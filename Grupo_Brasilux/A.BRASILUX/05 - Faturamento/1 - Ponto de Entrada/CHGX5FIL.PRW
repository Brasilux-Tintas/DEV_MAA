/*
CHGX5FIL - Utiliza Tabela 01 Exclusiva em um SX5 Compartilhado ( [ Nulo ] ) --> cFilSX5
25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
*/
User Function CHGX5FIL() 
     Local cFilSX5 := xFilial("SF2")
          u_zcfga01( 'CHGX5FIL' ) //LGS#2021201 - Gravação de log de utilização da rotina
Return cFilSX5
