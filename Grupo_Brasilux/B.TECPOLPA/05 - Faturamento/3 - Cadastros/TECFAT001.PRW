//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TOTVS.CH"
#Include "XMLXFUN.CH"


/*
  aCliente[1] = CGC
  aCliente[2] = Codigo
  aCliente[3] = Loja
  aCliente[4] = Nome

  aPedido[1] = Pedido
  aPedido[2] = Tipo
  aPedido[3] = Data e Hora
  aPedido[4] = Frete

  aProduto[1] = Codigo Cliente
  aProduto[2] = Quantidade
  aProduto[3] = Vlr Unitario
  aProduto[4] = Vlr Total
  aProduto[5] = DescriÁ„o Cliente
  aProduto[6] = Codigo Protheus
  aProduto[7] = Desc Protheus
  
*/

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunÁ„o    ≥ ZFAT001 ∫ Autor ≥ Nelieder Corneta   ∫ Data ≥  26/04/2022 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriÁ„o ≥ Importa XML e Gera Pedidos de Vendas 				              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function ZTFAT001()

  /*
    Origem
    1 - Console
    2 - Schedule
  */ 

  Private Origem := '1'
  Private oA1_COD,oArquivo,oA1_NOME,oA1_LOJA,oA1_CGC,oC6_PEDCLI,oC5_TPPED
  Private cA1_COD,cArquivo,nArquivo,aString

  Private oC6_HORENT,oC6_ENTREG,oFrete 
  Private cC6_HORENT,cC6_ENTREG 
  Private cData,cHora

  Private oDlg

  //Fontes
  Private    cFontUti   := "Tahoma"
  Private    oFontAno   := TFont():New(cFontUti,,-38)
  Private    oFontSub   := TFont():New(cFontUti,,-16)
  Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
  Private    oFontBtn   := TFont():New(cFontUti,,-14)
  
  //Tamanho da Janela
  Private    nJanLarg    := 1200
  Private    nJanAltu    := 650


  Private aPedido  := { '' , '' , '', '' }
  Private aCliente  := { '' , '' , '', '' }
  Private aProdutos := {}
  Private oBrowse

  
  if origem == "1"
      /* executa via console */
      DEFINE MSDIALOG oDlg TITLE "Importar Pedido XML" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

      /*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
      # Localizar Arquivo XML                                                     #
      ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
      
      @ 004, 003 MSPANEL oPanel SIZE 596, 035 OF oDlg COLORS 0, 14215660 CENTERED RAISED
      
      @ 016,010 SAY OemToAnsi("Arquivo XML.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
      @ 016,060 MSGET  oArquivo VAR cArquivo PICTURE "@!" SIZE 150,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn When .F.
      @ 012,215 BUTTON oBtnSalv  PROMPT "Localizar Arquivo" SIZE 060, 020 OF oDlg ACTION (Pastas()) FONT oFontBtn PIXEL
      @ 012,280 BUTTON oBtnSalv  PROMPT "Gerar Pedido" SIZE 050, 020 OF oDlg ACTION  MsAguarde({|| GerPedi() },"Gerando Pedido..","Aguarde...")  FONT oFontBtn PIXEL
      @ 012,500 BUTTON oBtnSalv  PROMPT "Sair" SIZE 050, 020 OF oDlg ACTION (oDlg:End())  FONT oFontBtn PIXEL


      /*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
      # Dados do Cliente                                                          #
      ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

      @ 040, 003 MSPANEL oPanel SIZE 596, 050 OF oDlg COLORS 0, 14215660 CENTERED RAISED

      @ 052,010 SAY OemToAnsi("Cod Cliente.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
      @ 050,060 MSGET  oA1_COD VAR aCliente[2] PICTURE "@!" SIZE 60,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      @ 052,140 SAY OemToAnsi("Loja.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
      @ 050,190 MSGET  oA1_LOJA VAR aCliente[3] PICTURE "@!" SIZE 20,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      @ 052,270 SAY OemToAnsi("Nome Cliente.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
      @ 050,320 MSGET  oA1_NOME VAR aCliente[4] PICTURE "@!" SIZE 160,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      @ 052,485 SAY OemToAnsi("CNPJ\CPF.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
      @ 050,525 MSGET  oA1_CGC VAR aCliente[1] PICTURE "@!" SIZE 70,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      /*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
      # Dados do Pedido                                                           #
      ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
      @ 072,010 SAY OemToAnsi("Pedido Cliente.: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
      @ 070,060 MSGET  oC6_PEDCLI VAR aPedido[1] PICTURE "@!" SIZE 60,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn
      
      @ 072,140 SAY OemToAnsi("Tipo de Pedido: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
      @ 070,190 MSGET  oC5_TPPED VAR aPedido[2] PICTURE "@!" SIZE 70,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      @ 072,270 SAY OemToAnsi("Data Entrega: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
      @ 070,320 MSGET  oC6_ENTREG VAR cData PICTURE "@!" SIZE 50,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      @ 072,375 SAY OemToAnsi("Hora Entrega: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
      @ 070,430 MSGET  oC6_HORENT VAR cHora PICTURE "@!" SIZE 50,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      @ 072,500 SAY OemToAnsi("Frete: ") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
      @ 070,525 MSGET  oFrete VAR aPedido[4] PICTURE "@!" SIZE 040,10 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

      
      /*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
      # Produtos                                                                  #
      ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
      
      @ 100, 003 MSPANEL oPanel SIZE 596, 250 OF oDlg COLORS 0, 14215660 CENTERED RAISED

      // Cria Browse
      oBrowse  := TCBrowse():New(110, 008, 580, 200, , {'Codigo Produto',' desc' ,'Quantidade', 'Vlr Unit.', 'Vlr Total.', 'Cod Protheus.' }, {70,130,40,40,40,50}, oDlg, , , , , , , oFontSub, , , , , .F., , .T., , .F., , ,)
      oBrowse:nLinhas := 2
      aProdutos := {{ '' , '' , '' , '', '', '' }}

     // Seta vetor para a browse
      oBrowse:SetArray(aProdutos)
      // Monta a linha a ser exibina no Browse
      oBrowse:bLine   := {||{ aProdutos[oBrowse:nAt,01],aProdutos[oBrowse:nAt,05],aProdutos[oBrowse:nAt,02],aProdutos[oBrowse:nAT,03],aProdutos[oBrowse:nAT,04],aProdutos[oBrowse:nAT,06], }}

      

      oDlg:lEscClose := .T.

    ACTIVATE MSDIALOG oDlg CENTERED
  
  else
   /* executa via schedule */
  
  Endif  

  
  
