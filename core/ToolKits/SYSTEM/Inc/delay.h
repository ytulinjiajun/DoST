/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: delay.h
 *@Author: 林家俊
 *@Version: v1.0
 *@CreateDate: 2017-12-1
 *@Brief:
 *+使用SysTick的普通计数模式对延迟进行管理(支持ucosii)
 *+包括delay_us,delay_ms
 *--------------------------------------------------------------------------------------------------
 */
#ifndef _DELAY_H
#define _DELAY_H
#include "sys.h"

void delay_init(u8 SYSCLK);
void delay_ms(u16 nms);
void delay_us(u32 nus);
#endif

