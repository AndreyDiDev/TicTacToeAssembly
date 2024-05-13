line:		.string	"------\n"
x:		.string "x"
o:		.string	"o"
wall:		.string "|"
empty:		.string " "
newLine:	.string	"\n"
debug:		.string	"(%d , %d)"
differentR:	.string	"diffR: %d"
differentC:	.string	"diffC:	%d"



.bss
.global map					// needed to have it global since it got deleted with every function 					// zero initialized
map:		.skip	3 * 3 * 4		// row * col * size of ints

.data
counter:	.int

diffR:		.int
diffC:		.int

lastR:		.int
lastC:		.int

minC:		.int

.text

dim1 = 2
dim2 = 3
map_size = dim1* dim2 * 4
alloc_SetX = -(16 + 36) & -16
dealloc_SetX = -alloc_SetX
map_s = 16

.balign 4
.global setRow
.global setCol
.global printBoard
.global setX
.global initializeBoard
.global setO
.global checkWin


rowR		.req	w26
colR		.req	w27
counterR	.req	w19
counterC	.req	w20
map_base_r	.req	x21
offset_r	.req	w22

newR		.req	w9
newC		.req	w10

signR		.req	w11
signC		.req	w12

floorR		.req	w13
floorC		.req	w14

.global mainA


mainA:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	bl	printBoard



	ldp	x29, x30, [sp], 16
	ret

checkWin:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	mov	w19, 0
	mov	w20, 0
	mov	w25, 0

stop:
	mov	w8, w0				// take passed parameter, 1 = x, 2 = 0

//	mov	w22, w8

	sub	newR, rowR, 1			// newRow = row - 1

//---------------------------------------------while loop to determine row ceiling
	bl	ceilingRowTest
ceilingRowTop:
	add	newR, newR, 1			// add to newRow since its out of bounds

ceilingRowTest:
	cmp	newR, 0				// check if ceiling row is in bounds
	b.lt	ceilingRowTop			// branch if it is

//	mov	w23, newR
//----------------------------------------------
	add	floorR,rowR, 1			// initialize floorR to row + 1

//---------------------------------------------while loop to determine row floor
	bl	floorRowTest

floorRowTop:
	sub	floorR, floorR, 1

floorRowTest:
	cmp	floorR, 2
	b.gt	floorRowTop
//---------------------------------------------

//	mov	w24, floorR
//----------------------------------------------while newR <= floorR, from ceiling to floor
	 bl	mainRowTest

mainRowTop:
	sub	newC, colR, 1			// initialize newC = colR - 1

	//1-------------------------------------while loop to determine ceiling col
	bl	ceilingColTest			// branch to ceiling Col Test

ceilingColTop:
	add	newC, newC, 1			// reset boundary to 0

ceilingColTest:
	cmp	newC, 0				// col has to be >= 0
	b.lt	ceilingColTop

//	mov	w25, newC

//	adrp	x1, minC
//	add	x1, x1, :lo12:minC

//	str	newC, [x1]
	//1--------------------------------------
	// newC = ceilingCol


	//2-------------------------------------while to determine floor column
	add	floorC, colR, 1			// initialize floorCol = colR + 1

	bl	floorColTest

floorColTop:
	sub	floorC, floorC, 1		// floorR is out of bounds so reset to 2

floorColTest:
        cmp     floorC, 2
        b.gt    floorColTop

	//2------------------------------------
//	mov	w19, floorC

	//3------------------------------------mainRowLoop that iterates through cols
	bl	mainColTest

mainColTop:
	//map[newR][newR]-----------------------
	adrp	map_base_r, map
	add	map_base_r, map_base_r, :lo12:map

	mov	w23, dim2

	mul	offset_r, newR, w23
	add	offset_r, offset_r, newC

//	lsl	offset_r, offset_r, 2

//	add	map_base_r, map_base_r, offset_r
//	smov	w25, offset_r
	ldr	w23, [map_base_r, offset_r, SXTW 2]// loads value of index in w23
	//end of map index---------------------- w23 = map[newR][newC]

	cmp	w23, w8				// map index == XorO
	b.eq	foundOne			// branch to deal with finding one

	bl	skipLinearization			// if not found one then skip square and pattern(if it was (-1, -1) then the algorithm would've ran again for (foundOneRow - 1, foundOneCol - 1)

foundOne:

	// counter ++-------------------------- might not need counter
//	adrp	x19, counter
//	add	x19, x19, :lo12:counter

//	ldr	w2, [x19]			// load old counter
	add	w25, w25, 1			// increment counter++

//	str	w2, [x19]			// store incremented counter into x1 which holds address of counter
	// counter++ end-----------------------

	// check-------------------------------
	cmp	newC, colR			// check if they poiting at original x
	b.eq	continueToRowTest

	bl	else

