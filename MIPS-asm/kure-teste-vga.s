### Mostra pixels na tela
### 
### A partir do endereço 4 x 0x1000 = 0x4000
        .data
### Color format ...0000.BBGG.GRRR
RED:    .word   0x00000007
BLUE:   .word   0x000000C0

RECT_MSG:	.ascii	"0123456789012345"
RECT_MSG2:	.asciiz	"=-.\.;kure gato "
	
        .text
# a partir do endereço 0x0000
#la $t0,STR

        li      $a0, 0
        li      $a1, 0
        li      $a2, 320
        li      $a3, 240
        lw      $v0, BLUE
        jal     kure_print_rect
	
        li      $a0, 0
        li      $a1, 0
        li      $a2, 5
        li      $a3, 5
        lw      $v0, RED
        jal     kure_print_rect

        li      $a0, 10
        li      $a1, 10
        li      $a2, 2
	li	$a3, 5
	lw	$v0, RED
        jal     kure_print_rect

	la	$a0, RECT_MSG
	jal	print_lcd
	
        li      $v0, 10         # exit
        syscall

### Prints a pixel on the screen
### $a0 x position
### $a1 y position
### $a2 color (format BBGG.GRRR.bbgg.grrr)
###
### Internal use:
### $t0 VGA starting memory address
### $t1 temporary
### $t2 temporary
print_pixel:
        addi    $sp, $sp, -12
        sw      $t0, 0($sp)
        sw      $t1, 4($sp)
        sw      $t2, 8($sp)     
        
        lui     $t0, 0x8000     # VGA memory starting address
        
        ## The VGA address (on which we store the pixel) has
        ## the following format:
        ##                           0x80YYYXXX
        ##                           
        ## Where YYY are the 3 bytes representing the Y offset
        ##       XXX are the 3 bytes representing the X offset
        ##       
        ## So we need to shift Y left 3 bytes (12 bits)

        add     $t1, $t0, $a0   # store X offset on address
        sll     $t2, $a1, 12    # send Y offset to the left
        add     $t1, $t1, $t2   # store Y offset on the address
        sw      $a2, 0($t1)     # Actually print the pixel

        lw      $t0, 0($sp)
        lw      $t1, 4($sp)
        lw      $t2, 8($sp)
        addi    $sp, $sp, 12    
        jr      $ra             # GTFO

### Prints a rectangle on the screen.
### 
### Arguments (preserved between uses):
### $a0 x position
### $a1 y position
### $a2 width
### $a3 height
### $v0 color (format BBGG.GRRR.bbgg.grrr)
###
### Returns (modified inside):
### nothing
### 
### Internal use (modified inside):
### $t0 counter x (i)
### $t1 counter y (j)
### $t2 original x ($a0)
### $t3 original y ($a1)
### $t4 original w ($a2)
### $t5 original h ($a3)
### $t6 temporary
### 
kure_print_rect:
        addi    $sp, $sp, -20
        sw      $ra, 0($sp)
        sw      $a0, 4($sp)
        sw      $a1, 8($sp)
        sw      $a2, 12($sp)
        sw      $a3, 16($sp)            
        
kure_print_rect_start:
        add     $t0, $zero, $zero # i = 0
        add     $t1, $zero, $zero # j = 0
        add     $t2, $zero, $a0   # saving original X
        add     $t3, $zero, $a1   # saving original Y
        add     $t4, $zero, $a2   # saving original W
        add     $t5, $zero, $a3   # saving original H
        
kure_print_rect_loop1:
        slt     $t6, $t1, $t5                     # if (j >= h)
        beq     $t6, $zero, kure_print_rect_exit  # then.. quit!

        add     $t0, $zero, $t2 # reset i to original x
                
kure_print_rect_loop2:
        slt     $t6, $t0, $t4                        # if (x >= w)
        beq     $t6, $zero, kure_print_rect_loop_end # then.. next line!

                                # print pixels on:  
        add     $a0, $t0, $t2   # i + x
        add     $a1, $t1, $t3   # j + y
        add     $a2, $zero, $v0 # original color
        jal     print_pixel

        addi    $t0, $t0, 1     # i++
        j       kure_print_rect_loop2
        
