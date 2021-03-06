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
		TEMPO
		AUX
		DADO

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
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES
	
	BSF	GPIO, GP0	;ACIONA O GP0
	MOVLW	.35
	MOVWF	TEMPO
	BCF	INTCON, GPIF
	BCF	INTCON, GPIE
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

MODO_EXECUCAO
	BANK1
	BSF	INTCON, GPIE
	BCF	TRISIO, 0	;TROCA DE INPUT PARA OUTPUT
	BANK0
	MOVLW   B'00001001'	;CONVERSOR ATIVADO
	MOVWF	ADCON0
	MOVLW	B'00000000'	;LIMPA A VARIAVEL QUE GUARDA OS DADOS
	MOVWF	ADRESH
	RETURN
    
MODO_ECONOMIA
	BANK0
	MOVLW   B'00000000'	;CONVERSOR DESATIVADO
	MOVWF	ADCON0
	MOVLW	B'00000111'	;COMPARADOR EM MODO OFF
	MOVWF	CMCON	
	BANK1
	MOVLW	B'00000000'	;DESABILITAR O BIT 7
	MOVWF	VRCON			    
	RETURN
	
;FUN��O GENERICA PARA FUNCIONAMENTO DE DELAY CURTO 
	
DELAY_US		      
	BCF INTCON, T0IF	;ZERA A FLAG DE ESTOURO
	
LOOP_1
	BTFSS INTCON, T0IF	;TESTA SE O TMR0 ESTOUROU
	GOTO LOOP_1		;N�O, CONTINUA NO LOOP
	RETURN			;SIM, RETORNA
	
;FUN��O GENERICA PARA FUNCIONAMENTO DE DELAY LONGOS

DELAY_MS		      
	CLRF TMR0		;LIMPA O TMR0	
	BCF INTCON, T0IF	;ZERA A FLAG DE ESTOURO
	
LOOP_2
	BTFSS INTCON, T0IF	;TESTA SE O TMR0 ESTOUROU
	GOTO LOOP_2		;N�O, CONTINUA NO LOOP
	BCF INTCON, T0IF	;SIM, LIMPA A FLAG DE ESTOURO
	DECFSZ TEMPO		;DECREMENTA O TEMPO DE VEZES QUE VAI ESTOURAR
	GOTO LOOP_2		;VOLTA A CONTAR AT� 255
	RETURN			;ACABOU? RETORNA
	
;-------------------------------------------------------------------------------
;PARA BIT IGUAL 0 = 50us EM LOW E 26-28us HIGH
;PARA BIT IGUAL 1 = 50us EM LOW E 70us HIGH
;-------------------------------------------------------------------------------

ENVIA_1
	MOVLW	.233	    ;CONFIGURA PARA DURAR 50US
	MOVWF	TMR0
	BCF	GPIO, GP0   ;DESCE O NIVEL LOGICO (LOW)
	CALL	DELAY_US    ;CHAMA O DELAY EM MICROSEGUNDOS
	MOVLW	.222	    ;CONFIGURA PARA DURAR 70US
	MOVWF	TMR0
	BSF	GPIO, GP0   ;SOBE O NIVEL LOGICO (HIGH)
	CALL	DELAY_US    ;CHAMA O DELAY EM MICROSEGUNDOS
	RETURN 
	
ENVIA_0
	MOVLW	.233	    ;CONFIGURA PARA DURAR 50US
	MOVWF	TMR0
	BCF	GPIO, GP0   ;DESCE O NIVEL LOGICO (LOW)
	CALL	DELAY_US    ;CHAMA O DELAY EM MICROSEGUNDOS
	MOVLW	.245	    ;CONFIGURA PARA DURAR 28US
	MOVWF	TMR0
	BSF	GPIO, GP0   ;SOBE O NIVEL LOGICO (HIGH)
	CALL	DELAY_US    ;CHAMA O DELAY EM MICROSEGUNDOS
	RETURN
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000101'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00010100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000000'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10001000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00000001'
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00001000'
	MOVWF	ADCON0
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;-------------------------------------------------------------------------------
;Para a comunica��o serial, ser� utilizado a GP0 para comunica��o serial e o
;GP2 como entrada de tens�o.
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;O programa principal inicia em modo de economia de energia e posteriomente 
;entra em modo sleep at� que receba um sinal do mestre. Esse sinal ser� recebido
;atraves do GP0 e a sa�da do sleep � por meio de uma interrup��o por troca de 
;porta. O barramento de comunica��o inicia em HIGH (GP0). 
;OBS.: QUANDO FOR EXECUTAR A SEGUNDA VEZ O PROGRAMA, APLICAR UM ESTIMULO NO GP0
;DIFERENTE DO PRIMEIRO ESTIMULO, UMA VEZ QUE A SA�DA DO SLEEP � POR MUDAN�A DO
;ESTADO DA PORTA. QUANDO TESTEI, INICIEI DANDO UM ESTIMULO SET HIGH E NA SEGUNDA
;VEZ APLIQUEI O ESTIMULO SET LOW.
;-------------------------------------------------------------------------------
MAIN
	CALL	MODO_ECONOMIA	;CHAMA O MODO DE ECONOMIA DE ENERGIA	
	SLEEP			;ENTRA EM MODO SLEEP
	NOP
	
