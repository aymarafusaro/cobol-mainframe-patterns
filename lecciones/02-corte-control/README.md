# Lección 02 — Corte de control

Ejemplo práctico del patrón clásico de **corte de control (control break)** en COBOL.

La lección procesa un archivo secuencial de movimientos bancarios ordenado por cuenta y genera un reporte con:

- cantidad de movimientos por cuenta
- total de créditos
- total de débitos
- saldo neto por cuenta
- totales generales del archivo

El objetivo es mostrar cómo COBOL detecta el cambio de una clave de control, procesa los acumuladores del grupo anterior y comienza a procesar el nuevo grupo.

## Concepto: corte de control

El corte de control es un patrón clásico de procesamiento batch utilizado cuando un archivo está ordenado por una clave.

En esta lección, la clave de control es la cuenta bancaria.

El programa procesa los movimientos de una cuenta y acumula sus valores. Cuando detecta que la cuenta cambia, genera los totales de la cuenta anterior y comienza a acumular los movimientos de la nueva cuenta.

El esquema general es:

1. Leer un registro.
2. Guardar la cuenta actual.
3. Acumular sus movimientos.
4. Leer el siguiente registro.
5. Comparar la cuenta actual con la cuenta anterior.
6. Si la cuenta cambió, emitir los totales del grupo anterior.
7. Reiniciar los acumuladores.
8. Continuar con la nueva cuenta.
9. Al finalizar el archivo, emitir también el último grupo.


## Archivo de entrada

El programa recibe un archivo secuencial de longitud fija:

`datos/entrada/movimientos-cuentas.dat`

Cada registro tiene una longitud de 30 caracteres.

### Estructura del registro

| Posiciones | Campo | Formato | Descripción |
|---|---|---|---|
| 1-6 | CUENTA-MOVIMIENTO | X(6) | Número de cuenta |
| 7-14 | FECHA-MOVIMIENTO | X(8) | Fecha del movimiento |
| 15 | TIPO-MOVIMIENTO | X(1) | C = crédito, D = débito |
| 16-27 | IMPORTE-MOVIMIENTO | 9(10)V99 | Importe con 2 decimales implícitos |
| 28-30 | RESERVADO-MOVIMIENTO | X(3) | Espacio reservado |

Ejemplo de registro:

`00000120260901D000000150000`

En este ejemplo:

- Cuenta: `000001`
- Fecha: `20260901`
- Tipo: `D`
- Importe: `1500.00`


## Datos de prueba

El archivo contiene movimientos agrupados y ordenados por número de cuenta.

### Cuenta 000001

- Débito: 1500.00
- Crédito: 500.00
- Débito: 200.00

Resultado:

- Movimientos: 3
- Créditos: 500.00
- Débitos: 1700.00
- Neto: -1200.00

### Cuenta 000002

- Crédito: 3000.00
- Débito: 750.00
- Crédito: 250.00

Resultado:

- Movimientos: 3
- Créditos: 3250.00
- Débitos: 750.00
- Neto: 2500.00

### Cuenta 000003

- Crédito: 1200.00
- Débito: 300.00

Resultado:

- Movimientos: 2
- Créditos: 1200.00
- Débitos: 300.00
- Neto: 900.00

### Cuenta 000004

- Débito: 800.00

Resultado:

- Movimientos: 1
- Créditos: 0.00
- Débitos: 800.00
- Neto: -800.00


## Lógica del programa

La clave de control utilizada es `CUENTA-MOVIMIENTO`.

El programa mantiene en `WS-CUENTA-ANTERIOR` la cuenta que se está procesando.

Mientras la cuenta actual sea igual a la cuenta anterior, los movimientos continúan acumulándose.

Cuando se detecta una cuenta diferente, se produce el corte de control.

En ese momento el programa:

1. Genera el resumen de la cuenta anterior.
2. Acumula los totales generales.
3. Reinicia los acumuladores de la cuenta.
4. Guarda la nueva cuenta como cuenta anterior.
5. Procesa el movimiento correspondiente a la nueva cuenta.

Los principales acumuladores utilizados son:

- `WS-CANTIDAD-MOVIMIENTOS`
- `WS-TOTAL-CREDITOS`
- `WS-TOTAL-DEBITOS`
- `WS-TOTAL-NETO`

