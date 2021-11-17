#include 'rwmake.ch'
#include 'topconn.ch'

User Function VMFAT026()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Previsão de carga para VIAMIX"
     //Local cPict         := ""
     Local titulo        := "Previsão de cargas"
     Local nLin          := 80

     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "VMFAT026" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     //Private cPerg       := padr("VMFT26",Len(SX1->X1_GRUPO)," ") //LGS#20200213 - Adequação de release 12.1.25 e posteriores
     Private cPerg       := "VMFT26"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "VMFAT026" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString := "SZA"
            
     dbSelectArea("SZA")
     dbSetOrder(1)

     VldPerg()
     pergunte(cPerg,.F.)

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)
     
     RptStatus({|| RunRpt(Cabec1,Cabec2,Titulo,nLin) },Titulo)
     
Return

Static Function RunRpt(Cabec1,Cabec2,Titulo,nLin)
       Local cQry := ""
       cabec1 := "NOTA   CNPJ               DESTINATÁRIO                   CIDADE                  "
       cabec2 := "VALOR                   PESO                    VOLUME"
       Titulo := Alltrim(Titulo)+" - "+mv_par01
       cQry += "SELECT CASE WHEN SC5.C5_NOTA <> '' THEN SC5.C5_NOTA    ELSE '      '       END AS NFISCAL, "
       cQry += "       SA1.A1_CGC  AS CNPJ, "
       cQry += "       SA1.A1_NOME AS RAZAO, "
       cQry += "       CASE WHEN SA1.A1_MUNE  = '' THEN SA1.A1_MUN     ELSE SA1.A1_MUNE    END AS MUNENT, "
       cQry += "       CASE WHEN SA1.A1_ESTE  = '' THEN SA1.A1_EST     ELSE SA1.A1_ESTE    END AS ESTENT, "
       cQry += "       CASE WHEN SC5.C5_NOTA  = '' THEN 0.00           ELSE SF2.F2_VALFAT  END AS VALORF, "
       cQry += "       CASE WHEN SC5.C5_NOTA  = '' THEN SC5.C5_PBRUTO  ELSE SF2.F2_PBRUTO  END AS PBRUTO, "
       cQry += "       CASE WHEN SC5.C5_NOTA  = '' THEN SC5.C5_VOLUME1 ELSE SF2.F2_VOLUME1 END AS VOLUME, "
       cQry += "       SA4.A4_COD  AS CODI, "
       cQry += "       SA4.A4_NOME AS NOME, "
       cQry += "       SA4.A4_TEL  AS FONE "
       cQry += "FROM SZA010 SZA "
       cQry += "LEFT OUTER JOIN SZB010 SZB ON SZB.ZB_FILIAL = SZA.ZA_FILIAL  AND SZB.ZB_CODIGO = SZA.ZA_CODIGO AND SZB.D_E_L_E_T_ = '' "
       cQry += "LEFT OUTER JOIN SC5010 SC5 ON SC5.C5_FILIAL = SZA.ZA_FILIAL  AND SC5.C5_NUM    = SUBSTRING(SZB.ZB_PEDIDO,3,6) AND SC5.D_E_L_E_T_ = '' "
       cQry += "LEFT OUTER JOIN SF2010 SF2 ON SF2.F2_FILIAL = SZA.ZA_FILIAL  AND SF2.F2_PEDIDO = SUBSTRING(SZB.ZB_PEDIDO,3,6) AND SF2.D_E_L_E_T_ = '' "
       cQry += "LEFT OUTER JOIN SA1010 SA1 ON SA1.A1_COD    = SC5.C5_CLIENTE AND SA1.D_E_L_E_T_ = '' "
       cQry += "LEFT OUTER JOIN SZ7010 SZ7 ON ''            = SZ7.Z7_FILIAL  AND SA1.A1_CODCID  = SZ7.Z7_COD AND SZ7.D_E_L_E_T_ = '' "
       cQry += "LEFT OUTER JOIN SA4010 SA4 ON ''            = SA4.A4_FILIAL  AND SA4.A4_COD     = SC5.C5_REDESP AND SA4.D_E_L_E_T_ = '' "
       cQry += "WHERE SZA.D_E_L_E_T_ = '' "
       cQry += "  AND SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
       cQry += "  AND SZA.ZA_CODIGO  = '"+mv_par01+"' "
       cQry += "  AND SUBSTRING(SZB.ZB_PEDIDO,1,2) = '01' "
       cQry += "  AND SZ7.Z7_REGIAO  = '999' "
       cQry += "ORDER BY 9 "
       
       TCQuery cQry ALIAS 'TCQ' NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             If nLin > 58 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif
             cQuebra1 := TCQ->CODI
             @ nLin, 000 PSAY Repl("*",80)
               nLin += 1
             @ nLin, 000 PSAY "REDESPACHO.: "+Alltrim(cQuebra1)+"-"+Alltrim(SubStr(TCQ->NOME, 1, 30))
             @ nLin, 059 PSAY "FONE.: "+Alltrim(TCQ->FONE)
               nLin += 1
             @ nLin, 000 PSAY Repl("=",80)
               nLin += 1
             While !Eof() .and. TCQ->CODI == cQuebra1
                   @ nLin, 000 PSAY TCQ->NFISCAL
                   @ nLin, 007 PSAY TCQ->CNPJ    Picture "@R 99.999.999/9999-99"
                   @ nLIn, 026 PSAY SubStr(TCQ->RAZAO, 1, 30) 
                   @ nLin, 057 PSAY SubStr(TCQ->MUNENT, 1, 24)
                     nLin += 1
                   If TCQ->VALORF == 0
                      @ nLin, 000 PSAY PADC("NAO FAT !!",14) Picture "@!"
                   Else
                      @ nLin, 000 PSAY TCQ->VALORF Picture "@E 999,999,999.99"
                   Endif
                   @ nLin, 024 PSAY TCQ->PBRUTO Picture "@E 999,999,999.99"
                   @ nLin, 048 PSAY TCQ->VOLUME Picture "@E 999999"
                     nLin += 1
                   @ nLin, 000 PSAY Repl("-",80)
                     nLin += 1
                   If nLin > 58 // Salto de Página. Neste caso o formulario tem 55 linhas...
                      nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                      nLin += 1
                   Endif
                   DbSelectArea("TCQ")
                   DbSkip()
             Enddo
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()

       SET DEVICE TO SCREEN

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
       
