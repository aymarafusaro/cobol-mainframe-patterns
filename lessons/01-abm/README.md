# Lección 01 — ABM de clientes

## Objetivo

Implementar un proceso batch en COBOL que permita realizar operaciones de **Alta, Modificación y Baja (ABM)** sobre un archivo maestro de clientes.

El ejercicio está diseñado para practicar estructuras y patrones habituales de procesamiento **Mainframe COBOL**, utilizando archivos secuenciales de longitud fija.

## Conceptos practicados

* COBOL Batch
* Archivos secuenciales
* Registros de longitud fija
* Copybooks
* Alta de registros
* Modificación de registros
* Baja de registros
* Búsqueda por clave
* Validación de operaciones
* Manejo de errores
* Código de retorno
* Reporte de resultados

## Estructura

```text
01-abm/
├── CUSTOMER-ABM.CBL
├── README.md
├── data/
│   ├── input/
│   │   ├── customer-master.dat
│   │   └── customer-requests.dat
│   └── output/
│       ├── customer-master-new.dat
│       └── abm-report.txt
├── tests/
└── deployment/
```

El layout de los registros se encuentra definido en:

```text
../../copybooks/CUSTOMER-RECORD.CPY
```

## Formato de los archivos

Los archivos de entrada y salida principales utilizan **registros de longitud fija de 50 bytes**.

No se utilizan:

* CSV
* comas
* `|`
* delimitadores de campos
* saltos de línea entre registros

Cada posición del registro tiene un significado determinado por el layout COBOL.

### Registro de cliente

| Campo          | Longitud |
| -------------- | -------: |
| ID de cliente  |        6 |
| Nombre         |       20 |
| Sucursal       |        3 |
| Tipo de cuenta |        2 |
| Estado         |        1 |
| Saldo          |       12 |
| Reservado      |        6 |
| **Total**      |   **50** |

Los espacios necesarios para completar los campos se definen mediante cláusulas `PIC X(n)` en el copybook.

### Registro de solicitud

| Campo          | Longitud |
| -------------- | -------: |
| Operación      |        1 |
| ID de cliente  |        6 |
| Nombre         |       20 |
| Sucursal       |        3 |
| Tipo de cuenta |        2 |
| Estado         |        1 |
| Saldo          |       12 |
| Reservado      |        5 |
| **Total**      |   **50** |

## Operaciones ABM

Las solicitudes utilizan una operación de un carácter:

| Operación | Significado  |
| --------- | ------------ |
| `A`       | Alta         |
| `M`       | Modificación |
| `D`       | Baja         |

### Alta

Agrega un nuevo cliente al archivo maestro.

La operación genera un error si el ID ya existe.

### Modificación

Busca un cliente por su ID y actualiza sus datos.

Si el cliente no existe, la operación genera un error.

### Baja

Busca un cliente por su ID y lo elimina del conjunto de registros procesados.

Si el cliente no existe, la operación genera un error.

## Procesamiento

El programa realiza las siguientes etapas:

1. Abre el archivo maestro.
2. Carga los registros de clientes en memoria.
3. Abre el archivo de solicitudes.
4. Procesa cada solicitud.
5. Busca el cliente por ID cuando corresponde.
6. Ejecuta la operación ABM.
7. Registra el resultado de cada operación.
8. Genera un nuevo archivo maestro.
9. Genera un reporte de resultados.
10. Muestra un resumen del procesamiento.
11. Finaliza con un código de retorno.

## Casos de prueba

El archivo `customer-requests.dat` contiene cinco solicitudes:

| Operación    | Cliente | Resultado esperado         |
| ------------ | ------- | -------------------------- |
| Alta         | 000006  | Correcta                   |
| Modificación | 000002  | Correcta                   |
| Baja         | 000003  | Correcta                   |
| Alta         | 000002  | Error: cliente existente   |
| Modificación | 000999  | Error: cliente inexistente |

## Resultado esperado

El procesamiento debe producir:

```text
ALTA       000006 OK
MODIFICAR  000002 OK
BAJA       000003 OK
ALTA       000002 ERROR: CLIENTE YA EXISTE
MODIFICAR  000999 ERROR: CLIENTE NO ENCONTRADO
```

Resumen:

```text
CLIENTES CARGADOS:    0005
SOLICITUDES:          0005
ALTAS:                0001
MODIFICACIONES:       0001
BAJAS:                0001
ERRORES:              0002
RETURN-CODE:         +000000000
```

## Compilación

Desde la raíz del repositorio:

```bash
cobc -x -free \
    -o lessons/01-abm/customer-abm \
    lessons/01-abm/CUSTOMER-ABM.CBL
```

## Ejecución

Antes de ejecutar nuevamente el programa:

```bash
rm -f lessons/01-abm/data/output/customer-master-new.dat
rm -f lessons/01-abm/data/output/abm-report.txt
```

Luego:

```bash
./lessons/01-abm/customer-abm
```

## Verificación del archivo maestro

El archivo generado debe contener 5 registros de 50 bytes:

```bash
wc -c lessons/01-abm/data/output/customer-master-new.dat
```

Resultado esperado:

```text
250
```

Esto permite comprobar que:

```text
5 registros × 50 bytes = 250 bytes
```

El archivo no utiliza separadores ni saltos de línea entre registros.

## Verificación del reporte

El reporte contiene una línea por cada solicitud:

```bash
wc -l lessons/01-abm/data/output/abm-report.txt
```

Resultado esperado:

```text
5
```

## Código de retorno

El programa utiliza `RETURN-CODE` para indicar el resultado general de la ejecución.

En la ejecución validada:

```text
RETURN-CODE: +000000000
```

El código `0` indica que el proceso terminó correctamente.

## Próximos pasos

Las siguientes lecciones incorporarán otros patrones clásicos de procesamiento batch:

* **Lección 02 — Corte de control**
* **Lección 03 — Apareo de archivos**
