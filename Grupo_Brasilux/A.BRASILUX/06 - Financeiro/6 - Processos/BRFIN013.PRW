#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN013 ºAutor  ³ Cleber O. Dominguesº Data ³  06/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para calcular índice de Liquidez para clientes      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN013()
     Private cPERG,mv_par01

cPerg   := "BRFI13"
                      
@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Calcular Indice de Liquidez p/ Clientes"

//@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa({|lEnd| BRFI013()})
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,16 SAY "Indice de Liquidez p/ Clientes."
@ 33,16 SAY "Atencao! Serão calculados os índices de Liquidez p/"
@ 43,16 SAY "todos os Clientes e o processo podera' ser demorado!"
@ 8,10 TO 84,222
ACTIVATE DIALOG oDlg1
Return

STATIC Function BRFI013()
Local cQuery,_cCliente,nTotal,nSaldo,nDiasAtraso,nIndice
cQuery = "SELECT E1_CLIENTE AS CLIENTE,"+;
"SUM(DATEDIFF(DAY,CASE WHEN '"+DTOS(DATE())+"' >= E1_VENCTO THEN "+montadata('E1_VENCTO')+;
" ELSE GETDATE() END,GETDATE())*E1_SALDO) AS TOTAL,SUM(E1_SALDO) AS SALDO FROM "+RetSqlName("SE1")+" "+;
"WHERE (E1_SALDO > 0) AND ('"+DTOS(DATE())+"' > E1_VENCTO) AND (E1_TIPO NOT IN('RA','NCC')) AND "+;
"(D_E_L_E_T_ <> '*') GROUP BY E1_CLIENTE" +;
" UNION ALL "+;
"SELECT E5_CLIFOR AS CLIENTE,SUM(DATEDIFF(DAY,CASE WHEN E5_DATA >= E1_VENCTO THEN "+montadata('E1_VENCTO')+;
" ELSE "+montadata('E5_DATA')+" END,"+montadata('E5_DATA')+")*E5_VALOR) AS TOTAL,SUM(E5_VALOR) AS SALDO FROM "+RetSqlName("SE5")+" SE5 "+;
"LEFT OUTER JOIN "+RetSqlName("SE1")+" SE1 ON (E5_FILIAL = E1_FILIAL) AND (E5_PREFIXO = E1_PREFIXO) AND "+;
"(E5_NUMERO = E1_NUM) AND (E5_PARCELA = E1_PARCELA) AND (E5_CLIFOR = E1_CLIENTE) AND "+;
"AND (SE1.D_E_L_E_T_ <> '*') WHERE "+;
"(SE5.D_E_L_E_T_ <> '*') AND (E5_RECPAG = 'R') AND (E5_TIPO NOT IN('RA','NCC')) GROUP BY E5_CLIFOR"+;
" UNION ALL "+;
"SELECT E1_CLIENTE AS CLIENTE,"+;
"SUM(DATEDIFF(DAY,CASE WHEN '"+DTOS(DATE())+"' >= E1_VENCTO THEN "+montadata('E1_VENCTO')+;
" ELSE GETDATE() END,GETDATE())*E1_SALDO) AS TOTAL,SUM(E1_SALDO) AS SALDO FROM SE1020 "+;
"WHERE (E1_SALDO > 0) AND '"+DTOS(DATE())+"' > E1_VENCTO AND (E1_TIPO NOT IN('RA','NCC')) AND "+;
"(D_E_L_E_T_ <> '*') GROUP BY E1_CLIENTE" +;
" UNION ALL "+;
"SELECT E5_CLIFOR AS CLIENTE,SUM(DATEDIFF(DAY,CASE WHEN E5_DATA >= E1_VENCTO THEN "+montadata('E1_VENCTO')+;
" ELSE "+montadata('E5_DATA')+" END,"+montadata('E5_DATA')+")*E5_VALOR) AS TOTAL,SUM(E5_VALOR) AS SALDO FROM SE5020 SE5 "+;
"LEFT OUTER JOIN SE1020 SE1 ON (E5_FILIAL = E1_FILIAL) AND (E5_PREFIXO = E1_PREFIXO) AND "+;
"(E5_NUMERO = E1_NUM) AND (E5_PARCELA = E1_PARCELA) AND (E5_CLIFOR = E1_CLIENTE) AND "+;
"(SE1.D_E_L_E_T_ <> '*') WHERE "+;
"(SE5.D_E_L_E_T_ <> '*') AND (E5_RECPAG = 'R') AND (E5_TIPO NOT IN('RA','NCC')) GROUP BY E5_CLIFOR"+;
" UNION ALL "+;
"SELECT E1_CLIENTE AS CLIENTE,"+;
"SUM(DATEDIFF(DAY,CASE WHEN '"+DTOS(DATE())+"' >= E1_VENCTO THEN "+montadata('E1_VENCTO')+;
" ELSE GETDATE() END,GETDATE())*E1_SALDO) AS TOTAL,SUM(E1_SALDO) AS SALDO FROM SE1030 "+;
"WHERE (E1_SALDO > 0) AND '"+DTOS(DATE())+"' > E1_VENCTO AND (E1_TIPO NOT IN('RA','NCC')) AND "+;
"(D_E_L_E_T_ <> '*') GROUP BY E1_CLIENTE" +;
" UNION ALL "+;
"SELECT E5_CLIFOR AS CLIENTE,SUM(DATEDIFF(DAY,CASE WHEN E5_DATA >= E1_VENCTO THEN "+montadata('E1_VENCTO')+;
" ELSE "+montadata('E5_DATA')+" END,"+montadata('E5_DATA')+")*E5_VALOR) AS TOTAL,SUM(E5_VALOR) AS SALDO FROM SE5030 SE5 "+;
"LEFT OUTER JOIN SE1030 SE1 ON (E5_FILIAL = E1_FILIAL) AND (E5_PREFIXO = E1_PREFIXO) AND (E5_NUMERO = E1_NUM) AND "+;
"(E5_PARCELA = E1_PARCELA) AND (E5_CLIFOR = E1_CLIENTE) AND (SE1.D_E_L_E_T_ <> '*') WHERE "+;
"(SE5.D_E_L_E_T_ <> '*') AND (E5_RECPAG = 'R') AND (E5_TIPO NOT IN('RA','NCC')) GROUP BY E5_CLIFOR"+;
" ORDER BY CLIENTE "
TCQuery cQuery NEW ALIAS "TCQ" 
dbselectarea("SA1")
dbsetorder(1)
ProcRegua(RecCount())

