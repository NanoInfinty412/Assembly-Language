.data # data section
# Reserve 400 bytes for the 10x10 matrix/array 
matrix2d: .space 400
#define row and columns 
r: .word 10
c: .word 10
.text
.globl main
main: #Intialize registers to be used
li $t1, 0 # t0 is a constant 10
li $t5,0
li $t6,0
li $t0,4 # Necessary for iteration/4 bytes 
lw $t2, c # t2 and t3 is our limiter for loops (i)
lw $t3, r
la $t4, matrix2d #Loads starting address of the matrix 
loop1:
# First outer Loop /checker
beq $t1, $t3, exit # if t2 == 0 we are done
#First inner loop 
loop1_a:
li $t6,0
beq $t5, $t2, exit_loop1a # if t2 == 0 we are done
lw $t7,r 
mul $t6,$t1,$t7 
add $t6,$t6, $t5 # Add mem offset after every iteration
mul $t6, $t6,$t0 #Multiply b
mul $t7,$t5,$t1 # i*j into t7
sw $t7,matrix2d($t6) #Stores t7 at effective address matrix2d+t6
addi $t5,$t5,1 #Iteration j+1
j loop1_a
#Transition macro before going back to outer loop 
exit_loop1a:
li $t6,0 #Renitialize $t6 to restart the count
li $t5,0
addi $t1,$t1,1 #Iteration i+1
j loop1
exit: #End of code 
lw $t3,r 
li, $v0,10
syscall
