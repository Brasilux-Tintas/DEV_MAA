#include "TOTVS.CH"
#include "TOPCONN.CH"
                                                                                             
User Function BRSACR09()
     Local cStartPath  := GetSrvProfString("Startpath","")
     Local nY, nX
     Private cAcesso   := Repl(" ",10)
     Private aDadosSac := {}
     Private aTotalSac := Array(1, 4) //Array com totalizadores do SAC
     Private aTotalAss := {}
     Private aTotalOco := {}
     Private nMaxCol   := 2330
     Private aProAut   := {} 
     Private nProcede:= nNProcede := 0
	PRIVATE MV_PAR10
     //fPergSAC()  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
     If !Pergunte("SACR09", .T.)
        Return
     Else
        Processa( { || fBuscaInf() }, 'Buscando informações')
     Endif
     If Len(aDadosSac) > 0
        // Monta objeto para impressão
        oPrint := TMSPrinter():New("Estatísticas do SAC")
        oPrint:SetPortrait()
        oPrint:Setup()
        oPrint:StartPage()
        oPrint:SetPaperSize( 9 )

        oFont1 := TFont():New('Courier New', , -09, .T.)
        oFont2 := TFont():New('Arial'      , , -13, .T., .T.) 
        oFont4 := TFont():New('Courier New', , -13, .T., .T.)
        oFont3 := TFont():New('Courier New', , -09, .T., .T.)
        oFont5 := TFont():New('Courier New', , -07, .T., .T., , , ,.T., .F.)
        oPrint:SayBitmap( 0020, 0020, cStartPath+"logo-bras.jpg", 474, 112 )
        oPrint:Line(00140, 0010, 0140, nMaxCol )
     
        oPrint:Say(0100, 0500, Alltrim( SM0->M0_FILIAL ), oFont1, 100, CLR_BLACK )
        oPrint:Say(0100, 1250, "Período: "+DTOC(mv_par01)+" Até : "+DTOC(mv_par02), oFont1, 100, CLR_BLACK )
        oPrint:Say(0050, 0900, "ESTATISTICAS DE ATENDIMENTO", oFont4, 100, CLR_BLACK )
        oPrint:Say(0100, 1990, "Data: "+DTOC( MsDate() ), oFont1, 100, CLR_BLACK )
        
        nLin := 0150
        /*****************************************************************************************/
        /*** RESUMO                                                                            ***/
        /*****************************************************************************************/
        nLinIBx := nLin
        nLin += 0020
        oPrint:Say(nLin, 0030, "Total Atend.:"    , oFont1, 100, CLR_BLACK )
        oPrint:Say(nLin, 0270, TransForm(Len(aDadosSac), "@E 99,999"), oFont3, 100, CLR_BLACK )
        oPrint:Say(nLin, 0500, "Encerrados:"      , oFont1, 100, CLR_BLACK )
        oPrint:Say(nLin, 0740, TransForm(aTotalSac[1][2], "@E 99,999"), oFont3, 100, CLR_BLACK )
        oPrint:Say(nLin, 0970, "Em Aberto:"       , oFont1, 100, CLR_BLACK )
        oPrint:Say(nLin, 1200, TransForm(aTotalSac[1][1], "@E 99,999"), oFont3, 100, CLR_BLACK )
        oPrint:Say(nLin, 1440, "No Prazo:"        , oFont1, 100, CLR_BLACK )
        oPrint:Say(nLin, 1650, TransForm(aTotalSac[1][3], "@E 99,999"), oFont3, 100, CLR_BLACK )
        oPrint:Say(nLin, 1900, "Sem Resposta:"    , oFont1, 100, CLR_BLACK )
        oPrint:Say(nLin, 2150, TransForm(aTotalSac[1][4], "@E 99,999"), oFont3, 100, CLR_BLACK )
        nLin += 0050
        oPrint:Say(nLin, 0030, "Por Assunto:"     , oFont1, 100, CLR_BLACK )
        nVerCol := 2
        For nY := 1 To Len(aTotalAss)
            If aTotalAss[nY][2] > 0
               nLin  += Iif(nVerCol == 1, 0, 0050)
               nVerCol := Iif(nVerCol == 1, 2, 1)
               nCol  := Iif(nVerCol == 1, 0030, 1200)
               oPrint:Say(nLin, nCol , aTotalAss[nY][1]+Transform(aTotalAss[nY][2], "@E 99,999"), oFont1, 100, CLR_BLACK )
            Endif
        Next
        nLinFin := nLin+50
        oPrint:Box(nLinIBx, 0010, nLinFin, nMaxCol )
        nLin := nLinFin
        /*****************************************************************************************/
        /*** INDICADOR DE QUALIDADE                                                            ***/
        /*****************************************************************************************/
        If mv_par03 == 1                                     
           nLinIBx := nLin    + 10
           nLin    := nLinIBx + 20
           oPrint:Say(nLin, 0020, "INDICADOR: Tempo de Resposta ao Cliente quanto a Reclamação(<=5 dias úteis):"+TransForm( ( ( aTotalSac[1][3] / Iif(Len(aDadosSac) == 0, 1, Len(aDadosSac)) ) * 100 ), "@E 999.99")+'%', oFont4, 100, CLR_BLACK )
           nLinFin := nLin+60
           oPrint:Box(nLinIBx, 0010, nLinFin, nMaxCol )
           nLin := nLinFin
        Endif
        /*****************************************************************************************/
        /*** OCORRENCIA X ASSUNTO                                                              ***/
        /*****************************************************************************************/
        If mv_par04 == 1
           For nY := 1 To Len(aTotalAss)
               If aTotalAss[nY][2] > 0
                  If !Empty(mv_par05)
                     If !SubStr(aTotalAss[nY][1], 1, 6) == mv_par05
                        Loop
                     Endif
                  Endif
                  nVerCol := 2
                  nLinIBx := nLin    + 10
                  nLin    := nLinIBx + 20
				  oPrint:Say(nLin, 0030, aTotalAss[nY][1]+Transform(aTotalAss[nY][2], "@E 99,999")     , oFont3, 100, CLR_BLACK ) 
                  For nX := 1 To Len(aTotalOco)
                      If SubStr(aTotalOco[nX][1], 1, 6) == SubStr(aTotalAss[nY][1], 1, 6)
                         nLin    += Iif(nVerCol == 1, 0, 0050)
                         nVerCol := Iif(nVerCol == 1, 2, 1)
                         nCol    := Iif(nVerCol == 1, 0030, 1200)
                         oPrint:Say(nLin, nCol, aTotalOco[nX][2]+Transform(aTotalOco[nX][3], "@E 9,999")     , oFont1, 100, CLR_BLACK )
                         If mv_par07 == 1
                            If nVerCol == 1
                               If aScan( aProAut, { |x| x[1] == aTotalOco[nX][1] } ) > 0
                                  nPos := aScan( aProAut, { |x| x[1] == aTotalOco[nX][1] } )
                                  oPrint:Say(nLin+35, nCol, '            PROCEDE.....: '+Transform(aProAut[nPos][2], "@E 999")+'     NÃO PROCEDE.:'+Transform(aProAut[nPos][3], "@E 999"), oFont5, 100, CLR_BLACK )
                              		nProcede +=	aProAut[nPos][2]
                              		nNProcede += aProAut[nPos][3]
                               Endif
                            Else
                               If aScan( aProAut, { |x| x[1] == aTotalOco[nX][1] } ) > 0
                                  nPos := aScan( aProAut, { |x| x[1] == aTotalOco[nX][1] } )
                                  oPrint:Say(nLin+35, nCol, '            PROCEDE.....: '+Transform(aProAut[nPos][2], "@E 999")+'     NÃO PROCEDE.:'+Transform(aProAut[nPos][3], "@E 999"), oFont5, 100, CLR_BLACK )
                                  nLin += 10    
                                  nProcede +=	aProAut[nPos][2]
                              	  nNProcede += aProAut[nPos][3]
                               Endif
                            Endif
                         Endif  

                         //If nLin >= 3300
                         //   oPrint:EndPage()
                         //   oPrint:StartPage()
                        // Endif
                      Endif
                  Next
                  nLinFin := nLin + 110
                  //If nY == 1
                     oPrint:Box(nLinIBx, 0010, nLinFin, nMaxCol )
                  //Endif 
                  nLin += 60                                  
                  //oPrint:Say(nLin, 0030, aTotalAss[nY][1], oFont3, 100, CLR_BLACK )  
                  oPrint:Say(nLin, 1250, "Procedente --> "+Transform(nProcede, "@E 99,999")        , oFont3, 100, CLR_BLACK )
                  oPrint:Say(nLin, 1750, "Não Procedente --> "+Transform(nNProcede, "@E 99,999")   , oFont3, 100, CLR_BLACK )
                  //oPrint:Say(nLin, 1520, "Total......:"+Transform(aTotalAss[nY][2], "@E 99,999") , oFont3, 100, CLR_BLACK )   
                  nProcede := 0
                  nNProcede := 0
                  nLin := nLinFin    
               
                  
                  If nLin >= 3300
                     oPrint:EndPage()
                     oPrint:StartPage()
                     nLin 	 := 0150
				     nLinIBx := 0150
				     nLin 	 += 0020
                  Endif 
               Endif
           Next
        Endif
        // Visualiza a impressão
        oPrint:EndPage()     
        oPrint:Preview() 
     Else
        MsgStop("Não foram encontrados informações")
     Endif
