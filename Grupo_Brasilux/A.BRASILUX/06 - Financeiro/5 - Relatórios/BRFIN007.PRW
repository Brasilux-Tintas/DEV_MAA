#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN007 ºAutor  ³                    º Data ³  30/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar e Emitir duplicatas                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN007()
     Local aMarked := {}     

   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
       
     SetPrvt("Exec,cPerg,cQuery,cFilSel,cFiltro")


//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01 SE1   Do Titulo:        //
// MV_PAR02 SE1   Ate o Titulo:     //
// MV_PAR03 SE1   Do Cliente:       //
// MV_PAR04 SE1   Ate o Cliente:    //
// MV_PAR05 SE1   Da Emissão:       //
// MV_PAR06 SE1   Ate a Emissão     //   
// MV_PAR07       Imp. 2a. Via      //
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg   := "FIN007"             
VldPerg()    
cFiltro := ""
cFilSel := " "
nOpcA   := 0
i       := 1    

oDlg    := oSend( MSDialog(), "New", 8, 10, 18, 63,"Seleção/Impressão de Duplicatas",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,13  SAY "Este programa tem como funcao imprimir duplicatas apartir de um FILTRO com"
@ 30,13  SAY "parametros ou atraves de uma ORDEM de titulos selecionados pelo usuario.  "
@ 57,130 BMPBUTTON TYPE 17 ACTION (cFilSel := "F",Pergunte(cPerg))
@ 57,170 BMPBUTTON TYPE 09 ACTION (cFilSel := "S",SelDup())

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0 
  Return
EndIf

MsAguarde({|| MontaFiltro() },"Aguarde","Atualizando arquivo com dados do Ctas a Receber")

If cFilSel == "F"
  DBSelectArea("SE1")            
  DBGotop()
  If EOF()
    MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
    DBSelectArea("SE1") 
    DBClearFilter()
    Return
  Endif

  @ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
  @ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
  @ 180,310 BMPBUTTON TYPE 01 ACTION (Exec := .T.,Close(oDlg))
  @ 180,280 BMPBUTTON TYPE 02 ACTION (Exec := .F.,Close(oDlg))
  ACTIVATE DIALOG oDlg CENTERED  
   
  SE1->(DBGotop())
  Do While !Eof()
    If Marked("E1_OK")
      AADD(aMarked,.T.)
    Else
      AADD(aMarked,.F.)
    EndIf
    SE1->(DBSkip())
  EndDo
Else
  DBSelectArea("TCQ")            
  DBGotop()
  If EOF()
    MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
    DBSelectArea("TCQ") 
    Dbcloseare()
    Return
  Endif  
  Exec := .T.
EndIf
 
If Exec 
  If cFilSel == "F"
    SE1->(DBGoTop() )
    Processa({|lEnd|MontaRel1(aMarked)})
    DBSelectArea("SE1") 
    DBClearFilter()
  Else               
    TCQ->(DBGoTop() )
    Processa({|lEnd|MontaRel2(aMarked)})
    DBSelectArea("TCQ") 
    Dbcloseare()
  EndIf  
Endif      

Return Nil




*---------------------------*                         
Static Function SelDup()  
*---------------------------*
         
cDuplic := SPACE(08)
nLin    := 010
nCol    := 090          
nLista  := 1
cFiltro := ""

@ 001,001 TO 200,510 DIALOG oDlg1 TITLE "Ordem de Duplicatas Selecionadas"
                            
@ 010,015 SAY "Tit./Parc." 
@ 010,045 GET cDuplic PICTURE '@!' Valid !VAZIO() 
     
@ 005,085 to 080,255
@ 085,150 BMPBUTTON TYPE 10 ACTION GravaDup()
@ 085,180 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
@ 085,210 BMPBUTTON TYPE 01 ACTION Close(oDlg1)
 
ACTIVATE DIALOG oDlg1 CENTERED  

Return 




*---------------------------*                         
Static Function GravaDup()  
*---------------------------*
  
If nLista == 6
  MsgStop("Capacidade para selecao completa. Imprima a selecao.")
  Close(oDlg1)
Endif  
                                  
@ nLin,nCol SAY cDuplic
cFiltro += "'"+cDuplic+"',"
nLin    += 10

If nLin == 70 
  nLin   := 010
  nCol   += 30 
  nLista += 1
Endif  

Return

                         
*---------------------------*                         
Static Function MontaFiltro()  
*---------------------------*
DBSelectArea("SE1") 
If cFilSel == "F"
  Set Filter to E1_FILIAL = xFilial("SE1") .AND. ;
                E1_TIPO # "CH " .AND. E1_TIPO # "NCC" .AND. ;
                E1_NUM >= MV_PAR01 .AND. E1_NUM <= MV_PAR02 .AND. ;
                E1_CLIENTE >= MV_PAR03 .AND. E1_CLIENTE <= MV_PAR04 .AND. ;
                E1_EMISSAO >= MV_PAR05 .AND. E1_EMISSAO <= MV_PAR06 
Else      
  cFiltro := Substr(cFiltro,2,len(cFiltro)-3)
  cQuery  := "SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_PORTADO,E1_CLIENTE,E1_LOJA,E1_OK,"
  cQuery  += "E1_NOMCLI,E1_EMISSAO,E1_VENCTO,E1_VENCREA,E1_VALOR,E1_AGEDEP,E1_VEND1,E1_PEDIDO "
  cQuery  += "FROM "+RetSqlName("SE1")+" "
  cQuery  += "WHERE E1_FILIAL = '"+xFilial("SE1")+ "' AND "                     
  cQuery  += "E1_NUM+E1_PARCELA IN ('"+ cFiltro +"') AND D_E_L_E_T_ <> '*' " 
  cQuery  += "ORDER BY E1_PREFIXO,E1_NUM,E1_PARCELA,E1_CLIENTE,E1_LOJA,E1_EMISSAO"
  TCQuery cQuery NEW ALIAS "TCQ" 
  //cQuery  := ChangeQuery(cQuery)
  //DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
Endif                

Return
             


*--------------------------------*
Static Function MontaRel1(aMarked) 
*--------------------------------*

SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3,CSTRING,ARETURN")
SetPrvt("CPERG,NLASTKEY,LI,CSAVSCR1,CSAVCUR1,CSAVROW1")
SetPrvt("CSAVCOL1,CSAVCOR1,WNREL")       

tamanho  := "P" 
limite   := 80
titulo   := "EMISSAO DE DUPLICATAS"
cDesc1   := "Este programa ira emitir duplicatas conforme"
cDesc2   := "selecao anterior."
cDesc3   := ""
cString  := "SE1"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
cPerg    := ""
nLastKey := 0
nLin     := 0
nCont    := 1                              
wnrel    := "BRFIN007" 
wnrel    := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,)
nNroVias := 0

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif  

