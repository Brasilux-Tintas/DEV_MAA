#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPR14             				 º Data ³  09/04/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Apontamento de Produção                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Variaveis utilizadas para parametros
mv_par01     // De (data)
mv_par02     // Até 
mv_par03     // Do Lote
mv_par04     // Até o Lote
mv_par05     // Da Op
mv_par06     // Até a Op
mv_par07     // Do Grupo
mv_par08     // Até o Grupo
mv_par09     // Alteração de Empenho
*/
User Function BRPCPR14()


     Local cDesc1  := PADC("Este programa ira emitir o relatório de apontamento de produção.", 74)
     Local cDesc2  := PADC("de acordo com os parametros informados pelo usuario.", 74)
     Local cDesc3  := PADC(" ", 74)
     Local titulo  := "APONTAMENTOS DE ORDENS DE PRODUÇÃO"
     Local nLin    := 0
     Local cCabec1 := ""
     Local cCabec2 := ""
     Local aOrd    := {}

     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRPCPR14" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Especial", 1, "Administracao", 1, 2, 1, "", 1 }
     Private nLastKey    := 0
     Private cPerg       := "PCPR14"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRPCPR14" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SC2"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 if !u_VldAcesso(funname())
         MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	 return 
	 endif 
    
     Pergunte(cPerg, .F.)   

     wnrel := SetPrint(cString, wnrel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .f., Tamanho, ,.F.)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Processa({|| RunReport(cCabec1, cCabec2, Titulo, nLin) }, Titulo)
Return

Static Function RunReport(cCabec1, cCabec2, Titulo, nLin)
    
    Local cProduto, nSomaOri, nSomaAlt, cQuery, cLote, nPerc
   
    cQuery := ""
	cQuery += " SELECT ZZF.ZZF_ORDEM, ZZF.ZZF_LOTE, ZZF.ZZF_CODIGO, ZZF.ZZF_TRT, ZZF.ZZF_LOCAL, ZZF.ZZF_QTDORI, ZZF.ZZF_QTDUSA, ZZF.ZZF_FLAG, ZZF.ZZF_TIPEMP, ZZF.ZZF_OBS, SC2.C2_QUJE, SC2.C2_PRODUTO "
	cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZF")+" ZZF WITH(NOLOCK) ON ZZF_FILIAL = C2_FILIAL AND ZZF_LOTE = C2_LOTE AND ZZF_ORDEM = C2_OP AND ZZF.D_E_L_E_T_ ='' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
	cQuery += " WHERE SC2.D_E_L_E_T_ ='' "
	cQuery += " AND C2_FILIAL ='"+XFilial("SC2")+"'"  
	cQuery += " AND C2_DATRF BETWEEN('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')"
	cQuery += " AND C2_LOTE BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')"
	cQuery += " AND C2_OP BETWEEN('"+MV_PAR05+"') AND ('"+MV_PAR06+"')"
	cQuery += " AND B1_GRUPO BETWEEN('"+MV_PAR07+"') AND ('"+MV_PAR08+"')"
	cQuery += " AND ZZF.ZZF_FLAG ='1' " 
	If MV_PAR09 =1
		cQuery += " AND (SC2.C2_QUANT <> SC2.C2_QUJE) "
	Elseif MV_PAR09 =2
		cQuery += " AND (SC2.C2_QUANT = SC2.C2_QUJE) "
	Endif
	cQuery += " ORDER BY ZZF.ZZF_ORDEM, ZZF.ZZF_LOTE, ZZF.ZZF_TRT "

	TCQuery cQuery NEW ALIAS "TCQ" 

//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//														     9,999,999.99	
cCabec2  := "Lote   / Op           / Produto           / Rendimento OP     %"
//cCabec2  += "Item      SEQ.  Local  Apt Padrão    Apt Utilizado    Diferença %"

cCabec1  := "De   "+dtoc(mv_par01) +" até "+dtoc(mv_par02) +" do Lote "+(mv_par03)+ " até "+(mv_par04)

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
nLin = 08

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
dbselectarea("TCQ")
dbgotop()


