; *********************************************************************************
; * IST-UL
; * Modulo: 	grupo09.asm
; * Autores:	106322 Raquel Rodrigues, 106835 Beatriz Martinho, 107413 Natacha Sousa
; * Descrição: Jogo de simulação de uma viagem interplanetária de uma nave espacial
; *
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
COMANDOS			EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_DISPLAY		EQU COMANDOS + 04H		; endereço do comando para selecionar um ecrã
SELECIONA_CENARIO_FUNDO EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
APAGA_CENARIO_FRONTAL 	EQU COMANDOS + 44H		; endereço do comando para apagar o cenário frontal
SELECIONA_CENARIO_FRONTAL EQU COMANDOS + 46H	; endereço do comando para selecionar um cenário frontal
SELECIONA_VIDEO_FUNDO	EQU COMANDOS + 5CH		; endereço do comando para selecionar um som/vídeo em ciclo
TOCA_SOM				EQU COMANDOS + 5AH		; endereço do comando para tocar um som
TERMINA_VIDEOS			EQU COMANDOS + 68H		; endereço do comando para terminar a reprodução de todos os vídeos

ECRA_COMECO				EQU 0 ; vídeo 0
ECRA_PAUSA				EQU 1 ; imagem 1
ECRA_COLISAO			EQU 1 ; vídeo 1
ECRA_ACABOU_ENERGIA		EQU 2 ; vídeo 2
SOM_BEGIN				EQU 3 ; som 3 - inicio do Jogo
SOM_GAME_OVER			EQU 4 ; som 4 - fim do Jogo
SOM_DISPARO				EQU 5 ; som 5 - disparo de uma sonda
SOM_NAO_MINERAVEL		EQU 6 ; som 6 - explosão de um asteroide não minerável ou da nave
SOM_MINERAVEL			EQU 7 ; som 7 - explosão de um asteroide minerável
SOM_PAUSE				EQU 8 ; som 8 - suspender o jogo
SOM_UNPAUSE				EQU 9 ; som 9 - retomar o jogo
DISPLAYS   		EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    		EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    		EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA      		EQU 16      ; primeira linha a testar (4ª linha, 1000b)
LINHA_TECLADO 	EQU 8		; linha das teclas do começo, pausa e terminar jogo
MASCARA    		EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
MASCARA_MENOR	EQU 3		; para isolar os 2 bits de menor peso, 
							; ao gerar um asteroide minerável ou não
TECLA_ESQ		EQU 0		; tecla para lançar uma sonda para a esquerda
TECLA_FRENTE	EQU 1		; tecla para lançar uma sonda em frente
TECLA_DRT		EQU 2		; tecla para lançar uma sonda para a direita
TECLA_COMECO	EQU 0CH		; tecla para começar o jogo
TECLA_PAUSE		EQU 0DH  	; tecla para suspender/retomar o jogo
TECLA_FIM		EQU 0EH		; tecla para terminar o jogo

FATOR 				EQU 1000	; fator inicial para converter um número hexadecimal para
								; um decimal com 3 dígitos
DIVISOR_0			EQU 10		; valor auxiliar da rotina converte_hex_decimal
DIVISOR_1			EQU 5		; valor auxiliar da rotina coluna_direcao_asteroide
PERDA_ENERGIA 		EQU 3H		; valor retirado periodicamente à energia da nave
PERDA_ENERGIA_SONDA	EQU 5H		; valor retirado à energia da nave pelo lançamento de uma sonda
ENERGIA_ASTEROIDE	EQU 19H		; valor a adicionar à energia da nave (25 em decimal)
								; quando se atinge um asteroide minerável
ENERGIA_DEC			EQU 100H	; valor inicial da energia da nave em decimal
ENERGIA_HEX			EQU 64H		; valor inicial da energia da nave em hexadecimal


VERMELHO   	    EQU 0FF00H	; pixel vermelho
LARANJA	   	    EQU 0FF94H	; pixel laranja
LARANJA_ESCURO  EQU 0FD52H  ; pixel laranja escuro
AZUL_CLARO 		EQU 0F78AH  ; pixel azul claro
AZUL_ESCURO 	EQU 0F568H  ; pixel azul escuro
CINZA			EQU 0FCCCH  ; pixel cinza
CINZA_ESCURO	EQU 0F555H  ; pixel cinza escuro
PRETO			EQU 0F222H  ; pixel preto
AMARELO			EQU 0FFE0h	; pixel amarelo	
VERDE           EQU 0F5F0H  ; pixel verde
AZUL			EQU 0F00FH	; pixel azul

MAX_LINHA		EQU 31		; número da linha mais inferior que um objeto pode ocupar
MIN_COLUNA		EQU 0		; número da coluna mais à esquerda que um objeto pode ocupar
MAX_COLUNA		EQU 63      ; número da coluna mais à direita que um objeto pode ocupar
LINHA_NAVE		EQU 27		; linha de referência da nave
COLUNA_NAVE		EQU 25		; coluna de referência da nave
ULTIMA_COL_NAVE	EQU 39		; última coluna da nave
LINHA_PAINEL    EQU 29      ; linha de referência do painel
COLUNA_PAINEL   EQU 29   	; coluna de referência do painel
MAX_PAINEL		EQU 14		; valor máximo a somar ao endereço da tabela de painéis
LINHA_SONDA 	EQU 26		; linha de referência das sondas
COLUNA_SONDA_ESQ	EQU 26	; coluna de referência da sonda da esquerda
COLUNA_SONDA_CENTRO	EQU 32	; coluna de referência da sonda central
COLUNA_SONDA_DRT	EQU 38	; coluna de referência da sonda da direita
ALCANCE_SONDA	EQU 12		; alcance máximo da sonda
N_ASTEROIDES	EQU 4		; número de asteroides
N_SONDAS		EQU 3		; número de sondas
TAMANHO_PILHA	EQU 100H	; tamanho de cada pilha, em words

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H

; Reserva do espaço para as pilhas dos processos
	STACK TAMANHO_PILHA			; espaço reservado para a pilha do processo "programa principal"
	
SP_inicial_prog_principal:		; endereço com que o SP deste processo deve ser inicializado

	STACK TAMANHO_PILHA			; espaço reservado para a pilha do processo "controlo"
SP_inicial_controlo:	; endereço com que o SP deste processo deve ser inicializado

	STACK TAMANHO_PILHA			; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:	    ; endereço com que o SP deste processo deve ser inicializado

	STACK TAMANHO_PILHA			; espaço reservado para a pilha do processo "nave"
SP_inicial_nave:		; endereço com que o SP deste processo deve ser inicializado

	STACK TAMANHO_PILHA			; espaço reservado para a pilha do processo "energia"
SP_inicial_energia:		; endereço com que o SP deste processo deve ser inicializado

	STACK TAMANHO_PILHA*N_SONDAS		; espaço reservado para as pilhas de todos os processos "sonda"
SP_inicial_sonda:		; endereço com que o SP deste processo deve ser inicializado

	STACK TAMANHO_PILHA*N_ASTEROIDES	; espaço reservado para as pilhas de todos os processos "asteroide"
SP_inicial_asteroide:	; endereço com que o SP deste processo deve ser inicializado

; Tabela das rotinas de interrupção
tab:
	WORD rot_int_asteroides		; rotina de atendimento da interrupção 0
	WORD rot_int_sondas			; rotina de atendimento da interrupção 1
	WORD rot_int_energia		; rotina de atendimento da interrupção 2
	WORD rot_int_nave			; rotina de atendimento da interrupção 3

; MUDAR PARA LOCKS	
evento_int_asteroides:
	LOCK 0				; se 1, indica que a interrupção 0 ocorreu
evento_int_sondas:	
	LOCK 0				; se 1, indica que a interrupção 1 ocorreu
evento_int_energia:
	LOCK 0				; se 1, indica que a interrupção 2 ocorreu
evento_int_nave:
	LOCK 0				; se 1, indica que a interrupção 3 ocorreu
	
tecla_carregada:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou
		 