Return

Static Function fBuscaInf()
       Local cQry1   := ""
       //Local cQry2   := ""
       Local cQry3   := ""
       //Local dDatAux := ""
       //Local nPrazo  := ""       
       //Local nAuxDia := ""
       //Local dDatIni := ""
       Local cBaseQuery
       aTotalSac[1][1] := 0
       aTotalSac[1][2] := 0
       aTotalSac[1][3] := 0
       aTotalSac[1][4] := 0

       ProcRegua( 10 )
 
   		//Cleber (12/07/11) -> Contagem direta p/ preenchimento de ATotalAss
   		If EMPTY(MV_PAR08)
			MV_PAR08 = "1"
		EndIf   
		cBaseQuery := " FROM "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) " +;
   				" LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR WITH (NOLOCK) ON (SZR.D_E_L_E_T_ <> '*') AND (ZR_FILIAL = '"+xFilial("SZR")+"') AND (ZR_NUM = ZQ_NUM) "+;
   				" LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ <> '*') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_TABELA = 'T1') AND (X5_CHAVE = ZR_ASSUNTO) "+;
   				" WHERE (SZQ.ZQ_FILIAL  = '"+xFilial("SZQ")+"') AND (SZQ.D_E_L_E_T_ = '') "    
		IF MV_PAR09 == 1
	    	cBaseQuery += " AND (SZQ.ZQ_DATA BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"') "
		ENDIF        
	 	If !Empty(mv_par05)
			cBaseQuery += " AND (SZR.ZR_ASSUNTO = '"+MV_PAR05+"') "
		ENDIF 	    	
		IF !Empty(mv_par06)
			cBaseQuery += "  AND (SZR.ZR_OCORREN = '"+MV_PAR06+"') "
		ENDIF

		DO CASE 
	 	CASE MV_PAR08 = "1"     							//Todos    
	 		IF MV_PAR10 == 1
		   		cBaseQuery += "AND (SZQ.ZQ_TIPOSAC <> '5')"   // Exceto Internos
		  	ENDIF
	 	CASE MV_PAR08 = "2"
	   		cBaseQuery +=" AND SZQ.ZQ_TIPOSAC = '1' "   // Reclamação
	   	CASE MV_PAR08 = "3"                         
			cBaseQuery +=" AND SZQ.ZQ_TIPOSAC = '2' "   // Sugestão
	   	CASE MV_PAR08 = "4"
	   		cBaseQuery +=" AND SZQ.ZQ_TIPOSAC = '3' "   // Comodato
	   	CASE MV_PAR08 = "5"
	   		cBaseQuery +=" AND SZQ.ZQ_TIPOSAC = '4' "   // Outros
	   	CASE MV_PAR08 = "6"
	   		cBaseQuery +=" AND SZQ.ZQ_TIPOSAC = '5' "   // Interno
	   	ENDCASE	
	   	
       	cBaseQuery += " ) "


   		cQry1 := " WITH TMP AS (SELECT DISTINCT SZQ.ZQ_NUM,ZR_ASSUNTO,ISNULL(X5_DESCRI,'') AS DESCR,"+;
   				"DATARESP = ISNULL((SELECT MIN(SZS.ZS_DATA) "+;
             	"FROM  "+RetSQLName("SZS")+" SZS WITH (NOLOCK) "+;
             	"WHERE (SZS.ZS_FILIAL  = SZQ.ZQ_FILIAL) "+;
               	"AND (SZS.D_E_L_E_T_ = '') "+;
               	"AND (SZS.ZS_NUM  = SZQ.ZQ_NUM ) "+;   // adicionado PRO, DIR e COM para contagem de sac com respostas, pois estava afetando o indice dos sacs respondidos (andré 03/03/16)
               	"AND (SZS.ZS_LOG IN('ATE','DIA','DIR','COM','FIN','TEC', 'EXP','VIA','-CO','#MA','REC','PRO','SUP'))),'') "
		cQry1 += cBaseQuery
   		cQry1 += " SELECT ZR_ASSUNTO AS ASSUNTO,MAX(DESCR) AS DESCR,COUNT(*) AS QTDE FROM TMP "
	   	If MV_PAR09 != 1
		   cQry1 += "WHERE (DATARESP BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"') "
	   	EndIf          
	   	cQry1 += " GROUP BY ZR_ASSUNTO ORDER BY ASSUNTO"

   		TCQuery cQry1 ALIAS "TCQ" NEW    
       		 	
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             IncProc("Buscando assuntos...")
//             aAdd(aTotalAss, {Alltrim(TCQ->X5_CHAVE)+' - '+Alltrim(TCQ->X5_DESCRI)+Repl('.', 25 - Len(Alltrim(TCQ->X5_CHAVE)+' - '+Alltrim(TCQ->X5_DESCRI)))+": ", 0 } )
             If TCQ->QTDE <> 0
             	aAdd(aTotalAss, {Alltrim(TCQ->ASSUNTO)+' - '+Alltrim(TCQ->DESCR)+Repl('.', 25 - Len(Alltrim(TCQ->ASSUNTO)+' - '+Alltrim(TCQ->DESCR)))+": ", TCQ->QTDE } )
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       ProcRegua( 300 )
       cQry1 := ""
       cQry1 += "WITH TMP AS(SELECT DISTINCT SZQ.ZQ_NUM,ZR_ASSUNTO, SZQ.ZQ_CLIENTE, SZQ.ZQ_DATA, SZQ.ZQ_STATUS, SZQ.ZQ_FLAG,SZQ.ZQ_TIPOSAC,"
       cQry1 += "DATARESP = ISNULL((SELECT MIN(SZS.ZS_DATA) "+;
             	"FROM  "+RetSQLName("SZS")+" SZS WITH (NOLOCK) "+;
             	"WHERE (SZS.ZS_FILIAL  = SZQ.ZQ_FILIAL) "+;
               	"AND (SZS.D_E_L_E_T_ = '') "+;
               	"AND (SZS.ZS_NUM  = SZQ.ZQ_NUM ) "+;   // adicionado PRO, DIR e COM para contagem de sac com respostas, pois estava afetando o indice dos sacs respondidos (andré 03/03/16)
               	"AND (SZS.ZS_LOG IN('ATE','DIA','DIR','COM','FIN','TEC', 'EXP','VIA','-CO','#MA','REC','PRO','SUP'))),'') "
       cQry1 += cBaseQuery
	   cQry1 += "SELECT * FROM TMP "
	
