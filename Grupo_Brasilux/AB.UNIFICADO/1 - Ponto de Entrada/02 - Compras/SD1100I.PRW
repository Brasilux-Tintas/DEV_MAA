#include 'TOTVS.CH'
#include 'topconn.CH'
#include "rwmake.ch"

   /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
   ±±ºPrograma  ³ SD1100I  ºAutor  ³ Cleber O. Dominguesº Data ³  29/08/02   º±±
   ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
   ±±ºDesc.     ³ Atualiza ultimo preco de compra(B1_UPRC) descontando o ICMSº±±
   ±±º          ³ caso seja creditavel.                                      º±±
   ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
   ±±ºUso       ³ AP                                                         º±±
   ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
   Últ. Atualizações
   03/08/04 -> Gravar B1_UPRC somente quando o preço de entrada for maior que o mesmo. 
      Gravar o campo B1_UPRCCMP criado para gravar o último preço para ser comparado
      para tomada de decisão sobre se irá ou não atualizar o ultimo preço manualmente.  
   19/06/2024 -> Ajuste para filial 010108 - Depósito Araraquara (André Maester)      
      */

User Function SD1100I()
   
   Local _aAlias    := GetArea()
   Local aAreaAnt   := u_PegaArea( {"SB1","AIC","SC7","SF4","SF2","CDD"} )
   Local nPreco     := 0, nDec := 2, nDif, cAuxMail, cTexto, cPict, nCusto, cQuery
   Local lBloqueado := .f.
   Local nRegD1,lAchou,nUPrcCmp,cCpoUprc,lRet,_cMensErro,_cGrpEmp,_nTam,cAux,_nVlrUnit,_cNumEmp
   Local _lVVarNull  := Type("l103Auto") <> "U"
   
   lRet := .t.
   _cGrpEmp := alltrim(FWGrpCompany())
   _cNumEmp := _cGrpEmp+alltrim(FWCodFil())
   _cMensErro := ""
   
   DbSelectArea("SC7")
   Dbsetorder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN     

   DbSelectArea("SB1")
   DbSetOrder(1)
   If !DbSeek(xFilial("SB1")+SD1->D1_COD) 
      lRet := .f.
      _cMensErro := "Nao encontrado o produto "+SD1->D1_COD+" no cad. de Produtos!"
   Endif

   If lRet .and. (_cGrpEmp == "01")
      Dbselectarea("SC7")
      Dbseek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC)   
      If found()
         If (SC7->C7_DEPOSI = "S") .AND. (SF1->F1_DEPOSI <> 'S') 
            //Cleber(30/10/20) -> Identificar NF que está sendo entrada através do depósito fechado
            SF1->F1_DEPOSI := "S"
         Endif
      Endif 
   Endif 

