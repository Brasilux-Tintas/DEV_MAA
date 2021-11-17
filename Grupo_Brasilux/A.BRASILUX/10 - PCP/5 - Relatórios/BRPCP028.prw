#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP028 ºAutor ³ André Maester          º Data ³ 10/04/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Saldo em estoque de Produtos inflamáveis, agrupados por    º±±
±±º          ³ Embalagens ou por Linha.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*
MV_PAR01 - Do Produto                 
MV_PAR02 - Até o Produto              
MV_PAR03 - Do Grupo de Produto        
MV_PAR04 - Até o Grupo de Produto     
MV_PAR05 - Do Armazem                 
MV_PAR06 - Até o Armazem              
MV_PAR07 - Padrão Relatório           (Embalagem   /  Linha)
MV_PAR08 - Ordenado por               (Volume Dec  /  Linha/Emb)
MV_PAR09 - Somente Inflamáveis/Todos  (Inflamáveis /  Todos)

*/
User Function BRPCP028()     
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

     CbTxt     := ""
     CbCont    := 0
     nOrdem    := 0
     Alfa      := 0
     Z         := 0
     M         := 0
     tamanho   := "P"
     limite    := 80
     titulo    := "SALDO DE PRODUTOS POR EMBALAGEM / LINHA"
     cDesc1    := PADC("Programa p/ emitir Rel. de saldos de Produtos por linha ou por embalagem",74)
     cDesc2    := ""
     cDesc3    := PADC(" ",74)
     cCabec    := PADC("Saldo de Produtos",27)
     cCabPro   := ""
     cNatureza := ""
     aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog  := "BRPCP028"
     cPerg     := "BRPCP28"
     nLastKey  := 0
     lContinua := .T.
     nLin      := 0
     nCol      := 0
     wnrel     := "BRPCP028"
     nTipo     := 18
     m_pag     := 01     
     nTamNf    := 80     // Apenas Informativo
     cString   := "SB2"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If !u_VldAcesso(funname())
      	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
     	Return 
	 Endif 


     //ValidPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg,.F.)   

     wnrel := SetPrint(cString, wnrel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .f., ,.f., Tamanho)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     RptStatus({|| RptDetail()})
     Return
     Static Function RptDetail()

	 Local  nSomaVol, cUniMed, cArmazem, cQuery, nDivisor, nSTotK, nSTotL
	 nDivisor := Iif(GetMv("MV_XDIVVOL") <= 0,1,GetMv("MV_XDIVVOL")) // Parametro solicitado por Thiago Diniz (Criar fator de divisão para elaboração de relatório para vistoria do bombeiro) 13-04-15
    
     cQuery := ""
	 If MV_PAR07 == 2  // Embalagem ou por Linha  
    	 cQuery += " SELECT B2_LOCAL AS 'ARMAZEM', Z5_EMB+' - '+Z5_DESCR AS 'EMBALAGEM', B1_SEGUM, SUM(B2_QATU * B1_CONV) AS 'QTDTOTAL' "
 	 Else
		 cQuery += " SELECT B2_LOCAL AS 'ARMAZEM', SUBSTRING(B2_COD,4,2)+' - '+Z1_DESCR AS 'LINHA', B1_SEGUM, SUM(B2_QATU * B1_CONV)  AS 'QTDTOTAL'  
	 Endif
	 cQuery += " FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
	 cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND SB1.D_E_L_E_T_ ='' "
	 cQuery += " LEFT OUTER JOIN "+RetSqlName("SYD")+" SYD WITH (NOLOCK) ON (YD_FILIAL = '"+xFilial("SYD")+"') AND YD_TEC = B1_POSIPI AND YD_EX_NCM = B1_EX_NCM AND SYD.D_E_L_E_T_ ='' "
	 cQuery += " LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (Z1_FILIAL = '"+xFilial("SZ1")+"') AND Z1_LINHA = SUBSTRING(B2_COD,4,2) AND SZ1.D_E_L_E_T_ ='' "
	 cQuery += " LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (Z5_FILIAL = '"+xFilial("SZ5")+"') AND Z5_EMB = SUBSTRING(B2_COD,11,2) AND SZ5.D_E_L_E_T_ ='' "
	 cQuery += " WHERE SB1.D_E_L_E_T_ ='' "
	 cQuery += " AND (B2_FILIAL = '"+xFilial("SB2")+"') AND (B2_QATU >0) AND (B1_TIPO ='PA') "
	 If MV_PAR09 == 1 // Somente inflamáveis ou todos os produtos
		 cQuery += " AND (YD_XCLASRI = '3') "
	 Endif	
	 cQuery += " AND LEN(B2_COD)=12 "
	 cQuery += " AND B2_COD   BETWEEN ('"+MV_PAR01+"') AND ('"+MV_PAR02+"')"
	 cQuery += " AND B1_GRUPO BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')"
	 cQuery += " AND B2_LOCAL BETWEEN ('"+MV_PAR05+"') AND ('"+MV_PAR06+"')"
	 If MV_PAR07 == 2 // Embalagem ou por Linha 
	 	cQuery += " GROUP BY B2_LOCAL, B1_SEGUM, Z5_EMB, Z5_DESCR "
     Else
	 	cQuery += " GROUP BY B2_LOCAL,SUBSTRING(B2_COD,4,2), B1_SEGUM, Z1_DESCR "
     Endif
     cQuery += " ORDER BY B2_LOCAL, B1_SEGUM, "+Iif(MV_PAR08 == 1,"QTDTOTAL DESC", Iif(MV_PAR07 ==2,"Z5_EMB","SUBSTRING(B2_COD,4,2)")) "

     TCQuery cQuery NEW ALIAS "TCQ"        

     //               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
     //           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     cCabec1  := "Estoque do Armazém "+(MV_PAR05) +" Até "+(MV_PAR06)+"                                       Versão ( "+cValToChar(nDivisor)+" )"
     cCabec2  := "Armazém         "+iif(MV_PAR07 == 2,"Embalagens","Linhas")+"                      Unid. Med     Volume/Peso"
     cCabec3  := ""
     Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
     nLin = 08

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
     DbSelectArea("TCQ")
     SetRegua(RecCount())

     nSomaVol := 0
     nSTotK   := 0
     nSTotL	  := 0
     cUniMed  := ""
     cArmazem := ""
     DbSelectArea("TCQ")
     DbGoTop()
     While ! Eof()
     	If Empty(cUniMed)
	     	cArmazem := TCQ->ARMAZEM
    	Endif
     	If nLin >= 60
        	nLin++
            @ nLin,000 pSay replicate("_",80)
            Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
            nLin := 08
        Endif
        If ((Alltrim(TCQ->ARMAZEM) <> Alltrim(cArmazem)) .or. (Alltrim(TCQ->B1_SEGUM) <> Alltrim(cUniMed))) .and. (!Empty(cUniMed))
            nLin++
            nLin++
            @ nLin,000 pSay replicate("_",80)
			@ nLin,000 pSay "ARMAZEM -> "+cArmazem+"                        TOTAL "
			@ nLin,054 pSay nSomaVol picture "@E 9,999,999.99"+ '  '+cUniMed
            cArmazem := TCQ->ARMAZEM
			cUniMed  := TCQ->B1_SEGUM
			nSomaVol := 0
        Endif
        nLin++
        cUniMed  := TCQ->B1_SEGUM
        @ nLin,000 pSay TCQ->ARMAZEM 
        @ nLin,016 pSay iif(MV_PAR07 ==2,Substr(TCQ->EMBALAGEM,1,30), Substr(TCQ->LINHA,1,30))
		@ nLin,050 pSay TCQ->B1_SEGUM
        @ nLin,054 pSay (TCQ->QTDTOTAL / nDivisor) picture "@E 9,999,999.99"  
		nSomaVol += (TCQ->QTDTOTAL / nDivisor)          
		nSTotK += Iif(Substr(cUniMed,1,1) $ 'K', (TCQ->QTDTOTAL / nDivisor), 0)
       	nSTotL += Iif(Substr(cUniMed,1,1) $ 'L', (TCQ->QTDTOTAL / nDivisor), 0)
       	DbSelectArea("TCQ")
		DbSkip() 
       	IncRegua()		   	
     Enddo
     nLin++
     @nLin,000 pSay replicate("_",80)
	 @nLin,000 pSay "ARMAZEM -> "+cArmazem+"                        TOTAL "
	 @nLin,054 pSay nSomaVol picture "@E 9,999,999.99"+ '  '+cUniMed
     nLin++
     @nLin,000 psay replicate("_",80)
     nLin++
	 @nLin,000 pSay "TOTAL LITROS -> "
     @nLin,018 psay nSTotL picture "@E 999,999,999.99"
	 @nLin,036 pSay "TOTAL QUILOS -> "
     @nLin,054 psay nSTotK picture "@E 999,999,999.99"

     nLin++
     @nLin,000 psay replicate("_",80)
     
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³                      FIM DA IMPRESSAO                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Dbselectarea("TCQ")
     Dbclosearea()
     
     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        dbcommitAll()
        ourspool(wnrel)
     Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Do Produto                 ?", "", "", "mv_ch1", "C", 15, 0, 0, "G", "", "mv_par01", ""           , ""           , ""           , "", "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "02", "Até o Produto              ?", "", "", "mv_ch2", "C", 15, 0, 0, "G", "", "mv_par02", ""           , ""           , ""           , "", "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "03", "Do Grupo de Produto        ?", "", "", "mv_ch3", "C", 04, 0, 0, "G", "", "mv_par03", ""           , ""           , ""           , "", "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "04", "Até o Grupo de Produto     ?", "", "", "mv_ch4", "C", 04, 0, 0, "G", "", "mv_par04", ""           , ""           , ""           , "", "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "05", "Do Armazem                 ?", "", "", "mv_ch5", "C", 02, 0, 0, "G", "", "mv_par05", ""           , ""           , ""           , "", "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "06", "Até o Armazem              ?", "", "", "mv_ch6", "C", 02, 0, 0, "G", "", "mv_par06", ""           , ""           , ""           , "", "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "07", "Padrão Relatório           ?", "", "", "mv_ch7", "N", 01, 0, 2, "C", "", "mv_par07", "Linha      ", "Linha      ", "Linha      ", "", "", "Embalagem", "Embalagem", "Embalagem", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "08", "Ordenado por               ?", "", "", "mv_ch8", "N", 01, 0, 2, "C", "", "mv_par08", "Volume Dec ", "Volume Dec ", "Volume Dec ", "", "", "Linha/Emb", "Linha/Emb", "Linha/Emb", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "09", "Somente Inflamáveis/Todos  ?", "", "", "mv_ch9", "N", 01, 0, 2, "C", "", "mv_par09", "Inflamáveis", "Inflamáveis", "Inflamáveis", "", "", "Todos    ", "Todos    ", "Todos    ", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

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
       
       DbSelectArea(_sAlias) 
       
Return*/