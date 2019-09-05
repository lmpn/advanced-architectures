#ifndef DOT_PRODUCT
#define DOT_PRODUCT
#include <stdio.h>
void ijk_vec(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void dot_product_set_bsize(int _bsize);
void transpose(float *m, int n);
void ijk(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void ijk_transpose(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void ijk_block(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void jki(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void jki_transpose(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void jki_block(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void jki_vec(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void ikj(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void ikj_block(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void ikj_vec(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n);
void ikj_par(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n,int);
void jki_par(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n,int);
void ijk_par(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n, int );
void ikj_knl(float *__restrict__ a, float *__restrict__ b, float *__restrict__ c, int n, int threads);
#endif
