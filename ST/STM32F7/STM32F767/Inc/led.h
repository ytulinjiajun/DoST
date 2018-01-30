#ifndef _LED_H
#define _LED_H
#include "sys.h"

#define LED0 PFout(9)
#define LED1 PFout(10)

void led_init(void);
#endif
