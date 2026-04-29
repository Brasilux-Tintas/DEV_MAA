#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ZFATP01  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 15/05/23  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Divide Pedido                                              ³±±
±±³		     ³ Subistitui rotina DividePed                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
 
User Function ZFATP01(cPedido)
 Local nLargBtn      := 50 // Largura botões
 
 // criado em 25/09/23 chamado R2603
 Private _ZPPAR0208 := GetMV( "ZP_PAR0208" ) // Efetua liberacoes em pedido destino na rotina de divisao dos pedidos
 Private _ZPPAR0209 := GetMV( "ZP_PAR0209" ) // Habilita Bloqueio de divisao do pedido de vendas quando ocorreu a separacao na expedicao
  
 Private _ZPPAR0210 := GetMV( "ZP_PAR0210" ) // Lista de e-mails para expedicao em pedidos dividos
//Private _ZPPAR0210 := 'joseuliana@brasilux.com.br' ///  depois que testar voltar o de cima Jose 22/05/2024

 Private xTexto     := ""   
 Private cUsuario   := PswChave(RetCodUsr())
 
 
 Private cRazao
 Private aLiberacoes := {}
 Private _cFilial   := Alltrim( FWCodFil( ) )
 
 Private _Bipado := .F. // variavel que informa se o pedido tem produto bipado

 Private aBrowser := {}
 //Tamanho da janela Automatico
 Private aSize := MsAdvSize(.F.)
 Private nJanLarg := ( aSize[5] - (aSize[5] * 0.05) ) // reduz 5% da tela altura
 Private nJanAltu := ( aSize[6] - (aSize[6] * 0.10) ) // reduz 10% da tela altura

 //Fontes
 Private cFontUti    := "Tahoma"
 Private oFontMod    := TFont():New(cFontUti, , -38)
 Private oFontSub    := TFont():New(cFontUti, , -20)
 Private oFontSubN   := TFont():New(cFontUti, ,  18)
 Private oFontBtn    := TFont():New(cFontUti, , -14)
 Private oFontSay    := TFont():New(cFontUti, , -12)

 Public _aDicvide2  := 0  // Jose 22/05/2024
 
 

    // valida existencia do pedido
    DbSelectArea("SC5")
    DbSetOrder(1)
    If !DbSeek(xFilial("SC5")+cPedido, .F.)
        FWAlertInfo("Não encontrado o pedido origem nro: "+cPedido, "Atenção!")
        return(.F.)
    EndIf

    /*If !Empty( SC5->C5_TABELA ) //LGS#20220308 - Não de deixar pedidos de campanha serem divididos. Indicativo que é pedido de campanha é a tabela de preços.
        FWAlertInfo("Atenção! Pedido de Campanha! NÃO PODE SER DIVIDIDO! ", "Atenção!")
        Return(.F.)
    Endif*/

    If !Empty(SC5->C5_NOTA) 
        FWAlertInfo("Divisão liberada apenas para pedidos em aberto ! ", "Atenção!")
        Return(.F.)
    Endif

    // Identifica nome do cliente (Cliente ou Fornecedor)
    IF SC5->C5_TIPO = "N"
        cRazao := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,"A1_NOME")
    ELSE
        cRazao := Posicione("SA2",1,xFilial("SA2")+SC5->C5_CLIENTE,"A2_NOME")
    ENDIF 


 

//Alimenta o array com os itens do pedido
If !BUSPEDIDOS(cPedido)
 return()
EndIf 
 
