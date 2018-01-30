/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: led.c
 *@Author: 林家俊
 *@Version: v1.0
 *@CreateDate: 2017-12-1
 *@Brief:
 *+ led 驱动
  *--------------------------------------------------------------------------------------------------
 */
#include "led.h"
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: 林家俊
 *@LastestUpdate: 2017-12-1
 *@Function: led 初始化
 *@Return: 无
 *--------------------------------------------------------------------------------------------------
 */
void led_init(void)
{
  GPIO_InitTypeDef GPIO_InitStructure;
  __HAL_RCC_GPIOF_CLK_ENABLE();

  GPIO_InitStructure.Pin = GPIO_PIN_9 | GPIO_PIN_10;
  GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStructure.Pull = GPIO_PULLUP;
  GPIO_InitStructure.Speed = GPIO_SPEED_HIGH;
  HAL_GPIO_Init(GPIOF,&GPIO_InitStructure);

  HAL_GPIO_WritePin(GPIOF,GPIO_PIN_9,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOF,GPIO_PIN_10,GPIO_PIN_SET);
}
