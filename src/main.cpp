#include <utils.h>
#include <dot_product.h>
using namespace std;

float __attribute__( ( aligned ( 64 ) ) ) *a;
float __attribute__( ( aligned ( 64 ) ) ) *b;
float __attribute__( ( aligned ( 64 ) ) ) *c;

void (*dp_func)(float *, float *, float *, int);
void (*dp_func_out)(float *, float *, float *, int, int);
void p (int N) {
for (int k=0;k<N;k++) {
                for(int j=0;j<N;j++) {
                    printf("%f ",c[k*N+j] );
                }
                printf("\n");
            }

}
int main(int argc, char const *argv[])
{
    //bin/dot_product alg_num type(time|l1mr|l2mr|l3mr|flops|vecops) N(150|300|750|1050)
    if (argc < 5)
    {
        cout << "usage: bin/dot_product alg_num repetitions size(150|300|750|1050) type(time|l1mr|l2mr|l3mr|flops|vecops) bsize(opt)" << endl;
        return 1;
    }

    if (argv[5] != NULL)
    {
        dot_product_set_bsize(atoi(argv[5]));
    }

    int N = atoi(argv[3]);
    int repetitions = atoi(argv[2]);
    int dp_version = atoi(argv[1]);
    switch (dp_version)
    {
    case 1:
        dp_func = &ijk;
        break;
    case 2:
        dp_func = &jki;
        break;
    case 3:
        dp_func = &ikj;
        break;
    case 4:
        dp_func = &ijk_transpose;
        break;
    case 5:
        dp_func = &jki_transpose;
        break;
    case 6:
        dp_func = &ijk_block;
        break;
    case 7:
        dp_func = &jki_block;
        break;
    case 8:
        dp_func= &ikj_block;
        break;
    case 9:
        dp_func = &ijk_vec;
        break;
    case 10:
        dp_func= &jki_vec;
        break;
    case 11:
        dp_func= &ikj_vec;
        break;
    case 12:
        dp_func_out= &ijk_par;
        break;
    case 13:
        dp_func_out= &jki_par;
        break;
    case 14:
        dp_func_out= &ikj_par;
        break;
    case 15:
        dp_func_out= &ikj_knl;
        break;
    }
    if(dp_version < 12)
    {        
        utils_setup_papi(repetitions,argv[4]);
        for(size_t i = 0; i < repetitions; i++)
        {
            utils_init_matrices(&a,&b,&c,N);
            utils_clear_cache();
            utils_start_papi(argv[4]);
            utils_start_timer();
            dp_func(a,b,c,N);
            //p(N);
            utils_stop_timer();
            utils_stop_papi(i, argv[4]);
            utils_clean_matrices(&a,&b,&c);
        }
        utils_results(argv[4]);
    }
    else
    {
        int th = atoi(argv[6]);
        for(size_t i = 0; i < repetitions; i++)
        {
            utils_init_matrices(&a,&b,&c,N);
            utils_clear_cache();
            utils_start_timer();
            dp_func_out(a,b,c,N,th);
            utils_stop_timer();
            utils_clean_matrices(&a,&b,&c);
        }
        utils_results(argv[4]);
    }
    
}
