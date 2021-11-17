#INCLUDE "rwmake.ch"       
#INCLUDE "TOPCONN.CH"
#include "Font.ch"   
#INCLUDE "avprint.ch"    
     
#xtranslate BORDA_BOLD1 => oPrn:Line( Linha,   09, (Linha+xLinha),   09 ) ;
                         ; oPrn:Line( Linha,   10, (Linha+xLinha),   10 ) ; 
                         ; oPrn:Line( Linha,   11, (Linha+xLinha),   11 ) ;
                         ; oPrn:Line( Linha, 2338, (Linha+xLinha), 2338 ) ;
                         ; oPrn:Line( Linha, 2339, (Linha+xLinha), 2339 ) ;
                         ; oPrn:Line( Linha, 2340, (Linha+xLinha), 2340 )       
                        
#xtranslate BORDA_BOLD2 => oPrn:Line( Linha, 349 , (Linha+xLinha),  349 ) ;
                         ; oPrn:Line( Linha, 350 , (Linha+xLinha),  350 ) ;                               
                         ; oPrn:Line( Linha, 351 , (Linha+xLinha),  351 ) ;                               
                         ; oPrn:Line( Linha, 1099, (Linha+xLinha), 1099 ) ; 
                         ; oPrn:Line( Linha, 1100, (Linha+xLinha), 1100 ) ;              
                         ; oPrn:Line( Linha, 1101, (Linha+xLinha), 1101 ) ; 
                         ; oPrn:Line( Linha, 1349, (Linha+xLinha), 1349 ) ;
                         ; oPrn:Line( Linha, 1350, (Linha+xLinha), 1350 ) ;               
                         ; oPrn:Line( Linha, 1351, (Linha+xLinha), 1351 ) ;              
                         ; oPrn:Line( Linha, 1599, (Linha+xLinha), 1599 ) ; 
                         ; oPrn:Line( Linha, 1600, (Linha+xLinha), 1600 ) ;             
                         ; oPrn:Line( Linha, 1601, (Linha+xLinha), 1601 ) ; 
                         ; oPrn:Line( Linha, 1839, (Linha+xLinha), 1839 ) ;
                         ; oPrn:Line( Linha, 1840, (Linha+xLinha), 1840 ) ;         
                         ; oPrn:Line( Linha, 1841, (Linha+xLinha), 1841 ) ;
                         ; oPrn:Line( Linha, 2089, (Linha+xLinha), 2089 ) ;
                         ; oPrn:Line( Linha, 2090, (Linha+xLinha), 2090 ) ;         
                         ; oPrn:Line( Linha, 2091, (Linha+xLinha), 2091 ) 
   

#xtranslate BORDA_NORMAL =>oPrn:Line( Linha, 350 , (Linha+xLinha),  350 ) ;                               
                         ; oPrn:Line( Linha, 1100, (Linha+xLinha), 1100 ) ;              
                         ; oPrn:Line( Linha, 1350, (Linha+xLinha), 1350 ) ;               
                         ; oPrn:Line( Linha, 1600, (Linha+xLinha), 1600 ) ;
                         ; oPrn:Line( Linha, 1840, (Linha+xLinha), 1840 ) ;
                         ; oPrn:Line( Linha, 2090, (Linha+xLinha), 2090 )           
                                                                                                           
#xtranslate TRACO_BOLD1 => oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 ) ;
                         ; oPrn:Line( Linha     , 10 , Linha     , 2340 ) ;
                         ; oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )

#xtranslate TRACO_NORMAL => oPrn:Line( Linha    , 10 , Linha     , 2340 )
                                                 

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BRTMK001 ¦ Autor ¦ Marcos Cesar Vieira   ¦ Data ¦ 07/04/03 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Relatório Autorização para Devolução de Mercadoria.        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Generico                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

USER FUNCTION BRTMK001()

