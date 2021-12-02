#include "rwmake.ch"
#include "avprint.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN008 ºAutor  ³                    º Data ³  02/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Informações Comerciais                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN008()
     Local nSomaValor     

   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFIN008' ) //LGS#2021202 - Gravação de log de utilização da rotina
     SetPrvt("cPerg, cQuery")
    
//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01 SA1   Cliente:          //
// MV_PAR02       FAX Destino:      //
// MV_PAR03       Para:             //
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg   := "FIN008"
ValidPerg()                     
nOpcA   := 0                                                                                 
cSolic1 := "    Conforme solicitação, estamos enviando informações cadastrais do cliente "
cSolic2 := "abaixo, aproveitamos para reinteirar que estas informações são estritamente  "
cSolic3 := "comercial e que devem ser mantidas em absoluto sigilo. "

oDlg  := oSend( MSDialog(), "New", 8, 10, 18, 63,"Impressão de Informações Comerciais",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,15  SAY "Este programa tem como finalidade imprimir Informacao Comercial de um   "
@ 30,15  SAY "determinado Cliente, conforme parametro.                                "
@ 57,170 BMPBUTTON TYPE 5 ACTION Pergunte("FIN008")

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0 
   Return
EndIf            

MsAguarde(,"Processando dados...")

cQuery  := "SELECT F2_VALFAT, F2_EMISSAO "
cQuery  += "FROM "+RetSqlName("SF2")+" "
cQuery  += "WHERE F2_FILIAL = '"+xFilial("SF2")+ "' AND "                     
cQuery  += "F2_CLIENTE = '"+ MV_PAR01 +"' AND D_E_L_E_T_ <> '*' " 
cQuery  += "ORDER BY F2_DUPL,F2_EMISSAO"
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
  DBSelectArea("TCQ") 
  Dbcloseare()
  Return
Endif  

nMaiorFat := TCQ->F2_VALFAT
dDataMFat := TCQ->F2_EMISSAO
nMaiorAcu := 0
dDataMAcu := CTOD("")
nUltCompr := TCQ->F2_VALFAT
dDataUCom := TCQ->F2_EMISSAO

Do While !EOF()             
  dDataAux := SUBSTR(TCQ->F2_EMISSAO,5,2)+SUBSTR(TCQ->F2_EMISSAO,3,2)
  nAcumulo := 0
  Do While SUBSTR(TCQ->F2_EMISSAO,5,2)+SUBSTR(TCQ->F2_EMISSAO,3,2) = dDataAux
    If nMaiorFat < TCQ->F2_VALFAT
      nMaiorFat := TCQ->F2_VALFAT
      dDataMFat := TCQ->F2_EMISSAO
    Endif  
            
    nAcumulo  += TCQ->F2_VALFAT
      
    nUltCompr := TCQ->F2_VALFAT
    dDataUCom := TCQ->F2_EMISSAO
    
    TCQ->(DBSkip())
  Enddo   
  
  If nMaiorAcu < nAcumulo
    nMaiorAcu := nAcumulo
    dDataMAcu := dDataAux
  Endif  
  
Enddo

cQuery  := "SELECT E1_VALOR, E1_BAIXA, E1_VENCREA, E1_SALDO "
cQuery  += "FROM "+RetSqlName("SE1")+" "
cQuery  += "WHERE "                     //E1_FILIAL = '"+xFilial("SE1")+ "' AND
cQuery  += "(E1_CLIENTE = '"+ MV_PAR01 +"') AND (E1_TIPO NOT IN('NCC','AB-','JP','RA')) AND D_E_L_E_T_ <> '*' " 
cQuery  += "ORDER BY E1_VENCREA"
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TMP", .F.)

DBSelectArea("TMP")            
DBGotop()
         
nDebAVenc := 0
nDebVenci := 0              
nPgEmDia  := 0
nPgAtrazo := 0
nSomaValor := 0
Do While !EOF()            
  IF EMPTY(TMP->E1_BAIXA) 
    dAuxDVenc := CTOD(SUBSTR(TMP->E1_VENCREA,7,2)+"/"+SUBSTR(TMP->E1_VENCREA,5,2)+"/"+SUBSTR(TMP->E1_VENCREA,1,4))
    If dDataBase > dAuxDVenc 
      nDebVenci += TMP->E1_SALDO
      nPgAtrazo += (dAuxDVenc -dDataBase)*TMP->E1_SALDO
    Else 
      nDebAVenc += TMP->E1_SALDO 
    Endif   
    nSomaValor += TMP->E1_SALDO  
  Else 
    dAuxDBaixa := CTOD(SUBSTR(TMP->E1_BAIXA,7,2)+"/"+SUBSTR(TMP->E1_BAIXA,5,2)+"/"+SUBSTR(TMP->E1_BAIXA,1,4))
    dAuxDVenc  := ctod(SUBSTR(TMP->E1_VENCREA,7,2)+"/"+SUBSTR(TMP->E1_VENCREA,5,2)+"/"+SUBSTR(TMP->E1_VENCREA,1,4))
    If dAuxDBaixa > dAuxDVenc 
      nPgAtrazo += (dAuxDBaixa -dAuxDVenc)*TMP->E1_VALOR
//    Else
//      nPgEmDia  += 1
    Endif
    nSomaValor += TMP->E1_VALOR
  Endif  
  
  TMP->(DBSkip())
Enddo

DBSelectArea("TMP") 
Dbcloseare()

oPrn:= TMSPrinter():New( "Informações Comerciais" )
oPrn:SetPortrait()      // ou SetLandscape()

AVPRINT oPrn NAME "Informações Comerciais"

oFont1 := TFont():New("Arial"      ,9,09,.F.,.F.,5,.T.,5,.T.,.F.)
oFont2 := TFont():New("Arial"      ,9,14,.F.,.F.,5,.F.,5,.T.,.F.) 
oFont3 := TFont():New("Arial"      ,9,16,.F.,.F.,5,.T.,5,.T.,.F.)
oFont4 := TFont():New("Arial"      ,9,22,.F.,.F.,5,.T.,5,.T.,.F.) 
oFont5 := TFont():New("Courier New",9,14,.F.,.F.,5,.F.,5,.T.,.F.)
oFont6 := TFont():New("Arial"      ,9,14,.F.,.F.,5,.T.,5,.T.,.F.)
oFont7 := TFont():New("Arial"      ,9,10,.F.,.F.,5,.T.,5,.T.,.F.) 

AVPAGE

nLin := 080
nCol := 060
                               
DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+MV_PAR01)

