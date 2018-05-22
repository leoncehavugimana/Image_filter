# An image processing program.
# This program blurs an eight-bit grayscale image by averaging a pixel
# in the image with the eight pixels around it. The average is computed
# by (CurCell*8 + other 8 cells)/16, weighting the current cell by 50%.
                .xlist: 
                .include "stdlib.a"
                .includelib "stdlib.lib"
                .list: 
                .286: 
dseg            segment para public 'data'
# integer variables:
 .bss
h               word    ?
i               word    ?
j               word    ?
k               word    ?
l               word    ?
sum             word    ?
iterations      word    ?

# Files names:
.data
InName          byte    "roller1.raw",0
OutName         byte    "roller2.raw",0

dseg            ends


# input data we manipulate.
.bss
InSeg           segment para public 'indata'

DataIn          byte    251 dup (256 dup (?))

InSeg           ends


# output array to hold the result.
.bss
OutSeg          segment para public 'outdata'

DataOut         byte    251 dup (256 dup (?))

OutSeg          ends




cseg            segment para public 'code'
                
.text
.globl Main
Main:            proc
                movw    dseg, %ax
                movw    %ax, %ds
               meminit

                movw    $0x3d00, %ax            #Open input image to be read.
                leaw    InName, %dx
                int     $0x21
                jnc     GoodOpen
               print
               byte    "Could not open input file.",cr,lf,0
                jmp     Quit

GoodOpen:       movw    %ax, %bx                #File handle.
                movw    InSeg, %dx              #Where to put the data.
                movw    %dx, %ds
                leaw    DataIn, %dx
                movw    $256*251, %cx           #Size of data file to read.
                movb    $0x3F, %ah
                int     $0x21
                cmpw    $256*251, %ax           # check if we can read data.
                je      GoodRead
               print
               byte    " Impossible to read ",cr,lf,0
                jmp     Quit

GoodRead:       movw    dseg, %ax
                movw    %ax, %ds
             print
              byte    "Enter number of iterations: ",0
               getsm
               atoi
                free
                movw    %ax, iterations

 print
              byte    "Computing Result",cr,lf,0

# for h= 1 to iterations

                movl    $1, h
hloop: 

# Copying input data to output buffer.
# Optimization1:Use movsd instruction rather than a loop to copy data from DataOut back to DataIn.

                pushw   %ds
                movw    OutSeg, %ax
                movw    %ax, %ds
                movw    InSeg, %ax
                movw    %ax, %es
                leaw    DataOut, %si
                leaw    DataIn, %di
                movw    (251*256)/4, %cx
        rep
        movsl
                popw    %ds


# Optimization2: Use a repeat-until

# for i = 1 to 249 

                movl    $1, i
iloop: 

# for j= 1 to 254 

                movl    $1, j
jloop: 


# Optimization3:Unroll the innermost two loops

             mov     bh, byte ptr i          
              mov     bl, byte ptr j          

                pushb   %ds
                movw    InSeg, %ax              #Get access to InSeg.
                movw    %ax, %ds

                movw    $0, %cx                 #Calculate sum.
                movb    %ch, %ah
                movb    ds:DataIn[bx-257], %cl  #DataIn[i-1][j-1]
                movb    ds:DataIn[bx-256], %al  #DataIn[i-1][j]
                addw    %ax, %cx
                movb    ds:DataIn[bx-255], %al  #DataIn[i-1][j+1]
                addw    %ax, %cx
                movb    ds:DataIn[bx-1], %al    #DataIn[i][j-1]
                addw    %ax, %cx
                movb    ds:DataIn[bx+1], %al    #DataIn[i][j+1]
                addw    %ax, %cx
                movb    ds:DataIn[bx+255], %al  #DataIn[i+1][j-1]
                addw    %ax, %cx
                movb    ds:DataIn[bx+256], %al  #DataIn[i+1][j]
                addw    %ax, %cx
                movb    ds:DataIn[bx+257], %al  #DataIn[i+1][j+1]
                addw    %ax, %cx

                movb    ds:DataIn[bx], %al      #DataIn[i][j]
                shlw    $3, %ax                 #DataIn[i][j]*8
                addw    %ax, %cx
                shrw    $4, %cx                 #Division by 16
                movw    OutSeg, %ax
                movw    %ax, %ds
                movb    %cl, ds:DataOut[bx]
                popb    %ds

                incl    %ds
                cmpl    $254, j
                jbe     jloop

                incl    %ds
                cmpl    $249, i
                jbe     iloop

                incl    %ds
                movw    h, %ax
                cmpw    Iterations, %ax
                jnbe    Done
                jmp     hloop

Done:           print
               byte    "Writing result",cr,lf,0

#Writing data to the output file:

                movb    $0x3c, %ah      #Create output file
                movw    $0, %cx         
                leaw    OutName, %dx
                int     $0x21
                jnc     GoodCreate
               print
              byte    " Impossible to create output file.",cr,lf,0
                jmp     Quit

GoodCreate:     movw    %ax, %bx        # handling file
                pushw   %bx
                movw    OutSeg, %dx     # data is placed here
                movw    %dx, %ds
                leaw    DataOut, %dx
                movw    $256*251, %cx   # amount of words to write at once
                movb    $0x40, %ah      # Writing task 
                int     $0x21
                popw    %bx             # Retrieve handle for close.
                cmpw    $256*251, %ax   # check if writing operation succeeded
                je      GoodWrite
              print
               byte    "Did not write the file properly",cr,lf,0
                jmp     Quit

GoodWrite:      movb    $0x3e, %ah      #Closing operation.
                int     $0x21


Quit:           ExitPgm                 
Main ENDP

cseg            ends

sseg            segment para stack 'stack'
stk             byte    1024 dup ("stack ")
sseg            ends
zzzzzzseg       segment para public 'zzzzzz'
LastBytes       byte    16 dup (?)
zzzzzzseg       ends
                end     Main


