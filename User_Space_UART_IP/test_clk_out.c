// UART IP Example
// UART IP Library (uart_ip.c)
// Krishna Patel

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board

// Hardware configuration:
// UART Port: 
// GPIO_1[0] (pin AK18) UART_CLK_OUT ***NEEDS TO BE CONFIGURED
// GPIO_1[1] (pin Y17)  UART_TX      ***NEEDS TO BE CONFIGURED
// GPIO_1[3] (pin Y18)  UART_RX      ***NEEDS TO BE CONFIGURED
//
// GPIO_1[31-0] is used as a general purpose GPIO port
// HPS interface:
//   Mapped to offset of 0x400 in light-weight MM interface aperature

//-----------------------------------------------------------------------------

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "uart_ip.h"
#include "gpio_ip.h"


// Pins
#define UART_CLK_OUT 0
#define GREEN_LED 1
// #define PUSH_BUTTON 2


// Initialize Hardware
void initHw()
{
	uint8_t val =0 ;
    // Initialize  GPIO IP
	val = gpioOpen();
	printf("%d -- ",val );
	perror("gpioOpen--");

    // Initialize UART IP
    val = uartOpen();
	printf("%d -- ",val );
	perror("uartOpen--");
	printf("\n");

    // Configure uart_clk_out 
    selectPinPushPullOutput(UART_CLK_OUT);
    setPinValue(UART_CLK_OUT, 0);
    selectPinPushPullOutput(GREEN_LED);	
   
    
}

int main(void)
{
	// Initialize hardware
	initHw();
	uint8_t val = getUartTestCLKValue();
	enableTX();
	printf("%u\n",getCONTROLValue() );
	setBRDValue(325,33);
	val = getBRDValue();
	printf("%u--new BRD Rate\n",val);
	printf("%u\n",3472 );

	// 2666666
	// 1333333
	// 3472
	while (1)
	{

		val = getUartTestCLKValue();
		if(val)
		{
			setPinValue(UART_CLK_OUT, 1);
			setPinValue(GREEN_LED, 1);
			// printf("HIGH\n");
// 
		}
		else
		{
			setPinValue(UART_CLK_OUT, 0);
			setPinValue(GREEN_LED, 0);
			// printf("LOW\n");
			
		}
	}
 //    // Turn off green LED, turn on red LED
	// setPinValue(GREEN_LED, 0);
 //    setPinValue(RED_LED, 1);

 //    // Wait for PB press
 //    waitPbPress();

 //    // Turn off red LED, turn on green LED
 //    setPinValue(RED_LED, 0);
 //    setPinValue(GREEN_LED, 1);
}
