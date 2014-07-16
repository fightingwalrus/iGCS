/****************************************************************************************
 *
 *	redparkSerial.h
 *		
 *		Data structures and interface for iThing app <--> Redpark Serial Cable
 *
 *  Copyright © 2010-2011 Redpark
 *
 *	Revisions:
 *			03mar2010 First Release Docs
 *          01jun2011 modify for libRsc (public api)    
 *
 *
 *  Note:  
 *
 *  In the info.plist of your iThing application, you need to add the Key
 * 
 *     ' UISupportedExternalAccessoryProtocols' and set it to: 'com.redpark.serdb9'
 *
 *
 * Usage Notes:
 *
 *  The serial port of the cable is always reset to the default settings  
 *  when the cable is first connected to the iThing exits.
 *   
 ******************************************************************************************/

#ifndef __REDPARKSERIAL_H
#define __REDPARKSERIAL_H


// modem control status bits

#define MODEM_STAT_CTS  0x01
#define MODEM_STAT_RI   0x02
#define MODEM_STAT_DSR  0x04
#define MODEM_STAT_DCD  0x08

#define MODEM_STAT_RTS  0x01
#define MODEM_STAT_DTR  0x02

// defines for dataLen, parity, stopBits

#define SERIAL_DATABITS_7   0x07
#define SERIAL_DATABITS_8   0x08

#define STOPBITS_1          0x01	// 1 stop bit for all byte sizes
#define STOPBITS_2          0x02	// 2 stop bits for 6-8 bit byte

#define SERIAL_PARITY_NONE  0x00
#define SERIAL_PARITY_ODD   0x01
#define SERIAL_PARITY_EVEN  0x02


// defines for rxFlowControl, txFlowControl
// if not 'NONE' flow control is handled within the accessory

#define TXFLOW_NONE 0x00
#define TXFLOW_CTS  0x01	
#define TXFLOW_DSR  0x02
#define TXFLOW_DCD  0x03
#define TXFLOW_XOFF 0x04

#define RXFLOW_NONE 0x00				// default state:  DTR=OFF & RTS=OFF
#define RXFLOW_XOFF 0x01				// default state:  DTR=OFF & RTS=OFF
#define RXFLOW_RTS  0x02				// default state:  DTR=OFF & RTS=ON
#define RXFLOW_DTR  0x03				// default state:  DTR=ON & RTS=OFF


// the default config settings...

#define DEFAULT_TXFLOW TXFLOW_NONE	
#define DEFAULT_RXFLOW RXFLOW_NONE
#define DEFAULT_SERIAL_DATABITS SERIAL_DATABITS_8
#define DEFAULT_SERIAL_PARITY SERIAL_PARITY_NONE
#define DEFAULT_STOPBITS STOPBITS_1
#ifdef LOCATION
#define DEFAULT_BAUD	4800	
#else
#define DEFAULT_BAUD	9600		
#endif
#define DEFAULT_RXFORWARDTIME	100		
#define DEFAULT_RXFORWARDCOUNT	16		
#define DEFAULT_TXACKSETTING	0		
#define DEFAULT_XON_CHAR	0		
#define DEFAULT_XOFF_CHAR	0		

typedef struct serialPortStatus { 
    unsigned char  
        txDiscard,                      // non-zero if tx data msg from App discarded
        rxOverrun,	                // non-zero if overrun error occurred
        rxParity,			// non-zero if parity error occurred
        rxFrame,			// non-zero if frame error occurred
        txAck,				// ack when tx buffer becomes empty (sent only if txAxkSetting non-zero in config)
        msr,				// 0-3 current modem status bits for CTS, DSR, DCD & RI, 4-7 previous modem status bits, MODEM_STAT_
        rtsDtrState,			// 0-3 current modem status bits for RTS & DTR, 4-7 previous modem status bits, MODEM_STAT_
        rxFlowStat,			// rx flow control off= 0 on = RXFLOW_RTS/DTR/XOFF
        txFlowStat,			// rx flow control off= 0 on = TXFLOW_DCD/CTS/DSR/XOFF
        returnResponse;			// Non-zero if returned in response to config or control
					// message with returnStatus requested (non-zero). If non-zero the
					// value will equal the returnStatus byte.
} serialPortStatus;


typedef struct serialPortConfig { 
	unsigned char  baudLo,      // baud rate lo/hi up to 57600
        baudHi,
	dataLen,		// SERIAL_DATABITS_ 7, 8
	parity,			// SERIAL_PARITY_ NONE, ODD, EVEN  
        stopBits,         	// STOPBITS_ 1, 2       
        txFlowControl,          // TXFLOW_
        rxFlowControl,          // RXFLOW_
        xonChar,                // XON/XOFF flow control chars if used
        xoffChar,       		 
				// RX forwarding parameters:
	rxForwardingTimeout,    // forward rx data when idle timeout reached 
        rxForwardCount,         // or received this many chars..
        txAckSetting,           // NON-zero if a txAck response is requested (sent when tx buffer becomes empty)
        returnStatus;           // NON-zero if a status response (to this config message) is requested
}serialPortConfig;

	
typedef struct serialPortControl { 
  unsigned char txFlush,          // non-zero if tx buffer should be flushed
    rxFlush,                      // non-zero if rx buffer should be flushed
    setDtr,                       // change DTR state to..                       
    dtr,                          //   DTR state 1=On, 0=Off (ignored if setDtr == 0)
    setRts,                       // change RTS state to.. 
    rts,                          //   RTS state 1=On, 0=Off (ignored if setRts == 0)
    txBreak,                      // tx 'n' break characters
    returnStatus;                 // non-zero if a status response (to this control message) is requested
}serialPortControl;

#endif // __REDPARKSERIAL_H