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
		STATUS_TEMP
		TEMP_C
		CICLOS
		TEMP_D1
		TEMP_D2
		TEMP_D3
		TEMP_D4
		TEMP_D5
		
		;JUNTO ÀS INTERRUPÇÕES

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
;Quando ocorrer o OverFlow do TMR0, será acionado GPIO baseado na especificação
;do projeto. Utiliza-se o mesmo comparador de frequências para determinar
;o tratamento adequado.
;-------------------------------------------------------------------------------

SWITCH_2
	MOVLW .8
	SUBWF TEMP_C, W
	BTFSC STATUS, Z
	GOTO I_30
	MOVLW .12
	SUBWF TEMP_C, W
	BTFSC STATUS, Z 
	GOTO I_20
	MOVLW .25
	SUBWF TEMP_C, W
	BTFSC STATUS, Z
	GOTO I_10
	MOVLW .50
	SUBWF TEMP_C, W
	BTFSC STATUS, Z 
	GOTO I_5
	
I_30 
	BSF GPIO, GP5
	NOP
	BCF GPIO, GP5
    	GOTO RETORNO
I_20
	BSF GPIO, GP4
	NOP
	BCF GPIO, GP4
	GOTO RETORNO
I_10
	BSF GPIO, GP1
	NOP
	BCF GPIO, GP1
	GOTO RETORNO
I_5
	BSF GPIO, GP0
	NOP
	BCF GPIO, GP0
	GOTO RETORNO
	
RETORNO
	BCF INTCON, T0IF ;Limpa a flag de estouro
	

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
	MOVLW	B'00000100'     ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000001'	;PRESCALER 1:4
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
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
;A rotina do programa é iniciada com a entrada de quatro frequências diferentes
;que entrarão em sequência (5kHz, 10kHz, 20kHz e 30kHz). O programa irá ler 
;essas frequências e, se estiverem na lista de frequências de precisam ser 
;verificadas, serão direcionadas para que ocorra um estouro no TMR0 para que
;ocorra o tratamento da interrupção.
;-------------------------------------------------------------------------------

MAIN
	BCF INTCON, T0IF ;Limpa a flag de interrupção
	
ENTRADA_1
	 BCF GPIO, GP2   ;Limpa o GP2
	 CLRF TMR0       ;Limpa o TMR0
	 CALL CONFIG_DELAY_5 ;Chama o delay para frequência de 5k
ENTRADA_2
	BCF GPIO, GP2     ;Limpa o GP2
	CLRF TMR0         ;Limpa o TMR0
	CALL CONFIG_DELAY_10  ;Chama o delay para frequência de 10k
ENTRADA_3
	BCF GPIO, GP2 ;Limpa o GP2
	CLRF TMR0     ;Limpa o TMR0
	CALL CONFIG_DELAY_20  ;Chama o delay para frequência de 20k
ENTRADA_4
	BCF GPIO, GP2 ;Limpa o GP2
	CLRF TMR0     ;Limpa o TMR0
	CALL CONFIG_DELAY_30 ;Chama o delay para frequência de 30k
	
;-------------------------------------------------------------------------------
;ROTINA DE DELAY: Os delay foram criados para a onda quadrada permanecer por
;um determinado período em nível lógico alto e depois baixo. Isso serve para
;determinamos uma entrada com frequência especifica. Para encontrar a relação
;entre frequência, ciclo de maquina e período definiu-se os sequintes cálculos:
;
;Ciclo de maquina = 1/(CLK/4) = 1/(4MHz/4) = 1us cada ciclo
;Para achar o período X que equivale um frequência Y. Usou-se um prescaler 1:4
;Y = 1/(1us*prescaler*X), no qual deve-se isolar X para achar o valor.
;
;Frequência: 5kHz = 1/(1us*4*X) -> X = 50us (200 ciclos de máquina)
;	     10kHz = 1/(1us*4*X) -> X = 25us (100 ciclos de máquina)
;	     20kHz = 1/(1us*4*X) -> X = 12.5us (48 ciclos de máquina)
;	     30kHz = 1/(1us*4*X) -> X = 8.3us (32 ciclos de máquina)
;
;O arredondamento dos valores equivale a um erro de aproximadamente 4,17%
;Os ciclos internados serão esses valores acima vezes quatro (prescaler) e essa
;é a base para o cálculo abaixo.
;-------------------------------------------------------------------------------
	
