#include <dot_product.h>
#include <iostream>
#include <immintrin.h>
using namespace std;
unsigned bsize = 1;

//1 2 4 5 7
void dot_product_set_bsize(int _bsize)
{
    bsize = _bsize;
}
void transpose(float *m, int n)
{
    for (unsigned i = 0; i < n; i++)
    {
        for (unsigned j = i + 1; j < n; j++)
        {
            m[i * n + j] = m[j * n + i];
            m[j * n + i] = m[i * n + j];
        }
    }
}

//ijk
void ijk(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    for (unsigned i = 0; i < n; i++)
        for (unsigned j = 0; j < n; j++)
        {
            unsigned in = i * n;
            float temp = 0.0;
            for (unsigned k = 0; k < n; k++)
                temp += a[in + k] * b[k * n + j];
            c[in + j] = temp;
        }
}

//ijk transpose
void ijk_transpose(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    transpose(b, n);
    for (unsigned i = 0; i < n; i++)
        for (unsigned j = 0; j < n; j++)
        {
            unsigned in = i * n;
            unsigned jn = j * n;
            float temp = 0.0;
            for (unsigned k = 0; k < n; k++)
                temp += a[in + k] * b[jn + k];
            c[in + j] = temp;
        }
}

//ijk transpose block
void ijk_block(
    float *__restrict__ a, 
    float *__restrict__ b, 
    float *__restrict__ c, int n)
{
    transpose(b, n);
    for (unsigned br = 0; br < n; br += bsize){
        for (unsigned bc = 0; bc < n; bc += bsize){
            for (unsigned i = 0; i < n; i++){
                unsigned upBr = br + bsize;
                for (unsigned j = br; j < upBr; j++)
                {
                    unsigned in = i * n;
                    unsigned jn = j * n;
                    float temp = 0.0;
                    unsigned upBc = bc + bsize;
                    for (unsigned k = bc; k < upBc; k++){
                        temp += a[in + k] * b[jn + k];
                    }
                    c[in + j] = temp;
                }
            }
        }
    }
}


void ijk_vec(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    transpose(b, n);
    for (unsigned br = 0; br < n; br += bsize)
        for (unsigned bc = 0; bc < n; bc += bsize)
            for (unsigned i = 0; i < n; i++)
                for (unsigned j = br; j < br + bsize; j++)
                {
                    for (unsigned k = bc; k < bc + bsize; k++)
                        c[i*n+j] += a[i*n + k] * b[j*n + k];
                }
}



void jki(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    for (unsigned j = 0; j < n; j++)
        for (unsigned k = 0; k < n; k++)
        {
            float bkj = b[k * n + j];
            for (unsigned i = 0; i < n; i++)
                c[i * n + j] += a[i * n + k] * bkj;
        }
}

//jki transpose
void jki_transpose(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    transpose(a, n);
    transpose(b, n);
    for (unsigned j = 0; j < n; j++)
        for (unsigned k = 0; k < n; k++)
        {
            unsigned jn = j * n;
            unsigned kn = k * n;
            float bjk = b[jn + k];
            for (unsigned i = 0; i < n; i++)
                c[jn + i] += a[kn + i] * bjk;
        }
    transpose(c, n);
}


void jki_block(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    transpose(a, n);
    transpose(b, n);
    for (unsigned br = 0; br < n; br += bsize){
        for (unsigned bc = 0; bc < n; bc += bsize){
            for (unsigned j = 0; j < n; j++){
                unsigned upBr = br + bsize;
                for (unsigned k = br; k < upBr; k++)
                {
                    unsigned jn = j * n;
                    unsigned kn = k * n;
                    float bjk = b[jn + k];
                    unsigned upBc = bc + bsize;
                    for (unsigned i = bc; i < upBc; i++){
                        c[jn + i] += a[kn + i] * bjk;
                    }
                }
            }
        }
    }
    transpose(c, n);
}

void jki_vec(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    transpose(a, n);
    transpose(b, n);
    for (unsigned br = 0; br < n; br += bsize)
        for (unsigned bc = 0; bc < n; bc += bsize)
            for (unsigned j = 0; j < n; j++)
                for (unsigned k = br; k < br + bsize; k++)
                {
                    for (unsigned i = bc; i < bc + bsize; i++)
                        c[j*n + i] += a[k*n + i] * b[j*n + k];
                }
    transpose(c, n);
}

