#INCLUDE 'Protheus.ch'
#include "topconn.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include 'DIRECTRY.CH' 
#include "TbiConn.ch"
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
        ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
        ฑฑบPrograma  ณ TCPCP001 บAutor  ณ Cleber Oratiบ Data ณ  26/07/21         บฑฑ
        ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
        ฑฑบDesc.     ณ Fun็ใo para Desmontar Kits Coca Cola (Recofarma) ap๓s 	  บฑฑ
        ฑฑบ          ณ entrada da nota fiscal dos mesmos                         บฑฑ
        ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
        ฑฑบUso       ณ TECPOLPA                                                   บฑฑ
        ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
        ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
        ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function TCPCP001()
private oDlg1
private cCodBar := SPACE(44)

if !(cNumEmp == "1111") // "0106"
		MsgBox("Esta opera็ใo s๓ pode ser executada na TecPolpa!", "Aten็ใo!", "STOP")
		return NIL 
endif 

     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Desmontagem Kits Coca Cola"

     //@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
     @ 15,016 SAY "Desmontagem Kits RECOFARMA - Informe a chave se quiser REPROCESSAR!"
 	 @ 30,016 Say OemToAnsi("Chave NFE(Bco = TODOS)") Size 040,040
	 @ 30,065 Get cCodBar  Picture "@!S80"  Size 150,030 // Valid AchaFile(@cArquivo)
     @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| Desmonta(cCodBar)} )
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 08,10 TO 84,222
     ACTIVATE DIALOG oDlg1 CENTERED
return 
Static Function Desmonta(cCodBar)
Local lSucesso,cQuery,cChvnfe 

if !empty(alltrim(cCodBar)) .and. (len(alltrim(cCodBar)) != 44)
	MsgAlert("Chave Invแlida!")
	return nil 
endif 
lSucesso := U_VKitsSA5() //Verificar se cadastro de cabe็alho dos Kits estใo OK
if !lSucesso
	return NIL
endif 

if Select("KITS")<>0		
	dbselectarea("KITS")
	dbclosearea()
endif 

	if (GETMV("ZP_PAR0052") == .F.)
		cQuery = "SELECT CODIGO,SEQ,COMPON,QTDE,PAI,QTDEFILHO FROM KITSCOCA ORDER BY COMPON,CODIGO,PAI "
	else
		cQuery = "SELECT ZA7_CODIGO AS CODIGO,ZA7_SEQ AS SEQ,ZA7_COMPON AS COMPON,ZA7_QTD AS QTDE,ZA7_PAI AS PAI,ZA7_QTDFIL AS QTDEFILHO FROM ZA7110 ORDER BY COMPON,CODIGO,PAI "
	endif	
TCQuery cQuery ALIAS "KITS" NEW


if Select("TMPNFS")<>0		
	dbselectarea("TMPNFS")
	dbclosearea()
endif 
/*
cQuery := "WITH TMP AS (SELECT DISTINCT ZZD_CHVNFE AS CHVNFE FROM "+RetSqlName("ZZD")+" WHERE (D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND (ZZD_PROCES = 'S')) "+;
"SELECT DISTINCT ZZD_CHVNFE AS CHVNFE FROM "+RetSqlName("ZZD")+" ZZD "+;
"WHERE (ZZD.D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND (ZZD_CHVNFE NOT IN (SELECT CHVNFE FROM TMP))"
*/
cQuery := "SELECT DISTINCT ZZD_CHVNFE AS CHVNFE FROM "+RetSqlName("ZZD")+" ZZD WITH (NOLOCK) "+;
"WHERE (ZZD.D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') "+;
iif(!empty(alltrim(cCodBar)),"AND (ZZD_CHVNFE = '"+alltrim(cCodBar)+"') ","AND (ZZD_PROCES <> 'S') ")+;
"ORDER BY CHVNFE "

TCQuery cQuery ALIAS "TMPNFS" NEW
dbselectarea("TMPNFS")
dbgotop()
do while lSucesso .and. !eof()
	cChvnfe := TMPNFS->CHVNFE
	dbselectarea("SF1")
	dbsetorder(8) //F1_FILIAL+F1_CHVNFE                                                                                                                                             
	MsSeek(xFilial("SF1")+cChvnfe)
	lSucesso := found()
	if lSucesso
		lSucesso := GrvValid(cChvnfe)
	endif 

	if lSucesso
		RptStatus({|| AbreKits()}, "Aguarde...", "Desmontando Kits Nf "+SF1->F1_DOC+"...")
	endif 

	dbselectarea("TMPNFS")
	dbskip()
enddo 
  
if Select("TMPNFS")<>0		
	dbselectarea("TMPNFS")
	dbclosearea()
endif 

if Select("KITS")<>0		
	dbselectarea("KITS")
	dbclosearea()
endif 
return nil  