;-------------------------------------------------------------------------------
;Ap�s o sinal do mestre, a comunica��o serial come�a com o nivel l�gico do 
;barramento (GP0) indo de HIGH para LOW por 18ms para garantir a detec��o do 
;sinal. Depois disso, volta para HIGH e espera 20-40us pela resposta do modulo
;escravo. Ap�s isso, o barramento � trocado de INPUT para OUTPUT
;para enviar os bits dos dados.
;-------------------------------------------------------------------------------
	
INICIANDO
	BCF	GPIO, GP0	;ASSIM QUE DETECTA HIGH PARA LOW
	CALL	DELAY_MS	;DELAY DE 18MS	
	
M_ESCRAVO			
	CALL	MODO_EXECUCAO	;VOLTA PARA O MODE DE EXECUC��O
	BSF	GPIO, GP0	;VOLTA PARA HIGH E ESPERA A CONVERS�O ACABAR
	BSF	ADCON0, 1	;INICIA A CONVERS�O
LOOP
	BTFSC	ADCON0, 1
	GOTO	LOOP
	
;-------------------------------------------------------------------------------
;Quando o modulo escravo detecta o sinal de partida, envia um sinal de resposta
;LOW de 80us no barramento e, depois, um sinal em HIGH de 80us e prepara a
;transmiss�o dos dados. 
;-------------------------------------------------------------------------------

CONFIG_ENVIO
	BCF	GPIO, GP0	;SINAL DE RESPOSTA EM LOW
	MOVLW	.218		;CONFIGURA PARA DURAR 80US
	MOVWF	TMR0
	CALL	DELAY_US	;INICIA O DELAY
	BSF	GPIO, GP0	;SINAL EM HIGH (PREPARA PARA TRANSMISS�O)
	MOVLW	.218		;CONFIGURA PARA DURAR 80US  
	MOVWF	TMR0
	CALL	DELAY_US	;INICIA O DELAY
	
	
;-------------------------------------------------------------------------------
;O processo de envio da informa��o vai acontecer bit a bit, iniciando do bit 
;mais significativo. Caso o bit a ser enviado seja igual a 0, o barramento vai
;ficar 50us em LOW e 26us em HIGH. Quando 1, o barramento fica 50us em LOW e 
;70us em HIGH. Quando acabar o envio de todos os bits, o barramento volta para
;LOW por 50us e o processo de transmiss�oa � finalizado.
;-------------------------------------------------------------------------------
	
ENVIA_DADOS
	BTFSS	ADRESH, 7	    ;TESTA SE O BIT NA POSI��O 7 � ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 7	    ;TESTA SE O BIT � 1 (REPETE PARA TODOS)
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 6	    ;TESTA SE O BIT NA POSI��O 6 � ZERO
	CALL	ENVIA_0	
	BTFSC	ADRESH, 6	   
	CALL	ENVIA_1	
	
	BTFSS	ADRESH, 5	    ;TESTA SE O BIT NA POSI��O 5 � ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 5	   
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 4	    ;TESTA SE O BIT NA POSI��O 4 � ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 4	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 3	    ;TESTA SE O BIT NA POSI��O 3 � ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 3	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 2	    ;TESTA SE O BIT NA POSI��O 2 � ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 2	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 1	    ;TESTA SE O BIT NA POSI��O 1 � ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 1	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 0	    ;TESTA SE O BIT NA POSI��O 0 � ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 0
	CALL	ENVIA_1
			
	
ACABOU
	BCF	GPIO, GP0	;VOLTA O GP0 PARA LOW
	MOVLW	.233		;DEFINE UM TEMPO DE 50US
	MOVWF	TMR0	
	CALL	DELAY_US	;CHAMA O DELAY
	BSF	GPIO, GP0	;PUXA PARA HIGH NOVAMENTE
	
	
REINICIANDO
	GOTO	INICIO		;REINICIA O PROCESSO



;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