oPrn:Say (nLin,nCol+700,"INFORMAÇÃO COMERCIAL",oFont4)
nLin += 120
oPrn:Say (nLin,nCol+950,"FAX.: "+MV_PAR02,oFont3)      
nLin += 350
oPrn:Say (nLin,nCol,"À "+MV_PAR03 ,oFont3)
nLin += 80
oPrn:Say (nLin,nCol,"A/C DEPTO DE CRÉDITO E COBRANÇA",oFont3)
nLin += 200
oPrn:Say (nLin,nCol,cSolic1,oFont5)
nLin += 50 
oPrn:Say (nLin,nCol,cSolic2,oFont5)
nLin += 50 
oPrn:Say (nLin,nCol,cSolic3,oFont5)
nLin += 200
oPrn:Say (nLin,nCol    ,"RAZÃO SOCIAL ",oFont6)
oPrn:Say (nLin,nCol+750,SA1->A1_NOME   ,oFont2)
nLin += 70
oPrn:Say (nLin,nCol    ,"CIDADE "                             ,oFont6) 
oPrn:Say (nLin,nCol+750,ALLTRIM(SA1->A1_MUN)+" - "+SA1->A1_EST,oFont2)
nLin += 70 
oPrn:Say (nLin,nCol    ,"C.N.P.J. "                                   ,oFont6)
oPrn:Say (nLin,nCol+750,Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont2)
nLin += 70 
oPrn:Say (nLin,nCol    ,"CLIENTE DESDE "    ,oFont6)
oPrn:Say (nLin,nCol+750,DTOC(SA1->A1_PRICOM),oFont2)
nLin += 170
dAux := SUBSTR(dDataMFat,7,2)+"/"+SUBSTR(dDataMFat,5,2)+"/"+SUBSTR(dDataMFat,3,2)
oPrn:Say (nLin,nCol     ,"MAIOR FATURA(DATA) " ,oFont6)
oPrn:Say (nLin,nCol+0750,dAux                  ,oFont2)
oPrn:Say (nLin,nCol+1200,"VALOR(R$)"           ,oFont6) 
oPrn:Say (nLin,nCol+1700,ALLTRIM(Transform(nMaiorFat,"@E 999,999,999.99")),oFont2)
nLin += 70 
dAux := SUBSTR(dDataUCom,7,2)+"/"+SUBSTR(dDataUCom,5,2)+"/"+SUBSTR(dDataUCom,3,2)
oPrn:Say (nLin,nCol     ,"ÚLTIMA COMPRA(DATA)" ,oFont6)
oPrn:Say (nLin,nCol+0750,dAux                  ,oFont2)
oPrn:Say (nLin,nCol+1200,"VALOR(R$)"           ,oFont6)
oPrn:Say (nLin,nCol+1700,ALLTRIM(Transform(nUltCompr,"@E 999,999,999.99")),oFont2)
nLin += 70                         
/*dAux := SUBSTR(dDataMAcu,1,2)+"/"+SUBSTR(dDataMAcu,3,2)
oPrn:Say (nLin,nCol     ,"MAIOR ACÚMULO(DATA)" ,oFont6)
oPrn:Say (nLin,nCol+0750,dAux                  ,oFont2)
oPrn:Say (nLin,nCol+1200,"VALOR(R$)"           ,oFont6)
oPrn:Say (nLin,nCol+1700,ALLTRIM(Transform(nMaiorAcu,"@E 999,999,999.99")),oFont2)
*/
oPrn:Say (nLin,nCol     ,"MAIOR ACÚMULO" ,oFont6)
oPrn:Say (nLin,nCol+1200,"VALOR(R$)"           ,oFont6)
oPrn:Say (nLin,nCol+1700,ALLTRIM(Transform(nMaiorAcu,"@E 999,999,999.99")),oFont2)

