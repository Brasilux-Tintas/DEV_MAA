#include 'brasilux.ch'
#include "rwmake.ch"
#include "protheus.ch"
#include 'topconn.ch'
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ BRPCPX04 ºAutor  ³ Luís G. de Souza   º Data ³  25/11/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Lançamento das ordens de produções em batch.               º±±
  ±±º          ³                                                            º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  Alterações: Cleber Orati Domingues -> Utilizaçào de SigaAuto - BRPCP013
              Luís Gustavo de Souza  -> Melhorias nas telas do programa, alteração
                                        nos nomes das funções, utilização de objetos,
                                        implementação de função para geração de arquivo
                                        para dosador
              Cleber(03/03/15) -> Melhoria no bloqueio que impede que mais de 1 pessoa acesse a rotina
*/
User Function BRPCPX04()
     Local aTcq          := {}
     Local aGerTxt       := {}

     Local cArqBloq, aBloq,_cAreaBloq,cAux
     Local _lOpen        := .F. //LGS#20200204 - Adequação para release 12.1.25
     Private aGerTxtOps  := {}
     Private cCallMenu   := "L"
     Private xLotes           // Tab. c/ os lotes gerados.     
     Private cCodUsr     := RetCodUsr()
     Private cAcessos    := ""
     Private cRotina     := "BRPCPX04"
     Private _cCadastro  := "Ordens de Produção"
     Private lAcs1       := .f.  //Acessa a Rotina
     Private lAcs2       := .f.  //Visualiza Envasadores
     Private _cAliasSX3  := GetNextAlias() //LGS#20200204 - Adequação para release 12.1.25
     Private oTempTbl01
     	
     If !(cNumEmp == "01010101") .AND. !(cNumEmp == "01010104") .AND. !(cNumEmp == "01060101") .AND. !(substr(cNumEmp,1,2) == "05")
        MSGBOX("Essa empresa não aceita cadastro de lotes de produção","ATENÇÃO...","STOP")
        Return nil
     Endif
     u_zcfga01( 'BRPCPX04' ) //LGS#2021201 - Gravação de log de utilização da rotina
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200204 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, NIL, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen //LGS#20200204 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir o dicionário SX3.", "Atenção...", 16 )
        Return
     Endif

     SetFunName("MATA650") //LGS#20190507 - Para funcionar a integração com o PPI Multitask

     //Verificar se a rotina esta sendo executada por alguém
     //cFlagRot := alltrim(getmv('MV_BXOPLAN'))
  	 cRotina  := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), space(10 - Len(cRotina)))
   	 cAcessos := Posicione("SZW", 4, xFilial("SZW")+cRotina+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")

   	 lAcs1    := Iif(SubStr(cAcessos, 01, 1) == '*', .t., .f.) //Acessa a rotina
     lAcs2    := Iif(SubStr(cAcessos, 02, 1) == '*', .t., .f.) // Visualiza envasadores (Antigo Cadastro de Envasadores)

	 If !lAcs1
       	MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
       	DbSelectArea( _cAliasSX3 )
       	DbCloseArea()
       	Return
     Endif

     // Verificar se tem alguém usando a rotina
     cArqBloq := "BRPCPX04"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
    if aBloq[1,1] //Já estava bloqueado?
   		cAux := "O programa já está sendo usado por: "+aBloq[1,2]
		Messagebox(cAux,"Atenção!",48) 		
		Return
	endif
	_cAreaBloq := aBloq[1,4]

     aTcq = {}    
     AADD( aTcq, { "LOTE", "C", 6, 0 } )

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
   
     xLotes := GetNextAlias()
     //Use &xLotes Alias &xLotes new
     oTempTbl01 := FWTemporaryTable():New( xLotes )
     oTempTbl01:SetFields( aTcq )
     oTempTbl01:Create()
     /********************************************************************************************************************************/

     VerLotesAb() // Preencher tabela temporária com lotes em aberto que não foram processados antes.

     Private aRotina    := { { OemToAnsi("Pesquisar")        , 'AxPesqui'       , 0, 1   },; //Pesquisar
                             { OemToAnsi("Visualizar")       , 'U_FATX04_1("V")', 0, 2   },; //Visualizar
                             { OemToAnsi("Incluir")          , 'U_FATX04_1("I")', 0, 3   },; //Inclusão
                             { OemToAnsi("Complemento")      , 'U_FATX04_1("C")', 0, 4   },; //Complemento
                             { OemToAnsi("Reprocesso")       , 'U_FATX04_1("R")', 0, 5   } } //Reprocesso

     If lAcs2
     //   aAdd(aRotina, { OemToAnsi("Envasador"), 'U_FATX04_2()', 0, 9 } )
         aAdd(aRotina, { OemToAnsi("Gera Op Por ponto de pedido"), 'U_ZPCPAX4()', 0, 9 } )
     Endif

     DbSelectArea("SZZ")
     DbSetOrder(1)
     MBrowse(06, 01, 22, 75, "SZZ")
     
     //Processa geração de Ordens de produções
     Processa({|lEnd| fGerOPS(@aGerTxt) } )  
  	 If (cNumEmp == "01010101")   // gerar txts somente para Matriz
     		Processa({|lEnd| u_fGerTXTOps(aGerTxt) } )
     Endif
     //Entra no cadastro de Ordens de produções para geração das intermediárias
     Mata650()
     
     // Apagar Arq. Temporário
     If Select( xLotes ) > 0   //  Jose 26/06/2024
        DbSelectArea(xLotes)
        DbCloseArea( )
     EndIf  //  Jose 26/06/2024
     oTempTbl01:Delete()   //LGS#20200206 - Adequação de release 12.1.25 e posteriores
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()

     /*If File(xLotes+".dbf")
       	cAux = xLotes+".dbf"
       	Delete File &cAux
     Endif*/

     DbSelectArea("SZZ")      
     
     //PutMv("MV_BXOPLAN", "")

     /*Else
	     cAuxQbr := cFlagRot
         cQbr1Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         cQbr2Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         cQbr3Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         cQbr4Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1)  )
         cMsgTel := "O Cadastro de O.P X Lote esta sendo usado pelo usuário: "+cQbr2Tx+", desde às: "+cQbr3Tx+" do dia "+cQbr4Tx+". Aguarde !!!"

         MsgStop(cMsgTel)

         If Hrs2Min( time() ) - Hrs2Min( SubStr( cFlagRot, 2 + At( "|", SubStr( cFlagRot, 3) ) + 1 ) ) >= 20 .or. Hrs2Min( time() ) - Hrs2Min( SubStr( cFlagRot, 2 + At( "|", SubStr( cFlagRot, 3) ) + 1 ) ) < 0
         	PutMv("MV_BXOPLAN", "")
         Endif
     Endif*/

     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg
    //PutMV( "ZP_PAR0014", '' )
Return

/*****************************************************************************************************************/
/*** FATX04_1 - Rotinas de Visualização / Inclusão / Complemento / Reprocessamento de ordens de produção       ***/
/*****************************************************************************************************************/
User Function FATX04_1(cOpc)
     Local nUsado       := 0
     Local cFieldOk     := Iif(cOpc $ "I.C", "U_fCamOPB()", "AllwaysTrue()")
     Local cLinOk       := Iif(cOpc $ "I.C", "U_fLinOPB()", "AllwaysTrue()")
     Local cTudoOk      := Iif(cOpc $ "I.C", "U_fTudOPB()", "AllwaysTrue()")
     Local nLinhas      := 6
     Local _nY
     Local nConv        := 0
     Local cObs         := "" // F - FNC EM ABERTO 
     						         // T - TEMPO MAIOR DO QUE 6 MESES SEM PRODUZIR 
     						         // P - PRIMEIRA PRODUÇÃO DO PRODUTO
                              // L - PRIMEIRO LOTE  
   //Local nReg         := SZM->(Recno())
     LOCAL cAuxProd 	  := ""
     Local _nQuant     := 0
     Local aAreaAnt 	  := U_PegaArea({"SC2"})
     Local pMes        := GETMV("ZP_PAR0082") // Config comparativo maior que X Meses
     Local cParaA      := GETMV("ZP_PAR0073") // Email PCP Brasilux
     Local cParaB      := GETMV("ZP_PAR0133") // Email PCP Brasilux
     Private nOpcE        := Iif(cOpc $ "V.R", 2, 3)
     Private _cLote       := CriaVar("ZZ_LOTE")    
     Private dEmissao     := dDataBase
     Private cDescric     := CriaVar("ZZ_DESCR")
     Private dPrevIni     := dDataBase
     Private dPrevFim     := dDataBase
     Private cPrevVol     := 0
     Private oLote, oEmissao, oDescric, oPrevIni, oPrevFim, _oProduto, oPrevVol
     Private nOpcA        := 0
     Private _cProduto    := CriaVar("ZZ_PRODUTO")
     Private aHeader      := {}
     Private aCols        := {}
	  Private lRefresh     := .T.
     Private aAltGetDados := {}
     Private _lSaida      := .f.
     aAltGetDados := {"ZZ_EMB", "ZZ_QTDETI", "ZZ_PEDIDO"}

     DbSelectArea("SZZ")
     TcRefresh("SZZ") 
	  TcRefresh("SZZ010")       
     If !cOpc $ 'I'
        _cLote    := SZZ->ZZ_LOTE
        dEmissao  := SZZ->ZZ_DTEMIS
        _cProduto := iif(len(alltrim(SZZ->ZZ_PRODUTO)) == 12,(SZZ->ZZ_PRODUTO),substr(SZZ->ZZ_PRODUTO,1,5))
        cDescric  := SZZ->ZZ_DESCR
        dPrevIni  := SZZ->ZZ_PREVI
        dPrevFim  := SZZ->ZZ_PREVF
     Endif
     
     fMonHea(@aHeader, @nUsado)
     fMonCol(@aHeader, @nUsado, @aCols, cOpc, _cLote)
     
     DEFINE MSDIALOG oDlgp TITLE OemToAnsi(_cCadastro) FROM 000,000 TO 355,610 PIXEL OF oMainWnd
            @ 032,001 GROUP oGrp1 TO 067,283 LABEL  ''                       PIXEL OF oDlgp
            @ 037,003 SAY OemToAnsi("Nº Lote")                               			   SIZE 030,009 PIXEL OF oDlgp
            @ 036,035 MSGET oLote    VAR _cLote    Picture "@R! X99999"      			   SIZE 020,009 PIXEL OF oDlgp    // Jose 06/03/2025   Picture "999999" 
            @ 037,100 SAY OemToAnsi("Emissão")                               			   SIZE 030,009 PIXEL OF oDlgp
            @ 036,130 MSGET oEmissao VAR dEmissao                            			   SIZE 040,009 PIXEL OF oDlgp When .f.
            @ 047,003 SAY "Produto"    COLOR CLR_HBLUE                       			   SIZE 030,009 PIXEL OF oDlgp
   			@ 046,035 MSGET _oProduto VAR _cProduto Picture "@R! XXX99.99.999-X9" F3 "SB1" SIZE 060,009 PIXEL OF oDlgp
            @ 047,100 SAY OemToAnsi("Descrição")                                           SIZE 030,009 PIXEL OF oDlgp
            @ 046,130 MSGET oDescric VAR cDescric Picture "@!"                             SIZE 100,009 PIXEL OF oDlgp
            @ 057,003 SAY OemToAnsi("Prev. Inicio")                                        SIZE 030,009 PIXEL OF oDlgp
            @ 056,035 MSGET oPrevIni VAR dPrevIni                                          SIZE 040,009 PIXEL OF oDlgp When .f.
            @ 057,100 SAY OemToAnsi("Prev. Fim")                                           SIZE 030,009 PIXEL OF oDlgp
            @ 056,130 MSGET oPrevFim VAR dPrevFim                                          SIZE 040,009 PIXEL OF oDlgp When .f. 
            @ 057,170 SAY OemToAnsi("Litros")                                              SIZE 030,009 PIXEL OF oDlgp      // Inclusão do volume total das embalagens, solicitado por Michelly
            @ 056,185 MSGET oPrevVol VAR cPrevVol Picture "999999.99"                      SIZE 045,009 PIXEL OF oDlgp When .f.
            
            oGetD := MsGetDados():New( 070, 001, 160, 276, nOpcE, cLinOk, cTudoOk, "", .T., aAltGetDados, 2,.f. , nLinhas, cFieldOk)
            oDlgp:nStyle         := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

            oLote:bWhen          := {|| .f. }
            oEmissao:bLostFocus  := {|| fValCab(@dEmissao, @oEmissao, @dPrevIni, @oPrevIni, @dPrevFim, @oPrevFim, @_cProduto, @_oProduto, @cDescric, @oDescric, @oPrevVol, @cPrevVol, 1) }
            _oProduto:bLostFocus := {|| fValCab(@dEmissao, @oEmissao, @dPrevIni, @oPrevIni, @dPrevFim, @oPrevFim, @_cProduto, @_oProduto, @cDescric, @oDescric, @oPrevVol, @cPrevVol, 2) }
            oDescric:bWhen       := {|| .f. }
            If !cOpc $ 'I'
               oEmissao:bWhen      := {|| .f. }
               _oProduto:bWhen     := {|| .f. }
               oPrevIni:bWhen      := {|| .f. }
               oPrevFim:bWhen      := {|| .f. }
               oPrevVol:bWhen      := {|| .f. }
            Endif
   //ACTIVATE MSDIALOG oDlgp CENTERED VALID _lSaida ON INIT EnchoiceBar( oDlgp, {|| Iif(oGetD:TudoOk(), nOpcA := 1, nOpcA := 0), Iif(nOpcA == 1, _lSaida := .t., nOpcA := 0), Iif(nOpcA == 1, oDlgp:End(), nOpcA := 0) }, {|| nOpcA := 0, _lSaida := .t., oDlgp:End()} )
     	    
     ACTIVATE MSDIALOG oDlgp CENTERED ON INIT EnchoiceBar(oDlgp, {||nOpcA:=If(oGetD:TudoOk() , 1,0),If(nOpcA==1,oDlgp:End(),Nil)},{||oDlgp:End()}) 
     
     If nOpcA == 1
        If cOpc $ 'R'
           DbSelectArea(xLotes)
           RecLock(xLotes,.T.)
           Replace lote with _cLote 
           MsUnLock()
        ElseIf cOpc == "C"
               _QtdPI := 0.00
               nConv    := Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_CONV")
               DbSelectArea(xLotes)
               RecLock(xLotes,.T.)
               Replace lote with _cLote 
               MsUnLock()
               For _nY := 1 to Len(aCols)
                   If aCols[_nY][Len(aHeader)+1] == .f.    
                   	 cAuxProd := iif(len(alltrim(_cProduto)) == 12,substr(_cProduto,1,10),substr(_cProduto,1,5))+aCols[_nY][1]
                      DbSelectArea("SZZ")
                      Reclock("SZZ", .t.)
                      SZZ->ZZ_FILIAL  := xFilial("SZZ")
                      SZZ->ZZ_LOTE    := _cLote
                      SZZ->ZZ_DTEMIS  := dEmissao
                      SZZ->ZZ_PRODUTO := cAuxProd //  Alltrim(SubStr(Alltrim(_cProduto), 1, 10)+aCols[_nY][1])
                      SZZ->ZZ_DESCR   := cDescric
                      SZZ->ZZ_PREVI   := dPrevIni
                      SZZ->ZZ_PREVF   := dPrevFim
                      SZZ->ZZ_EMB     := aCols[_nY][1]
                      SZZ->ZZ_DESEMB  := aCols[_nY][2]
                      SZZ->ZZ_QtdEti  := aCols[_nY][3]          		
                      SZZ->ZZ_TPINCL  := "C" 
                      SZZ->ZZ_PEDIDO  := aCols[_nY][4]
                      MsUnlock()
                      _cGravou := .t.

                      DbSelectArea("SZ5")
                      DbSetOrder(1)
                      DbSeek(xFilial("SZ5")+acols[_nY][1],.t.)
                      If Found()
                         DbSelectArea("SG1")
                         DbSetorder(1)
                         DbSeek(xFilial("SG1")+SubStr(Alltrim(SubStr(Alltrim(_cProduto), 1, 10))+aCols[_nY][1]+Space(15), 1, 15)+_cProduto, .t.)
                         if !found()
                            //_QtdPI := _QtdPI + Round((aCols[_nY][3] * SZ5->Z5_VOLUME), 2) 
                              _QtdPI := _QtdPI + Round((aCols[_nY][3] * nConv), 2)
                         else 
	                         do while !eof() .and. (SG1->G1_FILIAL = xFilial("SG1")) .and. (SG1->G1_COD = SubStr(Alltrim(SubStr(Alltrim(_cProduto), 1, 10))+aCols[_nY][1]+Space(15), 1, 15)) .and. (SG1->G1_COMP = _cProduto)
    	                       _QtdPI := _QtdPI + ( (aCols[_nY][3] * SG1->G1_QUANT) / ((100 - SG1->G1_PERDA) / 100) )
        	                    dbskip()
            	             Enddo 
            	         endif 
                      Endif
                      DbSelectArea("SC2")
                   Endif
               Next
        ElseIf cOpc == "I"
               cRoteiro := Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_OPERPAD")
               nConv    := Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_CONV")
               DbSelectArea("SG2")
               DbSetOrder(1)
               DbSeek(xFilial("SG2")+_cProduto+cRoteiro, .t.)
               If !Found()
                  MsgBox("Produto não tem roteiro padrão de operações cadastrado. Verifique !", "Informação...", "INFO")
               Endif
               _QtdPI := 0
              If (cNumEmp == "01010101") // Jose 25/03/2025
                  _cLote := U_NroSqLote("SZZ")  // Jose 25/03/2025
              Else // Jose 25/03/2025
                  _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
              Endif // Jose 25/03/2025
//            _cLote  := U_NroSqLote("SZZ") // Jose 11/03/2025 25/03/2025
               
               DbSelectArea(xLotes) 
               RecLock(xLotes, .t.) 
                  Replace lote with _cLote 
               MsUnLock() 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
               cQry1 := ""
               cQry1 += " SELECT QI2_FNC, QI2_DESCR, QI2_CODPRO, QI2_LOTE "
		   	   cQry1 += " FROM "+RetSqlName("QI2")+" WITH(NOLOCK) "
			      cQry1 += " WHERE D_E_L_E_T_ ='' AND QI2_FILIAL ='"+xFilial("QI2")+"'"
			      cQry1 += " AND QI2_CODPRO <>'' AND QI2_STATUS ='2' "               
               cQry1 += " AND SUBSTRING(QI2_CODPRO,6,5) = '"+Substr(_cProduto,6,5)+"' "
               TCQuery cQry1 ALIAS "QI2WF" NEW
               DbSelectArea("QI2WF")
               If !Eof()
			   	
			   	cTexto := "Emissão de Ordem de produção (COR + VARIAÇÃO) com Ficha de Não conformidade em aberto."
				   cTexto+= CHR(13)+CHR(10)+"Cor + Variação :  "+Substr(QI2WF->QI2_CODPRO,6,5)+ " Lote FNC ->  "+QI2WF->QI2_LOTE+" - "+QI2WF->QI2_CODPRO
				   cTexto+= CHR(13)+CHR(10)+"Número FNC -> "+QI2WF->QI2_FNC
				   cTexto+= CHR(13)+CHR(10)+"Novo Lote  -> "+_cLote+" gerado por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
			   	cTexto+= CHR(13)+CHR(10)+"Prog. Origem : BRPCPX04"
				   If Substr(xFilial("SC2"),1,2)== "06"
					   U_EnvMail("DISSOLTEX - Emissão de O.p (Cor + Variação) com FNC aberta. Cor/Variação -> "+Substr(QI2WF->QI2_CODPRO,6,5) ,cTexto,cParaB,"") 
               Else
					   U_EnvMail("BRASILUX  - Emissão de O.p (Cor + Variação) com FNC aberta. Cor/Variação -> "+Substr(QI2WF->QI2_CODPRO,6,5) ,cTexto,cParaA,"pcp@brasilux.com.br")                       	  
				   Endif
				   cObs += 'F'
	            Endif
               DbSelectArea("QI2WF")
               DbCloseArea()

               For _nY := 1 to Len(aCols)
                   If aCols[_nY][Len(aHeader)+1] == .f.   
                   	 cAuxProd := iif(len(alltrim(_cProduto)) == 12,substr(_cProduto,1,10),substr(_cProduto,1,5))+aCols[_nY][1]
                      DbSelectArea("SZZ")
                      RecLock("SZZ", .t.)
                      SZZ->ZZ_FILIAL  := xFilial("SZZ")
                      SZZ->ZZ_LOTE    := _cLote
                      SZZ->ZZ_DTEMIS  := dEmissao
                      SZZ->ZZ_PRODUTO := cAuxProd
                      SZZ->ZZ_DESCR   := cDescric
                      SZZ->ZZ_PREVI   := dPrevIni
                      SZZ->ZZ_PREVF   := dPrevFim
                      SZZ->ZZ_EMB     := aCols[_nY][1]
                      SZZ->ZZ_DESEMB  := aCols[_nY][2]
                      SZZ->ZZ_QTDETI  := aCols[_nY][3]
                      SZZ->ZZ_PEDIDO  := aCols[_nY][4]
                      SZZ->ZZ_TPINCL  := "I"
                      MsUnlock()
                      _cGravou := .T.
				
                      DbSelectArea("SZ5")
                      DbSetOrder(1)
                      DbSeek(xfilial("SZ5")+acols[_nY][1],.F.)
                      If Found()
                         DbSelectArea("SG1")
                         DbSetorder(1)
                         DbSeek(xFilial("SG1")+SubStr(Alltrim(SubStr(Alltrim(_cProduto), 1, 10))+aCols[_nY][1]+Space(15), 1, 15)+_cProduto, .t.)
                         If !found()
                            //_QtdPI := _QtdPI + Round((aCols[_nY][3] * SZ5->Z5_VOLUME), 2) // ALTERANDO O CALCULO DE VOLUME DO SZ5 PARA O B1_CONV
                            _QtdPI := _QtdPI + Round((aCols[_nY][3] * nConv), 2)
                         Else 
	                         do while !eof() .and. (SG1->G1_FILIAL = xFilial("SG1")) .and. (SG1->G1_COD = SubStr(Alltrim(SubStr(Alltrim(_cProduto), 1, 10))+aCols[_nY][1]+Space(15), 1, 15)) .and. (SG1->G1_COMP = _cProduto)
    	                        _QtdPI := _QtdPI + ( (aCols[_nY][3] * SG1->G1_QUANT) / ((100 - SG1->G1_PERDA) / 100) )
        	                    dbskip()
            	             Enddo 
            	         Endif 

                      Endif
                      DbSelectArea("SC2")
                   Endif
               Next
               If ((_QtdPI * 100) - int(_QtdPI * 100)) > 0
                  nAux = int(_QtdPI*100+1)/100
                  _QtdPI = nAux
               Endif
               DbSelectArea("SC2")
               _nQuant     := Round(_QtdPI, 2)
               _dDataPrIni := dPrevIni
               _dDataPrFim := dPrevFim

			      cAuxProd := iif(len(alltrim(_cProduto)) > 7,substr(_cProduto,1,12),substr(_cProduto,1,5))

               cQry1 := ""
               cQry1 += " SELECT DATEDIFF(M,MAX(C2_EMISSAO),GETDATE()) AS 'MESES'  "
               cQry1 += " FROM "+RetSqlName("SC2")+" WITH(NOLOCK) "
               cQry1 += " WHERE C2_FILIAL ='"+xFilial("SC2")+"' AND D_E_L_E_T_ ='' AND C2_LOTE <>'' "
               cQry1 += " AND C2_PRODUTO = '"+cAuxProd+"'"

               TCQuery cQry1 ALIAS "SC2WF" NEW
               DbSelectArea("SC2WF")
//               If !Eof() .and. SC2WF->MESES > 5 /* ajustar*/
               If !Eof() .and. SC2WF->MESES > Val(pMes)
			   	   //If SC2WF->MESES > 5
				   	   cTexto := "Emissão de Ordem de produção com última produção a mais de "+pMes+" meses."
					      cTexto+= CHR(13)+CHR(10)+"Produto -> "+cAuxProd
					      cTexto+= CHR(13)+CHR(10)+"Lote  -> "+_cLote+" gerado por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
					      cTexto+= CHR(13)+CHR(10)+"Qtde  -> "+TRANSFORM(_nQuant,'@E 999,999,999.99')
			   		   cTexto+= CHR(13)+CHR(10)+"Produzido a  "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses atrás."
				   	   cTexto+= CHR(13)+CHR(10)+"Prog. Origem : BRPCPX04"
					   If Substr(xFilial("SC2"),1,2)== "06"
						    U_EnvMail("DISSOLTEX - Emissão de Ordem de produção com última produção a "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses. " ,cTexto,cParaB,"") 
                  Else
						    U_EnvMail("BRASILUX  - Emissão de Ordem de produção com última produção a "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses. " ,cTexto,cParaA,"materiais@brasilux.com.br")
					   Endif
				    cObs += 'T' // T - TEMPO MAIOR DO QUE 6 MESES SEM PRODUZIR 
					Endif 
			   Endif	
            If Select( "SC2WF" ) > 0
                DbSelectArea( "SC2WF" )
                DbCloseArea()
            Else 
                DbCloseArea()
            Endif
//          DbSelectArea("SC2WF")
//			   DbCloseArea()

			   DbSelectArea("SC2")
			   DbSetOrder(2) // Filial + Produto + Entrega
    		   DbSeek(xFilial("SC2")+(cAuxProd), .t.)
    		   If !Found() 
			   	cTexto := "Emissão de Ordem de produção de produto novo."
				   cTexto+= CHR(13)+CHR(10)+"Produto -> "+cAuxProd
				   cTexto+= CHR(13)+CHR(10)+"Lote  -> "+_cLote+" gerado por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
				   cTexto+= CHR(13)+CHR(10)+"Qtde  -> "+TRANSFORM(_nQuant,'@E 999,999,999.99')
	   		   cTexto+= CHR(13)+CHR(10)+"Prog. Origem : BRPCPX04"
				   If Substr(xFilial("SC2"),1,2)== "06"
					    U_EnvMail("DISSOLTEX - Emissão de Ordem de produção de produto novo. (Primeira Produção) " ,cTexto,cParaB,"") 
       	    	   Else
					    U_EnvMail("BRASILUX  - Emissão de Ordem de produção de produto novo. (Primeira Produção) " ,cTexto,cParaA,"materiais@brasilux.com.br")
				   Endif
				   cObs += 'P'  // P - PRIMEIRA PRODUÇÃO DO PRODUTO

            If Select( "SC2WF" ) > 0
                DbSelectArea( "SC2WF" )
                DbCloseArea()
            Else 
                DbCloseArea()
            Endif
//          DbSelectArea("SC2WF")
//			   DbCloseArea()

  	         Endif
//-------------   Acrescentado o 1º Lote  Jose 20/07/2023 ----------------------------------

			   DbSelectArea("SC2")
			   DbSetOrder(2) // Filial + Produto + Entrega
    		   DbSeek(xFilial("SC2")+(cAuxProd), .t.)
    		   If !Found() 
			   	cTexto := "Emissão de Ordem de produção de produto Com Primeiro Lote."
				   cTexto+= CHR(13)+CHR(10)+"Produto -> "+cAuxProd
				   cTexto+= CHR(13)+CHR(10)+"Lote  -> "+_cLote+" gerado por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
				   cTexto+= CHR(13)+CHR(10)+"Qtde  -> "+TRANSFORM(_nQuant,'@E 999,999,999.99')
	   		   cTexto+= CHR(13)+CHR(10)+"Prog. Origem : BRPCPX04"
				   If Substr(xFilial("SC2"),1,2)== "06"
					   U_EnvMail("DISSOLTEX - Emissão de Ordem de produção de produto Com 1º Lote. (Primeiro Lote de Produção) " ,cTexto,cParaB,"") 
       	    	 Else
					   U_EnvMail("BRASILUX  - Emissão de Ordem de produção de produto novo. (Primeiro Lote de Produção) " ,cTexto,cParaA,"materiais@brasilux.com.br")
				   Endif
				   cObs += 'L' // L - PRIMEIRO PRODUÇÃO DO PRODUTO COM PRIMEIRO LOTE
	  		      DbSelectArea("SC2")
            Endif
//-------------  Até Aqui  Jose 20/07/2023  ----------------------------------------------------


            If _nQuant > 0 // Jose 14/05/2025
               DbSelectArea("SZZ")
               RecLock("SZZ", .t.)
               SZZ->ZZ_FILIAL  := xFilial("SZZ")
               SZZ->ZZ_LOTE    := _cLote
               SZZ->ZZ_DTEMIS  := dEmissao
               SZZ->ZZ_PRODUTO := cAuxProd //SubStr(Alltrim(SubStr(Alltrim(_cProduto), 1, 10)+"00")+Space(15), 1, 15)
               SZZ->ZZ_DESCR   := cDescric
               SZZ->ZZ_PREVI   := dPrevIni
               SZZ->ZZ_PREVF   := dPrevFim
               SZZ->ZZ_QTDETI  := _nQuant
               SZZ->ZZ_TPINCL  := "I" 
               SZZ->ZZ_INFOP   := Alltrim(cObs)   // F - FNC / L - Primeiro Lote / P - PRIMEIRA PRODUÇÃO / T - MAIS DE 6 MESES SEM PRODUÇÃO //   Acrestado L - Primeiro Lote  Jose 20/07/2023
               MsUnlock()
            EndIf // Jose  14/05/2025
     Endif
     
     U_VoltaArea(aAreaAnt)
Return

/*****************************************************************************************************************/
/*** FVALCAB - Rotina de validação do cabeçalho                                                               ***/
/*****************************************************************************************************************/
Static Function fValCab(dEmissao, oEmissao, dPrevIni, oPrevIni, dPrevFim, oPrevFim, _cProduto, _oProduto, cDescric, oDescric, oPrevVol, cPrevVol, nOpc)
     Local lRet:=.T. as logical  // maa
       //Local ltemGGF :=.f.
	   If nOpc == 1
          dPrevFim := dEmissao
          dPrevIni := dEmissao
       ElseIf nOpc == 2
              If Len(Alltrim(_cProduto)) == 11   
                 If !Empty(SubStr(_cProduto, 3, 1))
                    _cProduto := Stuff(_cProduto, 3, 0, ' ')
                 Endif
              Endif
              DbSelectArea("SB1")
              DbSetOrder(1)
              DbSeek(xFilial("SB1")+_cProduto, .t.)
              If !Found()
                  MsgBox("Produto não existe !", "Atenção", "STOP")
                  _cProduto := space(15)
                  cDescric := space(40)
                  _oProduto:SetFocus(.t.)
                  Return(.f.)
			  Else               
                  DbSelectArea("QI2")
	              DbSetOrder(7) //Produto + Ano FNC + Codigo FNC + Revisao FNC                          
              	  DbSeek(xFilial("QI2")+_cProduto, .t.)
                  If Found() 
                  	While !Eof() .AND. (QI2->QI2_FILIAL == XFILIAL("QI2")) .AND. (Alltrim(_cProduto) == Alltrim(QI2->QI2_CODPRO))
                  		If  QI2->QI2_STATUS ='2' 
                  			MsgBox("Produto possui fnc aberta. Não será possível incluir o.p eqto não encerrá-la ("+QI2->QI2_FNC+") !", "Informação...", "INFO")               	
                  			DbSelectArea("QI2")
                  			DbCloseArea()
                  			_cProduto := space(15)
                  			cDescric := space(40)
                  			_oProduto:SetFocus(.t.)
                  			Return(.f.)
                  		Endif
                  		DbSelectArea("QI2")
                  		DbSkip()
                  	Enddo
			      Endif
                  DbSelectArea("QI2")
                  DbCloseArea()
              	   If SB1->B1_TIPO <> 'PI' 
	                  MsgBox("Produto digitado não é do tipo PI !", "Atenção", "STOP")
        	            cDescric := space(40)
            	      _oProduto:SetFocus(.t.)
	                  Return(.f.)
    			      Endif	          	 	
                  If SB1->B1_MSBLQL == '1'
	                  MsgBox("Produto digitado esta bloqueado, Verifique", "Atenção", "STOP")
        	            cDescric := space(40)
            	      _oProduto:SetFocus(.t.)
	                  Return(.f.)
    			      Endif	          	 	
                  //If FWCodEmp() = '01'  // habilitado na brasilux por eqto até habilitar ggf na dissoltex
                     If u_VerMetrica(_cProduto)
                        MsgBox("Produto não possui GGF ou esta em desacordo com as métricas !", "Informação...", "INFO")               	
                  	   _cProduto := space(15)
                  	   cDescric := space(40)
                  	   _oProduto:SetFocus(.t.)
                  	   Return(.f.)
                     Endif
                  //Endif
                  DbSelectArea("QP6")
                  DbSetOrder(1)
                  DbSeek(xFilial("QP6")+_cProduto, .t.)
                  If !Found()
                 	 MsgBox("Produto sem cadastro de Inspeção - Avisar Departamento Técnico !", "Informação", "INFO")
                  Endif
                  DbSelectArea("QP6")
                  DbCloseArea()	

//------------    Jose acrestou 05/06/2024 -----------------------------------
                  If !(SubStr(Alltrim(_cProduto),1,2) $ 'CT.ED.TD.TN.AG.VN')
                      DbSelectArea("SZ3")
                      DbSetOrder(1)
                      DbSeek(xFilial("SZ3")+(SubStr(_cProduto,6,2))+(SubStr(_cProduto,8,3)), .t.)

                      If Found() 
                  	   	If  Alltrim(SZ3->Z3_PADCOR) = '' 
                  		       MsgBox("Produto sem Cor Padrão Cadastrada - Avisar Departamento Técnico !", "Informação...", "INFO")               	
                  		   Endif
                      Else
                	      MsgBox("Produto sem Cor Padrão Cadastrada - Avisar Departamento Técnico !", "Informação...", "INFO") 
			             Endif
                      DbSelectArea("SZ3")
                      DbCloseArea()	
                  EndIf
//------------  Jose Até Aqui 05/06/2024 -----------------------------------------

                     If Len(Alltrim(_cProduto)) == 12 .or. Len(Alltrim(_cProduto) == 5)
                        If (Substr(Alltrim(_cProduto),11, 2) $ '00.99') 
                           cDescric := SB1->B1_DESC
                           /*** VERIFICA OPS EM ABERTO PARA OS PRODUTOS ***/
                           cQry1 := ""
                           cQry1 += "SELECT COUNT(SC2.C2_NUM) AS NUMOP, SUM(SC2.C2_QUANT - SC2.C2_QUJE) AS QTDOP "
                           cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
                           cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                           cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                           cQry1 += "  AND SC2.C2_DATRF   = '' "
                           cQry1 += "  AND SC2.C2_PRODUTO = '"+_cProduto+"' "
                           TCQuery cQry1 ALIAS "TOPS" NEW
                           DbSelectArea("TOPS")
                           If TOPS->NUMOP > 0
                              cVarDes := "" ; cVarOps := ""
                              cVarDes := Iif(TOPS->NUMOP == 1, "Existe ", "Existem ")
                              cVarOps := Iif(TOPS->NUMOP == 1, " OP aberta ", " OPs abertas ")
                              MsgBox(cVarDes+Transform(TOPS->NUMOP, "@E 99")+cVarOps+"para esse produto, com "+Transform(TOPS->QTDOP, "@E 999,999.99")+" "+SB1->B1_UM+".", "Informação", "INFO")
                           Endif
                           DbSelectArea("TOPS")
                           DbCloseArea()
                       Else
                           MsgBox("Produto inválido !", "Atenção", "STOP")
                           _cProduto := space(15)
                           cDescric := space(40)
                           _oProduto:SetFocus(.t.)
                           Return(.f.)
                        Endif
                     Else
                        MsgBox("Produto inválido !", "Atenção", "STOP")
                        _cProduto := space(15)
                        cDescric := space(40)
                        _oProduto:SetFocus(.t.)
                        Return(.f.)
                     Endif
              Endif
       
        //-- Analisa saldo zerado de componentes --MAA
   If lRet
      BEGINSQL ALIAS "SALDOS"
         SELECT
            SB1.B1_COD,
            SG1.G1_COMP,
            SUM(SG1.G1_QUANT) AS G1_QUANT,
            SUM(SB2.B2_QATU) AS B2_QATU
         FROM
            %TABLE:SB1% SB1,
            (
               SELECT
                  SUM(B2_QATU) AS B2_QATU,
                  B2_FILIAL,
                  B2_COD
               FROM
                  %TABLE:SB2% SB2
               WHERE
                  %NOTDEL%
                  AND B2_FILIAL = %XFILIAL:SB2%
               GROUP BY
                  B2_FILIAL,
                  B2_COD
            ) SB2,
            %TABLE:SG1% SG1
         WHERE
            SB1.%NOTDEL%
            AND SB1.B1_FILIAL = %XFILIAL:SB1%
            AND SB1.B1_COD = %EXP:_cProduto%
            AND SB1.B1_FILIAL = SB2.B2_FILIAL
            AND SB1.B1_COD = SG1.G1_COD
            AND SB1.B1_UREV >= SG1.G1_REVINI
            AND SB1.B1_UREV <= SG1.G1_REVFIM
            AND SG1.G1_FILIAL = SB2.B2_FILIAL
            AND SG1.%NOTDEL%
            AND SUBSTRING(SG1.G1_COMP, 1, 2) <> 'GG'
            AND SG1.G1_COMP = SB2.B2_COD
         GROUP BY
            SB1.B1_COD,
            SG1.G1_COMP
         HAVING
            SUM(SG1.G1_QUANT) > SUM(SB2.B2_QATU)
      ENDSQL

      If .NOT. SALDOS->(EOF()) .AND. .NOT. SALDOS->(BOF())
         cComp := ""
         While .NOT. SALDOS->(EOF())
            cComp := SALDOS->G1_COMP+CRLF
            SALDOS->(DbSkip())
         Enddo
         FWAlertError("Produto(s) com saldo zerado de componentes!"+CRLF+cComp,"Saldo Zerado")
         lRet := .F.
         SALDOS->(DbCloseArea())
         _cProduto := space(15)
         cDescric := space(40)
         _oProduto:SetFocus(.t.)
         Return(NIL)
      Endif
      If Select("SALDOS") > 0
         SALDOS->(DbCloseArea())
      End
   Endif
   // FIm Analise Saldos - MAA    
       
       Endif
       oEmissao:Refresh() ; oPrevIni:Refresh() ; oPrevFim:Refresh() ; _oProduto:Refresh() ; oDescric:Refresh() ; oPrevVol:Refresh()
Return(.t.)

/*****************************************************************************************************************/
/*** fMonHea - Monta cabeçalho do acols                                                                        ***/
/*****************************************************************************************************************/
Static Function fMonHea(aHeader, nUsado)
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*
       DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZZ")
       While !Eof() .And. (SX3->X3_ARQUIVO == "SZZ")
             If  (Alltrim(SX3->X3_CAMPO) $ "ZZ_EMB,ZZ_DESEMB,ZZ_QTDETI,ZZ_PEDIDO") .and. ;
                  X3Uso(SX3->X3_USADO) .and. (cNivel >= SX3->X3_NIVEL) 
                  nUsado += 1
            	   Aadd(aHeader,{Trim(( _cAliasSX3 )->( X3_TITULO )),;
                  SX3->X3_CAMPO,;
                  SX3->X3_PICTURE,;
                  SX3->X3_TAMANHO,;
                  SX3->X3_DECIMAL,;
                  "",;
                  "",;
                  SX3->X3_TIPO,;
                  "",;
                  "" })
             Endif
             DbSkip()
       EndDo */
       DbSelectArea( _cAliasSX3 )
       DbSetOrder(1)
       DbSeek("SZZ")
       While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZZ" )
             If  ( Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZ_EMB,ZZ_DESEMB,ZZ_QTDETI,ZZ_PEDIDO") .and. X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. (cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) ) 
                nUsado += 1
        		aAdd( aHeader, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
             Endif
             DbSkip()
       EndDo
Return

/*****************************************************************************************************************/
/*** fMonCol - Monta aCols                                                                                     ***/
/*****************************************************************************************************************/
Static Function fMonCol(aHeader, nUsado, aCols, cOpc, _cLote)
       Local _nI
       //Local _nY
       If cOpc $ "V"
          DbSelectArea("SZZ")
          DbSetOrder(1)
          DbSeek(xFilial("SZZ")+_cLote, .t.)
          If Found()
             While !Eof() .and. SZZ->ZZ_LOTE == _cLote
                   If !Substr(ALLTRIM(SZZ->ZZ_PRODUTO),11,2) $ "00.99"
						Aadd(aCols,Array(nUsado+1))
						For _nI := 1 To nUsado
    						aCols[1][_nI] := CriaVar(aHeader[_nI][2])
						Next
						aCols[1][nUsado+1] := .F.
                   Endif
                   DbSelectArea("SZZ")
                   DbSkip()
             Enddo
           Else
				Aadd(aCols,Array(nUsado+1))
				For _nI := 1 To nUsado
    				aCols[1][_nI] := CriaVar(aHeader[_nI][2])
				Next
				aCols[1][nUsado+1] := .F.
           Endif
       Else
			Aadd(aCols,Array(nUsado+1))
			For _nI := 1 To nUsado
    			aCols[1][_nI] := CriaVar(aHeader[_nI][2])
			Next
			aCols[1][nUsado+1] := .F.
       Endif
Return

/*****************************************************************************************************************/
/*** fPrevVol - Soma o volume das embalagens digitadas no aCols                                                ***/
/*****************************************************************************************************************/
User Function fPrevVol()     
       	Local _nY
       	cPrevVol :=0
       	For _nY := 1 to Len(aCols)
	        If aCols[_nY][Len(aHeader)+1] == .f.    
       			cProdVol :=0
       			cProdEmba:= iif(len(alltrim(_cProduto)) == 12,SubStr(Alltrim(_cProduto), 1, 10),substr(alltrim(_cProduto),1,5))+aCols[_nY][1]
                cProdVol  = Posicione("SB1", 1, xFilial("SB1")+cProdEmba, "B1_CONV")
	            DbSelectArea("SB1")
     		    DbSetorder(1)
           		DbSeek(xFilial("SB1")+cProdEmba,.t.)
        	    If Found()
       				cPrevVol += Iif(Substr(Alltrim(_cProduto),11,2) $ '99', (aCols[_nY][3] * (cProdVol / Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_PESOESP"))), (aCols[_nY][3] * cProdVol))
           		Else
                  	MsgBox("Produto não localizado!", "Atenção", "STOP")
           			Return(.f.)
           		Endif
           	Endif
        Next		
     	oPrevVol:Refresh() 
Return

/*****************************************************************************************************************/
/*** fCamOPB - Valida Campos do aCols das ordens de produções.                                                 ***/
/*****************************************************************************************************************/
User Function fCamOPB()
     Local nPosEmb := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_EMB"    } )
     Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_DESEMB" } )
     Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_QTDETI" } )
     Local nPosPed := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_PEDIDO" } )
     Local lRet    := .t. , cProdEmba, i
     //Local ltemGGF := .f.
	 
	 //Local cProdVol
     //_cProduto :=0
     If __ReadVar $ 'M->ZZ_EMB'
		cProdEmba := iif(len(alltrim(_cProduto)) = 12,SubStr(Alltrim(_cProduto), 1, 10),substr(alltrim(_cProduto),1,5))+M->ZZ_EMB
        If aCols[n][Len(aHeader)+1] == .f.
           DbSelectArea("SB1")
           DbSetorder(1)
           DbSeek(xFilial("SB1")+cProdEmba,.t.)
//           Alltrim(SubStr(Alltrim(_cProduto), 1, 10)+M->ZZ_EMB),.t.)
           If !Found()
              MsgStop("Embalagem não cadastrada: "+cProdEmba)
              M->ZZ_EMB := space(02) ; aCols[n][nPosEmb] := space(02) ; aCols[n][nPosDes] := space(20) ; aCols[n][nPosQtd] := 0 ; aCols[n][nPosPed] := space(08)
              Return(.f.)
           Else
              // RETIRADO VERIFICAÇÃO DE PRODUTO BLOQUEADO PARA VENDA PARA FORMULAR PRODUTOS PI QUE SERÃO VENDIDOS PARA DISSOLTEX (NÃO APARECER NO BRASREPRES) 15/01/14
              If SB1->B1_MSBLQL == '1'
                 MsgBox("Produto bloqueado !", "Atenção", "STOP")
                 Return(.f.)
              Else
                 DbSelectArea("SZ5")
                 DbSetOrder(1)
                 DbSeek(xfilial("SZ5")+M->ZZ_EMB,.t.)
                 If Found()
                    aCols[n][nPosEmb] := M->ZZ_EMB
                    acols[n][nPosDes] := SZ5->Z5_DESCR

                    /*** VERIFICA OPS EM ABERTO PARA OS PRODUTOS ***/
                    cQry1 := ""
                    cQry1 += "SELECT COUNT(SC2.C2_NUM) AS NUMOP, SUM(SC2.C2_QUANT - SC2.C2_QUJE) AS QTDOP "
                    cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
                    cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                    cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                    cQry1 += "  AND SC2.C2_DATRF   = '' "
                    cQry1 += "  AND SC2.C2_PRODUTO = '"+cProdEmba+"' "
                    TCQuery cQry1 ALIAS "TOPS" NEW
                    DbSelectArea("TOPS")
                    If TOPS->NUMOP > 0
                       cVarDes := "" ; cVarOps := ""
                       cVarDes := Iif(TOPS->NUMOP == 1, "Existe ", "Existem ")
                       cVarOps := Iif(TOPS->NUMOP == 1, " OP aberta ", " OPs abertas ")
                       MsgBox(cVarDes+Transform(TOPS->NUMOP, "@E 99")+cVarOps+"para esse produto, com "+Transform(TOPS->QTDOP, "@E 999,999.99")+" "+SB1->B1_UM+".", "Informação", "INFO")
                    Endif
                    DbSelectArea("TOPS")
                    DbCloseArea()
                 Else
                    MsgStop("Embalagem inexistente: "+M->ZZ_EMB)    
                    Return(.f.)
                 Endif
                 //If FWCodEmp() = '01'  // habilitado na brasilux por eqto até habilitar ggf na dissoltex
                     If u_VerMetrica(_cProduto)
                        MsgBox("Produto não possui GGF ou esta em desacordo com as métricas !", "Informação...", "INFO")               	
                  	   _cProduto := space(15)
                  	   cDescric := space(40)
                  	   _oProduto:SetFocus(.t.)
                  	   Return(.f.)
                     Endif
                  //Endif
                  //If FWCodEmp() = '01'  // habilitado na brasilux por eqto até habilitar ggf na dissoltex
                     If u_VerMetrica(cProdEmba)
                        MsgBox("Produto não possui GGF ou esta em desacordo com as métricas !", "Informação...", "INFO")               	
                  	   Return(.f.)
                     Endif
                  //Endif                 
              Endif
           Endif
           For i := 1 to Len(aCols)
               If i # n
                  If aCols[i][Len(aHeader)+1] == .f.
                     If aCols[i][1] == aCols[n][1]
                        MsgBox("Há duplicidade de Embalagens!", "Atenção", "STOP")
                        lRet := .f.
                        Exit
                     Endif   
                  Endif
               Endif
           Next	
           If !lRet
              M->ZZ_EMB := space(02) ; aCols[n][nPosEmb] := space(02) ; aCols[n][nPosDes] := space(20) ; aCols[n][nPosQtd] := 0 ; aCols[n][nPosPed] := space(08)
              Return(.f.)
           Endif
        Endif
/*     Elseif __ReadVar $ 'M->ZZ_QTDETI'
       	cPrevVol :=0
       	For nY := 1 to Len(aCols)
	        If aCols[nY][Len(aHeader)+1] == .f.    
       			cProdVol :=0
       			cProdEmba:= iif(len(alltrim(_cProduto)) = 12,SubStr(Alltrim(_cProduto), 1, 10),substr(alltrim(_cProduto),1,5))+aCols[nY][nPosEmb]
                cProdVol  = Posicione("SB1", 1, xFilial("SB1")+cProdEmba, "B1_CONV")
	            DbSelectArea("SB1")
     		    DbSetorder(1)
           		DbSeek(xFilial("SB1")+cProdEmba,.t.)
        	    If Found()
           			If Len(aCols) >1
           				cPrevVol += (aCols[nY][3] * cProdVol)
           		    Else
						cPrevVol += (M->ZZ_QTDETI * cProdVol)
					Endif
           		Else
                  	MsgBox("Produto não localizado!", "Atenção", "STOP")
           			Return(.f.)
           		Endif
           	Endif
        Next		
     	oPrevVol:Refresh()   */
     ElseIf __ReadVar $ 'M->ZZ_PEDIDO'
            If aCols[n][Len(aHeader)+1] == .f.
               cArea      = alias()
			   cProdEmba := iif(len(alltrim(_cProduto)) = 12,SubStr(Alltrim(_cProduto), 1, 10),substr(alltrim(_cProduto),1,5))+aCols[n][nPosEmb]
               DbSelectArea("SC5")
               DbSetOrder(1)
               DbSeek(XFILIAL("SC5")+SUBSTR(M->ZZ_PEDIDO,3,6), .t.)
               If Found()
                  DbSelectArea("SC6")
                  DbSetOrder(2)
                  DbSeek(xFilial("SC6")+cProdEmba+space(15-len(cProdEmba))+SubStr(M->ZZ_PEDIDO, 3, 6), .t.)
                  If !Found()
                     MsgBox("Atenção, não existe esse produto nesse pedido.", "Atenção", "STOP")
                     DbSelectArea(cArea)
                     Return(.f.)
                  Endif
               Else
                  DbSelectArea(cArea)
                  Return(.f.)
               Endif
               DbSelectArea(cArea)
            Endif      
     EndIf
     DbSelectArea("SZZ")
     oGetD:oBrowse:Refresh()
Return(.t.)

/*****************************************************************************************************************/
/*** fLinOPB - Valida linhas do aCols das ordens de produções.                                                 ***/
/*****************************************************************************************************************/
User Function fLinOPB()
     Local nPosEmb := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_EMB"    } )
     //Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_DESEMB" } )
     Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_QTDETI" } )
     //Local nPosPed := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_PEDIDO" } )
     If aCols[n][Len(aHeader)+1] == .f.
        If Empty(aCols[n][nPosEmb]) 
           MsgBox("Informe o código da embalagem !", "Atenção", "STOP")
           Return(.f.)
        Else
           If aCols[n][nPosQtd] <= 0
              MsgBox("Informe a quantidade maior que zero!", "Atenção", "STOP")
              Return(.f.)
           Endif
        Endif
     Endif
     oGetD:oBrowse:Refresh()
     U_fPrevVol() // somar volume dos itens digitados
Return(.t.)

/*****************************************************************************************************************/
/*** fTudOPB - Valida linhas do aCols na confirmação da inclusão dos lotes.                                    ***/
/*****************************************************************************************************************/
User Function fTudOPB()
     Local nPosEmb := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_EMB"    } )
     //Local nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_DESEMB" } )
     Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_QTDETI" } )
     //Local nPosPed := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_PEDIDO" } )
     Local lRet    := .t.
     Local _nY
     
     If Empty(_cProduto)
        MsgBox("Código do Produto não pode estar em branco!", "Atenção", "STOP")
        Return(.f.)
     Endif
     For _nY := 1 To Len(aCols)
         If aCols[_nY][Len(aHeader)+1] == .f.
            If Empty(aCols[n][nPosEmb]) .or. aCols[n][nPosQtd] <= 0
               lRet := .f.
            Endif
         Endif
     Next
     If !lRet
        MsgBox("Exite embalagem igual a branco ou quantidade igual a zero. Verifique !", "Atenção", "STOP")
        Return(.f.)
     Endif
Return(.t.)

/*****************************************************************************************************************/
/*** fGerOPS - Gera as ordens de produções pelos lotes.                                                        ***/
/*****************************************************************************************************************/
Static Function fGerOPS(aGerTxt)
       Local _cMVXSOLUC := GetMv('MV_XSOLUCA') // Solucoes que ao atingir quantidades superiores a 300 kg na estrutura das formulas, deverao gerar ops automaticamente com a quantidade exata da formula Utilizado Programa BRPCPX04 - Gerar O.P x Lote 
       Local _cMVXSOLU0 := GetMv('MV_XSOLUC0') // Solucoes que ao atingir qualquer quantidade na estrutura das formulas, deverao gerar ops automaticamente com a quantidade exata da formula Utilizado Programa BRPCPX04 - Gerar O.P x Lote     
       Local _cMVXSOLU5 := GetMv('MV_XSOLUC5') // Solucoes que ao atingir quantidades superiores a 500 kg na estrutura das formulas, deverao gerar ops automaticamente com a quantidade exata da formula Utilizado Programa BRPCPX04 - Gerar O.P x Lote

       Local aerro    := ""  // Jose 13/05/2025

       Private lMSErroAuto := .f.
       Private lMSHelpAuto := .t.

       nContReg := RecCount()
       If Select( xLotes ) > 0 
           DbCloseArea()
       EndIf

       If nContReg > 0
          MsgBox("Serão geradas as Ordens de Produções junto com as Intermediarias!", "Atenção", "INFO")
          ProcRegua(nContReg, 21, 6)
       Endif
       nContOcorr := 0

If Select( xLotes ) > 0 // Jose 26/06/2024

       DbSelectArea(xLotes)
       DbGoTop()

       While !eof()
             cAuxLote = LOTE
             cAuxFilial = xFilial("SZZ")
             DbSelectArea("SZZ")
             DbSeek(cAuxFilial+cAuxLote, .t.)
             While !eof() .and. (cAuxFilial == xFilial("SZZ")) .and. (cAuxLote == SZZ->ZZ_LOTE)
                 //lVerCon := .f.
                   lVerSol := .f.
                   If SZZ->ZZ_FLAG == 'S'
                      Dbselectarea("SZZ")
                      DbSkip()
                      Loop
                   Endif
                   DbSelectArea("SB1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SB1")+SZZ->ZZ_PRODUTO)
                   If Found()
                      If SB1->B1_TIPO $ "PI"
                         cAutExpl = "S"
                       //lVerCon := .t.
                         lVerSol := .t.
                      Else
                         cAutExpl = "N"
                      Endif
                      cRoteiro := Posicione("SB1", 1, xFilial("SB1")+SZZ->ZZ_PRODUTO, "B1_OPERPAD")
                      nQuant2  := IIF(SB1->B1_TIPCONV != "D", (SZZ->ZZ_QTDETI * SB1->B1_CONV), (SZZ->ZZ_QTDETI / SB1->B1_CONV) )
                      If (SZZ->ZZ_PREVI + SB1->B1_PE) > SZZ->ZZ_PREVF
                         dAuxData := SZZ->ZZ_PREVI + SB1->B1_PE
                      Else
                         dAuxData := SZZ->ZZ_PREVF
                      Endif
                      If SZZ->ZZ_TPINCL $ 'C'
                         dAuxData := dDataBase
                      Endif
                      if dAuxData < dDataBase
                      	dAuxData := dDataBase
                      endif 
                      aAutoSC2 := {}
                      aadd(aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 , NIL})
                      aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
                      aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                      aadd(aAutoSC2, {"C2_PRODUTO", SZZ->ZZ_PRODUTO                , NIL})
                      aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                      aadd(aAutoSC2, {"C2_LOCAL"  , SB1->B1_LOCPAD                 , NIL})
                      aadd(aAutoSC2, {"C2_QUANT"  , SZZ->ZZ_QTDETI                 , NIL})
                      aadd(aAutoSC2, {"C2_QTSEGUM", nQuant2                        , NIL})
                      aadd(aAutoSC2, {"C2_UM"     , SB1->B1_UM                     , NIL})
                      aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                      aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                      aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                      aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                      aadd(aAutoSC2, {"C2_LOTE"   , SZZ->ZZ_LOTE                   , NIL})
                      aadd(aAutoSC2, {"C2_PEDIDO" , SubStr(SZZ->ZZ_PEDIDO, 3, 6)   , NIL})
                      aadd(aAutoSC2, {"C2_ITEMPV" , SubStr(SZZ->ZZ_PEDIDO, 1, 2)   , NIL})
                      aadd(aAutoSC2, {"C2_REVI"   , QA_UltRvQ(SZZ->ZZ_PRODUTO,,.F.), NIl})
                      If (cAutExpl == "S") .AND. (Len(Alltrim(SZZ->ZZ_PRODUTO)) == 12)
                         aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                    , NIL})
                      Endif

                      lMsErroAuto := .f.
                      Dbselectarea("SC2")
                      dbsetorder(1)
                      dbseek(xFilial("SC2")) //  jose 06/03/2025 aq1ui esta dando erro
                      MSExecAuto( {|x| MATA650(x)}, aAutoSC2)  
//                    U_MinhaFuncao()  //Jose 19/05/2025
//                    aerro := MostraErro()     // Ver  Jose 07/04/2025  JOse 13/05/2025
//                    If lMsErroAuto = .T. // Jose 07/04/2025   jose 13/05/2025
//                       If MostraErro() = "C650NOREV"  // Jose 07/04/2025   jose 13/05/2025
//                          MostraErro() // Jose 07/04/2025   jose 13/05/2025
//                       Else // Jose 07/04/2025   jose 13/05/2025
//                          aerro := "" // Jose 07/04/2025   jose 13/05/2025
//                       EndIf // Jose 07/04/2025   jose 13/05/2025
//                      Else  // Jose 07/04/2025   jose 13/05/2025
                      aerro := "" // Jose 07/04/2025   jose 13/05/2025
//                    EndIf  // Jose 07/04/2025   jose 13/05/2025
                      // incluido por nelieder em 23/10/23 .OR. ("C650NOREV" $ aerro)
                      //If !lMsErroAuto .OR. ("C650NOREV" $ aerro) jose 13/05/2025
                      If ("C650NOREV" <> aerro) // jose 13/05/2025 saindo em duplicidade o PA quando fazia complemento 
                         DbSelectArea("SZZ")
                         RecLock("SZZ", .f.)
                            SZZ->ZZ_FLAG := 'S'
                         MsUnLock()

                         If SZZ->ZZ_TPINCL == 'C'
                            aAutoSC2 := {}
                            aAutoSC2  := { { 'C2_FILIAL'   , SC2->C2_FILIAL                        , NIL },;
                                           { 'C2_PRODUTO'  , SC2->C2_PRODUTO                       , NIL },;          
                                           { 'C2_NUM'      , SC2->C2_NUM                           , NIL },;          
                                           { 'C2_ITEM'     , SC2->C2_ITEM                          , NIL },;
                                           { 'C2_SEQUEN'   , SC2->C2_SEQUEN                        , NIL },;
                                           { 'C2_OBS'      , "Complemento" + AllTrim( SC2->C2_OBS ), NIL } }
                            msExecAuto( { | x, Y | Mata650( x, Y ) }, aAutoSC2, 4 )
                            If lMsErroAuto
//                             MostraErro()    Jose 07/04/2025
                            EndIf

                            aerro := "" // Jose 21/05/2025
                            If ("C650NOREV" <> aerro) // jose 21/05/2025 saindo em duplicidade o PA quando fazia complemento 
                                DbSelectArea("SZZ") // Jose 21/05/2025
                                RecLock("SZZ", .f.) // Jose 21/05/2025
                                  SZZ->ZZ_FLAG := 'S' // Jose 21/05/2025
                                MsUnLock() // Jose 21/05/2025
                            EndIf // Jose 21/05/2025
                         Endif
                         If Substr(Alltrim(SZZ->ZZ_PRODUTO),11, 2) $ '00.99' //.Or. Posicione("SB1", 1, xFilial("SB1")+SZZ->ZZ_PRODUTO, "B1_TIPO") $ 'PI'
                            aAdd(aGerTxt, {SZZ->ZZ_PRODUTO, SZZ->ZZ_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, SC2->C2_QUANT })
                         Endif
      	                 
                         nContOcorr++
                         // VERIFICAR SE EXISTEM SOLUÇÕES COM QUANTIDADE MAIOR DO QUE 300 KG NA FORMULA. SE EXISTIR DEVE SER GERADO OP COM ESTE CONCENTRADO.
                         If lVerSol        // CHAMADO 000782 - MICHELLY EM 27/10/14
                            cQry1 := ""
                            cQry1 += " SELECT D4_OP,D4_COD,D4_QUANT, C2_QUANT "
                            cQry1 += " FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) " 
                            cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK)  ON SB1.B1_FILIAL = SD4.D4_FILIAL AND SB1.B1_COD = SD4.D4_COD AND SB1.D_E_L_E_T_ ='' "
                            cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK)  ON SD4.D4_FILIAL = SC2.C2_FILIAL AND SD4.D4_OP  = SC2.C2_OP  AND SC2.D_E_L_E_T_ ='' "
                            cQry1 += " WHERE SD4.D4_FILIAL  = '"+xFilial("SD4")+"' "
                            cQry1 += "  AND SD4.D_E_L_E_T_  = '' "
                            cQry1 += "  AND SD4.D4_OP       = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+"' "
                            //LGS#20200206 - Adequação de release 12.1.25 e posteriores
                            //cQry1 += "  AND SD4.D4_COD IN ("+GetMv('MV_XSOLUCA')+")"
                            cQry1 += "  AND SD4.D4_COD IN (" + _cMVXSOLUC + ',' + _cMVXSOLU0 + ',' +  _cMVXSOLU5 + ")" 
                            //cQry1 += "  AND SB1.B1_XSOLUCA  = 'S' "
                            TCQuery cQry1 ALIAS "QEMP" NEW 
                            DbSelectArea("QEMP")
                            nQtdCon := QEMP->D4_QUANT
                            nQtdTota:= QEMP->C2_QUANT
                            cCodCon := QEMP->D4_COD
                            DbSelectArea("QEMP")
                            DbCloseArea()
                            If Alltrim(cCodCon) $ Alltrim(_cMVXSOLUC) .and. nQtdTota > 200 .and. !Empty(cCodCon)  // alterado de 300 para 200 conforme chamado 007431
                          //If nQtdCon >= 300.00 .and. !Empty(cCodCon)
   	                           nQtdLMi  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
       	                       	nTipCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
           	                   	nFatCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
               	               nQtdCo2  := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                   	           	cUniMed  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
   	                           cLocPad  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
           	                   	cOpObs   := 'ROT. AUT. OP ORIG.: '+SC2->C2_NUM
                               	cRoteiro := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                                 If (cNumEmp == "01010101") // Jose 25/03/2025
                                     _cLote := U_NroSqLote("SZZ") // Jose 25/03/2025
                                 Else // Jose 25/03/2025
                                     _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                                 Endif // Jose 25/03/2025
//                              	_cLote   := U_NroSqLote("SZZ") // Jose 25/03/2025
                               	aAutoSC2 := {}
   	                           aadd(aAutoSC2, {"C2_FILIAL"  , xFilial("SC2")                , NIL})
       	                       	aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
           	                   	aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                   	           	aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                       	       	aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                               	aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
   	                          	aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
       	                       	aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
           	                   	aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
           	                   	aadd(aAutoSC2, {"C2_LOTE"   , _cLote                         , NIL})
               	               aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                   	           	aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                   	           	aadd(aAutoSC2, {"C2_OBS"    , cOpObs                         , NIL})																				
                       	       	aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                           	   aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                               	aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                       , NIL})
       	                        lMsErroAuto := .f.
			                    
			                        Dbselectarea("SC2")
               				      DbSetorder(1)
       				           	   Dbseek(xFilial("SC2"))
               				   	MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
               	                   	
           	                   	If !lMsErroAuto
               	                 	//Gera arquivo TXT para InkMaker
					                     aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon })
                               	Else
   	                       	   	MostraErro() // ver 07/04/2025
       	                       	Endif
 	                         Endif 
