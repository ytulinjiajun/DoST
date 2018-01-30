/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: delay.h
 *@Author: �ּҿ�
 *@Version: v1.0
 *@CreateDate: 2017-12-1
 *@Brief:
 *+ʹ��SysTick����ͨ����ģʽ���ӳٽ��й���(֧��ucosii)
 *+����delay_us,delay_ms
 *--------------------------------------------------------------------------------------------------
 */
#ifndef _DELAY_H
#define _DELAY_H
#include "sys.h"

void delay_init(u8 SYSCLK);
void delay_ms(u16 nms);
void delay_us(u32 nus);
#endif

