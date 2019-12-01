
RAMTOP  EQU     0x07ff      ; last ram location
LED     EQU     0xffff      ; LEDS
TX      EQU     0xfffe      ; uart transmit byte
BTN     EQU     0xfffc      ; hardware buttons
VID     EQU     0xfd00      ; video memory 32x16 but only first 25 of bytes of
                            ; each 32 columns used, and only 15 rows

RXTOP   EQU     0xfffd      ; ptr top rx ring buffer
RXBUFF  EQU     0xffe0      ; to 0xffef rx buffer

    ORG 0x0000
START:
;    DI
    JP MAIN                       ;Jump to the MAIN routine

; vectors to rom routines could go to different groups of routines
; currently all route to SYS
    ORG 0x0008
RST08
    JP      SYS

    ORG 0x0010
RST10
    JP      SYS

   ORG 0x0018
RST18
    JP      SYS

    ORG 0x0020
RST20
    JP      SYS

    ORG 0x0028
RST28
    JP      SYS

    ORG 0x0030
RST30
    JP      SYS

; TODO think of something to do with the interrupt!
    ORG 0x0038
MODE1_INTERRUPT:
    DI                            ;Disable interrupts
    EX      AF,AF'                ;Save register states'
    EXX                           ;Save register states

    NOP

    EXX                           ;Restore register states
    EX      AF,AF'                ;Restore register states'
    EI                            ;Enable interrupts
    RET


    ORG     0x0048
SYS:
    ADD     A,A     ; double the routine number

    LD      H,  0
    LD      L,  A
    LD      DE, VECTOR
    ADD     HL, DE  ; address of routine vector

    LD      A,(HL)
    INC     HL
    LD      H,(HL)
    LD      L,A     ; load that address into HL
    JP     (HL)

VECTOR:
    defw    TXWAIT, PCHAR, PSTR, DLY, GETUART

RSTTXWAIT   EQU     0
RSTPCHAR    EQU     1
RSTPSTR     EQU     2
RSTDLY      EQU     3
RSTUARTGET  EQU     4

;  "SYS" (rst) routines don't preserve any registers

;
; A=0       Wait for uart transmission to finish
;
TXWAIT:
    LD      A,(TX)  ; tx status (pausing while outputting)
    CP      0
    JR      NZ, TXWAIT
    RET

;
; A=1       Print a character (in B)
;
PCHAR:
    LD      A, B
    LD      (TX), A
    CALL    TXWAIT
    RET

;
; A=2       Print a string (at BC)
;
PSTR:
    LD      A,(BC)
    CP      0
    JR      Z, PSTR_DONE

    LD      (TX),A
WT:
    LD      A,(TX)  ; tx status (pausing while outputting)
    CP      0
    JR      NZ, WT

    INC     BC
    JR      PSTR
PSTR_DONE:
    RET

;
; a=3 do a delay   b=1 == min b=0 == max
;
DLY:
    LD      DE, 0x0000
DLYLOOP:
    INC     DE  ; doesnt effect flags!
    LD      A,D
    CP      0
    JR      NZ, DLYLOOP
    LD      A,E
    CP      0
    JR      NZ, DLYLOOP
    DEC     B
    JR      NZ, DLY

    RET


;
; a=4 get a character from the uart input buffer
;
RXBOTTOM:
    defb 0

GETUART:
; wait for buffer to have something
    LD      A, (RXTOP)
    LD      HL, RXBOTTOM
    SUB     (HL)
    JR      Z, GETUART

    LD      A, (RXBOTTOM)

    LD      DE, RXBUFF  ; add buffer address
    LD      H, 0
    LD      L, A
    ADD     HL, DE      ; address in buffer

    LD      D,(HL)

    LD      A, (RXBOTTOM)
    INC     A
    AND     0x0f
    LD      (RXBOTTOM), A  ; increment and save botom pointer

    LD      A,D

    RET

parseHexLine:
    LD      A, 0
    LD      (payloadCheck), A

    LD      A, (HL)
    CP      ':'
    JP      NZ, parseHexline_err1   ; error if not ":" return a=1
    INC     HL
    CALL    getByte     ; increments HL too
    LD      (payloadBytes), A
    CALL    addCheck

    CALL    getByte     ; get where to write data to
    LD      (payloadAddress+1), A
    CALL    addCheck

    CALL    getByte
    LD      (payloadAddress), A
    CALL    addCheck

    CALL    getByte
    LD      (payloadType), A
    CALL    addCheck

    LD      A, (payloadBytes)   ; parse payloadBytes bytes into payload
    LD      B, A
    LD      DE, payload