DEFINE MsDIALOG oDlg TITLE 'Divisão de Pedido' From 0, 4 To  nJanAltu, nJanLarg  Pixel
     
    @ 003,005 SAY OemToAnsi("Nº Pedido : "+SC5->C5_NUM)  SIZE 120,09 Font oFontSubN   PIXEL OF oDlg
    @ 003,080 SAY OemToAnsi("Emissao : "+DtoC(SC5->C5_EMISSAO))  SIZE 080,09 Font oFontSubN   PIXEL OF oDlg
    @ 016,005 SAY OemToAnsi("Cliente : "+SC5->C5_CLIENTE+' - '+cRazao)  SIZE 220,09 Font oFontSubN  PIXEL OF oDlg
    
    //Criando os botões
    oBtnSair := TButton():New(006, (nJanLarg/2-001)-((nLargBtn+2)*1), "Fechar",     oDlg, {|| oDlg:End()},       nLargBtn, 018, , oFontBtn, , .T., , , , , , )
    oBtnDivd := TButton():New(006, (nJanLarg/2-001)-((nLargBtn+2)*2), "Dividir 2",  oDlg, {|| Divide2(oBrowser,aBrowser,cPedido)},  nLargBtn, 018, , oFontBtn, , .T., , , , , , )
    oBtnDivd := TButton():New(006, (nJanLarg/2-001)-((nLargBtn+2)*3), "Dividir",    oDlg, {|| FWMsgRun(Nil, {|| Processa(cPedido) }, "Divisão de Pedido", "Processando, Aguarde...")},  nLargBtn, 018, , oFontBtn, , .T., , , , , , )

    oPnMaster := tPanel():New(030, 001, "", oDlg, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, (( nJanAltu - (nJanAltu * 0.15) )/2)-3)
 
  
    oBrowser := fwBrowse():New()
    oBrowser:setOwner( oPnMaster )
    oBrowser:setDataArray()
    oBrowser:setArray( aBrowser )
    oBrowser:SetLocate() // Habilita a Localização de registros
    oBrowser:disableConfig()
    oBrowser:disableReport()
    oBrowser:SetFontBrowse(oFontSubN)


    oBrowser:AddMarkColumns({|| IIf(aBrowser[oBrowser:nAt,01], "LBOK", "LBNO")},; //Code-Block image
        {|| SelectOne(oBrowser, aBrowser)},; //Code-Block Double Click
        {|| SelectAll(oBrowser, 01, aBrowser) }) //Code-Block Header Click

    oBrowser:addColumn({"Item"        , {||aBrowser[oBrowser:nAt,02]}, "C", pesqPict("SC6","C6_ITEM")     , 1, tamSx3("C6_ITEM")[1]    ,tamSx3("C6_ITEM")[1]    , .T. , , .F.,, "aBrowser[oBrowser:nAt,02]",, .F., .T.,, "ETDESPES1"})
    oBrowser:addColumn({"Codigo"      , {||aBrowser[oBrowser:nAt,03]}, "C", pesqPict("SC6","C6_PRODUTO")  , 1, 12                      ,12                      , .T. , , .F.,, "aBrowser[oBrowser:nAt,03]",, .F., .T.,, "ETDESPES2"})
    oBrowser:addColumn({"Produto"     , {||aBrowser[oBrowser:nAt,04]}, "C", pesqPict("SC6","C6_DESCRI")   , 1, tamSx3("C6_DESCRI")[1]  ,tamSx3("C6_DESCRI")[1]  , .T. , , .F.,, "aBrowser[oBrowser:nAt,04]",, .F., .T.,, "ETDESPES3"})
    oBrowser:addColumn({"Qtd Alterar" , {||aBrowser[oBrowser:nAt,05]}, "N", pesqPict("SC6","C6_QTDVEN")   , 2, tamSx3("C6_QTDVEN")[1]  ,tamSx3("C6_QTDVEN")[1]  , .T. , , .F.,, "aBrowser[oBrowser:nAt,05]",, .F., .T.,, "ETDESPES5"})
    oBrowser:addColumn({"Disponivel"  , {||aBrowser[oBrowser:nAt,12]}, "N", pesqPict("SC6","C6_QTDVEN")   , 2, tamSx3("C6_QTDVEN")[1]  ,tamSx3("C6_QTDVEN")[1]  , .T. , , .F.,, "aBrowser[oBrowser:nAt,05]",, .F., .T.,, "ETDESPES5"})
    oBrowser:addColumn({"Qtd Original", {||aBrowser[oBrowser:nAt,06]}, "N", pesqPict("SC6","C6_QTDVEN")   , 2, tamSx3("C6_QTDVEN")[1]  ,tamSx3("C6_QTDVEN")[1]  , .T. , , .F.,, "aBrowser[oBrowser:nAt,05]",, .F., .T.,, "ETDESPES5"})
    

    oBrowser:SetEditCell( .T. )
    
    oBrowser:acolumns[2]:ledit     := .F.
    oBrowser:acolumns[3]:ledit     := .F.
    oBrowser:acolumns[4]:ledit     := .F.
    oBrowser:acolumns[6]:ledit     := .F.    
    oBrowser:acolumns[7]:ledit     := .F.
    
    oBrowser:acolumns[5]:ledit     := .T.
    oBrowser:acolumns[5]:cReadVar:= 'aBrowser[oBrowser:nAt,05]'
    oBrowser:bValidEdit  := {|| Valid() }
    oBrowser:Activate(.T.)
 
Activate MsDialog oDlg
 
return()
 
 
/*/
    Função de selecionar um item no Browser
/*/
Static Function SelectOne(oBrowse, aArquivo)
    aArquivo[oBrowser:nAt,1] := !aArquivo[oBrowser:nAt,1]
Return .T.
 
 
/*/
    Função de inverter seleção total
/*/ 
Static Function SelectAll(oBrowse, nCol, aArquivo)

Local _ni := 1
For _ni := 1 to len(aArquivo)
    If aArquivo[_ni,1]
        aArquivo[_ni,1] := .F.    
    else
        aArquivo[_ni,1] := .T.
    Endif    
Next
oBrowse:Refresh()

Return .T.
 
 

 
 
 
//Alimenta a tabela temporaria
Static Function BUSPEDIDOS(cPedido)
Local cQuery    as Character
Local TMPSC6    as Character
Local cDispo
 
cQuery   := ""
TMPSC6   := GetNextAlias()
aBrowser := {}
 
