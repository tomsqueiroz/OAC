.include "../Resources/System_Rars/macros2.s"



.data
N: .word 6
C: .space 160
D: .space 1600

.text
M_SetEcall(exceptionHandling)
jal LIMPA_TELA

la a0, N
lw a0, 0(a0)
la a1, C
jal SORTEIO

la a0, N
lw a0, 0(a0)
la a1, C
jal DESENHA

la a0, N
lw a0, 0(a0)
la a1, C
jal ROTAS

li	a0, 0
li	a1, 0
li	a2, 3
li	a3, 4
jal DISTANCIA

li a7,2
M_Ecall


li a7,10
M_Ecall


LIMPA_TELA:
	addi sp,sp,-4
	sw ra,0(sp)
	li t1,0xFF000000	# endereco inicial da Memoria VGA
	li t2,0xFF012C00	# endereco final 
	li t3,0xFFFFFFFF	# cor vermelho|vermelho|vermelhor|vermelho
LOOP_LIMPA_TELA:
 	beq t1,t2,FORA_LIMPA_TELA		# Se for o �ltimo endere�o ent�o sai do loop
	sw t3,0(t1)		# escreve a word na mem�ria VGA
	addi t1,t1,4		# soma 4 ao endere�o
	j LOOP_LIMPA_TELA	# volta a verificar
FORA_LIMPA_TELA:
	lw ra,0(sp)
	addi sp,sp,4
	ret
	



SORTEIO: #recebe em a0 o valor de N e em a1 o ponteiro para o vetor C
addi sp,sp, -4
sw ra,0(sp)
mv s0,a0
mv s1,a1
li t3, 0

LOOP_SORTEIO:
beq t3,s0, FIM_SORTEIO	#teste para ver se o contador ja chegou em N
li a7,42		#ecall para gerar numero aleatorio 
li a1,310		#upper bound da coordenada aleatoria X == 320
M_Ecall
mv t0,a0		#move-se o coordenada X para t0
li a1,230		#upper bound da coordenada aleatoria Y == 240
M_Ecall
mv t1,a0		#move-se coordenada Y para t1
sw t0,0(s1)
sw t1,4(s1)
addi s1,s1,8		#soma-se 8 ao endereço base de C
addi t3,t3,1
jal LOOP_SORTEIO


FIM_SORTEIO:
lw ra,0(sp)
addi sp,sp,4
ret

DESENHA:
addi sp,sp,-4		#libera espaço para guardar o ra
sw ra,0(sp)		#salva ra na pilha
mv s0,a0		
mv s1,a1
li t0,0			#contador
li a0,65		#valor inicial da ascii (A) que vai ser printado na tela

li a3,0x00003800	#cores do fundo e da frente no printchar	
li a4,0			#frame 0
li a7,111		#print char

LOOP_DESENHA: 
beq t0,s0, FIM_DESENHA
lw a1, 0(s1)
lw a2, 4(s1)
M_Ecall
addi a0,a0,1		#atualiza char a ser printado
addi s1,s1,8		#pula duas words, ou seja X e Y
addi t0,t0,1		#atualiza contador
jal LOOP_DESENHA


FIM_DESENHA:
lw ra,0(sp)
addi sp,sp,4
ret


ROTAS:
addi sp,sp,-4	#libera espaço na pilha pra salvar o ra
sw ra,0(sp)	#salva o valor de ra
mv t0, a0	#move para t0 o valor de N
mv t1, a1	#move para t1 o valor do ponteiro c
li s0, 0	#contador para andar no vetor C
ROTAS_GRANDE:
beq s0,t0, FIM_ROTAS_GRANDE #laço grande que percorre todo o vetor
slli t2, s0, 3	#8 vezes o valor do contador, ou seja 2 words
add t3, t1, t2	#t3 é o endereço do N-ésimo ponto do vetor C
lw a0, 0(t3)	#coordenada X do N-ésimo ponto
lw a1, 4(t3)	#coordenada Y do N-ésimo ponto
mv t4,s0        #contador para o laço pequeno
addi t4,t4,1	#começa a partir da próxima entrada do vetor
ROTAS_PEQUENO:
beq t4, t0, FIM_ROTAS_PEQUENO	#laço responsável por inflar os valores de a2 e a3 a passar para o procedimento BRESENHAM]
slli	t5, t4, 3	#endereco do N-ésimo ponto do vetor
add	t6, t1, t5
lw a2, 0(t6)	#coordenada X
lw a3, 4(t6)	#coordenada Y
li a4, 0X00	#cor da rota, no caso preto
li a5, 0	#frame

# salvar t0, t1, t4, a0, a1, s0 -> 6 words: 24 bytes
addi sp, sp, -24
sw	t0, 20(sp)
sw	t1, 16(sp)
sw	t4, 12(sp)
sw	a0, 8(sp)
sw	a1, 4(sp)
sw	s0, 0(sp)
#####################

jal BRESENHAM

# recuperar t0, t1, t4, a0, a1, s0 -> 6 words: 24 bytes
lw	s0, 0(sp)
lw	a1, 4(sp)
lw	a0, 8(sp)
lw	t4, 12(sp)
lw	t1, 16(sp)
lw	t0, 20(sp)
addi sp,sp, 24
#####################

addi t4,t4,1	#atualizar contador pequeno
j ROTAS_PEQUENO
FIM_ROTAS_PEQUENO:
addi s0,s0,1    #atualizar contador grande
j ROTAS_GRANDE
FIM_ROTAS_GRANDE:
lw ra, 0(sp)	#recupera o valor de ra
addi sp,sp,4	#atualiza contador da pilha
ret


DISTANCIA:	#procedimento que recebe dois pontos (ao,a1) (a2,a3) e retorna em fa0 a distancia entre eles
sub t0, a0, a2	#distancia em coordenada X
sub t1, a1, a3	#distancia em coordenada Y
mul t0,t0,t0	#eleva-se t0²
mul t1,t1,t1	#eleva-se t1²
add t2, t0, t1	#soma-se as distancias
fcvt.s.w fa0, t2 #converte-se o valor para float
fsqrt.s fa0,fa0	
ret














	
.include "../Resources/System_Rars/SYSTEMv13.s"
	
