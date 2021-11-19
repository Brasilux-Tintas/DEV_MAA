#include "Protheus.ch"
#include "tbiconn.ch"
#include "error.ch"
#include "topconn.ch"
#INCLUDE "RWMAKE.CH"

User Function BRABRECPV()

    Local _Titulo := 'Tabela Auxiliar Fechamento - Z99'
    Local cPerg   := 'BRZ99'
    u_zcfga01( 'BRABRECPV' ) //LGS#2021118 - Gravação de log de utilização da rotina
    If !u_VldAcesso(funname())
        MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
        Return 
    Endif 

    Pergunte( cPerg, .T. )
    
    If dtos(MV_PAR01) < '20210101'
        MsgBox("Data inválida ! Verifique os parametros !!","Atenção","Alert")
        Return 
    Endif

    If Substr(DTOS(MV_PAR01),7,2) <> '01'
        MsgBox("Data inicial inválida!!","Atenção","Alert")
        Return 
    Endif

    If ((MV_PAR02) - (MV_PAR01)) > 30
        MsgBox("Intervalo de datas inválido !!","Atenção","Alert")
        Return 
    Endif
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Processamento. PROCESSA monta janela com a regua de processamento.  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    Processa({|| BRPZ990() },_Titulo)

Return

Static Function BRPZ990()
    
    Local cQry        := ""
    Local CQr1        := ""
    Local cSeek       := "" 
    Local nQtdVendas  := 0
    Local nQtdDev     := 0
    Local nMComissao  := 0
    
    Private dPerIni   := ""
    Private dPerFim   := ""
    Private cGrupoIni := ""
    Private cGrupoFim := ""
    Private cProdIni  := ""
    Private cProdFim  := ""
    Private cTipoIni  := ""
    Private cTipoFim  := ""

    dPerIni     := DTOS(MV_PAR01)
    dPerFim     := DTOS(MV_PAR02)
    cTipoIni    := MV_PAR03
    cTipoFim    := MV_PAR04
    cGrupoIni   := MV_PAR05
    cGrupoFim   := MV_PAR06
    cProdIni    := MV_PAR07
    cProdFim    := MV_PAR08


    cQry += " WITH TMP AS( "
    cQry += " SELECT SB9ATUAL.B9_FILIAL AS 'FILIAL', SB9ATUAL.B9_COD AS 'CODIGO', SB9ATUAL.B9_DATA AS 'DATAFIM', "
    cQry += " 'QTDEINICIAL' = ISNULL((SELECT SUM(B9_QINI) FROM SB9010 SB9ANT WITH(NOLOCK) WHERE SB9ANT.D_E_L_E_T_ ='' AND SB9ATUAL.B9_FILIAL = SB9ANT.B9_FILIAL AND SB9ATUAL.B9_COD = SB9ANT.B9_COD AND SB9ANT.B9_DATA =EOMONTH(SB9ATUAL.B9_DATA,-1)),0), "
    cQry += " SUM(B9_QINI) AS 'QTDEFINAL' "
    cQry += " FROM SB9010 SB9ATUAL WITH(NOLOCK)  "
    cQry += " LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_FILIAL = SB9ATUAL.B9_FILIAL AND B1_COD = SB9ATUAL.B9_COD AND SB1.D_E_L_E_T_ ='' "
    cQry += " WHERE SB9ATUAL.D_E_L_E_T_ =''  "
    cQry += " AND SB9ATUAL.B9_FILIAL ='"+xFilial("SB9")+"'"
    cQry += " AND SB9ATUAL.B9_DATA ='"+dPerFim+"'"
    cQry += " AND B1_TIPO BETWEEN ('"+cTipoIni+"') AND ('"+cTipoFim+"') "
    CQry += " AND B1_GRUPO BETWEEN('"+cGrupoIni+"') AND ('"+cGrupoFim+"') "
    cQry += " AND SB9ATUAL.B9_COD BETWEEN('"+cProdIni+"') AND ('"+cProdFim+"') "
    cQry += " GROUP BY SB9ATUAL.B9_FILIAL, SB9ATUAL.B9_COD, SB9ATUAL.B9_DATA) "
    cQry += " SELECT FILIAL,CODIGO, SUBSTRING(DATAFIM,7,2)+'/'+SUBSTRING(DATAFIM,5,2)+'/'+SUBSTRING(DATAFIM,3,2) AS 'DATAFIM', DATAFIM AS DATAFINAL, QTDEINICIAL, QTDEFINAL, ISNULL(SUM(D3_QUANT),0) AS 'PRODUCAO' "
    cQry += " FROM TMP "
    cQry += " LEFT OUTER JOIN SD3010 SD3 WITH(NOLOCK) ON D3_FILIAL = FILIAL AND D3_COD = CODIGO AND D3_ESTORNO <>'S' AND D3_EMISSAO BETWEEN('"+dPerini+"') AND ('"+dPerFim+"') AND D3_CF ='PR0' AND SD3.D_E_L_E_T_ =''  "
    cQry += " GROUP BY FILIAL,CODIGO, DATAFIM, QTDEINICIAL, QTDEFINAL "
    cQry += " ORDER BY FILIAL, CODIGO, DATAFIM "

    TCQuery cQry ALIAS "TCQ" New
    DbSelectArea("TCQ")
       
    While !Eof()
    
        nMComissao  := 0
        nQtdVendas  := fTotVenda(xFilial("Z99"),TCQ->CODIGO)
        nQtdDev     := fTotDev(xFilial("Z99"),TCQ->CODIGO)
        nValComiss  := fMedComi(xFilial("Z99"),TCQ->CODIGO)

        If nQtdVendas > 0 .and. nValComiss >0
           nMComissao := Round((nValComiss/nQtdVendas),4)
        Endif

        DbSelectArea("Z99")
		dbSetOrder(1)
		cSeek:=xFilial("Z99")+TCQ->CODIGO+TCQ->DATAFINAL
		//cCompara:="Z99_FILIAL+Z99_COD+Z99_DATA"
		dbSeek(cSeek)
		If !Found() //.And. cSeek == &(cCompara)
            RecLock("Z99", .t.)
                Z99->Z99_FILIAL      := TCQ->FILIAL
                Z99->Z99_COD         := TCQ->CODIGO
                Z99->Z99_DATA        := CTOD(TCQ->DATAFIM)
                Z99->Z99_QINI        := TCQ->QTDEINICIAL
                Z99->Z99_QFIM        := TCQ->QTDEFINAL
                Z99->Z99_PRODUC      := TCQ->PRODUCAO
                Z99->Z99_VENDAS      := nQtdVendas
                Z99->Z99_DEVOLU      := nQtdDev                
                Z99->Z99_VLRCOM      := nMComissao
            MsUnlock()
        Else
            RecLock("Z99", .f.)
                Z99->Z99_QINI        := TCQ->QTDEINICIAL
                Z99->Z99_QFIM        := TCQ->QTDEFINAL
                Z99->Z99_PRODUC      := TCQ->PRODUCAO
                Z99->Z99_VENDAS      := nQtdVendas
                Z99->Z99_DEVOLU      := nQtdDev                
                Z99->Z99_VLRCOM      := nMComissao
            MsUnlock()
        Endif
        DbSelectArea("Z99")
        
        DbSelectArea("TCQ")
        DbSkip()

    Enddo
    
    DbSelectArea("Z99")
    DbCloseArea()

    DbSelectArea("TCQ")
    DbCloseArea()    
    
    CQr1 := ""
    CQr1 += " WITH TMP AS "
    CQr1 += " (SELECT Z99_FILIAL AS 'FILIAL', Z99_COD AS 'PRODUTO', 0 AS GGF, 0 AS MO, 0 AS REQ, 0 AS PR0, "
    CQr1 += " '01/'+SUBSTRING(Z99_DATA,5,2)+'/'+SUBSTRING(Z99_DATA,1,4) AS 'DATA' "
    CQr1 += " FROM Z99010 Z99 WITH(NOLOCK)  "
    CQr1 += " LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_FILIAL = Z99_FILIAL AND B1_COD = Z99_COD AND SB1.D_E_L_E_T_ ='' "
    CQr1 += " WHERE Z99.D_E_L_E_T_ =''  "
    CQr1 += " AND Z99_FILIAL ='"+Xfilial("Z99")+"'"
    CQr1 += " AND Z99_DATA ='"+dPerFim+"' "
    CQr1 += " AND B1_TIPO BETWEEN ('"+cTipoIni+"') AND ('"+cTipoFim+"') "
    CQr1 += " AND B1_GRUPO BETWEEN('"+cGrupoIni+"') AND ('"+cGrupoFim+"') "
    CQr1 += " AND Z99_COD BETWEEN('"+cProdIni+"') AND ('"+cProdFim+"') "
    CQr1 += " UNION ALL "
    CQr1 += " SELECT C2_FILIAL AS 'FILIAL', C2_PRODUTO AS 'PRODUTO',D3_CUSTO1 AS 'GGF', 0 AS 'MO', 0 AS 'REQ', 0 AS 'PR0', "
    CQr1 += " '01/'+SUBSTRING(D3_EMISSAO,5,2)+'/'+SUBSTRING(D3_EMISSAO,1,4) AS 'DATA' "
    CQr1 += " FROM SC2010 SC2 WITH(NOLOCK) "
    CQr1 += " LEFT OUTER JOIN SD3010 SD3 WITH(NOLOCK) ON D3_FILIAL = C2_FILIAL AND D3_OP = C2_OP AND D3_ESTORNO <>'S' AND SD3.D_E_L_E_T_ ='' "
    CQr1 += " LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    CQr1 += " WHERE SC2.D_E_L_E_T_ ='' "
    CQr1 += " AND C2_FILIAL ='"+Xfilial("SC2")+"'"
    CQr1 += " AND D3_EMISSAO BETWEEN('"+dPerIni+"') AND ('"+dPerFim+"') "
    CQr1 += " AND D3_TIPO ='MO' AND SUBSTRING(D3_COD,1,3)='GGF' "
    CQr1 += " AND D3_OP <>'' "
    CQr1 += " AND B1_TIPO BETWEEN ('"+cTipoIni+"') AND ('"+cTipoFim+"') "
    CQr1 += " AND B1_GRUPO BETWEEN('"+cGrupoIni+"') AND ('"+cGrupoFim+"') "
    CQr1 += " AND C2_PRODUTO BETWEEN('"+cProdIni+"') AND ('"+cProdFim+"') "
    CQr1 += " UNION ALL "
    CQr1 += " SELECT C2_FILIAL AS 'FILIAL', C2_PRODUTO AS 'PRODUTO',0 AS 'GGF', D3_CUSTO1 AS 'MO', 0 AS 'REQ', 0 AS 'PR0', "
    CQr1 += " '01/'+SUBSTRING(D3_EMISSAO,5,2)+'/'+SUBSTRING(D3_EMISSAO,1,4) AS 'DATA' "
    CQr1 += " FROM SC2010 SC2 WITH(NOLOCK)  "
    CQr1 += " LEFT OUTER JOIN SD3010 SD3 WITH(NOLOCK) ON D3_FILIAL = C2_FILIAL AND D3_OP = C2_OP AND D3_ESTORNO <>'S' AND SD3.D_E_L_E_T_ ='' "
    CQr1 += " LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    CQr1 += " WHERE SC2.D_E_L_E_T_ ='' "
    CQr1 += " AND C2_FILIAL ='"+Xfilial("SC2")+"'"
    CQr1 += " AND D3_EMISSAO BETWEEN('"+dPerIni+"') AND ('"+dPerFim+"') "
    CQr1 += " AND D3_TIPO ='MO' AND SUBSTRING(D3_COD,1,3)='MO6' "
    CQr1 += " AND D3_OP <>'' "
    CQr1 += " AND B1_GRUPO BETWEEN('"+cGrupoIni+"') AND ('"+cGrupoFim+"') "
    CQr1 += " AND C2_PRODUTO BETWEEN('"+cProdIni+"') AND ('"+cProdFim+"') "
    CQr1 += " UNION ALL "
    CQr1 += " SELECT C2_FILIAL AS 'FILIAL', C2_PRODUTO AS 'PRODUTO',0 AS 'GGF', 0 AS 'MO', D3_CUSTO1 AS 'REQ', 0 AS 'PR0', "
    CQr1 += " '01/'+SUBSTRING(D3_EMISSAO,5,2)+'/'+SUBSTRING(D3_EMISSAO,1,4) AS 'DATA' "
    CQr1 += " FROM SC2010 SC2 WITH(NOLOCK)  "
    CQr1 += " LEFT OUTER JOIN SD3010 SD3 WITH(NOLOCK) ON D3_FILIAL = C2_FILIAL AND D3_OP = C2_OP AND D3_ESTORNO <>'S' AND SD3.D_E_L_E_T_ ='' "
    CQr1 += " LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    CQr1 += " WHERE SC2.D_E_L_E_T_ ='' "
    CQr1 += " AND C2_FILIAL ='"+Xfilial("SC2")+"'"
    CQr1 += " AND D3_EMISSAO BETWEEN('"+dPerIni+"') AND ('"+dPerFim+"') "
    CQr1 += " AND D3_TIPO NOT IN('MO') AND D3_CF NOT IN('PR0') "
    CQr1 += " AND D3_OP <>'' "
    CQr1 += " AND B1_GRUPO BETWEEN('"+cGrupoIni+"') AND ('"+cGrupoFim+"') "
    CQr1 += " AND C2_PRODUTO BETWEEN('"+cProdIni+"') AND ('"+cProdFim+"') "
    CQr1 += " UNION ALL "
    CQr1 += " SELECT C2_FILIAL AS 'FILIAL', C2_PRODUTO AS 'PRODUTO',0 AS 'GGF', 0 AS 'MO', 0 AS 'REQ', D3_QUANT AS 'PR0', "
    CQr1 += " '01/'+SUBSTRING(D3_EMISSAO,5,2)+'/'+SUBSTRING(D3_EMISSAO,1,4) AS 'DATA' "
    CQr1 += " FROM SC2010 SC2 WITH(NOLOCK)  "
    CQr1 += " LEFT OUTER JOIN SD3010 SD3 WITH(NOLOCK) ON D3_FILIAL = C2_FILIAL AND D3_OP = C2_OP AND D3_ESTORNO <>'S' AND SD3.D_E_L_E_T_ ='' "
    CQr1 += " LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
    CQr1 += " WHERE SC2.D_E_L_E_T_ ='' "
    CQr1 += " AND C2_FILIAL ='"+Xfilial("SC2")+"'"
    CQr1 += " AND D3_EMISSAO BETWEEN('"+dPerIni+"') AND ('"+dPerFim+"') "
    CQr1 += " AND D3_CF ='PR0' "
    CQr1 += " AND D3_OP <>'' "
    CQr1 += " AND B1_GRUPO BETWEEN('"+cGrupoIni+"') AND ('"+cGrupoFim+"') "
    CQr1 += " AND C2_PRODUTO BETWEEN('"+cProdIni+"') AND ('"+cProdFim+"')  ) "
    CQr1 += " SELECT FILIAL, PRODUTO, SUM(GGF) AS GGF, SUM(MO) AS MO, SUM(REQ) AS REQ, SUM(PR0) AS PR0,  "
    CQr1 += " CONVERT(varchar(10), EOMONTH(DATA), 112) AS 'DTFINAL', CONVERT(varchar(10), EOMONTH(DATA,-1), 112) AS 'DTANTFINAL', "
    CQr1 += " CASE WHEN SUM(GGF) >0 AND SUM(PR0) >0 THEN ROUND((SUM(GGF)/SUM(PR0)),4) ELSE 0 END AS 'GGFMES', "
    CQr1 += " CASE WHEN SUM(MO)  >0 AND SUM(PR0) >0 THEN ROUND((SUM(MO)/SUM(PR0)),4)  ELSE 0 END AS 'MOMES', "
    CQr1 += " CASE WHEN SUM(REQ) >0 AND SUM(PR0) >0 THEN ROUND((SUM(REQ)/SUM(PR0)),4) ELSE 0 END AS 'REQMES' "
    CQr1 += " FROM TMP "
    CQr1 += " GROUP BY FILIAL,PRODUTO, DATA "

    TCQuery CQr1 ALIAS "TCQ1" New
    DbSelectArea("TCQ1")
       
    While !Eof()
        nGGFANT     := 0
        nMOANT      := 0
        nREQANT     := 0

        // PREENCHER FATURAMENTO
        //nQtdVendas  := fTotVenda(xFilial("Z99"),TCQ1->PRODUTO)
        //nQtdDev     := fTotDev(xFilial("Z99"),TCQ1->PRODUTO)

        // PREENCHER DADOS DO MÊS ANTERIOR
        If TCQ1->DTFINAL > '20210131'
            DbSelectArea("Z99")
		    dbSetOrder(1)
		    cSeek:=xFilial("Z99")+TCQ1->PRODUTO+TCQ1->DTANTFINAL
		    dbSeek(cSeek)
		    If Found() 
                nGGFANT     := Z99->Z99_GGFCON
                nMOANT      := Z99->Z99_MOCONS
                nREQANT     := Z99->Z99_REQCON
            Endif
        Endif
        
        // BUSCA REGISTROS DO MÊS ATUAL
        DbSelectArea("Z99")
		dbSetOrder(1)
		cSeek:=xFilial("Z99")+TCQ1->PRODUTO+TCQ1->DTFINAL
		dbSeek(cSeek)
		If Found() 
            RecLock("Z99", .f.)
                Z99->Z99_GGFMES     := TCQ1->GGFMES
                Z99->Z99_MOMES      := TCQ1->MOMES
                Z99->Z99_REQMES     := TCQ1->REQMES

                
                // PREENCHER MÊS DE JANEIRO 2021 (PRIMEIRO MÊS DO CUSTO MÉDIO BRASILUX OU ABRIL PARA DISSOLTEX)
                
                /*
                If (TCQ1->FILIAL ='010101' .AND. TCQ1->DTFINAL ='20210131') .OR. (TCQ1->FILIAL ='060101' .AND. TCQ1->DTFINAL ='20210430')
                    Z99->Z99_GGFANT     := TCQ1->GGFMES
                    Z99->Z99_MOANT      := TCQ1->MOMES
                    Z99->Z99_REQANT     := TCQ1->REQMES
                Endif
                */

                // PREENCHER CUSTO DO MÊS ANTERIOR ANTES DO CÁLCULO DO CONSOLIDADO
                nGGFANT             := Iif ( nGGFANT <>0 , nGGFANT , TCQ1->GGFMES )
                nMOANT              := Iif ( nMOANT  <>0 , nMOANT  , TCQ1->MOMES  )
                nREQANT             := Iif ( nREQANT <>0 , nREQANT , TCQ1->REQMES )
              
                Z99->Z99_GGFANT     := nGGFANT
                Z99->Z99_MOANT      := nMOANT
                Z99->Z99_REQANT     := nREQANT
                
                If Z99->Z99_PRODUC >0 // CALCULAR CONSOLIDADO (MEDIA ENTRE GGF / MO / REQ ANTERIOR + ATUAL)
                    Z99->Z99_GGFCON    := ( (Z99->Z99_QINI * nGGFANT) + (Z99->Z99_PRODUC * Z99->Z99_GGFMES) ) /  ( Z99->Z99_QINI + Z99->Z99_PRODUC)
                    Z99->Z99_MOCONS    := ( (Z99->Z99_QINI * nMOANT ) + (Z99->Z99_PRODUC * Z99->Z99_MOMES ) ) /  ( Z99->Z99_QINI + Z99->Z99_PRODUC)
                    Z99->Z99_REQCON    := ( (Z99->Z99_QINI * nREQANT) + (Z99->Z99_PRODUC * Z99->Z99_REQMES) ) /  ( Z99->Z99_QINI + Z99->Z99_PRODUC)
                Elseif Z99->Z99_PRODUC = 0
                    Z99->Z99_GGFMES    := nGGFANT
                    Z99->Z99_MOMES     := nMOANT
                    Z99->Z99_REQMES    := nREQANT

                    Z99->Z99_GGFCON    := Iif( TCQ1->GGFMES <> 0, TCQ1->GGFMES ,nGGFANT ) 
                    Z99->Z99_MOCONS    := Iif( TCQ1->MOMES  <> 0, TCQ1->MOMES , nMOANT  ) 
                    Z99->Z99_REQCON    := Iif( TCQ1->REQMES <> 0, TCQ1->REQMES ,nREQANT ) 
                    
                Endif
            MsUnlock()
            // função buscar
        Endif
        
        DbSelectArea("Z99")
        
        DbSelectArea("TCQ1")
        DbSkip()
    
    Enddo

    DbSelectArea("TCQ1")
    DbCloseArea()

    DbSelectArea("Z99")
    DbCloseArea()
    
    If dPerFim >'20210131'
        fCorrJan() // Gravar GGF MO REQ de Janeiro com valores do mês subsequente se houve venda no mês.
    Endif

