#include "sys.h"
#include "delay.h"
#include "led.h"
#include "usart.h"

int main(void)
{
  MPU_Config();
  Cache_Enable();
  HAL_Init();
  Stm32_Clock_Init(432,25,2,9);

  while (1)
  {
    ;
  }
}
