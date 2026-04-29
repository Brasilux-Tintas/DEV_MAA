#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "QIEA231.CH"

/*/{Protheus.doc} QIEA231
Calculo do IQF Individual (para uma Filial)
@type function Processamento
@version  1.00
@author  Vera Lucia S. Simoes / Alterado por marioantonaccio
@since 14/05/98 / alterado em 06/01/2026
@return character, sem retrono
@see

Programador ¦ Data	 ¦ BOPS ¦ Motivo da Alteracao
------------+--------+------+--------------------------------
Vera        ¦17/03/99¦------¦ Usa Dias de Atraso em modulo
Vera        ¦15/04/99¦------¦ Inclusao da Loja do Fornecedor
Vera        ¦03/11/99¦------¦ Conceito de Liberacao Urgente
Vera        ¦14/01/00¦------¦ Inclusao do arquivo CH

+-------------------------------------------------------------------------+
¦ Formulas:                                                               ¦
¦ IQP por Tabela Completa:                                                ¦
¦   IA = ((Fator A*Qtd. A + Fator B*Qtd. B + ...)/(Qtd. A+Qtd. B)) * 100  ¦
¦   Se IQI por Tabela:                                                    ¦
¦     IQP = (100 - K) - Total Demerito   (K é obtido em funcao do IA)     ¦
¦   Se IQI por Soma:                                                      ¦
¦     IQP = IA                                                            ¦
¦ IQP por Tabela Simplificada:                                            ¦
¦   IQP = 101-((Qt.A+(Fat. B*100)*Qt.B+(Fat. C*100)*Qt.C)/(Qt.A+Qt.B+...))¦
¦                                                                         ¦
¦ IQI por Tabela:                                                         ¦
¦   IQI = IQP * FC   (FC é obtido em funcao do IQS)                       ¦
¦ IQI por Soma:                                                           ¦
¦   IQI = 0.80 * IQP + 0.20 * IQS                                         ¦
¦                                                                         ¦
¦ IES (IPO):                                                              ¦
¦  IPO = (1- (Somat.(Tam.Lote*Dias Atraso)/(MV_QDIAATR*Qtd.Total))) * 100 ¦
¦                                                                         ¦
¦ ICT = IPR = 0                                                           ¦
¦                                                                         ¦
¦ IQF:                                                                    ¦
¦   IQF = Fat.IQI * IQI + Fat.IPR * IPR + Fat.IES * IES + Fat.ICT * ICT   ¦
¦                                                                         ¦
¦ Calculo do Acumulado:                                                   ¦
¦ Flexivel:                                                               ¦
¦   Pelo menos 1 Entrada nos n meses                       -> Calcula     ¦
¦ Rigido:                                                                 ¦
¦   Menos de n/2 meses com Entradas                        -> Nao Calcula ¦
¦   De n/2 a n-1 meses c/ Entrada: menos de 6 Entradas     -> Nao Calcula ¦
¦                              6 ou mais Entradas          -> Calcula     ¦
¦   n meses com Entradas                                   -> Calcula     ¦
+-------------------------------------------------------------------------+
Obs.: Para as Entradas que tiverem laudo com categoria Liberado Urgente,
       o sistema assumira Laudo Aprovado. Se for dado um laudo diferente de
       Aprovado, no cadastro de Resultados, o sistema exibira mensagem para
       o usuario, orientando-o a gerar novamente o Indice de Qualidade.

O cálculo do IQF Mensal é realizado da seguinte forma:

IQF = (QF1_FATIOF * IQ1)+ (QF1._FATIOF * IPR)+ (QF1_FATIQF * IES)

sendo que:

IQF = Somatória dos índices informados no Cadastro de Índices Mensais (QE0)
QF1_FATIQF = campo "Fator IQF", do Cadastro dos Índices do IQF (QF1)
IQI = Índice de Qualidade do Item
	IQP =(100 - QEJ_FATOR) - QEU_DEMQI
	IQI = IQP * FC
IPR = Índice de Variação de Preços
IES ou IPO = Índice de Entrega e Serviços
/*/
User Function QIEA231()

	Local aSays        := {}
	Local aButtons     := {}
	Local lOk          := .F.
	//Local cPerg        := "X_SUA_PERG"

	Private AANOMES
	Private AFATACUM
	Private AFATINF
	Private AFATIQP
	Private AIPO
	Private AIQD
	Private ALAUAC
	Private ALOTDEM
	Private ALOTENT
	Private ATAMLAB
	Private CALIAS
	Private CANOFIM
	Private CANOINI
	Private CCHVMED
	Private CCOND
	Private CFATAPR
	Private CFATLU
	Private CFATREP
	Private CFOR
	Private CINDEX
	Private CINDINF
	Private CKEY
	Private CMESFIM
	Private CMESINI
	Private CMVQTREJ
	Private CPROD
	Private CSEEK
	Private DDTFIM
	Private DDTINI
	Private LACUMULA
	Private LCONSISTE
	Private LCONT
	Private LFLGACU
	Private LFLGMEN
	Private NAUX
	Private NCTDEM
	Private NCTENT
	Private NCTMES
	Private NDIV
	Private NFATIES
	Private NFATIPR
	Private NFATIQI
	Private NFC
	Private NIA
	Private NIES
	Private NIESA
	Private NINDEX
	Private NIPO
	Private NIPOA
	Private NIPR
	Private NIPRA
	Private NIQF
	Private NIQFA
	Private NIQI
	Private NIQIA
	Private NIQP
	Private NIQPA
	Private NIQS
	Private NITR
	Private NK
	Private NLTINSP
	Private NLTSKIP
	Private NMVDIATR
	Private NMVMESACU
	Private NNIDI
	Private NORDQE0
	Private NORDQEK
	Private NORDQEV
	Private NORDSA5
	Private NPOS
	Private NQTDENT
	Private NQTINSP
	Private NQTREJ
	Private NQTSKIP
	Private NRECQEV
	Private NRETFAT
	Private NSOMA
	Private NTOTDEM
	Private NY
	Private cLABOR:=CriaVar("QEL_LABOR")
	Private aFornece:={}
	Private aIndice:={}
	If 1==1
		Private cIE230Dia
		Private cIE230Mes
		Private cIE230Ano
		Private cIE230For
		Private cFornece:=""

		Private cFornIni:="00001"
		Private cFornFin:="00001"
		Private cProdIni:="ZZZCLFOR      "
		Private cProdfIN:="ZZZCLFOR      "
		Private dDataFin:=dDataBase
	End

	//Popula as linhas que serão mostradas na tela
	aAdd(aSays, "Esse programa tem como objetivo ")
	aAdd(aSays, "calcular o Indice de Qualificação de Fornecedor (IQF),")
	aAdd(aSays, "conforme parametros.")

	//Botões da tela, cada botão tem um Bloco de Código
	//aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
	aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
	aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

	//Chama a tela principal
	FormBatch("Calculo Indice Fornecedores (IQF)", aSays, aButtons)

	//Se foi confirmado a tela
	If lOk
		Processa({|| QIEA23A()}, "Gerando Indices...", , , , )
	EndIf

