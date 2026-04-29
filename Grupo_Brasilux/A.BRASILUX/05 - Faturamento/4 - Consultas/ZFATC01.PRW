#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ZFATC01  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 20/03/23 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ O Tela de  Consulta De Itens /                             ³±±
±±³		     ³ Desconto Política X Frete CIF. (Pedido de Venda)           ³±±
±±³		     ³ Relacionado com PE MA410MNU                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
 
User Function ZFATC01()

// Largura Botão Fechar
Local nLargBtn      := 40

//Objetos e componentes
Private oPanGrid
Private oDlgg

//Cabeçalho
Private oSayClie, cSayClie := ""
Private oSayDesc, cSayDesc := "Desconto : "
Private oSayFret, cSayFret := "Frete CIF : "
Private oSayVend, cSayVend := ""
Private oSayPed , cSayPed  := ""
Private oSayMun , cSayMun  := ""
Private oSayTot , cSayTot  

Private oSayPeso, cSayPeso := "Peso :"
Private oGetPeso, nGetPeso := ""

Private oSayTransp, cSayTransp := "Transportadora : "
Private oGetTransp, nGetTransp := SC5->C5_TRANSP

Private oSayTone, cSayTone := "Preço Por Tonelada :"
Private oGetPrcTone, nGetPrcTone := 0

Private oSayPercent, cSayPercent  := "% Pela Nota :"
Private oGetPercent, nGetPercent

Private oGetDesc,nGetDesc
Private oGetFret,nGetFret


//Tamanho da janela
Private nJanLarg  := 1400
Private nJanAltu  := 650

//Private aSize := MsAdvSize(.F.)
//Private nJanLarg := aSize[5] - 200
//Private nJanAltu := aSize[6]

//Fontes
Private cFontUti    := "Tahoma"
Private oFontMod    := TFont():New(cFontUti, , -38)
Private oFontSub    := TFont():New(cFontUti, , -20)
Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
Private oFontBtn    := TFont():New(cFontUti, , -14)
Private oFontSay    := TFont():New(cFontUti, , -12)

//Grid
Private aCampos := {}
Private cAliasTmp := "TST_" + RetCodUsr()
Private aColunas := {}

Private _nNFTOTAL

  
//Campos da Temporária
aAdd(aCampos, { "ITEM"    , "C", TamSX3("C6_ITEM")   [1], 0 })
aAdd(aCampos, { "CODIGO"  , "C", TamSX3("C6_PRODUTO")[1], 0 })
aAdd(aCampos, { "DESCRI"  , "C", TamSX3("C6_DESCRI") [1], 0 })
aAdd(aCampos, { "QTDVEN"  , "N", TamSX3("C6_QTDVEN") [1], 0 })
aAdd(aCampos, { "PRCVEN"  , "N", 14, 4, "@E 9,999,999.99999999"   })
aAdd(aCampos, { "X_PRCTA" , "N", 14, 4, "@E 9,999,999.99999999"   })
aAdd(aCampos, { "X_TOTAL" , "N", 14, 4, "@E 9,999,999.99999999"   })
aAdd(aCampos, { "DESCONT" , "N", TamSX3("C6_DESCONT")[1], 0 })


// Alimenta campos Cabeçalho
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+PadR(SC5->C5_CLIENTE,Len(SA1->A1_COD))))
cSayClie := "Cliente : "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NOME)

SA3->(dbSetOrder(1))
if SA3->(dbSeek(xFilial("SA3")+PadR(SC5->C5_VEND1,Len(SA3->A3_COD))))
    cSayVend := "Vendedor : "+AllTrim(SA3->A3_COD)+" - "+AllTrim(SA3->A3_NOME) 
EndIf

SA4->(dbSetOrder(1))
if SA4->(dbSeek(xFilial("SA4")+PadR(SC5->C5_REDESP,Len(SA4->A4_COD))))
    cSayTransp := cSayTransp + SA4->A4_COD + " - " + SA4->A4_NOME 
EndIf

cSayPed  := 'Nº Pedido : '+AllTrim(SC5->C5_NUM)

cSayMun  := "Cidade : "+AllTrim(SA1->A1_MUN)+" - "+AllTrim(SA1->A1_EST)

nGetDesc := SC5->C5_DESCON4
nGetPeso := SC5->C5_PBRUTO
nGetFret := SC5->C5_XVLRFRE

