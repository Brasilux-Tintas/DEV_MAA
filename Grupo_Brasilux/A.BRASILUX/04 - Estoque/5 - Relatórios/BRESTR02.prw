#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRESTR02 º Autor ³ Luís G. de Souza   º Data ³  01/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relação de Custo por produto para fechamento mensal de es- º±±
±±º          ³ toque.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRESTR02()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Relação de Custo/Produto"
     //Local cPict         := ""
     Local titulo        := "RELACAO DE CUSTO/PRODUTO"
     Local nLin          := 80
     Local Cabec1        := " COD.PRODUTO        DESCRICAO                               TIPO  UN  ALMOX           QTD       CUSTO UNIT         CUSTO TOTAL"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "M"
     Private nomeprog    := "BRESTR02" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "ESTR02"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRESTR02" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SB1"
    
    
     If !u_VldAcesso(funname())
     	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	Return 
	 Endif 

     u_zcfga01( 'BRESTR02' ) //LGS#2021118 - Gravação de log de utilização da rotina
	//If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
    //    MsgBox("Acesso não autorizado!", "Atenção...", "STOP")
    //    Return
    //Endif

     DbSelectArea("SB1")
     DbSetOrder(1)
     
     //ValidPerg() //LGS#20200130 - Adequação a release 12.1.25
     Pergunte(cPerg, .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Processa({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  07/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)
       Local cQry1   := ""
       Local cQry2   := ""
       Local cQry3   := ""
       Local _TotQtd := 0.00
       Local _TotCus := 0.00
       Local aFecMes := {}
       Local cMesAno :=""   
       Local nIcm, nY
       If Len(alltrim(MV_PAR10)) ==6
       	  cMesAno := Substr(MV_PAR10,3,6)+Substr(MV_PAR10,1,2)
       Else
          cMesAno := Substr(DTOS(GETMV("MV_ULMES")),1,6)
          MV_PAR10 := cMesAno
       Endif
/*       cQry1 := "SELECT B1_FILIAL,B1_COD,B1_DESC,B1_TIPO,B1_UM,B1_LOCPAD,"+;
       "B1_UPRCD1 AS B1_UPRC, B1_ESTOQUE "           
       */
       cQry2 := "SELECT COUNT(*) AS QTDREG "
       cQry3 += "FROM "+RetSqlName("SB1")+" A WITH (NOLOCK) "
       cQry3 += "WHERE (A.D_E_L_E_T_ <> '*') AND (A.B1_FILIAL = '"+xFilial("SB1")+"') "
       cQry3 += "AND (A.B1_COD   BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
       cQry3 += "AND (A.B1_TIPO  BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
	   cQry3 += "AND (A.B1_GRUPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "       
	   If mv_par14 == 1	
	   	   cQry3 += "AND LEN(A.B1_COD) < 12 "
	   Endif
//       cQry1 += cQry3
       cQry2 += cQry3
//       cQry1 += "ORDER BY A.B1_FILIAL, A.B1_COD "

       TCQuery cQry2 NEW ALIAS "TCQ"
       DbSelectArea("TCQ")
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ PROCREGUA -> Indica quantos registros serao processados para a regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       ProcRegua(TCQ->QTDREG)
       DbSelectArea("TCQ")
       DbCloseArea()

		nIcm := GETMV("MV_ICMPAD")
       
       If mv_par09 == 1
				cQry1 := "WITH TMP AS (SELECT B2_FILIAL,B2_COD,B2_QATU,B2_LOCAL,"+;
				"B1_UM,B1_TIPO,B1_DESC,B1_ESTOQUE,"+;
				"CUSTOMP = CASE WHEN B1_TIPO = 'MP' THEN B1_UPRCD1 ELSE 0 end,"+;
				"PERINT = CASE WHEN B1_ESTOQUE = 'S' THEN B1_LUCRO ELSE B1_LUCRO2 END+"+alltrim(str(nIcm))+"+ISNULL(Z1_COMISSA,B1_COMIS)+B1_PERINT, "+;
				"B1_PRV1,B1_CUSTOR,B1_LUCRO,B1_LUCRO2,ISNULL(Z1_COMISSA,B1_COMIS) AS COMIS,"+;
				"B1_PERINT, B1_GRTRIB, B1_UPRCD1,B2_CM1 "+;
				"FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "+;
				"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = "+Iif(cNumEmp = '01010106',"'010101'","B2_FILIAL")+") AND (B2_COD = B1_COD) "+;
				"LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '"+xFilial("SZ1")+"') AND (SUBSTRING(B2_COD,4,2) = Z1_LINHA) "+;
				"WHERE (SB2.D_E_L_E_T_ <> '*') AND (SB1.R_E_C_N_O_ IS NOT NULL) AND (B2_FILIAL = '"+xFilial("SB2")+"') AND "+;
		       	"(B2_COD   BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') AND "+;
       			"(B1_TIPO  BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') AND "+;
       			"(B1_GRUPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "                
                If mv_par14 == 1
			    	cQry1 += "AND LEN(B1_COD) < 12 "                
                Endif
                If mv_par11 = mv_par12 
                   cLocPad := mv_par11
                   cQry1 += "AND (B2_LOCAL = '"+mv_par11+"') "
                Else
                   cLocPad := ''
                   cQry1 += "AND (B2_LOCAL BETWEEN '"+mv_par11+"' AND '"+mv_par12+"') "
                Endif                                   
                If mv_par15 == 1
	                cQry1 += "AND (SUBSTRING(B2_LOCAL,1,1) NOT IN ('G','M')) " 
                Endif
                If (mv_par07 ==2)
                	cQry1 += " AND (B2_QATU > 0) "
                Elseif (mv_par07 ==3)
                	cQry1 += " AND (B2_QATU < 0 ) "
                Endif
                if !empty(mv_par13)
                   cQry1 += "AND (B1_UM = '"+upper(alltrim(mv_par13))+"') "
				endif                 	
				cQry1 += "), "+;
				"TMP1 AS (SELECT TMP.*,"+;
				"CUSTO = B2_QATU*(CASE "+;
				"WHEN B1_TIPO = 'MP' THEN CUSTOMP "+;
				"WHEN B1_TIPO = 'PI' THEN B1_CUSTOR*1.5 "+;
				"WHEN B1_TIPO = 'PA' THEN CASE WHEN B1_GRTRIB IN('002','005') THEN B1_CUSTOR WHEN LEN(B2_COD) <> 12 THEN B1_PRV1*0.7 ELSE B1_CUSTOR/(1 - (PERINT/100))*0.7 END "+;
				"ELSE B1_CUSTOR*1.5 END),B2_CM1 AS CUNIT "+;
				"FROM TMP) "

/*				"TMP1 AS (SELECT TMP.*,"+;
				"CUSTO = CASE WHEN B1_TIPO = 'MP' THEN CUSTOMP "+;
				"WHEN LEN(B2_COD) <> 12 THEN CASE WHEN B1_TIPO = 'PA' THEN B1_PRV1*0.7 WHEN B1_TIPO = 'PI' THEN B1_CUSTOR*0.56 ELSE B1_CUSTOR*0.7 END "+;
				"ELSE B1_CUSTOR/(1 - (PERINT/100))*CASE WHEN B1_TIPO = 'PI' THEN 0.56 ELSE 0.7 END END FROM TMP) " */


       else
				cQry1 := "WITH TMP1 AS (SELECT B9_FILIAL AS B2_FILIAL,B9_COD AS B2_COD,B9_QINI AS B2_QATU,B9_LOCAL AS B2_LOCAL,"+;
				"B1_UM,B1_TIPO,B1_DESC,B1_ESTOQUE,B9_CM1*B9_QINI AS CUSTO,B9_CM1 AS CUNIT "+;
				"FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK) "+;
				"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B9_FILIAL = B1_FILIAL) AND (B9_COD = B1_COD) "+;
				"WHERE (SB9.D_E_L_E_T_ <> '*') AND (SB1.R_E_C_N_O_ IS NOT NULL) AND (B9_FILIAL = '"+xFilial("SB9")+"') AND "+;
				"(SUBSTRING(SB9.B9_DATA,1,6) = '"+cMesAno+"') AND "+;   
		       	"(B9_COD   BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') AND "+;
       			"(B1_TIPO  BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') AND "+;
       			"(B1_GRUPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
                If mv_par14 == 1
			    	cQry1 += "AND LEN(B1_COD) < 12 "                
                Endif
                If mv_par11 = mv_par12 
                   cLocPad := mv_par11
                   cQry1 += "AND (B9_LOCAL = '"+mv_par11+"') "
                Else
                   cLocPad := ''
                   cQry1 += "  AND (B9_LOCAL BETWEEN '"+mv_par11+"' AND '"+mv_par12+"') "
                Endif                                   
                If mv_par15 == 1
	                cQry1 += "AND (SUBSTRING(B9_LOCAL,1,1) NOT IN ('G','M')) " 
                Endif                
                If (mv_par07 ==2)
                	cQry1 += " AND (B9_QINI > 0) "
                Elseif (mv_par07 ==3)
                	cQry1 += " AND (B9_QINI < 0 ) "
                Endif
                if !empty(mv_par13)
                   cQry1 += "AND (B1_UM = '"+upper(alltrim(mv_par13))+"') "
				endif                 	
				cQry1 += ") "
		endif 
		//Cleber (17/03/16) -> Estava pegando o valor máximo de custo dentre os almox. de cada produto, o correto é somar o valor total e dividir pela qtde total
		cQry1 += "SELECT B2_COD,MAX(B1_UM) AS B1_UM,MAX(B1_TIPO) AS B1_TIPO,MAX(B1_DESC) AS B1_DESC,"+;
		"SUM(B2_QATU) AS B2_QATU,CASE WHEN SUM(B2_QATU) > 0 THEN SUM(CUSTO)/SUM(B2_QATU) ELSE MAX(CUNIT) END AS CUSTO FROM TMP1 GROUP BY B2_COD "
		if (mv_par07 == 2)                            
  			cQry1 += "HAVING (SUM(B2_QATU) > 0) "
		elseif (mv_par07 == 3)                            
  			cQry1 += "HAVING (SUM(B2_QATU) < 0) "
		ENDIF        
		cQry1 += "ORDER BY B2_COD "
		TCQuery cQry1 ALIAS "TCQ" NEW



       	While !Eof()
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica o cancelamento pelo usuario...                             ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        	IncProc("Imprimindo relatório...")
			If lAbortPrint
				@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
   			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin >= 60
            	nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
                nLin += 1
			Endif
			@ nLin, 001 PSAY TCQ->B2_COD    Picture "@R XXX99.99.999-99"
			@ nLin, 020 PSAY TCQ->B1_DESC   Picture "@!"
			@ nLin, 060 PSAY TCQ->B1_TIPO
			@ nLin, 065 PSAY TCQ->B1_UM
			@ nLin, 070 PSAY cLocPad
			@ nLin, 075 PSAY TCQ->B2_QATU   Picture "@E 999,999,999.99"
			@ nLin, 090 PSAY TCQ->CUSTO      Picture "@E 999,999,999.9999"
			@ nLin,110 PSAY Round(TCQ->B2_QATU * TCQ->CUSTO, 2) Picture "@E 999,999,999.9999"
			_TotQtd := _TotQtd+TCQ->B2_QATU
			_TotCus := _TotCus+Round(TCQ->B2_QATU * TCQ->CUSTO, 2)
			aAdd(aFecMes, {TransForm(TCQ->B2_COD, "@R XXX99.99.999-99"), TCQ->B1_DESC, TCQ->B1_TIPO, TCQ->B1_UM, cLocPad, Transform(TCQ->B2_QATU, "@E 999,999,999.99"), Transform(TCQ->CUSTO, "@E 999,999,999.9999"), Transform(Round(TCQ->B2_QATU * TCQ->CUSTO, 2), "@E 999,999,999.9999") })
			nLin++  
   			DbSelectArea("TCQ")
			DbSkip()
   		Enddo

       DbSelectArea("TCQ")
       DbCloseArea()

       DbSelectArea("SB1")
       If (_TotQtd # 0.00) .or. (_TotCus # 0.00)
          If nLin >= 60
             nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
             nLin += 1
          Endif
          If Len(Alltrim(mv_par11)) = 0 // se De Local for "branco" totaliza
          
		  Endif	
          @ nLin,001 PSAY "TOTAL"
          @ nLin,078 PSAY _TotQtd Picture "@E 999,999,999.99"
          @ nLin,113 PSAY _TotCus Picture "@E 999,999,999.9999"
          aAdd(aFecMes, {"TOTAL", "", "", "", "", Transform(_TotQtd, "@E 999,999,999.99"), "", Transform(Round(_TotCus, 2), "@E 999,999,999.9999") })
       Endif

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Finaliza a execucao do relatorio...                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SET DEVICE TO SCREEN
       //Verificação da Existencia dos Diretórios de Controle
       cDirTxt := "C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Excel\"
       cDirOri := "C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original\"
       If !File("C:\Fechamento") //Diretório principal
          MakeDir("C:\Fechamento")
       Endif
       If !File("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))) //Diretório anual
          MakeDir("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4)))
       Endif
       If !File("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Excel") //Arquivos Texto para importação Excel
          MakeDir("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Excel")
       Endif
       If !File("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original") //Arquivos dos relatórios
          MakeDir("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original")
       Endif
       If mv_par08 == 1 //Gera arquivo texto para integração importação Excel
          Private cEOL        := "CHR(13)+CHR(10)"
          //Private cArqTxt   := SUBSTR(cNumEmp,FWSizeFilial()+1,2)+mv_par03+iif(Empty(mv_par13),'',mv_par13)+Substr(dtos(dDataBase), 1, 6)+Iif(Empty(cLocPad), '_TD','_'+MV_PAR11+'-'+MV_PAR12) +".TXT"
          Private cArqTxt     := SUBSTR(cNumEmp,3,6)+mv_par03+iif((mv_par14)==2,'','K')+iif(Empty(mv_par13),'',mv_par13)+Substr(dtos(dDataBase), 1, 6)+Iif(Empty(cLocPad), '_TD','_'+MV_PAR11+'-'+MV_PAR12) +".TXT"
          Private nHdl        := fCreate(cDirTxt+cArqTxt)

          If Empty(cEOL)
             cEOL := CHR(13)+CHR(10)
          Else
             cEOL := Trim(cEOL)
             cEOL := &cEOL
          Endif
          If nHdl == -1
             MsgAlert("O arquivo "+cDirTxt+cArqTxt+" não pode ser criado! Verifique com o Administrador do Sistema.", "Atenção!")
             Return
          Endif
          ProcRegua(Len(aFecMes))
          For nY := 1 To Len(aFecMes)
              IncProc("Gerando arquivo para envio.")
              nTamLin := 132
              cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao

              cLin    := Stuff(cLin, 001, 01, PADR(space(01)     , 01))
              cLin    := Stuff(cLin, 002, 16, PADR(aFecMes[nY][1], 16))
              cLin    := Stuff(cLin, 017, 02, PADR(space(04)     , 03))
              cLin    := Stuff(cLin, 020, 30, PADR(aFecMes[nY][2], 30))
              cLin    := Stuff(cLin, 050, 10, PADR(space(10)     , 10))
              cLin    := Stuff(cLin, 060, 02, PADR(aFecMes[nY][3], 02))
              cLin    := Stuff(cLin, 062, 03, PADR(space(03)     , 03))
              cLin    := Stuff(cLin, 065, 02, PADR(aFecMes[nY][4], 02))
              cLin    := Stuff(cLin, 067, 03, PADR(space(03)     , 03))
              cLin    := Stuff(cLin, 070, 02, PADR(aFecMes[nY][5], 02))
              cLin    := Stuff(cLin, 072, 03, PADR(space(03)     , 03))
              cLin    := Stuff(cLin, 075, 14, PADR(aFecMes[nY][6], 14))
              cLin    := Stuff(cLin, 089, 01, PADR(space(01)     , 01))
              cLin    := Stuff(cLin, 090, 16, PADR(aFecMes[nY][7], 16))
              cLin    := Stuff(cLin, 106, 04, PADR(space(04)     , 04))
              cLin    := Stuff(cLin, 110, 16, PADR(aFecMes[nY][8], 16))
              If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
                 If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                    Exit
                 Endif
              Endif
              /*
               XXX99.99.999-99    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX          XX   XX   XX   999,999,999.99 999,999,999.9999    999,999,999.9999
               123456789012345    123456789012345678901234567890          12   12   12   12345678901234 1234567890123456    1234567890123456
                        1         2         3         4         5         6         7         8         9         10        11        12    
              012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345 */
          Next
          fClose(nHdl)
       Endif

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Se impressao em disco, chama o gerenciador de impressao...          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If aReturn[5] == 1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
          If mv_par08 == 1
             __CopyFile(__RELDIR+wnrel+".##r", cDirOri+SubStr(cArqTxt, 1, Len(cArqTxt)-4)+".##r")
          Endif
       Endif
       MS_FLUSH()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPergºAutor  ³Luís G. de Souza    º Data ³  07/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação das perguntas do relatório.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//LGS#20200130 - Adequação a release 12.1.25
/*
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg   := PADR(cPerg, 10)
       aRegs   := {}

       PutSX1(cPerg, "07", "Lista Zerados/Negat       ?", "", "", "mv_ch7", "N", 1, 0, 1, "C", " ", " ", " ", " ", "mv_par07", "Sim", " ", " ", " ", "Nao", " ", " ", "Somente SLD NEGATIVO", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
       PutSX1(cPerg, "15", "Filtra Depósitos (G1,G2,G3,M1,M2,M3)  ?", "Exclui saldos Depósito", "", "mv_chf", "C", 1, 0, 1, "C", " ", " ", " ", " ", "mv_par15", "Sim", " ", " ", " ", "Nao", " ", " ", 					  "", " ", " ", "", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Cod.Produto    De         	  ?", "Cod.Produto    De   ?", "Cod.Produto    De   ?", "mv_ch1", "C", 15, 0, 0, "G", "", "mv_par01", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       aAdd(aRegs, {cPerg, "02", "Cod.Produto    Ate        	  ?", "Cod.Produto    Ate  ?", "Cod.Produto    Ate  ?", "mv_ch2", "C", 15, 0, 0, "G", "", "mv_par02", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       aAdd(aRegs, {cPerg, "03", "Tipo Produto   De         	  ?", "Tipo Produto   De   ?", "Tipo Produto   De   ?", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , ""})
       aAdd(aRegs, {cPerg, "04", "Tipo Produto   Ate        	  ?", "Tipo Produto   Ate  ?", "Tipo Produto   Ate  ?", "mv_ch4", "C", 02, 0, 0, "G", "", "mv_par04", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , ""})
       aAdd(aRegs, {cPerg, "05", "Do grupo                  	  ?", "Do grupo            ?", "Do grupo            ?", "mv_ch5", "C", 04, 0, 0, "G", "", "mv_par05", ""      ,"", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SBM", ""})
       aAdd(aRegs, {cPerg, "06", "Ate o grupo               	  ?", "Ate o grupo         ?", "Ate o grupo         ?", "mv_ch6", "C", 04, 0, 0, "G", "", "mv_par06", ""      ,"", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SBM", ""})
//       aAdd(aRegs, {cPerg, "07", "Lista Zerados/Negat       ?", "Lista Zerados/Negat ?", "Lista Zerados/Negat ?", "mv_ch7", "C", 01, 0, 0, "C", "", "mv_par07", "Sim"  , "", "", "", "", "Nao"            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})

       aAdd(aRegs, {cPerg, "08", "Gera Arq. p/ Contab.      	  ?", "Gera Arq. p/ Contab.?", "Gera Arq. p/ Contab. ?", "mv_ch8", "C", 01, 0, 0, "C", "", "mv_par08", "Sim"  , "", "", "", "", "Não"            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs, {cPerg, "09", "Tipo de Saldo             	  ?", "Tipo de Saldo       ?", "Tipo de Saldo        ?", "mv_ch9", "N", 01, 0, 0, "C", "", "mv_par09", "Atual", "", "", "", "", "Ult. Fechamento", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs, {cPerg, "10", "Mes/ Ano Fechamento MMAAAA	  ?", "Mes/ Ano Fechamento ?", "Mes/ Ano Fechamento  ?", "mv_cha", "C", 06, 0, 0, "G", "", "mv_par10", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs, {cPerg, "11", "Do local                  	  ?", "Do Local            ?", "Do Local             ?", "mv_chb", "C", 02, 0, 0, "G", "", "mv_par11", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "99" , ""})
       aAdd(aRegs, {cPerg, "12", "Até o Local               	  ?", "Até o Local         ?", "Até o Local          ?", "mv_chc", "C", 02, 0, 0, "G", "", "mv_par12", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "99" , ""})
       aAdd(aRegs, {cPerg, "13", "Unidade Medida                  ?", "Unidade Medida      ?", "Unidade Medida       ?", "mv_chd", "C", 02, 0, 0, "G", "", "mv_par13", ""     , "", "", "", "", ""               , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs, {cPerg, "14", "Somente Menores que 12 Digitos  ?", "Tamanho do Cód. Prod?", "Tamanho do Cód. Prod ?", "mv_che", "C", 01, 0, 0, "C", "", "mv_par14", "Sim"  , "", "", "", "", "Não"            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       //aAdd(aRegs, {cPerg, "15", "Filtra Depósito -SP (G1,G2,G3)  ?", "Exclui saldo G1,G2,G3", "Exclui saldo G1,G2,G3?", "mv_chf", "C", 01, 0, 0, "C", "", "mv_par15", "Sim"  , "", "", "", "", "Não"            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       For i := 1 to Len(aRegs)
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
Return */