Return

Static Function fTotVenda(FILIAL,PRODUTO)

    Local cQry      := ""
    Local nQtdVenda := 0

    cQry += " SELECT D2_FILIAL AS FILIAL,D2_COD AS 'PRODUTO', SUM(D2_QUANT) AS 'QTDVENDAS' "
    cQry += " FROM SD2010 SD2 WITH(NOLOCK) "
    cQry += " LEFT OUTER JOIN SF4010 SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO)  "
    cQry += " WHERE SD2.D_E_L_E_T_=''  "
    //cQry += " AND SUBSTRING(D2_FILIAL,1,2) IN('01','06') "
    cQry += " AND D2_EMISSAO BETWEEN('"+dPerIni+"') AND ('"+dPerFim+"') "
    cQry += " AND (D2_TIPO <> 'D')  "
    cQry += " AND (F4_DUPLIC = 'S' OR D2_TIPO ='I' OR F4_CODIGO ='519') "
    cQry += " AND D2_FILIAL ='"+FILIAL+"'" 
    cQry += " AND D2_COD = '"+PRODUTO+"'" 
    cQry += " AND D2_CF IN('000','5101','5105','5106','5113','5118','5122','5124','5401','5403','5501','5502','5922','6101','6102','6105','6106','6107','6108','6113','6118','6122','6124','6401','6403','6501','6502','6922','7105','7106','5102','6109','6110','7101','7102') "
    cQry += " GROUP BY D2_FILIAL, D2_COD "

    TCQUERY cQry ALIAS "TCV" NEW
    DbSelectArea("TCV")
    DbGoTop()	 
  	If !Eof() .and. !Bof()
    	nQtdVenda := Iif(TCV->QTDVENDAS >0, TCV->QTDVENDAS , 0)
    Endif
    DbSelectArea("TCV")
    DbCloseArea()
          