Return


/* abre pastas arquivos */
/*
MV_INXML
MV_OUTXML
*/

/*/{Protheus.doc} Pastas
Busca DiretÛrio com os arquivos XML
@type function
@author neliedercorneta
@since 26/04/2022
/*/
Static Function Pastas()
	Local targetDir
  targetDir := cGetFile("*.xml","XML File",0,GETMV("MV_INXML"),.T.,GETF_LOCALHARD,.T.,.T.)
  if !empty(targetDir)
    cArquivo := targetDir
    Importar(cArquivo)
  EndIf
  
return()


/*/{Protheus.doc} Importar
Importa Arquivo XML, conforme endereÁo
@type function
@author neliedercorneta
@since 26/04/2022
@param Caminho, character, caminho do arquivo XML
/*/
Static Function Importar (Caminho)

Local cError   := ""
Local cWarning := ""
Local oXml := NIL
Local nPro
Local CGC
Local aCGC

aCliente := {}
aPedido := {}
aProdutos := {}

//Gera o Objeto XML
oXml := XmlParserFile( Caminho, "_", @cError, @cWarning )
If (oXml == NIL )
  MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
  Return
Endif

/* pega CGC logada */
CGC := FWSM0Util():GetSM0Data( Substr(cNumEmp,1,2),Substr(cNumEmp,1,2), { "M0_CGC" } )[1][2]

/* pegar CGC Arquivo*/
aCGC := oXml:_BusinessContent:_VendorGovInfo:_ID[1]:Text



/* valida CGC XML com empresa logada */
if aCGC <> CGC
  MsgAlert('CNPJ do Arquivo XML difere da empresa logada !')
  return()