cQuery   := " SELECT  C6_ITEM,C6_PRODUTO,C6_DESCRI,C6_QTDVEN,C6_PRCVEN,C6_PRUNIT,C6_VALOR,C6_LOCAL,C6_TES,"
cQuery   += " QTDLIB = ISNULL((SELECT C9_QTDLIB FROM "+RetSqlName("SC9")+" WHERE (D_E_L_E_T_ <> '*') AND (C9_FILIAL = SC6.C6_FILIAL) AND "
cQuery   += " (C9_PEDIDO = SC6.C6_NUM) AND (C9_ITEM = SC6.C6_ITEM) AND (C9_PRODUTO = SC6.C6_PRODUTO) AND (C9_BLOQUEI = '') AND "
cQuery   += " (C9_BLCRED = '') AND (C9_BLEST = '')),0) "
cQuery   += " FROM "+RetSqlName("SC6")+" SC6 "
cQuery   += " WHERE D_E_L_E_T_= '' AND C6_NUM = '"+cPedido+"' AND C6_FILIAL = '"+_cFilial+"' "
cQuery   += " ORDER BY LEN(C6_PRODUTO), SUBSTRING(C6_PRODUTO,4,2), SUBSTRING(C6_PRODUTO,6,2) " // C6_ITEM "

cQuery   :=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , TMPSC6, .T., .F. )
 
(TMPSC6)->(DbGoTop())
While (TMPSC6)->(!EOF())
    
    SB1->(DbSeek(xFilial("SB1")+PadR(alltrim((TMPSC6)->C6_PRODUTO), tamsx3('D3_COD') [1])))
    If (SB1->B1_TIPO == "PA") .AND. (SB1->B1_VEND == "N" )
        FWAlertWarning("O Produto "+alltrim((TMPSC6)->C6_PRODUTO)+" não pode ser dividido, pois está bloqueado para venda !" + CHR( 13 ) + CHR( 10 );
        +"Verifique o campo Pode Vender","Divisão de Pedido, não permitada.") 
        return(.F.)
    Else
        cDispo := U_DetSaldo((TMPSC6)->C6_PRODUTO)+(TMPSC6)->QTDLIB
        aadd(aBrowser,{;
            .F.,;
            alltrim((TMPSC6)->C6_ITEM),;
            alltrim((TMPSC6)->C6_PRODUTO),;
            alltrim((TMPSC6)->C6_DESCRI),;
            (TMPSC6)->C6_QTDVEN,;    
            (TMPSC6)->C6_QTDVEN,;    
            (TMPSC6)->C6_PRCVEN,;
            (TMPSC6)->C6_PRUNIT,;
            (TMPSC6)->C6_TES,;
            (TMPSC6)->C6_LOCAL,;
            (TMPSC6)->C6_VALOR,;
            cDispo,;
            IIF(cDispo <= 0,'0','1')+alltrim((TMPSC6)->C6_ITEM);
            })

    EndIf  
     (TMPSC6)->(dbSkip())
EndDo
(TMPSC6)->(dbCloseArea())
DbSelectArea('SC5')

// ordena por campo Disponivel (12)
//Jose  26/04/2024  aSort(aBrowser, , , {|x, y| x[13] < y[13]}) 
Return .T.

// Valida se quantidade alterada é menor ou igual do pedido de origem
// Valida Volume 
Static Function Valid()
    Local lRet		:= .T.
    oBrowser:setArray(aBrowser)	// Forço o Browse a ler os novos valores informados.
       
    if (aBrowser[oBrowser:nAt,05] > aBrowser[oBrowser:nAt,06])
        Help( ,, 'HELP',, 'Quantidade do produto '+aBrowser[oBrowser:nAt,03]+' não pode ser maior que a original ('+AllTrim(str(aBrowser[oBrowser:nAt,06]))+') !', 1, 0) 
        lRet := .F.
    Endif

    If U_VolQuebrado( aBrowser[oBrowser:nAt,03], aBrowser[oBrowser:nAt,05] )
        Help( ,, 'HELP',, "Quantidade de Volumes para o produto " + aBrowser[oBrowser:nAt,03] + " não permitida!", 1, 0)     
        lRet := .F.
    EndIf

Return ( lRet )

// Função que divide o pedido pela metade automaticamente
Static Function Divide2(oBrowse, aArquivo, cPedido)
 Local _ni   := 1
 Local Limit := 0 

 _aDicvide2  := 1 // Jose 22/05/2024 
 
 //Limpa campos checados
 For _ni := 1 to len(aArquivo)
    aArquivo[_ni,1] := .F.
 Next
  
 // divide browser
 Limit := round(len(aArquivo)/2,0)
 
 // loop nos divididos 
 For _ni := 1 to Limit
    aArquivo[_ni,1] := .T.
 Next

oBrowse:Refresh()
FWMsgRun(Nil, {|| Processa(cPedido) }, "Divisão de Pedido", "Processando, Aguarde...")


return()