Return (nQtdVenda)

Static Function fTotDev(FILIAL,PRODUTO)

    Local cQry      := ""
    Local nQtdev    := 0

    cQry += " SELECT D1_FILIAL 'AS FILIAL', D1_COD AS 'PRODUTO', SUM(D1_QUANT) AS 'QTDDEV' "
    cQry += " FROM SD1010 SD1 WITH (NOLOCK)  "
    cQry += " LEFT OUTER JOIN SF4010 SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO)  "
    cQry += " WHERE SD1.D_E_L_E_T_ ='' "
    //cQry += " AND SUBSTRING(D1_FILIAL,1,2)IN('01','06') "
    cQry += " AND D1_DTDIGIT BETWEEN('"+dPerIni+"') AND ('"+dPerFim+"') "
    cQry += " AND D1_FILIAL ='"+FILIAL+"'" 
    cQry += " AND D1_COD = '"+PRODUTO+"'" 
    cQry += " AND ((F4_DUPLIC = 'S'AND D1_CF <>'000') OR (F4_CODIGO ='082' AND D1_SERIORI ='F')) "
    cQry += " AND D1_CF IN('000','1201','1202','1203','1204','2201','2202','2203','2204','1410','1411','1503','1504','2410','2411','2503','2504','3201','3202') "
    cQry += " GROUP BY D1_FILIAL, D1_COD "

    TCQUERY cQry ALIAS "TCD" NEW
    DbSelectArea("TCD")
    DbGoTop()	 
  	If !Eof() .and. !Bof()
    	nQtdev := Iif(TCD->QTDDEV >0, TCD->QTDDEV , 0)
    Endif
    DbSelectArea("TCD")
    DbCloseArea()
          