Static Function AbreKits()
Local i,cAuxCod,nAuxQtde,lSucesso,cCodPrf,dValid,cValid,cLote,_cDoc,nTotal,cQuery,cCodFor,nQtdeOp
private lMsErroAuto := .f.

lSucesso := .t.
cCodFor := "00251101" //Exclusivo RECOFARMA!!
_cDoc := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
      
cQuery := "SELECT SUM(D1_QUANT) AS QTDE FROM "+RetSqlName("SD1")+" SD1 WHERE (D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_SERIE = '"+SF1->F1_SERIE+"') AND (D1_DOC = '"+SF1->F1_DOC+"') AND (D1_FORNECE = '"+SF1->F1_FORNECE+"') AND (D1_LOJA = '"+SF1->F1_LOJA+"') AND (D1_TIPO = 'N')"
//Executa a consulta
TCQuery cQuery New Alias "QRY_AUX"
      
//Conta quantos registros existem, e seta no tamanho da rรฉgua
nTotal := ceiling(QRY_AUX->QTDE)

dbselectarea('QRY_AUX')
dbclosearea()

cQuery := "SELECT COUNT(R_E_C_N_O_) AS QTDE FROM "+RetSqlName("ZZD")+" ZZD WHERE (D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND (ZZD_CHVNFE = '"+SF1->F1_CHVNFE+"')"
//Executa a consulta
TCQuery cQuery New Alias "QRY_AUX"

nTotal += QRY_AUX->QTDE
dbselectarea('QRY_AUX')
dbclosearea()

SetRegua(nTotal)
nQtdeOp := 0
dbselectarea("SD1")
dbsetorder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.t.)
do while lSucesso .and. !eof() .and. (SD1->D1_FILIAL == xFilial("SD1") .AND. (SD1->D1_DOC == SF1->F1_DOC) .AND. (SD1->D1_SERIE == SF1->F1_SERIE) .AND. (SD1->D1_FORNECE == SF1->F1_FORNECE) .AND. (SD1->D1_LOJA == SF1->F1_LOJA))
	dbselectarea("SA5")
	dbsetorder(2) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
	msseek(xFilial("SA5")+SD1->D1_COD+cCodFor) //Exclusivo RECOFARMA!!!
	IF !FOUND()
		MsgAlert("Nใo encontrado c๓diigo em SA5 de SD1! -> "+SD1->D1_COD)
	else 
		if EMPTY(ALLTRIM(SA5->A5_CODPRCA))  //A5_CODPRCA identifica o cabe็alho do Kit (produto pai) em SG1
			MsgAlert("A5_CODPRCA em Branco de SD1! -> "+SD1->D1_COD)
		else 
			if ( SG1->(dbSetOrder(2), dbSeek(xFilial("SG1")+SD1->D1_COD)) ) //Se for TecPolpa e o produto tiver estrutura, ler cod barra
				cAuxCod := PADR(ALLTRIM(SA5->A5_CODPRCA),TAMSX3("B1_COD")[1]," ") //Codigo do pai da estrutura do Kit
				dbselectarea("SG1")
				dbsetorder(1) //G1_FILIAL+G1_COD+G1_COMP+G1_TRT  
				nAuxQtde := ceiling(SD1->D1_QUANT)
				dbselectarea("SB1")
				dbsetorder(1)
				msseek(xFilial("SB1")+cAuxCod) //Codigo do pai da estrutura do Kit
				if found()
					nAuxQtde := ceiling(SD1->D1_QUANT) * iif(SB1->B1_QB >= 1,SB1->B1_QB,1)
				endif 

				dbselectarea("SG1")
				for i := 1 to nAuxQtde
					nQtdeOp++
					lSucesso := GeraOpKit(cAuxCod,_cDoc+alltrim(str(nQtdeOp)))
					IncRegua()
				next i
			else 
				MsgAlert("Produto nใo estแ na estrutura! (lendo SD1)! -> "+SD1->D1_COD)
			endif 
		endif 
	endif 
	dbselectarea("SD1")
	dbskip()
enddo 

//Gravar informa็๕es dos lotes extraidas das etiquetas bipadas e salvas em ZZD
dbselectarea("ZZD")
dbsetorder(1) //ZZD_FILIAL+ZZD_CHVNFE+ZZD_CODBAR                                                                                                                                
dbgotop()
MsSeek(xFilial("ZZD")+SF1->F1_CHVNFE,.T.)
do while lSucesso .and. !eof() .and. (ZZD->ZZD_FILIAL == xFilial("ZZD")) .AND. (ZZD->ZZD_CHVNFE == SF1->F1_CHVNFE)
	IF !(ZZD->ZZD_PROCES = "S")
		cValid := ""
		cLote := ""
		cAuxCod := alltrim(ZZD->ZZD_CODOK)
		if empty(cAuxCod)
			cAuxCod := alltrim(ZZD->ZZD_CODBAR)
		endif 
		cCodPrf := substr(cAuxCod,4,7)
		dbselectarea("SA5")
		DbOrderNickName("FORPROD")   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
		MsSeek(xFilial("SA5")+cCodFor+cCodPrf,.t.)
		if found()
			if len(cAuxCod) == 36
				cValid := substr(cAuxCod,29,2)+"/"+substr(cAuxCod,27,2)+"/"+substr(cAuxCod,25,2)
				dValid := ctod(cValid)
				cLote := substr(cAuxCod,13,10)
				Begin Transaction
				lSucesso := GeraLoteKit(SA5->A5_PRODUTO,_cDoc,cLote,dValid)
				if lSucesso
					dbselectarea("ZZD")
					reclock("ZZD",.F.)
					ZZD->ZZD_PROCES := "S"
					msunlock()
					IncRegua()
				endif 
				End Transaction
			endif 
		endif 
	ENDIF 
	dbselectarea("ZZD")
	dbskip()
