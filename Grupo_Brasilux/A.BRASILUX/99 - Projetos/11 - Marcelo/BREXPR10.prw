#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "avprint.ch
User Function BREXPR10()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatório de Estoque por Localização"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := ""
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= "ZZL"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BREXPR10"
PRIVATE aLinha  := { },nLastKey := 0
//PRIVATE cPerg
PRIVATE Linha := 20
PRIVATE cPerg   := "BREXPR10"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BREXPR10"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR01 == 1
	cQuery :="SELECT ZZL_PRODUT AS 'PRODUTO', B1_DESC AS 'DESCRI', ZZL_LOCALI AS 'LOCALIZACAO' "
	cQuery +="FROM "+RetSqlName("ZZL")+" ZZL "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = ZZL.ZZL_FILIAL AND SB1.B1_COD = ZZL.ZZL_PRODUT AND SB1.D_E_L_E_T_ = '' "
	cQuery +="WHERE (ZZL_FILIAL='"+xFilial("ZZL")+"') AND (ZZL.D_E_L_E_T_='') AND LEN(B1_COD) = '12'  AND (SUBSTRING(B1_COD,4,2) BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')) " 
	If !Empty(MV_PAR02) 
		cQuery +="AND UPPER(SUBSTRING(ZZL_LOCALI,1,2)) = '"+MV_PAR02+"' "
	EndIf  
	If MV_PAR05 == 1
		cQuery +="AND ZZL_LOCALI <> '' "
	EndIf
	cQuery +="ORDER BY ZZL_LOCALI"
Else
	cQuery :="SELECT B1_COD AS 'PRODUTO', B1_DESC AS 'DESCRI', B2_LOCALIZ AS 'LOCALIZACAO', ZZL_LOCALI AS PROVISORIO "
	cQuery +="FROM "+RetSqlName("SB1")+" SB1 "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = '"+xFilial("SB2")+"' AND B1_COD = B2_COD AND SB2.D_E_L_E_T_ ='' "
	cQuery +="LEFT OUTER JOIN "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK) ON ZZL_FILIAL = '"+xFilial("ZZL")+"' AND B1_COD = ZZL_PRODUT AND ZZL.D_E_L_E_T_ ='' "
	cQuery +="WHERE SB1.D_E_L_E_T_ ='' AND B1_FILIAL ='"+xFilial("SB1")+"' AND (SUBSTRING(B1_COD,4,2) BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')) AND B2_LOCALIZ <>'' AND B1_TIPO = 'PA' AND LEN(B1_COD) = '12' "
	If !Empty(MV_PAR02)
		cQuery +="AND UPPER(SUBSTRING(B2_LOCALIZ,1,2)) = '"+MV_PAR02+"' "
    EndIf                               
	If MV_PAR05 == 1
		cQuery +="AND ZZL_LOCALI <> '' "
	EndIf
	cQuery +="ORDER BY B2_LOCALIZ"    
EndIf                                                                                 


TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")
    oPrn:= TMSPrinter():New( "..." )
       oPrn:SetLandscape()
       
        AVPRINT oPrn NAME "..."
                 ProcRegua(150)

               oFont1 := TFont():New("Arial"      , 9, 07, .F., .T., 5, .T., 5, .T., .F.)
               oFont2 := TFont():New("Courier New", 9, 14, .F., .T., 5, .F., 5, .T., .F.)
               oFont3 := TFont():New("Courier New", 9, 10, .F., .T., 5, .F., 5, .T., .F.)
               oFont4 := TFont():New("Courier New", 9, 10, .F., .F., 5, .T., 5, .T., .F.)
               oFont5 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .F., 5, .T., .F.)
               oFont6 := TFont():New("Arial"      , 9, 09, .F., .T., 5, .T., 5, .T., .F.)
               oFont7 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .T., 5, .T., .F.)

               AVPAGE
                 DbSelectArea("TCQ")
                 DbGotop()
 	While !Eof()
	   exp10kbc()
	   xLinha := 100
		While Linha <= 3100 .AND. !Eof()
 	       oPrn:Line( Linha - 34 , 0010, (Linha - 34 + xLinha),  0010 )
 	       oPrn:Line( Linha - 34 , 0011, (Linha - 34 + xLinha),  0011 )
    	   oPrn:Say(  Linha      , 0020, TCQ->PRODUTO     , oFont3 )
	       oPrn:Line( Linha - 34,  0289, (Linha - 34 + xLinha),  0289 )
	       oPrn:Line( Linha - 34,  0290, (Linha - 34 + xLinha),  0290 )
	       oPrn:Say(  Linha     , 0310, TCQ->DESCRI, oFont3 )
	       
           If MV_PAR01 = 2 .AND. MV_PAR05 = 1
	       	 oPrn:Line( Linha - 34, 1225, (Linha - 34 + xLinha), 1225 )
	      	 oPrn:Line( Linha - 34, 1226, (Linha - 34 + xLinha), 1226 )
	      	 oPrn:Say(  Linha     , 1300, TCQ->PROVISORIO, oFont3 )
	       Endif
	       oPrn:Line( Linha - 34, 900, (Linha - 34 + xLinha), 900 )
	       oPrn:Line( Linha - 34, 901, (Linha - 34 + xLinha), 901 )
	       oPrn:Say(  Linha     , 975, TCQ->LOCALIZACAO   , oFont3 )
	       oPrn:Line( Linha - 34,  1600, (Linha - 34 + xLinha),  1600 )
	       oPrn:Line( Linha - 34,  1601, (Linha - 34 + xLinha),  1601 )
	       oPrn:Say(  Linha     , 2000, ""     , oFont3 )
	       oPrn:Line( Linha - 34,  3334, (Linha - 34 + xLinha),  3334 )
	       oPrn:Line( Linha - 34,  3335, (Linha - 34 + xLinha),  3335 )
	       Linha += 65
	       oPrn:Line( Linha    ,   10, Linha         , 3450 )
	       xLinha := 100
	       nLinAtu := Linha + 30
       	   DbSelectArea("TCQ")
           DbSkip()
       EndDo
           If Linha > 3100 .AND. !Eof()
           	  AVNEWPAGE
           	  Linha := 20
           EndIf	
    EndDo
	dbSelectArea("TCQ")
    dbCloseArea( )    
    
    AVENDPAGE
    AVENDPRINT
    oFont1:End()
    oFont2:End()
    oFont3:End()
    oFont4:End()
    oFont5:End()
    oFont6:End()
    oFont7:End()
    MS_FLUSH()
