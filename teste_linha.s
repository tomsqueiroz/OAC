.include "../Resources/System_Rars/macros2.s"

.data
N: .word 6
C: .space 160 

.text
M_SetEcall(exceptionHandling)

li a0, 20
li a1, 120
li a2, 300
li a3, 120
li a4, 0xFF
li a5, 0
jal BRESENHAM

li a7,10
M_Ecall


	
.include "../Resources/System_Rars/SYSTEMv13.s"
	