enddo 



/*
dbselectarea("ZZD")
dbsetorder(1) //ZZD_FILIAL+ZZD_CHVNFE+ZZD_CODBAR                                                                                                                                
dbgotop()
MsSeek(xFilial("ZZD")+SF1->F1_CHVNFE,.T.)
do while lSucesso .and. !eof() .and. (ZZD->ZZD_FILIAL == xFilial("ZZD")) .AND. (ZZD->ZZD_CHVNFE == SF1->F1_CHVNFE)
	cAuxCod := alltrim(ZZD->ZZD_CODBAR)
	IF (ZZD->ZZD_PROCES <> "S") .AND. (LEN(cAuxCod) < 36)
		cCodPrf := substr(cAuxCod,4,7)
		dbselectarea("SA5")
		DbOrderNickName("FORPROD")   // FILIAL + FORNECEDOR + LOJA + CODIGO PRODUTO NO FORNECEDOR
		MsSeek(xFilial("SA5")+cCodFor+cCodPrf,.t.)
		if found()
			cCodPro := SA5->A5_PRODUTO
			if Select("TMPOP")<>0		
				dbselectarea("TMPOP")
				dbclosearea()
			endif 
			cQuery := "SELECT TOP 1 D4_OP AS OP,SD4.R_E_C_N_O_ AS REG FROM "+RetSqlName("SC2")+" SC2 "+;
			"LEFT OUTER JOIN  "+RetSqlName("SD4")+" SD4 ON (SD4.D_E_L_E_T_ <> '*') AND (D4_FILIAL = C2_FILIAL) AND (D4_OP = (C2_NUM+C2_ITEM+C2_SEQUEN)) "+;
			"LEFT OUTER JOIN  "+RetSqlName("SD3")+" SD3  ON (SD3.D_E_L_E_T_ <> '*') AND (D3_ESTORNO <> 'S') AND (D3_FILIAL = D4_FILIAL) AND (D3_OP = D4_OP) AND (D4_COD = D3_COD) "+;
			"WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (SD4.D4_QTDEORI < 0.0) AND (SD3.R_E_C_N_O_ IS NULL) AND (C2_OBS = '"+_cDoc+"') AND (D4_COD = '"+cCodPro+"')"
			TCQuery cQuery ALIAS "TMPOP" NEW

			dbselectarea("TMPOP")
			if !eof() .and. !bof()
				if Select("TMPV")<>0		
					dbselectarea("TMPV")
					dbclosearea()
				endif 
				cQuery := "SELECT TOP 1 D3_DTVALID FROM  "+RetSqlName("SC2")+" SC2 "+;
				"LEFT OUTER JOIN  "+RetSqlName("SD4")+" SD4 ON (SD4.D_E_L_E_T_ <> '*') AND (D4_FILIAL = C2_FILIAL) AND (D4_OP = (C2_NUM+C2_ITEM+C2_SEQUEN)) "+;
				"LEFT OUTER JOIN  "+RetSqlName("SD3")+" SD3  ON (SD3.D_E_L_E_T_ <> '*') AND (D3_ESTORNO <> 'S') AND (D3_FILIAL = D4_FILIAL) AND (D3_OP = D4_OP) AND (D4_COD = D3_COD) "+;
				"WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (SD4.D4_QTDEORI < 0.0) AND (SD3.R_E_C_N_O_ IS NOT NULL) AND (C2_OBS = '"+_cDoc+"') AND (D4_OP = '"+TMPOP->OP+"')"
				TCQuery cQuery ALIAS "TMPV" NEW
			
				dbselectarea("TMPV")
				if !eof() .and. !bof()
					cValid := substr(TMPV->D3_DTVALID,29,2)+"/"+substr(TMPV->D3_DTVALID,27,2)+"/"+substr(TMPV->D3_DTVALID,25,2)
					dValid := ctod(cValid)
					cLote := substr(cAuxCod,13,10)
					lSucesso := Gera2LoteKit(SA5->A5_PRODUTO,_cDoc,cLote,dValid,TMPOP->REG)
					if lSucesso
						dbselectarea("ZZD")
						reclock("ZZD",.F.)
						ZZD->ZZD_PROCES := "S"
						msunlock()
						IncRegua()
					endif 
				endif 
			endif 
		endif 
	ENDIF //FIM IF (ZZD->ZZD_PROCES <> "S") .AND. (LEN(cAuxCod) < 36)
	dbselectarea("ZZD")
	dbskip()
enddo 

*/

