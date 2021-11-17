#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch" 
#include 'font.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "DIRECTRY.CH"
/*
  CADASTRO DE RETENÇÕES
*/
User Function BRPCP046()
Private aRotina := {}
Private cCadastro := "Cadastro "

TcRefresh(RetSqlName("ZZ1"))

AAdd(aRotina, {"Pesquisar"             , "AxPesqui"  , 0, 1})
AAdd(aRotina, {"Visualizar"            , "AxVisual"  , 0, 2})
AAdd(aRotina, {"Incluir"               , "AxInclui"  , 0, 3})
AAdd(aRotina, {"Alterar"               , "AxAltera"  , 0, 4})
AAdd(aRotina, {"Excluir"               , "u_xPcpExmu(1)", 0, 5})
AAdd(aRotina, {"Excluir Mult."         , "u_xPcpExmu(2)", 0, 5})

dbSelectArea("ZZ1")
dbGoTop()

mBrowse( ,,,,"ZZ1")         
Return Nil   

User Function xPcpExmu(nOpc)
if nOpc == 1
	If MsgYesNo("Confirma a Exclusão dos dados?","Exclusão")  
		Processa({||delDados()},"Aguarde!","Excluindo os dados, aguarde...")
	Endif
elseif nOpc == 2
	If MsgYesNo("Deseja excluir mais de um registro?","Exclusão")  
		Processa({||mulDelet()},"Aguarde!","Excluindo os dados, aguarde...")
	Endif                                                                    
EndIf

Return Nil  

Static Function delDados()                                          

dbSelectArea("ZZ1")
dbSetOrder(1)
dbseek(xFilial("ZZ1")+ZZ1->ZZ1_OP)
RecLock("ZZ1",.F.)
dbDelete()
MSUnlock()	
dbSelectArea("ZZ1")
dbskip()

Return Nil         
//Monta a tela para informar quais retenções vão ser deletadas
Static Function mulDelet()    
Local aArea := GetArea()
Private cPerg  := "BRPCP046"
Private lRet := .t.  
Private lInverte := .f.     
Private cMarca     := GetMark()

//CriaSX1(cPerg)  //LGS#20200203 - Adequação ao release 12.1.25
Pergunte(cPerg,.T.)     

if Select("TMPSEL")<>0
	dbselectarea("TMPSEL")
	dbclosearea()
endif 
       
SetPrvt("oDlg1Sel", "oBrw1Sel", "oBtn1Sel", "oBtn2Sel", "oBtn3Sel","oBtn4Sel","oFont1Sl",  "oGet1Sel")      

lRet := psDados()

	If lRet
		oFont1Sl   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
		oDlg1Sel   := MSDialog():New( 077, 223, 354, 985, "Retenção  ", , , .F., , , , , , .T., , , .T. )
		DbSelectArea("TMPSEL")
		oBrw1Sel   := MsSelect():New( "TMPSEL", "SELEC", "", ;
		{ {"SELEC", , "Mark", "@!"}, {"NUMOP", "", "Num. OP", ""}, {"RETENCAO", "", "Retenção", ""}, {"PRODUTO", "", "Produto", ""}, {"LOTE", "", "Lote",""}, {"VALIDADE","","Dt. Validade"} }, ;
		@lInverte,@cMarca, {004, 004, 112, 372}, , , oDlg1Sel, , )  
			
		oBrw1Sel:oBrowse:lHasMark    := .T.
		oBrw1Sel:oBrowse:lCanAllmark := .F. 
		oBrw1Sel:bMark := {||TMPSELMark()}
                    
		oBtn2Sel   := TButton():New( 116, 220, "Deletar Todos", oDlg1Sel, { || aRet := {.t., 'S'}, fConfirmaSel(2) }, 037, 012, , , , .T., , "", , , , .F. )
		oBtn3Sel   := TButton():New( 116, 288, "Deletar Selec.", oDlg1Sel, { || aRet := {.t., 'S'}, fConfirmaSel(1) }, 037, 012, , , , .T., , "", , , , .F. )
		oBtn1Sel   := TButton():New( 116, 336, "Sair"    , oDlg1Sel, { || aRet := {.f., 'S'}, oDlg1Sel:End()         }, 037, 012, , , , .T., , "", , , , .F. )
	 	oBtn4Sel   := TButton():New( 116, 160, "Selecionar Todos", oDlg1Sel, { || aRet := {.t., 'S'}, selall() }, 046, 012, , , , .T., , "", , , , .F. )
			
		oDlg1Sel:Activate(,,,.T.)
          If Len(aRet) == 0
             aRet := {.f., 'S'}
          Endif
	Endif
	DbSelectArea("TMPSEL")
	DbCloseArea()

restarea(aArea)        

return Nil    

