#include 'protheus.ch'
#include 'topconn.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MA410DEL บAutor  ณ Cleber O. Dominguesบ Data ณ  27/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia dele็ใo do pedido para o BrasRepres.                 บฑฑ
ฑฑบ 18/08/05 ณ Verifica se o pedido estแ na tabela para novas f๓rmulas, - บฑฑ
ฑฑบ          ณ caso seja verdade deleta o pedido da mesma.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function MA410DEL()
     Local cArea  := Alias()
     Local _cAux
     u_zcfga01( 'MA410DEL' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
     If substr(cNumEmp,1,2) == "01"
        U_EnviaRec("SC5", SC5->C5_NUM, .t.,SC5->C5_VEND1)
     Endif      
     
// Cleber (03/10/2007) => Inserida Trigger p/ excluir
/*     If cNumEmp $ "0101_0301"
        cQry1 := ""
        cQry1 += "DELETE FROM ESPEPEDIDOS WHERE (EMPRESA = '"+alltrim(cNumEmp)+"') AND (PEDIDO = '"+SC5->C5_NUM+"') "
        TCSQLExec(cQry1)
     Endif              
*/     
     //Grava log de exclusao do pedido     
     
	//_cAux := M->C5_OBS
	MSMM(SC5->C5_OBSSC5, , , _cAux, 2, , , "SC5", "C5_OBSSC5")   
   //	_cAux := M->C5_OBSNF
	MSMM(SC5->C5_OBSNFS, , , _cAux, 2, , , "SC5", "C5_OBSNFS") 
     RecLock("ZZB", .t.)
        ZZB->ZZB_FILIAL := xFilial("ZZB")
        ZZB->ZZB_PEDIDO := M->C5_NUM
        ZZB->ZZB_IDLOG  := 'EXC'
        ZZB->ZZB_USRLOG := cUsername
        ZZB->ZZB_DATLOG := dDataBase
        ZZB->ZZB_HORLOG := Time()
     MsUnLock()
     //Deleta pedido do Bordero de Pedidos.
     DbSelectArea("SZG")
     DbSetOrder(2)
     DbSeek(xFilial("SZG")+"01"+SC5->C5_NUM, .t.)
     If Found()
        RecLock("SZG", .f.)
        DbDelete()
        MsUnLock()
     Endif
     //Deleta pedido do Bordero de Despacho.
     DbSelectArea("SZB")
     DbSetOrder(2)
     DbSeek(xFilial("SZB")+"01"+SC5->C5_NUM, .t.)
     If Found()
        cCodDes := SZB->ZB_CODIGO
        RecLock("SZB", .f.)
           DbDelete()
        MsUnLock()
        //Ajusta peso e volume do Bordero de Despacho.
        DbSelectArea("SZA")
        DbSetOrder(1)
        DbSeek(xFilial("SZA")+cCodDes, .t.)
        If Found()
           RecLock("SZA", .f.)
              SZA->ZA_PESO   := SZA->ZA_PESO - SC5->C5_PBRUTO
              SZA->ZA_VOLUME := SZA->ZA_VOLUME - SC5->C5_VOLUME1
           MsUnLock()
        Endif
        //Deleta pedido da Retirada do Envase.
        DbSelectArea("ZZC")
        DbSetOrder(2)
        DbSeek(xFilial("ZZC")+SC5->C5_NUM, .t.)
        If Found()
           While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. (ZZC->ZZC_PEDIDO == SC5->C5_NUM)
                 RecLock("ZZC", .f.)
                    DbDelete()
                 MsUnLock()
                 DbSelectArea("ZZC")
                 DbSkip()
           Enddo
        Endif
     Endif       

   IF cNumEmp = "01"
      _cAux := RetSqlName("ZZO")
	   cQry1 := "DELETE FROM "+_cAux+" WHERE (ZZO_FILIAL = '"+xFilial("ZZO")+"') AND (ZZO_PEDIDO = '"+SC5->C5_NUM+"')"
   ENDIF
	TCSQLEXEC(cQry1)
	TcRefresh( _cAux )     
                        
Endif // Fim If FWCodEmp() <> '11'
if !empty(cArea) 
	DbSelectArea(cArea)
endif
Return(.t.)