DEF_NAVE:							; tabela que defina a NAVE (largura, altura, pixels)
	WORD 15, 5
	WORD 0, 0, LARANJA_ESCURO, LARANJA_ESCURO, LARANJA_ESCURO, LARANJA_ESCURO,
	LARANJA_ESCURO, LARANJA_ESCURO, LARANJA_ESCURO, LARANJA_ESCURO, LARANJA_ESCURO,
	LARANJA_ESCURO, LARANJA_ESCURO, 0, 0
	WORD 0, LARANJA_ESCURO, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA,
	LARANJA, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA_ESCURO, 0
	WORD LARANJA_ESCURO, LARANJA, LARANJA, LARANJA, 0, 0, 0, 0, 0, 0, 0,
	LARANJA, LARANJA, LARANJA, LARANJA_ESCURO
	WORD LARANJA_ESCURO, LARANJA, LARANJA, LARANJA, 0, 0, 0, 0, 0, 0, 0,
	LARANJA, LARANJA, LARANJA, LARANJA_ESCURO
	WORD LARANJA_ESCURO, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA,
 	LARANJA, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA, LARANJA_ESCURO

DEF_PAINEL:
	WORD DEF_PAINEL1
	WORD DEF_PAINEL2
	WORD DEF_PAINEL3
	WORD DEF_PAINEL4
	WORD DEF_PAINEL5
	WORD DEF_PAINEL6
	WORD DEF_PAINEL7
	WORD DEF_PAINEL8
	
DEF_PAINEL1:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD AZUL, VERMELHO, VERDE, AMARELO, VERDE, VERMELHO, AMARELO
	WORD VERDE, AMARELO, VERMELHO, VERDE, AMARELO, AZUL, VERMELHO

DEF_PAINEL2:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD AZUL, CINZA, VERDE, CINZA, CINZA, VERMELHO, AMARELO
	WORD CINZA, AMARELO, CINZA, VERDE, CINZA, CINZA, VERMELHO

DEF_PAINEL3:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD CINZA, VERMELHO, VERDE, AMARELO, CINZA, VERMELHO, CINZA
	WORD VERDE, AMARELO, VERMELHO, VERDE, AMARELO, AZUL, VERMELHO

DEF_PAINEL4:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD CINZA, CINZA, CINZA, AMARELO, VERDE, VERMELHO, CINZA
	WORD CINZA, AMARELO, CINZA, CINZA, AMARELO, CINZA, VERMELHO

DEF_PAINEL5:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD AZUL, VERMELHO, CINZA, CINZA, CINZA, CINZA, AMARELO
	WORD VERDE, CINZA, VERMELHO, CINZA, CINZA, AZUL, CINZA

DEF_PAINEL6:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD AZUL, CINZA, CINZA, AMARELO, CINZA, CINZA, AMARELO
	WORD CINZA, CINZA, CINZA, CINZA, CINZA, AMARELO, CINZA

DEF_PAINEL7:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD CINZA, VERMELHO, VERDE, CINZA, VERDE, CINZA, CINZA
	WORD VERDE, CINZA, VERMELHO, VERDE, AMARELO, AZUL, CINZA

DEF_PAINEL8:			;tabela que define um dos PAINEIS DE INSTRUMENTOS  (largura, altura, pixels)
	WORD 7, 2
	WORD CINZA, CINZA, VERDE, AMARELO, VERDE, CINZA, CINZA
	WORD CINZA, CINZA, CINZA, VERDE, CINZA, CINZA, CINZA

DEF_ASTEROIDE_MIN:			; tabela que define o ASTEROIDE MINERAVEL (largura, altura, pixels)
	WORD 5, 5
	WORD 0, AZUL_ESCURO, AZUL_CLARO, AZUL_CLARO, 0
	WORD AZUL_CLARO, AZUL_CLARO, AZUL, AZUL_ESCURO, AZUL_CLARO
	WORD AZUL, AZUL_ESCURO, AZUL_CLARO, AZUL_ESCURO, AZUL_CLARO
	WORD AZUL_ESCURO, AZUL_CLARO, AZUL_CLARO, AZUL, AZUL_CLARO
	WORD 0, AZUL_CLARO, AZUL_ESCURO, AZUL_CLARO, 0

DEF_ASTEROIDE:			; tabela que define o ASTEROIDE NAO MINERAVEL (largura, altura, pixels)
	WORD 5, 5
	WORD 0, CINZA_ESCURO, CINZA_ESCURO, 0, 0
	WORD CINZA_ESCURO, PRETO, CINZA_ESCURO, CINZA_ESCURO, CINZA_ESCURO
	WORD CINZA_ESCURO, CINZA_ESCURO, CINZA_ESCURO, PRETO, CINZA_ESCURO
	WORD CINZA_ESCURO, PRETO, CINZA_ESCURO, CINZA_ESCURO, CINZA_ESCURO
	WORD 0, 0, PRETO, CINZA_ESCURO, 0

DEF_HIT_AST:		; tabela que defina o ASTEROIDE NAO MINERAVEL quando explode  (largura, altura, pixels)
	WORD 5, 5
	WORD 0, CINZA_ESCURO, 0, CINZA_ESCURO, 0
	WORD CINZA_ESCURO, 0, CINZA_ESCURO, 0, CINZA_ESCURO
	WORD 0, CINZA_ESCURO, 0, CINZA_ESCURO, 0
	WORD CINZA_ESCURO, 0, CINZA_ESCURO, 0, CINZA_ESCURO
	WORD 0, CINZA_ESCURO, 0, CINZA_ESCURO, 0

DEF_HIT_ASTM_1:	  ; tabela que defina o ASTEROIDE MINERAVEL quando explode 1 (largura, altura, pixels)
	WORD 5, 5
	WORD 0, 0, 0, 0, 0
	WORD 0, AZUL_CLARO, AZUL_CLARO, AZUL, 0
	WORD 0, AZUL, AZUL_CLARO, AZUL_CLARO, 0
	WORD 0, AZUL_CLARO, AZUL_CLARO, AZUL_CLARO, 0
	WORD 0, 0, 0, 0, 0

DEF_HIT_ASTM_2:    ; tabela que defina o ASTEROIDE MINERAVEL quando explode 2 (largura, altura, pixels)
	WORD 5, 5
	WORD 0, 0, 0, 0, 0
	WORD 0, 0, 0, 0, 0
	WORD 0, 0, AZUL, 0, 0
	WORD 0, 0, 0, 0, 0
	WORD 0, 0, 0, 0, 0

; tabela das quatro instâncias de asteroides
tab_asteroides:			
	WORD asteroide_0
	WORD asteroide_1
	WORD asteroide_2
	WORD asteroide_3

asteroide_0:
	WORD 0				; tipo de asteroide: 1 se for minerável, 0 senão
	WORD 0				; linha atual do asteroide 0
	WORD 0				; coluna atual do asteroide 0
	
asteroide_1:
	WORD 0				; tipo de asteroide: 1 se for minerável, 0 senão
	WORD 0				; linha atual do asteroide 1
	WORD 0				; coluna atual do asteroide 1
	
asteroide_2:
	WORD 0				; tipo de asteroide: 1 se for minerável, 0 senão
	WORD 0				; linha atual do asteroide 2
	WORD 0				; coluna atual do asteroide 2
	
asteroide_3:
	WORD 0				; tipo de asteroide: 1 se for minerável, 0 senão
	WORD 0				; linha atual do asteroide 3
	WORD 0				; coluna atual do asteroide 3
	
coluna_direcao:		; tabela com as combinações coluna-direção possíveis de asteroides
	WORD 0, +1		; canto superior esquerdo a descer para a direita
	WORD 30, -1		; centro a descer para a esquerda
	WORD 30, 0		; centro a descer verticalmente
	WORD 30, +1		; centro a descer para a direita
	WORD 59, -1		; canto superior direito a descer para a esquerda

colisoes_asteroides:		; flags de colisão dos asteroides com uma sonda
	WORD COLISAO_AST_0
	WORD COLISAO_AST_1
	WORD COLISAO_AST_2
	WORD COLISAO_AST_3

reinicia_asteroides:		; flags que indicam o restart dos asteroides
	WORD RESTART_AST_0
	WORD RESTART_AST_1
	WORD RESTART_AST_2
	WORD RESTART_AST_3
	
tab_sondas:					; tabela das três instâncias de sondas
	WORD sonda_0
	WORD sonda_1
	WORD sonda_2

colisoes_sondas:			; flags de colisão das sondas com um asteroide
	WORD COLISAO_SONDA_0
	WORD COLISAO_SONDA_1
	WORD COLISAO_SONDA_2

reinicia_sondas:			; flags que indicam o restart das sondas
	WORD RESTART_SONDA_0
	WORD RESTART_SONDA_1
	WORD RESTART_SONDA_2

sonda_0:
	WORD 0				; linha atual da sonda 0
	WORD 0				; coluna atual da sonda 0

sonda_1:
	WORD 0				; linha atual da sonda 1
	WORD 0				; coluna atual da sonda 1

