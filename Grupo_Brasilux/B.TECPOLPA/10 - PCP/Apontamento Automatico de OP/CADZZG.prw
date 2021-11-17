#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "SIGAWIN.CH"
#include "STDWIN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCADZZG     บ Autor ณ AP6 IDE           บ Data ณ  27/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro dos Logดs das Etiquetas Impressas		          บฑฑ
ฑฑบ          ณ Reimprimir Etiquetas                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CADZZG

	Private cPerg   := ""
	Private cCadastro := "Cadastro dos logดs das etiquetas impressas"
/*
aCores :=   {{'ZZE_RESOLV == "1" ' , 'ENABLE'},;		// RESOLVIDO
             {'ZZE_RESOLV == "2" ' , 'BR_VERMELHO' }}	// PENDENTE
*/
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","AxVisual",0,2} ,;
		{"Reimprimir","U_REIMPETI",0,7},;
		{"Estornar","U_ESTETIQ",0,8}}

/*
{"Incluir","AxInclui",0,3} ,;
{"Alterar","AxAltera",0,4} ,;
{"Excluir","AxDeleta",0,5},;
*/
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "ZZG"

	dbSelectArea("ZZG")
	dbSetOrder(1)
	cPerg   := ""
	dbSelectArea(cString)
//mBrowse( 6,1,22,75,cString)
//mBrowse( 6,1,22,75,cString,,,,,6,aCores)
	mBrowse( 6,1,22,75,cString)
	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

Return

/*
User Function LegCadZZ()
        aLegenda := {{"BR_VERDE","RESOLVIDO"},;
                     {"BR_VERMELHO", "PENDENTE"}}

BrwLegenda("Situa็ใo do Atendimento no Sistema","Legenda",aLegenda)
Return
*/

