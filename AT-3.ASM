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
		STATUS_TEMP
		TEMP_C
		CICLOS
		TEMP_D1
		TEMP_D2
		TEMP_D3
		TEMP_D4
		TEMP_D5
		
		;JUNTO �S INTERRUP��ES

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
;Quando ocorrer o OverFlow do TMR0, ser� acionado GPIO baseado na especifica��o
;do projeto. Utiliza-se o mesmo comparador de frequ�ncias para determinar
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
	MOVLW	B'00000100'     ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000001'	;PRESCALER 1:4
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
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
;A rotina do programa � iniciada com a entrada de quatro frequ�ncias diferentes
;que entrar�o em sequ�ncia (5kHz, 10kHz, 20kHz e 30kHz). O programa ir� ler 
;essas frequ�ncias e, se estiverem na lista de frequ�ncias de precisam ser 
;verificadas, ser�o direcionadas para que ocorra um estouro no TMR0 para que
;ocorra o tratamento da interrup��o.
;-------------------------------------------------------------------------------

MAIN
	BCF INTCON, T0IF ;Limpa a flag de interrup��o
	
ENTRADA_1
	 BCF GPIO, GP2   ;Limpa o GP2
	 CLRF TMR0       ;Limpa o TMR0
	 CALL CONFIG_DELAY_5 ;Chama o delay para frequ�ncia de 5k
ENTRADA_2
	BCF GPIO, GP2     ;Limpa o GP2
	CLRF TMR0         ;Limpa o TMR0
	CALL CONFIG_DELAY_10  ;Chama o delay para frequ�ncia de 10k
ENTRADA_3
	BCF GPIO, GP2 ;Limpa o GP2
	CLRF TMR0     ;Limpa o TMR0
	CALL CONFIG_DELAY_20  ;Chama o delay para frequ�ncia de 20k
ENTRADA_4
	BCF GPIO, GP2 ;Limpa o GP2
	CLRF TMR0     ;Limpa o TMR0
	CALL CONFIG_DELAY_30 ;Chama o delay para frequ�ncia de 30k
	
;-------------------------------------------------------------------------------
;ROTINA DE DELAY: Os delay foram criados para a onda quadrada permanecer por
;um determinado per�odo em n�vel l�gico alto e depois baixo. Isso serve para
;determinamos uma entrada com frequ�ncia especifica. Para encontrar a rela��o
;entre frequ�ncia, ciclo de maquina e per�odo definiu-se os sequintes c�lculos:
;
;Ciclo de maquina = 1/(CLK/4) = 1/(4MHz/4) = 1us cada ciclo
;Para achar o per�odo X que equivale um frequ�ncia Y. Usou-se um prescaler 1:4
;Y = 1/(1us*prescaler*X), no qual deve-se isolar X para achar o valor.
;
;Frequ�ncia: 5kHz = 1/(1us*4*X) -> X = 50us (200 ciclos de m�quina)
;	     10kHz = 1/(1us*4*X) -> X = 25us (100 ciclos de m�quina)
;	     20kHz = 1/(1us*4*X) -> X = 12.5us (48 ciclos de m�quina)
;	     30kHz = 1/(1us*4*X) -> X = 8.3us (32 ciclos de m�quina)
;
;O arredondamento dos valores equivale a um erro de aproximadamente 4,17%
;Os ciclos internados ser�o esses valores acima vezes quatro (prescaler) e essa
;� a base para o c�lculo abaixo.
;-------------------------------------------------------------------------------
	
CONFIG_DELAY_30
	MOVLW .3
	MOVWF TEMP_D1 ;UP
DELAY_30			    ;TMR0 = 8us (32 ciclos de m�quina)
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
DELAY_20                               ;TMR0 = 12us (48 ciclos de m�quina)
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
	
DELAY_10			;TMR0 = 25us (100 ciclos de m�quina)
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
DELAY_5			    ;TMR0 = 50us (200 ciclos de m�quina)
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
;ROTINA PRINCIPAL: Ap�s ocorrer os delays, � preciso identificar que frequ�ncia
;foi recebida e depois direcionar para que ocorra um estouro do TIMER0
;-------------------------------------------------------------------------------
	
INCREMENTO
	MOVF TMR0, W  
	MOVWF TEMP_C ;COPIA PARA TEMP_C PARA N�O PERDER O VALOR CORRETO DE TMR0
	
;COMPARA QUANTOS CICLOS DE M�QUINA OCORREU PARA IDENTIFICAR A FREQU�NCIA
SWITCH
	MOVLW .8        ;Periodo referente a 30kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z
	GOTO F_30       ;A FREQU�NCIA � DE 30kHZ
	MOVLW .12       ;Periodo referente a 20kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z 
	GOTO F_20       ;A FREQU�NCIA � DE 20kHZ
	MOVLW .25       ;Periodo referente a 10kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z
	GOTO F_10       ;A FREQU�NCIA � DE 10kHZ
	MOVLW .50       ;Periodo referente a 5kHz
	SUBWF TEMP_C, W
	BTFSC STATUS, Z 
	GOTO F_5        ;A FREQU�NCIA � DE 5kHZ
	
;-------------------------------------------------------------------------------
;ROTINA PARA ESTOURO DO TMR0: � iniciado o TMR0 com um valor (255 - per�odo) 
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
	GOTO ENTRADA_2 ;Direciona para a pr�xima entrada

F_10
	MOVLW .230
	MOVWF TMR0
	MOVF TEMP_C, W
	ADDWF TMR0
	BCF INTCON, T0IF ;Limpa a flag de estouro
	
LOOP_10
	BTFSS INTCON, T0IF  ;Testa se ocorreu o estouro e vai para tratamento
	GOTO LOOP_10
	GOTO ENTRADA_3 ;Direciona para a pr�xima entrada
	
F_20
	MOVLW .243
	MOVWF TMR0
	MOVF TEMP_C, W
	ADDWF TMR0
	BCF INTCON, T0IF ;Limpa a flag de estouro
	
LOOP_20
	BTFSS INTCON, T0IF  ;Testa se ocorreu o estouro e vai para tratamento
	GOTO LOOP_20
	GOTO ENTRADA_4 ;Direciona para a pr�xima entrada
	
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