Static Function Processa(cPedido)
Local aCabec   := {}
Local aCabe2   := {}
Local aItens   := {}
Local aLinha   := {}
Local aAlter   := {}
Local cVend
Local nAtual
Local cAuxMail
Local nX := 1
Local lMsErroAuto := .F.
Local aArea   := GetArea()
Local cRet := .T.
Local cUsuario
Local VlTotal
//Local nDesc1,nDesc2,nDesc3,nDesc4
//local xComis

    If _ZPPAR0209
        If Bipado(cPedido)
            
            _Bipado := .T. // Pedido tem produtos bipados
            
            FWAlertWarning("Os itens abaixo, já foram processados pela expedição.";
            +chr(13)+chr(10) + chr(13)+chr(10)+xTexto,"Atenção.")     

   
         
        EndIf
    Endif    
   

    If !FWAlertYesNo("Confirma a divisão do pedido?", "Confirme!")
        return()
    EndIf

    // valida se itens foram selecionados de acordo
    If VldItens()
        return()
    Endif


    DbSelectArea("SC5")
    DbSetOrder(1)
    DbSeek(xFilial("SC5")+cPedido, .F.)
    cVend := SC5->C5_VEND1
 
    // Cabecalho ao incluir novo pedido
    aCabec := DetCampos("SC5")
    
    // Cabecalho ao alterar pedido de origem
    aCabe2 := DetCampos("SC5")
    
    // Limpa campo -> Nr Pedido importado SIM3G
    aadd(aCabec,{"C5_X_PVSIM"   ,"",.F.})

    // 
    aadd(aCabec,{"C5_XCOMIS1"   ,SC5->C5_XCOMIS1,.F.})
  
    // Informa pedido de origem
    aadd(aCabec,{"C5_PEDDIV"   ,cPedido,.F.})

      // Informa que pedido originou de uma divisão
    M->C5_OBS := MSMM(SC5->C5_OBSSC5)
    cObs := M->C5_OBS
    aadd(aCabec,{"C5_OBS"   ,"PEDIDO DIVIDIDO."+CHR(13)+CHR(10)+cObs,.F.})

    For nAtual := 1 To Len(aBrowser)
        
        If aBrowser[nAtual][1]
            aLinha := {}
            if (aBrowser[nAtual,05] == aBrowser[nAtual,06])
                VlTotal := ROUND((aBrowser[nAtual,05]*aBrowser[nAtual,07]),02)
                //aadd(aLinha,{"C6_ITEM",    StrZero(nX,2)      , Nil}) Alterado por Nelieder em 20/07/23
                aadd(aLinha,{"C6_ITEM"  ,  aBrowser[nAtual,02], Nil})
                aadd(aLinha,{"C6_PRODUTO", aBrowser[nAtual,03], Nil})
                aadd(aLinha,{"C6_LOCAL",   aBrowser[nAtual,10], Nil})
                aadd(aLinha,{"C6_QTDVEN",  aBrowser[nAtual,05], Nil})
                aadd(aLinha,{"C6_PRCVEN",  aBrowser[nAtual,07], Nil})
                aadd(aLinha,{"C6_PRUNIT",  aBrowser[nAtual,08], Nil})
                aadd(aLinha,{"C6_VALOR",   VlTotal            , Nil}) 
                aadd(aLinha,{"C6_TES",     aBrowser[nAtual,09], Nil})
                aadd(aItens, aLinha)
            else
                VlTotal := ROUND((aBrowser[nAtual,05]*aBrowser[nAtual,07]),02)
               //aadd(aLinha,{"C6_ITEM",    StrZero(nX,2)      , Nil}) Alterado por Nelieder em 20/07/23
                aadd(aLinha,{"C6_ITEM"  ,  aBrowser[nAtual,02], Nil})
                aadd(aLinha,{"C6_PRODUTO", aBrowser[nAtual,03], Nil})
                aadd(aLinha,{"C6_LOCAL",   aBrowser[nAtual,10], Nil})
                aadd(aLinha,{"C6_QTDVEN",  aBrowser[nAtual,05], Nil})
                aadd(aLinha,{"C6_PRCVEN",  aBrowser[nAtual,07], Nil})
                aadd(aLinha,{"C6_PRUNIT",  aBrowser[nAtual,08], Nil})
                aadd(aLinha,{"C6_VALOR",   VlTotal            , Nil}) 
                aadd(aLinha,{"C6_TES",     aBrowser[nAtual,09], Nil})
                aadd(aItens, aLinha)

            EndIf        

            if (aBrowser[nAtual,05] == aBrowser[nAtual,06])
                aLinha := {}
                aadd(aLinha,{"LINPOS","C6_ITEM",aBrowser[nAtual,02]})
                aadd(aLinha,{"AUTDELETA","S",.F.})
                aadd(aLinha,{"C6_PRODUTO", aBrowser[nAtual,03], Nil})
                aadd(aLinha,{"C6_LOCAL",   aBrowser[nAtual,10], Nil})
                aadd(aLinha,{"C6_QTDVEN",  aBrowser[nAtual,05], Nil})
                aadd(aLinha,{"C6_PRCVEN",  aBrowser[nAtual,07], Nil})
                aadd(aLinha,{"C6_PRUNIT",  aBrowser[nAtual,08], Nil})
                aadd(aLinha,{"C6_VALOR",   aBrowser[nAtual,11], Nil})
                aadd(aLinha,{"C6_TES",     aBrowser[nAtual,09], Nil})
                aadd(aAlter, aLinha)
            else
                VlTotal := ROUND(((aBrowser[nAtual,06] - aBrowser[nAtual,05])*aBrowser[nAtual,07]),02)
                aLinha := {}
                aadd(aLinha,{"LINPOS","C6_ITEM",aBrowser[nAtual,02]})
                aadd(aLinha,{"AUTDELETA","N",.F.})
                aadd(aLinha,{"C6_PRODUTO", aBrowser[nAtual,03], Nil})
                aadd(aLinha,{"C6_LOCAL",   aBrowser[nAtual,10], Nil})
                aadd(aLinha,{"C6_QTDVEN",  (aBrowser[nAtual,06] - aBrowser[nAtual,05]), Nil})
                aadd(aLinha,{"C6_PRCVEN",  aBrowser[nAtual,07], Nil})
                aadd(aLinha,{"C6_PRUNIT",  aBrowser[nAtual,08], Nil})
                aadd(aLinha,{"C6_VALOR",   VlTotal, Nil})
                aadd(aLinha,{"C6_TES",     aBrowser[nAtual,09], Nil})
                aadd(aAlter, aLinha)
            Endif 

            nX++
        EndIf    
    Next
   
   // Alimenta Array com dados das liberações do pedido de origem
   aLiberacoes := DetLibera()
   
   lMsErroAuto := .F. 

   cRet := U_ZFATP03(aCabec,aItens,3)
  
   If cRet
        
        // Sucesso
        cDoc := SC5->C5_NUM // Nº do novo Pedido

        // Altera o Pedido de Origem
        dbselectarea("SC5")
        dbsetorder(1)
        dbseek(xFilial("SC5")+cPedido)
        aadd(aCabe2,{"C5_NUM" ,cPedido,.F.})
        
        //  aadd(aCab2,{"C5_PEDREPR"   ,cPedRepr,.F.})
        
        //FWMsgRun(, {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCabe2, aAlter, 4 ) }, "Processando", "Excluindo itens do ped atual...")
        cRet := U_ZFATP03(aCabe2,aAlter,4)
        If !cRet
            FWAlertError("Não foi possivel efetuar a (Alteração\Exclusão) de alguns itens do pedido original "+cPedido+"","Processo cancelado.")
        else

            // Volta liberações do pedido de origem
            FWMsgRun(Nil, {|| VoltaLiberacoes(aLiberacoes) }, "Divisão de Pedido", "Verificando liberações...")
            
            
            //Enviar e-mail avisando que pedido foi dividido e deverá passar por nova liberação

            if !empty(cVend)
                cAuxMail := alltrim(UsrRetMail(__cUserId))
                dbselectarea("SA3")
                dbsetorder(1)
                dbseek(xFilial("SA3")+cVend)
                if found()
                    if !empty(alltrim(SA3->A3_EMAIL))
                    if !empty(cAuxMail)
                        cAuxMail += ","
                    endif
                    cAuxMail += alltrim(SA3->A3_EMAIL)
                    endif 
                endif
                cTexto := "ATENÇÃO! O Pedido "+cPedido+"-"+ALLTRIM(cRazao)+", da filial "+xFilial("SC5")
                cTexto += ", foi dividido e o novo pedido gerado terá que passar por nova liberação! "+chr(13)+chr(10)
                cTexto += "Número do pedido novo gerado: "+cDoc
                cTexto += chr(13)+chr(10) + chr(13)+chr(10)
                cTexto += ItensDel(cPedido)
            
                cUsuario := PswChave(RetCodUsr())
                if (cUsuario == 'neliedercorneta') .or. (cUsuario == 'JoseUliana')
                    U_EnvMail("Pedido "+cPedido+" foi DIVIDIDO!!",cTexto,"joseuliana@brasilux.com.br","neliedercorneta@brasilux.com.br","") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
                else
                    U_EnvMail("Pedido "+cPedido+" foi DIVIDIDO!!",cTexto,"vendas@brasilux.com.br",cAuxMail,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
                Endif

            endif 
  
            //PreencheLiberacoes(aLiberacoes)
            FWMsgRun(Nil, {|| PreencheLiberacoes(aLiberacoes) }, "Divisão de Pedido", "Verificando liberações...")
            
            FWAlertSuccess("Pedido Dividido com Sucesso !", "Divisão de Pedido")

            If _Bipado // Caso pedido dividido tenha produto bipado avisa a expedição
                cTexto := "Atenção."+chr(13)+chr(10)+chr(13)+chr(10)+;
                 "O Pedido "+cPedido+" foi divido gerando um novo Pedido ("+cDoc+") pelo comercial ("+cUsuario+") e possui itens bipados, segue a lista : "+chr(13)+chr(10)+chr(13)+chr(10)+;
                 xTexto
                 //U_EnvMail("Pedido "+cPedido+" dividido com produtos Bipados !",cTexto,"vendas@brasilux.com.br","neliedercorneta@brasilux.com.br","") 
                 U_EnvMail("Pedido "+cPedido+" dividido com produtos Bipados !",cTexto,"vendas@brasilux.com.br",_ZPPAR0210,"") 
            EndIf
            
            oDlg:End()
        endif       
    Else

        FWAlertWarning("Não foi possivel dividir o Pedido.","Processo cancelado.")        

    EndIf

    RestArea( aArea )
return()

/*/
    Valida se itens foram selecionados para divisão do pedidos
/*/
Static Function VldItens()
Local nAtual
Local nSel := 0
Local cReturn := .F.

For nAtual := 1 To Len(aBrowser)
        If aBrowser[nAtual][1]
            nSel++            
        EndIf    
Next

If ( Len(aBrowser) == nSel ) .AND. ( Len(aBrowser) > 1 )
    FWAlertInfo("Não é permitida a seleção de TODOS os itens!", "Atenção!")
    cReturn := .T.
EndIf

If  nSel == 0
    FWAlertInfo("Não há o que separar!", "Atenção!")
    cReturn := .T.
EndIf

return(cReturn)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ VerNumItem()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function PreencheLiberacoes(aLiberacoes)
       //Local aArea := getarea()
       Local cPedDiv := "",_cPed,cQuery,_cPorcComiss,_cPorcLucro,_cMedLucro,_cComis1
       //Local _nVlrComiss, _nMedComiss, lRet := .t.
       _cPed := aLiberacoes[1,2]
       cQuery := "SELECT C5_NUM AS PEDDIV FROM "+RetSqlName("SC5")+" SC5 WHERE (D_E_L_E_T_ <> '*') AND "+;
       "(C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_PEDDIV = '"+_cPed+"')"
       TCQuery cQuery ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       if !eof() .and. !bof()
          cPedDiv := ALLTRIM(TCQ->PEDDIV)
       endif
       dbclosearea()
       _cPorcComiss := alltrim(str(aLiberacoes[12,2],TamSx3("C5_PORCOM")[1],TamSx3("C5_PORCOM")[2]))
       _cComis1 := alltrim(str(aLiberacoes[16,2],TamSx3("C5_COMIS1")[1],TamSx3("C5_COMIS1")[2]))
       _cPorcLucro := alltrim(str(aLiberacoes[13,2],TamSx3("C5_LUCRO")[1],TamSx3("C5_LUCRO")[2]))
       _cMedComiss := alltrim(str(aLiberacoes[14,2],TamSx3("C5_MEDCOM")[1],TamSx3("C5_MEDCOM")[2]))
       _cMedLucro := alltrim(str(aLiberacoes[14,2],TamSx3("C5_MEDLUCR")[1],TamSx3("C5_MEDLUCR")[2]))

       //Efetua Liberações Pedido Origem 
       cQuery := "UPDATE "+RetSqlName("SC5")+" SET C5_LIBCAD = '"+TRIM(aLiberacoes[2,2])+"',"+;
       "C5_USRCAD = '"+TRIM(aLiberacoes[3,2])+"',"+;
       "C5_LIBPED = '"+TRIM(aLiberacoes[4,2])+"',"+;
       "C5_USRPED = '"+TRIM(aLiberacoes[5,2])+"',"+;
       "C5_LIBCRE = '"+TRIM(aLiberacoes[6,2])+"',"+;
       "C5_USRCRE = '"+TRIM(aLiberacoes[7,2])+"',"+;
       "C5_LIBDIR = '"+TRIM(aLiberacoes[8,2])+"',"+;
       "C5_USRDIR = '"+TRIM(aLiberacoes[9,2])+"',"+;
       "C5_APROVA = '"+TRIM(aLiberacoes[10,2])+"',"+;
       "C5_USRAPR = '"+TRIM(aLiberacoes[11,2])+"',"+;
       "C5_PORCOM =  "+_cPorcComiss+","+;
       "C5_COMIS1 =  "+_cComis1+","+;
       "C5_LUCRO =   "+_cPorcLucro+","+;
       "C5_MEDCOM =  "+_cMedComiss+","+;
       "C5_MEDLUCR = "+_cMedLucro+","+;
       "C5_VLRCOM = ROUND("+_cComis1+"*C5_VLRDUP/100,"+ALLTRIM(STR(TamSx3("C5_VLRCOM")[2]))+") "+;
       "WHERE "+;
       "(D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = '"+_cPed+"')"
       TCSQLExec(cQuery)
       
       //Efetua Liberações Pedido Destino
       if !empty(cPedDiv)
          cQuery := "UPDATE "+RetSqlName("SC5")+" SET C5_LIBCAD = '"+TRIM(aLiberacoes[2,2])+"',"+;
          "C5_USRCAD = '"+TRIM(aLiberacoes[3,2])+"',"+;
          "C5_LIBPED = '"+TRIM(aLiberacoes[4,2])+"',"+;
          "C5_USRPED = '"+TRIM(aLiberacoes[5,2])+"',"+;
          "C5_LIBCRE = '"+TRIM(aLiberacoes[6,2])+"',"+;
          "C5_USRCRE = '"+TRIM(aLiberacoes[7,2])+"',"+;
          "C5_LIBDIR = '"+TRIM(aLiberacoes[8,2])+"',"+;
          "C5_USRDIR = '"+TRIM(aLiberacoes[9,2])+"',"+;
          "C5_APROVA = '"+TRIM(aLiberacoes[10,2])+"',"+;
          "C5_USRAPR = '"+TRIM(aLiberacoes[11,2])+"',"+;
          "C5_PORCOM =  "+_cPorcComiss+","+;
          "C5_COMIS1 =  "+_cComis1+","+;
          "C5_LUCRO  =  "+_cPorcLucro+","+;
          "C5_MEDCOM =  "+_cMedComiss+","+;
          "C5_MEDLUCR = "+_cMedLucro+","+;
          "C5_VLRCOM = ROUND("+_cComis1+"*C5_VLRDUP/100,"+ALLTRIM(STR(TamSx3("C5_VLRCOM")[2]))+") "+;
          "WHERE "+;
          "(D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = '"+cPedDiv+"')"
          TCSQLExec(cQuery)
       endif
          
        // Parametro para liberar rotina criado em 25/09/23 chamado R2603
        If !_ZPPAR0208 .And. _aDicvide2 = 0   //  acrescentado por Jose 22/05/2024 .And. _aDicvide2 = 0
            
            cQuery := "UPDATE "+RetSqlName("SC5")+" SET C5_APROVA = '0' "
            cQuery += ",C5_USRPED = ''  , C5_LIBPED = 'F' " // Vendas
            cQuery += ",C5_USRCAD = ''  , C5_LIBCAD = 'F' " // Sintegra
            cQuery += ",C5_USRDIR = ''  , C5_LIBDIR = 'F' " // Aprovação Final
            cQuery += ",C5_USRCRE = ''  , C5_LIBCRE = 'F'  " // Credito
            cQuery += ",C5_USRAPR = '' "
            cQuery += " WHERE C5_NUM = '"+cPedDiv+"' "
            cQuery += " AND (D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"')  "
            nRet := TCSQLExec(cQuery)
            If(nRet < 0 )
                FWAlertError("Erro ao limpar liberações "+TcSqlError(),"Processo cancelado.")
            EndIf

        EndIf
return(.t.)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ DetLibera()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function DetLibera()
       Local aLibs := {}
       aadd( aLibs, { "C5_NUM"    , SC5->C5_NUM    } )
       aadd( aLibs, { "C5_LIBCAD" , SC5->C5_LIBCAD } )
       aadd( aLibs, { "C5_USRCAD" , SC5->C5_USRCAD } )
       aadd( aLibs, { "C5_LIBPED" , SC5->C5_LIBPED } )
       aadd( aLibs, { "C5_USRPED" , SC5->C5_USRPED } )
       aadd( aLibs, { "C5_LIBCRE" , SC5->C5_LIBCRE } )
       aadd( aLibs, { "C5_USRCRE" , SC5->C5_USRCRE } )
       aadd( aLibs, { "C5_LIBDIR" , SC5->C5_LIBDIR } )
       aadd( aLibs, { "C5_USRDIR" , SC5->C5_USRDIR } )
       aadd( aLibs, { "C5_APROVA" , SC5->C5_APROVA } )
       aadd( aLibs, { "C5_USRAPR" , SC5->C5_USRAPR } )
       aadd( aLibs, { "C5_PORCOM" , SC5->C5_PORCOM } )
       aadd( aLibs, { "C5_LUCRO"  , SC5->C5_LUCRO  } )
       aadd( aLibs, { "C5_MEDCOM" , SC5->C5_MEDCOM } )
       aadd( aLibs, { "C5_MEDLUCR", SC5->C5_MEDLUCR} )
       aadd( aLibs, { "C5_COMIS1" , SC5->C5_COMIS1} )
return(aLibs)


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ VoltaLiberacoes()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function VoltaLiberacoes(aLiberacoes)
       Local aArea := getarea()
       Local cPedDiv := "",_cPed,cQuery,lRet := .t.

       _cPed := aLiberacoes[1,2]
       dbselectarea("SC5")
       dbsetorder(1)
       dbseek(xFilial("SC5")+_cPed)
       if found()
          cQuery := "SELECT C5_NUM AS PEDDIV FROM "+RetSqlName("SC5")+" SC5 WHERE (D_E_L_E_T_ <> '*') AND "+;
          "(C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_PEDDIV = '"+_cPed+"')"
          TCQuery cQuery ALIAS "TCQ" NEW

          DbSelectArea("TCQ")
          if !eof() .and. !bof()
             cPedDiv := ALLTRIM(TCQ->PEDDIV)
          endif
          dbclosearea()
          if aLiberacoes[4,2] = "T"
             
             // Libera pedido de origem
             lRet := U_LiberaPed(_cPed)

             // Libera pedido destino   
             If _ZPPAR0208 .Or. _aDicvide2 = 1 // Parametro para liberar rotina criado em 25/09/23 chamado R2603 // Acrescentado por Jose 22/05/2024 .Or. _aDicvide2 = 1
                IF lRet .and. !empty(cPedDiv)
                    lRet := U_LiberaPed(cPedDiv)
                Endif
             EndIf   

          endif
       endif
       restarea(aArea)
return(lRet)

Static Function DetCampos( cAlias )
       Local aArea := GetArea()
       Local aCampos := {},cAux,xValor
       Local _lOpen        := .F. //LGS#20200212 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200212 - Adequação para release 12.1.25

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200212 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200212 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek( cAlias ) )
       While !EOF() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) = cAlias
             
             //If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .AND. !( ( _cAliasSX3 )->( X3_CONTEXT ) = "V") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_DESCON1") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_DESCON2") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_DESCON3") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_PEDREPR") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_X_PVSIM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_FILIAL") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_ITEM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_NUM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_FILIAL") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_PEDDIV") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_NUM") 
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .AND. !( ( _cAliasSX3 )->( X3_CONTEXT ) = "V") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_PEDREPR") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_X_PVSIM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_FILIAL") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_ITEM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_NUM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_FILIAL") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_PEDDIV") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_NUM") 
                cAux   := Alltrim( cAlias ) + "->" + ( _cAliasSX3 )->( X3_CAMPO )
                xValor := &cAux
                if !empty(xValor)
                   aadd( aCampos, { ( _cAliasSX3 )->( X3_CAMPO ), xValor, .F. } )
                endif
             Endif
             dbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( dbSkip() )
       End
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
       /********************************************************************************************************************************/
       RestArea(aArea)