//-------------     Acrescentado Jose 05/09/2024 --------------
                            If Alltrim(cCodCon) $ Alltrim(_cMVXSOLU0) .and. !Empty(cCodCon) 
   	                           nQtdLMi  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
       	                       	nTipCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
           	                   	nFatCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
               	               nQtdCo2  := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                   	           	cUniMed  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
   	                           cLocPad  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
           	                   	cOpObs   := 'ROT. AUT. OP ORIG.: '+SC2->C2_NUM
                               	cRoteiro := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                                 If (cNumEmp == "01010101") // Jose 25/03/2025
                                     _cLote := U_NroSqLote("SZZ") // Jose 25/03/2025
                                 Else // Jose 25/03/2025
                                     _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                                 Endif // Jose 25/03/2025
//                             	_cLote   := U_NroSqLote("SZZ") // Jose 25/03/2025
                               	aAutoSC2 := {}
   	                           aadd(aAutoSC2, {"C2_FILIAL"  , xFilial("SC2")                , NIL})
       	                       	aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
           	                   	aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                   	           	aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                       	       	aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                               	aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
   	                          	aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
       	                       	aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
           	                   	aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
           	                   	aadd(aAutoSC2, {"C2_LOTE"   , _cLote                         , NIL})
               	               aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                   	           	aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                   	           	aadd(aAutoSC2, {"C2_OBS"    , cOpObs                         , NIL})																				
                       	       	aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                           	   aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                               	aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                       , NIL})
       	                        lMsErroAuto := .f.
			                    
			                        Dbselectarea("SC2")
               				      DbSetorder(1)
       				           	   Dbseek(xFilial("SC2"))
               				   	MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
               	                   	
           	                   	If !lMsErroAuto
               	                 	//Gera arquivo TXT para InkMaker
					                     aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon })
                               	Else
   	                       	   	MostraErro()   //  Ver  Jose 07/04/2025
       	                       	Endif
 	                         Endif 

                            If Alltrim(cCodCon) $ Alltrim(_cMVXSOLU5) .and. nQtdTota > 500 .and. !Empty(cCodCon) 
   	                           nQtdLMi  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
       	                       	nTipCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
           	                   	nFatCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
               	               nQtdCo2  := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                   	           	cUniMed  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
   	                           cLocPad  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
           	                   	cOpObs   := 'ROT. AUT. OP ORIG.: '+SC2->C2_NUM
                               	cRoteiro := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                                 If (cNumEmp == "01010101") // Jose 25/03/2025
                                     _cLote := U_NroSqLote("SZZ") // Jose 25/03/2025
                                 Else // Jose 25/03/2025
                                     _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                                 Endif // Jose 25/03/2025
