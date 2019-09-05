#ifndef UTILS
#define UTILS
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <vector>
#include <iostream>
#include <cstdlib>
#include <mm_malloc.h>
//#include <papi.h>


#define RAM "RAM"
#define L1MR "l1mr"
#define L2MR "l2mr"
#define L3MR "l3mr"
#define FLOPS "flops"
#define VFLOPS "vflops"
#define TIME_RESOLUTION 1000000

using namespace std;

double utils_time();
int    utils_init_matrices(float **a, float **b, float **c, int N);
int    utils_clean_matrices(float **a, float **b, float **c);
void   utils_clear_cache(void);
void utils_stop_papi(int rep,const char *type);
void utils_start_papi(const char *type);
void utils_results(const char *type);
void utils_setup_papi(int repetitions, const char *type);
void utils_stop_timer(void);
void utils_start_timer(void);
int utils_init_matrices_out(float **a, float **b, float **c, int N, int threads);

#endif
