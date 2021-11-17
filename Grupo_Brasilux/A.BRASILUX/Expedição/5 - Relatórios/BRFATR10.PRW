#INCLUDE "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR10 º Autor ³ Luís G. de Souza   º Data ³  31/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão dos endereços da expedição                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR10()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Status dos Endereços"
     //Local cPict         := ""
     Local titulo        := "Status dos Endereços"
     Local nLin          := 80
     Local Cabec1        := "ENDEREÇO DESCRIÇÃO                       BORDERO  PEDIDO  STATUS"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR10" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 15
     Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR10"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR10" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SBE"

     DbSelectArea("SBE")
     DbSetOrder(1)
     //fVldPer()  //LGS#20200212 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     Processa({|| FATR10_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR10_1 º Autor ³ Luís G. de Souza   º Data ³  31/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR10_1(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       
       DbSelectArea(cString)
       DbSetOrder(1)

       ProcRegua(RecCount())

       DbGoTop()
       While !EOF()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             If !Empty(mv_par01)
                If !SBE->BE_BORDERO == MV_PAR01
                   DbSelectArea("SBE")
                   DbSkip()
                   Loop
                Endif
             Else
                If mv_par02 == 1
                   If !SBE->BE_STATUS $ '2'
                      DbSelectArea("SBE")
                      DbSkip()
                      Loop
                   Endif
                Endif
             Endif
             If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif
             //0         1         2         3         4         5         6         7         8
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789
             //ENDEREÇO        DESCRIÇÃO                       BORDERO  PEDIDO  STATUS
             //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999   999999  XXXXXXXXXX
             //                                                          OCUPADO
             //                                                          DESOCUPADO
             //                                                          BLOQUEADO
             @ nLin, 000 PSAY Alltrim(SBE->BE_LOCALIZ)
             @ nLin, 016 PSAY Alltrim(SBE->BE_DESCRIC)
             @ nLin, 048 PSAY SBE->BE_BORDERO
             @ nLin, 057 PSAY SBE->BE_PEDIDO
             @ nLin, 065 PSAY Iif(SBE->BE_STATUS $ '1', 'DESOCUPADO', Iif(SBE->BE_STATUS $ '2', 'OCUPADO', 'BLOQUEADO'))
             nLin += 1 // Avanca a linha de impressao
             DbSelectArea("SBE")
             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo

       SET DEVICE TO SCREEN

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()
Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200212 - Adequação de release 12.1.25 e posteriores
/*Static Function fVldPer()
       PutSX1("FATR10    ", "01", "Bordero          ", "", "", "mv_ch1", "C"  , 6, 0, 0, "G" , " "   , "SZF", " "    , " "  , "mv_par01", " "        , " "     , " "     , " "   , " "        , " "     , " "     , " "  , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil     , Nil     , Nil     , "FATR10" )
       PutSX1("FATR10    ", "02", "Somente Ocupados ", "", "", "mv_ch2", "N"  , 1, 0, 0, "C", " ", " ", " ", " ", "mv_par02", "Sim" , " ", " ", " ", "Não" , " ", " ", ""       , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR10" )
Return*/