DBSelectArea("SE1") 
nRec := 0
Do While !EOF()
  nRec := nRec + 1
  DBSkip()
EndDo                         

if type("MV_PAR07") = "C"
	IF MV_PAR07 != "SIM"
  		MV_PAR07 := 0   
	else
  		MV_PAR07 := 2
	endif
else 
	MV_PAR07 := 0		
ENDIF  

Do While MV_PAR07 >= nNroVias
  I := 1
  
  DBSelectArea("SE1") 
  DBGoTop()
  ProcRegua(nRec)
  Do While !EOF()    
    If aMarked[i]
      SF2->(DbSetOrder(1))
      SF2->(DbSeek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO))

      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
 
      If nCont == 1          
        nLin := 0
        @ nLin,001 PSAY " "
        nLin := nLin + 6				
      Endif  
 
      @ nLin,048 PSAY DTOC(SE1->E1_EMISSAO)
      @ nLin,075 PSAY SE1->E1_NUM
      nLin := nLin + 2
  
      @ nLin,002 PSAY SF2->F2_VALFAT    PICTURE '@RE 9,999,999.99'
      @ nLin,018 PSAY SE1->E1_NUM	                                
      @ nLin,029 PSAY SE1->E1_VALOR    PICTURE '@RE 999,999,999.99'	  
      @ nLin,048 PSAY alltrim(SE1->E1_NUM)+"/"+SE1->E1_PARCELA
      @ nLin,061 PSAY DTOC(SE1->E1_VENCTO)                                                                               
      nLin := nLin + 1
  
      @ nlin,070 PSAY "Ped: "+SE1->E1_PEDIDO
      nLin := nLin + 1
      @ nlin,070 PSAY "Bco: "+SE1->E1_PORTADO 
      nLin := nLin + 1
      @ nlin,070 PSAY "Rep: "+SE1->E1_VEND1   
      nLin := nLin + 2
  
      @ nLin,021 PSAY SE1->E1_CLIENTE+"-"+SA1->A1_NOME
      nLin := nLin + 1
  
      @ nLin,021 PSAY SA1->A1_END+TRIM(SA1->A1_DDD)+TRIM(SA1->A1_TEL)
      nLin := nLin + 1
  
      @ nLin,021 PSAY SA1->A1_CEP		PICTURE '@R 99.999-999'
      @ nLin,038 PSAY SA1->A1_MUN
      @ nLin,078 PSAY SA1->A1_EST
      nLin := nLin + 1
  
      @ nLin,021 PSAY SA1->A1_CEPC		PICTURE '@R 99.999-999'
      @ nLin,038 PSAY ALLTRIM(SA1->A1_MUNC)+" - "+SA1->A1_ESTC    
      nLin := nLin + 1
  
      @ nLin,021 PSAY SA1->A1_ENDCOB
      nLin := nLin + 2
  
      @ nLin,021 PSAY SA1->A1_CGC PICTURE If(Len(SA1->A1_CGC)==11,'@R 999.999.999-99','@R 99.999.999/9999-99')
      @ nLin,062 PSAY SA1->A1_INSCR
      nLin := nLin + 3
  
      @ nLin,021 PSAY Subs(RTRIM(SUBS(EXTENSO(SE1->E1_VALOR),1,50)) + REPLICATE("*",50),1,50)
      nLin := nLin + 1
  
      @ nLin,021 PSAY Subs(RTRIM(SUBS(EXTENSO(SE1->E1_VALOR),51,50)) + REPLICATE("*",50),1,50) 
      nLin := nLin + 1
  
      @ nLin,021 PSAY Subs(RTRIM(SUBS(EXTENSO(SE1->E1_VALOR),101,50)) + REPLICATE("*",50),1,50)
	  	 
      If nCont > 1
        Eject
        SetPrc(0,0)
	    nCont := 1   	  
      Else 
        nLin  := nLin  + 19
        nCont := nCont + 1
      Endif  
    EndIf   
  
    DBSelectArea("SE1") 
    DBSkip()
    IncProc()
    i := i + 1
  
  EndDo   

  nNroVias += 1
  
  IF MV_PAR07 == 1 .AND. MV_PAR07 >= nNroVias
    IF !MsgYesNo("TROQUE DE FORMULÁRIO, SERÁ IMPRESSO 2a. VIA ? ","Pergunta")
      Exit
    Endif
  ENDIF
