       IDENTIFICATION DIVISION.
       PROGRAM-ID. ABM-CLIENTES.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT ARCHIVO-CLIENTES
               ASSIGN TO
               "lecciones/01-abm/datos/entrada/maestro-clientes.dat"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-CLIENTES.

           SELECT ARCHIVO-SOLICITUDES
               ASSIGN TO
               "lecciones/01-abm/datos/entrada/solicitudes-clientes.dat"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-SOLICITUDES.

           SELECT ARCHIVO-NUEVO-CLIENTES
               ASSIGN TO
               "lecciones/01-abm/datos/salida/maestro-clientes-nuevo.dat"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-NUEVO-CLIENTE.

           SELECT ARCHIVO-REPORTE
               ASSIGN TO
               "lecciones/01-abm/datos/salida/reporte-abm.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-ESTADO-REPORTE.

       DATA DIVISION.
       FILE SECTION.

       FD  ARCHIVO-CLIENTES.
       01  REGISTRO-ENTRADA-CLIENTE.
           05  DATOS-ENTRADA-CLIENTE PIC X(50).

       FD  ARCHIVO-SOLICITUDES.
       01  REGISTRO-ENTRADA-SOLICITUD.
           05  DATOS-ENTRADA-SOLICITUD PIC X(50).

       FD  ARCHIVO-NUEVO-CLIENTES.
       01  REGISTRO-SALIDA-CLIENTE.
           05  DATOS-SALIDA-CLIENTE PIC X(50).

       FD  ARCHIVO-REPORTE.
       01  REGISTRO-SALIDA-REPORTE PIC X(100).

       WORKING-STORAGE SECTION.

       COPY "copybooks/REGISTRO-CLIENTE.CPY".

       01  WS-ESTADO-CLIENTES          PIC XX.
       01  WS-ESTADO-SOLICITUDES           PIC XX.
       01  WS-ESTADO-NUEVO-CLIENTE      PIC XX.
       01  WS-ESTADO-REPORTE            PIC XX.
       01  WS-FIN-CLIENTES             PIC X     VALUE "N".
       01  WS-FIN-SOLICITUDES              PIC X     VALUE "N".
       01  WS-CLIENTE-ENCONTRADO           PIC X     VALUE "N".
       01  WS-CANTIDAD-CLIENTES           PIC 9(4)  VALUE 0.
       01  WS-CANTIDAD-SOLICITUDES            PIC 9(4)  VALUE 0.
       01  WS-CANTIDAD-ALTAS                PIC 9(4)  VALUE 0.
       01  WS-CANTIDAD-MODIFICACIONES             PIC 9(4)  VALUE 0.
       01  WS-CANTIDAD-BAJAS             PIC 9(4)  VALUE 0.
       01  WS-CANTIDAD-ERRORES              PIC 9(4)  VALUE 0.
       01  WS-RESULTADO-SOLICITUD           PIC X(100).
       01  WS-INDICE-TABLA              PIC 9(4).
       01  WS-INDICE-ENCONTRADO              PIC 9(4)  VALUE 0.
       01  WS-REGISTRO-ENCONTRADO              PIC X     VALUE "N".
       01  WS-TABLA-CLIENTES.
           05  WS-REGISTRO-CLIENTE       OCCURS 100 TIMES.
               10  WS-REGISTRO-TABLA     PIC X(50).

       PROCEDURE DIVISION.

       PROCESO-PRINCIPAL.

           DISPLAY "========================================"
           DISPLAY "             ABM DE CLIENTES"
           DISPLAY "========================================"

           PERFORM ABRIR-ARCHIVOS-ENTRADA

           IF RETURN-CODE = 0
               PERFORM CARGAR-CLIENTES
           END-IF

           IF RETURN-CODE = 0
               PERFORM PROCESAR-SOLICITUDES
           END-IF

           IF RETURN-CODE = 0
               PERFORM ESCRIBIR-NUEVO-MAESTRO
           END-IF

           PERFORM CERRAR-ARCHIVOS-ENTRADA

           DISPLAY "========================================"
           DISPLAY "CLIENTES CARGADOS:      " WS-CANTIDAD-CLIENTES
           DISPLAY "SOLICITUDES PROCESADAS: " WS-CANTIDAD-SOLICITUDES
           DISPLAY "ALTAS:                  " WS-CANTIDAD-ALTAS
           DISPLAY "MODIFICACIONES:         " WS-CANTIDAD-MODIFICACIONES
           DISPLAY "BAJAS:                  " WS-CANTIDAD-BAJAS
           DISPLAY "ERRORES:                " WS-CANTIDAD-ERRORES
           DISPLAY "RETURN-CODE:           " RETURN-CODE
           DISPLAY "========================================"

           STOP RUN.

       ABRIR-ARCHIVOS-ENTRADA.

           OPEN INPUT ARCHIVO-CLIENTES

           IF WS-ESTADO-CLIENTES NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE CLIENTES: "
                   WS-ESTADO-CLIENTES
               MOVE 8 TO RETURN-CODE
               GO TO FIN-APERTURA-ARCHIVOS
           END-IF

           OPEN INPUT ARCHIVO-SOLICITUDES

           IF WS-ESTADO-SOLICITUDES NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE SOLICITUDES: "
                   WS-ESTADO-SOLICITUDES
               MOVE 8 TO RETURN-CODE
               GO TO FIN-APERTURA-ARCHIVOS
           END-IF

           OPEN OUTPUT ARCHIVO-REPORTE

           IF WS-ESTADO-REPORTE NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE REPORTE: "
                   WS-ESTADO-REPORTE
               MOVE 8 TO RETURN-CODE
           END-IF.

       FIN-APERTURA-ARCHIVOS.
           EXIT.

       CARGAR-CLIENTES.

           MOVE "N" TO WS-FIN-CLIENTES

           PERFORM UNTIL WS-FIN-CLIENTES = "Y"

               READ ARCHIVO-CLIENTES

                   AT END
                       MOVE "Y" TO WS-FIN-CLIENTES

                   NOT AT END
                       ADD 1 TO WS-CANTIDAD-CLIENTES

                       MOVE DATOS-ENTRADA-CLIENTE
                           TO WS-REGISTRO-TABLA
                              (WS-CANTIDAD-CLIENTES)

               END-READ

           END-PERFORM.

       PROCESAR-SOLICITUDES.

           MOVE "N" TO WS-FIN-SOLICITUDES

           PERFORM UNTIL WS-FIN-SOLICITUDES = "Y"

               READ ARCHIVO-SOLICITUDES

                   AT END
                       MOVE "Y" TO WS-FIN-SOLICITUDES

                   NOT AT END
                       ADD 1 TO WS-CANTIDAD-SOLICITUDES

                       MOVE DATOS-ENTRADA-SOLICITUD
                           TO SOLICITUD-CLIENTE

                       EVALUATE OPERACION-SOLICITUD

                           WHEN "A"
                               PERFORM PROCESAR-ALTA

                           WHEN "M"
                               PERFORM PROCESAR-MODIFICACION

                           WHEN "D"
                               PERFORM PROCESAR-BAJA

                           WHEN OTHER
                               STRING
                                   "OPERACION INVALIDA - "
                                   OPERACION-SOLICITUD
                                   DELIMITED BY SIZE
                                   INTO WS-RESULTADO-SOLICITUD
                               END-STRING

                               ADD 1 TO WS-CANTIDAD-ERRORES

                               PERFORM ESCRIBIR-RESULTADO

                       END-EVALUATE

               END-READ

           END-PERFORM.

       PROCESAR-ALTA.

           MOVE SPACES TO WS-RESULTADO-SOLICITUD

           PERFORM BUSCAR-CLIENTE

           IF WS-REGISTRO-ENCONTRADO = "Y"

               STRING
                   "ALTA       "
                   ID-SOLICITUD
                   " ERROR: CLIENTE YA EXISTE"
                   DELIMITED BY SIZE
                   INTO WS-RESULTADO-SOLICITUD
               END-STRING

               ADD 1 TO WS-CANTIDAD-ERRORES

           ELSE

               IF WS-CANTIDAD-CLIENTES < 100

                   ADD 1 TO WS-CANTIDAD-CLIENTES

                   MOVE ID-SOLICITUD          TO ID-CLIENTE
                   MOVE NOMBRE-SOLICITUD        TO NOMBRE-CLIENTE
                   MOVE SUCURSAL-SOLICITUD      TO SUCURSAL-CLIENTE
                   MOVE TIPO-CUENTA-SOLICITUD   TO TIPO-CUENTA
                   MOVE ESTADO-SOLICITUD      TO ESTADO-CLIENTE
                   MOVE SALDO-SOLICITUD     TO SALDO-CLIENTE
                   MOVE RESERVADO-SOLICITUD    TO RESERVADO-CLIENTE

                   MOVE REGISTRO-CLIENTE     TO WS-REGISTRO-TABLA
                                            (WS-CANTIDAD-CLIENTES)

                   STRING
                       "ALTA       "
                       ID-SOLICITUD
                       " OK"
                       DELIMITED BY SIZE
                       INTO WS-RESULTADO-SOLICITUD
                   END-STRING

                   ADD 1 TO WS-CANTIDAD-ALTAS

               ELSE

                   STRING
                       "ALTA       "
                       ID-SOLICITUD
                       " ERROR: TABLA COMPLETA"
                       DELIMITED BY SIZE
                       INTO WS-RESULTADO-SOLICITUD
                   END-STRING

                   ADD 1 TO WS-CANTIDAD-ERRORES

               END-IF

           END-IF

           PERFORM ESCRIBIR-RESULTADO.

       PROCESAR-MODIFICACION.

           MOVE SPACES TO WS-RESULTADO-SOLICITUD

           PERFORM BUSCAR-CLIENTE

           IF WS-REGISTRO-ENCONTRADO = "Y"
               MOVE ID-SOLICITUD         TO ID-CLIENTE
               MOVE NOMBRE-SOLICITUD       TO NOMBRE-CLIENTE
               MOVE SUCURSAL-SOLICITUD     TO SUCURSAL-CLIENTE
               MOVE TIPO-CUENTA-SOLICITUD  TO TIPO-CUENTA
               MOVE ESTADO-SOLICITUD     TO ESTADO-CLIENTE
               MOVE SALDO-SOLICITUD    TO SALDO-CLIENTE
               MOVE RESERVADO-SOLICITUD   TO RESERVADO-CLIENTE

               MOVE REGISTRO-CLIENTE    TO WS-REGISTRO-TABLA
                                       (WS-INDICE-ENCONTRADO)

               STRING
                   "MODIFICAR  "
                   ID-SOLICITUD
                   " OK"
                   DELIMITED BY SIZE
                   INTO WS-RESULTADO-SOLICITUD
               END-STRING

               ADD 1 TO WS-CANTIDAD-MODIFICACIONES
           ELSE
               STRING
                   "MODIFICAR  "
                   ID-SOLICITUD
                   " ERROR: CLIENTE NO ENCONTRADO"
                   DELIMITED BY SIZE
                   INTO WS-RESULTADO-SOLICITUD
               END-STRING

               ADD 1 TO WS-CANTIDAD-ERRORES
           END-IF

           PERFORM ESCRIBIR-RESULTADO.

       PROCESAR-BAJA.

           MOVE SPACES TO WS-RESULTADO-SOLICITUD
           
           PERFORM BUSCAR-CLIENTE

           IF WS-REGISTRO-ENCONTRADO = "Y"

               PERFORM ELIMINAR-CLIENTE

               STRING
                   "BAJA       "
                   ID-SOLICITUD
                   " OK"
                   DELIMITED BY SIZE
                   INTO WS-RESULTADO-SOLICITUD
               END-STRING

               ADD 1 TO WS-CANTIDAD-BAJAS

           ELSE

               STRING
                   "BAJA       "
                   ID-SOLICITUD
                   " ERROR: CLIENTE NO ENCONTRADO"
                   DELIMITED BY SIZE
                   INTO WS-RESULTADO-SOLICITUD
               END-STRING

               ADD 1 TO WS-CANTIDAD-ERRORES

           END-IF

           PERFORM ESCRIBIR-RESULTADO.

       BUSCAR-CLIENTE.

           MOVE "N" TO WS-REGISTRO-ENCONTRADO
           MOVE 0 TO WS-INDICE-TABLA
           MOVE 0 TO WS-INDICE-ENCONTRADO

           PERFORM VARYING WS-INDICE-TABLA FROM 1 BY 1
               UNTIL WS-INDICE-TABLA > WS-CANTIDAD-CLIENTES
                  OR WS-REGISTRO-ENCONTRADO = "Y"

               IF WS-REGISTRO-TABLA(WS-INDICE-TABLA)(1:6)
                   = ID-SOLICITUD

                   MOVE "Y" TO WS-REGISTRO-ENCONTRADO
                   MOVE WS-INDICE-TABLA TO WS-INDICE-ENCONTRADO

               END-IF

           END-PERFORM.

       ELIMINAR-CLIENTE.

           PERFORM VARYING WS-INDICE-TABLA
               FROM WS-INDICE-ENCONTRADO BY 1
               UNTIL WS-INDICE-TABLA >= WS-CANTIDAD-CLIENTES

               MOVE WS-REGISTRO-TABLA(WS-INDICE-TABLA + 1)
                   TO WS-REGISTRO-TABLA(WS-INDICE-TABLA)

           END-PERFORM

           MOVE SPACES
               TO WS-REGISTRO-TABLA(WS-CANTIDAD-CLIENTES)

           SUBTRACT 1 FROM WS-CANTIDAD-CLIENTES.

       ESCRIBIR-NUEVO-MAESTRO.

           OPEN OUTPUT ARCHIVO-NUEVO-CLIENTES

           IF WS-ESTADO-NUEVO-CLIENTE NOT = "00"

               DISPLAY "ERROR AL ABRIR NUEVO ARCHIVO MAESTRO: "
                   WS-ESTADO-NUEVO-CLIENTE

               MOVE 8 TO RETURN-CODE

           ELSE

               PERFORM VARYING WS-INDICE-TABLA
                   FROM 1 BY 1
                   UNTIL WS-INDICE-TABLA > WS-CANTIDAD-CLIENTES

                   MOVE WS-REGISTRO-TABLA(WS-INDICE-TABLA)
                       TO DATOS-SALIDA-CLIENTE

                   WRITE REGISTRO-SALIDA-CLIENTE

               END-PERFORM

               CLOSE ARCHIVO-NUEVO-CLIENTES

           END-IF.

       ESCRIBIR-RESULTADO.

           DISPLAY WS-RESULTADO-SOLICITUD

           MOVE WS-RESULTADO-SOLICITUD
               TO REGISTRO-SALIDA-REPORTE

           WRITE REGISTRO-SALIDA-REPORTE.

       CERRAR-ARCHIVOS-ENTRADA.

           CLOSE ARCHIVO-CLIENTES
           CLOSE ARCHIVO-SOLICITUDES
           CLOSE ARCHIVO-REPORTE.

       END PROGRAM ABM-CLIENTES.