kure_print_rect_loop_end:
        addi    $t1, $t1, 1     # j++
        j       kure_print_rect_loop1
        
kure_print_rect_exit:
        lw      $ra, 0($sp)
        lw      $a0, 4($sp)
        lw      $a1, 8($sp)
        lw      $a2, 12($sp)
        lw      $a3, 16($sp)            
        addi    $sp, $sp, 20
        
        jr      $ra             # GTFO
        
### Prints a rectangle on the screen
### $a0 x position
### $a1 y position
### $a2 width
### $a3 height
### $v0 color (format BBGG.GRRR.bbgg.grrr)
###
### Internal use:
### $t0 counter
### $t1 current x
### $t2 x resolution
### $t3 current y
### $t4 (x + w)
### $t5 (y + h)
### $t6 temporary
print_rect:
        addi    $sp, $sp, -20
        sw      $ra, 0($sp)
        sw      $a0, 4($sp)
        sw      $a1, 8($sp)
        sw      $a2, 12($sp)
        sw      $a3, 16($sp)            

        add     $t4, $a0, $a2   # x_limit = (x + w)
        add     $t5, $a1, $a3   # y_limit = (y + h)
        
print_rect_start:
        lw      $t1, ($a0)      # int x = x_from_arg
        lw      $t3, ($a1)      # int y = y_from_arg
        
print_rect_loop1:
        slt     $t6, $t3, $t5                # if (y >= h)
        beq     $t6, $zero, print_rect_exit  # then.. quit!

        lw      $t1, ($a0)      # reset x to x_from_arg
                
print_rect_loop2:
        slt     $t6, $t1, $t4                   # if (x >= w)
        beq     $t6, $zero, print_rect_loop_end # then.. next line!

        add     $a0, $zero, $t1
        add     $a1, $zero, $t3
        add     $a2, $zero, $v0
        jal     print_pixel

        addi    $t1, $t1, 1     # x++
        j       print_rect_loop2
        
print_rect_loop_end:
        addi    $t3, $t3, 1     # y++
        j       print_rect_loop1
        
print_rect_exit:
        lw      $ra, 0($sp)
        lw      $a0, 4($sp)
        lw      $a1, 8($sp)
        lw      $a2, 12($sp)
        lw      $a3, 16($sp)            
        addi    $sp, $sp, 20
        
        jr      $ra             # GTFO
        
### Shows a beautiful demo of the VGA screen.
### (by Lamar)
### 
### Internal use:
### $t0 counter
### $t1 current x
### $t2 x resolution
### $t3 current y
### $t4 y resolution
### $t5 VGA starting memory address
### $t6 VGA current address
vga_demo:       
        li      $t0, 0          # int i = 0
        lui     $t5, 0x8000     # VGA memory starting address
        li      $t2, 320        # x resolution
        li      $t4, 240        # y resolution

vga_demo_start:
        li      $t1, 0          # x = 0
        li      $t3, 0          # y = 0
        
vga_demo_loop1:
        beq     $t3, $t4, vga_demo_end1 # if finished columns...
        li      $t1, 0                     # x = 0
                
vga_demo_loop2:
        ## The VGA address (on which we store the pixel) has
        ## the following format:
        ##                           0x80YYYXXX
        ##                           
        ## Where YYY are the 3 bytes representing the Y offset
        ##       XXX are the 3 bytes representing the X offset
        ##       
        ## So we need to shift Y left 3 bytes (12 bits)
        beq     $t1, $t2, vga_demo_loop_end 
        add     $t6, $t5, $t1   # store X offset on address
        sll     $s2, $t3, 12    # send Y offset to the left
        add     $t6, $t6, $s2   # store Y offset on the address
        sw      $t0, 0($t6)     # Actually store the value
        addi    $t1, $t1, 1     # x++
        j       vga_demo_loop2
        
vga_demo_loop_end:
        addi    $t3, $t3, 1     # y++
        j       vga_demo_loop1
        
vga_demo_end1:  
        addi    $t0, $t0, 1     # i++
        j       vga_demo_start

vga_demo_exit:
        jr      $ra             # GTFO


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
	
	