//Cria a tabela temporária
oTempTable:= FWTemporaryTable():New(cAliasTmp)
oTempTable:SetFields( aCampos )
oTempTable:Create()

//Busca as colunas do browse
aColunas := fCriaCols()

//Popula a tabela temporária
cSayTot := Transform(fPopula(), "@E 999,999.9999")

// Planilha Financeira
MsAguarde({|| RET_ICMS() },"Buscando informações do Pedido","Aguarde...")

  
//Cria a janela
DEFINE MSDIALOG oDlgg TITLE "Desconto Política X Frete CIF"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
        
    // Say  Top  Left
    oSayPed  := TSay():New(015, 010, {|| cSayPed} , oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
    oSayClie := TSay():New(015, 080, {|| cSayClie}, oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

    oSayDesc := TSay():New(015,320, {|| cSayDesc}, oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
    oGetDesc := TGet():New(012,360, {|u| If(PCount() > 0, nGetDesc := u, nGetDesc)}, oDlgg, 045, 010, '@E 999,999.9999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nGetDesc", , )
    // Top Lef Largura Altura
    
    oSayPeso := TSay():New(015,430, {|| cSayPeso} , oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
    oGetPeso := TGet():New(012,455, {|u| If(PCount() > 0, nGetPeso := u, nGetPeso)}, oDlgg, 045, 010,"@E 9999.99" , , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nGetPeso", , )

    oSayTone     := TSay():New(015,550, {|| cSayTone} , oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 140), , 300, 30, , , , , , .F., , )
    oGetPrcTone  := TGet():New(012,640, {|u| If(PCount() > 0, nGetPrcTone := u, nGetPrcTone)}, oDlgg, 045, 010,'@E 999,999.99', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nGetPrcTone", , )

    oSayMun  := TSay():New(032, 010, {|| cSayMun} , oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
    
    oSayVend := TSay():New(032, 180, {|| cSayVend}, oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

    oSayTransp := TSay():New(047, 010, {|| cSayTransp} , oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )    
       
    oSayPercent := TSay():New(047, 405, {|| cSayPercent} , oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )    
    oGetPercent := TGet():New(045, 455, {|u| If(PCount() > 0, nGetPercent := u, nGetPercent)}, oDlgg, 045, 010, '@E 99,99', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nGetPercent", , )
    
    oSayFret   := TSay():New(047,550, {|| cSayFret}, oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
    oGetFret   := TGet():New( 045, 640, {|u| If(PCount() > 0, nGetFret := u, nGetFret)}, oDlgg, 045, 010, '@E 999,999.99', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nGetFret", , )
    oGetFret:bChange := {|| GrvFrete('1') }
    
    oGetPercent:bWhen := {|| .F. }
    oGetPrcTone:bWhen := {|| .F. }
    oGetDesc:bWhen := {|| .F. }
    oGetPeso:bWhen := {|| .F. }

    If SC5->C5_XVLRFRE > 0
      GrvFrete('2')
    EndIf


    //                         Top Lef  Bot  Rig   
    oGrpPrE    := TGroup():New(02 ,02  ,060 ,702,'Dados Pedido',oDlgg,CLR_BLACK,CLR_GRAY,.T.)
        
    
  
    //Cria a grid            Top  Left                                                    Rigth bottom 
    oPanGrid := tPanel():New(062, 002, "", oDlgg, , , , RGB(000,000,000), RGB(254,254,254), 698,  222)
    oGetGrid := FWBrowse():New()
    oGetGrid:SetDataTable()
    oGetGrid:SetEditCell(.T., {|| .T.}) 
    oGetGrid:SetInsert(.T.)
    oGetGrid:SetDelete(.T., { || .T. })
    oGetGrid:SetAlias(cAliasTmp)
    oGetGrid:DisableReport()
    oGetGrid:DisableFilter()
    oGetGrid:DisableConfig()
    oGetGrid:DisableReport()
    oGetGrid:DisableSeek()
    oGetGrid:DisableSaveConfig()
    oGetGrid:SetFontBrowse(oFontSay)
    oGetGrid:SetColumns(aColunas)
    oGetGrid:SetOwner(oPanGrid)
    oGetGrid:Activate()
   
    oGrpPrD  := TGroup() :New(290 ,002  ,322 ,702,"Total do Pedido ",oDlgg,CLR_BLACK,CLR_GRAY,.T.)
    oSayTot  := TSay()   :New(303, 010, {|| "R$:"+AllTrim(transform(_nNFTOTAL,"@E 9,999,999.9999"))}, oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
    
    //oBtnFrete := TButton():New(300, 585 , "Calcular Frete", oDlgg, {|| U_ZFATC06(SC5->C5_NUM)}, 55, 018, , oFontBtn, , .T., , , , , , )
    
    oBtnSair := TButton():New(300, 655 , "Fechar", oDlgg, {|| Sair()}, nLargBtn, 018, , oFontBtn, , .T., , , , , , )
    
    Activate MsDialog oDlgg Centered
    oTempTable:Delete()
Return

Static Function Sair()
    oDlgg:End()
return()
  
Static Function fCriaCols()
    Local nAtual   := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
      
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, {"ITEM"    , "Item"      ,   "C", TamSX3('C6_ITEM')[01]    , 0,   ""})
    aAdd(aEstrut, {"CODIGO"  , "Código"    ,   "C", TamSX3('C6_PRODUTO')[01] , 0,   ""})
    aAdd(aEstrut, {"DESCRI"  , "Descrição" ,   "C", TamSX3('C6_DESCRI')[01]  , 0,   ""})
    aAdd(aEstrut, {"QTDVEN"  , "Qtde"      ,   "C", TamSX3('C6_QTDVEN')[01]  , 0,   ""})
    aAdd(aEstrut, {"PRCVEN" ,  "Prc Vend"  ,   "N" , 14, 4, "@E 9,999,999.99999999", .T.}    )
    aAdd(aEstrut, {"X_PRCTA" , "Prc Tabela",   "N" , 14, 4, "@E 9,999,999.99999999", .T.}    )
    aAdd(aEstrut, {"X_TOTAL" , "Vlr Total" ,   "N" , 14, 4, "@E 9,999,999.99999999", .T.}    )    
    aAdd(aEstrut, {"DESCONT" , "Desc %"    ,   "N" , 14, 4, "@E 9,999,999.99999999", .T.}    )
  
    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| (cAliasTmp)->" + aEstrut[nAtual][1] +"}"))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
        oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "') }")
  
        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas
  
Static Function fPopula()
Local nTotal := 0

    SC6->(dbSetOrder(1))
    SC6->(dbSeek(xFilial("SC6")+PadR(SC5->C5_NUM,Len(SC6->C6_NUM))))

    While SC6->(!EOF()) .AND. SC6->C6_NUM == SC5->C5_NUM

        //Grava na temporária
        RecLock(cAliasTmp, .T.)
            (cAliasTmp)->ITEM    := SC6->C6_ITEM
            (cAliasTmp)->CODIGO  := SC6->C6_PRODUTO
            (cAliasTmp)->DESCRI  := SC6->C6_DESCRI
            (cAliasTmp)->QTDVEN  := SC6->C6_QTDVEN
            (cAliasTmp)->PRCVEN  := SC6->C6_PRCVEN
            (cAliasTmp)->X_PRCTA := SC6->C6_X_PRCTA
            (cAliasTmp)->X_TOTAL := (SC6->C6_PRCVEN * SC6->C6_QTDVEN)
            (cAliasTmp)->DESCONT := SC6->C6_DESCONT

        (cAliasTmp)->(MsUnlock())
        nTotal := nTotal + SC6->C6_VALOR
        SC6->(DBSKIP())
    Enddo 

Return(nTotal)


// funcao para gravar valor do frete
Static Function GrvFrete(cTipo)
Local PrcPeso    
    
   nGetPercent := Transform(((nGetFret/_nNFTOTAL)*100), "@E 99.99")

   PrcPeso     := (nGetFret/nGetPeso)
   PrcPeso     := (PrcPeso * 1000)
   nGetPrcTone := PrcPeso


   If (SC5->C5_XVLRFRE <> nGetFret) .AND. (cTipo  == "1")

      RecLock("SC5", .F.)
         SC5->C5_XVLRFRE := nGetFret
      MsUnLock()
   
      TxtMail := "Nº Pedido : "+SC5->C5_NUM+chr(13)+chr(10)
      TxtMail += "Valor do Frete CIF :"+Transform(nGetFret, "@E 999,999.999")+chr(13)+chr(10)+chr(13)+chr(10)
      TxtMail += "Usuário : "+PswChave(RetCodUsr())+chr(13)+chr(10) 
      TxtMail += "Data :"+DToC(dDataBase)+" - "+Time()
      
      U_EnvMail("Frete CIF Cadastrado",TxtMail,GETMV("ZP_PAR0097"),"","")

   EndIf

Return()


Static Function RET_ICMS()

     Local aArea      := GetArea()
     Local aAreaSA1   := SA1->(GetArea())
     Local aFisGet    := {}
     Local aFisGetSC5 := {}
     //Local aTitles    := {"Nota Fiscal", "Duplicatas"}
     Local aDupl      := {}
     //Local aFlHead    := { "Vencimento", "Valor", 'STR0063' }
     Local aEntr      := {}                
     Local aDuplTmp   := {}
     Local aHeadSC6   := MHeaderSC6()
     Local aColsSC6   := MonAcolSC6(aHeadSC6)
     Local nPTotal    := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_VALOR"   })
     Local nPValDesc  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_VALDESC" })
     Local nPPrUnit   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRUNIT"  })
     Local nPPrcVen   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRCVEN"  })
     Local nPQtdVen   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_QTDVEN"  })
     Local nPDtEntr   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_ENTREG"  })
     Local nPProduto  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRODUTO" })
     Local nPTES      := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_TES"     })
     Local nPNfOri    := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_NFORI"   })
     Local nPSerOri   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_SERIORI" })
     Local nPItemOri  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_ITEMORI" })
     Local nPCodPro   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRODUTO" })
     //Local nUsado     := Len(aHeadSC6)
     Local nX         := 0
     Local nAcerto    := 0
     Local nPrcLista  := 0
     Local nValMerc   := 0
     Local nDesconto  := 0
     Local nAcresFin  := 0
     Local nQtdPeso   := 0
     Local nRecOri    := 0
     Local nPosEntr   := 0
     Local nItem      := 0
     Local nY         := 0 
     Local nPosCpo    := 0
     Local lDtEmi     := SuperGetMv("MV_DPDTEMI", .F., .T.)
     Local dDataCnd   := SC5->C5_EMISSAO
     //Local oDlg
     //Local oDupl
     //Local oFolder
     Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     Local _nNFFRETE     //LGS#20200211 - Adequação para release 12.1.25
     Local _nNFSEGUR
     Local _nNFDESCO
     Local _nNFAUTON
     Local _nNFDESPE
     Local _nNFBASED
     

     Private nUsdSC6  := Len(aHeadSC6)

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC5                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SC5")
     DbSetOrder(1)
     DbSeek(xFilial("SC5")+SC5->C5_NUM, .t.)
     dDataCnd   := SC5->C5_EMISSAO
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC6                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aFisGet	:= {}

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(1)
     MsSeek("SC6")
     While !Eof() .And. X3_ARQUIVO == "SC6"
           cValid := UPPER(X3_VALID+X3_VLDUSER)
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid)+10
              nLen        := AT('")',Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGet, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGet, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo*/
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )
     ( _cAliasSX3 )->( MsSeek("SC6") )
     While !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC6"
           cValid := UPPER( ( _cAliasSX3 )->( X3_VALID ) + ( _cAliasSX3 )->( X3_VLDUSER ) )
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid)+10
              nLen        := AT('")',Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGet, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGet, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     aSort(aFisGet, , ,{|x, y| x[3] < y[3]})

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC5                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aFisGetSC5	:= {}

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*dbSelectArea("SX3")
     dbSetOrder(1)
     MsSeek("SC5")
     While !Eof() .And. X3_ARQUIVO == "SC5"
           cValid := UPPER(X3_VALID+X3_VLDUSER)
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid) + 10
              nLen        := AT('")', Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGetSC5, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGetSC5, { cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo*/
     dbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( dbSetOrder(1) )
     ( _cAliasSX3 )->( MsSeek("SC5") )
     While !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC5"
           cValid := UPPER( ( _cAliasSX3 )->( X3_VALID ) + ( _cAliasSX3 )->( X3_VLDUSER ) )
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid) + 10
              nLen        := AT('")', Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGetSC5, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGetSC5, { cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     aSort(aFisGetSC5, , , {|x, y| x[3] < y[3]})

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Inicializa a funcao fiscal                   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     MaFisSave()
     MaFisEnd()
     MaFisIni(SC5->C5_CLIENTE                   ,; //1-Codigo Cliente/Fornecedor
              SC5->C5_LOJAENT                   ,; //2-Loja do Cliente/Fornecedor
              IIf(SC5->C5_TIPO $ 'DB', "F", "C"),; //3-C:Cliente , F:Fornecedor
              SC5->C5_TIPO                      ,; //4-Tipo da NF
              SC5->C5_TIPOCLI                   ,; //5-Tipo do Cliente/Fornecedor
              Nil                               ,;
              Nil                               ,;
              Nil                               ,;
              Nil                               ,;
              "MATA461"                          )

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Agrega os itens para a funcao fiscal         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
        For nX := 1 To Len(aColsSC6)
            nQtdPeso := 0
            If Len(aColsSC6[nX]) == nUsdSC6 .Or. !aColsSC6[nX][nUsdSC6+1]
               nItem++
               If nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
                  If !Empty(aColsSC6[nX][nPNfOri]) .And. !Empty(aColsSC6[nX][nPItemOri])
                     SD1->(dbSetOrder(1))
                     If SD1->(MSSeek(xFilial("SD1")+aColsSC6[nX][nPNfOri]+aColsSC6[nX][nPSerOri]+SC5->C5_CLIENTE+SC5->C5_LOJACLI+aColsSC6[nX][nPCodPro]+aColsSC6[nX][nPItemOri]))
                        nRecOri := SD1->(Recno())
                     Endif	
                  Endif
               Endif	
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Calcula o preco de lista                     ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               nValMerc  := aColsSC6[nX][nPTotal]
               nPrcLista := aColsSC6[nX][nPPrUnit]
               If ( nPrcLista == 0 )
                  nPrcLista := NoRound(nValMerc / aColsSC6[nX][nPQtdVen], TamSX3("C6_PRCVEN")[2])
               EndIf
               nAcresFin := a410Arred(aColsSC6[nX][nPPrcVen] * SC5->C5_ACRSFIN / 100, "D2_PRCVEN")
               nValMerc  += a410Arred(aColsSC6[nX][nPQtdVen] * nAcresFin, "D2_TOTAL")
               nDesconto := a410Arred(nPrcLista * aColsSC6[nX][nPQtdVen], "D2_DESCON") - nValMerc
               nDesconto := IIf(nDesconto == 0, aColsSC6[nX][nPValDesc], nDesconto)
               nDesconto := Max(0, nDesconto)
               nPrcLista += nAcresFin
               nValMerc  += nDesconto

               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Verifica a data de entrega para as duplicatas³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               If ( nPDtEntr > 0 )
                  If ( dDataCnd > aColsSC6[nX][nPDtEntr] .And. !Empty(aColsSC6[nX][nPDtEntr]) )
                     dDataCnd := aColsSC6[nX][nPDtEntr]
                  EndIf
               Else
                  dDataCnd  := SC5->C5_EMISSAO
               EndIf
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Agrega os itens para a funcao fiscal         ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               MaFisAdd(aColsSC6[nX][nPProduto],; // 1-Codigo do Produto ( Obrigatorio )
                        aColsSC6[nX][nPTES]    ,; // 2-Codigo do TES ( Opcional )
                        aColsSC6[nX][nPQtdVen] ,; // 3-Quantidade ( Obrigatorio )
                        nPrcLista           ,; // 4-Preco Unitario ( Obrigatorio )
                        nDesconto           ,; // 5-Valor do Desconto ( Opcional )
                        ""                  ,; // 6-Numero da NF Original ( Devolucao/Benef )
                        ""                  ,; // 7-Serie da NF Original ( Devolucao/Benef )
                        nRecOri             ,; // 8-RecNo da NF Original no arq SD1/SD2
                        0                   ,; // 9-Valor do Frete do Item ( Opcional )
                        0                   ,; // 10-Valor da Despesa do item ( Opcional )
                        0                   ,; // 11-Valor do Seguro do item ( Opcional )
                        0                   ,; // 12-Valor do Frete Autonomo ( Opcional )
                        nValMerc            ,; // 13-Valor da Mercadoria ( Obrigatorio )
                        0                    ) // 14-Valor da Embalagem ( Opiconal )
            EndIf
            SB1->(dbSetOrder(1))
            If SB1->(MsSeek(xFilial("SB1")+aColsSC6[nX][nPProduto]))
               nQtdPeso := aColsSC6[nX][nPQtdVen] * SB1->B1_PESO
            Endif	
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Altera peso para calcular frete              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            MaFisLoad("IT_VALMERC", nValMerc, nItem)
            MaFisAlt("IT_PESO"    , nQtdPeso, nItem)
        Next nX
     EndIf

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Indica os valores do cabecalho               ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     MaFisAlt("NF_FRETE"   , SC5->C5_FRETE)
     MaFisAlt("NF_SEGURO"  , SC5->C5_SEGURO)
     MaFisAlt("NF_AUTONOMO", SC5->C5_FRETAUT)
     MaFisAlt("NF_DESPESA" , SC5->C5_DESPESA)
     If SC5->C5_DESCONT > 0
        MaFisAlt("NF_DESCONTO", Min(MaFisRet(, "NF_VALMERC") - 0.01, SC5->C5_DESCONT + MaFisRet(, "NF_DESCONTO")))
     EndIf
     If SC5->C5_PDESCAB > 0
        MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(, "NF_VALMERC") * SC5->C5_PDESCAB / 100, "C6_VALOR")+MaFisRet(, "NF_DESCONTO"))
     EndIf

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Realiza alteracoes de referencias do SC6         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SC6")
     If Len(aFisGet) > 0
        For nX := 1 to Len(aColsSC6)
            If !aColsSC6[nX][Len(aHeadSC6)+1]
               For nY := 1 to Len(aFisGet)
                   nPosCpo := aScan(aHeadSC6, { |x| AllTrim(x[2]) == Alltrim(aFisGet[ny][2])})
                   If nPosCpo > 0
                      If !Empty(aColsSC6[nX][nPosCpo])
                         MaFisAlt(aFisGet[ny][1], aColsSC6[nX][nPosCpo], nX, .F.)
                      Endif
                   EndIf
               Next nX
            Endif
        Next nY           
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Realiza alteracoes de referencias do SC5         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If Len(aFisGetSC5) > 0	
        DbSelectArea("SC5")
        For nY := 1 to Len(aFisGetSC5)
            If !Empty(&("SC5->"+Alltrim(aFisGetSC5[ny][2])))
               MaFisAlt(aFisGetSC5[ny][1], &("SC5->"+Alltrim(aFisGetSC5[ny][2])), nItem, .F.)
            EndIf
        Next nY
     Endif
     If ExistBlock("M410PLNF")
        ExecBlock("M410PLNF", .F., .F.)
     EndIf
     MaFisWrite(1)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Calcula os venctos conforme a condicao de pagto  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If lDtEmi
        DbSelectarea("SE4")
        DbSetOrder(1)
        MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)
        If !(SE4->E4_TIPO == "9")
           aDupl := Condicao(MaFisRet(, "NF_BASEDUP"), SC5->C5_CONDPAG, MaFisRet(, "NF_VALIPI"), dDataCnd, MaFisRet(, "NF_VALSOL"))
           If Len(aDupl) > 0
              For nX := 1 To Len(aDupl)
                  nAcerto += aDupl[nX][2]
              Next nX
              aDupl[Len(aDupl)][2] += MaFisRet(,"NF_BASEDUP") - nAcerto
              For nX := 1 To Len(aDupl)
                  aDupl[nX][2] := TransForm(aDupl[nX][2], PesqPict("SE1", "E1_VALOR"))
              Next nX
           Endif	
        Else
           aDupl := {{Ctod(""), TransForm(MaFisRet(,"NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
        EndIf
     Else
        For nX := 1 to Len(aColsSC6)
            If Len(aColsSC6[nX]) == nUsdSC6 .Or. !aColsSC6[nX][nUsdSC6+1]
               If nPDtEntr > 0
                  nPosEntr := Ascan(aEntr, {|x| x[1] == aColsSC6[nX][nPDtEntr]})
                  If nPosEntr == 0
                     aAdd(aEntr, {aColsSC6[nX][nPDtEntr], MaFisRet(nX, "IT_BASEDUP"), MaFisRet(nX, "IT_VALIPI"), MaFisRet(nX, "IT_VALSOL")})
                  Else
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_BASEDUP")
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_VALIPI")
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_VALSOL")
                  Endif
               Endif
            Endif
        Next
        DbSelectArea("SE4")
        DbSetOrder(1)
        MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)
        If !(SE4->E4_TIPO == "9")
           For nY := 1 to Len(aEntr)           
               nAcerto := 0
               aDuplTmp := Condicao(aEntr[nY][2], SC5->C5_CONDPAG, aEntr[nY][3], aEntr[nY][1], aEntr[nY][4])
               For nX := 1 To Len(aDuplTmp)
                   nAcerto += aDuplTmp[nX][2]
               Next nX
               aDuplTmp[Len(aDuplTmp)][2] += aEntr[nY][2] - nAcerto
               For nX := 1 To Len(aDuplTmp)
                   aDuplTmp[nX][2] := TransForm(aDuplTmp[nX][2], PesqPict("SE1", "E1_VALOR"))
               Next nX
               aEval(aDuplTmp, {|x| Aadd(aDupl, {aEntr[nY][1], x[1], x[2]})})
           Next
        Else
           aDupl := { {Ctod(""), TransForm(MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
        EndIf
     Endif
     If Len(aDupl) == 0
        aDupl := {{Ctod(""), TransForm(MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
     Endif
     _nNFFRETE := MaFisRet(,"NF_FRETE")  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     _nNFSEGUR := MaFisRet(,"NF_SEGURO")
     _nNFDESCO := MaFisRet(,"NF_DESCONTO")
     _nNFAUTON := MaFisRet(,"NF_AUTONOMO")
     _nNFDESPE := MaFisRet(,"NF_DESPESA")
     _nNFBASED := MaFisRet(,"NF_BASEDUP")
     _nNFTOTAL := MaFisRet(,"NF_TOTAL")
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Monta a tela de exibicao dos valores fiscais ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     /*DEFINE MSDIALOG oDlg TITLE OemToAnsi("Planilha Financeira") FROM 09, 00 TO 28, 80
            oFolder := TFolder():New(001, 001, aTitles, {"HEADER"}, oDlg, , , , .T., .F., 315, 140)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Folder 1                                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            MaFisRodape(1, oFolder:aDialogs[1], , {005, 001, 310, 60}, Nil, .T.)
            @ 070, 005 SAY RetTitle("F2_FRETE")       SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 070, 105 SAY RetTitle("F2_SEGURO")      SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 070, 205 SAY RetTitle("F2_DESCONT")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 005 SAY RetTitle("F2_FRETAUT")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 105 SAY RetTitle("F2_DESPESA")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 205 SAY RetTitle("F2_VALFAT")      SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Troquei as chamadas de função para variável pois não será suportado em versões futuras.
            //@ 070, 050 MSGET MaFisRet(,"NF_FRETE")    PICTURE PesqPict("SF2", "F2_FRETE"   , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 050 MSGET _nNFFRETE                PICTURE PesqPict("SF2", "F2_FRETE"   , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 070, 150 MSGET MaFisRet(,"NF_SEGURO")   PICTURE PesqPict("SF2", "F2_SEGURO"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 150 MSGET _nNFSEGUR                PICTURE PesqPict("SF2", "F2_SEGURO"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 070, 250 MSGET MaFisRet(,"NF_DESCONTO") PICTURE PesqPict("SF2", "F2_DESCONTO", 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 250 MSGET _nNFDESCO                PICTURE PesqPict("SF2", "F2_DESCONTO", 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 050 MSGET MaFisRet(,"NF_AUTONOMO") PICTURE PesqPict("SF2", "F2_FRETAUT" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 050 MSGET _nNFAUTON                PICTURE PesqPict("SF2", "F2_FRETAUT" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 150 MSGET MaFisRet(,"NF_DESPESA")  PICTURE PesqPict("SF2", "F2_DESPESA" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 150 MSGET _nNFDESPE                PICTURE PesqPict("SF2", "F2_DESPESA" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 250 MSGET MaFisRet(,"NF_BASEDUP")  PICTURE PesqPict("SF2", "F2_VALFAT"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 250 MSGET _nNFBASED                PICTURE PesqPict("SF2", "F2_VALFAT"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            @ 105, 005 TO 106, 310 PIXEL OF oFolder:aDialogs[1]
            @ 110, 005 SAY OemToAnsi("Total da Nota") SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            //@ 110, 050 MSGET MaFisRet(,"NF_TOTAL")    PICTURE PesqPict("SF2","F2_VALBRUT",16,2)     SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 110, 050 MSGET   _nNFTOTAL              PICTURE PesqPict("SF2","F2_VALBRUT",16,2)     SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            @ 110, 270 BUTTON OemToAnsi("Sair")       SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[1] PIXEL
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Folder 2                                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lDtEmi
               @ 005, 001 LISTBOX oDupl FIELDS TITLE aFlHead[1], aFlHead[2]             SIZE 310, 095 OF oFolder:aDialogs[2] PIXEL
            Else	
               @ 005, 001 LISTBOX oDupl FIELDS TITLE aFlHead[3], aFlHead[1], aFlHead[2] SIZE 310, 095 OF oFolder:aDialogs[2] PIXEL
            Endif
            oDupl:SetArray(aDupl)
            oDupl:bLine := {|| aDupl[oDupl:nAt] }
            @ 105, 005 TO 106, 310 PIXEL OF oFolder:aDialogs[2]
            If cPaisLoc == "BRA"
               @ 110, 005 SAY RetTitle("F2_VALFAT") SIZE 40, 10 PIXEL OF oFolder:aDialogs[2]
            Else
               @ 110, 005 SAY OemToAnsi('STR0051')    SIZE 40, 10 PIXEL OF oFolder:aDialogs[2]
            Endif	
            //@ 110, 050 MSGET MaFisRet(,"NF_BASEDUP")  PICTURE PesqPict("SF2", "F2_VALFAT", 16, 2)   SIZE 50, 07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
              @ 110, 050 MSGET _nNFBASED                PICTURE PesqPict("SF2", "F2_VALFAT", 16, 2)   SIZE 50, 07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
            @ 110, 270 BUTTON OemToAnsi("Sair")       SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[2] PIXEL

     //ACTIVATE MSDIALOG oDlg CENTERED*/
     MaFisEnd()
     MaFisRestore()

     DbSelectArea( _cAliasSX3 )
     DbCloseArea()

     RestArea(aAreaSA1)
     RestArea(aArea)
Return(.T.)


Static Function MHeaderSC6()
       Local aHeaderSC6 := {}
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       MsSeek("SC6")
       While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
             If ( X3USO(SX3->X3_USADO) .And. !(	Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And. Trim(SX3->X3_CAMPO) <> "C6_QTDEMP" .And. Trim(SX3->X3_CAMPO) <> "C6_QTDENT" .And. cNivel >= SX3->X3_NIVEL )
                aAdd(aHeaderSC6, { TRIM(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
             EndIf
             DbSelectArea("SX3")
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( MsSeek("SC6") )
       While ( !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC6") )
             If ( X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. !( Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_NUM" ) .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) <> "C6_QTDEMP" .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) <> "C6_QTDENT" .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) )
                aAdd( aHeaderSC6, { TRIM(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             DbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( DbSkip() )
       EndDo
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
       /********************************************************************************************************************************/
Return( aHeaderSC6 )

Static Function MonAcolSC6(aHeadSC6)
       Local aColsSC6 := {}
       Local nCntFor
       Private AHEADGRADE := {}
       Private ACOLSGRADE := {}
       DbSelectArea("SC6")
       DbSetOrder(1)
       MsSeek(xFilial("SC6")+SC5->C5_NUM)
       While ( !Eof() .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM )
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica se este item foi digitada atraves de uma    ³
             //³ grade, se for junta todos os itens da grade em uma   ³
             //³ referencia , abrindo os itens so quando teclar enter ³
             //³ na quantidade                                        ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If ( SC6->C6_GRADE == "S" .And. lGrade )
                //a410Grade(.F., , cArqQry)
             Else
                aAdd(aColsSC6, Array(Len(aHeadSC6)+1))
                For nCntFor:=1 To Len(aHeadSC6)
                    If ( aHeadSC6[nCntFor,10] <>  "V" )
                       aCOLSSC6[Len(aColsSC6)][nCntFor] := FieldGet(FieldPos(aHeadSC6[nCntFor,2]))
                    Else			
                       aCOLSSC6[Len(aColsSC6)][nCntFor] := CriaVar(aHeadSC6[nCntFor,2])
                    EndIf
                Next nCntFor
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Mesmo nao sendo um item digitado atraves de grade e' necessa-³
                //³ rio criar o Array referente a este item para controle da     ³
                //³ grade                                                        ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                MatGrdMont(Len(aColsSC6))
             EndIf
             aColsSC6[Len(aColsSC6)][Len(aHeadSC6)+1] := .F.	
             DbSelectArea("SC6")
             DbSkip()
       EndDo
Return(aColsSC6)
   

