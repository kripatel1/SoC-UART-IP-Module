// UART IP Example
// UART IP Library (uart_ip.c)
// Krishna Patel

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board

// Hardware configuration:
// UART Port: 
// GPIO_1[5] (pin AK18) UART_CLK_OUT ***NEEDS TO BE CONFIGURED
// GPIO_1[1] (pin Y17)  UART_TX      ***NEEDS TO BE CONFIGURED
// GPIO_1[3] (pin Y18)  UART_RX      ***NEEDS TO BE CONFIGURED
//
// GPIO_1[31-0] is used as a general purpose GPIO port
// HPS interface:
//   Mapped to offset of 0x400 in light-weight MM interface aperature

//-----------------------------------------------------------------------------

#ifndef UART_H_
#define UART_H_

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

bool     getUartTestCLKValue();
uint32_t getSTATUSValue();
uint32_t getCONTROLValue();
uint32_t getBRDValue();
void     setBRDValue(uint32_t IBRD, uint32_t FBRD);
void 	 setParity(uint8_t value);
void 	 enable8bitTX();
void 	 disable8bitTX();
void	 disableTX();
void     enableTX();
void	 txData(uint8_t value);
uint8_t	 rxDate();

uint8_t getSIZE();
void setSIZE(bool size);
#endif 