#include 'rwmake.ch'
#include 'topconn.ch'
#include "winapi.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFISX03 º Autor ³ Luís Gustavo       º Data ³  11/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para exportação de Dados da BRASILUX para AUDITEC   º±±
±±º          ³ ACESSORIA LTDA. para integração com o programa de contabi- º±±
±±º          ³ lidade CONTMATIC. versão: 3.0                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASIMIX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFISX03()
     Local   nOpca    := 0
     Private cPerg    := "FISX03"
     Private oDlg
     Private cString  := "SF3"

     ValPerg()
     Pergunte(cPerg, .f.)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Montagem da tela de processamento.                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     oDlg := oSend( MSDialog(), "New", 08, 10, 18, 60, OemToAnsi("Gera Integração com AUDITEC CONTABILIDADE E ACESSORIA LTDA."), , , .F., , , , , GetWndDefault(), .F., , , .F.)
     @ 012,010 TO 060,185
     @ 020,018 SAY OemToAnsi(" Este programa ira gerar um arquivo texto, conforme os parame- ")
     @ 030,018 SAY OemToAnsi(" tros definidos  pelo usuario,  com os registros do arquivo de ")
     @ 040,018 SAY OemToAnsi(" de Notas Fiscais de entrada e saída. Versão 3.0               ")
     @ 062,155 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)

     bInit       := {|| EnchoiceBar(oDlg, { ||nOpcA := 1, oSend(oDlg, "End") }, { ||nOpcA := 0, oSend(oDlg, "End") } ) }
     oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     
     oSend( oDlg, "Activate", , , , .T., , , bInit )
     
     If nOpcA == 0
        Return
     Else
        fGerTxt()
     Endif
Return

/*************************************************************************/
/*** FGERTXT - Gera arquivo texto e busca informações.                 ***/
/*************************************************************************/
Static Function fGerTxt()
       Private cArqTxt := ""
       Private nHdl    := 0
       Private aRegExp := {}
       Private cEOL    := "CHR(13)+CHR(10)"
       Private cPriDia := ctod("01/"+StrZero(mv_par01, 2)+"/"+StrZero(Year(dDataBase),4))
       Private cUltDia := ctod(StrZero(f_UltDia(cPridia),2)+"/"+StrZero(mv_par01, 2)+"/"+StrZero(Year(dDataBase),4))
       
       If Empty(cEOL)
          cEOL := CHR(13)+CHR(10)
       Else
          cEOL := Trim(cEOL)
          cEOL := &cEOL
       Endif

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicializa a regua de processamento                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       nQtdReg := 0

       MsAguarde({|| fGerArq(@nQtdReg) }, "Gerando arquivo, Processo pode ser demorado...")

       cArqTxt := "\spool\AUDITEC\"+Iif(mv_par02 == 1, "ENTRADA\"+GetMv("MV_AUDITEC")+".E"+StrZero(mv_par01,2), "SAIDA\"+GetMv("MV_AUDITEC")+".S"+StrZero(mv_par01,2) )
       nHdl    := fCreate(cArqTxt)
       If nHdl == -1
          MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
          Return
       Endif

       Processa({|| fGerLiv(nQtdReg) }, "Processando...")

       If ChkFile("LIVC")
          DbSelectArea("LIVC")
          DbCloseArea()
       Endif
       If ChkFile("LIVD")
          DbSelectArea("LIVD")
          DbCloseArea()
       Endif
       fClose(nHdl)
Return

