#include <stdio.h>

extern int FindMax(int *i, int count);


int main(){
  int arr[10] = {1, 6, 3, 4, 5, 2, 7, 8, 9};
  printf("The maximum is %i", FindMax(arr, 9));
}
