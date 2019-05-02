.include "../Resources/System_Rars/macros2.s"



.data
N: .word 3
C: .word 10,10,10,20,10,30

.text
M_SetEcall(exceptionHandling)
la t0,N
lw a0, 0(t0)
la a1,C
jal DESENHA
li a7,10
M_Ecall



DESENHA:
addi sp,sp,-4
sw ra,0(sp)
mv s0,a0
mv s1,a1
li t0,0
li a0,65

li a3,0x0000FF00
li a4,0
li a7,111

LOOP_DESENHA: 
beq t0,s0, FIM_DESENHA
lw a1, 0(s1)
lw a2, 4(s1)
M_Ecall
addi a0,a0,1
addi s1,s1,8
addi t0,t0,1
jal LOOP_DESENHA


FIM_DESENHA:
lw ra,0(sp)
addi sp,sp,4
ret


#  PrintChar    ecall 111                               #
#  a0 = char(ASCII)                                     #
#  a1 = x                                               #
#  a2 = y                                               #
#  a3 = cores (0x0000bbff) 	b = fundo, f = frente	#
#  a4 = frame (0 ou 1)	

.include "../Resources/System_Rars/SYSTEMv13.s"