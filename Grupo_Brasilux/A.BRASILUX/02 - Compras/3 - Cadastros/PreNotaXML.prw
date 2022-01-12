/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PRENOTAº Autor ³ Luiz Alberto º Data ³ 29/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Leitura e Importacao Arquivo XML para geração de Pre-Nota  º±±
±±º          ³                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-- Ponto de Entrada para incluir botão na Pré-Nota de Entrada

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

/* ATENCAO PARA QUE A ROTINA FUNCIONE CORRETAMENTE
EXISTE A NECESSIDADE DE CRIAÇÃO DE DOIS INDICES

TABELA SA5
CHAVE: FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR

A5_FILIAL + A5_FORNECE + A5_LOJA + A5_CODPRF

NICK NAME - > FORPROD

TABELA SA7
CHAVE: FILIAL + CLIENTE + LOJA + CODIGO PRODUTO CLIENTE

A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_CODCLI

NICK NAME -> CLIPROD

**Cleber Orati** :
  * Caso banco de dados não for compatível excluir cláusula WITH (NOLOCK) da 
  query que consulta pedidos, esta cláusula impede que registros bloqueados (em transaction) bloqueiem a consulta
    

*/
User Function PreNotaXML
//Local aTipo			:={'N','B','D'}
//Local lBloqueado
Local ni
Local nItem
Local cAuxMail,nX,nTipo,nIpi,lMarcou,lAchou,CST_Aux,cFci,cSerie,cNroNf,cTipoNf
Local lCsosn,cMenNota, nTamFile, nBtLidos, lLerKits,cAuxCod,i,nContKit,j,nAuxQtde
Local cAviso := ""
Local cErro  := ""
Local aCamposPE:={}
Local _cGrpEmp,_cFilial,_cNumEmp
//Local _lVerNfePr // := Type("oNFe:_NfeProc")<> "U" -> Cleber(15/01/20)
//Local _lVerNfe   // := Type("oNFe:_NFe") <> "U"
//Local _lVerICMS  //:= Type("oNF:_InfNfe:_ICMS")<> "U"
//Local nAliqSt, nBaseSt, nVlrSt
Private aItensKits := {} //Verificar se irá ler Kits Coca Cola (Cleber 13/07/21) ->TecPolpa
Private CPERG   	:="NOTAXML"
Private Caminho 	:= "\SYSTEM\XMLNFE\" //"E:\Protheus10_Teste\protheus_data\XmlNfe\  Foi alterado para \System\XmlNfe\ para funcionar de qualquer estacao Emerson Holanda 10/11/10
Private _cMarca   := GetMark()
Private aFields   := {}
Private cArq,nHdl,cBuffer
Private aFields2  := {}
Private aFields3 := {}
Private cUmFor,nQtde,nQtdeNfe,cArq2,cProds,cCodBar,cCodPro,Chkproc,lCancelar
Private oAux,oICM,oNF,oNFChv,oEmitente,oIdent,oDestino,oTotal,oTransp,oDet,cChvNfe  
Private oFatura,cEdit1,_DESCdigit,_NCMdigit,lOut,lOk,_oPT00005,cCodPrf,cFornec,cLoja,cCodBarKit,nQtItKit,nLidoKit,lFimDlg
Private lMsErroAuto,lMsHelpAuto
Private lPcNfe		:= GETMV("MV_PCNFE")
Private cArquivo 		:= ""
Private oTempTbl01
Private oTempTbl02
Private oTempTbl03
Private _lVerNfePr  //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerNfe    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerICMS   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerInfN   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerCobr   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerCPF    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerEmit   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerDtEm   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerNCM    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerFCI    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerDes    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI00    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI10    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI20    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI30    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI40    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI51    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI60    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI70    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerI90    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerISN    //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerIOri   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerICST   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
Private _lVerICSO   //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
private _oBrwCodb 
     u_zcfga01( 'PRENOTAXML' ) //LGS#2021214 - Gravação de log de utilização da rotina
_cGrpEmp := ALLTRIM(FWGrpCompany())
_cFilial := alltrim(FWCodFil())
_cNumEmp := _cGrpEmp+_cFilial
lCancelar := .f.
//PutMV("MV_PCNFE",.f.)
lLerKits := .f. //Verificar se irá ler Kits Coca Cola (TecPolpa)
cCodBarKit := ""
nTipo := 1
lOut := .f. //Sair do programa
cBuffer := ""
cCodBar := space(44)
Do While .T.
	cArquivo := ""
	_oPT00005 := nil
	DEFINE MSDIALOG _oPT00005 FROM  50, 050 TO 400,500 TITLE OemToAnsi('Busca de XML de Notas Fiscais de Entrada') PIXEL	// "Movimenta‡„o Banc ria"
	
	@ 003,005 Say OemToAnsi("Cod Barra NFE") Size 040,030
	@ 030,005 Say OemToAnsi("Tipo Nota Entrada:") Size 070,030
	
	@ 003,060 Get cCodBar  Picture "@!S80"  Size 150,030 // Valid AchaFile(@cArquivo)
	@ 020,060 RADIO oTipo VAR nTipo ITEMS "Nota Normal","Nota Beneficiamento","Nota Devolução" SIZE 70,10 OF _oPT00005
	
	
	@ 135,060 Button OemToAnsi("Arquivo") Size 036,016 Action (GetArq(@cArquivo),_oPT00005:End())
	@ 135,110 Button OemToAnsi("Ok")  Size 036,016 Action (_oPT00005:End())
	@ 135,160 Button OemToAnsi("Sair")   Size 036,016 Action Fecha()
	
	Activate Dialog _oPT00005 CENTERED
	
	if lOut
		exit
	endif 
	MV_PAR01 := nTipo
	
	if !empty(alltrim(cCodBar)) 
		if !AchaFile(@cArquivo)
			loop
		endif
	else 
		
		//cArquivo := cCodBar
//		If empty(cArquivo) .or. (!Empty(cArquivo) .and. !File(cArquivo))
		If empty(cArquivo) 
			MsgAlert("Arquivo Não Encontrado no Local de Origem Indicado!")
	//		PutMV("MV_PCNFE",lPcNfe)                                       
	/*
			if type("_oPT00005") <> "U"
				_oPT00005:End()
				Close(_oPT00005)
			endif   
	*/		
			loop 
		Endif
	endif 
	
	aCamposPE:={}
	cCodBar := alltrim(cCodBar)

	if empty(cBuffer)
		nHdl    := fOpen(cArquivo,0)
		If nHdl == -1
			If !Empty(cArquivo)
				MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! Verifique os parametros.","Atencao!")
			Endif
			//PutMV("MV_PCNFE",lPcNfe)
			Return
		Endif
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
		nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
		fClose(nHdl)
	endif 
	cAviso := ""
	cErro  := ""
	
	oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)
    fValTagC( oNfe ) //LGS#20200129 ADEQUAÇÃO AO RELEASE PROTHEUS 12.1.25 E POSTERIORES ***/
    //_lVerNfePr := Type("oNFe:_NfeProc") <> "U"
    //_lVerNfe   := Type("oNFe:_NFe") <> "U"
    //_lVerICMS  := Type("oNF:_InfNfe:_ICMS") <> "U"
	/*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
	//***Cleber(15/01/20)
	//***Luis Gustavo (29/01/2020) - Declaração das variáveis de verificação após criação do objeto oNfe
	//If Type("oNFe:_NfeProc")<> "U"
	If _lVerNfePr
		oNF := oNFe:_NFeProc:_NFe
	Else
	   /*** Substituido em 08/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
	   //***Luis Gustavo (29/01/2020) - Declaração das variáveis de verificação após criação do objeto oNfe
	   //if Type("oNFe:_NFe") <> "U"
	   //_lVerNfe := Type("oNFe:_NFe") <> "U"
	   //if Type("oNFe:_NFe") <> "U"
	   If _lVerNfe
		  oNF := oNFe:_NFe
       ELSE  
		  MsgAlert("Não foi possível abrir o arquivo XML, provavel falha em sua estrutura. Por favor substitua o arquivo","Atencao!")
		  Return
	   Endif 
	Endif
	
	//oNFChv := oNFe:_NFeProc:_protNFe
	
	oEmitente  := oNF:_InfNfe:_Emit
	oIdent     := oNF:_InfNfe:_IDE
	oDestino   := oNF:_InfNfe:_Dest
	oTotal     := oNF:_InfNfe:_Total
	oTransp    := oNF:_InfNfe:_Transp
	oDet       := oNF:_InfNfe:_Det

	/***Luis Gustavo (29/01/2020) - Declaração das variáveis de verificação após criação do objeto oNfe ***/
	//cChvNfe    := IIF( TYPE("oNF:_INFNFE:_ID:TEXT") <> "U", substr(oNF:_INFNFE:_ID:TEXT,4,44),oNFe:_NFeProc:_protNFe:_INFPROT:_CHNFE:TEXT)	//oNFChv:_INFPROT:_CHNFE:TEXT
	cChvNfe    := IIF( _lVerInfN, substr(oNF:_INFNFE:_ID:TEXT,4,44), oNFe:_NFeProc:_protNFe:_INFPROT:_CHNFE:TEXT )	//oNFChv:_INFPROT:_CHNFE:TEXT
	
	/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
	//***Luis Gustavo (29/01/2020) - Declaração das variáveis de verificação após criação do objeto oNfe
	//	<chNFe>41101108365527000121550050000014611623309134</chNFe>
	//If Type("oNF:_InfNfe:_ICMS")<> "U"
	//_lVerICMS 
	//If Type("oNF:_InfNfe:_ICMS") <> "U"
	If _lVerICMS
		oICM := oNF:_InfNfe:_ICMS
	Else
		oICM := nil
	Endif 
	
	/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
	//oFatura    := IIf( Type("oNF:_InfNfe:_Cobr") == "U", Nil, oNF:_InfNfe:_Cobr )
	oFatura    := IIf( _lVerCobr, Nil, oNF:_InfNfe:_Cobr )
	cEdit1	   := Space(15)
	_DESCdigit :=space(55)
	_NCMdigit  :=space(8)
	
	oDet := IIf( ValType(oDet)=="O", {oDet}, oDet )
	// Validações -------------------------------
	// -- CNPJ da NOTA = CNPJ do CLIENTE ? oEmitente:_CNPJ
	If MV_PAR01 = 1
		cTipoNf := "N"
	ElseIF MV_PAR01 = 2
		cTipoNf := "B"
	ElseIF MV_PAR01 = 3
		cTipoNf := "D"
	Endif
	
	
	// CNPJ ou CPF
	/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
	//cCgc := AllTrim(IIf(Type("oDestino:_CPF")=="U",oDestino:_CNPJ:TEXT,oDestino:_CPF:TEXT)) 
	cCgc := AllTrim( IIf( _lVerCPF, oDestino:_CNPJ:TEXT, oDestino:_CPF:TEXT ) )
	if !(cCgc == alltrim(SM0->M0_CGC))
		//Tratamento Brasilux Depósito Fechado. Possibilidade de entrada em notas para armazenagem
//		if !(alltrim(SM0->M0_CGC) == "72770878000540")
			MsgAlert("Nota Fiscal pertencente a OUTRA EMPRESA ou FILIAL. Por favor efetuar login no seguinte CNPJ: " + cCgc)
			loop 