Return(aCampos)

Static Function ItensDel (cPedido)
Local nAtual
Local Txt := ""

Txt := "Segue os itens excluidos do Pedido : "+cPedido + chr(13)+chr(10)
For nAtual := 1 To Len(aBrowser)
    
    If aBrowser[nAtual][1]
        
        Txt += "Produto : "+aBrowser[nAtual,03] 
        Txt += "  Qtd  : "+AllTrim(Str(aBrowser[nAtual,05])) 
        Txt += chr(13)+chr(10)
      
        
        /* aadd(aLinha,{"C6_ITEM"  ,  aBrowser[nAtual,02], Nil})
        aadd(aLinha,{"C6_PRODUTO", aBrowser[nAtual,03], Nil})
        aadd(aLinha,{"C6_LOCAL",   aBrowser[nAtual,10], Nil})
        aadd(aLinha,{"C6_QTDVEN",  aBrowser[nAtual,05], Nil})
        aadd(aLinha,{"C6_PRCVEN",  aBrowser[nAtual,07], Nil})
        aadd(aLinha,{"C6_PRUNIT",  aBrowser[nAtual,08], Nil})
        aadd(aItens, aLinha) */
    EndIf       
Next

return(Txt)


// Verifica se pedido já foi Bipado.
Static Function Bipado(cPedido)
Local cRet := .F.
Local nAtual
Local nSaldo := 0
Local QtdOrignal := 0
Local QtdGerado := 0

