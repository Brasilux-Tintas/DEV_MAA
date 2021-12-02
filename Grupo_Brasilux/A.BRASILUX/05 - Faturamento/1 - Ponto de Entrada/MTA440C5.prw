/*
Ponto de Entrada para permitir campos a serem alterados na Liberação do Pedido
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
*/
User Function MTA440C5() 
     Local _aCpos := {}
     u_zcfga01( 'MTA440C5' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        _aCpos := {"C5_VEICULO","C5_OBSNF"}
     Endif 
Return (_aCpos)
