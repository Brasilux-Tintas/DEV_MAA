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
 
User Function ZFATC07()

Private oTempTable

//Objetos e componentes
Private oPanGrid
Private oDlgg

Private _nNFTOTAL

//Cabeçalho

Private oEmisP1 , nEmisP1  := MonthSub(dDataBase,2) //cTod("  /  /  ") 
Private oEmisP2 , nEmisP2  := dDataBase //cTod("  /  /  ")

Private oEmisF1 , nEmisF1  := cTod("  /  /  ") 
Private oEmisF2 , nEmisF2  := cTod("  /  /  ")

Private oTransp1 , nTransp1  := "" 
Private oTransp2 , nTransp2  := ""

Private oGetPed1 , nGetPed1  := SPACE(6) 
Private oGetPed2 , nGetPed2  := SPACE(6)

Private oNota1 , nNota1  := SPACE(6) 
Private oNota2 , nNota2  := SPACE(6)

Private oUF,nUF


//Tamanho da janela
Private nJanLarg  := 1480
Private nJanAltu  := 650

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
Private aUF := {'MT','AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MG','MS','PA','PB','PE','PI','PR','RJ','RN','RO','RR','RS','SC','SE','SP','TO'}
CriaTab()  


//Popula a tabela temporária
cSayTot := "0" //Transform(fPopula(), "@E 999,999.9999")