if Select("TMPOP")<>0		
	dbselectarea("TMPOP")
	dbclosearea()
endif 

cQuery := "SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO FROM "+RetSqlName("SC2")+" WHERE (D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_OBS LIKE '"+_cDoc+"%') AND (C2_DATRF = '')"
TCQuery cQuery ALIAS "TMPOP" NEW
dbselectarea("TMPOP")
dbgotop()
do while lSucesso .and. !eof()
	lSucesso := ProdKit(TMPOP->C2_NUM+TMPOP->C2_ITEM+TMPOP->C2_SEQUEN)
	dbselectarea("TMPOP")
	dbskip()
enddo 
if Select("TMPOP")<>0		
	dbselectarea("TMPOP")
	dbclosearea()
endif 

return nil 


Static Function GeraOpKit(cCodPro,_cObs)
Local lRet,lJaExiste
Local aMATA650      := {}       //-Array com os campos
Local nOpc := 3
Private lMsErroAuto,lMsHelpAuto
lRet := .t.

lJaExiste := .f.
if Select("TMPOP")<>0		
	dbselectarea("TMPOP")
	dbclosearea()
endif 

cQuery := "SELECT R_E_C_N_O_ AS REG FROM "+RetSqlName("SC2")+" WHERE (D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_OBS = '"+_cObs+"') "
TCQuery cQuery ALIAS "TMPOP" NEW
dbselectarea("TMPOP")
IF !EOF() .AND. !BOF()
	lJaExiste := .t.
ENDIF 
dbselectarea("TMPOP")
dbclosearea()

//รรรรรรรรรรรรรรรรรรรยฟ
//ยณ 3 - Inclusao     ยณ
//ยณ 4 - Alteracao    ยณ
//ยณ 5 - Exclusao     ยณ
//ร€รรรรรรรรรรรรรรรรรรร

if !lJaExiste
	aMata650  := {  {'C2_FILIAL'   ,xFilial("SC2")              ,NIL},;
					{'C2_PRODUTO'  ,cCodPro       ,NIL},;         
					{'C2_QUANT'  ,1       ,NIL},;         
					{'C2_ITEM'     ,"01"                    ,NIL},;         
					{'C2_SEQUEN'   ,"001"                   ,NIL},;            
					{'C2_DATPRI'   ,dDataBase                   ,NIL},;            
					{'C2_DATPRF'   ,dDataBase                   ,NIL},;            
					{'C2_XLOTE'   ,""                  ,NIL},;
					{ 'C2_OBS' ,_cObs ,NIL},;
						{'AUTEXPLODE' ,"S" ,NIL}}		
					

	lMsErroAuto := .f.  
	dbselectarea("SC2")
	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

	if lMsErroAuto
		lRet := .f.
		MostraErro()
	endif 
endif 

return(lRet)

Static Function	GeraLoteKit(cCodPro,_cObs,cLote,dValid)
local cQuery,lRet
Private lMsErroAuto,lMsHelpAuto
lMsErroAuto := .f.  
lRet := .t.

if Select("TMPSC2")<>0
	dbselectarea("TMPSC2")
	dbclosearea()
