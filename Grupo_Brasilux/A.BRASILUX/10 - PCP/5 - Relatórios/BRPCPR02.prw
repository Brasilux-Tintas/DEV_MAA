#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPR02 º Autor ³ Cleber O. Dominguesº Data ³  23/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Produção em Litros por Embalagem.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
14/01/08 - GUSTAVO - Re-modelado antigo programa BRPCP004
14/01/08 - GUSTAVO - Ajuste na query do programa
/*/
User Function BRPCPR02()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Produção em Litros x Embalagem"
     //Local cPict         := ""
     Local titulo        := "PRODUÇÃO EM LITROS X EMBALAGEM"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := "Produto         Descricao                     Volume(Litros)"
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRPCPR02" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "PCPR02"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRPCPR02" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SD3"

     DbSelectArea("SD3")
     DbSetOrder(1)

     //ValidPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif
     SetDefault(aReturn, cString)
     If nLastKey == 27
        Return
     Endif
     nTipo := If(aReturn[4] == 1, 15, 18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. PROCESSA monta janela com a regua de processamento.  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Processa({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  14/01/08   º±±
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
       Local cQry1 := ""
       Local cQry2 := ""
       Local cQry3 := ""
       Local nSoma := 0.0
       Cabec1      := "PRODUÇÃO DE "+dtoc(mv_par01) +" ATÉ "+dtoc(mv_par02)
       If !Empty(mv_par04)
          cCabec1 += "(TURNO "+mv_par04+")"
       Endif

       cQry1 += "SELECT SD3.D3_COD, SUM(SD3.D3_QUANT) AS D3_QUANT, SUM(SD3.D3_QUANT * SZ5.Z5_VOLUME) AS VOLUME "
       cQry2 += "SELECT COUNT(*) AS QTDREG "
       cQry3 += "FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) "
       cQry3 += "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON SZ5.Z5_FILIAL = '' AND SZ5.Z5_EMB = SUBSTRING(SD3.D3_COD, 11, 2) AND SZ5.D_E_L_E_T_ = '' " 
       cQry3 += "WHERE SD3.D3_FILIAL   = '"+xFilial("SD3")+"' 
       cQry3 += "  AND LEN(SD3.D3_COD) = 12 "
       cQry3 += "  AND SUBSTRING(SD3.D3_COD, 11, 2) <> '00' "
       cQry3 += "  AND SD3.D3_TM       = '010' "
       cQry3 += "  AND SD3.D3_ESTORNO <> 'S' "
       If !Empty(mv_par04)
          cQry3 += "  AND SD3.D3_TURNO = '"+mv_par04+"' "
       Endif
       cQry3 += "  AND SD3.D_E_L_E_T_ <> '*' "
       cQry3 += "  AND SD3.D3_EMISSAO BETWEEN '"+DTOS(mv_Par01)+"' AND '"+DTOS(mv_Par02)+"' "
       cQry1 += cQry3
       cQry2 += cQry3
       cQry1 += "GROUP BY SD3.D3_COD "
       cQry1 += "ORDER BY SD3.D3_COD "
       TCQuery cQry2 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ ProcRegua -> Indica quantos registros serao processados para a regua³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       ProcRegua(TCQ->QTDREG)
       DbSelectArea("TCQ")
       DbCloseArea()

       TCQuery cQry1 ALIAS "TCQ" NEW
       /*** 1º ARQUIVO TEMPORÁRIO + INDICES PARA UTILIZAÇÃO ***/
       aArqSin := {}
       aAdd( aArqSin, { "PRODUTO"  , "C", 10, 0 } )
       aAdd( aArqSin, { "DESCRICAO", "C", 30, 0 } )
       aAdd( aArqSin, { "VOLUME"   , "N", 13, 2 } )
       aAdd( aArqSin, { "VOLINV"   , "C", 13, 0 } )
       cArqSin := CriaTrab(aArqSin,.t.)
       DbUseArea(.t., __LocalDrive, cArqSin, cArqSin, .f., .f.)       

       cKey1 := "PRODUTO"
       cKey2 := "VOLINV"
       cInd1 := cArqSin+"1"
       cInd2 := cArqSin+"2"
       DbCreateIndex(cInd1, cKey1, {||cKey1 })
       DbCreateIndex(cInd2, cKey2, {||cKey2 })
       DbClearIndex()
       DbSetIndex(cInd1)
       DbSetIndex(cInd2)
       DbSetOrder(1)

       If mv_par05 == 1
          /*** 2º ARQUIVO TEMPORÁRIO + INDICES PARA UTILIZAÇÃO ***/
          aArqAna := {}
          aAdd( aArqAna, { "PRODUTO", "C", 10, 0 } )
          aAdd( aArqAna, { "CODIGO" , "C", 15, 0 } )
          aAdd( aArqAna, { "QUANT"  , "N", 10, 0 } )
          aAdd( aArqAna, { "LOCPAD" , "C", 2, 0 } )
          cArqAna := CriaTrab(aArqAna,.t.)
          DbUseArea(.t., __LocalDrive, cArqAna, cArqAna, .f., .f.)       

          cKey1 := "PRODUTO+CODIGO" //Iif(mv_par03 == 1, "VOLINV", "PRODUTO")
          cInd1 := cArqAna+"1"
          DbCreateIndex(cInd1, cKey1, {||cKey1 })
          DbClearIndex()
          DbSetIndex(cInd1)
          DbSetOrder(1)          
       Endif

       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica o cancelamento pelo usuario...                             ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             IncProc("Aguarde, criando arquivos de trabalho...")
             If lAbortPrint
                Exit
             Endif
             cProduto := SubStr(TCQ->D3_COD, 1, 10)
             /*** ADICIONA DADOS NO ARQUIVO SINTÉTICO ***/
             DbSelectArea(cArqSin)
             DbSetOrder(1)
             DbSeek(cProduto)
             If !Found()
                RecLock(cArqSin, .t.)
                   PRODUTO   := cProduto
                   DESCRICAO := Posicione("SB1", 1, xFilial("SB1")+cProduto+"00", "B1_DESC")
                   VOLUME    := TCQ->VOLUME
                   VOLINV    := INVERTE(StrZero(TCQ->VOLUME, 13))
             Else
                RecLock(cArqSin, .f.)
                   VOLUME    += TCQ->VOLUME
                   VOLINV    := INVERTE(StrZero(VOLUME, 13))
             Endif
             nSoma += TCQ->VOLUME
             MsUnLock()

             /*** ADICIONA DADOS NO ARQUIVO ANALITICO ***/
             If mv_par05 == 1
                DbSelectArea(cArqAna)
                DbSetOrder(1)
                DbSeek(cProduto+TCQ->D3_COD, .t.)
                If !Found()
                   RecLock(cArqAna, .t.)
                      PRODUTO   := cProduto
                      CODIGO    := TCQ->D3_COD
                      QUANT     := TCQ->D3_QUANT
                      LOCPAD	:= Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_LOCPAD")
                Else
                   RecLock(cArqAna, .f.)
                      PRODUTO   := cProduto
                      QUANT     += TCQ->D3_QUANT
                      LOCPAD	:= Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_LOCPAD")
                      
                Endif
                MsUnLock()
             Endif

             DbSelectArea("TCQ")
             DbSkip()
       Enddo      
       DbSelectArea("TCQ")
       DbCloseArea()

       DbSelectArea(cArqSin)
       If mv_par03 == 1
          DbSetOrder(2)
       Else
          DbSetOrder(1)
       Endif
       DbGoTop()
       While !Eof()
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica o cancelamento pelo usuario...                             ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lAbortPrint
                @ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif
             @ nLin, 000 PSAY (cArqSin)->PRODUTO   Picture "@R XX 99.99.999"
             @ nLin, 016 PSAY (cArqSin)->DESCRICAO Picture "@!"
             @ nLin, 048 PSAY (cArqSin)->VOLUME    Picture "@E 9,999,999.99"
               nLin := nLin + 1 // Avanca a linha de impressao
             If mv_par05 == 1
                If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                   nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                   nLin += 1
                Endif
                DbSelectArea(cArqAna)
                DbSetOrder(1)
                DbSeek((cArqSin)->PRODUTO, .t.)
                If Found()
                   While !Eof() .and. (cArqAna)->PRODUTO == (cArqSin)->PRODUTO
                         @ nLin, 016 PSAY (cArqAna)->CODIGO Picture "@R! XXX99.99.999-99"
                         @ nLin, 032 PSAY (cArqAna)->QUANT  Picture "@E 9,999,999"  
                         @ nLin, 063 PSAY Alltrim(Posicione("SB2", 1, xFilial("SB2")+Posicione("SB1",1,xFilial("SB1")+(cArqAna)->CODIGO,"B1_COD")+(cArqAna)->LOCPAD, "B2_LOCALIZ"))
                         nLin += 1
                         DbSelectArea(cArqAna)
                         DbSkip()
                   Enddo
                Endif
             Endif
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Impressao do cabecalho do relatorio. . .                            ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             DbSelectArea(cArqSin)
             dbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
       @ nLin,000 PSAY __PrtFatLine() //Replicate("_", 80)
       nLin++
       @ nLin,048 PSAY nSoma picture "@E 9,999,999.99"

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

Return

//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Data Emissao de         ?", "", "", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01", ""          , "", "", "", "", ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "02", "Data Emissao Ate'       ?", "", "", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", ""          , "", "", "", "", ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "03", "Ordem                   ?", "", "", "mv_ch3", "N", 01, 0, 2, "C", "", "mv_par03", "VOL DECRES", "", "", "", "", "COD PROD" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "04", "Turno(Em brco p/ todos) ?", "", "", "mv_ch4", "C", 03, 0, 0, "G", "", "mv_par04", ""          , "", "", "", "", ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "05", "Analitico/Sintético     ?", "", "", "mv_ch5", "N", 01, 0, 2, "C", "", "mv_par05", "Analitico ", "", "", "", "", "Sintético", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

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