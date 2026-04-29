#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include 'avprint.ch'
#include 'font.ch'

/*/{Protheus.doc} ZESTR01
Relatório de Consumo Mensal - Baseado no fonte BREST010
Criado em: 18/01/22 por Luís Gustavo
Alteração: Cleber(02/01/06) Alteração tirando onde há C5_ESPECI4
           Gustavo(22/11/06) Alteração adicionando filtro de produto ativo
@type function
@version  V2022.01
@author Jose Uliana
@since 20/01/2022
/*/

User Function ZESTR01
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local   aOrd        := {}
     Local   cDesc1      := "Este programa tem como objetivo imprimir relatorio "
     Local   cDesc2      := "de acordo com os parametros informados pelo usuario."
     Local   cDesc3      := "Relatorio de Consumo Mensal"
// Jose    Local   cPict       := ""
     Local   titulo      := "Relatorio de Consumo Mensal"
     Local   nLin        := 80
     Local   Cabec1      := "    CODIGO                     DESCRICAO                 TP LC UM     "
     Local   Cabec2      := ""
// Jose     Local   imprime     := .T.

//     Private cString
// Jose      Private CbTxt       := ""
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "ZESTR01" 
     Private nTipo       := 15
     Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "ZESTR01"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "ZESTR01"
     Private cString     := "SB1"
	 Private mv_par20	 := 2
      
	
  //if !u_VldAcesso(funname())
  //    MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
  //    return 
  //endif 
     u_zcfga01( 'ZESTR01' ) //LGS#2021220 - Gravação de log de utilização da rotina
     dbSelectArea("SB1")
     dbSetOrder(1)

     ValidPerg()

     pergunte(cPerg,.F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)
     
     If nLastKey == 27
        Return
     Endif

if mv_par07 > 12
      MsgBox("Qtde de Meses Anteriores Deverá ser Menor que 13!!","Atenção","Alert")
      return 