endif 
cQuery := "SELECT TOP 1 C2_NUM+C2_ITEM+C2_SEQUEN AS OP FROM "+RetSqlName("SC2")+" WHERE (D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_PRODUTO = '"+cCodPro+;
"') AND (C2_OBS LIKE '"+_cObs+"%') AND (C2_XLOTE = '')"
TCQuery cQuery ALIAS "TMPSC2" NEW
dbselectarea("TMPSC2")
if eof() .or. bof()
	_aIteMov := {}
	_aIteBai := {}
	dbclosearea()
	cQuery := "SELECT TOP 1 D4_OP,SD4.R_E_C_N_O_ AS REG FROM "+RetSqlName("SC2")+" SC2 "+;
	"LEFT OUTER JOIN "+RetSqlName("SD4")+" SD4 ON (SD4.D_E_L_E_T_ <> '*') AND (D4_FILIAL = C2_FILIAL) AND (D4_OP = (C2_NUM+C2_ITEM+C2_SEQUEN)) "+;
	"LEFT OUTER JOIN "+RetSqlName("SD3")+" SD3  ON (SD3.D_E_L_E_T_ <> '*') AND (D3_ESTORNO <> 'S') AND (D3_FILIAL = D4_FILIAL) AND (D3_OP = D4_OP) AND (D4_COD = D3_COD) "+;
	"WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (SD4.D4_QTDEORI < 0.0) AND (D4_COD = '"+cCodPro+"') AND (SD3.R_E_C_N_O_ IS NULL) AND (C2_OBS LIKE '"+_cObs+"%') "
	TCQuery cQuery ALIAS "TMPSC2" NEW
	dbselectarea("TMPSC2")
	if !eof() .AND. !bof()
		dbselectarea("SB1")
		dbsetorder(1)
		dbselectarea("SD4")
		dbsetorder(1)
		dbgoto(TMPSC2->REG)

		_aCabMov := { { "D3_TM"     , '002'    , NIL },;
              { "D3_EMISSAO", dDatabase, NIL },;
        	  { "D3_DOC"  , SubStr(_cObs,1,9 ) , NIL },;
        	  { "D3_OBS"  , _cObs , NIL }}
		IF SD4->D4_QUANT < 0
			dbselectarea("SB1")
			MsSeek(xFilial("SB1")+SD4->D4_COD)
            		_aIteMov := { { "D3_COD"  , SD4->D4_COD, NIL },;
                            { "D3_QUANT", ABS(SD4->D4_QUANT), NIL },;
                            { "D3_UM"   , SB1->B1_UM     , NIL },;
                            { "D3_LOCAL", SD4->D4_LOCAL , NIL },;
                            { "D3_TIPO" , SB1->B1_TIPO   , NIL },;
                            { "D3_OP"   , SD4->D4_OP , NIL },;
                            { "D3_TRT"  , SD4->D4_TRT   , NIL },;
                            { "D3_LOTECTL",cLote    , NIL },; 
                            { "D3_DTVALID", dValid   , NIL },; 
                            { "D3_OBS"  , _cObs    , NIL } }
                   aAdd( _aIteBai, _aIteMov )
					//Garante que existe o item no armazem na tabela SB2
                   DbSelectArea("SB2") 
                   SB2->( DbSetOrder( 1 ) )
                   If !SB2->( DbSeek( xFilial("SB2") + SD4->D4_COD + SD4->D4_LOCAL ) )
                      CriaSB2( SD4->D4_COD, SD4->D4_LOCAL )
                   Endif
		ENDIF 						 
  
		If Len( _aIteBai ) > 0
			MSExecAuto( { |x, y, z| MATA241( x, y, z ) }, _aCabMov, _aIteBai, 3 )
			if lMsErroAuto
				MostraErro()
				lRet := .f.
			endif 
		endif 
		dbselectarea("TMPSC2")
		dbclosearea()
	endif
else //Se for a Ordem de Produ็ใo grava o lote/validade diretamente em SC2
	
	dbselectarea("SC2")
	dbsetorder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD                                                                                                                   
	MsSeek(xFilial("SC2")+TMPSC2->OP,.t.)
	if found()
		reclock("SC2",.F.)
		SC2->C2_XLOTE := cLote
		SC2->C2_DATPRF := dValid
		msunlock()
	endif 
	dbselectarea("TMPSC2")
	dbclosearea()
endif 

return(lRet)

//************

Static Function	Gera2LoteKit(cCodPro,_cObs,cLote,dValid,nReg)
local lRet,_aIteMov,_aIteBai
Private lMsErroAuto,lMsHelpAuto
lMsErroAuto := .f.  
lRet := .t.
	_aIteMov := {}
	_aIteBai := {}

if Select("TMPSC2")<>0
	dbselectarea("TMPSC2")
	dbclosearea()
endif 
dbselectarea("SD4")
dbsetorder(1)
dbgoto(nReg)
if !eof() .AND. !bof()
		dbselectarea("SB1")
		dbsetorder(1)

		_aCabMov := { { "D3_TM"     , '002'    , NIL },;
              { "D3_EMISSAO", dDatabase, NIL },;
        	  { "D3_DOC"  , SubStr(_cObs,1,9 ) , NIL },;
        	  { "D3_OBS"  , _cObs , NIL }}
		dbselectarea("SD4")
		IF SD4->D4_QUANT < 0
			dbselectarea("SB1")
			dbsetorder(1)
			MsSeek(xFilial("SB1")+SD4->D4_COD)
            		_aIteMov := { { "D3_COD"  , SD4->D4_COD, NIL },;
                            { "D3_QUANT", ABS(SD4->D4_QUANT), NIL },;
                            { "D3_UM"   , SB1->B1_UM     , NIL },;
                            { "D3_LOCAL", SD4->D4_LOCAL , NIL },;
                            { "D3_TIPO" , SB1->B1_TIPO   , NIL },;
                            { "D3_OP"   , SD4->D4_OP , NIL },;
                            { "D3_TRT"  , SD4->D4_TRT   , NIL },;
                            { "D3_LOTECTL",cLote    , NIL },; 
                            { "D3_DTVALID", dValid   , NIL },; 
                            { "D3_OBS"  , _cObs    , NIL } }
                   aAdd( _aIteBai, _aIteMov )
					//Garante que existe o item no armazem na tabela SB2
                   DbSelectArea("SB2") 
                   SB2->( DbSetOrder( 1 ) )
                   If !SB2->( DbSeek( xFilial("SB2") + SD4->D4_COD + SD4->D4_LOCAL ) )
                      CriaSB2( SD4->D4_COD, SD4->D4_LOCAL )
                   Endif

		ENDIF 						 
  
		If Len( _aIteBai ) > 0
			MSExecAuto( { |x, y, z| MATA241( x, y, z ) }, _aCabMov, _aIteBai, 3 )
			if lMsErroAuto
				MostraErro()
				lRet := .f.
			endif 
		endif 
