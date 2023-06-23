.macro printString %memoryAddress
         li $v0 4
	la $a0 %memoryAddress
         syscall
.end_macro

.data
welcomeMessage: .asciiz "CONVERTIDOR DE NUMERO DE PUNTO FLOTANTE\n \nMENU\nIndique que tipo de número desea ingresar\n1.Número decimal\n2.Número hexadecimal\nIngrese una opción --> "
decimalMessage: .asciiz "\nIngrese el número decimal (máximo 8 dígitos): "
decimalInput: .space 12  # Aumentado en 1 para el carácter nulo
hexNumber: .space 10
hexToBinaryArray: .asciiz  "0000-0001-0010-0011-0100-0101-0110-0111-1000-1001-1010-1011-1100-1101-1110-1111"
vector_binarioParteFraccDecimal: .space 20
salto: .asciiz "\n"
vector_binarioParteEnteraDecimal: .space 20 #Vector para guardar los digitos enteros
vector_decimalNormalizado: .space 40
print_exponente: .asciiz "*2^"
vector_decimalNormalizadoIEEE: .space 28
hexadecimalMessage: .asciiz "\nIngrese el número hexadecimal (máximo 7 dígitos): "
exponente: .space 8
mantisa: .space 24
espacio: .asciiz " "
result: .space 40
tipoDeNum: .space 2
.text
la $t7, vector_binarioParteEnteraDecimal
li $t8, 20
li $t9, 48
init_vector_binarioParteEnteraDecimal:
    sb $t9, 0($t7)
    addi $t7, $t7, 1
    addi $t8, $t8, -1
    bnez $t8, init_vector_binarioParteEnteraDecimal

la $t7, vector_binarioParteFraccDecimal
li $t8, 20
init_vector_binarioParteFraccDecimal:
    sb $t9, 0($t7)
    addi $t7, $t7, 1
    addi $t8, $t8, -1
    bnez $t8, init_vector_binarioParteFraccDecimal

#1 BIENVENIDA
printString(welcomeMessage)

#2 SELECCION TIPO DE NUMERO
li $v0, 5
syscall
move $t0, $v0
li $t3 0
sb $t0 tipoDeNum($t3)
bgt $t0, 2, exit     # Si la opción es mayor que 2 o menor que 1, salta a la etiqueta 'exit'
blt $t0, 1, exit
beq $t0, 1, readDecimal  
beq $t0, 2, readHexadecimal

readDecimal:
	printString(decimalMessage)
	li $v0, 8
	la $a0, decimalInput   # Mensaje para solicitar número decimal
	li $a1, 12   # Máximo 8 caracteres (incluyendo el carácter nulo)
	syscall
	sb $zero, decimalInput($a1) # Agregar carácter nulo al final

j DecimalCase

readHexadecimal:

	printString(hexadecimalMessage)
	li $v0, 8
	la $a0, hexNumber # Mensaje para solicitar número hexadecimal
	li $a1, 11 # Máximo 7 caracteres (incluyendo el carácter nulo)
	syscall
	
	li $s5, 0 # indice para el array result
	li $s6 0 # cantidad de digitos en la parte entera
	li $s7 0 # cantidad de digitos en la parte fraccionaria
	la $a2, hexNumber
	
	# Contamos la cantidad de digitos en la parte entera
	countInt:
		addi $a2, $a2, 1
		lb $t0 0($a2)
		beq $t0, 44, countFracc # Vemos si hay una coma o un punto
		beq $t0, 46, countFracc
		beq $t0, 10, startConversion # Si $t0 es 10 entonces el numero no tiene parte fraccionaria
		addi $s6, $s6, 1 # Aumentamos el contador 
		j countInt
			
	countFracc:
		addi $a2, $a2, 1
		lb $t0 0($a2)
		beq $t0, 10, startConversion # Si $t0 es 11 entonces terminamos de contar
		addi $s7, $s7, 1 # Aumentamos el contador 
		j countFracc
		
	startConversion:
		li $a2, 0
		la $a2, hexNumber
		lb $t5 0($a0)
		beq $t5 43 loop1
		beq $t5 45 loop1
		bgt $t5 45 exit
		blt $t5 43 exit
		loop1: 
			addi $a2, $a2, 1
			lb $t0, 0($a2) # Cargamos el digito en $t0
							
HexaToBinary:
	beq $t0, 10, print
	beq  $t0, 44, case3 # Encontramos un punto o una coma
	beq $t0, 46, case3
	ble $t0, 57, case1 # Si es menor o igual que 57, entonces puede ser un numero
	ble $t0, 70, case2 # Si es menor o igual que 57, entonces puede ser un numero
	