//                              	_cLote   := U_NroSqLote("SZZ") // Jose 25/03/2025
                               	aAutoSC2 := {}
   	                           aadd(aAutoSC2, {"C2_FILIAL"  , xFilial("SC2")                , NIL})
       	                       	aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
           	                   	aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                   	           	aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                       	       	aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                               	aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
   	                          	aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
       	                       	aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
           	                   	aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
           	                   	aadd(aAutoSC2, {"C2_LOTE"   , _cLote                         , NIL})
               	               aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                   	           	aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                   	           	aadd(aAutoSC2, {"C2_OBS"    , cOpObs                         , NIL})																				
                       	       	aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                           	   aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                               	aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                       , NIL})
       	                        lMsErroAuto := .f.
			                    
			                        Dbselectarea("SC2")
               				      DbSetorder(1)
       				           	   Dbseek(xFilial("SC2"))
               				   	MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
               	                   	
           	                   	If !lMsErroAuto
               	                 	//Gera arquivo TXT para InkMaker
					                     aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon })
                               	Else
   	                       	   	MostraErro()  //   Ver Jose 07/04/2025
       	                       	Endif
 	                         Endif 

//-------------     Até Aqui Jose 05/09/2024 ------------------
                         Endif 
                         //Ver empenhos para OP se tem concentrado e a quantidade.
                         /*
                         If lVerCon
                            cQry1 := ""
                            cQry1 += "SELECT D4_OP,D4_COD,D4_QUANT "
                            cQry1 += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
                            cQry1 += "WHERE SD4.D4_FILIAL  = '"+xFilial("SD4")+"' "
                            cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                            cQry1 += "  AND SD4.D4_OP      = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+"' "
                            cQry1 += "  AND SUBSTRING(SD4.D4_COD, 1, 5) = '"+SUBSTR(SC2->C2_PRODUTO, 6, 5)+"' "
                            TCQuery cQry1 ALIAS "QEMP" NEW 
                            DbSelectArea("QEMP")
                            nQtdCon := QEMP->D4_QUANT
                            cCodCon := QEMP->D4_COD
                            DbSelectArea("QEMP")
                            DbCloseArea()
                            If !Empty(cCodCon)
                               nQtdLMi := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
                               nTipCon := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
                               nFatCon := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
                               nQtdCo2 := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                               cUniMed := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
                               lTemLoc := !Empty(Posicione("SB2", 1, xFilial("SB2")+Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_COD")+Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD"), "B2_LOCALIZ"))
                               If lTemLoc //Se tem localização
                                  If nQtdCon >= 30.0 //Se Quantidade do Concentrado for maior ou igual a 30
                                     lGerCon := .t.
                                  Else
                                     lGerCon := .f.
                                  Endif
                               Else
                                  lGerCon := .t.
                               Endif
                               If lGerCon
                                  cLocPad := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
                                  cNumOp  := SC2->C2_NUM
                                  aAutoSC2 := {}
                                  aadd(aAutoSC2, {"C2_FILIAL"  , xFilial("SC2")                , NIL})
                                  aadd(aAutoSC2, {"C2_ITEM"   , "02"                           , NIL})
                                  aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                                  aadd(aAutoSC2, {"C2_NUM"    , cNumOp                         , NIL})
                                  aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                                  aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                                  aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
                                  aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
                                  aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
                                  aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
                                  aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                                  aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                                  aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                                  aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                                  aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                       , NIL})
                                  lMsErroAuto := .f.
                                  Dbselectarea("SC2")
                                  MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
                                  If !lMsErroAuto
                                     //Gera arquivo TXT para InkMaker
                                     aAdd(aGerTxt, {cCodCon, '      ', cNumOp+'02'+'001', SZZ->ZZ_DTEMIS, nQtdCon })
                                  Else
                                  	 MostraErro()
                                  Endif
                               Endif
                            Endif
                         Endif */
                      Else