Return (nQtdev)

// Calcula a comissão média por item faturado dentro do período
Static Function fMedComi(FILIAL,PRODUTO)

    Local cQry      := ""
    Local nValComis := 0

    cQry += " SELECT SUM(D2_TOTAL * D2_COMIS1)/100 AS VALCOMISS "
    cQry += " FROM SF2010 SF2 WITH(NOLOCK) "
    cQry += " LEFT OUTER JOIN SD2010 SD2 WITH (NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SD2.D_E_L_E_T_ ='' "
    cQry += " LEFT OUTER JOIN SF4010 SF4 WITH (NOLOCK) ON F4_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO AND SF4.D_E_L_E_T_ = '' "
    cQry += " WHERE SF2.D_E_L_E_T_ ='' "
    cQry += " AND (F4_DUPLIC = 'S' OR D2_TIPO ='I' OR F4_CODIGO ='519') "
    cQry += " AND F2_FILIAL ='"+FILIAL+"'" 
    cQry += " AND F2_DUPL <>'' "
    cQry += " AND F2_EMISSAO BETWEEN('"+dPerIni+"') AND ('"+dPerFim+"') "
    cQry += " AND D2_COD = '"+PRODUTO+"'" 
    cQry += " AND (D2_TIPO <> 'D')  "
    cQry += " AND D2_CF IN('000','5101','5105','5106','5113','5118','5122','5124','5401','5403','5501','5502','5922','6101','6102','6105','6106','6107','6108','6113','6118','6122','6124','6401','6403','6501','6502','6922','7105','7106','5102','6109','6110','7101','7102')  "

    TCQUERY cQry ALIAS "TCC" NEW
    DbSelectArea("TCC")
    DbGoTop()	 
  	If !Eof() .and. !Bof()
    	nValComis := Iif(TCC->VALCOMISS >0, TCC->VALCOMISS , 0)
    Endif
    DbSelectArea("TCC")
    DbCloseArea()
          

