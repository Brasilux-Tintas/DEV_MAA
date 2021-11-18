#include "rwmake.ch"
#include "totvs.ch"
  /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ MT100TOK º Autor ³ Cleber Orati       º Data ³  01/03/12   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDescri‡„o ³ Validação de NFs ELETRONICAS obrigando a preencher a chave º±±
  ±±º          ³ da NFE                                                     º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±³ Uso      ³ PONTO DE ENTRADA                                           ³±±
  ±±³          ³ COM - MATA103 - ENTRADA DE NOTAS FISCAIS                   ³±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
  //25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
  //02/06/20 -> Não permitir entrada de MP sem pedido
User Function MT100TOK()
     Local lRet, cAuxMens, _x,nTx
     Local cArea       := Alias()
     Local aArea       := U_PegaArea( { "SC7", "SF4","SB1" } )
     Local nPosCst     := aScan(aHeader, { |x| Trim( x[2] ) == "D1_CLASFIS" } ) 
     Local nPosPed     := aScan(aHeader, { |x| Trim( x[2] ) == "D1_PEDIDO"  } ) 
     Local nPosItem    := aScan(aHeader, { |x| Trim( x[2] ) == "D1_ITEMPC"  } ) 
     Local nPosXCst    := aScan(aHeader, { |x| Trim( x[2] ) == "D1_XCST"    } ) 
     Local nPosBs5     := aScan(aHeader, { |x| Trim( x[2] ) == "D1_BASIMP5" } ) //Posicionamento do campo D1_BASIMP5 no aHeader
     Local nPosBs6     := aScan(aHeader, { |x| Trim( x[2] ) == "D1_BASIMP6" } ) //Posicionamento do campo D1_BASIMP6 no aHeader
     //Local nPosI5      := aScan(aHeader, { |x| Trim( x[2] ) == "D1_VALIMP5" } ) //Posicionamento do campo D1_BASIMP5 no aHeader
     //Local nPosI6      := aScan(aHeader, { |x| Trim( x[2] ) == "D1_VALIMP6" } ) //Posicionamento do campo D1_BASIMP6 no aHeader
     Local nPosTES     := aScan(aHeader, { |x| Trim( x[2] ) == "D1_TES"     } ) //Posicionamento do campo D1_TES no aHeader
     Local nPosD1SIM3G := aScan(aHeader, { |x| Trim( x[2] ) == "D1_X_SIM3G" } ) //Posicionamento do campo D1_X_SIM3G no aHeader
     Local nPosNfOri    := aScan(aHeader, { |x| Trim( x[2] ) == "D1_NFORI"    } ) //Posicionamento do campo D1_NFORI no aHeader
     Local nPosCod     := aScan(aHeader, { |x| Trim( x[2] ) == "D1_COD"    } ) //Posicionamento do campo D1_COD no aHeader
     Local nPosVunit   := aScan(aHeader, { |x| Trim( x[2] ) == "D1_VUNIT"    } ) //Posicionamento do campo D1_VUNIT no aHeader
     Local lPis, lCof, cMens,_cGrpEmp,lAchou,_nTam,_nVlrUnit //, cTes
     Local _lVVarNull  := Type("l103Auto") <> "U"
     u_zcfga01( 'MT100TOK' ) //LGS#2021118 - Gravação de log de utilização da rotina
_cGrpEmp := alltrim(FWGrpCompany())

     //If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa). //Cleber(24/02/20) -> Considerar TecPolpa para MasterSales, outras validações também serão consideradas