ProcRegua(Reccount())
While ! EoF()         
	
	nSomaOri := 0
	nSomaAlt := 0
	nPerc    := 0

  	if nLin > 60
  		nLin++
  		@nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08
	endif
	cProduto := ALLTRIM(TCQ->C2_PRODUTO)
	cLote    := ALLTRIM(TCQ->ZZF_LOTE)
   	
   	nLin++
 	
 	@nLin,00 psay cLote   
   	@nLin,08 psay TCQ->ZZF_ORDEM picture "@R XXXXXXXXXXX"
 	@nLin,21 psay cProduto picture "@R XXX99.99.999.99"
   	@nLin,38 psay TCQ->C2_QUJE picture "@E 9,999,999.99"
	nLin++
	@nLin,00 psay "ITEM           SEQ.  LOCAL   APT PADRÃO    APT UTILIZADO     DIFERENÇA %"
	//nLin++
	@nLin,000 psay replicate("_",80)
	While !	eof() .and. (alltrim(cProduto) == ALLTRIM(TCQ->C2_PRODUTO) .and. (alltrim(cLote) == Alltrim(TCQ->ZZF_LOTE)))
		
	  	if nLin > 60
  			nLin++
  			@nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			nLin := 08
		endif
		nLin++

		nSomaOri += TCQ->ZZF_QTDORI
		nSomaAlt += TCQ->ZZF_QTDUSA

		@nLin,00 psay TCQ->ZZF_CODIGO picture "@R XXXXXXXXXXXX"
		@nLin,15 psay TCQ->ZZF_TRT   
		@nLin,22 psay TCQ->ZZF_LOCAL   
		@nLin,27 psay TCQ->ZZF_QTDORI picture "@E 9,999,999.99"
		@nLin,42 psay TCQ->ZZF_QTDUSA picture "@E 9,999,999.99"

		dbselectarea("TCQ")
		dbskip()
		IncProc()		   	
	enddo
	nLin++
  	@nLin,00 psay replicate("_",80)
  	
  	nLin++
	@nLin,27 psay nSomaOri picture "@E 9,999,999.99"
	@nLin,42 psay nSomaAlt picture "@E 9,999,999.99"	
	nPerc := ((nSomaAlt/nSomaOri)-1)*100
	@nLin,65 psay nPerc picture "@E 99.99"
	@nLin,000 psay replicate("_",80)
	nLin++

    cQuery := ""
	cQuery += " SELECT DISTINCT ZZG.ZZG_LOTE, ZZG.ZZG_PROENV, " 
	cQuery += " CASE WHEN ZZG.ZZG_TPUSER ='B' THEN 'BALANÇA' ELSE " 
	cQuery += " CASE WHEN ZZG.ZZG_TPUSER ='C' THEN 'COLORISTA' ELSE "
	cQuery += " CASE WHEN ZZG.ZZG_TPUSER ='L' THEN 'LABORATORIO' ELSE "
	cQuery += " CASE WHEN ZZG.ZZG_TPUSER ='E' THEN 'ENVASE' ELSE " 
	cQuery += " CASE WHEN ZZG.ZZG_TPUSER ='Y' THEN 'CONF. BALANÇA' ELSE "
	cQuery += " CASE WHEN ZZG.ZZG_TPUSER ='Z' THEN 'CONF. LABORATORIO' END END END END END END AS 'ETAPA',ZZG.ZZG_NOME AS 'NOME'"
	cQuery += " FROM "+RetSqlName("ZZG")+" ZZG WITH(NOLOCK) "
	cQuery += " WHERE (ZZG.ZZG_FILIAL='"+XFilial("ZZG")+"') " 
	cQuery += " AND (ZZG.D_E_L_E_T_='') " 
	cQuery += " AND (ZZG.ZZG_LOTE ='"+cLote+"') "
	cQuery += " ORDER BY ZZG_LOTE " 
	
	TCQuery cQuery NEW ALIAS "TCQ1" 
	dbselectarea("TCQ1")
	dbgotop()
	
	While !Eof()
	  	if (nLin+3) > 60
	  		nLin++
	  		@nLin,000 psay replicate("_",80)
	  		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	  		nLin := 08
	  	endif
	
		@nLin,00 psay TCQ1->ETAPA   
		@nLin,20 psay TCQ1->NOME   
		nLin++
		dbselectarea("TCQ1")
		dbskip()	
	Enddo
	dbselectarea("TCQ1")
	dbCloseArea()	

  	@nLin,00 psay replicate("_",80)
	nLin++				
   	dbselectarea("TCQ")
Enddo
  		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TCQ")
dbCloseArea()

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return

