#include 'TOTVS.CH'
#include 'topconn.CH'

User Function MTA650I()
     Local _cArea     := Alias()  
     Local aAreaAnt   := U_PegaArea({"QPK","SB1","SZH","SC2"})
     Local lBloqueado := .f.
     Local lBloqueou  := .f.
     Local xNumLote   := space(6)  
     local nRegC2
     Local cQry1 	  := ""
     Local cTexto	  := ""
     Local cTextoBase := ""
     
     Local lContrLot
     Local cOrdem     := SC2->C2_NUM
     Local cItem      := SC2->C2_ITEM
     Local cSeqPa     := SC2->C2_SEQUEN
     Local cIteGrd    := SC2->C2_ITEMGRD
     Local cProd      := SC2->C2_PRODUTO
     Local cLotePA    := ""
     Local nRegi  
     Local nVolume    := 0
     Local nFator     := 0 
     Local _cGrpEmp := alltrim(FWGrpCompany())

If _cGrpEmp <> '11' //Empresas do Grupo BRASILUX
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³ MTA650I  ºAutor  ³                    º Data ³    /  /     º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³ Grava dados na inclusão da Ordem de Produção               º±±
        ±±º          ³                                                            º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
        aGerTXTOPs := Iif(Type("aGERTXTOps") == "U", {}, aGerTXTOPs) 
        cCallMenu  := Iif(Type("cCallMenu") == "U", "S", cCallMenu)
        lGerTxt    := Iif(Type("aGerTxtOps") == "U", .f.  , .t. ) //Envase

        dbselectarea("SB1")
        dbsetorder(1)
        dbseek(xFilial("SB1")+SC2->C2_PRODUTO)

        dbselectarea("SC2")
        nRegC2 := RecNo()
        lBloqueado := U_EstaBloqueado('SC2', nRegC2)
        If !lBloqueado .and. !lBloqueou
           RecLock("SC2", .F.)
              lBloqueou := .t.	
        Endif
        If (cNumEmp == "01010104") //Para Filial Resina
           If Empty(SC2->C2_LOTE)
              If Len(Alltrim(SC2->C2_PRODUTO)) == 4 .or. Len(Alltrim(SC2->C2_PRODUTO)) == 5 //Resina Principal
                 xNumLote := U_NumSeqLot("SZZ")
              ElseIf Len(Alltrim(SC2->C2_PRODUTO)) == 7
                     cQry1 := ""
                     cQry1 += "SELECT TOP 1 SC2.C2_PRODUTO, SC2.C2_LOTE "
                     cQry1 += "FROM "+RetSqlname("SC2")+" SC2 WITH (NOLOCK) "
                     cQry1 += "WHERE (SC2.C2_FILIAL = '"+xFilial("SC2")+"') "
                     cQry1 += "  AND (SC2.D_E_L_E_T_ = '') "
                     cQry1 += "  AND (SC2.C2_NUM <> '"+SC2->C2_NUM+"') "
                     cQry1 += "  AND (SC2.C2_PRODUTO = '"+SUBSTR(SC2->C2_PRODUTO,1,5)+"') "
                     cQry1 += "  AND (SC2.C2_QUJE = 0) "
                     cQry1 += "ORDER BY R_E_C_N_O_ DESC "
                     TCQuery cQry1 ALIAS "TCQ" NEW
                     DbSelectArea("TCQ")             
                     if !eof() .and. !bof()
                        xNumLote := TCQ->C2_LOTE
                     Endif
                     DbSelectArea("TCQ")
                     DbCloseArea()
                     DbSelectArea("SC2")
              Endif
              SC2->C2_LOTE := xNumLote
           Endif
	     Else
           //Buscar e inserir numero de lote
	       If Empty(SC2->C2_LOTE)
              //xNumLote := U_NumSeqLot("SZZ")
              If (cNumEmp == "01010101") 
                  //If SC2->C2_PRODUTO $ 'MANUTENCAO'
                     //xNumLote := ""
                  //Else
                     xNumLote := U_NroSqLote("SZZ")
                  //Endif
              Else
                  xNumLote := U_NumSeqLot("SZZ")
              Endif
              SC2->C2_LOTE := xNumLote
           Endif
        Endif
        SC2->C2_OP := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
        DbSelectArea("SC2")
        If !lBloqueado .and. lBloqueou
           MsUnLock()
        Endif

        //Cleber (27/06/2017)-> Michelly pediu pra tirar embalagem 38 da tinta em pó
        If (Len(Alltrim(SC2->C2_PRODUTO)) == 4) .OR. ((SB1->B1_TIPO = "PA") .AND. !((LEN(ALLTRIM(SB1->B1_COD)) == 12) .AND. (SUBSTR(SB1->B1_COD,4,2) $ "97-98-99") .AND. (SUBSTR(SB1->B1_COD,11,2) = "38")))
	       // CHAMADO 005575 - Workflow enviado quando op de pi k ultrapassa média de consumo no mês, solicitada por Gustavo Diniz        
	       //Cleber(18/10/16) -> Estava mandando e-mail errado, refazendo as queries:   
	       //Cleber(23/06/17) -> Chamado 006637, enviar e-mail para quando qtde de PA ultrapassar média de vendas dos últimos 3 meses
		   //André(29/09/17) -> Chamado 008297, alterar para quando qtde de PA ultrapassar média de vendas dos últimos 4 meses ao invés dos 3
		   //André(22/10/18) -> Chamado 011413 e 011412, alterar a quantidade de PI de 45 para 90 dias e PA para 180 dias
		   cQry1 := ""
	       cQry1 := "SELECT ISNULL(SUM(B2_QATU),0.0) AS QATU,ISNULL(SUM(B2_QATU-B2_QEMP-B2_RESERVA),0.0) AS DISP,ISNULL(MAX(ZZ2_MEDIA),0.0) AS MEDIA, "+;
	       "MAX(B1_DESC) AS DESCPRO "+;
	       "FROM "+RetSqlname("SB2")+" SB2 WITH (NOLOCK) "+;  
	       "LEFT OUTER JOIN "+RetSqlname("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ ='') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = B2_COD) "+;  
	       "LEFT OUTER JOIN "+RetSqlname("ZZ2")+" ZZ2 WITH (NOLOCK) ON (ZZ2.D_E_L_E_T_ ='') AND (ZZ2_FILIAL = '"+xFilial("ZZ2")+"') AND (ZZ2_COD = B2_COD) "+;  
	       "WHERE (SB2.D_E_L_E_T_ ='') AND (B2_FILIAL = '"+xFilial("SB2")+"') AND (B2_COD = '"+Alltrim(SC2->C2_PRODUTO)+"')AND (B1_MSBLQL <>'1') AND "+;
	       "(((B1_TIPO = 'PI') AND (B1_UM IN ('K','KG')) AND (B1_GRUPO NOT BETWEEN 'PI00' AND 'PI99')) OR (B1_TIPO = 'PA')) "

   	       TCQuery cQry1 ALIAS "SC2WF" NEW
           DbSelectArea("SC2WF")             

         IF !Eof() .and. !Bof() .and. ((SB1->B1_TIPO = "PI") .AND. ((SC2WF->DISP+SC2->C2_QUANT) > (SC2WF->MEDIA * 3))) .OR. ((SB1->B1_TIPO = "PA") .AND. ((SC2WF->DISP+SC2->C2_QUANT) > (SC2WF->MEDIA*6)))             
		      cTextoBase:= "Emissão de Ordem de Produção "+iif((SB1->B1_TIPO = "PI"),"PI Kg","de Prod. Acabado")+" ultrapassando consumo médio de "+iif((SB1->B1_TIPO = "PI"),"90","180")+" dias"
			   cTexto := cTextoBase+", verificar necessidade !"+CHR(13)+CHR(10)
			   cTexto+= CHR(13)+CHR(10)+"Produto :  "+SC2->C2_PRODUTO+' - '+SC2WF->DESCPRO+ ", Lote ->  "+SC2->C2_LOTE
			   cTexto+= CHR(13)+CHR(10)+"Saldo Total Atual -> "+TRANSFORM(SC2WF->QATU,'@E 999,999,999.99')
			   cTexto+= CHR(13)+CHR(10)+"Saldo Total Disponível (Qtde Atual - Empenho - Reserva) -> "+TRANSFORM(SC2WF->DISP,'@E 999,999,999.99')
			   cTexto+= CHR(13)+CHR(10)+"Saldo Disponível + Qtde Prevista  -> "+TRANSFORM(SC2WF->DISP+SC2->C2_QUANT,'@E 999,999,999.99')
   			cTexto+= CHR(13)+CHR(10)+"Consumo Médio -> "+TRANSFORM(SC2WF->MEDIA,'@E 999,999,999.99')+CHR(13)+CHR(10)
			   cTexto+= CHR(13)+CHR(10)+"O.P gerada por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
			   cTexto+= CHR(13)+CHR(10)+"Prog. Origem : MTA650I"

			   If Substr(xFilial("SC2"),1,2)== "06"
				   U_EnvMail("DISSOLTEX - "+cTextoBase+". Produto -> "+SC2->C2_PRODUTO ,cTexto,"materiais@dissoltex.com.br","")  
            Else
				   U_EnvMail("BRASILUX  - "+cTextoBase+". Produto -> "+SC2->C2_PRODUTO ,cTexto,"materiais@brasilux.com.br","") //                       	  
			   Endif  
         ENDIF    
            
           DbSelectArea("SC2WF")
           DbCloseArea()	
        Endif
        If Len(Alltrim(SC2->C2_PRODUTO)) == 12  // Projeto 21 - Disparar WorkFlow quando não houve saldo dos produtos na emissão da ordem de produção
           cTexto := ""
	       cQry1  := ""
           cQry1  += " SELECT D4_COD, MAX(B1_DESC) AS B1_DESC, D4_LOCAL, SUM(D4_QUANT) AS D4_QUANT, MAX(B2_QATU) AS B2_QATU, (MAX(B2_QATU) - SUM(D4_QUANT)) AS 'DISP', B1_GRUPO, "
		   cQry1  += " 'SALTOTAL' = (SELECT SUM(B2_QATU) FROM "+RetSqlName("SB2")+" WITH(NOLOCK) WHERE D4_FILIAL = B2_FILIAL AND D4_COD = B2_COD AND D_E_L_E_T_ ='' AND SUBSTRING(B2_LOCAL,1,1) NOT IN('G','M') ) "
		   cQry1  += " FROM "+RetSqlName("SD4")+" SD4 WITH(NOLOCK) "
		   cQry1  += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON (B2_FILIAL = D4_FILIAL) AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND SB2.D_E_L_E_T_ ='' "
		   cQry1  += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON (B1_FILIAL = D4_FILIAL) AND B1_COD = D4_COD AND SB1.D_E_L_E_T_ ='' "
		   cQry1  += " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) ON (C2_FILIAL = D4_FILIAL) AND C2_OP = D4_OP AND SC2.D_E_L_E_T_ ='' "
		   cQry1  += " WHERE (SD4.D_E_L_E_T_ ='') AND B1_GRUPO NOT BETWEEN('PI00') AND ('PI99') "
		   cQry1  += " AND (D4_FILIAL  = '"+xFilial("SD4")+"')"
		   cQry1  += " AND C2_LOTE = '"+SC2->C2_LOTE+"'"
		   cQry1  += " GROUP BY D4_FILIAL, D4_COD, D4_LOCAL, B1_GRUPO "
           //cQry1  += " HAVING SUM(D4_QUANT) > MAX(B2_QATU) "
           cQry1  += " HAVING SUM(D4_QUANT) > (SELECT SUM(B2_QATU) FROM "+RetSqlName("SB2")+" WITH(NOLOCK) WHERE D4_FILIAL = B2_FILIAL AND D4_COD = B2_COD AND D_E_L_E_T_ ='' AND SUBSTRING(B2_LOCAL,1,1) NOT IN('G','M') ) "
           cQry1  += " ORDER BY D4_COD,D4_LOCAL " 

           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           DbGoTop()

           While !Eof()  
               // produto de custeio
               If U_IsProdCusto(TCQ->D4_COD)
                  TCQ->(dbSkip())
                  Loop
               Endif       
                 If (TCQ->D4_QUANT) > (TCQ->SALTOTAL)
                    cTexto += "Produto "+TCQ->D4_COD+" - "+TCQ->B1_DESC+" com saldo insuficiente em todos os almoxarifados somados "+Alltrim(TransForm(TCQ->SALTOTAL, "@E 99999"))+" Local -> "+TCQ->D4_LOCAL+CHR(13)+CHR(10)
   		         Endif
    	         DbSelectArea("TCQ")
    	         DbSkip()
	       Enddo
           DbSelectArea("TCQ")
           DbCloseArea()
           If Len(Alltrim(cTexto)) >0
              cTexto += CHR(13)+CHR(10)+"Prog. Origem : MTA650I"
              If Substr((SC2->C2_FILIAL),1,2)== "06"
                 U_EnvMail("DISSOLTEX - O.P Lote "+SC2->C2_LOTE+" emitido, porém, existe falta de Saldo !" ,cTexto,"silene@dissoltex.com.br","") 
              Else
                 U_EnvMail("BRASILUX - O.P Lote "+SC2->C2_LOTE+" emitido, porém, existe falta de Saldo !" ,cTexto,"compras@brasilux.com.br, pcp@brasilux.com.br, paulo@brasilux.com.br","")                       	  
              Endif
           Endif
        Endif
        //Verificar se existe o item na tabela QPK e colocar o numero de lote também.
        DbSelectArea("QPK")               
        DbSetOrder(1)
        DbSeek(xFilial("QPK")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, .t.)
        If Found()
           RecLock("QPK", .f.)
              QPK->QPK_LOTE := SC2->C2_LOTE
           MsUnLock()
        Endif       
        //Alimentar tabela SZZ
        If cCallMenu $ 'S'
           Reclock("SZZ", .t.)
              SZZ->ZZ_FILIAL  := xFilial("SZZ")
              SZZ->ZZ_LOTE    := SC2->C2_LOTE
              SZZ->ZZ_DTEMIS  := SC2->C2_EMISSAO
              SZZ->ZZ_PRODUTO := SC2->C2_PRODUTO
              SZZ->ZZ_DESCR   := SB1->B1_DESC
              SZZ->ZZ_PREVI   := SC2->C2_DATPRF
              SZZ->ZZ_PREVF   := SC2->C2_DATPRI
              SZZ->ZZ_EMB     := ""
              SZZ->ZZ_DESEMB  := ""
              SZZ->ZZ_QTDETI  := 0
              SZZ->ZZ_TPINCL  := "C" 
              SZZ->ZZ_PEDIDO  := ""
           MsUnlock()
        Endif
        If cNumEmp = '01010101'
           If lGerTxt
              aAdd(aGerTxtOps, {SZZ->ZZ_PRODUTO, SZZ->ZZ_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, SC2->C2_QUANT })
           Endif
        Endif        
Else // If _cGrpEmp <> '11'
        /*Programa MTA650I()
          Desenvolvedor: Igor Manrique - chaus
          Função: 1) Copiar o lote do PA para os PIs que utilizam controle de lote;
                  2) Copiar a quantidade de volume por tanque para as OPs intermediárias;
        */
        _lPAR0056 := GETMV('ZP_PAR0056')

        DbSelectArea("SC2")
        nRegi := recno()
        
        If GetMv("MV_XBIPOP") 
           DbSelectArea("SC2")
           DbSetOrder(1)
           DbGoTo(nRegi)
           Reclock("SC2",.F.)
              SC2->C2_XOP := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
           MSUNLOCK()
        Endif	
        If !(cSeqPa == "001")
           lContrLot := Alltrim(POSICIONE("SB1", 1, xFilial("SB1")+cProd,"B1_RASTRO")) == "L"

           dbSelectArea("SC2")
           dbSetOrder(1)
           dbSeek(xFilial("SC2")+cOrdem+cItem+"001"+cIteGrd)

           If lContrLot
              cLotePa := SC2->C2_XLOTE
           Endif
           nVolume := SC2->C2_XVOLTNQ
           nFator  := SC2->C2_XCONV

           dbSelectArea("SC2")
           dbGoTo(nRegi)
           Reclock("SC2",.F.)
              If lContrLot
                 SC2->C2_XLOTE := cLotePa
              Endif
              SC2->C2_XVOLTNQ := nVolume
              SC2->C2_XCONV   := nFator
           MSUNLOCK()
        Else //LGS#20220722 - Integração Protheus x ProdWin - Envia somente a sequencia 001 para o ProdWin
           If _lPAR0056
              u_ZWSDLI01()
           Endif           
        Endif
Endif //If _cGrpEmp <> '11'
U_VoltaArea(aAreaAnt)
If !Empty( _cArea )
   DbSelectArea( _cArea )
Endif 
Return
