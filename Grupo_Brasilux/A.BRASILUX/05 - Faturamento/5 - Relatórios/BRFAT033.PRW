#include "rwmake.ch"    
#include "TOPCONN.CH"     


/////////////////////////////////////////////////
//                                             //
// Funçào....: BRFAT033     Data....: 19.06.01 //
// Autor.....:            //
// Descriçào.: Emissao de Duplicatas           //
// Uso.......: Brasilux/Brasitec/Resina        //
//                                             //
/////////////////////////////////////////////////     


User Function BRFAT033()

//=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=//
// Declaracao de variaveis utilizadas no programa atraves da funcao    //
// SetPrvt, que criara somente as variaveis definidas pelo usuario,    //
// identificando as variaveis publicas do sistema utilizadas no codigo //
//=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=//

SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3,CSTRING,ARETURN")
SetPrvt("CPERG,NLASTKEY,LI,CSAVSCR1,CSAVCUR1,CSAVROW1")
SetPrvt("CSAVCOL1,CSAVCOR1,WNREL")       

Private tamanho  := "P" 
Private limite   := 80
Private titulo   := "EMISSAO DE DUPLICATAS"
Private cDesc1   := "Este programa irá emitir duplicatas conforme"
Private cDesc2   := "parametros especificados."
Private cDesc3   := ""
Private cString  := "SE1"
Private aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg    := "BRFT33"
Private nLastKey := 0
Private nLin     := 0
Private nCont    := 1
Private wnrel    :=""
 if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
                                     
//////////////////////////////////////
//|                                |//
//| mv_par01 <...> Data Emissao de |//
//| mv_par02 <...> Data Emissao ate|//
//| mv_par03 <...> Duplicata   de  |//
//| mv_par04 <...> Parcela     de  |//
//| mv_par05 <...> Duplicata   ate |//
//| mv_par06 <...> Parcela     ate |//
//| mv_par07 <...> Serie           |//
//|                                |//
//////////////////////////////////////

VldPerg() // Verifica as perguntas selecionadas    
Pergunte("BRFT33",.F.)

//+-----------------------------------------+
//¦ Envia controle para a funcao SETPRINT.  ¦
//+-----------------------------------------+
wnrel:="BRFAT033" 

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,)

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif

RptStatus({|| RptDetail()}) 
Return

Static Function RptDetail()
Local _count    :=0
Local cQuery    :=""                              
Local cInterv01 :=""
Local cInterv02 :=""
Local nLin      :=0
Local cAux      :=""
cInterv01 := (MV_PAR03+MV_PAR04)
cInterv02 := (MV_PAR05+MV_PAR06)

cQuery := "SELECT * "
cQuery := cQuery + " FROM "+RetSqlName("SE1") 
cQuery := cQuery + " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "
cQuery := cQuery + " E1_PREFIXO = '"+MV_PAR07+"' AND " 
cQuery := cQuery + " E1_EMISSAO BETWEEN  '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND "
cQuery := cQuery + " (E1_NUM+E1_PARCELA) BETWEEN '"+cInterv01+"' AND '"+cInterv02+"' AND "
cQuery := cQuery + " D_E_L_E_T_ <> '*' "
cQuery := cQuery + " ORDER BY E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO "
//TCQuery Abre uma workarea com o resultado da query
TCQUERY cQuery NEW ALIAS "TMP"
dbSelectArea("TMP")
dbGoTop()                    

_count:=0
While !Eof()
  _count:=_count+1
  DBSKIP()           
Enddo              
dbSelectArea("TMP")
DbGoTop()

SetRegua(_count)
  
