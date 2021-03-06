;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      MAR�O DE 2021                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		VALOR_ADC
		AUX
		V
		V1
		V2
		VALOR_IN
		TEMPO_ON
		TEMPO_OFF
		AUX_TEMP
		AUX_TEMP2

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
	
;-------------------------------------------------------------------------------
;   As instru��es abaixo ir�o definir a porcentagem que o valor de sa�da do ADC
;representa em rela��o a tens�o geral de 5V (equivale a 255 em valor digital).
;Nesse caso, ser�o definidas numa escala de 0 - 10, em que 10 representa 100%, 
;e a variavel V1 aguardar� esse valor. Optou-se por utilizar o formato do 
;resultado do ADC justificado a esquerda, trabalhando apenas com o ADRESH e
;ignorando os dois bits menos significativos do ADRESL.
;-------------------------------------------------------------------------------
	
DUTY_CYCLE
	MOVLW .0
	MOVWF V1
	MOVLW .1
	MOVWF V2
	BCF STATUS, C
	MOVF ADRESH, W
	MOVWF VALOR_ADC
	MOVLW .10
	MOVWF AUX
	
LOOP	
	BTFSC STATUS, C
	GOTO ADI
	MOVFW VALOR_ADC
	ADDWF V2
	DECFSZ AUX
	GOTO LOOP
	BTFSC STATUS, C
	GOTO AD2
	GOTO CALCULO_ON
ADI
	INCF V1
	INCF V2
	BCF STATUS, C
	GOTO LOOP

AD2
	INCF V1
	GOTO CALCULO_OFF
	
;A��O FINAL: VALOR DA PORCENTAGEM DE DUTY CYCLE (V1)

;-------------------------------------------------------------------------------
;Ap�s essa sequencia de instru��es, a variavel V1 estar� guardando a taxa do
;do ciclo de trabalho. Nesse momento, ser� calculado o periodo que o LED ficara
;acesso e apagado. A frequ�ncia definida � 500Hz. Esta sendo utilizado um 
;prescaler 1:8, logo o periodo completo � de aproximadamente 250us. 
;-------------------------------------------------------------------------------

CALCULO_OFF
	BCF STATUS, Z
	MOVLW .10
	MOVWF V
	MOVFW V1
	SUBWF V 

LOOP_MULTI 
	BTFSC STATUS, Z 
	GOTO CALCULO_ON
	MOVLW .25
	ADDWF TEMPO_OFF
	DECF V 
	GOTO LOOP_MULTI  
	
	
CALCULO_ON 
	BCF STATUS, Z
LOOP_MULTI1
	BTFSC STATUS, Z 
	GOTO FIM_INT
	MOVLW .25
	ADDWF TEMPO_ON 
	DECF V1 
	GOTO LOOP_MULTI1
	
;A��O FINAL: VALOR DO TEMPO LIGADO (TEMPO_ON) E DO TEMPO DESLIGADO (TEMPO_OFF)
	
;-------------------------------------------------------------------------------
;Por fim, a flag de interrup��o � limpa
;-------------------------------------------------------------------------------
FIM_INT
	BCF PIE1, ADIE
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	ADRESH
	
	
	
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

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00010000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00011000'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000010'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'11001000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BSF     PIE1, 6
	MOVLW	B'00010000'     ;Habilitado interrup��o por troca de porta
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW   B'00001101'
	MOVWF	ADCON0
	MOVLW   B'00000000'
	MOVWF	PIR1
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
;-------------------------------------------------------------------------------
;Nesse programa foi utilizado o conversor AD para realizar a transforma��o da
;entrada analogica do GP4 em um valor digital. Ap�s realizar todas as configura-
;��es dos registradores, o bit GO_DONE do ADCON0 � acionado para iniciar a 
;convers�o. Ap�s toda convers�o ser realizar, � gerado uma interrup��o para
;tratamento.
;-------------------------------------------------------------------------------

;ESSA FUN��O SERVE APENAS PARA DA TEMPO DE IR NO STIMULUS E ACIONAR O GP4
ESPERANDO_SINAL
	NOP
	NOP
	NOP
	
CONFIG_CONV
	BSF ADCON0, 1
	
LOOP_PRINCIPAL
	MOVLW .0
	MOVWF TEMPO_ON
	MOVLW .0
	MOVWF TEMPO_OFF
	BCF GPIO, GP0
	BTFSC ADCON0, 1
	GOTO LOOP_PRINCIPAL
	GOTO TESTE_5V
;-------------------------------------------------------------------------------
;Depois que o programa sair da interrup��o, as variaveis TEMPO_ON e o TEMPO_OFF
;estar�o guardando os valores responsaveis pelo tempo de acionamento e
;desligando do GPIO que liga o LED. Esse tempo � baseado no porcentagem de duty
;cycle. 
;-------------------------------------------------------------------------------
	
;TESTA SE A TENS�O � DE 100% E ACIONAR O LED
TESTE_5V
	MOVFW TEMPO_ON
	MOVWF AUX_TEMP
	MOVLW .250
	SUBWF AUX_TEMP
	BTFSS STATUS, Z
	GOTO TESTE_0V
	BSF GPIO, GP0
	GOTO ESPERANDO_SINAL

;TESTA SE A TENS�O � DE 0% E DESLIGA O LED
TESTE_0V
	MOVFW TEMPO_ON
	MOVWF AUX_TEMP2
	MOVLW .0
	SUBWF AUX_TEMP2
	BTFSS STATUS, Z
	GOTO ACENDER_LED
	BCF GPIO, GP0
	GOTO ESPERANDO_SINAL
	

ACENDER_LED	      ;INICIO DO LOOP (HIGH) 
	CLRF TMR0
	MOVLW .255
	MOVWF TMR0
	MOVFW TEMPO_ON
	SUBWF TMR0
	BCF INTCON, T0IF
	BSF GPIO, GP0
	
LOOP_ON
	BTFSS INTCON, T0IF
	GOTO LOOP_ON
	
DESLIGA_LED		;MEIO DO LOOP (MUDA DE HIGH PARA LOW) 
	MOVLW .255
	MOVWF TMR0
	MOVFW TEMPO_OFF
	SUBWF TMR0
	BCF INTCON, T0IF
	BCF GPIO, GP0
	
LOOP_OFF
	BTFSS INTCON, T0IF  
	GOTO LOOP_OFF
	GOTO ESPERANDO_SINAL  ;FIM DO LOOP (LOW)
	
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
