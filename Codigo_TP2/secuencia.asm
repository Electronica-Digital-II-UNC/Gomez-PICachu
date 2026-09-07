LIST P=16F887
#include    <p16f887.inc>

; en este caos, la muestra a leds no se encarga esta seccion, por eso se expor-
; ta las variables Secu y Sentido para que pueda usarse en main para los leds.
; del exterior, pueden llamarse las funcoines InicializarSecuencia, RotarIzq    
; y RotarDer
    
GLOBAL	Secu
GLOBAL	Sentido

GLOBAL	InicializarSecuencia
GLOBAL	RotarDer
GLOBAL	RotarIzq

PuertoLEDS  EQU	PORTB
  
DatosSecuencia	UDATA
	Secu	RES 1
	Sentido	RES 1
CodigoSecuencia	CODE
	
InicializarSecuencia:	; se llama una sola vez, para limpiar
    BANKSEL Secu
    MOVLW   0x01
    MOVWF   Secu
    CLRF    Sentido
RETURN
    
RotarDer:
    BANKSEL Secu
    BCF     STATUS, C
    BTFSC   Secu, 0
    BSF     STATUS, C
    RRF     Secu, F
RETURN

RotarIzq:
    BANKSEL Secu
    BCF     STATUS, C
    BTFSC   Secu, 7
    BSF     STATUS, C
    RLF     Secu, F
RETURN

END