/*************************************************************************/
/*** FGERARQ - Verifica arquivo com as informações.                    ***/
/*************************************************************************/
Static Function fGerArq(nQtdReg)
       Local cDrvArq := ""
       Local cPatArq := "\spool\AUDITEC\"+Iif(mv_par02 == 1, 'ENTRADA\', 'SAIDA\')
       Local aStrCab := {}
       Local aStrDet := {}
       Local cArqCab := "C"+SubStr(StrZero(Year(dDataBase), 4), 3, 2)+StrZero(mv_par01, 2)+xFilial("SF3")
       Local cArqDet := "D"+SubStr(StrZero(Year(dDataBase), 4), 3, 2)+StrZero(mv_par01, 2)+xFilial("SF3")
       Local cArqRes := "R"+SubStr(StrZero(Year(dDataBase), 4), 3, 2)+StrZero(mv_par01, 2)+xFilial("SF3")
       //Local cQry1   := ""
       nQtdReg       := 0
       #IFDEF WNTX
              cDrvArq := "DBFNTX"
       #ENDIF
       #IFDEF WCDX
              cDrvArq := "DBFCDX"
       #ENDIF
       #IFDEF WASX
              cDrvArq := "DBFCDXAX"
       #ENDIF
       #IFDEF WCODEBASE
              cDrvArq := "DBFCDXTTS"
       #ENDIF

       If ChkFile("LIVC")
          DbSelectArea("LIVC")
          DbCloseArea()
       Endif
       If ChkFile("LIVD")
          DbSelectArea("LIVD")
          DbCloseArea()
       Endif
       lRet := .t.
       If File(cPatArq+cArqCab+'.DBF')
          If MsgYesNo("Arquivo já existe para esse mês/ano, sobrepõe ?", "Atenção")
             FErase(cPatArq+cArqCab+'.DBF') //Apaga arquivo de cabeçalho existente.
             FErase(cPatArq+cArqDet+'.DBF') //Apaga arquivo de detalhe existente.
             FErase(cPatArq+cArqRes+'.DBF') //Apaga arquivo de resumo por CFO
          Else
             lRet := .f.
          Endif
       Endif
       If lRet //Cria um novo arquivo
          aStrCab := {} //Matriz com campos da matriz de cabeçalho
          aadd(aStrCab, {"LC_GERAKEY", "C", 019, 0}) //Chave da Tabela
          aadd(aStrCab, {"LC_TIPOREG", "C", 002, 0}) //Tipo do Registro                  - R1
          aadd(aStrCab, {"LC_ENTRADA", "C", 004, 0}) //Dia e Mes da Emissão
          aadd(aStrCab, {"LC_EMISSAO", "C", 004, 0}) //Entrada e Saída
          aadd(aStrCab, {"LC_DATAINT", "C", 002, 0}) //Data da Integração                - space(02)
          aadd(aStrCab, {"LC_ESPECIE", "C", 003, 0}) //Espécie da Nota
          aadd(aStrCab, {"LC_SERIENF", "C", 003, 0}) //Série da Nota
          aadd(aStrCab, {"LC_DANOTAF", "C", 006, 0}) //Da Nota Fiscal
          aadd(aStrCab, {"LC_ATNOTAF", "C", 006, 0}) //Até Nota Fiscal                   - 000000
          aadd(aStrCab, {"LC_CFONFIS", "C", 005, 0}) //Código da Operação da Nota Fiscal
          aadd(aStrCab, {"LC_VALORCO", "N", 012, 2}) //Valor contábil
          aadd(aStrCab, {"LC_BICMS_1", "N", 012, 2}) //Base de ICMS 1
          aadd(aStrCab, {"LC_AICMS_1", "N", 006, 2}) //Aliquota de ICMS 1
          aadd(aStrCab, {"LC_VICMS_1", "N", 012, 2}) //Valor de ICMS 1
          aadd(aStrCab, {"LC_IICMS_1", "N", 012, 2}) //Isentas de ICMS 1
          aadd(aStrCab, {"LC_OICMS_1", "N", 012, 2}) //Outras de ICMS 1
          aadd(aStrCab, {"LC_BICMS_2", "N", 012, 2}) //Base de ICMS 2                    - 000000000000
          aadd(aStrCab, {"LC_AICMS_2", "N", 006, 2}) //Aliquota de ICMS 2                - 000,00
          aadd(aStrCab, {"LC_VICMS_2", "N", 012, 2}) //Valor de ICMS 2                   - 000000000,00
          aadd(aStrCab, {"LC_IICMS_2", "N", 012, 2}) //Isentas de ICMS 2                 - 000000000,00
          aadd(aStrCab, {"LC_OICMS_2", "N", 012, 2}) //Outras de ICMS 2                  - 000000000,00
          aadd(aStrCab, {"LC_BICMS_3", "N", 012, 2}) //Base de ICMS 3                    - 000000000,00
          aadd(aStrCab, {"LC_AICMS_3", "N", 006, 2}) //Aliquota de ICMS 3                - 000,00
          aadd(aStrCab, {"LC_VICMS_3", "N", 012, 2}) //Valor de ICMS 3                   - 000000000,00
          aadd(aStrCab, {"LC_IICMS_3", "N", 012, 2}) //Isentas de ICMS 3                 - 000000000,00
          aadd(aStrCab, {"LC_OICMS_3", "N", 012, 2}) //Outras de ICMS 3                  - 000000000,00
          aadd(aStrCab, {"LC_BICMS_4", "N", 012, 2}) //Base de ICMS 4                    - 000000000,00
          aadd(aStrCab, {"LC_AICMS_4", "N", 006, 2}) //Aliquota de ICMS 4                - 000,00
          aadd(aStrCab, {"LC_VICMS_4", "N", 012, 2}) //Valor de ICMS 4                   - 000000000,00
          aadd(aStrCab, {"LC_IICMS_4", "N", 012, 2}) //Isentas de ICMS 4                 - 000000000,00
          aadd(aStrCab, {"LC_OICMS_4", "N", 012, 2}) //Outras de ICMS 4                  - 000000000,00
          aadd(aStrCab, {"LC_BICMS_5", "N", 012, 2}) //Base de ICMS 5                    - 000000000,00
          aadd(aStrCab, {"LC_AICMS_5", "N", 006, 2}) //Aliquota de ICMS 5                - 000,00
          aadd(aStrCab, {"LC_VICMS_5", "N", 012, 2}) //Valor de ICMS 5                   - 000000000,00
          aadd(aStrCab, {"LC_IICMS_5", "N", 012, 2}) //Isentas de ICMS 5                 - 000000000,00
          aadd(aStrCab, {"LC_OICMS_5", "N", 012, 2}) //Outras de ICMS 5                  - 000000000,00
          aadd(aStrCab, {"LC_BASEIPI", "N", 012, 2}) //Base de IPI
          aadd(aStrCab, {"LC_IMPOIPI", "N", 012, 2}) //Valor do IPI
          aadd(aStrCab, {"LC_ISENIPI", "N", 012, 2}) //Isentas de IPI
          aadd(aStrCab, {"LC_OUTRIPI", "N", 012, 2}) //Outras de IPI
          aadd(aStrCab, {"LC_NAOAIPI", "N", 012, 2}) //IPI não aproveitado
          aadd(aStrCab, {"LC_VICMRET", "N", 012, 2}) //Valor do ICMS Retido
          aadd(aStrCab, {"LC_BICMRET", "N", 012, 2}) //Base do ICMS Retido
          aadd(aStrCab, {"LC_VLRAVIS", "N", 012, 2}) //Valor a vista                     - 000000000,00
          aadd(aStrCab, {"LC_VLRAPRZ", "N", 012, 2}) //Valor a prazo                     - 000000000,00
          aadd(aStrCab, {"LC_ISENPIS", "N", 012, 2}) //Insento do PIS                    - 000000000,00
          aadd(aStrCab, {"LC_CONTRIB", "C", 001, 0}) //Contrinuinte                      - 0
          aadd(aStrCab, {"LC_TIPONFC", "C", 002, 0}) //Tipo da Nota Fiscal
          aadd(aStrCab, {"LC_CODCONT", "C", 002, 0}) //Código da Conta Contábil          - 00
          aadd(aStrCab, {"LC_OBSERVA", "C", 014, 0}) //Observação
          aadd(aStrCab, {"LC_CGCCLFO", "C", 014, 0}) //CGC Cliente/Fornecedor
          aadd(aStrCab, {"LC_INSCEST", "C", 016, 0}) //Inscrição Estadual
          aadd(aStrCab, {"LC_RAZAOSO", "C", 035, 0}) //Razao Social
          aadd(aStrCab, {"LC_CTACONT", "C", 018, 0}) //Conta Contabil do Fornecedor      - space(18)
          aadd(aStrCab, {"LC_UFCLIFO", "C", 002, 0}) //UF Cliente/Fornecedor
          aadd(aStrCab, {"LC_CODMUNI", "C", 004, 0}) //Código do Municipio               - space(04)
          aadd(aStrCab, {"LC_VAGOR11", "C", 050, 0}) //Campo vago                        - space(50)
          aadd(aStrCab, {"LC_CLIENTE", "C", 006, 0}) //Código do Cliente/Fornecedor
          aadd(aStrCab, {"LC_LOJACLI", "C", 002, 0}) //Loja do Cliente/Fornecedor
          aadd(aStrCab, {"LC_TIPONFI", "C", 001, 0}) //Tipo da Nota Fiscal
          aadd(aStrCab, {"LC_TESNFIS", "C", 003, 0}) //TES da Nota Fiscal
          aadd(aStrCab, {"LC_LFISICM", "C", 001, 0}) //Livro Fiscal de ICMS
          aadd(aStrCab, {"LC_LFISIPI", "C", 001, 0}) //Livro Fiscal de IPI
          aadd(aStrCab, {"LC_INCSOLI", "C", 001, 0}) //ICMS Solidário
          aadd(aStrCab, {"LC_F3_DCAN", "D", 008, 0}) //Data da Nota fiscal cancelada
          aadd(aStrCab, {"LC_COLUICM", "N", 012, 2}) //Soma das Colunas de ICMS
          aadd(aStrCab, {"LC_COLUIPI", "N", 012, 2}) //Soma das Colunas de IPI
          aadd(aStrCab, {"LC_CLASCLI", "C", 001, 2}) //Classificação do Cliente no Cadastro de clientes
          aadd(aStrCab, {"LC_CLASNFI", "C", 001, 2}) //Classificação do Cliente nas Notas fiscais
          
          DbCreate(cPatArq+cArqCab, aStrCab, cDrvArq)
          DbUseArea(.t., cDrvArq, cPatArq+cArqCab, "LIVC", Iif(.f. .or. .t., !.t., Nil), .f.)
          DbCreateIndex(cPatArq+cArqCab+'1', "LC_GERAKEY", {|| "LC_GERAKEY"})
          DbCreateIndex(cPatArq+cArqCab+'2', "LC_DANOTAF", {|| "LC_DANOTAF"})
          DbClearIndex()
          DbSetIndex(cPatArq+cArqCab+'1')
          DbSetIndex(cPatArq+cArqCab+'2')
          DbSetOrder(1)

          aStrDet := {} //Matriz com campos da matriz de detalhe
          aadd(aStrDet, {"LD_GERAKEY", "C", 019, 0}) //Chave da Tabela
          aadd(aStrDet, {"LD_TIPOREG", "C", 002, 0}) //Tipo do Registro                  - R2
          aadd(aStrDet, {"LD_VAGOR21", "C", 008, 0}) //Campo vago                        - Space(08)
          aadd(aStrDet, {"LD_CPDNCMP", "C", 010, 0}) //Código NCM do Produto
          aadd(aStrDet, {"LD_ITEMNFS", "C", 010, 0}) //Código do Item na NF
          aadd(aStrDet, {"LD_DESCPRO", "C", 025, 0}) //Descrição do Produto
          aadd(aStrDet, {"LD_ISENPIS", "N", 012, 2}) //Isenção de PIS
          aadd(aStrDet, {"LD_BASEIPI", "N", 012, 2}) //Base de IPI
          aadd(aStrDet, {"LD_IMPOIPI", "N", 012, 2}) //Valor do Imposto IPI
          aadd(aStrDet, {"LD_ISENIPI", "N", 012, 2}) //Isentas de IPI
          aadd(aStrDet, {"LD_VAGOR22", "C", 012, 2}) //Campo vago                        - Space(50)
          aadd(aStrDet, {"LD_D2_BICM", "N", 012, 2}) //Base de ICMS
          aadd(aStrDet, {"LD_D2_VICM", "N", 012, 2}) //Valor de ICMS
          aadd(aStrDet, {"LD_D2_BRET", "N", 012, 2}) //Base de ICMS Retido
          aadd(aStrDet, {"LD_D2_IRET", "N", 012, 2}) //Valor de ICMS Retido
          aadd(aStrDet, {"LD_D2_DZFR", "N", 012, 2}) //Desconto da Zona Franca de Manaus
          aadd(aStrDet, {"LD_D2_VTOT", "N", 012, 2}) //Valor total da NF
          aadd(aStrDet, {"LD_D2_VALC", "N", 012, 2}) //Valor total da NF

          DbCreate(cPatArq+cArqDet, aStrDet, cDrvArq)
          DbUseArea(.t., cDrvArq, cPatArq+cArqDet, "LIVD", Iif(.f. .or. .t., !.t., Nil), .f.)
          DbCreateIndex(cPatArq+cArqDet+'1', "LD_GERAKEY+LD_CPDNCMP+LD_ITEMNFS", {||"LD_GERAKEY+LD_CPDNCMP+LD_ITEMNFS"})
          DbClearIndex()
          DbSetIndex(cPatArq+cArqDet+'1')
          DbSetOrder(1)

          aStrRES := {} //Matriz com campos da matriz de detalhe
          aadd(aStrRes, {"RS_CFONOTA", "C", 005, 0}) //
          aadd(aStrRes, {"RS_VLRCONT", "N", 012, 2}) //
          aadd(aStrRes, {"RS_BASEICM", "N", 012, 2}) //
          aadd(aStrRes, {"RS_VALOICM", "N", 012, 2}) //
          aadd(aStrRes, {"RS_ISENICM", "N", 012, 2}) //
          aadd(aStrRes, {"RS_OUTRICM", "N", 012, 2}) //
          DbCreate(cPatArq+cArqRes, aStrRes, cDrvArq)
          DbUseArea(.t., cDrvArq, cPatArq+cArqRes, "RESU", Iif(.f. .or. .t., !.t., Nil), .f.)
          DbCreateIndex(cPatArq+cArqRes+'1', "RS_CFONOTA", {||"RS_CFONOTA"})
          DbClearIndex()
          DbSetIndex(cPatArq+cArqRes+'1')
          DbSetOrder(1)

          Proc2BarGauge( {|| fMonArq() }, "Gerando integração Microsiga(Brasilux) X G5 Phoenix(Auditec)", "Processando Nota Fiscal: ", "Processando Codigo Fiscal: ", .f., .t., .t., .t.)
          nQtdRec := LIVC->(RecCount())
       Else
          //Abre arquivo existente
          DbUseArea(.t., cDrvArq, cPatArq+cArqCab, "LIVC", Iif(.f. .or. .t., !.t., Nil), .f.)
          DbClearIndex()
          DbSetIndex(cPatArq+cArqCab+'1')
          DbSetOrder(1)

          DbUseArea(.t., cDrvArq, cPatArq+cArqDet, "LIVD", Iif(.f. .or. .t., !.t., Nil), .f.)
          DbClearIndex()
          DbSetIndex(cPatArq+cArqDet+'1')
          DbSetOrder(1)
          nQtdRec := LIVC->(RecCount())
       Endif
