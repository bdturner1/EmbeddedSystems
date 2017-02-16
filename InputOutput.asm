; Lab 02: For-loops, while-loops, if-then branching, subroutines, and time delays
; Names: Alinda Heng & Blake Turner
; 02/09/2017


; This code simulates locking and unlocking a digital lock.
; When both switches (P1.1 & P1.4) are pressed at the same time, the lock (P1.0) will be unlocked.
; This is indicated by the LED turning on. Otherwise, it remains locked (LED off).

; InputOutput.s
; Runs on MSP432
; Test the GPIO initialization functions by setting the LED
; color according to the status of the switches.
; Daniel Valvano
; June 20, 2015

;  This example accompanies the book
;  "Embedded Systems: Introduction to the MSP432 Microcontroller",
;  ISBN: 978-1512185676, Jonathan Valvano, copyright (c) 2015
;  Section 4.2    Program 4.1
;
;Copyright 2015 by Jonathan W. Valvano, valvano@mail.utexas.edu
;   You may use, edit, run or distribute this file
;   as long as the above copyright notice remains
;THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
;OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
;VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
;OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;For more information about my classes, my research, and my books, see
;http://users.ece.utexas.edu/~valvano/

; built-in LED1 connected to P1.0
; negative logic built-in Button 1 connected to P1.1
; negative logic built-in Button 2 connected to P1.4
; built-in red LED connected to P2.0
; built-in green LED connected to P2.1
; built-in blue LED connected to P2.2
       .thumb

       .text
       .align  2
P1IN    .field 0x40004C00,32  ; Port 1 Input
P2IN    .field 0x40004C01,32  ; Port 2 Input
P2OUT   .field 0x40004C03,32  ; Port 2 Output
P1OUT   .field 0x40004C02,32  ; Port 1 Output
P1DIR   .field 0x40004C04,32  ; Port 1 Direction
P2DIR   .field 0x40004C05,32  ; Port 2 Direction
P1REN   .field 0x40004C06,32  ; Port 1 Resistor Enable
P2REN   .field 0x40004C07,32  ; Port 2 Resistor Enable
P1DS    .field 0x40004C08,32  ; Port 1 Drive Strength
P2DS    .field 0x40004C09,32  ; Port 2 Drive Strength
P1SEL0  .field 0x40004C0A,32  ; Port 1 Select 0
P2SEL0  .field 0x40004C0B,32  ; Port 2 Select 0
P1SEL1  .field 0x40004C0C,32  ; Port 1 Select 1
P2SEL1  .field 0x40004C0D,32  ; Port 2 Select 1

; Note: These global constants are unnecessary in this code.
RED       .equ 0x01
GREEN     .equ 0x02
BLUE      .equ 0x04
SW1       .equ 0x02                 ; on the left side of the LaunchPad board
SW2       .equ 0x10                 ; on the right side of the LaunchPad board

      .global main
      .thumbfunc main

main: .asmfunc
    BL  Port1_Init                  ; initialize P1.1 and P1.4 and make them inputs (P1.1 and P1.4 built-in buttons)
	BL  toggle
; Only information we need to know is whether both switches are pressed at the same time.
; It does not matter if only one or neither are pressed, so code concerning that is removed.
loop
	BL  delay
    BL  Port1_Input				; read both of the switches on Port 1
    CMP R0, #0x00				; R0 == 0x00?
    BEQ lock					; If so, both switches pressed and lock should unlock.
    BL toggle						; Otherwise, it remains locked.
    B   loop
toggle							; Unlocked - LED should be on.
    LDR  R1, P1OUT			;load address of p1out into R1
    LDRB R0, [R1]			;load what is pointed at by *p1out into R0
    ORR  R0, R0, #0x01			; Set bit 0
	STRB R0, [R1]
    B   loop
lock								; Locked - LED should be off.
    LDR  R1, P1OUT
    LDRB R0, [R1]
	EOR  R0, R0, #0xFF			; Toggle bit 0.
	STRB R0, [R1]
    B   loop


    .endasmfunc
;------------Port1_Init------------
; Initialize GPIO Port 1 for negative logic switches on P1.1 and
; P1.4 as the LaunchPad is wired.  Weak internal pull-up
; resistors are enabled.
; Input: none
; Output: none
; Modifies: R0, R1
Port1_Init: .asmfunc
    LDR  R1, P1SEL0
    MOV  R0, #0x00                  ; configure P1.4 and P1.1 as GPIO
    STRB R0, [R1]
    LDR  R1, P1SEL1
    MOV  R0, #0x00                  ; configure P1.4 and P1.1 as GPIO
    STRB R0, [R1]
    LDR  R1, P1DIR
    MOV  R0, #0x01                  ; make P1.4 and P1.1 output, which can both read and write.
    STRB R0, [R1]
    LDR  R1, P1REN
    MOV  R0, #0x12                  ; enable pull resistors on P1.4 and P1.1
    STRB R0, [R1]
    LDR  R1, P1OUT
    MOV  R0, #0x12                  ; P1.4 and P1.1 are pull-up
    STRB R0, [R1]
    BX  LR
    .endasmfunc
;------------Port1_Input------------
; Read and return the status of the switches.
; Input: none
; Output: R0  0x10 if only Switch 1 is pressed
;         R0  0x02 if only Switch 2 is pressed
;         R0  0x00 if both switches are pressed
;         R0  0x12 if no switches are pressed
; Modifies: R1
Port1_Input: .asmfunc
    LDR  R1, P1IN
    LDRB R0, [R1]                   ; read all 8 bits of Port 1
    AND  R0, R0, #0x10              ; select the input pins P1.1 and P1.4 - was 0x12 thinking 0x02 will disable one of the buttons.
    BX   LR
    .endasmfunc

delay: .asmfunc
	MOV R1, #1000   ;1000
wait
	SUBS R1,R1,#0x01
	BNE wait
	BX LR
	.endasmfunc

    .end