Return

//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"de Periodo"  },  {""}, {""}})
AAdd(aHelp, {{"ate Periodo" },  {""}, {""}})
AAdd(aHelp, {{"de Linha"  },  {""}, {""}})
AAdd(aHelp, {{"ate Linha" },  {""}, {""}})
AAdd(aHelp, {{"Imprimir provisorio" },  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Tipo relatorio: " ,"","","mv_ch1","N",1,00,00,"C","","","","","MV_PAR01","Provisorio","","","","Estoque","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Fabrica: " ,"","","mv_ch2","C",2,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","de Linha " ,"","","mv_ch3","C",2,00,00,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","ate Linha: " ,"","","mv_ch4","C",2,00,00,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Imprimir Provisorio? " ,"","","mv_ch5","N",1,00,00,"C","","","","","MV_PAR05","Sim","","","","Não","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")

Return */

//CRIA O CABEÇADO DO RELATORIO
Static Function exp10kbc()  
Local cDescricao := ""
oPrn:Line( Linha - 1,   10, Linha - 1     , 3340 )
       oPrn:Line( Linha    ,   10, Linha         , 3340 )
       oPrn:Line( Linha + 1,   10, Linha + 1     , 3340 )
       Linha  += 1
       xLinha := 100
       //BORDA_BOLD1
       oPrn:Line( Linha    ,   09, (Linha+xLinha),   09 )
       oPrn:Line( Linha    ,   10, (Linha+xLinha),   10 )
       oPrn:Line( Linha    ,   11, (Linha+xLinha),   11 )
       oPrn:Line( Linha    , 3338, (Linha+xLinha), 3338 )
       oPrn:Line( Linha    , 3339, (Linha+xLinha), 3339 )
       oPrn:Line( Linha    , 3340, (Linha+xLinha), 3340 )
       Linha += 34
       cCol  := 20
       If  MV_PAR01 == 1
           cDescricao := "PROVISÓRIO"
       Else
       	   cDescricao := "ESTOQUE"
       EndIf
       oPrn:Say(  Linha     , 0020, "PRODUTO"      , oFont3 )
       oPrn:Line( Linha - 34,  289, (Linha - 34 + xLinha),  289 )
       oPrn:Line( Linha - 34,  290, (Linha - 34 + xLinha),  290 )
       oPrn:Line( Linha - 34,  291, (Linha - 34 + xLinha),  291 )
       oPrn:Say(  Linha     , 0310, "DESCRICAO --/-- "+cDescricao, oFont3 )
       If MV_PAR01 = 2 .AND. MV_PAR05 = 1
	       oPrn:Line( Linha - 34, 1225, (Linha - 34 + xLinha), 1225 )
	       oPrn:Line( Linha - 34, 1226, (Linha - 34 + xLinha), 1226 )
	       oPrn:Line( Linha - 34, 1227, (Linha - 34 + xLinha), 1227 )
	       oPrn:Say(  Linha     , 1300, "PROVISORIO", oFont3 )
	   EndIf
	   oPrn:Say(  Linha     , 1900, SUBSTR(dtos(date()),7,2)+"/"+SUBSTR(dtos(date()),5,2)+"/"+SUBSTR(dtos(date()),1,4)+" - "+(time() ) , oFont3 )
	   oPrn:Line( Linha - 34, 900, (Linha - 34 + xLinha), 900 )
	   oPrn:Line( Linha - 34, 901, (Linha - 34 + xLinha), 901 )
	   oPrn:Line( Linha - 34, 902, (Linha - 34 + xLinha), 902 )
       oPrn:Say(  Linha     , 975, "LOCAL"   , oFont3 )
       oPrn:Line( Linha - 34,  1600, (Linha - 34 + xLinha),  1600 )
       oPrn:Line( Linha - 34,  1601, (Linha - 34 + xLinha),  1601 )
       oPrn:Line( Linha - 34,  1602, (Linha - 34 + xLinha),  1602 )
       oPrn:Say(  Linha     , 1650, "OBSERVAÇÃO"     , oFont3 )
       oPrn:Line( Linha - 34,  3333, (Linha - 34 + xLinha),  3333 )
       oPrn:Line( Linha - 34,  3334, (Linha - 34 + xLinha),  3334 )
       oPrn:Line( Linha - 34,  3335, (Linha - 34 + xLinha),  3335 )      
       Linha += 65  
       oPrn:Line( Linha - 1,   10, Linha - 1     , 3340 )
       oPrn:Line( Linha    ,   10, Linha         , 3340 )
       oPrn:Line( Linha + 1,   10, Linha + 1     , 3340 )
       xLinha := 100
       nLinAtu := Linha + 30
Return