# El digito a convertir es un numero
	case1:	
		blt $t0, 48, exit # si es menor que 48, entonces el input no es valido
		la $a3, 0
		la $a3, hexToBinaryArray
		addi $t0, $t0, -48 # Pasamos el digito a decimal
		li $t3, 5
		mult $t0, $t3
		mflo $t0
		add $a3, $a3, $t0 # la posicion inicial sobre el array hexToBinaryArray
		j innerLoop1	
	
	# El digito a convertir es una letra
	case2:
		blt $t0, 65, exit # si es menor que 65, entonces el input no es valido
		la $a3, 0
		la $a3, hexToBinaryArray
		addi $t0, $t0, -55 # Pasamos el digito a decimal
		li $t3, 5
		mult $t0, $t3
		mflo $t0
		add $a3, $a3, $t0 # la posicion inicial sobre el array hexToBinaryArray
		
	innerLoop1:
		# Nos movemos a traves del hexToBinaryArray
		li $t2, 0 # Contador, la cota superior sera 4
		innerLoop2:
			lb $t4, 0($a3)
			sb $t4, result($s5)
			addi $s5, $s5, 1
			addi $t2, $t2, 1
			addi $a3, $a3, 1
			beq $t2, 4, loop1
			j innerLoop2
 
 	# encontramos una coma o punto
	case3:
		j loop1
	
print:
chooseATypeNormalization:
	li $t0, 0 
	li $t9, 0
	bgtz $s6 normalizarDerechaAIzquierda
	beqz $s7 normalizarIzquierdaADerecha

normalizarDerechaAIzquierda:
	mul $s6, $s6, 4 
	subi $s1, $s6 1
	bgtz $s1, whereToStart
	
normalizarIzquierdaADerecha:
	mul $s7, $s7, 4
	mul $s2, $s7, 2
	sub $s1, $s7, $s2
	addi $s1, $s1, 1
	bltz $s1 whereToStart
	
	whereToStart: #PARA VER CUAL ES LA PRIMERA CIFRA SIGNIFICATIVA
  	  	lb $t1, result ($t9) # Cargamos un elemento del vector result
  	  	beq $t1, 49, copiarVector
    		addi $t9, $t9, 1 
    		blt $t0, 39 whereToStart
    		
	copiarVector: 
		sub $s1, $s1, $t9 #s1 es util para el exponente en fin_normalizacion
		copyLoop:
  	  		lb $t1, result ($t9) # Cargamos un elemento del vector result
   	 		sb $t1, vector_decimalNormalizado ($t0) # Almacenamos el elemento en el vector vector_decimalNormalizado
    			addi $t0, $t0, 1 
    			addi $t9, $t9, 1 
    			blt $t9, 39 copyLoop
   	
j fin_normalizacion


#3 STRING A DECIMAL
DecimalCase:
	la $a0, decimalInput # Cargamos la dirección de memoria del input a $a0
	addi $a0, $a0, 0 
	lb $t1, 0($a0)
	beq $t1, 43, StringToDec # Verificamos si el 1er caracter es + o -
	beq $t1, 45, StringToDec
	j exit # Si no es + o - entonces terminamos la ejecución

