;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      MARÇO DE 2021                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
	
;-------------------------------------------------------------------------------
;   As instruções abaixo irão definir a porcentagem que o valor de saída do ADC
;representa em relação a tensão geral de 5V (equivale a 255 em valor digital).
;Nesse caso, serão definidas numa escala de 0 - 10, em que 10 representa 100%, 
;e a variavel V1 aguardará esse valor. Optou-se por utilizar o formato do 
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
	
;AÇÃO FINAL: VALOR DA PORCENTAGEM DE DUTY CYCLE (V1)

;-------------------------------------------------------------------------------
;Após essa sequencia de instruções, a variavel V1 estará guardando a taxa do
;do ciclo de trabalho. Nesse momento, será calculado o periodo que o LED ficara
;acesso e apagado. A frequência definida é 500Hz. Esta sendo utilizado um 
;prescaler 1:8, logo o periodo completo é de aproximadamente 250us. 
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
	
;AÇÃO FINAL: VALOR DO TEMPO LIGADO (TEMPO_ON) E DO TEMPO DESLIGADO (TEMPO_OFF)
	
;-------------------------------------------------------------------------------
;Por fim, a flag de interrupção é limpa
;-------------------------------------------------------------------------------
FIM_INT
	BCF PIE1, ADIE
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	ADRESH
	
	
	
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

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00010000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00011000'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000010'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11001000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BSF     PIE1, 6
	MOVLW	B'00010000'     ;Habilitado interrupção por troca de porta
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW   B'00001101'
	MOVWF	ADCON0
	MOVLW   B'00000000'
	MOVWF	PIR1
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
;-------------------------------------------------------------------------------
;Nesse programa foi utilizado o conversor AD para realizar a transformação da
;entrada analogica do GP4 em um valor digital. Após realizar todas as configura-
;ções dos registradores, o bit GO_DONE do ADCON0 é acionado para iniciar a 
;conversão. Após toda conversão ser realizar, é gerado uma interrupção para
;tratamento.
;-------------------------------------------------------------------------------

;ESSA FUNÇÃO SERVE APENAS PARA DA TEMPO DE IR NO STIMULUS E ACIONAR O GP4
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
;Depois que o programa sair da interrupção, as variaveis TEMPO_ON e o TEMPO_OFF
;estarão guardando os valores responsaveis pelo tempo de acionamento e
;desligando do GPIO que liga o LED. Esse tempo é baseado no porcentagem de duty
;cycle. 
;-------------------------------------------------------------------------------
	
;TESTA SE A TENSÃO É DE 100% E ACIONAR O LED
TESTE_5V
	MOVFW TEMPO_ON
	MOVWF AUX_TEMP
	MOVLW .250
	SUBWF AUX_TEMP
	BTFSS STATUS, Z
	GOTO TESTE_0V
	BSF GPIO, GP0
	GOTO ESPERANDO_SINAL

;TESTA SE A TENSÃO É DE 0% E DESLIGA O LED
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
