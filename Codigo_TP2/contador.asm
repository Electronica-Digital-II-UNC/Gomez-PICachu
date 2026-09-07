LIST P=16F887
#include <p16f887.inc>

; este archivo lleva el registro del conteo en la variable Conteo    
; se puede llamar a las funciones IncrementarConteo y ResetConteo desde afuera 
; ambas funciones actuan sobre el conteo y lo que muestra los leds en consec
    
GLOBAL	IncrementarContador
GLOBAL	ResetContador    
PuertoLEDS EQU PORTB ;e
 
DatosContador	UDATA
    Conteo	RES 1
CodigoContador	CODE
    
IncrementarContador: 
    BANKSEL Conteo	    ; incremento
    INCF    Conteo , F
    MOVF    Conteo , W
    
    BANKSEL PuertoLEDS	    ; muestra en puertos
    MOVWF   PuertoLEDS
RETURN    
    
ResetContador:
    BANKSEL Conteo	    ; contador a 0
    CLRF    Conteo
    
    BANKSEL PuertoLEDS	    ; apagar los LEDS
    CLRF    PuertoLEDS
RETURN
    
END    