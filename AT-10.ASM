;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      MAR�O DE 2021                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 16F628A                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p16f628a.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BOREN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _XT_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		D_VALOR
		FLAG

		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	CLRF	D_VALOR		    ;LIMPA O VALOR DO DISPLAY
	BCF	PIR1, TMR2IF	    ;LIMPA FLAG DE INTERRUP��O
	INCF	FLAG	    
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

;-------------------------------------------------------------------------------
;SA�DA DO DISPLAY PARA PORTB: E (RB7), D (RB6), C (RB5),  B (RB3), A (RB2),
;F (RB1), G (RB0).
;-------------------------------------------------------------------------------
	
DISPLAY					;DISPLAY DE CATODO COMUM
	MOVF	D_VALOR, W		;MOVE O N�MERO ESCOLHIDO PARA W
	
	ADDWF	PCL, F	;PCL = PCL + W	;RETORNA UM LITERAL 
	
		;'EDC.BAFG'
	RETLW	B'11101110' ;0		
	RETLW	B'00101000' ;1		
	RETLW	B'11001101' ;2	
	RETLW	B'01101101' ;3
	RETLW	B'00101011' ;4
	RETLW	B'01100111' ;5
	RETLW	B'11100111' ;6
	RETLW	B'00101100' ;7
	RETLW	B'11101111' ;8
	RETLW	B'01101111' ;9
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'		;RA1 � INPUT
	MOVWF	TRISA
	MOVLW	B'00000000'		;TODAS S�O OUTPUT
	MOVWF	TRISB
	MOVLW	B'11100010'		;INICIA EM LOW RANGE COM 0.35V NA VREF
	MOVWF	VRCON	
	MOVLW	B'00000000'
	MOVWF	OPTION_REG		;DEFINE OP��ES DE OPERA��O
	MOVLW	B'11000000'
	MOVWF	INTCON			;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	.208			;VALOR PARA CALCULO DO TIMER2
	MOVWF	PR2
	BSF	PIE1, TMR2IE		;ACIONA A INTERRUP��O DO TIMER2
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00100101'
	MOVWF	CMCON			;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'01110011'		;PRE - 1:14 E POS - 1:16
	MOVWF	T2CON
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	CLRF	D_VALOR		    ;LIMPA O VALOR QUE DEFINE O N� DO DISPLAY
	
;-------------------------------------------------------------------------------
;AS TENS�ES S�O COMPARADAS UTILIZANDO O MODO DE OPERA��O 101 (One Independent 
;Comparator) DO COMPARADOR, NO QUAL � UTILIZADO O C2. O PINO DE ESTIMULO � O 
;RA1 E A TENS�O DE COMPARA��O � VREF. ABAIXO � EXIBIDO AS APROXIMA��ES DAS 
;TENS�ES. A SAIDA DO COMPARADOR 2 EST� INVERITDA (C2INV = 1)
;	
;TENS�O 0,35V  =  0.41V  
;TENS�O 0.7V   =  0.625V    
;TENS�O 1,05V  =  1.041V 
;TENS�O	1,4V   =  1,406V 
;TENS�O 1,75V  =  1,718V 
;TENS�O 2,1V   =  2.083V 
;TENS�O 2,45V =	  2,5V
;TENS�O 2,85V =   2,91V
;TENS�O 3,2V  =   3,125V	
;-------------------------------------------------------------------------------
	
MENOR_0.35				
	BTFSC	CMCON, C2OUT		;A TENS�O � MAIOR QUE 0.35?
	GOTO	MAIOR_0.35_MENOR_0.7	;SIM, VAI PARA PR�X. COMPARA��O
	GOTO	EXIBIR			;N�O, EXIBE
	
