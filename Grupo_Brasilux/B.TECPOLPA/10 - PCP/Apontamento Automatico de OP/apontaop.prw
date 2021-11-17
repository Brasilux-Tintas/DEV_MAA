#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "SIGAWIN.CH"
#include "STDWIN.CH"

/*
Static oFont1 := TFont():New("MS Serif",,089,,.T.,,,,,.F.,.F.)
Static oFont2 := TFont():New("Arial Narrow",,030,,.F.,,,,,.F.,.F.)
*/

User Function apontaop(cAlias, nRecno, nOpc)
	Private lMsErr	:= .F.
	Private aIdent	:= {}
	Static oDlg
	Static oButton1
	Static oButton2
	Static oButton3
	Static oGet1
	Static cGet1 := Space((TamSX3("C2_NUM")[1]))
	Static oGet2
	Static cGet2 := Space((TamSX3("C2_SEQUEN")[1]))
	Static oGet3
	Static cGet3 := Space((TamSX3("B1_DESC")[1]))
	Static oSay1
	Static oSay2
	Static oFont1 := TFont():New("MS Serif",,089,,.T.,,,,,.F.,.F.)
	Static oFont2 := TFont():New("Arial Narrow",,030,,.F.,,,,,.F.,.F.)
	Static oFont3 := TFont():New("Arial Narrow",,050,,.F.,,,,,.F.,.F.)

	DEFINE MSDIALOG oDlg TITLE "Apontar OP" FROM 000, 000  TO 550, 1100 COLORS 0, 16777215 PIXEL


	@ 065, 021 SAY oSay1 PROMPT "Digite o numero do lote" SIZE 129, 020 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 060, 162 MSGET oGet1 VAR cGet1 SIZE 144, 027 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL VALID SUGPALLET(cGet1)
	@ 155, 018 SAY oSay2 PROMPT "Qtd. de caixas x Pallet" SIZE 137, 029 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 154, 163 MSGET oGet2 VAR cGet2 SIZE 143, 030 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL VALID ValidcGet(cGet1,cGet2,cGet3)
	@ 213, 024 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlg PIXEL ACTION (Processa( {|| processaop(cGet1,cGet2,cGet3,cAlias,nRecno,nOpc,@lMsErr,@aIdent)},"Aguarde, gravando a OP..."),;
		Processa( {|| imprimeeti(cGet1,cGet2,cAlias,nRecno,nOpc,lMsErr,aIdent)},"Aguarde, imprimindo a etiqueta..."),;
		LIMPATELA(cGet1))
	@ 213, 200 BUTTON oButton2 PROMPT "Limpa Tela" SIZE 037, 012 OF oDlg PIXEL ACTION(LIMPATELA(cGet1))
	@ 214, 421 BUTTON oButton3 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION(oDlg:End())
	@ 095, 162 MSGET oGet3 VAR cGet3 SIZE 297, 041 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL WHEN .F.


/*
	@ 044, 173 SAY oSay1 PROMPT "Digite o numero do lote" SIZE 129, 020 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 076, 162 MSGET oGet1 VAR cGet1 SIZE 144, 053 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL VALID SUGPALLET(cGet1)
	@ 187, 102 SAY oSay2 PROMPT "Qtd. de caixas x Pallet" SIZE 137, 031 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
	@ 188, 255 MSGET oGet2 VAR cGet2 SIZE 143, 031 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL VALID ValidcGet(cGet1,cGet2,cGet3)
	@ 230, 101 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlg PIXEL ACTION (Processa( {|| processaop(cGet1,cGet2,cAlias,nRecno,nOpc)},"Aguarde, gravando a OP..."),;
		Processa( {|| imprimeetiq(cGet1,cGet2,cAlias,nRecno,nOpc)},"Aguarde, imprimindo a etiqueta..."),;
		LIMPATELA(cGet1))

	@ 229, 246 BUTTON oButton2 PROMPT "Limpa Tela" SIZE 037, 012 OF oDlg PIXEL ACTION(LIMPATELA(cGet1))
	@ 228, 378 BUTTON oButton3 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION(oDlg:End())
	@ 133, 101 MSGET oGet3 VAR cGet3 SIZE 297, 048 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL WHEN .F.

*/
	ACTIVATE MSDIALOG oDlg

Return

