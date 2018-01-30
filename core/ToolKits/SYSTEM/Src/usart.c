/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: delay.c
 *@Author: �ּҿ�
 *@Version: v1.0
 *@CreateDate: 2017-12-02
 *@Brief:
 *+ ʵ�ִ��ڵĳ�ʼ��
 *+ ʵ�� printf �������ض��򵽴���1
 *+ ʵ���жϽ��ܴ�������
 *--------------------------------------------------------------------------------------------------
 */
#include "usart.h"

#if SYSTEM_SUPPORT_OS
#include "includes.h"           /* ʹ��OS */
#endif

/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-01-02
 *@Note:
 *+ USARTx_RX_STA: ����״̬��ʶ
 *+ USARTx_RX_BUF: ���ݻ����������ڴ洢���յ�������
 *+ USARTx_RxBuffer: �����ݴ����� ���ڴ洢���ν��ܵ����ַ�
 *--------------------------------------------------------------------------------------------------
 */
#if EN_USART1_RX
UART_HandleTypeDef USART1_Handler; /* ���ھ�� */
u8 USART1_RX_BUF[USART1_REC_LEN];   /* ���ݻ�������������� USART_REC_LEN ���ֽ� */
u32 USART1_RX_STA=0;               /* bit31: ��ʶ������Ҫ���յ����ݰ��Ƿ�ȫ���������; bit30: ��ʶ�Ƿ���յ����� 0x0d; bit0~bit29: ��ʶ�Ѿ����յ����ֽ��������Ϊ1GB-1�� */
u8 USART1_RxBuffer[USART1_RXBUFFERSIZE];       /* ���ν��յ����ַ��ŵ��ñ��������ݴ棬������н�������ȡ��һ�ַ�ʱ�Ὣ�串�� */
#endif
#if EN_USART2_RX
UART_HandleTypeDef USART2_Handler;
u8 USART2_RX_BUF[USART2_REC_LEN];
u32 USART2_RX_STA=0;
u8 USART2_RxBuffer[USART2_RXBUFFERSIZE];
#endif
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-29
 *@Function: ��ʼ������1,�ô��ڻ������������ض���
 *@Param: bound:������
 *@Return:��
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
	USART1_Handler.Init.Mode=UART_MODE_TX_RX; /* �շ�ģʽ */
	HAL_UART_Init(&USART1_Handler);
  //�ú����Ὺ�������жϣ���־λUART_IT_RXNE���������ý��ջ����Լ����ջ���������������
	HAL_UART_Receive_IT(&USART1_Handler, (u8 *)USART1_RxBuffer, USART1_RXBUFFERSIZE);
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-02
 *@Function: UART�ײ��ʼ����ʱ��ʹ�ܣ��������ã��ж�����
 *@Param: huart:���ھ��
 *@Return:��
 *@Note:
 *+ �˺����ᱻHAL_UART_Init()����
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
 *@Author: �ּҿ�
 *@LastestUpdate: 2018-01-02
 *@Function: ���ڻص��������ú���ʹ��һ���㷨ʵ�ֽ������ݵ��߼�
 *@Param: huart: ���ھ��
 *@Return:��
 *@Note:
 *+ ��(����:0x0d-�س�:0x0a)��Ϊһ�������Ľ��գ�Ҫ������������\r\n��β
 *+ USART_RX_STA ��һ�� u16 �ı�������
 *--------------------------------------------------------------------------------------------------
 */
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
	if(huart->Instance == USART1){ /* USART1 */
		if((USART1_RX_STA & 0x80000000) == 0){ /*û����ɱ������ݰ��Ľ��� */
			if(USART1_RX_STA & 0x40000000){      /* �Ѿ����յ��˻����ַ� */
				if( USART1_RxBuffer[0]!=0x0a){      /* ���ν��յ��Ĳ��ǻس��ַ� */
          USART1_RX_STA=0;       /* ��������£����еĺ���Ӧ�������Żس��� 0x0a, �˴����ڻ��к��治�ǻس������϶����մ��󣬽�״̬��ʶȫ����λ*/
        }else{
          USART1_RX_STA|=0x8000; /* ����0x0d��������Żس�0x0a,��Ϊ���һ����ȷ�Ľ��գ���������ɱ�־λ bit31 ��1*/
        }
			}else{                    /* ֮ǰû�н��յ������ַ� 0x0d */
				if( USART1_RxBuffer[0] == 0x0d){ /* �жϱ��ν��յ��ַ��Ƿ��ǻ����ַ�������ǣ����ʶ bit14*/
          USART1_RX_STA|=0x4000;
        }else{                  /* ���ν��յĲ��ǻ��з�����ض��������� */
					USART1_RX_BUF[USART1_RX_STA & 0X3FFFFFFF] = USART1_RxBuffer[0] ;
					USART1_RX_STA++;
					if(USART1_RX_STA>(USART1_REC_LEN-1)){ /* ���ʱ�������յ������ݰ����ֽ�������USART1_REC_LEN���趨���ֽ��� */
            USART1_RX_STA=0;
          }
				}
			}
		}
	}
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-02
 *@Function: ����1�жϷ������
 *@Param: ��
 *@Return:��
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

	HAL_UART_IRQHandler(&USART1_Handler); /* ����HAL���е��жϴ����� */

	timeout = 0;
  while (HAL_UART_GetState(&USART1_Handler) != HAL_UART_STATE_READY){ /* �ȴ����� */
    timeout++;
    if(timeout > HAL_MAX_DELAY) break; /* �ȴ���ʱ���˳� */
	}

  timeout = 0;
  // ����ÿ����һ���ַ��ͻ����һ���жϣ��ڸ��жϺ����е��� HAL ����жϴ�����ʱ��ر��жϣ���ˣ���������������¿����ж� 
	while(HAL_UART_Receive_IT(&USART1_Handler, (u8 *)USART1_RxBuffer, USART1_RXBUFFERSIZE) != HAL_OK){
	 timeout++;
	 if(timeout>HAL_MAX_DELAY) break;
	}

#if SYSTEM_SUPPORT_OS
	OSIntExit();
#endif
}
