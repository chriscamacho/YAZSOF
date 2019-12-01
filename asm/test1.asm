RAMTOP  EQU     0x07ff      ; last ram location
LED     EQU     0xffff      ; LEDS
TX      EQU     0xfffe      ; uart transmit byte
BTN     EQU     0xfffc      ; hardware buttons
VID     EQU     0xfd00      ; video memory 20x15
RXTOP   EQU     0xfffd      ; ptr top rx ring buffer
RXBUFF  EQU     0xffe0      ; to 0xffef rx buffer


    ORG    0x0400

    LD      A,0
    LD      (LOWB),A
    LD      (MEDB),A
    LD      (LED),A     ; clear counter (testing reset)

LOOP:
    LD      A,(LOWB)
    INC     A
    LD      (LOWB),A
    JR      NZ, LOOP    ; loop till least significant byte overflows

    LD      A,(MEDB)
    INC     A
    LD      (MEDB),A
    JR      NZ, LOOP    ; both loops till middle significant byte overflows

    LD      A,'.'
    LD      (TX),A      ; output '.' of each increment of LED's

    LD      A,(LED)
    INC     A
    LD      (LED),A
    CP      0x0f
    JR      NZ, LOOP

    LD      A, 0
    LD      (LED), A
    LD      A,'*'
    LD      (TX),A      ; if the LED's overflow output a '*'

    JR      LOOP

LOWB:
    defb      0xff
MEDB:
    defb      0xff
