#include <stdio.h>
#include <stdint.h>

int solve(int array[], int index){
  int sum = 0;
  int counter = 0;
  do {
    counter = counter + 1;
    index = array[index];
    sum = sum + index;
  } while (index != 0xf);
  index = 0xf;
  if (counter == 0xf) return sum;
  return -1;
}

int main(){
  int array[] = {10, 2, 14, 7, 8, 12, 15, 11, 0, 4, 1, 13, 3, 9, 6, 5};
  int sum = 0;
  for(int i = 0; i < 15; ++i){
    sum = solve(array, i);
    if(sum == -1) continue;
    printf("%i %i", i, sum);
  }
}