//SUGERIR A QUANTIDADE DE CAIXAS POR PALLET COM BASE NA TABELA DOS LASTROS.
Static Function sugpallet(cGet1)
	Local nSugestao	:= 0
	Local cDescProd	:= ""

	IF (Len(Alltrim(cGet1))<(TamSX3("C2_NUM")[1]))
		cGet1 := PADL(AllTrim(cGet1),(TamSX3("C2_NUM")[1]),"0")
	ENDIF

	DBSELECTAREA("SC2")
	SC2->(DBSETORDER(1))
	SC2->(DBGOTOP())

	IF SC2->(DBSEEK(XFILIAL("SC2")+cGet1))
		While SC2->(!EOF().AND. (SC2->(XFILIAL("SC2") == SC2->C2_FILIAL .AND. cGet1 == SC2->C2_NUM)))
			IF  (Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_TIPO")) $ "PA-TA"
				cDescProd	:= Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DESC")
				nSugestao	:= ((Posicione("SB5",1,XFILIAL("SB5")+SC2->C2_PRODUTO,"B5_EMPMAX"))*(Posicione("SB5",1,XFILIAL("SB5")+SC2->C2_PRODUTO,"B5_ECPROFU")))
			ENDIF
			SC2->(DBSKIP())
		ENDDO
	ENDIF

	//Fechando a tabela que estava aberta
	SC2->(DBCLOSEAREA())

	//Carregar a variável da sugestao e dar refresh na tela
	cGet2	:= PADL(nSugestao,(TamSX3("C2_SEQUEN")[1]),"0")
	cGet3	:= cDescProd

	oGet2:cText	:= cGet2
	oGet3:cText	:= cGet3
	oGet2:Refresh()
	oGet3:Refresh()
	oDlg:Refresh()
Return

//GRAVAR OU CORRIGIR A OP
Static Function processaop(cGet1,cGet2,cGet3,cAlias,nRecno,nOpc,lMsErr,aIdent)
	Local nX				:= 0
	Private aVetor 			:= {}
	Private cErro			:= ""
	Private lMsErroAuto 	:= .F.
	Private aLogErro		:= {}
	//Private nX
	Private _cQry			:= ""
	Private _cQryNo			:= ""
	Private _cUpd			:= ""
	Private cPrdPrincipal	:= ""
	Private nQtdMult		:= 0
	Private lGravaOp		:= .T.
	Private lAutoErrNoFile	:= .T.	//SEM ESSA VARIAVEL A FUNCAO DE GRAVAR O ERRO NAO RETORNA NADA.
	PRIVATE lMsHelpAuto 	:= .T.
	Private nSugest1		:= 0
	Private cB1XTMPPROD		:= ""
	Private cHrIniProd		:= ""
	Private nNQtdHoras		:= 0
	Private dDataIni		:= {}
	//LGS#20200207 - Adequação de release 12.1.25 e posteriores
	PRIVATE cCusMed := GetMv("MV_CUSMED")
	PRIVATE cCadastro:= "Transferencias"
	PRIVATE aRegSD3 := {}

	IF (Len(Alltrim(cGet1))<(TamSX3("C2_NUM")[1]))
		cGet1 := PADL(AllTrim(cGet1),(TamSX3("C2_NUM")[1]),"0")
	ENDIF

	//A QUANTIDADE DIGITADA NAO PODE SER MAIOR QUE O LASTRO...
	//...ESSA VALIDACAO FOI INCLUIDA AQUI PORQUE O USUARIO PODE SIMPLESMENTE PULAR O CAMPO DA QUANTIDADE E CLICAR NO "OK".
	DBSELECTAREA("SC2")
	SC2->(DBGOTOP())
	SC2->(DBSETORDER(1))
	IF SC2->(DBSEEK(XFILIAL("SC2")+cGet1))
		While SC2->(!EOF().AND. (SC2->(XFILIAL("SC2") == SC2->C2_FILIAL .AND. cGet1 == SC2->C2_NUM)))
			IF  (Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_TIPO")) $ "PA-TA"
				nSugest1	:= ((Posicione("SB5",1,XFILIAL("SB5")+SC2->C2_PRODUTO,"B5_EMPMAX"))*(Posicione("SB5",1,XFILIAL("SB5")+SC2->C2_PRODUTO,"B5_ECPROFU")))
			ENDIF
			SC2->(DBSKIP())
		ENDDO
	ENDIF
	SC2->(DBCLOSEAREA())

	IF nSugest1 < Val(cGet2)
		Alert("A quantidade digitada não pode ser maior que o lastro permitido para esse produto!")
		cGet2 := Space((TamSX3("C2_SEQUEN")[1]))
		oGet2:cText	:= cGet2
		oGet2:Refresh()
		Return .T.
	ENDIF


	//Se o usuário estiver tentando corrigir a OP ele chamou essa função de dentro de uma FWMBROWSE (U_FWMBRZZE)...
	//... e ela passou pra ele um cAlias. Isso indica que é uma correção.
	//A tela apareceu, ele digitou novamente o número da OP...
	//... a rotina vai encontrar os dados na ZZE, setar o campo ZZE_CORRIGE = "1" indicando que aquele erro foi corrigido e, se der errado novamente...
	//... a rotina vai gravar uma outra linha na ZZE e vai mandar e-mail novamente.
	IF !EMPTY(cAlias)	//Alias passado pela rotina U_FWMBRZZE
		_cQryNo :="	SELECT ZZE_FILIAL, ZZE_OP, ZZE_RESOLV, ZZE_OK FROM "+RetSqlName("ZZE")
		_cQryNo	+="	WHERE "
		_cQryNo	+="	SUBSTRING(ZZE_OP,1,6) = '"+Substr(cGet1,1,6)+"' "
		_cQryNo	+=" AND "
		_cQryNo	+="	ZZE_RESOLV = '2' "
		_cQryNo +=" AND "
		_cQryNo +=" ZZE_OK <> '' "

		IF SELECT("TMZZE")<>0
			TMZZE->(DBCLOSEAREA())
		ENDIF

		TcQuery _cQryNo NEW ALIAS "TMZZE"

		//Agora valido se o usuario realmente digitou o número correto da OP a ser marcada como corrigida na ZZE
		//Lembrar:
		//1) O usuário pode estar despercebido e digitar o número de uma OP que não tinha erro.
		//2) A rotina só dá update na tabela para o caso da OP realmenter conter um erro.
		DBSELECTAREA("TMZZE")
		TMZZE->(DBGOTOP())
		IF TMZZE->(!EOF())
			_cUpd :="	UPDATE "+RetSqlName("ZZE")
			_cUpd +="	SET ZZE_RESOLV = '1', ZZE_OK = '' "
			_cUpd +="	WHERE "
			_cUpd +="	ZZE_FILIAL ='"+XFILIAL("ZZE")+"' "
			_cUpd +="	AND "
			_cUpd +="	SUBSTRING(ZZE_OP,1,6) = '"+Substr(cGet1,1,6)+"' "
			_cUpd +="	AND "
			_cUpd +="	ZZE_OK <> '' "
			TCSQLEXEC(_cUpd)
			TCSQLEXEC("Commit")
			TMZZE->(DBCLOSEAREA())
		ELSEIF TMZZE->(EOF())
			Alert("Nenhum lote foi marcado para correção!")
			lGravaOp := .F.
			oDlg:End()
		ENDIF
	ENDIF

	If lGravaOp
		_cQry	:=" SELECT DISTINCT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_QUANT, C2_QUJE, C2_LOCAL, C2_EMISSAO, B1_FILIAL, B1_COD, B1_GRUPO, B1_TIPO "
		_cQry	+=" FROM "+RetSqlName("SC2")+" C2 "
		_cQry	+=" INNER JOIN "+RetSqlName("SB1")+" B1 "
		_cQry	+=" ON "
		_cQry	+=" C2.C2_FILIAL = B1.B1_FILIAL "
		_cQry	+=" AND "
		_cQry	+=" C2.C2_PRODUTO = B1.B1_COD "
		_cQry	+=" AND "
		_cQry	+=" B1.B1_GRUPO NOT LIKE '%BL' "
		_cQry	+=" AND "
		_cQry	+=" B1_TIPO IN ('PI','TI','PA','TA') "
		_cQry	+=" WHERE "
		_cQry	+=" C2.C2_FILIAL = '"+XFILIAL("SC2")+"' "
		_cQry	+=" AND "
		_cQry	+=" C2.C2_NUM = '"+cGet1+"'"
		_cQry	+=" AND "
		_cQry	+=" C2.D_E_L_E_T_ = '' "
		_cQry	+=" ORDER BY C2.C2_NUM, C2.C2_ITEM DESC, C2.C2_SEQUEN DESC "

		if Select("TMSC2")<>0
			dbselectarea("TMSC2")
			TMSC2->(dbclosearea())
		Endif

		TcQuery _cQry NEW ALIAS "TMSC2"

		DBSELECTAREA("TMSC2")
		TMSC2->(DBGOTOP())

		WHILE TMSC2->(!EOF())
			IF TMSC2->B1_TIPO $ 'PA-TA'
				cPrdPrincipal	:= TMSC2->C2_PRODUTO
			ENDIF
			TMSC2->(DBSKIP())
		ENDDO

		TMSC2->(DBGOTOP())

		WHILE TMSC2->(!EOF())
			IF LEN(dDataIni) <> 0
				dDataIni 	:= {}
				nQtdHoras	:= 0
			ENDIF
			IF !(cPrdPrincipal == TMSC2->C2_PRODUTO)
				nQtdMult 	:= Posicione("SG1",1,XFILIAL("SG1")+cPrdPrincipal+TMSC2->C2_PRODUTO,"G1_QUANT")
				nQtdHoras	:= (Val(cGet2) * (Posicione("SB1",1,XFILIAL("SB1")+TMSC2->C2_PRODUTO,"B1_XTMPPRO")) * nQtdMult)
				IF nQtdHoras <= 0.0199
					dDataIni	:= retdtini(0.02,SUBSTR(TIME(),1,5),dDataBase)	//1Minuto
				ELSEIF nQtdHoras > 0.0199
					dDataIni	:= retdtini(nQtdHoras,SUBSTR(TIME(),1,5),dDataBase)
				ENDIF
			ELSEIF cPrdPrincipal == TMSC2->C2_PRODUTO
				nQtdHoras	:= (Val(cGet2) * (Posicione("SB1",1,XFILIAL("SB1")+TMSC2->C2_PRODUTO,"B1_XTMPPRO")))
				IF nQtdHoras <= 0.0199
					dDataIni	:= retdtini(0.02,SUBSTR(TIME(),1,5),dDataBase)	//1Minuto
				ELSEIF nQtdHoras > 0.0199
					dDataIni	:= retdtini(nQtdHoras,SUBSTR(TIME(),1,5),dDataBase)
				ENDIF
			ENDIF
			AADD(aVetor, {"H6_FILIAL"	,	xFilial("SH6")																			,Nil})
			AADD(aVetor, {"H6_OP"	   	,	TMSC2->C2_NUM + TMSC2->C2_ITEM + TMSC2->C2_SEQUEN  										,NIL})
			AADD(aVetor, {"H6_PRODUTO" 	,	TMSC2->C2_PRODUTO																		,NIL})
			AADD(aVetor, {"H6_OPERAC"  	,	"01"      																				,NIL})
			AADD(aVetor, {"H6_RECURSO" 	,	"000001"  																				,NIL})
			AADD(aVetor, {"H6_DATAINI" 	,	IIF(Empty(dDataIni[1]),dDataBase,dDataIni[1])											,NIL})
			AADD(aVetor, {"H6_HORAINI" 	,	IIF(Empty(dDataIni[2]),SubStr(Time(),1,5),SUBSTR(dDataIni[2],1,5))						,NIL})
			AADD(aVetor, {"H6_DATAFIN" 	,	dDataBase 																				,NIL})
			AADD(aVetor, {"H6_HORAFIN" 	, 	SubStr(Time(),1,5)					 													,NIL})
			IF !(cPrdPrincipal == TMSC2->C2_PRODUTO)
				AADD(aVetor, {"H6_QTDPROD" 	, 	(Val(cGet2)*nQtdMult)				       											,NIL})
			ELSEIF cPrdPrincipal == TMSC2->C2_PRODUTO
				AADD(aVetor, {"H6_QTDPROD" 	, 	Val(cGet2)							       											,NIL})
			ENDIF
			AADD(aVetor, {"H6_DTAPONT" 	, 	dDataBase																				,NIL})
			AADD(aVetor, {"H6_LOTECTL" 	, 	cGet1																					,NIL})
			AADD(aVetor, {"H6_DTVALID" 	, 	DaySum(dDataBase, Posicione("SB1",1,XFILIAL("SB1")+TMSC2->C2_PRODUTO,"B1_PRVALID"))		,NIL})
			//Inclusão
			MSExecAuto({|x| mata681(x)},aVetor)

			//Se não tiver dado erro, salvo o H6_IDENT porque será necessário gravar ele junto com o log das etiquetas...
			//... para o caso de haver estorno. Cada identidade gravada corresponderá à uma linha que foi gravada na SH6 pelo ExecAuto()
			IF !lMsErroAuto
				AADD(aIdent,SH6->H6_IDENT)
			ENDIF

			//Limpar o Vetor porque ele vai ser usado novamente.
			aVetor	:= {}

			lMsErr := lMsErroAuto

			//Gravar o erro na tabela ZZE para o usuário corrigir posteriormente.
			If lMsErroAuto
				aLogErro := GetAutoGRLog()
				For nX := 1 To Len(aLogErro)
					cErro += aLogErro[nX] + Chr(13)+Chr(10)
				Next nX

				DBSELECTAREA("ZZE")
				ZZE->(DBSETORDER(1))
				RECLOCK("ZZE",.T.)
				ZZE->ZZE_FILIAL 	:= XFILIAL("ZZE")
				ZZE->ZZE_OP			:= TMSC2->C2_NUM + TMSC2->C2_ITEM + TMSC2->C2_SEQUEN
				ZZE->ZZE_PRODUT		:= TMSC2->C2_PRODUTO
				ZZE->ZZE_DTINI		:= IIF(Empty(dDataIni[1]),dDataBase,dDataIni[1])
				ZZE->ZZE_HRINI		:= IIF(Empty(dDataIni[2]),SubStr(Time(),1,5),SUBSTR(dDataIni[2],1,5))
				ZZE->ZZE_DTFIN		:= dDataBase
				ZZE->ZZE_HRFIN		:= SubStr(Time(),1,5)
				ZZE->ZZE_QTDE		:= Val(cGet2)
				ZZE->ZZE_ERRO		:= cErro //CAMPO DO TIPO MEMO
				ZZE->ZZE_RESOLV		:= "2"
				ZZE->(MSUNLOCK())
				ZZE->(DBCLOSEAREA())
				cErro := ""
			Endif

			//Se não tiver dado erro e, se o produto for o principal (PA) ou (TA), transfere para o armazem do faturamento.
			IF !lMsErroAuto
				IF (cPrdPrincipal == TMSC2->C2_PRODUTO) .and. (TMSC2->B1_TIPO $ "PA-TA" )
					//Dados para transferir o produto principal
					// Pega a variavel que identifica se o calculo do custo é: O = Online / M = Mensal
					//LGS#20200207 - Adequação de release 12.1.25 e posteriores - passei a declaração de variáveis para ao inicio da função 
					//PRIVATE cCusMed := GetMv("MV_CUSMED")
					//PRIVATE cCadastro:= "Transferencias"
					//PRIVATE aRegSD3 := {}
					// Verifica se o custo medio é calculado On-Line
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
					EndIf

					//Dados do produto principal
					cCodOrig   	:= cPrdPrincipal   					//Codigo do Produto Origem - Obrigatorio
					cLocOrig   	:= "EPCP"                    		//Almox Origem             - Obrigatorio
					nQuant260 	:= Val(cGet2)     					//Quantidade 1a UM        - Obrigatorio
					cDocto     	:= NextNumero("SD3",8,"D3_DOC",.T.) //Documento               - Obrigatorio
					dEmis260   	:= dDataBase            			//Data                     - Obrigatorio
					nQuant260D 	:= Nil     							//Quantidade 2a UM
					cNumLote   	:= Nil                    			//Sub-Lote - obrigatório apenas qdo MV_RASTRO ==‘S‘
					cLoteDigi 	:= cGet1     						//Lote - obrigatório apenas qdo MV_RASTRO ==‘L‘
					dDtValid   	:= dDataBase     					//Validade - Obrigatorio se usa Rastro
					cNumSerie 	:= Nil                   			//Numero de Serie
					cLoclzOrig 	:= Nil                   			//Localizacao Origem
					cCodDest   	:= cPrdPrincipal      				//Codigo do Produto Destino     - Obrigatorio
					cLocDest   	:= "E1PA"                           //Almox Destino            - Obrigatorio
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
					cLoteDest 	:= cGet1   							//cLoteDest - Lote Destino da Transferencia
					cIdDcf		:= Nil								// ID DCF
					cObserva	:= Nil								// Observação

               		//Gravando a transferencia do produto principal
					If !a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,lEstorno,nRecOrig,nRecDest,cPrograma,cEstFis,cServico,cTarefa,cAtividade,cAnomalia,cEstDest,cEndDest,cHrInicio,cAtuEst,cCarga,cUnitiza,cOrdTar,cOrdAti,cRHumano,cRFisico,nPotencia,cLoteDest,cIdDcf,cObserva)
						MsgBox( "Erro de processamento na Transferência. Lote Destino: "+cLoteDest+"."+CHR(13) +;
							"Favor entrar em contato com o administrador do sistema.")
					Endif
				ENDIF
			ENDIF
			TMSC2->(DBSKIP())
		ENDDO
		TMSC2->(DBCLOSEAREA())

		//Enviando e-mail caso tenha dado errado
		IF lMsErroAuto
			U_SCHZZE()
		ENDIF

		//Se o usuario fez a opção por corrigir os dados e deu tudo certo até chegar aqui...
		//... então é necessário fechar o oDlg quando terminar para o MBrowse atualizar...
		//... lembrar que o MBrowse da rotina da correção tem refresh automatico a cada 60s.
		IF !EMPTY(cAlias) .and. !EMPTY(nRecno) .and. !EMPTY(nOpc)
			oDlg:End()
		ENDIF
	ENDIF
Return

Static Function imprimeeti(cGet1,cGet2,cAlias,nRecno,nOpc,lMsErr,aIdent)
	Local nZ			:= 0
	Private cPorta	 	:= "LPT1"
	Private cModelo  	:= "ZT230"
	Private lStatus		:= .F.
	Private cCodProd	:= ""
	Private cB1XCod		:= ""
	Private cCodBar		:= ""
	Private dDtValid	:= dDataBase
	Private cNomeCli	:= ""
	Private cQryZZG		:= ""
	Private ZZGSEQUEN	:= 1
	Private cIdent		:= ""

	//Só imprime a etiqueta se ela realmente tiver sido chamada de dentro da funcao mãe (apontaop.prw)...
	//... fora disso ele está fazendo correção de OP e aí não precisa imprimir porque ele pode ter...
	//... usado qualquer computador da rede.
	IF Empty(cAlias) .and. Empty(nRecno) .and. Empty(nOpc) .and. !Empty(cGet1) .and. Val(cGet2) <> 0
		IF (Len(Alltrim(cGet1))<(TamSX3("C2_NUM")[1]))
			cGet1 := PADL(AllTrim(cGet1),(TamSX3("C2_NUM")[1]),"0")
		ENDIF

		DBSELECTAREA("SC2")
		SC2->(DBSETORDER(1))
		SC2->(DBGOTOP())
		IF SC2->(DBSEEK(XFILIAL("SC2")+cGet1))
			WHILE SC2->(!EOF()) .AND. SC2->C2_FILIAL == XFILIAL("SC2") .AND. SC2->C2_NUM == cGet1
				IF	(POSICIONE("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_TIPO")) $ "PA-TA"
					cCodProd := SC2->C2_PRODUTO
					dDtValid := DaySum(dDataBase, SB1->B1_PRVALID)
					cB1XCod  := SB1->B1_XCOD
				ENDIF
				SC2->(DBSKIP())
			ENDDO
		ENDIF
		SC2->(DBCLOSEAREA())

		//PEGAR O MAIOR SEQUENCIAL DE ZZG_OP
		cQryZZG	:="	SELECT MAX(ZZG_SEQUEN) ZZG_SEQUEN FROM "+RETSQLNAME("ZZG")+" ZZG "
		cQryZZG	+="	WHERE "
		cQryZZG	+="	ZZG_FILIAL = '"+XFILIAL("ZZG")+"' "
		cQryZZG	+="	AND "
		cQryZZG	+="	ZZG_OP = '"+cGet1+"' "

		IF SELECT("TMZZG") <> 0
			DBSELECTAREA("TMZZG")
			TMZZG->(DBCLOSEAREA())
		Endif

		TcQuery cQryZZG NEW ALIAS "TMZZG"

		DBSELECTAREA("TMZZG")
		TMZZG->(DBGOTOP())

		IF TMZZG->(EOF())
			ZZGSEQUEN	:= 1
		ELSEIF TMZZG->(!EOF())
			WHILE TMZZG->(!EOF())
				ZZGSEQUEN := TMZZG->ZZG_SEQUEN + 1
				TMZZG->(DBSKIP())
			ENDDO
		ENDIF
		TMZZG->(DBCLOSEAREA())

		//GRAVAR OS DADOS PARA REIMPRESSAO DA ETIQUETA CASO SEJA NECESSARIO.
		//GRAVAR ANTES PORQUE PODE OCORRER ALGUM PROBLEMA COM A IMPRESSORA DURANTE A IMPRESSAO
		For nZ := 1 to len(aIdent)
			cIdent += "'"+aIdent[nZ]+"'"
			if nZ <> len(aIdent)
				cIdent += +","
			endif
		Next nZ
		DBSELECTAREA("ZZG")
		ZZG->(DBSETORDER(1))
		RECLOCK("ZZG",.T.)
		ZZG->ZZG_FILIAL 	:= XFILIAL("ZZG")
		ZZG->ZZG_OP			:= cGet1
		ZZG->ZZG_QTD		:= Val(cGet2)
		ZZG->ZZG_PRODUT		:= cCodProd
		ZZG->ZZG_DTVALI		:= dDtValid
		ZZG->ZZG_DTEMIS		:= dDataBase
		ZZG->ZZG_HREMIS		:= SUBSTR(TIME(),1,5)
		ZZG->ZZG_SEQUEN		:= ZZGSEQUEN
		//Validação para poder dizer se a produção referente a essa etiqueta deu certo ou não.
		//1 - Algum erro foi detectado na produção (SH6) dessa etiqueta
		//2 - Nenhum erro foi detectado na produção (SH6) dessa etiqueta
		//Motivo: Na hora de estornar a etiqueta será necessário verificar se para ela houve realmente uma produção ou não.
		IIF(lMsErr,ZZG->ZZG_ERRO := "1",ZZG->ZZG_ERRO := "2")
		//Gravar os H6_IDENT referentes a essa etiqueta
		IIF(!Empty(cIdent),ZZG->ZZG_IDENTD := cIdent, ZZG->ZZG_IDENTD := "")
		//Gravar o codigo de barras dessa etiqueta
		ZZG->ZZG_CODBAR	:= Replicate(' ',6-Len(Alltrim(cB1XCod))) + Alltrim(cB1XCod) + Replicate('0',12-Len(Alltrim(cGet1))-Len(Alltrim(cValToChar(ZZGSEQUEN)))) + Alltrim(cValToChar(ZZGSEQUEN)) + Alltrim(cGet1) + Strzero(Val(cGet2)*100,9)
		ZZG->(MSUNLOCK())
		ZZG->(DBCLOSEAREA())

		//Limpar a variável e o vetor logo que tiver gravado a etiqueta...
		//...porque o usuario não vai sair da rotina e enquanto ele estiver na rotina os valores ficam gravados na memória da linguagem...
		//...pois isso aqui se trata de uma variável passada por parâmetro através da rotina principal que não foi fechada.
		cIdent := ""
		aIdent := {}

		//IMPRIMIR A ETIQUETA
		MSCBPRINTER(cModelo,cPorta,,,.f.,,,,)
		MSCBCHKStatus(lStatus)

		//INICIALIZA A PAGINA
		MSCBBEGIN(4/*copias*/,5/*velocidade*/,223/*tamanho*/)	//Não precisa dar loop para imprimir a quantidade de etiquetas, a impressora da loop sozinha!
		MSCBBOX(30,05,76,05)
		MSCBBOX(02,12.7,76,12.7)
		MSCBBOX(02,21,120,21)
		MSCBBOX(30,01,30,12.7,3)
		MSCBSAY(33,02,"F033: ID. DO PALLET / PRODUTO ","N","0","025,035")
		MSCBSAY(33,06,"CODIGO","N","B","012,008")
		MSCBSAY(33,08,cCodProd, "N", "0", "032,035")
		MSCBSAY(05,14,"DESCRICAO","N","B","012,008")
		MSCBSAY(05,16,POSICIONE("SB1",1,XFILIAL("SB1")+cCodProd,"B1_DESC"),"N", "0", "032,035")
		MSCBSAY(05,23,"LOTE/VALIDADE","N","B","012,008")
		MSCBSAY(05,25,cGet1 +"  /  "+ Transform(dDtValid,"@E") ,"N", "0", "020,030")
		MSCBSAY(75,23,"QUANTIDADE","N","B","012,008")
		MSCBSAY(75,25,cGet2,"N", "0", "020,030") //Quantidade de caixas no Pallet
		MSCBSAY(105,23,"VOLUME","N","B","012,008")
		MSCBSAY(105,25,"01/01","N", "0","020,030")
		MSCBBOX(02,30,150,30)

		//cCodBar := REPLICATE(' ',6-Len(Alltrim(cB1XCod))) + Alltrim(cB1XCod) + REPLICATE(' ',12-Len(Alltrim(cGet1)))+Alltrim(cGet1) + Strzero(Val(cGet2)*100,9)
		//Como é formado o código de barras?
		//Ele tem 27 caracteres que é o tamanho máximo que cabe na etiqueta 10cmx7cm
		//6 = B1XCOD
		//6 = SEQUENCIAL DA ETIQUETA
		//6 = NUMERO DA OP
		//9 = QUANTIDADE DE PA DAQUELA ETIQUETA * 100
		//EX.: 004012 000001 001327 000000100
		cCodBar	:= Replicate(' ',6-Len(Alltrim(cB1XCod))) + Alltrim(cB1XCod) + Replicate('0',12-Len(Alltrim(cGet1))-Len(Alltrim(cValToChar(ZZGSEQUEN)))) + Alltrim(cValToChar(ZZGSEQUEN)) + Alltrim(cGet1) + Strzero(Val(cGet2)*100,9)

		MSCBSAYBAR(05,34,cCodBar,"N","MB07",/*8.36*/ 18,.F.,.T.,.F.,,2.4 ,1,.F.,.F.,"1",.T.)

		IF SubStr(cCodProd,2,3) $ 'AAA'
			cNomeCli	:= "TECPOLPA"
		Else
			cNomeCli	:= Posicione("SA1",12,XFILIAL("SA1")+Substr(cCodProd,2,3),"A1_NOME")
		ENDIF
		MSCBSAY(05,67,cNomeCli,"N","0","032,035")

		//FECHA A PAGINA
		MSCBEND()

		//FECHA A COMUNICACAO COM A IMPRESSORA
		MSCBCLOSEPRINTER()

	ENDIF
Return

Static Function limpatela(cGet1)
	cGet1 := Space((TamSX3("C2_NUM")[1]))
	cGet2 := Space((TamSX3("C2_SEQUEN")[1]))
	cGet3 := Space((TamSX3("B1_DESC")[1]))
	oGet1:cText := cGet1
	oGet2:cText	:= cGet2
	oGet3:cText := cGet3
	oGet1:Refresh()
	oGet2:Refresh()
	oGet3:Refresh()
	oDlg:Refresh()
Return()

Static Function ValidcGet(cGet1,cGet2,cGet3)
	Local nY		:= 0
	Private nSugest	:= 0

	//Verifico se realmente trata-se de um lote válido.
	IF Empty(cGet3)
		Alert("Lote inexistente!")
		cGet1 := Space((TamSX3("C2_NUM")[1]))
		cGet3 := Space((TamSX3("B1_DESC")[1]))
		oGet1:cText := cGet1
		oGet3:cText := cGet3
		oGet1:Refresh()
		oGet3:Refresh()
		Return .T.
	ENDIF

	IF (Len(Alltrim(cGet1))<(TamSX3("C2_NUM")[1]))
		cGet1 := PADL(AllTrim(cGet1),(TamSX3("C2_NUM")[1]),"0")
	ENDIF

	FOR nY = 1 to Len(Alltrim(cGet2))
		IF !(SubStr(Alltrim(cGet2),nY,1) $ "0123456789")
			Alert("O campo da quantidade só deve conter números!")
			cGet2 := Space((TamSX3("C2_SEQUEN")[1]))
			oGet2:cText	:= cGet2
			oGet2:Refresh()
			Return .T.
		ENDIF
	NEXT nY

	//A QUANTIDADE DIGITADA NAO PODE SER MAIOR QUE O LASTRO
	DBSELECTAREA("SC2")
	SC2->(DBGOTOP())
	SC2->(DBSETORDER(1))
	IF SC2->(DBSEEK(XFILIAL("SC2")+cGet1))
		While SC2->(!EOF().AND. (SC2->(XFILIAL("SC2") == SC2->C2_FILIAL .AND. cGet1 == SC2->C2_NUM)))
			IF  (Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_TIPO")) $ "PA-TA"
				nSugest	:= ((Posicione("SB5",1,XFILIAL("SB5")+SC2->C2_PRODUTO,"B5_EMPMAX"))*(Posicione("SB5",1,XFILIAL("SB5")+SC2->C2_PRODUTO,"B5_ECPROFU")))
			ENDIF
			SC2->(DBSKIP())
		ENDDO
	ENDIF
	SC2->(DBCLOSEAREA())

	IF nSugest < Val(cGet2)
		Alert("A quantidade digitada não pode ser maior que o lastro permitido para esse produto!")
		cGet2 := Space((TamSX3("C2_SEQUEN")[1]))
		oGet2:cText	:= cGet2
		oGet2:Refresh()
		Return .T.
	ENDIF
Return

Static Function retdtini(_qtdhoras,_horafim,_datafim)
//_qtdhoras precisa estar em formato decimal ex.: 1,50 ou 1.50
//retorna datainicial,horainicial
	Private ndias
	Private nhoras
	Private _dataini
	Private _horaini
	Private _qtdemhoras
	Private _difhoras

	IF VALTYPE(_qtdhoras) <> "N"
		RETURN
	ENDIF

	_qtdemhoras := inttohora(_qtdhoras)
	nDias 		:= int(_qtdhoras/24)
	nhoras 		:= _qtdhoras%24
	_difhoras	:= inttohora(nhoras)

	if _difhoras > _horafim
		ndias+=1
		_horaini	:=	inttohora(horatoint("24:00")-(SubtHoras(DDATABASE,_horafim,DDATABASE,_difhoras)))
	Else
		_horaini	:=	inttohora(horatoint(_horafim)-horatoint(_difhoras))
	Endif
	_dataini	:=	ddatabase-ndias

Return {_dataini,_horaini}