//		endif 
	Endif
	/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/	
	//cCgc := AllTrim( IIf( Type("oEmitente:_CPF") == "U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT ) )
	cCgc := AllTrim( IIf( _lVerEmit, oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT ) )

	lAchou := .f.                                   
	// Considerar situação em que registro está bloqueado
	If MV_PAR01 = 1 // Nota Normal Fornecedor                     
		dbselectarea("SA2")
		dbSetOrder(3)
		dbSeek(xFilial("SA2")+cCgc)
		do while !lAchou .and. !eof() .and. (xFilial("SA2") = SA2->A2_FILIAL) .AND. (TRIM(SA2->A2_CGC) == cCgc)
			IF SA2->(FieldPos("A2_MSBLQL")) > 0
				IF !(SA2->A2_MSBLQL == "1")
					lAchou := .t.          
					EXIT
				endif
			else
				lAchou := .t.  
				EXIT 
			endif
			dbselectarea('SA2')
			dbskip()
		enddo 
	Else
		dbselectarea("SA1")
		dbSetOrder(3)
		dbSeek(xFilial("SA1")+cCgc)
		do while !lAchou .and. !eof() .and. (xFilial("SA1") = SA1->A1_FILIAL) .AND. (TRIM(SA1->A1_CGC) == cCgc)
			IF SA1->(FieldPos("A1_MSBLQL")) > 0
				IF !(SA1->A1_MSBLQL == "1")
					lAchou := .t.
					EXIT 
				endif
			else
				lAchou := .t.    
				EXIT 
			endif
			dbselectarea('SA1')
			dbskip()
		enddo 
	Endif
	If !lAchou
		MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgc)
//		PutMV("MV_PCNFE",lPcNfe)
		Return
	else
		If MV_PAR01 = 1 // Nota Normal Fornecedor                     
			cFornec := SA2->A2_COD
			cLoja := SA2->A2_LOJA
		else
			cFornec := SA1->A1_COD
			cLoja := SA1->A1_LOJA
		endif		
	Endif
	
	// -- Nota Fiscal já existe na base ?
	If SF1->(DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+cFornec+cLoja))
		MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT+" do "+IIF(MV_PAR01 = 1,"Fornec ","Cliente ")+cFornec+"/"+cLoja+" Ja Existe. A Importacao sera interrompida")