continueToRowTest:
	cmp	newR, rowR			// check if poiting at original x
	b.eq	checkIfFirstIsOriginal

	bl	else

checkIfFirstIsOriginal:
//	cmp	w25, 1
//	b.eq	skipLinearization

	bl	skipLinearization
	// check end---------------------------
else:						// if they correspond and not original x then extrapolate pattern to one more square to see if there is a match
	// pattern extrapolation---------------


		// diffRow---------------------
	cmp	newR, rowR
	b.lt	subRow

	bl	addRow

subRow:
	sub	w19, newR, rowR			// x19 = newR - rowR
	bl	restRow

addRow:
	sub	w19, rowR, newR			// x19 = rowR - newR

restRow:
//	adrp	x21, diffR
//	add	x21, x21, :lo12:diffR

//	str	w19, [x21]
		// diffRow end-----------------
//	mov	w22, w9
//	mov	w23, newR
//	mov	w24, w13
//	mov	w25, w14

//	adrp	x1, differentR
//	add	x1, x1, :lo12:differentR
//	ldr	x1, =differentR
//	mov	w2, w19

//	bl	printf

		// diffCol -------------------

	cmp	newC, colR
	b.lt	subCol

	bl	addCol

subCol:
	sub	w20, newC, colR
	bl	restCol

addCol:
	sub	w20, colR, newC

restCol:
//	adrp	x1, diffC
//	add	x1, x1, :lo12:diffC

//	str	w20, [x1]
		// diffCol end------------------

		// lastR -----------------------
//	adrp	x1, diffR
//	add	x1, x1, :lo12:diffR

//	ldr	w19, [x1]			// load contents of address diffR into x19
lastRLabel:
	add	w19, w19, newR			// lastR = newR +- diffR

//	adrp	x1, lastR
//	add	1, x1, :lo12:lastR		// load lastR address

//	str	x19, [x1]			// store result into address of lastR

	cmp	w19, -1				// check boundary and wrap around if necessary
	b.eq	wrapAroundRow

	cmp	w19, 3
	b.eq	wrapAroundRow2

	bl	endWrapRow
wrapAroundRow:
	mov	w19, 2				// if lastR is -1 then it wraps around to 2
	bl	endWrapRow

wrapAroundRow2:
	mov	w19, 0

endWrapRow:
//	adrp	x1, lastR
//	add	x1, x1, :lo12:lastR

//	str	w19, [x1]			// store result into address lastR


		// lastR end--------------------


		// lastC -----------------------

//	adrp	x1, diffC
//	add	x1, x1, :lo12:diffC

//	ldr	w19, [x1]

	add	w20, w20, newC			// extrapolate pattern = lastC = diffC +- newC

	cmp	w20, -1
	b.eq	wrapAroundCol

	cmp	w20, 3
	b.eq	wrapAroundCol2

	bl	endWrapAroundCol

wrapAroundCol:
	mov	w20, 2
	bl	endWrapAroundCol

wrapAroundCol2:
	mov	w20, 0

endWrapAroundCol:
//	adrp	x1, lastC
//	add	x1, x1, :lo12:lastC

//	str	w19, [x1]
		// lastC end--------------------

		// if condition to check if it is a winning pattern
//	adrp	x2, lastR
//	add	x2, x2, :lo12:lastR

//	ldr	w20, [x2]

		// map index--------------------
	adrp	map_base_r, map
	add	map_base_r, map_base_r, :lo12:map

	mov	w23, dim2

	mul	offset_r, w19, w23		// where w20 is the lastR
	add	offset_r, offset_r, w20		// where w19 is the lastC

//	lsl	offset_r, offset_r, 2

//	add	map_base_r, map_base_r, offset_r

	ldr	w23, [map_base_r, offset_r, SXTW 2]	// w23 holds value of map[lastR][lastC]
		// map index end----------------

	cmp	w23, w8				// if they the same sign its winning pattern
	b.eq	win


skipLinearization:
	add	newC, newC, 1			// increment newC

mainColTest:

//	adrp	x0, debug
//	add	x0, x0, :lo12:debug

//	mov	w1, newR
//	mov	w2, newC

//	bl	printf

	cmp	newC, floorC			// newC <= floorC to iterate through all cols
	b.le	mainColTop

//---------------------------------------------
//	adrp	x1, minC
//	add	x1, x1, :lo12:minC

//	ldr	newC,

	add	newR, newR, 1

	bl	mainRowTest



//	add	newR, newR, 1			// increment newR for new loop iteration

mainRowTest:
	cmp	newR, floorR			// check if within bounds
	b.le	mainRowTop			// branch to mainRowTop

	mov	w0, 0
	bl	endOfCheck			// has ran through all neighbours of placed sign and no winning pattern found

//----------------------------------------------end of mainRow loop
win:	mov	w0, 1


