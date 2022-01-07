#Fibonacci
#Define variables
.data 
n: .word 40
fibonacci: .space 200
.text 
.globl main
main: #Intialize registers to be used
li $t0,0
li $t1,1
li $t2, 0
lw $t3, n
li $t4,0
li $t6,0 #Store 0 as first element 
sw $t0, fibonacci($t4)
addi $t4,$t4,4
sw $t1, fibonacci($t4) #Store 1 as second element 
addi $t4,$t4,4 #Next element
loop:
li $t6,0
beq $t2,$t3, done # if t2 == t1 we are done
sw $t1,fibonacci($t4) #Store t1 as next element
addi $t4,$t4,4
subi $t5,$t4,8 #Get fibonacci[i-2] 
lw $t7,fibonacci($t5) 
add $t1,$t7,$t1 #Solve for fibonacci[i-1] + fibonacci[i-2] 
addi $t2,$t2,1
j loop
li $t6,0
done:
li $t6,0
# w $t5,factorial
li $t6,0
exit: #End of code 
li $t6,0
li, $v0,10
syscall