//'ATE','DIA','DIR','COM','FIN','TEC', 'EXP','VIA','-CO','#MA','REC','PRO','SUP'

	   	If MV_PAR09 != 1
		   cQry1 += "WHERE (DATARESP BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"') "
	   	EndIf          

	   	cQry1 += "ORDER BY TMP.ZQ_NUM "
       
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             IncProc("Buscando atendimentos...")
             aAdd(aDadosSac, {TCQ->ZQ_NUM, TCQ->ZQ_CLIENTE, TCQ->ZQ_DATA, TCQ->ZQ_STATUS, TCQ->ZQ_FLAG,TCQ->DATARESP , } )

             aDadosSac[Len(aDadosSac)][7] := Iif(Empty(TCQ->DATARESP),((dDatabase)-(STOD(TCQ->ZQ_DATA)+7)),STOD(TCQ->DATARESP) - STOD(TCQ->ZQ_DATA))
			 aTotalSac[1][1] += Iif(TCQ->ZQ_STATUS == '1', 1, 0)
             aTotalSac[1][2] += Iif(TCQ->ZQ_STATUS == '2', 1, 0)
             aTotalSac[1][3] += Iif(aDadosSac[Len(aDadosSac)][7] <=7 .and. !Empty(TCQ->DATARESP), 1, 0)
             aTotalSac[1][4] += Iif(Empty(TCQ->DATARESP), 1, 0)

             //Ocorrência x Assunto
             If mv_par04 == 1
                cQry3 := ""
                cQry3 += "SELECT SZR.ZR_ASSUNTO, SZR.ZR_OCORREN, SU9.U9_DESC "
                cQry3 += "FROM "+RetSQLName("SZR")+" SZR WITH (NOLOCK) "
                cQry3 += "LEFT OUTER JOIN "+RetSQLName("SU9")+" SU9 WITH (NOLOCK) ON SU9.U9_FILIAL = '"+xFilial("SU9")+"' AND SU9.U9_ASSUNTO = SZR.ZR_ASSUNTO AND SU9.U9_CODIGO = SZR.ZR_OCORREN AND SU9.D_E_L_E_T_ = '' "
                cQry3 += "WHERE SZR.ZR_FILIAL  = '"+xFilial("SZR")+"' "
                cQry3 += "  AND SZR.D_E_L_E_T_ = '' "
                cQry3 += "  AND SZR.ZR_NUM     = '"+TCQ->ZQ_NUM+"' "
                If !Empty(mv_par05)
                   cQry3 += "  AND SZR.ZR_ASSUNTO = '"+MV_PAR05+"' "
                   If !Empty(mv_par06)
                      cQry3 += "  AND SZR.ZR_OCORREN = '"+MV_PAR06+"' "
                   Endif
                Endif
                cQry3 += "GROUP BY SZR.ZR_ASSUNTO, SZR.ZR_OCORREN, SU9.U9_DESC "
                TCQuery cQry3 ALIAS "ASS" NEW
                DbSelectArea("ASS")
                DbGoTop()
                While !Eof()
                      If mv_par07 == 1
                         cQry3 := ""
                         cQry3 += "SELECT TOP 1 ZS_PROCEDE "
                         cQry3 += "FROM "+RetSQLName("SZS")+" SZS WITH (NOLOCK) "
                         cQry3 += "WHERE SZS.ZS_FILIAL   = '"+xFilial("SZS")+"' "
                         cQry3 += "  AND SZS.D_E_L_E_T_  = '' "
                         cQry3 += "  AND SZS.ZS_NUM      = '"+TCQ->ZQ_NUM+"' "
                         cQry3 += "  AND SZS.ZS_PROCEDE <> '' "
                         //Cleber(25/01/17) -> Exclusão de GROUP BY para pegar apenas o último lançamento de procede/não procede. Pelo GROUP BY vai pegar aleatoreamente.