sonda_2:
	WORD 0				; linha atual da sonda 2
	WORD 0				; coluna atual da sonda 2

; tabela com flags que indicam se a sonda respetiva está ativa
; (se estiver ativa fica a 1)
sondas_ativas:
	WORD 0				; sonda da esquerda
	WORD 0				; sonda central
	WORD 0				; sonda da direita

ENERGIA_NAVE:		WORD 100H	; energia inicial da nave
COLISAO_AST_0:		WORD 0		; flag de colisão entre uma sonda e o asteroide 0
COLISAO_AST_1:		WORD 0		; flag de colisão entre uma sonda e o asteroide 1
COLISAO_AST_2:		WORD 0		; flag de colisão entre uma sonda e o asteroide 2
COLISAO_AST_3:		WORD 0		; flag de colisão entre uma sonda e o asteroide 3
COLISAO_SONDA_0:	WORD 0		; flag de colisão entre um asteroide e a sonda 0
COLISAO_SONDA_1:	WORD 0		; flag de colisão entre um asteroide e a sonda 1
COLISAO_SONDA_2:	WORD 0		; flag de colisão entre um asteroide e a sonda 2
RESTART_AST_0: 		WORD 0 		; flag de restart do asteroide 0
RESTART_AST_1: 		WORD 0 		; flag de restart do asteroide 1
RESTART_AST_2: 		WORD 0 		; flag de restart do asteroide 2
RESTART_AST_3: 		WORD 0 		; flag de restart do asteroide 3
RESTART_SONDA_0:	WORD 0		; flag de restart da sonda 0
RESTART_SONDA_1:	WORD 0		; flag de restart da sonda 1
RESTART_SONDA_2:	WORD 0		; flag de restart da sonda 2

START:				WORD 1		; flag que indica se o jogo está em start
GAME_OVER:			LOCK 0		; flag que indica se o jogo terminou ou se está em pause
		 
; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0			; endereço do início do código
	
	
inicio:		
; inicializações
	MOV SP, SP_inicial_prog_principal 	; inicializa SP
	MOV BTE, tab						; inicializa BTE
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados
	
	EI0						; permite interrupções 0
	EI1						; permite interrupções 1
	EI2						; permite interrupções 2
	EI3						; permite interrupções 3
	EI						; permite interrupções (geral)
	
; corpo principal do programa
	
	CALL controlo
	CALL espera_tecla
	CALL energia
	CALL nave
	
	MOV	R11, N_ASTEROIDES		; número de asteroides a usar
	MOV R10, N_SONDAS			; número de sondas a usar
ciclo_asteroides:
	SUB	R11, 1					; próximo asteroide
	CALL asteroide				; cria uma nova instância do processo "asteroide"
	CMP R11, 0					; já criou as instâncias todas?
    JNZ	ciclo_asteroides		; se não, continua
ciclo_sondas:
	SUB	R10, 1					; próxima sonda
	CALL sonda					; cria uma nova instância do processo "sonda"
	CMP R10, 0					; já criou as instâncias todas?
    JNZ	ciclo_sondas			; se não, continua
ciclo_principal:
	YIELD
	JMP ciclo_principal

; **********************************************************************
; Processo
;
; CONTROLO - Processo que trata das teclas de começar, suspender/continuar
; e terminar jogo, e controla o estado do jogo.
;
; **********************************************************************
PROCESS SP_inicial_controlo	

controlo:
	MOV R1, [START]		; para sabermos se estamos no ecrã que inicia o jogo.
	CMP R1, 2			; verifica se o jogo está em restart depois de ter acabado
						; a energia da nave ou ter havido colisão com a nave
	JZ reinicializa_displays
	CMP R1, 1			; verifica se estamos no ecrã inicial 
	JNZ decorrer_jogo	; se não, salta para o ciclo do jogo 
start:								; ecrã que inicia o jogo
	MOV R1, 0						; como a constante START começou em 1 deve ser alterada para 0
	MOV [START], R1					; altera a variável para não voltar ao ciclo
	MOV  [APAGA_AVISO], R1			; apaga o aviso de nenhum cenário selecionado
	MOV [APAGA_ECRÃ], R1			; apaga todos os pixels do ecrã
	MOV [APAGA_CENARIO_FRONTAL], R1	; apaga o ecrã de pausa
	MOV [TERMINA_VIDEOS], R1		; termina os vídeos em reprodução
	MOV R6, ECRA_COMECO				; chama o ecrã inicial
	MOV [SELECIONA_VIDEO_FUNDO], R6 ; seleciona o vídeo de fundo para o 1º ecrã
	MOV R1, LINHA_TECLADO			; linha do teclado que se quer testar
	MOV R7, TECLA_COMECO
espera_tecla_comeco:
	CALL teclado 				; faz a leitura das teclas da linha LINHA_TECLADO
	CMP R0, 0					; há tecla premida?
	JZ espera_tecla_comeco		; se não, repete o ciclo
	CALL encontra_tecla			; qual foi a tecla premida?
	CMP	R6, R7					; foi a tecla C?
	JZ reinicializa_displays	; se sim, então começa o jogo 
	JMP espera_tecla_comeco		; se não, repete o ciclo
reinicializa_displays:
	MOV R7, ENERGIA_DEC			; valor inicial da energia em decimal
	MOV [DISPLAYS], R7			; escreve contador de energia nos displays
	MOV R7, ENERGIA_HEX
	MOV [ENERGIA_NAVE], R7		; 100 em hexadecimal (para o PEPE-16 fazer as contas em hexadecimal)
	CALL toca_begin				; som de início de jogo
decorrer_jogo:
	MOV R1, 0						; como a constante START começou em 1 deve ser alterada para 0
	MOV [START], R1					; altera a variável para não voltar ao ciclo
	MOV [TERMINA_VIDEOS], R1			; termina os vídeos em reprodução
	CALL desenha_nave
	MOV R6, 0
	MOV [SELECIONA_CENARIO_FUNDO], R6	; seleciona a imagem principal do jogo
	MOV R8, [GAME_OVER]					; lê o LOCK 
	CMP R8, 0							; verifica se a variável foi alterada 
	JZ controlo							; se não, então o jogo continua
	CMP R8, 1							
	JZ esgotou_energia					; se está a 1, então acabou a energia
	CMP R8, 2
	JZ termina_colisao					; se está a 2, houve colisão com a nave
	CMP R8, 4
	JZ pausa							; se está a 4, então o jogo está em pausa
	CALL ativa_flags_restart			; se está a 3, o jogo foi terminado, ativam-se todas as flags
										; de restart para comunicar o fim do jogo aos processos 
	MOV R5, 1							
	MOV [START], R5						; START volta a ter o valor inicial	
	
	JMP controlo						; volta ao início do processo
pausa:
	CALL toca_pause 					; som de pause
	CALL rotina_pausa					; espera que o jogo seja retomado ou terminado
	CMP R1, 1							; verifica se o jogo foi retomado
	JZ decorrer_jogo					; se sim volta ao jogo
	CALL toca_game_over
	MOV R5, 1							; se não, o jogo foi terminado							
	MOV [START], R5						; START a 1 para o controlo saber que é para 
										; ficar no ecrã start								
	JMP controlo
termina_colisao:
	CALL toca_nao_mineravel				; toca o som da derrota por colisao com a nave
	MOV R8, 0							
	MOV [GAME_OVER], R8					; repôr variável a 0, para o jogo poder reiniciar
	MOV R1, LINHA_TECLADO				; linha do teclado que se quer testar
	MOV R2, TECLA_COMECO				; tecla de começo do jogo
	MOV [APAGA_ECRÃ], R8				; apaga tudo do ecrã 
	MOV R9, ECRA_COLISAO				
	MOV [SELECIONA_VIDEO_FUNDO], R9		; seleciona o cenário de colisão com a nave
	CALL ativa_flags_restart			; se está a 3, o jogo foi terminado, ativam-se todas as flags
										; de restart para comunicar o fim do jogo aos processos
	MOV R5, 2							
	MOV [START], R5						; START a 1 para o controlo saber que é para 
										; ficar no ecrã start
ciclo_termina_colisao:
	CALL teclado					; faz a leitura das teclas da linha LINHA_TECLADO
	CMP R0, 0						; houve tecla premida?
	JZ ciclo_termina_colisao		; lê o teclado até haver tecla
	CALL encontra_tecla				; qual foi a tecla premida?
	CMP	R6, R2						; foi a tecla C?
	JZ controlo						; se sim, volta ao inicio do processo
	JMP ciclo_termina_colisao		; se não, volta ao início do ciclo		
