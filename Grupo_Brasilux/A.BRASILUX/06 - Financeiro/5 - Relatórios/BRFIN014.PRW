#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "avprint.ch"
#xtranslate TRACO_BOLD1 => oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 ) ;
                         ; oPrn:Line( Linha     , 10 , Linha     , 2340 ) ;
                         ; oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN014 ºAutor  ³                    º Data ³  22/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório Envio de Duplicatas para Instituição de Cobrança º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN014()     

   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFIN014' ) //LGS#2021202 - Gravação de log de utilização da rotina

     SetPrvt("cPerg, cQuery, nPag")

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01   Numedo do Borderô     //
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg      := "FIN014"             
VldPerg()    
Linha      := 0                
nOpcA      := 0                
nPag       := 0
nValTotGer := 0     
 
 
oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Relação de Duplicatas para Instituição de Cobrança.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação"
@ 30,18  SAY "de titulos em atraso que serão enviados a uma Insti-"
@ 40,18  SAY "tuição de Cobrança já definida pelo usuário.        "
@ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("FIN014"))

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0 
   Return
EndIf

MsAguarde({|| FilSE1FIN014() },"Aguarde","Em processamento conforme parametros...")

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
  DBSelectArea("TCQ") 
  Dbcloseare()
  Return
Endif  

DBSelectArea("SZL")
DBSetOrder(1)
DBSeek(xFilial("SZL")+MV_PAR01)
      
Processa({|lEnd|RelFIN014()})

DBSelectArea("TCQ") 
Dbcloseare()

Return Nil

                         
*----------------------------*                         
Static Function FilSE1FIN014()  
*----------------------------*                                          

cQuery  := "SELECT * "
cQuery  += "FROM "+RetSqlName("SE1")+" "
cQuery  += "WHERE E1_FILIAL = '"+xFilial("SE1")+ "' AND "
cQuery  += "E1_NUMBOR = '"+mv_par01+"' AND  D_E_L_E_T_ <> '*' "  
cQuery  += "ORDER BY E1_CLIENTE, E1_NUM, E1_PARCELA " 
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
  
Return 
            

*-------------------------*
Static Function RelFIN014() 
*-------------------------*                     
oPrn:= TMSPrinter():New( "Relação de Duplicatas para Instituição de Cobrança." )
oPrn:SetPortrait()     //SetLandscape()   

AVPRINT oPrn NAME "Relação de Duplicatas para Instituição de Cobrança."
ProcRegua(150)

oFont1 := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
oFont2 := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.) 
oFont3 := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
oFont4 := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.) 

AVPAGE

