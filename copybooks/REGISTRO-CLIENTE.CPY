       01  REGISTRO-CLIENTE.
           05  ID-CLIENTE          PIC X(6).
           05  NOMBRE-CLIENTE      PIC X(20).
           05  SUCURSAL-CLIENTE    PIC X(3).
           05  TIPO-CUENTA         PIC X(2).
           05  ESTADO-CLIENTE      PIC X(1).
           05  SALDO-CLIENTE       PIC 9(10)V99.
           05  RESERVADO-CLIENTE   PIC X(6).

       01  SOLICITUD-CLIENTE.
           05  OPERACION-SOLICITUD   PIC X(1).
           05  ID-SOLICITUD          PIC X(6).
           05  NOMBRE-SOLICITUD      PIC X(20).
           05  SUCURSAL-SOLICITUD    PIC X(3).
           05  TIPO-CUENTA-SOLICITUD PIC X(2).
           05  ESTADO-SOLICITUD      PIC X(1).
           05  SALDO-SOLICITUD       PIC 9(10)V99.
           05  RESERVADO-SOLICITUD   PIC X(5).
