#include 'TOTVS.ch'
#include "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ FA080CHK บAutor  ณ Luํs Gustavo de Souza บ Data ณ 10/19/04 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. desenvolvido para nใo deixar fazer baixa de PAs (Pa-  บฑฑ
ฑฑบ          ณ gamentos antecipados).                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//30/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function FA080CHK()
     Local lRet := .t.

    // If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa). (Cleber 21/01/20)
    //Cleber(17/04/20) -> liberar tํtulos do EEC 
/*LGS#20200826 - Conforme verificado em reuniใo e solicitado 
        If (Alltrim(SE2->E2_TIPO) == 'PA') .AND. !(ALLTRIM(SE2->E2_PREFIXO) == "EEC")
           MsgBox("Titulo tipo PA tem que ser compensado!", "Aten็ใo", "STOP")
           lRet := .f.
        Endif*/
    // Endif
Return(lRet)