lPis := .f.
lCof := .f.
nTx := 0 //Taxa Moeda do Pedido
lRet := .t. 
dbselectarea("SC7") //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN  
dbsetorder(1)
dbselectarea("SF4")
dbsetorder(1)
dbselectarea("SB1")
dbsetorder(1)
        
        
For _x := 1 to Len(aCols)
   If !aCols[_x][Len(aHeader)+1] //Se não for registro deletado   
               If (((nPosPed > 0) .and. (nPosCst > 0)) .or. (nPosXCst > 0)) .and. (nPosItem > 0)
                  If (nPosXCst >0) .and. !empty(aCols[_x][nPosXCst]) 
                     If !(trim(aCols[_x][nPosXCst]) == trim(aCols[_x][nPosCst]))
                        lRet = .f.
                        cAuxMens := "CST DIVERGE ARQUIVO XML ORIGINAL. CORRIJA POR FAVOR!!"
                        /*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                        //If ( Type("l103Auto") <> "U" .And. l103Auto )		               
                        If ( _lVVarNull .And. l103Auto )
                           //ConOut(cAuxMens)
                           FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
                        Else 
                           MsgBox(cAuxMens, "Atenção", "STOP")
                        Endif 
                        EXIT 
                     Endif 
                  Else
                     If !empty(aCols[_x][nPosPed]) .and. !empty(aCols[_x][nPosItem])
                        dbselectarea("SC7")
                        dbseek(xFilial("SC7")+padr(aCols[_x][nPosPed],TamSx3("D1_PEDIDO")[1])+aCols[_x][nPosItem])
                        If found() .and. (SC7->(FieldPos("C7_XCST")) > 0) 
                           If !empty(trim(SC7->C7_XCST)) .and. !(trim(SC7->C7_XCST) == trim(aCols[_x][nPosCst]))
                              lRet = .f.
                              cAuxMens := "CST DIVERGE DO PEDIDO DE COMPRA. CORRIJA POR FAVOR!!"
                              /*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                              If ( _lVVarNull .And. l103Auto )
                              //If ( Type("l103Auto") <> "U" .And. l103Auto )		               
                                 //ConOut(cAuxMens)
                                 FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
                              Else 
                                 MsgBox(cAuxMens, "Atenção", "STOP")
                              Endif 
                              EXIT 
                           Endif
                        Endif
                     Endif
                  Endif
               Endif //if (((nPosPed > 0) .and. (nPosCst > 0)) .or. (nPosXCst > 0)) .and. (nPosItem > 0)
            if nPosD1SIM3G > 0
               aCols[_x][nPosD1SIM3G] := "N"
            endif 
            If nPosTES > 0    		
               DbSelectArea("SF4") //Tipo de Entrada e Saída
               DbSeek(xFilial("SF4")+aCols[_x][nPosTES])
               If Found()
                  IF (cTipo = "D") .and. (nPosD1SIM3G > 0) .and. !empty(aCols[_x][nPosNfOri]) .and. (SF4->F4_DUPLIC = "S") 
                     aCols[_x][nPosD1SIM3G] := "S"
                  ENDIF
                  //Checar PIS/COFINS pois em Nov/2013 passou a não zerar os impostos qdo se troca um TES com pis/cofins por outro sem.
                  IF !(_cGrpEmp == '11') //Desconsiderar TecPolpa!
	                  //F4_PISCOF =>	1=PIS;2=COFINS;3=Ambos;4=Nao Considera
	                  If (nPosBs5 > 0) .and. (SF4->F4_AGREG <> 'B') .AND. (aCols[_x][nPosBs5] > 0) .AND. (SF4->F4_PISCOF <> '2') .AND. (SF4->F4_PISCOF <> '3')
	                        /*
	                        aCols[_x][nPosBs5] := 0
	                        aCols[_x][nPosI5] := 0
	                        */
	                     lRet := .f.
	                     lCof := .t.
	                  Endif
	                  If (nPosBs6 > 0) .and. (SF4->F4_AGREG <> 'B') .AND. (aCols[_x][nPosBs6] > 0) .AND. (SF4->F4_PISCOF <> '1') .AND. (SF4->F4_PISCOF <> '3')
	                        /*
	                        aCols[_x][nPosBs6] := 0
	                        aCols[_x][nPosI6] := 0 
	                        */
	                     lRet := .f.
	                     lPis := .t.
	                  Endif
	                  If !lRet
	                     exit
	                  Endif 

	               ENDIF
                  if lRet .and. (nPosPed > 0).and. (nPosItem > 0) .and. (nPosCod > 0).and. (cTipo = "N") .AND. (SF4->F4_ESTOQUE = 'S') .AND. (SF4->F4_DUPLIC $ " S")
                        if lRet
                           dbselectarea("SC7")
                           dbseek(xFilial("SC7")+padr(aCols[_x][nPosPed],TamSx3("D1_PEDIDO")[1])+aCols[_x][nPosItem])
                           if found()
                              if (SC7->C7_MOEDA > 1) //.AND. (SC7->C7_TXMOEDA > 0)
                                 dbselectarea("SC7")
                                 nTx := xMoeda(1,SC7->C7_MOEDA,1,dDEmissao,TamSx3("C7_TXMOEDA")[2])
                                 if nTx <= 0
                                    cAuxMens := "Taxa para a moeda "+alltrim(str(SC7->C7_MOEDA))+" não está cadastrada na data "+dtoc(dDEmissao)
                                    lRet := .f.
                                 else 
                                    if SC7->C7_TXMOEDA != nTx
                                       RecLock("SC7",.f.)
                                       SC7->C7_TXMOEDA := nTx
                                       msunlock()
                                    endif 
                                 endif 
                              endif 
                           endif 
                        endif 
                        DBSelectArea("SB1") 
                        dbseek(xFilial("SB1")+aCols[_x][nPosCod])
                        if found() .AND. lRet .and. (ALLTRIM(SB1->B1_TIPO) $ "MP.MC")
                           do case 
                           case empty(aCols[_x][nPosPed])
                              lRet := .f.
                              cAuxMens := "Proibida a entrada de NF SEM PEDIDO!"
                           case empty(alltrim(SB1->B1_POSIPI))
                              lRet := .f.
                              cAuxMens := "Produto "+alltrim(SB1->B1_COD)+" está sem NCM! Necessário seu preenchimento antes!"
                           otherwise
                              dbselectarea("SC7")
	                           dbseek(xFilial("SC7")+padr(aCols[_x][nPosPed],TamSx3("D1_PEDIDO")[1])+aCols[_x][nPosItem])
                              if !found()
                                 lRet := .f.
                                 cAuxMens := "Não encontrado o pedido nro "+aCols[_x][nPosPed]+"/"+aCols[_x][nPosItem]
                              else
                                 IF (_cGrpEmp == "01") .and. (SF4->F4_UPRC $ " S")
                                    //*****************************************
                                    //Validar valor com relação à Tolerância
                                    
                                    lAchou := .f.
                                    DbSelectArea("AIC")
                                    DbSetOrder(2) //AIC_FILIAL+AIC_FORNEC+AIC_LOJA+AIC_PRODUT+AIC_GRUPO                                                                                                             
                                    dbseek(xFilial("AIC")+cA100For+cLoja+aCols[_x][nPosCod])
                                    lAchou := found()
                                    if !lAchou
                                       dbseek(xFilial("AIC")+cA100For+cLoja)
                                       lAchou := found()
                                    endif
                                    if !lAchou
                                       _nTam := TamSx3("AIC_FORNEC")[1]
                                       dbseek(xFilial("AIC")+space(_nTam+2)+aCols[_x][nPosCod])
                                       lAchou := found()
                                    endif 
                                    if !lAchou
                                       lRet := .f.
                                       cAuxMens := "Favor cadastrar a TOLERÂNCIA DE RECEBIMENTO para o Produto "+alltrim(aCols[_x][nPosCod])+" na filial "+xFilial("SD1")
                                    endif 
                                    if lAchou 
                                       _nVlrUnit := SC7->C7_PRECO*iif((SC7->C7_MOEDA != 1) .AND. (SC7->C7_TXMOEDA > 0),SC7->C7_TXMOEDA,1)
                                       if (abs(aCols[_x][nPosVunit] - _nVlrUnit)*100/_nVlrUnit) > AIC->AIC_PPRECO
                                          lRet := .f.
                                          cAuxMens := "Produto "+alltrim(aCols[_x][nPosCod])+" está fora da tolerância de preço permitida!"
                                       endif 
                                    endif
                                 ENDIF
                                 //****************************************
                              endif 
                           endcase 
                        endif

                        if !lRet
                           If ( _lVVarNull .And. l103Auto )
                              FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
                           Else 
                                 MsgBox(cAuxMens, "Atenção", "STOP")
                           Endif  
                           exit 
                        endif                       
                  endif
               Endif 
            Endif //Fim if nPosTES > 0
   Endif //Se não for registro deletado 
next

If lPis .OR. lCof      
   cMens := ""
   If lPis
      cMens := "PIS"
   Endif
   If lCof
      If !empty(cMens)
         cMens += " e "
      Endif
      cMens += "COFINS" 
   Endif
   cMens += " está(ão) destacado(s) INDEVIDAMENTE pois no TES diz pra não GERAR! Corrija o problema!"
   MsgBox(cMens,"Atenção","STOP")
Endif
        /*	
        if !(ALLTRIM(cFormul) == "S") .AND. (alltrim(cEspecie) == "SPED") .and. (LEN(ALLTRIM(M->F1_CHVNFE)) <> 44)
           lRet := .f.    
           cAuxMens := "PREENCHA A CHAVE DA NOTA FISCAL ELETRONICA!!"
           if ( Type("l103Auto") <> "U" .And. l103Auto )		               
              //ConOut(cAuxMens)
           else 
              MsgBox(cAuxMens, "Atenção", "STOP")
           endif 
        endif 
        */
        //RestArea(aArea)
     //Endif // Fim If FWCodEmp() <> '11'
U_VoltaArea(aArea)
If !empty(cArea)
	dbselectarea(cArea)
Endif
Return(lRet)

