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
±±ºPrograma  ³ BRFIN016 ºAutor  ³ Marcos C.D. Vieira º Data ³  29/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Participação por tipo de cliente              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN016()
SetPrvt("cPerg,cQuery,nPag,nFatBrt,nFatLiq")
SetPrvt("nVl_C_Brt,nVl_C_Liq,nVl_D_Brt,nVl_D_Liq,nVl_I_Brt,nVl_I_Liq")
SetPrvt("nVl_N_Brt,nVl_N_Liq,nVl_V_Brt,nVl_V_Liq") 
SetPrvt("nPer_C_Brt,nPer_C_Liq,nPer_D_Brt,nPer_D_Liq,nPer_I_Brt,nPer_I_Liq")
SetPrvt("nPer_N_Brt,nPer_N_Liq,nPer_V_Brt,nPer_V_Liq")
     u_zcfga01( 'BRFIN016' ) //LGS#2021202 - Gravação de log de utilização da rotina

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01   Data de Referencia    // 
//=//=//=//=//=//=//=//=//=//=//=//=//
                      
nVl_C_Brt  := 0
nVl_C_Liq  := 0
nVl_D_Brt  := 0
nVl_D_Liq  := 0
nVl_I_Brt  := 0
nVl_I_Liq  := 0
nVl_N_Brt  := 0
nVl_N_Liq  := 0
nVl_V_Brt  := 0
nVl_V_Liq  := 0 

nPer_C_Brt := 0
nPer_C_Liq := 0
nPer_D_Brt := 0
nPer_D_Liq := 0
nPer_I_Brt := 0  
nPer_I_Liq := 0
nPer_N_Brt := 0
nPer_N_Liq := 0
nPer_V_Brt := 0
nPer_V_Liq := 0

nFatBrt    := 0
nFatLiq    := 0
     
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


cPerg      := "FIN016"
VldPerg()    
Linha      := 0                
nOpcA      := 0                
nPag       := 0
nValTotGer := 0 
oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Relatório de rentabilidade por tipo de Cliente.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação de"
@ 30,18  SAY "Participação sobre o Faturamento por tipo de Cliente.  "
@ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("FIN016"))

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0
   Return
EndIf

MsAguarde({|| FilSE1FIN016() },"Aguarde","Este processamento poderá levar alguns minutos...")

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
  DBSelectArea("TCQ") 
  Dbcloseare()
  Return
Endif  

Processa({|lEnd|RelFin016()})

DBSelectArea("TCQ") 
Dbcloseare()

Return Nil

                         
*----------------------------*                         
Static Function FilSE1FIN016()  
*----------------------------*                                          
dDtInic  := CTOD("01/"+SUBSTR(DTOC(MV_PAR01),4,5))
IF SUBSTR(DTOC(MV_PAR01),4,2)$"01*03*05*07*08*10*12"
  dDtFin := CTOD("31/"+SUBSTR(DTOC(MV_PAR01),4,5))
ELSEIF SUBSTR(DTOC(MV_PAR01),4,2)$"04*06*09*11"
  dDtFin := CTOD("30/"+SUBSTR(DTOC(MV_PAR01),4,5))
ELSEIF SUBSTR(DTOC(MV_PAR01),4,2) == "02"          
  dDtFin := CTOD("28/"+SUBSTR(DTOC(MV_PAR01),4,5))
ENDIF  

cQuery  := "SELECT F2_VALBRUT,F2_VALMERC,F2_CLAS "
cQuery  += "FROM "+RetSqlName("SF2")+" "
cQuery  += "WHERE F2_FILIAL = '"+xFilial("SF2")+ "' AND "
cQuery  += "F2_EMISSAO BETWEEN '"+DTOS(ddtinic)+"' AND '"+DTOS(ddtfin)+"' AND "
cQuery  += "F2_TIPO = 'N' AND D_E_L_E_T_ <> '*' "
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  Return 
Endif  
        
nVl_C_Brt  := 0
nVl_C_Liq  := 0
nVl_D_Brt  := 0
nVl_D_Liq  := 0
nVl_I_Brt  := 0
nVl_I_Liq  := 0
nVl_N_Brt  := 0
nVl_N_Liq  := 0
nVl_V_Brt  := 0
nVl_V_Liq  := 0 

