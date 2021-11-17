#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRTOTPED()
PRIVATE cPerg   := "BRTOTPED"
  
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.T.)

cQuery := "SELECT COUNT(R_E_C_N_O_) AS VALOR FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
cQuery += "WHERE C5_FILIAL = '010101' AND D_E_L_E_T_ <> '*' AND C5_EMISSAO BETWEEN ('"+DTOS(MV_PAR01)+"') AND ('"+DTOS(MV_PAR02)+"') AND C5_APROVA = '1' "
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")
	Messagebox("Quantidade de pedidos: "+TRANSFORM(TCQ->VALOR,"@E 999999"),"Atenção...",48) 
	
	dbSelectArea("TCQ")
    dbCloseArea()
Set Device To Screen
Return

//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})


//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de Periodo: " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Periodo: " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

Return*/