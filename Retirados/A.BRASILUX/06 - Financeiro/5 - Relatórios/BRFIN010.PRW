#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN010 ºAutor  ³ Cleber O. Dominguesº Data ³  12/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar e Emitir Boletos Bancários                      º±±
±±º 10/01/06 ³ Cleber                                                     º±±
±±º          ³ Valdo pediu pARA filtrar apenas boletos com pagamento à    º±±
±±º          ³ vista                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN010()
Local aMarked := {}       
Local Exec,i,cPerg
Private cFiltro := "",cFilSel := "",mv_par01,mv_par02,mv_par03
cPerg := "BRFI10"
ValidPerg(cPerg)
cFiltro := ""
cFilSel := " "
nOpcA   := 0
i       := 1
oDlg    := oSend( MSDialog(), "New", 8, 10, 18, 63,"Seleção/Impressão de Boletos",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

@ 20,13  SAY "Este programa tem como funcao imprimir boletos bancários do BANCO DO BRASIL"
@ 30,13  SAY "para as Notas Fiscais Selecionadas                                        "

@ 57,130 BMPBUTTON TYPE 05 ACTION (cFilSel := "F",Pergunte(cPerg))
//@ 57,130 BUTTON OemToAnsi("Impr Marcados")  SIZE 40,16 ACTION SelDup(1)
@ 57,170 BMPBUTTON TYPE 09 ACTION (cFilSel := "S",SelDup())

bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
If nOpca == 0 
   Return
EndIf
       
MsAguarde({|| MontaFiltro() },"Atualizando arquivo com dados do Ctas a Receber")

DBSelectArea("TCQ")            
DBGotop()
If EOF()
    MSGSTOP("Nenhuma Ocorrencia!")
    DBSelectArea("TCQ") 
    Dbclosearea()
    Exec = .f.
else
  	Exec := .T.
endif 
 
If Exec 
    TCQ->(DBGoTop() )
    Processa({|lEnd|MontaRel2(aMarked)})
    DBSelectArea("TCQ") 
    Dbclosearea()
Endif      

Return Nil



*---------------------------*                         
Static Function SelDup()  
*---------------------------*
Private nLista,nLin,nCol,cNf
cNf := SPACE(10)
nLin    := 010
nCol    := 090          
nLista  := 1
cFiltro := ""
if mv_par01 == 1
	@ 001,001 TO 200,510 DIALOG oDlg1 TITLE "Selecao de Notas Fiscais"
                            
	@ 010,012 SAY "NF/Serie" 
	@ 010,041 GET cNf PICTURE '@R! 999999XXX/XXX' Valid ExistNf(cNf)
     
	@ 005,085 to 080,255
	@ 085,150 BMPBUTTON TYPE 10 ACTION GravaDup()
	@ 085,180 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
	@ 085,210 BMPBUTTON TYPE 01 ACTION Close(oDlg1)
 
	ACTIVATE DIALOG oDlg1 CENTERED  
else
	cFiltro := "SELECT DISTINCT F2_DOC+F2_SERIE FROM "+RetSqlName("SF2")+" SF2 "+;
	"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON (F2_FILIAL = C5_FILIAL) AND (F2_PEDIDO = C5_NUM) AND "+;
	"(SC5.D_E_L_E_T_ <> '*') WHERE (F2_FILIAL = '"+;
	xFilial("SF2")+"') AND (F2_EMISSAO BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+;
	"') AND (SC5.C5_BOLETO = 'S') AND (C5_CONDPAG = '001') AND (SF2.D_E_L_E_T_ <> '*') "
endif 
Return 

Static Function ExistNf(cNF)
Local lRet
lRet = .t.
dbselectarea("SF2")
dbsetorder(1)
dbseek(xFilial("SF2")+cNf)
if !found() .or. empty(cNf)
	lRet = .f.
	Alert("Nro de NF Invalido!")
endif

return(lRet)



*---------------------------*                         
Static Function GravaDup()  
*---------------------------*
  
If nLista == 6
  MsgStop("Capacidade para selecao completa. Imprima a selecao.")
  Close(oDlg1)
Endif  
                                  
@ nLin,nCol SAY cNf
cFiltro += "'"+cNf+"',"
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
if cFilSel != 'S'
	SelDup()
endif 
if !empty(cFiltro)
  cFiltro := Substr(cFiltro,1,len(cFiltro)-1)
else
	cFiltro := "''"
endif 
  cQuery = "SELECT F2_FILIAL,F2_DOC,F2_SERIE FROM "+RetSqlName("SF2")+" SF2 "+;
  "WHERE (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_DOC+F2_SERIE IN("+cFiltro+"))"+;
  " AND (D_E_L_E_T_ <> '*') ORDER BY F2_DOC"
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TCQ",.T.,.T.)
//  TCQuery cQuery NEW ALIAS "TCQ" 
  //cQuery  := ChangeQuery(cQuery)
  //DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)

Return
             
*--------------------------------*
Static Function MontaRel2(aMarked) 
*--------------------------------*
Local nLinha := 0,lAvista

SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3,CSTRING,ARETURN")
SetPrvt("CPERG,NLASTKEY,LI,CSAVSCR1,CSAVCUR1,CSAVROW1")
SetPrvt("CSAVCOL1,CSAVCOR1,WNREL")       
tamanho  := "P" 
limite   := 80
titulo   := "EMISSAO DE BOLETOS BANCARIOS"
cDesc1   := "Este programa ira emitir boletos conforme"
cDesc2   := "selecao anterior."
cDesc3   := ""
cString  := "TCQ"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
cPerg    := ""
nLastKey := 0
nLin     := 0
nCont    := 1                              
wnrel    := "BRFIN010" 
wnrel    := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,)      
nLinha := 0

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif  
/////////////////////////////
dbselectarea("SC5")
dbsetorder(1)
//SfTstPrn(aReturn,nLinha) // Testa a impressora
dbselectarea("TCQ")
ProcRegua(RecCount())
SetPrc(0,0)
dbgotop()
do while !eof()
	DbSelectArea("SE1")
	DbSetOrder(1)         
	dbseek(xFilial("SE1")+TCQ->F2_SERIE+TCQ->F2_DOC,.F.)
	While !Eof() .and. (SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM) == (TCQ->F2_FILIAL+TCQ->F2_SERIE+TCQ->F2_DOC)
	/*
			If lAbortPrint
				@nLinha,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
	*/			
			if SE1->E1_TIPO != "NF"
				DbSelectArea("SE1")
				SE1->(DbSkip())
				loop 
			endif 
			nLinha += 2
			@ nLinha, 000 PSAY CHR(15)
			lAvista = .f.
			dbselectarea("SC5")
			dbseek(xFilial("SC5")+SE1->E1_PEDIDO)
			if found() .and. (SC5->C5_CONDPAG == "001") // Se for venda à vista
				lAvista = .t.
			endif
			@ nLinha, 091 PSAY IF(lAvista,"C/ APRESENTACAO",SE1->E1_VENCREA)
			nLinha+= 3
			@ nLinha, 005 PSAY SE1->E1_EMISSAO
			@ nLinha, 016 PSAY SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+SE1->E1_PARCELA
			@ nLinha, 053 PSAY "B" // Especie Doc
			@ nLinha, 063 PSAY "N" // Aceite
			@ nLinha, 072 PSAY dDataBase
			nLinha +=2
			@ nLinha, 045 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
			@ nLinha, 090 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
			IF !lAvista
				nLinha += 3
				@ nLinha, 010 PSAY "COBRAR R$ " + Transform((SE1->E1_VALOR * .0033),"@R 999.99") + " POR DIA DE ATRASO"
				nLinha += 2
				@ nLinha, 010 PSAY "** APOS VENCIMENTO PAGAVEL SOMENTE NO B. BRASIL"
			ELSE
				nLinha += 5
			endif 
			nLinha += 2
			@ nLinha, 090 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
			nLinha++
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			@ nLinha, 010 PSAY AllTrim(SA1->A1_NOME)
			nLinha++
			@ nLinha, 010 PSAY AllTrim(SA1->A1_ENDCOB)
			nLinha++
			@ nLinha, 010 PSAY Transform(SA1->A1_CEP,"@R 99999-999") + "  " + AllTrim(SA1->A1_MUN) + "  " +AllTrim(SA1->A1_EST)
			nLinha++
			@ nLinha, 010 PSAY IF(LEN(SA1->A1_CGC) > 11,"C.N.P.J. " + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),"C.P.F." + Transform(SA1->A1_CGC,"@R 999.999.999-99") ) + chr(18)
			nLinha+=6
		DbSelectArea("SE1")
		SE1->(DbSkip())
	EndDo
	dbselectarea("TCQ")
	IncProc()
	dbskip()
enddo

SET DEVICE TO SCREEN

/////////////////////////////

//@ nLin,000 PSAY CHR(18)  

If aReturn[5] == 1   // Se impressao em Disco, chama Spool. 
  Set Printer To 
  dbCommitAll()
  ourspool(wnrel)
Endif

FT_PFLUSH()          // Libera relatorio para Spool da Rede.   

Return nil

Static Function ValidPerg(cPerg)
Local _sAlias,aRegs,i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Tipo de Selecao  ?","","","mv_ch1","N",01,0,2,"C","","mv_par01","Selecao Manual","Selecao Manual" ,"Selecao Manual","","","Ped Marcados","Ped Marcados" ,"Ped Marcados" ,"","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Nfs Emitidas De  ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Nfs Emitidas Ate ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

