       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORTE-CONTROL.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT ARCHIVO-MOVIMIENTOS
               ASSIGN TO
      "lecciones/02-corte-control/datos/entrada/movimientos-cuentas.dat"
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-ARCHIVO.

           SELECT ARCHIVO-REPORTE
               ASSIGN TO
     "lecciones/02-corte-control/datos/salida/reporte-corte-control.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ESTADO-REPORTE.

       DATA DIVISION.
       FILE SECTION.

       FD  ARCHIVO-MOVIMIENTOS
           RECORD CONTAINS 30 CHARACTERS
           RECORDING MODE IS F.

       01  REGISTRO-MOVIMIENTO.
           05  CUENTA-MOVIMIENTO       PIC X(6).
           05  FECHA-MOVIMIENTO        PIC X(8).
           05  TIPO-MOVIMIENTO         PIC X(1).
           05  IMPORTE-MOVIMIENTO      PIC 9(10)V99.
           05  RESERVADO-MOVIMIENTO    PIC X(3).

       FD  ARCHIVO-REPORTE
           RECORD CONTAINS 100 CHARACTERS
           RECORDING MODE IS V.

       01  REGISTRO-REPORTE            PIC X(100).

       WORKING-STORAGE SECTION.

       01  WS-ESTADO-ARCHIVO           PIC XX.
       01  WS-ESTADO-REPORTE           PIC XX.
       01  WS-FIN-ARCHIVO              PIC X          VALUE "N".
       01  WS-CUENTA-ANTERIOR          PIC X(6).
       01  WS-CANTIDAD-MOVIMIENTOS     PIC 9(5)       VALUE ZERO.
       01  WS-TOTAL-CREDITOS           PIC 9(10)V99   VALUE ZERO.
       01  WS-TOTAL-DEBITOS            PIC 9(10)V99   VALUE ZERO.
       01  WS-TOTAL-NETO               PIC S9(10)V99  VALUE ZERO.
       01  WS-GRAL-MOVIMIENTOS         PIC 9(6)       VALUE ZERO.
       01  WS-GRAL-CREDITOS            PIC 9(10)V99   VALUE ZERO.
       01  WS-GRAL-DEBITOS             PIC 9(10)V99   VALUE ZERO.
       01  WS-GRAL-NETO                PIC S9(10)V99  VALUE ZERO.
       01  WS-LINEA-REPORTE            PIC X(100).
       01  WS-CREDITOS-EDITADO         PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-DEBITOS-EDITADO          PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-NETO-EDITADO             PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-SIGNO-NETO               PIC X.
       01  WS-GRAL-CREDITOS-EDITADO    PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-GRAL-DEBITOS-EDITADO     PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-GRAL-NETO-EDITADO        PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-GRAL-SIGNO-NETO          PIC X.

       PROCEDURE DIVISION.

       PROCESO-PRINCIPAL.

           DISPLAY "-------------------------"
           DISPLAY "INICIO CORTE DE CONTROL"
           DISPLAY "-------------------------".

           OPEN INPUT ARCHIVO-MOVIMIENTOS
                OUTPUT ARCHIVO-REPORTE.

           IF WS-ESTADO-ARCHIVO NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE MOVIMIENTOS"
               DISPLAY "FILE STATUS: " WS-ESTADO-ARCHIVO
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF.

           IF WS-ESTADO-REPORTE NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE REPORTE"
               DISPLAY "FILE STATUS: " WS-ESTADO-REPORTE
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF.

           DISPLAY "ARCHIVOS ABIERTOS CORRECTAMENTE".

           MOVE SPACES
               TO WS-LINEA-REPORTE

           MOVE "======================================================"
               TO WS-LINEA-REPORTE
           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE
           
           MOVE "             REPORTE DE CORTE DE CONTROL"
               TO WS-LINEA-REPORTE
           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE
           
           MOVE "======================================================"
               TO WS-LINEA-REPORTE
           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE
           
           MOVE SPACES
               TO WS-LINEA-REPORTE
           
           MOVE "CUENTA   MOV.      CREDITOS       DEBITOS         NETO"
               TO WS-LINEA-REPORTE
           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE
           
           MOVE "------   ----   -----------   -----------   ----------"
               TO WS-LINEA-REPORTE
           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE

           READ ARCHIVO-MOVIMIENTOS
               AT END
                   MOVE "S" TO WS-FIN-ARCHIVO
           END-READ.

           IF WS-FIN-ARCHIVO = "N"
               DISPLAY "-------------------------"
               DISPLAY "PRIMERA CUENTA: " CUENTA-MOVIMIENTO
               DISPLAY "FECHA: " FECHA-MOVIMIENTO
               DISPLAY "TIPO: " TIPO-MOVIMIENTO
               DISPLAY "IMPORTE: " IMPORTE-MOVIMIENTO
           END-IF.

           IF WS-FIN-ARCHIVO = "N"
               MOVE CUENTA-MOVIMIENTO
                   TO WS-CUENTA-ANTERIOR

               MOVE 1
                   TO WS-CANTIDAD-MOVIMIENTOS

               IF TIPO-MOVIMIENTO = "C"
                   ADD IMPORTE-MOVIMIENTO
                       TO WS-TOTAL-CREDITOS
               END-IF

               IF TIPO-MOVIMIENTO = "D"
                   ADD IMPORTE-MOVIMIENTO
                       TO WS-TOTAL-DEBITOS
               END-IF

               ADD 1 TO WS-GRAL-MOVIMIENTOS

               IF TIPO-MOVIMIENTO = "C"
                   ADD IMPORTE-MOVIMIENTO
                       TO WS-GRAL-CREDITOS
               END-IF

               IF TIPO-MOVIMIENTO = "D"
                   ADD IMPORTE-MOVIMIENTO
                       TO WS-GRAL-DEBITOS
               END-IF
           END-IF.

           PERFORM UNTIL WS-FIN-ARCHIVO = "S"

               READ ARCHIVO-MOVIMIENTOS
                   AT END
                       MOVE "S" TO WS-FIN-ARCHIVO
               END-READ

               IF WS-FIN-ARCHIVO = "N"

                   IF CUENTA-MOVIMIENTO = WS-CUENTA-ANTERIOR

                       ADD 1
                           TO WS-CANTIDAD-MOVIMIENTOS

                       IF TIPO-MOVIMIENTO = "C"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-TOTAL-CREDITOS
                       END-IF

                       IF TIPO-MOVIMIENTO = "D"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-TOTAL-DEBITOS
                       END-IF

                       ADD 1 TO WS-GRAL-MOVIMIENTOS

                       IF TIPO-MOVIMIENTO = "C"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-GRAL-CREDITOS
                       END-IF

                       IF TIPO-MOVIMIENTO = "D"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-GRAL-DEBITOS
                       END-IF

                   ELSE

                       DISPLAY "-------------------------"
                       DISPLAY "CAMBIO DE CUENTA: "
                           WS-CUENTA-ANTERIOR

                       DISPLAY "MOVIMIENTOS: "
                           WS-CANTIDAD-MOVIMIENTOS

                       COMPUTE WS-TOTAL-NETO =
                           WS-TOTAL-CREDITOS -
                           WS-TOTAL-DEBITOS

                       MOVE WS-TOTAL-CREDITOS
                           TO WS-CREDITOS-EDITADO

                       MOVE WS-TOTAL-DEBITOS
                           TO WS-DEBITOS-EDITADO

                       MOVE WS-TOTAL-NETO
                           TO WS-NETO-EDITADO

                       IF WS-TOTAL-NETO < ZERO
                           MOVE "-" TO WS-SIGNO-NETO
                       ELSE
                           MOVE SPACE TO WS-SIGNO-NETO
                       END-IF

                       MOVE SPACES
                           TO WS-LINEA-REPORTE

                       STRING
                           WS-CUENTA-ANTERIOR
                           "   "
                           WS-CANTIDAD-MOVIMIENTOS
                           "   "
                           WS-CREDITOS-EDITADO
                           "   "
                           WS-DEBITOS-EDITADO
                           "   "
                           WS-SIGNO-NETO
                           FUNCTION TRIM(WS-NETO-EDITADO LEADING)
                           DELIMITED BY SIZE
                           INTO WS-LINEA-REPORTE
                       END-STRING

                       WRITE REGISTRO-REPORTE
                           FROM WS-LINEA-REPORTE

                       DISPLAY "TOTAL CREDITOS: "
                           WS-TOTAL-CREDITOS

                       DISPLAY "TOTAL DEBITOS: "
                           WS-TOTAL-DEBITOS

                       MOVE CUENTA-MOVIMIENTO
                           TO WS-CUENTA-ANTERIOR

                       MOVE 1
                           TO WS-CANTIDAD-MOVIMIENTOS

                       MOVE ZERO
                           TO WS-TOTAL-CREDITOS

                       MOVE ZERO
                           TO WS-TOTAL-DEBITOS

                       IF TIPO-MOVIMIENTO = "C"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-TOTAL-CREDITOS
                       END-IF

                       IF TIPO-MOVIMIENTO = "D"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-TOTAL-DEBITOS
                       END-IF

                       ADD 1 TO WS-GRAL-MOVIMIENTOS

                       IF TIPO-MOVIMIENTO = "C"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-GRAL-CREDITOS
                       END-IF

                       IF TIPO-MOVIMIENTO = "D"
                           ADD IMPORTE-MOVIMIENTO
                               TO WS-GRAL-DEBITOS
                       END-IF

                   END-IF

               END-IF

           END-PERFORM.

           COMPUTE WS-GRAL-NETO =
               WS-GRAL-CREDITOS -
               WS-GRAL-DEBITOS

           MOVE WS-GRAL-CREDITOS
               TO WS-GRAL-CREDITOS-EDITADO

           MOVE WS-GRAL-DEBITOS
               TO WS-GRAL-DEBITOS-EDITADO

           MOVE WS-GRAL-NETO
               TO WS-GRAL-NETO-EDITADO

           IF WS-GRAL-NETO < ZERO
               MOVE "-" TO WS-GRAL-SIGNO-NETO
           ELSE
               MOVE SPACE TO WS-GRAL-SIGNO-NETO
           END-IF

           IF WS-CUENTA-ANTERIOR NOT = SPACES

               DISPLAY "-------------------------"
               DISPLAY "CAMBIO DE CUENTA: "
                   WS-CUENTA-ANTERIOR

               DISPLAY "MOVIMIENTOS: "
                   WS-CANTIDAD-MOVIMIENTOS

               DISPLAY "TOTAL CREDITOS: "
                   WS-TOTAL-CREDITOS

               DISPLAY "TOTAL DEBITOS: "
                   WS-TOTAL-DEBITOS

               COMPUTE WS-TOTAL-NETO =
                   WS-TOTAL-CREDITOS -
                   WS-TOTAL-DEBITOS

               MOVE WS-TOTAL-CREDITOS
                   TO WS-CREDITOS-EDITADO

               MOVE WS-TOTAL-DEBITOS
                   TO WS-DEBITOS-EDITADO

               MOVE WS-TOTAL-NETO
                   TO WS-NETO-EDITADO

               IF WS-TOTAL-NETO < ZERO
                   MOVE "-" TO WS-SIGNO-NETO
               ELSE
                   MOVE SPACE TO WS-SIGNO-NETO
               END-IF

               MOVE SPACES
                   TO WS-LINEA-REPORTE

               STRING
                   WS-CUENTA-ANTERIOR
                   "   "
                   WS-CANTIDAD-MOVIMIENTOS
                   "   "
                   WS-CREDITOS-EDITADO
                   "   "
                   WS-DEBITOS-EDITADO
                   "   "
                   WS-SIGNO-NETO
                   FUNCTION TRIM(WS-NETO-EDITADO LEADING)
                   DELIMITED BY SIZE
                   INTO WS-LINEA-REPORTE
               END-STRING

               WRITE REGISTRO-REPORTE
                   FROM WS-LINEA-REPORTE

           END-IF.

           MOVE ALL "="
               TO WS-LINEA-REPORTE

           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE

           MOVE "TOTALES GENERALES"
               TO WS-LINEA-REPORTE

           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE

           STRING
               "MOVIMIENTOS: "
               WS-GRAL-MOVIMIENTOS
               DELIMITED BY SIZE
               INTO WS-LINEA-REPORTE
           END-STRING

           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE

           MOVE SPACES
               TO WS-LINEA-REPORTE

           MOVE WS-GRAL-CREDITOS
               TO WS-GRAL-CREDITOS-EDITADO

           STRING
               "CREDITOS: "
               FUNCTION TRIM(WS-GRAL-CREDITOS-EDITADO LEADING)
               DELIMITED BY SIZE
               INTO WS-LINEA-REPORTE
           END-STRING

           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE

           MOVE SPACES
               TO WS-LINEA-REPORTE

           MOVE WS-GRAL-DEBITOS
               TO WS-GRAL-DEBITOS-EDITADO

           STRING
               "DEBITOS: "
               FUNCTION TRIM(WS-GRAL-DEBITOS-EDITADO LEADING)
               DELIMITED BY SIZE
               INTO WS-LINEA-REPORTE
           END-STRING

           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE

           COMPUTE WS-GRAL-NETO =
               WS-GRAL-CREDITOS -
               WS-GRAL-DEBITOS

           MOVE WS-GRAL-NETO
               TO WS-GRAL-NETO-EDITADO

           MOVE SPACES
               TO WS-GRAL-SIGNO-NETO

           IF WS-GRAL-NETO < ZERO
               MOVE "-" TO WS-GRAL-SIGNO-NETO
           END-IF

           MOVE SPACES
               TO WS-LINEA-REPORTE

           STRING
               "NETO: "
               WS-GRAL-SIGNO-NETO
               FUNCTION TRIM(WS-GRAL-NETO-EDITADO LEADING)
               DELIMITED BY SIZE
               INTO WS-LINEA-REPORTE
           END-STRING

           WRITE REGISTRO-REPORTE
               FROM WS-LINEA-REPORTE

           CLOSE ARCHIVO-MOVIMIENTOS
                 ARCHIVO-REPORTE.

           STOP RUN.