EndIf


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
# Dados do Pedido                                                           #
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
aadd(aPedido,oXml:_BusinessContent:_ORDERID:Text) // numero pedido do cliente
aadd(aPedido,oXml:_BusinessContent:_ORDERTYPECODE:Text) // tipo de pedido
aadd(aPedido,oXml:_BusinessContent:_DHINIDELIVERY:Text) /* Data e hora de entrega do item	InformaÁıes gravadas nos campos C6_ENTREG e C6_HORENT */
cData := (SUBSTR(aPedido[3],9,2))+'/'+(SUBSTR(aPedido[3],6,2))+'/'+(SUBSTR(aPedido[3],1,4))
cHora := (SUBSTR(aPedido[3],12,5))

aadd(aPedido,oXml:_BusinessContent:_FREIGHTTYPE:Text) 


/* dados do cliente */
  if empty(Posicione("SA1", 3,xFilial("SA1")+oXml:_BusinessContent:_CustomerGovInfo:_ID[1]:Text,'A1_CGC')) 
     MsgAlert('O CNPJ '+oXml:_BusinessContent:_CustomerGovInfo:_ID[1]:Text+ 'n„o foi localizado')
     aCliente  := { '' , '' , '', '' }
     aProdutos := {{ '' , '' , '' , '', '', '' }}
     return()
  else
    aadd(aCliente,SA1->A1_CGC)
    aadd(aCliente,SA1->A1_COD) 
    aadd(aCliente,SA1->A1_LOJA)
    aadd(aCliente,SA1->A1_NOME)
  Endif


  /* valida se campo È um array */
  if valtype(oXml:_BusinessContent:_SalesOrderItens:_Item) <> "A"
      Aadd(aProdutos,{; 
            oXml:_BusinessContent:_SalesOrderItens:_Item:_prodcoderpbuy:TEXT,; 
            val(oXml:_BusinessContent:_SalesOrderItens:_Item:_Quantity:Text),;
            val(oXml:_BusinessContent:_SalesOrderItens:_Item:_UnityPrice:Text),;
            val(oXml:_BusinessContent:_SalesOrderItens:_Item:_valnetlineitem:Text),;
            AllTrim(oXml:_BusinessContent:_SalesOrderItens:_Item:_ItemDescription:Text),;
            CadPro(oXml:_BusinessContent:_SalesOrderItens:_Item:_prodcoderpbuy:TEXT);
      })  
  else
    nQtdProd := len(oXml:_BusinessContent:_SalesOrderItens:_Item)
      /* lista produto */
    For nPro := 1 To nQtdProd 
      Aadd(aProdutos,{; 
            oXml:_BusinessContent:_SalesOrderItens:_Item[nPro]:_prodcoderpbuy:TEXT,; 
            val(oXml:_BusinessContent:_SalesOrderItens:_Item[nPro]:_Quantity:Text),;
            val(oXml:_BusinessContent:_SalesOrderItens:_Item[nPro]:_UnityPrice:Text),;
            val(oXml:_BusinessContent:_SalesOrderItens:_Item[nPro]:_valnetlineitem:Text),;
            AllTrim(oXml:_BusinessContent:_SalesOrderItens:_Item[nPro]:_ItemDescription:Text),;
            CadPro(oXml:_BusinessContent:_SalesOrderItens:_Item[nPro]:_prodcoderpbuy:TEXT);
      })  
    Next
    
  Endif  

// Seta vetor para a browse
oBrowse:SetArray(aProdutos)
// Monta a linha a ser exibina no Browse
oBrowse:bLine   := {||{ aProdutos[oBrowse:nAt,01],aProdutos[oBrowse:nAt,05],aProdutos[oBrowse:nAt,02],aProdutos[oBrowse:nAT,03],aProdutos[oBrowse:nAT,04],aProdutos[oBrowse:nAT,06], }}
oBrowse:nLinhas := 2
oBrowse:Refresh()  
oDlg:Refresh()
return()

/*/{Protheus.doc} CadPro
Verifica se tem Cadastro de Produto & Cliente
@type function
@author neliedercorneta
@since 26/04/2022
@param codigo, character, codigo produto cliente
/*/
Static Function CadPro(codigo)

