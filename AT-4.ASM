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
		AUX
		AUX2
		TEMP_C

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
;No inicio da interrupção, será identifico qual GPIO sofreu modificação para
;assim tratar na maneira correta.
;-------------------------------------------------------------------------------
    
	
	BTFSC GPIO, GP0
	GOTO LIGAR_ALERTA ;ACIONA A FUNÇÃO DE ALERTA
	BTFSC GPIO, GP1
	GOTO LIGA_ESQUERDA ;ACIONA A SETA ESQUERDA
	BTFSC GPIO, GP2
	GOTO LIGA_DIREITA ;ACIONA A SETA DIREITA
	GOTO DESATIVA_LEDS ;DESATIVA AS SETAS
	
;-------------------------------------------------------------------------------
;As funções LIGA_PISCA, LIGA_ESQUERDA e LIGA_DIREITA são usadas para gerar um
;delay de 1s (1Hz), no qual o LED permanecerá em alto durante 0,5s e em baixo 
;no mesmo tempo. O LED ficara sempre acesso até que uma nova entrada seja 
;colocada no sistema. Para identificar isso, o LED fica ligado por
;1 segundo e depois o algoritmo verifica se ocorreu alguma nova mudança na 
;entrada. Se sim, o algoritmo fica esperando o novo sinal. Caso não, ele retorna
;a executar o ciclo de instruções anteriores. 
;-------------------------------------------------------------------------------
; FUNÇÃO ALERTA
;-------------------------------------------------------------------------------
LIGAR_ALERTA                ;INICIO DO LOOP (HIGH) - TEMPO: 0s
	BSF GPIO, GP4
	BSF GPIO, GP5
	MOVLW .16
	MOVWF AUX
	CLRF TMR0
	BCF INTCON, T0IF
	
LOOP_ON
	BTFSS INTCON, T0IF
	GOTO LOOP_ON
	BCF INTCON, T0IF
	DECFSZ AUX
	GOTO LOOP_ON
	GOTO DESLIGA_ALERTA
	
DESLIGA_ALERTA		   ;MEIO DO LOOP (MUDA DE HIGH PARA LOW) - TEMPO: 0.5s
	BCF GPIO, GP4
	BCF GPIO, GP5
	MOVLW .16
	MOVWF AUX2
	CLRF TMR0
	BCF INTCON, T0IF
	
LOOP_OFF
	BTFSS INTCON, T0IF  
	GOTO LOOP_OFF
	BCF INTCON, T0IF
	DECFSZ AUX2
	GOTO LOOP_OFF
	GOTO TESTANDO_GP0   ;FIM DO LOOP (LOW) - TEMPO: 1s
	
;-------------------------------------------------------------------------------
; ACIONA O LED-ESQUERDO
;-------------------------------------------------------------------------------

LIGA_ESQUERDA		   ;INICIO DO LOOP (HIGH) - TEMPO: 0s
	BSF GPIO, GP4
	MOVLW .16
	MOVWF AUX
	CLRF TMR0
	BCF INTCON, T0IF
	
LOOP_ON_ESQ
	BTFSS INTCON, T0IF
	GOTO LOOP_ON_ESQ
	BCF INTCON, T0IF
	DECFSZ AUX
	GOTO LOOP_ON_ESQ
	GOTO DESLIGA_ESQ
	
DESLIGA_ESQ		;MEIO DO LOOP (MUDA DE HIGH PARA LOW) - TEMPO: 0.5s
	BCF GPIO, GP4
	MOVLW .16
	MOVWF AUX2
	CLRF TMR0
	BCF INTCON, T0IF
	
LOOP_OFF_ESQ
	BTFSS INTCON, T0IF  
	GOTO LOOP_OFF_ESQ
	BCF INTCON, T0IF
	DECFSZ AUX2
	GOTO LOOP_OFF_ESQ
	GOTO TESTANDO_GP1   ;FIM DO LOOP (LOW) - TEMPO: 1s

;-------------------------------------------------------------------------------
; ACIONA O LED-DIREITO
;-------------------------------------------------------------------------------
	
LIGA_DIREITA		;INICIO DO LOOP (HIGH) - TEMPO: 0s
	BSF GPIO, GP5
	MOVLW .16
	MOVWF AUX
	CLRF TMR0
	BCF INTCON, T0IF
	