endif
return(lRet)

//***********
Static Function ExtraiKit()
Local aMATA650      := {}       //-Array com os campos
Local _aIteMov := {}
Local _aIteBai      := {}
Local _aCabMov := {}
Local nOpc := 3
Private lMsErroAuto,lMsHelpAuto


//รรรรรรรรรรรรรรรรรรรยฟ
//ยณ 3 - Inclusao     ยณ
//ยณ 4 - Alteracao    ยณ
//ยณ 5 - Exclusao     ยณ
//ร€รรรรรรรรรรรรรรรรรรร
begin transaction
  
aMata650  := {  {'C2_FILIAL'   ,xFilial("SC2")              ,NIL},;
                {'C2_PRODUTO'  ,"1COCMMIXAX04"       ,NIL},;         
                {'C2_QUANT'  ,1       ,NIL},;         
  	           {'C2_ITEM'     ,"01"                    ,NIL},;         
                {'C2_SEQUEN'   ,"001"                   ,NIL},;            
                {'C2_DATPRI'   ,dDataBase                   ,NIL},;            
                {'C2_DATPRF'   ,dDataBase                   ,NIL},;            
                  {'C2_XLOTE'   ,"COC04"                   ,NIL},;
 				{'AUTEXPLODE' ,"S" ,NIL}}		
                  

lMsErroAuto := .f.  
      
msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
If !lMsErroAuto
	nOpc := 4
	cNroOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
	dbselectarea("SB1")
	dbsetorder(1)
    dbselectarea( "SD4" )
    dbsetorder( 2 )
    msseek( xFilial("SD4") + cNroOp ,.t. )
	nCont := 0
                //Baixa da Operaรงรฃo
	              _aCabMov := { { "D3_TM"     , '002'    , NIL },;
                              { "D3_EMISSAO", dDatabase, NIL },;
                              { "D3_DOC"  , SubStr( cNroOp , 1, 6 ) + '-' +ALLTRIM(SC2->C2_XLOTE) , NIL } }
	While !lMsErroAuto .and. !Eof() .AND. ( SD4->D4_FILIAL == xFilial("SD4") ) .AND. ( SD4->D4_OP = cNroOp ) 
		nCont++
		IF SD4->D4_QUANT < 0
			dbselectarea("SB1")
			MsSeek(xFilial("SB1")+SD4->D4_COD)
            		_aIteMov := { { "D3_COD"  , SD4->D4_COD, NIL },;
                            { "D3_QUANT", ABS(SD4->D4_QUANT), NIL },;
                            { "D3_UM"   , SB1->B1_UM     , NIL },;
                            { "D3_LOCAL", SD4->D4_LOCAL , NIL },;
                            { "D3_TIPO" , SB1->B1_TIPO   , NIL },;
                            { "D3_OP"   , SD4->D4_OP , NIL },;
                            { "D3_TRT"  , SD4->D4_TRT   , NIL },;
                            { "D3_LOTECTL", ALLTRIM(STR(nCont))     , NIL },; 
                            { "D3_DTVALID", dDataBase+10+nCont   , NIL },; 
                            { "D3_OBS"  , 'teste kits'      , NIL } }
                   aAdd( _aIteBai, _aIteMov )
					//Garante que existe o item no armazem na tabela SB2
                   DbSelectArea("SB2") 
                   SB2->( DbSetOrder( 1 ) )
                   If !SB2->( DbSeek( xFilial("SB2") + SD4->D4_COD + SD4->D4_LOCAL ) )
                      CriaSB2( SD4->D4_COD, SD4->D4_LOCAL )
                   Endif


		ENDIF 						 
		DbSelectArea("SD4")
		SD4->( DbSkip( ) )
    Enddo
  
    If Len( _aIteBai ) > 0
		MSExecAuto( { |x, y, z| MATA241( x, y, z ) }, _aCabMov, _aIteBai, 3 )
	endif 
EndIf

if lMsErroAuto
	MostraErro()
	return nil 
else
	MsgAlert("Blz!")
endif 

End Transaction

  
Return nil 

