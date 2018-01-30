/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: delay.c
 *@Author: 林家俊
 *@Version: v1.0
 *@CreateDate: 2017-12-02
 *@Brief:
 *+ 实现串口的初始化
 *+ 实现 printf 数据流重定向到串口1
 *+ 实现中断接受串口数据
 *--------------------------------------------------------------------------------------------------
 */
#include "usart.h"

#if SYSTEM_SUPPORT_OS
#include "includes.h"           /* 使用OS */
#endif

/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: 林家俊
 *@LastestUpdate: 2017-01-02
 *@Note:
 *+ USARTx_RX_STA: 接收状态标识
 *+ USARTx_RX_BUF: 数据缓冲区，用于存储接收到的数据
 *+ USARTx_RxBuffer: 数据暂存区， 用于存储本次接受到的字符
 *--------------------------------------------------------------------------------------------------
 */
#if EN_USART1_RX
UART_HandleTypeDef USART1_Handler; /* 串口句柄 */
u8 USART1_RX_BUF[USART1_REC_LEN];   /* 数据缓冲区最大允许存放 USART_REC_LEN 个字节 */
u32 USART1_RX_STA=0;               /* bit31: 标识本次需要接收的数据包是否全部接收完毕; bit30: 标识是否接收到换行 0x0d; bit0~bit29: 标识已经接收到的字节数（最多为1GB-1） */
u8 USART1_RxBuffer[USART1_RXBUFFERSIZE];       /* 本次接收到的字符放到该变量下面暂存，方便进行解析，提取下一字符时会将其覆盖 */
#endif
#if EN_USART2_RX
UART_HandleTypeDef USART2_Handler;
u8 USART2_RX_BUF[USART2_REC_LEN];
u32 USART2_RX_STA=0;
u8 USART2_RxBuffer[USART2_RXBUFFERSIZE];
#endif
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: 林家俊
 *@LastestUpdate: 2017-12-29
 *@Function: 初始化串口1,该串口还用于数据流重定向
 *@Param: bound:波特率
 *@Return:无
 *--------------------------------------------------------------------------------------------------
 */
void usart1_init(u32 bound)
{
  USART1_Handler.Instance=USART1;
	USART1_Handler.Init.BaudRate=bound;
	USART1_Handler.Init.WordLength=UART_WORDLENGTH_8B;
	USART1_Handler.Init.StopBits=UART_STOPBITS_1;
	USART1_Handler.Init.Parity=UART_PARITY_NONE;
	USART1_Handler.Init.HwFlowCtl=UART_HWCONTROL_NONE;
	USART1_Handler.Init.Mode=UART_MODE_TX_RX; /* 收发模式 */
	HAL_UART_Init(&USART1_Handler);
  //该函数会开启接收中断：标志位UART_IT_RXNE，并且设置接收缓冲以及接收缓冲接收最大数据量
	HAL_UART_Receive_IT(&USART1_Handler, (u8 *)USART1_RxBuffer, USART1_RXBUFFERSIZE);
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: 林家俊
 *@LastestUpdate: 2017-12-02
 *@Function: UART底层初始化，时钟使能，引脚配置，中断配置
 *@Param: huart:串口句柄
 *@Return:无
 *@Note:
 *+ 此函数会被HAL_UART_Init()调用
  *--------------------------------------------------------------------------------------------------
 */
void HAL_UART_MspInit(UART_HandleTypeDef *huart)
{
	GPIO_InitTypeDef GPIO_Initure;

	if(huart->Instance == USART1){
		__HAL_RCC_GPIOA_CLK_ENABLE();
		__HAL_RCC_USART1_CLK_ENABLE();

		GPIO_Initure.Pin=GPIO_PIN_9;
		GPIO_Initure.Mode=GPIO_MODE_AF_PP;
		GPIO_Initure.Pull=GPIO_PULLUP;
		GPIO_Initure.Speed=GPIO_SPEED_FAST;
		GPIO_Initure.Alternate=GPIO_AF7_USART1;
    HAL_GPIO_Init(GPIOA,&GPIO_Initure);

		GPIO_Initure.Pin=GPIO_PIN_10;
		HAL_GPIO_Init(GPIOA,&GPIO_Initure);

#if EN_USART1_RX
		HAL_NVIC_EnableIRQ(USART1_IRQn);
		HAL_NVIC_SetPriority(USART1_IRQn,3,3);
#endif
	}
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: 林家俊
 *@LastestUpdate: 2018-01-02
 *@Function: 串口回调函数，该函数使用一个算法实现接收数据的逻辑
 *@Param: huart: 串口句柄
 *@Return:无
 *@Note:
 *+ 以(换行:0x0d-回车:0x0a)作为一次完整的接收，要求数据总是以\r\n结尾
 *+ USART_RX_STA 是一个 u16 的变量，该
 *--------------------------------------------------------------------------------------------------
 */
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
	if(huart->Instance == USART1){ /* USART1 */
		if((USART1_RX_STA & 0x80000000) == 0){ /*没有完成本次数据包的接收 */
			if(USART1_RX_STA & 0x40000000){      /* 已经接收到了换行字符 */
				if( USART1_RxBuffer[0]!=0x0a){      /* 本次接收到的不是回车字符 */
          USART1_RX_STA=0;       /* 正常情况下，换行的后面应当进跟着回车： 0x0a, 此处由于换行后面不是回车，则认定接收错误，将状态标识全部复位*/
        }else{
          USART1_RX_STA|=0x8000; /* 换行0x0d后面进跟着回车0x0a,认为完成一次正确的接收，将接收完成标志位 bit31 置1*/
        }
			}else{                    /* 之前没有接收到换行字符 0x0d */
				if( USART1_RxBuffer[0] == 0x0d){ /* 判断本次接收的字符是否是换行字符，如果是，则标识 bit14*/
          USART1_RX_STA|=0x4000;
        }else{                  /* 本次接收的不是换行符，则必定就是数据 */
					USART1_RX_BUF[USART1_RX_STA & 0X3FFFFFFF] = USART1_RxBuffer[0] ;
					USART1_RX_STA++;
					if(USART1_RX_STA>(USART1_REC_LEN-1)){ /* 不允本次许接收到的数据包的字节数大于USART1_REC_LEN所设定的字节数 */
            USART1_RX_STA=0;
          }
				}
			}
		}
	}
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: 林家俊
 *@LastestUpdate: 2017-12-02
 *@Function: 串口1中断服务程序
 *@Param: 无
 *@Return:无
 *@Note:
 *+
 *+
 *--------------------------------------------------------------------------------------------------
 */
void USART1_IRQHandler(void)
{
	u32 timeout = 0;
#if SYSTEM_SUPPORT_OS
	OSIntEnter();
#endif

	HAL_UART_IRQHandler(&USART1_Handler); /* 调用HAL库中的中断处理函数 */

	timeout = 0;
  while (HAL_UART_GetState(&USART1_Handler) != HAL_UART_STATE_READY){ /* 等待就绪 */
    timeout++;
    if(timeout > HAL_MAX_DELAY) break; /* 等待超时，退出 */
	}

  timeout = 0;
  // 由于每接收一个字符就会产生一次中断，在该中断函数中调用 HAL 库的中断处理函数时会关闭中断，因此，这里的作用是重新开启中断 
	while(HAL_UART_Receive_IT(&USART1_Handler, (u8 *)USART1_RxBuffer, USART1_RXBUFFERSIZE) != HAL_OK){
	 timeout++;
	 if(timeout>HAL_MAX_DELAY) break;
	}

#if SYSTEM_SUPPORT_OS
	OSIntExit();
#endif
}