nLin += 70                         
oPrn:Say (nLin,nCol     ,"A VENCER(R$)"        ,oFont6)
oPrn:Say (nLin,nCol+0750,ALLTRIM(Transform(nDebAVenc,"@E 999,999,999.99")),oFont2)
oPrn:Say (nLin,nCol+1200,"VENCIDOS(R$)"        ,oFont6)
oPrn:Say (nLin,nCol+1700,ALLTRIM(Transform(nDebVenci,"@E 999,999,999.99")),oFont2)                                                                         
nLin += 70                        
oPrn:Say (nLin,nCol     ,"MEDIA DE ATRASO(DIAS)"            ,oFont6)
oPrn:Say (nLin,nCol+0750,IF(nSomaValor > 0,transform(round(nPgAtrazo/nSomaValor,0),"9999"),"0(Zero)"),oFont2)
nLin += 500                        
oPrn:Say (nLin,nCol,"Matão,"+STRZERO(DAY(dDataBase),2,0)+" de "+MesExtenso()+" de "+STRZERO(YEAR(dDataBase),4,0),oFont7)
nLin += 750
oPrn:Say (nLin,nCol,"BRASILUX TINTAS TÉCNICAS LTDA."      ,oFont7)
nLin += 50
oPrn:Say (nLin,nCol,"Rua Ítalo Ferreira, 300 - Bairro Primavera - CEP 15990-670 - Matão-SP  -  Fone.: (16) 283.7000",oFont1)
nLin += 50
oPrn:Say (nLin,nCol,"www.brasilux.com.br    -     E-mail: brasilux@brasilux.com.br",oFont1)

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

DBSelectArea("TCQ") 
Dbcloseare()

Return  


//////////////////////////////////////////////////
// Programa  : VALIDPERG   Autor:  Marcos Cesar //    
// Data      : 01/10/02                         //
// Descricao : Grava Perguntas                  //
//////////////////////////////////////////////////

Static Function ValidPerg()
Local i, j
Local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={} 

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01 SA1   Cliente:          //
// MV_PAR02       FAX Destino:      //
// MV_PAR03       Para:             //
//=//=//=//=//=//=//=//=//=//=//=//=//

//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Cliente ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
AADD(aRegs,{cPerg,"02","Fax     ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
AADD(aRegs,{cPerg,"03","Para    ?","","","mv_ch3","C",40,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})

For i:=1 to Len(aRegs)
  If !dbSeek(cPerg+aRegs[i,2])
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
