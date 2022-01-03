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
		TEMPO
		AUX
		DADO

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
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES
	
	BSF	GPIO, GP0	;ACIONA O GP0
	MOVLW	.35
	MOVWF	TEMPO
	BCF	INTCON, GPIF
	BCF	INTCON, GPIE
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
	
;FUNÇÃO GENERICA PARA FUNCIONAMENTO DE DELAY CURTO 
	
DELAY_US		      
	BCF INTCON, T0IF	;ZERA A FLAG DE ESTOURO
	
LOOP_1
	BTFSS INTCON, T0IF	;TESTA SE O TMR0 ESTOUROU
	GOTO LOOP_1		;NÃO, CONTINUA NO LOOP
	RETURN			;SIM, RETORNA
	
;FUNÇÃO GENERICA PARA FUNCIONAMENTO DE DELAY LONGOS

DELAY_MS		      
	CLRF TMR0		;LIMPA O TMR0	
	BCF INTCON, T0IF	;ZERA A FLAG DE ESTOURO
	
LOOP_2
	BTFSS INTCON, T0IF	;TESTA SE O TMR0 ESTOUROU
	GOTO LOOP_2		;NÃO, CONTINUA NO LOOP
	BCF INTCON, T0IF	;SIM, LIMPA A FLAG DE ESTOURO
	DECFSZ TEMPO		;DECREMENTA O TEMPO DE VEZES QUE VAI ESTOURAR
	GOTO LOOP_2		;VOLTA A CONTAR ATÉ 255
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
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00010100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000000'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10001000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00000001'
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00001000'
	MOVWF	ADCON0
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;-------------------------------------------------------------------------------
;Para a comunicação serial, será utilizado a GP0 para comunicação serial e o
;GP2 como entrada de tensão.
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;O programa principal inicia em modo de economia de energia e posteriomente 
;entra em modo sleep até que receba um sinal do mestre. Esse sinal será recebido
;atraves do GP0 e a saída do sleep é por meio de uma interrupção por troca de 
;porta. O barramento de comunicação inicia em HIGH (GP0). 
;OBS.: QUANDO FOR EXECUTAR A SEGUNDA VEZ O PROGRAMA, APLICAR UM ESTIMULO NO GP0
;DIFERENTE DO PRIMEIRO ESTIMULO, UMA VEZ QUE A SAÍDA DO SLEEP É POR MUDANÇA DO
;ESTADO DA PORTA. QUANDO TESTEI, INICIEI DANDO UM ESTIMULO SET HIGH E NA SEGUNDA
;VEZ APLIQUEI O ESTIMULO SET LOW.
;-------------------------------------------------------------------------------
MAIN
	CALL	MODO_ECONOMIA	;CHAMA O MODO DE ECONOMIA DE ENERGIA	
	SLEEP			;ENTRA EM MODO SLEEP
	NOP
	
;-------------------------------------------------------------------------------
;Após o sinal do mestre, a comunicação serial começa com o nivel lógico do 
;barramento (GP0) indo de HIGH para LOW por 18ms para garantir a detecção do 
;sinal. Depois disso, volta para HIGH e espera 20-40us pela resposta do modulo
;escravo. Após isso, o barramento é trocado de INPUT para OUTPUT
;para enviar os bits dos dados.
;-------------------------------------------------------------------------------
	
INICIANDO
	BCF	GPIO, GP0	;ASSIM QUE DETECTA HIGH PARA LOW
	CALL	DELAY_MS	;DELAY DE 18MS	
	
M_ESCRAVO			
	CALL	MODO_EXECUCAO	;VOLTA PARA O MODE DE EXECUCÇÃO
	BSF	GPIO, GP0	;VOLTA PARA HIGH E ESPERA A CONVERSÃO ACABAR
	BSF	ADCON0, 1	;INICIA A CONVERSÃO
LOOP
	BTFSC	ADCON0, 1
	GOTO	LOOP
	
;-------------------------------------------------------------------------------
;Quando o modulo escravo detecta o sinal de partida, envia um sinal de resposta
;LOW de 80us no barramento e, depois, um sinal em HIGH de 80us e prepara a
;transmissão dos dados. 
;-------------------------------------------------------------------------------

CONFIG_ENVIO
	BCF	GPIO, GP0	;SINAL DE RESPOSTA EM LOW
	MOVLW	.218		;CONFIGURA PARA DURAR 80US
	MOVWF	TMR0
	CALL	DELAY_US	;INICIA O DELAY
	BSF	GPIO, GP0	;SINAL EM HIGH (PREPARA PARA TRANSMISSÃO)
	MOVLW	.218		;CONFIGURA PARA DURAR 80US  
	MOVWF	TMR0
	CALL	DELAY_US	;INICIA O DELAY
	
	
;-------------------------------------------------------------------------------
;O processo de envio da informação vai acontecer bit a bit, iniciando do bit 
;mais significativo. Caso o bit a ser enviado seja igual a 0, o barramento vai
;ficar 50us em LOW e 26us em HIGH. Quando 1, o barramento fica 50us em LOW e 
;70us em HIGH. Quando acabar o envio de todos os bits, o barramento volta para
;LOW por 50us e o processo de transmissãoa é finalizado.
;-------------------------------------------------------------------------------
	
ENVIA_DADOS
	BTFSS	ADRESH, 7	    ;TESTA SE O BIT NA POSIÇÃO 7 É ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 7	    ;TESTA SE O BIT É 1 (REPETE PARA TODOS)
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 6	    ;TESTA SE O BIT NA POSIÇÃO 6 É ZERO
	CALL	ENVIA_0	
	BTFSC	ADRESH, 6	   
	CALL	ENVIA_1	
	
	BTFSS	ADRESH, 5	    ;TESTA SE O BIT NA POSIÇÃO 5 É ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 5	   
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 4	    ;TESTA SE O BIT NA POSIÇÃO 4 É ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 4	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 3	    ;TESTA SE O BIT NA POSIÇÃO 3 É ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 3	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 2	    ;TESTA SE O BIT NA POSIÇÃO 2 É ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 2	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 1	    ;TESTA SE O BIT NA POSIÇÃO 1 É ZERO
	CALL	ENVIA_0
	BTFSC	ADRESH, 1	    
	CALL	ENVIA_1
	
	BTFSS	ADRESH, 0	    ;TESTA SE O BIT NA POSIÇÃO 0 É ZERO
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