endif 
 
     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. PROCESSA monta janela com a regua de processamento.  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Processa({|| EST0101(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/{Protheus.doc} EST0101
Relatório de Consumo Mensal - Baseado no fonte BREST010
Criado em: 18/01/22 por Luís Gustavo
Alteração: Cleber(02/01/06) Alteração tirando onde há C5_ESPECI4
           Gustavo(22/11/06) Alteração adicionando filtro de produto ativo
		   Jose Uliana (19/01/2022) Altereção adicionado campo Saldo Pedido
		             da tabela SC7 e com a possibilidade de gerar tudo em execel
@type function
@version  
@author joseuliana
@since 20/01/2022
@param Cabec1, character, Primeira Linha do Cabeçalho do Relatório
@param Cabec2, character, param_description
@param Titulo, variant, "Relatorio de Consumo Mensal"
@param nLin, numeric, Quantidade de Linhas por Pagina No Relatório
@return variant, return_description
/*/

Static Function EST0101(Cabec1,Cabec2,Titulo,nLin)
// Jose       Local aCons   := {}  // Array com dados da impressao
       Local aMeses  := {}  // Array com os meses a serem impressos
       Local cQry1   := ""  // Variavel para guardar a query da tabela SB1
// Jose       Local cQry2   := ""  // Variavel para guardar a query da tabela SD3
// Jose       Local cQry3   := ""  // Variavel para guardar a query da tabela SD2 
// Jose       Local cQry4   := ""  // Variavel para guardar a query da tabela SD1
// Jose       Local cPriDia := ""  // Primeiro dia do mes
// Jose       Local cUltDia := ""  // Ultimo dia do mes
       Local nMesAtu := 0   // Variavel para guardar mes atual
       Local nAnoAtu := 0   // Variavel para guardar ano atual
       Local nMesIni := 0   // Variavel para guardar mes inicial
// Jose       Local nAnoAnt := 0   // Variavel para guardar ano anterior
// Jose       Local nNumMes := 0   // Variavel para guardar numero de meses ano anterior
// Jose       Local nNumAux := 0   // Variavel para guardar numero de meses ano anterior (Auxiliar)
       Local nQuantR := 0   // Quantidade reservada em estoque
       Local nQuant  := 0   // Quantidade atual no estoque
       Local nQtdeMeses,nAuxAno,nAuxMes,cPerIni,cPerFinal,i,x
	   Local nAtual := 0
       	
		nMesAtu := Month(dDataBase)  
		nAnoAtu := Year(dDataBase)
		
		nQtdeMeses := mv_par07 + iif(mv_par10 == 1,1,0)
		
		nMesIni := nMesAtu - mv_par07
		nAnoIni := Year(dDataBase)
		if nMesIni < 0  
			nAnoIni := nAnoIni - ceiling(abs(nMesIni/12))
			nMesIni := 12-round(12*(abs(nMesIni/12) - int(abs(nMesIni/12))),0)
		elseif nMesIni ==0                         
		    nAnoIni := nAnoIni -1
		    nMesIni := 12-round(12*(abs(nMesIni/12) - int(abs(nMesIni/12))),0)
		endif
		
		nAuxAno := nAnoIni
		nAuxMes := nMesIni
		for i := 1 to nQtdeMeses
			if nAuxMes > 12
				nAuxMes := 1
				nAuxAno += 1
			endif
            aadd(aMeses,StrZero(nAuxMes,2)+StrZero(nAuxAno,4))
            nAuxMes += 1
		next 			         
			
       	If mv_par10 == 1
       		nMesFim := nMesAtu
       		nAnoFim := nAnoAtu
       	else	
       		nMesFim := nMesAtu-1
       		nAnoFim := nAnoAtu
       		if nMesFim <= 0
       			nMesFim := 12 - nMesFim
       			nAnoFim := nAnoFim - 1
       		endif
       	endif               
       	
       	cPerIni   := strzero(nAnoIni,4)+strzero(nMesIni,2)+'01'
       	cPerFinal := strzero(nAnoFim,4)+strzero(nMesFim,2)+'99'
       	

       For i := 1 to Len(aMeses)
           Cabec1 := Cabec1 + SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[i],1,2)))),1,3)+'/'+SubStr(Alltrim(SubStr(aMeses[i],3,4)),3,2)+'     '
       Next

       If mv_par08 == 1
          Cabec1 := Cabec1 + 'MEDIAS   '
       Endif
       If mv_par11 == 1
          Cabec1 := Cabec1 + 'SAL. ATUAL    '
       Endif
       If mv_par09 == 1
          Cabec1 := Cabec1 + 'DISPONIVEL    '
       Endif
	     Cabec1 := Cabec1 + 'SALDO PED.'
       //    CODIGO                     DESCRICAO                 TP LC UM   XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     XXX/99     MEDIAS    SAL. ATUAL   DISPONIVEL     SALDO PED.
       //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX 99 XX 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99 9,999,999.99 9,999,999.99  9,999,999.99
       //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
       //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        10        20        30        40 
       dbSelectArea(cString)
       dbSetOrder(1)
       #IFDEF TOP            
      		
			cQry1 := "WITH CONSUMO AS ( "
			if mv_par18 <> 1
				cQry1 += "SELECT D1_COD AS CODPRO,SUBSTRING(D1_DTDIGIT,1,6) AS MES, SUM(D1_QUANT*-1) AS SOMA "+; 
				"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
				"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = B1_FILIAL) AND (D1_COD = B1_COD) "+;
				"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (SA1.A1_FILIAL = '"+xFilial("SA1")+"') AND (D1_FORNECE = A1_COD) "+;
				"WHERE (SD1.D_E_L_E_T_  = '') "+;
				"AND (SD1.D1_FILIAL = '"+xFilial("SD1")+"') "
				IF !EMPTY(MV_PAR02)  
					cQry1 += "AND (SD1.D1_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
				ENDIF 
				cQry1 += "AND (SD1.D1_DTDIGIT BETWEEN '"+cPerIni+"' AND '"+cPerFinal+"') "+;
				"AND (SD1.D1_TIPO = 'D') "+;
				"AND (SD1.D1_XESTOQU = 'S') "
				IF !EMPTY(MV_PAR06)  
					cQry1 += "AND (SB1.B1_TIPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
				ENDIF 
				IF !EMPTY(MV_PAR04)
					cQry1 += "AND (B1_LOCPAD BETWEEN '"+mv_par03+"' and '"+mv_par04+"') "
				ENDIF 
				IF !EMPTY(MV_PAR15)
					cQry1 += "AND (SB1.B1_GRUPO BETWEEN '"+mv_par14+"' AND '"+mv_par15+"') "
				ENDIF 
              	cQry1 += IIf(mv_par12 == 1,"AND (SB1.B1_ESTOQUE = 'S') ","")+;
              	IIf(mv_par16 == 1,"AND (SB1.B1_ATIVO <> 'N') ","")+;
              	IIf(mv_par17 == 1,"AND (SB1.B1_MSBLQL <> '1') ","")+;  
              	"AND "+IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),"(((LEN(A1_CGC) = 14) AND (SUBSTRING(A1_CGC ,1,8) <> '"+SUBSTR(ALLTRIM(SM0->M0_CGC),1,8)+"')) OR (LEN(A1_CGC) <> 14)) ","(A1_CGC <> '"+ALLTRIM(SM0->M0_CGC)+"') ")+;
				"GROUP BY D1_COD,SUBSTRING(D1_DTDIGIT,1,6)"+;
				"UNION ALL "+;
				"SELECT D3_COD AS CODPRO,SUBSTRING(D3_EMISSAO,1,6) AS MES,SUM(SD3.D3_QUANT) AS SOMA "+;
				"FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) "+;
				"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D3_FILIAL = B1_FILIAL) AND (D3_COD = B1_COD) "+;
				"WHERE (SD3.D_E_L_E_T_ = '') "+;
				"AND (SD3.D3_FILIAL = '"+xFilial("SD3")+"') "
				IF !EMPTY(MV_PAR02)  
					cQry1 += "AND (SD3.D3_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
				ENDIF
				IF !EMPTY(MV_PAR06)  
					cQry1 += "AND (SB1.B1_TIPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
				ENDIF 
				IF !EMPTY(MV_PAR04)  
					cQry1 += "AND (B1_LOCPAD BETWEEN '"+mv_par03+"' and '"+mv_par04+"') "
				ENDIF 
				IF !EMPTY(MV_PAR15)  
					cQry1 += "AND (SB1.B1_GRUPO BETWEEN '"+mv_par14+"' AND '"+mv_par15+"') "
				ENDIF 
              	cQry1 += IIf(mv_par12 == 1,"AND (SB1.B1_ESTOQUE = 'S') ","")
              	cQry1 += IIf(mv_par20 == 1,"AND (SB1.B1_MCUSTD = '2') ","")+; //Chamado 020483 (Caio), filtrar apenas produtos dolarizados :
              	IIf(mv_par16 == 1,"AND (SB1.B1_ATIVO NOT IN('N')) ","")+;
              	IIf(mv_par17 == 1,"AND (SB1.B1_MSBLQL <> '1') ","")+;
				"AND (SD3.D3_EMISSAO BETWEEN '"+cPerIni+"' AND '"+cPerFinal+"') "+;
				"AND (SD3.D3_DOC <> 'INVENT') "+;
				"AND (SD3.D3_ESTORNO <> 'S') "+;
				"AND (SUBSTRING(SD3.D3_CF,1,2) = 'RE') "+;
				"AND (SUBSTRING(SD3.D3_CF,3,1) IN('0', '1', '2', '3')) "+;
				"AND (SD3.D3_TM NOT IN('600', '200', '110','120','520')) "
				//Chamado 006041 de 15/12/16, Gustavo pedido para entrarem todos os produtos no consumo Mes a Mes, não somente produtos de OP
				//cQry1 += "AND (((SB1.B1_TIPO IN ('MP','PI')) AND (SD3.D3_OP <> '')) OR (B1_TIPO NOT IN('MP','PI') OR B1_XREQUIS ='S')) " //				"AND (((SB1.B1_TIPO <> 'PA') AND (SD3.D3_OP <> '')) OR (B1_TIPO = 'PA')) "
				cQry1 += "GROUP BY D3_COD,SUBSTRING(D3_EMISSAO,1,6) "+;
				"UNION ALL "
			endif 

			cQry1 += "SELECT D2_COD AS CODPRO,SUBSTRING(SD2.D2_EMISSAO,1,6) AS MES, SUM(SD2.D2_QUANT) AS SOMA "+;
			"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
			"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D2_FILIAL = B1_FILIAL) AND (D2_COD = B1_COD) "+;
			"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (D2_CLIENTE = A1_COD) "+;
			"WHERE (SD2.D_E_L_E_T_  = '') "+;
			"AND (SD2.D2_FILIAL = '"+xFilial("SD2")+"') "
			IF !EMPTY(MV_PAR02)  
				cQry1 += "AND (SD2.D2_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
			ENDIF 
			cQry1 += "AND (SD2.D2_EMISSAO BETWEEN '"+cPerIni+"' AND '"+cPerFinal+"') "+;
			"AND (SD2.D2_TIPO <> 'D') "+;
			"AND (SD2.D2_ESTOQUE = 'S') "+;
           	IIf(mv_par12 == 1,"AND (SB1.B1_ESTOQUE = 'S') ","")+;
            IIf(mv_par20 == 1,"AND (SB1.B1_MCUSTD = '2') ","") //Chamado 020483 (Caio), filtrar apenas produtos dolarizados :

			IF !EMPTY(MV_PAR06)  
				cQry1 += "AND (SB1.B1_TIPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
			ENDIF 
			IF !EMPTY(MV_PAR04)  
				cQry1 += "AND (B1_LOCPAD BETWEEN '"+mv_par03+"' and '"+mv_par04+"') "
			ENDIF 
			IF !EMPTY(MV_PAR15)  
				cQry1 += "AND (SB1.B1_GRUPO BETWEEN '"+mv_par14+"' AND '"+mv_par15+"') "
			ENDIF 
   			cQry1 += IIf(mv_par16 == 1,"AND (SB1.B1_ATIVO <> 'N') ","")+;
			IIf(mv_par17 == 1,"AND (SB1.B1_MSBLQL <> '1') ","")+;
   			"AND "+IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),"(((LEN(A1_CGC) = 14) AND (SUBSTRING(A1_CGC ,1,8) <> '"+SUBSTR(ALLTRIM(SM0->M0_CGC),1,8)+"')) OR (LEN(A1_CGC) <> 14)) ","(A1_CGC <> '"+ALLTRIM(SM0->M0_CGC)+"') ")+;
			"GROUP BY D2_COD,SUBSTRING(SD2.D2_EMISSAO,1,6) "+;
			"), TMP AS ( SELECT "+;
			"CODPRO,MES,SUM(SOMA) AS QTDE "+;
			"FROM CONSUMO GROUP BY CODPRO,MES), "+;
			"CONSFINAL AS (SELECT CODPRO,"+;
			"ROUND(SUM(QTDE)/"+alltrim(str(Len(aMeses)))+",4) AS MEDIA "
	       	For i := 1 to Len(aMeses) 
	       		cQry1 += ",'M_"+SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[i],1,2)))),1,3)+"' = (SELECT QTDE FROM TMP WHERE (CODPRO = A.CODPRO) AND (MES = '"+SubStr(aMeses[i],3,4)+SubStr(aMeses[i],1,2)+"'))"
       		Next	
       		cQry1 += " FROM TMP A GROUP BY CODPRO) "+;
       		"SELECT ROW_NUMBER() OVER(ORDER BY "+IIF(mv_par13 == 1,"CODPRO","MEDIA")+" DESC) AS LINHA,CODPRO AS CODIGO, SB1.B1_LOCPAD AS LOCALL, SB1.B1_TIPO AS TIPO,"+;   
       		"SB1.B1_DESC AS DESCRICAO, SB1.B1_UM AS UNIDADE, SB1.B1_POSIPI AS NCM, SB1.B1_MCUSTD AS MOEDA, SB1.B1_UPRC AS ULTPRECO, SB1.B1_CUSTD AS CUSTODOLAR, "
// Acrescentado por jose 19/01/2022 --------------------------------------
		    cQry1 += "QUANTPE = ( SELECT ISNULL(SUM(C7_QUANT-C7_QUJE),0) FROM SC7010 C7 WHERE C7.D_E_L_E_T_ = '' AND (B1_FILIAL = C7_FILIAL) "+;
             "AND (B1_COD = C7_PRODUTO) AND (C7_QUANT-C7_QUJE) > 0 AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' ),"
//-------------------------------------------------------------------------     
	       	For i := 1 to Len(aMeses) 
	       		cAux := SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[i],1,2)))),1,3)
       			cQry1 += "ISNULL(M_"+cAux+",0) AS 'M_"+cAux+"',"
			next  
			cQry1 += "MEDIA"
			iF (mv_par11 == 1) .or. (mv_par09 == 1)
				cQry1 += ",SALDOATUAL = (SELECT SUM(B2_QATU) FROM SB2010 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+xFilial("SB2")+"') AND (B2_COD = CONSFINAL.CODPRO))"
			endif      
			if (mv_par09 == 1)
				cQry1 += ",QTDDISP = CASE WHEN SB1.B1_TIPO IN ('MP','MC') THEN "+;
				"(SELECT SUM(B2_QEMP+B2_RESERVA+B2_QEMPSA) FROM "+RetSqlName("SB2")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+xFilial("SB2")+"') AND (B2_COD = CONSFINAL.CODPRO)) ELSE "+;
				"(SELECT SUM(C9_QTDLIB) FROM "+RetSqlName("SC9")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C9_FILIAL = '"+xFilial("SC9")+"') AND (C9_NFISCAL = '') AND (C9_BLCRED  = '') AND (C9_PRODUTO = CONSFINAL.CODPRO)) END "
			endif  
			cQry1 += " FROM CONSFINAL "+;
			"LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (CODPRO = B1_COD) "
//  Alterado por Jose 19/01/2022 antes era 1 o Dolarizado --------------
			If (mv_par19 == 2)
        		cQry1 += " WHERE SB1.B1_MCUSTD ='2' "
			Endif	
//------------------------------------------------------------------------

			cQry1 += "ORDER BY "+IIF(mv_par13 == 1,"CODIGO","MEDIA")

            TCQUERY cQry1 NEW ALIAS "TMPSB1"

			
/*              DbSelectArea("TMPSB1")
              DbGoTop()
              If mv_par05 $ 'MP' .or. mv_par06 $ 'MP'
                 ProcRegua(1000)
              ElseIf mv_par05 $ 'PI' .or. mv_par06 $ 'PI'
                     ProcRegua(8000)
              ElseIf mv_par05 $ 'PA' .or. mv_par06 $ 'PA'
                     ProcRegua(14000)
              Else
                  ProcRegua(20000)
              Endif
              
              While !eof()
                     aadd(aCons,{CODIGO, DESCRICAO, TIPO, LOCAL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UNIDADE, 0})
                     IncProc("Selecionando registro conforme filtro.")
                     dbSkip()
              Enddo
              DbSelectArea("TMPSB1")
              DbCloseArea()*/
       #ENDIF

	Count To nTotal
    ProcRegua(nTotal)

//       ProcRegua(Len(aCons) * Len(aMeses))
  
	dbselectarea("TMPSB1")     
	dbgotop()      
	if !eof()
		ProcRegua(TMPSB1->LINHA)
	endif 

	If mv_par19 == 3 // Alterado por jose antes era 2 ----------------------------
	
		while !eof()
       
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o cancelamento pelo usuario...                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If lAbortPrint
					@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
					Exit
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao do cabecalho do relatorio. . .                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				Endif

				@ nLin,000 PSAY TMPSB1->CODIGO Picture "@R XXX99.99.999-99"
				@ nLin,016 PSAY TMPSB1->DESCRICAO Picture "@!"
				@ nLin,057 PSAY TMPSB1->TIPO Picture "@!"
				@ nLin,060 PSAY TMPSB1->LOCALL Picture "XX"
				@ nLin,063 PSAY TMPSB1->UNIDADE Picture "@!"
				nCol := 066
				For x := 1 to Len(aMeses)
					cAux = "TMPSB1->M_"+SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[x],1,2)))),1,3)
					@ nLin,nCol PSAY &cAux Picture "@E 999,999.99"
					nCol := nCol + 11
				Next
				// Imprime Média de Quantidade dos Produtos
				If mv_par08 == 1
					@ nLin,nCol PSAY TMPSB1->MEDIA Picture "@E 999,999.99"
					nCol := nCol + 11
				Endif
				nQuantR := 0
				nQuant  := 0   
				// Imprime Saldo Atual
				If mv_par11 == 1
					@ nLin,nCol PSAY TMPSB1->SALDOATUAL Picture "@E 9,999,999.99"
					nCol := nCol + 14
				Endif
				// Imprime Saldo Disponivel
				If mv_par09 == 1
				//  @ nLin,nCol PSAY (nQuant - nQuantR) Picture "@E 9,999,999.99"
					@ nLin,nCol PSAY TMPSB1->SALDOATUAL - TMPSB1->QTDDISP Picture "@E 9,999,999.99"
