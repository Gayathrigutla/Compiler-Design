#include<stdio.h>
int main() {
int a=0;
/*for loop execution*/
for(a=a+1; a<(16+4); a=a+1+a);{
	printf("value of a:%d\n",a);
	a+=1.0;
}
return 0;
}
