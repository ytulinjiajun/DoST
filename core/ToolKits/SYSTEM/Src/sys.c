/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@FileName: sys.c
 *@Author: �ּҿ�
 *@Version: v1.0
 *@CreateDate: 2017-12-1
 *@Brief: ����ϵͳʱ��
  *--------------------------------------------------------------------------------------------------
 */
#include "sys.h"
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function: ����ϵͳʱ��
 *@Param: plln:��PLL��Ƶϵ��(PLL��Ƶ),ȡֵ��Χ:64~432
 *@Param: pllm:��PLL����ƵPLL��Ƶϵ��(PLL֮ǰ�ķ�Ƶ),ȡֵ��Χ:2~63
 *@Param: pllp:ϵͳʱ�ӵ���PLL��Ƶϵ��(PLL֮��ķ�Ƶ),ȡֵ��Χ:2,4,6,8.(������4��ֵ!)
 *@Param: pllq:USB/SDIO/������������ȵ���PLL��Ƶϵ��(PLL֮��ķ�Ƶ),ȡֵ��Χ:2~15
 *@Return: 0,�ɹ�;1,ʧ��
 *@Note:
 *+Fvco=Fs*(plln/pllm);
 *+SYSCLK=Fvco/pllp=Fs*(plln/(pllm*pllp));
 *+Fusb=Fvco/pllq=Fs*(plln/(pllm*pllq));
 *+
 *+Fvco:VCOƵ��
 *+SYSCLK:ϵͳʱ��Ƶ��
 *+Fusb:USB,SDIO,RNG�ȵ�ʱ��Ƶ��
 *+Fs:PLL����ʱ��Ƶ��,������HSI,HSE��
 *+
 *+�ⲿ����Ϊ8M��ʱ��,�Ƽ�ֵ:plln=336,pllm=8,pllp=2,pllq=7.
 *+�õ�:Fvco=8*(336/8)=336Mhz  SYSCLK=336/2=168Mhz  Fusb=336/7=48Mhz
  *--------------------------------------------------------------------------------------------------
 */
void Stm32_Clock_Init(u32 plln,u32 pllm,u32 pllp,u32 pllq)
{
  HAL_StatusTypeDef ret = HAL_OK;
  RCC_OscInitTypeDef RCC_OscInitStructure; 
  RCC_ClkInitTypeDef RCC_ClkInitStructure;

  __HAL_RCC_PWR_CLK_ENABLE(); //ʹ��PWRʱ��

  //������������������õ�ѹ�������ѹ�����Ա�������δ�����Ƶ�ʹ���
  //ʱʹ�����빦��ʵ��ƽ��
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1); //���õ�ѹ�������ѹ����1

  RCC_OscInitStructure.OscillatorType = RCC_OSCILLATORTYPE_HSE;    //ʱ��ԴΪHSE
  RCC_OscInitStructure.HSEState = RCC_HSE_ON;                      //��HSE
  RCC_OscInitStructure.PLL.PLLState = RCC_PLL_ON; //��PLL
  RCC_OscInitStructure.PLL.PLLSource = RCC_PLLSOURCE_HSE; //PLLʱ��Դѡ��HSE
  RCC_OscInitStructure.PLL.PLLM = pllm; //��PLL����ƵPLL��Ƶϵ��(PLL֮ǰ�ķ�Ƶ),ȡֵ��Χ:2~63.
  RCC_OscInitStructure.PLL.PLLN = plln; //��PLL��Ƶϵ��(PLL��Ƶ),ȡֵ��Χ:64~432.  
  RCC_OscInitStructure.PLL.PLLP = pllp; //ϵͳʱ�ӵ���PLL��Ƶϵ��(PLL֮��ķ�Ƶ),ȡֵ��Χ:2,4,6,8.(������4��ֵ!)
  RCC_OscInitStructure.PLL.PLLQ = pllq; //USB/SDIO/������������ȵ���PLL��Ƶϵ��(PLL֮��ķ�Ƶ),ȡֵ��Χ:2~15.
  ret = HAL_RCC_OscConfig(&RCC_OscInitStructure); //��ʼ��

  if(ret != HAL_OK){
    while(1){;}
  }
#ifdef USER_STM32F7
  ret = HAL_PWREx_EnableOverDrive(); /* ����Over-Driver���ܣ��Ի�������Ƶ */
  if(ret != HAL_OK){
    while(1){;}
  }
