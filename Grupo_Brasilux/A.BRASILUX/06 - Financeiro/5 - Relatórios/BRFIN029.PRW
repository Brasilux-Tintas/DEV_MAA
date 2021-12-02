#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN028º Autor ³ Cleber O. Domingues º Data ³  20/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ctas a Receber por Estado                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFIN029()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de saldo devedor de clientes por Estado."
     Local cDesc3        := ""
     Local titulo        := "Saldo Dev por Estado"
     Local nLin          := 80                                                 
                           //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
                           //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     Local Cabec1        := "ESTADO    VLR FATURADO                              SALDO DEVIDO"
     Local Cabec2        := ""
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFIN029" // Coloque aqui o nome do programa para impressao no cabecalho
     Private cPerg       := "FIN029"
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFIN029" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SA3"

  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFIN029' ) //LGS#2021202 - Gravação de log de utilização da rotina
     //VldPerg(cPerg) //LGS#20200131 - Adequação para release 12.1.25 e posteriores
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

     Processa({|| FINR29_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FINR29_1 º Autor ³ Cleber Orati   º Data ³  13/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FINR29_1(Cabec1, Cabec2, Titulo, nLin)     
       //Local dAux, cAux 
       Local nSaldoTotal,nFat,nPerc

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ SETREGUA -> Indica quantos registros serao processados para a regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       ProcRegua(20)
		cQry := "WITH TMP AS (SELECT A1_EST AS UF,SUM(E1_SALDO) AS SALDO "+;
		"FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (E1_CLIENTE = A1_COD) "+;
		"WHERE (SE1.D_E_L_E_T_ <> '*') AND (E1_FILIAL = '"+xFilial("SE1")+"') AND (E1_SALDO > 0) AND "
		do case
		case mv_par06 == 2
			cQry += "(E1_NATUREZ = '801004') AND "
		case mv_par06 == 3
			cQry += "(E1_NATUREZ <> '801004') AND "
		endcase 
		cQry += "(E1_VENCREA BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"') AND "+;
		"(E1_EMISSAO BETWEEN '"+dtos(mv_par04)+"' AND '"+dtos(mv_par05)+"') AND "+;
		"(SE1.E1_TIPO NOT IN('NCC','AB-','JP','RA')) "+iif(mv_par01 == 1,"AND (A1_INATIVO  = '') ","")+;
		"GROUP BY A1_EST) SELECT TMP.*,FAT = (SELECT SUM(E1_VALOR) FROM SE1010 SE1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (E1_CLIENTE = A1_COD) "+;
		"WHERE (SE1.D_E_L_E_T_ <> '*') AND (E1_FILIAL = '"+xFilial("SE1")+"') AND "+;
	   	"(E1_EMISSAO BETWEEN '"+dtos(mv_par04)+"' AND '"+dtos(mv_par05)+"') AND "+;
		"(SE1.E1_TIPO NOT IN('NCC','AB-','JP','RA')) AND (A1_EST = TMP.UF)) FROM TMP ORDER BY SALDO DESC "

		// AND (E1_SITUACA <> '5') Cleber (01/09/10) -> Cláudio pediu pra tirar este filtro

       	TCQuery cQry ALIAS "TCQ" NEW




		nSaldoTotal := 0     
		nFat := 0
  		DbSelectArea("TCQ")
       	DbGoTop()
       	While !EOF()
   			If lAbortPrint
      			@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
         		Exit
          	Endif
           	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
            	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
             	nLin += 1
  			Endif     
  			nSaldoTotal += TCQ->SALDO
  			nFat += TCQ->FAT
 			nPerc := iif(TCQ->FAT > 0,round((TCQ->SALDO/TCQ->FAT)*100,2),0)
    		@ nLin, 000 PSAY TCQ->UF
    		@ nLin, 008 PSAY TCQ->FAT picture "@E 999,999,999.99"
		
   			@ nLin, 052 psay TCQ->SALDO picture "@E 9,999,999.99"
   			@ nLin, 065 psay nPerc picture "@E 999.99"
   			@ nLin, 071 psay "%" 
   			
      		nLin += 1 // Avanca a linha de impressao  
			IncProc()
      		dbselectarea("TCQ")
        	dbskip()
       EndDo 
   		If (nLin+1) > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
     		nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
     		nLin += 1
  		Endif    
  		@ nLin, 000 psay replicate("=",80) 
  		nLin++ 
  		@ nLin, 006 psay nFat picture "@E 9,999,999,999.99"
  		@ nLin, 051 psay nSaldoTotal picture "@E 99,999,999.99" 
  		nPerc := iif(nFat > 0,round((nSaldoTotal*100/nFat),2),0)
  		@ nLin, 065 psay nPerc picture "@E 999.99"
		@ nLin, 071 psay "%" 
  		
		  		         
  		
       
       DbSelectArea("TCQ")
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
/*** VLDPERG  - Gera perguntas para paramentros do relatório.                                                   ***/
/******************************************************************************************************************/
//LGS#20200131 - Adequação para release 12.1.25 e posteriores
/*
Static Function VldPerg(cPerg)
       Local _sAlias := Alias()



       PutSX1(cPerg, "01",  "Excl Cli Inativos? ","Excl Cli Inativos? ","Excl Cli Inativos? "   , "mv_ch1", "N",  6, 0, 0, "C", " ", ""       , " " , " ", "mv_par01","Sim","Si"  ,"Yes"   ,"","Não","No","No","","","","","","","","","", Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "02",  "Vencimento de  ?    ","Vencimento de ?     ","Vencimento de ?     ", "mv_ch2", "D",  8, 0, 0, "G", " ", ""       , " " , " ", "mv_par02", ""  , ""   , ""     ,"",""   ,""  ,""  ,"","","","","","","","","", Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "03",  "Vencimento até ?    ","Vencimento até ?    ","Vencimento até ?    ", "mv_ch3", "D",  8, 0, 0, "G", " ", ""       , " " , " ", "mv_par03", ""  , ""   , ""     ,"",""   ,""  ,""  ,"","","","","","","","","", Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "04",  "Emissão de     ?    ","Emissão de     ?    ","Emissão de     ?    ", "mv_ch4", "D",  8, 0, 0, "G", " ", ""       , " " , " ", "mv_par04", ""  , ""   , ""     ,"",""   ,""  ,""  ,"","","","","","","","","", Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "05",  "Emissão até    ?    ","Emissão até    ?    ","Emissão até    ?    ", "mv_ch5", "D",  8, 0, 0, "G", " ", ""       , " " , " ", "mv_par05", ""  , ""   , ""     ,"",""   ,""  ,""  ,"","","","","","","","","", Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "06",  "Imprimir"            ,"Imprimir"            ,"Print "              , "mv_ch6", "N",  6, 0, 0, "C", " ", ""       , " " , " ", "mv_par06","Todos os Titulos","Todos os Titulos"  ,"Todos os Titulos"   ,"","Só Lucros/Perdas","Só Lucros/Perdas","Só Lucros/Perdas","Excluir Lucros/Perdas","Excluir Lucros/Perdas","Excluir Lucros/Perdas","","","","","","", Nil  , Nil     , Nil     , cPerg )



       dbSelectArea(_sAlias)
Return
*/
