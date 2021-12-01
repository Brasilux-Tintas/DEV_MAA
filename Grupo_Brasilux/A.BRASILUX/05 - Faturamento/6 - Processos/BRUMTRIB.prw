#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function BRUMTRIB()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _cPerg     := "BRUMTRIB"
Private _oGeraTxt,MV_PAR01,MV_PAR02
    u_zcfga01( 'BRUMTRIB' ) //LGS#2021123 - Gravação de log de utilização da rotina    
MV_PAR01 := ""
MV_PAR02 := "" 


//CriaSX1(_cPerg)
Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Corrige UM de Tributação")
@ 02,10 TO 060,215
@ 10,018 Say " Este programa cria as Unidades de Medida de Tributação para NF de Exportação " SIZE 196,0
@ 18,018 Say " não autorizada pela SEFAZ                                                    " SIZE 196,0

@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkGeraTrb() }) 
@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered

Return
//-------------------------------------
Static Function OkGeraTrb
Local _cQuery,_cFilial,_cSerie,_cNf,cAux

_cFilial := xFilial("SF2")
cAux := ALLTRIM(MV_PAR01)
_cSerie := cAux+space(TamSx3("F2_SERIE")[1] - len(cAux))
cAux := padl(ALLTRIM(MV_PAR02),6,"0")
_cNf := cAux+space(TamSx3("F2_DOC")[1] - len(cAux))

dbselectarea("SF2")
dbsetorder(1)
dbseek(_cFilial+_cNf+_cSerie)
if !found()
	MsgAlert("Nota Fiscal "+_cNf+"/"+_cSerie+"INEXISTENTE!","Atenção!")
	return
endif 
_cQuery := "UPDATE "+RetSqlName("SB5")+" SET B5_UMDIPI = 'KG',"+; 
"B5_CONVDIP = CASE WHEN (LEN(D2_COD) < 12) OR (D2_COD LIKE 'ST 55%') THEN SB1C.B1_PESO ELSE ISNULL(Z5_VOLUME,1)*(CASE WHEN ISNULL(Z5_UMEMB,'K') IN ('K','KG') THEN 1 ELSE SB1.B1_PESOESP END) END,"+;
"B5_2CODBAR = CASE WHEN LEN(ISNULL(SB1C.B1_CODBAR,'')) = 12 THEN  RTRIM(SB1C.B1_CODBAR)+dbo.DigVer(SB1C.B1_CODBAR) WHEN LEN(ISNULL(SB1C.B1_CODBAR,'')) = 13 THEN SB1C.B1_CODBAR ELSE '' END "+;
"FROM "+RetSqlName("SD2")+" SD2 "+; 
"LEFT OUTER JOIN "+RetSqlName("SB5")+" SB5 WITH (NOLOCK) ON (SB5.D_E_L_E_T_ <> '*') AND (B5_FILIAL = '"+xFilial("SB5")+"') AND (B5_COD = D2_COD) "+; 
"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (SB1.B1_COD = (SUBSTRING(D2_COD,1,10)+'00')) "+; 
"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1C WITH (NOLOCK) ON (SB1C.D_E_L_E_T_ <> '*') AND (SB1C.B1_FILIAL = '"+xFilial("SB1")+"') AND (SB1C.B1_COD = D2_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') AND (SZ5.Z5_FILIAL = '"+xFilial("SZ5")+"') AND (Z5_EMB = SUBSTRING(D2_COD,11,2)) "+; 
"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_SERIE = '"+alltrim(_cSerie)+"') AND (D2_DOC = '"+alltrim(_cNf)+"')"
TCSQLEXEC(_cQuery)
if TcSqlExec( _cQuery ) <> 0
	UserException( "Erro: " + TCSqlError() )
else 
	MsgAlert("Processo Finalizado","OK!")
endif

Return  

/*/
Programa  : CRIASX1   Autor:  
Data      : 10/10/18
Descricao : Grava Perguntas
/*/

/*  DESABILITADO EM FUNÇÃO DE ADEQUAÇÃO DA RELEASE 12.1.25
Static Function CriaSX1(cPerg)

Local aHelp := {}

//            Texto do help em português                , inglês, espanhol
AAdd(aHelp, {{"Série da NF"},  {"Série da NF"}, {"Série da NF"}})
AAdd(aHelp, {{"Número da NF"}, {"Número da NF"}, {"Número da NF"}})

xPutSX1(cPerg,"01",  "Série NF?"  ,"Série NF?","Série NF?","mv_ch1","C",3,00,00,"G","",""   ,"","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],cPerg)
xPutSX1(cPerg,"02",  "Nro NF?"    ,"Nro NF?"  ,"Nro NF?"  ,"mv_ch2","C",9,00,00,"G","",""   ,"","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],cPerg)

Return

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lPort := .f. 
Local lSpa := .f. 
Local lIngl := .f. 

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
cF3      := Iif( cF3           == NIl, " ", cF3          ) 
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 

dbSelectArea( "SX1" ) 
dbSetOrder( 1 ) 

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
// RFC - 15/03/2007 
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

If !( DbSeek( cGrupo + cOrdem )) 

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     Reclock( "SX1" , .T. ) 

     Replace X1_GRUPO   With cGrupo 
     Replace X1_ORDEM   With cOrdem 
     Replace X1_PERGUNT With cPergunt 
     Replace X1_PERSPA With cPerSpa 
     Replace X1_PERENG With cPerEng 
     Replace X1_VARIAVL With cVar 
     Replace X1_TIPO    With cTipo 
     Replace X1_TAMANHO With nTamanho 
     Replace X1_DECIMAL With nDecimal 
     Replace X1_PRESEL With nPresel 
     Replace X1_GSC     With cGSC 
     Replace X1_VALID   With cValid 

     Replace X1_VAR01   With cVar01 

     Replace X1_F3      With cF3 
     Replace X1_GRPSXG With cGrpSxg 

     If Fieldpos("X1_PYME") > 0 
          If cPyme != Nil 
               Replace X1_PYME With cPyme 
          Endif 
     Endif 

     Replace X1_CNT01   With cCnt01 
     If cGSC == "C"               // Mult Escolha 
          Replace X1_DEF01   With cDef01 
          Replace X1_DEFSPA1 With cDefSpa1 
          Replace X1_DEFENG1 With cDefEng1 

          Replace X1_DEF02   With cDef02 
          Replace X1_DEFSPA2 With cDefSpa2 
          Replace X1_DEFENG2 With cDefEng2 

          Replace X1_DEF03   With cDef03 
          Replace X1_DEFSPA3 With cDefSpa3 
          Replace X1_DEFENG3 With cDefEng3 

          Replace X1_DEF04   With cDef04 
          Replace X1_DEFSPA4 With cDefSpa4 
          Replace X1_DEFENG4 With cDefEng4 

          Replace X1_DEF05   With cDef05 
          Replace X1_DEFSPA5 With cDefSpa5 
          Replace X1_DEFENG5 With cDefEng5 
     Endif 

     Replace X1_HELP With cHelp 

     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

     MsUnlock() 
Else 

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

   If lPort .Or. lSpa .Or. lIngl 
          RecLock("SX1",.F.) 
          If lPort 
        SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
          EndIf 
          If lSpa 
               SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
          EndIf 
          If lIngl 
               SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
          EndIf 
          SX1->(MsUnLock()) 
     EndIf 
Endif 

RestArea( aArea ) 

Return

*/