esgotou_energia:
	CALL toca_game_over					; toca o som da derrota
	MOV R8, 0							
	MOV [GAME_OVER], R8					; repôr variável a 0, para o jogo poder reiniciar
	MOV R1, LINHA_TECLADO				; linha do teclado que se quer testar
	MOV R2, TECLA_COMECO				; tecla de começo do jogo
	MOV [APAGA_ECRÃ], R8				; apaga o ecrã
	MOV R9, ECRA_ACABOU_ENERGIA
	MOV [SELECIONA_VIDEO_FUNDO], R9	; seleciona o cenário de esgotamento de energia
	CALL ativa_flags_restart			; se está a 3, o jogo foi terminado, ativam-se todas as flags
										; de restart para comunicar o fim do jogo aos processos
	MOV R5, 2							
	MOV [START], R5						; START a 1 para o controlo saber que é para 
										; ficar no ecrã start
ciclo_esgotou_energia:
	CALL teclado					; faz a leitura das teclas da linha LINHA_TECLADO
	CMP R0, 0						; houve tecla premida?
	JZ ciclo_esgotou_energia		; lê o teclado até haver tecla
	CALL encontra_tecla				; qual foi a tecla premida?
	CMP R6, R2						; foi a tecla C?
	JZ controlo						; se sim, volta ao inicio do processo
	JMP ciclo_esgotou_energia		; se não, volta ao início do ciclo
		
; **********************************************************************
; Processo
;
; TECLADO - Processo que deteta quando se carrega numa tecla
;		  do teclado e escreve o valor da tecla num LOCK.
;
; **********************************************************************

PROCESS SP_inicial_teclado	

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
	WAIT			   ; ponto de fuga para outro processo
	MOV R1, LINHA	   ; começamos por testar a linha 4
proxima_linha:
	SHR R1, 1		   ; muda para a linha acima
	JZ espera_tecla	   ; se já testou todas as linhas, repete o ciclo
    CALL teclado	   ; leitura das teclas
    CMP  R0, 0         ; há tecla premida?
    JZ  proxima_linha  ; se nenhuma tecla foi premida, passa à próxima linha
	
	MOV R8, R1		   			; guardar valor da linha
	CALL encontra_tecla			; descobre qual foi a tecla premida
	MOV	[tecla_carregada], R6	; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada
								; altera a variável LOCK para o valor da tecla
verifica_pause:
	MOV R1, TECLA_PAUSE
	CMP R6, R1				; verifica se a tecla de pausa foi premida
	JNZ verifica_fim_jogo	; se não, salta
	MOV R1, 4				; flag que indica que a tecla de pausa foi premida
	MOV [GAME_OVER], R1		; para o processo "controlo" saber que o jogo foi suspendido
	JMP ha_tecla	
verifica_fim_jogo:
	MOV R1, TECLA_FIM
	CMP R6, R1 				; verifica se a tecla para terminar o jogo foi premida
	JNZ ha_tecla			; se não, salta
	CALL toca_game_over
	MOV R1, 3				; flag que indica que a tecla para terminar o jogo foi premida
	MOV [GAME_OVER], R1		; para o processo "controlo" saber que o jogo foi terminado

ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
	YIELD			   ; ponto de fuga para outro processo
	MOV R1, R8         ; repõe a linha a testar
	CALL teclado	   ; leitura das teclas
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  espera_tecla  ; repete ciclo

; **********************************************************************
; Processo
;
; NAVE - Processo responsável por atualizar e desenhar os painéis
;			de instrumentos da nave.
;
; **********************************************************************
PROCESS SP_inicial_nave

nave:
	MOV R1, LINHA_PAINEL		; linha de referência do painel
	MOV R2, COLUNA_PAINEL		; coluna de referência do painel
	MOV R5, 0					; contador de incrementos
	
anima_painel:
	MOV R3, DEF_PAINEL			; endereço da tabela dos painéis
	ADD R3, R5					; indexar a tabela de painéis
	MOV R4, [R3]				; endereço da tabela do painel corrente
	CALL desenha_boneco			; desenha o painel
	MOV R0, [evento_int_nave]	; leitura do LOCK, bloqueia até haver interrupção 3
	CALL apaga_boneco
	MOV R0, MAX_PAINEL		; vai verificar se já indexamos a tabela toda
	CMP R5, R0  			; chegou ao último painel?
	JZ nave					; se sim volta ao primeiro
	ADD R5, 2				; próximo valor para indexar a tabela
	JMP anima_painel    	; desenha o próximo painel
		
; **********************************************************************
; Processo
;
; ENERGIA - Processo que retira 3% de energia à nave e atualiza os displays.
;
; **********************************************************************
PROCESS SP_inicial_energia

energia:
	MOV R1, [evento_int_energia]	; leitura do LOCK, bloqueia até haver interrupção 2
	MOV R1, PERDA_ENERGIA			; energia perdida periodicamente
	CALL retira_energia
	JMP energia

; **********************************************************************
; Processo
;
; SONDA - Processo que trata do lançamento e movimento de uma sonda.
;
; **********************************************************************
PROCESS SP_inicial_sonda

sonda:
	MOV	R1, TAMANHO_PILHA	; tamanho em palavras da pilha de cada processo
	MUL	R1, R10				; TAMANHO_PILHA vezes o nº da instância da "sonda"
	SUB	SP, R1		     	; ajusta SP deste "sonda"	
	MOV  R5, R10			; cópia do nº de instância do processo
	SHL  R5, 1				; multiplica por 2 porque as tabelas são de WORDS
	MOV R6, tab_sondas		; endereço da tabela com os endereços de todas as instâncias das sondas
	MOV R7, [R6+R5]			; endereço da tabela da sonda desta intância específica
	MOV R9, reinicia_sondas ; endereço da tabela com as flags de restart das sondas
inicio_sonda:
	CALL desativa_flag_restart	; repõe flag de restart a 0
	MOV R1, colisoes_sondas		; tabela com as flags de colisões de sondas
	MOV R3, 0					; repõe a flag a 0
	MOV [R1+R5], R3				; flag de colisão da sonda desta instância específica
	MOV R3, sondas_ativas	; endereço da tabela das flags que indicam se as sondas estão ativas
	MOV R0, [tecla_carregada]   ; leitura do LOCK, bloqueia até se carregar numa tecla
	CMP R0, TECLA_ESQ        	; verifica se a tecla premida foi 0
	JZ move_esq                 ; se sim move para a esquerda
	CMP R0, TECLA_FRENTE    	; verifica se a tecla premida foi 1
	JZ move_frente              ; se sim move para a frente
	CMP R0, TECLA_DRT        	; verifica se a tecla premida foi 2 
	JZ move_drt                 ; se sim move para a direita 
	JMP sonda                ; se não houver uma tecla premida, repete o ciclo

move_esq:
	MOV R0, [R3]				; flag da sonda da esquerda
	CMP R0, 1					; verifica se a sonda está ativa (já foi lançada)
	JZ inicio_sonda				; se sim, não lança a sonda
	MOV R0, 1					; se não, muda a flag para 1
	MOV [R3], R0				; assinala mudança na tabela
	MOV R4, -1					; sentido do movimento para a esquerda
	MOV R2, COLUNA_SONDA_ESQ	; coluna inicial da sonda
	JMP inicio_move
move_frente:	
	MOV R0, [R3+2]				; flag da sonda central
	CMP R0, 1					; verifica se a sonda está ativa (já foi lançada)
	JZ inicio_sonda				; se sim, não lança a sonda
	MOV R0, 1					; se não, muda a flag para 1
	MOV [R3+2], R0				; assinala mudança na tabela
	MOV R4, 0					; sentido do movimento em frente
	MOV R2, COLUNA_SONDA_CENTRO	; coluna inicial da sonda
	JMP inicio_move
move_drt:
	MOV R0, [R3+4]				; flag da sonda da direita
	CMP R0, 1					; verifica se a sonda está ativa (já foi lançada)
	JZ inicio_sonda				; se sim, não lança a sonda
	MOV R0, 1					; se não, muda a flag para 1
	MOV [R3+4], R0				; assinala mudança na tabela
	MOV R4, +1					; sentido do movimento para a direita
	MOV R2, COLUNA_SONDA_DRT	; coluna inicial da sonda