//Funcao que reimprime a etiqueta
USER FUNCTION REIMPETI(cAlias, nRecno, nOPc)
	Private cPorta	 	:= "LPT1"
	Private cModelo  	:= "ZT230"
	Private lStatus		:= .F.
	Private cB1XCod		:= ""
	Private cCodBar		:= ""
	Private dDtValid	:= dDataBase
	Private cNomeCli	:= ""
	Private	_cQryEtiq	:= ""
	Private cUpdZZG		:= ""

	_cQryEtiq	:=" SELECT * FROM "+RETSQLNAME("ZZG")
	_cQryEtiq	+="	WHERE "
	_cQryEtiq	+="	R_E_C_N_O_ = '"+cValToChar(nRecno)+"' "

	IF SELECT("TMETI")<>0
		TMETI->(DBCLOSEAREA())
	ENDIF

	TcQuery _cQryEtiq NEW ALIAS "TMETI"

	DBSELECTAREA("TMETI")
	TMETI->(DBGOTOP())

	WHILE TMETI->(!EOF())
		//ABRE A COMUNICACAO COM A IMPRESSORA
		MSCBPRINTER(cModelo,cPorta,,,.f.,,,,)
		MSCBCHKStatus(lStatus)

		//INICIALIZA A PAGINA
		MSCBBEGIN(4/*copias*/,5/*velocidade*/,223/*tamanho*/)	//Nใo precisa dar loop para imprimir a quantidade de etiquetas, a impressora da loop sozinha!
		MSCBBOX(30,05,76,05)
		MSCBBOX(02,12.7,76,12.7)
		MSCBBOX(02,21,120,21)
		MSCBBOX(30,01,30,12.7,3)
		MSCBSAY(33,02,"F033: ID. DO PALLET / PRODUTO ","N","0","025,035")
		MSCBSAY(33,06,"CODIGO","N","B","012,008")
		MSCBSAY(33,08,TMETI->ZZG_PRODUT, "N", "0", "032,035")
		MSCBSAY(05,14,"DESCRICAO","N","B","012,008")
		MSCBSAY(05,16,POSICIONE("SB1",1,XFILIAL("SB1")+TMETI->ZZG_PRODUTO,"B1_DESC"),"N", "0", "032,035")
		MSCBSAY(05,23,"LOTE/VALIDADE","N","B","012,008")
		MSCBSAY(05,25,ALLTRIM(TMETI->ZZG_OP) +"  /  "+ Transform(sToD(TMETI->ZZG_DTVALI),"@E") ,"N", "0", "020,030")
		MSCBSAY(75,23,"QUANTIDADE","N","B","012,008")
		MSCBSAY(75,25,cValToChar(TMETI->ZZG_QTD),"N", "0", "020,030") //Quantidade de caixas no Pallet
		MSCBSAY(105,23,"VOLUME","N","B","012,008")
		MSCBSAY(105,25,"01/01","N", "0","020,030")
		MSCBBOX(02,30,150,30)
		cB1Xcod	:= POSICIONE("SB1",1,XFILIAL("SB1")+TMETI->ZZG_PRODUT,"B1_XCOD")

		//cCodBar := REPLICATE(' ',6-Len(Alltrim(cB1XCod)))  + Alltrim(cB1XCod) + REPLICATE(' ',12-Len(Alltrim(TMETI->ZZG_OP))) + Alltrim(TMETI->ZZG_OP) + Strzero(TMETI->ZZG_QTD*100,9)
		//Como ้ formado o c๓digo de barras?
		//Ele tem 27 caracteres que ้ o tamanho mแximo que cabe na etiqueta 10cmx7cm
		//6 = B1XCOD
		//6 = SEQUENCIAL DA ETIQUETA
		//6 = NUMERO DA OP
		//9 = QUANTIDADE DE PA DAQUELA ETIQUETA * 100
		//EX.: 004012 000001 001327 000000100
		cCodBar	:= 	Replicate(' ',6-Len(Alltrim(cB1XCod))) + Alltrim(cB1XCod) + Replicate('0',12-Len(Alltrim(TMETI->ZZG_OP))-Len(Alltrim(cValToChar(TMETI->ZZG_SEQUEN)))) + Alltrim(cValToChar(TMETI->ZZG_SEQUEN)) + Alltrim(TMETI->ZZG_OP) + Strzero(TMETI->ZZG_QTD*100,9)
		MSCBSAYBAR(05,34,cCodBar,"N","MB07",/*8.36*/ 18,.F.,.T.,.F.,,2.4 ,1,.F.,.F.,"1",.T.)

		IF SubStr(TMETI->ZZG_PRODUT,2,3) $ 'AAA'
			cNomeCli	:= "TECPOLPA"
		Else
			cNomeCli	:= Posicione("SA1",12,XFILIAL("SA1")+Substr(TMETI->ZZG_PRODUT,2,3),"A1_NOME")
		ENDIF
		MSCBSAY(05,67,cNomeCli,"N","0","032,035")

		//FECHA A PAGINA
		MSCBEND()

		//FECHA A COMUNICACAO COM A IMPRESSORA
		MSCBCLOSEPRINTER()

		//GRAVA A QUANTIDADE DE REIMPRESSOES

		BEGIN TRANSACTION
			cUpdZZG	:="	UPDATE "+RETSQLNAME("ZZG")
			cUpdZZG	+=" SET ZZG_REIMP = '"+cValToChar(VAL(TMETI->ZZG_REIMP)+1)+"' "
			cUpdZZG	+="	WHERE "
			cUpdZZG	+="	R_E_C_N_O_ = '"+cValToChar(nRecno)+"' "
			TCSQLEXEC(cUpdZZG)
			TCSQLEXEC("Commit")
		END TRANSACTION

		//SALTA PARA A PRำXIMA LINHA DO SELECT
		TMETI->(DBSKIP())
	ENDDO
RETURN

//Fun็ใo que estorna a etiqueta
//1) O usuแrio acessarแ a rotina onde estใo os logดs das etiquetas.
//1.1) Clicarแ em Outras A็๕es - Estornar
//2) A tela do estorno vai aparecer.
//2.1) Ele vai fazer a leitura do c๓digo de barras atrav้s do leitor.
//3) O usuแrio clica em "OK".
//4) A rotina transfere de volta do E1PA para o EPCP o produto e a quantidade referente เquela etiqueta.
//4.1) A rotina faz o estorno da Produ็ใo.
//4.2) A rotina marca aquela etiqueta como estornada.