//		PutMV("MV_PCNFE",lPcNfe)
		Return Nil
	EndIf
	cSerie := padr(OIdent:_serie:TEXT,TamSx3("F1_SERIE")[1])
	cNroNf := Right(REPLICATE("0",TamSx3("F1_DOC")[1])+Alltrim(OIdent:_nNF:TEXT),TamSx3("F1_DOC")[1])
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"F1_TIPO"   ,cTipoNf,Nil,Nil})
	aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})
	aadd(aCabec,{"F1_DOC"    ,cNroNf,Nil,Nil})
	aadd(aCabec,{"F1_SERIE"  ,cSerie,Nil,Nil})
    /*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/   
	//if !Type("OIdent:_dEmi:TEXT") = "C"
	If !_lVerDtEm
		cData:=Alltrim(OIdent:_dHEMI:TEXT)  
	else  	
		cData:=Alltrim(OIdent:_dEmi:TEXT)
	endif 
	dData:=CTOD(Substr(cData,9,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))

	//Informações adicionais da nota
	/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
	//cMenNota := substr(IIF(TYPE("oNF:_InfNfe:_InfAdic:_infcpl:TEXT") <> "U",oNF:_InfNfe:_InfAdic:_infcpl:TEXT,""),1,TamSx3("F1_MENNOTA")[1])
	cMenNota := substr( IIF( _lVerDtEm, oNF:_InfNfe:_InfAdic:_infcpl:TEXT, "" ), 1, TamSx3("F1_MENNOTA")[1] )
	
	aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})
	aadd(aCabec,{"F1_FORNECE",cFornec,Nil,Nil})
	aadd(aCabec,{"F1_LOJA"   ,cLoja,Nil,Nil})
	aadd(aCabec,{"F1_ESPECIE","SPED ",Nil,Nil})
	aadd(aCabec,{"F1_MENNOTA",cMenNota,Nil,Nil})
	aadd(aCabec,{"F1_CHVNFE",cChvNfe,Nil,Nil})
	
	
	dbselectarea("SG1") //Verificar se poduto lido tem estrutura (Kit´s Coca Cola TecPolpa)
	dbsetorder(2) //G1_FILIAL+G1_COMP+G1_COD                                                                                                                                        

	// Primeiro Processamento
	// Busca de Informações para Pedidos de Compras
	
	cProds := ''
	nQtItKit := 0
	aPedIte:={}
	
	For nX := 1 To Len(oDet)
		nQtde := 0
		nQtdeNfe := 0
		cEdit1 := Space(15)
		_DESCdigit :=space(55)
		_NCMdigit  :=space(8)
		cUmFor := UPPER(AllTrim(oDet[nX]:_Prod:_Ucom:TEXT))
		if (cUmFor == "KG") .and. (_cFilial $ "010101_010104_010106_010107")
			cUmFor := "K"
		endif 
		if cUmFor == "UNID"
			cUmFor := "UN"
		endif 
		oAux := oDet[nX]
		_lVerNCM := .f.
		fValTagD( oAux )
		/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
		//cNCM:=IIF(Type("oAux:_Prod:_NCM")=="U",space(12),oAux:_Prod:_NCM:TEXT)
		cNCM := IIF( _lVerNCM, space(12), oAux:_Prod:_NCM:TEXT )
		
		If (MV_PAR01 = 1) //NF de entrada tipo N-Normal
			cCodPrf:=PadR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSx3("A5_CODPRF")[1])
			
			Chkproc=.F.
			//Desconsiderar produto bloqueado que foi amarrado anteriormente
			dbselectarea("SB1")
			dbsetorder(1)
			dbselectarea("SA5")
			DbOrderNickName("FORPROD")   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
			dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cCodPrf)
			lAchou := .f.                                        
			do while !eof() .and. !lAchou .and. !empty(cCodPrf) .and. (SA5->A5_FILIAL == xFilial("SA5")) .AND. (SA5->A5_FORNECE == SA2->A2_COD) .AND. (SA5->A5_LOJA == SA2->A2_LOJA) .AND. !empty(SA5->A5_CODPRF) .AND. (SA5->A5_CODPRF == cCodPrf)
				dbselectarea("SB1")
				MsSeek(xFilial("SB1")+SA5->A5_PRODUTO)
				if found() .AND. (SB1->B1_MSBLQL <> "1")
					lAchou := .t.   
					cCodPro := SA5->A5_PRODUTO        
				endif 
				dbselectarea("SA5")
				dbskip()
			enddo 
			if lAchou
				dbselectarea("SA5")
				dbsetorder(1)	//A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
				MsSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cCodPro)
				if !found()
					MsgAlert("Amarração do Produto "+cCodPro+" Nao Encontrada. A Importacao sera interrompida")
					//PutMV("MV_PCNFE",lPcNfe)
					Return Nil
				endif 
			else
				If !MsgYesNo ("Produto Cod.: "+cCodPrf+" Nao Encontrado. Digita Codigo de Substituicao?")
					//PutMV("MV_PCNFE",lPcNfe) //Cleber (06/07/2016) -> Tirei pois caso o usuario diga para não digitar código Prod x Fornecedor desabilita a obrigação de se ter ped de compra para a NFE
					Return Nil
				Endif
				DEFINE MSDIALOG _oDlg TITLE "Dig.Cod.Substituicao" FROM C(177),C(192) TO C(509),C(659) PIXEL
				
				// Cria as Groups do Sistema
				@ C(002),C(003) TO C(071),C(186) LABEL "Dig.Cod.Substituicao " PIXEL OF _oDlg
				
				// Cria Componentes Padroes do Sistema
				@ C(012),C(027) Say "Cod Fornec: "+cCodPrf+" - NCM: "+cNCM Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(020),C(027) Say "Descricao: "+oDet[nX]:_Prod:_xProd:TEXT Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(028),C(070) MsGet oEdit1 Var cEdit1 F3 "SB1" Valid(ValProd()) Size C(060),C(009) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(040),C(027) Say "Produto digitado: "+cEdit1+" - NCM: "+_NCMdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(048),C(027) Say "Descricao: "+_DESCdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(004),C(194) Button "Processar" Size C(037),C(012) PIXEL OF _oDlg Action(Troca())
				@ C(025),C(194) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())
				oEdit1:SetFocus()
				
				ACTIVATE MSDIALOG _oDlg CENTERED
				If Chkproc!=.T.
					MsgAlert("Produto Cod.: "+cCodPrf+" Nao Encontrado. A Importacao sera interrompida")
					//PutMV("MV_PCNFE",lPcNfe)
					Return Nil
				Else        
					cAux := padr(alltrim(cEdit1),TamSx3("B1_COD")[1])
					cCodPro := cAux
//					cEdit1 := cAux
					dbselectarea("SA5")
					dbsetorder(1)	//A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
					msseek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cCodPro)
					If found()
						RecLock("SA5",.f.)
					Else
						Reclock("SA5",.t.)
					Endif
					
					SA5->A5_FILIAL := xFilial("SA5")
					SA5->A5_FORNECE := SA2->A2_COD
					SA5->A5_LOJA 	:= SA2->A2_LOJA
					SA5->A5_NOMEFOR := SA2->A2_NOME
					SA5->A5_PRODUTO := cCodPro //SB1->B1_COD
					SA5->A5_NOMPROD := oDet[nX]:_Prod:_xProd:TEXT
					//			 		SA5->A5_PRODDES :=
					SA5->A5_CODPRF  := cCodPrf 
					SA5->A5_UNID := right(cUmFor,TamSx3("A5_UNID")[1])
					IF EMPTY(SA5->A5_SITU)  
						SA5->A5_SITU := "C"
					ENDIF
					IF SA5->A5_TEMPLIM = 0.0
						SA5->A5_TEMPLIM :=  1
					ENDIF 
					IF EMPTY(SA5->A5_FABREV)
						SA5->A5_FABREV := "F"					
					ENDIF                  

					SA5->(MsUnlock())
				EndIf
			endif 
			cCodPro := SA5->A5_PRODUTO
				
		Else
			
			cCodPrf:=PadR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSx3("A7_CODCLI")[1])
			Chkproc=.F.
			
			//SA7->(DbOrderNickName("CLIPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR -> A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI  
			dbselectarea("SA7")
			dbsetorder(3)	//A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI
			MsSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cCodPrf)
			If !found()
				If !MsgYesNo ("Produto Cod.: "+cCodPrf+" Nao Encontrado. Digita Codigo de Substituicao?")
//					PutMV("MV_PCNFE",lPcNfe)
					Return Nil
				Endif
				DEFINE MSDIALOG _oDlg TITLE "Dig.Cod.Substituicao" FROM C(177),C(192) TO C(509),C(659) PIXEL
				
				// Cria as Groups do Sistema
				@ C(002),C(003) TO C(071),C(186) LABEL "Dig.Cod.Substituicao " PIXEL OF _oDlg
				
				// Cria Componentes Padroes do Sistema
				@ C(012),C(027) Say "Cod Clie.: "+cCodPrf+" - NCM: "+cNCM Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(020),C(027) Say "Descricao: "+oDet[nX]:_Prod:_xProd:TEXT Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(028),C(070) MsGet oEdit1 Var cEdit1 F3 "SB1" Valid(ValProd()) Size C(060),C(009) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(040),C(027) Say "Cod. Produto: "+cEdit1+" - NCM: "+_NCMdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(048),C(027) Say "Descricao: "+_DESCdigit Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(004),C(194) Button "Processar" Size C(037),C(012) PIXEL OF _oDlg Action(Troca())
				@ C(025),C(194) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())
				oEdit1:SetFocus()
				
				ACTIVATE MSDIALOG _oDlg CENTERED
				If Chkproc!=.T.
					MsgAlert("Produto Cod.: "+cCodPrf+" Nao Encontrado. A Importacao sera interrompida")
//					PutMV("MV_PCNFE",lPcNfe)
					Return Nil
				Else          
					cCodPro := padr(alltrim(cEdit1),TamSx3("B1_COD")[1])
					If SA7->(dbSetOrder(1), dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cCodPro))
						RecLock("SA7",.f.)
					Else
						Reclock("SA7",.t.)
					Endif
					
					SA7->A7_FILIAL := xFilial("SA7")
					SA7->A7_CLIENTE := SA1->A1_COD
					SA7->A7_LOJA 	:= SA1->A1_LOJA
					SA7->A7_DESCCLI := oDet[nX]:_Prod:_xProd:TEXT
					SA7->A7_PRODUTO := cCodPro //SB1->B1_COD
					SA7->A7_CODCLI  := cCodPrf
					SA7->(MsUnlock())
					
				EndIf
			endif 
			cCodPro := SA7->A7_PRODUTO
		Endif
		dbselectarea("SB1")
		dbsetorder(1)
		msseek(xFilial("SB1")+cCodPro)
		If found() .and. !Empty(cNCM) .and. (cNCM != '00000000') .and. (cNCM != '99999999') .And. empty(SB1->B1_POSIPI) //SB1->B1_POSIPI <> cNCM 
			dbselectarea("SYD")
			dbsetorder(1)
			dbseek(xFilial("SYD")+PADR(cNCM,TamSx3("YD_TEC")[1])+SB1->B1_EX_NCM+SB1->B1_EX_NBM)
			nIpi := iif(found(),SYD->YD_PER_IPI,0)
			dbselectarea("SB1")
			RecLock("SB1",.F.)
			Replace B1_POSIPI with cNCM
			replace B1_IPI with nIpi
			MSUnLock()
		Endif

		nQtde := Val(oDet[nX]:_Prod:_qCom:TEXT) //Val(oDet[nX]:_Prod:_qTrib:TEXT)       
		nQtdeNfe := nQtde
		//Se não estiver na mesma UM, converter
		if !(alltrim(cUmFor) == alltrim(SB1->B1_UM))
			if (alltrim(cUmFor) == alltrim(SB1->B1_SEGUM)) .AND. (SB1->B1_CONV > 0)
				nQtde := IIF(SB1->B1_TIPCONV = "D",nQtde*SB1->B1_CONV,nQtde/SB1->B1_CONV)
			elseif (MV_PAR01 == 1) .AND. (SA5->(FieldPos("A5_ZZUMXML")) > 0) .AND. (SA5->(FieldPos("A5_ZZCONV")) > 0) .AND. (SA5->(FieldPos("A5_ZZTIPCO")) > 0) .AND. (alltrim(cUmFor) == alltrim(SA5->A5_ZZUMXML)) .AND. (SA5->A5_ZZCONV > 0)
				nQtde := IIF(SA5->A5_ZZTIPCO = "D",nQtde*SA5->A5_ZZCONV,nQtde/SA5->A5_ZZCONV)
			elseif (MV_PAR01 > 1) .AND. (SA7->(FieldPos("A7_ZZUMXML")) > 0) .AND. (SA7->(FieldPos("A7_ZZCONV")) > 0) .AND. (SA7->(FieldPos("A7_ZZTIPCO")) > 0) .AND. (alltrim(cUmFor) == alltrim(SA7->A7_ZZUMXML)) .AND. (SA7->A7_ZZCONV > 0)
				nQtde := IIF(SA7->A7_ZZTIPCO = "D",nQtde*SA7->A7_ZZCONV,nQtde/SA7->A7_ZZCONV)

			else   
				nAux := nQtde  
				//UM com mais de 2 dígitos na NFe, se as iniciais forem iguais considerar a mesma qtde p/ facilitar
				IF !(ALLTRIM(substr(cUmFor,1,TamSx3("B1_UM")[1])) == alltrim(SB1->B1_UM))
					nQtde := 0
				ENDIF

				DEFINE MSDIALOG _oDlg TITLE "Conversao Unid Medida" FROM C(177),C(192) TO C(509),C(659) PIXEL
				
				@ C(002),C(003) TO C(071),C(186) LABEL "Digite a Qtde em "+SB1->B1_UM PIXEL OF _oDlg
				
				@ C(012),C(027) Say "Prod na NF  : "+cCodPrf+" - "+oDet[nX]:_Prod:_xProd:TEXT Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(020),C(027) Say "Prod Sistema: "+cCodPro+" - "+SB1->B1_DESC Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(028),C(027) Say "Quantidade em "+cUmFor+": "+transform(nAux,"@E 999999.999999") Size C(150),C(008) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(036),C(027) Say "Quantidade em "+SB1->B1_UM+": "
				@ C(035),C(080) MsGet oEdit1 Var nQtde picture "@E 999999.999999" Size C(060),C(009) COLOR CLR_HBLUE PIXEL OF _oDlg
				@ C(004),C(194) Button "Processar" Size C(037),C(012) PIXEL OF _oDlg Action(Troca())
				@ C(025),C(194) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())
				oEdit1:SetFocus()
				
				ACTIVATE MSDIALOG _oDlg CENTERED

				If nQtde <= 0
					MsgAlert("Necessário converter Unid. de Medida")
//					PutMV("MV_PCNFE",lPcNfe)
					Return Nil
				endif
				
			endif
		endif 
				
		
		cProds += ALLTRIM(cCodPro)+'/'

		AAdd(aPedIte,{cCodPro,nQtde,Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/nQtde,TamSx3("D1_VUNIT")[2]),Val(oDet[nX]:_Prod:_vProd:TEXT)})

		if (MV_PAR01 = 1) .and. (ALLTRIM(FWGrpCompany()) == "11") 
			if (SA5->A5_FORNECE = "002511") .AND. (SA5->A5_LOJA = "01")//Exclusivo RECOFARMA!!
				lOk := U_VKitsSA5() //Verificar se cadastro de cabeçalho dos Kits estão OK
				IF !lOk
					RETURN NIL 
				ENDIF 
				if lOk .and. !EMPTY(ALLTRIM(SA5->A5_CODPRCA)) .AND. ( SG1->(dbSetOrder(2), dbSeek(xFilial("SG1")+cCodPro)) ) //Se for TecPolpa e o produto tiver estrutura, ler cód barra
					cAuxCod := PADR(ALLTRIM(SA5->A5_CODPRCA),TAMSX3("B1_COD")[1]," ") //Código do pai da estrutura do Kit
					dbselectarea("SG1")
					dbsetorder(1) //G1_FILIAL+G1_COD+G1_COMP+G1_TRT  
					lLerKits := .t.
					nAuxQtde := ceiling(nQtde)
					msseek(xFilial("SG1")+cAuxCod,.T.)
					IF FOUND()
						dbselectarea("SB1")
						dbsetorder(1)
						msseek(xFilial("SB1")+cAuxCod)
						if found()
							nAuxQtde := ceiling(nQtde) * iif(SB1->B1_QB >= 1,SB1->B1_QB,1)
						endif 
					endif 
					dbselectarea("SG1")
					do while !eof() .and. (SG1->G1_FILIAL == xFilial("SG1")) .AND. (SG1->G1_COD == cAuxCod )
						for i := 1 to nAuxQtde
							if (ALLTRIM(SG1->G1_COMP) == ALLTRIM(cCodPro))
								nQtItKit++
							else 
								nContKit := ceiling(ABS(SG1->G1_QUANT))
								for j := 1 to nContKit
									nQtItKit++
								next j
							endif 
						next i
						dbselectarea("SG1")
						dbskip()
					enddo 
				endif 
			endif 
		endif 
		//SB1->(dbSetOrder(1))
		
	Next nX
	if lLerKits
		aCampos3 := {}
		AADD(aCampos3,{'ZZD_CODBAR'		,'Código Lido','@R (999)9999999(99)9999999999(99)999999(99)9999','36','0'})

		CriaXCODB()

		nLidoKit := ContCodKits()
		cCodBarKit := space(36)
		lFimDlg := .f.
		do while !lFimDlg


			DEFINE MSDIALOG _oDlg TITLE "Ler Códigos Barra Kits" FROM C(177),C(192) TO C(509),C(659) PIXEL
				
			@ C(002),C(003) TO C(071),C(186) LABEL "Entre com os códigos de Barras ("+alltrim(str(nQtItKit))+")" PIXEL OF _oDlg
				//+alltrim(str(nLidoKit))
				@ C(036),C(027) Say "Cód Barras: "
				@ C(035),C(080) MsGet oEdit1 Var cCodBarKit picture "9999999999999999999999999999999999999" Size C(060),C(009) COLOR CLR_HBLUE PIXEL OF _oDlg Valid (LeCodKit(1))
				@ C(046),C(027) Say "Qtde Lidos: "
				@ C(046),C(080) MsGet oEdit2 Var nLidoKit picture "99999" Size C(020),C(007) COLOR CLR_HBLUE PIXEL OF _oDlg when .f.
				@ C(004),C(194) Button "Continuar" Size C(037),C(012) PIXEL OF _oDlg Action(LeCodKit(2))
				@ C(025),C(194) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(LeCodKit(3))
				@ C(046),C(194) Button "Excluir" Size C(037),C(012) PIXEL OF _oDlg Action(LeCodKit(4))
		
				DbSelectArea('XCODBAR')
		
				@ 100,005 TO 190,200 BROWSE "XCODBAR" FIELDS aCampos3 Object _oBrwCodb
				//_oBrwPed2

				oEdit1:SetFocus()
				
			ACTIVATE MSDIALOG _oDlg CENTERED

		enddo 

	endif 

If Select("XCODBAR") <> 0
	XCODBAR->(dbCloseArea())
	//oTempTbl03:Delete()
endif 

	IF lCancelar
		Return Nil
	ENDIF 

	// Retira a Ultima "/" da Variavel cProds
	
	cProds := Left(cProds,Len(cProds)-1)
	
	aCampos := {}
	aCampos2:= {}
	
	AADD(aCampos,{'T9_OK'			,'#','@!','2','0'})
	AADD(aCampos,{'T9_PEDIDO'		,'Pedido','@!','6','0'})
	AADD(aCampos,{'T9_ITEM'			,'Item','@!','3','0'})
	AADD(aCampos,{'T9_PRODUTO'		,'PRODUTO','@!','15','0'})
	AADD(aCampos,{'T9_DESC'			,'Descrição','@!','40','0'})
	AADD(aCampos,{'T9_UM'			,'Un','@!','02','0'})
	AADD(aCampos,{'T9_QTDE'			,'Qtde',PesqPict("SC7","C7_QUANT"),trim(str(TamSx3("C7_QUANT")[1])),trim(str(TamSx3("C7_QUANT")[2]))})
	AADD(aCampos,{'T9_UNIT'			,'Unitario',PesqPict("SC7","C7_PRECO"),trim(str(TamSx3("C7_PRECO")[1])),trim(str(TamSx3("C7_PRECO")[2]))})
	AADD(aCampos,{'T9_TOTAL'		,'Total',PesqPict("SC7","C7_TOTAL"),trim(str(TamSx3("C7_TOTAL")[1])),trim(str(TamSx3("C7_TOTAL")[2]))})
	AADD(aCampos,{'T9_DTPRV'		,'Dt.Prev','','10','0'})
	AADD(aCampos,{'T9_ALMOX'		,'Alm','','4','0'})
	AADD(aCampos,{'T9_OBSERV'		,'Observação','@!','30','0'})
	AADD(aCampos,{'T9_CCUSTO'		,'C.Custo','@!','6','0'})
	AADD(aCampos,{'T9_TES'			,'TES','999','3','0'})
	
	AADD(aCampos2,{'T8_NOTA'		,'N.Fiscal','@!','9','0'})
	AADD(aCampos2,{'T8_SERIE'		,'Serie','@!','3','0'})
	AADD(aCampos2,{'T8_PRODUTO'		,'PRODUTO','@!','15','0'})
	AADD(aCampos2,{'T8_DESC'		,'Descrição','@!','40','0'})
	AADD(aCampos2,{'T8_UM'			,'Un','@!','02','0'})
	AADD(aCampos2,{'T8_QTDE'		,'Qtde',PesqPict("SC7","C7_QUANT"),trim(str(TamSx3("C7_QUANT")[1])),trim(str(TamSx3("C7_QUANT")[2]))})
	AADD(aCampos2,{'T8_UNIT'		,'Unitario',PesqPict("SC7","C7_PRECO"),trim(str(TamSx3("C7_PRECO")[1])),trim(str(TamSx3("C7_PRECO")[2]))})
	AADD(aCampos2,{'T8_TOTAL'		,'Total',PesqPict("SC7","C7_TOTAL"),trim(str(TamSx3("C7_TOTAL")[1])),trim(str(TamSx3("C7_TOTAL")[2]))})
	
	Cria_TC9()
	
	For ni := 1 To Len(aPedIte)                   
		dbselectarea("SB1")
		dbsetorder(1)
		dbseek(xFilial("SB1")+aPedIte[nI,1])
		dbselectarea("XTC8")
		RecLock("XTC8",.t.)
		XTC8->T8_NOTA 	:= Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
		XTC8->T8_SERIE 	:= OIdent:_serie:TEXT
		XTC8->T8_PRODUTO := aPedIte[nI,1]
		XTC8->T8_DESC	:= SB1->B1_DESC //Posicione("SB1",1,xFilial("SB1")+aPedIte[nI,1],"B1_DESC")
		XTC8->T8_UM		:= SB1->B1_UM
		XTC8->T8_QTDE	:= aPedIte[nI,2]
		XTC8->T8_UNIT	:= aPedIte[nI,3]
		XTC8->T8_TOTAL	:= aPedIte[nI,4]
		XTC8->(msUnlock())
	Next
	XTC8->(dbGoTop())
	
	Monta_TC9()
	
	lOk := .f.
	lOut := .f.	//POLIESTER
//	If !Empty(XTC9->(RecCount()))
		
		
		DbSelectArea('XTC9')
		@ 100,005 TO 500,750 DIALOG oDlgPedidos TITLE "Pedidos de Compras Associados ao XML selecionado!"	//Poliester
		
		
		@ 006,005 TO 100,325 BROWSE "XTC9" MARK "T9_OK" FIELDS aCampos Object _oBrwPed
		
		@ 066,330 BUTTON "Marcar"         SIZE 40,15 ACTION MsAguarde({||MarcarTudo()},'Marcando Registros...')
		@ 086,330 BUTTON "Desmarcar"      SIZE 40,15 ACTION MsAguarde({||DesMarcaTudo()},'Desmarcando Registros...')
		@ 106,330 BUTTON "Processar"	  SIZE 40,15 ACTION MsAguarde({|| lOk := .t. , Close(oDlgPedidos)},'Gerando e Enviando Arquivo...')
		@ 183,330 BUTTON "Sair"			  SIZE 40,15 ACTION MsAguarde({|| lOut := .t., Close(oDlgPedidos)},'Saindo do Sistema')	//POLIESTER
//		@ 183,330 BUTTON "Sair"           SIZE 40,15 ACTION Close(oDlgPedidos)
		
//		Processa({||  } ,"Selecionando Informacoes de Pedidos de Compras...")
		
		DbSelectArea('XTC8')
		
		@ 100,005 TO 190,325 BROWSE "XTC8" FIELDS aCampos2 Object _oBrwPed2
		
		DbSelectArea('XTC9')
		
		_oBrwPed:bMark := {|| Marcar()}
		
		ACTIVATE DIALOG oDlgPedidos CENTERED
		
//	Endif

//Verifica se o usuário clicou no botão para sair, anteriormente se ele clicasse para sair o sistema ainda fazia a inserçao dos dados, agora não. - Poliester
	If lOut
		EXIT
	Endif
	
	// Verifica se o usuario selecionou algum pedido de compra
	
	dbSelectArea("XTC9")
	dbGoTop()
	ProcRegua(Reccount())
	
	lMarcou := .f.
	
	While !Eof() .And. lOk
		IncProc()
		If XTC9->T9_OK  <> _cMarca
			dbSelectArea("XTC9")
			XTC9->(dbSkip(1))
			Loop
		Else
			lMarcou := .t.
			Exit
		Endif
		
		XTC9->(dbSkip(1))
	Enddo
	
	
	
	
	For nX := 1 To Len(oDet)
		
		// Validacao: Produto Existe no SB1 ?
		// Se não existir, abrir janela c/ codigo da NF e descricao para digitacao do cod. substituicao.
		// Deixar opção para cancelar o processamento //  Descricao: oDet[nX]:_Prod:_xProd:TEXT
		
		aLinha := {}
		cCodPrf:=PADR(AllTrim(oDet[nX]:_Prod:_cProd:TEXT),TamSX3( "A5_CODPRF" )[1])
		
		oAux := oDet[nX]
		_lVerNCM := .f.
		fValTagD( oAux )
		/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
		//cNCM:=IIF(Type("oAux:_Prod:_NCM")=="U",space(12),oAux:_Prod:_NCM:TEXT)
		cNCM := IIF( _lVerNCM, space(12), oAux:_Prod:_NCM:TEXT )
		Chkproc=.F.
		
		If MV_PAR01 == 1
			SA5->(DbOrderNickName("FORPROD"))   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
			SA5->(dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+cCodPrf))
			SB1->(dbSetOrder(1) , dbSeek(xFilial("SB1")+SA5->A5_PRODUTO))  
			
		Else
			//SA7->(DbOrderNickName("CLIPROD"))
			dbselectarea("SA7")
			dbsetorder(3)
			SA7->(dbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cCodPrf))
			SB1->(dbSetOrder(1) , dbSeek(xFilial("SB1")+SA7->A7_PRODUTO))
		Endif
		
		aadd(aLinha,{"D1_COD",SB1->B1_COD,Nil,Nil}) //Emerson Holanda
		If Val(oDet[nX]:_Prod:_qCom:TEXT) != 0
			aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qCom:TEXT),Nil,Nil})
			aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qCom:TEXT),6),Nil,Nil})
		Else
			aadd(aLinha,{"D1_QUANT",Val(oDet[nX]:_Prod:_qTrib:TEXT),Nil,Nil})
			aadd(aLinha,{"D1_VUNIT",Round(Val(oDet[nX]:_Prod:_vProd:TEXT)/Val(oDet[nX]:_Prod:_qTrib:TEXT),6),Nil,Nil})
		Endif
		//Val(oDet[nX]:_Prod:_vUnCom:TEXT)
		aadd(aLinha,{"D1_TOTAL",Val(oDet[nX]:_Prod:_vProd:TEXT),Nil,Nil})
		_cfop:=oDet[nX]:_Prod:_CFOP:TEXT
		If Left(Alltrim(_cfop),1)="5"
			_cfop:=Stuff(_cfop,1,1,"1")
		Else
			_cfop:=Stuff(_cfop,1,1,"2")
		Endif
		oAux := oDet[nX]
		//Número FCI do Item
		cFci := "" 
		_lVerFCI := .f.
		_lVerDes := .f.
		_lVerI00 := .f.
		_lVerI10 := .f.
		_lVerI20 := .f.
		_lVerI30 := .f.
		_lVerI40 := .f.
		_lVerI51 := .f.
		_lVerI60 := .f.
		_lVerI70 := .f.
		_lVerI90 := .f.
		_lVerISN := .f.
		fValTagD( oAux )
		/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
		//if Type("oAux:_Prod:_nFCI:TEXT") <> "U"
		if _lVerFCI
			cFci := oAux:_Prod:_nFCI:TEXT
		endif 
		//	      aadd(aLinha,{"D1_CF",_cfop,Nil,Nil})
		//If Type("oAux:_Prod:_vDesc") <> "U"
		If _lVerDes
            aadd(aLinha,{"D1_VALDESC",Val(oDet[nX]:_Prod:_vDesc:TEXT),Nil,Nil})
        Else 
            aadd(aLinha,{"D1_VALDESC",0,Nil,Nil})            
        Endif
        lCsosn := .f. //Define se a origem é CSOSN (Empresa do Simples)
		Do Case
			/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
			/*
			Case Type("oAux:_Imposto:_ICMS:_ICMS00") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS00
			Case Type("oAux:_Imposto:_ICMS:_ICMS10") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS10
			Case Type("oAux:_Imposto:_ICMS:_ICMS20") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS20
			Case Type("oAux:_Imposto:_ICMS:_ICMS30") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS30
			Case Type("oAux:_Imposto:_ICMS:_ICMS40") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS40
			Case Type("oAux:_Imposto:_ICMS:_ICMS51") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS51
			Case Type("oAux:_Imposto:_ICMS:_ICMS60") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS60
			Case Type("oAux:_Imposto:_ICMS:_ICMS70") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS70
			Case Type("oAux:_Imposto:_ICMS:_ICMS90") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMS90
			Case Type("oAux:_Imposto:_ICMS:_ICMSSN101") <> "U"
				oICM:=oAux:_Imposto:_ICMS:_ICMSSN101
				lCsosn := .t.
			*/
			Case _lVerI00
				oICM:=oAux:_Imposto:_ICMS:_ICMS00
			Case _lVerI10
				oICM:=oAux:_Imposto:_ICMS:_ICMS10
			Case _lVerI20
				oICM:=oAux:_Imposto:_ICMS:_ICMS20
			Case _lVerI30
				oICM:=oAux:_Imposto:_ICMS:_ICMS30
			Case _lVerI40
				oICM:=oAux:_Imposto:_ICMS:_ICMS40
			Case _lVerI51
				oICM:=oAux:_Imposto:_ICMS:_ICMS51
			Case _lVerI60
				oICM:=oAux:_Imposto:_ICMS:_ICMS60
			Case _lVerI70
				oICM:=oAux:_Imposto:_ICMS:_ICMS70
			Case _lVerI90
				oICM:=oAux:_Imposto:_ICMS:_ICMS90
			Case _lVerISN
				oICM:=oAux:_Imposto:_ICMS:_ICMSSN101
				lCsosn := .t.
		EndCase
		CST_Aux := ""
		_lVerIOri := .f.
		_lVerICST := .f.
		_lVerICSO := .f.
		fValTagI( oICM )
		do case
		   /*
           case (Type("oICM:_orig:TEXT") <> "U") .and. !lCsosn .and. (Type("oICM:_CST:TEXT") <> "U")
			    CST_Aux:=Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT)
           case (Type("oICM:_orig:TEXT") <> "U") .and. lCsosn .and. (Type("oICM:_CSOSN:TEXT") <> "U")
                //ATENÇÃO!!(21/11/18) Será passada uma relação de conversão de CSOSN para CST de empresa fornecedoras do Simples para entradas em empresas RPA!!
                //CST_Aux:=Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CSOSN:TEXT)
                CST_Aux:=Alltrim(oICM:_orig:TEXT)+IIF(SB1->B1_TIPO = "MP","00","90")*/
           case _lVerIOri .and. !lCsosn .and. _lVerICST
			    CST_Aux:=Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT)
           case _lVerIOri .and. lCsosn .and. _lVerICSO
                //ATENÇÃO!!(21/11/18) Será passada uma relação de conversão de CSOSN para CST de empresa fornecedoras do Simples para entradas em empresas RPA!!
                //CST_Aux:=Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CSOSN:TEXT)
                CST_Aux:=Alltrim(oICM:_orig:TEXT)+IIF(SB1->B1_TIPO = "MP","00","90")
		EndCase
		
		aadd(aLinha,{"D1_CLASFIS",CST_Aux,Nil,Nil})

