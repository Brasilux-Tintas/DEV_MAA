#include 'protheus.ch'
#include 'topconn.ch'
#Translate MSGBOX( => IW_MsgBox(
  /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ M410ALOK บAutor  ณ Luํs Gustavo       บ Data ณ  17/09/04   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDescri็ใo ณ Ponto de entrada antes da altera็ใo de pedidos para verifi-บฑฑ
  ฑฑบ          ณ car se o usuแrio estแ autorizado.                          บฑฑ
  ฑฑบ 18/08/05 ณ Passou a verificar se existe Ordem de Produ็ใo de itens es-บฑฑ
  ฑฑบ          ณ pecํficos e nใo deixa efetuar altera็ใo caso exista.       บฑฑ
  ฑฑบ          ณ                                                            บฑฑ
  ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
  ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
  //25/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function M410ALOK()
     Local lRet      := .t.,lAdmin
     Local cAliAtu   := Alias()
     Local cQry1     := ""
     Local cMsgUse   := ""  
     Local cTmp, cMsgPed, nConPed, cAuxMen   
     Local _cCodUser := RetCodUsr()
     u_zcfga01( 'M410ALOK' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
     If alltrim(FWGrpCompany()) <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        lAdmin := (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),_cCodUser) = 0)

        If ALTERA .AND. !( Type("l410Auto") <> "U" .And. l410Auto )
           DO CASE 
              CASE (SC5->C5_TPFRETE = "C") .AND. (SC5->C5_XVLRFRE > 0.0) .AND. (SC5->C5_TIPO = "N") .AND. (SC5->C5_APROVA = '1')					
                   lRet := .f.
                   cMsgUse := "Aten็ใo! Pedido com FRETE CIF! Execute antes a rotina "+chr(13)+chr(10)
                   cMsgUse += "Atualizacoes->Especificos Brasilux->Pedidos->Zerar FRETE CIF!"
                   MsgBox(cMsgUse, "Aten็ใo...", "ALERT")     	
              CASE !lAdmin .and. (SC5->C5_APROVA = '1') .AND. !(ALLTRIM(UPPER(SC5->C5_USRCAD)) == UPPER(ALLTRIM(cUsername)))
                   cTmp := U_NovoCursor()
                   cMsgUse += "Aten็ใo, pedido jแ estแ totalmente liberado."+chr(13)+chr(10)
                   cMsgUse += "Usuแrio(s) autorizado(s) a efetuar(em) a(s) altera็ใo(๕es): "+chr(13)+chr(10)
                   cQry1 += "SELECT ZW_USUARIO "
                   cQry1 += "FROM "+RetSqlName("SZW")+" SZW WITH (NOLOCK) "
                   cQry1 += "WHERE (D_E_L_E_T_ <> '*') AND SZW.ZW_FILIAL = '"+xFilial("SZW")+"' "
                   cQry1 += "  AND SZW.ZW_ROTINA = 'BRFATX01' "
                   cQry1 += "  AND SUBSTRING(SZW.ZW_ACESSOS, 5, 1) = '*' "
                   TCQuery cQry1 ALIAS (cTmp) NEW
                   DbSelectArea(cTmp)
                   DbGoTop()
                   While !Eof()
                         If !(_cCodUser == (cTmp)->ZW_USUARIO)
                            lRet := .f.
                            cMsgUse += (cTmp)->ZW_USUARIO+" - "+UsrRetName((cTmp)->ZW_USUARIO)+" "+chr(13)+chr(10)
                         Else
                            lRet := .t.
                            exit 
                         Endif
                         DbSelectArea(cTmp)
                         DbSkip()
                   Enddo
                   DbSelectArea(cTmp)
                   DbCloseArea()
                   If !lRet
                      MsgBox(cMsgUse, "Aten็ใo...", "ALERT")
                   Endif
           ENDCASE 
           If lRet
              nConPed := 0
              cAuxMen := ""
              cQry1 := ""
              cQry1 += "SELECT C6_ITEM,C6_PRODUTO,C6_NUMOP,C6_NUMLOTE "
              cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
              cQry1 += "WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
              cQry1 += "  AND SC6.D_E_L_E_T_ <> '*' "
              cQry1 += "  AND SC6.C6_NUM     = '"+SC5->C5_NUM+"' "
              cQry1 += "  AND SC6.C6_NUMLOTE <> '' "
              TCQuery cQry1 ALIAS "QPED" NEW
              DbSelectArea("QPED")   
              dbgotop()
              while !Eof()
                    nConPed += 1
                    cAuxMen += "ITEM / PRODUTO: "+Alltrim(QPED->C6_ITEM)+" / "+Transform(QPED->C6_PRODUTO, "@R XXX99.99.999-99")+" - OP / LOTE: "+Alltrim(QPED->C6_NUMOP)+" / "+Alltrim(QPED->C6_NUMLOTE)+CHR(10)+CHR(13)
                    DbSelectArea("QPED")
                    DbSkip()
              EndDo
              DbSelectArea("QPED")
              DbCloseArea()
              If nConPed > 0
                 //          ITEM / PRODUTO: 99 / XX 99.99.999-99 - OP / LOTE: 999999 / 999999
                 cMsgPed := "Existe item(s) com Ordem(s) de Produ็ใo gerada(s)!"+CHR(10)+CHR(13)+CHR(10)+CHR(13)
                 cMsgPed += cAuxMen
                 MsgBox(cMsgPed, "Aten็ใo...", "ALERT")
              Endif
           Endif
        Endif     
        If !empty(cAliAtu)
           DbSelectArea(cAliAtu)
        Endif
     Endif
Return(lRet)