User Function ESTETIQ()
	Static oDlg
	Static oButton1
	Static oButton2
	Static oGet1
	Static cGet1 := Space(27)
	Static oSay1
	Static oSay2
	IF cNivel < 6
		Alert("Voc๊ nใo tem permissao para acessar essa rotina! Favor procurar o T.I.")
	Elseif cNivel >= 6
		IF Len(Alltrim(cGet1)) <> 0
			cGet1	:= Space(27)
		ENDIF

		DEFINE MSDIALOG oDlg TITLE "Estornar Etiqueta" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

		@ 021, 095 SAY oSay1 PROMPT "Estornar Etiqueta" SIZE 047, 009 OF oDlg COLORS 0, 16777215 PIXEL
		@ 052, 009 SAY oSay2 PROMPT "Codigo da Etiqueta" SIZE 051, 012 OF oDlg COLORS 0, 16777215 PIXEL
		@ 050, 067 MSGET oGet1 VAR cGet1 SIZE 140, 012 OF oDlg COLORS 0, 16777215 PIXEL
		@ 084, 042 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlg PIXEL ACTION (Processa( {|| EstEtiq(cGet1), oDlg:End()},"Aguarde, estornando a etiqueta..."))
		@ 083, 150 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION(oDlg:End())
		ACTIVATE MSDIALOG oDlg
	ENDIF
Return