Enddo

@ nLin,000 PSAY CHR(18)  


If aReturn[5] == 1   // Se impressao em Disco, chama Spool. 
  Set Printer To 
  dbCommitAll()
  ourspool(wnrel)
Endif

FT_PFLUSH()          // Libera relatorio para Spool da Rede.   

Return nil 



*--------------------------------*
Static Function MontaRel2(aMarked) 
*--------------------------------*

SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3,CSTRING,ARETURN")
SetPrvt("CPERG,NLASTKEY,LI,CSAVSCR1,CSAVCUR1,CSAVROW1")
SetPrvt("CSAVCOL1,CSAVCOR1,WNREL")       

tamanho  := "P" 
limite   := 80
titulo   := "EMISSAO DE DUPLICATAS"
cDesc1   := "Este programa ira emitir duplicatas conforme"
cDesc2   := "selecao anterior."
cDesc3   := ""
cString  := "TCQ"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
cPerg    := ""
nLastKey := 0
nLin     := 0
nCont    := 1                              
wnrel    := "BRFIN007" 
wnrel    := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,)      
nNroVias := 0


If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif  

DBSelectArea("TCQ") 
nRec := 0
Do While !EOF()
  nRec := nRec + 1
  DBSkip()
EndDo                         

IF TYPE("MV_PAR07") = "C"
	IF MV_PAR07 != "SIM"
  		MV_PAR07 := 0   
	else
  		MV_PAR07 := 2
	endif 
else
	MV_PAR07 := 0	
ENDIF  