Static Function ProdKit(_cOp)
Local lRet,aVetor,nOpc,dData
private lMsErroAuto,lMsHelpAuto
lRet := .t.
lMsErroAuto := .F.
	aVetor := {}         
	nOpc   := 3 //-Opcaoo de execucao da rotina, informado nos parametros quais as opcoes possiveis. 5-estorno
	
	dbselectarea("SC2")
	dbsetorder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD    
	msseek(xFilial("SC2")+_cOp,.t.)                                                                                                               
	dData:=dDataBase
	aVetor := {; 
          {"D3_OP"     ,_cOp   ,NIL},;
          {"D3_TM"     ,"001"          ,NIL},;
          {"D3_LOTECTL",SC2->C2_XLOTE          ,NIL},;
          {"D3_DTVALID",SC2->C2_DATPRF        ,NIL}}                                      
 
	MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc ) 
if lMsErroAuto
	MostraErro()
	lRet := .f.
endif 

return(lRet)

Static Function ExcluiKit(_cOp)
Local aMATA650      := {}       //-Array com os campos
Private lMsErroAuto,lMsHelpAuto
lRet := .t.

//รรรรรรรรรรรรรรรรรรรยฟ
//ยณ 3 - Inclusao     ยณ
//ยณ 4 - Alteracao    ยณ
//ยณ 5 - Exclusao     ยณ
//ร€รรรรรรรรรรรรรรรรรรร
	dbselectarea("SC2")
	dbsetorder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD    
	msseek(xFilial("SC2")+_cOp,.t.)                                                                                                               
  
aMata650  := {  {'C2_FILIAL'   ,xFilial("SC2")              ,NIL},;
                {'C2_PRODUTO'  ,SC2->C2_PRODUTO       ,NIL},;         
  	            {'C2_NUM'     ,SC2->C2_NUM                    ,NIL},;         
  	            {'C2_ITEM'     ,SC2->C2_ITEM                    ,NIL},;         
                {'C2_SEQUEN'   ,SC2->C2_SEQUEN                  ,NIL}}           
                  

lMsErroAuto := .f.  
      
msExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)
if lMsErroAuto
	MostraErro()
	lRet := .f.
endif 

return(lRet)

//Acertar c๓digos menores que 36 dํgitos que nใo possuem data de validade
Static Function GrvValid(cChvnfe)
Local lRet := .t.
Local cQuery,lSucesso,cCod,nReg,cRefeito,cAux,nCont,cPai
Local aFields := {}
Local oTempTable
Local cAlias := "CODIGOS"

//-------------------
//Cria็ใo do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cAlias )

//CREATE CURSOR codigos (original c(36),refeito c(36),qtdefilho I,processado L)

//--------------------------
//Monta os campos da tabela
//--------------------------
aadd(aFields,{"ORIGINAL","C",36,0})
aadd(aFields,{"REFEITO","C",36,0})
aadd(aFields,{"QTDEFILHO","N",3,0})
aadd(aFields,{"PROCESSADO","L",1,0})
aadd(aFields,{"REG","N",15,0})

oTemptable:SetFields( aFields )
//------------------
//Cria็ใo da tabela
//------------------
oTempTable:Create()


lSucesso := .t.

dbselectarea("KITS")
dbgotop()

if Select("TMP")<>0		
	dbselectarea("TMP")
	dbclosearea()
endif 

	/* alterado por nelieder 18/08/2022 */
	if (GETMV("ZP_PAR0052") == .F.)
		cQuery = "SELECT ZZD.R_E_C_N_O_ AS REG,ZZD_CODBAR AS CODBAR,KITS.QTDEFILHO "+;
		"FROM "+RetSqlName("ZZD")+" ZZD "+;
		"LEFT OUTER JOIN KITSCOCA KITS ON KITS.COMPON = SUBSTRING(ZZD_CODBAR,4,7) "+;
		"WHERE (ZZD.D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND "+;
		"(ZZD_CHVNFE = '"+cChvnfe+"') ORDER BY REG "
	else
		cQuery = "SELECT ZZD.R_E_C_N_O_ AS REG,ZZD_CODBAR AS CODBAR,KITS.ZA7_QTDFIL AS QTDEFILHO  "+;
		"FROM "+RetSqlName("ZZD")+" ZZD "+;
		"LEFT OUTER JOIN ZA7110 KITS ON ZA7_COMPON = SUBSTRING(ZZD_CODBAR,4,7) "+;
		"WHERE (ZZD.D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND "+;
		"(ZZD_CHVNFE = '"+cChvnfe+"') ORDER BY REG "

	endif	
TCQuery cQuery ALIAS "TMP" NEW
dbselectarea("KITS")
dbgotop()  // COMPON+CODIGO+PAI 