DbSelectARea("SA7")
DbSetOrder(3)
if DbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+codigo)
       return(SA7->A7_PRODUTO)
Else
       MsgAlert('O Produto '+codigo+' n„o foi localizado no cadastro de Clientes & Produto, favor cadastrar !')
       return('')
Endif


return


/*/{Protheus.doc} GerPedi
Gera Pedido de Venda
@type function
@author neliedercorneta
@since 26/04/2022
/*/
Static Function GerPedi()

Local nOpr    := 3  // N⁄MERO DA OPERA«√O (INCLUS√O)
Local aHeader := {} // INFORMA«’ES DO CABE«ALHO
Local aLine   := {} // INFORMA«’ES DA LINHA
Local aItems  := {} // CONJUNTO DE LINHAS
Local aArea   := {} // ARMAZENA ¡REA CORRENTE
Local Cont

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private cFrete


If (len(aProdutos) < 0) .and. (len(aCliente) <0) .and. (len(aPedido) < 0)
  MessageBox( "Informe o arquivo XML !", "AtenÁ„o", 48 )
  return
EndIf

If (aPedido[1] == '' ) .or. (aProdutos[1][1] == '' ) .or. (aCliente[1] == '' ) 
  MessageBox( "Informe o arquivo XML !", "AtenÁ„o", 48 )
  return
EndIf

/* tipo de frete */
/*  1 - CIF (Frete por conta do vendedor)
    2 - FOB (Frete por conta do comprador)
    3 - SFT (Sem frete)
*/    

if aPedido[4] == '1'
  cFrete := 'C'
elseif aPedido[4] == '2'
  cFrete := 'F'
elseif aPedido[4] == '2'
  cFrete := 'S'
EndIf  

