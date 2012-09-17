#include <string.h>
#include <stdio.h>     
#include <stdlib.h>     
#include <sys/types.h>     
#include <unistd.h>     

#define MAXLINE 2048

//copy file from fp1 to fp2
int copyfile(FILE* fp1, FILE* fp2)
{
	char buf[MAXLINE];
	while (fgets(buf, MAXLINE, fp1) != NULL)
	{
		printf("%s", buf);
		//if (fputs(buf, fp2) == EOF)
		//{
		//	printf("output error\n");
		//	return 1;
		//}
	}
	if (ferror(fp1))
	{
		printf("input error\n");
		return 1;
	}
	return 0;
}

int main(int argc, char* argv[])    
{    
	uid_t uid ,euid;    
	char cmd[1024];
	int i; 
  	int length;
	FILE* fp;
	uid = getuid() ;    
	euid = geteuid();   
	
	printf("my uid :%u\n",getuid()); //这里显示的是当前的uid 可以注释掉.     
	printf("my euid :%u\n",geteuid()); //这里显示的是当前的euid 
	if(setreuid(euid, uid)) //交换这两个id     
	perror("setreuid");
	printf("after setreuid uid :%u\n",getuid());    
	printf("afer sertreuid euid :%u\n",geteuid()); 	
	
	sprintf(cmd, "./postaccountadmin.sh");
	length = strlen("./postaccountadmin.sh");
	for (i = 1; i < argc; i++)
	{
		sprintf(cmd + length," %s", argv[i]);
		length += (strlen(argv[i])+1); 
	}
	sprintf(cmd + length," > runtmp");
	printf ("this is run. cmd is:%s\n", cmd);
	system(cmd);


	fp = fopen("runtmp", "r");
	if (fp != NULL)
	{
		copyfile(fp ,stdout);		
	}
	else
	{
		printf("can not read the result.\n");
	}
	fclose(fp);
	return 0; 
}   
