#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFAT058  ºAutor  ³ Cleber O. Dominguesº Data ³  11/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Pedidos em Região de Entrega                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT058()

     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Relatório de pedidos em região de entrega."
     Local titulo        := "PEDIDOS EM REGIAO DE ENTREGA"
     Local _nLin         := 90
     Local Cabec1        := "CIDADE                        EMP-PEDIDO-CLIENTE                        QTDE VOL"
     Local Cabec2        := ""

     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "P"
     Private nomeprog    := "BRFAT058" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFT58"
     Private cbCont      := 0
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFAT058" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SC5"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  
    if !u_VldAcesso(funname())
        MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
        return 
     endif 

     ValidPerg()
     Pergunte("BRFT58", .F.)
     
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel := SetPrint(cString, wnrel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .T., , .T., Tamanho)

     If mv_par03 == 1
        Cabec1 := "CIDADE                        EMP-PEDIDO-CLIENTE                          QTDE  "
        Cabec1 := "                                                                         VOLUME "
     ElseIf mv_par03 == 2
            Cabec1 := "CIDADE                        EMP-PEDIDO-CLIENTE                        QTDE PESO"
            Cabec1 := "                                                                         LIQUIDO"
     Else
        Cabec1 := "CIDADE                        EMP-PEDIDO-CLIENTE                        QTDE PESO"
        Cabec1 := "                                                                          BRUTO "
     Endif

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
     
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Processa({|| RunReport(Cabec1, Cabec2, Titulo, _nLin) }, Titulo)
Return