/*		
		nBaseSt := 0
		nVlrSt := 0
		nAliqSt := 0
		If (Type("oICM:_VBCST:TEXT") <> "U") .AND. !EMPTY(oICM:_VBCST:TEXT)
			nBaseSt := VAL(oICM:_VBCST:TEXT)
			nVlrSt := VAL(oICM:_VICMSST:TEXT) //vICMSST
			nAliqSt := VAL(oICM:_PICMSST:TEXT)
		Endif

		aadd(aLinha,{"D1_BRICMS",nBaseSt,Nil,Nil})
		aadd(aLinha,{"D1_ALIQSOL",nAliqSt,Nil,Nil})
		aadd(aLinha,{"D1_ICMSRET",nVlrSt,Nil,Nil})
 */
//		If lMarcou

			//Cleber Orati => colocando .F. na terceira coluna faz com que não valide o pedido
			//no caso de se passar pedido em branco.
			aadd(aLinha,{"D1_PEDIDO",'',.f.,Nil})
			aadd(aLinha,{"D1_ITEMPC",'',.f.,Nil})
//		Endif 
		
		//Cleber(17/05/17)-> informar Almoxarifado, caso exista pedido reproduzir do pedido de compra     
		cAux := U_DetLocPad(SB1->B1_COD)
		aadd(aLinha,{"D1_LOCAL",cAux,Nil,Nil}) 

       	if !empty(CST_Aux)
			dbselectarea("SD1")
			if SD1->((FieldPos("D1_XCST")) > 0)     
				aadd(aLinha,{"D1_XCST",CST_Aux,Nil,Nil}) 
			endif       
		endif 

       	if !empty(cFci)
			dbselectarea("SD1")
			if (SD1->(FieldPos("D1_FCICOD")) > 0)     
				aadd(aLinha,{"D1_FCICOD",cFci,Nil,Nil}) 
			endif       
		endif 

		//		If cTipo=='D' // Nota Fiscal de Devolucao
		//			aadd(aLinha,{"D1_NFORI",'',Nil,Nil})
		//			aadd(aLinha,{"D1_ITEMORI",'',Nil,Nil})
		//			aadd(aLinha,{"D1_SERIORI",'',Nil,Nil})
		//		Endif

		
		
		aadd(aItens,aLinha)
	Next nX
	
	
	If lMarcou
		
		dbSelectArea("XTC9")
		dbGoTop()
		ProcRegua(Reccount())
		
		While !Eof() .And. lOk
			IncProc()
			If XTC9->T9_OK  <> _cMarca
				dbSelectArea("XTC9")
				XTC9->(dbSkip(1))
				Loop
			Endif
			
			For nItem := 1 To Len(aItens)
				If AllTrim(aItens[nItem,1,2]) == AllTrim(XTC9->T9_PRODUTO) .And. Empty(aItens[nItem,7,2])
					If !Empty(XTC9->T9_QTDE)  
						aItens[nItem,7,2] := XTC9->T9_PEDIDO
						aItens[nItem,8,2] := XTC9->T9_ITEM 
						aItens[nItem,9,2] := XTC9->T9_LOCAL //Cleber(17/05/17) -> Reproduzir mesmo armazem do pedido de compra
						dbselectarea("SC7")
						dbsetorder(1)
						
						if (SC7->(FieldPos("C7_XCST")) > 0) .and. !empty(aItens[nItem,6,2])     
							dbselectarea("SC7")
							dbseek(xFilial("SC7")+XTC9->T9_PEDIDO+XTC9->T9_ITEM)
							if found()
								reclock("SC7",.F.)
								SC7->C7_XCST := aItens[nItem,6,2]
								SC7->(MsUnlock())
							endif   
						endif 
						
						If RecLock('XTC9',.f.)
							If (XTC9->T9_QTDE-aItens[nItem,2,2]) < 0
								XTC9->T9_QTDE := 0
							Else
								XTC9->T9_QTDE := (XTC9->T9_QTDE - aItens[nItem,2,2])
							Endif
							XTC9->(MsUnlock())
						Endif
					Endif
				Endif
			Next
			
			
			XTC9->(dbSkip(1))
		Enddo
		
		XTC8->(dbCloseArea())
		oTempTbl02:Delete()
		XTC9->(dbCloseArea())
		oTempTbl01:Delete()
       	If Select("XCODBAR") <> 0
			XCODBAR->(dbCloseArea())
			//oTempTbl03:Delete()
		endif 


	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Teste de Inclusao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItens) > 0 
	
		lMsErroAuto := .f.
		lMsHelpAuto := .f.
		
		SB1->( dbSetOrder(1) )
		SA2->( dbSetOrder(1) )
		
		nModulo := 2  //COMPRAS
		dbselectarea("SD1")
		dbsetorder(1)
		dbselectarea("SF1")
		dbsetorder(1)             
		
		MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItens,3)
		
		IF lMsErroAuto 
			//(Cleber)-> Copiar o arquivo pra pasta de erros só faz ter que voltar o arquivo novamente para posterior processamento.
		    /*
			if ("PROCESSADOS\" $ Upper(cArquivo))
				xFile := STRTRAN(Upper(cArquivo),"XMLNFE\PROCESSADOS\", "XMLNFE\ERRO\")
			ELSE 
				xFile := STRTRAN(Upper(cArquivo),"XMLNFE\", "XMLNFE\ERRO\")
			ENDIF 
			
			COPY FILE &cArquivo TO &xFile
			
			FErase(cArquivo)
			*/
			MSGALERT("ERRO NO PROCESSO")
			MostraErro()
		Else        
			dbselectarea("SF1")
			dbsetorder(1)
			dbseek(xFilial("SF1")+cNroNf+cSerie+cFornec+cLoja+cTipoNf)
			If found()
				ConfirmSX8()
				/*
				if !empty(cCodBars)
					dbselectarea("SF1")
					Reclock("SF1",.F.)
					SF1->F1_HISTRET := cCodBars
					msunlock()
				endif 
*/
				if !("PROCESSADOS\" $ Upper(cArquivo))
					xFile := STRTRAN(Upper(cArquivo),"XMLNFE\", "XMLNFE\PROCESSADOS\")
				
					COPY FILE &cArquivo TO &xFile
				
					FErase(cArquivo)
				endif 
				
				MSGALERT(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Gerada Com Sucesso!")
				
				
				
				//				If SF1->F1_PLUSER <> __cUserId
				//					If Reclock("SF1",.F.)
				//						SF1->F1_PLUSER := __cUserId
				//					EndIf
				//				EndIf
				//				Desabilitado pois a Solange e Luciene serão as unicas que poderão classificar notas
				/*			IF Msgyesno("Deseja Efetuar a Classificação da Nota " + Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " Agora ?")
				_aArea := GetArea()
				//A103NFiscal("SF1",SF1->(Recno()),4,.f.,.f.)
				dbSelectArea("SF1")
				SET FILTER TO AllTrim(F1_DOC) = Alltrim(aCabec[3,2]) .AND. AllTrim(F1_SERIE) == aCabec[4,2]
				MATA103()
				dbSelectArea("SF1")
				SET FILTER TO
				RetArea(_aArea)
				Endif
				*/
				/*
				PswOrder(1)
				PswSeek(__cUserId,.T.)
				aInfo := PswRet(1)
				*/
				cAssunto := 'Geração da pre nota '+Alltrim(aCabec[3,2])+' Serie '+Alltrim(aCabec[4,2]) + ' Usr. Id: '+__cUserId
				cTexto   := 'A pre nota '+Alltrim(aCabec[3,2])+' Serie: '+Alltrim(aCabec[4,2]) +;
				' do tipo '+Alltrim(aCabec[1,2]) + ' do fornecedor '+ Alltrim(aCabec[6,2])+' loja ' + Alltrim(aCabec[7,2]) + ;
				' foi gerada com sucesso. Por gentileza Classifique a Pré-Nota na rotina DOC.ENTRADA.' 
				cAuxMail := alltrim(UsrRetMail(__cUserId))
/*
				if empty(cAuxMail)
					cAuxMail := alltrim(UsrRetMail("000000"))
				endif 
*/
				if !empty(cAuxMail)				
					cPara    := cAuxMail
					cCC      := ''
					cArquivo := ''
					U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo) //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
				endif 
			Else
				MSGALERT(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - Pré Nota Não Gerada - Tente Novamente !")
			EndIf
		EndIf
	Endif
Enddo
//PutMV("MV_PCNFE",lPcNfe)
Return




Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)

Static Function ValProd()
	_DESCdigit=Alltrim(GetAdvFVal("SB1","B1_DESC",XFilial("SB1")+cEdit1,1,""))
	_NCMdigit=GetAdvFVal("SB1","B1_POSIPI",XFilial("SB1")+cEdit1,1,"")
Return(ExistCpo("SB1"))

Static Function Troca()  
//Local lBloqueado
Local nIpi
Chkproc=.T.
//cCodPrf=cEdit1
If Empty(SB1->B1_POSIPI) .and. !Empty(cNCM) .and. cNCM != '00000000' //Emerson Holanda alterar o ncm se houver discrepancia
	dbselectarea("SYD")
	dbsetorder(1)
	dbseek(xFilial("SYD")+PADR(cNCM,TamSx3("YD_TEC")[1])+SB1->B1_EX_NCM+SB1->B1_EX_NBM)
	nIpi := iif(found(),SYD->YD_PER_IPI,0)
	dbselectarea("SB1")
	RecLock("SB1",.F.)
	Replace B1_POSIPI with cNCM
	replace B1_IPI with nIpi
	MSUnLock()
Endif

if (MV_PAR01 == 1) .AND. (nQtde > 0) .AND. (SA5->(FieldPos("A5_ZZUMXML")) > 0) .AND. (SA5->(FieldPos("A5_ZZCONV")) > 0) .AND. (SA5->(FieldPos("A5_ZZTIPCO")) > 0) 
	IF 	(nQtde > 0) .and. !(alltrim(cUmFor) == alltrim(SB1->B1_UM))
		dbselectarea("SA5")
		reclock("SA5",.F.)
		SA5->A5_ZZUMXML := alltrim(cUmFor)
		SA5->A5_ZZCONV := round(nQtde/nQtdeNfe,TamSx3("A5_ZZCONV")[2])
		SA5->A5_ZZTIPCO := "D"
		MSUnLock()
	ENDIF
endif 

_oDlg:End()
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Chk_File  ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamado pelo grupo de perguntas EESTR1			          º±±
±±º          ³Verifica se o arquivo em &cVar_MV (MV_PAR06..NN) existe.    º±±
±±º          ³Se não existir abre janela de busca e atribui valor a       º±±
±±º          ³variavel Retorna .T.										  º±±
±±º          ³Se usuário cancelar retorna .F.							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Texto da Janela		                                      º±±
±±º          ³Variavel entre aspas.                                       º±±
±±º          ³Ex.: Chk_File("Arquivo Destino","mv_par06")                 º±±
±±º          ³VerificaSeExiste? Logico - Verifica se arquivo existe ou    º±±
±±º          ³nao - Indicado para utilizar quando o arquivo eh novo.      º±±
±±º          ³Ex. Arqs. Saida.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Chk_F(cTxt, cVar_MV, lChkExiste)
Local lExiste := File(&cVar_MV)
Local cTipo := "Arquivos XML   (*.XML)  | *.XML | Todos os Arquivos (*.*)    | *.* "
Local cArquivo := ""

//Verifica se arquivo não existe
If lExiste == .F. .or. !lChkExiste
	cArquivo := cGetFile( cTipo,OemToAnsi(cTxt))
	If !Empty(cArquivo)
		lExiste := .T.
		&cVar_Mv := cArquivo
	Endif
Endif
Return (lExiste .or. !lChkExiste)

//******************************************
Static Function MarcarTudo()
DbSelectArea('XTC9')
dbGoTop()
While !Eof()
	MsProcTxt('Aguarde...')
	RecLock('XTC9',.F.)
	XTC9->T9_OK := _cMarca
	MsUnlock()
	DbSkip()
EndDo
DbGoTop()
DlgRefresh(oDlgPedidos)
SysRefresh()
Return(.T.)

//******************************************
Static Function DesmarcaTudo()
DbSelectArea('XTC9')
dbGoTop()
While !Eof()
	MsProcTxt('Aguarde...')
	RecLock('XTC9',.F.)
	XTC9->T9_OK := ThisMark()
	MsUnlock()
	DbSkip()
EndDo
DbGoTop()
DlgRefresh(oDlgPedidos)
SysRefresh()
Return(.T.)


******************************************
Static Function Marcar()
DbSelectArea('XTC9')
RecLock('XTC9',.F.)
If Empty(XTC9->T9_OK)
	XTC9->T9_OK := _cMarca
Endif
MsUnlock()
SysRefresh()
Return(.T.)

/******************************************************/
Static FUNCTION Cria_TC9()
       If Select("XTC9") <> 0
          XTC9->(dbCloseArea())
       Endif
       If Select("XTC8") <> 0
          XTC8->(dbCloseArea())
       Endif

       aFields   := {}
       AADD(aFields,{"T9_OK"     ,"C",02,0})
       AADD(aFields,{"T9_PEDIDO" ,"C",06,0})
       AADD(aFields,{"T9_ITEM"   ,"C",04,0})
       AADD(aFields,{"T9_PRODUTO","C",15,0})
       AADD(aFields,{"T9_DESC"   ,"C",40,0})
       AADD(aFields,{"T9_UM"     ,"C",02,0})
       AADD(aFields,{"T9_QTDE"   ,"N",TamSx3("C7_QUANT")[1],TamSx3("C7_QUANT")[2]})
       AADD(aFields,{"T9_UNIT"   ,"N",TamSx3("C7_PRECO")[1],TamSx3("C7_PRECO")[2]})
       AADD(aFields,{"T9_TOTAL"  ,"N",TamSx3("C7_TOTAL")[1],TamSx3("C7_TOTAL")[2]})
       AADD(aFields,{"T9_DTPRV"  ,"D",08,0})
       AADD(aFields,{"T9_ALMOX"  ,"C",04,0})
       AADD(aFields,{"T9_OBSERV" ,"C",30,0})
       AADD(aFields,{"T9_CCUSTO" ,"C",06,0})
       AADD(aFields,{"T9_TES" ,"C",3,0})
       AADD(aFields,{"T9_REG" ,"N",10,0})     
       //Cleber(17/05/17)->pegar local do pedido de compra para MC
       AADD(aFields,{"T9_LOCAL" ,"C",4,0})
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cArq:=Criatrab(aFields,.T.)
       //DBUSEAREA(.t.,,cArq,"XTC9")
       oTempTbl01 := FWTemporaryTable():New( "XTC9" )
       oTempTbl01:SetFields( aFields )
       oTempTbl01:Create()
       /********************************************************************************************************************************/

       aFields2   := {}
       AADD(aFields2,{"T8_NOTA" ,"C",09,0})
       AADD(aFields2,{"T8_SERIE"   ,"C",03,0})
       AADD(aFields2,{"T8_PRODUTO","C",15,0})
       AADD(aFields2,{"T8_DESC"   ,"C",40,0})
       AADD(aFields2,{"T8_UM"     ,"C",02,0})
       AADD(aFields2,{"T8_QTDE"   ,"N",TamSx3("C7_QUANT")[1],TamSx3("C7_QUANT")[2]})
       AADD(aFields2,{"T8_UNIT"   ,"N",TamSx3("C7_PRECO")[1],TamSx3("C7_PRECO")[2]})
       AADD(aFields2,{"T8_TOTAL"  ,"N",TamSx3("C7_TOTAL")[1],TamSx3("C7_TOTAL")[2]})
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cArq2:=Criatrab(aFields2,.T.)
       //DBUSEAREA(.t.,,cArq2,"XTC8")
       oTempTbl02 := FWTemporaryTable():New( "XTC8" )
       oTempTbl02:SetFields( aFields2 )
       oTempTbl02:Create()
       /********************************************************************************************************************************/
Return


********************************************
Static Function Monta_TC9()
Local cQuery
Local _nX
// Irá efetuar a checagem de pedidos de compras
// em aberto para este fornecedor e os itens desta nota fiscal a ser importa
// será demonstrado ao usuário se o pedido de compra deverá ser associado
// a entrada desta nota fiscal

cQuery := ""
cQuery += " SELECT  C7_NUM T9_PEDIDO,     "
cQuery += " 		C7_ITEM T9_ITEM,    "
cQuery += " 	    C7_PRODUTO T9_PRODUTO, "
cQuery += " 		B1_DESC T9_DESC,    "
cQuery += " 		B1_UM T9_UM,		"
cQuery += " 		C7_QUANT T9_QTDE,   "
cQuery += " 		C7_PRECO T9_UNIT,   "
cQuery += " 		C7_TOTAL T9_TOTAL,   "
cQuery += " 		C7_DATPRF T9_DTPRV,  "
cQuery += " 		C7_LOCAL T9_ALMOX, "
cQuery += " 		C7_OBS T9_OBSERV, "
cQuery += " 		C7_CC T9_CCUSTO, "
cQuery += " 		C7_TES T9_TES, "
cQuery += " 		C7_LOCAL T9_LOCAL, "
cQuery += " 		SC7.R_E_C_N_O_ T9_REG "
cQuery += " FROM " + RetSqlName("SC7") + " SC7 WITH (NOLOCK) " + ;
"LEFT OUTER JOIN "+RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (C7_PRODUTO = B1_COD) "
cQuery += " WHERE (C7_FILIAL = '" + xFilial("SC7") + "') "
cQuery += " AND (SC7.D_E_L_E_T_ <> '*') "
cQuery += " AND (C7_QUANT > C7_QUJE)  "
cQuery += " AND (C7_RESIDUO = '')  "
//	cQuery += " AND C7_TPOP <> 'P'  "
cQuery += " AND (C7_CONAPRO <> 'B')  "
cQuery += " AND (C7_ENCER = '') "
//	cQuery += " AND C7_CONTRA = '' "
//	cQuery += " AND C7_MEDICAO = '' "
cQuery += " AND (C7_FORNECE = '" + cFornec + "') "
cQuery += " AND (C7_LOJA = '" + cLoja + "') "
cQuery += " AND C7_PRODUTO IN" + FormatIn( cProds, "/")
If MV_PAR01 <> 1
	cQuery += " AND 1 > 1 "
Endif
cQuery += " ORDER BY T9_PEDIDO, T9_ITEM, T9_PRODUTO "
//cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CAD",.T.,.T.)
TcSetField("CAD","T9_DTPRV","D",8,0)

Dbselectarea("CAD")

While CAD->(!EOF())
	RecLock("XTC9",.T.)
	For _nX := 1 To Len(aFields)
		If !(aFields[_nX,1] $ 'T9_OK')
			If aFields[_nX,2] = 'C'
				_cX := 'XTC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
			Else
				_cX := 'XTC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
			Endif
			_cX := &_cX
		Endif
	Next
	XTC9->T9_OK := _cMarca //ThisMark()
	MsUnLock()
	
	DbSelectArea('CAD')
	CAD->(dBSkip())
EndDo

Dbselectarea("CAD")
DbCloseArea()
Dbselectarea("XTC9")
DbGoTop()

/*
_cIndex:=Criatrab(Nil,.F.)
_cChave:="T9_PEDIDO"
Indregua("XTC9",_cIndex,_cChave,,,"Ordenando registros selecionados...")
DbSetIndex(_cIndex+ordbagext())
*/
SysRefresh()
Return

Static Function CriaXCODB()
Local _cArea := Alias()

If Select("XCODBAR") <> 0
	XCODBAR->(dbCloseArea())
	//oTempTbl03:Delete()
endif 

aFields3   := {}
AADD(aFields3,{"ZZD_CODBAR"     ,"C",TamSx3("ZZD_CODBAR")[1],0})

oTempTbl03 := FWTemporaryTable():New( "XCODBAR" )
oTempTbl03:SetFields( aFields3 )
oTempTbl03:Create()



if !empty(_cArea)
   dbSelectArea(_cArea)
endif 
return


Static Function GetArq(cArquivo)
	cCodBar := ""
	cArquivo:= cGetFile( "Arquivo NFe (*.xml) | *.xml", "Selecione o Arquivo de Nota Fiscal XML",,Caminho,.F.,nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE) ) //Exerga Unidade Mapeadas - Poliester
Return(cArquivo)


StatiC Function Fecha()
cCodBar := ""
Close(_oPT00005)     
lOut := .t.
Return

/*
Static Function AchaFile(cArqLoc)
Local cCaminho,cQuery,cPasta,cEnv,nQtdePastas
Local lOk := .f.
Local nHdl,aFiles,nArq,nTamFile,nBtLidos,cChave,i,lAchouBD,nVezes
aFiles := {}
cChave := alltrim(cCodBar)
If Empty(cChave)
	Return(.t.)
Endif

if len(cChave) != 44
	MsgAlert("Tamanho da chave deverá ter 44 dígitos! Corrija por favor", "Atencao!")
	return(.f.)
endif 	

cPasta := alltrim(GetSrvProfString ("ROOTPATH",""))+"\system\XMLNFe\"

lAchouBD := .f. //Verifica se existe o xml na tabela XMLNFE do banco de dados OU na tabela SKO ou na tabela  SPED050 
cArquivo := ""
cEnv := UPPER(ALLTRIM(GetEnvServer()))
cQuery := "SELECT FILIAL FROM XMLNFE WHERE (CHVNFE = '"+cChave+"') AND (ISNULL(XMLNFE,'') > '')"
TCQuery cQuery ALIAS "TMPNF" NEW
dbselectarea("TMPNF")
IF TMPNF->(!EOF())
	lAchouBD := .t.
//	cPasta := "C:\"+IIF(cEnv = "P12TESTE","P12TESTE","TOTVS12")+"\Microsiga\protheus_data\system\XMLNFe\"
	
	cQuery := ";declare @cNf varchar(max); set @cNf = (SELECT XMLNFE FROM XMLNFE WHERE (CHVNFE = '"+cChave+"') AND (ISNULL(XMLNFE,'') > '')); "+;
	"EXEC WriteToFile '"+cPasta+cChave+"X.XML', @cNf"
	TCSQLEXEC(cQuery)

	cArquivo := cChave+"X.XML"
ENDIF 
dbselectarea("TMPNF")
dbclosearea()


IF !lAchouBD
	cQuery := "SELECT TOP 1 R_E_C_N_O_ AS REG FROM SPED050 WHERE (D_E_L_E_T_ <> '*') AND (DOC_CHV = '"+cChave+"') AND (XML_ERP IS NOT NULL)"
	TCQuery cQuery ALIAS "TMPNF" NEW
	dbselectarea("TMPNF")
	IF TMPNF->(!EOF())
		lAchouBD := .t.
//		cPasta := "C:\"+IIF(cEnv = "P12TESTE","P12TESTE","TOTVS12")+"\Microsiga\protheus_data\system\XMLNFe\"
	
		cQuery := ";declare @cNf varchar(max); set @cNf = (SELECT CONVERT(varchar(MAX),convert(varbinary(MAX),XML_ERP)) AS XMLNFE FROM SPED050 WHERE (R_E_C_N_O_ = "+ALLTRIM(STR(TMPNF->REG))+") ); "+;
		"EXEC WriteToFile '"+cPasta+cChave+"X.XML', @cNf"
		TCSQLEXEC(cQuery)

		cArquivo := cChave+"X.XML"
	ENDIF

	dbselectarea("TMPNF")
	dbclosearea()
ENDIF  

nVezes := 0
do while !lOk .and. (nVezes < 2)
	nVezes++ 

	nQtdePastas := iif(lAchouBD,1,2)
	for i := 1 to nQtdePastas
		aFiles := {}
		cCaminho := alltrim(Caminho)
		if substr(cCaminho,len(cCaminho),1) != "\"
			cCaminho += "\"
		endif
		if i == 2
			cCaminho += "PROCESSADOS\"
		endif 
		
		if !lAchouBD
			aFiles := Directory(cCaminho+"*.XML", "D")
		else
			aadd(aFiles,{cArquivo,1})
		endif 
			
		For nArq := 1 To Len(aFiles)
			cArquivo := AllTrim(cCaminho+aFiles[nArq,1])
	
			nHdl    := fOpen(cArquivo,0)
			If nHdl < 0
				MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! ERRO:"+StrZero(FERROR(), 1)+"!", "Atencao!")
				loop      
			Endif
			nTamFile := fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
			nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
			fClose(nHdl)
			If AT("INFCTE ID",UPPER(cBuffer)) <= 0 //Não ler conhecimentos de frete
				If AT("NFE"+AllTrim(cChave),UPPER(cBuffer)) > 0
					lOk := .t.
					Exit
				Endif                        
			ENDIF 
		Next
		if lOk
			exit
		endif 
	next
	//Só funciona se manifestar antes
	//if !lOk .and. (nVezes == 1) // Se não achou o arquivo, tentar baixar da receita
	//	U_zBxXML(cChave)
	//endif 
ENDDO  
If !lOk
	cArquivo := ""
	MsgAlert("Nenhum Arquivo Encontrado, Por Favor Selecione a Opção Arquivo e Faça a Busca na Arvore de Diretórios!")  
Endif

Return(lOk)
*/
//12/07/21->Nova versão, pegando direto das tabelas (Cleber)
Static Function AchaFile(cArqLoc)
Local cQuery,nPos
Local lOk := .f.
Local aFiles,nTamFile,cChave,i,lAchouBD
aFiles := {}
cChave := alltrim(cCodBar)
If Empty(cChave)
	Return(.t.)
Endif

if len(cChave) != 44
	MsgAlert("Tamanho da chave deverá ter 44 dígitos! Corrija por favor", "Atencao!")
	return(.f.)
endif 	

//cPasta := alltrim(GetSrvProfString ("ROOTPATH",""))+"\system\XMLNFe\"

lAchouBD := .f. //Verifica se existe o xml na tabela XMLNFE do banco de dados OU na tabela SKO ou na tabela  SPED050 ou na tabela ZNF
cArquivo := ""

if !empty(alltrim(RetSqlName("ZNF"))) //Se existe a tabela ZNF 
	dbselectarea("ZNF")
	if ZNF->(FieldPos("ZNF_XML")) > 0 //Se estamos falando da tabela ZNF da B2FINANCE que abriga os xmls das NFes
		dbsetorder(1)
		dbseek(xFilial("ZNF")+cChave)
		if found()
			cBuffer := ZNF->ZNF_XML
			if cBuffer = NIL
				cBuffer := ""
			endif 
		endif 
	endif 
endif 

if !empty(cBuffer)
	lAchouBD := .t.
endif 

IF !lAchouBD

	cQuery := "SELECT CONVERT(VARCHAR(8000),XMLNFE) AS NOTA,LEN(XMLNFE) AS TAMNF "+;
	"FROM XMLNFE WHERE (CHVNFE = '"+cChave+"') AND (ISNULL(XMLNFE,'') > '')"
	TCQuery cQuery ALIAS "TMPNF" NEW
	dbselectarea("TMPNF")

	IF TMPNF->(!EOF())
		lAchouBD := .t.
	
		cBuffer := alltrim(TMPNF->NOTA)
		nTamFile := TMPNF->TAMNF
		if nTamFile > 8000
			for i := 2 to ceiling(nTamFile/8000)
				dbselectarea("TMPNF")
				dbclosearea()
				nPos := ((i-1)*8000)+1

				cQuery := "SELECT CONVERT(VARCHAR(8000),SUBSTRING(XMLNFE,"+alltrim(str(nPos))+",8000)) AS NOTA "+;
				"FROM XMLNFE WHERE (CHVNFE = '"+cChave+"') AND (ISNULL(XMLNFE,'') > '')"
				TCQuery cQuery ALIAS "TMPNF" NEW
				cBuffer += alltrim(TMPNF->NOTA)
			next 
		endif 
	ENDIF 
	dbselectarea("TMPNF")
	dbclosearea()
ENDIF 


IF !lAchouBD
	cQuery := "WITH TMP AS (SELECT CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),XML_ERP)) AS NOTA FROM SPED050 WHERE (D_E_L_E_T_ <> '*') AND (DOC_CHV = '"+cChave+"')) "+;
	"SELECT CONVERT(VARCHAR(8000),NOTA) AS NOTA,LEN(NOTA) AS TAMNF FROM TMP "

	TCQuery cQuery ALIAS "TMPNF" NEW
	dbselectarea("TMPNF")

	IF TMPNF->(!EOF())
		lAchouBD := .t.
	
		cBuffer := alltrim(TMPNF->NOTA)
		nTamFile := TMPNF->TAMNF
		if nTamFile > 8000
			for i := 2 to ceiling(nTamFile/8000)
				dbselectarea("TMPNF")
				dbclosearea()
				nPos := ((i-1)*8000)+1
				cQuery := "WITH TMP AS (SELECT CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),XML_ERP)) AS NOTA FROM SPED050 WHERE (D_E_L_E_T_ <> '*') AND (DOC_CHV = '"+cChave+"')) "+;
				"SELECT CONVERT(VARCHAR(8000),SUBSTRING(NOTA,"+alltrim(str(nPos))+",8000)) AS NOTA FROM TMP "

				TCQuery cQuery ALIAS "TMPNF" NEW
				cBuffer += alltrim(TMPNF->NOTA)
			next 
		endif 
	ENDIF 
	dbselectarea("TMPNF")
	dbclosearea()
ENDIF  

if lAchouBD .and. (cBuffer != Nil) .and. !empty(cBuffer)
	lOk := .t.
endif 

	//Só funciona se manifestar antes
	//if !lOk .and. (nVezes == 1) // Se não achou o arquivo, tentar baixar da receita
	//	U_zBxXML(cChave)
	//endif 
If !lOk
	cArquivo := ""
	MsgAlert("Nenhum Arquivo Encontrado, Por Favor Selecione a Opção Arquivo e Faça a Busca na Arvore de Diretórios!")  
Endif

Return(lOk)


/*/{Protheus.doc} fValTags
//TODO Função para carregar validações das Tags Cabeçalho da NF sendo que as mesmas não podem ser feitas dentro de um loop a partir da release 12.1.25
@author Luís Gustavo de Souza
@since 29/01/2020
@version 1.0
@return ${return}, ${return_description}
@param oNfe, object, descricao
@type function
/*/
Static Function fValTagC( oNfe )
       Private _oNF
       Private _oDest
       Private _oEmit
       Private _oIdent

       _lVerNfePr := Type("oNFe:_NfeProc")        <> "U"
       _lVerNfe   := Type("oNFe:_NFe")            <> "U"
       If _lVerNfePr
          _oNF      := oNFe:_NFeProc:_NFe
       Else
          If _lVerNfe
		     _oNF := oNFe:_NFe
          Endif
       Endif
       _lVerICMS  := Type("_oNF:_InfNfe:_ICMS")    <> "U"
       _lVerInfN  := Type("_oNF:_InfNfe:_ID:TEXT") <> "U"
       _lVerCobr  := Type("_oNF:_InfNfe:_Cobr")    == "U"
       _lVerMen   := Type("_oNF:_InfNfe:_InfAdic:_infcpl:TEXT") <> "U"
       _oDest     := _oNF:_InfNfe:_Dest
       _lVerCPF   := Type("oDest:_CPF")            == "U"
       _oEmit     := _oNF:_InfNfe:_Emit
       _lVerEmit  := Type("_oEmit:_CPF")           == "U"
       _oIdent    := _oNF:_InfNfe:_IDE
       _lVerDtEm  := Type("_oIdent:_dEmi:TEXT")    == "C"
Return

/*/{Protheus.doc} fValTags
//TODO Função para carregar validações das Tags Detalhes (Itens) da NF sendo que as mesmas não podem ser feitas dentro de um loop a partir da release 12.1.25
@author Luís Gustavo de Souza
@since 29/01/2020
@version 1.0
@return ${return}, ${return_description}
@param oNfe, object, descricao
@type function
/*/
Static Function fValTagD( _oDet )
       Private _oAuxDet := _oDet
       
       _lVerNCM := Type("_oAuxDet:_Prod:_NCM")             == "U"
       _lVerFCI := Type("_oAuxDet:_Prod:_nFCI:TEXT")       <> "U"
       _lVerDes := Type("_oAuxDet:_Prod:_vDesc")           <> "U"
       _lVerI00 := Type("_oAux:_Imposto:_ICMS:_ICMS00")    <> "U"
       _lVerI10 := Type("_oAux:_Imposto:_ICMS:_ICMS10")    <> "U"
       _lVerI20 := Type("_oAux:_Imposto:_ICMS:_ICMS20")    <> "U"
       _lVerI30 := Type("_oAux:_Imposto:_ICMS:_ICMS30")    <> "U"
       _lVerI40 := Type("_oAux:_Imposto:_ICMS:_ICMS40")    <> "U"
       _lVerI51 := Type("_oAux:_Imposto:_ICMS:_ICMS51")    <> "U"
       _lVerI60 := Type("_oAux:_Imposto:_ICMS:_ICMS60")    <> "U"
       _lVerI70 := Type("_oAux:_Imposto:_ICMS:_ICMS70")    <> "U"
       _lVerI90 := Type("_oAux:_Imposto:_ICMS:_ICMS90")    <> "U"
       _lVerISN := Type("_oAux:_Imposto:_ICMS:_ICMSSN101") <> "U"
Return

/*/{Protheus.doc} fValTags
//TODO Função para carregar validações das Tags de impostos da NF sendo que as mesmas não podem ser feitas dentro de um loop a partir da release 12.1.25
@author Luís Gustavo de Souza
@since 29/01/2020
@version 1.0
@return ${return}, ${return_description}
@param oNfe, object, descricao
@type function
/*/
Static Function fValTagI( _oICM )
       Private _oAuxICM := _oICM

       _lVerIOri := Type("_oAuxICM:_orig:TEXT")  <> "U"
       _lVerICST := Type("_oAuxICM:_CST:TEXT")   <> "U"
       _lVerICSO := Type("_oAuxICM:_CSOSN:TEXT") <> "U"
Return

Static Function LeCodKit(_nOpcao)
Local lRet := .f.
Local cAuxCod
DO CASE
CASE _nOpcao == 4 //Excluir item bipado
	dbselectarea("XCODBAR")
	if !eof() .and. !bof()
		cAuxCod := alltrim(XCODBAR->ZZD_CODBAR)
		if PodeIE(cAuxCod,2) //segundo parâmetro indica se pode excluir (2) ou incluir (1)
			if MsgYesNo ("Exclui o código de barra "+cAuxCod+" ?")
				dbselectarea("XCODBAR")
				reclock("XCODBAR",.F.)
				dbdelete()	
				msunlock()
				dbselectarea("ZZD")
				MsSeek(xFilial("ZZD")+cChvNfe+cAuxCod,.t.)
				if found()
					reclock("ZZD",.F.)
					dbdelete()	
					msunlock()
				endif 
				nLidoKit--
				nQtde := ExcluiFilhos(cAuxCod)
				if nQtde > 0
					nLidoKit -= nQtde
					//oEdit2:Refresh()
				endif 
				oEdit2:Refresh()

			endif 
		endif 
	endif 

CASE _nOpcao == 3
	lCancelar := .t.
	lFimDlg := .T.
	lRet := .t.
	_oDlg:End()
CASE _nOpcao == 2
	do case 
	case nLidoKit < nQtItKit
		MsgAlert("Faltam Itens a Serem Lidos!")
		oEdit1:SetFocus()
	case nLidoKit == 0 .and. (nQtItKit > 0)
		MsgAlert("Nenhum Kit Lido!")
		oEdit1:SetFocus()
	case nLidoKit <> nQtItKit
		MsgAlert("Qtde Lida diverge da Qtde Total!")
		oEdit1:SetFocus()
	otherwise
		lRet := .t.
		lFimDlg := .t.
		_oDlg:End()
	endcase

OTHERWISE 
	if empty(alltrim(cCodBarKit)) .or. ((len(alltrim(cCodBarKit)) != 36) .and. (len(alltrim(cCodBarKit)) != 28))
		lRet := .t.
		//lFimDlg := .t.
	else 
		if ProcItemKit(cCodBarKit)
			if PodeIE(cCodBarKit,1) // Segundo parametro determina se pode incluir (1) ou excluir(2)
				nLidoKit++
				//Prosseguir com a leitura do kit
				//cCodBars += ALLTRIM(cCodBarKit)+"|"
				dbselectarea("XCODBAR")
				reclock("XCODBAR",.T.)
				XCODBAR->ZZD_CODBAR := cCodBarKit
				msunlock()
				dbselectarea("ZZD")
				reclock("ZZD",.T.)
				ZZD->ZZD_FILIAL := xFilial("ZZD")
				ZZD->ZZD_CHVNFE := cChvNfe
				ZZD->ZZD_CODBAR := cCodBarKit
				msunlock()
				dbselectarea("XCODBAR")
				//dbgobottom()
				nQtde := CadFilhos(cCodBarKit)
				if nQtde > 0
					nLidoKit += nQtde
					//oEdit2:Refresh()
				endif 
				_oBrwCodb := nil
				@ 100,005 TO 190,200 BROWSE "XCODBAR" FIELDS aCampos3 Object _oBrwCodb

				oEdit2:Refresh()
			endif 
		endif 
	endif 
ENDCASE 
cCodBarKit := space(36)
oEdit1:Refresh()
if !lFimDlg
	//_oDlg:End()
endif 
return(lRet)



Static Function ProcItemKit(_cCod)
Local cAuxCod,_cCodPrf,cCodProtheus,lAchou
cAuxCod := alltrim(_cCod)
lAchou := .f.
if !empty(cAuxCod)
	cCodProtheus := ""
	_cCodPrf := alltrim(substr(_cCod,4,7))
	dbselectarea("SA5")
	DbOrderNickName("FORPROD")   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
	MsSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA+_cCodPrf)	
	if found()
		cCodProtheus := alltrim(SA5->A5_PRODUTO)
