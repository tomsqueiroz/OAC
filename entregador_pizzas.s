.include "../Resources/System_Rars/macros2.s"



.data
N: .word 6
C: .space 160 

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
li a1,320		#upper bound da coordenada aleatoria X == 320
M_Ecall
mv t0,a0		#move-se o coordenada X para t0
li a1,240		#upper bound da coordenada aleatoria Y == 240
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
	
.include "../Resources/System_Rars/SYSTEMv13.s"
	
