#include "protheus.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  MT120APV  บAutor  ณ Cleber O. Dominguesบ Data ณ  11/06/19 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ 11/06/19 ณ Ponto de entrada Troca de grupo de Compras do Pedido para  บฑฑ
ฑฑบ          ณ que nใo passe por libera็ใo no caso de pedido entre empre- บฑฑ
ฑฑบ          ณ sas do mesmo grupo. Deverแ ser criado um grupo de compras  บฑฑ
ฑฑบ          ณ e colocar usuแrios neste grupo. Os pedidos somente rece-   บฑฑ
ฑฑบ          ณ rใo o c๓digo de grupo de MV_GRPEMPR e somente os usuแrios  บฑฑ
ฑฑบ          ณ pertencentes a este grupo conseguirใo liberar. O prop๓sito บฑฑ
ฑฑบ          ณ ้ fazer com que os pedidos nใo passe pela diretoria.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
*/
//25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function MT120APV()
     Local _cGrupoAlt, _cCnpj, cQuery
     //Local _cForn
     Local _cAlias    := Alias()
     Local _cGrupoLib := SuperGetMv("MV_GRPEMPR",.F.,"")  
     Local aAreaAnt   := U_PegaArea({"SC7","SA2"})  
     //ExpC2 := PARAMIXB[2]
     //C๓digo do usuแrio manipulando o grupo de aprova็ใo, conforme necessidade.
     //MV_GRPEMPR
     u_zcfga01( 'MT120APV' ) //LGS#2021118 - Grava็ใo de log de utiliza็ใo da rotina
     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        If !(cNumEmp = "01060101") .AND. !EMPTY(_cGrupoLib) .AND. !EMPTY(SC7->C7_FORNECE)
           dbselectarea("SA2")
           dbsetorder(1)
           dbseek(xFilial("SA2")+SC7->C7_FORNECE)
           IF FOUND() .AND. !EMPTY(ALLTRIM(SA2->A2_CGC))
              _cCnpj := ALLTRIM(SA2->A2_CGC)
              //Excluindo Dissoltex (59599555000144) do Grupo pois Rui diz que quer analisar pedidos
              IF !_cCnpj == "59599555000144" .or. !_cCnpj == "05102932000169"
			  //IF !_cCnpj == "59599555000144"
                 cQuery := "SELECT m0_cgc AS CNPJ FROM sigamat WHERE (m0_cgc > '') AND (m0_cgc = '"+_cCnpj+"')"
                 TCQuery cQuery NEW ALIAS "TCQ"
                 dbselectarea("TCQ")
                 IF !EOF() .AND. !BOF() .AND. (TCQ->CNPJ = _cCnpj)
                    _cGrupoAlt := _cGrupoLib
                 ENDIF
              ENDIF 
              dbselectarea("TCQ")
              dbclosearea()
           ENDIF
        ENDIF 
        U_VoltaArea(aAreaAnt)
        if !empty(_cAlias)
           dbselectarea(_cAlias)
        endif
     Endif
Return(_cGrupoAlt)
