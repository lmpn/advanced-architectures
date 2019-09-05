import numpy as np
def print_mt():
    for i in range(0,8,4):
        for j in range(0,8,4):
            for ii in range(i,i+4):
                for jj in range(j,j+4):
                    print(str(jj) + str(ii) +" "+ str(jj*8 + ii) , end=" ")
                print()
def print_m():
    for i in range(0,8,4):
        for j in range(0,8,4):
            for ii in range(i,i+4):
                for jj in range(j,j+4):
                    print(str(ii) + str(jj) +" "+str(ii*8+jj), end=" ")
                print()


def transpose(mat,n,bsize):
    print(mat)
    for i in range(0,n): 
        for j in range(i+1,n): 
            temp = mat[j][i] 
            mat[j][i] = mat[i][j] 
            mat[i][j] = temp
    print(mat)

def mult_ijk(a,b,c):
    for i in range(0,8):
        for j in range(0,8): 
            for k in range(0,8):
                c[i][j] += a[i][k] * b[k][j]
    print(c)

def mult_ijk_wt(a,b,c):
    b = b.transpose()
    for i in range(0,8):
        for j in range(0,8): 
            for k in range(0,8):
                c[i][j] += a[i][k] * b[j][k]
    print(c)    

def b_mult_ijk_wt(a,b,c):
    b = b.transpose()

    for br in range(0,8,4):
        for bc in range(0,8,4):
            for i in range(0,8):
                for j in range(br,br+4): 
                    for k in range(bc,bc+4):
                        c[i][j] += a[i][k] * b[j][k]
    print(c)



def mult_jki(a,b,c):
    for j in range(0,8):
        for k in range(0,8): 
            for i in range(0,8):
                c[i][j] += a[i][k] * b[k][j]
    print(c)

def mult_jki_wt(a,b,c):
    a = a.transpose()
    b = b.transpose()
    for j in range(0,8):
        for k in range(0,8): 
            for i in range(0,8):
                c[i][j] += a[k][i] * b[j][k]
    c = c.transpose()
    print(c)


def b_mult_jki_wt(a,b,c):
    a = a.transpose()
    b = b.transpose()

    for br in range(0,8,4):
        for bc in range(0,8,4):
            for j in range(0,8):
                for k in range(br,br+4): 
                    for i in range(bc,bc+4):
                        c[i][j] += a[k][i] * b[j][k]
    print(c)



def mult_ikj(a,b,c):
    for i in range(0,8):
        for k in range(0,8): 
            for j in range(0,8):
                c[i][j] += a[i][k] * b[k][j]
    print(c)


def b_mult_ikj(a,b,c):
    for br in range(0,8,4):
        for bc in range(0,8,4):
            for i in range(0,8):
                for k in range(br,br+4): 
                    for j in range(bc,bc+4):
                        c[i][j] += a[i][k] * b[k][j]
    print(c)


a = np.array([np.array([j for j in range(8)]) for i in range(8)])
b = np.array([np.array([1 for j in range(8)]) for i in range(8)])
c = np.array([np.array([0 for j in range(8)]) for i in range(8)])
mult_jki_wt (a,b,c)
