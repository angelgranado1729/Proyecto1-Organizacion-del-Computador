## Representación coma flotante

La representación de coma flotante (en inglés, floating point) es una forma de notación científica usada en las computadoras con la cual se pueden representar números reales extremadamente grandes y pequeños de una manera muy eficiente y compacta y con la que se pueden realizar operaciones aritméticas. El estándar actual para la representación en coma flotante es el IEEE 754.

Para este primer proyecto se requiere que desarrolle un programa en lenguaje de ensamblaje de MIPS 2000 que acepte un número decimal o hexadecimal, y que muestre como resultado el mismo número representado en coma flotante, según el estándar IEEE 754 de 32 bits.

El número debe ser ingresado con syscall 8, puede tener parte fraccionaria y debe identificarse su signo, por ejemplo:

* +10,75
* -15323,5
* +A1,4E
* -352,B

Los números que se transcriban de forma decimal tendrán un máximo de 6 dígitos a la izquierda del punto decimal y un máximo de 2 dígitos después del punto decimal, o sea desde -999999,99 pasando por cero y hasta +999999,99 .

Los números que se transcriban de forma hexadecimal tendrán un máximo de 5 dígitos a la izquierda del punto hexadecimal y un máximo de 2 dígitos después del punto hexadecimal, o sea desde -FFFFF,FF pasando por cero y hasta +FFFFF,FF .

Seguidamente debe mostrarse el número normalizado, por ejemplo:

* +1,1101*2^3  utilizando Syscall 4.

Por último debe mostrarse el resultado solicitado, por ejemplo:

* 0 10000011 11010000000000000000000  nuevamente utilizando Syscall 4.
