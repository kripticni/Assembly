#include <stdio.h>
#include <stdint.h>

extern void absoluteArray(int16_t* arr);

//void absoluteArray(int16_t* arr){
//for(int i=0;i<4;i++){
//  if(arr[i]<0)
//    arr[i] = arr[i] *(-1);
//}

int main(){
  int16_t arr[] = {-1, -5, -7, -8};
  absoluteArray(arr);

  for(int i=0;i<4;i++){
    printf("%i\n", arr[i]);
  }
}