LOOP_ON_DIR
	BTFSS INTCON, T0IF
	GOTO LOOP_ON_DIR
	BCF INTCON, T0IF
	DECFSZ AUX
	GOTO LOOP_ON_DIR
	GOTO DESLIGA_DIR
	
DESLIGA_DIR		;MEIO DO LOOP (MUDA DE HIGH PARA LOW) - TEMPO: 0.5s
	BCF GPIO, GP5
	MOVLW .16
	MOVWF AUX2
	CLRF TMR0
	BCF INTCON, T0IF
	
LOOP_OFF_DIR
	BTFSS INTCON, T0IF  
	GOTO LOOP_OFF_DIR
	BCF INTCON, T0IF
	DECFSZ AUX2
	GOTO LOOP_OFF_DIR
	GOTO TESTANDO_GP2   ;FIM DO LOOP (LOW) - TEMPO: 1s

;-------------------------------------------------------------------------------
; DESATIVA OS LEDS
;-------------------------------------------------------------------------------
	
DESATIVA_LEDS
	BCF GPIO, GP4
	BCF GPIO, GP5
	BCF INTCON, GPIF
	GOTO ESPERA_SINAL
	
;-------------------------------------------------------------------------------
;ESSA PARTE TESTA SE OCORREU ALGUMA MUDANÇA NOS GPIO'S. AS MUDANÇAS OCORRIDAS
;NO GP0, QUE ACIONA A FUNÇÃO DE ALERTA, POSSUI PRIORIDADE EM RELAÇÃO AS OUTRAS,
;POR ISSO ELA É TESTADA NO INICIO DE CADA LABEL ABAIXO.
;-------------------------------------------------------------------------------
	
TESTANDO_GP0		    ;VERIFICA MUDANÇAS NO GP0
	BTFSS GPIO, GP0
	GOTO ESPERA_SINAL   ;CASO OCORRA MUDANÇA
	GOTO LIGAR_ALERTA   ;CASO PERMANEÇA ATIVO, A FUNÇÃO VOLTA A EXECUTAR
	
TESTANDO_GP1		    ;VERIFICA MUDANÇAS NO GP1
	BTFSC GPIO, GP0     ;PRIORIZA O TESTE DO GP0
	GOTO TESTANDO_GP0
	BTFSS GPIO, GP1
	GOTO ESPERA_SINAL   ;CASO OCORRA MUDANÇA
	GOTO LIGA_ESQUERDA  ;CASO PERMANEÇA ATIVO, A FUNÇÃO VOLTA A EXECUTAR
	
TESTANDO_GP2		    ;VERIFICA MUDANÇAS NO GP2
	BTFSC GPIO, GP0	    ;PRIORIZA O TESTE DO GP0
	GOTO TESTANDO_GP0
	BTFSS GPIO, GP2
	GOTO ESPERA_SINAL   ;CASO OCORRA MUDANÇA
	GOTO LIGA_DIREITA   ;CASO PERMANEÇA ATIVO, A FUNÇÃO VOLTA A EXECUTAR
	
;-------------------------------------------------------------------------------
; Nesse momento, a interrupção é encerrada para que uma nova seja realizada
;-------------------------------------------------------------------------------
	
ESPERA_SINAL
	BCF INTCON, T0IF
	GOTO SAI_INT


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
	MOVLW	B'00000111'   ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000110'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10101000'     ;Habilitado interrupção por troca de porta
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00000111'     ;Habilitado interrupção por troca de porta
	MOVWF	IOC	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;-------------------------------------------------------------------------------
; Foi utilizado a interrupção por troca de porta. Quando detectado a troca de
; estimulo entre os GPIO's de entrada, uma interrupção é acionada.
; Prescaler: 1/128
; Calculo periodo: 1Hz = 1/(1us*128*X) -> X = 7812us (10^6 ciclos de máquina)
;-------------------------------------------------------------------------------
	
;-------------------------------------------------------------------------------
;O programa permancerá em loop na MAIN enquanto não ocorrer nenhum estimulo
;-------------------------------------------------------------------------------
MAIN
	NOP
	NOP
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
