#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFIN018 บAutor  ณ 					 บ Data ณ  27/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integra็ใo para envio de duplicatas para Institui็ใo de Co-บฑฑ
ฑฑบ          ณ bran็a                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRFIN018()

SetPrvt("cPerg,cQuery,cAux")


//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//=//=//=//=//=//=//=//=//=//=//=//=//
//                                  //
//MV_PAR01 - Border๔ p/Inst.de Cobr.//
//                                  //
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg      := "FIN014"             
//VldPerg()    
nAux       := SPACE(40)
Linha      := 0                
nOpcA      := 0                
nPag       := 0
nValTotGer := 0 
oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Integra็ใo com a ABE p/envio de Tํtulos.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,18  SAY "Este processo tem como fun็ใo, gerar uma integra็ใo "
@ 30,18  SAY "com SoftWare da Inst.Cobr.ABE, gerando um arquivo do"
@ 40,18  SAY "tipo texto dos Tํtulo a serem cobrados.             "
@ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("FIN014"))

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0 
   Return
EndIf

MsAguarde({|| FilSE1FIN018() },"Aguarde","Em processando conforme parametros...")

DBSelectArea("TCQ")            
DBGotop()
If EOF()
  MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
  DBSelectArea("TCQ") 
  Dbcloseare()
  Return
Endif  

Processa({|lEnd|IntFIN018()})

DBSelectArea("TCQ") 
Dbcloseare()

Return Nil

                         
*----------------------------*                         
Static Function FilSE1FIN018()  
*----------------------------*                                          

cQuery  := "SELECT * "
cQuery  += "FROM "+RetSqlName("SE1")+ " WITH (NOLOCK) "
cQuery  += "WHERE E1_FILIAL = '"+xFilial("SE1")+ "' AND "
cQuery  += "E1_NUMBOR = '"+mv_par01+"' AND  D_E_L_E_T_ <> '*' "  
cQuery  += "ORDER BY E1_CLIENTE, E1_NUM, E1_PARCELA " 
//cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
  
Return 


*-------------------------*
Static Function IntFIN018() 
*-------------------------*                      
Local _cNumEmp,cNumEnv
cNumEnv := Soma1(GetMV("MV_NUMENVB"),2)    // Numero de borderos enviados เ Inst.Cobr.
_cNumEmp := ""   


IF cnumemp == "01010101"
  _cNumEmp := "011049"              
ELSEIF cnumemp == "01010104"
  _cNumEmp := "011050"              
ELSEIF cnumemp == "0301"
  _cNumEmp := "011051"              
ENDIF  

cArq  := "C:\ABE\BO"+_cNumEmp+cNumEnv+".TXT"
hFile := fCreate(cArq)

IF hFile < 0
  ALERT("NรO FOI POSSIVEL GERAR ARQUIVO DE INTEGRAวรO.")
  dbselectarea("TCQ")
  dbclosearea()
  Return
endif                
 
cBLinha := "REGISTRO DE CONTROLE - VERSAO 5" 
cBLinha += CHR(13)+CHR(10)
FWrite(hFile,cBLInha,len(cBLinha))

DBSelectArea("TCQ")            
DBGotop()
DO WHILE !EOF()
  cCliente   := TCQ->E1_CLIENTE
  nValTotCli := 0
  
  DBSelectArea("SA1")
  DBSetOrder(1)
  DBSeek(xFilial("SA1")+TCQ->E1_CLIENTE+TCQ->E1_LOJA)
  
  cBLinha := "1"+_cNumEmp
  cBLinha += SA1->A1_NOME+SPACE(20)+SA1->A1_NREDUZ+SPACE(20)
  cBLinha += SA1->A1_END +SPACE(20)+SA1->A1_BAIRRO+SA1->A1_CEP
  cBLinha += SUBSTR(SA1->A1_MUN,1,30)+SA1->A1_EST
  cBLinha += SA1->A1_TEL+SPACE(35)+SA1->A1_FAX+SPACE(10)
  cBLinha += SA1->A1_EMAIL+SPACE(40)
  cBLinha += IF(RIGHT(SA1->A1_CGC,2)= '  ',"F","J")+"0"+SA1->A1_CGC
  IF RIGHT(SA1->A1_CGC,2)= '  '
    cBLinha += REPLICATE("0",15)
  ELSE
    cBLinha += SUBSTR(SA1->A1_INSCR,1,15)  
  ENDIF                 
  cBLinha += SPACE(85)
  cBLinha += CHR(13)+CHR(10)
  FWrite(hFile,cBLInha,len(cBLinha))

  DBSelectArea("TCQ")
  DO WHILE !EOF() .AND. TCQ->E1_CLIENTE = cCliente   
    dVencto := SUBSTR(TCQ->E1_VENCTO,7,2)+SUBSTR(TCQ->E1_VENCTO,5,2)+SUBSTR(TCQ->E1_VENCTO,1,4)
    cBLinha := "2" 
    cBLinha += SUBSTR(TCQ->E1_TIPO,1,2)       
    cBLinha += TCQ->E1_PREFIXO+TCQ->E1_NUM+E1_PARCELA
    cBLinha += STRZERO(ROUND(TCQ->E1_SALDO*100,2),11) 
    cBLinha += dVencto    
    cBLinha += "00000000000"    // Valor de Protesto
    cBLinha += CHR(13)+CHR(10)
    FWrite(hFile,cBLInha,len(cBLinha))
    
    dbSelectArea("TCQ")
    DBSKIP() 
  ENDDO    
ENDDO  
fClose(hFile)
Alert("NOME DO ARQUIVO GERADO " + cArq + CHR(13)+CHR(10) +;
      "ESTA LOCALIZADO NA PASTA C:\ABE\ " + CHR(13)+CHR(10))

//LGS#20200120 - Adequa็ใo para release 12.1.25 e posteriores
//dbSelectArea("SX6")
GetMv("MV_NUMENVB")
//RecLock("SX6",.F.)
//SX6->X6_CONTEUD := cNumenv
//MsUnlock()            
PUTMV( "MV_NUMENVB", cNumenv )
Return nil 
    

//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
// Fun็ใo....: VldPerg                             //
// Data......: 14/03/03                            //
// Descri็ใo.: Verifica as perguntas incluindo-as  //
//             caso nใo existam                    //
// Uso.......: BRCON006                            //
//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
//LGS#20200120 - Adequa็ใo para release 12.1.25 e posteriores
/*
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
// MV_PAR01 SE1 - Border๔           // 
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Bordero ? ","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

Return*/