// Planilha Financeira
//MsAguarde({|| RET_ICMS() },"Buscando informações do Pedido","Aguarde...")

  
//Cria a janela
DEFINE MSDIALOG oDlgg TITLE "Consultar Frete CIF"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL

    // Say  Top  Left
    @ 015, 008 SAY OemToAnsi("Emissão Pedido: ") SIZE 080,009 PIXEL OF oDlgg FONT oFontBtn
    oEmisP1  := TGet():New(013, 080, {|u| If(PCount() > 0, nEmisP1 := u, nEmisP1)}, oDlgg, 045, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nEmisP1", , )
    
    @ 015, 140 SAY OemToAnsi("Até ") SIZE 060,009 PIXEL OF oDlgg FONT oFontBtn
    oEmisP2  := TGet():New(013, 155, {|u| If(PCount() > 0, nEmisP2 := u, nEmisP2)}, oDlgg, 045, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nEmisP2", , )

     // Say  Top  Left
    @ 040, 008 SAY OemToAnsi("Emissão Faturamento: ") SIZE 080,009 PIXEL OF oDlgg FONT oFontBtn
    oEmisF1  := TGet():New(038, 080, {|u| If(PCount() > 0, nEmisF1 := u, nEmisF1)}, oDlgg, 045, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nEmisF1", , )
    
    @ 040, 140 SAY OemToAnsi("Até ") SIZE 060,009 PIXEL OF oDlgg FONT oFontBtn
    oEmisF2  := TGet():New(038, 155, {|u| If(PCount() > 0, nEmisF2 := u, nEmisF2)}, oDlgg, 045, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nEmisF2", , )
        
    
     // Say  Top  Left
    @ 015, 210 SAY OemToAnsi("Pedido : ") SIZE 080,009 PIXEL OF oDlgg FONT oFontBtn
    oGetPed1  := TGet():New(013, 250, {|u| If(PCount() > 0, nGetPed1 := u, nGetPed1)}, oDlgg, 035, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nGetPed1", , )
    
    @ 015, 295 SAY OemToAnsi("Até ") SIZE 060,009 PIXEL OF oDlgg FONT oFontBtn
    oGetPed2  := TGet():New(013, 320, {|u| If(PCount() > 0, nGetPed2 := u, nGetPed2)}, oDlgg, 035, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nGetPed2", , )

     // Say  Top  Left
    @ 040, 210 SAY OemToAnsi("Nota Fiscal : ") SIZE 080,009 PIXEL OF oDlgg FONT oFontBtn
    oNota1  := TGet():New(038, 250, {|u| If(PCount() > 0, nNota1 := u, nNota1)}, oDlgg, 035, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nNota1", , )
    
    @ 040, 295 SAY OemToAnsi("Até ") SIZE 060,009 PIXEL OF oDlgg FONT oFontBtn
    oNota2  := TGet():New(038, 320, {|u| If(PCount() > 0, nNota2 := u, nNota2)}, oDlgg, 035, 010, '@E 999999', , CLR_BLACK, CLR_WHITE, oFontSay, , , .T., "", , , .F., .F., , , .F., "", "nNota2", , )

    @ 015, 380 SAY OemToAnsi("Estado ") SIZE 060,009 PIXEL OF oDlgg FONT oFontBtn
    oUF   := TComboBox():New( 014, 420, {|u| If(PCount()>0,nUF:=u,nUF)},aUF, 035, 011,oDlgg,,,,CLR_BLACK,CLR_WHITE,.T.,oFontSay,"",,,,,,,nUF )

    
    oBtnFrete := TButton():New(013, 500 , "Pesquisar",      oDlgg, {|| MsAguarde({|| fPopula() },"Buscando Pedidos..","Aguarde...")}, 70, 040, , oFontBtn, , .T., , , , , , )
    //MsAguarde({|| RET_ICMS() },"Buscando informações do Pedido","Aguarde...")
    oBtnFrete := TButton():New(013, 580 , "Gerar Planilha", oDlgg, {|| Exportar()}, 70, 040, , oFontBtn, , .T., , , , , , )
    oBtnSair  := TButton():New(013, 660 , "Fechar",         oDlgg, {|| Sair()}   , 70, 040, , oFontBtn, , .T., , , , , , )      

    
    //                         Top Lef  Bot  Rig   
    oGrpPrE    := TGroup():New(02 ,02  ,060 ,740,'Dados Pedido',oDlgg,CLR_BLACK,CLR_GRAY,.T.)
    
        
    
  
    //Cria a grid            Top  Left                                                    Rigth bottom 
    oPanGrid := tPanel():New(062, 002, "", oDlgg, , , , RGB(000,000,000), RGB(254,254,254), 740,  262)
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
   
    //oGrpPrD  := TGroup() :New(290 ,002  ,322 ,702,"Total do Pedido ",oDlgg,CLR_BLACK,CLR_GRAY,.T.)
    //oSayTot  := TSay()   :New(303, 010, {|| "R$:"+AllTrim(transform(_nNFTOTAL,"@E 9,999,999.9999"))}, oDlgg,"", oFontBtn, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
    
    
    
   
    
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
    aAdd(aEstrut, {"CODIGO"     , "Código"           ,   "C", TamSX3('A1_COD') [01]     , 0,   ""})
    aAdd(aEstrut, {"CLIENTE"    , "Cliente"          ,   "C", 30 , 0,   ""})
    aAdd(aEstrut, {"CIDADE"     , "Cidade"           ,   "C", 35  , 0,   ""})
    aAdd(aEstrut, {"NOTA"       , "Nota"             ,   "C", TamSX3('F2_DOC') [01]      , 0,   ""})
    aAdd(aEstrut, {"PEDIDO"     , "Pedido"           ,   "C", TamSX3('C5_NUM') [01]      , 0,   ""})
    aAdd(aEstrut, {"EMISSAOP"   , "Emissão Ped."     ,   "D", TamSX3('C5_EMISSAO') [01]  , 0,   ""})
    aAdd(aEstrut, {"VALOR"      , "Vlr Nota"         ,   "N", 14, 4, "@E 9,999,999.99", .T.}    )
    aAdd(aEstrut, {"PBRUTO"     , "Peso Bruto"       ,   "N", 14, 4, "@E 9,999,999.99", .T.}    )
    aAdd(aEstrut, {"TRANSP"     , "Transportadora"   ,   "C", 20  , 0,   ""})   
    aAdd(aEstrut, {"FRETEN"     , "Frete Negociado"  ,   "N", 14, 4, "@E 9,999,999.99", .T.}    )

    aAdd(aEstrut, {"PRCTONE"    , "% Tonelada"       ,   "N", 14, 4, "@E 9,999,999.99", .T.}    )
    aAdd(aEstrut, {"PROCNOTA"   , "% Nota"           ,   "C", 5  , 0,   ""})
    aAdd(aEstrut, {"FINALIZADO" , "Finalizado"       ,   "C", 10  , 0,   ""}) 

    aAdd(aEstrut, {"CTE"        , "CT-e"             ,   "C", 3   , 0,   ""}) 
    aAdd(aEstrut, {"CTEVLR"     , "Ct-e Valor"       ,   "N", 14, 4, "@E 9,999,999.99", .T.}    ) 
    aAdd(aEstrut, {"DIF"        , "Diferença"        ,   "N", 14, 4, "@E 9,999,999.99", .T.}    )     
    aAdd(aEstrut, {"STATUS"     , "Status"           ,   "C", 4   , 0,   ""}) 
  
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
Local nGetPercent
Local nGetFret
Local PrcPeso
Local nGetPrcTone
Local Status,LimtSup,LimtInf,Saldo


    cQuery1 := " SELECT * FROM SC5010 SC5 "
    cQuery1 += " INNER JOIN SA1010 SA1 ON A1_COD = C5_CLIENTE AND SA1.D_E_L_E_T_ = ''  "
    cQuery1 += " LEFT JOIN SF2010 SF2 ON F2_DOC = C5_NOTA AND F2_SERIE = C5_SERIE  AND SF2.D_E_L_E_T_ = '' AND F2_FILIAL = C5_FILIAL  "
    cQuery1 += " LEFT JOIN SA4010 SA4 ON A4_COD = C5_REDESP AND SA4.D_E_L_E_T_ = '' "
    cQuery1 += " LEFT JOIN ZA9010 ZA9 ON ZA9.D_E_L_E_T_ = '' AND  ZA9_CHVSF2 = F2_CHVNFE "
    cQuery1 += " WHERE C5_FILIAL = '010101' AND SC5.D_E_L_E_T_ = '' AND A1_EST = '"+nUF+"'  "
    
    If (nEmisP1 <> cTod("  /  /  ") .AND. nEmisP2 <> cTod("  /  /  ") )
        cQuery1 += " AND C5_EMISSAO >= '"+dTos(nEmisP1)+"' AND C5_EMISSAO <= '"+dTos(nEmisP2)+"' "
    EndIf

    If (!Empty(dToS(nEmisF1)) .AND. !Empty(dToS(nEmisF2)) )
        cQuery1 += " AND F2_EMISSAO >= '"+dTos(nEmisF1)+"' AND F2_EMISSAO <= '"+dTos(nEmisF2)+"' "
    EndIf

    If ( !Empty(nGetPed1) .AND. !Empty(nGetPed2) )
        cQuery1 += " AND C5_NUM >= '"+nGetPed1+"' AND C5_NUM <= '"+nGetPed2+"' "
    EndIf

    If ( !Empty(nNota1) .AND. !Empty(nNota2) )
        cQuery1 += " AND F2_DOC >= '"+dTos(nNota1)+"' AND F2_DOC <= '"+dTos(nNota2)+"' "
    EndIf
    
    
    cQuery1 += " AND C5_TPFRETE = 'C'  "
    cQuery1 += " Order By C5_EMISSAO  "

    /* verifica se arquivo está aberto e finaliza */
    IF Select("TMP") <> 0
        DbSelectArea("TMP")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery1 NEW ALIAS "TMP"  

     oTempTable:Delete()
     CriaTab()  

    While TMP->(!EOF()) 
        
        If !Empty(TMP->F2_DOC) 
            _nNFTOTAL := TMP->F2_VALBRUT
        else
            _nNFTOTAL := 0
            //If TMP->C5_XVLRFRE > 0
                DbSelectArea("SC5")
                DbSetOrder(1)
                DbSeek(xFilial("SC5")+TMP->C5_NUM, .t.)
                RET_ICMS()
            //else
                //_nNFTOTAL := 0
            //EndIf    
        Endif      
        
        
        nGetFret  := TMP->C5_XVLRFRE
        nGetPeso  := TMP->C5_PBRUTO

        nGetPercent := Transform(((nGetFret/_nNFTOTAL)*100), "@E 99.99") //% Pela Nota
        PrcPeso     := (nGetFret/nGetPeso)
        PrcPeso     := (PrcPeso * 1000)
        nGetPrcTone := PrcPeso // Preço Por Tonelada

        //Grava na temporária
        RecLock(cAliasTmp, .T.)
            (cAliasTmp)->CODIGO      := TMP->C5_CLIENTE
            (cAliasTmp)->CLIENTE     := TMP->A1_NOME
            (cAliasTmp)->CIDADE      := TMP->A1_MUN
            (cAliasTmp)->NOTA        := TMP->F2_DOC
            (cAliasTmp)->PEDIDO      := TMP->C5_NUM
            (cAliasTmp)->EMISSAOP    := sTod(TMP->C5_EMISSAO)
            (cAliasTmp)->VALOR       := _nNFTOTAL
            (cAliasTmp)->PBRUTO      := TMP->C5_PBRUTO
            (cAliasTmp)->TRANSP      := TMP->A4_NREDUZ
            (cAliasTmp)->FRETEN      := TMP->C5_XVLRFRE
            (cAliasTmp)->PRCTONE     := nGetPrcTone
            (cAliasTmp)->PROCNOTA    := Transform((nGetPercent), "@E 99.99")

            (cAliasTmp)->CTE         := IIf(TMP->ZA9_VALMER > 0,"Sim","Nao")   
            (cAliasTmp)->CTEVLR      := IIf(TMP->ZA9_VALMER > 0,TMP->ZA9_VALMER,0)   
            
            // calculo é feito apenas quando tem frete informado
            If TMP->C5_XVLRFRE > 0
               (cAliasTmp)->DIF         := IIf(TMP->ZA9_VALMER > 0,TMP->C5_XVLRFRE-TMP->ZA9_VALMER,0)
               Saldo := TMP->C5_XVLRFRE-TMP->ZA9_VALMER
               
               LimtInf := TMP->C5_XVLRFRE - (TMP->C5_XVLRFRE * (GETMV("ZP_PAR0099") / 100))
               LimtSup := TMP->C5_XVLRFRE + (TMP->C5_XVLRFRE * (GETMV("ZP_PAR0099") / 100))

               If (TMP->ZA9_VALMER > LimtSup) .OR. (TMP->ZA9_VALMER < LimtInf)
                  Status := "Erro"
               else
                  Status := "Ok"   
               Endif

            else
               (cAliasTmp)->DIF         := 0
               Status := ""
            Endif   
            
            If (AllTrim(TMP->A4_COD) $ "00933-00692-02643") 
                (cAliasTmp)->FINALIZADO  :="MATAO"
            elseif (AllTrim(TMP->A4_COD) $ "00959")
                (cAliasTmp)->FINALIZADO  :="OK"    
            else
                 (cAliasTmp)->FINALIZADO  :="MATAO"
            EndIf

            
            (cAliasTmp)->STATUS         := Status
                    

        (cAliasTmp)->(MsUnlock())
     
        TMP->(DBSKIP())
    Enddo 

     oGetGrid:Activate()
    

Return(nTotal)


// funcao para gravar valor do frete
Static Function GrvFrete()
Local PrcPeso    
    
   nGetPercent := Transform(((nGetFret/_nNFTOTAL)*100), "@E 99.99")

   PrcPeso     := (nGetFret/nGetPeso)
   PrcPeso     := (PrcPeso * 1000)
   nGetPrcTone := PrcPeso


   If (SC5->C5_XVLRFRE <> nGetFret)    

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

Static Function Exportar()
Local cArquivo    := GetTempPath()+'FreteCIF.xml'

//Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMsExcelEx():New()
     
    //Aba 
    oFWMsExcel:AddworkSheet("CIF")
        //Criando a Tabela
    oFWMsExcel:AddTable("CIF","CIF")
    oFWMsExcel:AddColumn("CIF","CIF","Cod.Cliente",1)
    oFWMsExcel:AddColumn("CIF","CIF","Cliente",1)
    oFWMsExcel:AddColumn("CIF","CIF","Cidade",1)
    oFWMsExcel:AddColumn("CIF","CIF","Nº Nota Fiscal",1)
    oFWMsExcel:AddColumn("CIF","CIF","Vlr Nota",1)
    
    oFWMsExcel:AddColumn("CIF","CIF","Nº Pedido",1)
    oFWMsExcel:AddColumn("CIF","CIF","Emissao Pedido",1)
    
    
    oFWMsExcel:AddColumn("CIF","CIF","Peso Bruto",1)
    oFWMsExcel:AddColumn("CIF","CIF","Transportadora",1)
    oFWMsExcel:AddColumn("CIF","CIF","Frete Negociado",1)
    oFWMsExcel:AddColumn("CIF","CIF","Preço Por Tonelada",1)
    oFWMsExcel:AddColumn("CIF","CIF","% Pela Nota",1)
    oFWMsExcel:AddColumn("CIF","CIF","Finalizado",1)

    oFWMsExcel:AddColumn("CIF","CIF","CT-e",1)
    oFWMsExcel:AddColumn("CIF","CIF","Vlr Ct-e",1)
    oFWMsExcel:AddColumn("CIF","CIF","Diferença",1)
    oFWMsExcel:AddColumn("CIF","CIF","Status",1)
    
    dbSelectArea(cAliasTmp)
    (cAliasTmp)->(dbGoTop())

    While !(cAliasTmp)->(eof())

       
        oFWMsExcel:AddRow("CIF","CIF",{;
                        (cAliasTmp)->CODIGO,;
                        (cAliasTmp)->CLIENTE,;
                        (cAliasTmp)->CIDADE,;
                        (cAliasTmp)->NOTA,;
                        (cAliasTmp)->VALOR,;
                        (cAliasTmp)->PEDIDO,;
                        (cAliasTmp)->EMISSAOP,;
                        (cAliasTmp)->PBRUTO,;
                        (cAliasTmp)->TRANSP,;
                        (cAliasTmp)->FRETEN,;
                        (cAliasTmp)->PRCTONE,;
                        (cAliasTmp)->PROCNOTA,;
                        (cAliasTmp)->FINALIZADO,;
                        (cAliasTmp)->CTE,;
                        (cAliasTmp)->CTEVLR,;
                        (cAliasTmp)->DIF,;
                        (cAliasTmp)->STATUS;
                                            })

 //Alterando atributos da linha e adicionando
         oFWMsExcel:SetCelBold(.T.)
         oFWMsExcel:SetCelFont('Line Draw')
         oFWMsExcel:SetCelItalic(.F.)
         oFWMsExcel:SetCelUnderLine(.F.)
         oFWMsExcel:SetCelSizeFont(12)
         oFWMsExcel:SetCelFrColor("#FFFFFF")
         oFWMsExcel:SetCelBgColor("#D7BCFB")                                             
        (cAliasTmp)->(dbSkip())
    EndDo                                        
    
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    MsgRun("Processando...","Aguarde...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
    
        
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

return()

Static Function CriaTab()

aCampos := {}
//Campos da Temporária
aAdd(aCampos, { "CODIGO"    , "C", TamSX3("A1_COD")   [1], 0 })
aAdd(aCampos, { "CLIENTE"   , "C", 30, 0 })
aAdd(aCampos, { "CIDADE"    , "C", 35, 0 })
aAdd(aCampos, { "NOTA"      , "C", TamSX3("F2_DOC")   [1], 0 })
aAdd(aCampos, { "PEDIDO"    , "C", TamSX3("C5_NUM")   [1], 0 })
aAdd(aCampos, { "EMISSAOP"  , "D", TamSX3("C5_EMISSAO")[1], 0 })
aAdd(aCampos, { "VALOR"     , "N", 14, 4, "@E 9,999,999.99"   })
aAdd(aCampos, { "PBRUTO"    , "N", 14, 4, "@E 9,999,999.99"   })
aAdd(aCampos, { "TRANSP"    , "C", 20, 0 })
aAdd(aCampos, { "FRETEN"    , "N", 14, 4, "@E 9,999,999.99"   })
aAdd(aCampos, { "PRCTONE"   , "N", 14, 4, "@E 9,999,999.99"   })
aAdd(aCampos, { "PROCNOTA"  , "C", 5, 0 })
aAdd(aCampos, { "FINALIZADO", "C", 10, 0 })

aAdd(aCampos, { "CTE"    , "C", 10, 0 })
aAdd(aCampos, { "CTEVLR" , "N", 14, 4, "@E 9,999,999.99"   })
aAdd(aCampos, { "DIF"    , "N", 14, 4, "@E 9,999,999.99"   })
aAdd(aCampos, { "STATUS" , "C", 4, 0 })

//Cria a tabela temporária
oTempTable:= FWTemporaryTable():New(cAliasTmp)
oTempTable:SetFields( aCampos )
oTempTable:Create()

//Busca as colunas do browse
aColunas := fCriaCols()

return()

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
                       //aCOLSSC6[Len(aColsSC6)][nCntFor] := CriaVar(aHeadSC6[nCntFor,2])
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


