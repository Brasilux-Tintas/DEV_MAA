#INCLUDE 'protheus.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'rwmake.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'colors.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'dbstruct.ch' 


#DEFINE CMD_OPENWORKBOOK 1
#DEFINE CMD_CLOSEWORKBOOK 2
#DEFINE CMD_ACTIVEWORKSHEET 3
#DEFINE CMD_READCELL 4
#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY

/*
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Programa   IMPXLS2INV      Claudinei E Nascimento-CAAK        Data 26/11/12
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Objetivo   Inventariar produtos em lote a partir de informacoes da planilha excel
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Rotina Principal MATA270
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Detalhes  A planilha excel devera conter colunas na seguinte ordem: Cod Produto, Lote, Qtde e Armazem
          O tipo do produto e obrigatorio, mas o sistema trara automaticamente do cadastro
          do produto
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
*/
user function BRINVENT()
	local aArea := GetArea() //reserva espaco em memoria para trabalhar
	local oSmallFont, oFontNegri, oFontNormal //objetos fonte e janela principal
	local oSay1, oSay4, oSay5 //objetos legenda de informacao
	//Local oSay2, oSay3
	local oSBtn1, oSBtn2, oSBtn3 //objetos botoes
	local aRegs := {} //matriz que armazenar o grupo de perguntas
	//local aHelp := {} //exibe informacoes ao usuario sobre o parametro
	//local aHelpI := {}
	//local aHelpE := {}
	//local cHelp := ""
	private oDlg1
	private aStruct := {}
	private cPerg := PADR("BRINVENT",10) //grupo de perguntas especifico para importacao de planilha
    u_zcfga01( 'BRINVENT' ) //LGS#2021118 - Gravação de log de utilização da rotina
	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" TABLES "SA1990" //Prepara ambiente para executar programa sem chamar pelo menu
	//RpcSetType(3) //Desliga o contador de licencas
	//RpcSetEnv("99","01", "","","","",{"SB8","SB1"}) //Abrindo empresa 01 e filial 02

	if !u_VldAcesso(funname())
      	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	return 
  	endif 


	aStruct := SX1->(DBSTRUCT())

            //Grupo ORDEM PERGUNT Brasil         E  I  VARIAVL   TIPO TAMANHO DECIMAL PRESEL GSC VALID                             VAR01      DEF01   DEFSPA1 DEFENG1 CNT01 VAR02 DEF02 DEFSPA2 DEFENG2 CNT02 VAR03 DEF03 DEFSPA3 DEFENG3 CNT03 VAR04 DEF04 DEFSPA4 DEFENG4 CNT04 VAR05 DEF05 DEFSPA5 DEFENG5 CNT05 F3    PYME GRPSXG HELP PICTURE IDFIL
	aAdd(aRegs,{cPerg,"01" ,"Diretório?          ","","","mv_ch1" ,"C" ,28     ,0      ,0     ,"G","NaoVazio() .And. U_f_ChkPrms(MV_PAR01,'DIR')","MV_PAR01",""      ,""    ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""  ,""    ,""  ,""     ,""   })
	aAdd(aRegs,{cPerg,"02" ,"Nome Planilha Excel?","","","mv_ch2" ,"C" ,42     ,0      ,0     ,"G","NaoVazio() .And. U_f_ChkPrms(MV_PAR02,'PLA')","MV_PAR02",""      ,""    ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""  ,""    ,""  ,""     ,""   })
	aAdd(aRegs,{cPerg,"03" ,"Nome Pasta Excel?   ","","","mv_ch3" ,"C" ,35     ,0      ,0     ,"G","NaoVazio() .And. U_f_ChkPrms(MV_PAR03,'PAS')","MV_PAR03",""      ,""    ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""  ,""    ,""  ,""     ,""   })
	aAdd(aRegs,{cPerg,"04" ,"Documento?          ","","","mv_ch4" ,"C" ,09     ,0      ,0     ,"C","                                            ","MV_PAR04",""      ,""    ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""  ,""    ,""  ,""     ,""   })

	//U_ValidarSX1(cPerg, aRegs) //LGS#20200130 - Adequação a release 12.1.25
	Pergunte(cPerg,.T.)

	oSmallFont := TFont():New( "Small Fonts",0,-9,,.F.,0,,400,.F.,.F.,,,,,, )
	oFontNegri := TFont():New( "Arial",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
	oFontNormal := TFont():New( "Arial",0,-11,,.F.,0,,700,.F.,.F.,,,,,, )
    If !u_VldAcesso(funname())
  	  Aviso("Atenção","Acesso negado para esta Rotina -->"+funname()+", consulte depto T.I", {"Ok"}, 2, "MSG008-Usuário sem acesso a esta rotina!")	
      Return 
  	Endif 
  
	oDlg1 := MSDialog():New( 102,373,345,825,"Inventariar Itens a partir de planilha excel",,,.F.,,,,,,.T.,,,.T. )
		oSay1 := TSay():New( 007,008,{||"Informar na planilha excel a partir das colunas : A2 o Codigo Produto   "},oDlg1,,oFontNegri,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,028)
		oSay1 := TSay():New( 016,008,{||", B2 o Codigo Lote, C2 a(s) Quantidade(s) e D2 o Armazem a Inventariar  "},oDlg1,,oFontNegri,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,028)
		oSay1 := TSay():New( 025,008,{||"O nome da planilha excel e da pasta dentro desta planilha deverão,      "},oDlg1,,oFontNegri,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,028)
		oSay1 := TSay():New( 033,008,{||"ser escritos sem caractere especial algum como: ç, ', , ~ , `, etc.     "},oDlg1,,oFontNegri,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,028)
		oSay1 := TSay():New( 043,008,{||"Informar no parâmetro o nome da planilha com a extensão: xls ou xlsx    "},oDlg1,,oFontNegri,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,028)
		oSay1 := TSay():New( 052,008,{||"O parametro Documento serve para informar o numero inicial de controle, "},oDlg1,,oFontNegri,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,028)
		oSay1 := TSay():New( 061,008,{||"se deixar em branco o sistema utiliza a data corrente                   "},oDlg1,,oFontNegri,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,028)
		oSay4 := TSay():New( 074,008,{||"Deverá existir o arquivo 'readexcel.dll' no caminho C:\TEMP\             "},oDlg1,,oFontNormal,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,215,090)
		oSay5 := TSay():New( 112,008,{||"Rotina: BRINVENT                                                      "},oDlg1,,oSmallFont,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,204,008)

		oSBtn1 := SButton():New( 105,118,5,{ || Pergunte(cPerg,.T.) },oDlg1,,"", )
		oSBtn2 := SButton():New( 105,154,1,{ || U_ProceXLS(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04)},oDlg1,,"", )
		oSBtn3 := SButton():New( 105,190,2,{ || oDlg1:END() },oDlg1,,"", )
	oDlg1:Activate(,,,.T.)

	RestArea(aArea)
return(nil)


/*
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Funcao ProceXLS          Autor: Claudinei E Nascimento-CAAK          Data: 28/10/11
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Objetivo Pega parametro(s) necessario(s) e chama a funcao que lera a planilha excel
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Parametros     cMVDIR     : Diretorio onde desta a planilha excel
               cMVArqXls  : Nome do arquivo excel
               cMVPastaXLS   : Nome da pasta dentro do arquivo excel
               cMVDocument: Codigo do documento inventariado
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
*/
user function ProceXls(cMVDir,cMVArqXls,cMVPastaXLS,cMVDocument)
	local aArea := GetArea()
	/* - - Parametros Exibidos ao Usuario - - 
	MV_PAR01 "Diretório?          " cMVDir := AllTrim(MV_PAR01)
	MV_PAR02 "Nome Planilha Excel?" cMVArqXLS := AllTrim(MV_PAR02)
	MV_PAR03 "Nome Pasta Excel?   " cMVPastaXLS := AllTrim(MV_PAR03)
	MV_PAR04 "Documento?          " cMVDocument := MV_PAR04
	*/

	if File('C:\TEMP\readexcel.dll')
		PROCESSA({| | U_LerXLS2Inv(AlLTrim(cMVDir),cMVArqXls,cMVPastaXLS,cMVDocument)}, "Aguarde, selecionado registros...")
	else
		Aviso("Atenção","O arquivo 'readexcel.dll' deverá ser gravado na pasta 'C:\TEMP\'.", {"Ok"}, 2, "MSG001-Diretorio e/ou Arquivo Inexistente!")
	endif

	oDlg1:End()
	RestArea(aArea)
return(nil)


/*
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Funcao: LerXLS2Inv        Autor: Claudinei E Nascimento-CAAK   Data: 29/11/11
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Objetivo Ler planilha excel e chamar rotina para gravar inventario
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
*/
user function LerXLS2Inv(cMVDir,cMVArqXls,cMVPastaXLS,cMVDocument)
	local aArea := GetArea() //array armazena area na memoria para trabalharmos
	local aCells	:= {} //array com as celulas a serem lidas
	local aPlanXLS := {} //array planilha que devem ser lidas
	local aPasta := {} //array pastas existente na planilha excel
	local aInvItens := {} //array armazena codigo produto,local,tipo,doc,quantidade e data
	local cCelPro := cCelTip := cCelArm := cCelQtd := cCelDoc := cCelPrc := cCelfim2 := "" //colunas no excel: codigo produto,tipo produto,armazem/local,quantidade,numero documento
	local cPro := cPro1 := cTpPro := cCodLote := cCodLot1 := cArm := cLclPlanXLS := cPasta := cQry := cQryEst := "" //armazenara dados da planilha: cod produto,local e nome planilha,nome pasta,codigo do vendedor,instrucoes a banco de dados
	local cBuffer := cMsg := cMsg1 := cMsgM270 := cMsgM270a := cMsgM270b := cProAnt := cFimAnt := ""
	local dDtVldLote := CTOD("//")
	local nCelIni := nI := nCont := nQtde := nDoc := nPlanXLS := nPastaXLS := nQtdeAnt := 0
	Local nCont

	nCelIni := 02 //primeira linha a ser lida
	cCelPro := "A" //coluna com codigo produto e fim da linha
	cCelLote := "B" //coluna com codigo lote
	cCelQtd := "C" //coluna com quantidade a inventariar
	cCelArm := "D" //coluna com codigo do armazem
	cCelDoc := ""  //numero documento

	//retorna todas as planilhas informadas no parametro 'Nome Planilha Excel? (MV_PAR03)'
	nCont := 1 //Contador para controlar situacoes especificas
	while nCont < len(AllTrim(cMVArqXLS)) //enquanto o contador for menor ou igual a quantidade de campos na pergunta com nome das planilhas excel...
		nAt := AT(";",SUBSTR(cMVArqXLS,nCont,len(cMVArqXLS)) ) //...verifica se existe o ";"
		if nAt == 0 //se houver ";" entre os nomes das planilhas
			nAt := len(cMVArqXLS) + 1 //soma 1 a quantidade da contagem dos caracteres
		endif

		//coloca a barra "\" caso inexistente
		if SubStr(cMVDir,Len(cMVDir),1) <> "\"
			cMVDir+="\"
		endif

		aAdd(aPlanXLS,cMVDir+substr(cMVArqXLS,nCont,nAt-1)) //adiciona ao array o diretorio + o nome das planilhas excel
		nCont += nAt
	end while
	
	//retorna todas as pastas informadas no parametro 'Nome Pasta Excel? (MV_PAR04)'
	aPasta := {}
	nCont := 1
	while nCont < len(cMVPastaXLS) //enquanto o contador for < quantidade de todos os caracteres da pasta dentro do excel
		nAt := AT(";",SUBSTR(cMVPastaXLS,nCont,len(cMVPastaXLS)) ) //...verifica se existe o ";"
		if nAt == 0 //se houver ";" entre os nomes das planilhas
			nAt := len(cMVPastaXLS)+1 //soma 1 a quantidade da contagem dos caracteres
		endif
		aAdd(aPasta,substr(cMVPastaXLS,nCont,nAt-1)) //adiciona ao array as pastas
		nCont += nAt
	end while

	//Quantidade de registros considerados na barra de progressao
	ProcRegua(Len(aPlanXLS))

	for nCont := 1 to Len(aPlanXLS)
		cPro := cCodLote := cTpPro := cArm := cBuffer := "" //codigo produto,tipo produto,armazem/local e local na memoria para armazenar planilha
		nQtde := 0 //quantidade a inventariar
		nDoc := "" //codigo documento
		nPlanXLS := 0
		cLclPlanXLS := aPlanXLS[nCont] //local onde esta gravado a planilha excel
		cPasta := aPasta[nCont] //nome da pasta lida
		aCells := {}

		//            A2 Codigo produto             B2 Cod Lote                    C2 Quantidade a Invetariar    D2 Codigo Armazem
		aAdd(aCells,{cCelPro+AllTrim(Str(nCelIni)),cCelLote+AllTrim(Str(nCelIni)),cCelQtd+AllTrim(Str(nCelIni)),cCelArm+AllTrim(Str(nCelIni))})

		//localiza e habilita a biblioteca responsavel por ler planilha excel
		nHdl:= ExecInDLLOpen('C:\TEMP\readexcel.dll')

		//se a dll estiver no local indicado
		If (nHdl < 0)
			Aviso("Atenção","O arquivo readexcel.dll deverá ser gravado na pasta C:\TEMP\.", {"Ok"}, 2, "MSG002-Arquivo Inexistente!")
			return(nil)
		endif

		//Carrega a planilha excel o abre
		cBuffer := cLclPlanXLS + Space(512) //coloca o local + nome da planilha excel + 512 bytes de spaco em memoria
		nPlanXLS := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer) //Carrega o Excel, Exibe ao usuario e retorna controle
		
		//Valida existencia do arquivo excel
		If ( nPlanXLS < 0 ) //se controle de abertura for inferior a 0 (zero)
			Aviso("Atenção","Arquivo "+cLclPlanXLS+" inexistente.", {"Ok"}, 2, "MSG003-Arquivo Inexistente!") //informa erro critico ao usuario
			cBuffer := Space(512)
			ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
			ExecInDLLClose(nHdl)
			Return(nil)
		ElseIf ( nPlanXLS > 0 )//se controle de abertura for superior a 0 (zero)
			Aviso("Atenção",SubStr(cBuffer,1,nPlanXLS), {"Ok"}, 2, "MSG004-Arquivo Inexistente!") //informa erro critico ao usuario
			cBuffer := Space(512)
			ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
			ExecInDLLClose(nHdl)
			Return(nil)
		EndIf
		
		//seleciona a pasta dentro da planilha excel
		cBuffer := ''
		cBuffer := cPasta + Space(512) //Seleciona a planilha dentro do excel
		nPastaXLS := ExeDLLRun2(nHdl, CMD_ACTIVEWORKSHEET, @cBuffer) //executa a leitura

		//Valida existencia da pasta dentro do arquivo excel
		if (nPastaXLS < 0) //se controle de abertura for inferior a 0 (zero)
			MsgStop("Pasta "+cPasta+" inexistente na planilha excel. Evite acentuações de qualquer tipo.") //informa erro critico ao usuario
			cBuffer := Space(512)
			ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
			ExecInDLLClose(nHdl)
			Return(nil)
		elseif (nPastaXLS > 0) //se controle de abertura for superior a 0 (zero)
			MsgStop("Pasta "+cPasta+" inexistente na planilha excel. Evite acentuações de qualquer tipo.") //se controle de abertura for inferior a 0 (zero)
			cBuffer := Space(512)
			ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
			ExecInDLLClose(nHdl)
			Return(nil)
		endif

		ProcRegua(1700)
		//Inicia a leitura das celulas (colunas-linhas) da planilha excel
		nI := 1
		while .T.
			//Ler celula com codigo de produto
			cBuffer := aCells[nI,1] + Space(1024)
			nBytes := ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
			//cPro := Subs(cBuffer, 1, nBytes) //Exclui ' na primeira posicao do codigo do produto
			cPro := iif(Subs(cBuffer, 1, nBytes)!="" .or. !Empty(Subs(cBuffer, 1, nBytes)),iif(SubStr(Subs(cBuffer, 1, nBytes),1,1)=="'",SubStr(Subs(cBuffer, 1, nBytes),2,Len(Subs(cBuffer, 1, nBytes))-1),Subs(cBuffer, 1, nBytes)),Subs(cBuffer, 1, nBytes))

			//Ler celula com codigos de lotes
			cBuffer := aCells[nI,2] + Space(1024)
			nBytes := ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
			            //Analisa se produto possui codigo de lote, grava branco caso nao possua
			//cCodLote := iif(Subs(cBuffer, 1, nBytes) == "'SEM_LOTE" .or. Subs(cBuffer, 1, nBytes) == "SEM_LOTE" .or. Subs(cBuffer, 1, nBytes)==" " .or. Empty(Subs(cBuffer, 1, nBytes)),"",Subs(cBuffer, 1, nBytes))
			cCodLote := ""
			//Se tiver Lote elimina '
			//cCodLot1 := iif(cCodLote!="" .or. !Empty(cCodLote),iif(SubStr(cCodLote,1,1)=="'",SubStr(cCodLote,2,Len(cCodLote)-1),cCodLote),cCodLote)
			cCodLot1 := ""
			//Ler celula com quantidades a inventariar
			cBuffer := aCells[nI,3] + Space(1024)
			nBytes := ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
			cQtde := Subs(cBuffer, 1, nBytes)

			//Ler celula com codigo armazem
			cBuffer := aCells[nI,4] + Space(1024)
			nBytes := ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
			cArm := Subs(cBuffer, 1, nBytes)

			//Se chegou no final da planilha fecha a planilha e para processo de leitura
			if substring(cPro,1,3) == '---' .or. cPro == ""
				cBuffer := Space(512)
				ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer) //fecha excel
				ExecInDLLClose(nHdl) //fecha a planilha excel
				exit
			endif

			//Informar ao usuario se produto inexiste no cadastro de produtos ou se esta bloqueado
			if SELECT("QRYSB1") > 0
				DBSelectArea("QRYSB1")
				QRYSB1->(dbCloseArea())
			endif
			cQry := ""
			cQry := "SELECT B1_COD,B1_MSBLQL,B1_RASTRO,B1_TIPO FROM "+RetSQLName("SB1")
			cQry += " WHERE B1_FILIAL='"+xFilial("SB1")+"' AND D_E_L_E_T_='' AND B1_COD='"+cPro+"'"
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRYSB1", .F., .T.)

			if Empty(AllTrim(QRYSB1->B1_COD)) .or. QRYSB1->B1_COD==" " .or. QRYSB1->B1_COD==""
				cMsgM270 += "Cadastro Produto: "+AllTrim(cPro)+CRLF
			endif

			if QRYSB1->B1_MSBLQL=='1'
				cMsgM270 += "Produto Bloqueado: "+AllTrim(cPro)+CRLF
			endif

			//Tipo do produto
			cTpPro := QRYSB1->B1_TIPO

			//05/01/2012-Claudinei Nascimento-CAAK: Quando houver rastro no cadastro de produto e planilha excel estiver sem rastro
			//                                      exibe mensagem, mas continua programa
			if (QRYSB1->B1_RASTRO != 'N' .and. cCodLot1=="") .or. (QRYSB1->B1_RASTRO == "N" .and. (cCodLot1!="" .or. !Empty(cCodLot1)))
				cMsgM270a += AllTrim(cPro)+CRLF
			endif

			//27-12-18 criar armazem no sb2 quando ainda não existir (andre maester)
			//DbSelectArea("SB2")
			//DbSetOrder(1)
			//DbGotop()
			//If !SB2->(DBSEEK(xFilial("SB2")+Alltrim(cPro)+Alltrim(cArm)))
			//	CriaSB2(Alltrim(cPro), Alltrim(cArm))
			//Endif

			//05/01/2012-Claudinei CAAK: Consulta existencia do saldo inicial do produto e informa ao usuario caso inexista, mas continua programa
			
			if Select("QRYSB9") > 0
				DBSelectArea("QRYSB9")
				QRYSB9->(DBCloseArea())
			endif
			cQry := ""
			cQry := "SELECT DISTINCT B9_COD,B9_LOCAL FROM "+RetSQLName("SB9")
			cQry += " WHERE B9_FILIAL='"+xFilial("SB9")+"' AND D_E_L_E_T_='' AND B9_COD='"+cPro+"' AND B9_LOCAL='"+cArm+"'"
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRYSB9", .F., .T.)

			if Empty(QRYSB9->B9_COD)
				cMsgM270 += "Cadastro Saldos Iniciais: "+AllTrim(cPro)+CRLF
			endif
             
			//Consulta saldo por lote somente se produto houver rastro
			if (QRYSB1->B1_RASTRO != 'N' .and. !Empty(QRYSB1->B1_RASTRO))
				//Consulta existencia do saldo por lote e informa ao usuario caso inexista
				if Select("QRYSB8") > 0
					DBSelectArea("QRYSB8")
					QRYSB8->(DBCloseArea())
				endif
				cQry := ""
				cQry := "SELECT B8_PRODUTO,B8_LOCAL,B8_DATA,B8_DTVALID FROM "+RetSQLName("SB8")
				cQry += " WHERE B8_FILIAL='"+xFilial("SB8")+"' AND D_E_L_E_T_='' AND B8_PRODUTO='"+cPro+"' AND B8_LOCAL='"+cArm+"' AND B8_LOTECTL='"+cCodLot1+"'"
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRYSB8", .F., .T.)
				dDtVldLote := QRYSB8->B8_DTVALID  //A270VLDLOT(): funcao que traz a data de validade do lote

				if Empty(QRYSB8->B8_PRODUTO)
					cMsgM270 += "Saldo Por Lote: "+AllTrim(cPro)+CRLF
				endif
			endif

			//Se parametro Documento estiver em branco considera database do sistema, mas se preenchido executa incremento (falta fazer incremento funcionar)
			nDoc := iif(cMVDocument==nil,GravaData(DDATABASE,.F.,5),GravaData(DDATABASE,.F.,5))

			//Se produto Inventariado o desconsidera
			if SELECT("QRYSB7") > 0
				DBSelectArea("QRYSB7")
				QRYSB7->(dbCloseArea())
			endif
			cQry := ""
			cQry := "SELECT B7_COD FROM "+RetSQLName("SB7")
			cQry += " WHERE B7_FILIAL='"+xFilial("SB7")+"' AND D_E_L_E_T_='' AND B7_COD='"+cPro+"' AND B7_TIPO='"+cTpPro+"' AND B7_LOCAL='"+cArm+"'"
			cQry += "   AND B7_DOC='"+nDoc+"' AND B7_DATA='"+GravaData(DDATABASE,.F.,8)+"' AND B7_QUANT='"+cQtde+"'"
			//Consulta saldo por lote somente se produto houver rastro
			if QRYSB1->B1_RASTRO != 'N' .and. !Empty(QRYSB1->B1_RASTRO)
				cQry += " AND B7_LOTECTL='"+cCodLot1+"' AND B7_DTVALID='"+dDtVldLote+"'"
			endif
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRYSB7", .F., .T.)

			if QRYSB1->B1_RASTRO != 'N' .and. !Empty(QRYSB1->B1_RASTRO)
				//Informa usuario que a data Emissao lote deve ser superior a data do inventario
				if QRYSB8->B8_DATA > GravaData(DDATABASE,.F.,8)
					cMsgM270b := AllTrim(cPro)+CRLF
				endif
			endif

			//Inventaria itens se: 1.Codigo produto+tipo produto+armazem+nr documento+data inventario+quantidades diferentes do inventariado
			//                  e  2.Data do inventario inferior ou igual a data de emissao do lote
			//                  e  3.Rastro no cadastro de produto e planilha excel com rastro
			if Empty(QRYSB7->B7_COD) .and. ; //.and. iif((QRYSB1->B1_RASTRO != 'N' .and. !Empty(QRYSB1->B1_RASTRO)),(QRYSB8->B8_DATA < GravaData(DDATABASE,.F.,8)),.T.)
			       !((QRYSB1->B1_RASTRO != 'N' .and. cCodLot1=="") .or. (QRYSB1->B1_RASTRO=="N" .and. (cCodLot1!="" .or. !Empty(cCodLot1))))
				aAdd(aInvItens,{cPro,cCodLot1,Val(cQtde),cArm,cTpPro,nDoc,iif(Empty(dDtVldLote),"",dDtVldLote)})
			endif

			nI++
			++nCelIni
			//            A2 Codigo produto             B2 Cod Lote                    C2 Quantidade a Invetariar    D2 Codigo Armazem
			aAdd(aCells,{cCelPro+AllTrim(Str(nCelIni)),cCelLote+AllTrim(Str(nCelIni)),cCelQtd+AllTrim(Str(nCelIni)),cCelArm+AllTrim(Str(nCelIni))})

			IncProc("Importando "+AllTrim(cLclPlanXLS)+". Aguardar...")
		end while

		//Fecha o arquivo e remove o excel da memoria
		cBuffer := Space(512)
		ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
		ExecInDLLClose(nHdl)
	next

	//05/01/2012-Claudinei Nascimento-CAAK: Quando houver rastro no cadastro produto e codigo lote ausente no excel ou cadastro produto 
	//                                      sem rastro e lote existir no excel, informa ao usuario para correcao e fecha programa
	if !Empty(AllTrim(cMsgM270a)) .or. cMsgM270a != ""
		Aviso("Aviso","Produtos com rastro, mas excel SEM_LOTE: "+CRLF+cMsgM270a+CRLF+" PRODUTOS NÃO INVENTARIADOS! ",{"O K"},3,"MSG005-Produtos Lotes Iconsistentes !")
	//	return(nil)
	endif

	//16/01/2012-Claudinei Nascimento-CAAK: Informa que a data de validade do produto com rastro deve ser inferior ou igual a data do inventario
	//                                      e fecha programa
	if !Empty(AllTrim(cMsgM270b)) .or. cMsgM270b != ""
		Aviso("Aviso","Data Emissao do Lote Superior a Data do Inventário"+CRLF+"Produto(s): "+cMsgM270b+CRLF+" PRODUTOS NÃO INVENTARIADOS! ",{"O K"},3,"MSG006-Datas Inconsistentes !")
	//	return(nil)
	endif

	if Len(aInvItens) > 0
		U_MATA_270(aInvItens)
	else  //senao retorna para tela principal
		return(nil)
	endif

	Aviso("Atenção","Por favor, conferir inventário e executar Miscelanea->Acertos->Acerto Inventario.", {"Ok"}, 2, "MSG007-Inventario Atualizado!")

	If !Empty(cMsgM270) .or. cMsgM270 != ""
		Aviso("Aviso","Produtos inexistentes/bloqueados no: "+CRLF+cMsgM270+CRLF+" PRODUTOS NÃO INVENTARIADOS! ",{"O K"},3,"MSG008-Produtos Iconsistentes !")
	endif
    RestArea(aArea)