inicio_move:
	MOV R1, PERDA_ENERGIA_SONDA		; o lançamento da sonda retira 5% à energia da nave
	CALL retira_energia			
	MOV R1, LINHA_SONDA				; linha inicial da sonda (igual para todas)
	MOV [R7], R1					; inicializa a linha na tabela da sonda
	MOV [R7+2], R2					; inicializa a coluna na tabela da sonda
	MOV R3, VERMELHO				; cor da sonda
	CALL toca_disparo					; som de disparo da sonda
	CALL escreve_pixel				; desenho na posição inicial
	CALL movimento_sonda			; movimenta a sonda até ser desativada
	JMP inicio_sonda				; espera pelo próximo lançamento de sonda
	

; **********************************************************************
; Processo
;
; ASTEROIDE - Processo que trata do aparecimento e movimento de um asteroide.
; Argumentos:   R11 - número da instância do processo (0 a 3)
;
; **********************************************************************
PROCESS SP_inicial_asteroide

asteroide:
	MOV	R1, TAMANHO_PILHA	; tamanho em palavras da pilha de cada processo
	MUL	R1, R11				; TAMANHO_PILHA vezes o nº da instância do "asteroide"
	SUB	SP, R1		     	; ajusta SP deste "asteroide"	
	MOV  R10, R11			; cópia do nº de instância do processo
	SHL  R10, 1				; multiplica por 2 porque as tabelas são de WORDS
	MOV R6, tab_asteroides	; endereço da tabela com os endereços de todas as instâncias dos asteroides
	MOV R7, [R6+R10]		; endereço da tabela do asteroide desta intância específica
	MOV R9, reinicia_asteroides ; endereço da tabela com as flags de restart dos asteroides
	MOV R6, R11				; cópia do nº de instância do processo
	ADD R6, 1				; para selecionar o ecrã do asteroide (1-4)
inicio_asteroide:
	MOV R5, R10						; para passar o valor como argumento da rotina "desativa_flag_restart"
	CALL desativa_flag_restart		; repõe flag de restart a 0
	MOV R1, colisoes_asteroides		; tabela com as flags de colisões de asteroides
	MOV R0, 0						; repõe a flag a 0
	MOV [R1+R10], R0				; flag de colisão do asteroide desta instância específica
	CALL tipo_asteroide		; trata de determinar se o asteroide é minerável ou não
							; e alterar o valor na tabela do asteroide
	MOV R2, 0
	MOV [R7+2], R2				  ; inicializa linha a 0
	CALL coluna_direcao_asteroide ; trata de determinar a coluna inicial do asteroide e o 
								  ; sentido do movimento e altera os valores respetivos na tabela
move_asteroide:
	MOV R0, R6
	MOV [SELECIONA_DISPLAY], R0	; seleciona o ecrã desta instância do asteroide
	MOV R1, [R7+2]				; linha atual do asteroide
	MOV R2, [R7+4]				; coluna atual do asteroide
	CALL desenha_boneco
	MOV R0, 0
	MOV [SELECIONA_DISPLAY], R0			; seleciona o ecrã principal
	MOV R3, [evento_int_asteroides]   	; leitura do LOCK, bloqueia até haver interrupção 0
	MOV R0, R6
	MOV [SELECIONA_DISPLAY], R0	; seleciona o ecrã desta instância do asteroide
	CALL apaga_boneco
	INC R1						; próxima linha
	MOV [R7+2], R1				; atualiza a linha na tabela
	ADD R2, R8					; valor a adicionar à coluna de acordo com o sentido do movimento
	MOV [R7+4], R2				; atualiza a coluna na tabela
	MOV R5, [R4]				; obtém a largura do asteroide (R4 é a tabela que o define)
	CALL testa_limites			; verifica se o asteroide saiu dos limites
	CMP R0, 1					; ultrapassou os limites?
	JZ inicio_asteroide			; gera um novo asteroide
	MOV R0, colisoes_asteroides		; tabela com as flags de colisões de asteroides
	MOV R3, [R0+R10]				; flag de colisão do asteroide desta instância específica
	CMP R3, 1						; verifica se houve colisão com uma sonda
	JZ inicio_asteroide				; se sim, gera um novo asteroide
	MOV R0, [R9+R10]				; endereço da flag de restart do asteroide
	MOV R3, [R0]					; obtém o valor da flag
	CMP R3, 1						; verifica se é para reiniciar o asteroide
	JZ inicio_asteroide				; se está ativa, reinicia o asteroide
	CALL verifica_colisao_nave		; verifica se o asteroide atingiu a nave
	JMP move_asteroide				; se não, continua o movimento
	
; **********************************************************************
; ROTINA_PAUSA - Rotina responsável por tratar do modo de jogo em pausa.
;
; Retorno:	R1 - indica se o jogo foi retomado ou terminado.
; **********************************************************************	
rotina_pausa:
	PUSH R0
	PUSH R2
	PUSH R3
	PUSH R6
	PUSH R8
	PUSH R9
	MOV R8, 0
	MOV [GAME_OVER], R8					; repôr variável a 0 (para o jogo poder prosseguir)
	MOV R1, LINHA_TECLADO				; linha do teclado que se quer testar
	MOV R2, TECLA_PAUSE		
	MOV R3, TECLA_FIM
	MOV R9, ECRA_PAUSA
	MOV [SELECIONA_CENARIO_FRONTAL], R9	; seleciona a imagem de pausa
	CALL rotina_ha_tecla				; espera até não haver tecla premida
ciclo_pause:
	CALL teclado					; faz a leitura das teclas da linha LINHA_TECLADO
	CALL encontra_tecla				; qual foi a tecla premida?
	CMP R6, R2						; foi a tecla D?
	JZ sai_ciclo_pause				; se sim, sai do modo pause
	CMP R6, R3						; foi a tecla E?
	JZ pause_para_termina			; se sim, vai para o ecrã de start
	JMP ciclo_pause					; se nenhuma tecla foi premida, volta ao início do ciclo
sai_ciclo_pause:
	CALL rotina_ha_tecla			; espera até não haver tecla premida
	CALL toca_unpause				; som de retomar o jogo
	MOV [APAGA_CENARIO_FRONTAL], R9	; apaga o ecrã de pausa	
	MOV R1, 1						; indica que o jogo foi retomado
	JMP sai_rotina_pause
pause_para_termina:
	MOV [APAGA_CENARIO_FRONTAL], R9	; apaga o ecrã de pausa	
	CALL ativa_flags_restart			; se está a 3, o jogo foi terminado, ativam-se todas as flags
										; de restart para comunicar o fim do jogo aos processos
	MOV R1, 0						; indica que o jogo não foi retomado
sai_rotina_pause:
	POP R9
	POP R8
	POP R6
	POP R3
	POP R2
	POP R0
	RET
	
; **********************************************************************
; ATIVA_FLAGS_RESTART - Rotina que trata de ativar todas as flags de 
;						restart, das sondas e dos asteroides.
;
; **********************************************************************
ativa_flags_restart:							
	PUSH R0
	PUSH R4
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R0, 1							; valor para ativar as flags
	MOV R9, reinicia_asteroides			; tabela das flags de restart dos asteroides
	MOV R10, 0							; valor para indexar a tabela
	MOV R8, 8							; último valor de R10
ativa_flags_asteroides:
	MOV R4, [R9+R10]					; instância do asteroide (0-3)
	MOV [R4], R0					; alterar a flag para assinalar que se deve reiniciar o asteroide
	ADD R10, 2							; próximo valor para indexar a tabela
	CMP R10, R8							; verifica se já passou por todos os asteroides
	JNZ ativa_flags_asteroides			; se não, vai para o próximo asteroide 
	MOV R9, reinicia_sondas				; tabela das flags de restart das sondas
	MOV R10, 0							; repõe valor para indexar a tabela
	MOV R8, 6							; último valor de R10, no caso das sondas
ativa_flags_sondas:					
	MOV R4, [R9+R10]					; instância da sonda (0-2)
	MOV [R4], R0					; alterar a flag para assinalar que se deve reiniciar a sonda
	ADD R10, 2							; próximo valor para indexar a tabela
	CMP R10, R8							; verifica se já passou por todas as sondas
	JNZ ativa_flags_sondas				; se não, vai para a próxima sonda
	POP R10
	POP R9
	POP R8
	POP R4
	POP R0
	RET	

; **********************************************************************
; DESATIVA_FLAG_RESTART - Rotina que trata de desativar uma flag de 
;						restart, de uma sonda ou asteroide.
; Argumentos:	R9 - tabela com os endereços das flags de restart
;				R5 - instância do processo multiplicada por dois porque as
;					tabelas são de words.
;
; **********************************************************************
desativa_flag_restart:
	PUSH R0
	PUSH R1
	PUSH R5
	PUSH R9
	MOV R0, 0
	MOV R1, [R9+R5]			; endereço da variável com a flag de restart 
							; da instância do processo respetiva
	MOV [R1], R0			; repôr a flag a 0
	POP R9
	POP R5
	POP R1
	POP R0
	RET

