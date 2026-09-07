LIST P=16F887
#include <p16f887.inc>

; Este archivo incluye contadores de retardo de 20 ms y 200 ms. 
; NO realiza ninguna validacion, solo retrasan el programa
; llamar atra vez de: Retardo_20ms o Retardo_200ms

GLOBAL	Retardo_20ms
GLOBAL	Retardo_200ms    
    
DatosRetardo	UDATA	;Variables internas
    CONT1   RES	1
    CONT2   RES	1
CodigoRetardo	CODE

Retardo_20ms:	    ; LLAMAR RETAEDO 20ms
    BANKSEL CONT1 ; seleccion banco
    MOVLW   D'50'
    MOVWF   CONT1
    
    Bucle_1_20ms:
	MOVLW   D'133'
        MOVWF   CONT2
    Bucle_2_20ms:
        DECFSZ  CONT2, F
	GOTO    Bucle_2_20ms
        DECFSZ  CONT1, F
	GOTO    Bucle_1_20ms
RETURN
    
Retardo_200ms:	    ;LLAMAR RETARDO 200ms
    BANKSEL CONT1   ;seleccionar banco
    MOVLW   D'250'
    MOVWF   CONT1
    
    Bucle_1_200ms:
	MOVLW   D'250'
        MOVWF   CONT2
    Bucle_2_200ms:
        DECFSZ  CONT2, F
        GOTO    Bucle_2_200ms
	DECFSZ  CONT1, F
        GOTO    Bucle_1_200ms
RETURN

END