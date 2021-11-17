#include 'TOTVS.CH'
#include 'topconn.CH'

User Function MTA650E()
     Local _cAlias  := Alias()
     Local aAreaAnt := {}
     //Local cNumOP   := SC2->C2_NUM
     //Local cIteOP   := SC2->C2_ITEM
     //Local cSeqOp   := SC2->C2_SEQUEN
     Local lRet     := .t.
     Local cQry1    := ""
     Local aAutoSC2 := {}

     Private lMSErroAuto := .f.
     Private lMSHelpAuto := .t. 

If FWCodEmp() <> '11'
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³ MTA650E  ºAutor  ³ Cleber O. Dominguesº Data ³  08/05/02   º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³                                                            º±±
        ±±º 08/05/02 ³ Excluir itens da tabela SZZ (Lotes)                        º±±
        ±±º 18/08/05 ³ Excluir todas as ordens de produção que pertencem ao lote, º±±
        ±±º          ³ ajustando tabelas de pedidos no caso da OP ser de produtos º±±
        ±±º          ³ específicos.                                               º±±
        ±±º          ³                                                            º±±
        ±±º          ³                                                            º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
		aAreaAnt := u_PegaArea({"SC2","ZZA","SZZ"})
        dbselectarea("SC2")
        If !Empty(SC2->C2_LOTE)
           If SELECT("TCQ") == 0
              cQry1 += "SELECT C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_ITEMGRD,C2_OP,C2_LOTE,C2_PRODUTO "
              cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
              cQry1 += "WHERE SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
              cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
              cQry1 += "  AND SC2.C2_LOTE = '"+SC2->C2_LOTE+"' "
              cQry1 += "  AND SC2.C2_PRODUTO NOT IN('"+SC2->C2_PRODUTO+"') "
              cQry1 += "  AND SC2.C2_OP      NOT IN('"+SC2->C2_OP+"') "
              cQry1 += "  AND SC2.C2_DATRF = '' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              While !Eof()
                    //Apaga Ordens de produção vinculadas ao lote selecionado.
                    aAutoSC2 := {}
                    aAutoSC2 := { {"C2_FILIAL" , TCQ->C2_FILIAL , NIL},;
                                  {"C2_NUM"    , TCQ->C2_NUM    , NIL},;
                                  {"C2_ITEM"   , TCQ->C2_ITEM   , NIL},;
                                  {"C2_SEQUEN" , TCQ->C2_SEQUEN , NIL},;
                                  {"C2_ITEMGRD", "  "           , NIL} }
                    lMsErroAuto := .f.
                    DbSelectArea("SC2")
                    DbSetOrder(1)
                    DbSeek(xFilial("SC2")+TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+TCQ->C2_ITEMGRD, .t.)
                    If Found()
                       //Verifica se existe apontamento para essa ordem de produção
                       DbSelectArea("ZZA")
                       DbSetOrder(2)
                       DbSeek(xFilial("ZZA")+TCQ->C2_OP, .t.)
                       If Found() //.and. ((!ZZA->ZZA_FLAG =='5') .and. (!ZZA->ZZA_TPENVA $ 'E.1') .and. (!ZZA->ZZA_QUANT =0))
	                      MsgStop("Foi encontrada ordem de produção apontada para op: "+TCQ->C2_OP+". A mesma não poderá ser excluida!")
                       Else
                          MSExecAuto( {|x, y| MATA650(x, y)}, aAutoSC2, 5)
                          If !lMsErroAuto
                             //Deleta lote da tabela SZZ
                             DbSelectArea("SZZ")
                             DbSetOrder(1)
                             DbSeek(xFilial("SZZ")+TCQ->C2_LOTE+TCQ->C2_PRODUTO, .t.)
                             If Found()
                                RecLock("SZZ", .f.)
                                   DbDelete()
                                MsUnLock()
                             Endif      
                             //if cNumEmp = "01010101"
                             cQry1 := ""
    	                     cQry1 += "SELECT * "
                             cQry1 += "FROM ESPECIFICOS "
                             cQry1 += "WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND PRODUTO = '"+TCQ->C2_PRODUTO+"' "
                             cQry1 += "  AND LOTE = '"+TCQ->C2_LOTE+"' "
                             TCQuery cQry1 ALIAS "ESP" NEW
                             DbSelectArea("ESP")
	                         While !Eof()
    	                           //Seleciona pedidos da tabela ESPEPEDIDOS, para apagar da
        	                       //tabela SC6.
            	                   cQry1 := ""
                	               cQry1 += "SELECT * FROM ESPEPEDIDOS WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND (ID = '"+ESP->ID+"') AND EMBAL = '"+SubStr(Alltrim(ESP->PRODUTO), 11, 2)+"' "
                    	           If Select("PED") > 0
                                      PED->(DbCloseArea())
                                   EndIF
                                   TCQuery cQry1 ALIAS "PED" NEW
	                               DbSelectArea("PED")
    	                           While !Eof()
        	                             //Libera pedido da tabela SC6, dos lotes vinculados.
            	                         cQry1 := ""
                	                     cQry1 += "UPDATE "+RetSqlName("SC6")+" "
                    	                 cQry1 += "SET C6_NUMLOTE = '', C6_NUMOP = '', C6_ITEMOP = '' "
                                         cQry1 += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
                            	         cQry1 += "  AND C6_NUM = '"+PED->PEDIDO+"' "
                                	     cQry1 += "  AND C6_NUMLOTE = '"+ESP->LOTE+"' "
                                         cQry1 += "  AND SUBSTRING(C6_PRODUTO, 11, 2) = '"+PED->EMBAL+"' "
	                                     TCSQLExec(cQry1)
    	                                 DbSelectArea("PED")
        	                             DbSkip()
            	                   Enddo
                	               DbSelectArea("PED")
                    	           DbCloseArea()
                                   DbSelectArea("ESP")
                            	   DbSkip()
	                         Enddo
    	                     DbSelectArea("ESP")
        	                 DbCloseArea()
            	             //Deleta numero do lote na tabela ESPECIFICOS,
                	         //liberando para ser gerado nova OP.
                    	     cQry1 += "UPDATE ESPECIFICOS SET LOTE = '' WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND PRODUTO = '"+TCQ->C2_PRODUTO+"' AND LOTE = '"+TCQ->C2_LOTE+"' "
                             TCSQLExec(cQry1)
						     //endif                         	 
                          Else
                             MostraErro()
                          Endif
                       Endif
                    Endif
                    DbSelectArea("TCQ")
                    DbSkip()
              Enddo
              DbSelectArea("TCQ")
              DbCloseArea()
              //Deleta item posicionado no SC2
              //Verifica se existe apontamento para essa ordem de produção
              DbSelectArea("ZZA")
              DbSetOrder(2)
              DbSeek(xFilial("ZZA")+SC2->C2_OP, .t.)
              If Found()
                 If (ZZA->ZZA_FLAG $ '1.6.8.5') .AND. (SUBSTR(ZZA->ZZA_PRODUT, 11, 2) <> '00') .AND. (SUBSTR(ZZA->ZZA_PRODUT, 11, 2) <> '99') .AND. (LEN(ALLTRIM(ZZA->ZZA_PRODUT)) == 12) .AND. (ZZA->ZZA_QUANT =0)  .AND. (ZZA_TPENVA $ '1.E')
                    If MsgYesNo('Atenção, essa OP já encontra apontada. Deseja exclui-la?')
                       RecLock("ZZA", .f.)
                          DbDelete()
                       MsUnLock()
                       lRet := .t.
                    Else
                       lRet := .f.
                    Endif
                 Else
                    MsgStop("Foi encontrada ordem de produção apontada para op: "+ZZA->ZZA_ORDEM+". A mesma não poderá ser excluida!")
                    lRet := .f.
                 Endif
              Else
                 DbSelectArea("SZZ")
                 DbSetOrder(1)
                 DbSeek(xFilial("SZZ")+SC2->C2_LOTE+SC2->C2_PRODUTO, .t.)
                 If Found()
                    RecLock("SZZ", .F.)
                       DbDelete()
                    MsUnLock()
                 Endif
              Endif
              //Se o item selecionado não for PI, processa exclusão nas tabelas
              //de pedidos selecionados para geração de OP.
              If (SubStr(Alltrim(SC2->C2_PRODUTO), 11, 2) <> '00') .AND. (SubStr(Alltrim(SC2->C2_PRODUTO), 11, 2) <> '99')
                 cQry1 := ""
                 cQry1 += "SELECT * "
                 cQry1 += "FROM ESPECIFICOS "
                 cQry1 += "WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND PRODUTO = '"+SC2->C2_PRODUTO+"' "
                 cQry1 += "  AND LOTE = '"+SC2->C2_LOTE+"' "
                 TCQuery cQry1 ALIAS "ESP" NEW
                 DbSelectArea("ESP")
                 While !Eof()
                       //Seleciona pedidos da tabela ESPEPEDIDOS, para apagar da
                       //tabela SC6.
                       cQry1 := ""
                       cQry1 += "SELECT * FROM ESPEPEDIDOS WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND ID = '"+ESP->ID+"' AND EMBAL = '"+SubStr(Alltrim(ESP->PRODUTO), 11, 2)+"' "
                       TCQuery cQry1 ALIAS "PED" NEW
                       DbSelectArea("PED")
                       While !Eof()
                             //Libera pedido da tabela SC6, dos lotes vinculados.
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("SC6")+" "
                             cQry1 += "SET C6_NUMLOTE = '', C6_NUMOP = '', C6_ITEMOP = '' "
                             cQry1 += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
                             cQry1 += "  AND C6_NUM = '"+PED->PEDIDO+"' "
                             cQry1 += "  AND C6_NUMLOTE = '"+ESP->LOTE+"' "
                             cQry1 += "  AND SUBSTRING(C6_PRODUTO, 11, 2) = '"+PED->EMBAL+"' "
                             TCSQLExec(cQry1)
                             DbSelectArea("PED")
                             DbSkip()
                       Enddo
                       DbSelectArea("PED")
                       DbCloseArea()
                       DbSelectArea("ESP")
                       DbSkip()
                 Enddo
                 DbSelectArea("ESP")
                 DbCloseArea()
                 //Deleta numero do lote na tabela ESPECIFICOS,
                 //liberando para ser gerado nova OP.
                 cQry1 := ""
                 cQry1 += "UPDATE ESPECIFICOS SET LOTE = '' WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND PRODUTO = '"+SC2->C2_PRODUTO+"' AND LOTE = '"+SC2->C2_LOTE+"' "
                 TCSQLExec(cQry1)
              Endif
           Endif
        Endif
        U_VoltaArea( aAreaAnt )
        IF !EMPTY( _cAlias )
           DbSelectArea( _cAlias )
        Endif
Else //if FWCodEmp() <> '11'
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³ MTA650E  ºAutor  ³ André Maesterº Data ³  30/07/2019       º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³ Não permitir que seja excluída a ordem de produção com     º±±
        ±±º          ³ ordem de separação gerada.                                 º±±
        ±±º          ³                                                            º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ TECPOLPA                                                   º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
        DbSelectArea("SC2")
        If !Empty(SC2->C2_XORDSEP)
           lRet := .f.
           MsgStop("Foi encontrada ordem de separação para a Op "+SC2->C2_XOP+". Estorne a Ordem de Separação primeiro !")
        Endif   	

        If !Empty( _cAlias )
           DbSelectArea( _cAlias )
        Endif
Endif
Return(lRet)
