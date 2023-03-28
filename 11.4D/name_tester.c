#include <stdio.h>
#include <string.h>
#include "./terminal_user_input.h"

#define LOOP_COUNT 60

void print_silly_name(my_string name)
{
  printf("%s is a\n", name.str);
  for (int i = 0; i < LOOP_COUNT; i++)
  {
    printf(" silly");
  }
  printf("\n name!\n");
}

int main()
{
  my_string name;
  int index;
 
  name = read_string("What is your name? ");

  printf("Your name is: %s\n", name.str);

  if (strcmp(name.str, "Khang") == 0 || strcmp(name.str, "Tran") == 0)
  {
    printf("%s is an AWESOME name!", name.str);
  } else {
    print_silly_name(name);
  }

  return 0;
}