//  Jose 20/03/2025      MsgBox("O Produto "+SZZ->ZZ_PRODUTO+" do Lote "+cAuxLote+" não foi processado!", "Atencao!", "STOP")
//  Jose 20/03/2025      MostraErro()
                      Endif
                   Endif
                   DbSelectArea("SZZ")
                   DbSkip()
             Enddo
             DbSelectArea(xLotes)
             DbSkip()
             IncProc()      
       Enddo
EndIf   //  Jose 26/06/2024
       If (nContOcorr == 0) .and. (nContReg > 0)
          MsgBox("Nenhuma Ocorrencia!", "Atenção", "INFO")
       endif
Return

User Function fGerTXTOps(aGerTxt)
	Local lExiste   := .f.
	Local _nPos     := 0
    Local lPatOps, nX, _nY
    Local cPatOps   := Alltrim( GETMV("MV_DOSADOR") ) //LGS#20200204 - Adequação de release 12.1.25 e posteriores
    Local _cMVRETEN := GETMV("MV_RETENOP")
    Private cArqTxt := ""
    Private cArqMes := ""
    Private nHdl    := 0
    Private cEOL    := CHR(13)+CHR(10)
    
    If (cNumEmp == "01010101") 
       If Len(aGerTxt) > 0
          For _nY := 1 To Len(aGerTXT)
              lExiste := .f.
              cDescri := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[_nY][1], "B1_DESC")
              aQtdMat := {} ; aVolMat := {}
              aCodMat := {}
              aadd(aQtdMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
              aadd(aCodMat, {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
              aadd(aVolMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
              _nPos    := 1
              aMatIte := {}
              DbSelectArea("SD4")
              DbSetOrder(2)
              DbSeek(xFilial("SD4")+aGerTxt[_nY][3], .t.)
              If Found()
                 While !Eof() .and. Alltrim(SD4->D4_OP) == Alltrim(aGerTxt[_nY][3])
                 	 If _nPos <= 20
                         //LGS#20200206 - Adequação de release 12.1.25 e posteriores
                         //If !Alltrim(SD4->D4_COD) $ Alltrim(GETMV("MV_RETENOP"))
                         If !Alltrim(SD4->D4_COD) $ Alltrim( _cMVRETEN )
                             If Substr(Posicione("SC2", 1, xFilial("SC2")+SD4->D4_OP, "C2_PRODUTO"),6,2) =='05' .and. Len(Alltrim(Posicione("SC2", 1, xFilial("SC2")+SD4->D4_OP, "C2_PRODUTO")))==12
	                             If !Posicione("SB1", 1, xFilial("SB1")+Alltrim(SD4->D4_COD), "B1_DESC") $ 'PASTA' .and. SD4->D4_QUANT >= 0.2 .AND. !U_IsProdCusto( SD4->D4_COD )
		                             aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
    		                         //aQtdMat[1][_nPos] := SD4->D4_QUANT
        		                     //aCodMat[1][_nPos] := Alltrim(SD4->D4_COD)
            		                 //aVolMat[1][_nPos] := SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP")
                		             _nPos += 1
                             
	                	             If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
    	                	            lExiste := .t.
        	                	     Endif
        	                	 Endif
        	                 Else
                             If !U_IsProdCusto( SD4->D4_COD )
		                         aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
             		             _nPos += 1
                	             If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
   	                	            lExiste := .t.
       	                	     Endif
                              Endif
        	                 Endif
                         Endif
                     Endif
                     DbSelectArea("SD4")
                     DbSkip()
                 Enddo
              Endif
              _nPos    := 1
              aSort(aMatIte, , , { | x, y | x[3] > y[3] } )
              For nX := 1 To Len(aMatIte)
                  If _nPos <= 20
                     aQtdMat[1][_nPos] := aMatIte[nX][1]
                     aCodMat[1][_nPos] := aMatIte[nX][2]
                     aVolMat[1][_nPos] := aMatIte[nX][3]
                     _nPos += 1
                  Endif
              Next
              nQtdMat := 0
              For nX := 1 To 20
                  nQtdMat += aQtdMat[1][nX]
              Next
              If nQtdMat <= 0
                 Loop
              Endif
              If !lExiste
                 Loop
              Endif
              aCodEmb := { "", "", "", "", "", ""}
              aDesEmb := { "", "", "", "", "", ""}
              aOPSEmb := { "", "", "", "", "", ""}
              aQtdEmb := {  0,  0,  0,  0,  0,  0}
              aLocEmb := { "", "", "", "", "", ""}
              _nPos := 1
              DbSelectArea("SC2")
              DbOrderNickName("SC2001")
              DbSeek(xFilial("SC2")+aGerTxt[_nY][2], .t.)
              While !Eof() .and. SC2->C2_LOTE == aGerTxt[_nY][2]
                    If !Substr(Alltrim(SC2->C2_PRODUTO),11, 2) $ '00.99'
                       If _nPos <= 6
                          aCodEmb[_nPos] := SubStr(Alltrim(SC2->C2_PRODUTO), 11, 2)
                          aDesEmb[_nPos] := Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(SC2->C2_PRODUTO), 11, 2), "Z5_DESCR"))
                          aOPSEmb[_nPos] := SC2->C2_OP
                          aQtdEmb[_nPos] := SC2->C2_QUANT
                          aLocEmb[_nPos] := SC2->C2_LOCAL
                          _nPos += 1
                       Endif
                    Endif
                    DbSelectArea("SC2")
                    DbSkip()
              EndDo
              _cProduto := aGerTxt[_nY][1]
              cCatalis := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[_nY][1], "B1_CATALIS")
              dEmissao := DTOC(aGerTxt[_nY][4])
              nVolume  := aGerTxt[_nY][5]
              nPeso    := aGerTxt[_nY][5] * Posicione("SB1", 1, xFilial("SB1")+aGerTXT[_nY][1], "B1_PESOESP")
              cNumOrd  := aGerTxt[_nY][3]
              cNumLot  := aGerTxt[_nY][2]
              //lPatOps := File(GETMV("MV_DOSADOR")+"DOSADOR.CFG")
              //lPatOps := File(cPatOps+"DOSADOR.CFG") //LGS#20200204 - Adequação de release 12.1.25 e posteriores
			  lPatOps := waitrun( 'XCOPY' + " \\10.1.1.160\DADOS\OP\DOSADOR.CFG " + "c:\temp\" + " /y" ) == 0 //LGS#20210714 - Ajuste pois a função FILE não estava funcionando.
              If lPatOps
                 //cPatMes := Alltrim(GETMV("MV_DOSADOR"))
                 cPatMes := Alltrim(cPatOps) //LGS#20200204 - Adequação de release 12.1.25 e posteriores
              Else
                 cPatMes := Alltrim("F:\TEMP\DOSADOR\FABII\")
              Endif
              cArqMes := cPatMes+SubStr(aGerTxt[_nY][3], 1, 6)+'.DAT' //Para Fabrica II

              //If File(cArqMes)
                 //cCodPro := Alltrim(MemoLine(MemoRead(cArqMes), 250, 4))
                 //cNumOp  := Alltrim(MemoLine(MemoRead(cArqMes), 250, 7))
              cNumOP := aGerTxt[_nY][3]
              DbSelectArea("SC2")
              DbSetOrder(1)
              DbSeek(xFilial("SC2")+cNumOp, .t.)
              If Found()
                  If SubStr(cNumOp, 7, 2) == '02'
                      Loop
                  Else
                      FErase(cArqMes)
              	  Endif
              Endif
              //Endif
           	  nOutFile := FCreate(cArqMes) //Arquivo para Fabrica II
           	  If nOutFile == -1
               	  //MsgAlert("O arquivo de nome "+cArqMes+" nao pode ser gravado para Fabrica II!", "Atencao!")
           	  Endif
              /******************************************************************/
              /*** MONTAGEM DO ARQUIVO TEXTO                                  ***/
              /******************************************************************/
              /*** Linha 1 - Código do Produto ***/
              cLinMes := ""
              cFab2   := ""
              cCpoMes := Alltrim(_cProduto)
              cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
              cFab2   += cLinMes
              fWrite(nOutFile, cLinMes, Len(cLinMes)) //!= Len(cLinMes)
              /*** Linha 2 - Descrição do produto ***/
              cLinMes := ""
              cCpoMes := PADR(cDescri, 040)
              cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
              cFab2   += cLinMes
              fWrite(nOutFile, cLinMes, Len(cLinMes)) //!= Len(cLinMes)
              /*** Linha 3 - Peso ***/
              cLinMes := ""
              cCpoMes := Alltrim(Stuff(TransForm(nPeso, "@E 99999.999999"), At(",", TransForm(nPeso, "@E 99999.999999")), 1, "."))
              cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
              cFab2   += cLinMes
              fWrite(nOutFile, cLinMes, Len(cLinMes)) //!= Len(cLinMes)
              /*** Linha 4 - Volume ***/
              cLinMes := ""
              cCpoMes := Alltrim(Stuff(TransForm(nVolume, "@E 99999.999999"), At(",", TransForm(nVolume, "@E 99999.999999")), 1, "."))
              cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
              cFab2   += cLinMes
              fWrite(nOutFile, cLinMes, Len(cLinMes)) //!= Len(cLinMes)
              /*** Linha 5 - Materias Primas ***/
              For nX := 1 To 20
                  cLinMes := ""
                  cCpoMes := ""
                  If !Empty(aCodMat[1][nX])
                     cCpoMes := Alltrim(aCodMat[1][nX])+' '
                  Else
                     cCpoMes := " "
                  Endif
                  cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
                  cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
                  cFab2   += cLinMes
                  fWrite(nOutFile, cLinMes, Len(cLinMes)) //!= Len(cLinMes)
              Next
              /*** Linha 25 - Quantidades de matérias primas ***/
              cLinMes := ""
              cCpoMes := ""
              For nX := 1 To 20
                  cCpoMes += Alltrim(Stuff( TransForm(Round(aQtdMat[1][nX], 3), "@E 99999.999999"), At(",", TransForm(Round(aQtdMat[1][nX], 3), "@E 99999.999999")), 1 , "."))+' '
              Next
              cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
              cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
              cFab2   += cLinMes
              fWrite(nOutFile, cLinMes, Len(cLinMes)) //!= Len(cLinMes)
              /*** Linha 26 - Quantidades de matérias primas com valor negativo ***/
              cLinMes := ""
              cCpoMes := ""
              For nX := 1 To 20
                  cCpoMes += Alltrim(Stuff( TransForm((Round(aQtdMat[1][nX], 3) * (-1)), "@E 99999.999999"), At(",", TransForm((Round(aQtdMat[1][nX], 3) * (-1)), "@E 99999.999999")), 1 , "."))+' '
              Next
              cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
              cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
              cFab2   += cLinMes
              fWrite(nOutFile, cLinMes, Len(cLinMes)) //!= Len(cLinMes)
              /*** Finaliza arquivo ***/
              fClose(nOutFile)
              //Gravação no diretório F:\USER\DOSADOR\FAB2
              MemoWrit("\\10.1.1.160\DADOS\OP\"+SubStr(aGerTxt[_nY][3], 1, 6)+'.DAT', cFab2)
           	  //MemoWrit("F:\USERS\DOSADOR\FABII\"+SubStr(aGerTxt[_nY][3], 1, 6)+'.DAT', cFab2)
           	  //Gravação pelo diretório local - Incluida em 23/06/2010 para verificar quem está gerando a O.P. e porque as vezes a mesma não grava nos diretórios da rede
          	  If !Len(Directory("C:\TEMP", "D")) > 0
              	  MakeDir("C:\TEMP\")
               	  If !Len(Directory("C:\TEMP\FAB2\*", "D")) > 0
                  	  MakeDir("C:\TEMP\FAB2\")
               	  Endif
           	  Else
               	  If !Len(Directory("C:\TEMP\FAB2\*", "D")) > 0
                     MakeDir("C:\TEMP\FAB2\")
                  Endif
           	  Endif
           	  MemoWrit("C:\TEMP\FAB2\"+SubStr(aGerTxt[_nY][3], 1, 6)+'.DAT', cFab2)
          Next
       Endif
    Endif   
Return                   

User Function FATX04_2()
     Local oDlgF, oFont1, oNumLot, oCodOrd, oDesOrd, oCodEn1, oEnvas1, oCodEn2, oEnvas2, oCodEn3, oEnvas3, oCodEn4, oEnvas4, oCodEn5, oEnvas5, oCodEn6, oEnvas6
     Local lSaidaF   := .f.
     Local cNumLot   := SZZ->ZZ_LOTE
     //Local cCodOrd   := TransForm(SubStr(Alltrim(SZZ->ZZ_PRODUTO), 1, 10)+'00', "@R XX 99.99.999-99")
	 Local cCodOrd   := TransForm(Alltrim(SZZ->ZZ_PRODUTO), "@R XX 99.99.999-99")
     Local cDesOrd   := Iif(!Empty(SZZ->ZZ_DESCR), SZZ->ZZ_DESCR, Posicione("SB1", 1, xFilial("SB1")+SZZ->ZZ_PRODUTO, "B1_DESC"))
     Local cCodEn1   := space(06)
     Local cCodEn2   := space(06)
     Local cCodEn3   := space(06)
     Local cCodEn4   := space(06)
     Local cCodEn5   := space(06)
     Local cCodEn6   := space(06)
     Local cEnvas1   := space(30)
     Local cEnvas2   := space(30)
     Local cEnvas3   := space(30)
     Local cEnvas4   := space(30)
     Local cEnvas5   := space(30)
     Local cEnvas6   := space(30)
     Local nUsado    := 0
     Local nOpcA     := 0
     Local _nY
     Private aCols   := {}
     Private aHeader := {}

     //Montagem do aHeader
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*
     DbSelectArea("SX3")
     DbSetOrder(2)
     MsSeek("C2_OP")
     nUsado += 1
     AADD(aHeader, { 'O.P.'       , 'NUMORD', '999999'   ,  6, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
     MsSeek("C2_PRODUTO")
     nUsado += 1
     AADD(aHeader, { 'Embal.'     , 'CODORD', '99'       ,  2, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
     MsSeek("C2_QUANT")
     nUsado += 1
     AADD(aHeader, { 'Qtd. Solic.', 'QTDSOL', '@E 999999.99',  6, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
     MsSeek("C2_QUANT")
     nUsado += 1
     AADD(aHeader, { 'Qtd. Apont.', 'QTDAPT', '@E 999999.99',  6, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
     nUsado += 1
     AADD(aHeader, { 'Qtd. Ñ. Pr.', 'QTDNPR', '@E 999999.99',  6, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
     nUsado += 1
     AADD(aHeader, { '           ', 'QTDVAG', '@!'          ,  1, 0, '', X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )     */
     DbSelectArea( _cAliasSX3 )
     DbSetOrder(2)
     MsSeek("C2_OP")
     nUsado += 1
     AADD(aHeader, { 'O.P.'       , 'NUMORD', '999999'      ,  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
     MsSeek("C2_PRODUTO")
     nUsado += 1
     AADD(aHeader, { 'Embal.'     , 'CODORD', '99'          ,  2, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
     MsSeek("C2_QUANT")
     nUsado += 1
     AADD(aHeader, { 'Qtd. Solic.', 'QTDSOL', '@E 999999.99',  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
     MsSeek("C2_QUANT")
     nUsado += 1
     AADD(aHeader, { 'Qtd. Apont.', 'QTDAPT', '@E 999999.99',  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
     nUsado += 1
     AADD(aHeader, { 'Qtd. Ñ. Pr.', 'QTDNPR', '@E 999999.99',  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
     nUsado += 1
     AADD(aHeader, { '           ', 'QTDVAG', '@!'          ,  1, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )          
     /********************************************************************************************************************************/
     //Montagem do aCols
     DbSelectArea("SZZ")
     DbSetOrder(1)
     DbSeek(xFilial("SZZ")+cNumLot, .t.)
     If Found()
        While !Eof() .and. SZZ->ZZ_LOTE == cNumLot
              cQry1 := ""
              cQry1 += "SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_QUJE "
              cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
              cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
              cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
              cQry1 += "  AND SC2.C2_LOTE    = '"+cNumLot+"' "
              cQry1 += "  AND SC2.C2_PRODUTO = '"+SZZ->ZZ_PRODUTO+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              cQry1 := ""
              cQry1 += "SELECT PRO.ORDEM, "+Iif(Substr(Alltrim(SZZ->ZZ_PRODUTO),11,2) $ '00.99', "SUM(PRO.QTDE) AS QUANT ", "SUM(EMP.QUANT) AS QUANT ")
              cQry1 += "FROM PRODUCAO PRO "
              cQry1 += "LEFT OUTER JOIN EMPENHO EMP ON PRO.ORDEM = EMP.ORDEM AND PRO.LOTE = EMP.LOTE "
              cQry1 += "WHERE PRO.LOTE  = '"+cNumLot+"' "
              cQry1 += "  AND PRO.ORDEM = '"+TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+"' "
              cQry1 += "  AND EMP.FLAG  <> '1' "
              cQry1 += "GROUP BY PRO.ORDEM "
              TCQuery cQry1 ALIAS "EMP" NEW
              aAdd(aCols, {TCQ->C2_NUM, SubStr(SZZ->ZZ_PRODUTO, 11, 2), SZZ->ZZ_QTDETI, TCQ->C2_QUJE, EMP->QUANT, '', .f.})
              DbSelectArea("EMP")
              DbCloseArea()
              DbSelectArea("TCQ")
              DbCloseArea()
              DbSelectArea("SZZ")
              DbSkip()
        Enddo
     Endif
     //Verificação de Envasadores do Lote
     cQry1 := ""
     cQry1 += "SELECT DISTINCT ZZG_FILMAT, ZZG_NOME "
     cQry1 += " FROM "+RetSqlName("ZZG")+" ZZG WITH(NOLOCK) "
     cQry1 += " WHERE ZZG.D_E_L_E_T_ = ''  AND  ZZG_FILIAL ='"+xFilial("ZZG")+"' "
     cQry1 += " AND ZZG_PROENV <>'' AND ZZG_TPUSER ='E' AND ZZG_LOTE = '"+cNumLot+"' "
     cQry1 += " ORDER BY ZZG_PROENV, ZZG_SEQENV "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     aEnvasa := {}
     While !Eof()
           aAdd(aEnvasa, { TCQ->ZZG_FILMAT, TCQ->ZZG_NOME } )
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()
     If Len(aEnvasa) > 0.0
        For _nY := 1 To Len(aEnvasa)
            If _nY <= 6
               If _nY == 1
                  cCodEn1 := aEnvasa[_nY,1]
                  cEnvas1 := aEnvasa[_nY,2]
               ElseIf _nY == 2
                  cCodEn2 := aEnvasa[_nY,1]
                  cEnvas2 := aEnvasa[_nY,2]
               ElseIf _nY == 3
                  cCodEn3 := aEnvasa[_nY,1]
                  cEnvas3 := aEnvasa[_nY,2]
               ElseIf _nY == 4
                  cCodEn4 := aEnvasa[_nY,1]
                  cEnvas4 := aEnvasa[_nY,2]
               ElseIf _nY == 5
                  cCodEn5 := aEnvasa[_nY,1]
                  cEnvas5 := aEnvasa[_nY,2]
               ElseIf _nY == 6
                  cCodEn6 := aEnvasa[_nY,1]
                  cEnvas6 := aEnvasa[_nY,2]
               Endif
            Endif

        Next
     Endif
     DEFINE MSDIALOG oDlgF FROM 000,000 TO 023,085 TITLE OemToAnsi("Apontamento dos envasadores") OF oMainWnd
     DEFINE FONT oFont1 SIZE 9,0 BOLD
     DEFINE FONT oFont2 NAME 'ARIAL' SIZE 10,0 BOLD
            @ 001, 003 SAY   OemToAnsi("Lote")                     SIZE 030,009                PIXEL OF oDlgF
            @ 009, 003 MSGET oNumLot VAR cNumLot PICTURE "@R!"     SIZE 040,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 001, 045 SAY   OemToAnsi("Produto")                  SIZE 030,009                PIXEL OF oDlgF
            @ 009, 045 MSGET oCodOrd VAR cCodOrd PICTURE "@R!"     SIZE 078,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 001, 125 SAY   OemToAnsi("Descrição")                SIZE 030,009                PIXEL OF oDlgF
            @ 009, 125 MSGET oDesOrd VAR cDesOrd PICTURE "@R!"     SIZE 143,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            /****************************************************************************************************/
            @ 021, 003 SAY   OemToAnsi("Envasador 1")              SIZE 035,009                PIXEL OF oDlgF
            @ 029, 003 MSGET oCodEn1 VAR cCodEn1 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 029, 040 MSGET oEnvas1 VAR cEnvas1 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 021, 170 SAY   OemToAnsi("Envasador 2")              SIZE 035,009                PIXEL OF oDlgF
            @ 029, 170 MSGET oCodEn2 VAR cCodEn2 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 029, 207 MSGET oEnvas2 VAR cEnvas2 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            /****************************************************************************************************/
            @ 041, 003 SAY   OemToAnsi("Envasador 3")              SIZE 035,009                PIXEL OF oDlgF
            @ 049, 003 MSGET oCodEn3 VAR cCodEn3 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 049, 040 MSGET oEnvas3 VAR cEnvas3 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 041, 170 SAY   OemToAnsi("Envasador 4")              SIZE 035,009                PIXEL OF oDlgF
            @ 049, 170 MSGET oCodEn4 VAR cCodEn4 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 049, 207 MSGET oEnvas4 VAR cEnvas4 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            /****************************************************************************************************/
            @ 061, 003 SAY   OemToAnsi("Envasador 5")              SIZE 035,009                PIXEL OF oDlgF
            @ 069, 003 MSGET oCodEn5 VAR cCodEn5 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 069, 040 MSGET oEnvas5 VAR cEnvas5 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 061, 170 SAY   OemToAnsi("Envasador 6")              SIZE 035,009                PIXEL OF oDlgF
            @ 069, 170 MSGET oCodEn6 VAR cCodEn6 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            @ 069, 207 MSGET oEnvas6 VAR cEnvas6 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
            /****************************************************************************************************/
            oGetEnv := MsGetDados():New( 085, 003, 160, 335, 3, "AllwaysTrue()", "AllwaysTrue()", "", .f., {}, 3, , Len(aCols), "AllwaysTrue()" )
            
            DEFINE SBUTTON oBtnECf FROM 161, 260 TYPE 1 ACTION(nOpcA := 1, lSaidaF := .t., oDlgF:End()) ENABLE OF oDlgF
            DEFINE SBUTTON oBtnESa FROM 161, 300 TYPE 2 ACTION(nOpcA := 0, lSaidaF := .t., oDlgF:End()) ENABLE OF oDlgF
            oDlgF:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
            oCodEn1:SetFocus()
            oNumLot:lReadOnly  := .t. ; oCodOrd:lReadOnly := .t. ; oDesOrd:lReadOnly := .t. 
            oEnvas1:lReadOnly  := .t. ; oEnvas2:lReadOnly := .t. ; oEnvas3:lReadOnly := .t.
            oEnvas4:lReadOnly  := .t. ; oEnvas5:lReadOnly := .t. ; oEnvas6:lReadOnly := .t.
            oCodEn1:bLostFocus := {|| fValEnv(@oCodEn1, @cCodEn1, @oEnvas1, @cEnvas1, @oNumLot)}
            oCodEn2:bLostFocus := {|| fValEnv(@oCodEn2, @cCodEn2, @oEnvas2, @cEnvas2, @oNumLot)}
            oCodEn3:bLostFocus := {|| fValEnv(@oCodEn3, @cCodEn3, @oEnvas3, @cEnvas3, @oNumLot)}
            oCodEn4:bLostFocus := {|| fValEnv(@oCodEn4, @cCodEn4, @oEnvas4, @cEnvas4, @oNumLot)}
            oCodEn5:bLostFocus := {|| fValEnv(@oCodEn5, @cCodEn5, @oEnvas5, @cEnvas5, @oNumLot)}
            oCodEn6:bLostFocus := {|| fValEnv(@oCodEn6, @cCodEn6, @oEnvas6, @cEnvas6, @oNumLot)}
     ACTIVATE MSDIALOG oDlgF VALID lSaidaF CENTERED
     If nOpcA == 1
        cQry1 := ""
        cQry1 += "DELETE ENVASADORES WHERE LOTE = '"+cNumLot+"' "
        TCSQLExec(cQry1)
        For _nY := 1 To 6
            If _nY == 1
               If !Empty(cCodEn1)
                  cQry1 := ""
                  cQry1 += "SELECT * FROM ENVASADORES WHERE LOTE = '"+cNumLot+"' AND ENVASADOR = '"+cCodEn1+"' "
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  If Empty(TCQ->ENVASADOR)
                     cQry1 := ""
                     cQry1 += "INSERT ENVASADORES (ENVASADOR, LOTE) VALUES('"+cCodEn1+"', '"+cNumLot+"') "
                     TCSQLExec(cQry1)
                  Endif
                  DbSelectArea("TCQ")
                  DbCloseArea()
               Endif
            ElseIf _nY == 2
                   If !Empty(cCodEn2)
                      cQry1 := ""
                      cQry1 += "SELECT * FROM ENVASADORES WHERE LOTE = '"+cNumLot+"' AND ENVASADOR = '"+cCodEn2+"' "
                      TCQuery cQry1 ALIAS "TCQ" NEW
                      DbSelectArea("TCQ")
                      If Empty(TCQ->ENVASADOR)
                         cQry1 := ""
                         cQry1 += "INSERT ENVASADORES (ENVASADOR, LOTE) VALUES('"+cCodEn2+"', '"+cNumLot+"') "
                         TCSQLExec(cQry1)
                      Endif
                      DbSelectArea("TCQ")
                      DbCloseArea()
                   Endif
            ElseIf _nY == 3
                   If !Empty(cCodEn3)
                      cQry1 := ""
                      cQry1 += "SELECT * FROM ENVASADORES WHERE LOTE = '"+cNumLot+"' AND ENVASADOR = '"+cCodEn3+"' "
                      TCQuery cQry1 ALIAS "TCQ" NEW
                      DbSelectArea("TCQ")
                      If Empty(TCQ->ENVASADOR)
                         cQry1 := ""
                         cQry1 += "INSERT ENVASADORES (ENVASADOR, LOTE) VALUES('"+cCodEn3+"', '"+cNumLot+"') "
                         TCSQLExec(cQry1)
                      Endif
                      DbSelectArea("TCQ")
                      DbCloseArea()
                   Endif
            ElseIf _nY == 4
                   If !Empty(cCodEn4)
                      cQry1 := ""
                      cQry1 += "SELECT * FROM ENVASADORES WHERE LOTE = '"+cNumLot+"' AND ENVASADOR = '"+cCodEn4+"' "
                      TCQuery cQry1 ALIAS "TCQ" NEW
                      DbSelectArea("TCQ")
                      If Empty(TCQ->ENVASADOR)
                         cQry1 := ""
                         cQry1 += "INSERT ENVASADORES (ENVASADOR, LOTE) VALUES('"+cCodEn4+"', '"+cNumLot+"') "
                         TCSQLExec(cQry1)
                      Endif
                      DbSelectArea("TCQ")
                      DbCloseArea()
                   Endif
            ElseIf _nY == 5
                   If !Empty(cCodEn5)
                      cQry1 := ""
                      cQry1 += "SELECT * FROM ENVASADORES WHERE LOTE = '"+cNumLot+"' AND ENVASADOR = '"+cCodEn5+"' "
                      TCQuery cQry1 ALIAS "TCQ" NEW
                      DbSelectArea("TCQ")
                      If Empty(TCQ->ENVASADOR)
                         cQry1 := ""
                         cQry1 += "INSERT ENVASADORES (ENVASADOR, LOTE) VALUES('"+cCodEn5+"', '"+cNumLot+"') "
                         TCSQLExec(cQry1)
                      Endif
                      DbSelectArea("TCQ")
                      DbCloseArea()
                   Endif
            ElseIf _nY == 6
                   If !Empty(cCodEn6)
                      cQry1 := ""
                      cQry1 += "SELECT * FROM ENVASADORES WHERE LOTE = '"+cNumLot+"' AND ENVASADOR = '"+cCodEn6+"' "
                      TCQuery cQry1 ALIAS "TCQ" NEW
                      DbSelectArea("TCQ")
                      If Empty(TCQ->ENVASADOR)
                         cQry1 := ""
                         cQry1 += "INSERT ENVASADORES (ENVASADOR, LOTE) VALUES('"+cCodEn6+"', '"+cNumLot+"') "
                         TCSQLExec(cQry1)
                      Endif
                      DbSelectArea("TCQ")
                      DbCloseArea()
                   Endif
            Endif
        Next
     Endif
     DbSelectArea("SZZ")
     DbSetOrder(1)
     DbSeek(xFilial("SZZ")+cNumLot, .t.)
Return

Static Function fValEnv(oCodEnv, cCodEnv, oEnvasa, cEnvasa, oNumLot)
       If Empty(cCodEnv)
          oNumLot:SetFocus()
          Return
       Endif
       DbSelectArea("SRA")
       DbSetOrder(1)
       DbSeek(xFilial("SRA")+cCodEnv, .t.)
       If Found()
          cEnvasa := SRA->RA_NOME
          oCodEnv:Refresh()
          oEnvasa:Refresh()
       Else
          MsgBox("Envasador Inválido !!!", "Atenção", "STOP")
          cCodEnv := space(06)
          cEnvasa := space(30)
          oCodEnv:Refresh()
          oEnvasa:Refresh()
          oCodEnv:SetFocus()
       Endif
Return

Static Function VerLotesAb()
       Local lRet := .t.,cQuery,cTrab,cLote      
       If alltrim(cNumEmp) == "0501" //Executar somente para Paraguay por enquanto 
          cQuery := "SELECT DISTINCT ZZ_LOTE AS LOTE "+;
                    "FROM "+RetSqlName("SZZ")+" SZZ WITH (NOLOCK) "+;
                    "WHERE (D_E_L_E_T_ <> '*') AND (ZZ_FILIAL = '"+xFilial("SZZ")+"') AND (ZZ_LOTE > '') AND (ZZ_FLAG <= 'N') "+;
                    "ORDER BY LOTE"   
          cTrab := U_NovoCursor()
          TCQuery cQuery ALIAS (cTrab) NEW
          dbselectarea(cTrab)
          dbgotop()
          do while !eof()
             cLote := (cTrab)->LOTE
             dbselectarea(xLotes)
             dbgotop()
             locate for lote == cLote   
             if eof() .or. (!eof() .and. !bof() .and. (xLotes)->LOTE <> cLote)
                RecLock(xLotes,.T.)
                   Replace lote with cLote 
                MsUnLock()
             endif
             dbselectarea(cTrab)
             dbskip()
          enddo
          dbselectarea(cTrab)
          dbclosearea()
          dbselectarea(xLotes)
          dbgotop()
       endif
return(lRet)

User Function VerMetrica(cProd)
   Local cQry     := ""
   Local cQry1    := ""
   Local lDiverge := .F.

if alltrim(FWGrpCompany()) = "05" //Cleber (19/04/2021) -> Está dando problema na UnionSur!!!
   return(lDiverge)
endif 


   DbSelectArea("ZGF")
	DbSetOrder(1) // ZGF_FILIAL+ZGFG_COD
   DbSeek(xFilial("ZGF")+cProd, .t.)
   If Found() 
      cQry := "" // CONSULTA EXCEÇÃO OU PI KG, OU SEJA, SE PRODUTO CADASTRADO DIRETAMENTE NA TABELA ZGF
      cQry += " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_LOCPAD, SG1.G1_COMP, ZGF.ZGF_CODGGF "
      cQry += " FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
      cQry += " LEFT OUTER JOIN "+RetSqlName("SG1")+" SG1 ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COD = SB1.B1_COD AND SG1.D_E_L_E_T_ ='' "
      cQry += " LEFT OUTER JOIN "+RetSqlName("ZGF")+" ZGF ON ZGF.ZGF_FILIAL = SG1.G1_FILIAL AND ZGF.ZGF_COD = SG1.G1_COD AND SG1.G1_COMP = ZGF.ZGF_CODGGF AND ZGF.D_E_L_E_T_ ='' "
      cQry += " WHERE SB1.D_E_L_E_T_ ='' "
      cQry += " AND SB1.B1_FILIAL ='"+xFilial("SB1")+"' "
      cQry += " AND SB1.B1_COD ='"+cProd+"' "
      cQry += " AND SUBSTRING(SG1.G1_COMP,1,3)='GGF' "
      TCQuery cQry ALIAS "TMETRICA" NEW
      DbSelectArea("TMETRICA")
      If !Eof()
         While !Eof() .AND. (TMETRICA->B1_FILIAL == XFILIAL("SB1")) .AND. (Alltrim(cProd) == Alltrim(TMETRICA->B1_COD))
            If (ALLTRIM(TMETRICA->ZGF_CODGGF)) <> (ALLTRIM(TMETRICA->G1_COMP))
               lDiverge :=.T.
            Endif
            DbSelectArea("TMETRICA")
            DbSkip()
         Enddo
      Endif
   Else
      cQry1 := "" // PRODUTOS QUE TEM MÉTRICA DEFINIDA POR LINHA + CARACTERÍSTICA
      cQry1 += " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_LOCPAD, ZGF.ZGF_CODGGF,  "
      cQry1 += " 'GGF_SG1' = (SELECT MAX(G1_COMP) FROM "+RetSqlName("SG1")+" SG1 WHERE SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COD = SB1.B1_COD AND SG1.G1_COMP = ZGF.ZGF_CODGGF AND SG1.D_E_L_E_T_='') "
      cQry1 += " FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) "
      cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZGF")+" ZGF WITH(NOLOCK) ON SB1.B1_FILIAL = ZGF.ZGF_FILIAL AND SUBSTRING(SB1.B1_COD,4,2)= ZGF.ZGF_LINHA AND SUBSTRING(SB1.B1_COD,1,3) = ZGF.ZGF_CARAC AND SB1.B1_TIPO = ZGF.ZGF_TIPO  AND ZGF.ZGF_COD =''  AND ZGF.D_E_L_E_T_ ='' "
      cQry1 += " WHERE SB1.D_E_L_E_T_ ='' "
      cQry1 += " AND SB1.B1_FILIAL ='"+xFilial("SB1")+"' "
      cQry1 += " AND SB1.B1_COD ='"+cProd+"' "
      TCQuery cQry1 ALIAS "TMETRICA" NEW
      DbSelectArea("TMETRICA")
      If !Eof()
         While !Eof() .AND. (TMETRICA->B1_FILIAL == XFILIAL("SB1")) .AND. (Alltrim(cProd) == Alltrim(TMETRICA->B1_COD))
            If ((ALLTRIM(TMETRICA->ZGF_CODGGF)) <> (ALLTRIM(TMETRICA->GGF_SG1)))  .OR. Empty(TMETRICA->ZGF_CODGGF)
               lDiverge :=.T.
            Endif
            DbSelectArea("TMETRICA")
            DbSkip()
         Enddo
      Endif
   Endif   
   
   DbSelectArea("TMETRICA")
   DbCloseArea()   
   

   DbSelectArea("ZGF")
   DbClosearea()


Return (lDiverge)
// ----------  Jose 11/03/2025 ------------------------------
User Function NroSqLote(cTabela, nTam)
     Local _cNumAut  := "*"
     Local _cProximo := ""
     Local cSx2, cAliasZZW, lAbriuOutraArea
     Local _cAux, _cGrupoEmp,nTamFil,cFilTab
     Local _cAux1 := ""
     Local _cAux2 := 0 
     Local cArea := Alias()
     
   //Ver para qual tabela SX2 aponta (Cleber)
 	cAliasZZW       := "ZZW"
	cSx2 := alltrim(RetSqlName(cAliasZZW))
	_cGrupoEmp := substr(cSx2,4,2)
	nTamFil := FWSizeFilial(_cGrupoEmp)

	lAbriuOutraArea := .f.
	DbSelectArea(cAliasZZW)
	DbSetOrder(1)

     cFilTab := padr(alltrim(xFilial(cTabela)),nTamFil," ")

     If cFilTab = "010101" .AND. cTabela = 'SZZ' // Jose 24/03/2025
        nTam = 5 // Jose 06/03/2025
     Else // Jose 06/03/2025
        nTam = 6 // Jose 06/03/2025
     Endif  

     DbSelectArea(cAliasZZW)         // Tabela de numeracao de Lote.
     DbSeek(cFilTab+cTabela, .F.)
     If !Found()
        RecLock(cAliasZZW, .T.)
           _cAux  := cAliasZZW+"->ZZW_FILIAL"
           &_cAux := cFilTab
           _cAux  := cAliasZZW+"->ZZW_TABELA"
           &_cAux := cTabela
           _cAux  := cAliasZZW+"->ZZW_NUM"
           &_cAux := "*"
        MsUnLock()          
        _cNumAut := StrZero(1, nTam)
     Else
        _cAux    := cAliasZZW+"->ZZW_NUM"
        _cNumAut := &_cAux
        _nTime   := 1000
        While ("*" $ _cNumAut)
              DbSelectArea(cAliasZZW)
              DbGoBottom()
              DbGoTop()
              DbSeek(cFilTab+cTabela)
              _cAux    := cAliasZZW+"->ZZW_NUM"
              _cNumAut := &_cAux
              If ("*" $ _cNumAut) .And. ((_nTime--) <= 0)
                 If MsgYesNo("Nao foi possível obter proximo numero.", "Tentar novamente?")
                    _nTime := 500
                    Loop
                 Else
                    Exit
                 EndIf
              EndIf
        EndDo
        If !("*" $ _cNumAut)
           RecLock(cAliasZZW, .F.)
              _cAux  := cAliasZZW+"->ZZW_NUM"
              &_cAux := "*"
           MsUnLock()
        EndIf

     EndIf
     If ("*" $ _cNumAut)
        MsgBox("Nao foi possivel obter prox. nro!", "Tente novamente!", "STOP")
     Else
        // Libera para pegarem o proximo numero de Lote
       IF cFilTab = "010101" .AND. cTabela = 'SZZ'  // jose 24/03/2025
          _cAux1 = SUBSTRING(_cNumAut,1,1)  //  Jose 06/03/2025
          If _cAux1 = "*" //  Jose 06/03/2025
             _cAux1 = "A" //  Jose 06/03/2025
          EndIf.
          If _cAux1 = "0" //  Jose 06/03/2025
             _cAux1 = "A" //  Jose 06/03/2025
          EndIf.
          _cAux2 = SUBSTRING(_cNumAut,2,5) //  Jose 06/03/2025
          _cAux2 = StrZero(Val(_cAux2)+1, nTam) //  Jose 06/03/2025
         _cProximo = _cAux1 + (Padl(cValToChar(_cAux2),5,"0")) //  Jose 06/03/2025
       Else
         _cProximo := StrZero(Val(_cNumAut)+1, nTam) //  Jose 06/03/2025
       Endif // Jose 06/03/2025
       DbSelectArea(cAliasZZW)
       DbSeek(cFilTab+cTabela, .F.)
       RecLock(cAliasZZW, .F.)
          _cAux  := cAliasZZW+"->ZZW_NUM"
          &_cAux := _cProximo
       MsUnLock()
     Endif 
     If lAbriuOutraArea
        DbSelectArea(cAliasZZW)
        DbCloseArea()
     Endif   
     if !empty(cArea)
     	select(cArea)
     endif 
Return _cNumAut

//   jose 14/05/2025
User Function MinhaFuncao()
Local cErro := ""
Local cErroa:= ""

cErro := ErrorBlock({|e| e:Description})  
cErroa:= ErrorBlock({|e| e:MostraErro()})   

// Seu código aqui

If !Empty(cErro)
// Tratar o erro aqui
   MsgInfo("Ocorreu um erro: " + cErro, "Erro")
EndIf

Return

// ate aqui Jose 14/05/2025