//	else 
//		MsgAlert("Não encontrado produto "+_cCodPrf+" em Prod x Fornecedor!")
	endif 
	if !empty(cCodProtheus)
		dbselectarea("ZZD")
		MsSeek(xFilial("ZZD")+cChvNfe+_cCod,.t.)
		if !found() //É preciso ser leitura nova para contabilizar como adicional
			lAchou := .t.
		endif 
	endif 

endif 

return(lAchou)

//Cleber -> Incluir automaticamente códigos filhos (20/12/21) 
Static Function CadFilhos(_cCod)
Local _cArea := Alias()
Local nRet,cAuxCod,cQuery,_cCodPrf,cCodComp,i,nQtde,nFator 
cAuxCod := alltrim(_cCod)
nRet := 0
if !empty(cAuxCod)
	_cCodPrf := alltrim(substr(_cCod,4,7))
	If Select("TMPCOMP") <> 0
		TMPCOMP->(dbCloseArea())
	endif 	
	cQuery := "SELECT CODIGO,COMPON,QTDE FROM KITSCOCA WHERE (PAI = '"+_cCodPrf+"') ORDER BY COMPON"
	TCQuery cQuery ALIAS "TMPCOMP" NEW
	dbselectarea("TMPCOMP")
	dbgotop()
	do while !eof()
		//Descobrir se estrutura possui itens com subestrutura repetidos
		nFator := 1 
		cQuery := "SELECT QTDE FROM KITSCOCA WHERE (CODIGO = '"+TMPCOMP->CODIGO+"') AND (COMPON = '"+_cCodPrf+"')"
		TCQuery cQuery ALIAS "TMPPAI" NEW
		dbselectarea("TMPPAI")
		dbgotop()
		if !eof() .and. !bof()
			nFator := TMPPAI->QTDE
		endif 
		nQtde := ROUND(TMPCOMP->QTDE/nFator,0)
		
		for i = 1 to nQtde
			cCodComp := substr(cAuxCod,1,3)+ALLTRIM(TMPCOMP->COMPON)+substr(cAuxCod,11,2)+substr(cAuxCod,13,10)+substr(cAuxCod,23,8)+U_NumSeqLot("ZZD", 6) 
			dbselectarea("XCODBAR")
			reclock("XCODBAR",.T.)
			XCODBAR->ZZD_CODBAR := cCodComp
			msunlock()
			dbselectarea("ZZD")
			reclock("ZZD",.T.)
			ZZD->ZZD_FILIAL := xFilial("ZZD")
			ZZD->ZZD_CHVNFE := cChvNfe
			ZZD->ZZD_CODBAR := cCodComp
			msunlock()
			nRet++
			dbselectarea("XCODBAR")
		next
		If Select("TMPPAI") <> 0
			TMPPAI->(dbCloseArea())
		endif 	

		dbselectarea("TMPCOMP")
		dbskip()
	enddo 
	If Select("TMPCOMP") <> 0
		TMPCOMP->(dbCloseArea())
	endif 	
