#INCLUDE "rwmake.ch"       
#INCLUDE "TOPCONN.CH"
#include "Font.ch"   
#INCLUDE "avprint.ch"    
     
                                                                                                           
#xtranslate TRACO_BOLD1  => oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 ) ;
                          ; oPrn:Line( Linha     , 10 , Linha     , 2340 ) ;
                          ; oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
                          
#xtranslate TRACO_NORMAL => oPrn:Line( Linha     , 10 , Linha     , 2340 )
                                                 
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BRCTB001 ¦ Autor ¦ Marcos Cesar Vieira   ¦ Data ¦ 16/01/04 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Relatório de lançamentos contábil sem estarem Aglutinados  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ CTB                                                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

USER FUNCTION BRCTB001()

SetPrvt("cPerg,cQuery,nPag,cNomeArq,aCampos,cIndex,aInd,nQtdTot")


//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//                                  //
// MV_PAR01 - Data Inicial          //
// MV_PAR02 - Data Final            //
// MV_PAR03 - Lote                  // 
// MV_PAR04 - Documento             //
//                                  //
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg      := "CTB001"
VldPerg()       
cIndex     := ""
aInd       := {}                        
cNomeArq   := ""
aCampos    := {}
Linha      := 0                
nOpcA      := 0                
nPag       := 0 
nQtdTot    := 0
nPerOcor   := 0
nTotPer    := 0 
dDtInic    := CTOD("")
dDtFin     := CTOD("")


oDlg := oSend( MSDialog(), "New", 8, 10, 18, 63,"Conferência Contábil.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
@ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação "
@ 30,18  SAY "de Lançamentos Contabéis para conferência Contábil.  "
@ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("CTB001"))

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0
   Return
EndIf

MsAguarde({|| FilCTB001() },"Aguarde","Este processamento poderá levar alguns minutos...")

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
  DBSelectArea("TCQ") 
  DbCloseArea()
  Return
Endif  

Processa({|lEnd|RelCTB001()})

DBSelectArea("TCQ") 
Dbcloseare()

Return Nil

                         
*-------------------------*                         
Static Function FilCTB001()  
*-------------------------*                                          
cQuery  := "SELECT * "
cQuery  += "FROM "+RetSqlName("CTK")+" "
cQuery  += "WHERE CTK_FILIAL = '"+xFilial("CTK")+"' AND "
cQuery  += "CTK_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND "
IF !EMPTY(MV_PAR04)           
  cQuery += "CTK_HIST LIKE ('%"+ALLTRIM(MV_PAR04)+"%') AND "
ENDIF
CQuery  += "CTK_LOTE = '"+MV_PAR03+"' AND D_E_L_E_T_ <> '*' "
cQuery  += "ORDER BY CTK_DATA"
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)                  

Return Nil
           

*-------------------------*
Static Function RelCTB001()
*-------------------------*
oPrn:= TMSPrinter():New( "Relatorio para conferência contábil.")
oPrn:SetPortrait()     //SetLandscape()   

AVPRINT oPrn NAME "Relatorio para conferência contábil."
ProcRegua(150)

oFont1    := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
oFont2    := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
oFont3    := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
oFont4    := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.)
oFont5    := TFont():New("Arial"      ,9,10,.F.,.T.,5,.T.,5,.T.,.F.) 

AVPAGE


cHistorico := ""
nDebito    := 0
nCredito   := 0

DBSelectArea("TCQ")            
DBGotop()
DO WHILE !EOF()   
  IF nPag == 0 .OR. Linha > 3200
    CTB001Cab()
  ENDIF                               
  
  dData := SUBSTR(TCQ->CTK_DATA,7,2)+"/"+SUBSTR(TCQ->CTK_DATA,5,2)+"/"+SUBSTR(TCQ->CTK_DATA,3,2)
  oPrn:Say( Linha , 0010 , dData                                         , oFont4 ) 
  oPrn:Say( Linha , 0250 , ALLTRIM(TCQ->CTK_DEBITO)                      , oFont4 )
  oPrn:Say( Linha , 0500 , ALLTRIM(TCQ->CTK_CREDIT)                      , oFont4 )
  oPrn:Say( Linha , 0650 , Transform(TCQ->CTK_VLR01,"@E 999,999,999.99") , oFont4 )
  cHistorico := ALLTRIM(TCQ->CTK_HIST)
   
  IF TCQ->CTK_DC == "1"    
    nDebito  += TCQ->CTK_VLR01
  ELSEIF TCQ->CTK_DC == "2"
    nCredito += TCQ->CTK_VLR01
  ELSEIF TCQ->CTK_DC == "3"
    nDebito  += TCQ->CTK_VLR01
    nCredito += TCQ->CTK_VLR01
  ENDIF
   
  DBSelectArea("TCQ")
  DBSkip()
     
  IF TCQ->CTK_DC == "4"
    oPrn:Say( Linha , 1050 , cHistorico+ALLTRIM(TCQ->CTK_HIST) , oFont4 )            
    DBSelectArea("TCQ")
    DBSkip()
  ELSE 
    oPrn:Say( Linha , 1050 , cHistorico                        , oFont4 )            
  ENDIF
  Linha += 60   

