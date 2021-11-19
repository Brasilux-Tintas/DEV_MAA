#INCLUDE "TOTVS.ch"
#INCLUDE "topconn.ch"      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT105QRY  บAutor  ณMauriico             บ Data ณ  08/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Este ponto de entrada e executado pela rotina MATA105     บฑฑ
ฑฑบ          ณ  Requisi็ใo ao Armazem e ้ utilizado para criar filtros    บฑฑ   
ฑฑบ          ณ  no browse de navega็ao. O mesmo foi implementado na       บฑฑ
ฑฑบ          ณ  Brasilux para filtrar as requisi็๕es do usuแrio logado no บฑฑ
ฑฑบ          ณ  Totvs baseado no Almoxarifado de requisi็ใo do usuแrio    บฑฑ
ฑฑบ          ณ  Amarrado pela ZZN - Requisitantes x Armazens              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
*/
User Function MT105QRY()
     Local cQuery
     Local nArea := Alias()                
     Local xLoc                                                                                      

     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        u_zcfga01( 'MT150QRY' ) //LGS#2021119 - Grava็ใo de log de utiliza็ใo da rotina
        dbselectarea("ZZN")
        dbsetorder(1)  //xFilial("ZZN")+RetCodUsr()+"R"
        dbseek(xFilial("ZZN")+RetCodUsr()+"R")
        xLoc := ZZN->ZZN_LOCAL  

        cQuery = " CP_LOCAL = '"+xLoc+"' "   

        dbselectarea(nArea)
     Endif	
Return( cQuery )