//                       //cQry3 += "GROUP BY SZS.ZS_PROCEDE " 
                         cQry3 += "ORDER BY SZS.R_E_C_N_O_ DESC "
                         TCQuery cQry3 ALIAS "PRN" NEW
                         DbSelectArea("PRN")
                         While !Eof()
                               nPos := aScan( aProAut, { |x| Alltrim(x[1]) == Alltrim(ASS->ZR_ASSUNTO+ASS->ZR_OCORREN) } )
                               If nPos == 0
                                  If PRN->ZS_PROCEDE $ 'S.A'
                                     aAdd(aProAut, {ASS->ZR_ASSUNTO+ASS->ZR_OCORREN, 1, 0} )
                                  Else
                                     aAdd(aProAut, {ASS->ZR_ASSUNTO+ASS->ZR_OCORREN, 0, 1} )
                                  Endif
                               Else
                                  If PRN->ZS_PROCEDE $ 'S.A'
                                     aProAut[nPos][2] += 1
                                  Else
                                     aProAut[nPos][3] += 1
                                  Endif
                               Endif
                               DbSelectArea("PRN")
                               DbSkip()
                         EndDo
                         DbSelectArea("PRN")
                         DbCloseArea()
                      Endif
                      nPos :=  aScan( aTotalOco, { |x| Alltrim(x[1]) == Alltrim(ASS->ZR_ASSUNTO+ASS->ZR_OCORREN) } )
                      If nPos == 0
                         aAdd(aTotalOco, { ASS->ZR_ASSUNTO+ASS->ZR_OCORREN, Alltrim(ASS->ZR_OCORREN)+' - '+Alltrim(ASS->U9_DESC)+Repl('.', 40 - Len( Alltrim(ASS->ZR_OCORREN)+' - '+Alltrim(ASS->U9_DESC) ))+': ', 1 })
                      Else
                         aTotalOco[nPos][3] += 1
                      Endif
                      DbSelectArea("ASS")
                      DbSkip()
                EndDo
                DbSelectArea("ASS")
                DbCloseArea()
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       IncProc()
       DbSelectArea("TCQ")
       DbCloseArea()