Do While MV_PAR07 >= nNroVias

  DBSelectArea("TCQ") 
  DBGoTop()
  ProcRegua(nRec)
  Do While !EOF()    
    SF2->(DbSetOrder(1))
    SF2->(DbSeek(xFilial("SF2")+TCQ->E1_NUM+TCQ->E1_PREFIXO))
  
    SA1->(DbSetOrder(1))
    SA1->(DbSeek(xFilial("SA1")+TCQ->E1_CLIENTE+TCQ->E1_LOJA))
 
    If nCont == 1          
      nLin := 0
      @ nLin,001 PSAY " "
      nLin := nLin + 6				
    Endif  
  
    cAux := SUBSTR(TCQ->E1_EMISSAO,7,2)+"/"+SUBSTR(TCQ->E1_EMISSAO,5,2)+"/"+SUBSTR(TCQ->E1_EMISSAO,3,2)
    @ nLin,048 PSAY cAux	 
    @ nLin,075 PSAY TCQ->E1_NUM
    nLin := nLin + 2
  
    @ nLin,002 PSAY SF2->F2_VALFAT    PICTURE '@RE 9,999,999.99'
    @ nLin,018 PSAY alltrim(TCQ->E1_NUM)
    @ nLin,029 PSAY TCQ->E1_VALOR    PICTURE '@RE 999,999,999.99'	  
    @ nLin,048 PSAY alltrim(TCQ->E1_NUM)+"/"+TCQ->E1_PARCELA
    cAux := SUBSTR(TCQ->E1_VENCTO,7,2)+"/"+SUBSTR(TCQ->E1_VENCTO,5,2)+"/"+SUBSTR(TCQ->E1_VENCTO,3,2)
    @ nLin,061 PSAY cAux 
    nLin := nLin + 1

    @ nlin,070 PSAY "Ped: "+TCQ->E1_PEDIDO
    nLin := nLin + 1
    @ nlin,070 PSAY "Bco: "+TCQ->E1_PORTADO 
    nLin := nLin + 1
    @ nlin,070 PSAY "Rep: "+TCQ->E1_VEND1   
    nLin := nLin + 2
  
    @ nLin,021 PSAY TCQ->E1_CLIENTE+"-"+SA1->A1_NOME
    nLin := nLin + 1

    @ nLin,021 PSAY SA1->A1_END+TRIM(SA1->A1_DDD)+'-'+SA1->A1_TEL
    nLin := nLin + 1

    @ nLin,021 PSAY SA1->A1_CEP		PICTURE '@R 99.999-999'
    @ nLin,038 PSAY SA1->A1_MUN
    @ nLin,078 PSAY SA1->A1_EST
    nLin := nLin + 1

    @ nLin,021 PSAY SA1->A1_CEPC		PICTURE '@R 99.999-999'
    @ nLin,038 PSAY ALLTRIM(SA1->A1_MUNC)+" - "+SA1->A1_ESTC    
    nLin := nLin + 1
  
    @ nLin,021 PSAY SA1->A1_ENDCOB
    nLin := nLin + 2

    @ nLin,021 PSAY SA1->A1_CGC PICTURE If(Len(SA1->A1_CGC)==11,'@R 999.999.999-99','@R 99.999.999/9999-99')
    @ nLin,062 PSAY SA1->A1_INSCR
    nLin := nLin + 3
 
    @ nLin,021 PSAY Subs(RTRIM(SUBS(EXTENSO(TCQ->E1_VALOR),1,50)) + REPLICATE("*",50),1,50)
    nLin := nLin + 1

    @ nLin,021 PSAY Subs(RTRIM(SUBS(EXTENSO(TCQ->E1_VALOR),51,50)) + REPLICATE("*",50),1,50) 
    nLin := nLin + 1
  
    @ nLin,021 PSAY Subs(RTRIM(SUBS(EXTENSO(TCQ->E1_VALOR),101,50)) + REPLICATE("*",50),1,50)
	  	 
    If nCont > 1
      Eject
      SetPrc(0,0)
      nCont := 1   	  
    Else 
      nLin  := nLin  + 19
      nCont := nCont + 1
    Endif  
  
    DBSelectArea("TCQ") 
    DBSkip()
    IncProc()
   
  EndDo   
 
  nNroVias += 1

  IF MV_PAR07 == 1 .AND. MV_PAR07 >= nNroVias
    IF !MsgYesNo("TROQUE DE FORMULÁRIO, SERÁ IMPRESSO 2a. VIA ? ","Pergunta")
      Exit
    Endif
  ENDIF                

Enddo

@ nLin,000 PSAY CHR(18)  

If aReturn[5] == 1   // Se impressao em Disco, chama Spool. 
  Set Printer To 
  dbCommitAll()
  ourspool(wnrel)
Endif

FT_PFLUSH()          // Libera relatorio para Spool da Rede.   

Return nil

      

//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
// Função....: VldPerg                             //
// Data......: 26/09/02                            //
// Descrição.: Verifica as perguntas incluindo-as  //
//             caso não existam                    //
// Uso.......: BRFIN007                            //
//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//

*-----------------------*
Static Function VldPerg() 
*-----------------------*
      Local i, j  
Local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01 SE1   Do Titulo:        //
// MV_PAR02 SE1   Ate o Titulo:     //
// MV_PAR03 SE1   Do Cliente:       //
// MV_PAR04 SE1   Ate o Cliente:    //
// MV_PAR05 SE1   Da Emissão:       //
// MV_PAR06 SE1   Ate a Emissão     // 
// MV_PAR07       Imp. 2a. Via      //
//=//=//=//=//=//=//=//=//=//=//=//=//

cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Do  Titulo   ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"02","Ate Titulo   ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"03","Do  Cliente  ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
aAdd(aRegs,{cPerg,"04","Ate Cliente  ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
aAdd(aRegs,{cPerg,"05","Da  Emissao  ?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"06","Ate Emissao  ?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"07","Imp.2a. Via  ?","","","mv_ch7","C",03,0,1,"C","","mv_par07","SIM"   ,"","","","","NAO"  ,"","","","","","","","","","","","","","","","","","","",""})

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