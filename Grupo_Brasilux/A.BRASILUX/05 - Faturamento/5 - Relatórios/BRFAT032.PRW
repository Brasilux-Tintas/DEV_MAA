#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

#Include "rwmake.ch"
#Include "TOPCONN.CH"

/*/
    {Protheus.doc} BRFAT032
    Rel Tabela de PRecos
    @type  User Function
    @author Cleber Orati Domingues
    @since 27/01/2002
    @version P12 12.1.25
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    	(examples)
    @see (links_or_references)
    @table ZGU
    @history
		Ticket: #018060 - 16/09/2020 - Ajuste duplicidade de linha (Andre Fracassi)
    @obs
    @menu
/*/
User Function BRFAT032()

	Private mv_par01
	Private mv_par02
	Private mv_par03
	Private oTempTbl01

	mv_par03 = 1

	if !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!----> " + funname(), "Atenção", "Alert")
		return
	endif

	SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
	SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
	SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
	SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
	SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
	SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
	SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

	CbTxt    :=""
	CbCont   :=0
	nOrdem   :=0
	Alfa     :=0
	Z        :=0
	M        :=0
	tamanho  :="M"
	limite   :=136
	titulo   :="TABELA DE PRECOS"
	cDesc1   :=PADC("Este programa ira emitir a Tabela de Precos",74)
	cDesc2   :=""
	cDesc3   :=PADC(" ",74)
	cCabec   :=PADC("Tabela de Precos",27)
	cCabPro  :=""
	cNatureza:=""
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog :="BRFAT032"
	cPerg    :="BRFT32"
	nLastKey := 0
	lContinua:=.T.
	wnrel    := "BRFAT032"
	nTipo    := 15
	m_pag    := 01
	cCabec1  :="CODIGO        NOME DO PRODUTO                CATALISADOR"
	cCabec2  :=""
	cCabec3  :=""
	nTamNf   :=83     // Apenas Informativo
	cString  :="SB1"

	ValidPerg()
	Pergunte("BRFT32",.F.)

	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,,Tamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	#IFDEF WINDOWS
		RptStatus({|| RptDetail()})
	#ENDIF
Return



Static Function RptDetail()

	Local  cCond,cAux

	@ 0, 001 PSAY Chr(15)                  // Compressao de Impressao

	dbSelectArea("SZ5")
	dbsetorder(1)

	cCond = ""
	If mv_par03 == 1
		cCond = " AND B.B1_ESTOQUE = 'S' "
	Else

	Endif

	ImprCols := {} // Vetor c/ Nros das Colunas a IMprimir
	AADD(ImprCols,68)
	AADD(ImprCols,78)
	AADD(ImprCols,88)
	AADD(ImprCols,98)
	AADD(ImprCols,108)

	cQuery := " SELECT DISTINCT "
	cQuery += " 	SZ1.Z1_LINHA AS LINHA,SUBSTRING(B.B1_COD,6,2) AS COR,"
	cQuery += "		SZ1.Z1_DESCR, SUBSTRING(B.B1_COD,1,10) AS B1_COD, LTRIM(B.B1_DESC) AS DESCR,"

	//Ticket : #018060
	//cQuery += "		B.B1_CATALIS,B.B1_RELCAT1 AS RELCAT,B1_ESTOQUE "
	cQuery += "		B.B1_CATALIS,B.B1_RELCAT1 AS RELCAT "

	cQuery += " FROM " + RetSqlName("SB1") + " B WITH (NOLOCK) "
	cQuery += "       LEFT OUTER JOIN " + RetSqlName("SZ1") + " SZ1 WITH (NOLOCK) ON "
	cQuery += "       		SZ1.D_E_L_E_T_          = ' ' "
	cQuery += "         AND Z1_FILIAL               = '" + xFilial("SZ1") + "' "
	cQuery += "         AND SUBSTRING(B.B1_COD,4,2) = SZ1.Z1_LINHA "
	cQuery += " WHERE "
	cQuery += "     B.B1_FILIAL              = '" + xFilial("SB1") + "' "
	cQuery += " AND LEN(B1_COD)              = 12 "
	cQuery += " AND SUBSTRING(B1_COD,11,2)  != '00' "
	cQuery += " AND SUBSTRING(B1_COD,11,2)  != '99' "
	cQuery += " AND SUBSTRING(B.B1_COD,4,2) >= '" + mv_par01 + "' "
	cQuery += " AND SUBSTRING(B.B1_COD,4,2) <= '" + mv_par02 + "' "
	cQuery += " AND B.B1_VEND               != 'N' "
	cQuery += " AND B.B1_MSBLQL             != '1' "
	cQuery += " AND B.D_E_L_E_T_             = ' ' "

	if !Empty( cCond )
		cQuery += cCond
	endif

	//Ticket : #018060
	cQuery += " GROUP BY "
	cQuery += " 	SZ1.Z1_LINHA, "
	cQuery += " 	SUBSTRING(B.B1_COD,6,2), "
	cQuery += " 	SZ1.Z1_DESCR, "
	cQuery += " 	SUBSTRING(B.B1_COD,1,10), "
	cQuery += " 	LTRIM(B.B1_DESC), "
	cQuery += " 	B.B1_CATALIS, "
	cQuery += " 	B.B1_RELCAT1 "

	cQuery += " ORDER BY LINHA,DESCR,COR,B1_COD "

	//TCQuery Abre uma workarea com o resultado da query
	TCQUERY cQuery NEW ALIAS "TMP"
	dbSelectArea("TMP")
	dbgotop()

	SetRegua(Reccount())

	iNroLin = 9
	nNroPag = 0

	Cabecalho()
	GeraCols()
	cabecalho2()
	LinhaProd()

	cTipo = TMP->LINHA

	dbselectarea("SB1")
	dbsetorder(1)
	dbSelectArea("TMP")
	dbgotop()

	SetRegua(Reccount())

	While ! EoF()
		If iNroLin >= 58
			iNroLin = iNroLin+1
			@iNroLin,00 psay replicate("=",136)
			Cabecalho()
			Cabecalho2()
		Endif
		ImprReg()

		dbselectarea("TMP")
		if !eof() .AND. (cTipo != TMP->LINHA)

			cTipo := TMP->LINHA
			iNroLin = iNroLin+1
			@iNroLin,00 psay replicate("=",136)
			if iNroLin >= 53
				cabecalho()
			endif
			Cabecalho2()
			LinhaProd()
		endif

		dbSelectArea("TMP")
		IncRegua()

	End

	iNroLin = iNroLin+1
	@iNroLin,00 psay replicate("=",136)

	If SELECT("TMP") > 0
		TMP->(DbcloseArea())
	Endif

	If SELECT("TMPC") > 0
		TMPC->(DbcloseArea())
	Endif

	dbSelectArea("SB1")
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

