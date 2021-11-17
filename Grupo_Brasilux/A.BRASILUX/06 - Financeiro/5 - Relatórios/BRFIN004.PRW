#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN004 ºAutor  ³ Cleber O. Dominguesº Data ³  22/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Emitir Boletos Bancários de Juros                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN004()
     Local Exec, i
     Local cPerg := "FIN004"
     Private cFilSel := "", mv_par01, mv_par02, mv_par03

     ValidPerg(cPerg) 
     Pergunte(cPerg)
     cFilSel := " "
     nOpcA   := 0
     i       := 1
     oDlg    := oSend(MSDialog(), "New", 8, 10, 18, 63, "Impressão de Boletos de Juros",,, .F.,,,,, GetWndDefault(), .F.,,, .F.)

     @ 20,013 SAY "Este programa tem como funcao imprimir boletos bancários do BANCO DO BRASIL"
     @ 30,013 SAY "para os Lotes Selecionados                                                 "
     @ 57,130 BMPBUTTON TYPE 05 ACTION (cFilSel := "F", Pergunte(cPerg))
     bOk     := {|| nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {|| nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }
     oSend( oDlg, "Activate",,,, .T.,,, bInit )
     If nOpca == 0 
        Return
     EndIf
     MsAguarde({|| MontaFiltro() }, "Atualizando arquivo com dados do Ctas a Receber")
     DbSelectArea("TMP")            
     DbGotop()
     If Eof()
        MsgStop("Nenhuma Ocorrencia!")
        DbSelectArea("TMP") 
        DbCloseArea()
        Exec := .f.
     Else
        Exec := .T.
     Endif
     If Exec
        TMP->(DBGoTop() )
        Processa({|lEnd| MontaRel2()})
        DbSelectArea("TMP") 
        DbCloseArea()
     Endif      
Return Nil

Static Function MontaFiltro()
       Local cQuery

       cQuery := "SELECT ORDEM = CASE WHEN E1_PREFIXO = 'JUR' THEN 1 ELSE 2 END,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_VALOR,"+;
       "SE1.E1_CLIENTE,SE1.E1_PGJURO,E1_VENCREA,E1_BAIXA,SA1.A1_NOME,SA1.A1_CGC,"+;
       "SA1.A1_ENDCOB,SA1.A1_MUNC,SA1.A1_ESTC,SA1.A1_CEPC FROM "+RetSqlName("SE1")+" SE1 LEFT OUTER JOIN "+;
       ""+RetSqlName("SA1")+" SA1 ON (E1_CLIENTE = A1_COD) AND (SA1.D_E_L_E_T_ <> '*') WHERE "+;
       "(E1_FILIAL = '"+xFilial("SE1")+"') AND (E1_PGJURO BETWEEN '"+;
       mv_par01+"' AND '"+mv_par02+"') AND "+;
       "(SE1.D_E_L_E_T_ <> '*') ORDER BY E1_CLIENTE,E1_PGJURO,ORDEM,E1_PREFIXO,E1_NUM,E1_PARCELA"
       TCQuery cQuery NEW ALIAS "TMP" 
Return

Static Function MontaRel2()
       Local nLin := 0, nCont, nPos, nContImpr, cRazao, nValor, cEnd, cCep, cUf, cCgc, cCidade

SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3,CSTRING,ARETURN")
SetPrvt("CPERG,NLASTKEY,LI,CSAVSCR1,CSAVCUR1,CSAVROW1")
SetPrvt("CSAVCOL1,CSAVCOR1,WNREL")       
tamanho  := "P" 
limite   := 80
titulo   := "BOLETOS BANCARIOS DE JUROS"
cDesc1   := "Este programa ira emitir boletos conforme"
cDesc2   := "selecao anterior."
cDesc3   := ""
cString  := "TMP"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
cPerg    := ""
nLastKey := 0
nLin     := 0
wnrel    := "BRFIN004" 
wnrel    := SetPrint("SE1",wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.)      

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If LastKey() == 27 .Or. nLastKey == 27
   Return
Endif  
/////////////////////////////
dbselectarea("TMP")
ProcRegua(RecCount())
SetPrc(0,0)
nLin := 0      
/* @ nLin,01 PSAY chr(18)
@ nLin,01 PSAY " " */
dbgotop()
nPos = 0
do while !eof()
	nLin += 2
	@ nLin, 000 PSAY CHR(15)
  	@ nLin,91 PSAY "C/ APRESENTACAO"
  	nLin := nLin + 3
  	@ nLin,05 PSAY dDataBase
  	@ nLin,16 PSAY alltrim(TMP->E1_NUM)+"/"+E1_PARCELA
  	@ nLin, 053 PSAY "B" // Especie Doc
	@ nLin, 063 PSAY "N" // Aceite
	@ nLin, 072 PSAY dDataBase
  	nLin := nLin + 2
  	@ nLin,45 PSAY Transform(TMP->E1_VALOR,"@E 999,999,999.99")
  	@ nLin,90 PSAY Transform(TMP->E1_VALOR,"@E 999,999,999.99")
  	nLin := nLin + 1
  	@ nLin,05 PSAY "PAGAMENTO DE JUROS REF.A TITULOS PAGOS EM CARTORIO"
  	nValor := TMP->E1_VALOR
  	cRazao := TMP->A1_NOME
  	cEnd := TMP->A1_ENDCOB 
  	cCep := TMP->A1_CEPC   
  	cCidade := TMP->A1_MUNC   
  	cUf := TMP->A1_ESTC 
  	cCgc := TMP->A1_CGC
  	cChave = TMP->E1_CLIENTE+TMP->E1_PGJURO
  	dbskip()                                                        
	nCont = 0 
	nContImpr := 0
  	do while !eof() .and. (TMP->ORDEM = 2) .and. ((TMP->E1_CLIENTE+TMP->E1_PGJURO) = cChave) 
  		nCont++
  /*		if nCont <= 6  
  			nContImpr++
	  		nLin++
  			@ nLin,05 psay "Tít.: "+TMP->E1_PREFIXO+"-"+TMP->E1_NUM+"-"+TMP->E1_PARCELA+;
  			" Vlr: "+transform(TMP->E1_VALOR,"999,999.99")+;
	  		" Vcto: "+substr(tmp->e1_vencrea,7,2)+"/"+substr(tmp->e1_vencrea,5,2)+"/"+substr(tmp->e1_vencrea,3,2)+;
  			" Pgto: "+substr(tmp->e1_baixa,7,2)+"/"+substr(tmp->e1_baixa,5,2)+"/"+substr(tmp->e1_vencrea,3,2)
  		endif 
*/  		
  		dbskip()
  	enddo     
  	
/*  	dbgotop()
  	if nPos > 0
	  	dbskip(nPos)
	endif 	  */
  	nLin := nLin + 6 - nContImpr
	@ nLin, 090 PSAY Transform(nValor,"@E 999,999,999.99")
  	nLin := nLin + 1
  	@ nLin,010 PSAY cRazao 
  	nLin++
  	@ nLin,010 PSAY cEnd 
  	nLin++
	@ nLin, 010 PSAY Transform(cCep,"@R 99999-999") + "  " + AllTrim(cCidade) + "  " +AllTrim(cUf)
	nLin++
	@ nLin, 010 PSAY IF(LEN(alltrim(cCgc)) > 11,"C.N.P.J. " + Transform(cCgc,"@R 99.999.999/9999-99"),"C.P.F." + Transform(cCgc,"@R 999.999.999-99") ) + chr(18)
	nLin += 6
		
  	IncProc()
  	dbselectarea("TMP")  
 // 	dbskip(nCont+1) 
  	nPos += nCont + 1

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
aRegs:={}
cPerg := PADR(cPerg,10)
//=======================//
// mv_par01.. Titulo de  //
// mv_par02.. Titulo ate //
// mv_par03.. Banco      //
//=======================//
aAdd(aRegs,{cPerg,"01","Lote de   ?","","","mv_ch1","C",06,0,0,"G","","mv_par01",""		 ,""		,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Lote ate  ?","","","mv_ch2","C",06,0,0,"G","","mv_par02",""		 ,""	    ,""		   ,"","",""	,""	   ,""	  ,"","","		  ","		 ","		","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Banco       ?","","","mv_ch3","N",01,0,1,"C","","mv_par03","B.Brasil","B.Brasil","B.Brasil","","","Itau","Itau","Itau","","","Bradesco","Bradesco","Bradesco","","","","","","","","","","","","",""})

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