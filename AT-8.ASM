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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		TENSAO		;Guarda o valor da tensão que vem do ADRESH

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

DESABILITA
	BANK0
	MOVLW   B'00000000'	;Conversor desativado
	MOVWF	ADCON0
	MOVLW	B'00000111'	;Comparador em modo off
	MOVWF	CMCON	
	BANK1
	MOVLW	B'00000000'	;Desabilita o GP0 como entrada
	MOVWF	TRISIO	
	MOVLW	B'00000000'	;Desabilita a entrada analogica
	MOVWF	ANSEL 
	RETURN
	
HABILITA 
	BANK1
	MOVLW	B'00000001'	;Habilita o GP0 como entrada
	MOVWF	TRISIO	
	MOVLW	B'00000001'	;Ativa a entrada analogica
	MOVWF	ANSEL 
	BANK0
	MOVLW   B'00000001'	;Conversor ativado
	MOVWF	ADCON0
	MOVLW	B'00000000'
	MOVWF	ADRESH
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000001'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00000001'
	MOVWF	ANSEL 
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW   B'00000001'
	MOVWF	ADCON0
	MOVLW	B'00000000'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;-------------------------------------------------------------------------------
;Para essa atividade optou-se por utilizar um conversor analogico-digital.
;O valor recebido no GP0 é transformado para um valor digital e, posteriomente,
;comparado para acionamento dos GPIO's
;-------------------------------------------------------------------------------
	
;-------------------------------------------------------------------------------
;O microcontrolador irá permanecer "adormecido" até que o WDT o "acorde" a cada 
;2 segundos. Para isso, utilizou-se um prescaler de 1:128 já que O período de 
;tempo limite nominal é de 18 ms, resultando num tempo de aprox. de 2,2s.
;-------------------------------------------------------------------------------
	
MAIN
	CALL	DESABILITA  ;Chama a função de desabilitar 
		
ADORMECE
	SLEEP		    ;Aciona o modo adormecido
	NOP
	
CONFIG_1
	CALL	HABILITA    ;Chama a função de habilitar
	NOP
	NOP 
	BSF	ADCON0, 1   ;Inicia a conversão analogica-digital
	
ENTRADA
	BTFSC	ADCON0, 1   ;Testa se a conversão acabou
	GOTO	ENTRADA	    ;Não? Volta pra ENTRADA
	
;-------------------------------------------------------------------------------	
;Optou-se por utilizar o formato do resultado do ADC justificado a esquerda, 
;trabalhando apenas com o ADRESH e ignorando os dois bits menos significativos 
;do ADRESL.
;-------------------------------------------------------------------------------	
CONFIG_2
	MOVFW	ADRESH	    
	MOVWF	TENSAO	    ;Move o valor do ADRESH para TENSÃO
	
	
;-------------------------------------------------------------------------------
;COMPARA AS TENSÕES DE ENTRADA. 
;Menor que 2 = GP1 LIGADO
;MAIOR-IGUAL A 2 E MENOR QUE 3 = GP2 LIGADO
;MAIOR-IGUAL A 3 E MENOR QUE 4 = GP4 LIGADO
;MAIOR-IGUAL A 4 = GP5 LIGADO
;-------------------------------------------------------------------------------
	
	
MENOR_2
	MOVLW	.102		;Compara tensão maior ou menor que 2V (102)?
	SUBWF	TENSAO, W	;Subtrai o 102 do valor de entrada
	BTFSC	STATUS, C	;Testa se o valor é menor ou maior que 2v 
	GOTO	MAIOR_2_MENOR_3 ;É maior? Teste se é maior que 2 e menor que 3
	BSF	GPIO, GP1	;Liga o GP1
	BCF	GPIO, GP2	;Desliga os GP2, GP4 e GP5
	BCF	GPIO, GP4
	BCF	GPIO, GP5
	GOTO	FIM
	
MAIOR_2_MENOR_3
	MOVLW	.153		;Compara tensão maior ou menor que 3V (153)?
	SUBWF	TENSAO, W	;Subtrai o 153 do valor de entrada
	BTFSC	STATUS, C	;Testa se o valor é menor ou maior que 3v 
	GOTO	MAIOR_3_MENOR_4	;É maior? Teste se é maior que 3 e menor que 4
	BSF	GPIO, GP2	;Liga o GP2
	BCF	GPIO, GP1	;Desliga os GP1, GP4 e GP5
	BCF	GPIO, GP4
	BCF	GPIO, GP5
	
	GOTO	FIM
	
MAIOR_3_MENOR_4
	MOVLW	.204		;Compara tensão maior ou menor que 4V (204)?
	SUBWF	TENSAO, W	;Subtrai o 204 do valor de entrada
	BTFSC	STATUS, C	;Testa se o valor é menor ou maior que 4v
	GOTO	MAIOR_4		;É maior? Teste se é maior que 4
	BSF	GPIO, GP4	;Liga o GP4
	BCF	GPIO, GP1	;Desliga os GP1, GP2 e GP5
	BCF	GPIO, GP2
	BCF	GPIO, GP5
	GOTO	FIM
		
MAIOR_4	
	BSF	GPIO, GP5	;Liga o GP5
	BCF	GPIO, GP1	;Desliga os GP1, GP2 e GP4
	BCF	GPIO, GP2
	BCF	GPIO, GP4
	GOTO	FIM
	
	
LIMPA
	MOVLW	B'00000000'	;Limpa todos os GPIO's
	MOVWF	GPIO
FIM
	GOTO MAIN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