DBSelectArea("TCQ")            
DBGotop()
DO WHILE !EOF()  
  cCliente   := TCQ->E1_CLIENTE
  nValTotCli := 0
  
  DBSelectArea("SA1")
  DBSetOrder(1)
  DBSeek(xFilial("SA1")+TCQ->E1_CLIENTE+TCQ->E1_LOJA)

  DBSelectArea("TCQ")
  DO WHILE !EOF() .AND. TCQ->E1_CLIENTE = cCliente
    IF nPag == 0 .OR. Linha > 3000
      FIN014Cab()
    ENDIF
  
    dEmissao := CTOD(SUBSTR(TCQ->E1_EMISSAO,7,2)+"/"+SUBSTR(TCQ->E1_EMISSAO,5,2)+"/"+SUBSTR(TCQ->E1_EMISSAO,3,2))
    dVencto  := CTOD(SUBSTR(TCQ->E1_VENCTO ,7,2)+"/"+SUBSTR(TCQ->E1_VENCTO ,5,2)+"/"+SUBSTR(TCQ->E1_VENCTO ,3,2))
    
    oPrn:Say( Linha , 0010 , TCQ->E1_PREFIXO+"/"+alltrim(TCQ->E1_NUM)+"/"+TCQ->E1_PARCELA , oFont4 )
    oPrn:Say( Linha , 0560 , DTOC(dEmissao)                                      , oFont4 )
    oPrn:Say( Linha , 0910 , DTOC(dVencto)                                       , oFont4 )
    oPrn:Say( Linha , 1170 , Transform(TCQ->E1_SALDO,"@E 999,999,999.99")        , oFont4 )
    oPrn:Say( Linha , 1650 , Transform(dDataBase - dVencto, "999")+" Dia(s)"     , oFont4 )
    oPrn:Say( Linha , 2120 , IF(ALLTRIM(TCQ->E1_NATUREZ)=="802016","S","N")      , oFont4 )
    Linha += 40
                 
    nValTotCli += TCQ->E1_SALDO
    nValTotGer += TCQ->E1_SALDO 
                   
    DBSelectArea("TCQ")
    DBSkip()
  ENDDO        
  Linha += 20
  oPrn:Say( Linha , 0010 , "TOTAL DO CLIENTE.:"                      , oFont3 )
  oPrn:Say( Linha , 1170 , Transform(nValTotCli,"@E 999,999,999.99") , oFont3 )
  Linha += 100
  oPrn:Say( Linha , 0010 , "CLIENTE.:"        , oFont3)
  oPrn:Say( Linha , 0300 , SA1->A1_NOME       , oFont4)
  Linha += 50
  oPrn:Say( Linha , 0010 , "ENDEREÇO.:"       , oFont3)
  oPrn:Say( Linha , 0300 , SA1->A1_END        , oFont4)
  Linha += 50
  oPrn:Say( Linha , 0010 , "BAIRRO.:"         , oFont3)
  oPrn:Say( Linha , 0300 , SA1->A1_BAIRRO     , oFont4)
  Linha += 50
  oPrn:Say( Linha , 0010 , "CIDADE.:"         , oFont3)
  oPrn:Say( Linha , 0300 , ALLTRIM(SA1->A1_MUN)+" - "+SA1->A1_EST , oFont4)
  oPrn:Say( Linha , 1300 , "CEP.:"            , oFont3)
  oPrn:Say( Linha , 1700 , SA1->A1_CEP        , oFont4)
  Linha += 50
  oPrn:Say( Linha , 0010 , "TELEFONE.:"       , oFont3)
  oPrn:Say( Linha , 0300 , TRIM(SA1->A1_DDD)+TRIM(SA1->A1_TEL)        , oFont4)
  oPrn:Say( Linha , 1300 , "FAX.:"            , oFont3)
  oPrn:Say( Linha , 1700 , SA1->A1_FAX        , oFont4)
  Linha += 50
  oPrn:Say( Linha , 0010 , "C.N.P.J.:"        , oFont3)
  oPrn:Say( Linha , 0300 , Transform(SA1->A1_CGC,"@R 99.999.999/9999-99") , oFont4)
  oPrn:Say( Linha , 1300 , "INSC.ESTADUAL.:"  , oFont3)
  oPrn:Say( Linha , 1700 , SA1->A1_INSCR      , oFont4)
  Linha += 50
  TRACO_BOLD1
  Linha += 30
     
ENDDO  

IF nValTotGer <> 0
  Linha += 60
  oPrn:Say( Linha , 0010 , "TOTAL GERAL ENVIADO P/COBRANÇA.:"        , oFont3 )
  oPrn:Say( Linha , 1170 , Transform(nValTotGer,"@E 999,999,999.99") , oFont3 )
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
Static FUNCTION FIN014Cab()
*-------------------------*      

If Linha <> 0
  AVNEWPAGE
Endif
      
nPag  += 1
Linha := 10                           

oPrn:Say( Linha , 010  , "BRASILUX"                            , oFont1 )
oPrn:Say( Linha , 600  , "DUPLICATAS ENVIADAS PARA COBRANÇA"   , oFont2 )
oPrn:Say( Linha , 2100 , "PAG........:"                        , oFont1 )
oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                       , oFont1 ) 
Linha += 70
oPrn:Say( Linha , 10   , "BRFIN014"                            , oFont1 )
oPrn:Say( Linha , 900  , SZL->ZL_NREDUZ                        , oFont3 )
oPrn:Say( Linha , 2100 , "Emissao.:"                           , oFont1 )
oPrn:Say( Linha , 2240 , DTOC(dDataBase)                       , oFont1 ) 
Linha += 40
TRACO_BOLD1 
Linha += 20          
oPrn:Say( Linha , 0010 , "PRF/NUMERO/PARC"                     , oFont3 )
oPrn:Say( Linha , 0550 , "DT.EMISSAO"                          , oFont3 )
oPrn:Say( Linha , 0900 , "DT.VENCTO"                           , oFont3 )
oPrn:Say( Linha , 1200 , "VALOR DO TITULO"                     , oFont3 )
oPrn:Say( Linha , 1650 , "ATRASO DE"                           , oFont3 )
oPrn:Say( Linha , 2000 , "PROTESTADO"                          , oFont3 )
Linha += 70
TRACO_BOLD1
Linha += 30 
 
Return NIL                              

    

//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
// Função....: VldPerg                             //
// Data......: 14/03/03                            //
// Descrição.: Verifica as perguntas incluindo-as  //
//             caso não existam                    //
//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
*-----------------------*
Static Function VldPerg() 
*-----------------------*     
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}
cPerg := PADR(cPerg,10)
//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01   Numero do Borderô     // 
//=//=//=//=//=//=//=//=//=//=//=//=//

//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Num. do Borderô ","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