//ikj
void ikj(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    for (unsigned i = 0; i < n; i++)
        for (unsigned k = 0; k < n; k++)
        {
            unsigned in = i * n;
            unsigned kn = k * n;
            float aik = a[in + k];
            for (unsigned j = 0; j < n; j++)
                c[in + j] += aik * b[kn + j];
        }
}

//ikj block
void ikj_block(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    for (unsigned br = 0; br < n; br += bsize){
        for (unsigned bc = 0; bc < n; bc += bsize){
            for (unsigned i = 0; i < n; i++){
                unsigned upBr = br + bsize;
                for (unsigned k = br; k < upBr; k++)
                {
            	    unsigned in = i * n;
                    unsigned kn = k * n;
		            unsigned upBc = bc+bsize;
                    float aik = a[in + k];
                    for (unsigned j = bc; j < upBc; j++)
                    {
                        c[in+j] += aik * b[kn+j];
                    }
                }
            }
        }
    }
}
//vec
void ikj_vec(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n)
{
    for (unsigned br = 0; br < n; br += bsize)
        for (unsigned bc = 0; bc < n; bc += bsize)
            for (unsigned i = 0; i < n; i++)
                for (unsigned k = br; k < br + bsize; k++)
                {
                    for (unsigned j = bc; j < bc + bsize; j++)
                    {
                        c[i*n + j] += a[i*n+ k] * b[k*n + j];
                    }
                }
}







void jki_par(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n, int threads)
{
    transpose(a, n);
    transpose(b, n);
#pragma omp parallel num_threads(threads)
    {
        for (unsigned br = 0; br < n; br += bsize)
            for (unsigned bc = 0; bc < n; bc += bsize)
#pragma omp for
                for (unsigned j = 0; j < n; j++)
                    for (unsigned k = br; k < br + bsize; k++)
                    {
#pragma omp simd
                        for (unsigned i = bc; i < bc + bsize; i++)
                            c[j * n + i] += a[k * n + i] * b[j * n + k];
                    }
    }
    transpose(c, n);
}
void ijk_par(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n,int threads)
{
    transpose(b, n);
#pragma omp parallel num_threads(threads)
    {
        for (unsigned br = 0; br < n; br += bsize)
            for (unsigned bc = 0; bc < n; bc += bsize)
#pragma omp for
                for (unsigned i = 0; i < n; i++)
                    for (unsigned j = br; j < br + bsize; j++)
                    {
#pragma omp simd 
                        for (unsigned k = bc; k < bc + bsize; k++)
                            c[i * n + j] += a[i * n + k] * b[j * n + k];
                    }
    }
}




void ikj_knl(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n, int threads)
{

#pragma omp parallel num_threads(threads)
    {
        unsigned i, j, k;
        for (unsigned br = 0; br < n; br += bsize)
            for (unsigned bc = 0; bc < n; bc += bsize)
#pragma omp for
                for (unsigned i = 0; i < n; i++)
                    for (unsigned k = br; k < br + bsize; k++)
                    {
#pragma omp simd
                        for (unsigned j = bc; j < bc + bsize; j++)
                        {
                            c[i * n + j] += a[i * n + k] * b[k * n + j];
                        }
                    }
    }
}

void ikj_par(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n, int threads)
{
#pragma omp parallel num_threads(threads)
    {
        unsigned i, j, k;
        for (unsigned br = 0; br < n; br += bsize)
            for (unsigned bc = 0; bc < n; bc += bsize)
#pragma omp for
                for (unsigned i = 0; i < n; i++)
                    for (unsigned k = br; k < br + bsize; k++)
                    {
#pragma vector aligned
# pragma prefetch a:1:8
# pragma prefetch b:1:8
# pragma prefetch c:1:8
                        for (unsigned j = bc; j < bc + bsize; j+=8)
                        {
                            c[i * n + j:8] += a[i * n + k:8] * b[k * n + j:8];
                        }
                    }
    }
}