dbselectarea("TCQ")
dbgotop()
do while !eof()
//	if len(alltrim(tcq->cliente)) == 6
		_cCliente = tcq->cliente    
		nTotal = 0
		nSaldo = 0
		do while !eof() .and. (tcq->cliente == _cCliente)
			if (tcq->saldo # NIL) 
				nSaldo += tcq->saldo
			endif
			if (tcq->total # NIL)
				nTotal += tcq->total
			endif
			dbskip()
		enddo
		if (nSaldo > 0) .and. (len(alltrim(_cCliente)) == 6)
			nDiasAtraso := nTotal/nSaldo
			do case
				case nDiasatraso < 5
					nIndice = 100
				case (nDiasatraso >= 5) .and. (nDiasatraso < 15)
					nIndice = 70
				case (nDiasatraso >= 15) .and. (nDiasatraso < 30)
					nIndice = 50
				otherwise
					nIndice = 0
			endcase
			dbselectarea("SA1")
			dbseek(xFilial("SA1")+_cCliente)
			if found()
				reclock("SA1",.F.)
				SA1->A1_LIQUID := nIndice
				SA1->A1_DTLIQ := date()
				msunlock("SA1")
			endif
		endif
		dbselectarea('TCQ')
		IncProc()
enddo		
dbselectarea("TCQ")
dbclosearea("TCQ")			
MsgBox("Processo Finalizado!","Aviso","INFO")
Close(oDlg1)

RETURN                         

STATIC FUNCTION montadata(cCampo)
LOCAL cRet

cRet = "CAST(SUBSTRING("+cCampo+",5,2)+'/'+SUBSTRING("+cCampo+",7,2)+'/'+"+;
"SUBSTRING("+cCampo+",1,4) AS DATETIME)"

return(cRet)
