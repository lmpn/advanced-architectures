#include <cstdlib>
#include <iostream>
#include <mm_malloc.h>
#include <stdio.h>  /* printf, scanf, puts, NULL */
#include <stdlib.h> /* srand, rand */
#include <sys/time.h>
#include <time.h> /* time */

using namespace std;
int f = 0;
#define BLOCK_SIZE 32
#define GRID_SIZE 75

cudaEvent_t start, stop;

void startKernelTime(void)
{
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
}

void stopKernelTime(void)
{
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    cout << milliseconds << " ms have elapsed for the CUDA execution" << endl;
}

void checkCUDAError(const char *msg)
{
    cudaError_t err = cudaGetLastError();
    if (cudaSuccess != err)
    {
        cerr << "Cuda error: " << msg << ", " << cudaGetErrorString(err) << endl;
        exit(-1);
    }
}

__global__ void matrixMultKernel(float *a, float *b, float *c, int n)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    float sum = 0;
    if (col < n && row < n)
    {
        for (int i = 0; i < n; i++)
        {
            sum += a[row * n + i] * b[i * n + col];
        }
        c[row * n + col] = sum;
    }
}
__global__ void kernel_mm(float *d_a, float *d_b, float *d_result, int n)
{
     __shared__ int tile_a[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ int tile_b[BLOCK_SIZE][BLOCK_SIZE];

    int row = blockIdx.y * BLOCK_SIZE + threadIdx.y;
    int col = blockIdx.x * BLOCK_SIZE + threadIdx.x;
    int tmp = 0;
    int idx;

    for (int sub = 0; sub < gridDim.x; ++sub) 
    {
        idx = row * n + sub * BLOCK_SIZE + threadIdx.x;
        if(idx >= n*n)
        {
            // n may not divisible by BLOCK_SIZE
            tile_a[threadIdx.y][threadIdx.x] = 0;
        }
        else
        {
            tile_a[threadIdx.y][threadIdx.x] = d_a[idx];
        }

        idx = (sub * BLOCK_SIZE + threadIdx.y) * n + col;
        if(idx >= n*n)
        {
            tile_b[threadIdx.y][threadIdx.x] = 0;
        }  
        else
        {
            tile_b[threadIdx.y][threadIdx.x] = d_b[idx];
        }
        __syncthreads();

        for (int k = 0; k < BLOCK_SIZE; ++k) 
        {
            tmp += tile_a[threadIdx.y][k] * tile_b[k][threadIdx.x];
        }
        __syncthreads();
    }
    if(row < n && col < n)
    {
        d_result[row * n + col] = tmp;
    }
}


__global__ void kernel_mm2(float *d_a, float *d_b, float *d_result, int n)
{
    float tile_a[BLOCK_SIZE];
    float tile_b[BLOCK_SIZE];
    int gs = GRID_SIZE * BLOCK_SIZE;
    int gg = GRID_SIZE * GRID_SIZE;
    int tx = threadIdx.y;
    int ty = threadIdx.x;
    int row = blockIdx.y * BLOCK_SIZE + threadIdx.y;
    int col = blockIdx.x * BLOCK_SIZE + threadIdx.x;
    float tmp = 0;
    
    for (size_t i = 0; i < GRID_SIZE; i++)
    {
        tile_a[tx * BLOCK_SIZE + ty] = d_a[i * BLOCK_SIZE + tx * gs + ty];
        tile_b[tx * BLOCK_SIZE + ty] = d_b[i * gg + tx * gs + ty];
        __syncthreads();
        for (int i=0; i<BLOCK_SIZE; i++)
        {
            tile_a[i] += __shfl(-1, tile_a[i], i);
            tile_b[i] += __shfl(-1, tile_b[i], i);
        }
        
        for (size_t i = 0; i < BLOCK_SIZE; i++)
        {
            tmp += tile_a[tx * i + i] * tile_b[ty * i + i];
        }
    }

    d_result[row * n + col] = tmp;
}

__global__ void bmatrixMultKernel(float *d_a, float *d_b, float *d_result, int n)
{
    __shared__ float tile_a[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ float tile_b[BLOCK_SIZE][BLOCK_SIZE];

    int row = blockIdx.y * BLOCK_SIZE + threadIdx.y;
    int col = blockIdx.x * BLOCK_SIZE + threadIdx.x;
    float tmp = 0;
    int idx;

    for (int sub = 0; sub < gridDim.x; ++sub)
    {
        idx = row * n + sub * BLOCK_SIZE + threadIdx.x;
        if (idx >= n * n)
        {
            // n may not divisible by BLOCK_SIZE
            tile_a[threadIdx.y][threadIdx.x] = 0;
        }
        else
        {
            tile_a[threadIdx.y][threadIdx.x] = d_a[idx];
        }

        idx = (sub * BLOCK_SIZE + threadIdx.y) * n + col;
        if (idx >= n * n)
        {
            tile_b[threadIdx.y][threadIdx.x] = 0;
        }
        else
        {
            tile_b[threadIdx.y][threadIdx.x] = d_b[idx];
        }
        __syncthreads();

        for (int k = 0; k < BLOCK_SIZE; ++k)
        {
            tmp += tile_a[threadIdx.y][k] * tile_b[k][threadIdx.x];
        }
        __syncthreads();
    }
    if (row < n && col < n)
    {
        d_result[row * n + col] = tmp;
    }
}

float *stencilGPU(float *a, float *b, int size)
{
    float *dev_a, *dev_b, *dev_c;
    float *c = new float[size * size];

    cudaMalloc((void **)&dev_a, size * size * sizeof(float));
    cudaMalloc((void **)&dev_b, size * size * sizeof(float));
    cudaMalloc((void **)&dev_c, size * size * sizeof(float));

    startKernelTime();
    cudaMemcpy(dev_a, a, size * size * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, size * size * sizeof(float), cudaMemcpyHostToDevice);
    stopKernelTime();

    startKernelTime();
    if (f == 0)
    {
        dim3 dimGrid(size, size);
        dim3 dimBlock(1, 1);
        matrixMultKernel<<<dimGrid, dimBlock>>>(dev_a, dev_b, dev_c, size);
    }
    else
    {
        dim3 dimGrid(75, 75);
        dim3 dimBlock(32, 32);
        // bmatrixMultKernel <<< dimGrid, dimBlock >>>(dev_a, dev_b, dev_c, size);
        kernel_mm<<<dimGrid, dimBlock>>>(dev_a, dev_b, dev_c, size);
    }
    stopKernelTime();

    startKernelTime();
    cudaMemcpy(c, dev_c, size * size * sizeof(float), cudaMemcpyDeviceToHost);
    stopKernelTime();

    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    for(size_t i = 0; i < 2400; i++)
    {
       for(size_t j = 0; j < 2400; j++)
       {
           printf("%lf ", c[i*2400 + j]);
       }
        printf("\n");
    }
    

    return c;
}

int init_matrices(float **a, float **b, int N)
{
    int i;
    const int total_elements = N * N;
    *a = (float *)_mm_malloc(N * N * sizeof(float), 32);
    *b = (float *)_mm_malloc(N * N * sizeof(float), 32);
    for (i = 0; i < total_elements; i++)
    {
        (*b)[i] = 1;
        (*a)[i] = ((float)rand()) / ((float)RAND_MAX);
    }
    return 1;
}

int main(int argc, char **argv)
{
    int size = atoi(argv[1]);
    f = atoi(argv[2]);
    printf("%d ", f);
    float *a, *b;
    init_matrices(&a, &b, size);
    for (int i = 0; i < 1; i++)
    {
        stencilGPU(a, b, size);
        printf("i = %d\n", i);
    }
    return 0;
}
