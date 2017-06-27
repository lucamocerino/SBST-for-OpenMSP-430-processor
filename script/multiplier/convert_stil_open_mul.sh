#!/bin/sh

input=$1

cat <<END_PROLOGUE
; 
; CODE MEMORY: (0x00000000-0x0000FFFF)
; DATA MEMORY: (0x00010000-0x0001FFFF)
; 

org 0000

_reset:

	xor r0,  r0
	xor r1,  r1
	xor r2,  r2
	xor r3,  r3
	xor r4,  r4
	xor r5,  r5
	xor r6,  r6
	xor r7,  r7
	xor r8,  r8
	xor r9,  r9
	xor r10, r10
	xor r11, r11
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15
	
main:
	
END_PROLOGUE


egrep '"_pi"=[01N]*;' ${input}|sed 's/^[^"]*"_pi"=\([^;]*\);.*/\1/g' | 
gawk -v FIELDWIDTHS="16 8 1 " '{ print $1 " " $2 " " $3 }' |
while read line; do
  op_a=`echo $line|awk '{print $1}'`
  op_b=`echo $line|awk '{print $2}'`
  tc=`echo $line|awk '{print $3}'`	
 
 

  
  op_a_dec=$((2#$op_a))
  op_b_dec=$((2#$op_b))
 
 


  [[ op_a_dec -gt 32767 ]] && let op_dst_dec-=65536
  [[ op_b_dec -gt 32767 ]] && let op_src_dec-=65536
  
  
  cat <<MARK
  
  mov #${op_a_dec}, r4
  mov #${op_b_dec}, r6
  
  call #EXEC_MUL
	
MARK
done


cat <<END_EPILOGUE
	;sw r15, 0(r31)    ; store result
	nop
	nop
	nop
	nop		
end:	jmp end
END_EPILOGUE
