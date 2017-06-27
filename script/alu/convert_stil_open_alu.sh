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
gawk -v FIELDWIDTHS="2 12 1 8 8 16 16 1 3" '{ print $1 " " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9 }' |
while read line; do
  i_alu=`echo $line|awk '{print $2}'`
  bw=`echo $line|awk '{print $3}'`
  op_jump=`echo $line|awk '{print $4}'`	
  i_so=`echo $line|awk '{print $5}'`
  op_dst=`echo $line|awk '{print $6}'`
  op_src=`echo $line|awk '{print $7}'`
  op_st1=`echo $line|awk '{print $8}'`
  op_st2=`echo $line|awk '{print $9}'`

  istruction_alu=$((2#$i_alu))
  op_dst_dec=$((2#$op_dst))
  op_src_dec=$((2#$op_src))
  op_st1_dec=$((2#$op_st1))
  op_st2_dec=$((2#$op_st2))
  op_st_tot=$((( op_st1 * (2 ** y) ) + op_st2))

  [[ istruction_alu  -gt 32767 ]] && let istruction_alu-=65536
  [[ op_st_tot  -gt 32767 ]] && let op_st_tot-=65536
  [[ op_dst_dec -gt 32767 ]] && let op_dst_dec-=65536
  [[ op_src_dec -gt 32767 ]] && let op_src_dec-=65536
  
  
  cat <<MARK
  
  mov #${op_dst_dec}, r4
  mov #${op_src_dec}, r6
  
  call #EXEC1
	
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