CONFIG_DELAY_30
	MOVLW .3
	MOVWF TEMP_D1 ;UP
DELAY_30			    ;TMR0 = 8us (32 ciclos de máquina)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ TEMP_D1
	GOTO DELAY_30  
	NOP
	NOP
	GOTO INCREMENTO 
	
CONFIG_DELAY_20
	MOVLW .9
	MOVWF TEMP_D2	
DELAY_20                               ;TMR0 = 12us (48 ciclos de máquina)
	NOP
	NOP
	DECFSZ TEMP_D2
	GOTO DELAY_20 
	NOP
	NOP
	NOP
	GOTO INCREMENTO
	
CONFIG_DELAY_10
	MOVLW .10
	MOVWF TEMP_D3
	
DELAY_10			;TMR0 = 25us (100 ciclos de máquina)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ TEMP_D3
	GOTO DELAY_10 
	GOTO INCREMENTO
	
CONFIG_DELAY_5
	MOVLW .20
	MOVWF TEMP_D4 
DELAY_5			    ;TMR0 = 50us (200 ciclos de máquina)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ TEMP_D4
	GOTO DELAY_5 
	GOTO INCREMENTO 

;-------------------------------------------------------------------------------
;ROTINA PRINCIPAL: Após ocorrer os delays, é preciso identificar que frequência
;foi recebida e depois direcionar para que ocorra um estouro do TIMER0
;-------------------------------------------------------------------------------
	
INCREMENTO
	MOVF TMR0, W  
	MOVWF TEMP_C ;COPIA PARA TEMP_C PARA NÃO PERDER O VALOR CORRETO DE TMR0
	
;COMPARA QUANTOS CICLOS DE MÁQUINA OCORREU PARA IDENTIFICAR A FREQUÊNCIA
SWITCH
	MOVLW .8        ;Periodo referente a 30kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z
	GOTO F_30       ;A FREQUÊNCIA É DE 30kHZ
	MOVLW .12       ;Periodo referente a 20kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z 
	GOTO F_20       ;A FREQUÊNCIA É DE 20kHZ
	MOVLW .25       ;Periodo referente a 10kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z
	GOTO F_10       ;A FREQUÊNCIA É DE 10kHZ
	MOVLW .50       ;Periodo referente a 5kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z 
	GOTO F_5        ;A FREQUÊNCIA É DE 5kHZ
	
;-------------------------------------------------------------------------------
;ROTINA PARA ESTOURO DO TMR0: É iniciado o TMR0 com um valor (255 - período) 
;para gerar um estouro imediato.
;-------------------------------------------------------------------------------
	
F_5
	MOVLW .205
	MOVWF TMR0
	MOVF TEMP_C, W
	ADDWF TMR0
	BCF INTCON, T0IF ;Limpa a flag de estouro
	
LOOP_5
	BTFSS INTCON, T0IF  ;Testa se ocorreu o estouro e vai para tratamento
	GOTO LOOP_5
	GOTO ENTRADA_2 ;Direciona para a próxima entrada

F_10
	MOVLW .230
	MOVWF TMR0
	MOVF TEMP_C, W
	ADDWF TMR0
	BCF INTCON, T0IF ;Limpa a flag de estouro
	
LOOP_10
	BTFSS INTCON, T0IF  ;Testa se ocorreu o estouro e vai para tratamento
	GOTO LOOP_10
	GOTO ENTRADA_3 ;Direciona para a próxima entrada
	
F_20
	MOVLW .243
	MOVWF TMR0
	MOVF TEMP_C, W
	ADDWF TMR0
	BCF INTCON, T0IF ;Limpa a flag de estouro
	
LOOP_20
	BTFSS INTCON, T0IF  ;Testa se ocorreu o estouro e vai para tratamento
	GOTO LOOP_20
	GOTO ENTRADA_4 ;Direciona para a próxima entrada
	
F_30
	MOVLW .247
	MOVWF TMR0
	MOVF TEMP_C, W
	ADDWF TMR0
	BCF INTCON, T0IF  ;Limpa a flag de estouro
	
LOOP_30
	BTFSS INTCON, T0IF  ;Testa se ocorreu o estouro e vai para tratamento
	GOTO LOOP_30
	
FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