SetPrvt("cPerg,cQuery,nPag,cCtaInic")

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01       Do Cliente        //
// MV_PAR02       Ate Cliente       // 
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg    := "CALL01"             
VldPerg()    
Linha    := 0                
xLinha   := 0
cCol     := 0
cCol1    := 0
nOpcA    := 0                
nPag     := 0
i        := 1
oDlg     := oSend( MSDialog(), "New", 8, 10, 18, 63,"Relatorio Devolução de Mercadorias(SAC)",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,18  SAY "Este relatorio tem como funcao, Imprimir/Consultar  "
@ 30,18  SAY "SAC's que geraram uma Devolução, podendo imprimir   "
@ 40,18  SAY "uma ficha de Devolução de Mercadorias.              "
@ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("CALL01"))

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0 
   Return
EndIf

MsAguarde({|| FilSUCTMK0() },"Aguarde","Em processando conforme parametros...")

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
  DBSelectArea("TCQ") 
  DbCloseArea()
  Return
Endif  
      
Processa({|lEnd|RelTMK001()})

DBSelectArea("TCQ") 
Dbcloseare()

Return Nil

                         
*----------------------------*                         
Static Function FilSUCTMK0()  
*----------------------------*                                          

cQuery  := "SELECT * "
cQuery  += "FROM "+RetSqlName("SUC")+" "
cQuery  += "WHERE UC_FILIAL = '"+xFilial("SUC")+ "' AND "                     
cQuery  += "UC_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
cQuery  += "UC_DEVOLUC = '2' AND UC_STATUS <> '3' AND D_E_L_E_T_ <> '*' "  
cQuery  += "ORDER BY UC_CLIENTE " 
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
  
Return 

            

*-------------------------*
Static Function RelTMK001() 
*-------------------------*
//Local i                     
Local oPrn:= TMSPrinter():New( "Relatorio de Autorização para Devolução de Mercadoria." )
oPrn:SetPortrait()     //SetLandscape()   

AVPRINT oPrn NAME "Relatorio de Autorização para Devolução de Mercadoria."
ProcRegua(150)

oFont1 := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
oFont2 := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.) 
oFont3 := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
oFont4 := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.) 
oFont5 := TFont():New("Arial"      ,9,10,.F.,.F.,5,.F.,5,.T.,.F.)
oFont6 := TFont():New("Arial"      ,9,09,.F.,.T.,5,.T.,5,.T.,.F.)
oFont7 := TFont():New("Arial"      ,9,10,.F.,.F.,5,.T.,5,.T.,.F.) 

AVPAGE

DBSelectArea("TCQ")            
DBGotop()
DO WHILE !EOF()
  CALL001Cab()
  DBSelectArea("SUD")            
  DBSetOrder(1)
  DbSeek(xFilial("SUD")+TCQ->UC_CODIGO)
  DO WHILE TCQ->UC_CODIGO = SUD->UD_CODIGO
    IF ALLTRIM(SUD->UD_DEVOLUC) # "1"
      DBSelectArea("SUD")
      DBSkip()
      Loop
    ENDIF                                                                            
    DBSelectArea("SB1")            
    DBSetOrder(1)
    DbSeek(xFilial("SB1")+SUD->UD_PRODUTO)
           
    oPrn:Say( Linha , cCol      , SUD->UD_PRODUTO                         , oFont5 )
    oPrn:Say( Linha , cCol+350  , SB1->B1_DESC                            , oFont5 )
    oPrn:Say( Linha , cCol+1090 , Transform(SUD->UD_QTD,"@E 999,999,999") , oFont5 )
    oPrn:Say( Linha , cCol+1370 , DTOC(SUD->UD_DTVALID)                   , oFont5 )
    oPrn:Say( Linha , cCol+1620 , SUD->UD_LOTE                            , oFont5 ) 
    oPrn:Say( Linha , cCol+1860 , SUD->UD_PEDIDO                          , oFont5 )    
    oPrn:Say( Linha , cCol+2150 , SUD->UD_NUMNF                           , oFont5 )
    Linha += 40
    
    IF Linha > 2400
      CALL001Cab()
    ENDIF  
           
    DBSelectArea("SUD")
    DBSkip()
  ENDDO
  DBSelectArea("TCQ")
  DBSkip()
ENDDO  

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


Return nil 



*---------------------------*
Static FUNCTION CALL001Cab()
*---------------------------*      
Local I
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+TCQ->UC_CLIENTE)

