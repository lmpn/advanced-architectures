#include <utils.h>
struct timeval t;
long long unsigned initial_time;
int numEvents;
long long **values;
vector<long long unsigned> *time_measurement = new vector<long long unsigned>();
double clearcache[30000000];
int *events;
//int eventSet = PAPI_NULL;

void utils_start_timer(void)
{
    gettimeofday(&t, NULL);
    initial_time = t.tv_sec * TIME_RESOLUTION + t.tv_usec;
}

void utils_stop_timer(void)
{
    gettimeofday(&t, NULL);
    long long unsigned final_time = t.tv_sec * TIME_RESOLUTION + t.tv_usec;
    time_measurement->push_back(final_time - initial_time);
}

void utils_stop_timer2(void)
{
    gettimeofday(&t, NULL);
    long long unsigned final_time = t.tv_sec * TIME_RESOLUTION + t.tv_usec;
    time_measurement->push_back(final_time - initial_time);
    cout << "Exec time GPU:" << time_measurement->at(0)/(double)1000 <<"ms"<<  endl;

}

int utils_clean_matrices(float **a, float **b, float **c)
{
    if (*a != NULL)
        free(*a);
    if (*b != NULL)
        free(*b);
    if (*c != NULL)
        free(*c);
    return 0;
}
int utils_init_matrices(float **a, float **b, float **c, int N)
{
    int i;
    float *ptr;
    srand(time(NULL));
    const int total_elements = N * N;
    *a = (float *)_mm_malloc(N * N * sizeof(float), 64);
    *b = (float *)_mm_malloc(N * N * sizeof(float), 64);
    *c = (float *)_mm_malloc(N * N * sizeof(float), 64);
    for (i = 0; i < total_elements; i++)
    {
        (*b)[i] = 1;
        (*a)[i] = ((float)rand()) / ((float)RAND_MAX);
        (*c)[i] = 0;
    }
    return 1;
}
int utils_init_matrices_out(float **a, float **b, float **c, int N, int threads)
{
    int i;
    float *ptr;
    const int total_elements = N * N * threads;
    *a = (float *)_mm_malloc(total_elements * sizeof(float), 64);
    *b = (float *)_mm_malloc(total_elements * sizeof(float), 64);
    *c = (float *)_mm_malloc(total_elements * sizeof(float), 64);
    for (i = 0; i < total_elements; i++)
    {
        (*b)[i] = 1;
        (*a)[i] = ((float)rand()) / ((float)RAND_MAX);
        (*c)[i] = 0;
    }
    return 1;
}
void utils_clear_cache(void)
{
    for (unsigned i = 0; i < 30000000; ++i)
        clearcache[i] = i;
}

void utils_setup_papi(int repetitions, const char *type)
{
    if (!strcmp(type, "time"))
    {
        return;
    }
 /*   else if (!strcmp(type, L1MR))
    {
        numEvents = 2;
        events = (int *)malloc(numEvents * sizeof(int));
        events[0] = PAPI_L1_DCM;
        events[1] = PAPI_LD_INS;
    }
    else if (!strcmp(type, L2MR))
    {
        numEvents = 2;
        events = (int *)malloc(numEvents * sizeof(int));
        events[0] = PAPI_L2_TCM;
        events[1] = PAPI_L1_DCM;
    }
    else if (!strcmp(type, RAM))
    {
        numEvents = 2;
        events = (int *)malloc(numEvents * sizeof(int));
        events[0] = PAPI_L3_TCM;
	events[1] = PAPI_TOT_INS;
    }
    else if (!strcmp(type, L3MR))
    {
        numEvents = 2;
        events = (int *)malloc(numEvents * sizeof(int));
        events[0] = PAPI_L3_TCM;
        events[1] = PAPI_L2_TCM;
    }
    else if (!strcmp(type, FLOPS))
    {
        numEvents = 1;
        events = (int *)malloc(numEvents * sizeof(int));
        events[0] = PAPI_FP_OPS;
    }
    else if (!strcmp(type, VFLOPS))
    {
        numEvents = 1;
        events = (int *)malloc(numEvents * sizeof(int));
        events[0] = PAPI_VEC_SP;
    }
    values = (long long **)malloc(sizeof(long long) * repetitions);
    for (int i = 0; i < repetitions; i++)
    {
        values[i] = (long long *)malloc(sizeof(long long) * numEvents);
    }
    PAPI_library_init(PAPI_VER_CURRENT);
    PAPI_create_eventset(&eventSet);
    PAPI_add_events(eventSet, events, numEvents);*/
}

void utils_results(const char *type)
{
    int repetitions = time_measurement->size();
    for (size_t i = 0; i < repetitions; i++)
    {
        if (!strcmp(type, "time"))
        {
            double tm = time_measurement->at(i) / (double)1000;
            cout << "Execution Time #" << i << ": " << tm << "ms" << endl;
        }/*
        else if (!strcmp(type, L1MR))
        {
            cout << values[i][0] <<";"<<values[i][1] << endl;
        }
        else if (!strcmp(type, L2MR))
        {
            cout << values[i][0] <<";"<<values[i][1] << endl;
        }
        else if (!strcmp(type, L3MR))
        {
            cout << values[i][0] <<";"<<values[i][1] << endl;
        }
        else if (!strcmp(type, FLOPS))
        {
            cout << values[i][0] << endl;
        }
        else if (!strcmp(type, RAM))
        {
            cout << values[i][0] <<";"<<values[i][1] << endl;
        }
        else if (!strcmp(type, VFLOPS))
        {
            cout << values[i][0] << endl;
        }*/
    }
}

void utils_start_papi(const char *type)
{
    if (strcmp(type, "time")){}
//        PAPI_start(eventSet);
}

void utils_stop_papi(int rep, const char *type)
{
    if (strcmp(type, "time")){}
 //       PAPI_stop(eventSet, values[rep]);
}
