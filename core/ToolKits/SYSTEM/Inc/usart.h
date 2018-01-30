/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: usart.h
 *@Author: 林家俊
 *@Version: v1.0
 *@CreateDate: 2017-12-2
 *@Brief:
 *+串口初始化
 *--------------------------------------------------------------------------------------------------
 */
#ifndef _USART_H
#define _USART_H
#include "sys.h"

#define EN_USART1_RX 			  1     /* 使能（1）/禁止（0）串口1接收 */
#define USART1_REC_LEN  			200 /* 定义本次接收的数据包存放的数据缓冲区的最大字节数,这个参数受限于 USART1_RX_STA, 最大可以是2^30-1 */
#define USART1_RXBUFFERSIZE        1   /* 定义本次接收到的字符存放的数据暂存区的字节数 */
extern UART_HandleTypeDef USART1_Handler; /* 串口句柄 */
extern u8 USART1_RX_BUF[USART1_REC_LEN];   /* 数据缓冲区最大允许存放 USART_REC_LEN 个字节 */
extern u32 USART1_RX_STA;      /* bit31: 标识本次需要接收的数据包是否全部接收完毕; bit30: 标识是否接收到换行 0x0d; bit0~bit29: 标识已经接收到的字节数（最多为1GB-1） */
extern u8 USART1_RxBuffer[USART1_RXBUFFERSIZE];       /* 本次接收到的字符放到该变量下面暂存，方便进行解析，提取下一字符时会将其覆盖 */


#define EN_USART2_RX        0     /* 使能（1）/禁止（0）串口2接收 */

void usart1_init(u32 bound);
#endif
