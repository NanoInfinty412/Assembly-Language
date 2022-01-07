#factorial
.data 
#Define variables
size: .word 13
factorial: .word 1
array: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
results: .space 42
.text 
.globl main
#Initialize offset to be used 
initialize:
li $t0,0
li $t6,0
main: #Intialize registers to be used
lw $s0, size
blez $s0,exit #If <= 0, exit!
li $t1, 1
li $t5,1
lw $t2, array($t0) #Load with iterration
addi $t0,$t0,4 #Go to next element in array
li $t6,0
loop:
li $t6,0
ble $t2,$t1, done # if t2 == 1 we are done
subi $t3,$t2,1 #i-1
mul $t4,$t3,$t2 #f(i) = i*(i-1)
mul $t5,$t5,$t4 #f(i-1)*f(i)
subi $t2,$t2,2 # Get i-2 for next multiplication
j loop #Loop back if not done
li $t6,0
done:
li $t6,0
sw $t5,results($t0) #Save with iteration
lw $t7, size 
subi $t7,$t7,1
sw $t7,size
j main # Loop backif not done 
li $t6,0
exit: #End of code 
li $t6,0
li, $v0,10
syscall