Static Function RunReport(Cabec1, Cabec2, Titulo, _nLin)
       
	Local cQuery    := ""
    Local nTotalVol := 0
    Local nSomaVol  := 0
    Local cRegiao   := ""
    Local cAux      := ""
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Inicializa  regua de impressao                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If mv_par03 == 1
    	cQuery += "SELECT DISTINCT '01' AS EMPRESA, SC9.C9_PEDIDO AS PEDIDO, SC9.C9_CLIENTE AS CLIENTE, SC5.C5_VOLUME1 AS QTDEVOL, SA1.A1_NOME AS RAZAO, SA1.A1_CODCID AS CODLOCAL, SZ7.Z7_NOME AS CIDADE, SZ7.Z7_EST AS ESTADO, SZ7.Z7_REGIAO AS REGIAO, SX5.X5_DESCRI AS DESCRREGIAO "
    ElseIf mv_par03 == 2
        cQuery += "SELECT DISTINCT '01' AS EMPRESA, SC9.C9_PEDIDO AS PEDIDO, SC9.C9_CLIENTE AS CLIENTE, SC5.C5_PESOL   AS QTDEVOL, SA1.A1_NOME AS RAZAO, SA1.A1_CODCID AS CODLOCAL, SZ7.Z7_NOME AS CIDADE, SZ7.Z7_EST AS ESTADO, SZ7.Z7_REGIAO AS REGIAO, SX5.X5_DESCRI AS DESCRREGIAO "
    Else
        cQuery += "SELECT DISTINCT '01' AS EMPRESA, SC9.C9_PEDIDO AS PEDIDO, SC9.C9_CLIENTE AS CLIENTE, SC5.C5_PBRUTO  AS QTDEVOL, SA1.A1_NOME AS RAZAO, SA1.A1_CODCID AS CODLOCAL, SZ7.Z7_NOME AS CIDADE, SZ7.Z7_EST AS ESTADO, SZ7.Z7_REGIAO AS REGIAO, SX5.X5_DESCRI AS DESCRREGIAO "
    Endif
    
    cQuery += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SC9.C9_CLIENTE = SA1.A1_COD AND SA1.D_E_L_E_T_ <> '*' "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SC9.C9_FILIAL AND SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.D_E_L_E_T_ <> '*' "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON SZ7.Z7_FILIAL = '' AND SZ7.Z7_COD = SA1.A1_CODCID AND SZ7.D_E_L_E_T_ <> '*' "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON SX5.X5_FILIAL = '' AND SX5.X5_TABELA = '98' AND SX5.X5_CHAVE = SZ7.Z7_REGIAO AND SX5.D_E_L_E_T_ <> '*' "
    cQuery += "WHERE SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
    cQuery += "  AND SC9.D_E_L_E_T_ <> '*' "
    cQuery += "  AND SC9.C9_BLEST   = '  ' "
    cQuery += "  AND SC9.C9_BLCRED  = '  ' "
    cQuery += "  AND SC9.C9_BLOQUEI = '  ' "
    cQuery += "  AND LEN(SC9.C9_NFISCAL) = 0 "
    cQuery += "  AND SC9.C9_DTLCRED BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
    cQuery += "  AND SZ7.Z7_REGIAO <> '999' "
    cQuery += "ORDER BY SX5.X5_DESCRI, SZ7.Z7_EST, SZ7.Z7_NOME, SC9.C9_CLIENTE DESC "
    
    TCQuery cQuery ALIAS "TCQ" NEW

    nTotalVol := 0
    DbSelectArea("TCQ")
    DbGoTop()

    ProcRegua(100)
    
    While !Eof()
        cRegiao := TCQ->REGIAO
        If _nlin >= 57
        	_nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
            _nLin += 1
        Endif
        
        _nLin += 1
        @ _nLin, 000 PSAY Replicate("=", 80)
        _nLin += 1
        cAux := "REGIAO : "+Alltrim(TCQ->DESCRREGIAO)
        nCol := 40 - Round(Len(cAux) / 2, 0)
        @ _nLin, nCol PSAY cAux
        _nLin += 1
        @ _nLin, 000 PSAY Replicate("=", 80)
        nSomaVol := 0
        While !Eof() .and. (TCQ->REGIAO == cRegiao)
        	If _nlin >= 60
        		_nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
                _nLin += 1
            Endif
            _nLin += 1
            @ _nLin, 000 PSAY SubStr(Alltrim(TCQ->CIDADE)+"-"+TCQ->ESTADO, 1, 30)
            @ _nLin, 030 PSAY SubStr(TCQ->EMPRESA+"-"+TCQ->PEDIDO+"-"+TCQ->RAZAO, 1, 40)
            If mv_par03 == 1
            	@ _nLin, 070 PSAY TCQ->QTDEVOL Picture "@E 99,999,999"
            ElseIf mv_par03 == 2
                @ _nLin, 070 PSAY TCQ->QTDEVOL Picture "@E 999,999.99"
            Else
                @ _nLin, 070 PSAY TCQ->QTDEVOL Picture "@E 999,999.99"
            Endif
            
            nSomaVol += TCQ->QTDEVOL
            DbSelectArea("TCQ")
            DbSkip()
        EndDo
        If _nlin >= 57
        	_nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
            _nLin += 1
        Endif
        _nLin += 1
        @ _nLin, 000 PSAY Replicate("_", 80)
        _nLin += 1
        If mv_par03 == 1
        	@ _nLin, 040 PSAY "QTDE DE VOLUMES P/ A REGIAO : "
            @ _nLin, 070 PSAY nSomaVol Picture "@E 99,999,999"
        ElseIf mv_par03 == 2
            @ _nLin, 040 PSAY "QTDE DE PESO L. P/ A REGIAO : "
            @ _nLin, 070 PSAY nSomaVol Picture "@E 999,999.99"
        Else
            @ _nLin, 040 PSAY "QTDE DE PESO B. P/ A REGIAO : "
            @ _nLin, 070 PSAY nSomaVol Picture "@E 999,999.99"
        Endif
        _nLin += 1
        @ _nLin, 000 PSAY Replicate("_", 80)
        nTotalVol += nSomaVol
           
        DbSelectArea("TCQ")
        DbSkip()
    EndDo
       
       If _nlin >= 57
          _nLin := Cabec(titulo, Cabec1, Cabec2, nomeprog, tamanho, nTipo)
          _nLin += 1
       Endif
       _nLin += 1
       @ _nLin, 000 PSAY Replicate("-",80)
       _nLin += 1
       If mv_par03 == 1
          @ _nLin, 000 PSAY "QTDE TOTAL DE VOLUMES : "+Alltrim(Transform(nTotalVol, "@E 999,999,999"))
       ElseIf mv_par03 == 1
              @ _nLin, 000 PSAY "QTDE TOTAL DE PESO L. : "+Alltrim(Transform(nTotalVol, "@E 999,999,999"))
       Else
          @ _nLin, 000 PSAY "QTDE TOTAL DE PESO B. : "+Alltrim(Transform(nTotalVol, "@E 999,999,999"))
       Endif
       _nLin += 1
       @ _nLin, 000 PSAY Replicate("-", 80)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³                      FIM DA IMPRESSAO                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       DbSelectArea("TCQ")
       DbCloseArea()

       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif
Return

/******************************************************************************/
/*** Programa  : VALIDPERG                                                  ***/
/*** Descricao : Grava Perguntas                                            ***/
/******************************************************************************/
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local aRegs   := {}
       Local i, j

       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Data Aprov.Ped. De  ?", "", "", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01", "      ", "", "", "            ", "", "", "          ", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "02", "Data Aprov.Ped. Ate ?", "", "", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", "      ", "", "", "            ", "", "", "          ", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "03", "Tipo de relatório    ", "", "", "mv_ch3", "N", 01, 0, 1, "C", "", "mv_par03", "Volume", "", "", "Peso Liquido", "", "", "Peso Bruto", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       For i := 1 to Len(aRegs)
           If !DbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return