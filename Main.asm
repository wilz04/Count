_data segment para "data"
	file db "info.txt"
	handle dw 0
	text db 1024 dup(0)
	len dw 1024
	
	spacer db ": $" 
	br db 10, 13, '$'
ends

_stack segment para "stack"
	dw 4 dup(0)
ends

_code segment para "code"
init:
	assume ds:_data, ss:_stack, cs:_code
	mov ax, _data
	mov ds, ax
	xor ax, ax
	
	include File.asm                      ;incluimos el archivo File.asm
	
	open file, handle                     ;llamamos a la macro open para abrir el archivo <file> y devuelve el manejador <handle>..
	jc exit                               ;si hay un error brincamos a exit
	load handle, text, len                 ;llamamos a la macro load para cargar el texto del archivo de <handle>, lo devuelbe en <text>..
	jc exit                               ;si hay un error brincamos a exit
	close handle                          ;llamamos a la macro close que cierra el archivo apuntado por <handle>
	jc exit                               ;si hay un error brincamos a exit
	
	lea bx, text
	add bx, len
	
	mov dl, '$'
	
	mov [bx], dl
	lea dx, text
	mov ah, 09h
	int 21h
	
	mov cx, len                           ;copiamos a cx la longitud del texto, para usar a cx como contador y procesar el texto byte/byte
	xor ch, ch
	lea bx, text                          ;apuntamos con bx al texto
	xor dh, dh
	
	next:
	call count
	
	mov dl, dh
	mov ah, 02h                           ;imprime el caracter que esta en dl el caracter ascII
	int 21h
	
	push dx
	lea dx, spacer                        ;imprime la cadena de los dos puntos y el espacio que sigue
	mov ah, 09h
	int 21h
	pop dx
	
	add ch, 48
   	mov dl, ch                            ;imprime el caracter numero de veces que se repite y le suma 48 para imprimir el numero de veces q esta el caracter en codigo ascII y no codigo de bits
	mov ah, 02h
	int 21h
	
	push dx
	lea dx, br                            ;imprime el enter
	mov ah, 09h
	int 21h
	pop dx
	
	mov cx, len
	xor ch, ch
	lea bx, text                          ;pasaba a comparar el sgte y compara con 255 para ver si ya termino
	inc dh
	cmp dh, 255
	jne next
	
	exit:
	mov ax, 4C00h
	int 21h                               ;llamamos a la interrupcion 21, 4C para salir devolviendo 0 en al
	
	count proc near
		_next:
		mov dl, [bx]                      ;copiamos a dl el byte al que apunta bx
		cmp dl, dh
		jne continue
		inc ch
		continue:
		inc bx                            ;incrementamos bx en 1 para que apunte al siguiente byte
		dec cl
		jnz _next                         ;brincamos a _next, mientras cx sea diferente de 0
		ret
	count endp
	                                    
_code ends
end init
