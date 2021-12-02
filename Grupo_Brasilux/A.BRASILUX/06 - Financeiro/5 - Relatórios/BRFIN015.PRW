#include "rwmake.ch"
#include "topconn.ch"
#include "Font.ch"
#include "avprint.ch"
#xtranslate TRACO_BOLD1 => oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 ) ;
                         ; oPrn:Line( Linha     , 10 , Linha     , 2340 ) ;
                         ; oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN015 ºAutor  ³ Marcos C.D. Vieira º Data ³  28/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de títulos em Instituição de Cobrança.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN015()
     SetPrvt("cPerg,cQuery,nPag")
     u_zcfga01( 'BRFIN015' ) //LGS#2021202 - Gravação de log de utilização da rotina
//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01   Do  Titulo     ?      // 
// MV_PAR02   Até Titulo     ?      //
// MV_PAR03   Do  Cliente    ?      // 
// MV_PAR04   Até Cliente    ?      //
// MV_PAR05   Da  Emissão    ?      //
// MV_PAR06   Até Emissão    ?      //
// MV_PAR07   Do  Vencimento ?      //
// MV_PAR08   Até Vencimento ?      //
// MV_PAR09   Da  Inst.Cobranca ?   //
// MV_PAR10   Até Inst.Cobranca ?   //
//=//=//=//=//=//=//=//=//=//=//=//=//
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 



cPerg      := "FIN015"
VldPerg()    
Linha      := 0                
nOpcA      := 0                
nPag       := 0
nValTotGer := 0      


oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Relação de Duplicatas em Instituição de Cobrança.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação"
@ 30,18  SAY "de Títulos em atraso, que foram enviadas a Institu- "
@ 40,18  SAY "ção Financeira.                                     "
@ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("FIN015"))

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0
   Return
EndIf

MsAguarde({|| FilSE1FIN015() },"Aguarde","Em processamento conforme parametros...")

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
  DBSelectArea("TCQ") 
  Dbcloseare()
  Return
Endif  

Processa({|lEnd|RelFIN015()})

DBSelectArea("TCQ") 
Dbcloseare()

Return Nil

                         
*----------------------------*                         
Static Function FilSE1FIN015()  
*----------------------------*                                          

cQuery  := "SELECT * "
cQuery  += "FROM "+RetSqlName("SE1")+" "
cQuery  += "WHERE E1_FILIAL = '"+xFilial("SE1")+ "' AND "
IF !EMPTY(MV_PAR01)
  cQuery += "E1_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
ENDIF
IF !EMPTY(MV_PAR03)
  cQuery += "E1_CLIENTE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND "
ENDIF
IF !EMPTY(MV_PAR05)
  cQuery += "E1_EMISSAO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
ENDIF
IF !EMPTY(MV_PAR07)
  cQuery += "E1_VENCTO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' AND "
ENDIF     
IF !EMPTY(MV_PAR09)
  cQuery += "E1_INSTCOB BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' AND "
ELSE    
  cQuery  += "E1_INSTCOB <> '   ' AND "
ENDIF                                                      
cQuery  += "D_E_L_E_T_ <> '*' "
cQuery  += "ORDER BY E1_INSTCOB, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_EMISSAO, E1_VENCTO "
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
  
Return 
            

*-------------------------*
Static Function RelFIN015() 
*-------------------------*                     
oPrn:= TMSPrinter():New( "Relação de Duplicatas em Instituição de Cobrança." )
oPrn:SetPortrait()     //SetLandscape()   

AVPRINT oPrn NAME "Relação de Duplicatas em Instituição de Cobrança."
ProcRegua(150)

oFont1 := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
oFont2 := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
oFont3 := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
oFont4 := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.) 

AVPAGE

