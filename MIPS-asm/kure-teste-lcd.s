### Complete test of the MIPS ISA according to our implementation
### 
### Alexandre Dantas
### Ciro Viana
### Matheus Pimenta
###
### Will store on $v0 the current test index, so we can see which one failed.
	
### Data segment ###############################################################
	.data
ERROR_MSG:	.ascii	"Erro: algo estr"
ERROR_MSG2:	.asciiz	"anho aconteceu!"

SUCCESS_MSG:	.ascii	"Sucesso!       "
SUCCESS_MSG2:	.asciiz	" tudo deu certo"
	
FLOAT_A:	.float	1.5
FLOAT_B:	.float	2.5

### Text segment ###############################################################
 	.text
	
### Prints two lines on the LCD
### $a0	Address of the first line of the message
### 
### NOTE: The two lines MUST be contiguous on .data!
###
### Internal use:
### $t0	.data offset (starting point of the string)
### $t1	LCD upper address
### $t2 LCD current printing address
### $t3 Loop counter
### $t4 .data pointer
### $t5 Loop limiter
### 
print_lcd:
	addu	$t0, $zero, $a0		# Copying message address to .data offset	
	lui	$t1, 0x7000		# LCD address
	
	sw	$zero, 0x20($t1)	# Clears LCD's value

	move	$t3, $zero		# int i = 0;
	li	$t5, 8
	

	## Inside this loop we print 4 bytes.
	## The loop will repeat 8 times.
print_lcd_loop:
	beq	$t3, $t5, print_lcd_end 

	lw	$t4, 0($t0) 		# add offset value to pointer

	##  These 3 instructions print a byte.
	##  We repeat them 4 times.
	sw	$t4, 0($t1)	# Print byte
	addi	$t1, $t1, 1
	srl	$t4, $t4, 8

	sw	$t4, 0($t1)	# Print byte
	addi	$t1, $t1, 1
	srl	$t4, $t4, 8

	sw	$t4, 0($t1)	# Print byte
	addi	$t1, $t1, 1
	srl	$t4, $t4, 8
	
	sw	$t4, 0($t1)	# Print byte
	addi	$t1, $t1, 1
	
	addi	$t0, $t0, 4	# Increase offset value
	addi	$t3, $t3, 1	# Increase counter
	
	j print_lcd_loop

print_lcd_end:
	jr	$ra		# Thanks for your time!
	


	