//RPCSetEnv("99", "01", NIL, NIL, "FAT", NIL, {"SC5", "SC6"}) // ABERTURA DE AMBIENTE (REMOVER SE EXECUTADO VIA SMARTCLIENT)
  aArea := GetArea() // CAPTURA DA ¡REA PARA FUTURA RESTAURA«√O

  //cNum := GetSXENum("SC5", "C5_NUM") // REMOVER PARA GERA«√O DE NUMERA«√O AUTOM¡TICA PELA ROTINA

  // DADOS DO CABE«ALHO
  //AAdd(aHeader, {"C5_NUM", cNum, NIL}) // REMOVER PARA GERA«√O DE NUMERA«√O AUTOM¡TICA PELA ROTINA

  if empty(SA1->A1_COND)
      MsgAlert('CondiÁ„o de Pagamento n„o informada no cadastro do Cliente, verifique')
      return()
  EndIf

  if empty(SA1->A1_TABELA)
      MsgAlert('Tabela de preÁo n„o informada no cadastro do Cliente, verifique')
      return()
  EndIf

  AAdd(aHeader, {"C5_TIPO", "N", NIL})
  AAdd(aHeader, {"C5_CLIENTE", SA1->A1_COD, NIL})
  AAdd(aHeader, {"C5_LOJACLI", SA1->A1_LOJA, NIL})
  AAdd(aHeader, {"C5_CONDPAG", SA1->A1_COND, NIL})
  AAdd(aHeader, {"C5_TABELA", SA1->A1_TABELA, NIL})
  AAdd(aHeader, {"C5_VEND1", SA1->A1_VEND, NIL})
  AAdd(aHeader, {"C5_TPFRETE", cFrete, NIL})
  
  for Cont := 1 to len(aProdutos)
     
    if  empty(aProdutos[Cont][6])
      MsgAlert('O Produto '+aProdutos[Cont][1]+' n„o foi localizado no cadastro de Clientes & Produto, favor cadastrar !')   
      return()
    EndIf

    if empty(Posicione("SB1", 1,xFilial("SB1")+aProdutos[Cont][6],'B1_COD'))
       MsgAlert('O Produto '+aProdutos[Cont][6]+' n„o foi localizado no cadastro de Clientes & Produto, favor cadastrar !')
       return()
    EndIf

    dbselectarea("SB2")
    dbsetorder(1)
    dbseek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
      if !found()
     			CriaSb2(SB1->B1_COD+SB1->B1_LOCPAD)
     	endif  

    if empty(SB1->B1_TS)
      xB1_TES := GETMV("MV_TESXML")
      //MsgAlert('O Produto '+SB1->B1_COD+' n„o possui TES de SaÌda Cadastrada, favor informar ')
      //return()
    else
      xB1_TES := AllTrim(SB1->B1_TS)
    EndIf

     if empty(SB1->B1_LOCPAD)
      MsgAlert('O Produto '+SB1->B1_COD+' n„o possui Local Padr„o Cadastrado, favor informar ')
      return()
    EndIf


    dbselectarea("SC6")
		dbsetorder(11) //C6_FILIAL+C6_CLI+C6_LOJA+C6_PEDCLI                                                                                                                              
		MsSeek(xFilial("SC6")+SA1->A1_COD+SA1->A1_LOJA+aPedido[1])
    if !found()
      // DADOS DOS ITENS
      aLine := {}
      AAdd(aLine, {"C6_ITEM", StrZero(Cont , 2), NIL})
      AAdd(aLine, {"C6_PRODUTO", SB1->B1_COD, NIL})
      AAdd(aLine, {"C6_LOCAL", SB1->B1_LOCPAD, NIL})

    
      AAdd(aLine, {"C6_QTDVEN", aProdutos[Cont][2], NIL})
      AAdd(aLine, {"C6_PRUNIT", aProdutos[Cont][3], NIL})
      AAdd(aLine, {"C6_PRCVEN", aProdutos[Cont][3], NIL})
      AAdd(aLine, {"C6_VALOR" , aProdutos[Cont][4], NIL})
      AAdd(aLine, {"C6_TES"   , xB1_TES           ,NIL})
      AAdd(aLine, {"C6_PEDCLI", aPedido[1]        ,NIL})
      AAdd(aLine, {"C6_ENTREG", CTOD(cData) ,NIL})
      
    
    AAdd(aItems, aLine)

    endif
  Next

  if len(aItems) <= 0
    MsgAlert('Pedido cliente j· existente !')
    return()
  endif 

   MsExecAuto({|x, y, z| MATA410(x, y, z)}, aHeader, aItems, nOpr)

  // VALIDA«√O DE ERRO
  If (lMsErroAuto)
      MostraErro()
      // RollbackSX8() // REMOVER PARA GERA«√O DE NUMERA«√O AUTOM¡TICA PELA ROTINA

  Else
      // ConfirmSX8() // REMOVER PARA GERA«√O DE NUMERA«√O AUTOM¡TICA PELA ROTINA
      //MsgBox("Pedido Gerado com Sucesso ",SC5->C5_NUM,"INFO")
      MessageBox( "Pedido "+SC5->C5_NUM+" , gerado com Sucesso !", "AtenÁ„o", 48 )

      aString := strtokarr (cArquivo, "\")
      nArquivo := GETMV("MV_OUTXML")+aString[len(aString)]
      
      if __CopyFile(cArquivo,nArquivo)
          FErase(cArquivo)
      else
          MsgStop("AtenÁ„o, o arquivo xml n„o foi excluido, verifique!")
      EndIf
      

  EndIf

  aPedido  := { '' , '' , '', '' }
  aCliente  := { '' , '' , '', '' }
  cData := ''
  cHora := ''
  cArquivo := ''
  aProdutos := {{ '' , '' , '' , '', '', '' }}

  // Seta vetor para a browse
  oBrowse:SetArray(aProdutos)
  // Monta a linha a ser exibina no Browse
  oBrowse:bLine   := {||{ aProdutos[oBrowse:nAt,01],aProdutos[oBrowse:nAt,05],aProdutos[oBrowse:nAt,02],aProdutos[oBrowse:nAT,03],aProdutos[oBrowse:nAT,04],aProdutos[oBrowse:nAT,06], }}
  oBrowse:nLinhas := 2
  oBrowse:Refresh()  
  oDlg:Refresh()



  RestArea(aArea) // RESTAURA«√O DA ¡REA ANTERIOR
  //RPCClearEnv() // FECHAMENTO DE AMBIENTE (REMOVER SE EXECUTADO VIA SMARTCLIENT)



return()