Return

//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function fPergSAC()
       //PutSX1(cPerg, "08"  ,  "Ordem dos itens     ?", "Ordem dos itens     ?", "Ordem dos itens     ?", "mv_ch8", "N",  1, 0, 1, "C"  , "","","","",             "mv_par08","Pedido+Itens", "Pedido+Itens", "Pedido+Itens"   , ""   , "Descrição itens", "Descrição itens", "Descrição itens", "Itens+'BM'+Variação", "Itens+'BM'+Vari", "Itens+'BM'+Vari" , "Quadrantes", "Quadrantes", "Quadrantes",  "Cód. Produto", "Cód. Produto", "Cód. Produto",{},{},{}, "" )
         aHelpPor := {}
         //              1234567890123456789012345678901234567890
         aAdd(aHelpPor, {'Informe o perido inicial para proces-   '})
         aAdd(aHelpPor, {'samento do relatório.'})     
        // aAdd(aHelpPor, {{'1 - Todos / 2 - Reclamação / 3 - Sugestão / 4 - Comodato / 5 - Outros / 6 - Interno'},{""},{""}})     
         
         PutSX1("SACR09"  , "01"      ,  "Periodo de"                     , "Periodo de"                     , "Periodo de"                     , "mv_ch1", "D"      ,  8          , 0           , 1          , "G"     , ""        , ""      , ""         , ""       , "mv_par01", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}         , {}           , ".SACR0901." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe o perido final para processamen-')
         aAdd(aHelpPor, 'to do relatório.')
         PutSX1("SACR09"  , "02"      ,  "Periodo até"                    , "Periodo até"                    , "Periodo até"                    , "mv_ch2", "D"      ,  8          , 0           , 1          , "G"     , ""        , ""      , ""         , ""       , "mv_par02", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0902." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe Sim para mostrar o indicador de ')
         aAdd(aHelpPor, 'qualidade.')
         PutSX1("SACR09"  , "03"      ,  "Mostra Indicador de Qualidade"  , "Mostra Indicador de Qualidade"  , "Mostra Indicador de Qualidade"  , "mv_ch3", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par03", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0903." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe Sim para o sistema mostrar as   ')
         aAdd(aHelpPor, 'ocorrências x assunto.')
         PutSX1("SACR09"  , "04"      ,  "Mostra Ocorren. X Assunto"      , "Mostra Ocorren. X Assunto"      , "Mostra Ocorren. X Assunto"      , "mv_ch4", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par04", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0904." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe um assunto específico para ser  ')
         aAdd(aHelpPor, 'analisado.')
         PutSX1("SACR09"  , "05"      ,  "Assunto Específico"             , "Assunto Específico"             , "Assunto Específico"             , "mv_ch5", "C"      ,  6          , 0           , 1          , "G"     , ""        , "T1"    , ""         , ""       , "mv_par05", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0905." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe uma ocorrência específica para  ')
         aAdd(aHelpPor, 'ser analisado.')
         PutSX1("SACR09"  , "06"      ,  "Ocorrência Específica"          , "Ocorrência Específica"          , "Ocorrência Específica"          , "mv_ch6", "C"      ,  6          , 0           , 1          , "G"     , ""        , "SU9XXZ", ""         , ""       , "mv_par06", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0906." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Informe Sim para o sistema mostrar as   ')
         aAdd(aHelpPor, 'Atendimentos procedentes/não procedentes')
         PutSX1("SACR09"  , "07"      ,  "Mostra Qtd. Procede/Não Procede", "Mostra Qtd. Procede/Não Procede", "Mostra Qtd. Procede/Não Procede", "mv_ch7", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par07", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0907." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Escolha o tipo de sac  -  Reclamação    ')
		 aAdd(aHelpPor,'1 - Todos')     
		 aAdd(aHelpPor,'2 - Reclamação')
		 aAdd(aHelpPor,'3 - Sugestão')
		 aAdd(aHelpPor,'4 - Comodato')
		 aAdd(aHelpPor,'5 - Outros')
		 aAdd(aHelpPor,'6 - Interno')
         PutSX1("SACR09", "08"      ,  "Escolha o tipo de Sac"          , "Escolha o tipo de Sac"          , "Escolha o tipo de Sac"          , "mv_ch8", "C"      ,  1          , 0           , 1          , "G"     , ""        , ""      , ""         , ""       , "mv_par08","","","","","","","","","","","","","","","","", aHelpPor,"","",".SACR0908." )
         PutSX1("SACR09","09","Filtro data", "","", "mv_ch9","N",1,0,1,"C","","","","","mv_par09","Dt Emissao", "","", "", "Resposta","","", "", "","","","","","","","",nil,nil,nil,".SACR0908." )
         aHelpPor := {}
         aAdd(aHelpPor, 'Deseja excluir os SACs de tipo ')
         aAdd(aHelpPor, 'Interno?')
         PutSX1("SACR09"  , "10"      ,  "Excluir SACs tipo Interno?"  , "Excluir SACs tipo Interno?"  , "Excluir SACs tipo Interno?"  , "mv_cha", "N"      ,  1          , 0           , 1          , "C"     , ""        , ""      , ""         , ""       , "mv_par10", "Sim"     , "Sim"       , "Sim"       , ""        , "Não"     , "Não"       , "Não"       , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}          , {}          , ".SACR0910." )
       //PutSX1([ cGrupo ], [ cOrdem ], [ cPergunt ]                      , [ cPerSpa ]                      , [ cPerEng ]                      , [ cVar ], [ cTipo ], [ nTamanho ], [ nDecimal ], [ nPresel ], [ cGSC ], [ cValid ], [ cF3 ] , [ cGrpSxg ], [ cPyme ], [ cVar01 ], [ cDef01 ], [ cDefSpa1 ], [ cDefEng1 ], [ cCnt01 ], [ cDef02 ], [ cDefSpa2 ], [ cDefEng2 ], [ cDef03 ], [ cDefSpa3 ], [ cDefEng3 ], [ cDef04 ], [ cDefSpa4 ], [ cDefEng4 ], [ cDef05 ], [ cDefSpa5 ], [ cDefEng5 ], [ aHelpPor ], [ aHelpEng ], [ aHelpSpa ], [ cHelp ] )
Return*/