ENDDO  
             
Linha += 60   
oPrn:Say( Linha , 0010 , "Débito:"                                         , oFont3 )
oPrn:Say( Linha , 0150 , Transform(nDebito ,"@E 999,999,999.99")           , oFont4 ) 
oPrn:Say( Linha , 0500 , "Crédito:"                                         , oFont3 )           
oPrn:Say( Linha , 0680 , Transform(nCredito,"@E 999,999,999.99")           , oFont4 ) 
oPrn:Say( Linha , 1050 , "Diferença:"                                      , oFont3 )
oPrn:Say( Linha , 1350 , Transform(nDebito - nCredito,"@E 999,999,999.99") , oFont4 ) 

AVENDPAGE
AVENDPRINT
            
oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End()

MS_FLUSH()

Return nil 



*--------------------------*
Static FUNCTION CTB001Cab()
*--------------------------*      

If Linha <> 0
  AVNEWPAGE
Endif
      
nPag  += 1
Linha := 10                           
cMes  := MesExtenso(Month(MV_PAR01))

oPrn:Say( Linha , 010  , "BRASILUX/CTB"                        , oFont1 )
oPrn:Say( Linha , 640  , "RELATÓRIO PARA CONFERÊNCIA CONTÁBIL" , oFont2 )
oPrn:Say( Linha , 2100 , "PAG........:"                        , oFont1 )
oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                       , oFont1 ) 
Linha += 70
oPrn:Say( Linha , 10   , "Referente ao Mês: "+cMes             , oFont1 )        
oPrn:Say( Linha , 2100 , "Emissao.:"                           , oFont1 )
oPrn:Say( Linha , 2240 , DTOC(dDataBase)                       , oFont1 ) 
Linha += 40
TRACO_BOLD1 
Linha += 20   
oPrn:Say( Linha , 0010 , "DATA"                                , oFont3 ) 
oPrn:Say( Linha , 0250 , "CTA DEBITO"                          , oFont3 )
oPrn:Say( Linha , 0500 , "CTA CRÉDITO"                         , oFont3 )
oPrn:Say( Linha , 0750 , "VALOR"                               , oFont3 )
oPrn:Say( Linha , 1050 , "HISTÓRICO"                           , oFont3 )
Linha += 70
TRACO_BOLD1
Linha += 30 
 
Return NIL                              
                                        

    

//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
// Função....: VldPerg                             //
// Data......: 16/01/04                            //
// Descrição.: Verifica as perguntas incluindo-as  //
//             caso não existam                    //
// Uso.......: BRCTB001                            //
//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
/*-----------------------*/
Static Function VldPerg() 
/*-----------------------*/
Local i, j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//=//=//=//=//=//=//=//=//=//=//=//=//
//                                  //
// MV_PAR01 - Data Inicial          //
// MV_PAR02 - Data Final            //
// MV_PAR03 - Lote                  //
// MV_PAR04 - Conta Contábil        //
//                                  //
//=//=//=//=//=//=//=//=//=//=//=//=//
cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data Inicial?    ","","","mv_ch1" ,"D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Final?      ","","","mv_ch2" ,"D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
AADD(aRegs,{cPerg,"03","Lote?            ","","","mv_ch3" ,"C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""}) 
AADD(aRegs,{cPerg,"04","Documento?       ","","","mv_ch4" ,"C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
  If ! dbSeek(cPerg+aRegs[i,2])
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