#3 STRING A DECIMAL
StringToDec:
	la $a0, decimalInput
	addi $a0, $a0, 1 # Para iterar desde segunda posición
	li $t1, 0
	li $t4, 0

	# Conversion de string a decimal la parte entera del numero
	stringToDecimalLoop:
		mul $t4, $t4, 10  # Multiplicamos por 10 para darle espacio al próximo dígito
		lb $t2, 0($a0)
		bgt $t2, 57, exit
		sub $t3, $t2, 48  # Le restamos 48 para obtener el valor en la base decimal
		add $t4, $t4, $t3 # Almacenamos el dígito en $t4
		addi $a0, $a0, 1
		lb $t2, 0($a0)
		bgt $t2, 57, exit
		beqz $t2, NoTieneParteFracc   # Si encuentra el caracter nulo, el número no tiene parte fraccionaria
		beq $t2, 44, TieneParteFracc   # Convierte hasta que encuentra una coma o un punto
		beq $t2, 46, TieneParteFracc   
		blt $t2, 48, NoTieneParteFracc 
		j stringToDecimalLoop

	TieneParteFracc:
		li $t5, 0 # Almacena la parte fraccionaria en t5
		addi $a0, $a0, 1 # Nos movemos una posición más para saltarnos la coma o el punto
		li $t2, 0
		li $t6, 10

		# Conversión de string de la parte fraccionaria   
		stringToDecimalLoop2:
			lb $t2, 0($a0)
			blt $t2, 48, decimalToBinaryLoop
			bgt $t2, 57, exit
      			sub $t3, $t2, 48 
      			mul $t3, $t3, $t6
      			div $t6, $t6, 10
      			add $t5, $t5, $t3  
      			addi $a0, $a0, 1
      			lb $t2, 0($a0)
      			beqz $t2, decimalToBinaryLoop
      			blt $t6, 1, decimalToBinaryLoop
      			j stringToDecimalLoop2
	
		
	#4 CONVERSION DE DECIMAL A BINARIO
	NoTieneParteFracc:
	decimalToBinaryLoop:
	
		## PARTE ENTERA
		li $t1, 19  # $t1 es el indice pa movernos sobre el vector
		start2: 
          		div $t4, $t4, 2
          		mfhi $t2         # Guardamos el residuo en $t2 (el digito pa la representacion en binario)
          		addi $t2, $t2, 48 # Lo pasamos a ascii pa poderlo imprimir despues
          		sb $t2, vector_binarioParteEnteraDecimal($t1) # Lo guardamos en el vector
          		subi $t1, $t1, 1
          		bgez $t1, start2
		
		## PARTE FRACCIONARIA
       		li $t1, 0
          	decimalToBinaryLoop2: 
          		mul $t5, $t5, 2
     			div $t5, $t5, 100
     			mflo $t3         # Guardamos el cociente en $t3
     			mfhi $t2         # Guardamos el residuo en $t2 para seguir dividiendo
       			addi $t3, $t3, 48   # Lo pasamos a ASCII para poder imprimirlo después
     			sb $t3, vector_binarioParteFraccDecimal($t1) # Lo guardamos en el vector
     			move $t5, $t2
     			addi $t1, $t1, 1
     			blt $t1, 19, decimalToBinaryLoop2
   
## 5 NORMALIZACION
Normalizacion:
    	li $s0 0
	
	# Distinguimos 2 casos
	StandardizationLoop1: # Con este loop determinamos si vamos a normalizar de derecha a izquierda o de izquierda a derecha
		lb $s2, vector_binarioParteEnteraDecimal ($s0)
		beq $s2, 49, standardization_RightToLeft  #Si conseguimos un 1 es que la parte entera no es 0 y por lo tanto tenemos que normalizar de LeftToRight
		beq $s0, 19, standardization_LeftToRight  #Si llego a la ultima posicion es porque no habia nada en la parte entera y es una normalizacion de RightToLeft
		addi $s0, $s0, 1
		blt $s2, 49, StandardizationLoop1 
	
	# Caso 1: movemos la coma de derecha a izquierda
	standardization_RightToLeft: #En $s0 se guarda la posicion donde comienza el numero entero
		li $s2 19
		sub $s1, $s2, $s0   #En $s1 guardamos la cantidad de veces que hay que mover la coma a la izquierda. UTIL PARA EL CALCULO DEL EXPONENTE EXCESO 127
      		
      		StandardizationLoop2: #Con este loop determinamos la posicion donde termina la parte fraccionaria para poder concatenarlo al final
      			lb $s3, vector_binarioParteFraccDecimal ($s2)
      			beq $s3, 49, concat_entero
      			beq $s2, 0, concat_entero 
      			subi $s2, $s2, 1
      			blt $s3, 49, StandardizationLoop2
      			
      		li $s5, 0
      		concat_entero: #En $s2 se guarda la posicion donde termina la parte fraccionaria y en $s0 donde comienza el numero entero. 
      			lb $s3, vector_binarioParteEnteraDecimal ($s0)
      			sb $s3, vector_decimalNormalizado($s5)
      			addi $s5 $s5 1 
      			addi $s0 $s0 1
      			blt $s0, 20, concat_entero 
	
      		li $s6, 0
      		addi $s2 $s2 1
      		concat_decimal:
      			lb $s3, vector_binarioParteFraccDecimal($s6)
      			sb $s3, vector_decimalNormalizado($s5)
      			addi $s5 $s5 1 
      			addi $s6 $s6 1 
      			blt  $s6, $s2 concat_decimal
      			li $s6, 0
      			beq $s6, 0, fin_normalizacion
      			
      	# Caso 2: movemos la coma de izquierda a derecha			
	standardization_LeftToRight:
		li $s0 19
    		StandardizationLoop3:
    			lb $s2, vector_binarioParteFraccDecimal ($s0)
			beq $s2, 49, StandardizationLoop4  #Si conseguimos un 1 es la ultima cifra del decimal (no se completo con 0)
			subi $s0, $s0, 1
			blt $s2, 49, StandardizationLoop3 
		
		li $s6 0
    		StandardizationLoop4:
    			lb $s2, vector_binarioParteFraccDecimal ($s6)
			beq $s2, 49, continue_concat #Si conseguimos un 1 es la primera cifra representativa para mover la coma
			addi $s6, $s6, 1
			blt $s2, 49, StandardizationLoop4 
		
		continue_concat:
      		move $s1 $s6
		addi $s1 $s1 1 #$S1 CANTIDAD DE VECES RODADA LA COMA UTIL PARA EL EXPONENTE
      		
      		li $s4 0
      		concat_decimal2:
      			lb $s3, vector_binarioParteFraccDecimal($s6) #$6 es el iterador que permitira movernos a la cifra significativa (1) mas cercana de izquierda a derecha
      			sb $s3, vector_decimalNormalizado($s4) #cargamos al nuevo vector
      			addi $s6, $s6, 1 #Se incrementa el interador de vector_binarioParteFraccDecimal
      			addi $s4, $s4, 1 # Se incrementa el iterador de vector_decimalNormalizado
      			ble  $s6, $s0, concat_decimal2 #s0 es la posicion de parada
      			
      		# Le cambiamos el signo al exponente porque estamos moviendo la coma de izq a der
      		li $t9, -1
      		mult $s1, $t9
      		mflo $s1

