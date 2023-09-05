#===========================================================================
#     Diamond Search
#
# Author: Alexander Snapp
# Date: 10/6/22
#
# This program finds the shortest path out of a diamond of weighted squares.
#
#===========================================================================
# CHANGE LOG:
# Date  Modification
# 10/6  Designed edge cases to attempt to catch straight line paths to use in comparison
# 10/7  Updated and attempted to debug loop which wasn't allowing dual movements per iteration,
#       eventually I settled on temporarily removing it and addressing single edge cases and
#       creating a way to compare minimum found values by continuously updating it.
# 10/15 Remade my edge cases to work with jal instructions to reduce static instruction count.
# 10/20 Made a function to work through a 'staircase' pattern from side-to-side in each quadrant and
#       find the minimum value to get to an edge. Then compared edges to find the smallest value.
# 10/21 Finished the code and made some comparisons more efficient by removing lines that were 
#       not needed. Proceeded to move on with minor efficiency improvements and testing various
#       cases using Misasim.
#===========================================================================

.data
Array:	.alloc	121			# allocate static space for padded weight map

.text
PathOut:   addi $1, $0, Array		# set memory base
           swi 514			# create weight map in memory

# Beginning of search algorithm

           add $30, $31, $0
           addiu $4, $0, 0xFFFF 		# Sets $4 to the largest possible number (will hold smallest path value)
           addi $2, $0, 236		# Resets $2 to it's start value at 59
           addi $3, $0, 4			# Resets $3 to the value 4
           addi $6, $0, -4		# Sets register 6 initially to -4 (used to find left path)
           jal Straight			# Calls function to find left path

           addi $2, $0, 196		# Resets $2 to it's start value at 49
           addi $3, $0, 4			# Resets $3 to the value 4
           addi $6, $0, -44		# Sets $6 to -44 (used to find upper path)
           jal Straight			# Calls function to find value of path moving up
           
           addi $2, $0, 244		# Resets $2 to it's start value at 61
           addi $3, $0, 4			# Resets $3 to the value 4
           addi $6, $0, 4			# Sets $6 to 4 (used to find right path)
           jal Straight			# Calls function to find value of path moving right

           addi $2, $0, 284		# Resets $2 to it's start value at 71
           addi $3, $0, 4			# Resets $3 to the value 4
           addi $6, $0, 44		# Sets $6 to 44 (used to find lower path)
           jal Straight			# Calls function to find value of path moving down
           
           addi $2, $0, 196		# Sets starting point for left upper quadrant at 1 up from start
           addi $6, $0, 40		# Sets $6 to 40 so that it iterates left one and down one
           addi $9, $0, -4		# Sets $9 to -4 to iterate left.
           addi $12, $0, -44		# Sets $12 to -44 to make it increment up 1 index
           addi $11, $0, 4		# Sets $11 initially to 4
           jal First			# Calls function to find lowest cost value in top left quadrant

           addi $2, $0, 284		# Sets starting point for left lower quadrant at 1 down from start
           addi $6, $0, -48		# Sets $6 to -48 so that it iterates up one and left one
           addi $12, $0, 44		# Sets $12 to 44 to make it increment up 1 index
           addi $11, $0, 4		# Sets $11 initially to 4
           jal First			# Calls function to find lowest cost value in lower left quadrant

           addi $2, $0, 284		# Sets starting point for right lower quadrant at 1 down from start
           addi $6, $0, -40		# Sets $6 to -40 so that it iterates right one and up one
           addi $9, $0, 4			# Sets $9 to 4 to iterate right
           addi $11, $0, 4		# Sets $11 initially to 4
           jal First			# Calls function to find lowest cost value in lower right quadrant

           addi $2, $0, 196		# Sets starting point for right upper quadrant at 1 up from the start
           addi $6, $0, 48		# Sets $6 to 48 so that it iterates left one and down one
           addi $12, $0, -44		# Sets $12 to -44 to make it increment up 1 index
           addi $11, $0, 4		# Sets $11 initially to 4
           jal First			# Calls function to find lowest cost value in upper left quadrant

           j end

Straight:  lw $7, Array($2)		# Finds the value from the current node in the graph
           add $2, $2, $6			# Increments $2
           lw $8, Array($2)		# Finds the value of the new node
           add $7, $7, $8			# Adds the values of the new node with the previous node.
           sw $7, Array($2)		# Updates the new node to the lowest path cost
           addi $3, $3, -1		# Decrements $3 (the counter for the loop)
           bne $3, $0, Straight		# Continues the loop if it has not run 5 times

           slt $3, $7, $4			# Check if value on the edge is less than the current min value ($2 < $4)
           beq $3, $0, NoUpdate		# Skip the update if $3 != 1
           addi $4, $7, 0			# Update $4 to new lowest cost path value

NoUpdate:  jr $31

First:    addi $13, $2, 0		  	# Sets $13 to initial value of $2
          addi $3, $11, 0 		# Sets value of $3 to recently decremented $11
Stair:    add $7, $2, $6			# Sets $7 to the index to the side and then the inside of $2
          lw $7, Array($7)		# Sets $7 to value of weight of its index
          lw $8, Array($2)		# Sets $8 to value of weight on indexes other side
          add $2, $2, $9			# Increments $2 to the side.
          lw $14, Array($2)		# Finds weight at new value of $2
          slt $10, $7, $8			# Sets $10 to if ($7 < $8)
          add $8, $14, $8                 # Adds value of node with that of node of $7
          beq $10, $0, Continue		# Checks if $10 = 0

Less:     add $8, $7, $14			# Adds value of node with that of node of $7

Continue: sw $8, Array($2)		# Store update value from $8 into the node
          addi $3, $3, -1			# decrement $3
          bne $3, $0, Stair		# Continue loop if $3 not equal to 0
          lw $14, Array($2)		# Update the value of $14 as the new value at the edge
          slt $10, $14, $4		# Check if value on the edge is less than current min value ($2 < $4)
          beq $10, $0, Next		# If $10 is equal to 0, move on
          add $4, $14, $0			# Set $4's new value to $2 if it is new lowest cost path

Next:     addi $11, $11, -1		# Decrements $11
          add $2, $13, $12		# Resets $2 to next level to be iterated over
          bne $11, $0, First		# Continues the outermost loop

          jr $31

end:      add $31, $0, $30		# Reset $31 to it's initial value to return to caller
          swi 591             		# report the answer
          jr $31				# return to caller
