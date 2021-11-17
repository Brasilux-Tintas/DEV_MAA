#INCLUDE 'Protheus.ch'
#include "topconn.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include 'DIRECTRY.CH' 
#include "TbiConn.ch"
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
        ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
        ฑฑบPrograma  ณ TCPCP003 บAutor  ณ Cleber Oratiบ Data ณ  26/10/21         บฑฑ
        ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
        ฑฑบDesc.     ณ Estorno Desmontar Kits Coca Cola (Recofarma)         	  บฑฑ
        ฑฑบ          ณ                                                            บฑฑ
        ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
        ฑฑบUso       ณ TECPOLPA                                                   บฑฑ
        ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
        ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
        ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function TCPCP003()
private oDlg1
private cCodBar := SPACE(44)

if !(cNumEmp == "1111") // "0106"
		MsgBox("Esta opera็ใo s๓ pode ser executada na TecPolpa!", "Aten็ใo!", "STOP")
		return NIL 
endif 

     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "ESTORNO Desmontagem Kits Coca Cola"

     //@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
     @ 15,016 SAY "ESTORNO Desmontagem Kits RECOFARMA"
 	 @ 30,016 Say OemToAnsi("Chave NFE") Size 040,040
	 @ 30,065 Get cCodBar  Picture "@!S80"  Size 150,030 Valid VerChave(cCodBar)
     @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| Monta(cCodBar)} )
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 08,10 TO 84,222
     ACTIVATE DIALOG oDlg1 CENTERED

return 

Static Function VerChave(cCodBar)
Local lRet := .t.
if empty(alltrim(cCodBar))
	MsgAlert("Deve-se informar uma Chave!")
	lRet = .f.
else 
	if (len(alltrim(cCodBar)) != 44)
		MsgAlert("Chave Invแlida!")
		lRet = .f.
	endif 
endif 
return(lRet)

Static Function Monta(cCodBar)
Local lSucesso,cQuery,cChvnfe 



if Select("TMPNFS")<>0		
	dbselectarea("TMPNFS")
	dbclosearea()
endif 

cQuery := "SELECT DISTINCT ZZD_CHVNFE AS CHVNFE FROM "+RetSqlName("ZZD")+" ZZD WITH (NOLOCK) "+;
"WHERE (ZZD.D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND (ZZD_CHVNFE = '"+alltrim(cCodBar)+"') "

TCQuery cQuery ALIAS "TMPNFS" NEW
dbselectarea("TMPNFS")
dbgotop()

if eof() .or. bof()
	MsgAlert("NรO EXISTE apontamento com essa CHAVE!")
else 
	cChvnfe := TMPNFS->CHVNFE
	dbselectarea("SF1")
	dbsetorder(8) //F1_FILIAL+F1_CHVNFE                                                                                                                                             
	MsSeek(xFilial("SF1")+cChvnfe)
	lSucesso := found()

	if lSucesso
		RptStatus({|| FechaKits()}, "Aguarde...", "Estornando Kits Nf "+SF1->F1_DOC+"...")
	endif 
endif 
  
if Select("TMPNFS")<>0		
	dbselectarea("TMPNFS")
	dbclosearea()
endif 

if Select("KITS")<>0		
	dbselectarea("KITS")
	dbclosearea()
endif 
return nil  

Static Function FechaKits()
Local lSucesso,_cDoc,nTotal,cQuery,cCodFor
private lMsErroAuto := .f.

lSucesso := .t.
cCodFor := "00251101" //Exclusivo RECOFARMA!!
_cDoc := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
      
cQuery := "SELECT SUM(D1_QUANT) AS QTDE FROM "+RetSqlName("SD1")+" SD1 WHERE (D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_SERIE = '"+SF1->F1_SERIE+"') AND (D1_DOC = '"+SF1->F1_DOC+"') AND (D1_FORNECE = '"+SF1->F1_FORNECE+"') AND (D1_LOJA = '"+SF1->F1_LOJA+"') AND (D1_TIPO = 'N')"
//Executa a consulta
TCQuery cQuery New Alias "QRY_AUX"
      
//Conta quantos registros existem, e seta no tamanho da rรฉgua
nTotal := ceiling(QRY_AUX->QTDE)*2

dbselectarea('QRY_AUX')
dbclosearea()

SetRegua(nTotal)

if Select("TMPOP")<>0		
	dbselectarea("TMPOP")
	dbclosearea()
endif 
cQuery := "SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO FROM "+RetSqlName("SC2")+" WHERE (D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_OBS LIKE '"+_cDoc+"%')"
TCQuery cQuery ALIAS "TMPOP" NEW
Begin Transaction
dbselectarea("TMPOP")
dbgotop()
do while lSucesso .and. !eof()

	lSucesso := EstProdKit(TMPOP->C2_NUM+TMPOP->C2_ITEM+TMPOP->C2_SEQUEN)
	IncRegua()
	dbselectarea("TMPOP")
	dbskip()