; **********************************************************************
; TIPO_ASTEROIDE - Determina se um asteroide é minerável ou não.
; Argumentos:   R7 - tabela que define as características do asteroide
;				(tipo, linha, coluna e direção)
; Retorno:	R4 - tabela que define o asteroide (largura, altura, pixels)
;
; **********************************************************************
tipo_asteroide:
	PUSH R1
	PUSH R2
	PUSH R5
	CALL gera_aleatorio
	MOV R5, MASCARA_MENOR	; para isolar os 2 bits de menor peso e obter um número entre 0 e 3
	AND R1, R5				; elimina os bits para além dos bits 0 e 1
	CMP R1, 0				; calhou minerável?
	JZ asteroide_mineravel	; se sim torna-o minerável
	MOV R2, 0
	MOV [R7], R2			; torna o asteroide não minerável, indicando-o na tabela do asteroide
	MOV R4, DEF_ASTEROIDE	; tabela que define o asteroide não minerável (largura, altura, pixels)
	JMP sai_tipo_asteroide
asteroide_mineravel:
	MOV R2, 1
	MOV [R7], R2			; torna o asteroide minerável, indicando-o na tabela do asteroide
	MOV R4, DEF_ASTEROIDE_MIN	; tabela que define o asteroide minerável (largura, altura, pixels)
sai_tipo_asteroide:
	POP R5
	POP R2
	POP R1
	RET

; **********************************************************************
; COLUNA_DIRECAO_ASTEROIDE - Determina a combinação coluna-direção do asteroide.
; Argumentos:   R7 - tabela que define as características do asteroide
;				(tipo, linha, coluna e direção)
; Retorno:	R8 - valor do sentido do movimento do asteroide
; **********************************************************************
coluna_direcao_asteroide:
	PUSH R1
	PUSH R2
	PUSH R5
	CALL gera_aleatorio
	MOV R2, DIVISOR_1		; divisor igual a 5
	MOD R1, R2				; obtém um resto entre 0 e 4
	SHL R1, 2				; multiplica por 4 porque as tabelas são de words
							; e cada elemento da tabela tem duas words
	MOV R5, coluna_direcao	; tabela com as combinações de coluna e direção
	MOV R8, [R5+R1]			; obtém a coluna inicial do asteroide
	MOV [R7+4], R8			; guarda o valor da coluna na tabela do asteroide
	ADD R1, 2				; próxima word
	MOV R8, [R5+R1]			; obtém a direção do asteroide
	POP R5
	POP R2
	POP R1
	RET
	
; **********************************************************************
; MOVIMENTO_SONDA - Rotina que trata do movimento de uma sonda.
; Argumentos:
;				R4 - sentido do movimento da sonda
;				R7 - tabela que define a posição atual da sonda (linha, coluna)
;				R5 - instância do processo multiplicada por dois porque as
;					tabelas são de words.
; **********************************************************************
movimento_sonda: 
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R9
	MOV R0, 0						; inicializa contador de movimentos
ciclo_movimento_sonda:
	MOV R3, [evento_int_sondas]     ; leitura do LOCK, bloqueia até haver interrupção 1
	MOV R3, 0						; cor transparente
	CALL escreve_pixel
	MOV R1, [R7]					; obtém linha atual da sonda
	SUB R1, 1						; anda para a linha anterior
	MOV [R7], R1     				; atualiza a linha da sonda
	MOV R2, [R7+2]					; obtém coluna atual da sonda
	ADD R2, R4						; adiciona valor do sentido do movimento à coluna
	MOV [R7+2], R2   				; atualiza a coluna atual da sonda
	INC R0                    		; mais um movimento utilizado
	MOV R3, ALCANCE_SONDA
	CMP R0, R3    					; verifica se a sonda ultrapassou o alcance da nave
	JZ reset_flag_sonda             ; desativa a sonda
	CALL verifica_colisao_sonda		; verifica se a sonda atingiu um asteroide
	MOV R9, colisoes_sondas			; tabela com as flags de colisões de sondas			
	MOV R3, [R9+R5]					; flag de colisão da sonda desta instância específica
	CMP R3, 1						; se atingiu um asteroide, desativa a sonda
	JZ reset_flag_sonda
	MOV R9, reinicia_sondas			; tabela de flags de restart das sondas
	MOV R6, [R9+R5]					; endereço da flag de restart da sonda
	MOV R3, [R6]					; obtém o valor da flag
	CMP R3, 1						; verifica se é para reiniciar a sonda
	JZ reset_flag_sonda				; se está ativa, reinicia a sonda
	MOV R3, VERMELHO				; cor da sonda
	CALL escreve_pixel
	JMP ciclo_movimento_sonda       ; volta ao inicio do ciclo
reset_flag_sonda:
	MOV R3, sondas_ativas	; endereço da tabela das flags que indicam se as sondas estão ativas
	MOV R0, 0				; muda a flag para 0
	CMP R4, -1				; verifica se é a sonda da esquerda
	JZ fim_flag_sonda
	ADD R3, 2				; próxima word da tabela (flag da sonda central)
	CMP R4, 0				; verifica se é a sonda central
	JZ fim_flag_sonda
	ADD R3, 2				; próxima word da tabela (flag da sonda da direita)
fim_flag_sonda:
	MOV [R3], R0			; assinala mudança na tabela
	POP R9
	POP R7
	POP R6
	POP R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	POP R0
	RET

; **********************************************************************
; VERIFICA_COLISAO_SONDA - Verifica se houve colisão da sonda com um asteroide.
; Argumentos:   R7 - tabela que define a posição atual da sonda (linha, coluna)
;				R5  - instância do processo multiplicada por dois porque as
;					tabelas são de words.
; **********************************************************************
verifica_colisao_sonda:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9	
	PUSH R10
	PUSH R11
	MOV R1, [R7] 			; linha atual da sonda
	MOV R2, [R7+2]			; coluna atual da sonda
	MOV R0, tab_asteroides	; tabela das instâncias dos asteroides
	MOV R10, 0				; valor para indexar a tabela de asteroides
valores_asteroides:
	MOV R8, [R0+R10]		; instância do asteroide (0-3)
	ADD R10, 2				; próximo valor para indexar a tabela na próxima iteração
	MOV R3, [R8+2]			; linha atual do asteroide
	MOV R9, DEF_ASTEROIDE
	MOV R4, [R9+2]			; obter a altura do asteroide
	SUB R4, 1				; para dar a última linha do asteroide
	ADD R4, R3				; última linha do asteroide
	MOV R11, [R8+4]			; coluna atual do asteroide
	MOV R6, [R9]			; obter a largura do asteroide
	SUB R6, 1				; para dar a última coluna do asteroide
	ADD R6, R11				; última coluna do asteroide
	
	CMP R1, R4				; linha da sonda maior que a última linha do asteroide?
	JGT proximo_asteroide	; se sim, não há colisão
	CMP R2, R11				; coluna da sonda menor que a primeira coluna do asteroide?
	JLT proximo_asteroide   ; se sim, não há colisão
	CMP R2, R6				; coluna da sonda maior que a última coluna do asteroide?
	JGT proximo_asteroide   ; se sim, não há colisão
	CMP R1, R3				; linha da sonda menor que a primeira linha do asteroide?
	JLT proximo_asteroide   ; se sim, não há colisão
	JMP houve_colisao_sonda
proximo_asteroide:
	MOV R9, 8
	CMP R10, R9						; já verificou todos os asteroides?
	JNZ valores_asteroides			; se não, passa ao próximo
	JMP fim_verifica_colisao_sonda	; não houve colisão
	
; se nenhuma das condições se verificou, há colisão
houve_colisao_sonda:
	MOV R0, colisoes_sondas		; tabela com as flags de colisões de sondas
	MOV R9, 1
	MOV [R0+R5], R9				; altera a flag para assinalar que houve uma colisão
	MOV R0, colisoes_asteroides	; tabela das flags de colisões de cada asteroide
	SUB R10, 2					; repõe o valor correto que foi usado para indexar a tabela
	MOV [R0+R10], R9			; altera a flag para assinalar que houve uma colisão
	MOV R1, R3					; passar a linha do asteroide como argumento da rotina
	MOV R2, R11					; passar a coluna do asteroide como argumento da rotina
	MOV R4, [R8]				; tipo do asteroide (minerável ou não)
	CMP R4, 1					; é minerável?
	JZ colisao_mineravel