#endif
  //ѡ��PLL��Ϊϵͳʱ��Դ��������HCLK,PCLK1��PCLK2
  RCC_ClkInitStructure.ClockType=(RCC_CLOCKTYPE_SYSCLK|RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2);
  RCC_ClkInitStructure.SYSCLKSource=RCC_SYSCLKSOURCE_PLLCLK; //����ϵͳʱ��ʱ��ԴΪPLL
  RCC_ClkInitStructure.AHBCLKDivider=RCC_SYSCLK_DIV1;//AHB��Ƶϵ��Ϊ1
  RCC_ClkInitStructure.APB1CLKDivider=RCC_HCLK_DIV4; //APB1��Ƶϵ��Ϊ4
  RCC_ClkInitStructure.APB2CLKDivider=RCC_HCLK_DIV2; //APB2��Ƶϵ��Ϊ2

#ifdef USER_STM32F4
  ret = HAL_RCC_ClockConfig(&RCC_ClkInitStructure,FLASH_LATENCY_5); //ͬʱ����FLASH��ʱ����Ϊ5WS��Ҳ����6��CPU���ڡ�
#elif USER_STM32F7
  ret = HAL_RCC_ClockConfig(&RCC_ClkInitStructure,FLASH_LATENCY_7);
#endif

  if(ret != HAL_OK){
    while(1){;}
  }

#ifdef USER_STM32F4
if (HAL_GetREVID() == 0x1001){ //STM32F405x/407x/415x/417x Z�汾������֧��Ԥȡ����
		__HAL_FLASH_PREFETCH_BUFFER_ENABLE();  //ʹ��flashԤȡ
	}
#endif
}

#ifdef USER_STM32F7
void Cache_Enable(void)
{
  SCB_EnableICache();           /* ʹ��I-Cache */
  SCB_EnableDCache();           /* ʹ��D-Cache */
  SCB->CACR |= 1 << 2;          /* ǿ��D-Cache͸д�������������ʵ��ʹ���п��ܻ��������� */
}
#endif

#ifdef USER_STM32F7
void MPU_Config(void)
{
  MPU_Region_InitTypeDef MPU_InitStruct;

  /* Disable the MPU */
  HAL_MPU_Disable();

  /* Configure the MPU attributes as WT for SRAM */
  MPU_InitStruct.Enable = MPU_REGION_ENABLE;
  MPU_InitStruct.BaseAddress = 0x20020000;
  MPU_InitStruct.Size = MPU_REGION_SIZE_512KB;
  MPU_InitStruct.AccessPermission = MPU_REGION_FULL_ACCESS;
  MPU_InitStruct.IsBufferable = MPU_ACCESS_NOT_BUFFERABLE;
  MPU_InitStruct.IsCacheable = MPU_ACCESS_CACHEABLE;
  MPU_InitStruct.IsShareable = MPU_ACCESS_SHAREABLE;
  MPU_InitStruct.Number = MPU_REGION_NUMBER0;
  MPU_InitStruct.TypeExtField = MPU_TEX_LEVEL0;
  MPU_InitStruct.SubRegionDisable = 0x00;
  MPU_InitStruct.DisableExec = MPU_INSTRUCTION_ACCESS_ENABLE;

  HAL_MPU_ConfigRegion(&MPU_InitStruct);

  /* Enable the MPU */
  HAL_MPU_Enable(MPU_PRIVILEGED_DEFAULT);
}
#endif


#ifdef  USE_FULL_ASSERT
//��������ʾ�����ʱ��˺����������������ļ���������
//file��ָ��Դ�ļ�
//line��ָ�����ļ��е�����
void assert_failed(uint8_t* file, uint32_t line)
{
	while (1)
	{
	}
}
#endif

/* //THUMBָ�֧�ֻ������ */
/* //�������·���ʵ��ִ�л��ָ��WFI */
/* __asm void WFI_SET(void) */
/* { */
/* 	WFI; */
/* } */
/* //�ر������ж�(���ǲ�����fault��NMI�ж�) */
/* __asm void INTX_DISABLE(void) */
/* { */
/* 	CPSID   I */
/* 	BX      LR */
/* } */
/* //���������ж� */
/* __asm void INTX_ENABLE(void) */
/* { */
/* 	CPSIE   I */
/* 	BX      LR */
/* } */
/* //����ջ����ַ */
/* //addr:ջ����ַ */
/* __asm void MSR_MSP(u32 addr) */
/* { */
/* 	MSR MSP, r0 			//set Main Stack value */
/* 	BX r14 */
/* } */