parseHexline_1:
    PUSH    BC
    Call    getByte
    POP     BC
    LD      (DE), A
    CALL    addCheck
    INC     DE
    DJNZ    parseHexline_1

    LD      A,(payloadCheck)
    NEG
    LD      (payloadCheck),A

    CALL    getByte
    LD      B,A
    LD      A,(payloadCheck)
    SUB     B
    JR      NZ,parseHexline_err2

    LD      A,0     ; 0 error code
    RET

parseHexline_err1:
    LD      A,1     ; didn't start with :
    RET
parseHexline_err2:
    LD      A,2     ; checksum error
    RET



addCheck:
    LD      C, A
    LD      A, (payloadCheck)
    ADD     A, C
    LD      (payloadCheck), A
    RET


getByte:    ; from (HL) returned in A
    LD      A, (HL)
    INC     HL
    CALL    getDigit
    RLC     A
    RLC     A
    RLC     A
    RLC     A
    LD      B, A        ; high nibble in B
    LD      A, (HL)
    INC     HL
    CALL    getDigit
    OR      B           ; combine hi and low nibble
    RET

getDigit:
    CP      '9'+1         ; Is it a digit (less or equal '9')?
    JR      C, getDigit_1
    SUB     7               ; Adjust for A-F
getDigit_1:
    SUB     '0'             ; back to 0..f
    AND     0x0F
    RET

; TODO allocate this somewhere else (stack?)
; so low ram can become ROM!


payloadAddress: ; address hex line will be written to
    defw      0

payloadBytes:   ; bytes of data in hex line
    defb      0

payload:    ; saved here before checksub verified max 8 bytes
    defb      0,0,0,0,0,0,0,0

payloadType:
    defb      0

payloadCheck:
    defb      0

HexLine:
    defb  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    defb  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    defb  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    defb  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00



MAIN:       ; main entry point for hexloader
    LD      SP,RAMTOP+1
    ;IM      1                     ;Use interrupt mode 1
    ;EI                            ;Enable interrupts


; print a string
    LD      BC, msgWAIT
    LD      A, RSTPSTR
    RST     8

    LD      A, RSTPCHAR
    LD      B,'.'                   ; output '.'
    RST     8

    LD      A, RSTPCHAR
    LD      B,10                    ; output CR
    RST     8

LOOP:
    LD      HL,HexLine
    LD      D,32
lineLoop:
    PUSH    HL
    PUSH    DE
    LD      A,RSTUARTGET     ; get char from uart
    RST     8
    POP     DE
    POP     HL
    CP      10      ; if cr
    JR      Z,lineDone
    LD      (HL),A
    INC     HL
    JR      lineLoop

lineDone:
    LD      HL,HexLine
    CALL    parseHexLine

    CP      0
    JR      Z,lineOK

    CP      1
    JR      Z,strF

    LD      BC, msgCHCK
    LD      A,RSTPSTR
    RST     8
    JP      LOOP

strF:
    LD      BC, msgSTART
    LD      A,RSTPSTR
    RST     8
    JP      LOOP


lineOK:
    LD      BC, msgOK
    LD      A,RSTPSTR
    RST     8

    LD      A,(payloadType)
    CP      1
    JR      NZ, cont

    LD      A, RSTPCHAR
    LD      B,10                    ; output CR
    RST     8

    JP      USERmem

cont:
    LD      HL,(payloadAddress) ; copy payload to memory
    LD      DE,payload
    LD      A,(payloadBytes)
    LD      B,A
cpy:
    LD      A,(DE)
    LD      (HL),A
    INC     DE
    INC     HL
    DJNZ    cpy

    JP      LOOP


; here in case....
;END_PROGRAM:
;    HALT
;    JP      END_PROGRAM

; data....

msgWAIT:
    defm    "Waiting for intel format Hex file."
    defb    10,0
msgOK:
    defm    "OK"
    defb    10,0
msgCHCK:
    defm    "Checksum failed"
    defb    10,0
msgSTART:
    defm    "Line should start with :"
    defb    10,0




    ORG     0x0400
USERmem:
    defb    0