endif 
if !empty(_cArea)
   dbSelectArea(_cArea)
endif 

return(nRet)

//Cleber -> Excluir automaticamente códigos filhos (20/12/21) 
Static Function ExcluiFilhos(cAuxCod)
Local _cArea := Alias()
Local nRet,cQuery,_cCodPrf,cCodComp,nQtde,_cAux 
nRet := 0
if !empty(cAuxCod)
	_cCodPrf := alltrim(substr(cAuxCod,4,7))
	If Select("TMPCOMP") <> 0
		TMPCOMP->(dbCloseArea())
	endif 	
	cQuery := "SELECT COMPON,QTDE FROM KITSCOCA WHERE (PAI = '"+_cCodPrf+"') ORDER BY COMPON"
	TCQuery cQuery ALIAS "TMPCOMP" NEW
	dbselectarea("TMPCOMP")
	dbgotop()
	do while !eof()
		nQtde := TMPCOMP->QTDE
		cCodComp := substr(cAuxCod,1,3)+ALLTRIM(TMPCOMP->COMPON)+substr(cAuxCod,11,2)+substr(cAuxCod,13,10)+substr(cAuxCod,23,8) //+U_NumSeqLot("ZZD", 6) 
		dbselectarea("XCODBAR")
		dbgotop()
		LOCATE FOR SUBSTR(XCODBAR->ZZD_CODBAR,1,30) = cCodComp
		do while !eof() .and. !bof() .and. (XCODBAR->ZZD_CODBAR = cCodComp)
			nRet++
			_cAux := alltrim(XCODBAR->ZZD_CODBAR)
			reclock("XCODBAR",.F.)
			dbdelete()	
			msunlock()
			dbselectarea("ZZD")
			MsSeek(xFilial("ZZD")+cChvNfe+_cAux,.t.)
			if found()
				reclock("ZZD",.F.)
				dbdelete()	
				msunlock()
			endif 
			dbselectarea("XCODBAR")
			dbskip()
		enddo 

		dbselectarea("TMPCOMP")
		dbskip()
	enddo 
	If Select("TMPCOMP") <> 0
		TMPCOMP->(dbCloseArea())
	endif 	
