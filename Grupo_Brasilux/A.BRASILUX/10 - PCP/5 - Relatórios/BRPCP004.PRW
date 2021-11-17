#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP004 ºAutor ³ Cleber Orati Domingues º Data ³ 23/05/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Produção em Litros por Embalagem.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros

mv_par01  -  Dt. Fabr. de?
mv_par02  -  Dt. Fabr Ate?
mv_par03  -  Ordem de Impr.? (1 - Vol. Decresc. ### 2 - Cod. Produto)
mv_par04  -  Turno Trabalho ?
*/
User Function BRPCP004()     
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
     titulo    := "PRODUTOS FABRICADOS(EM LITROS)"
     cDesc1    := PADC("Programa p/ emitir Rel. de Produtos Fabricados em Litros.",74)
     cDesc2    := ""
     cDesc3    := PADC(" ",74)
     cCabec    := PADC("Prod. Fabricados",27)
     cCabPro   := ""
     cNatureza := ""
     aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog  := "BRPCP004"
     cPerg     := "BRPC04"
     nLastKey  := 0
     lContinua := .T.
     nLin      := 0
     nCol      := 0
     wnrel     := "BRPCP004"
     nTipo     := 18
     m_pag     := 01     
     nTamNf    := 80     // Apenas Informativo
     cString   := "SD3"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //ValidPerg()  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
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

     #IFDEF WINDOWS
            RptStatus({|| RptDetail()})
            Return
            Static Function RptDetail()
     #ENDIF

     Local cProduto, nSomaVol, cGrupo,cPict
     //Local aTcq, cArqTcq, cArq, cAux, cProd, nCont, nTotal, nVolume 
     cGrupo := iif(mv_par05 == 1,"SUBSTRING(D3_COD,1,10)","SUBSTRING(D3_COD,4,2)")  
     cDescr := iif(mv_par05 == 1,"MAX(B1_DESC)","MAX(Z1_DESCR)")  
     cPict := iif(mv_par05 == 1,"@R XXX99.99.999","99")  
     
     cQuery = "SELECT "+cGrupo+" AS GRUPO,"+cDescr+" AS DESCRICAO,SUM(D3_QUANT*Z5_VOLUME) AS VOLUME "+;
              "FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) "+;
              "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D3_FILIAL = B1_FILIAL) AND (D3_COD = B1_COD) "+;
              "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') AND (Z5_FILIAL = '"+xFilial("SZ5")+"') AND (SUBSTRING(D3_COD,11,2) = SZ5.Z5_EMB) "+;
              "LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '"+xFilial("SZ1")+"') AND (SUBSTRING(D3_COD,4,2) = SZ1.Z1_LINHA) "+;
              "WHERE (SD3.D3_FILIAL = '"+xFilial("SD3")+"') AND "+;
              " (LEN(D3_COD) = 12) AND "+; 
              " (SUBSTRING(D3_COD,11,2) NOT IN('00','99')) AND "+;
              " (D3_TM = '010') AND "+;
              " (D3_ESTORNO <> 'S') AND "
              If !Empty(mv_par04)
                 cQuery += "(D3_TURNO = '"+mv_par04+"') AND "
              Endif
     cQuery += " (SD3.D_E_L_E_T_ <> '*') AND "+;
               " SD3.D3_EMISSAO BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"'"+;
               " GROUP BY "+cGrupo+ " ORDER BY "+IIF(mv_par03 == 1,"VOLUME DESC","GRUPO")
     TCQuery cQuery NEW ALIAS "TCQ"        
     
	IF mv_par05 == 1
		cQuery := "SELECT D3_COD AS GRUPO,SUM(D3_QUANT) AS QTDE,MAX(B2_LOCALIZ) AS LOCALIZ "+;
              "FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) "+;
              "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D3_FILIAL = B1_FILIAL) AND (D3_COD = B1_COD) "+;
              "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (D3_FILIAL = B2_FILIAL) AND (D3_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "+;
              "WHERE (SD3.D3_FILIAL = '"+xFilial("SD3")+"') AND "+;
              " (LEN(D3_COD) = 12) AND "+; 
              " (SUBSTRING(D3_COD,11,2) NOT IN('00','99')) AND "+;
              " (D3_TM = '010') AND "+;
              " (D3_ESTORNO <> 'S') AND "
              If !Empty(mv_par04)
                 cQuery += "(D3_TURNO = '"+mv_par04+"') AND "
              Endif
              cQuery += " (SD3.D_E_L_E_T_ <> '*') AND "+;
               " SD3.D3_EMISSAO BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"'"+;
               " GROUP BY D3_COD ORDER BY GRUPO"
		      TCQuery cQuery NEW ALIAS "TCQ1"        
 	endif 

     //               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
     //           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     cCabec2  := "Produto         Descricao                     Volume(Litros)"
     cCabec1  := "PRODUCAO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
     If !empty(mv_par04)
        cCabec1 += "(TURNO "+mv_par04+")"
     Endif
     cCabec3  := ""
     Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
     nLin = 08


     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
     DbSelectArea("TCQ")
     SetRegua(RecCount())

     nSomaVol = 0
     DbSelectArea("TCQ")
     DbGoTop()
     While ! Eof()
           	If nLin > 60
              nLin++
              @ nLin,000 pSay replicate("_",80)
              Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              nLin := 08
           	Endif
           	cProduto = TCQ->GRUPO
           	nLin++
           	@ nLin,00 pSay TCQ->GRUPO Picture cPict
           	@ nLin,16 psay TCQ->DESCRICAO
           	@ nLin,48 pSay TCQ->VOLUME picture "@E 9,999,999.99"  
			nSomaVol += TCQ->VOLUME           
			if mv_par05 == 1
	  			Dbselectarea("TCQ1")
    	       	dbgotop()
           		locate for substr(TCQ1->GRUPO,1,10) == cProduto

           		While !eof() .and. (substr(TCQ1->GRUPO,1,10) == cProduto)
                 	If nLin > 60
                    	nLin++
                    	@nLin,000 psay replicate("_",80)
                    	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                    	nLin := 08
                 	Endif
                 	nLin++
                 	@nLin,16 psay TCQ1->GRUPO picture "@R XXX99.99.999-99"
                 	@nLin,32 psay TCQ1->qtde picture "@E 999,999"
                 	@nLin,40 psay TCQ1->localiz
                 	dbselectarea("TCQ1")
                 	dbskip()
           		enddo
			endif
           	dbselectarea("TCQ")
   			dbskip() 
           	IncRegua()		   	
     Enddo
     nLin++
     @nLin,00 psay replicate("_",80)
     nLin++
     @nLin,46 psay nSomaVol picture "@E 999,999,999.99"
     nLin++
     @nLin,00 psay replicate("_",80)
     
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³                      FIM DA IMPRESSAO                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Dbselectarea("TCQ")
     Dbclosearea()
     
	if mv_par05 == 1
	     Dbselectarea("TCQ1")
    	 Dbclosearea()
	endif    	

     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        dbcommitAll()
        ourspool(wnrel)
     Endif

Return

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Data Emissao de         ?", "", "", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01", ""          , ""          , ""          , "", "", ""        ,""         , ""        , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "02", "Data Emissao Ate'       ?", "", "", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", ""          , ""          , ""          , "", "", ""        , ""        , ""        , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "03", "Ordem                   ?", "", "", "mv_ch3", "N", 01, 0, 2, "C", "", "mv_par03", "VOL DECRES", "VOL DECRES", "VOL DECRES", "", "", "CODIGO", "CODIGO", "CODIGO", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "04", "Turno(Em brco p/ todos) ?", "", "", "mv_ch4", "C", 03, 0, 0, "G", "", "mv_par04", ""          , ""          , ""          , "", "", ""        , ""        , ""        , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

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
       PutSX1(cPerg, "05"  ,  "Padrao Relatorio ?", "Padrao Relatorio ?", "Padrao Relatorio ?", "mv_ch5", "N",  1, 0, 1, "C"  , "","","","",             "mv_par05","Por Embalagem", "Por Embalagem", "Por Embalagem"   , ""   , "Por Linha Prod", "Por Linha Prod", "Por Linha Prod", , , , , , , , , ,{},{},{}, "" )



       DbSelectArea(_sAlias)
Return*/
/*
Static Function ArqTemp(cExt) 
       //Recebe como parametro a extensão a ser utilizada, por ex.: ".DBF"
       Local cArq,nCont
       cArq = "TEMP"
       nCont = 0	
       While File(cArq+cExt)
             nCont++
             cArq = "TEMP"+alltrim(str(nCont))
       Enddo
Return(cArq)*/