DBSelectArea("TCQ")            
DBGotop()
DO WHILE !EOF()  
  cInstCob    := TCQ->E1_INSTCOB
  nValTotCobr := 0
  
  DBSelectArea("SZL")
  DBSetOrder(1)
  DBSeek(xFilial("SZL")+TCQ->E1_INSTCOB)

  DBSelectArea("TCQ")
  DO WHILE !EOF() .AND. TCQ->E1_INSTCOB = cInstCob
    IF nPag == 0 .OR. Linha > 2400
      FIN015Cab()
    ENDIF                               
    
    DBSelectArea("SA1")
    DBSetOrder(1)
    DBSeek(xFilial("SA1")+TCQ->E1_CLIENTE+TCQ->E1_LOJA)
       
    dEmissao := CTOD(SUBSTR(TCQ->E1_EMISSAO,7,2)+"/"+SUBSTR(TCQ->E1_EMISSAO,5,2)+"/"+SUBSTR(TCQ->E1_EMISSAO,3,2))
    dVencto  := CTOD(SUBSTR(TCQ->E1_VENCTO ,7,2)+"/"+SUBSTR(TCQ->E1_VENCTO ,5,2)+"/"+SUBSTR(TCQ->E1_VENCTO ,3,2))
    
    oPrn:Say( Linha , 0010 , TCQ->E1_PREFIXO+"/"+alltrim(TCQ->E1_NUM)+"/"+TCQ->E1_PARCELA , oFont4 )
    oPrn:Say( Linha , 0400 , TCQ->E1_CLIENTE+"-"+SA1->A1_NREDUZ                  , oFont4 )
    oPrn:Say( Linha , 1050 , DTOC(dEmissao)                                      , oFont4 )
    oPrn:Say( Linha , 1350 , DTOC(dVencto)                                       , oFont4 )
    oPrn:Say( Linha , 1650 , Transform(TCQ->E1_SALDO,"@E 999,999,999.99")        , oFont4 )
    oPrn:Say( Linha , 2150 , Transform(dDataBase - dVencto, "999")               , oFont4 )
    Linha += 40
                 
    nValTotCobr += TCQ->E1_SALDO
    nValTotGer  += TCQ->E1_SALDO 
                   
    DBSelectArea("TCQ")
    DBSkip()
  ENDDO        
  Linha += 20
  oPrn:Say( Linha , 0010 , "TOTAL NA INST.DE COBRANÇA"                , oFont3 )
  oPrn:Say( Linha , 1650 , Transform(nValTotCobr,"@E 999,999,999.99") , oFont3 )
  Linha += 80
  oPrn:Say( Linha , 0010 , "INST.COBRANÇA.:"          , oFont3)
  oPrn:Say( Linha , 0400 , cInstCob+"-"+SZL->ZL_NOME  , oFont4)
  Linha += 50
  oPrn:Say( Linha , 0010 , "TELEFONE.:"               , oFont3)
  oPrn:Say( Linha , 0400 , SZL->ZL_TEL                , oFont4)
  oPrn:Say( Linha , 1300 , "FAX.:"                    , oFont3)
  oPrn:Say( Linha , 1700 , SZL->ZL_FAX                , oFont4)
  Linha += 50
  oPrn:Say( Linha , 0010 , "C.N.P.J.: "               , oFont3)
  oPrn:Say( Linha , 0400 , Transform(SZL->ZL_CNPJ,"@R 99.999.999/9999-99") , oFont4)
  oPrn:Say( Linha , 1300 , "INSC.ESTADUAL.:"          , oFont3)
  oPrn:Say( Linha , 1700 , SZL->ZL_INSCR              , oFont4)
  Linha += 50
  TRACO_BOLD1
  Linha += 30
       
ENDDO  

IF nValTotGer <> 0
  Linha += 60
  oPrn:Say( Linha , 0010 , "TOTAL GERAL EM COBRANÇA.:"               , oFont3 )
  oPrn:Say( Linha , 1650 , Transform(nValTotGer,"@E 999,999,999.99") , oFont3 )
ENDIF  


AVENDPAGE
AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

MS_FLUSH()


Return nil 



*-------------------------*
Static FUNCTION FIN015Cab()
*-------------------------*      

If Linha <> 0
  AVNEWPAGE
Endif
      
nPag  += 1
Linha := 10                           

oPrn:Say( Linha , 010  , "BRASILUX"                             , oFont1 )
oPrn:Say( Linha , 600  , "TITULO EM COBRANÇA POR INST.COBRANÇA" , oFont2 )
oPrn:Say( Linha , 2100 , "PAG........:"                         , oFont1 )
oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                        , oFont1 ) 
Linha += 70
oPrn:Say( Linha , 10   , "BRFIN015"                             , oFont1 )
oPrn:Say( Linha , 2100 , "Emissao.:"                            , oFont1 )
oPrn:Say( Linha , 2240 , DTOC(dDataBase)                        , oFont1 ) 
Linha += 40
TRACO_BOLD1 
Linha += 20          
oPrn:Say( Linha ,  010 , "PRF/NUMERO/PARC"                      , oFont3 ) 
oPrn:Say( Linha ,  400 , "CLIENTE"                              , oFont3 )
oPrn:Say( Linha , 1050 , "DT.EMISSAO"                           , oFont3 )
oPrn:Say( Linha , 1350 , "DT.VENCTO"                            , oFont3 )
oPrn:Say( Linha , 1650 , "VALOR DO TITULO"                      , oFont3 )
oPrn:Say( Linha , 2040 , "DIAS EM ATRASO"                       , oFont3 )
Linha += 70
TRACO_BOLD1
Linha += 30 
 
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
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01   Do  Titulo     ?      // 
// MV_PAR02   Até Titulo     ?      //
// MV_PAR03   Do  Cliente    ?      // 
// MV_PAR04   Até Cliente    ?      //
// MV_PAR05   Da  Emissão    ?      //
// MV_PAR06   Até Emissão    ?      //
// MV_PAR07   Do  Vencimento ?      //
// MV_PAR08   Até Vencimento ?      //
// MV_PAR09   Da  Inst.Cobranca ?   //
// MV_PAR10   Até Inst.Cobranca ?   //
//=//=//=//=//=//=//=//=//=//=//=//=//
cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Do  Titulo ?        ","","","mv_ch1" ,"C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"02","Ate Titulo ?        ","","","mv_ch2" ,"C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"03","Do  Cliente ?       ","","","mv_ch3" ,"C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"04","Ate Cliente ?       ","","","mv_ch4" ,"C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""}) 
AADD(aRegs,{cPerg,"05","Da  Emissao ?       ","","","mv_ch5" ,"D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"06","Ate Emissao ?       ","","","mv_ch6" ,"D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"07","Do  Vencimento ?    ","","","mv_ch7" ,"D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"08","Ate Vencimento ?    ","","","mv_ch8" ,"D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"09","Da  Inst.Cobranca ? ","","","mv_ch9" ,"C",03,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SZL",""})
AADD(aRegs,{cPerg,"10","Ate Inst.Cobranca ? ","","","mv_cha" ,"C",03,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SZL",""})


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
