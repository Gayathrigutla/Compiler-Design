#include<stdio.h>

int main()
{
	int v = 5, c = 6; 
	while(v > 0)
	{
		printf("%d",v);
		v--;
	}
	if(v == 0)
	{
		printf("%d", 2*v + 2);
		v++;
		while(c>0)
		{
			printf("%d is positive\n", c);
			c--;
		}
	}
	else
		printf("negative\n");
}
