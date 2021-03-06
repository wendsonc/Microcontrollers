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
		AUX
		AUX2
		TEMP_C

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
;No inicio da interrup��o, ser� identifico qual GPIO sofreu modifica��o para
;assim tratar na maneira correta.
;-------------------------------------------------------------------------------
    
	
	BTFSC GPIO, GP0
	GOTO LIGAR_ALERTA ;ACIONA A FUN��O DE ALERTA
	BTFSC GPIO, GP1
	GOTO LIGA_ESQUERDA ;ACIONA A SETA ESQUERDA
	BTFSC GPIO, GP2
	GOTO LIGA_DIREITA ;ACIONA A SETA DIREITA
	GOTO DESATIVA_LEDS ;DESATIVA AS SETAS
	
;-------------------------------------------------------------------------------
;As fun��es LIGA_PISCA, LIGA_ESQUERDA e LIGA_DIREITA s�o usadas para gerar um
;delay de 1s (1Hz), no qual o LED permanecer� em alto durante 0,5s e em baixo 
;no mesmo tempo. O LED ficara sempre acesso at� que uma nova entrada seja 
;colocada no sistema. Para identificar isso, o LED fica ligado por
;1 segundo e depois o algoritmo verifica se ocorreu alguma nova mudan�a na 
;entrada. Se sim, o algoritmo fica esperando o novo sinal. Caso n�o, ele retorna
;a executar o ciclo de instru��es anteriores. 
;-------------------------------------------------------------------------------
; FUN��O ALERTA
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
;ESSA PARTE TESTA SE OCORREU ALGUMA MUDAN�A NOS GPIO'S. AS MUDAN�AS OCORRIDAS
;NO GP0, QUE ACIONA A FUN��O DE ALERTA, POSSUI PRIORIDADE EM RELA��O AS OUTRAS,
;POR ISSO ELA � TESTADA NO INICIO DE CADA LABEL ABAIXO.
;-------------------------------------------------------------------------------
	
TESTANDO_GP0		    ;VERIFICA MUDAN�AS NO GP0
	BTFSS GPIO, GP0
	GOTO ESPERA_SINAL   ;CASO OCORRA MUDAN�A
	GOTO LIGAR_ALERTA   ;CASO PERMANE�A ATIVO, A FUN��O VOLTA A EXECUTAR
	
TESTANDO_GP1		    ;VERIFICA MUDAN�AS NO GP1
	BTFSC GPIO, GP0     ;PRIORIZA O TESTE DO GP0
	GOTO TESTANDO_GP0
	BTFSS GPIO, GP1
	GOTO ESPERA_SINAL   ;CASO OCORRA MUDAN�A
	GOTO LIGA_ESQUERDA  ;CASO PERMANE�A ATIVO, A FUN��O VOLTA A EXECUTAR
	
TESTANDO_GP2		    ;VERIFICA MUDAN�AS NO GP2
	BTFSC GPIO, GP0	    ;PRIORIZA O TESTE DO GP0
	GOTO TESTANDO_GP0
	BTFSS GPIO, GP2
	GOTO ESPERA_SINAL   ;CASO OCORRA MUDAN�A
	GOTO LIGA_DIREITA   ;CASO PERMANE�A ATIVO, A FUN��O VOLTA A EXECUTAR
	
;-------------------------------------------------------------------------------
; Nesse momento, a interrup��o � encerrada para que uma nova seja realizada
;-------------------------------------------------------------------------------
	
ESPERA_SINAL
	BCF INTCON, T0IF
	GOTO SAI_INT


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
	MOVLW	B'00000111'   ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000110'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10101000'     ;Habilitado interrup��o por troca de porta
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00000111'     ;Habilitado interrup��o por troca de porta
	MOVWF	IOC	
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;-------------------------------------------------------------------------------
; Foi utilizado a interrup��o por troca de porta. Quando detectado a troca de
; estimulo entre os GPIO's de entrada, uma interrup��o � acionada.
; Prescaler: 1/128
; Calculo periodo: 1Hz = 1/(1us*128*X) -> X = 7812us (10^6 ciclos de m�quina)
;-------------------------------------------------------------------------------
	
;-------------------------------------------------------------------------------
;O programa permancer� em loop na MAIN enquanto n�o ocorrer nenhum estimulo
;-------------------------------------------------------------------------------
MAIN
	NOP
	NOP
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