Static Function psDados()        

	Local aFds    := {}
	Local cQuery
	Local aArea := GetArea()
	Private  oTempTbl01
	
	lRet := .t.

    Aadd( aFds, {"SELEC" , "C", 002, 000} )
    Aadd( aFds, {"NUMOP" , "C", TamSX3("ZZ1_OP")[1], 000} )
    Aadd( aFds, {"RETENCAO" , "C", TamSX3("ZZ1_RETENC")[1], 000} )
    Aadd( aFds, {"PRODUTO" , "C", TamSX3("ZZ1_PRODUT")[1], 000} )
    Aadd( aFds, {"LOTE" , "C", TamSX3("ZZ1_LOTE")[1], 000} )
    Aadd( aFds, {"VALIDADE" , "D", 8, 000} )
    
    /*    
	cTmp := U_NovoArqTrab("dbf")
	dbcreate(cTmp+".dbf",aFds,"DBFCDXADS")
	USE (cTmp+".dbf") ALIAS TMPSEL VIA "DBFCDXADS" NEW
	DbCreateIndex(cTmp+".cdx", "RETENCAO", {||"RETENCAO"} )
  	DbClearInd()
	DbSetIndex(cTmp)
	*/
	
    oTempTbl01 := FWTemporaryTable():New( "TMPSEL" )
    oTempTbl01:SetFields( aFds )
    oTempTbl01:AddIndex( "cInd01", { "RETENCAO" } )
    oTempTbl01:Create()
    DbSelectArea( "TMPSEL" )
    DbSetOrder(1)
	

	cQuery:= "SELECT ZZ1_OP, ZZ1_RETENC,ZZ1_PRODUT, ZZ1_LOTE, ZZ1_VALIDA "
	cQuery+= "FROM "+RetSqlName("ZZ1")+" ZZ1 WITH (NOLOCK) " 
	cQuery+= "WHERE (ZZ1.D_E_L_E_T_ <> '*') AND (ZZ1_FILIAL = '"+xFilial("ZZ1")+"') AND (ZZ1_RETENC BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"')
	cQuery+= "ORDER BY ZZ1_RETENC"
    TCQuery cQuery ALIAS "TCQ" NEW
               
    DbSelectArea("TCQ")
    DbGoTop()
	While !Eof()
		RecLock("TMPSEL", .t.)
		TMPSEL->NUMOP := TCQ->ZZ1_OP
		TMPSEL->RETENCAO := TCQ->ZZ1_RETENC
		TMPSEL->PRODUTO := TCQ->ZZ1_PRODUT
		TMPSEL->LOTE := TCQ->ZZ1_LOTE
		TMPSEL->VALIDADE := STOD(TCQ->ZZ1_VALIDA)
        MsUnLock()
        DbSelectArea("TCQ")
		DbSkip()
	EndDo
	DbSelectArea("TCQ")
	DbCloseArea()
	DbSelectArea("TMPSEL")
	DbGoTop()
	If TMPSEL->(RecCount()) <= 0
		lRet := .f.
	Endif   
	restarea(aArea)
Return(lRet)

//LGS#20200203 - Adequação ao release 12.1.25
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Informe o codigo de inicio de Retenção"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate qual retenção sera excluido "},  {""}, {""}})

PutSX1(cPerg,"01","de Retenção? " ,"","","mv_ch1","C",6,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Retenção?" ,"","","mv_ch2","C",6,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

Return*/

Static Function TMPSELMark()
RecLock("TMPSEL",.F.)
If Marked("SELEC")
	TMPSEL->SELEC := cMarca
Else
	TMPSEL->SELEC := ""
Endif
MSUNLOCK() 
oBrw1Sel:oBrowse:Refresh()
Return


//Deleta os dados dentro do intervalo informado
Static Function fConfirmaSel(_nOpc)

Local aAuxSel,nContItens,nContMark,lContinua
//Local aArea := GetArea() 
//Local aCab,aCab2,aItens1,aItens2,aLinha,cDoc,cVend,nReg,cPedRepr,nOrdem
//Local aLinha,cDoc,cVend,nReg,cPedRepr,nOrdem
//Local nOrdC6,nRegC6,lRegC6,cObs := "",aLiberacoes := {}
Private lMsErroAuto, lMsHelpAuto := .t.

lContinua := .t.
aAuxSel := {}
nContItens := 0
nContMark := 0
DbSelectArea("TMPSEL")
DbGoTop()  
dbSelectArea("ZZ1")
DbGoTop()		

if _nOpc == 1
    while !Eof()
         if !Empty(TMPSEL->SELEC)
         	dbSelectArea("ZZ1")   
         	dbsetorder(1)
         	dbseek(xFilial("ZZ1")+TMPSEL->NUMOP)
         	if found()
				RecLock("ZZ1",.F.)
				dbDelete()
				MSUnlock()
			endif
			RecLock("TMPSEL",.F.)
			dbDelete()
			MSUnlock()
		 endIf  
         DbSelectArea("TMPSEL")
         dbSkip()
    EndDo
elseif _nOpc == 2
	while !Eof()
		dbSelectArea("ZZ1")      
		dbsetorder(1)
		dbseek(xFilial("ZZ1")+TMPSEL->NUMOP)
		if found()
			RecLock("ZZ1",.F.)
			dbDelete()
			MSUnlock()
		endif
			RecLock("TMPSEL",.F.)
			dbDelete()
			MSUnlock()		
			DbSelectArea("TMPSEL")
	    dbSkip() 		
	EndDo
endif       
Return

//Selecionar todos itens 
Static Function selall()
DbSelectArea("TMPSEL")
dbgotop()
While !Eof() .OR. TMPSEL->SELEC == ""    
	RecLock("TMPSEL",.F.)                                  
	
	TMPSEL->SELEC := cMarca    
	DbSelectArea("TMPSEL")
    dbSkip()    
    MSUnlock()
EnddO   
oBrw1Sel:oBrowse:Refresh()   
DbSelectArea("TMPSEL")
dbgotop()
return