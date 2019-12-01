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

; print a string
    LD      A,(LED)
    ADD     A,A

    LD      H,  0
    LD      L,  A
    LD      DE, MSG
    ADD     HL, DE  ; address of message a

    LD      A,(HL)
    INC     HL
    LD      H,(HL)
    LD      L,A     ; load that address into HL

PLOOP:
    LD      A,(HL)
    CP      0
    JR      Z, PDONE
    LD      (TX),A

BUSY:
    LD      A,(TX)  ; tx status (pausing while outputting)
    CP      1
    JR      Z, BUSY

    INC     HL
    JR      PLOOP
PDONE:

    LD      A,(LED)
    INC     A
    LD      (LED),A
    CP      0x08
    JR      NZ, LOOP

    LD      A, 0
    LD      (LED), A
    LD      A,'*'
    LD      (TX),A      ; if the LED's overflow output a '*'

    LD      A,(BTN)
    CP      0
    JP      Z,doloop
    JP      0
doloop:
    JP      LOOP

mONE:
    defb    10
    defm    "One."
    defb    10,0
mTWO:
    defm    "Two."
    defb    10,0
mTHREE:
    defm    "Three."
    defb    10,0
mFOUR:
    defm    "Four."
    defb    10,0
mFIVE:
    defm    "Five."
    defb    10,0
mSIX:
    defm    "Six."
    defb    10,0
mSEVEN:
    defm    "Seven."
    defb    10,0
mEIGHT:
    defm    "Eight."
    defb    10,0

MSG:
    defw      mONE, mTWO , mTHREE, mFOUR, mFIVE, mSIX, mSEVEN, mEIGHT

LOWB:
    defb      0xff
MEDB:
    defb      0xff
