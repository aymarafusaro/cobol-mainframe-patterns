# Lección 03 — Apareo de archivos

## Introducción

Esta lección implementa el patrón clásico de **apareo de archivos** utilizado en procesos batch COBOL/Mainframe.

El programa toma dos archivos secuenciales ordenados por una misma clave:

- un archivo maestro de clientes
- un archivo de movimientos

El programa compara las cuentas de ambos archivos y:

- actualiza el saldo cuando existe correspondencia
- aplica múltiples movimientos de una misma cuenta
- copia los maestros que no tienen movimientos
- detecta movimientos que no tienen maestro
- genera un nuevo archivo maestro actualizado
- genera un reporte de control

---

## Objetivo

Practicar el procesamiento batch de dos archivos secuenciales ordenados por clave.

El concepto central es:

```text
MAESTRO                    MOVIMIENTOS
--------                   -----------
000001  ----------------> 000001
000002  ----------------> 000002
                          000002
000003
000004  ----------------> 000004
                          000005
```

El programa compara las cuentas utilizando la lógica clásica de apareo:

```text
CUENTA-MAESTRO = CUENTA-MOVIMIENTO
```

## Archivos de entrada

### Maestro de clientes

Archivo:

```text
datos/entrada/maestro-clientes.dat
```

Cada registro tiene una longitud fija de 36 caracteres.

Estructura:

Posición	Campo	        Longitud	Descripción
1-6	        CUENTA-MAESTRO	6	        Número de cuenta
7-26	    NOMBRE-MAESTRO	20	        Nombre del cliente
27-36	    SALDO-MAESTRO	10	        Saldo con 2 decimales implícitos

Definición COBOL:

```cobol
01  REGISTRO-MAESTRO.
    05  CUENTA-MAESTRO
        PIC X(6).
    05  NOMBRE-MAESTRO
        PIC X(20).
    05  SALDO-MAESTRO
        PIC 9(8)V99.
```

### Movimientos

Archivo:

```text
datos/entrada/movimientos-clientes.dat
```

Cada registro tiene una longitud fija de 20 caracteres.

Estructura:

| Posición | Campo | Longitud | Descripción |
|---|---|---|---|
| 1-6 | CUENTA-MOVIMIENTO | 6 | Número de cuenta |
| 7 | TIPO-MOVIMIENTO | 1 | C = crédito / D = débito |
| 8-19 | IMPORTE-MOVIMIENTO | 12 | Importe con 2 decimales implícitos |
| 20 | RESERVADO-MOVIMIENTO | 1 | Campo reservado |

Definición COBOL:

```cobol
01  REGISTRO-MOVIMIENTO.
    05  CUENTA-MOVIMIENTO
        PIC X(6).
    05  TIPO-MOVIMIENTO
        PIC X(1).
    05  IMPORTE-MOVIMIENTO
        PIC 9(10)V99.
    05  RESERVADO-MOVIMIENTO
        PIC X(1).
```

## Datos utilizados

Maestro

```text
000001CLIENTE A           0000100000
000002CLIENTE B           0000250000
000003CLIENTE C           0000180000
000004CLIENTE D           0000320000
```

## Movimientos

```text
000001C000000050000
000002D000000030000
000002C000000020000
000004D000000070000
000005C000000010000
```

Los archivos están ordenados por número de cuenta.

El movimiento de la cuenta 000005 fue agregado intencionalmente para probar el caso de un movimiento sin maestro correspondiente.

## Lógica del apareo

El proceso comienza leyendo el primer registro de cada archivo.

Luego compara:

```text
CUENTA-MAESTRO
        vs
CUENTA-MOVIMIENTO
```

### Caso 1 — Las cuentas son iguales

Cuando:

```text
CUENTA-MAESTRO = CUENTA-MOVIMIENTO
```

se toma el saldo del maestro y se procesan todos los movimientos correspondientes a esa cuenta.

Para un crédito:

```text
ADD IMPORTE-MOVIMIENTO
    TO WS-SALDO-ACTUAL
```

Para un débito:

```text
SUBTRACT IMPORTE-MOVIMIENTO
    FROM WS-SALDO-ACTUAL
```

Una vez procesados todos los movimientos de la cuenta, se escribe el maestro actualizado.

### Caso 2 — El maestro es menor

Cuando:

```text
CUENTA-MAESTRO < CUENTA-MOVIMIENTO
```

significa que el maestro no tiene movimiento asociado.