Return


Static Function QIEA23A()

	Local nI := 0
	Local nX := 0
	Local bError
	Local bErrorBlock
	Local oError
	Local nFornece:=0
	Local nIndice:=1

	// Indica se prossegue o programa
	lCont := .T.

	// Verifica se as Tabelas do IA e do IQS estao cadastradas
	//Passo 01
	//Tabela IA - Indice de Aprovação
	QEJ->(dbSetOrder(1))
	If .NOT. QEJ->(dbSeek(xFilial("QEJ")+"1"))
		FWMsgAlert("Favor cadastrar a Tabela do Indice Aceitacao (IA)","Atencao")
		Return (.F.)
	EndIf

	//Tabela de Indice de Aceitação Sisterma (IQS)
	If .NOT. QEJ->(dbSeek(xFilial("QEJ")+"2"))
		FWMsgAlert("Favor cadastrar a Tabela do Indice Qualidade Sistema (IQS)","Atencao")
		Return (.F.)
	EndIf

	//PAsso 02: Tabela IQF
	// Verifica se cadastrou os Indices do IQF
	QF1->(dbSetOrder(1))
	If .NOT. QF1->(dbSeek(xFilial("QF1")))
		FWMsgAlert("Favor cadastrar os Indices do IQF","Atencao")
		Return (.F.)
	EndIf

	// IQI
	aIndice:={"IQI","IPR","IES"}
	For nIndice:=1 To Len(aIndice)
		QF1->(dbSetOrder(1))
		If QF1->(dbSeek(xFIlial("QF1")+aIndice[nIndice]))
			If nIndice == 1
				nFatIQI:=   QF1->QF1_FATIQF
			ElseIf nIndice == 2
				nFatIPR	:=	QF1->QF1_FATIQF
			ElseIf nIndice == 3
				nFatIES:=	QF1->QF1_FATIQF
			End
		Else
			FWMsgAlert( "Indice nao cadastrado: "+ aIndice[nIndice],"Atencao")
			Return (.F.)
		End
	Next

	//Estando OK    passo 03  e 04 completos
	//Passo 05
	// Define os Fatores do IQP
	aFatIQP := {}
	cFatApr := " "
	cFatRep := " "
	cFatLU  := " "

	QED->(dbSetOrder(1))
	QED->(dbSeek(xFilial("QED")))
	While .NOT. QED->(EOF() ).And. QED->QED_FILIAL == xFilial("QED")
		If QED->QED_CATEG == "4"	// Fator com categoria Liberado Urgente
			cFatLU := QED->QED_CODFAT
		Else
			Aadd(aFatIQP,{ QED->QED_CODFAT, SuperVal(QED->QED_FATOR), QED->QED_CATEG, 0})

			If QED->QED_CATEG == "1"	// Fator Aprovado
				cFatApr := QED->QED_CODFAT
			ElseIf QED->QED_CATEG == "3"	// Fator Reprovado
				cFatRep := QED->QED_CODFAT
			EndIf
		EndIf
		QED->(dbSkip())
	End

	//Passo 06
	//Calcula data inicial confomre parametro
	dDataIni:=MonthSub(dDataFin,GetMv("MV_QMESACU"))

	// Obtem os fatores de todos os indices do IQF calculados neste RDMAKE.
	// Obs.: Se incluir algum indice (do usuario) deve checar aqui se existe
	//       seu respectivo fator.

	// Ordena vetor pela Categoria+Cod. Laudo
	aFatIQP := aSort(aFatIQP,,, {| x, y | x[3]+x[1] < y[3]+y[1]} )
	dInicio := dDataIni
	dFinal  := dDataFin

	// Define o periodo a ser considerado para a geracao IQF acumulado
	// Volta n meses a partir do mes/ano solicitado, de acordo com parametro.

	// Obtem o numero de meses para o calculo do acumulado
	aAnoMes   := {}
	dData1:=dDataFin
	For nI:=1 to GetMv("MV_QMESACU")
		Aadd(aAnoMes, { StrZero(Year(dData1),4,0), StrZero(Month(dData1),2,0) })
		dData1:=MonthSub(dData1,nI)
	Next

	// Ordena vetor por Ano+Mes
	aAnoMes := aSort(aAnoMes,,, { | x,y | x[1]+x[2] < y[1]+y[2] } )
	cMesIni := aAnoMes[1][2]
	cAnoIni := aAnoMes[1][1]
	cMesFim := aAnoMes[Len(aAnoMes)][2]
	cAnoFim := aAnoMes[Len(aAnoMes)][1]

	// Guarda os indices ativos
	nOrdSA5 := SA5->(IndexOrd())
	nOrdQEV := QEV->(IndexOrd())
	nOrdQE0 := QE0->(IndexOrd())
	nOrdQEK := QEK->(IndexOrd())

	// Abre indice com as ultimas Entradas por Fornec./Produto (independente da Loja)
	// Quando gerar Indice por Fornecedor/Loja, pode usar o order 1, e excluir o 9,
	// se nao utilizar em mais nenhum lugar.

	// Parametro que indica se acumula a qtde. rejeitada no laudo reprovado
	cMvQtRej := GetMv("MV_QQTDREJ")

	// Parametro que indica o numero maximo de dias em atraso
	nMvDiAtr := GetMv("MV_QDIAIPO")

	// Flag que indica se há dados para a geracao dos Indices Mensais
	lFlgMen := .F.

	// Flag que indica se somente há dados para a geracao dos Indices Acumulados
	lFlgAcu := .F.

	// Define Tamanho do campo Laboratorio
	aTamLab     := Array(2)
	aTamLab     := TamSX3("QEL_LABOR")
	lNaoCer     := GetMV("MV_QNAOCER",.T.,.F.)
	lQReinsp    := GetNewPar("MV_QREINSP",.F.)
	lPrForFab   := GETNEWPAR( 'MV_PRFOFAB' ,.F.)

	cAnd        := "%"
	cAnd        := IF(LNAOCER ," AND QEK.QEK_VERIFI <> 2 ","")
	cAnd        := If(LQREINSP," AND QEL.QEL_NUMSEQ = QEK.QEK_NUMSEQ","")
	cAnd        := "%"
	cOrder      := "%"+SqlOrder(QEK->(IndexKey()))+"%"

	bError      :={|e| oError := e, BREAK(e)}
	bErrorBlock := ErrorBlock( bError )
	cError      := ""

	BEGIN SEQUENCE
		BeginSql ALIAS "XQEK"
			SELECT
				QEK.QEK_FILIAL QEK_FILIAL,
				QEK.QEK_FORNEC QEK_FORNEC,
				QEK.QEK_LOJFOR QEK_LOJFOR,
				QEK.QEK_PRODUT QEK_PRODUT,
				QEK.QEK_REVI QEK_REVI,
				QEK.QEK_LOTE QEK_LOTE,
				QEK.QEK_TAMLOT QEK_TAMLOT,
				QEK.QEK_TIPONF QEK_TIPONF,
				QEK.QEK_TIPDOC QEK_TIPDOC,
				QEK.QEK_DTENTR QEK_DTENTR,
				QEK.QEK_VERIFI QEK_VERIFI,
				QEK.QEK_DIASAT QEK_DIASAT,
				QEK.QEK_SITENT QEK_SITENT,
				QEK.QEK_NTFISC QEK_NTFISC,
				QEK.QEK_SERINF QEK_SERINF,
				QEK.QEK_ITEMNF QEK_ITEMNF,
				QEK.QEK_TIPONF QEK_TIPONF,
				QEK.QEK_ENTINV QEK_ENTINV,
				QEK.QEK_LOTINV QEK_LOTINV,
				QEL.QEL_FILIAL QEL_FILIAL,
				QEL.QEL_FORNEC QEL_FORNEC,
				QEL.QEL_LOJFOR QEL_LOJFOR,
				QEL.QEL_PRODUT QEL_PRODUT,
				QEL.QEL_LOTE QEL_LOTE,
				QEL.QEL_DTENTR QEL_DTENTR,
				QEL.QEL_LABOR QEL_LABOR,
				QEL.QEL_LAUDO QEL_LAUDO,
				QEL.QEL_DTLAUD QEL_DTLAUD,
				QEL.QEL_QTREJ QEL_QTREJ,
				QEL.QEL_NTFISC QEL_NTFISC,
				QEL.QEL_SERINF QEL_SERINF,
				QEL.QEL_ITEMNF QEL_ITEMNFJ,
				QEL.QEL_TIPONF QEL_TIPONF,
				SA5.A5_FILIAL A5_FILIAL,
				SA5.A5_FORNECE A5_FORNECE,
				SA5.A5_LOJA A5_LOJA,
				SA5.A5_PRODUTO A5_PRODUTO,
				SA5.A5_FABREV A5_FABREV
			FROM
				%Table:QEK% QEK,%Table:QEL% QEL,%Table:SA5% SA5
			WHERE
				QEK.QEK_FILIAL = %XFILIAL:QEK%
				AND QEK.QEK_TIPONF <> 'B'
				AND QEK.QEK_TIPONF <> 'D'
				AND QEK.QEK_SITENT <> '1'
				AND QEK.QEK_SITENT <> '7'
				AND QEK.%notdel%
				AND QEK.QEK_FORNEC >= %Exp:cFornIni%
				AND QEK.QEK_FORNEC <= %Exp:cFornFin%
				AND QEK.QEK_PRODUT >= %Exp:cProdIni%
				AND QEK.QEK_PRODUT <= %Exp:cProdFin%
				AND QEK.QEK_DTENTR >= %Exp:DTOS(dDataIni)%
				AND QEK.QEK_DTENTR <= %Exp:DTOS(dDataFin)%
				AND QEL.QEL_FILIAL = %XFILIAL:QEL%
				AND QEL.QEL_FORNEC = QEK.QEK_FORNEC
				AND QEL.QEL_LOJFOR = QEK.QEK_LOJFOR
				AND QEL.QEL_PRODUT = QEK.QEK_PRODUT
				AND QEL.QEL_DTENTR = QEK.QEK_DTENTR
				AND QEL.QEL_LOTE = QEK.QEK_LOTE
				AND QEL.QEL_LABOR = %Exp:CLABOR%
				AND QEL.QEL_DTLAUD >= %Exp:DTOS(dDataIni)%
				AND QEL.QEL_DTLAUD <= %Exp:DTOS(dDataFin)%
				AND QEL.QEL_LAUDO <> ' '
				AND QEL.QEL_NISERI = (
					QEK.QEK_NTFISC || QEK.QEK_SERINF || QEK.QEK_ITEMNF
				)
				AND QEL.%NOTDEL%
				AND SA5.A5_FILIAL = %XFILIAL:SA5%
				AND SA5.A5_FORNECE = QEK.QEK_FORNEC
				AND SA5.A5_LOJA = QEK.QEK_LOJFOR
				AND SA5.A5_PRODUTO = QEK.QEK_PRODUT
				AND SA5.A5_FABREV <> 'P'
				AND SA5.%NOTDEL% %Exp:cAnd%
			ORDER BY
				%Exp:cOrder%,
				SA5.A5_FABR,
				SA5.A5_FALOJA
		EndSql

		RECOVER

		cLastQuery    := GetLastQuery()[2]

		cError          := oError:Description
		cTCSqlError      := TCSqlError()

	END SEQUENCE

	If .NOT. Empty(cError)
		cMensagem:=""
		nPos:=RAT("]",cTCSQLError)+2
		cMensagem += "Erro na execução da query: " +CRLF+CRLF
		cMensagem += Substr(cError,1,nPos) + CRLF + CRLF + AllTrim(cLastquery)
		ShowLog(cMensagem)
		//ErrorBlock( bErrorBlock )
		Return
	End
	nNumReg:=CONTAR("XQEK",".NOT. EOF()")
	XQEK->(dbGoTop())
	ProcRegua(nNumReg)

	While XQEK->QEK_FILIAL == xFilial("QEK") .And. .NOT. XQEK->(EOF())
		// Deixa os Ifs por data pq. se for Top Connect ou Geracao p/ Data Laudo, nao cria IndRegua

		IncProc("Fornecedor : "+XQEK->QEK_FORNEC+"   "+"Produto : "+XQEK->QEK_PRODUT )
		ProcessMessage()

		If ASCAN(aFornece,XQEK->QEK_FORNEC+XQEK->QEK_LOJFOR) == 0
			AADD(aFornece,XQEK->QEK_FORNEC+XQEK->QEK_LOJFOR)
		End

		// Calculos dos Indices Mensais Informados
		QF1->(dbSetOrder(1))
		QF1->(dbSeek(xFilial("QF1")))

		aFatInf := {}
		While QF1->(.NOT. EOF()) .And. QF1->QF1_FILIAL == xFilial("QF1")

			If QF1->QF1_CALC == "I" .And. QF1->QF1_FATIQF <> 0	// Indice informado mensalmente
				QE0->(dbSetOrder(1))
				If	QE0->(.NOT. dbSeek(xFilial("QE0")+cAnoFim+cMesFim+XQEK->QEK_FORNEC+XQEK->QEK_PRODUT+QF1->QF1_INDICE))
					FWMsgAlert("Indice Mensal nao informado para o Produto/Fornecedor: "+CRLF+;
						Alltrim(cProd)+" / "+Alltrim(XQEK->QEK_FORNEC)+" ("+QF1->QF1_INDICE +")","Atencao")
					lCont := .F.
					Exit
				Else
					// Guarda num array o valor mensal multiplicado pelo seu fator IQF
					Aadd(aFatInf, QF1->QF1_FATIQF * QE0->QE0_VALOR)
				EndIf
			EndIf

			dbSelectArea("QF1")
			QF1->(dbSkip())

		EndDo

		// Se nao houver indice mensal informado, retorna sem calcular nada
		If .NOT. lCont
			Exit
		EndIf

		// Indices Mensais Calculados
		// Define as variaveis a serem zeradas p/ cada Fornecedor/Produto
		nCtEnt	:= 0		// Numero total de Entradas
		nCtDem	:= 0		// Qtde de Entradas demeritadas
		nQtdEnt	:= 0		// Qtde total entregue (Tam. Lote)
		nNidi	:= 0		// Qtde entregue * N. dias de atraso
		nTotDem	:= 0		// Total de demeritos das Entradas
		nQtRej	:= 0		// Total de qtde. rejeitada do forn./item
		nLtInsp	:= 0		// Total de lotes inspecionados
		nLtSkip	:= 0		// Total de lotes em skip-lote
		nQtInsp	:= 0		// Qtde. total (tam. lote) inspecionada
		nQtSkip	:= 0		// Qtde. total (tam. lote) em skip-lote

		// Zera a ocorrencia de cada Fator
		For nI := 1 to Len(aFatIQP)
			aFatIQP[nI][4] := 0
		Next nI

		// Seleciona as Entradas do Fornecedor/Produto
		cFor  := XQEK->QEK_FORNEC
		cProd := XQEK->QEK_PRODUT
		dbSelectArea("XQEK")
		While XQEK->QEK_FILIAL+XQEK->QEK_FORNEC+XQEK->QEK_PRODUT == xFilial("QEK")+cFor+cProd .And. XQEK->(.NOT. EOF())

			// Seta flag que indica que tem dados para geracao dos indices mensais
			lFlgMen := .t.

			// Contabiliza no. de Entradas
			nCtEnt++

			// Identifica o Laudo da Entrada
			// Se o Laudo da Entrada tiver categoria Liberado Urgente, considera como Aprovado
			nI := Ascan(aFatIQP, {|x| x[1] == Iif(XQEK->QEL_LAUDO == cFatLU,cFatApr,XQEK->QEL_LAUDO) })

			// Identifica o Laudo Reprovado
			nY := Ascan(aFatIQP, {|x| x[1] == cFatRep })

			// IQP por Tabela Completa
			If cMvQtRej == "S"	// Cons. qtde. rejeitada
				// Acumula a Qtde. Rejeitada no laudo reprovado
				// Acumula a diferenca do tam. lote e a qtde. rej. no laudo Entrada
				If .NOT. Empty(XQEK->QEL_QTREJ)
					If nI > 0
						aFatIQP[nI][4] +=(SuperVal(XQEK->QEK_TAMLOT)-SuperVal(XQEK->QEL_QTREJ))
					EndIf
					If nY > 0
						aFatIQP[nY][4] +=SuperVal(XQEK->QEL_QTREJ)
					EndIf
				Else
					If nI > 0
						aFatIQP[nI][4] +=SuperVal(XQEK->QEK_TAMLOT)
					EndIf
				EndIf
			Else
				If nI > 0
					aFatIQP[nI][4] += SuperVal(XQEK->QEK_TAMLOT)
				EndIf
			EndIf

			// Acumula a Qtde. Rejeitada
			nQtRej +=SuperVal(XQEK->QEL_QTREJ)

			// Acumula Ocorrencias e Qtde. Lote - Inspec. e em Skip-Lote
			If XQEK->QEK_VERIFI == 2	// Certificada
				nLtSkip++
				nQtSkip+=SuperVal(XQEK->QEK_TAMLOT)
			Else
				nLtInsp++
				nQtInsp+=SuperVal(XQEK->QEK_TAMLOT)
			EndIf

			// Verifica se a Entrada é demeritada
			If nI > 0
				If aFatIQP[nI][3] <> "1"
					nCtDem++
				EndIf
			EndIf
			// Acumula valores para o calculo do IPO
			// Utiliza Dias em Atraso em modulo porque pode ser negativo
			nQtdEnt+=SuperVal(XQEK->QEK_TAMLOT)
			If XQEK->QEK_DIASAT <> 0
				nNiDi += (SuperVal(XQEK->QEK_TAMLOT)*If(Abs(XQEK->QEK_DIASAT)>nMvDiAtr,nMvDiAtr,Abs(XQEK->QEK_DIASAT)))
			EndIf

			// Acumula pontos de demeritos oriundos das NCs
			cSeek := XQEK->QEK_PRODUT+XQEK->QEK_REVI+XQEK->QEK_FORNEC+XQEK->QEK_LOJFOR+XQEK->QEK_DTENTR+XQEK->QEK_LOTE

			QER->(dbSetOrder(1))
			QER->(dbSeek(xFilial("QER")+cSeek))

			ProcRegua(QER->(RecCount()))

			While QER->QER_FILIAL+QER->QER_PRODUT+QER->QER_REVI+QER->QER_FORNEC+QER->QER_LOJFOR+;
					Dtos(QER->QER_DTENTR)+QER->QER_LOTE==xFilial("QER")+cSeek .And. QER->(.NOT. EOF())

				IncProc("Produto : "+QER->QER_PRODUT)
				// Obtem chave de ligacao da medicao com os outros arquivos
				cChvMed := QER->QER_CHAVE

				// Verifica se a medicao tem NC
				QEU->(dbSetOrder(1))
				QEU->(dbSeek(xFilial("QEU")+QER->QER_CHAVE))
				While QEU->(.NOT. EOF()) .And. QEU->QEU_FILIAL == xFilial("QEU") .And. QEU->QEU_CODMED == cChvMed
					If QEU->QEU_DEMIQI == "S"
						QEE->(dbSetOrder(1))
						QEE->(dbSeek(xFilial("QEE")+QEU->QEU_CLASSE))
						// Acumula os pontos relativos às classes das NCs
						nTotDem  += QEE->QEE_PONTOS
					EndIf
					QEU->(dbSkip())
				EndDo

				QER->(dbSkip())

			EndDo

			XQEK->(dbSkip())

		EndDo

		If nCtEnt == 0
			Loop
		EndIf

		// Calculo do IQI Mensal
		// Calculo do IQP por Tabela Completa
		nSoma := 0
		nAux := 0
		For nX := 1 to Len(aFatIQP)
			nAux +=(aFatIQP[nX][2] * aFatIQP[nX][4])	// Fator * Ocorr. Laudo
			nSoma+=aFatIQP[nX][4]
		Next nX

		nIA := If(nSoma <> 0, (nAux/nSoma)*100, 0)

		// Calculo do IQI por Tabela
		// Obtem o Fator K, de acordo com o IA
		QEJ->(dbSetOrder(1))
		QEJ->(dbSeek(xFilial("QEJ")+"1"+Str(nIA,6,2),.T.))
		nK := SuperVal(QEJ->QEJ_FATOR)
		nIQP := ( 100 - nK ) - nTotDem
		nIQP := Iif(nIQP < 0, 0, nIQP)

		// Calculo do IQS
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+cFor))
		nIQS:=If(SA2->A2_FATAVA == 0 .And. Empty(SA2->A2_DTAVA),999.99,SA2->A2_FATAVA)

		// Calculo do IQI por Tabela
		QEJ->(dbSetOrder(1))
		If nIQS <> 999.99
			// Obtem o Fator FC, de acordo com o IQS
			QEJ->(dbSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2),.T.))
			nFC := SuperVal(QEJ->QEJ_FATOR)
		Else
			// Obtem o Fator FC para quando nao tiver a nota do IQS (999.99)
			// IQP por Tabela Completa, assume 1
			nFC:=If(QEJ->(dbSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2),.T.)),SuperVal(QEJ->QEJ_FATOR),1)
		End

		nIQI := nIQP * nFC

		// Calculo do IPR Mensal
		nIPR := 0

		// Calculo do IES Mensal
		// Calcula o IPO
		nIPO := Iif(nQtdEnt<>0, (1 - (nNiDi / (nMvDiAtr * nQtdEnt))) * 100, 0)

		nITR := 0
		nIES := nIPO

		// Calculo do IQF Mensal
		// Indices calculados:
		nIQF := (nFatIQI*nIQI) + (nFatIPR*nIPR) + (nFatIES*nIES)

		// Indices informados:
		For nI := 1 to Len(aFatInf)
			nIQF := nIQF + aFatInf[nI]
		Next nI

		// Gravacao dos indices mensais calculados
		// Grava somente os laudos que tiveram ocorrencia no mes/ano
		QEW->(dbSetOrder(1))
		For nX := 1 to Len(aFatIQP)
			If aFatIQP[nX][4] <> 0
				If QEW->(.NOT. dbSeek(xFilial("QEW")+cFor+cProd+cAnoFIm+cMesFim+aFatIQP[nX][1]))
					RecLock("QEW",.T.)
					QEW->QEW_FILIAL	:= xFilial("QEW")
					QEW->QEW_ANO	:= cAnoFim
					QEW->QEW_MES	:= cMesFim
					QEW->QEW_FORNEC	:= cFor
					QEW->QEW_PRODUT	:= cProd
					QEW->QEW_LAUDO 	:= aFatIQP[nX][1]
				Else
					RecLock("QEW",.F.)
				EndIf
				QEW->QEW_QTDLAU	:= aFatIQP[nX][4]
				MsUnLock()
			EndIf
		Next nX

		// Grava os indices mensais
		QEV->(dbSetOrder(1))
		If QEV->(.NOT. dbSeek(xFilial("QEV")+cAnoFim+cMesFim+cFor+cProd))
			RecLock("QEV",.T.)
			QEV->QEV_FILIAL	:= xFilial("QEV")
			QEV->QEV_ANO		:= cAnoFim
			QEV->QEV_MES		:= cMesFim
			QEV->QEV_FORNEC	:= cFor
			QEV->QEV_PRODUT	:= cProd
		Else
			RecLock("QEV",.F.)
		EndIf
		QEV->QEV_LOTENT	:=	nCtEnt
		QEV->QEV_LOTDEM	:=	nCtDem
		QEV->QEV_LOTINS	:=	nLtInsp
		QEV->QEV_LOTSKP	:=	nLtSkip
		QEV->QEV_QTDINS	:=	nQtInsp
		QEV->QEV_QTDSKP	:=	nQtSkip
		QEV->QEV_QTDREJ	:=	nQtRej
		QEV->QEV_IQP	:=	nIQP
		QEV->QEV_IQD	:=	nTotDem
		QEV->QEV_IQS	:=	nIQS
		QEV->QEV_IQI	:=	nIQI
		QEV->QEV_IPO	:=	nIPO
		QEV->QEV_ITR	:=	nITR
		QEV->QEV_IES	:=	nIES
		QEV->QEV_IPR	:=	nIPR
		QEV->QEV_IQF	:=	nIQF
		QEV->QEV_DTGER	:=	dDataBase
		nRecQEV := QEV->(Recno())
		MsUnLock()

		// Calculo do IQF Acumulado
		// Vetor que guarda a qtde nos n meses de cada Fator Laudo
		aFatAcum := Array(Len(aFatIQP),nMvMesAcu+1)
		For nI := 1 to Len(aFatIQP)
			aFatAcum[nI][1] := aFatIQP[nI][1]
			For nX := 1 to nMvMesAcu
				aFatAcum[nI][nX+1] := 0
			Next nX
		Next nI

		// Vetores que terao as respect. somas nos n meses
		aLotEnt := Array(nMvMesAcu)	// Lotes entregues
		Afill(aLotEnt,0)

		aLotDem := Array(nMvMesAcu)	// Lotes demeritados
		Afill(aLotDem,0)

		aIQD := Array(nMvMesAcu)	// IQDs
		Afill(aIQD,0)

		aIPO := Array(nMvMesAcu)	// IPOs
		Afill(aIPO,0)

		// Seleciona os indices dos meses a serem cons. p/ o acumulado
		QEV->(dbSetOrder(2))
		QEV->(dbSeek(xFilial("QEV")+SA5->A5_FORNECE+SA5->A5_PRODUTO+cAnoIni+cMesIni,.T.))
		While QEV->QEV_FILIAL+QEV->QEV_FORNEC+QEV->QEV_PRODUT == xFilial("QEV")+SA5->A5_FORNECE+SA5->A5_PRODUTO .and. QEV->(.NOT. Eof())

			If QEV->QEV_ANO+QEV->QEV_MES < cAnoIni+cMesIni .Or. QEV->QEV_ANO+QEV->QEV_MES > cAnoFim+cMesFim
				Exit
			EndIf
			nI := Ascan(aAnoMes, {|x| x[1]+x[2] == QEV->QEV_ANO+QEV->QEV_MES })

			// Acumula as qtdes. de cada Laudo
			For nX := 1 to Len(aFatAcum)
				QEW->(dbSetOrder(1))
				If QEW->(dbSeek(xFilial("QEW")+QEV->QEV_FORNEC+QEV->QEV_PRODUT+;
						QEV->QEV_ANO+QEV->QEV_MES+aFatAcum[nX][1]))
					aFatAcum[nX][nI+1] := aFatAcum[nX][nI+1]+QEW->QEW_QTDLAU
				EndIf
			Next nX

			// Acumula Lotes entregues, demeritados, IQDs e IPOs
			dbSelectArea("QEV")
			aLotEnt[nI] += QEV->QEV_LOTENT
			aLotDem[nI] += QEV->QEV_LOTDEM
			aIQD[nI] 	+= Iif(QEV->QEV_IQD<>999.99,QEV->QEV_IQD,0)
			aIPO[nI] 	+= Iif(QEV->QEV_IPO<>999.99,QEV->QEV_IPO,0)

			QEV->(dbSkip())

		EndDo

		// Verifica a possibilidade de geracao do acumulado
		nCtMes := 0
		nCtEnt := 0
		For nX := 1 to nMvMesAcu
			If aLotEnt[nX] <> 0
				nCtMes += 1
				nCtEnt += aLotEnt[nX]
			EndIf
		Next nX

		// Criterio Flexivel
		lAcumula := Iif(nCtEnt > 0, .T., .F.)

		// Chama a funcao que calcula o acumulado
		nIQPa   := 999.99
		nIQIa   := 999.99
		nIPOa   := 999.99
		nIQFa   := 999.99
		nTotDem := 999.99

		If lAcumula
			A231CaAc()
		EndIf

		//Gravacao dos indices acumulados gerados
		QEV->(dbGoto(nRecQEV))
		RecLock("QEV",.F.)
		QEV->QEV_IQPA	:= nIQPa
		QEV->QEV_IQDA	:= nTotDem
		QEV->QEV_IQIA	:= nIQIa
		QEV->QEV_IPOA	:= nIPOa
		QEV->QEV_IQFA	:= nIQFa
		MsUnLock()

		dbSelectArea("XQEK")

	EndDo

	If lCont

		// Calc. o IQF Acum. p/ os produtos/fornecedores s/ Entrada no mes/ano
		For nFornece:=1 To Len(aFornece)

			QEV->(dbSetOrder(2))

			SA5->(dbSetOrder(1))
			SA5->(dbSeek(xFilial("SA5")+aFornece[nFornece]))

			ProcRegua(RecCount())

			While SA5->A5_FILIAL == xFilial("SA5") .And. SA5->(.NOT. Eof()) .and.;
					SA5->A5_FORNECE+SA5->A5_LOJA == aFornece[nFornece]

				IncProc("Fornecedor : "+SA5->A5_FORNECE+"   "+"Produto : "+SA5->A5_PRODUTO )

				// Verifica se nao é Produto de Permuta
				If SA5->A5_FABREV == "P"	// Permuta
					SA5->(dbSkip())
					Loop
				EndIf

				cFor := SA5->A5_FORNECE
				cProd := SA5->A5_PRODUTO

				// Verifica se gerou IQF com Entrada no mes/ano p/ o Produto/Fornecedor
				QEV->(dbSetOrder(2))
				If QEV->(dbSeek(xFilial("QEV")+SA5->A5_FORNECE+SA5->A5_PRODUTO+cIE230Ano+cIE230Mes))
					If QEV->QEV_LOTENT <> 0
						SA5->(dbSkip())
						Loop
					EndIf
				EndIf

				// Calculos dos Indices Mensais Informados
				aFatInf := {}
				QF1->(dbSetOrder(1))
				QF1->(dbSeek(xFilial("QF1")))
				While QF1->(.NOT. EOF()) .And. QF1->QF1_FILIAL == xFilial("QF1")
					If QF1->QF1_CALC == "I" .And. QF1->QF1_FATIQF <> 0	// Indice informado mensalmente
						QE0->(dbSetOrder(1))
						If	QE0->(dbSeek(xFilial("QE0")+cAnoFim+cMesFIm+SA5->A5_FORNECE+SA5->A5_PRODUTO+QF1->QF1_INDICE))
							// Guarda num array o valor mensal multiplicado pelo seu fator IQF
							Aadd(aFatInf, (QF1->QF1_FATIQF * QE0->QE0_VALOR))
						EndIf
						dbSelectArea("QF1")
					EndIf
					QF1->(dbSkip())
				EndDo

				//  Indices Mensais Calculados
				// Vetor que guarda a qtde nos n meses de cada Fator Laudo
				aFatAcum := Array(Len(aFatIQP),nMvMesAcu+1)
				For nI := 1 to len(aFatIQP)
					aFatAcum[nI][1] := aFatIQP[nI][1]
					For nX := 1 to nMvMesAcu
						aFatAcum[nI][nX+1] := 0
					Next nX
				Next nI

				// Vetores que terao as respect. somas nos n meses
				aLotEnt := Array(nMvMesAcu)	// Lotes entregues
				Afill(aLotEnt,0)

				aLotDem := Array(nMvMesAcu)	// Lotes demeritados
				Afill(aLotDem,0)

				aIQD := Array(nMvMesAcu)	// IQDs
				Afill(aIQD,0)

				aIPO := Array(nMvMesAcu)	// IPOs
				Afill(aIPO,0)

				// Verifica se existe pelo menos 1 Entrada nos ultimos n meses
				dbSelectArea("QEV")
				cPerini:=cAnoIni+cMesIni
				cPerFim:=cAnoFim+cMesFim

				BeginSQL Alias "XQEV"
					SELECT
						QEV_ANO,
						QEV_MES,
						QEV_FORNEC,
						QEV_PRODUT,
						QEV_LOTENT,
						QEV_LOTDEM,
						QEV_IQP,
						QEV_IPO
					FROM
						%Table:QEV%
					WHERE
						%NotDel%
						AND QEV_FORNEC = %Exp:cFor%
						AND QEV_PRODUT = %Exp:cProd%
						AND QEV_FILIAL = %XFILIAL:QEV%
					ORDER BY
						QEV_FILIAL,
						QEV_FORNEC,
						QEV_PRODUT,
						QEV_ANO,
						QEV_MES
				EndSQL

				While XQEV->(.NOT. EOF())

					nI := Ascan(aAnoMes, {|x| x[1]+x[2] == XQEV->QEV_ANO+XQEV->QEV_MES })

					If nI > 0
						// Acumula as qtdes. de cada Laudo
						QEW->(dbSetOrder(1))
						For nX := 1 to Len(aFatAcum)
							If QEW->(dbSeek(xFilial("QEW")+XQEV->QEV_FORNEC+XQEV->QEV_PRODUT+;
									XQEV->QEV_ANO+XQEV->QEV_MES+aFatAcum[nX][1]))
								aFatAcum[nX][nI+1] +=QEW->QEW_QTDLAU // A 1a. pos. é o laudo
							EndIf
						Next nX

						// Acumula Lotes entregues, demeritados, IQDs e IPOs
						dbSelectArea("XQEV")
						aLotEnt[nI] += XQEV->QEV_LOTENT
						aLotDem[nI] += XQEV->QEV_LOTDEM
						aIQD[nI] 	+= Iif(XQEV->QEV_IQD<>999.99,XQEV->QEV_IQD,0)
						aIPO[nI] 	+= Iif(XQEV_IPO<>999.99,XQEV_IPO,0)
					End
					XQEV->(dbSkip())

				EndDo

				XQEV->(dbCloseArea())

				// Verifica se nos ult. n meses houve algum mes com Entrada
				nCtMes := 0
				For nX := 1 to nMvMesAcu
					If aLotEnt[nX] <> 0
						nCtMes++
					EndIf
				Next nX

				If nCtMes == 0
					SA5->(dbSkip())
					Loop
				EndIf

				// Verifica a possibilidade de geracao do acumulado
				nCtMes :=0
				nCtEnt := 0
				For nX := 1 to nMvMesAcu
					If aLotEnt[nX] <> 0
						nCtMes++
						nCtEnt += aLotEnt[nX]
					EndIf
				Next nX

				// Criterio Flexivel
				lAcumula := Iif(nCtEnt > 0, .t., .f.)

				// Define o IQS do Fornecedor
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+cFor))
				nIQS:=If(SA2->A2_FATAVA == 0 .And. Empty(SA2->A2_DTAVA),999.99,SA2->A2_FATAVA)

				// Chama a funcao que calcula o acumulado
				nIQPa   := 999.99
				nIQIa   := 999.99
				nIPOa   := 999.99
				nIQFa   := 999.99
				nTotDem := 999.99

				If lAcumula
					A231CaAc()
				EndIf

				// Seta flag que indica que gerou o acumulado p/ os itens s/ Entrada
				lFlgAcu := .t.

				//¦ Gravacao acumulados p/ forn./prod. s/ Entradas no mes/ano            ¦
				// Nao grava as qtdes. no QEW porque somente tem os acumulados
				QEV->(dbSetOrder(2))
				If QEV->(.NOT. dbSeek(xFilial("QEV")+cFor+cProd+cIE230Ano+cIE230Mes))
					RecLock("QEV",.T.)
					QEV->QEV_FILIAL	:= xFilial("QEV")
					QEV->QEV_ANO	:= cIE230Ano
					QEV->QEV_MES	:= cIE230Mes
					QEV->QEV_FORNEC	:= cFor
					QEV->QEV_PRODUT	:= cProd
				Else
					RecLock("QEV",.F.)
				EndIf
				QEV->QEV_LOTENT	:=	0
				QEV->QEV_LOTDEM	:=	0
				QEV->QEV_LOTINS	:=	0
				QEV->QEV_LOTSKP	:=	0
				QEV->QEV_QTDINS	:=	0
				QEV->QEV_QTDSKP	:=	0
				QEV->QEV_QTDREJ	:=	0
				QEV->QEV_IQP	:=	999.99
				QEV->QEV_IQD	:=	999.99
				QEV->QEV_IQS	:=	nIQS
				QEV->QEV_IQI	:=	999.99
				QEV->QEV_IPO	:=	999.99
				QEV->QEV_ITR	:=	999.99
				QEV->QEV_IES	:=	999.99
				QEV->QEV_IPR	:=	999.99
				QEV->QEV_IQF	:=	999.99
				QEV->QEV_IQPA	:= nIQPa
				QEV->QEV_IQDA	:= nTotDem
				QEV->QEV_IQIA	:= nIQIa
				QEV->QEV_IPOA	:= nIPOa
				QEV->QEV_IQFA	:= nIQFa
				QEV->QEV_DTGER	:=	dDataBase
				MsUnLock()

				QEG->(dbSetOrder(1))
				QEG->(dbGoTop())
				While QEG->(.NOT. EOF())
					If nIQFa >= QEG->QEG_IQI_I .or. nIQFa <= QEG->QEG_IQI_S
						Exit
					End
					QEG->(dbSkip())
				End

				RecLock("SA5",.F.)
				SA5->A5_SITU:=QEG->QEG_SITU
				MsUnLock()

				SA5->(dbSkip())
			EndDo

			QEV->(dbSetOrder(1))

		Next nFornece

		// Avisa se gerou os indices mensais/ acumulados ou N.D.A.
		If !lFlgMen
			If !lFlgAcu
				FwMsgAlert("Nao ha dados para a geracao Ind. Qual. neste mes/ano","Atencao")
			Else
				FWMsgAlert("Somente foram gerados os Indices acumulados, para produtos sem Entrada no mes/ano","Atencao")
			EndIf
		EndIf
	EndIf

	XQEK->(dbCloseArea())

	dbSelectArea("QEK")
	dbSetOrder(nOrdQEK)

	dbSelectArea("SA5")
	dbSetOrder(nOrdSA5)

	dbSelectArea("QEV")
	dbSetOrder(nOrdQEV)

	dbSelectArea("QE0")
	dbSetOrder(nOrdQE0)