Return (nValComis)


Static Function fCorrJan()

    Local cQry  := ""
    Local cQry1 := ""
    Local cSeek := ""

    cQry := " SELECT Z99_FILIAL, Z99_COD, Z99_DATA "
    cQry += " FROM Z99010 Z99 WITH(NOLOCK) "
    cQry += " WHERE Z99.D_E_L_E_T_ ='' 
    cQry += " AND Z99_FILIAL ='"+xFilial("Z99")+"'"
    cQry += " AND Z99_VENDAS <>0 
    cQry += " AND Z99_PRODUC =0 
    cQry += " AND (Z99_GGFMES =0 OR Z99_MOMES =0 OR Z99_REQMES =0)

    TCQUERY cQry ALIAS "TCE" NEW
    DbSelectArea("TCE")
    DbGoTop()	 
  	
    While !Eof()

        cQry1 := " SELECT TOP 1 Z99_FILIAL, Z99_COD, MIN(Z99_DATA) AS DATA, Z99_GGFANT, Z99_GGFMES, Z99_GGFCON,  "
        cQry1 += " Z99_MOANT, Z99_MOMES, Z99_MOCONS, Z99_REQANT, Z99_REQMES, Z99_REQCON "
        cQry1 += " FROM Z99010 Z99 WITH(NOLOCK) "
        cQry1 += " WHERE Z99.D_E_L_E_T_ ='' "
        cQry1 += " AND Z99_FILIAL ='"+xFilial("Z99")+"'"
        cQry1 += " AND Z99_COD ='"+TCE->Z99_COD+"'"
        cQry1 += " AND (Z99_GGFMES <>0 OR Z99_MOMES <>0 OR Z99_REQMES <>0) "
        cQry1 += " GROUP BY Z99_FILIAL, Z99_COD, Z99_GGFANT, Z99_GGFMES, Z99_GGFCON,Z99_MOANT, Z99_MOMES, Z99_MOCONS, Z99_REQANT, Z99_REQMES, Z99_REQCON "
        cQry1 += " ORDER BY MIN(Z99_DATA) "
        
        TCQUERY cQry1 ALIAS "TCQ1" NEW
        DbSelectArea("TCQ1")
        DbGoTop()	 
        
        If !Eof() .and. !Bof()
    	    DbSelectArea("Z99")
            dbSetOrder(1)
	        cSeek:=xFilial("Z99")+TCE->Z99_COD+TCE->Z99_DATA
	        dbSeek(cSeek)
	        If Found() 
                RecLock("Z99", .f.)
                    Z99->Z99_GGFANT     := TCQ1->Z99_GGFANT
                    Z99->Z99_MOANT      := TCQ1->Z99_MOANT
                    Z99->Z99_REQANT     := TCQ1->Z99_REQANT
                    Z99->Z99_GGFMES     := TCQ1->Z99_GGFMES
                    Z99->Z99_MOMES      := TCQ1->Z99_MOMES
                    Z99->Z99_REQMES     := TCQ1->Z99_REQMES
                    Z99->Z99_GGFCON     := TCQ1->Z99_GGFCON
                    Z99->Z99_MOCONS     := TCQ1->Z99_MOCONS
                    Z99->Z99_REQCON     := TCQ1->Z99_REQCON
                MsUnlock()
            Endif
        Endif
        DbSelectArea("TCQ1")
        DbCloseArea()


        DbSelectArea("TCE")
        DbSkip()

    Enddo

    DbSelectArea("TCE")
    DbCloseArea()

Return ()
