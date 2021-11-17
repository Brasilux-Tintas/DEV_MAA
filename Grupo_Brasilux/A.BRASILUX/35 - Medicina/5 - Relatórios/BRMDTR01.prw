#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRMDTR01 º Autor ³ Luís G. de Souza   º Data ³  13/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRMDTR01()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Funcionarios x Função x CC"
     //Local cPict         := ""
     Local titulo        := "Funcionarios x Função x CC"
     Local nLin          := 80
     Local Cabec1        := "FILIAL             MATRIC NOME                           FUNÇÃO                    CENTRO CUSTO                        ADMISSÃO"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "M"
     Private nomeprog    := "BRMDTR01" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "MDTR01"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRMDTR01" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SRA"

     DbSelectArea("SRA")
     DbSetOrder(1)
     //fMontaPerg()  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ RUNREPORTº Autor ³ Luís G. de Souza   º Data ³  13/05/09   º±±
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
       Local aInfo := {}
       cQry1 := ""
       cQry1 += "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CODFUNC, SRJ.RJ_DESC, SRA.RA_CC, SI3.I3_DESC, SRA.RA_ADMISSA "
       cQry1 += "FROM "+RetSqlName("SRA")+" SRA WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SRJ")+" SRJ WITH (NOLOCK) ON SRJ.RJ_FILIAL = '' AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SI3")+" SI3 WITH (NOLOCK) ON SI3.I3_FILIAL = '' AND SI3.I3_CUSTO = SRA.RA_CC AND SI3.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SRA.D_E_L_E_T_ = '' "
       cQry1 += "   AND SRA.RA_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry1 += "   AND SRA.RA_CC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQry1 += "   AND SRA.RA_MAT BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
       cQry1 += "   AND SRA.RA_CODFUNC BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
       cQry1 += "   AND SRA.RA_SITFOLH NOT IN('D') "
       cQry1 += "   AND SRA.RA_CATFUNC NOT IN('A', 'P') "
       cQry1 += "ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "
       TCQUERY cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       SetRegua(50)
       While !EOF()
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica o cancelamento pelo usuario...                             ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

             If lAbortPrint
                @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Impressao do cabecalho do relatorio. . .                            ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

             If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
             Endif
             aInfo := {}
             fInfo(@aInfo, TCQ->RA_FILIAL)

             @ nLin,000 PSAY TCQ->RA_FILIAL
             @ nLin,003 PSAY Alltrim(aInfo[1])
             @ nLin,019 PSAY TCQ->RA_MAT
             @ nLin,026 PSAY TCQ->RA_NOME
             @ nLin,057 PSAY TCQ->RA_CODFUNC
             @ nLin,062 PSAY TCQ->RJ_DESC
             @ nLin,083 PSAY TCQ->RA_CC
             @ nLin,093 PSAY TCQ->I3_DESC
             @ nLin,119 PSAY DTOC(STOD(TCQ->RA_ADMISSA))

             nLin += 1 //Avanca a linha de impressao                                                      
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
             //FILIAL             MATRIC NOME                           FUNÇÃO                    CENTRO CUSTO                        ADMISSÃO
             //99 XXXXXXXXXXXXXXX 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9999 XXXXXXXXXXXXXXXXXXXX 999999999 XXXXXXXXXXXXXXXXXXXXXXXXX 99/99/9999
             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("SRA")
       SET DEVICE TO SCREEN

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Se impressao em disco, chama o gerenciador de impressao...          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
Return

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function fMontaPerg()
       Local aArea := GetArea()
       Local aHelp := {}

       aAdd(aHelp, { {"Informe o numero da filial." }, {"Inform the branch  number."}, {"Informe el numero de la sucursal." }})
       aAdd(aHelp, { {"Informe o Cento de Custo."   }, {"Inform the Cost Center."   }, {"Infome el Centro Costo."           }})
       aAdd(aHelp, { {"Informe a matricula."        }, {"Inform the registration."  }, {"Infome el matricula."              }})	
       aAdd(aHelp, { {"Informe a função."           }, {"               "           }, {"                 "                 }})
       cPerg := PADR(cPerg,10)
       PutSx1(cPerg, "01", "Filial de          ?", "¨De Sucursal    ?", "From Branch        ?", "mv_ch1", "C", 02, 0, 0, "G", "NaoVazio"  , "SM0", "", "", "mv_par01", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[1][1], aHelp[1][2], aHelp[1][3])
       PutSx1(cPerg, "02", "Filial ate         ?", "¨A Sucursal     ?", "To Branch          ?", "mv_ch2", "C", 02, 0, 0, "G", "NaoVazio"  , "SM0", "", "", "mv_par02", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[1][1], aHelp[1][2], aHelp[1][3])
       PutSx1(cPerg, "03", "Centro de Custo de ?", "¨De Centro Costo?", "From Cost Center   ?", "mv_ch3", "C", 09, 0, 0, "G", "NaoVazio"  , "SI3", "", "", "mv_par03", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[2][1], aHelp[2][2], aHelp[2][3])
       PutSx1(cPerg, "04", "Centro de Custo ate?", "¨A Centro Costo ?", "To Cost Center     ?", "mv_ch4", "C", 09, 0, 0, "G", "NaoVazio"  , "SI3", "", "", "mv_par04", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[2][1], aHelp[2][2], aHelp[2][3])
       PutSx1(cPerg, "05", "Matricula de       ?", "¨De Matricula   ?", "From Registration  ?", "mv_ch5", "C", 06, 0, 0, "G", "NaoVazio"  , "SRA", "", "", "mv_par05", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[3][1], aHelp[3][2], aHelp[3][3])
       PutSx1(cPerg, "06", "Matricula ate      ?", "¨A Matricula    ?", "To Registration    ?", "mv_ch6", "C", 06, 0, 0, "G", "NaoVazio"  , "SRA", "", "", "mv_par06", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[3][1], aHelp[3][2], aHelp[3][3])
       PutSx1(cPerg, "07", "Função de          ?", "¨De Matricula   ?", "From Registration  ?", "mv_ch7", "C", 04, 0, 0, "G", "NaoVazio"  , "SRJ", "", "", "mv_par07", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[3][1], aHelp[3][2], aHelp[3][3])
       PutSx1(cPerg, "08", "Função ate         ?", "¨A Matricula    ?", "To Registration    ?", "mv_ch8", "C", 04, 0, 0, "G", "NaoVazio"  , "SRJ", "", "", "mv_par08", " ", " ", " ", "", "", "", "", "", "", "", "", "", "", "", "", " ", aHelp[4][1], aHelp[4][2], aHelp[4][3])
Return*/