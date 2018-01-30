/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Note:
 *+���SYSTEM_SUPPORT_OS������,˵��Ҫ֧��OS��(����UCOSII��UCOSIII��֧��,����OS,�����вο�����ֲ)
 *+��delay_us/delay_ms��Ҫ֧��OS��ʱ����Ҫ������OS��صĺ궨��ͺ�����֧��
 *+������3���궨��:
 *+delay_osrunning:���ڱ�ʾOS��ǰ�Ƿ���������,�Ծ����Ƿ����ʹ����غ���
 *+delay_ostickspersec:���ڱ�ʾOS�趨��ʱ�ӽ���,delay_init�����������������ʼ��systick
 *+delay_osintnesting:���ڱ�ʾOS�ж�Ƕ�׼���,��Ϊ�ж����治���Ե���,delay_msʹ�øò����������������
 *+Ȼ����3������:
 *+delay_osschedlock:��������OS�������,��ֹ����
 *+delay_osschedunlock:���ڽ���OS�������,���¿�������
 *+delay_ostimedly:����OS��ʱ,���������������
 *--------------------------------------------------------------------------------------------------
 */
#include "delay.h"
#include "sys.h"

#if SYSTEM_SUPPORT_OS
#include "includes.h"           /* ���ʹ��ucos,����������ͷ�ļ����� */
#endif

//us��ʱ������
static u32 fac_us=0;

//ms��ʱ������,��os��,����ÿ�����ĵ�ms��
#if SYSTEM_SUPPORT_OS
    static u16 fac_ms=0;
#endif

#if SYSTEM_SUPPORT_OS

#ifdef 	OS_CRITICAL_METHOD						//OS_CRITICAL_METHOD������,˵��Ҫ֧��UCOSII
#define delay_osrunning		OSRunning			//OS�Ƿ����б��,0,������;1,������
#define delay_ostickspersec	OS_TICKS_PER_SEC	//OSʱ�ӽ���,��ÿ����ȴ���
#define delay_osintnesting 	OSIntNesting		//�ж�Ƕ�׼���,���ж�Ƕ�״���
#endif

#ifdef 	CPU_CFG_CRITICAL_METHOD					//CPU_CFG_CRITICAL_METHOD������,˵��Ҫ֧��UCOSIII	
#define delay_osrunning		OSRunning			//OS�Ƿ����б��,0,������;1,������
#define delay_ostickspersec	OSCfg_TickRate_Hz	//OSʱ�ӽ���,��ÿ����ȴ���
#define delay_osintnesting 	OSIntNestingCtr		//�ж�Ƕ�׼���,���ж�Ƕ�״���
#endif
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function:us����ʱʱ,�ر��������(��ֹ���us���ӳ�)
 *--------------------------------------------------------------------------------------------------
 */