colisao_nao_mineravel:
	CALL toca_nao_mineravel		; som de explosão
	MOV R4, DEF_HIT_AST			; tabela que define a animação do asteroide não minerável
	MOV R3, [evento_int_asteroides]   ; leitura do LOCK, bloqueia até haver interrupção 0
	CALL desenha_boneco
	MOV R3, [evento_int_asteroides]   ; leitura do LOCK, bloqueia até haver interrupção 0
	CALL apaga_boneco
	JMP fim_verifica_colisao_sonda
colisao_mineravel:
	CALL toca_mineravel				  ; som da explosão e ganho de energia
	CALL adiciona_energia			  ; aumenta a energia da nave em 25%
	MOV R4, DEF_HIT_ASTM_1   		  ; tabela que define a primeira frame de animação
	MOV R3, [evento_int_asteroides]   ; leitura do LOCK, bloqueia até haver interrupção 0
	CALL desenha_boneco
	MOV R3, [evento_int_asteroides]   ; leitura do LOCK, bloqueia até haver interrupção 0
	CALL apaga_boneco
	MOV R4, DEF_HIT_ASTM_2			  ; tabela que define a segunda frame de animação
	CALL desenha_boneco
	MOV R3, [evento_int_asteroides]   ; leitura do LOCK, bloqueia até haver interrupção 0
	CALL apaga_boneco	
fim_verifica_colisao_sonda:	
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	POP R0
	RET

; **********************************************************************
; VERIFICA_COLISAO_NAVE - Verifica se houve colisao de um asteróide com a nave.
;
; Argumentos: R1 - linha atual do asteroide
;         	 R2 - coluna atual do asteroide
;
; **********************************************************************
verifica_colisao_nave:
	PUSH R0
    PUSH R1
    PUSH R2
	PUSH R3
	PUSH R4
	PUSH R9
	MOV R9, DEF_ASTEROIDE
	MOV R4, [R9+2]				; obter a altura do asteroide
	SUB R4, 1					; para dar a última linha do asteroide
    ADD R1, R4					; linha de baixo do asteroide
	MOV R3, [R9]				; obter a largura do asteroide
	SUB R3, 1					; para dar a última coluna do asteroide
	ADD R3, R2					; coluna da direita do asteroide
	MOV R4, LINHA_NAVE
    CMP R1, R4		        	; compara linha de baixo do asteroide com a primeira linha da nave
    JLT fim_colisao_nave        ; se for maior, não há colisão
    MOV R4, ULTIMA_COL_NAVE 	; última coluna da nave
	CMP R2, R4    				; compara a primeira coluna do asteroide com a ultima coluna da nave
    JGT fim_colisao_nave        ; se for maior, não há colisão
	MOV R4, COLUNA_NAVE			; primeira coluna da nave
    CMP R3, R4         			; compara a ultima coluna do asteroide com a primeira coluna da nave
    JLT fim_colisao_nave        ; se for menor, não há colisão

    ; se chegou ate aqui, houve colisão - FIM DO JOGO
    MOV [APAGA_ECRÃ], R0        ; apaga todos os pixeis do ecrã
    MOV R0, 2
    MOV [GAME_OVER], R0         ; coloca o GAME_OVER a 2 (fim do jogo por colisao com a nave)
fim_colisao_nave:
	POP R9
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET       					
		
; **********************************************************************
; RETIRA_ENERGIA - Retira um valor de energia à nave, 
; 					atualiza os displays e verifica se acabou a energia.
; Argumentos: R1 - Valor a retirar
;
; **********************************************************************
retira_energia:
	PUSH R0
	PUSH R2
	PUSH R4
	MOV R0, [ENERGIA_NAVE]		; energia atual da nave
	CMP R0, R1					; verifica se o valor da energia é maior que o valor a retirar
	JGT	atualiza_energia		; se for maior, não se esgotou a energia
	MOV R4, 0					; se não, esgotou-se a energia e deixamo-la a 0
	MOV R0, 0
	MOV [DISPLAYS], R4       	; atualiza o valor nos displays
	MOV [ENERGIA_NAVE], R0  	; atualiza a energia
	MOV R2, 1					; alterar a flag GAME_OVER, para o processo "controlo"
	MOV [GAME_OVER], R2			; saber que o jogo acabou por falta de energia
	JMP sai_retira_energia
atualiza_energia:
	SUB R0, R1					; subtrai o valor à energia
	CALL converte_hex_decimal  	; converte o valor para decimal
	MOV [DISPLAYS], R4       	; atualiza o valor nos displays
	MOV [ENERGIA_NAVE], R0  	; atualiza a energia
sai_retira_energia:
	POP R4
	POP R2
	POP R0
	RET
	
; **********************************************************************
; ADICIONA_ENERGIA - Aumenta a energia da nave em 25% e atualiza os displays.
;
; **********************************************************************
adiciona_energia:
	PUSH R0
	PUSH R1
	PUSH R4
	MOV R0, [ENERGIA_NAVE]			; energia atual da nave
	MOV R1, ENERGIA_ASTEROIDE		; valor a adicionar
	ADD R0, R1						
	CALL converte_hex_decimal  		; converte o valor para decimal
	MOV [DISPLAYS], R4       		; atualiza o valor nos displays
	MOV [ENERGIA_NAVE], R0  		; atualiza a energia
	POP R4
	POP R1
	POP R0
	RET
	
; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R1 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)
; **********************************************************************
teclado:
	PUSH R2
	PUSH R3
	PUSH R5
	MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R1      ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
	POP R5
	POP R3
	POP R2
	RET

; **********************************************************************
; CONVERTE - Converte um valor binário de linha/coluna e adiciona-o a R6.
; Argumentos:   R1 - valor a converter
;				R6 - auxiliar em que se acumula o resultado da conversão
; Retorna:   R6 - R6 + resultado da conversão
;
; **********************************************************************
converte:
	PUSH R1
	PUSH R2
	MOV R2, 0		   ; inicializa contador
ciclo_converte:		   ; neste ciclo converte-se o valor da coluna/linha para 0, 1, 2 ou 3
	INC R2
	SHR R1, 1
	JNZ ciclo_converte ; se o bit a 1 ainda não caiu, continua a incrementar
	SUB R2, 1          ; passar os valores de 1, 2, 3 e 4 para 0, 1, 2 e 3, respetivamente
	ADD R6, R2		   ; acumula o resultado na auxiliar
	POP R2			   ; recuperar os valores da pilha
	POP R1
	RET

; **********************************************************************
; ROTINA_HA_TECLA - Espera até não haver uma tecla premida
; Argumentos:	R1 - linha a testar 
;
; **********************************************************************

rotina_ha_tecla:
	PUSH R0
	ciclo_ha_tecla:
		CALL teclado
		CMP R0, 0 				; há tecla premida?
		JNZ ciclo_ha_tecla		; volta ao inicio do ciclo até não haver uma tecla carregada 
	POP R0
	RET

; **********************************************************************
; ENCONTRA_TECLA - Encontra qual foi a tecla premida
; Argumentos:	R1 - linha a converter
;				R0 - coluna a converter
;
; Retorna: 	R6 - valor da tecla premida
; **********************************************************************
encontra_tecla:
	PUSH R0
	PUSH R1
	MOV R6, 0          ; inicializar auxiliar para detetar a tecla premida
	CALL converte	   ; converte o valor da linha
	SHL R6, 2		   ; multiplica o valor da linha por quatro
	MOV R1, R0		   ; R0 é o argumento passado para a rotina converte
	CALL converte	   ; converte o valor da coluna
	POP R1
	POP R0
	RET
	
; **********************************************************************
; DESENHA_NAVE - Desenha a nave.
;
; **********************************************************************
desenha_nave:
	PUSH R1
	PUSH R2
	PUSH R4
	MOV R1, LINHA_NAVE			; linha referência da nave
	MOV R2, COLUNA_NAVE			; coluna referência da nave
	MOV R4, DEF_NAVE			; tabela que define a nave
	CALL desenha_boneco
	POP	R4
	POP	R2
	POP R1
	RET

; **********************************************************************
; ESCREVE_PIXEL - Desenha ou apaga um pixel numa dada linha e coluna.
; Argumentos:   R1 - linha
; 				R2 - coluna
;				R3 - cor do pixel
;
; **********************************************************************    
escreve_pixel:
	PUSH R1
	PUSH R2
	PUSH R3
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
    POP R3
	POP R2
	POP R1
	RET
	
; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha referência
;               R2 - coluna referência
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	MOV R7, R2				; guarda a coluna referência
	MOV	R5, [R4]			; obtém a largura do boneco
	MOV R8, R5				; guarda a largura
	ADD	R4, 2				; endereço da altura do boneco
	MOV R6, [R4]			; obtém a altura do boneco
	ADD R4, 2				; endereço da cor do primeiro pixel

desenha_pixels:				; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2				; endereço da cor do próximo pixel
    ADD R2, 1               ; próxima coluna
    SUB R5, 1				; menos uma coluna para tratar
    JNZ desenha_pixels      ; continua até percorrer toda a linha atual
	
	MOV R2, R7				; volta à primeira coluna
	MOV R5, R8				; repõe o valor da largura
	ADD R1, 1				; próxima linha
	SUB R6, 1				; menos uma linha para tratar
	JNZ desenha_pixels		; continua até percorrer todas as linhas da tabela
	POP R8
	POP R7
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET
	
; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha referência
;               R2 - coluna referência
;               R4 - tabela que define o boneco
;
; **********************************************************************
apaga_boneco:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	MOV R7, R2				; guarda a coluna referência
	MOV	R5, [R4]			; obtém a largura do boneco
	MOV R8, R5				; guarda a largura
	ADD	R4, 2				; endereço da altura do boneco
	MOV R6, [R4]			; obtém a altura do boneco
	ADD R4, 2				; endereço da cor do primeiro pixel

apaga_pixels:
	MOV	R3, 0				; cor para apagar o próximo pixel do boneco
	CALL escreve_pixel		; escreve cada pixel do boneco
	ADD R2, 1               ; próxima coluna
    SUB R5, 1				; menos uma coluna para tratar
    JNZ apaga_pixels      ; continua até percorrer toda a linha atual
	
	MOV R2, R7				; volta à primeira coluna
	MOV R5, R8				; repõe o valor da largura
	ADD R1, 1				; próxima linha
	SUB R6, 1				; menos uma linha para tratar
	JNZ apaga_pixels		; continua até percorrer todas as linhas da tabela
	POP R8
	POP R7
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   	muda R0 para 1.
; Argumentos:	R1 - linha em que o objeto está
;				R2 - coluna em que o objeto está
;				R5 - largura do boneco
;
; Retorna: 	R0 - indica se o objeto saiu dos limites.
; **********************************************************************
testa_limites:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R3, MIN_COLUNA
	ADD R5, R2				; posição a seguir ao extremo direito do boneco
	CMP	R5, R3
	JLE	ultrapassou_limites
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	MOV	R3, MAX_COLUNA
	CMP	R2, R3
	JGE	ultrapassou_limites
testa_limite_inferior:		; vê se o boneco chegou ao limite inferior
	MOV R3, MAX_LINHA
	CMP R1, R3
	JGE ultrapassou_limites
	MOV R0, 0				; indica que o objeto está dentro dos limites
	JMP sai_testa_limites	; o boneco está dentro dos limites do ecrã
ultrapassou_limites:
	MOV R0, 1 				; indica que o objeto saiu dos limites
sai_testa_limites:
	POP	R5
	POP R3
	POP R2
	POP R1
	RET

; **********************************************************************
; GERA_ALEATORIO - Gera um número aleatório entre 0 e 15
;
; Retorna:   R1 - número aleatório gerado
;
; **********************************************************************
gera_aleatorio:
	PUSH R0
	MOV R0, TEC_COL		; endereço do periférico PIN
	MOVB R1, [R0]		; leitura do periférico de 8 bits
	SHR R1, 4			; coloca os bits 7 a 4 (bits "no ar") nos bits 3 a 0
	POP R0
	RET
	
; **********************************************************************
; CONVERTE_HEX_DECIMAL - Desenha ou apaga um pixel numa dada linha e coluna.
; Argumentos:   R1 - valor em hexadecimal a converter em decimal
; Retorna: 	R4 - resultado em decimal
;
; **********************************************************************   
converte_hex_decimal:
	PUSH R0
	PUSH R2
	PUSH R3
	PUSH R5
	MOV R2, FATOR		; inicializar o fator
	MOV R4, 0			; inicializar o resultado
	MOV R5, DIVISOR_0
ciclo_hex_decimal:			; este ciclo trata da conversão de hexadecimal para decimal
	MOD R0, R2			; valor a converter nesta iteração
	DIV R2, R5			; prepara o próximo fator de divisão
	CMP R2, 1			; terminou a conversão?
	JLT sai_hex_decimal	; se sim sai do ciclo
	MOV R3, R0			; cópia do número
	DIV R3, R2			; dígito do valor decimal
	SHL R4, 4			; dá espaço ao novo dígito
	OR R4, R3			; compõe o resultado
	JMP ciclo_hex_decimal
sai_hex_decimal:	
	POP	R5
	POP	R3
	POP	R2
	POP R0
	RET
	
	
; **********************************************************************
; Rotinas para tocar sons
; **********************************************************************

; **********************************************************************
; TOCA_BEGIN - Toca o som de começo do jogo.
; **********************************************************************

toca_begin:
    PUSH R0
    MOV R0, SOM_BEGIN
    MOV [TOCA_SOM], R0
    POP R0
    RET


; **********************************************************************
; TOCA_GAME_OVER - Toca o som de derrota.
; **********************************************************************
toca_game_over:
	PUSH R0
	MOV R0, SOM_GAME_OVER
	MOV [TOCA_SOM], R0
	POP R0
	RET

; **********************************************************************
; TOCA_DISPARO - Toca o som do disparo de uma sonda
; **********************************************************************

toca_disparo:
    PUSH R0
    MOV R0, SOM_DISPARO
    MOV [TOCA_SOM], R0
    POP R0
    RET


; **********************************************************************
; TOCA_NAO_MINERAVEL - Toca o som da explosão de um asteróide não minerável
; **********************************************************************

toca_nao_mineravel:
    PUSH R0
    MOV R0, SOM_NAO_MINERAVEL
    MOV [TOCA_SOM], R0
    POP R0
    RET


; **********************************************************************
; TOCA_MINERAVEL - Toca o som da explosão de um asteróide minerável
; **********************************************************************

toca_mineravel:
    PUSH R0
    MOV R0, SOM_MINERAVEL
    MOV [TOCA_SOM], R0
    POP R0
    RET

; **********************************************************************
; TOCA_PAUSE - Toca o som de suspender o jogo
; **********************************************************************

toca_pause:
    PUSH R0
    MOV R0, SOM_PAUSE
    MOV [TOCA_SOM], R0
    POP R0
    RET
	
; **********************************************************************
; TOCA_UNPAUSE - Toca o som de retomar o jogo
; **********************************************************************

toca_unpause:
    PUSH R0
    MOV R0, SOM_UNPAUSE
    MOV [TOCA_SOM], R0
    POP R0
    RET

; **********************************************************************
; Rotinas de interrupção 
; **********************************************************************


; **********************************************************************
; ROT_INT_ASTEROIDES - 	Rotina de atendimento da interrupção 0
;			Assinala o evento na componente 0 da variável evento_int
; **********************************************************************
rot_int_asteroides:
	PUSH R0
	MOV  R0, 1						   ; assinala que houve uma interrupção 0
	MOV  [evento_int_asteroides], R0   ; desbloqueia o processo "energia"
	POP  R0
	RFE

; **********************************************************************
; ROT_INT_SONDAS - 	Rotina de atendimento da interrupção 1
;			Assinala o evento na componente 1 da variável evento_int
; **********************************************************************
rot_int_sondas:
	PUSH R0
	MOV  R0, 1						; assinala que houve uma interrupção 1
	MOV  [evento_int_sondas], R0   ; desbloqueia o processo "energia"
	POP  R0
	RFE

; **********************************************************************
; ROT_INT_ENERGIA -	 Rotina de atendimento da interrupção 2
;			Assinala o evento na componente 2 da variável evento_int
; **********************************************************************
rot_int_energia:
	PUSH R0
	MOV  R0, 1						; assinala que houve uma interrupção 2
	MOV  [evento_int_energia], R0   ; desbloqueia o processo "energia"
	POP  R0
	RFE

; **********************************************************************
; ROT_INT_NAVE -  Rotina de atendimento da interrupção 3
;			Assinala o evento na componente 3 da variável evento_int
; **********************************************************************
rot_int_nave:
	PUSH R0
	MOV  R0, 1					; assinala que houve uma interrupção 3
	MOV  [evento_int_nave], R0	; desbloqueia o processo "nave"
	POP  R0
	RFE