Return



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa: VALIDPERG   Autor:  Fernando Roquete
Data:     05/06/01
Descricao:Grava Perguntas
/*/

Static Function ValidPerg()
	Local _sAlias := Alias()
	Local i, j

	dbSelectArea("SX1")
	dbSetOrder(1)

	cPerg := PADR(cPerg,10)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Linha de ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SZ1",""})
	AADD(aRegs,{cPerg,"02","Linha ate' ?","","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SZ1",""})
	AADD(aRegs,{cPerg,"03","Apenas Prod Estoque?","","","mv_ch3" ,"C",03,0,0,"C","","mv_par03","SIM"   ,"","","","","NAO"  ,"","","","","","","","","","","","","","","","","","","",""})
	// AADD(aRegs,{cPerg,"04","Qual Tabela?","","","mv_ch4" ,"C",03,0,0,"C","","mv_par04","TAB 1","","","","","TAB 2"  ,"","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return



static function LinhaProd()
	cAux = rtrim(TMP->Z1_DESCR)
	iNroLin = iNroLin+1
	@iNroLin,64-(len(cAux)/2) psay cAux
	iNroLin = iNroLin+1
	@iNroLin,00 psay replicate("=",136)
return


static function ImprReg()

	Local _cFilial,cPreco,cAux,nCont,cLinha

	iNroLin = iNroLin+1
	@iNroLin,00  psay SUBSTR(TMP->B1_COD,1,10) picture "@R XXX99.99.999"
	@iNroLin,14  psay rtrim(SUBSTR(TMP->DESCR,1,30))
	@iNroLin,45  psay SUBSTR(TMP->B1_CATALIS,1,10)

	cAux = rtrim(iif(!EMPTY(TMP->RELCAT),"("+rtrim(TMP->RELCAT)+")",""))
	cAux = ltrim(cAux)
	@iNroLin,55  psay substr(cAux,1,12)

	cProd = SUBSTR(TMP->B1_COD,1,10)
	cLinha = substr(cProd,4,2)
	dbselectarea("TMP")
	dbselectarea("SB1")
	_cFilial = alltrim(xFilial("SB1"))
	dbseek(_cFilial+TMP->B1_COD)
	if !eof() .AND. (SB1->B1_FILIAL = _cFilial) .AND. (SUBSTR(SB1->B1_COD,1,10) == cProd) .and. ((SUBSTR(SB1->B1_COD,11,2) == '00') .OR. (SUBSTR(SB1->B1_COD,11,2) == '99'))
		dbskip()
	endif
	while !eof() .AND. (_cFilial = SB1->B1_FILIAL) .AND. (SUBSTR(SB1->B1_COD,1,10) == cProd)

		dbselectarea("TMPC")
		locate for TMPC->LINHA == cLinha
		nCont = 0
		while !eof() .AND. (TMPC->LINHA == cLinha) .AND. (nCont < 5)
			nCont = nCont+1
			if (substr(SB1->B1_COD,11,2) == TMPC->EMBA) .and. (SB1->B1_VEND <> 'N')
				//Det. de qual preço a imprimir
				cPreco = ""
				if (SB1->B1_ESTOQUE == 'S')
					cPreco = "*"+alltrim(transform(SB1->B1_PRV1,"@E 999999.99"))
				else
					dbselectarea("SB5")
					dbseek(xFilial("SB5")+SB1->B1_COD)
					if found()
						cPreco := alltrim(transform(SB5->B5_PRV2,"@E 999999.99"))
					endif
				endif
				cAux = space(9-len(cPreco))+cPreco
				@iNroLin,ImprCols[nCont] psay cAux
			endif
			dbselectarea("TMPC")
			dbskip()
		end
		dbselectarea("SB1")
		dbskip()
	end
	dbselectarea('TMP')
	dbskip()
RETURN



Static Function Cabecalho()
	nNroPag = nNroPag+1

	cNroPag = rtrim(str(nNroPag,3))
	cNroPag = replicate("0",3-len(cNroPag))+cNroPag

	iNroLin = 1
	@iNroLin,25 psay replicate("-",80)
	iNroLin = iNroLin+1
	@iNroLin,25 psay "T A B E L A    D E    P R E C O S  (* -> Prod. ESTOQUE)"
	@iNroLin,85 psay "EXPEDICAO : "+DTOC(DATE())
	iNroLin = iNroLin+1
	@iNroLin,25 psay ALLTRIM(SM0->M0_NOMECOM)
	@iNroLin,85 psay "PAGINA....: "
	@iNroLin,102 psay cNroPag
	iNroLin = iNroLin+1
	@iNroLin,25 psay replicate("-",80)
	iNroLin = iNroLin+1
	@iNroLin,00 psay replicate("=",136)

//iNroLin = 9

RETURN

static function cabecalho2()

	cLinha = SUBSTR(TMP->B1_COD,4,2)
	dbSelectArea("TMPC")
	locate for LINHA == cLinha
	//dbseek(cLinha)
	nContEmba = 0
	while !EOF() .AND. (TMPC->LINHA == cLinha) .AND. (nContEmba < 5)
		nContEmba++
		cAux = "cEmba"+str(nContEmba,1)
		&cAux = space(9)
		dbSelectArea("SZ5")
		dbSeek(xFilial("SZ5")+TMPC->EMBA)
		if found()
			&cAux = rtrim(substr(SZ5->Z5_DESCR,1,9))
		endif
		dbselectarea("TMPC")
		dbskip()
	End

	iNroLin = iNroLin+1
	@iNroLin,00 psay "CODIGO"
	@iNroLin,14 PSAY "NOME DO PRODUTO"
	@iNroLin,45 psay "CATAL."
	if nContEmba >= 1
		@iNroLin,ImprCols[1] psay space(9-len(cEmba1))+cEmba1
	endif
	if nContEmba >= 2
		@iNroLin,ImprCols[2] psay space(9-len(cEmba2))+cEmba2
	endif
	if nContEmba >= 3
		@iNroLin,ImprCols[3] psay space(9-len(cEmba3))+cEmba3
	endif
	if nContEmba >= 4
		@iNroLin,ImprCols[4] psay space(9-len(cEmba4))+cEmba4
	endif
	if nContEmba >= 5
		@iNroLin,ImprCols[5] psay space(9-len(cEmba5))+cEmba5
	endif
	// @prow(),127 say "Ref."
	iNroLin = iNroLin+1
	@iNroLin,00 psay replicate("=",136)



return


Static Function GeraCols()

	Local _aCampos, cCond

	cQuery := " SELECT "
	cQuery += " 	SUBSTRING(B1_COD,4,2) AS LINHA, SUBSTRING(B1_COD,11,2) AS EMBA "
	cQuery += " FROM " + RetSqlName("SB1") + " A WITH (NOLOCK) "
	cQuery += " WHERE "
	cQuery += " 	A.B1_FILIAL   = '"+xFilial("SB1")+"' "
	cQuery += " AND A.D_E_L_E_T_  = ' ' "
	cQuery += " AND A.B1_VEND    != 'N' "
	cQuery += " AND A.B1_MSBLQL  != '1' "
	cQuery += " AND SUBSTRING(B1_COD,11,2) != '00' "
	cQuery += " AND SUBSTRING(B1_COD,11,2) != '99' "

	IIf( mv_par03 == 1," AND A.B1_ESTOQUE   = 'S' ","")

	cQuery += " GROUP BY SUBSTRING(B1_COD,4,2), SUBSTRING(B1_COD,11,2) "
	cQuery += " ORDER BY SUBSTRING(B1_COD,4,2), SUBSTRING(B1_COD,11,2) "

	TCQUERY cQuery NEW ALIAS "TMPC"
	DbSelectArea("TMPC")
	DbGoTop()

Return