return(nil)


/*
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Funcao fChkPrms       Autor Claudinei E Nascimento-CAAK               Data 18/10/2011
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Objetivo Validar a existencia de i
nformacoes
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Parametro  DPPVCTT: D: Informar DIR-analisar diretorio
                    P: Informar PLA-analisar Diretorio+Planilha Excel
                    P: Informar PAS-comparar quantidade de planilha x pastas
                    V: Informar VEN-analisar vendedor
                    C: Informar PGT-analisar condicao de pagamento
                    T: Informar TAB-analisar tabela preco de venda
                    T: Informar TRA-analisar transportadora
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
*/
user function f_ChkPrms(cMVPARAM,DPPVCTT)
	local aArea := GetArea()
	local lLclArq := .T.
	local aPlanXLS := {}
	local aPasta := {}
	local nCont := 1
	local cMVDir := cQry := ""

	//verifica a existencia do diretorio
	if UPPER(DPPVCTT) == "DIR"
		//informa ao usuario se o diretorio inexiste
		if !ExistDir(AllTrim(cMVPARAM))
			Aviso("Atenção","Diretório '"+AllTrim(cMVPARAM)+"' incorreto, por favor corrigir. "+CRLF+ ;
		                "Ex.: C:\[nome_da_pasta] ou C:\[nome_da_pasta]\", {"Ok"}, 2, "MSG009-Diretório inexistente!")
			lLclArq := .F.
		endif

	//verifica a existencia da planilha
	elseif UPPER(DPPVCTT) == "PLA"
		while nCont < len(AllTrim(cMVPARAM)) //enquanto o contador for menor ou igual a quantidade de campos na pergunta com nome das planilhas excel...
			nAt := AT(";",SUBSTR(AllTrim(cMVPARAM), nCont, len(AllTrim(cMVPARAM))) ) //...verifica se existe o ";"
			if nAt == 0 //se houver ";" entre os nomes das planilhas
				nAt := len(AllTrim(cMVPARAM)) + 1 //soma 1 a quantidade da contagem dos caracteres
			endif
			//coloca a \ (barra) caso inexista
			if SubStr(MV_PAR01,Len(MV_PAR01),1)<>"\"
				cMVDir := AllTrim(MV_PAR01)+"\"
			endif
			//se a planilha inexiste informa ao usuario
			if !File(AllTrim(cMVDir)+substr(AllTrim(cMVPARAM),nCont,nAt-1))
				Aviso("Atenção","Planilha '"+substr(AllTrim(cMVPARAM),nCont,nAt-1)+"' inexistente no diretório "+AllTrim(MV_PAR02)+". Por favor, informar o nome correto. "+CRLF+ ;
				                "Ex.: C:\[nome_da_pasta]\[nome_do_arquivo.xls] ou C:\[nome_do_arquivo.xlsx]", {"Ok"}, 2, "MSG010-Planilha inexistente!")
				lLclArq := .F.
			endif
			aAdd(aPasta,substr(AllTrim(cMVPARAM),nCont,nAt-1)) //adiciona ao array as pastas
			nCont += nAt
		end while

	//verifica a existencia da pasta
	elseif UPPER(DPPVCTT) == "PAS"
		while nCont < len(AllTrim(cMVPARAM)) //enquanto o contador for menor ou igual a quantidade de campos na pergunta com nome das planilhas excel...
			nAt := AT(";",SUBSTR(AllTrim(cMVPARAM), nCont, len(AllTrim(cMVPARAM))) ) //...verifica se existe o ";"
			if nAt == 0 //se houver ";" entre os nomes das planilhas
				nAt := len(AllTrim(cMVPARAM)) + 1 //soma 1 a quantidade da contagem dos caracteres
			endif
			//coloca a \ (barra) caso inexista
			if SubStr(MV_PAR02,Len(MV_PAR02),1)<>"\"
				cMVDir := AllTrim(MV_PAR02)+"\"
			endif
			aAdd(aPasta,substr(AllTrim(cMVPARAM),nCont,nAt-1)) //adiciona ao array as pastas
			nCont += nAt
		end while

		//retorna todas as planilhas informadas no parametro 'Nome Planilha Excel? (MV_PAR03)'
		nCont := 1 //Contador para controlar situacoes especificas
		while nCont < len(MV_PAR03) //enquanto o contador for menor ou igual a quantidade de campos na pergunta com nome das planilhas excel...
			nAt := AT(";",SUBSTR(MV_PAR03,nCont,len(MV_PAR03)) ) //...verifica se existe o ";"
			if nAt == 0 //se houver ";" entre os nomes das planilhas
				nAt := len(MV_PAR03) + 1 //soma 1 a quantidade da contagem dos caracteres
			endif
			aAdd(aPlanXLS,cMVDir+substr(MV_PAR03,nCont,nAt-1)) //adiciona ao array o diretorio + o nome das planilhas excel
			nCont += nAt
		end while

		//garante que para cada planilha haja uma pasta informa nos parametros Nome Planilha Excel? (MV_PAR03) e  Nome Pasta Excel?(MV_PAR04)
		if len(aPasta) <> len(aPlanXLS)
				Aviso("Atenção","Para cada planilha informada no parametro 'Nome Planilha Excel?', deverá existir uma pasta informada no parâmetro 'Nome Pasta Excel?'. O nome da pasta deverá possuir mais que um caracter.", {"Ok"}, 2, "MSG011-Quantidades Divergentes!")
				lLclArq := .F.
		endif

	//--Analisa vendedor vinculado ao cliente e retorna mensagem ao usuario para cadastrar se necessario
	elseif UPPER(DPPVCTT) == "VEN"
		if select("QRY") > 0 //Verifica se nao esta aberto o alias e...
			dbSelectArea("QRY")
			("QRY")->(DBCloseArea()) //Fecha para evitar conflitos
		endif
		cQry := "SELECT A1_VEND,A1_NOME FROM "+RetSqlName("SA1") +" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND D_E_L_E_T_='' AND A1_COD='"+MV_PAR05+"' AND A1_LOJA='"+cMVPARAM+"' "
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRY", .F., .T.)
		cCodigo := QRY->A1_VEND

		if Empty(cCodigo)
			Aviso("Atenção","Cadastrar o Vendedor para o Cliente/Loja: "+MV_PAR05+"/"+cMVPARAM+"-"+AllTrim(SubStr(AllTrim(QRY->A1_NOME),1,21))+".", {"Ok"}, 2, "MSG012-Vendedor Inexistente!")
			lLclArq := .F.
		endif

	//--analisa condicao de pagamento e informa ao usuario caso inexistente
	elseif UPPER(DPPVCTT) == "PGT"
		if select("QRY") > 0 //Verifica se nao esta aberto o alias e...
			dbSelectArea("QRY")
			("QRY")->(DBCloseArea()) //Fecha para evitar conflitos
		endif
		cQry := "SELECT E4_CODIGO FROM "+RetSqlName("SE4")+" WHERE E4_FILIAL='"+xFilial("SE4")+"' AND D_E_L_E_T_='' AND E4_CODIGO='"+cMVPARAM+"' "
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRY", .F., .T.)
		cCodigo := QRY->E4_CODIGO

		if Empty(cCodigo)
			Aviso("Atenção","Cadastrar a condição de pagamento: "+cMVPARAM, {"Ok"}, 2, "MSG013-Condição de Pagamento Inexistente!")
			lLclArq := .F.
		endif

	//--analisa se a tabela preco de venda existe e informa ao usuario se inexistente
	elseif UPPER(DPPVCTT) == "TAB"
		if select("QRY") > 0 //Verifica se nao esta aberto o alias e...
			dbSelectArea("QRY")
			("QRY")->(DBCloseArea()) //Fecha para evitar conflitos
		endif
		cQry := "SELECT DA0_CODTAB FROM "+RetSqlName("DA0")+" WHERE DA0_FILIAL='"+xFilial("DA0")+"' AND D_E_L_E_T_='' AND DA0_CODTAB='"+cMVPARAM+"' "
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRY", .F., .T.)
		cCodigo := QRY->DA0_CODTAB
		if Empty(cCodigo)
			Aviso("Atenção","Cadastrar a tabela preço de venda: "+cMVPARAM, {"Ok"}, 2, "MSG014-Tabela Preço de Venda Inexistente!")
			lLclArq := .F.
		endif

	//--Analisa se a transportadora existe e informa ao usuario se inexistente
	elseif UPPER(DPPVCTT) == "TRA"
		if select("QRY") > 0 //Verifica se nao esta aberto o alias e...
			dbSelectArea("QRY")
			("QRY")->(DBCloseArea()) //Fecha para evitar conflitos
		endif
		cQry := "SELECT A4_COD FROM "+RetSqlName("SA4")+" WHERE A4_FILIAL='"+xFilial("SA4")+"' AND D_E_L_E_T_='' AND A4_COD='"+cMVPARAM+"'"
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRY", .F., .T.)
		cCodigo := QRY->A4_COD

		if Empty(cCodigo)
			Aviso("Atenção","Cadastrar a transportadora : "+cMVPARAM, {"Ok"}, 2, "MSG015-Transportadora Inexistente!")
			lLclArq := .F.
		endif
	endif
	RestArea(aArea)
return(lLclArq)


/*======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Funcao ValidSX1
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Objetivo Verifica a existencia das perguntas no SX1, criando-as caso seja necessario ou
         excluindo as que nao sejam mais necessarias
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= */
//LGS#20200130 - Adequação a release 12.1.25
/*user function ValidarSX1(cPerg, aRegs)
	local i, j
	local nTamPerg := 0
	local U_X1_GRP := 6

	nTamPerg := LEN(cPerg)

	//varrer array de campos do SX1 em busca do campo X1_GRUPO e assim obter seu tamanho atual
	for I := 1 to Len(aStruct)
		if upper(aStruct[I, DBS_NAME]) == 'X1_GRUPO'
			U_X1_GRP := aStruct[I, DBS_LEN]
			exit
		endif
	next

	//comparar tamanho do campo X1_GRUPO com o valor passado
	//em cPerg e, se necessario, altero o conteudo de cPerg
	//de modo a ter o mesmo "comprimento" de X1_GRUPO - Emerson - 29/10/2008
	//OBS.: [cPerg := SubStr(cPerg, 1, U_X1_GRP)] nao funciona
	IF nTamPerg < U_X1_GRP
		cPerg += Replicate(" ", U_X1_GRP - nTamPerg)
	elseif nTamPerg > U_X1_GRP
		cPerg := SUBSTR(cPerg, 1, U_X1_GRP)
	endif

	SX1->(DBSetOrder(1))

	// verificando se ha alguma pergunta desnecessaria (por nao constar mais no array) - Emerson - 29/10/2008
	IF SX1->(DBSEEK(cPerg))
		WHILE AllTrim(UPPER(SX1->X1_GRUPO)) == AllTrim(UPPER(cPerg)) .AND. ! SX1->(EOF())
			IF ASCAN(aRegs, { |x| UPPER(x[2]) == Upper(SX1->X1_ORDEM) }) == 0
				RecLock("SX1", .F.)
				SX1->(dbDelete())
				SX1->(MsUnlock())
			ENDIF
			SX1->(dbSkip())
		ENDDO

	ENDIF

	// verificando se ha necessidade de criar alguma pergunta
	FOR i := 1 TO LEN(aRegs)
		IF !SX1->(DBSEEK(cPerg + aRegs[i, 2]))
			RecLock("SX1", .T.)
			FOR j := 1 TO LEN(aRegs[i])
				aRegs[i, 1] := cPerg // atribui o novo valor de cPerg (por conta de uma possivel alteracao) - Emerson - 29/10/2008
				IF !EMPTY(aRegs[i, j])
					SX1->(FIELDPUT(j, aRegs[i, j]))
				ENDIF
			NEXT
			SX1->(MsUnlock())
		ELSE
			aRegs[i, 1] := cPerg // atribui o novo valor de cPerg (por conta de uma possivel alteracao) - Emerson - 29/10/2008
			RecLock("SX1", .F.)
			FOR j := 1 TO LEN(aRegs[i])
				IF !EMPTY(aRegs[i, j]) .AND. !(SX1->&(FIELD(j)) == aRegs[i, j])
					SX1->(FIELDPUT(j, aRegs[i, j]))
				ENDIF
			NEXT
		
	SX1->(MsUnlock())
		ENDIF
	NEXT
return(Nil) */


/*
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Funcao  MATA_270     Autor: Claudinei E Nascimento-CAAK     Data: 04/01/2012
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Objetivo Cadastra Itens no Inventario em Lote
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
Parametros aInvItens: itens a inventariar
======= ======= ======= ======= ======= ======= ======= ======= ======= ======= ======= 
*/
user function MATA_270(aInvItens)
	local aArea := GetArea()
	MsgRun("Atualizando Inventario...",,{||U_MATA270RODA(aInvItens)})
	RestArea(aArea)
return(nil)


/**/
user function MATA270RODA(aInvItens)
	local aArea := GetArea()
	local aInvItem := {}
	//local aItem := {}
	local _nOpc := 3  //3- inclusao  5- exclusao
	local cMsgM270 := cQry := ""
	Local x
	private lMshelpAuto := .T.
	private lMsErroAuto := .F.

	For x := 1 to len(aInvItens)
		aInvItem := {}
		//Controlar se produto nao esta cadastrado e/ou bloqueado
		if Select("QRYSB1") > 0
			DBSelectArea("QRYSB1")
			DBCloseArea()
		endif
		cQry := ""
		cQry += "SELECT B1_COD,B1_MSBLQL,B1_RASTRO FROM "+RetSqlName("SB1")+" WHERE B1_FILIAL='"+xFilial("SB1")+"' AND D_E_L_E_T_='' AND B1_COD='"+aInvItens[x,1]+"'"
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRYSB1", .F., .T.)
		
		//Consulta existencia do saldo inicial do produto e informa ao usuario caso nao exista
		
		if Select("QRYSB9") > 0
			DBSelectArea("QRYSB9")
			DBCloseArea()
		endif
		cQry := ""
		cQry := "SELECT DISTINCT B9_COD,B9_LOCAL FROM "+RetSQLName("SB9")
		cQry += " WHERE B9_FILIAL='"+xFilial("SB9")+"' AND D_E_L_E_T_='' AND B9_COD='"+aInvItens[x,1]+"' AND B9_LOCAL='"+aInvItens[x,4]+"'"
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRYSB9", .F., .T.)
		if Empty(QRYSB9->B9_COD)
			cMsgM270 += "Cadastro Saldos Iniciais: "+AllTrim(aInvItens[x,1])+CRLF
		endif
        /*        
		if !Empty(aInvItens[x,2])
			//Consulta existencia do lote e informa ao usuario caso nao exista
			if Select("QRYSB8") > 0
				DBSelectArea("QRYSB8")
				DBCloseArea()
			endif
			cQry := ""
			cQry := "SELECT B8_PRODUTO,B8_LOCAL FROM "+RetSQLName("SB8")
			cQry += " WHERE B8_FILIAL='"+xFilial("SB8")+"' AND D_E_L_E_T_='' AND B8_PRODUTO='"+aInvItens[x,1]+"' AND B8_LOCAL='"+aInvItens[x,4]+"' AND B8_LOTECTL='"+aInvItens[x,2]+"'"
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRYSB8", .F., .T.)
			if Empty(QRYSB8->B8_PRODUTO)
				cMsgM270 += "Saldo Por Lote: "+AllTrim(aInvItens[x,1])+CRLF
			endif
		endif
        */

		if (!Empty(QRYSB1->B1_COD) .and. QRYSB1->B1_MSBLQL<>'1') .and. (!Empty(QRYSB1->B1_COD)) .and. iif(!Empty(aInvItens[x,2]), (!Empty(QRYSB1->B1_COD) .and. !Empty(QRYSB8->B8_PRODUTO)),.T.)
		//if (!Empty(QRYSB1->B1_COD) .and. QRYSB1->B1_MSBLQL<>'1') .and. (!Empty(QRYSB1->B1_COD) .and. !Empty(QRYSB9->B9_COD)) .and. iif(!Empty(aInvItens[x,2]), (!Empty(QRYSB1->B1_COD) .and. !Empty(QRYSB9->B9_COD) .and. !Empty(QRYSB8->B8_PRODUTO)),.T.)
			aInvItem := {{"B7_COD"       ,aInvItens[x,1]      ,Nil},;
						  		 {"B7_LOCAL"  ,aInvItens[x,4]      ,Nil},;
							  	 {"B7_TIPO"   ,aInvItens[x,5]      ,Nil},;
							  	 {"B7_DOC"    ,aInvItens[x,6]      ,Nil},;
	  							 {"B7_QUANT"  ,aInvItens[x,3]      ,Nil},;
		  						 {"B7_DATA"   ,Date()           ,Nil},;
	 	  						 {"B7_DTVALID",Date(),Nil}}


			//Begin Transaction
			//MsExecAuto({|x,y| Mata270(x,y)},aInvItem,_nOpc)
			MSExecAuto({|x,y,z| mata270(x,y,z)},aInvItem,.T.,_nOpc)
			if lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Break
			endif
			//End Transaction
		endif

	next

	RestArea(aArea)
return(cMsgM270)