Return          

/*************************************************************************/
/*** FMONARQ - Busca dados nos arquivos.                               ***/
/*************************************************************************/
Static Function fMonArq()
       Local nY
       Local cQry1_A := ""
       Local _CFIPINA := GETMV("MV_CFIPINA")
       cQry1_A += "SELECT 'GERAKEY' = SF2.F2_EMISSAO+SF2.F2_DOC, "
       cQry1_A += "       'ENTRADA' = SF2.F2_EMISSAO, "
       cQry1_A += "       'EMISSAO' = SF2.F2_EMISSAO, "
       cQry1_A += "       'CLIENTE' = SF2.F2_CLIENTE, "
       cQry1_A += "       'LOJACLI' = SF2.F2_LOJA   , "
       cQry1_A += "       'NFISCAL' = SF2.F2_DOC    , "
       cQry1_A += "       'SERIENF' = SF2.F2_SERIE  , "
       cQry1_A += "       'ESTADOC' = SF2.F2_EST    , "
       cQry1_A += "       'ESPECIE' = ''            , "
       cQry1_A += "       'TIPONFI' = ''            , "
       cQry1_A += "       'TIPOSF2' = SF2.F2_TIPO   , "
       cQry1_A += "       'F3_VALC' = CASE WHEN SF2.F2_TIPO = 'I' THEN  SF2.F2_ICMSRET ELSE SF2.F2_VALBRUT END, "
       cQry1_A += "       'F3_IRET' = SF2.F2_ICMSRET, "
       cQry1_A += "       'F3_BRET' = SF2.F2_BRICMS   "
       cQry1_B := ""
       cQry1_B += "SELECT COUNT(*) AS QTDREC "
       cQry1_C := ""
       cQry1_C += "FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
       cQry1_C += "WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"' "
       cQry1_C += "  AND SF2.D_E_L_E_T_ = '' "
       cQry1_C += "  AND SF2.F2_EMISSAO BETWEEN '"+dtos(cPriDia)+"' AND '"+dtos(cUltDia)+"' "
       cQry1_A += cQry1_C 
       cQry1_A += "ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC "
       cQry1_B += cQry1_C 
       TCQuery cQry1_A ALIAS "TCQ" NEW
       TCQuery cQry1_B ALIAS "QTD" NEW

       DbSelectArea("QTD")
       BarGauge1Set( QTD->QTDREC )
       DbSelectArea("QTD")
       DbCloseArea()
       
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             IncProcG1("Processando nota fiscal: "+TCQ->NFISCAL)
             cQry1_A := ""
             cQry1_A += "SELECT 'TESNFIS' = SD2.D2_TES    , "
             cQry1_A += "       'COPERAC' = SD2.D2_CF     , "
             cQry1_A += "       'LFISICM' = SF4.F4_LFICM  , "
             cQry1_A += "       'LFISIPI' = SF4.F4_LFIPI  , "
             cQry1_A += "       'INCSOLI' = SF4.F4_INCSOL , "
             cQry1_A += "       'CODINCM' = SD2.D2_POSIPI , "
             cQry1_A += "       'DESCPRO' = SB1.B1_DESC   , "
             cQry1_A += "       'F3_BICM' = SD2.D2_BASEICM, "
             cQry1_A += "       'F3_AICM' = SD2.D2_PICM   , "
             cQry1_A += "       'F3_VICM' = SD2.D2_VALICM , "
             cQry1_A += "       'F3_BIPI' = SD2.D2_BASEIPI, "
             cQry1_A += "       'F3_VIPI' = SD2.D2_VALIPI , "
             cQry1_A += "       'D2_VTOT' = SD2.D2_TOTAL  , "
             cQry1_A += "       'D2_BICM' = SD2.D2_BASEICM, "
             cQry1_A += "       'D2_VIPI' = SD2.D2_VALIPI , "
             cQry1_A += "       'D2_BIPI' = SD2.D2_BASEIPI, "
             cQry1_A += "       'D2_VICM' = SD2.D2_VALICM , "
             cQry1_A += "       'D2_BRET' = SD2.D2_BRICMS , "
             cQry1_A += "       'D2_IRET' = SD2.D2_ICMSRET, "
             cQry1_A += "       'D2_DZFR' = SD2.D2_DESCZFR, "
             cQry1_A += "       'D2_ITEM' = SD2.D2_ITEM   , "
             cQry1_A += "       'D2_VALC' = SD2.D2_TOTAL + SD2.D2_VALIPI + SD2.D2_ICMSRET - SD2.D2_DESCZFR + SD2.D2_SEGURO + SD2.D2_VALFRE + SD2.D2_DESPESA "
             cQry1_B := ""
             cQry1_B += "SELECT COUNT(SD2.D2_CF) AS QTDCFO "
             cQry1_C := ""
             cQry1_C += "FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
             cQry1_C += "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON '  ' = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = '' "
             cQry1_C += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SD2.D2_FILIAL AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_ = '' "
             cQry1_C += "WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"' "
             cQry1_C += "  AND SD2.D_E_L_E_T_ = '' "
             cQry1_C += "  AND SD2.D2_DOC     = '"+TCQ->NFISCAL+"' "
             cQry1_C += "  AND SD2.D2_SERIE   = '' "
             cQry1_A += cQry1_C
             cQry1_A += "ORDER BY SD2.D2_CF "
             cQry1_B += cQry1_C
             TCQuery cQry1_A ALIAS "CAB" NEW
             TCQuery cQry1_B ALIAS "QTD" NEW

             DbSelectArea("QTD")
             BarGauge2Set( QTD->QTDCFO )
             DbSelectArea("QTD")
             DbCloseArea()
             aMatAux := {}
             aMatRes := {}
             DbSelectArea("CAB")
             DbGoTop()
             While !Eof()
                   IncProcG2("Processando Codigo Fiscal: "+SubStr(CAB->COPERAC, 1, 1)+'.'+SubStr(CAB->COPERAC, 2, 3))
                   RecLock("LIVD", .t.)
                      LIVD->LD_GERAKEY := TCQ->GERAKEY+CAB->COPERAC
                      LIVD->LD_TIPOREG := 'R2'
                      LIVD->LD_VAGOR21 := Space(08)
                      LIVD->LD_CPDNCMP := CAB->CODINCM
                      LIVD->LD_DESCPRO := CAB->DESCPRO
                      LIVD->LD_ISENPIS := 0
                      LIVD->LD_BASEIPI := CAB->D2_BIPI
                      LIVD->LD_IMPOIPI := CAB->D2_VIPI
                      LIVD->LD_ISENIPI := Iif(CAB->D2_BIPI == 0.00, CAB->D2_VTOT, 0.00)
                      LIVD->LD_VAGOR22 := Space(50)
                      LIVD->LD_D2_BICM := CAB->D2_BICM
                      LIVD->LD_D2_VICM := CAB->D2_VICM
                      LIVD->LD_D2_BRET := CAB->D2_BRET
                      LIVD->LD_D2_IRET := CAB->D2_IRET
                      LIVD->LD_D2_DZFR := CAB->D2_DZFR
                      LIVD->LD_D2_VTOT := CAB->D2_VTOT
                      LIVD->LD_ITEMNFS := CAB->D2_ITEM
                      LIVD->LD_D2_VALC := CAB->D2_VALC
                   MsUnLock()
                   If aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC}) == 0
                      cTipNFi := ""
                      If TCQ->TIPONFI $ 'D'                                              //Se for Nota Fiscal de Devolução
                         cTipNFi := '00'                                                 //Nota Fiscal Normal
                      Else                                                               //Senão não for Nota Fiscal de Devolução
                         If mv_par02 == 1                                                //Se estiver processando as Notas Fiscais de Entrada
                            cTipNFi := space(02)                                         //Tipo em branco
                         Else                                                            //Senão se estiver processando as Notas Fiscais de Saída
                            cTipNFi := '00'                                              //Tipo inicializa como Nota fiscal normal.
                            If TCQ->ESTADOC $ 'SP' .and. Alltrim(CAB->COPERAC) $ '5401'  //Estado de São Paulo Com Substituição
                               cTipNFi := '22'
                            ElseIf TCQ->ESTADOC $ 'AC.AM.AP.RO.RR'  //Zona Franca
                                   If !Empty(Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE+TCQ->LOJACLI, "A1_CODMUN")) .and. !Empty(Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE+TCQ->LOJACLI, "A1_SUFRAMA")) .and. Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE+TCQ->LOJACLI, "A1_CALCSUF") $ 'S'
                                      cTipNFi := '05'
                                   Endif
                            //ElseIf Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE+TCQ->LOJACLI, "A1_CLAS") $ 'C.N' //Ipi Embutido
                            ElseIf Posicione("SF2", 1, xFilial("SF2")+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI, "F2_CLAS") $ 'C.N' //Ipi Embutido
                                   If CAB->F3_VIPI > 0
                                      cTipNFi := '02'
                                   Endif
                            ElseIf TCQ->F3_BRET > 0.0 .and. !TCQ->ESTADOC $ 'AM.SP'
                                   cTipNFi := '13'
                            Endif
                         Endif
                      Endif                   
                      nCampo34 := Iif(cTipNFi $ '02', (CAB->D2_BICM + Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_ISENICM") + Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_OUTRICM") + TCQ->F3_IRET), (CAB->D2_BICM + Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_ISENICM") + Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_OUTRICM") + CAB->D2_VIPI +TCQ->F3_IRET))
                      nCampo35 := (CAB->D2_BIPI + CAB->D2_VIPI + Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_ISENIPI") + Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_OUTRIPI") + TCQ->F3_IRET)
                      nCampo36 := Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ '', Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_CLAS'), Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ 'B.D', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_CLAS'), Iif(mv_par02 == 1 .and. TCQ->TIPONFI $ '', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_INSCR'), Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_CLAS')) ) )
                      nCampo37 := Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ '', Posicione("SF2", 1, xFilial('SF2')+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI, 'F2_CLAS'), Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ 'B.D', '', Iif(mv_par02 == 1 .and. TCQ->TIPONFI $ '', '', Posicione("SF2", 1, xFilial('SF2')+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI, 'F2_CLAS')) ) )
                      aAdd(aMatAux, {TCQ->GERAKEY+CAB->COPERAC                                ,; // 01
                                     SubStr(TCQ->ENTRADA, 7, 2)+SubStr(TCQ->ENTRADA, 5, 2)    ,; // 02
                                     SubStr(TCQ->EMISSAO, 7, 2)+SubStr(TCQ->EMISSAO, 5, 2)    ,; // 03
                                     Iif(mv_par02 == 1, TCQ->ESPECIE, Iif(Empty(TCQ->ESPECIE), 'NFF', TCQ->ESPECIE)),; // 04
                                     Iif(mv_par02 == 1, TCQ->SERIENF, Iif(Empty(TCQ->SERIENF), '1  ', TCQ->SERIENF)),; // 05
                                     TCQ->NFISCAL                                             ,; // 06
                                     SubStr(CAB->COPERAC, 1, 1)+'.'+SubStr(CAB->COPERAC, 2, 3),; // 07
                                     CAB->D2_VALC                                             ,; // 08
                                     CAB->D2_BICM                                             ,; // 09
                                     CAB->F3_AICM                                             ,; // 10
                                     CAB->D2_VICM                                             ,; // 11
                                     Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_ISENICM"),; // 12
                                     Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_OUTRICM"),; // 13
                                     CAB->D2_BIPI                                             ,; // 14
                                     CAB->D2_VIPI                                             ,; // 15
                                     Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_ISENIPI"),; // 16
                                     Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_OUTRIPI"),; // 17
                                     Iif(mv_par02 == 2, 0, Iif(SubStr(CAB->COPERAC, 2, 3) $ _CFIPINA, CAB->F3_VIPI, 0 ))                                            ,; // 18
                                     TCQ->F3_IRET                                             ,; // 19
                                     TCQ->F3_BRET                                             ,; // 20
                                     cTipNFi                                                  ,; // 21
                                     Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_OBSERV"),; // 22
                                     StrZero(Val(Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ '', Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_CGC')  , Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ 'B.D', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_CGC')  , Iif(mv_par02 == 1 .and. TCQ->TIPONFI $ '', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_CGC'), Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_CGC'  )) ) )), 14),; // 23
                                     Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ '', Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_INSCR'), Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ 'B.D', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_INSCR'), Iif(mv_par02 == 1 .and. TCQ->TIPONFI $ '', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_INSCR'), Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_INSCR')) ) ),; // 24
                                     Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ '', Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_NOME') , Iif(mv_par02 == 2 .and. TCQ->TIPONFI $ 'B.D', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_NOME') , Iif(mv_par02 == 1 .and. TCQ->TIPONFI $ '', Posicione("SA2", 1, xFilial('SA2')+TCQ->CLIENTE+TCQ->LOJACLI, 'A2_NOME') , Posicione("SA1", 1, xFilial('SA1')+TCQ->CLIENTE+TCQ->LOJACLI, 'A1_NOME' )) ) ),; // 25
                                     TCQ->ESTADOC                                             ,; // 26
                                     TCQ->CLIENTE                                             ,; // 27
                                     TCQ->LOJACLI                                             ,; // 28
                                     TCQ->TIPONFI                                             ,; // 29
                                     CAB->TESNFIS                                             ,; // 30
                                     CAB->LFISICM                                             ,; // 31
                                     CAB->LFISIPI                                             ,; // 32
                                     CAB->INCSOLI                                             ,; // 33
                                     nCampo34                                                 ,; // 34
                                     nCampo35                                                 ,; // 35
                                     nCampo36                                                 ,; // 36
                                     nCampo37                                                 }) //37
                   Else
                      aMatAux[aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC})][08] += CAB->D2_VALC
                      aMatAux[aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC})][09] += CAB->D2_BICM
                      aMatAux[aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC})][11] += CAB->D2_VICM
                      aMatAux[aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC})][14] += CAB->D2_BIPI
                      aMatAux[aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC})][15] += CAB->D2_VIPI
                      aMatAux[aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC})][34] += Iif(cTipNFi $ '02', (CAB->D2_BICM), (CAB->D2_BICM + CAB->D2_VIPI) )
                      aMatAux[aScan(aMatAux, {|x| x[1] = TCQ->GERAKEY+CAB->COPERAC})][35] += (CAB->D2_BIPI + CAB->D2_VIPI)
                   Endif
                   If aScan(aMatRes, {|x| x[1] = CAB->COPERAC}) == 0
                      aAdd(aMatRes, {CAB->COPERAC, CAB->D2_VALC, CAB->D2_BICM, CAB->F3_VICM, Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_ISENICM"), Posicione("SF3", 1, xFilial("SF3")+TCQ->ENTRADA+TCQ->NFISCAL+TCQ->SERIENF+TCQ->CLIENTE+TCQ->LOJACLI+CAB->COPERAC, "F3_OUTRICM") })
                   Else
                      aMatRes[aScan(aMatRes, {|x| x[1] = CAB->COPERAC})][02] += CAB->D2_VALC
                      aMatRes[aScan(aMatRes, {|x| x[1] = CAB->COPERAC})][03] += CAB->D2_BICM
                      aMatRes[aScan(aMatRes, {|x| x[1] = CAB->COPERAC})][04] += CAB->F3_VICM
                   EndIf
                   DbSelectArea("CAB")
                   DbSkip()
             Enddo
             If Len(aMatAux) > 0
                For nY := 1 To Len(aMatAux)
                    RecLock("LIVC", .t.)
                       LIVC->LC_GERAKEY := aMatAux[nY][01]
                       LIVC->LC_TIPOREG := 'R1'
                       LIVC->LC_ENTRADA := aMatAux[nY][02]
                       LIVC->LC_EMISSAO := aMatAux[nY][03]
                       LIVC->LC_DATAINT := Space(02)
                       LIVC->LC_ESPECIE := aMatAux[nY][04]
                       LIVC->LC_SERIENF := aMatAux[nY][05]
                       LIVC->LC_DANOTAF := aMatAux[nY][06]
                       LIVC->LC_ATNOTAF := '000000'
                       LIVC->LC_CFONFIS := aMatAux[nY][07]
                       LIVC->LC_VALORCO := aMatAux[nY][08]
                       LIVC->LC_BICMS_1 := aMatAux[nY][09]
                       LIVC->LC_AICMS_1 := aMatAux[nY][10]
                       LIVC->LC_VICMS_1 := aMatAux[nY][11]
                       LIVC->LC_IICMS_1 := aMatAux[nY][12]
                       LIVC->LC_OICMS_1 := aMatAux[nY][13]
                       LIVC->LC_BICMS_2 := 0
                       LIVC->LC_AICMS_2 := 0
                       LIVC->LC_VICMS_2 := 0
                       LIVC->LC_IICMS_2 := 0
                       LIVC->LC_OICMS_2 := 0
                       LIVC->LC_BICMS_3 := 0
                       LIVC->LC_AICMS_3 := 0
                       LIVC->LC_VICMS_3 := 0
                       LIVC->LC_IICMS_3 := 0
                       LIVC->LC_OICMS_3 := 0
                       LIVC->LC_BICMS_4 := 0
                       LIVC->LC_AICMS_4 := 0
                       LIVC->LC_VICMS_4 := 0
                       LIVC->LC_IICMS_4 := 0
                       LIVC->LC_OICMS_4 := 0
                       LIVC->LC_BICMS_5 := 0
                       LIVC->LC_AICMS_5 := 0
                       LIVC->LC_VICMS_5 := 0
                       LIVC->LC_IICMS_5 := 0
                       LIVC->LC_OICMS_5 := 0
                       LIVC->LC_BASEIPI := aMatAux[nY][14]
                       LIVC->LC_IMPOIPI := aMatAux[nY][15]
                       LIVC->LC_ISENIPI := aMatAux[nY][16]
                       LIVC->LC_OUTRIPI := aMatAux[nY][17]
                       LIVC->LC_NAOAIPI := aMatAux[nY][18]
                       LIVC->LC_VICMRET := aMatAux[nY][19]
                       LIVC->LC_BICMRET := aMatAux[nY][20]
                       LIVC->LC_VLRAVIS := 0
                       LIVC->LC_VLRAPRZ := 0
                       LIVC->LC_ISENPIS := 0
                       LIVC->LC_CONTRIB := '0'
                       LIVC->LC_TIPONFC := aMatAux[nY][21]
                       LIVC->LC_CODCONT := '00'
                       LIVC->LC_OBSERVA := aMatAux[nY][22]
                       LIVC->LC_CGCCLFO := aMatAux[nY][23]
                       LIVC->LC_INSCEST := aMatAux[nY][24]
                       LIVC->LC_RAZAOSO := aMatAux[nY][25]
                       LIVC->LC_CTACONT := space(18)
                       LIVC->LC_UFCLIFO := aMatAux[nY][26]
                       LIVC->LC_CODMUNI := Space(04)
                       LIVC->LC_VAGOR11 := Space(50)
                       LIVC->LC_CLIENTE := aMatAux[nY][27]
                       LIVC->LC_LOJACLI := aMatAux[nY][28]
                       LIVC->LC_TIPONFI := aMatAux[nY][29]
                       LIVC->LC_TESNFIS := aMatAux[nY][30]
                       LIVC->LC_LFISICM := aMatAux[nY][31]
                       LIVC->LC_LFISIPI := aMatAux[nY][32]
                       LIVC->LC_INCSOLI := aMatAux[nY][33]
                       LIVC->LC_F3_DCAN := CTOD('  /  /  ')
                       LIVC->LC_COLUICM := aMatAux[nY][34]
                       LIVC->LC_COLUIPI := aMatAux[nY][35]
                       LIVC->LC_CLASCLI := aMatAux[nY][36]
                       LIVC->LC_CLASNFI := aMatAux[nY][37]
                    MsUnLock()
                Next
             Endif
             If Len(aMatRes) > 0
                For nY := 1 To Len(aMatRes)
                    RecLock("RESU", .t.)
                       RESU->RS_CFONOTA := aMatRes[nY][01]
                       RESU->RS_VLRCONT := aMatRes[nY][02]
                       RESU->RS_BASEICM := aMatRes[nY][03]
                       RESU->RS_VALOICM := aMatRes[nY][04]
                       RESU->RS_ISENICM := aMatRes[nY][05]
                       RESU->RS_OUTRICM := aMatRes[nY][06]
                    MsUnLock()
                Next
             Endif

             DbSelectArea("CAB")
             DbCloseArea()
             
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return

/************************************************************************************/
/*** FGERLIV - Busca registros das Notas Fiscais e gera livro de entrada e saída. ***/
/************************************************************************************/
Static Function fGerLiv(nQtdReg)
       Local nTamLin, cLin, cCpo, nY

       DbSelectArea("LIVC")
       DbSetOrder(1)
       DbGoTop()
       ProcRegua(nQtdReg) // Numero de registros a processar
       While !Eof()
             IncProc( Iif(mv_par02 == 1, "Processando Livro de Entradas...", "Processando Livro de Saídas...")+SubStr(LIVC->LC_ENTRADA, 1, 2)+'/'+SubStr(LIVC->LC_ENTRADA, 3, 2)+'/'+StrZero(Year(dDataBase), 4) )
             /****************************************************************************************************/
             /***                    SEPARAÇÃO DAS VARIÁVEIS - REGISTRO TIPO R1 (CABEÇALHO)                    ***/
             /****************************************************************************************************/
             cLinCab := ""
             cValCon := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_VALORCO, 0)
             cBsICM1 := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_BICMS_1, 0)
             cAlICM1 := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_AICMS_1, 0)
             cImICM1 := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_VICMS_1, 0)
             cIsICM1 := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_IICMS_1, 0)
             cOuICM1 := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_OICMS_1, 0)
             cBasIPI := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_BASEIPI, 0)
             cImpIPI := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_IMPOIPI, 0)
             cIseIPI := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_ISENIPI, 0)
             cOutIPI := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_OUTRIPI, 0)
             cIPINAp := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_NAOAIPI, 0)
             cICMFon := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_VICMRET, 0)
             cDescon := Iif(Empty(LIVC->LC_F3_DCAN), LIVC->LC_BICMRET, 0)
             /****************************************************************************************************/
             /***                                GRAVAÇÃO DO REGISTRO - TIPO R1                                ***/
             /****************************************************************************************************/
             nTamLin := 596
             cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao no arquivo
             //                                                                                               | INICIO | TAMANH |
             cCpo    := PADR(LIVC->LC_TIPOREG                                 , 002) ; cLin := Stuff(cLin, 001, 002, cCpo) //TIPO REGISTRO     |    001 |     02 |
             cCpo    := PADR(LIVC->LC_ENTRADA                                 , 004) ; cLin := Stuff(cLin, 003, 004, cCpo) //DIA E MES EMISSÃO |    003 |     04 |
             cCpo    := PADR(LIVC->LC_EMISSAO                                 , 004) ; cLin := Stuff(cLin, 007, 004, cCpo) //ENTRADA E SAIDA   |    007 |     04 |
             cCpo    := PADR(LIVC->LC_DATAINT                                 , 002) ; cLin := Stuff(cLin, 011, 002, cCpo) //DATA INTEGRAÇÃO   |    011 |     02 |
             cCpo    := PADR(LIVC->LC_ESPECIE                                 , 003) ; cLin := Stuff(cLin, 013, 003, cCpo) //ESPECIE DA NOTA   |    013 |     03 |
             cCpo    := PADR(LIVC->LC_SERIENF                                 , 003) ; cLin := Stuff(cLin, 016, 003, cCpo) //SERIE DA NOTA     |    016 |     03 |
             cCpo    := PADR(LIVC->LC_DANOTAF                                 , 006) ; cLin := Stuff(cLin, 019, 006, cCpo) //DA  NOTA FISCAL   |    019 |     06 |
             cCpo    := PADR(LIVC->LC_ATNOTAF                                 , 006) ; cLin := Stuff(cLin, 025, 006, cCpo) //ATE NOTA FISCAL   |    025 |     06 |
             cCpo    := PADR(LIVC->LC_CFONFIS                                 , 005) ; cLin := Stuff(cLin, 031, 005, cCpo) //CODIGO FISCAL     |    031 |     05 |
             cCpo    := PADR(StrZero(Round((cValCon          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 036, 012, cCpo) //VALOR CONTABIL    |    036 |     12 |
             cCpo    := PADR(StrZero(Round((cBsICM1          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 048, 012, cCpo) //BASE ICMS 1       |    048 |     12 |
             cCpo    := PADR(StrZero(Round((cAlICM1          * 10000), 2), 06), 006) ; cLin := Stuff(cLin, 060, 006, cCpo) //ALIQUOTA ICMS 1   |    060 |     06 |
             cCpo    := PADR(StrZero(Round((cImICM1          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 066, 012, cCpo) //IMPOSTO ICMS 1    |    066 |     12 |
             cCpo    := PADR(StrZero(Round((cIsICM1          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 078, 012, cCpo) //ISENTOS ICMS 1    |    078 |     12 |
             cCpo    := PADR(StrZero(Round((cOuICM1          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 090, 012, cCpo) //OUTRAS ICMS 1     |    090 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_BICMS_2 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 102, 012, cCpo) //BASE ICMS 2       |    102 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_AICMS_2 * 10000), 2), 06), 006) ; cLin := Stuff(cLin, 114, 006, cCpo) //ALIQUOTA ICMS 2   |    114 |     06 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_VICMS_2 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 120, 012, cCpo) //IMPOSTO ICMS 2    |    120 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_IICMS_2 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 132, 012, cCpo) //ISENTOS ICMS 2    |    132 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_OICMS_2 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 144, 012, cCpo) //OUTRAS ICMS 2     |    144 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_BICMS_3 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 156, 012, cCpo) //BASE ICMS 3       |    156 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_AICMS_3 * 10000), 2), 06), 006) ; cLin := Stuff(cLin, 168, 006, cCpo) //ALIQUOTA ICMS 3   |    168 |     06 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_VICMS_3 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 174, 012, cCpo) //IMPOSTO ICMS 3    |    174 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_IICMS_3 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 186, 012, cCpo) //ISENTOS ICMS 3    |    186 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_OICMS_3 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 198, 012, cCpo) //OUTRAS ICMS 3     |    198 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_BICMS_4 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 210, 012, cCpo) //BASE ICMS 4       |    210 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_AICMS_4 * 10000), 2), 06), 006) ; cLin := Stuff(cLin, 222, 006, cCpo) //ALIQUOTA ICMS 4   |    222 |     06 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_VICMS_4 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 228, 012, cCpo) //IMPOSTO ICMS 4    |    228 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_IICMS_4 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 240, 012, cCpo) //ISENTOS ICMS 4    |    240 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_OICMS_4 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 252, 012, cCpo) //OUTRAS ICMS 4     |    252 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_BICMS_5 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 264, 012, cCpo) //BASE ICMS 5       |    264 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_AICMS_5 * 10000), 2), 06), 006) ; cLin := Stuff(cLin, 276, 006, cCpo) //ALIQUOTA ICMS 5   |    276 |     06 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_VICMS_5 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 282, 012, cCpo) //IMPOSTO ICMS 5    |    282 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_IICMS_5 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 294, 012, cCpo) //ISENTOS ICMS 5    |    294 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_OICMS_5 * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 306, 012, cCpo) //OUTRAS ICMS 5     |    306 |     12 |
             cCpo    := PADR(StrZero(Round((cBasIPI          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 318, 012, cCpo) //BASE DO IPI       |    318 |     12 |
             cCpo    := PADR(StrZero(Round((cImpIPI          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 330, 012, cCpo) //IMPOSTO IPI       |    330 |     12 |
             cCpo    := PADR(StrZero(Round((cIseIPI          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 342, 012, cCpo) //ISENTOS IPI       |    342 |     12 |
             cCpo    := PADR(StrZero(Round((cOutIPI          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 354, 012, cCpo) //OUTRAS IPI        |    354 |     12 |
             cCpo    := PADR(StrZero(Round((cIPINAp          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 366, 012, cCpo) //IPI NÃO APROVEIT. |    366 |     12 |
             cCpo    := PADR(StrZero(Round((cICMFon          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 378, 012, cCpo) //ICMS RETIDO FONTE |    378 |     12 |
             cCpo    := PADR(StrZero(Round((cDescon          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 390, 012, cCpo) //DESCONTO BASE S.T.|    390 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_VLRAVIS * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 402, 012, cCpo) //VALOR A VISTA     |    402 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_VLRAPRZ * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 414, 012, cCpo) //VALOR A PRAZO     |    414 |     12 |
             cCpo    := PADR(StrZero(Round((LIVC->LC_ISENPIS * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 426, 012, cCpo) //ISENTO PIS        |    426 |     12 |
             cCpo    := PADR(LIVC->LC_CONTRIB                                 , 001) ; cLin := Stuff(cLin, 438, 001, cCpo) //CONTRIBUINTE      |    438 |     01 |
             cCpo    := PADR(LIVC->LC_TIPONFC                                 , 002) ; cLin := Stuff(cLin, 439, 002, cCpo) //TIPO DA NF        |    439 |     02 |
             cCpo    := PADR(LIVC->LC_CODCONT                                 , 002) ; cLin := Stuff(cLin, 441, 002, cCpo) //COD. CONTABIL     |    441 |     02 |
             cCpo    := PADR(LIVC->LC_OBSERVA                                 , 014) ; cLin := Stuff(cLin, 443, 014, cCpo) //OBSERVAÇÃO LIVRE  |    443 |     14 |
             cCpo    := PADR(LIVC->LC_CGCCLFO                                 , 014) ; cLin := Stuff(cLin, 457, 014, cCpo) //CGC CLIENTE/FORNEC|    457 |     14 |
             cCpo    := PADR(LIVC->LC_INSCEST                                 , 016) ; cLin := Stuff(cLin, 471, 016, cCpo) //INSCRIÇÃO ESTADUAL|    471 |     16 |
             cCpo    := PADR(LIVC->LC_RAZAOSO                                 , 035) ; cLin := Stuff(cLin, 487, 035, cCpo) //RAZÃO SOCIAL      |    487 |     35 |
             cCpo    := PADR(LIVC->LC_CTACONT                                 , 018) ; cLin := Stuff(cLin, 522, 018, cCpo) //CONTA CTBL FORNEC.|    522 |     18 |
             cCpo    := PADR(LIVC->LC_UFCLIFO                                 , 002) ; cLin := Stuff(cLin, 540, 002, cCpo) //UF CLIENTE/FORNEC.|    540 |     02 |
             cCpo    := PADR(LIVC->LC_CODMUNI                                 , 004) ; cLin := Stuff(cLin, 542, 004, cCpo) //CODIGO MUNICIPIO  |    542 |     04 |
             cCpo    := PADR(LIVC->LC_VAGOR11                                 , 050) ; cLin := Stuff(cLin, 546, 050, cCpo) //VAGO R1 - 1       |    546 |     50 |
             cLinCab := cLin

             aMatDet := {}
             DbSelectArea("LIVD")
             DbSetOrder(1)
             DbGoTop()
             DbSeek(LIVC->LC_GERAKEY)
             If Found()
                nValNTr := 0.0
                While !Eof() .and. LIVC->LC_GERAKEY == LIVD->LD_GERAKEY
                      If LIVC->LC_LFISIPI $ 'T' .and. LIVD->LD_IMPOIPI == 0.0
                         nValNTr += LIVD->LD_D2_VTOT
                      Endif
                      aAdd(aMatDet, {LIVD->LD_TIPOREG, LIVD->LD_VAGOR21, LIVD->LD_CPDNCMP, LIVD->LD_DESCPRO, LIVD->LD_BASEIPI, LIVD->LD_IMPOIPI, LIVD->LD_ISENIPI, LIVD->LD_VAGOR22, LIVD->LD_D2_DZFR, LIVD->LD_ISENPIS})
                      DbSelectArea("LIVD")
                      DbSkip()
                Enddo
                If nValNtr == 0.0
                   nValNtr := LIVC->LC_OUTRIPI
                Endif
             Endif

             //Grava Linha do Cabeçalho (R1)
             If fWrite(nHdl, cLin, Len(cLinCab)) != Len(cLinCab)
                If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                   Exit
                Endif
             Endif

             /****************************************************************************************************/
             /***                                GRAVAÇÃO DO REGISTRO - TIPO R2                                ***/
             /****************************************************************************************************/
             If Len(aMatDet) > 0 //Gravação da(s) Linha(s) do Detalhe (R2)
                For nY := 1 To Len(aMatDet)
                    cBasIPI := aMatDet[nY][05]
                    cValIPI := aMatDet[nY][06]
                    cIseIPI := aMatDet[nY][07]
                    cIsePIS := aMatDet[nY][10]

                    nTamLin := 131
                    cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao no arquivo
                    //                                                                                      | INICIO | TAMANH |
                    cCpo    := PADR(aMatDet[nY][01]                                  , 002) ; cLin := Stuff(cLin, 001, 002, cCpo) //TIPO REGISTRO     |    001 |     02 |
                    cCpo    := PADR(aMatDet[nY][02]                                  , 008) ; cLin := Stuff(cLin, 003, 008, cCpo) //VAGO R2 - 1       |    003 |     08 |
                    cCpo    := PADR(aMatDet[nY][03]                                  , 010) ; cLin := Stuff(cLin, 011, 010, cCpo) //COD. NCM PRODUTO  |    011 |     10 |
                    cCpo    := PADR(aMatDet[nY][04]                                  , 025) ; cLin := Stuff(cLin, 021, 025, cCpo) //DESCRIÇÃO PRODUTO |    021 |     25 |
                    cCpo    := PADR(StrZero(Round((cBasIPI          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 046, 012, cCpo) //BASE DE IPI       |    046 |     12 |
                    cCpo    := PADR(StrZero(Round((cValIPI          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 058, 012, cCpo) //VALOR DO IPI      |    058 |     12 |
                    cCpo    := PADR(StrZero(Round((cIseIPI          * 100  ), 2), 12), 012) ; cLin := Stuff(cLin, 070, 012, cCpo) //ISENTAS IPI       |    070 |     12 |
                    cCpo    := PADR(aMatDet[nY][08]                                  , 050) ; cLin := Stuff(cLin, 082, 050, cCpo) //VAGO R2 - 2       |    082 |     50 |
                    If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
                       If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                          Exit
                       Endif
                    Endif                      
                Next
             Endif
                          
             DbSelectArea("LIVC")
             DbSkip()
       Enddo
Return


/*************************************************************************/
/*** VALPERG - Validação de perguntas                                  ***/
/*************************************************************************/
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Mes para envio              ?", "", "", "mv_ch1", "N", 02, 0, 0, "G", "Entre(1, 12, MV_PAR01)", "mv_par01", ""       , "", "", "", "", ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "02", "Tipo de arquivo             ?", "", "", "mv_ch2", "N", 01, 0, 1, "C", ""                      , "mv_par02", "Entrada", "", "", "", "", "Saída", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
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
Return