El neto de cada cuenta se calcula como:

`CRÉDITOS - DÉBITOS`


## Totales generales

Además de los acumuladores de cada cuenta, el programa mantiene acumuladores generales para todo el archivo.

Se utilizan:

- `WS-GRAL-MOVIMIENTOS`
- `WS-GRAL-CREDITOS`
- `WS-GRAL-DEBITOS`
- `WS-GRAL-NETO`

Estos valores se actualizan cada vez que se procesa el cierre de una cuenta.

Al finalizar el archivo se genera una sección de totales generales.

## Tratamiento del último grupo

Un aspecto importante del corte de control es el tratamiento del último registro.

El cambio de cuenta normalmente permite detectar el final de un grupo cuando comienza el siguiente. Sin embargo, después de leer el último registro no existe un registro posterior que provoque otro cambio.

Por este motivo, el programa realiza explícitamente el cierre del último grupo después de finalizar el ciclo principal de lectura.

Esto permite incluir también la última cuenta en el reporte y en los totales generales.


## Archivo de salida

El programa genera el reporte:

`datos/salida/reporte-corte-control.txt`

El reporte contiene un resumen por cuenta con:

- número de cuenta
- cantidad de movimientos
- total de créditos
- total de débitos
- saldo neto

También incluye los totales generales del archivo.

### Resultado obtenido

Para los datos de prueba utilizados, el reporte genera:

```text
000001   00003          500.00        1,700.00   -1,200.00
000002   00003        3,250.00          750.00    2,500.00
000003   00002        1,200.00          300.00      900.00
000004   00001            0.00          800.00     -800.00

TOTALES GENERALES
MOVIMIENTOS: 000009
CREDITOS: 4,950.00
DEBITOS: 3,550.00
NETO:  1,400.00
```

El resultado permite verificar que los movimientos fueron agrupados correctamente por cuenta y que los acumuladores generales coinciden con los totales de todos los registros procesados.


## Estructura de la lección

```text
02-corte-control/
├── CORTE-CONTROL.CBL
├── README.md
└── datos/
    ├── entrada/
    │   └── movimientos-cuentas.dat
    └── salida/
        └── reporte-corte-control.txt
```

El archivo ejecutable corte-control se genera durante la compilación y no forma parte del repositorio.

## Compilación

Desde la raíz del proyecto se puede compilar con:

```bash
cobc -x -free \
  -o lecciones/02-corte-control/corte-control \
  lecciones/02-corte-control/CORTE-CONTROL.CBL
```

## Ejecución

Una vez compilado:

```bash
./lecciones/02-corte-control/corte-control
```

### Para consultar el reporte generado:

```bash
cat lecciones/02-corte-control/datos/salida/reporte-corte-control.txt
```

## Conceptos COBOL y Mainframe utilizados

Esta lección permite practicar varios conceptos habituales de procesamiento batch:

- Archivos secuenciales.
- Registros de longitud fija.
- Definición de estructuras mediante FD.
- Cláusulas RECORD CONTAINS y RECORDING MODE IS F.
- Lectura secuencial con READ.
- Detección del fin de archivo mediante AT END.
- Claves de control.
- Corte de control.
- Acumuladores.
- Procesamiento por grupos.
- Generación de reportes.
- Manejo de archivos de entrada y salida.
- Campos numéricos con posiciones decimales implícitas.
- Formateo de importes para reportes.

## Objetivo de aprendizaje

El objetivo principal es comprender el patrón de corte de control y su aplicación en programas COBOL batch.

Este patrón es especialmente importante en procesamiento de archivos ordenados por una clave, donde se necesita obtener subtotales por grupo y posteriormente totales generales.

La implementación busca representar una situación similar a la que puede encontrarse en procesos batch tradicionales de entornos Mainframe.

## Resultado

La lección demuestra un procesamiento completo de principio a fin:

1. Lectura de un archivo de movimientos.
2. Identificación de la clave de control.
3. Agrupación de registros por cuenta.
4. Acumulación de créditos y débitos.
5. Detección del cambio de cuenta.
6. Emisión del subtotal de cada grupo.
7. Tratamiento explícito del último grupo.
8. Cálculo de los totales generales.
9. Generación del reporte final.