nPer_C_Brt := 0
nPer_C_Liq := 0
nPer_D_Brt := 0
nPer_D_Liq := 0
nPer_I_Brt := 0  
nPer_I_Liq := 0
nPer_N_Brt := 0
nPer_N_Liq := 0
nPer_V_Brt := 0
nPer_V_Liq := 0

nFatBrt    := 0
nFatLiq    := 0

DO WHILE !EOF()       
  IF TCQ->F2_CLAS == "C"
    nVl_C_Brt += TCQ->F2_VALBRUT
    nVl_C_Liq += TCQ->F2_VALMERC
  ELSEIF TCQ->F2_CLAS == "D"
    nVl_D_Brt += TCQ->F2_VALBRUT
    nVl_D_Liq += TCQ->F2_VALMERC   
  ELSEIF TCQ->F2_CLAS == "I"
    nVl_I_Brt += TCQ->F2_VALBRUT
    nVl_I_Liq += TCQ->F2_VALMERC  
  ELSEIF TCQ->F2_CLAS == "N"
    nVl_N_Brt += TCQ->F2_VALBRUT
    nVl_N_Liq += TCQ->F2_VALMERC  
  ELSEIF TCQ->F2_CLAS == "V"
    nVl_V_Brt += TCQ->F2_VALBRUT
    nVl_V_Liq += TCQ->F2_VALMERC              
  ENDIF  

  nFatBrt += TCQ->F2_VALBRUT
  nFatLiq += TCQ->F2_VALMERC                   
                          
  DBSelectArea("TCQ")
  DBSkip()
ENDDO        

nPer_C_Brt := (nVl_C_Brt/nFatBrt)*100
nPer_C_Liq := (nVl_C_Liq/nFatLiq)*100
nPer_D_Brt := (nVl_D_Brt/nFatBrt)*100
nPer_D_Liq := (nVl_D_Liq/nFatLiq)*100
nPer_I_Brt := (nVl_I_Brt/nFatBrt)*100
nPer_I_Liq := (nVl_I_Liq/nFatLiq)*100
nPer_N_Brt := (nVl_N_Brt/nFatBrt)*100
nPer_N_Liq := (nVl_N_Liq/nFatLiq)*100
nPer_V_Brt := (nVl_V_Brt/nFatBrt)*100
nPer_V_Liq := (nVl_V_Liq/nFatLiq)*100
  
Return 
            

*-------------------------*
Static Function RelFIN016() 
*-------------------------*                     
oPrn:= TMSPrinter():New( "Relatório de Participação sobre o Faturamento por tipo de Cliente." )
oPrn:SetPortrait()     //SetLandscape()   

AVPRINT oPrn NAME "Relatório de Participação sobre o Faturamento por tipo de Cliente."
ProcRegua(150)

oFont1    := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
oFont2    := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
oFont3    := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
oFont4    := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.) 

AVPAGE
 
FIN015Cab()
           
