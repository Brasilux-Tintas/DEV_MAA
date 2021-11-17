#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFAT  บAutor ณ Marcelo J. A Paivaบ Data ณ  11/08/17       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   												          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ 11/08/17 ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TECNICAS LTDA                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TRANSFP()
Private cPerg, MV_PAR01,MV_PAR02,MV_PAR03

cPerg := PADR("TRFPROD",10," ")

//CriaSX1(cPerg) //LGS#20200210 - Adequa็ใo de release 12.1.25 e posteriores
//Pergunte(cPerg, .F.) 
@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Transferencia de produtos entre filiais"

@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_TRFPROD()} )
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,016 SAY "Transferencia de produtos entre filiais."
@ 08,10 TO 84,222
ACTIVATE DIALOG oDlg1 CENTERED
Return

User Function TRFPROD()
Local cAux := ""
Local cQuery := ""

if(len(alltrim(MV_PAR01)) == 0)
	cAux := "Campo filial em branco, favor preencher!"
elseif(len(alltrim(MV_PAR02)) == 0)                                
	cAux := "Campo filial em branco, favor preencher!"
elseif(len(alltrim(MV_PAR03)) == 0)
	cAux := "Campo produto em branco, favor preencher!"
else
	cQuery := "SELECT B1_COD FROM "+RetSqlName("SB1")+" SB1 WHERE (D_E_L_E_T_ <> '*') AND (B1_COD IN ('"+ALLTRIM(MV_PAR03)+"')) AND (B1_FILIAL = '"+MV_PAR01+"') "

endif

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

if (cAux == "")             
	while !eof()
		cQuery := "Exec dbo.CopiarProduto '"+MV_PAR01+"','"+MV_PAR02+"','"+TCQ->B1_COD+"' "
		if (TCSqlExec(cQuery) < 0 )
			cAux := "Processo Finalizado!"	
		else
			cAux := "Processo Finalizado. Houveram Erros!"
		endif
		dbselectarea("TCQ")	 
		dbskip() 	
	enddo        
endIf	
MsgBox(cAux, "Aviso", "INFO")
dbSelectArea("TCQ")
dbCloseArea( )
return

//LGS#20200210 - Adequa็ใo de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de filial"  },  {""}, {""}})
AAdd(aHelp, {{"ate filial" },  {""}, {""}})
AAdd(aHelp, {{"codigo dos produtos, utilize (,) para separar os produtos" },  {""}, {""}})


//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de filial:   " ,"","","mv_ch1","C",6,00,00,"G","","SM0","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","para filial: " ,"","","mv_ch2","C",6,00,00,"G","","SM0","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Cod. produtos:" ,"","","mv_ch3","C",99,00,00,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")

Return*/