Por lo tanto, se copia sin modificaciones al archivo de salida.

### Caso 3 — El movimiento es menor

Cuando:

```text
CUENTA-MAESTRO > CUENTA-MOVIMIENTO
```

significa que existe un movimiento para una cuenta que no existe en el maestro.

El movimiento no se aplica y se contabiliza como:

```text
MOVIMIENTO SIN MAESTRO
```

### Múltiples movimientos

El programa soporta múltiples movimientos para una misma cuenta.

Por ejemplo:

```text
000002 D 300.00
000002 C 200.00
```

Partiendo de:

```text
Saldo inicial = 2500.00
```

se obtiene:

```text
2500.00 - 300.00 = 2200.00
2200.00 + 200.00 = 2400.00
```

Resultado:

```text
000002 → 2400.00
```

## Archivo de salida

El programa genera:

```text
datos/salida/maestro-clientes-actualizado.dat
```

Cada registro mantiene la longitud fija de 36 caracteres.

Resultado obtenido:

```text
000001CLIENTE A           0000150000
000002CLIENTE B           0000240000
000003CLIENTE C           0000180000
000004CLIENTE D           0000250000
```

El archivo contiene:

```text
4 registros × 36 caracteres = 144 bytes
```

## Reporte de control

También se genera:

```text
datos/salida/reporte-apareo.txt
```

Resultado:

```text
========================================
          REPORTE DE APAREO
========================================
MAESTROS PROCESADOS:  00004
CUENTAS ACTUALIZADAS: 00003
MOVIMIENTOS APLICADOS: 00004
MOVIMIENTOS SIN MAESTRO: 00001
RETURN-CODE: 000000000
========================================
```

Interpretación

```text
4 maestros procesados
3 cuentas actualizadas
4 movimientos aplicados
1 movimiento sin maestro
```
```text
RETURN-CODE 0 indica finalización correcta
```

Estructura
```text
03-apareo-archivos/
│
├── APAREO-ARCHIVOS.CBL
├── README.md
│
└── datos/
    ├── entrada/
    │   ├── maestro-clientes.dat
    │   └── movimientos-clientes.dat
    │
    └── salida/
        ├── maestro-clientes-actualizado.dat
        └── reporte-apareo.txt
```

Los archivos generados dentro de datos/salida/ y el ejecutable no se versionan mediante Git.

### Compilación

Desde la raíz del proyecto:

```text
cobc -x -free \
  -o lecciones/03-apareo-archivos/apareo-archivos \
  lecciones/03-apareo-archivos/APAREO-ARCHIVOS.CBL
```

### Ejecución

```text
./lecciones/03-apareo-archivos/apareo-archivos
```

Salida de consola:

```text
========================================
       APAREO DE ARCHIVOS
========================================
ARCHIVOS ABIERTOS CORRECTAMENTE
```

El resultado se obtiene en:

```text
lecciones/03-apareo-archivos/datos/salida/
```

### Conceptos COBOL / Mainframe practicados

- Archivos secuenciales
- Registros de longitud fija
- FILE SECTION
- FD
- RECORD CONTAINS
- RECORDING MODE IS F
- FILE STATUS
- OPEN
- READ
- WRITE
- CLOSE
- AT END
- PERFORM UNTIL
- Comparación de claves
- Apareo de archivos
- Actualización de maestros
- Procesamiento de múltiples movimientos
- Control de registros sin correspondencia
- Contadores de procesamiento
- RETURN-CODE
- Archivos de salida
- Reportes de control

### Patrón Mainframe representado

El flujo implementado es:

```text
        ┌──────────────────────┐
        │  MAESTRO CLIENTES    │
        └──────────┬───────────┘
                   │
                   │
                   ▼
            ┌─────────────┐
            │   APAREO    │◄──────────────┐
            └──────┬──────┘               │
                   │                      │
                   │                      │
                   ▼                      │
        ┌──────────────────────┐          │
        │ MOVIMIENTOS CUENTAS  │──────────┘
        └──────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ MAESTRO ACTUALIZADO  │
        └──────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ REPORTE DE CONTROL   │
        └──────────────────────┘
```

## Resultado

La lección demuestra un proceso batch clásico de actualización de un archivo maestro mediante el apareo con un archivo de movimientos.

El programa mantiene los archivos ordenados por clave, procesa múltiples movimientos para una misma cuenta, conserva los registros del maestro sin movimientos y detecta movimientos que no tienen correspondencia.