xTexto := ""
// Loop nos produtos da grid
    For nAtual := 1 To Len(aBrowser)

    // verifica se produto for selecionado
    If aBrowser[nAtual][1]

        cQuery := " SELECT C6_NUM,C6_ITEM,C6_PRODUTO,ISNULL(ZZK_PRODUT,0) ZZK_PRODUT, "
        cQuery += " SUM(ZZK_QUANT)ZZK_QUANT,C6_QTDVEN "
        cQuery += " FROM "+RetSqlName("SC6")+" SC6 "
        cQuery += " INNER JOIN "+RetSqlName("ZZK")+" ZZK ON ZZK.D_E_L_E_T_ = '' AND ZZK_PEDIDO = C6_NUM AND ZZK_FILIAL = C6_FILIAL "
        cQuery += " AND ZZK_PRODUT = C6_PRODUTO "
        cQuery += " WHERE C6_NUM = '"+cPedido+"' AND SC6.D_E_L_E_T_ = '' AND C6_FILIAL = '"+xFilial("SC6")+"' "
        cQuery += " AND C6_PRODUTO = '"+aBrowser[nAtual,03]+"' "
        cQuery += " GROUP BY C6_NUM,C6_ITEM,C6_PRODUTO,ZZK_PRODUT,ZZK_QUANT,C6_QTDVEN "
        cQuery += " ORDER BY C6_NUM, SUBSTRING(C6_PRODUTO,4,2) " //C6_ITEM "


        IF Select("TMP") <> 0
            DbSelectArea("TMP")
            DbCloseArea()
        ENDIF

        TCQUERY cQuery NEW ALIAS "TMP" 
        Count To nTotal
        TMP->(DbGoTop())

        QtdGerado := aBrowser[nAtual,05]
        
        QtdOrignal := aBrowser[nAtual,06]-aBrowser[nAtual,05]

        //nSaldo := aBrowser[nAtual,06] - TMP->ZZK_QUANT // (Saldo da Qtd total do Pedido - Bipados)

        nSaldo := QtdOrignal - TMP->ZZK_QUANT // (Saldo da Qtd total do Pedido - Bipados)

        // (aBrowser[nAtual,05] Qtd Cortada
        // (aBrowser[nAtual,06] Qtd Original
        // TMP->ZZK_QUANT       Qtd Bipadas

        // Verifique se quantidade de pedido é maior que quantidade bipado
        If (QtdOrignal < TMP->ZZK_QUANT)   
            // Caso o produto seja bipado alimenta
            if nTotal > 0
                cRet := .T.
                xTexto += "Item : "+AllTrim(aBrowser[nAtual,02]) + " | Produto : " +AllTrim(aBrowser[nAtual,03]);
                + " | Qtd Pedido Original : " +AllTrim(Str(QtdOrignal));
                + " | Qtd Pedido Cortado  : " +AllTrim(Str(QtdGerado));
                + " | Qtd Bipado : " +AllTrim(Str(TMP->ZZK_QUANT))+chr(13)+chr(10)  
            EndIf
        EndIf        
    EndIf    
Next

return(cRet)

