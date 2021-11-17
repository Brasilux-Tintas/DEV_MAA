#include "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFART16 º Autor ³ AP6 IDE            º Data ³  17/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Consulta de Pedidos Liberados.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR16(cTipRel)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2         := "de acordo com os parametros informados pelo usuario."
     Local cDesc3         := "Consulta Pedidos Liberados"
     //Local cPict          := ""
     Local titulo         := "Consulta Pedidos Liberados"
     Local nLin           := 80
     Local Cabec1         := "PEDIDO CLIENTE-NOME                                    IMP PED.PROGR. EMISSAO    LIB.CRED.  DIAS ESP. EST. B.PED. B.DES."
     Local Cabec2         := ""
     //Local imprime        := .T.
     Local aOrd 		  := {}
     Private lEnd         := .F.
     Private lAbortPrint  := .F.
     Private CbTxt        := ""
     Private limite       := 132
     Private tamanho      := "M"
     Private nomeprog     := "NOME" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo        := 18
     Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey     := 0
     Private cPerg        := "XXXXXX"
     Private cbcont       := 00
     Private CONTFL       := 01
     Private m_pag        := 01
     Private wnrel        := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString      := "SC9"

     DbSelectArea("SC9")
     DbSetOrder(1)
     pergunte(cPerg, .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel := SetPrint(cString, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)
     If nLastKey == 27
        Return
     Endif
     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif
     nTipo := If(aReturn[4]==1, 15, 18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  17/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
       //Local nOrdem

       DbSelectArea("TMPCON")
       DbGoTop()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ SETREGUA -> Indica quantos registros serao processados para a regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       SetRegua(RecCount())

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
       //³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
       //³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
       //³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
       //³                                                                     ³
       //³ dbSeek(xFilial())                                                   ³
       //³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ O tratamento dos parametros deve ser feito dentro da logica do seu  ³
       //³ relatorio. Geralmente a chave principal e a filial (isto vale prin- ³
       //³ cipalmente se o arquivo for um arquivo padrao). Posiciona-se o pri- ³
       //³ meiro registro pela filial + pela chave secundaria (codigo por exem ³
       //³ plo), e processa enquanto estes valores estiverem dentro dos parame ³
       //³ tros definidos. Suponha por exemplo o uso de dois parametros:       ³
       //³ mv_par01 -> Indica o codigo inicial a processar                     ³
       //³ mv_par02 -> Indica o codigo final a processar                       ³
       //³                                                                     ³
       //³ dbSeek(xFilial()+mv_par01,.T.) // Posiciona no 1o.reg. satisfatorio ³
       //³ While !EOF() .And. xFilial() == A1_FILIAL .And. A1_COD <= mv_par02  ³
       //³                                                                     ³
       //³ Assim o processamento ocorrera enquanto o codigo do registro posicio³
       //³ nado for menor ou igual ao parametro mv_par02, que indica o codigo  ³
       //³ limite para o processamento. Caso existam outros parametros a serem ³
       //³ checados, isto deve ser feito dentro da estrutura de laço (WHILE):  ³
       //³                                                                     ³
       //³ mv_par01 -> Indica o codigo inicial a processar                     ³
       //³ mv_par02 -> Indica o codigo final a processar                       ³
       //³ mv_par03 -> Considera qual estado?                                  ³
       //³                                                                     ³
       //³ dbSeek(xFilial()+mv_par01,.T.) // Posiciona no 1o.reg. satisfatorio ³
       //³ While !EOF() .And. xFilial() == A1_FILIAL .And. A1_COD <= mv_par02  ³
       //³                                                                     ³
       //³     If A1_EST <> mv_par03                                           ³
       //³         dbSkip()                                                    ³
       //³         Loop                                                        ³
       //³     Endif                                                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       DbGoTop()
       While !EOF()
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
                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin := 8
             Endif
             //0         1         2         3         4         5         6         7         8         9         10        11
             //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
             //PEDIDO CLIENTE-NOME                                    IMP PED.PROGR. EMISSAO    LIB.CRED.  DIAS ESP. EST. B.PED. B.DES.
             //999999 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXX 99/99/9999 99/99/9999 99/99/9999 9999 9999 9999 999999 999999
             @nLin,000 PSAY TMPCON->PEDI
             @nLin,007 PSAY TMPCON->CODC
             @nLin,013 PSAY '-'+TMPCON->NOME
             @nLin,055 PSAY Iif(TMPCON->FLAG $ 'S', 'SIM', 'NÂO')
             @nLin,059 PSAY DTOC(TMPCON->PEDP)
             @nLin,070 PSAY DTOC(TMPCON->EMIS)
             @nLin,081 PSAY DTOC(TMPCON->LIBC)
             @nLin,092 PSAY TransForm(TMPCON->DIAS, "@E 9999")
             @nLin,097 PSAY TransForm(TMPCON->ESPE, "@E 9999")
             @nLin,102 PSAY TransForm(TMPCON->ESTO, "@E 9999")
             @nLin,107 PSAY TMPCON->BORP
             @nLin,114 PSAY TMPCON->BORD
             
             nLin := nLin + 1 // Avanca a linha de impressao
             dbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
       DbSelectArea("TMPCON")
       DbGoTop()
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