/*
if lRet 
   if (cTipo = "N") .AND. (SF4->F4_ESTOQUE = 'S') .AND. (SF4->F4_UPRC $ " S") .AND. (ALLTRIM(SB1->B1_TIPO) $ "MP.MC")
      if empty(SD1->D1_PEDIDO)
         lRet := .f.
         _cMensErro := "Proibida a entrada de NF SEM PEDIDO!"
      else
         dbselectarea("SC7")
	      dbseek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
         if !found()
            lRet := .f.
            _cMensErro := "Não encontrado o pedido nro "+SD1->D1_PEDIDO+"/"+SD1->D1_ITEMPC
         endif 
      endif 
   endif
endif
*/

   If lRet .and. !U_IsProdCusto(SB1->B1_COD) /* produto de custeio */
      If (dDataBase >= SB1->B1_UCOM)
         Dbselectarea("SB1")
         lBloqueado := U_EstaBloqueado("SB1",recno())
         If !lBloqueado
            RecLock("SB1",.F.)
         Endif 
   
         If (SF4->F4_UPRC $ " S") 
            If (cTipo == "N") 
               cCpoUprc := iif(SB1->(FieldPos("B1_XUPRC")) > 0,"B1_XUPRC","B1_UPRC")
               nDec := TamSx3(cCpoUprc)[2]
               cPict := PesqPict("SB1", cCpoUprc)
               nPreco := round(SD1->D1_CUSTO/SD1->D1_QUANT,nDec)
               DbSelectArea("SB1")
               Replace B1_UCOM With dDataBase
               //tecpolpa -> B1_XUPRCCM , mantendo porém não tem necessidade uma vez que B1_XUPRC é customizado e o Protheus não altera
               //B1_UPRC, equivalente TecPolpa -> B1_XMAXPRC 
               //B1_XUPRC é o último preço customizado na TecPolpa, desconsiderar lá o B1_UPRC!!!
               nUPrcCmp := nPreco
               If (SB1->(FieldPos("B1_XMAXPRC")) > 0)
                  If (nPreco > SB1->B1_XMAXPRC)
                     SB1->B1_XMAXPRC := nPreco
                  Endif
               Endif
               /*
               if (SB1->(FieldPos("B1_XUPRCCM")) > 0) .and. (SB1->(FieldPos("B1_XUPRC")) > 0)
                  nUPrcCmp := SB1->B1_XUPRC
                  SB1->B1_XUPRCCM := SB1->B1_XUPRC 
                  SB1->B1_XUPRC   := nPreco
               endif
                  */          
               If (SB1->(FieldPos("B1_XUPRC")) > 0) .AND. (_cGrpEmp = '11')
                  nUPrcCmp := SB1->B1_XUPRC
                  //SB1->B1_XUPRCCM := SB1->B1_XUPRC 
                  SB1->B1_XUPRC   := nPreco
               Endif

               If SB1->(FieldPos("B1_UPRCCMP")) > 0
                  nUPrcCmp := SB1->B1_UPRCCMP
               Endif

               If (nPreco > nUPrcCmp) 
                  If _cGrpEmp = '01' //Empresas que são do grupo 01(Brasilux). Atualizar B1_UPRC com o último maior custo
                     SB1->B1_UPRC := nPreco  
                     If (SB1->(FieldPos("B1_XUPRC")) > 0)
                        SB1->B1_XUPRC   := nPreco
                     Endif 
                     SB1->B1_UPRCCMP := nPreco // Microsiga atualiza B1_UPRC antes de passar por aqui
                  Endif
                  // Campo criado para comparar com o último preço gravado, para que se possa analisar posteriormente
                  // se o último preço pode ser baixado ou não. 
                  If (ALLTRIM(SB1->B1_TIPO) $ "MP.MC") .AND. (nUPrcCmp > 0) //Enviar e-mail caso variação de preço seja alta
                     nDif := ((nPreco - nUPrcCmp)*100)/nUPrcCmp
                     If abs(nDif) > 10 // Se diferença maior que 10% enviar e-mail de alerta!     
                        cAuxMail := alltrim(UsrRetMail(__cUserId))
                        If !empty(cAuxMail)
                           cAuxMail += ","
                        Endif
                        // ------------------ Acrescentado por Jose Uliana 09/06/2020 por solicitação do Sr. Rui  Chamado 017598 da Aline
                        If _cGrpEmp = '11' // Para outros usuários Compras Empresa TEcPolpa
                           cAuxMail += "jp@tecpolpa.com.br,compras@tecpolpa.com.br" 
                        Else
                           cAuxMail += "compras@brasilux.com.br"   //               
                        Endif
                        //--------------------------------------------------------------------------------------------------------------                     
                        // Antigo antes 09/06/2020     cAuxMail += "compras@brasilux.com.br"
                        cTexto := "O Produto "+alltrim(SD1->D1_COD)+"-"+ALLTRIM(SB1->B1_DESC)+", tipo "+SB1->B1_TIPO+", da filial "+xFilial("SD1")+" foi dado entrada com uma divergência maior que 10%."+chr(13)+chr(10)+;
                        "Valor anterior: R$ "+transform(nUPrcCmp,cPict)+chr(13)+chr(10)+;
                        "Novo Valor :    R$ "+transform(nPreco,cPict)
                        //U_EnvMail("Divergência de Preço maior que 10%",cTexto,"sergioduo@brasilux.com.br",cAuxMail,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
                     Endif 
                  Endif
               Else
                  If _cGrpEmp = '01' //Empresas que são do grupo 01(Brasilux). Atualizar B1_UPRC com o último maior custo
                     SB1->B1_UPRC := nUPrcCmp //Microsiga atualiza B1_UPRC antes de passar por aqui, voltar último maior preço
                  Endif

               Endif
               //Verificar Tolerância inferior, enviar e-mail
               If !empty(SD1->D1_PEDIDO) .AND.!empty(SD1->D1_ITEMPC)
                  lAchou := .f.
                  DbSelectArea("AIC")
	               DbSetOrder(2) //AIC_FILIAL+AIC_FORNEC+AIC_LOJA+AIC_PRODUT+AIC_GRUPO                                                                                                             
                  Dbseek(xFilial("AIC")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD)
                  lAchou := found()
                  If !lAchou
                     Dbseek(xFilial("AIC")+SD1->D1_FORNECE+SD1->D1_LOJA)
                     lAchou := found()
                  Endif
                  If !lAchou
                     _nTam := TamSx3("AIC_FORNEC")[1]
                     Dbseek(xFilial("AIC")+space(_nTam+2)+SD1->D1_COD)
                     lAchou := found()
                  Endif 
                  If !lAchou
                     lRet := .f.
                     _cMensErro := "Favor cadastrar a TOLERÂNCIA DE RECEBIMENTO para o Produto "+alltrim(SD1->D1_COD)+" na filial "+xFilial("SD1")
                  Endif 
                  If lAchou 
                     Dbselectarea("SC7")
                     Dbseek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
                  
	                  //if found() .and. (SD1->D1_VUNIT < (SC7->C7_PRECO*(1-(AIC->AIC_PPRECO/100))))
                     If found() 
                        _nVlrUnit := SC7->C7_PRECO*iif((SC7->C7_MOEDA != 1) .AND. (SC7->C7_TXMOEDA > 0),SC7->C7_TXMOEDA,1)
                        If ((abs(SD1->D1_VUNIT - _nVlrUnit)*100/_nVlrUnit) > AIC->AIC_PPRECO)
                           cAuxMail := alltrim(UsrRetMail(__cUserId))
                           If !empty(cAuxMail)
                              cAuxMail += ","
                           Endif
                           // ------------------ Acrescentado por Jose Uliana 09/06/2020 por solicitação do Sr. Rui  Chamado 017598 da Aline
                           If _cGrpEmp = '11' // Para outros usuários Compras Empresa TEcPolpa
                              cAuxMail += "jp@tecpolpa.com.br,compras@tecpolpa.com.br" 
                           Else
                              cAuxMail += "compras@brasilux.com.br"                   
                           Endif
                           //--------------------------------------------------------------------------------------------------------------                     
                           // Antigo antes 09/06/2020 	cAuxMail += "compras@brasilux.com.br"
                           cPict := PesqPict("AIC", "AIC_PPRECO")
                           cTexto := "O Produto "+alltrim(SD1->D1_COD)+"-"+ALLTRIM(SB1->B1_DESC)+", tipo "+SB1->B1_TIPO+", da filial "+xFilial("SD1")
                           cTexto += " foi dado entrada com uma divergência "
                           cAux := iif(SD1->D1_VUNIT > _nVlrUnit,"MAIOR","MENOR")
                           cTexto += cAux+ " que "+transform(AIC->AIC_PPRECO,cPict)+"% em relação ao pedido."+chr(13)+chr(10)
                           cPict := PesqPict("SC7", "C7_PRECO")
                           cTexto += "Valor no pedido nro "+SD1->D1_PEDIDO+": R$ "+transform(_nVlrUnit,cPict)+chr(13)+chr(10)
                           cTexto += "Valor na NF nro "+SD1->D1_DOC+": R$ "+transform(SD1->D1_VUNIT,cPict)
                           //U_EnvMail("Entrada com Preço a MENOR!!",cTexto,"sergioduo@brasilux.com.br",cAuxMail,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
                        Endif
                     Endif 
                  Endif
               Endif
            Endif // FIM IF (cTipo == "N")  
         Endif //FIM IF (SF4->F4_UPRC $ " S")    	  
         Dbselectarea("SB1")
         If lRet .and. (SB1->(FieldPos("B1_UPRCD1")) > 0)
            //Atualizar último custo de entrada
            If SELECT("TCQ") > 0
               TCQ->(DbcloseArea())
            Endif          
            nDec := TamSx3("B1_UPRCD1")[2]
            cQuery := "SELECT dbo.UltPreco('"+xFilial("SD1")+"','"+ALLTRIM(SD1->D1_COD)+"') AS CUSTO "
            TCQuery cQuery NEW ALIAS "TCQ"
            nCusto := ROUND(TCQ->CUSTO,nDec)
            Dbselectarea("TCQ")
            Dbclosearea()
            Dbselectarea("SB1")
            If (nCusto <= 0) .AND. (nPreco > 0)
               nCusto := nPreco
            Endif 
            SB1->B1_UPRCD1 := nCusto	
         Endif
         Dbselectarea("SB1")
         If !lBloqueado
            MsUnlock()
         Endif
      Endif // FIM IF (dDataBase >= SB1->B1_UCOM)
   Endif // FIM IF DbSeek(xFilial("SB1")+SD1->D1_COD) 
   If lRet .and. ((_cNumEmp == "01010106") .OR. (_cNumEmp == "01010107") .OR. (_cNumEmp == "01010108")) 
      If !(SD1->D1_TES = "265") //Ignorar geração de bloco C113 do Sped
         //Gravar registro de movimentação de saída para depósito p/ ref. p/ movim. interna na filial 010101
         Dbselectarea("SD1")
            nRegD1 := RecNo()
            Dbselectarea("ZZY")
            RecLock("ZZY", .T.)
               ZZY->ZZY_FILIAL := "010101"
               ZZY->ZZY_DOC := nRegD1
               ZZY->ZZY_TIPO := "E"
               ZZY->ZZY_TAB := "SD1"
            MsUnLock()
      Endif 
   Endif
   //BLOCO C113
   If lRet .and. !empty(alltrim(SF4->F4_CODINFC)) .AND. !(SD1->D1_TES = "265") .AND. (ALLTRIM(SD1->D1_TIPO) $ "D-N") .and. !EMPTY(ALLTRIM(SD1->D1_NFORI)) .AND. !EMPTY(ALLTRIM(SD1->D1_ITEMORI))
      Dbselectarea("SF2")
      Dbsetorder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
      Dbseek(xFilial("SF2")+SD1->D1_NFORI+SD1->D1_SERIORI)
      If found()
         Dbselectarea("CDD")
			Dbsetorder(1) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF                                                          
			Dbseek(xFilial("CDD")+"E"+padr(ALLTRIM(SD1->D1_DOC),TamSx3("CDD_DOC")[1]," ")+padr(alltrim(SD1->D1_SERIE),TamSx3("CDD_SERIE")[1]," ")+padr(SD1->D1_FORNECE,TamSx3("CDD_CLIFOR")[1]," ")+SD1->D1_LOJA+padr(SF2->F2_DOC,TamSx3("CDD_DOCREF")[1]," ")+padr(SF2->F2_SERIE,TamSx3("CDD_SERREF")[1]," ")+padr(SF2->F2_CLIENTE,TamSx3("CDD_PARREF")[1]," ")+SF2->F2_LOJA)
			If !found() 
				Reclock("CDD",.T.)
               CDD->CDD_FILIAL   := xFilial("CDD")
               CDD->CDD_TPMOV    := "E"
               CDD->CDD_DOC      := SD1->D1_DOC
               CDD->CDD_SERIE    := SD1->D1_SERIE
               CDD->CDD_CLIFOR   := SD1->D1_FORNECE
               CDD->CDD_LOJA     := SD1->D1_LOJA
               CDD->CDD_DOCREF   := SF2->F2_DOC
               CDD->CDD_SERREF   := SF2->F2_SERIE
               CDD->CDD_PARREF   := SF2->F2_CLIENTE
               CDD->CDD_LOJREF   := SF2->F2_LOJA
            Else
               Reclock("CDD",.f.)
            Endif 
            CDD->CDD_IFCOMP   := SF4->F4_CODINFC
            CDD->CDD_CHVNFE   := SF2->F2_CHVNFE
            CDD->CDD_SDOC     := SD1->D1_SERIE
            CDD->CDD_SDOCRF   := SF2->F2_SERIE
            CDD->CDD_ENTSAI   := "2"
            Msunlock()
      Endif 
   Endif 
   U_VoltaArea( aAreaAnt )
   
   If !empty( _aAlias )
      RestArea( _aAlias )
   Endif 
   If !lRet
      If ( _lVVarNull .And. l103Auto ) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
         FwLogMSG( "WARN", , 'SIGAEST', funname(), '', '01', _cMensErro, 0 )
      Else
         MsgBox(_cMensErro, "Atenção", "STOP")
      Endif
   Endif

Return( lRet )