endif 
if !empty(_cArea)
   dbSelectArea(_cArea)
endif 

return(nRet)

//Cleber -> Verificar se item não é produto filho, orientar a excluir ou incluir o produto pai
Static Function PodeIE(_cCod,nOper)
Local _cArea := Alias()
Local lRet,cAuxCod,cQuery,_cCodPrf 
/*
PARAMETROS: 
_cCod: Código de Barras Lido
nOper: Qual operação? 1-Incluindo; 2-Excluindo
*/
lRet := .t.
cAuxCod := alltrim(_cCod)
if !empty(cAuxCod)
	_cCodPrf := alltrim(substr(_cCod,4,7))
	If Select("TMPCOMP") <> 0
		TMPCOMP->(dbCloseArea())
	endif 	
	cQuery := "SELECT CODIGO FROM KITSCOCA WHERE (COMPON = '"+_cCodPrf+"') AND (PAI > '')"
	TCQuery cQuery ALIAS "TMPCOMP" NEW
	dbselectarea("TMPCOMP")
	dbgotop()
	if !eof() .and. !bof()
		lRet := .f.
		MsgAlert("Movimente o item PAI!")		
	endif 
	If Select("TMPCOMP") <> 0
		TMPCOMP->(dbCloseArea())
	endif 	
endif 
if !empty(_cArea)
   dbSelectArea(_cArea)
endif 

return(lRet)


Static Function ContCodKits()
Local _cArea := Alias()
Local _cChave := cChvNfe
Local nLido,cQuery

nLido := 0
If Select("TMPCOMP") <> 0
	TMPCOMP->(dbCloseArea())
endif 	
cQuery := "SELECT ZZD_CODBAR FROM "+RetSqlName("ZZD")+" WHERE (D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND (ZZD_CHVNFE = '"+_cChave+"') ORDER BY R_E_C_N_O_"
TCQuery cQuery ALIAS "TMPCOMP" NEW
dbselectarea("TMPCOMP")
dbgotop()

do while !eof()
	if !empty(alltrim(TMPCOMP->ZZD_CODBAR))
		nLido++
		dbselectarea("XCODBAR")
		reclock("XCODBAR",.T.)
		XCODBAR->ZZD_CODBAR := TMPCOMP->ZZD_CODBAR
		msunlock()
	endif 
	dbselectarea("TMPCOMP")
	dbskip()
enddo 
If Select("TMPCOMP") <> 0
	TMPCOMP->(dbCloseArea())
endif 	

if !empty(_cArea)
   dbSelectArea(_cArea)
endif 
return(nLido)
