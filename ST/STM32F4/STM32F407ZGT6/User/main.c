#include "sys.h"
#include "delay.h"
#include "led.h"
#include "usart.h"

int main(void)
{
  u32 len = 0;
  /* u16 times = 0; */

  HAL_Init();
  Stm32_Clock_Init(366,8,2,7);
  delay_init(168);
  led_init();
  usart1_init(115200);
  while(1){
    LED0 = !LED0;
    printf("OK\n");
    len += 1;
    /* printf("you choice: %s\n",STM32_CHIP); */
    delay_ms(100);
  }
}
/*     if(USART1_RX_STA & 0x80000000){ */
/*       len = USART1_RX_STA & 0x3fffffff; */
/*       printf("you are sending message：\n"); */
/*       HAL_UART_Transmit(&USART1_Handler, (uint8_t*)USART1_RX_BUF,len, 1000); */
/*       while(__HAL_UART_GET_FLAG(&USART1_Handler, UART_FLAG_TC) != SET); */
/*       printf("\n"); */
/*       USART1_RX_STA = 0; */
/*     }else{ */
/*       times++; */
/*       if(times % 5000 == 0){ */
/*         /\* printf("this is a test of stm32f407zgt6 about usart\n"); *\/ */
/*       } */
/*       if(times%200 == 0){ */
/*         /\* printf("plese input data and type enter to end of the send\n"); *\/ */
/*       } */
/*       if(times%30 == 0){ */
/*         LED0 = !LED0; */
/*       } */
/*       delay_ms(10); */
/*     } */
/*   } */
/* } */