dbselectarea("TMP")
dbgotop()
DO WHILE lSucesso .and. !EOF()
	dbselectarea("CODIGOS")
	reclock("CODIGOS",.t.)
	CODIGOS->ORIGINAL := TMP->CODBAR
	CODIGOS->REG := TMP->REG
	IF (LEN(ALLTRIM(TMP->CODBAR)) == 36)
		dbselectarea("KITS")
		dbgotop()
		do while !eof() .and. (KITS->COMPON <> SUBSTR(TMP->CODBAR,4,7))
			dbskip()
		enddo 
		IF (SUBSTR(TMP->CODBAR,4,7) == KITS->COMPON) 
			dbselectarea("CODIGOS")
			CODIGOS->QTDEFILHO := KITS->QTDEFILHO
		ENDIF 
	ENDIF 
	dbselectarea("CODIGOS")
	msunlock()
	dbselectarea("TMP")
	dbskip()
ENDDO 
dbselectarea("TMP")
dbclosearea()


dbselectarea("CODIGOS")
dbgotop()
DO WHILE lSucesso .and. !EOF()
	cCod := ALLTRIM(CODIGOS->ORIGINAL)
	nReg := CODIGOS->REG
	IF (LEN(cCod) < 36) .AND. !CODIGOS->PROCESSADO
		cRefeito := ""
		cAux := SUBSTR(cCod,4,7)				
		DBSELECTAREA("KiTS")
		dbgotop()
		do while lSucesso .and. !eof() .and. !(KITS->COMPON == cAux)
			dbskip()
		enddo 
		nCont := 0
		cPai := ""
		DO WHILE lSucesso .AND. !EOF() .AND. (KITS->COMPON == cAux)
			IF !EMPTY(ALLTRIM(KITS->PAI))
				nCont++
				cPai := KITS->PAI
			ENDIF 
			dbskip()
		ENDDO 
		DO CASE 
		CASE nCont == 0
			lSucesso = .f.
			MsgAlert("Nใo encontrado pai para c๓digo "+cCod)
		CASE nCont > 1
			lSucesso := .f.
			MsgAlert("Mais de um pai para c๓digo "+cCod)
		ENDCASE 
		dbselectarea("CODIGOS")
		dbgotop()
		DO WHILE lSucesso .and. !EOF()
			IF (SUBSTR(CODIGOS->ORIGINAL,4,7) == cPai) .and. (LEN(ALLTRIM(CODIGOS->ORIGINAL)) == 36) .AND. (CODIGOS->QTDEFILHO > 0)
				cRefeito = SUBSTR(cCod,1,22)+SUBSTR(CODIGOS->ORIGINAL,23,8)+SUBSTR(cCod,23,6)
				RECLOCK("CODIGOS",.F.)
				CODIGOS->QTDEFILHO := CODIGOS->QTDEFILHO - 1
				msunlock()
				EXIT 
			ENDIF 
			dbselectarea("CODIGOS")
			dbskip()
		ENDDO 
		dbselectarea("CODIGOS")
		dbgotop()
		do while lSucesso .and. !eof() .and. (CODIGOS->REG != nReg)
			dbskip()
		enddo 
		IF !EMPTY(cRefeito)
			RECLOCK("CODIGOS",.F.)
			CODIGOS->REFEITO := cRefeito
			CODIGOS->PROCESSADO := .T.
			msunlock()
		ENDIF 
	ELSE
		RECLOCK("CODIGOS",.F.)
		CODIGOS->REFEITO := cCod
		CODIGOS->PROCESSADO := .T.
		msunlock()
	ENDIF 
	dbselectarea("CODIGOS")
	dbskip()
ENDDO 		

if Select("NAOPROC")<>0		
	dbselectarea("NAOPROC")
	dbclosearea()
endif 
if lSucesso 
	cQuery := "select count(*) as qtde from "+ oTempTable:GetRealName()+ " WHERE PROCESSADO = 'F'"
	MPSysOpenQuery( cQuery, 'NAOPROC' )


	DbSelectArea('NAOPROC')
	if NAOPROC->QTDE > 0
		MsgAlert("Existem Nใo Processados!")
		lSucesso = .f.
	endif

	dbselectarea("NAOPROC")
	dbclosearea()

	dbselectarea("CODIGOS")
	dbgotop()
	DO WHILE lSucesso .and. !EOF()
		cCod = ALLTRIM(CODIGOS->ORIGINAL)
		cRefeito = ALLTRIM(CODIGOS->REFEITO)
		dbselectarea("ZZD")
		dbgoto(CODIGOS->REG)
		if !(ALLTRIM(ZZD->ZZD_CODBAR) == ALLTRIM(CODIGOS->ORIGINAL))
			lSucesso := .f.
			MsgAlert("Nใo encontrado c๓digo "+CODIGOS->ORIGINAL+" para atualizar!")
			exit 
		endif 
		reclock("ZZD",.F.)
		ZZD->ZZD_CODOK := cRefeito
		msunlock()
		dbselectarea("CODIGOS")
		dbskip()
	ENDDO 
endif 
//---------------------------------
//Exclui a tabela 
//---------------------------------
oTempTable:Delete() 
lRet := lSucesso
return(lRet)
