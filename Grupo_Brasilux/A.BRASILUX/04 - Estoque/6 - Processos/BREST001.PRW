#include "rwmake.ch"
#include "topconn.ch"

USER Function BREst001()
Local lRet := .T.

lRet := MsgBox("Deseja criar inventario ?'","PERGUNTA","YESNO")

if lRet
	Processa({|| ProcInv()},"Gerando Inventario")
Endif

Return

Static Function ProcInv()
Local cQry
DbSelectArea("SB1")

cQry := "SELECT * FROM "+RetSqlName("SB1")+" SB1 "
cQry += "WHERE (LEN(SB1.B1_COD) = 12) "
cQry += "AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cQry += "SB1.D_E_L_E_T_ <> '*' AND "
cQry += "SB1.B1_COD NOT IN "
cQry += "(SELECT B1_COD FROM"+RetSqlName("SB1")+" "
cQry += "WHERE (B1_FILIAL = '"+xFilial("SB1")+"') AND (D_E_L_E_T_ <> '*') AND "
cQry += "(B1_COD NOT IN (SELECT G1_COD FROM "+RetSqlName("SG1")+" "
cQry += "WHERE (G1_FILIAL = '"+xFilial("SG1")+"') AND (D_E_L_E_T_ <> '*'))) AND "
cQry += "(B1_COD NOT IN (SELECT G1_COMP FROM "+RetSqlName("SG1")+" "
cQry += "WHERE (G1_FILIAL = '"+xFilial("SG1")+"') AND (D_E_L_E_T_ <> '*')))) "
cQry += "ORDER BY SB1.B1_COD, SB1.B1_LOCPAD"
/*
cQry := " SELECT * FROM "+RetSqlName("SB1")+" SB1 WHERE "
cQry += " SB1.B1_TIPO = 'MP' AND "
cQry += " SB1.B1_FILIAL = "+xFilial("SB1")+" AND "
cQry += " SB1.D_E_L_E_T_ <> '*' "
cQry += " ORDER BY SB1.B1_COD,SB1.B1_LOCPAD"
*/

TcQuery cQry New Alias "TMP"

dbselectarea("SB2")
dbsetorder(1)
DbSelectArea("TMP")
TMP->(DbGoBottom())
ProcRegua(RecCount())
TMP->(DbGoTop())
While !EOF()
	
//	IF Len(Alltrim(TMP->B1_COD)) == 12
dbselectarea("SB2")
dbseek(xFilial("SB2")+TMP->B1_COD+TMP->B1_LOCPAD)
IF FOUND() 
	if (SUBSTR(TMP->B1_COD,11,2) == "00") .OR. (SB2->B2_QATU > 2000)
		DbSelectArea("SB7")
		RecLock("SB7",.T.)
		SB7->B7_FILIAL := xFilial("SB7")
		SB7->B7_COD    := TMP->B1_COD
		SB7->B7_LOCAL  := TMP->B1_LOCPAD
		SB7->B7_TIPO   := TMP->B1_TIPO
		SB7->B7_DOC    := "110202"
		SB7->B7_QUANT  := 0
		SB7->B7_DATA   := CTOD("11/02/2002")
		MsUnlock()   
	endif
ENDIF
/*
	Else
		MsgBox("O Produto " + AllTrim(SB1->B1_COD) + " - " + AllTrim(SB1->B1_DESC) +CHR(13);
		+CHR(13)+;
		"esta como MP.","ATENCAO","ALERT")
		DbSelectArea("SB1")
		SB1->(DbSkip())
		IncProc()
	ENDIF
*/		
	DbSelectArea("TMP")
	TMP->(Dbskip())
	IncProc()
	
EndDo

DbSelectArea("TMP")
DbCloseArea()

MsgBox("Inventario terminado com sucesso...","*** ATENCAO ***","INFO")
Return()

User Function DELINVENT()
Local cQryB7
Local lRet := .T.


lRet := MsgBox("Deseja deletar todo o inventário","ATENCAO","YESNO")

IF lRet
	Processa({|| DelSB7() },"Deletando Inventario")
Endif
Return

Static Function DelSB7()
DbSelectArea("SB7")
/*
cQryB7 := " SELECT * FROM "+RetSqlName("SB7")+" SB7 WHERE "
cQryB7 += " SB7.B7_DOC = '310102' AND "
cQryB7 += " SB7.B7_FILIAL = "+xFilial("SB7")+" AND "
cQryB7 += " SB7.D_E_L_E_T_ <> '*' "
cQryB7 += " ORDER BY SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_DATA"

TCQuery cQryB7 New Alias "TB7"

DbSelectArea("TB7")
While !EOF() .AND. TB7->B7_DOC == "310102"
	DbSelectArea("TB7")
	nRecno := Recno()
      DbSelectArea("SB7")
	  DbGoTo(nRecno)
	  RecLock("SB7",.F.)
	  SB7->(DbDelete())
	  MsUnlock()
	DbSelectArea("TB7")
	TB7->(DbSkip())
EndDo
*/
dbselectarea("SB7")
dbsetorder(1)
dbseek(xFilial("SB7"))
WHILE !eof() .AND. (SB7->B7_FILIAL = xFilial("SB7"))
	if SB7->B7_DOC == "020202"
	  RecLock("SB7",.F.)
	  SB7->(DbDelete())
	  MsUnlock()     
	endif
	DBSKIP()
END	
Return
