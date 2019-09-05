#include <cstdlib>
#include <iostream>
#include <sys/time.h>
#include <mm_malloc.h>
#include <stdlib.h>

#define BLOCK_SIZE 16
#define GRID_SIZE 150
using namespace std;
cudaEvent_t start, stop;

int validate(float *c, int n) {
    //all resulting columns should have the same values
    for(unsigned i = 0; i < n*n ; i += n) {
        float tmp = c[i];
        for(unsigned j = 0; j < n; j++) {
            if(c[i + j] != tmp) return 0;
        }
    }
    return 1;
}
void startStopWatch () {
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start);
}

void stopStopWatch () {
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	float time = 0;
	cudaEventElapsedTime(&time, start, stop);
	cout << time << " ms." << endl;
}

__global__ void kernel_mm3(float *d_a, float *d_b, float *d_result, int n)
{
    float tile_a[BLOCK_SIZE];
    float tile_b[BLOCK_SIZE];
    int gs = GRID_SIZE * BLOCK_SIZE;
    int gg = GRID_SIZE * GRID_SIZE;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    float tmp = 0;

    for (size_t i = 0; i < GRID_SIZE; i++)
    {
        tile_a[tx * BLOCK_SIZE + ty] = d_a[i * BLOCK_SIZE + tx * gs + ty];
        tile_b[tx * BLOCK_SIZE + ty] = d_b[i * gg + tx * gs + ty];
        __syncthreads();
        for (int i=0; i<BLOCK_SIZE; i++)
        {
            tile_a[i] += __shfl_sync(-1, tile_a[i], i);
            tile_b[i] += __shfl_sync(-1, tile_b[i], i);
        }

        for (size_t i = 0; i < BLOCK_SIZE; i++)
        {
            tmp += tile_a[tx * i + i] * tile_b[ty * i + i];
        }
    }

    d_result[tx * n + ty] = tmp;
}



__global__ void kernel_mm2(float *d_a, float *d_b, float *d_result, int n)
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

__global__ void kernel_mm(float *d_a, float *d_b, float *d_result, int n)
{
    __shared__ float tile_a[BLOCK_SIZE * BLOCK_SIZE];
    __shared__ float tile_b[BLOCK_SIZE * BLOCK_SIZE];
    
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    float tmp = 0;





    int startA = by * n * BLOCK_SIZE; // 0 
    int stepA  = BLOCK_SIZE;
    int endA   = by * n * BLOCK_SIZE + n; // 8 
    int startB = bx * BLOCK_SIZE;
    int stepB  = BLOCK_SIZE * n;
    int endB   = BLOCK_SIZE * stepB; 
    
    for (size_t a = startA, size_t b = startB; a < endA; a+=stepA, b+=stepB)
    {
        tile_a[ty * BLOCK_SIZE + tx] = d_a[a+tx+ty*n];
        tile_b[ty * BLOCK_SIZE + tx] = d_b[b+tx+ty*n];
        __syncthreads();
        for (size_t i = 0; i < BLOCK_SIZE; i++)
        {
            tmp += tile_a[ty * BLOCK_SIZE + i] * tile_b[i * BLOCK_SIZE + tx];
        }
	__syncthreads();
    }

    d_result[tx * n + ty] = tmp;
}

__global__
void multMat(float *a,float *b, float *c, int N){
    int linha=blockIdx.y*blockDim.y+threadIdx.y;
    int coluna=blockIdx.x*blockDim.x+threadIdx.x;
    float sum=0;
    if(coluna<N&&linha<N){
        for(int i=0;i<N;i++)sum+=a[linha*N+i]*b[i*N+coluna];
        c[linha*N+coluna]=sum;
    }
}


void checker(float *c, int N){
    if (cudaSuccess==cudaGetLastError() && validate(c,N)){
        cout << "NO ERROR" << endl;
    }
    else{
        cout << "There was an error" << endl;
    }
}
void stencil(float *a, float *b, float *c, int N){
    float *devA,*devB, *devC;
    int NQ = N*N;
    cudaMalloc((void**) &devA, NQ * sizeof(float));
    cudaMalloc((void**) &devB, NQ * sizeof(float));
    cudaMalloc((void**) &devC, NQ * sizeof(float));

    startStopWatch();
	cudaMemcpy(devA,a,NQ*sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(devB,b,NQ*sizeof(float),cudaMemcpyHostToDevice);
    stopStopWatch();
    dim3 dimGrid(150,150);
    dim3 dimBlock(16,16);
    startStopWatch();
    kernel_mm3<<<dimGrid,dimBlock>>>(devA,devB,devC,N);
    stopStopWatch();
    startStopWatch();
    cudaMemcpy(c,devC,NQ*sizeof(float),cudaMemcpyDeviceToHost);
    stopStopWatch();
    cudaFree(devA);
    cudaFree(devB);
    cudaFree(devC);
}

void newMatrices(float **a, float **b, float **c, int N){
    int i;
    int NQ = N*N;
    *a = (float *)_mm_malloc(NQ * sizeof(float), 32);
    *b = (float *)_mm_malloc(NQ * sizeof(float), 32);
    *c = (float *)_mm_malloc(NQ * sizeof(float), 32);
    for (i = 0; i < NQ; i++){
        (*b)[i] = 1;
        (*a)[i] = ((float)rand()) / ((float)RAND_MAX);
    }
}

int main (int argc, char** argv) {
  	int N = atoi(argv[1]);
    srand(0);
	float *a,*b,*c;
    newMatrices(&a,&b,&c,N);
    stencil(a,b,c,N);
    checker(c,N);
	return 0;
}