enddo 



dbselectarea("TMPOP")
dbgotop()
do while lSucesso .and. !eof()
	lSucesso := ExcluiKit(TMPOP->C2_NUM+TMPOP->C2_ITEM+TMPOP->C2_SEQUEN)
	IncRegua()
	dbselectarea("TMPOP")
	dbskip()
enddo 

End Transaction

IF lSucesso 
	cQuery := "UPDATE "+RetSqlName("ZZD")+" SET ZZD_PROCES = 'N' WHERE (D_E_L_E_T_ <> '*') AND (ZZD_FILIAL = '"+xFilial("ZZD")+"') AND (ZZD_CHVNFE = '"+alltrim(cCodBar)+"') "
	lSucesso := (TcSQLExec(cQuery) >= 0)
	If !lSucesso
		MsgStop(TcSqlError())
					//DisarmTrans()
	Endif 
ENDIF 



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
					{'C2_OBS'   ,_cObs                  ,NIL},;
					{'AUTEXPLODE' ,"S" ,NIL}}		
					

	lMsErroAuto := .f.  
		
	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

	if lMsErroAuto
		lRet := .f.
		MostraErro()
	endif 
endif 

return(lRet)

Static Function	EstLoteKit(cCodPro,_cObs)
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
endif 

return(lRet)

Static Function EstProdKit(_cOp)
Local lRet,aVetor,nOpc,cCod,cLocal,cChave,nQtde,cAuxOp,nCont,aCab,nReg
private lMsErroAuto,lMsHelpAuto,nRegSD3
lRet := .t.
lMsErroAuto := .F.
aVetor := {}
nOpc := 5 //-Op็ใo de execu็ใo da rotina, informado nos parametros quais as op็๕es possiveis

dbselectarea("SC2")
dbsetorder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD                                                                                                                   
MsSeek(xFilial("SC2")+_cOp,.t.)
if found()
	cCod := SC2->C2_PRODUTO
	cLocal:= SC2->C2_LOCAL
	cChave:= ""
 
 
	cAuxOp := PADR(ALLTRIM(_cOp),TAMSX3("D3_OP")[1]," ")
	cChave:= xFilial("SD3") + cAuxOp + cCod + cLocal
	dbselectarea("SD3")
	dbsetorder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL 
	MsSeek(cChave)
    Do While lRet .and. !(SD3->(Eof())) .And. SD3->(D3_FILIAL + D3_OP + D3_COD + D3_LOCAL) == cChave
        	If SD3->D3_ESTORNO == " "
				nQtde := SD3->D3_QUANT
            	aVetor := {;              
                      {"D3_FILIAL" ,xFilial("SD3")  ,NIL},;
                      {"D3_OP"     ,cAuxOp   ,NIL},;
                      {"D3_QUANT"  ,nQtde   ,NIL},;
                      {"D3_LOCAL"  ,cLocal          ,NIL}}

//                      {"D3_TM"     ,"001"           ,NIL},;

				nRegSD3 := SD3->(Recno())
				dbselectarea("SD3")

            	MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )
            	If lMsErroAuto
                	Mostraerro()
					lRet := .f.
	            Endif
    	        Exit
        	EndIf
		dbselectarea("SD3")
		dbskip()
    EndDo
	nCont := 0
	dbselectarea("SD3")
	dbsetorder(1)
	MsSeek(xFilial("SD3")+cAuxOp)
	do while lRet .and. !eof() .and. (SD3->D3_FILIAL == xFilial("SD3")) .AND. (SD3->D3_OP == cAuxOp)
		nCont++ 
		nReg = recno()
		if (SD3->D3_ESTORNO == " ") .AND. !(SD3->(D3_FILIAL + D3_OP + D3_COD + D3_LOCAL) == cChave)
			aCab := { {"D3_DOC" ,SD3->D3_DOC,Nil}}
			aVetor := {{"D3_COD",  SD3->D3_COD,        NIL},;
					{"D3_UM",   SD3->D3_UM,       NIL},;
					{"D3_QUANT",  SD3->D3_QUANT,          NIL},;
					{"D3_LOCAL",       SD3->D3_LOCAL,       NIL},;
					{"D3_ESTORNO",      "S",        NIL}}
		
			MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,{aVetor},6)
			If lMsErroAuto 
				Mostraerro()
				lRet := .f.
			Endif			
			dbselectarea("SD3")
			dbgoto(nReg)
		endif 
		if nCont == 10000 //Prevenir loop infinito
			exit 
		endif 
		dbselectarea("SD3")
		dbskip()
	enddo 

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

