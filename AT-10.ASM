;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      MARÇO DE 2021                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 16F628A                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p16f628a.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BOREN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _XT_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		D_VALOR
		FLAG

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	CLRF	D_VALOR		    ;LIMPA O VALOR DO DISPLAY
	BCF	PIR1, TMR2IF	    ;LIMPA FLAG DE INTERRUPÇÃO
	INCF	FLAG	    
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

;-------------------------------------------------------------------------------
;SAÍDA DO DISPLAY PARA PORTB: E (RB7), D (RB6), C (RB5),  B (RB3), A (RB2),
;F (RB1), G (RB0).
;-------------------------------------------------------------------------------
	
DISPLAY					;DISPLAY DE CATODO COMUM
	MOVF	D_VALOR, W		;MOVE O NÚMERO ESCOLHIDO PARA W
	
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
	MOVLW	B'00000010'		;RA1 É INPUT
	MOVWF	TRISA
	MOVLW	B'00000000'		;TODAS SÃO OUTPUT
	MOVWF	TRISB
	MOVLW	B'11100010'		;INICIA EM LOW RANGE COM 0.35V NA VREF
	MOVWF	VRCON	
	MOVLW	B'00000000'
	MOVWF	OPTION_REG		;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON			;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	.208			;VALOR PARA CALCULO DO TIMER2
	MOVWF	PR2
	BSF	PIE1, TMR2IE		;ACIONA A INTERRUPÇÃO DO TIMER2
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00100101'
	MOVWF	CMCON			;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'01110011'		;PRE - 1:14 E POS - 1:16
	MOVWF	T2CON
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	CLRF	D_VALOR		    ;LIMPA O VALOR QUE DEFINE O Nº DO DISPLAY
	
;-------------------------------------------------------------------------------
;AS TENSÕES SÃO COMPARADAS UTILIZANDO O MODO DE OPERAÇÃO 101 (One Independent 
;Comparator) DO COMPARADOR, NO QUAL É UTILIZADO O C2. O PINO DE ESTIMULO É O 
;RA1 E A TENSÃO DE COMPARAÇÃO É VREF. ABAIXO É EXIBIDO AS APROXIMAÇÕES DAS 
;TENSÕES. A SAIDA DO COMPARADOR 2 ESTÁ INVERITDA (C2INV = 1)
;	
;TENSÃO 0,35V  =  0.41V  
;TENSÃO 0.7V   =  0.625V    
;TENSÃO 1,05V  =  1.041V 
;TENSÃO	1,4V   =  1,406V 
;TENSÃO 1,75V  =  1,718V 
;TENSÃO 2,1V   =  2.083V 
;TENSÃO 2,45V =	  2,5V
;TENSÃO 2,85V =   2,91V
;TENSÃO 3,2V  =   3,125V	
;-------------------------------------------------------------------------------
	
MENOR_0.35				
	BTFSC	CMCON, C2OUT		;A TENSÃO É MAIOR QUE 0.35?
	GOTO	MAIOR_0.35_MENOR_0.7	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	GOTO	EXIBIR			;NÃO, EXIBE
	
MAIOR_0.35_MENOR_0.7			
	BANK1		
	MOVLW	B'11100011'		;SETA A VREF PARA 0,625 (3 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V < 0.625
	GOTO	MAIOR_0.7_MENOR_1.05	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.1			
	MOVWF	D_VALOR			;GUARDA '1' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_0.7_MENOR_1.05			 
	BANK1
	MOVLW	B'11100101'		;SETA A VREF PARA 1.041	 (5 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V < 1.041
	GOTO	MAIOR_1.05_MENOR_1.4	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.2			
	MOVWF	D_VALOR			;GUARDA '2' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY

MAIOR_1.05_MENOR_1.4
	BANK1
	MOVLW	B'11000001'		;SETA A VREF PARA 1.406 (1 digitall)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V < 1.406
	GOTO	MAIOR_1.4_MENOR_1.75	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.3
	MOVWF	D_VALOR			;GUARDA '3' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_1.4_MENOR_1.75
	BANK1
	MOVLW	B'11000011'		;SETA A VREF PARA 1,718 (3 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V <  1,718
	GOTO	MAIOR_1.75_MENOR_2.1	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.4
	MOVWF	D_VALOR			;GUARDA '4' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY

MAIOR_1.75_MENOR_2.1
	BANK1
	MOVLW	B'11101010'		;SETA A VREF PARA 2.083 (10 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V <  2.083 
	GOTO	MAIOR_2.1_MENOR_2.45	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.5
	MOVWF	D_VALOR			;GUARDA '5' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	    
MAIOR_2.1_MENOR_2.45			;SETA A VREF PARA 2,5 (12 digital)
	BANK1
	MOVLW	B'11101100'		;MOVE PARA O VRCON
	MOVWF	VRCON	
	BANK0
	BTFSC	CMCON, C2OUT		;V <  2.5
	GOTO	MAIOR_2.45_MENOR_2.85	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.6
	MOVWF	D_VALOR			;GUARDA '6' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_2.45_MENOR_2.85			;SETA A VREF PARA 2,91 (14 digital)
	BANK1
	MOVLW	B'11101110'		;MOVE PARA O VRCON
	MOVWF	VRCON	
	BANK0
	BTFSC	CMCON, C2OUT		 ;V <  2,91
	GOTO	MAIOR_2.85_MENOR_3.2	 ;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.7
	MOVWF	D_VALOR			;GUARDA '7' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_2.85_MENOR_3.2			
	BANK1
	MOVLW	B'11001100'		;SETA A VREF PARA 3,125 (12 digital)
	MOVWF	VRCON			;MOVE PARA O VRCON
	BANK0
	BTFSC	CMCON, C2OUT		;V <  3,125
	GOTO	MAIOR_3.2_MENOR_3.5	;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.8
	MOVWF	D_VALOR			;GUARDA '8' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
MAIOR_3.2_MENOR_3.5
	BANK1
	MOVLW	B'11001110'		;SETA A VREF PARA 3,5 (14 digital)
	MOVWF	VRCON	
	BANK0
	BTFSC	CMCON, C2OUT		;V <  3,5
	GOTO	FINAL			;SIM, VAI PARA PRÓX. COMPARAÇÃO
	MOVLW	.9
	MOVWF	D_VALOR			;GUARDA '9' PARA ACIONAR O DISPLAY
	GOTO	EXIBIR			;CHAMA PARA EXIBIR NO DISPLAY
	
EXIBIR
	CALL	DISPLAY			;RETORNA 8 BITS
	MOVWF	PORTB			;MOVE PARA SER EXIBIDA NA PORTB
	
	BSF	T2CON, TMR2ON		;ACIONA O TIMER2
	
DELAY
	MOVLW	.1			;FLAG PARA SABER SE SAIU DO TIMER2
	SUBWF	FLAG, W			;ESTOUROU = 0, NÃO ESTOUROU = 1
	BTFSS	STATUS, Z		;TESTA A FLAG
	GOTO	DELAY			;ACIONA PARA DELAY ATÉ ESTOURAR
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
