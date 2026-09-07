LIST P=16F887
#include <p16f887.inc>
__CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON
__CONFIG _CONFIG2, _LVP_OFF & _BOR_OFF

; Funciones que llama el main:
EXTERN  Retardo_20ms
EXTERN  Retardo_200ms
EXTERN  IncrementarContador
EXTERN  ResetContador
EXTERN  InicializarSecuencia
EXTERN  RotarDer
EXTERN  RotarIzq
    
; Variables que llama el main:
EXTERN  Secu
EXTERN  Sentido
    
PuertoLEDS  EQU	PORTB	; salida a leds

DatosMain   UDATA		; variables para la secuencia
EstadoAnteriorA0    RES     1
EstadoAnteriorA1    RES     1  
  
CodigoMain  CODE

ORG     0x00
GOTO    Inicio		; inicio del progarma
ORG     0x05  
  
Inicio:			    ; Programa de arranque, una vez.
    BSF     STATUS,RP0
    BSF     STATUS,RP1      ; Banco 3
    CLRF    ANSEL
    CLRF    ANSELH
    BCF     STATUS,RP1      ; Banco 1
    CLRF    TRISB           ; LEDs como salida
    
    MOVLW   0x03
    MOVWF   TRISA           ; RA0, RA1 como entradas
    BCF     STATUS,RP0      ; volver a Banco 0

CALL    InicializarSecuencia
BANKSEL PORTA
    
Espera:		   ; Loop principal, espera pulsacion Ao y valida, sino->Espera2
    BTFSS   PORTA,0		; Revisa A0
    GOTO    Espera2		    ; Si a0 es 0, va a Espera2 a ver A1
    CALL    Retardo_20ms	    ; si A0 es 1, llama retardo para ver rebbote
    BANKSEL PORTA
    BTFSS   PORTA,0			; asi A0 es 1, pasa a EsperarSoltarA0 
    GOTO    Espera			; si A0 es 0, vuelve a Espera 
    
    EsperarSoltarA0:	    ; llega solo si A0 es 1 despues del retardo 20ms 
	BTFSC   PORTA,0		; revisa A0
	GOTO    EsperarSoltarA0    ; si A0 es 1, vuelve a EsperarSoltarA0 
	GOTO    LoopContador	    ; si A0 es 0, va al LoopContador 
	
; siempre va a algun lado antes de llegar a esta linea
	
Espera2:	    ; Loop principal, espera pulso en A1 y valida, sino-> Espera	
    BTFSS   PORTA,1		; Revisa A1
    GOTO    Espera		    ; Si A1 es 0, va a Espera , a ver A0 
    CALL    Retardo_20ms	    ; Si A! es 1, llama a retardo de 20ms
    BANKSEL PORTA
    BTFSS   PORTA,1			; si A1 es 1, pasa a EsperaSoltarA1 
    GOTO    Espera			; si A1 es 0, vuelve a Espera 
    
EsperaSoltarA1:		    ; Llega solo si A1 es 1 despus del retardo 20ms
    BTFSC   PORTA,1		;Revisa A1
    GOTO    EsperaSoltarA1	    ; Si A1 es 1, vuelve a EsperarSoltarA1 (63)
    GOTO    EntrarSecuencia	    ; si A1 es 0, va a LoopSecuencia
    
; siempre va a algun lado antes de llegar a esta linea
    
;-- CODIGO DEL LOOP DEL CONTADOR --
    ; Las primeras 5 lineas del LoopContador son para mantener el loop, 
    ; es decir, el pulso que se dio por valido en Espera, sirve para entrar a 
    ; este loop, no para sumar al contador. Una vez dentro, los pulsos si 
    ; suman al contador
    
LoopContador:		;primera parte del loop general de contador. revisa A0
    BTFSS   PORTA,0
    GOTO    ChequearA1	    ;lleva a chequear si se pulsa A1
    CALL    Retardo_20ms
    BANKSEL PORTA
    BTFSS   PORTA,0	    ; si el pulso es valido (A0=1) pasa a incrementar
    GOTO    LoopContador    ; si no es valido vuelve al loop del contador
    
    CALL IncrementarContador
    BANKSEL PORTA
    
    ; siempre va a algun lado antes de llegar a esta linea
    
    EsperaSoltarA0Contador:
	BTFSC   PORTA,0		    ; evalua A0
        GOTO    EsperaSoltarA0Contador	; si A0 = 1, vulve a este loop 
	GOTO    LoopContador		; si es = 0, vuelve al Loop del contador
	
	; simpre va algun lado antes de llegar a esta linea
	
ChequearA1:		; segunda parte del loop general del contador, revisa A1
    BTFSS	PORTA,1
    GOTO	LoopContador
    CALL	Retardo_20ms
    BANKSEL PORTA
    BTFSS	PORTA,1
    GOTO	LoopContador
	
    CALL	ResetContador
    BANKSEL PORTA
	
    EsperaSoltarA1Contador:	; codigo de espera para soltar A!
	BTFSC   PORTA,1
	GOTO    EsperaSoltarA1Contador
        GOTO    Espera

; Siempre va a algun lado antes de llegar a esta linea
	
;-- CODIGO DEL LOOP DE LA SECUENCIA --
	
	
EntrarSecuencia:		;limpia y prepara para el loop principal de secu
    BANKSEL EstadoAnteriorA0
    CLRF    EstadoAnteriorA0
    CLRF    EstadoAnteriorA1
    GOTO    LoopSecuencia	
    
LoopSecuencia:
    BANKSEL Sentido 
    BTFSC   Sentido, 0
    GOTO    Rotar_Izq_Sec
    CALL    RotarDer
    GOTO    Mostrar_Sec
    
    Rotar_Izq_Sec:
    CALL    RotarIzq
    
    Mostrar_Sec:
	BANKSEL Secu
        MOVF    Secu, W
	BANKSEL PuertoLEDS
        MOVWF   PuertoLEDS

	CALL    Retardo_200ms
	BANKSEL PORTA 
	
	BTFSS   PORTA, 1		; cambia la secuencia xuando A1 0->1
	GOTO    A1_Bajo_Sec
	BANKSEL EstadoAnteriorA1
        BTFSC   EstadoAnteriorA1, 0
	GOTO    A1_Ya_Alto_Sec          ; ya estaba en 1, no es flanco nuevo
	BANKSEL Sentido 
        MOVLW   0x01
	XORWF   Sentido, F              ; flanco real -> invertir sentido

    A1_Ya_Alto_Sec:
	BANKSEL EstadoAnteriorA1
	BSF     EstadoAnteriorA1, 0
        GOTO    Chequear_A0_Sec
    A1_Bajo_Sec:
	BANKSEL EstadoAnteriorA1
        BCF     EstadoAnteriorA1, 0
	BANKSEL PORTA 
	
    Chequear_A0_Sec:
	BTFSS   PORTA, 0
	GOTO    A0_Bajo_Sec
	BANKSEL EstadoAnteriorA0
        BTFSC   EstadoAnteriorA0, 0
	GOTO    LoopSecuencia          ; ya estaba en 1, seguir rotando
        GOTO    Espera                  ; flanco real -> detener y salir
    A0_Bajo_Sec:
	BANKSEL EstadoAnteriorA0
	BCF     EstadoAnteriorA0, 0
        GOTO    LoopSecuencia
	
	
END