endOfCheck:
	ldp	x29, x30, [sp], 16
	ret




setRow:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	mov	rowR, w0
	sub	rowR, rowR, 1

	ldp	x29, x30, [sp], 16
	ret

setCol:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	mov	colR, w0
	sub	colR, colR, 1

	ldp	x29, x30, [sp], 16
	ret

setX:
	stp	x29, x30, [sp, alloc_SetX]!
	mov	x29, sp
					// offset row * 3 + 3

	adrp	map_base_r, map
	add	map_base_r, map_base_r, :lo12:map

	mov	w23, dim2

	mul	offset_r, rowR, w23

	add	offset_r, offset_r, colR


//	lsl	offset_r, offset_r, 2

//	add	map_base_r, map_base_r, offset_r

	mov	w25, 1
	str	w25, [map_base_r, offset_r, SXTW 2]		// map[row][col] = 1

	ldp	x29, x30, [sp], dealloc_SetX
	ret

setO:
	stp	x29, x30, [sp, alloc_SetX]!
	mov	x29, sp

	adrp	map_base_r, map
	add	map_base_r, map_base_r, :lo12:map

	mov	w23, dim2

	mul	offset_r, rowR, w23

	add	offset_r, offset_r, colR
//	lsl	offset_r, offset_r, 2

	mov	w25, 2

//	add	map_base_r, map_base_r, offset_r
	str	w25, [map_base_r, offset_r, SXTW 2]		// map[row][col] = 2

	ldp	x29, x30, [sp], dealloc_SetX
	ret


initializeBoard:
	stp 	x29, x30, [sp, -16]!
	mov	x29, sp


	mov	rowR, 0						// initialize row count to 0
	mov	colR, 0						// initialize column count to 0

	bl	testRow

topRow:
//-------------------------------------------------------------- code for map ldr and str
	bl	testCol

topCol:

	adrp	map_base_r, map
	add	map_base_r, map_base_r, :lo12:map

	mov	w23, dim2
//	mov	offset_r, 0

	mul	offset_r, rowR, w23				// offset = row * dim2
	add	offset_r, offset_r, colR			// offset = (row * dim2) + col
//	lsl	offset_r, offset_r, 2				// offset = (row * dim2 + col) * 4

//	add	map_base_r, map_base_r, offset_r

	mov	w25, 0						// move 0 into w25
	str	w25, [map_base_r, offset_r, SXTW 2]		// map[row][col] = 0
//--------------------------------------------------------------

	add	colR, colR, 1					// increment col count

testCol:
	cmp	colR, dim2
	b.le	topCol

	mov	colR, 0						// reset col count after every row

	add	rowR, rowR, 1					// increment row count

testRow:
	cmp	rowR, dim1
	b.le	topRow

	mov	rowR, 0
	mov	colR, 0


	ldp	x29, x30, [sp], 16
	ret

checkSpace:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

//map[counterR][counterC]---------------------------
	// take row, col
	adrp	map_base_r, map
	add	map_base_r, map_base_r, :lo12:map

	mov	w23, dim2

	mul	offset_r, counterR, w23
	add	offset_r, offset_r, counterC

//	lsl	offset_r, offset_r, 2

//	add	map_base_r, map_base_r, offset_r

	ldr	w23, [map_base_r, offset_r, SXTW 2]
//map index end------------------------------------

	cmp	w23, 1
	b.eq	xSpace

	cmp	w23, 2
	b.eq	oSpace

	bl	emptySpace

emptySpace:
	adrp	x25, empty
	add	x25, x25, :lo12:empty

	bl	end

xSpace:
	adrp	x25, x
	add	x25, x25, :lo12:x

	bl	end

oSpace:
	adrp	x25, o
	add	x25, x25, :lo12:o

end:
	ldp	x29, x30, [sp], 16
	ret


printBoard:
	stp	x29, x30, [sp, -32]!
	mov	x29, sp

	mov	counterR, 0

	bl	test1
						// loop for rows
top1:
	ldr	x0, =line		// line
	bl	printf

	mov	counterC, 0

	bl	test2

top2:

	ldr	x0, =wall
	bl	printf

//	mov	rowR, counterR
//	mov	colR, counterC

	bl	checkSpace
	mov	x0, x25
	cmp	rowR, 1
	b.ne	skip2

	cmp	colR, 3
	b.ne	skip2

	adrp	x0, empty
	add	x0, x0, :lo12:empty

skip2:
	bl	printf

	add	counterC, counterC, 1

test2:
	cmp	counterC, 2
	b.le	top2

	ldr	x0, =newLine
	bl	printf

	add	counterR, counterR, 1
test1:
	cmp	counterR, 3
	b.lt	top1

	ldr	x0, =line
	bl	printf


	ldp	x29, x30, [sp], 32
	ret

