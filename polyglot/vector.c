#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct Vector
{
    int size,max_size;
    int size_e;
    void *d;
} Vector;
Vector new_Vector(int sz)
{
    Vector res;
    res.size_e=sz;
    res.max_size=1;
    res.size=0;
    res.d=(void *)malloc(res.size_e*res.max_size);
    return res;
}
void generate(Vector *v)
{
    v->max_size*=2;
    void *tmp=(void *)malloc(v->max_size*v->size_e);
    memcpy(tmp,v->d,v->size*v->size_e);
    v->d=tmp;
}
void push_back(Vector *v,void *ptr)
{
    if(v->size==v->max_size)
    {
	generate(v);
    }
    memcpy(v->d+(v->size_e*v->size),ptr,v->size_e);
    v->size++;
}
void pop_back(Vector *v)
{
    if(v->size==0)return;
    v->size--;
    return;
}
void* at(Vector *v,int idx)
{
    if(idx>=v->size)return NULL;
    void *ptr=malloc(v->size_e);
    memcpy(ptr,v->d+(idx*v->size_e),v->size_e);
    return ptr;
}
int main()
{
    Vector v=new_Vector(sizeof(int));
    int *ptr=(int *)malloc(sizeof(int));
    *ptr=10;
    push_back(&v,ptr);
    //pop_back(&v);
    printf("size : %d\n",v.size);
    printf("%d\n",*((int *)(at(&v,0))));
    return 0;
}