#Print del numero normalizado junto al exponente
fin_normalizacion:
      			li $t0 0 #para iterar sobre vector_decimalNormalizadoIEEE
      			li $t1 49 #Numero 1
      			li $t2 44 #Coma
      			sb $t1 vector_decimalNormalizadoIEEE($t0)
      			addi $t0 $t0 1
      			sb $t2 vector_decimalNormalizadoIEEE($t0) 
      			addi $t0 $t0 1
      			li $t1 1 #para iterar sobre vector_decimalNormalizado
      			loop_Construccion_vector:
      				lb $t2 vector_decimalNormalizado($t1)
      				beqz $t2 print_Normalizacion
      				sb $t2 vector_decimalNormalizadoIEEE($t0)
      				beq $t0 24 print_Normalizacion
      				beq $t1 23 print_Normalizacion
      				addi $t0 $t0 1
      				addi $t1 $t1 1
      				b loop_Construccion_vector
      			
      			# Imprimimos el numero normalizado
      			print_Normalizacion:
      			li $v0 4 
      			la $a0 vector_decimalNormalizadoIEEE
      			syscall
      			
      			li $v0 4 
      			la $a0 print_exponente
      			syscall
      			
      			move $a0 $s1
      			li $v0 1
      			syscall
      				
# 7 Exponente en exceso 127
	
	li $t9, 127 # 2^(8-1) 
	add $s1, $s1, $t9 # Lo pasamos a binario
	li $t8, 7
	li $t7, 0
	li $t6, 2

	aux:
		div $s1, $t6
		mfhi $t7
		mflo $s1
		addi $t7, $t7, 48
		sb $t7, exponente($t8)
		addi $t8, $t8, -1
		bltz $t8, finalPrint
		j aux

#Print de ultimo output
finalPrint:
	printString(salto)
	li $t0 0
	lb $t9 tipoDeNum($t0)
	beq $t9 1 finalDecimal
	beq $t9 2 finalHexadecimal
	bgt $t9 2 exit
	blt $t9 1 exit
	
	finalDecimal:
	li $t1, 0
	lb $t2, decimalInput($t1)
	beq $t2, 43, positivo
	
	negativo:
		li $a0, 1
		li $v0, 1
		syscall
		j continuacionPrint
	
	positivo:
		li $a0, 0
		li $v0, 1
		syscall
		j continuacionPrint
		
	finalHexadecimal:
		li $t1, 0
		lb $t2, hexNumber($t1)
		beq $t2, 43, positivo
	
	negativo2:
		li $a0, 1
		li $v0, 1
		syscall
		j continuacionPrint
	
	positivo2:
		li $a0, 0
		li $v0, 1
		syscall
		j continuacionPrint
		
continuacionPrint:	
	printString(espacio)
	printString(exponente)
	printString(espacio)

	li $t0 0
	li $t2 1
	
	loopCrearMantisa:
		bgt $t0 22 ultimoPrint
		lb $t1 vector_decimalNormalizado($t2)
		blt $t1 48 continuarLoopMantisa
		sb $t1 mantisa($t0)
		addi $t0 $t0 1
		addi $t2 $t2 1
		ble $t0 23 loopCrearMantisa
		
		continuarLoopMantisa: 
			addi $t1 $t1 48
			sb $t1 mantisa($t0)
			addi $t0 $t0 1
			addi $t2 $t2 1
			b loopCrearMantisa
		
	ultimoPrint:	
	printString(mantisa)
	b exit	

exit:
	li $v0, 10
	syscall