Static Function EstEtiq(cGet1)
	Local nX			:= 0
	Local _cMVXCODPL    := GETMV("MV_XCODPLT")  //LGS#20200207 - Adequa็ใo de release 12.1.25 e posteriores
	Private cB1XCod		:= Substr(cGet1,1,6)
	Private cSequen		:= Substr(cGet1,7,6)
	Private cNumOP		:= Substr(cGet1,13,6)
	Private nQtdOP		:= Val(Substr(cGet1,19,9))/100
	Private cQryZZG		:= ""
	Private aSld		:= {}
	Private lTrPrd		:= .F.	//TRANSFERE PRODUTO
	Private lTrPlt		:= .F.	//TRANSFERE PALLET
	Private cH6Ident	:= ""	//SH6_IDENT
	Private aVetEst		:= {}
	Private lMsErroAuto := .F.
	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile	:= .T.
	Private cErro			:= ""
	//Dados para transferir o produto principal de volta para o EPCP
	// Pega a variavel que identifica se o calculo do custo ้: O = Online / M = Mensal
	PRIVATE cCusMed := GetMv("MV_CUSMED")
	PRIVATE cCadastro:= "Transferencias"
	PRIVATE aRegSD3 := {}
	// Verifica se o custo medio ้ calculado On-Line
	If cCusMed == "O"
		PRIVATE nHdlPrv 			// Endereco do arquivo de contra prova dos lanctos cont.
		PRIVATE lCriaHeader := .T. 	// Para criar o header do arquivo Contra Prova
		PRIVATE cLoteEst      		// Numero do lote para lancamentos do estoque

	// Posiciona numero do Lote para Lancamentos do Faturamento
		dbSelectArea("SX5")
		dbSeek(xFilial()+"09EST")
		cLoteEst:=IIF(Found(),Trim(X5Descri()),"EST ")
		PRIVATE nTotal := 0      	// Total dos lancamentos contabeis
		PRIVATE cArquivo     		// Nome do arquivo contra prova
	ENDIF

	//DETALHES SOBRE O SELECT
	//1) ZZG_ERRO: 1-SIM, 2-NAO.
	//1.1)SE TEM ERRO = NรO TEM IDENT.
	//1.2)SE NAO TEM IDENT = NAO GEROU PRODUCAO.
	//1.3)SE NAO GEROU PRODUCAO = NAO HA O QUE TRANSFERIR DE VOLTA.
	//1.4)SE NAO HA O QUE TRANSFERIR DE VOLTA = NAO HA PRODUCAO A SER ESTORNADA PELO EXECAUTO MATA681.
	//2) ZZG_ESTORN = ''
	//2.1) SE A ETIQUETA Jม FOI ESTORNADA UMA VEZ, NรO Hม COMO REALIZAR O ESTORNO DELA NOVAMENTE E ELA NรO PODE SER REAPROVEITADA.
	cQryZZG	:="	SELECT * FROM "+RetSqlName("ZZG")
	cQryZZG	+="	WHERE "
	cQryZZG	+=" ZZG_FILIAL = '"+xFilial("ZZG")+"' "
	cQryZZG	+=" AND "
	cQryZZG	+="	ZZG_OP = '"+cNumOP+"' "
	cQryZZG	+="	AND "
	cQryZZG	+="	ZZG_SEQUEN = '"+cValToChar(Val(cSequen))+"' "

	If Select("TMZZG") <> 0
		TMZZG->(DbCloseArea())
	ENDIF

	TcQuery cQryZZG NEW ALIAS "TMZZG"

	DBSELECTAREA("TMZZG")
	TMZZG->(DBGOTOP())

	//Verificar se a etiqueta realmente existe
	IF TMZZG->(EOF())
		Alert("Etiqueta Inexistente!")
		Return
	ENDIF

	//Verificar se a etiqueta jแ foi estornada
	TMZZG->(DBGOTOP())
	WHILE TMZZG->(!EOF())
		IF ALLTRIM(TMZZG->ZZG_ESTORN) <> ''
			Alert("Etiqueta jแ estornada!")
			Return
		ENDIF
		TMZZG->(DBSKIP())
	ENDDO

	TMZZG->(DBGOTOP())
	WHILE TMZZG->(!EOF())
		IF TMZZG->ZZG_ERRO == "2"	//NAO PODE TER OCORRIDO ERRO NA GERACAO DA OP QUE ORIGINOU ESSA ETIQUETA. 1-SIM, 2-NAO

			//SALVAR OS DADOS QUE IDENTIFICAM QUAL ษ A IDENT DA SH6
			cH6Ident	:= TMZZG->ZZG_IDENTD

			//VERIFICAR SE OS ITENS (PALLET E PRODUTO PRODUZIDO) TEM SALDO NO E1PA ANTES DE TRANSFERI-LOS DE VOLTA AO EPCP.
			//SO FAZ O ESTORNO DA OP SE REALMENTE FOR POSSIVEL TRANSFERIR O PALLET E O PRODUTO DE VOLTA AO EPCP.
			//LEMBRAR QUE O PALLET = 1 POR ETIQUETA E QUE A MESMA ETIQUETA SEMPRE ษ IMPRESSA EM QUATRO VIAS, UMA PARA CADA LADO DO PALLET
			DBSELECTAREA("SB2")
			SB2->(DBSETORDER(1))
			SB2->(DBGOTOP())
			IF SB2->(MSSEEK(XFILIAL("SB2")+TMZZG->ZZG_PRODUT+"E1PA"))
				IF SB2->B2_QATU >= nQtdOP
					lTrPrd	:= .T.
				ELSEIF SB2->B2_QATU < nQtdOP
					MsgAlert("Nใo ้ possํvel transferir o PA do E1PA de volta para o EPCP", "Verificar Saldo E1PA")
					cErro += "Nใo foi possํvel transferir o PA do E1PA de volta para o EPCP." + Chr(13)+Chr(10)
				ENDIF
			ENDIF

			SB2->(DBGOTOP())
			//LGS#20200207 - Adequa็ใo de release 12.1.25 e posteriores
			//IF SB2->(MSSEEK(XFILIAL("SB2")+GETMV("MV_XCODPLT")+"E1PA"))
			IF SB2->(MSSEEK(XFILIAL("SB2")+_cMVXCODPL+"E1PA"))
				IF SB2->B2_QATU >= 1
					lTrPlt	:= .T.
				ELSEIF SB2->B2_QATU < 1
					MsgAlert("Nใo ้ possํvel transferir o Pallet do E1PA de volta para o EPCP", "Verificar Saldo E1PA")
					cErro += "Nใo foi possํvel transferir o Pallet do E1PA de volta para o EPCP." + Chr(13)+Chr(10)
				ENDIF
			ENDIF
			SB2->(DBCLOSEAREA())

			IF	lTrPrd .and. lTrPlt
			//Transfiro o Pallet de Volta para o EPCP
				//LGS#20200207 - Adequa็ใo de release 12.1.25 e posteriores
				//cCodOrig   	:= GETMV("MV_XCODPLT")   			//Codigo do Produto Origem - Obrigatorio
				cCodOrig   	:= _cMVXCODPL           			//Codigo do Produto Origem - Obrigatorio
				cLocOrig   	:= "E1PA"                    		//Almox Origem             - Obrigatorio
				nQuant260 	:= 1		     					//Quantidade 1a UM        - Obrigatorio
				cDocto     	:= NextNumero("SD3",8,"D3_DOC",.T.) //Documento               - Obrigatorio
				dEmis260   	:= dDataBase            			//Data                     - Obrigatorio
				nQuant260D 	:= Nil     							//Quantidade 2a UM
				cNumLote   	:= Nil                    			//Sub-Lote - obrigat๓rio apenas qdo MV_RASTRO ==‘S‘
				cLoteDigi 	:= cNumOP     						//Lote - obrigat๓rio apenas qdo MV_RASTRO ==‘L‘
				dDtValid   	:= dDataBase     					//Validade - Obrigatorio se usa Rastro
				cNumSerie 	:= Nil                   			//Numero de Serie
				cLoclzOrig 	:= Nil                   			//Localizacao Origem
				//LGS#20200207 - Adequa็ใo de release 12.1.25 e posteriores
				//cCodDest   	:= GETMV("MV_XCODPLT") 				//Codigo do Produto Destino     - Obrigatorio
				cCodDest   	:= _cMVXCODPL        				//Codigo do Produto Destino     - Obrigatorio
				cLocDest   	:= "EPCP"                           //Almox Destino            - Obrigatorio
				cLocLzDest 	:= Nil               				//Localizacao Destino
				lEstorno   	:= .f.               				//Indica se movimento e estorno
				nRecOrig   	:= Nil               				//Numero do registro original (utilizado estorno)
				nRecDest   	:= Nil               				//Numero do registro destino (utilizado estorno)
				cPrograma 	:= "MATA261"        				//Indicacao do programa que originou os lancamentos
				cEstFis    	:= Nil                    			//cEstFis    - Estrutura Fisica          (APDL)
				cServico   	:= Nil               				//cServico   - Servico                   (APDL)
				cTarefa    	:= Nil                    			//cTarefa    - Tarefa                    (APDL)
				cAtividade 	:= Nil                   			//cAtividade - Atividade                 (APDL)
				cAnomalia 	:= Nil                    			//cAnomalia - Houve Anomalia? (S/N)     (APDL)
				cEstDest   	:= Nil                    			//cEstDest   - Estrututa Fisica Destino (APDL)
				cEndDest   	:= Nil                    			//cEndDest   - Endereco Destino          (APDL)
				cHrInicio 	:= Nil                    			//cHrInicio - Hora Inicio               (APDL)
				cAtuEst    	:= Nil                    			//cAtuEst    - Atualiza Estoque? (S/N)   (APDL)
				cCarga     	:= Nil                    			//cCarga     - Numero da Carga           (APDL)
				cUnitiza   	:= Nil                    			//cUnitiza   - Numero do Unitizador      (APDL)
				cOrdTar    	:= Nil                    			//cOrdTar    - Ordem da Tarefa           (APDL)
				cOrdAti    	:= Nil                    			//cOrdAti    - Ordem da Atividade        (APDL)
				cRHumano   	:= Nil                    			//cRHumano   - Recurso Humano            (APDL)
				cRFisico   	:= Nil                    			//cRFisico   - Recurso Fisico            (APDL)
				nPotencia 	:= Nil                    			//nPotencia - Potencia do Lote
				cLoteDest 	:= Nil 								//cLoteDest - Lote Destino da Transferencia

	    		//Gravando a transfer๊ncia de retorno do Pallet
				If !a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico,nPotencia,cLoteDest)
					MsgBox( "Erro de processamento na Transfer๊ncia. Lote Destino: "+cLoteDest+"."+CHR(13) +;
						"Favor entrar em contato com o administrador do sistema.")
					cErro += "A260Processa - Nใo foi possํvel transferir o Pallet de volta do E1PA para o EPCP." + Chr(13)+Chr(10)
				Endif


				//Transfiro o PA de Volta para o EPCP
				cCodOrig   	:= TMZZG->ZZG_PRODUT	   			//Codigo do Produto Origem - Obrigatorio
				cLocOrig   	:= "E1PA"                    		//Almox Origem             - Obrigatorio
				nQuant260 	:= TMZZG->ZZG_QTD  					//Quantidade 1a UM        - Obrigatorio
				cDocto     	:= NextNumero("SD3",8,"D3_DOC",.T.) //Documento               - Obrigatorio
				dEmis260   	:= dDataBase            			//Data                     - Obrigatorio
				nQuant260D 	:= Nil     							//Quantidade 2a UM
				cNumLote   	:= Nil                  			//Sub-Lote - obrigat๓rio apenas qdo MV_RASTRO ==‘S‘
				cLoteDigi 	:= cNumOP     						//Lote - obrigat๓rio apenas qdo MV_RASTRO ==‘L‘
				dDtValid   	:= dDataBase     					//Validade - Obrigatorio se usa Rastro
				cNumSerie 	:= Nil                   			//Numero de Serie
				cLoclzOrig 	:= Nil                   			//Localizacao Origem
				cCodDest   	:= TMZZG->ZZG_PRODUT 				//Codigo do Produto Destino     - Obrigatorio
				cLocDest   	:= "EPCP"                           //Almox Destino            - Obrigatorio
				cLocLzDest 	:= Nil               				//Localizacao Destino
				lEstorno   	:= .f.               				//Indica se movimento e estorno
				nRecOrig   	:= Nil               				//Numero do registro original (utilizado estorno)
				nRecDest   	:= Nil               				//Numero do registro destino (utilizado estorno)
				cPrograma 	:= "MATA261"        				//Indicacao do programa que originou os lancamentos
				cEstFis    	:= Nil                    			//cEstFis    - Estrutura Fisica          (APDL)
				cServico   	:= Nil               				//cServico   - Servico                   (APDL)
				cTarefa    	:= Nil                    			//cTarefa    - Tarefa                    (APDL)
				cAtividade 	:= Nil                   			//cAtividade - Atividade                 (APDL)
				cAnomalia 	:= Nil                    			//cAnomalia - Houve Anomalia? (S/N)     (APDL)
				cEstDest   	:= Nil                    			//cEstDest   - Estrututa Fisica Destino (APDL)
				cEndDest   	:= Nil                    			//cEndDest   - Endereco Destino          (APDL)
				cHrInicio 	:= Nil                    			//cHrInicio - Hora Inicio               (APDL)
				cAtuEst    	:= Nil                    			//cAtuEst    - Atualiza Estoque? (S/N)   (APDL)
				cCarga     	:= Nil                    			//cCarga     - Numero da Carga           (APDL)
				cUnitiza   	:= Nil                    			//cUnitiza   - Numero do Unitizador      (APDL)
				cOrdTar    	:= Nil                    			//cOrdTar    - Ordem da Tarefa           (APDL)
				cOrdAti    	:= Nil                    			//cOrdAti    - Ordem da Atividade        (APDL)
				cRHumano   	:= Nil                    			//cRHumano   - Recurso Humano            (APDL)
				cRFisico   	:= Nil                    			//cRFisico   - Recurso Fisico            (APDL)
				nPotencia 	:= Nil                    			//nPotencia - Potencia do Lote
				cLoteDest 	:= Nil 								//cLoteDest - Lote Destino da Transferencia

	    		//Gravando a transfer๊ncia de retorno do PA
				If !a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico,nPotencia,cLoteDest)
					MsgBox( "Erro de processamento na Transfer๊ncia. Lote Destino: "+cLoteDest+"."+CHR(13) +;
						"Favor entrar em contato com o administrador do sistema.")
					cErro += "A260Processa - Nใo foi possํvel transferir o PA de volta do E1PA para o EPCP." + Chr(13)+Chr(10)
				Endif
			ENDIF
		ENDIF
		TMZZG->(DBSKIP())
	ENDDO

	//FECHAR A TABELA QUE ESTAVA EM USO
	TMZZG->(DBCLOSEAREA())

	//SE HOUVE A TRANSFERENCIA DO PALLET E DO PRODUTO 'PA' DE VOLTA PARA O EPCP, SIGNIFICA QUE HOUVE PRODUCAO E ENTAO DEVE EXISTIR O ESTORNO DELA.
	IF	lTrPrd .and. lTrPlt

		cQrySH6	:="	SELECT * FROM "+RetSqlName("SH6")
		cQrySH6	+="	WHERE "
		cQrySH6	+=" H6_IDENT IN ("+Alltrim(cH6Ident)+")"
		cQrySH6 +="	ORDER BY H6_OP "

		If Select("TMSH6") <> 0
			TMSH6->(DBCLOSEAREA())
		ENDIF
		TcQuery cQrySH6 NEW ALIAS "TMSH6"

		DBSELECTAREA("TMSH6")
		TMSH6->(DBGOTOP())
		WHILE TMSH6->(!EOF())
			DbSelectArea("SH6")
			SH6->(DbSetOrder(2))	//H6_FILIAL+H6_PRODUTO+H6_OP
			IF DBSEEK(xFilial("SH6")+TMSH6->H6_PRODUTO+TMSH6->H6_OP)
				AADD(aVetEst, {"H6_FILIAL"		,	xFilial("SH6")																			,Nil})
				AADD(aVetEst, {"H6_PRODUTO" 	,	Alltrim(TMSH6->H6_PRODUTO)																,NIL})
				AADD(aVetEst, {"H6_OP"	   		,	Alltrim(TMSH6->H6_OP)							  										,NIL})
				AADD(aVetEst, {"INDEX"			,	2																						,NIL})

				//Executa o estorno
				Begin Transaction
					MSExecAuto({|x,Y| MATA681(x,Y)},aVetEst,5)	//5 - ESTORNO
				End Transaction

				//Limpar o vetor para poder fazer o estorno do pr๓ximo sequencial
				aVetEst	:= {}

				IF lMsErroAuto
					aLogErro := GetAutoGRLog()
					For nX := 1 To Len(aLogErro)
						cErro += aLogErro[nX] + Chr(13)+Chr(10)
					Next nX
					Alert(cErro)
				ENDIF
			ENDIF
			TMSH6->(DBSKIP())
		ENDDO
		TMSH6->(DBCLOSEAREA())
	ENDIF

	//MARCAR A ETIQUETA COMO ESTORNADA INDEPENDENTE DA SITUAวรO
	cUpdEtiq :=" UPDATE "+RetSqlName("ZZG")
	cUpdEtiq +=" SET ZZG_ESTORN = '1' "
	IF !EMPTY(cErro)
		cUpdEtiq +=" , ZZG_ERREST = '"+cErro+"' "
	ENDIF
	cUpdEtiq +=" WHERE "
	cUpdEtiq +=" ZZG_CODBAR = '"+cGet1+"' "
	TCSQLEXEC(cUpdEtiq)
	TCSQLEXEC("Commit")

	//Limpar a variแvel do erro porque o usuแrio poderแ executar novamente a rotina sem sair da tela
	cErro := ""

	//Avisar ao usuario que a etiqueta foi estornada.
	MsgAlert("Etiqueta Estornada com sucesso","Fim!")
Return