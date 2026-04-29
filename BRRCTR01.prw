#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BRRCTR01
Relacao de Contratos De -> Ate
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@return character, sem retorno
@see
Baseado no relatorio CNTR010

Variaveis utilizadas para parametros
MV_PAR01 01	Contrato De?
MV_PAR02 02	Contrato ate?
MV_PAR03 03	Revisão de ?
MV_PAR03 03	Revisão de ?
MV_PAR04 04	Revisão ate?
MV_PAR05 05	Vigência de: ?
MV_PAR06 06	Vigência até: ?
MV_PAR07 07	Situação: ?
MV_PAR08 08	Fornecedor: ?
MV_PAR09 09	Tipo de Contrato: ?
MV_PAR10 10	Exibir Textos do Contrato ?
MV_PAR11 11	Exibir Detalhes da Medicao ?
MV_PAR12 12	Cliente: ?
MV_PAR13 13	Imprimir valores na moeda ?
MV_PAR14 14	Moeda ?
MV_PAR15 15	Data de referência ?
MV_PAR16 16	Por contrato de ?
MV_PAR17 17	Exibir Aprovadores Contrato ?
MV_PAR18 18	Exibir Aprovadores Itens ?
*/
User Function BRRCTR01()

	Pergunte("BRRCTR01",.F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return (NIL)

/*/{Protheus.doc} ReportDef
Define a configuracao do relatorio de contratos
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@return object, objeto do relatorio
/*/
Static Function ReportDef()
	Local oReport
	Local oSectCab// Sessao Cabecalho
	Local oSectPla// Sessao Planilhas
	Local oSectItm// Sessao Itens de Planilhas
	Local oSectAgr// Sessao Agrupadores
	Local oSectCac// Sessao Caucoes
	Local oSectFrn// Sessao Fornecedores
	Local oSectCli// Sessao Cliente
	Local oSectCro// Sessao Cronograma
	Local oSectMul// Sessao Multas
	Local oSectMed// Sessao Medicoes
	Local oSectIMe// Sessao Itens de medicoes
	Local oSectBon// Sessao Multas/Bonificacoes
	Local oSectDes// Sessao Descontos
	Local oSectCtb// Sessao Cronograma Contabil

	Local nCNBTamPrd:= TamSX3("CNB_PRODUT")[1]
	Local nCNETamPrd:= TamSX3("CNE_PRODUT")[1]
	Local cCabec:="Nr. Contrato	Revisao	Tipo	Situacao	Dt Proposta	Inicio	Assinatura	Data Revisao	Final	Vl. Inicial	Valor Atual	Saldo	Reajuste S/N	Indice"

	oReport := TReport():New("BRRCTR01",OemToAnsi("Contratos"),"BRRCTR01",{|oReport| BR010Imp(oReport)},"Imprime relatorio de contratos")

	// Cabecalho do contrato
	oSectCab := TRSection():New(oReport,OemToAnsi(cCabec),{"CN9","SE4","CN1"})

	TRCell():New(oSectCab,"CN9_NUMERO","CN9",,,TamSx3("CN9_NUMERO")[1]+11)
	TRCell():New(oSectCab,"CN9_REVISA","CN9",,,TamSx3("CN9_REVISA")[1])
	TRCell():New(oSectCab,"CN1_DESCRI","CN1","Tipo",,TamSx3("CN1_DESCRI")[1])
	TRCell():New(oSectCab,"CN9_SITUAC","CN9",,,TamSx3("CN9_SITUAC")[1],,{|| QA_CBox("CN9_SITUAC",AllTrim(QRYCN9->CN9_SITUAC))})

	TRCell():New(oSectCab,"CN9_DTPROP","CN9")
	TRCell():New(oSectCab,"CN9_DTINIC","CN9")
	TRCell():New(oSectCab,"CN9_ASSINA","CN9")
	TRCell():New(oSectCab,"CN9_DTREV" ,"CN9")
	TRCell():New(oSectCab,"CN9_DTFIM" ,"CN9")

	TRCell():New(oSectCab,"CN9_VLINI","CN9",,,,,{|| QRYCN9->(B010xMoeda(CN9_NUMERO,CN9_REVISA,"CN9_VLINI"))})
	TRCell():New(oSectCab,"CN9_VLATU","CN9",,,,,{|| QRYCN9->(B010xMoeda(CN9_NUMERO,CN9_REVISA,"CN9_VLATU"))})
	TRCell():New(oSectCab,"CN9_SALDO","CN9",,,,,{|| QRYCN9->(B010xMoeda(CN9_NUMERO,CN9_REVISA,"CN9_SALDO"))})

	TRCell():New(oSectCab,"CN9_FLGREJ","CN9",,,TamSx3("CN9_FLGREJ")[1],,{|| QA_CBox("CN9_FLGREJ",AllTrim(QRYCN9->CN9_FLGREJ))})
	TRCell():New(oSectCab,"CN6_DESCRI","CN6","Indice",,TamSx3("CN6_DESCRI")[1],,{||Alltrim(QRYCN9->CN6_DESCRI)})

	oSectCab:Cell("CN1_DESCRI"):SetLineBreak()

	// Aprovadores Contrato
	oSectApC := TRSection():New(oSectCab,OemToAnsi("Aprovadores"))
	oSectApC:lHeaderVisible := .T.
	TrCell():New(oSectApC, "CR_NUM"    , "SCR", /*4*/                    , /*5*/, 35                   , /*7*/, /*8*/)
	TrCell():New(oSectApC, "CR_TIPO"   , "SCR", OemToAnsi("Tipo docto")  , /*5*/, TamSx3("CR_TIPO")[1] , /*7*/, /*8*/)
	TrCell():New(oSectApC, "CR_NIVEL"  , "SCR", /*4*/                    , /*5*/, TamSx3("CR_NIVEL")[1], /*7*/, /*8*/)
	TrCell():New(oSectApC, "CR_USER"   , "SCR", OemToAnsi("Cod. Usuario"), /*5*/, TamSx3("AK_NOME")[1] , /*7*/, {|| QRYSCR->(UsrRetName(CR_USER))})
	TrCell():New(oSectApC, "CR_USERLIB", "SCR", OemToAnsi("Cod. Aprov.") , /*5*/, TamSx3("AK_NOME")[1] , /*7*/, {|| QRYSCR->(UsrRetName(CR_USERLIBE))})
	TrCell():New(oSectApC, "CR_STATUS" , "SCR", OemToAnsi("Cont. Aprov."), /*5*/, /*6*/                , /*7*/, /*8*/)
	TrCell():New(oSectApC, "CR_DATALIB", "SCR", /*4*/                    , /*5*/, /*6*/                , /*7*/, /*8*/)
	TrCell():New(oSectApC, "CR_OBS"    , "SCR", /*4*/                    , /*5*/, /*6*/                , /*7*/, {|| QRYSCR->(B010GtMemo(R_E_C_N_O_))})

	// Fornecedores
	oSectFrn := TRSection():New(oSectCab,OemToAnsi("Fornecedores"),{"CNC","SA2"})
	oSectFrn:lHeaderVisible := .T.
	TRCell():New(oSectFrn,"CNC_CODIGO","CNC")
	TRCell():New(oSectFrn,"CNC_LOJA","CNC")
	TRCell():New(oSectFrn,"A2_NOME","SA2",RetTitle("CNC_NOME"))

	// Cliente
	oSectCli := TRSection():New(oSectCab,OemToAnsi("Cliente"),{"CNC","SA1"})
	TRCell():New(oSectCli,"CNC_CLIENT","CNC")
	TRCell():New(oSectCli,"CNC_LOJACL","CNC")
	TRCell():New(oSectCli,"A1_NOME","SA1",RetTitle("A1_NOME"))
	oSectCli:lHeaderVisible := .T.

	// Multas
	oSectMul := TRSection():New(oSectCab,OemToAnsi("Multas"),{"CNH","CN4"})
	oSectMul:lHeaderVisible := .T.
	TRCell():New(oSectMul,"CNH_CODIGO","CNH")
	TRCell():New(oSectMul,"CN4_DESCRI","CN4")

	// Caucoes
	oSectCac := TRSection():New(oSectCab,OemToAnsi("Cauções"),{"CN8","CN3"})
	oSectCac:lHeaderVisible := .T.
	TRCell():New(oSectCac,"CN8_CODIGO","CN8")
	TRCell():New(oSectCac,"CN3_DESCRI","CN3")
	TRCell():New(oSectCac,"CN8_FORNEC","CN8")
	TRCell():New(oSectCac,"CN8_LOJA","CN8")
	TRCell():New(oSectCac,"CN8_NUMDOC","CN8")
	TRCell():New(oSectCac,"CN8_DTINVI","CN8")
	TRCell():New(oSectCac,"CN8_DTFIVI","CN8")
	TRCell():New(oSectCac,"CN8_VLEFET","CN8",,,,,{|| QRYCN8->(B010xMoeda(QRYCN8->CN8_CONTRA,QRYCN8->CN8_REVISA,"CN8_VLEFET"))})
	TRCell():New(oSectCac,"CN8_MOEDA","CN8")
	TRCell():New(oSectCac,"CN8_EMITEN","CN8")

	// Cabecalho das Planilhas
	oSectPla := TRSection():New(oSectCab,OemToAnsi("Planilha"),{"CNA","CNL"})
	oSectPla:lHeaderVisible := .T.
	TRCell():New(oSectPla,"CNA_NUMERO","CNA")
	TRCell():New(oSectPla,"CNL_DESCRI","CNL","Tipo")
	TRCell():New(oSectPla,"CNA_FORNEC","CNA")
	TRCell():New(oSectPla,"CNA_LJFORN","CNA")
	TRCell():New(oSectPla,"CNA_CLIENT","CNA")
	TRCell():New(oSectPla,"CNA_LOJACL","CNA")
	TRCell():New(oSectPla,"CNA_DTINI" ,"CNA")
	TRCell():New(oSectPla,"CNA_DTFIM" ,"CNA")
	TRCell():New(oSectPla,"CNA_VLTOT","CNA",,,,,{|| QRYCNA->(B010xMoeda(QRYCNA->CNA_CONTRA,QRYCNA->CNA_REVISA,"CNA_VLTOT"))})
	TRCell():New(oSectPla,"CNA_SALDO","CNA",,,,,{|| QRYCNA->(B010xMoeda(QRYCNA->CNA_CONTRA,QRYCNA->CNA_REVISA,"CNA_SALDO"))})
	TRCell():New(oSectPla,"CNA_FLREAJ","CNA",,,TamSx3("CNA_FLREAJ")[1],,{|| QA_CBox("CNA_FLREAJ",AllTrim(QRYCNA->CNA_FLREAJ))})

	// Itens das planilhas
	oSectItm := TRSection():New(oSectPla,OemToAnsi("Itens Planilha"),{"CNB"})
	oSectItm:lHeaderVisible := .T.
	TRCell():New(oSectItm,"CNB_ITEM","CNB")
	TRCell():New(oSectItm,"CNB_PRODUT","CNB",,,nCNBTamPrd)
	TRCell():New(oSectItm,"CNB_QUANT","CNB")
	TRCell():New(oSectItm,"CNB_VLUNIT","CNB",,,,,{|| QRYCNB->(B010xMoeda(QRYCNB->CNB_CONTRA,QRYCNB->CNB_REVISA,"CNB_VLUNIT"))})
	TRCell():New(oSectItm,"CNB_VLTOT","CNB",,,,,{|| QRYCNB->(B010xMoeda(QRYCNB->CNB_CONTRA,QRYCNB->CNB_REVISA,"CNB_VLTOT"))})
	TRCell():New(oSectItm,"CNB_DESC","CNB")
	TRCell():New(oSectItm,"CNB_VLDESC","CNB",,,,,{|| QRYCNB->(B010xMoeda(QRYCNB->CNB_CONTRA,QRYCNB->CNB_REVISA,"CNB_VLDESC"))})
	TRCell():New(oSectItm,"CNB_QTDMED","CNB")
	TRCell():New(oSectItm,"CNB_SLDMED","CNB")

	oSectItm:Cell("CNB_PRODUT"):SetLineBreak()

	//- Agrupadores de estoque -------------------------------------------
	oSectAgr	:= TRSection():New(oSectPla,OemToAnsi("Estoque"),{"CXM"})
 	oSectAgr:lHeaderVisible := .T.
	TRCell():New(oSectAgr,"CXM_ITEMID","CXM")
	TRCell():New(oSectAgr,"CXM_AGRTIP","CXM",,,nCNBTamPrd)
	TRCell():New(oSectAgr,"CXM_AGRGRP","CXM",,,nCNBTamPrd)
	TRCell():New(oSectAgr,"CXM_AGRCAT","CXM",,,nCNBTamPrd)
	TRCell():New(oSectAgr,"CXM_VLMAX ","CXM",,,,,{|| QRYCXM->(B010xMoeda(QRYCXM->CXM_CONTRA,QRYCXM->CXM_REVISA,"CXM_VLMAX"))})
	TRCell():New(oSectAgr,"CXM_VLMED ","CXM",,,,,{|| QRYCXM->(B010xMoeda(QRYCXM->CXM_CONTRA,QRYCXM->CXM_REVISA,"CXM_VLMED"))})

	oSectAgr:Cell("CXM_ITEMID"):SetLineBreak()

	// Cronogramas
	oSectCro := TRSection():New(oSectPla,OemToAnsi("Cronograma"),{"CNF"})
	oSectCro:lHeaderVisible := .T.
	TRCell():New(oSectCro,"CNF_NUMERO","CNF")
	TRCell():New(oSectCro,"CNF_PARCEL","CNF")
	TRCell():New(oSectCro,"CNF_COMPET","CNF")
	TRCell():New(oSectCro,"CNF_VLPREV","CNF",,,,,{|| QRYCNF->(B010xMoeda(QRYCNF->CNF_CONTRA,QRYCNF->CNF_REVISA,"CNF_VLPREV"))})
	TRCell():New(oSectCro,"CNF_VLREAL","CNF",,,,,{|| QRYCNF->(B010xMoeda(QRYCNF->CNF_CONTRA,QRYCNF->CNF_REVISA,"CNF_VLREAL"))})
	TRCell():New(oSectCro,"CNF_SALDO","CNF",,,,,{|| QRYCNF->(B010xMoeda(QRYCNF->CNF_CONTRA,QRYCNF->CNF_REVISA,"CNF_SALDO"))})
	TRCell():New(oSectCro,"CNF_DTVENC","CNF")
	TRCell():New(oSectCro,"CNF_PRUMED","CNF")
	TRCell():New(oSectCro,"CNF_DTREAL","CNF")

	// Parcelas do Cronograma Contabil
	oSectCtb := TRSection():New(oSectPla,OemToAnsi("Cronograma Contabil"),{"CNW"})
	oSectCtb:lHeaderVisible := .T.
	TRCell():New(oSectCtb,"CNW_NUMERO","CNW")
	TRCell():New(oSectCtb,"CNW_PARCEL","CNW")
	TRCell():New(oSectCtb,"CNW_DTPREV","CNW")
	TRCell():New(oSectCtb,"CNW_VLPREV","CNW",,,,,{|| QRYCNW->(B010xMoeda(QRYCNw->CNW_CONTRA,QRYCNW->CNW_REVISA,"CNW_VLPREV"))})
	TRCell():New(oSectCtb,"CNW_HIST","CNW")
	TRCell():New(oSectCtb,"CNW_CC","CNW")
	TRCell():New(oSectCtb,"CNW_DTLANC","CNW")
	TRCell():New(oSectCtb,"CNW_ITEMCT","CNW")
	TRCell():New(oSectCtb,"CNW_CLVL","CNW")

	// Cabecalho das Medicoes
	oSectMed := TRSection():New(oSectCab,OemToAnsi("Medições"),{"CND"})
	oSectMed:lHeaderVisible := .T.
	TRCell():New(oSectMed,"CND_NUMMED","CND")
	TRCell():New(oSectMed,"CND_NUMERO","CND")
	TRCell():New(oSectMed,"CND_FORNEC","CND")
	TRCell():New(oSectMed,"CND_LJFORN","CND")
	TRCell():New(oSectMed,"CND_COMPET","CND")
	TRCell():New(oSectMed,"CND_VLTOT","CND",,,,,{|| QRYCND->(B010xMoeda(QRYCND->CND_CONTRA,QRYCND->CND_REVISA,"QRYCND->CND_VLTOT"))})

	// Itens de Medicoes
	oSectIMe := TRSection():New(oSectMed,OemToAnsi("Itens Medições"),{"CNE"})
	oSectIMe:lHeaderVisible := .T.
	TRCell():New(oSectIMe,"CNE_ITEM","CNE")
	TRCell():New(oSectIMe,"CNE_PRODUT","CNE",,,nCNETamPrd)
	TRCell():New(oSectIMe,"CNE_QTDSOL","CNE")
	TRCell():New(oSectIMe,"CNE_QUANT","CNE")
	TRCell():New(oSectIMe,"CNE_VLUNIT","CNE",,,,,{|| QRYCNE->(B010xMoeda(QRYCNE->CNE_CONTRA,QRYCNE->CNE_REVISA,"QRYCNE->CNE_VLUNIT"))})
	TRCell():New(oSectIMe,"CNE_VLTOT","CNE",,,,,{|| QRYCNE->(B010xMoeda(QRYCNE->CNE_CONTRA,QRYCNE->CNE_REVISA,"QRYCNE->CNE_VLTOT"))})

	oSectIMe:Cell("CNE_PRODUT"):SetLineBreak()

	// Multas/Bonificacoes
	oSectBon := TRSection():New(oSectMed,OemToAnsi("Multas/Bonificações"),{"CNR"})
	oSectBon:lHeaderVisible := .T.
	oSectBon:SetTotalText("")
	TRCell():New(oSectBon,"CNR_TIPO","CNR")
	TRCell():New(oSectBon,"CNR_DESCRI","CNR")
	TRCell():New(oSectBon,"CNR_VALOR","CNR",,,,,{|| QRYCNR->(B010xMoeda(QRYCND->CND_CONTRA,QRYCND->CND_REVISA,"CNR_VALOR"))})
	TRFunction():New(oSectBon:Cell("CNR_VALOR"),NIL,"SUM",/*oBreak*/,OemToAnsi("Valor"),/*cPicture*/,/*uFormula*/,.T.,.F.,,oSectBon,{|| IIf( QRYCNR->CNR_TIPO == "1" , .T. , .F. ) } )
	TRFunction():New(oSectBon:Cell("CNR_VALOR"),NIL,"SUM",/*oBreak*/,OemToAnsi("Valor"),/*cPicture*/,/*uFormula*/,.T.,.F.,,oSectBon,{|| IIf( QRYCNR->CNR_TIPO == "2" , .T. , .F. ) } )

	// Descontos
	oSectDes := TRSection():New(oSectMed,OemToAnsi("Descontos"),{"CNQ","CNP"})
	oSectDes:lHeaderVisible := .T.
	oSectDes:SetTotalText("")
	TRCell():New(oSectDes,"CNQ_TPDESC","CNQ")
	TRCell():New(oSectDes,"CNP_DESCRI","CNP")
	TRCell():New(oSectDes,"CNQ_VALOR","CNQ",,,,,{|| QRYCNQ->(B010xMoeda(QRYCND->CND_CONTRA,QRYCND->CND_REVISA,"CNQ_VALOR"))})
	TRFunction():New(oSectDes:Cell("CNQ_VALOR"),NIL,"SUM",,OemToAnsi("Valor"),,,.T.,.F.,,oSectDes)

Return oReport

/*/{Protheus.doc} BR010Imp
Executa impressao do relatorio de contratos
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oReport, object, Objeto do Relatorio
@return Character, sem retorno
/*/
Static Function BR010Imp(oReport)  

	Local oSectCab := oReport:Section(1)//Cabecalho do contrato
	Local oSectApC := oReport:Section(1):Section(1)//Aprovadores do contrato
	Local oSectFrn := oReport:Section(1):Section(2)//Fornecedores
	Local oSectCli := oReport:Section(1):Section(3)//Cliente
	Local oSectMul := oReport:Section(1):Section(4)//Multas
	Local oSectCac := oReport:Section(1):Section(5)//Caucoes
	Local oSectPla := oReport:Section(1):Section(6)//Cabecalho da planilha
	Local oSectItm := oReport:Section(1):Section(6):Section(1)//Itens de Planilhas
	Local oSectAgr := oReport:Section(1):Section(6):Section(2)//Agrupadores de Estoque
	Local oSectCro := oReport:Section(1):Section(6):Section(3)//Cronogramas
	Local oSectCtb := oReport:Section(1):Section(6):Section(4)//Cronograma Contabil
	Local oSectMed := oReport:Section(1):Section(7)//Medicoes
	Local oSectIMe := oReport:Section(1):Section(7):Section(1)//Itens de Medicoes
	Local oSectBon := oReport:Section(1):Section(7):Section(2)//Multas e Bonificacoes de Medicoes
	Local oSectDes := oReport:Section(1):Section(7):Section(3)//Descontos de Medicoes
	Local nTotLinha
	Local nX

	oSectCab:SetTitle(Upper(oSectCab:Title())) //Cabecalho do contrato
	oSectApC:SetTitle(Upper(oSectApC:Title()))
	oSectFrn:SetTitle(Upper(oSectFrn:Title()))
	oSectCli:SetTitle(Upper(oSectCli:Title()))
	oSectMul:SetTitle(Upper(oSectMul:Title()))
	oSectCac:SetTitle(Upper(oSectCac:Title()))
	oSectPla:SetTitle(Upper(oSectPla:Title())) //Cabecalho da planilha
	oSectItm:SetTitle(Upper(oSectItm:Title()))
	oSectAgr:SetTitle(Upper(oSectAgr:Title()))
	oSectCro:SetTitle(Upper(oSectCro:Title()))
	oSectCtb:SetTitle(Upper(oSectCtb:Title()))
	oSectMed:SetTitle(Upper(oSectMed:Title())) //Medicoes
	oSectIMe:SetTitle(Upper(oSectIMe:Title()))
	oSectBon:SetTitle(Upper(oSectBon:Title()))
	oSectDes:SetTitle(Upper(oSectDes:Title()))

	If mv_par14 == 2
		oReport:SetTitle(oReport:Title() +" em " +AllTrim(GetMv("MV_SIMB" +LTrim(Str(mv_par14)))) +")")
		oSectCac:Cell("CN8_MOEDA"):Disable()
	EndIf

	// Configura perguntas do tipo Range
	//MakeSqlExpr(PadR("BRRCTR01",10))

	// Define querys para impressao do relatorio
	BR010Cab(oSectCab) //-- Cabeçalho

	If mv_par17 == 1 .Or. mv_par18 == 1
		BR010ApC(oSectApC) //-- Aprovadores
	Else
		oSectApC:Disable()
	EndIf

	If mv_par16 == 1
		BR010Frn(oSectFrn) //-- Fornecedores
		oSectCli:Disable()
		oSectPla:Cell("CNA_CLIENT"):Disable()
		oSectPla:Cell("CNA_LOJACL"):Disable()
	Else
		BR010Cli(oSectCli) //-- Clientes
		oSectFrn:Disable()
		oSectPla:Cell("CNA_FORNEC"):Disable()
		oSectPla:Cell("CNA_LJFORN"):Disable()
	EndIf

	BR010Mul(oSectMul) //-- Multas e Bonificações
	BR010Cac(oSectCac) //-- Cauções
	//BR010Pla(oSectPla) //-- Planilhas
	BR010Itm(oSectItm) //-- Itens da Planilha
	BR010Agr(oSectAgr) //-- Agrupadores de Estoque
	BR010Cro(oSectCro) //-- Cronograma
	BR010Ctb(oSectCtb) //-- Cronograma Contábil
	//BR010Med(oSectMed) //-- Medições
	//BR010IMe(oSectIMe) //-- Itens da Medição

	If MV_PAR11 == 1
		BR010Bon(oSectBon) //-- Multas e Bonificações da Medição
		BR010Des(oSectDes) //-- Descontos da Medição
	Else
		oSectBon:Disable()
		oSectDes:Disable()
	EndIf

	// Processa relatorio
	oSectCab:Init()
	While .NOT. QRYCN9->(EOF())
		If oReport:Cancel()
			Exit
		EndIf

		// Imprime cabecalho do contrato
		oSectCab:PrintLine()

		If MV_PAR10 == 1
			oReport:SkipLine()

			// Imprime Texto do Objeto do Contrato
			nTotLinha := MlCount(MSMM(QRYCN9->CN9_CODOBJ,,,,,160))
			oReport:PrintText("Objeto")
			oReport:SkipLine()
			For nX := 1 To nTotLinha
				oReport:PrintText(MemoLine(MSMM(QRYCN9->CN9_CODOBJ,,,,,160),160,nX))
				oReport:SkipLine()
			Next nX
			If nTotLinha == 0
				oReport:PrintText(OemToAnsi("Sem Informações"))
			EndIf
			oReport:SkipLine()

			// Imprime Texto de Clausulas do Contrato
			nTotLinha := MlCount(MSMM(QRYCN9->CN9_CODCLA,,,,,160))
			oReport:PrintText("Clausulas")
			oReport:SkipLine()
			For nX := 1 To nTotLinha
				oReport:PrintText(MemoLine(MSMM(QRYCN9->CN9_CODCLA,,,,,160),160,nX))
				oReport:SkipLine()
			Next nX
			If nTotLinha == 0
				oReport:PrintText(OemToAnsi("Sem Informações"))
			EndIf
			oReport:SkipLine()

			// Imprime Texto de Justificativas do Contrato
			nTotLinha := MlCount(MSMM(QRYCN9->CN9_CODJUS,,,,,160))
			oReport:PrintText("Justficativa")
			oReport:SkipLine()
			For nX := 1 To nTotLinha
				oReport:PrintText(MemoLine(MSMM(QRYCN9->CN9_CODJUS,,,,,160),160,nX))
				oReport:SkipLine()
			Next nX
			If nTotLinha == 0
				oReport:PrintText(OemToAnsi("Sem Informações"))
			EndIf
			oReport:SkipLine()
		EndIf

		// Imprime listagem de Aprovadores do contrato
		If oSectApC:lEnabled
			oSectApC:Print()
		EndIf

		// Imprime listagem de fornecedores
		If mv_par16 == 1
			oSectFrn:Print()
		Else
			oSectCli:Print()
		EndIf

		// Imprime listagem de multas do contrato
		If oSectMul:lEnabled
			oSectMul:Print()
		EndIf

		// Imprime caucoes do contrato
		If oSectCac:lEnabled
			oSectCac:Print()
		EndIf

		// Imprime planilhas/itens/cronogramas
		If oSectPla:lEnabled
			BR010Pla(oSectPla)
			oSectPla:Print()
		EndIf

		// Imprime medicoes do contrato
		If oSectMed:lEnabled
			BR010Med(oSectMed)
			BR010IMe(oSectIMe)
			oSectMed:Print()
		EndIf

		QRYCN9->(dbSkip())

		// Pula pagina quando quebrar contrato
		If .NOT. QRYCN9->(Eof())
			oReport:EndPage()
		EndIf
	EndDo

	oSectCab:Finish()

Return (NIL)

/*/{Protheus.doc} BR010Box
Imprime box com texto centralizado
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oReport, object, Objeto do Relatorio
@param cTexto, character, Texto Impresso
@returnCharacter, sem retorno
/*/
Static Function BR010Box(oReport,cTexto)
	Local nCol1 := 7
	Local nCol2 := oReport:PageWidth()-40

	oReport:Box(oReport:Row()-10,2,oReport:Row()+38,oReport:PageWidth()-35)
	oReport:Box(oReport:Row()-5,nCol1,oReport:Row()+33,nCol2)
	oReport:PrintText(cTexto,oReport:Row(),((nCol2-nCol1)/2)-((Len(alltrim(cTexto))/2)*20))
	oReport:SkipLine()

Return(NIL)

/*/{Protheus.doc} BR010Cab
d Configura sessao do cabecalho de contratos
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectCab, object, Objeto de cabecalho do relatorio - Inclui QUERYS
@return character, sem retorno
/*/
Static Function BR010Cab(oSectCab)
	Local cPart	:= "%"
	Local cCamp	:= "%"
	Local cParam:="%"

	cCamp += ",CN9_FILCTR"

	If .NOT. Empty(mv_par09)
		cPart += "AND CN9.CN9_TPCTO = '" +mv_par07 +"' "
	EndIf
	If .NOT. Empty(mv_par16)
		cPart += "AND CN1.CN1_ESPCTR = '" +Str(mv_par16,1) +"' "

		If mv_par16 == 1
			If .NOT. Empty(mv_par08)
				cParam+=" AND CNC_CODIGO  ='"+mv_par08+"'"
			End
		Else
			If .NOT. Empty(mv_par12)
				cParam+=" AND CNC_CLIENT  ='"+mv_par12+"'"
			End
		EndIf
	EndIf

	cPart += '%'
	cCamp += '%'
	cParam+= "%"

	//oSectCab:BeginQuery()

	// Gera query de filtro dos contratos
	BeginSql alias "QRYCN9"
		SELECT
			CN9_FILIAL,
			CN9_NUMERO,
			CN9_REVISA,
			CN9_DTINIC,
			CN9_SITUAC,
			CN9_DTFIM,
			CN9_DTPROP,
			CN9_ASSINA,
			CN9_DTENCE,
			CN9_CONDPG,
			CN9_TPCTO,
			CN9_DTULST,
			CN9_VIGE,
			CN9_INDICE,
			CN9_FLGCAU,
			CN9_MINCAU,
			CN9_FLGREJ,
			CN9_REVATU,
			CN9_VLINI,
			CN9_VLATU,
			CN9_SALDO,
			CN9_CODOBJ,
			CN9_CODCLA,
			CN9_CODJUS,
			CN9_UNVIGE,
			CN9_CLIENT,
			CN9_LOJACL,
			CN9_DTREV,
			CN6_DESCRI %Exp:cCamp%
		FROM
			%table:CN9% CN9
		JOIN %Table:CN1% CN1
		ON CN1.%NotDel%
			AND CN1.CN1_FILIAL = %xFilial:CN1%
			AND CN1.CN1_CODIGO = CN9.CN9_TPCTO
		LEFT JOIN %table:CNC% CNC
		ON CNC.%notDel%
			AND CNC.CNC_FILIAL = %xfilial:CNC%
			AND CNC.CNC_NUMERO = CN9.CN9_NUMERO
			AND CNC.CNC_REVISA = CN9.CN9_REVISA %EXP:cParam%
		LEFT JOIN %table:CN6% CN6
		ON CN6.%notDel%
			AND CN6.CN6_FILIAL = %xfilial:CN6%
			AND CN6.CN6_CODIGO = CN9.CN9_INDICE
		WHERE
			CN9.CN9_FILIAL = %xfilial:CN9%
			AND CN9.CN9_DTINIC >= %exp:DTOS(mv_par05)%
			AND CN9.CN9_DTFIM <= %exp:DTOS(mv_par06)%
			AND CN9_NUMERO >= %Exp:mv_par01%
			AND CN9_NUMERO <= %Exp:mv_par02%
			AND CN9_REVISA >= %Exp:mv_par03%
			AND CN9_REVISA <= %Exp:mv_par04%
			AND CN9.%notDel% %exp:cPart%
		GROUP BY
			CN9_FILIAL,
			CN9_NUMERO,
			CN9_REVISA,
			CN9_DTINIC,
			CN9_SITUAC,
			CN9_DTFIM,
			CN9_DTPROP,
			CN9_ASSINA,
			CN9_DTENCE,
			CN9_CONDPG,
			CN9_TPCTO,
			CN9_DTULST,
			CN9_VIGE,
			CN9_INDICE,
			CN9_FLGCAU,
			CN9_MINCAU,
			CN9_FLGREJ,
			CN9_REVATU,
			CN9_VLINI,
			CN9_VLATU,
			CN9_SALDO,
			CN9_CODOBJ,
			CN9_CODCLA,
			CN9_CODJUS,
			CN9_UNVIGE,
			CN9_CLIENT,
			CN9_LOJACL,
			CN9_DTREV,
			CN6_DESCRI %Exp:cCamp%
		ORDER BY
			CN9_NUMERO,
			CN9_REVISA
	EndSql
	//oSectCab:EndQuery()

	// Configura posicionamento das tabelas filhas
	TRPosition():New(oSectCab,"SE4",1,"xFilial('SE4')+QRYCN9->CN9_CONDPG")//Cond. Pagto
	TRPosition():New(oSectCab,"CN1",1,"xFilial('CN1')+QRYCN9->CN9_TPCTO")//Tipo de Contrato

Return (NIL)

/*/{Protheus.doc} BR010ApC
Configura sessao do cabecalho de Aprovações
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectApC, object, Sessao do cabecalho - TRSection
@return character, sem retorno
/*/
Static Function BR010ApC(oSectApC)

	Local cTipApr := ""
	Local nTamCtr := TAMSX3('CN9_NUMERO')[1]
	local nTamRev := TAMSX3('CN9_REVISA')[1]
	Local nDe	  := 1

	If mv_par17 == 1 .And. mv_par18 == 1
		cTipApr := "CT','IC','RV','IR"
	ElseIf mv_par17 == 1
		cTipApr := "CT','RV"
	ElseIf mv_par18 == 1
		cTipApr := "IC','IR"
	EndIf

	//BEGIN REPORT QUERY oSectApC
		BeginSQL Alias "QRYSCR"
			SELECT
				CR_NUM,
				CR_TIPO,
				CR_NIVEL,
				CR_APROV,
				CR_USER,
				CR_USERLIB,
				CR_STATUS,
				CR_DATALIB,
				R_E_C_N_O_
			FROM
				%TABLE:SCR% SCR
			WHERE				
				SCR.CR_FILIAL = %EXP:QRYCN9->CN9_FILIAL%
				AND SCR.CR_TIPO in (%EXP:cTipApr%)
				AND (
					(
						SCR.CR_TIPO in ('CT', 'IC')
						AND %EXP:QRYCN9->CN9_NUMERO% = SUBSTRING(CR_NUM,%exp:nDe%,%exp:nTamCtr%)
						AND %EXP:QRYCN9->CN9_REVISA% = %EXP:SPACE(nTamRev)%
					)
					OR (
						SCR.CR_TIPO in ('RV', 'IR')
						AND SUBSTRING(CR_NUM, %Exp:nDe%,%exp:nTamCtr+nTamRev%) = %EXP:QRYCN9->(CN9_NUMERO+CN9_REVISA)%
					)
				)
				AND SCR.%notDel%
			ORDER BY
				CR_NUM,
				CR_NIVEL,
				CR_DATALIB
		EndSQL
	//END REPORT QUERY oSectApC

Return (NIL)

/*/{Protheus.doc} BR010Pla
Configura sessao do cabecalho de planilhas
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectPla, object, Sessao do cabecalho - TRSection Planilha
@return Character, sem retorno
/*/
Static Function BR010Pla(oSectPla)

	// Gera query de filtro das planilhas
	//BEGIN REPORT QUERY oSectPla
		BeginSQL Alias "QRYCNA"
			SELECT
				CNA.CNA_NUMERO,
				CNA.CNA_FORNEC,
				CNA.CNA_LJFORN,
				CNA.CNA_CRONOG,
				CNA.CNA_DTINI,
				CNA.CNA_VLTOT,
				CNA.CNA_SALDO,
				CNA.CNA_TIPPLA,
				CNA.CNA_DTFIM,
				CNA.CNA_FLREAJ,
				CNA.CNA_CONTRA,
				CNA.CNA_REVISA,
				CNA.CNA_CRONCT,
				CNA.CNA_CLIENT,
				CNA.CNA_LOJACL
			FROM
				%Table:CNA% CNA
			WHERE
				CNA.CNA_FILIAL = %XFILIAL:CNA%
				AND CNA.CNA_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CNA.CNA_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNA.%NotDel%
			ORDER BY
				CNA.CNA_CONTRA,
				CNA.CNA_REVISA,
				CNA.CNA_NUMERO
		EndSQL
	//END REPORT QUERY oSectPla

	// Configura posicionamento das tabelas filhas
	TRPosition():New(oSectPla,"CNL",1,"xFilial('CNL')+QRYCNA->CNA_TIPPLA")//Tipos de Tabelas

Return

/*/{Protheus.doc} BR010Itm
Configura sessao dos itens de planilhas
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectItm, object, Sessao dos itens - TRSection
@return character, sem retorno
/*/
Static Function BR010Itm(oSectItm)

	// Gera query de filtro dos itens de planilhas
	//BEGIN REPORT QUERY oSectItm
		BeginSQL Alias "QRYCNB"
			SELECT
				CNB.CNB_ITEM,
				CNB.CNB_PRODUT,
				CNB.CNB_QUANT,
				CNB.CNB_VLUNIT,
				CNB.CNB_VLTOT,
				CNB.CNB_VLTOT,
				CNB.CNB_DESC,
				CNB.CNB_VLDESC,
				CNB.CNB_QTDMED,
				CNB.CNB_SLDMED,
				CNB.CNB_CONTRA,
				CNB.CNB_REVISA,
				CNB.CNB_NUMERO
			FROM
				%Table:CNB% CNB
			WHERE
				CNB.CNB_FILIAL = %xFilial:CNB%
				AND CNB.CNB_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CNB.CNB_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNB.CNB_NUMERO = %EXP:QRYCNA->CNA_NUMERO%
				AND CNB.%NotDel%
			ORDER BY
				CNB.CNB_CONTRA,
				CNB.CNB_REVISA,
				CNB.CNB_NUMERO,
				CNB.CNB_ITEM
		EndSQL
	//END REPORT QUERY oSectItm

Return (NIL)

/*/{Protheus.doc} BR010Agr
Imprime os agruipadores de Estoque
@type function 1.0
@version  Relatorio
@author marioantonaccio
@since 02/03/2026
@param oSectAgr, object, Objeto de Impressao ds agrupadores
@return Character, sem retorno
/*/
Static Function BR010Agr(oSectAgr)

	//- Gera query de filtro dos itens de planilhas        ³
	//BEGIN REPORT QUERY oSectAgr
		BeginSQL Alias "QRYCXM"
			SELECT
				CXM.CXM_CONTRA,
				CXM.CXM_REVISA,
				CXM.CXM_NUMERO,
				CXM.CXM_ITEMID,
				CXM.CXM_AGRTIP,
				CXM.CXM_AGRGRP,
				CXM.CXM_AGRCAT,
				CXM.CXM_VLMAX,
				CXM.CXM_VLMED
			FROM
				%Table:CXM% CXM
			WHERE
				CXM.CXM_FILIAL = %xFilial:CXM%
				AND CXM.CXM_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CXM.CXM_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CXM.CXM_NUMERO = %EXP:QRYCNA->CNA_NUMERO%
				AND CXM.%NotDel%
			ORDER BY
				CXM.CXM_CONTRA,
				CXM.CXM_REVISA,
				CXM.CXM_NUMERO,
				CXM.CXM_ITEMID
		EndSQL
	//END REPORT QUERY oSectAgr

Return (NIL)

/*/{Protheus.doc} BR010Cro
Configura sessao dos cronogramas
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectCro, object,  Sessao dos cronogramas - TRSection
@return character, sem retorno
/*/
Static Function BR010Cro(oSectCro)

	// Gera query de filtro dos cronogramas
	//BEGIN REPORT QUERY oSectCro
		BeginSQL Alias "QRYCNF"
			SELECT
				CNF.*
			FROM
				%Table:CNF% CNF
			WHERE
				CNF.CNF_FILIAL = %xFilial:CNF%
				AND CNF.CNF_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CNF.CNF_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNF.CNF_NUMERO = %EXP:QRYCNA->CNA_CRONOG%
				AND CNF.%NotDel%
			ORDER BY
				CNF.CNF_CONTRA,
				CNF.CNF_REVISA,
				CNF.CNF_NUMERO,
				CNF.CNF_PARCEL
		EndSQL
	//END REPORT QUERY oSectCro

Return (NIL)

/*/{Protheus.doc} BR010Cac
Configura sessao das caucoes
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectCac, object, Sessao das caucoes  - TRSection
@return Character, sem retorno
/*/
Static Function BR010Cac(oSectCac)
A:=1
	// Gera query de filtro das caucoes
	//BEGIN REPORT QUERY oSectCac
		BeginSQL Alias "QRYCN8"
			SELECT
				CN8.CN8_CODIGO,
				CN8.CN8_FORNEC,
				CN8.CN8_LOJA,
				CN8.CN8_NUMDOC,
				CN8.CN8_DTINVI,
				CN8.CN8_DTFIVI,
				CN8.CN8_VLEFET,
				CN8.CN8_EMITEN,
				CN8.CN8_MOEDA
			FROM
				%Table:CN8% CN8
			WHERE
				CN8.CN8_FILIAL = %xFilial:CN8%
				AND CN8.CN8_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CN8.CN8_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CN8.%NotDel%
			ORDER BY
				CN8.CN8_CONTRA,
				CN8.CN8_REVISA,
				CN8.CN8_CODIGO
		EndSQL
	//END REPORT QUERY oSectCac

Return (NIL)

/*/{Protheus.doc} BR010Frn
Configura sessao dos fornecedores de contratos
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectFrn, object, Sessao dos fornecedores
@return character, sem retorno
/*/
Static Function BR010Frn(oSectFrn)

	// Gera query de filtro dos fornecedores
	//BEGIN REPORT QUERY oSectFrn
		BeginSQL Alias "QRYCNC"
			SELECT
				CNC.CNC_NUMERO,
				CNC.CNC_REVISA,
				CNC.CNC_CODIGO,
				CNC.CNC_LOJA
			FROM
				%Table:CNC% CNC
			WHERE
				CNC.CNC_FILIAL = %xFilial:CNC%
				AND CNC.CNC_NUMERO = %EXP:QRYCN9->CN9_NUMERO%
				AND CNC.CNC_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNC.%NotDel%
			ORDER BY
				CNC.CNC_NUMERO,
				CNC.CNC_REVISA,
				CNC.CNC_CODIGO,
				CNC.CNC_LOJA
		EndSQL
	//END REPORT QUERY oSectFrn

	// Configura posicionamento das tabelas filhas
	TRPosition():New(oSectFrn,"SA2",1,"xFilial('SA2')+QRYCNC->(CNC_CODIGO+CNC_LOJA)")//Fornecedores

Return

/*/{Protheus.doc} BR010Cli
Configura sessao do cliente do contrato
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectCli, object,  Sessao dos clientes
@return character, sem retorno
/*/
Static Function BR010Cli(oSectCli)

	// Gera query de filtro dos clientes
//	BEGIN REPORT QUERY oSectCli

		BeginSQL Alias "QRYCLI"
			SELECT
				CNC.CNC_NUMERO,
				CNC.CNC_REVISA,
				CNC.CNC_CLIENT,
				CNC.CNC_LOJACL
			FROM
				%Table:CNC% CNC
			WHERE
				CNC.CNC_FILIAL = %xFilial:CNC%
				AND CNC.CNC_NUMERO = %EXP:QRYCN9->CN9_NUMERO%
				AND CNC.CNC_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNC.%NotDel%
			ORDER BY
				CNC_NUMERO,
				CNC_REVISA,
				CNC_CLIENT,
				CNC_LOJACL
		EndSQL
//	END REPORT QUERY oSectCli

	// Configura posicionamento das tabelas filhas
	TRPosition():New(oSectCli,"SA1",1,"xFilial('SA1')+QRYCLI->(CNC_CLIENT+CNC_LOJACL)")//Cliente

Return (NIL)

/*/{Protheus.doc} BR010Mul
Configura sessao das multas de contratos
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectMul, object, Sessao dos multas
@return character,sem retorno
/*/
Static Function BR010Mul(oSectMul)

	// Gera query de filtro das multas
//	BEGIN REPORT QUERY oSectMul
		BeginSQL Alias "QRYCNH"
			SELECT
				CNH.*
			FROM
				%Table:CNH% CNH
			WHERE
				CNH_FILIAL = %xFilial:CNH%
				AND CNH.CNH_NUMERO = %EXP:QRYCN9->CN9_NUMERO%
				AND CNH.CNH_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNH.%NotDel%
			ORDER BY
				CNH_NUMERO,
				CNH_CODIGO
		EndSQL
//	END REPORT QUERY oSectMul

	// Configura posicionamento das tabelas filhas
	TRPosition():New(oSectMul,"CN4",1,"xFilial() + QRYCNH->CNH_CODIGO")//Tipos de Multas

Return (NIL)

/*/{Protheus.doc} BR010Med
Configura sessao dos cabecalhos de medicao
@type function Relatorio
@version  1.0
@author marioantonaccio
@since 02/03/2026
@param oSectMed, object, Sessao do cabecalho de medicao
@return character, sem retorno
/*/
Static Function BR010Med(oSectMed)
 
	// Gera query de filtro das medicoes
	//BEGIN REPORT QUERY oSectMed
		BeginSQL Alias "QRYCND"
			SELECT
				CND.CND_FILIAL,
				CND.CND_NUMMED,
				CND.CND_NUMERO,
				CND.CND_CONTRA,
				CND.CND_REVISA,
				CND.CND_FORNEC,
				CND.CND_LJFORN,
				CND.CND_COMPET,
				CND.CND_DTVENC,
				CND.CND_VLMEAC,
				CND.CND_VLSALD,
				CND.CND_VLTOT
			FROM
				%Table:CND% CND
			WHERE
				CND.CND_FILCTR = %EXP:QRYCN9->CN9_FILCTR%
				AND CND.CND_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CND.CND_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CND.%NotDel%
			ORDER BY
				CND.CND_CONTRA,
				CND.CND_REVISA,
				CND.CND_NUMMED
		EndSQL
	//END REPORT QUERY oSectMed

Return (NIL)

/*/{Protheus.doc} BR010IMe
Configura sessao dos itens de medicoes
@type function Relatorio
@version  1.0
@author marioantonaccio
@since 02/03/2026
@param oSectIMe, object, Sessao dos itens de medicoes
@return Character, sem retonro
/*/
Static Function BR010IMe(oSectIMe)

	// Gera query de filtro dos itens de medicoes
	//BEGIN REPORT QUERY oSectIMe
		BeginSQL Alias "QRYCNE"
			SELECT
				CNE.CNE_ITEM,
				CNE.CNE_CONTRA,
				CNE.CNE_REVISA,
				CNE.CNE_NUMMED,
				CNE.CNE_PRODUT,
				CNE.CNE_QTDSOL,
				CNE.CNE_QTAMED,
				CNE.CNE_QUANT,
				CNE.CNE_PERC,
				CNE.CNE_VLUNIT,
				CNE.CNE_VLTOT
			FROM
				%Table:CNE% CNE
			WHERE
				CNE.CNE_FILIAL = %EXP:QRYCND->CND_FILIAL%
				AND CNE.CNE_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CNE.CNE_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNE.CNE_NUMMED = %EXP:QRYCND->CND_NUMMED%
				AND CNE.%NotDel%
			ORDER BY
				CNE_CONTRA,
				CNE_REVISA,
				CNE_NUMMED,
				CNE_ITEM
		EndSQL
		A:=1
	//END REPORT QUERY oSectIMe

Return (NIL)

/*/{Protheus.doc} BR010Ctb
Configura sessao dos cronogramas contabeis
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectCtb, object, Sessao dos cronogramas contabeis
@return character, sem retorno
/*/
Static Function BR010Ctb(oSectCtb)

	// Gera query de filtro dos cronogramas
//	BEGIN REPORT QUERY oSectCtb
		BeginSQL Alias "QRYCNW"
			SELECT
				CNW.*
			FROM
				%Table:CNW% CNW
			WHERE
				CNW.CNW_FILIAL = %xFilial:CNW%
				AND CNW.CNW_CONTRA = %EXP:QRYCN9->CN9_NUMERO%
				AND CNW.CNW_REVISA = %EXP:QRYCN9->CN9_REVISA%
				AND CNW.CNW_NUMERO = %EXP:QRYCNA->CNA_CRONCT%
				AND CNW.%NotDel%
			ORDER BY
				CNW.CNW_CONTRA,
				CNW.CNW_REVISA,
				CNW.CNW_NUMERO,
				CNW.CNW_PARCEL
		EndSQL
//	END REPORT QUERY oSectCtb

Return (NIL)

/*/{Protheus.doc} BR010Bon
Configura sessao de multas/bonificacoes de medicoes
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param oSectBon, object, Sessao de multas/bonific de medicoes
@return character, sem retorno
/*/
Static Function BR010Bon(oSectBon)

	// Gera query de filtro das bonificacoes de medicoes
	//BEGIN REPORT QUERY oSectBon
		BeginSQL Alias "QRYCNR"
			SELECT
				CNR.CNR_NUMMED,
				CNR.CNR_TIPO,
				CNR.CNR_DESCRI,
				CNR.CNR_VALOR
			FROM
				%Table:CNR% CNR
			WHERE
				CNR.CNR_FILIAL = %EXP:QRYCND->CND_FILIAL%
				AND CNR.CNR_NUMMED = %EXP:QRYCND->CND_NUMMED%
				AND CNR.%NotDel%
			ORDER BY
				CNR.CNR_NUMMED,
				CNR.CNR_TIPO
		EndSQL
	//END REPORT QUERY oSectBon

Return (NIL)

/*/{Protheus.doc} BR010Des
Configura sessao dos descontos de medicoes
@type function Relatorio
@version 1.0
@author marioantonaccio
@since 02/03/2026
@param oSectDes, object, parSessao de descontos de medicoes
@return character, sem retorno
/*/
Static Function BR010Des(oSectDes)

	// Gera query de filtro dos descontos de medicoes
//	BEGIN REPORT QUERY oSectDes
		BeginSQL Alias "QRYCNQ"
			SELECT
				CNQ.CNQ_NUMMED,
				CNQ.CNQ_TPDESC,
				CNQ.CNQ_VALOR,
				CNP.CNP_DESCRI
			FROM
				%Table:CNQ% CNQ
			JOIN %Table:CNP% CNP
			ON CNP.CNP_FILIAL = %xFilial:CNP%
				AND CNP.%NotDel%
				AND CNP.CNP_CODIGO = CNQ.CNQ_TPDESC
			WHERE
				CNQ.CNQ_FILIAL = %EXP:QRYCND->CND_FILIAL%
				AND CNQ.CNQ_NUMMED = %EXP:QRYCND->CND_NUMMED%
				AND CNQ.%NotDel%
			ORDER BY
				CNQ.CNQ_NUMMED,
				CNQ.CNQ_TPDESC
		EndSQL
//	END REPORT QUERY oSectDes

Return (NIL)

/*/{Protheus.doc} B010xMoeda
 Realiza a conversao entre moedas de um determinado valor
@type function rELATORIO
@version 1.0
@author marioantonaccio
@since 02/03/2026
@param cContra, character,numero do contrato que esta sendo impresso.
@param cRev, character,revisao do contrato que esta sendo impresso.
@param cCampo,character,  nome do campo a ser convertido.
@return numeric, valor apos conversao
/*/
Static Function B010xMoeda(cContra,cRev,cCampo)
	Local dDataRef  := mv_par15
	Local nMoedaOri	:= 0
	Local nMoedaDes := 0
	Local nRet 		:= 0

	If Empty(dDataRef)
		dDataRef := dDataBase
	EndIf
	nMoedaOri := If(Substr(cCampo,1,3) == "CN8",CN8_MOEDA,Posicione("CN9",1,xFilial("CN9")+cContra+cRev,"CN9_MOEDA"))
	nMoedaDes := nMoedaOri
	nRet	  := &(cCampo)

	If mv_par13 == 2
		nMoedaDes := mv_par14
	EndIf

	nRet := Round(xMoeda(nRet,nMoedaOri,nMoedaDes,dDataRef,6),TamSX3(cCampo)[2])

Return nRet

/*/{Protheus.doc} B010GtMemo
Função para retornar Memo da SCR
@type function Processamento
@version  1.00
@author marioantonaccio
@since 02/03/2026
@param nRecno, numeric, Numero regisro na SCR
@return character, texto da OBS na SCR
/*/
Static Function B010GtMemo(nRecno)
	Local aAreaSCR:= SCR->(GetArea())
	Local cRet 	:= ""
	SCR->(MsGoto(nRecno))
	cRet := AllTrim(SCR->CR_OBS)
	RestArea(aAreaSCR)
Return cRet