MAIOR_0.35_MENOR_0.7			
	BANK1		
	MOVLW	B'11100011'		;SETA A VREF PARA 0,625 (3 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V < 0.625
	GOTO	MAIOR_0.7_MENOR_1.05	;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.1			
	MOVWF	D_VALOR			;GUARDA '1' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_0.7_MENOR_1.05			 
	BANK1
	MOVLW	B'11100101'		;SETA A VREF PARA 1.041	 (5 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V < 1.041
	GOTO	MAIOR_1.05_MENOR_1.4	;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.2			
	MOVWF	D_VALOR			;GUARDA '2' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY

MAIOR_1.05_MENOR_1.4
	BANK1
	MOVLW	B'11000001'		;SETA A VREF PARA 1.406 (1 digitall)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V < 1.406
	GOTO	MAIOR_1.4_MENOR_1.75	;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.3
	MOVWF	D_VALOR			;GUARDA '3' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_1.4_MENOR_1.75
	BANK1
	MOVLW	B'11000011'		;SETA A VREF PARA 1,718 (3 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V <  1,718
	GOTO	MAIOR_1.75_MENOR_2.1	;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.4
	MOVWF	D_VALOR			;GUARDA '4' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY

MAIOR_1.75_MENOR_2.1
	BANK1
	MOVLW	B'11101010'		;SETA A VREF PARA 2.083 (10 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V <  2.083 
	GOTO	MAIOR_2.1_MENOR_2.45	;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.5
	MOVWF	D_VALOR			;GUARDA '5' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	    
MAIOR_2.1_MENOR_2.45			;SETA A VREF PARA 2,5 (12 digital)
	BANK1
	MOVLW	B'11101100'		;MOVE PARA O VRCON
	MOVWF	VRCON	
	BANK0
	BTFSC	CMCON, C2OUT		;V <  2.5
	GOTO	MAIOR_2.45_MENOR_2.85	;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.6
	MOVWF	D_VALOR			;GUARDA '6' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_2.45_MENOR_2.85			;SETA A VREF PARA 2,91 (14 digital)
	BANK1
	MOVLW	B'11101110'		;MOVE PARA O VRCON
	MOVWF	VRCON	
	BANK0
	BTFSC	CMCON, C2OUT		 ;V <  2,91
	GOTO	MAIOR_2.85_MENOR_3.2	 ;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.7
	MOVWF	D_VALOR			;GUARDA '7' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_2.85_MENOR_3.2			
	BANK1
	MOVLW	B'11001100'		;SETA A VREF PARA 3,125 (12 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V <  3,125
	GOTO	MAIOR_3.2_MENOR_3.5	;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.8
	MOVWF	D_VALOR			;GUARDA '8' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_3.2_MENOR_3.5
	BANK1
	MOVLW	B'11001110'		;SETA A VREF PARA 3,5 (14 digital)
	MOVWF	VRCON	
	BANK0
	BTFSC	CMCON, C2OUT		;V <  3,5
	GOTO	FINAL			;SIM, VAI PARA PR�X. COMPARA��O
	MOVLW	.9
	MOVWF	D_VALOR			;GUARDA '9' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
EXIBIR
	CALL	DISPLAY			;RETORNA 8 BITS
	MOVWF	PORTB			;MOVE PARA SER EXIBIDA NA PORTB
	
	BSF	T2CON, TMR2ON		;ACIONA O TIMER2
	
DELAY
	MOVLW	.1			;FLAG PARA SABER SE SAIU DO TIMER2
	SUBWF	FLAG, W			;ESTOUROU = 0, N�O ESTOUROU = 1
	BTFSS	STATUS, Z		;TESTA A FLAG
	GOTO	DELAY			;ACIONA PARA DELAY AT� ESTOURAR
	GOTO	FINAL			;ESTOUROU, SAI DO DELAY
	
FINAL
	NOP
	BCF	CMCON, C2OUT		;LIMPA A SAIDA DO COMPARADOR 2
	CLRF	FLAG			;LIMPA A FLAG
	GOTO	MAIN			;RETORNA O PROGRAMA
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