oPrn:Say( Linha , 0010 , "CONSUMIDOR FINAL"                            , oFont4 )
oPrn:Say( Linha , 0700 , Transform(nVl_C_Brt ,"@E 999,999,999.99")     , oFont4 ) 
oPrn:Say( Linha , 1000 , Transform(nPer_C_Brt,"@E 999,999,999.99")+"%" , oFont4 ) 
oPrn:Say( Linha , 1750 , Transform(nVl_C_Liq ,"@E 999,999,999.99")     , oFont4 )
oPrn:Say( Linha , 2000 , Transform(nPer_C_Liq,"@E 999,999,999.99")+"%" , oFont4 ) 
Linha += 80   
oPrn:Say( Linha , 0010 , "COMÉRCIO DISTRIB"                            , oFont4 )
oPrn:Say( Linha , 0700 , Transform(nVl_D_Brt ,"@E 999,999,999.99")     , oFont4 ) 
oPrn:Say( Linha , 1000 , Transform(nPer_D_Brt,"@E 999,999,999.99")+"%" , oFont4 ) 
oPrn:Say( Linha , 1750 , Transform(nVl_D_Liq ,"@E 999,999,999.99")     , oFont4 )
oPrn:Say( Linha , 2000 , Transform(nPer_D_Liq,"@E 999,999,999.99")+"%" , oFont4 ) 
Linha += 80                                                        
oPrn:Say( Linha , 0010 , "INDUSTRIALIZAÇÃO"                            , oFont4 )
oPrn:Say( Linha , 0700 , Transform(nVl_I_Brt ,"@E 999,999,999.99")     , oFont4 ) 
oPrn:Say( Linha , 1000 , Transform(nPer_I_Brt,"@E 999,999,999.99")+"%" , oFont4 ) 
oPrn:Say( Linha , 1750 , Transform(nVl_I_Liq ,"@E 999,999,999.99")     , oFont4 )
oPrn:Say( Linha , 2000 , Transform(nPer_I_Liq,"@E 999,999,999.99")+"%" , oFont4 ) 
Linha += 80  
oPrn:Say( Linha , 0010 , "NÃO CONTRIBUINTE"                            , oFont4 )
oPrn:Say( Linha , 0700 , Transform(nVl_N_Brt ,"@E 999,999,999.99")     , oFont4 ) 
oPrn:Say( Linha , 1000 , Transform(nPer_N_Brt,"@E 999,999,999.99")+"%" , oFont4 ) 
oPrn:Say( Linha , 1750 , Transform(nVl_N_Liq ,"@E 999,999,999.99")     , oFont4 )
oPrn:Say( Linha , 2000 , Transform(nPer_N_Liq,"@E 999,999,999.99")+"%" , oFont4 ) 
Linha += 80  
oPrn:Say( Linha , 0010 , "COMÉRCIO/REVENDA"                            , oFont4 )
oPrn:Say( Linha , 0700 , Transform(nVl_V_Brt ,"@E 999,999,999.99")     , oFont4 ) 
oPrn:Say( Linha , 1000 , Transform(nPer_V_Brt,"@E 999,999,999.99")+"%" , oFont4 ) 
oPrn:Say( Linha , 1750 , Transform(nVl_V_Liq ,"@E 999,999,999.99")     , oFont4 )
oPrn:Say( Linha , 2000 , Transform(nPer_v_Liq,"@E 999,999,999.99")+"%" , oFont4 ) 
Linha += 120   
  
oPrn:Say( Linha , 0010 , "FAT.TOTAL DO MÊS C/IMPOSTOS"                 , oFont3 )
oPrn:Say( Linha , 0700 , Transform(nFatBrt,"@E 999,999,999.99")        , oFont4 ) 
oPrn:Say( Linha , 1300 , "FAT.TOTAL DO MÊS S/IMPOSTOS"                 , oFont3 )
oPrn:Say( Linha , 2000 , Transform(nFatLiq,"@E 999,999,999.99")        , oFont4 )

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
cMes  := MesExtenso(Month(MV_PAR01))

oPrn:Say( Linha , 010  , "BRASILUX"                              , oFont1 )
oPrn:Say( Linha , 600  , "REL.PARTICIPAÇÃO POR TIPO DE CLIENTE"  , oFont2 )
oPrn:Say( Linha , 2100 , "PAG........:"                          , oFont1 )
oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                         , oFont1 ) 
Linha += 70
oPrn:Say( Linha , 10   , "Referente ao Mês: "+cMes               , oFont1 )        
oPrn:Say( Linha , 2100 , "Emissao.:"                             , oFont1 )
oPrn:Say( Linha , 2240 , DTOC(dDataBase)                         , oFont1 ) 
Linha += 40
TRACO_BOLD1 
Linha += 20   
oPrn:Say( Linha , 0010 , "TIPO DE CLIENTE"                       , oFont3 ) 
oPrn:Say( Linha , 0600 , "FATURAMENTO C/IMPOSTOS"                , oFont3 )
oPrn:Say( Linha , 1180 , "% PART."                               , oFont3 )
oPrn:Say( Linha , 1620 , "FATURAMENTO S/IMPOSTOS"                , oFont3 )
oPrn:Say( Linha , 2180 , "% PART."                               , oFont3 )
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
// MV_PAR01   Data de Ref. ?        // 
//=//=//=//=//=//=//=//=//=//=//=//=//
cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data de Ref. ? ","","","mv_ch1" ,"D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})

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
