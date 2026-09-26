       IDENTIFICATION DIVISION.
       PROGRAM-ID. APAREO-ARCHIVOS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       
           SELECT ARCHIVO-MAESTRO
               ASSIGN TO
       "lecciones/03-apareo-archivos/datos/entrada/maestro-clientes.dat"
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-MAESTRO.
       
           SELECT ARCHIVO-MOVIMIENTOS
               ASSIGN TO
   "lecciones/03-apareo-archivos/datos/entrada/movimientos-clientes.dat"
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-MOVIMIENTOS.
       
           SELECT ARCHIVO-SALIDA
               ASSIGN TO
"lecciones/03-apareo-archivos/datos/salida/maestro-clientes-actualizado.dat"
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-SALIDA.
       
           SELECT ARCHIVO-REPORTE
               ASSIGN TO
          "lecciones/03-apareo-archivos/datos/salida/reporte-apareo.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-REPORTE.
       
       DATA DIVISION.
       FILE SECTION.
       
       FD  ARCHIVO-MAESTRO
           RECORD CONTAINS 36 CHARACTERS
           RECORDING MODE IS F.
       
       01  REGISTRO-MAESTRO.
           05  CUENTA-MAESTRO          PIC X(6).
           05  NOMBRE-MAESTRO          PIC X(20).
           05  SALDO-MAESTRO           PIC 9(8)V99.
       
       FD  ARCHIVO-MOVIMIENTOS
           RECORD CONTAINS 20 CHARACTERS
           RECORDING MODE IS F.
       
       01  REGISTRO-MOVIMIENTO.
           05  CUENTA-MOVIMIENTO       PIC X(6).
           05  TIPO-MOVIMIENTO         PIC X(1).
           05  IMPORTE-MOVIMIENTO      PIC 9(10)V99.
           05  RESERVADO-MOVIMIENTO    PIC X(1).
       
       FD  ARCHIVO-SALIDA
           RECORD CONTAINS 36 CHARACTERS
           RECORDING MODE IS F.
       
       01  REGISTRO-MAESTRO-SALIDA.
           05  CUENTA-SALIDA           PIC X(6).
           05  NOMBRE-SALIDA           PIC X(20).
           05  SALDO-SALIDA            PIC 9(8)V99.
       
       FD  ARCHIVO-REPORTE
           RECORD CONTAINS 100 CHARACTERS
           RECORDING MODE IS V.
       
       01  REGISTRO-REPORTE            PIC X(100).
       
       WORKING-STORAGE SECTION.
       
       01  WS-ESTADO-MAESTRO           PIC XX.
       01  WS-ESTADO-MOVIMIENTOS       PIC XX.
       01  WS-ESTADO-SALIDA            PIC XX.
       01  WS-ESTADO-REPORTE           PIC XX.
       01  WS-FIN-MAESTRO              PIC X          VALUE "N".
       01  WS-FIN-MOVIMIENTOS          PIC X          VALUE "N".
       01  WS-CUENTA-MAESTRO-ACTUAL    PIC X(6).
       01  WS-CUENTA-MOVIMIENTO-ACTUAL PIC X(6).
       01  WS-CANTIDAD-ACTUALIZADOS    PIC 9(5)       VALUE ZERO.
       01  WS-CANTIDAD-SIN-MAESTRO     PIC 9(5)       VALUE ZERO.
       01  WS-CANTIDAD-MAESTROS        PIC 9(5)       VALUE ZERO.
       01  WS-CANTIDAD-MOVIMIENTOS     PIC 9(5)       VALUE ZERO.
       01  WS-CUENTAS-IGUALES          PIC X          VALUE "N".
       01  WS-SALDO-ACTUAL             PIC 9(8)V99    VALUE ZERO.
       
       PROCEDURE DIVISION.
       
       0000-INICIO.
       
           DISPLAY "========================================".
           DISPLAY "       APAREO DE ARCHIVOS".
           DISPLAY "========================================".
       
           OPEN INPUT ARCHIVO-MAESTRO
                      ARCHIVO-MOVIMIENTOS
                OUTPUT ARCHIVO-SALIDA
                       ARCHIVO-REPORTE.
       
           IF WS-ESTADO-MAESTRO NOT = "00"
               DISPLAY "ERROR APERTURA MAESTRO: " WS-ESTADO-MAESTRO
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF.
       
           IF WS-ESTADO-MOVIMIENTOS NOT = "00"
               DISPLAY "ERROR APERTURA MOVIMIENTOS: "
                   WS-ESTADO-MOVIMIENTOS
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF.
       
           IF WS-ESTADO-SALIDA NOT = "00"
               DISPLAY "ERROR APERTURA SALIDA: "  WS-ESTADO-SALIDA
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF.
       
           IF WS-ESTADO-REPORTE NOT = "00"
               DISPLAY "ERROR APERTURA REPORTE: " WS-ESTADO-REPORTE
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF.
       
           DISPLAY "ARCHIVOS ABIERTOS CORRECTAMENTE".

           READ ARCHIVO-MAESTRO
               AT END
                   MOVE "S" TO WS-FIN-MAESTRO
               NOT AT END
                   MOVE CUENTA-MAESTRO
                       TO WS-CUENTA-MAESTRO-ACTUAL
           END-READ.
       
           READ ARCHIVO-MOVIMIENTOS
               AT END
                   MOVE "S" TO WS-FIN-MOVIMIENTOS
               NOT AT END
                   MOVE CUENTA-MOVIMIENTO
                       TO WS-CUENTA-MOVIMIENTO-ACTUAL
           END-READ.
       
           PERFORM UNTIL WS-FIN-MAESTRO = "S"
                        AND WS-FIN-MOVIMIENTOS = "S"
       
               IF WS-FIN-MAESTRO = "S"
       
                   ADD 1 TO WS-CANTIDAD-SIN-MAESTRO
       
                   READ ARCHIVO-MOVIMIENTOS
                       AT END
                           MOVE "S" TO WS-FIN-MOVIMIENTOS
                   END-READ
       
               ELSE
                   IF WS-FIN-MOVIMIENTOS = "S"
       
                       MOVE CUENTA-MAESTRO  TO CUENTA-SALIDA
                       MOVE NOMBRE-MAESTRO  TO NOMBRE-SALIDA
                       MOVE SALDO-MAESTRO   TO SALDO-SALIDA
       
                       WRITE REGISTRO-MAESTRO-SALIDA

                       ADD 1 TO WS-CANTIDAD-MAESTROS
       
                       READ ARCHIVO-MAESTRO
                           AT END
                               MOVE "S" TO WS-FIN-MAESTRO
                       END-READ
       
                   ELSE
       
                       IF CUENTA-MAESTRO = CUENTA-MOVIMIENTO
       
                           MOVE SALDO-MAESTRO    TO WS-SALDO-ACTUAL
       
                           PERFORM UNTIL WS-FIN-MOVIMIENTOS = "S"
                                        OR CUENTA-MOVIMIENTO
                                           NOT = CUENTA-MAESTRO
       
                               IF TIPO-MOVIMIENTO = "C"
                                   ADD IMPORTE-MOVIMIENTO
                                       TO WS-SALDO-ACTUAL
                               ELSE
                                   IF TIPO-MOVIMIENTO = "D"
                                       SUBTRACT IMPORTE-MOVIMIENTO
                                           FROM WS-SALDO-ACTUAL
                                   END-IF
                               END-IF

                               ADD 1 TO WS-CANTIDAD-MOVIMIENTOS
       
                               READ ARCHIVO-MOVIMIENTOS
                                   AT END
                                       MOVE "S" TO WS-FIN-MOVIMIENTOS
                               END-READ
       
                           END-PERFORM
       
                           MOVE CUENTA-MAESTRO   TO CUENTA-SALIDA
                           MOVE NOMBRE-MAESTRO   TO NOMBRE-SALIDA
                           MOVE WS-SALDO-ACTUAL  TO SALDO-SALIDA
       
                           WRITE REGISTRO-MAESTRO-SALIDA
       
                           ADD 1 TO WS-CANTIDAD-ACTUALIZADOS

                           ADD 1 TO WS-CANTIDAD-MAESTROS
       
                           READ ARCHIVO-MAESTRO
                               AT END
                                   MOVE "S" TO WS-FIN-MAESTRO
                           END-READ
       
                       ELSE
                           IF CUENTA-MAESTRO < CUENTA-MOVIMIENTO
       
                               MOVE CUENTA-MAESTRO TO CUENTA-SALIDA
                               MOVE NOMBRE-MAESTRO TO NOMBRE-SALIDA
                               MOVE SALDO-MAESTRO  TO SALDO-SALIDA
       
                               WRITE REGISTRO-MAESTRO-SALIDA

                               ADD 1 TO WS-CANTIDAD-MAESTROS
       
                               READ ARCHIVO-MAESTRO
                                   AT END
                                       MOVE "S" TO WS-FIN-MAESTRO
                               END-READ
       
                           ELSE
       
                               ADD 1 TO WS-CANTIDAD-SIN-MAESTRO
       
                               DISPLAY "MOVIMIENTO SIN MAESTRO: "
                                   CUENTA-MOVIMIENTO
       
                               READ ARCHIVO-MOVIMIENTOS
                                   AT END
                                       MOVE "S" TO WS-FIN-MOVIMIENTOS
                               END-READ
       
                           END-IF
                       END-IF
       
                   END-IF
               END-IF
       
           END-PERFORM.
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "========================================"
               TO REGISTRO-REPORTE
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "          REPORTE DE APAREO"
               TO REGISTRO-REPORTE
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "========================================"
               TO REGISTRO-REPORTE
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "MAESTROS PROCESADOS:     "
               TO REGISTRO-REPORTE(1:22)
       
           MOVE WS-CANTIDAD-MAESTROS
               TO REGISTRO-REPORTE(23:5)
       
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "CUENTAS ACTUALIZADAS:    "
               TO REGISTRO-REPORTE(1:22)
       
           MOVE WS-CANTIDAD-ACTUALIZADOS
               TO REGISTRO-REPORTE(23:5)
       
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "MOVIMIENTOS APLICADOS:  "
               TO REGISTRO-REPORTE(1:23)
       
           MOVE WS-CANTIDAD-MOVIMIENTOS
               TO REGISTRO-REPORTE(24:5)
       
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "MOVIMIENTOS SIN MAESTRO: "
               TO REGISTRO-REPORTE(1:25)
       
           MOVE WS-CANTIDAD-SIN-MAESTRO
               TO REGISTRO-REPORTE(26:5)
       
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "RETURN-CODE: 000000000"
               TO REGISTRO-REPORTE
           WRITE REGISTRO-REPORTE
       
           MOVE SPACES TO REGISTRO-REPORTE
           MOVE "========================================"
               TO REGISTRO-REPORTE
           WRITE REGISTRO-REPORTE
           
           CLOSE ARCHIVO-MAESTRO
                 ARCHIVO-MOVIMIENTOS
                 ARCHIVO-SALIDA
                 ARCHIVO-REPORTE.
       
           MOVE 0 TO RETURN-CODE.
       
           STOP RUN.
       