If Linha <> 0
  AVNEWPAGE
Endif

Linha := 10                           
oPrn:Say( Linha , 600  , "AUTORIZAÇÃO PARA DEVOLUÇÃO DE MERCADORIAS", oFont2 )
Linha += 150
oPrn:Say( Linha , 10   , "CLIENTE....:"                             , oFont3 )
oPrn:Say( Linha , 300  , SA1->A1_NOME                  		        , oFont4 ) 
oPrn:Say( Linha , 1750 , "DATA.......:"                             , oFont3 )
oPrn:Say( Linha , 2035 , DTOC(dDataBase)                            , oFont4 ) 
Linha += 60                                                 
oPrn:Say( Linha , 10   , "ENDEREÇO...:"                             , oFont3 )
oPrn:Say( Linha , 300  , SA1->A1_END                                , oFont4 ) 
oPrn:Say( Linha , 1750 , "SAC........:"                             , oFont3 )
oPrn:Say( Linha , 2035 , TCQ->UC_CODIGO                             , oFont4 )
Linha += 60
oPrn:Say( Linha , 10   , "CIDADE-UF..:"                             , oFont3 )
oPrn:Say( Linha , 300  , ALLTRIM(SA1->A1_MUN) +"-"+SA1->A1_EST      , oFont4 ) 
oPrn:Say( Linha , 1750 , "TELEFONE...:"                             , oFont3 )
oPrn:Say( Linha , 2035 , TRIM(SA1->A1_DDD)+'-'+TRIM(SA1->A1_TEL)    , oFont4 ) 
Linha += 60

TRACO_BOLD1           
Linha  += 1 
xLinha := 100
BORDA_BOLD1
BORDA_BOLD2
Linha += 100
TRACO_BOLD1 

xLinha := 100
I := 1
For I = 1 to 25
  Linha += 1
  BORDA_BOLD1 
  BORDA_NORMAL
  Linha += 100
Next  
TRACO_NORMAL           
oPrn:Say( Linha+20  , 20  , "OBSERVAÇÃO..:" , oFont3 )
oPrn:Say( Linha+20  , 350 , SUBSTR(TCQ->UC_OBSDEV,1,85)   , oFont4 )
oPrn:Say( Linha+70  , 350 , SUBSTR(TCQ->UC_OBSDEV,86,85)  , oFont4 )
oPrn:Say( Linha+120 , 350 , SUBSTR(TCQ->UC_OBSDEV,171,85) , oFont4 )

I := 1
For I = 1 to 3
  Linha += 1
  BORDA_BOLD1 
  Linha += 100
Next  
TRACO_BOLD1           

oPrn:Say( 3300 , 10   , "Brasilux Tintas Técnicas"      , oFont1 )
oPrn:Say( 3300 , 2050 , "Emitido em: "+dtoc(dDataBase)  , oFont1 )

cCol  := 20 
Linha := 360

oPrn:Say( Linha , cCol      , "COD.DO PRODUTO"     , oFont3 ) 
oPrn:Say( Linha , cCol+620  , "DESCRIÇÃO"          , oFont3 ) 
oPrn:Say( Linha , cCol+1100 , "QUANTIDADE"         , oFont3 ) 
oPrn:Say( Linha , cCol+1365 , "VALIDADE"           , oFont3 )  
oPrn:Say( Linha , cCol+1640 , "LOTE"               , oFont3 ) 
oPrn:Say( Linha , cCol+1860 , "NUM.PED."           , oFont3 ) 
oPrn:Say( Linha , cCol+2085 , "NF ORIGEM"          , oFont3 ) 
Linha := 450
 
Return NIL                              

    

//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
// Função....: VldPerg                             //
// Data......: 14/03/03                            //
// Descrição.: Verifica as perguntas incluindo-as  //
//             caso não existam                    //
// Uso.......: BRCON006                            //
//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
*-----------------------*
Static Function VldPerg() 
*-----------------------*     
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01 SI2   Data Inicial      // 
// MV_PAR02 SI2   Data Final        //
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","De  Cliente ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"02","Ate Cliente ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})

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