//  Acrescentado por Jose 18/01/2022 --------------------------------------------------------------
					nCol := nCol + 14
//-------------------------------------------------------------------------------------------------
				Endif
//  acrescentado por Jose 18/02/2022 ----------------------------------------------------------------
    			@ nLin,nCol PSAY TMPSB1->QUANTPE Picture "@E 9,999,999.99"
//---------------------------------------------------------------------------------------------------
				nLin := nLin + 1    // Avanca a linha de impressao
				IncProc("Imprimindo relatorio !!!")
				
			dbselectarea("TMPSB1")     
			dbSkip()            // Avanca o ponteiro do registro no arquivo
		enddo
		
		dbselectarea("TMPSB1")     
		DbCloseArea()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Finaliza a execucao do relatorio...                                 ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        SET DEVICE TO SCREEN

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Se impressao em disco, chama o gerenciador de impressao...          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        If aReturn[5]==1
           dbCommitAll()
           SET PRINTER TO
           OurSpool(wnrel)
        Endif

        MS_FLUSH()

   Else  // gerar planilha excel

        aCabExcel := {}
        AADD(aCabExcel, {"CODIGO"       ,"C", 15, 0}) 
        AADD(aCabExcel, {"DESCRIÇÃO"    ,"C", 30, 0}) 
        AADD(aCabExcel, {"TIPO" 		,"C", 04, 0}) 
        AADD(aCabExcel, {"LOCALL"       ,"C", 05, 0}) 
        AADD(aCabExcel, {"NCM"          ,"C", 12, 0}) 
        AADD(aCabExcel, {"UM"           ,"C", 02, 0}) 
        AADD(aCabExcel, {"CUSTO DOLAR"  ,"N", 09, 2})
        AADD(aCabExcel, {"ULT. PREÇO"   ,"N", 09, 2})
                 	
        For x := 1 to Len(aMeses)
        	cAux = "MES_"+SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[x],1,2)))),1,3)
        	AADD(aCabExcel, {SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[x],1,2)))),1,3)      ,"N", 09, 2})
       	Next
       	If mv_par08 == 1
       		AADD(aCabExcel, {"MEDIA"            ,"N", 09, 2})
       	Endif                        
       	If mv_par11 == 1
       		AADD(aCabExcel, {"SALDO ATUAL"      ,"N", 09, 2})
       	Endif
       	If mv_par09 == 1
       		AADD(aCabExcel, {"QTD DISPO"        ,"N", 09, 2})
       	Endif

		//-    Acrescentado por Jose 15/01/2022 ---------------------------------------
   		AADD(aCabExcel, {"SALDO PED"        ,"N", 09, 2})
		//-----------------------------------------------------------------------------

		/* adicionado nelieder 15/07/2022
		  calculo = QTD DISPO/MEDIA
		*/

		If mv_par08 == 1 .AND. mv_par09 == 1
			AADD(aCabExcel, {"COBERTURA"   ,"C", 09, 0})
		Endif	

		AADD(aCabExcel, {"FORNECEDOR"   ,"C", 09, 0})

    	AADD(aCabExcel, {"CONSUMO 6 MÊS"   ,"C", 09, 0})

		/* fim nelieder */


		

       	aMatDad := {}
       	//aMatDad := Array(1,Len(aMeses)+12)
        nLin    := 1

    	While !eof()
    		If nLin == 1
    			aMatDad := Array(TMPSB1->LINHA,Len(aMeses)+16) //  alterado por jose 19/01/2022 antes era +12
    		End
    		
			nAtual++
        	IncProc("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
    		aMatDad[nLin][1] := CHR(160)+TMPSB1->CODIGO
    		aMatDad[nLin][2] := CHR(160)+SUBSTR(TMPSB1->DESCRICAO,1,30)	
        	aMatDad[nLin][3] := CHR(160)+TMPSB1->TIPO
        	aMatDad[nLin][4] := CHR(160)+TMPSB1->LOCALL
        	aMatDad[nLin][5] := CHR(160)+TMPSB1->NCM 
        	aMatDad[nLin][6] := CHR(160)+TMPSB1->UNIDADE
        	aMatDad[nLin][7] := Transform(TMPSB1->CUSTODOLAR, "@E 999,999.99") 
        	aMatDad[nLin][8] := Transform(TMPSB1->ULTPRECO, "@E 999,999.99") 
        	
        	For x := 1 to Len(aMeses)
        		cAux = "TMPSB1->M_"+SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[x],1,2)))),1,3) 
                aMatDad[nLin][x+8] := Transform(&cAux, "@E 999,999.99")
       		Next

			/* média */
       		If mv_par08 == 1
       			aMatDad[nLin][x+8] := Transform(TMPSB1->MEDIA, "@E 999,999.99")
       		Endif                        
       		
			/*saldo atual */
			If mv_par11 == 1
       			aMatDad[nLin][x+09] := Transform(TMPSB1->SALDOATUAL, "@E 9,999,999.99")
       		Endif

			/* qtd disponivel */
       		If mv_par09 == 1
       			aMatDad[nLin][x+10] := Transform((TMPSB1->SALDOATUAL - TMPSB1->QTDDISP), "@E 9,999,999.99")
       		Endif

			//   acrescentado por jose 18/01/2022  -------------------------------------------------------
      		aMatDad[nLin][x+11] := Transform((TMPSB1->QUANTPE), "@E 9,999,999.99")
			//------------------------------------------------------------------------------------------

			/* Incluido por Nelieder em 13/07/2022 Cobertura */
			If mv_par08 == 1 .AND. mv_par09 == 1
				aMatDad[nLin][x+12] := Transform(val(aMatDad[nLin][x+10])/val(aMatDad[nLin][x+8]), "@E 9,999,999.99")
			endif

			cQry2 := ""
			cQry2 += " SELECT TOP 1 D1_FORNECE,A2_COD,A2_NOME,D1_EMISSAO FROM "+RetSqlName("SD1")+" SD1 "
			cQry2 += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON D1_FORNECE = A2_COD AND SA2.D_E_L_E_T_ = '' "
			cQry2 += " WHERE D1_COD = '"+Alltrim(TMPSB1->CODIGO)+"' AND SD1.D_E_L_E_T_ = '' "
			if !empty(alltrim(mv_par21))
        		cQry2 += " AND (A2_COD NOT IN "+NFornec()+" )  "
    		endif
			cQry2 += " ORDER BY D1_EMISSAO DESC "

			
			

			cQry2 := ChangeQuery(cQry2)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),"TMPSA5",.T.,.T.)
            DbSelectArea("TMPSA5")

			/* Fornecedor */
            aMatDad[nLin][x+13] := CHR(300)+A2_COD+'-'+TMPSA5->A2_NOME

            /* Consumo 6 Meses */
			aMatDad[nLin][x+14] := Transform(val(aMatDad[nLin][x+8])*6, "@E 9,999,999.99")

			
            //aMatDad[nLin][x+12] := CHR(160)+space(30)   /// alterado por jose 18/01/222 aMatDad[nLin][x+11]
            nLin := (nLin + 1)

			dbselectarea("TMPSA5")
	        dbCloseArea()

            dbselectarea("TMPSB1")     
            dbSkip()            // Avanca o ponteiro do registro no arquivo

        Enddo

       		MsgRun("Aguarde.....", "Exportando os Registros para o Excel",; 
       		{||DlgToExcel({{"GETDADOS",;
       		"RELATÓRIO DE CONSUMO MÊS A MÊS FILIAL -> "+XFILIAL("SB1")+" - EMISSÃO :"+ cValtoChar(Date()),aCabExcel,aMatDad}})})   
		      
	    
	    dbselectarea("TMPSB1")     
        DbCloseArea()
   Endif
   
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  17/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Do produto        	","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"02","Ate o produto     	","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"03","Do local          	","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"04","Ate o local       	","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"05","Do tipo           	","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg,"06","Ate o tipo        	","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg,"07","Meses Anteriores  	","","","mv_ch7","N",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"08","Calcula Media     	","","","mv_ch8","N",01,0,0,"C","","mv_par08","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"09","Saldo Disponivel  	","","","mv_ch9","N",01,0,0,"C","","mv_par09","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"10","Consid. Mes Atual 	","","","mv_cha","N",01,0,0,"C","","mv_par10","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"11","Saldo Atual       	","","","mv_chb","N",01,0,0,"C","","mv_par11","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"12","Somente           	","","","mv_chc","N",01,0,0,"C","","mv_par12","Itens de Estoque","","","","","Todos"  ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"13","Ordem             	","","","mv_chd","N",01,0,0,"C","","mv_par13","Codigo"          ,"","","","","Consumo","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"14","Do grupo          	","","","mv_che","C",04,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg,"15","Ate o grupo       	","","","mv_chf","C",04,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg,"16","Filtra Ativos    ?	","","","mv_chg","N",01,0,0,"C","","mv_par16","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"17","Filtra Bloqueados?	","","","mv_chh","N",01,0,0,"C","","mv_par17","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"18","Somente Saida Vendas?","","","mv_chi","N",01,0,0,"C","","mv_par18","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"19","Gera Excel       ?   ","","","mv_chj","N",01,0,0,"C","","mv_par19","Todos"           ,"","","","","Dolarizados"    ,"Não Gera Excel","","","","","","","","","","","","","","","","","","",""})
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
	
	u_xPutSX1(cPerg,"20","Filtra Dolarizados?" ,"Filtra Dolarizados?","Filtra Dolarizados?","mv_chk","N",6,0,1,"C","","","","","MV_PAR20","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","","Prod Dolar?","Prod Dolar?","Prod Dolar?","ZESTR01")

Return


Static Function NFornec()
Local retorna,aString 
Local i

aString := strtokarr (alltrim(mv_par21), ",")

retorna := '('
For i := 1 to len(aString)
    retorna := retorna + "'"+aString[i]+"'"
        if (i < len(aString))
            retorna := retorna + ','
        endif
Next

retorna := retorna + ')'

return(retorna)
