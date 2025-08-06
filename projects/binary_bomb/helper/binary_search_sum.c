#include <stdio.h>

int binary_search_sum(int target,long low,int high)

{
  int rec;
  int mid;
  
  mid = (high - (int)low) / 2 + (int)low;
  if (target < mid) {
    rec = binary_search_sum(target,low,mid + -1);
    mid = mid + rec;
  }
  else if (mid < target) {
    rec = binary_search_sum(target,(unsigned long)(mid + 1),high);
    mid = mid + rec;
  }
  return mid;
}

int main(){
  for(int i = 0; i < 14; ++i)
    printf("%i -> %i\n", i, binary_search_sum(i, 0, 14));
  return 0;
}
