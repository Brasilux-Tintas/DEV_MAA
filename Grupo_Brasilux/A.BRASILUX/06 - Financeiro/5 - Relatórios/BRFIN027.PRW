#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFIN027บ Autor ณ Cleber O. Domingues บ Data ณ  28/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Maiores Devedores                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFIN027()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Maiores devedores"
     Local titulo        := "Devedores"
     Local nLin          := 80                                                 
                           //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
                           //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     Local Cabec1        := "CLIENTE                                             VALOR DEVIDO  ATRASO MEDIO  "
     Local Cabec2        := ""
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFIN027" // Coloque aqui o nome do programa para impressao no cabecalho
     Private cPerg       := "FIN027"
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFIN027" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SA1"

     DbSelectArea("SA1")
     DbSetOrder(1)

     //VldPerg(cPerg)  //LGS#20200131 - Adequa็ใo para release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     Processa({|| FINR27_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FINR27_1 บ Autor ณ Cleber Orati   บ Data ณ  28/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FINR27_1(Cabec1, Cabec2, Titulo, nLin)     
       Local dAux, cAux, nNumerador, nSaldo, nAtraso, nMedia, nSaldoTotal, nNumTotal, cCond
       DbSelectArea(cString)
       DbSetOrder(1)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


       ProcRegua(20)

		cCond := "(SE1.D_E_L_E_T_ <> '*') AND (E1_FILIAL = '"+xFilial("SE1")+"') AND (E1_SALDO > 0) AND (E1_SITUACA <> '6') AND (E1_NATUREZ <> '801004') AND "+;
		"(E1_VENCREA < CONVERT(varchar,GETDATE(),112)) AND (E1_SITUACA <> '5') AND (A1_EST <> 'EX') "+;
		iif(!empty(mv_par01),"AND (A1_ULTCOM > '"+dtos(mv_par01)+"')","")+" AND "+;
		"(SE1.E1_TIPO NOT IN('NCC','AB-','JP','RA')) "

		cQry1 := "SELECT E1_CLIENTE AS CLIENTE,A1_NOME AS RAZAO,E1_SALDO AS SALDO,E1_EMISSAO AS EMISSAO,E1_VENCREA AS VENCTO "+;
		"FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (E1_CLIENTE = A1_COD) "+;
		"WHERE "+cCond+;
		"ORDER BY CLIENTE"
       TCQuery cQry1 ALIAS "TCQ1" NEW

//		"WHERE (SE1.D_E_L_E_T_ <> '*') AND (E1_FILIAL = '"+xFilial("SE1")+"') AND (E1_SALDO > 0) AND (E1_SITUACA <> '801004') AND "+;

		cQry1 := "SELECT "+iif(mv_par02 > 0,"TOP "+alltrim(str(mv_par02)),"")+;
		" E1_CLIENTE AS CLIENTE,MAX(A1_NOME) AS RAZAO,SUM(E1_SALDO) AS SALDO "+;
		"FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (E1_CLIENTE = A1_COD) "+;
		"WHERE "+cCond+;
		"GROUP BY E1_CLIENTE ORDER BY SALDO DESC"
       TCQuery cQry1 ALIAS "TCQ" NEW

		nSaldoTotal := 0
		nNumTotal := 0
       DbSelectArea("TCQ")
       DbGoTop()
       While !EOF()
   			If lAbortPrint
      			@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
         		Exit
          	Endif
           	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
            	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
             	nLin += 1
  			Endif     
 			
             @ nLin, 000 PSAY TCQ->CLIENTE+"-"+TCQ->RAZAO
			cCliente :=  TCQ->CLIENTE 
			nSaldo := 0   
			nNumerador := 0
  			dbselectarea("TCQ1")
  			dbgotop()
  			locate for cliente = TCQ->CLIENTE
		
			do while !eof() .and. (TCQ1->CLIENTE = cCliente)

             	If lAbortPrint
                	@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                	Exit
             	Endif       
             	cAux := strzero(val(substr(TCQ1->VENCTO,7,2)),2)+"/"+strzero(val(substr(TCQ1->VENCTO,5,2)),2)+"/"+strzero(val(substr(TCQ1->VENCTO,1,4)),4)
                dAux := ctod(cAux)  
                nAtraso := date() - dAux
                nNumerador += nAtraso*TCQ1->SALDO
                nSaldo += TCQ1->SALDO
                dbselectarea("TCQ1")
                dbskip()
			enddo 
			nSaldoTotal += nSaldo
			nNumTotal += nNumerador              
   			@ nLin, 052 psay nSaldo picture "@E 9,999,999.99"
   			nMedia := iif(nSaldo > 0,round(nNumerador/nSaldo,0),0)
   			@ nLin, 071 psay nMedia picture "@E 999,999"
      		nLin += 1 // Avanca a linha de impressao  
			IncProc()
      		dbselectarea("TCQ")
        	dbskip()
       EndDo 
   		If (nLin+1) > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
     		nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
     		nLin += 1
  		Endif    
  		@ nLin, 000 psay replicate("=",80) 
  		nLin++ 
  		@ nLin, 051 psay nSaldoTotal picture "@E 99,999,999.99"
   		nMedia := iif(nSaldoTotal > 0,round(nNumTotal/nSaldoTotal,0),0)
   		@ nLin, 071 psay nMedia picture "@E 999,999"
		  		         
  		
       
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TCQ1")
       DbCloseArea()
       
       SET DEVICE TO SCREEN

       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()
Return     

/******************************************************************************************************************/
/*** VLDPERG  - Gera perguntas para paramentros do relat๓rio.                                                   ***/
/******************************************************************************************************************/
//LGS#20200131 - Adequa็ใo para release 12.1.25 e posteriores
/*
Static Function VldPerg(cPerg)
       cPerg := PADR(cPerg,10)
       PutSX1(cPerg, "01",   "Ult Compra apos dia   ", "", "", "mv_ch1", "D",  8, 0, 0, "G", " ", "SA1", " ", " ", "mv_par01", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "FINR27" )
       PutSX1(cPerg, "02",   "Nro Mแximo de Clientes", "", "", "mv_ch2", "N",  5, 0, 0, "G", " ", "SA1", " ", " ", "mv_par02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , "FINR27" )
Return*/