#include <stdio.h>
#include <unistd.h>


int main(int argc, char *argv[])
{
  printf("Hello world\n");
  //test printf with floats
  printf("Value of Pi = %f\n\n", 3.1415);
  sleep(10);
  printf("Finished Timer!\n\n");
  char c = 0x4;
  putc(c, stdout);
}