void delay_osschedlock(void)
{
#ifdef CPU_CFG_CRITICAL_METHOD
	OS_ERR err;
	OSSchedLock(&err);						//UCOSIII�ķ�ʽ,��ֹ���ȣ���ֹ���us��ʱ
#else
	OSSchedLock();							//UCOSII�ķ�ʽ,��ֹ���ȣ���ֹ���us��ʱ
#endif
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function:us����ʱʱ,�ָ��������
 *--------------------------------------------------------------------------------------------------
 */
void delay_osschedunlock(void)
{
#ifdef CPU_CFG_CRITICAL_METHOD
	OS_ERR err;
	OSSchedUnlock(&err);					//UCOSIII�ķ�ʽ,�ָ�����
#else
	OSSchedUnlock();						//UCOSII�ķ�ʽ,�ָ�����
#endif
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Param:ticks:��ʱ�Ľ�����
 *@Function:����OS�Դ�����ʱ������ʱ
 *--------------------------------------------------------------------------------------------------
 */
void delay_ostimedly(u32 ticks)
{
#ifdef CPU_CFG_CRITICAL_METHOD
	OS_ERR err; 
	OSTimeDly(ticks,OS_OPT_TIME_PERIODIC,&err); //UCOSIII��ʱ��������ģʽ
#else
	OSTimeDly(ticks);						    //UCOSII��ʱ
#endif
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Param:ticks:��ʱ�Ľ�����
 *@Function:systick�жϷ�����,ʹ��OSʱ�õ�
 *--------------------------------------------------------------------------------------------------
 */
void SysTick_Handler(void)
{
  HAL_IncTick();
	if(delay_osrunning==1)					//OS��ʼ����,��ִ�������ĵ��ȴ���
	{
		OSIntEnter();						//�����ж�
		OSTimeTick();       				//����ucos��ʱ�ӷ������
		OSIntExit();       	 				//���������л����ж�
	}
}
#endif
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function:��ʼ���ӳٺ���
 *@Param:SYSCLK:ϵͳʱ��Ƶ��
 *@Return:��
 *@Note:
 *+��ʹ��ucos��ʱ��,�˺������ʼ��ucos��ʱ�ӽ���
 *+SYSTICK��ʱ�ӹ̶�ΪAHBʱ��
  *--------------------------------------------------------------------------------------------------
 */
void delay_init(u8 SYSCLK)
{
#if SYSTEM_SUPPORT_OS 						//�����Ҫ֧��OS.
	u32 reload;
#endif
  HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);//SysTickƵ��ΪHCLK
	fac_us=SYSCLK;						//�����Ƿ�ʹ��OS,fac_us����Ҫʹ��
#if SYSTEM_SUPPORT_OS 						//�����Ҫ֧��OS.
	reload=SYSCLK;					    //ÿ���ӵļ������� ��λΪK
	reload*=1000000/delay_ostickspersec;	//����delay_ostickspersec�趨���ʱ��
											//reloadΪ24λ�Ĵ���,���ֵ:16777216,��180M��,Լ��0.745s����
	fac_ms=1000/delay_ostickspersec;		//����OS������ʱ�����ٵ�λ
	SysTick->CTRL|=SysTick_CTRL_TICKINT_Msk;//����SYSTICK�ж�
	SysTick->LOAD=reload; 					//ÿ1/OS_TICKS_PER_SEC���ж�һ��
	SysTick->CTRL|=SysTick_CTRL_ENABLE_Msk; //����SYSTICK
#else
#endif
}

#if SYSTEM_SUPPORT_OS 						//�����Ҫ֧��OS.

/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function:��os����ʱnus
 *@Param:nus:Ҫ��ʱ��us��
 *@Return:��
 *@Note:
 *+nus:0~190887435(���ֵ��2^32/fac_us@fac_us=22.5)
 *--------------------------------------------------------------------------------------------------
 */
void delay_us(u32 nus)
{
	u32 ticks;
	u32 told,tnow,tcnt=0;
	u32 reload=SysTick->LOAD;				//LOAD��ֵ
	ticks=nus*fac_us; 						//��Ҫ�Ľ�����
	delay_osschedlock();					//��ֹOS���ȣ���ֹ���us��ʱ
	told=SysTick->VAL;        				//�ս���ʱ�ļ�����ֵ
	while(1)
	{
		tnow=SysTick->VAL;
		if(tnow!=told)
		{
			if(tnow<told)tcnt+=told-tnow;	//����ע��һ��SYSTICK��һ���ݼ��ļ������Ϳ�����.
			else tcnt+=reload-tnow+told;
			told=tnow;
			if(tcnt>=ticks)break;			//ʱ�䳬��/����Ҫ�ӳٵ�ʱ��,���˳�.
		}
	};
	delay_osschedunlock();					//�ָ�OS����
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function:��os����ʱnms
 *@Param:nms:Ҫ��ʱ��ms��
 *@Return:��
 *@Note:
 *+nms:0~65535
 *--------------------------------------------------------------------------------------------------
 */
void delay_ms(u16 nms)
{
	if(delay_osrunning&&delay_osintnesting==0)//���OS�Ѿ�������,���Ҳ������ж�����(�ж����治���������)
	{
		if(nms>=fac_ms)						//��ʱ��ʱ�����OS������ʱ������
		{
      delay_ostimedly(nms/fac_ms);	//OS��ʱ
		}
		nms%=fac_ms;						//OS�Ѿ��޷��ṩ��ôС����ʱ��,������ͨ��ʽ��ʱ
	}
	delay_us((u32)(nms*1000));				//��ͨ��ʽ��ʱ
}
#else  //����ucosʱ
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function:����os����ʱnus
 *@Param:nusΪҪ��ʱ��us��
 *@Return:��
 *@Note:
 *+nus:0~190887435(���ֵ��2^32/fac_us@fac_us=22.5)
 *--------------------------------------------------------------------------------------------------
 */
void delay_us(u32 nus)
{
	u32 ticks;
	u32 told,tnow,tcnt=0;
	u32 reload=SysTick->LOAD;				//LOAD��ֵ
	ticks=nus*fac_us; 						//��Ҫ�Ľ�����
	told=SysTick->VAL;        				//�ս���ʱ�ļ�����ֵ
	while(1)
	{
		tnow=SysTick->VAL;
		if(tnow!=told)
		{
			if(tnow<told)tcnt+=told-tnow;	//����ע��һ��SYSTICK��һ���ݼ��ļ������Ϳ�����.
			else tcnt+=reload-tnow+told;
			told=tnow;
			if(tcnt>=ticks)break;			//ʱ�䳬��/����Ҫ�ӳٵ�ʱ��,���˳�.
		}
	};
}
/**
 *---------------------------------------- (C) COPYRLEFT -------------------------------------------
 *@Author: �ּҿ�
 *@LastestUpdate: 2017-12-1
 *@Function:����os����ʱms
 *@Param:nmsΪҪ��ʱ��ms��
 *@Return:��
 *--------------------------------------------------------------------------------------------------
 */
void delay_ms(u16 nms)
{
	u32 i;
	for(i=0;i<nms;i++) delay_us(1000);
}
#endif
