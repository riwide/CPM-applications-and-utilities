; Magic Wand PRINT config blocks.
;
; Diablo 630/16xx, Qume Sprint 5, Juki 6100, and compatible printers.

CR	equ	13
LF	equ	10
FF	equ	12
ESC	equ	27
RS	equ	30
US	equ	31

DELAY	equ	080h	; flag bit, 6-0 is NUL count

HMI	equ	120
VMI	equ	48
VMI8LPI	equ	6	; VMI / 8
VMI6LPI	equ	8	; VMI / 6
HMI10CPI equ	12	; HMI / 10
HMI12CPI equ	10	; HMI / 12

	org	00400h

; Diablo micro-step 120/in horizontally, 48/in vertically.

	jmp 00000h	; print w/redirection
prtchr: jmp 00000h	; print w/suppress, mode, redirection
prtmsg: jmp 00000h	; print string with delays (NUL repeat...)

l0409h: db	081h		;; Debug:
	db	HMI	; 040a	;; 10 = 12cpi		; printer HU/I
	db	HMI	; 040b	;; 120          => 1	; curr HU/I
	db	VMI		;; 6  = 8lpi		; printer VU/I
dnVMI:	db	VMI	; 040d	;; 48           => 1	; curr VU/I down
upVMI:	db	VMI	; 040e	;; 48           => 1	; curr VU/I up
	db	1584	; platten width, HMI, 13.2" * 120
curHSI: db	0	; 0411  ;;              => 1
curVSI: db	0	; 0412  ;;              => 1
	; original/default settings for CPI/LPI... in HMI/VMI units.
	; copied out at startup (R/O).
	db	12	; temp/curr h-units/char (= 10cpi)
	db	12	; set h-units/char (= 10cpi)
	db	8	; set v-units/char (= 6lpi)

	jmp init	; 0416
	jmp setHSI
	jmp setVSI
	jmp doCR
	jmp doLF
	jmp doNLF
	jmp doFF
	jmp l04e2h	; noop for this printer.
	jmp setBAK
	jmp setFWD

l0434h:
 if 1
	db	'Diablo 1600     '
	db	'B '
 else
	db	'Diablo 1650     '
	db	'B5'
 endif
reset:	db	CR,0		; CR clears backward print mode...
cmdHSI: db	ESC,US,0	; Set Horiz Motion Index (n-1). 1/120"
offHSI: db	1	; Bias of Horiz Motion Index (-) (0x01 = 0 motion units)
cmdVSI: db	ESC,RS,0	; Set Vert Motion Index (n-1). 1/48"
offVSI: db	1	; Bias of Vert Motion Index (-)
cmdCR:	db	CR,DELAY+0,0	; CR
cmdFF:	db	FF,DELAY+0,0	; FF
cmdLF:	db	LF,DELAY+0,0	; LF
cmdNLF: db	ESC,LF,DELAY+0,0	; Reverse LF
cmdBAK: db	ESC,'6',0	; Backward Printing Mode
cmdFWD: db	ESC,'5',0	; Forward Printing mode

doCR:
	lxi d,cmdCR
	call prtmsg
	ret
doNLF:
	lxi d,cmdNLF
	mov c,a
	lda upVMI
	jmp l047bh
doLF:
	lxi d,cmdLF
	mov c,a
	lda dnVMI
l047bh:
	cmp c
	jnc l048fh
	mov b,a
	push b
	mov c,b
	push d
	call l048fh
	pop d
	pop b
	mov a,c
	sub b
	mov c,a
	mov a,b
	jmp l047bh
l048fh:
	push d
	lda curVSI
	cmp c
	cnz setVSI
	pop d
	call prtmsg
	ret
setVSI:
	push b
	lxi d,cmdVSI
	call prtmsg
	pop b
	mov a,c
	sta curVSI
	lda offVSI
	add c
	mov b,a
	call prtchr
	ret
setHSI:
	push b
	lxi d,cmdHSI
	call prtmsg
	pop b
	mov a,c
	sta curHSI
	lda offHSI
	add c
	mov b,a
	call prtchr
	ret
doFF:
	lxi d,cmdFF
	call prtmsg
	ret
init:
	lxi d,reset
	call prtmsg
	ret
setBAK:
	lxi d,cmdBAK
	call prtmsg
	ret
setFWD:
	lxi d,cmdFWD
	call prtmsg
	ret
l04e2h:
	ret

	org	0500h
;	character widths table
 if 1
	db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	db	10, 6, 8,12, 8,16,14, 4, 6, 6,10,10, 6, 8, 6, 8
	db	10,10,10,10,10,10,10,10,10,10, 6, 6,10,10,10,10
	db	16,14,10,12,14,12,12,14,14, 6,10,14,12,14,12,12
	db	10,12,14,10,12,12,12,14,14,14,12,10,10,10,10,10
	db	 6, 8,10, 8,10, 8, 8,10,10, 6, 6,10, 6,12,10, 8
	db	10,10, 8, 8, 8, 8,10,12,10,10,10,10,10,10,10,10
 else
	db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	db	10, 6, 8,12,10,16,14, 4, 6, 6,10,10, 6, 8, 6, 8
	db	10,10,10,10,10,10,10,10,10,10, 6, 6,12,10,12,10
	db	16,14,12,14,14,12,12,14,14, 6,10,14,12,16,14,14
	db	12,14,14,10,12,14,12,16,14,14,12,10,10,10,10,10
	db	 6,10,10,10,10,10, 8,10,10, 6, 6,10, 6,16,10,10
	db	10,10, 8, 8, 8,10,10,14,10,10,10, 6,10,10,10,10
 endif

;	character mapping table
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	' !"#$%&''()*+,-./'
	db	'0123456789:;<=>?'
	db	'@ABCDEFGHIJKLMNO'
	db	'PQRSTUVWXYZ[\]^_'
	db	'`abcdefghijklmno'
	db	'pqrstuvwxyz{|}~',127

	end