Return NIL

/*/{Protheus.doc} A231CaAc
Calculo do IQF Acumulado  (para uma Filial)
@type function Processamento
@version  1.01
@author Vera Lucia S. Simoes / alterado por marioantonaccio
@since 21/05/98 /  alterado em 08/01/2026
@return Character, sem retorno
/*/
Static Function A231CaAc()

	// Calculo dos Acumulados para os Indices Calculados                    ¦

	// Calcula o IQI Acumulado
	// Acumula a qtde. de cada Fator (de todos os meses)
	Local nX := 0
	Local nI := 0

	aLauAc := {}
	For nI := 1 to Len(aFatAcum)
		nSoma := 0
		For nX := 1 to nMvMesAcu
			nSoma := nSoma+aFatAcum[nI][nX+1]
		Next nX
		Aadd(aLauAc, { aFatAcum[nI][1], nSoma })
	Next nI

	// Acumula os demeritos
	nTotDem := 0
	For nI := 1 to nMvMesAcu
		nTotDem +=aIQD[nI]
	Next nI

	// Calculo do IQI Acumulado
	// Calculo do IQPa por Tabela Completa
	nSoma	:= 0
	nAux	:= 0
	For nX := 1 to Len(aLauAc)
		nAux +=(aFatIQP[nX][2] * aLauAc[nX][2]) // Fator * Ocorr. Acum. Laudo
		nSoma+=nSoma+aLauAc[nX][2]
	Next nX
	nIA := Iif(nSoma <> 0, (nAux/nSoma)*100, 0)

	// Calculo do IQIa por Tabela
	// Obtem o Fator K, de acordo com o IA
	QEJ->(dbSetOrder(1))
	QEJ->(dbSeek(xFilial("QEJ")+"1"+Str(nIA,6,2),.T.))
	nK := SuperVal(QEJ->QEJ_FATOR)
	nIQPa := ( 100 - nK ) - nTotDem
	nIQPa := Iif(nIQPa < 0, 0, nIQPa)

	// Calculo do IQS
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+cFor))
	nIQS:=If(SA2->A2_FATAVA == 0 .And. Empty(SA2->A2_DTAVA),999.99,SA2->A2_FATAVA)

	// Calculo do IQIa por Tabela
	QEJ->(dbSetOrder(1))
	If nIQS <> 999.99
		// Obtem o Fator FC, de acordo com o IQS
		QEJ->(dbSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2),.T.))
		nFC := SuperVal(QEJ->QEJ_FATOR)
	Else
		// Obtem o Fator FC para quando nao tiver a nota do IQS (999.99)
		nFC:=If(QEJ->(dbSeek(xFilial("QEJ")+"2"+Str(nIQS,6,2),.T.)),SuperVal(QEJ->QEJ_FATOR),1)
	EndIf
	nIQIa := (nIQPa * nFC)

	// Calculo do IPR Acumulado
	nIPRa := 0

	// Calculo do IES Acumulado
	// Calcula o IPOa: Media dos IPOs dos n meses
	nSoma := 0
	nDiv  := 0
	nIPOa := 0
	For nX := 1 to nMvMesAcu
		If aLotEnt[nX] <> 0
			nSoma +=aIPO[nX]
			nDiv++
		EndIf
	Next nX

	If nDiv <> 0
		nIPOa := (nSoma / nDiv)
	EndIf

	nIESa := nIPOa

	// Calculos dos Acumulados para os Indices Informados: media            ¦
	aFatInf := {}
	QF1->(dbSetOrder(1))
	QF1->(dbSeek(xFilial("QF1")))
	While QF1->(.NOT. EOF()) .And. QF1->QF1_FILIAL == xFilial("QF1")

		If QF1->QF1_CALC == "I"	// Indice informado mensalmente
			QE0->(dbSetOrder(1))
			For nI := 1 to Len(aAnoMes)
				If	QE0->(dbSeek(xFilial("QE0")+aAnoMes[nI,1]+aAnoMes[nI,2]+cFor+cProd+QF1->QF1_INDICE))
					nPos := Ascan(aFatInf, {|x| x[1] == QF1->QF1_INDICE })
					If nPos == 0
						// Guarda o Indice, a soma valores mensais, no. de meses, Fator Indice no calc. IQF
						Aadd(aFatInf, {QF1->QF1_INDICE, QE0->QE0_VALOR, 1, QF1->QF1_FATIQF} )
					Else
						aFatInf[nPos,2]+= QE0->QE0_VALOR
						aFatInf[nPos,3]++
					EndIf
				EndIf
			Next nI
			dbSelectArea("QF1")
		EndIf

		QF1->(dbSkip())

	EndDo

	// Calculo do IQF Acumulado
	// Indices calculados
	nIQFa := (nFatIQI*nIQIa) + nFatIPR*nIPRa + (nFatIES*nIESa)

	// Indices informados: Media dos valores mensais
	For nI := 1 to Len(aFatInf)
		nIQFa := nIQFa + ((aFatInf[nI,2] / aFatInf[nI,3])*aFatInf[nI,4])
	Next nI

Return NIL
