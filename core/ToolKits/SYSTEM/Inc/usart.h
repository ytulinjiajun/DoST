/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: usart.h
 *@Author: �ּҿ�
 *@Version: v1.0
 *@CreateDate: 2017-12-2
 *@Brief:
 *+���ڳ�ʼ��
 *--------------------------------------------------------------------------------------------------
 */
#ifndef _USART_H
#define _USART_H
#include "sys.h"

#define EN_USART1_RX 			  1     /* ʹ�ܣ�1��/��ֹ��0������1���� */
#define USART1_REC_LEN  			200 /* ���屾�ν��յ����ݰ���ŵ����ݻ�����������ֽ���,������������� USART1_RX_STA, ��������2^30-1 */
#define USART1_RXBUFFERSIZE        1   /* ���屾�ν��յ����ַ���ŵ������ݴ������ֽ��� */
extern UART_HandleTypeDef USART1_Handler; /* ���ھ�� */
extern u8 USART1_RX_BUF[USART1_REC_LEN];   /* ���ݻ�������������� USART_REC_LEN ���ֽ� */
extern u32 USART1_RX_STA;      /* bit31: ��ʶ������Ҫ���յ����ݰ��Ƿ�ȫ���������; bit30: ��ʶ�Ƿ���յ����� 0x0d; bit0~bit29: ��ʶ�Ѿ����յ����ֽ��������Ϊ1GB-1�� */
extern u8 USART1_RxBuffer[USART1_RXBUFFERSIZE];       /* ���ν��յ����ַ��ŵ��ñ��������ݴ棬������н�������ȡ��һ�ַ�ʱ�Ὣ�串�� */


#define EN_USART2_RX        0     /* ʹ�ܣ�1��/��ֹ��0������2���� */

void usart1_init(u32 bound);
#endif