Return

//0         1         2         3         4         5         6         7         8
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//*********************************************************************************
//*BRASILUX / MATRIZ                                             FOLHA..:       1 *
//*SIGA/BROMS001/v.AP7 7.10    PREVISÃO DE CARGA PARA VIAMIX     DT.REF.: 99/99/99*
//*HORA...: 99:99:99                                             EMISSAO: 99/99/99*
//*********************************************************************************
//NOTA   CNPJ               DESTINATÁRIO                   CIDADE                  
//VALOR                   PESO                    VOLUME
//*********************************************************************************
//REDESPACHO.: 999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       FONE.: XXXXXXXXXXXXXXX
//=================================================================================
//999999 99.999.999/9999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXX
//999.999.999,99          999.999.999,99          999999
//---------------------------------------------------------------------------------
//LGS#20200213 - Adequação de release 12.1.25 e posteriores
/*
Static Function VldPerg()
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       aRegs:={}
       //Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       //          01    02     03                     04  05  06        07   08  09 10 11   12  13          14         15  16  17  18  19             20  21  22  23  24   25  26  27  28  29   30  31  32  33  34   35  36  37  38     39  40  41
       AADD(aRegs,{cPerg, "01", "Bordero           ?", "", "", "mv_ch1", "C", 06, 0, 0, "G", "", "mv_par01", " "      , "", "", "", "", " "          , "", "", "", "", " ", "", "", "", "", " ", "", "", "", "", " ", "", "", "", ""   , "", "", "" })
       For i:=1 to Len(aRegs)
           If ! dbSeek(cPerg+aRegs[i,2])
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
Return*/