Do While ! eof() 
  DbSelectArea("SF2")
  DbSetOrder(1)
  DbSeek(xFilial("SF2")+TMP->E1_NUM+TMP->E1_PREFIXO)

  DbSelectArea("SA1")
  DbSetOrder(1)
  DbSeek(xFilial("SA1")+TMP->E1_CLIENTE+TMP->E1_LOJA)
  DbSelectArea("TMP")        
  
  If nCont == 1          
    nLin := 0
    @ nLin,001 PSAY " "
    nLin := nLin + 6				
  Endif  
 
  cAux := SUBSTR(TMP->E1_EMISSAO,7,2)+"/"+SUBSTR(TMP->E1_EMISSAO,5,2)+"/"+SUBSTR(TMP->E1_EMISSAO,3,2)
  @ nLin,048 PSAY cAux	 
  @ nLin,075 PSAY TMP->E1_NUM
  nLin := nLin + 2
  
  @ nLin,000 PSAY SF2->F2_VALFAT    PICTURE '@RE 9,999,999.99'
  @ nLin,016 PSAY TMP->E1_NUM	                                
  @ nLin,029 PSAY TMP->E1_VALOR    PICTURE '@RE 999,999,999.99'	  
  @ nLin,047 PSAY TMP->E1_NUM+"/"+TMP->E1_PARCELA
  cAux := SUBSTR(TMP->E1_VENCREA,7,2)+"/"+SUBSTR(TMP->E1_VENCREA,5,2)+"/"+SUBSTR(TMP->E1_VENCREA,3,2)
  @ nLin,061 PSAY cAux                                                                               
  nLin := nLin + 1
  
  @ nlin,071 PSAY "Ped: "+TMP->E1_PEDIDO
  nLin := nLin + 1
  @ nlin,071 PSAY "Bco: "+TMP->E1_PORTADO 
  nLin := nLin + 1
  @ nlin,071 PSAY "Ag.: "+TMP->E1_AGEDEP 
  nLin := nLin + 1
  @ nlin,071 PSAY "Rep: "+TMP->E1_VEND1   
  nLin := nLin + 1
  
  @ nLin,020 PSAY TMP->E1_CLIENTE+"-"+SA1->A1_NOME
  nLin := nLin + 1
  
  @ nLin,020 PSAY SA1->A1_END+"  -Tel: "+SA1->A1_TEL
  nLin := nLin + 1
  
  @ nLin,020 PSAY SA1->A1_CEP		PICTURE '@R 99.999-999'
  @ nLin,038 PSAY SA1->A1_MUN
  @ nLin,079 PSAY SA1->A1_EST
  nLin := nLin + 1
  
  @ nLin,020 PSAY SA1->A1_CEPC		PICTURE '@R 99.999-999'
  @ nLin,038 PSAY ALLTRIM(SA1->A1_MUNC)+" - "+SA1->A1_ESTC    
  nLin := nLin + 1
  
  @ nLin,020 PSAY SA1->A1_ENDCOB
  nLin := nLin + 2
  
  @ nLin,020 PSAY SA1->A1_CGC PICTURE If(Len(SA1->A1_CGC)==11,'@R 999.999.999-99','@R 99.999.999/9999-99')
  @ nLin,063 PSAY SA1->A1_INSCR
  nLin := nLin + 3
  
  @ nLin,019 PSAY Subs(RTRIM(SUBS(EXTENSO(TMP->E1_VALOR),1,50)) + REPLICATE("*",50),1,50)
  nLin := nLin + 1
  
  @ nLin,019 PSAY Subs(RTRIM(SUBS(EXTENSO(TMP->E1_VALOR),51,50)) + REPLICATE("*",50),1,50) 
  nLin := nLin + 1
  
  @ nLin,019 PSAY Subs(RTRIM(SUBS(EXTENSO(TMP->E1_VALOR),101,50)) + REPLICATE("*",50),1,50)
	  	 
  If nCont > 1
    Eject
	SetPrc(0,0)
	nCont := 1   	  
  Else 
    nLin  := nLin  + 19
    nCont := nCont + 1
  Endif  
	         
  DbSelectArea("TMP")        	  
  IncRegua(_count)
  DBSKIP()
  _count :=_count+1
    
Enddo
@ nLin,000 PSAY CHR(18)  

dbSelectArea("TMP")
dbCloseArea() 
DbSelectArea("SE1")
DbSetOrder(1)
DbSelectArea("SA1")
DbSetOrder(1)

If aReturn[5] == 1   // Se impressao em Disco, chama Spool. 
   Set Printer To 
   dbCommitAll()
   ourspool(wnrel)
Endif

//FT_PFLUSH()          // Libera relatorio para Spool da Rede.   

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldPerg  ³ Autor ³ Joao Vasconcelos      ³ Data ³ 16/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ BRFAT033                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 17/05/00 ==> Function VldPerg
Static Function VldPerg()  
Local j, i
Local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}
                       
//////////////////////////////////////
//|                                |//
//| mv_par01 <...> Data Emissao de |//
//| mv_par02 <...> Data Emissao ate|//
//| mv_par03 <...> Duplicata   de  |//
//| mv_par04 <...> Parcela     de  |//
//| mv_par05 <...> Duplicata   ate |//
//| mv_par06 <...> Parcela     ate |//
//| mv_par07 <...> Serie           |//
//|                                |//
//////////////////////////////////////
cPerg := PADR(cPerg,10)
aAdd(aRegs,{cPerg,"01","Dt.Emissao de    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01",""		 ,""		,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Dt.Emissao ate   ?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""		 ,""		,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Duplicata   de   ?","","","mv_ch3","C",06,0,0,"G","","mv_par03",""		 ,""		,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Parcela     de   ?","","","mv_ch4","C",01,0,0,"G","","mv_par04",""		 ,""	    ,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Duplicata   ate  ?","","","mv_ch5","C",06,0,0,"G","","mv_par05",""		 ,""	    ,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""}) 
aAdd(aRegs,{cPerg,"06","Parcela     ate  ?","","","mv_ch6","C",01,0,0,"G","","mv_par06",""		 ,""	    ,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Serie            ?","","","mv_ch7","C",03,0,0,"G","","mv_par07",""		 ,""	    ,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})

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