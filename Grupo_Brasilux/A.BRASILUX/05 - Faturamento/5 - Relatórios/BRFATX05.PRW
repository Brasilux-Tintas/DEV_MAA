#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATX05 º Autor ³ Luís Gustavo de S. º Data ³  04/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Demonstrativo de Resultados do faturamento.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATX05()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio  "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "     Demonstrativo de Resultados do Faturamento     "
     //Local cPict         := ""
     Local titulo        := "Demonstrativo de Resultados: "
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     Local Cabec3        := ""
     Local Cabec4        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRFATX05" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 15
     Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATX05"
     //Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATX05" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SF2"

      if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  	endif 
     u_zcfga01( 'BRFATX05' ) //LGS#2021201 - Gravação de log de utilização da rotina
     //ValPerg()
     Pergunte(cPerg,.F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     Processa({|| FATX05_1(Cabec1, Cabec2, Titulo, nLin, Cabec3, Cabec4) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATX05_1 º Autor ³                    º Data ³  04/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATX05_1(Cabec1, Cabec2, Titulo, nLin, Cabec3, Cabec4)
       Local cPul01  := "" ; Local cPul02 := ""
       Local nFol01  := 0  ; Local nFol02 := 0
       Local xUltMes := 0
       Local nZ, nA, nB
       Local aMeses  := {"          Janeiro          ", "         Fevereiro         ", "           Março           ", "           Abril           ", "           Maio            ", "           Junho           ",;
                         "           Julho           ", "          Agosto           ", "         Setembro          ", "          Outubro          ", "         Novembro          ", "         Dezembro          " }
	   Local aMatImp   := {}
	   Private aVolLin := {} 
       Private aLinha  := {} 
       Private aVolTot := {}
       Private aRecLin := {} ; Private aRecTot := {}
       Private aVolDLn := {} ; Private aVolDTt := {}
       Private aRecDLn := {} ; Private aRecDTt := {}
       Private cUm 	   := iif(mv_par06 == 1,"'L'","'K','KG'")   
	
/*
       MsAguarde({|| fMonAFI( @aLinha , @aVolLin, @aVolTot, @aRecLin, @aRecTot,;
                                        @aVolDLn, @aVolDTt, @aRecDLn, @aRecDTt ) }, "Aguarde", "Montando Matrizes...")
*/                                        

		aadd(aVolTot, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aRecTot, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
		aadd(aVolDTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aRecDTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })

       	If mv_par02 == 1
	       	MsAguarde({|| FATX05_2(@aVolLin, @aVolTot, @aRecLin, @aRecTot ) }, "Aguarde", "Buscando informações do Faturamento...")
		else
       		MsAguarde({|| FATX05_3(@aVolDLn, @aVolDTt, @aRecDLn, @aRecDTt ) }, "Aguarde", "Buscando informações de Devolução...")
  		endif 

       	fMonCab(aVolTot, aVolDTt, aMeses, @Cabec1, @Cabec2, @cPul01, @Cabec3, @Cabec4, @cPul02, @nFol01, @nFol02, @xUltMes)

       	If mv_par02 == 1
          	aadd(aMatImp, {aVolLin, aRecLin, aVolTot, aRecTot, "IM"})
          	aadd(aMatImp, {       ,        ,        ,        , "P1"})
       	Else
          	aadd(aMatImp, {aVolDLn, aRecDLn, aVolDTt, aRecDTt, "IM"})
          	aadd(aMatImp, {       ,        ,        ,        , "P1"})
       	Endif
		If nFol01 > 0
          If mv_par02 == 1
             Titulo := Alltrim("Faturamento x Linha em "+iif(mv_par06 == 1,"Litros","Kilogramas"))+' - '+Alltrim(mv_par01)+'  -  '+("Do Representante .: ")+(mv_par04)+("   Até o Representante .: ")+(mv_par05)
             nNumFol := Iif(nFol02 > 0, 2, 1)
             nImpAcu := Iif(nNumFol == 1, 1, 2)
             For nA := 1 To nNumFol
                 nColIni := Iif(nA      == 1,      2,        9)
                 nColFim := Iif(nA      == 1, Iif(xUltMes < 7, xUltMes + 1, 8), nFol02+1)
                 //nColFim := Iif(nA    == 1,      8, nFol02+1) // +1 significa a impressão dos acumulados
                 cPulLin := Iif(nA      == 1, cPul01, cPul02)
                 If nNumFol == 2 .and. nA == 2
                    nLin := 0 ; nLin := Cabec(Titulo, Cabec3, Cabec4, NomeProg, Tamanho, nTipo) ; nLin += 1
                    For nB := 1 To Len(aMatImp)
                        If aMatImp[nB][5] $ 'IM'
                           For nZ := 1 To Len(aLinha)
                               IMPX05_1(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, nZ, nA)
                               nLin += 1
                           Next
                        ElseIf aMatImp[nB][5] $ 'P1'
                               @ nLin, 000 PSAY cPulLin
                        Endif
                    Next
                    nLin += 1
                    nCol1 := 00 ; nCol2 := 14 ; nCol3 := 27
                    For nB := nColIni TO nColFim
                        @ nLin, nCol1 PSAY aVolTot[1][nB] Picture "@E 9,999,999.99"
                        @ nLin, nCol2 PSAY aRecTot[1][nB] Picture "@E 99,999,999.99"
                        @ nLin, nCol3 PSAY "|"
                        nCol1 += 28 ; nCol2 += 28 ; nCol3 += 28
                    Next
                    @ nLin, nCol1   PSAY aVolTot[1][14] Picture "@E 999,999,999.99"
                    @ nLin, nCol2+3 PSAY aRecTot[1][14] Picture "@E 999,999,999.99"
                    @ nLin, nCol3+5 PSAY "|"
                    nLin += 1
                    @ nLin, 000 PSAY cPulLin
                 Else
                    nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                    For nB := 1 To Len(aMatImp)
                        If aMatImp[nB][5] $ 'IM'
                           For nZ := 1 To Len(aLinha)
                               @ nLin, 002 PSAY aLinha[nZ][1]
                               @ nLin, 006 PSAY "|"
                               IMPX05_1(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, nZ, nA)
                               nLin += 1
                           Next
                        ElseIf aMatImp[nB][5] $ 'P1'
                               @ nLin, 000 PSAY cPulLin
                        Endif
                    Next
                    nLin += 1
                   
                    nCol1 := 08 ; nCol2 := 21 ; nCol3 := 34
                    @ nLin, 000 PSAY "TOTAL |"
                    For nB := nColIni TO nColFim
                        @ nLin, nCol1 PSAY aVolTot[1][nB] Picture "@E 9,999,999.99"
                        @ nLin, nCol2 PSAY aRecTot[1][nB] Picture "@E 99,999,999.99"
                        @ nLin, nCol3 PSAY "|"
                        nCol1 += 28 ; nCol2 += 28 ; nCol3 += 28
                    Next
                    If nA == nImpAcu
                       @ nLin, nCol1   PSAY aVolTot[1][14] Picture "@E 999,999,999.99"
                       @ nLin, nCol2+3 PSAY aRecTot[1][14] Picture "@E 999,999,999.99"
                       @ nLin, nCol3+5 PSAY "|"
                       nLin += 1
                       @ nLin, 000 PSAY cPulLin
                    Endif
                 Endif
             Next
          Else
             Titulo := Alltrim("Devolução x Linha")+' - '+Alltrim(mv_par01)
             nNumFol := Iif(nFol02 > 0, 2, 1)
             nImpAcu := Iif(nNumFol == 1, 1, 2)
             For nA := 1 To nNumFol
                 nColIni := Iif(nA      == 1,      2,        9)
                 nColFim := Iif(nA      == 1,      8, nFol02+1) // +1 significa a impressão dos acumulados
                 cPulLin := Iif(nA      == 1, cPul01, cPul02)
                 If nNumFol == 2 .and. nA == 2
                    nLin := 0 ; nLin := Cabec(Titulo, Cabec3, Cabec4, NomeProg, Tamanho, nTipo) ; nLin += 1
                    For nB := 1 To Len(aMatImp)
                        If aMatImp[nB][5] $ 'IM'
                           For nZ := 1 To Len(aLinha)
                               IMPX05_1(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, nZ, nA)
                               nLin += 1
                           Next
                        ElseIf aMatImp[nB][5] $ 'P1'
                               @ nLin, 000 PSAY cPulLin
                        Endif
                    Next
                    nLin += 1
                    nCol1 := 01 ; nCol2 := 14 ; nCol3 := 27
                    For nB := nColIni TO nColFim
                        @ nLin, nCol1 PSAY aVolDTt[1][nB] Picture "@E 9,999,999.99"
                        @ nLin, nCol2 PSAY aRecDTt[1][nB] Picture "@E 9,999,999.99"
                        @ nLin, nCol3 PSAY "|"
                        nCol1 += 28 ; nCol2 += 28 ; nCol3 += 28
                    Next
                    @ nLin, nCol1   PSAY aVolDTt[1][14] Picture "@E 999,999,999.99"
                    @ nLin, nCol2+3 PSAY aRecDTt[1][14] Picture "@E 999,999,999.99"
                    @ nLin, nCol3+5 PSAY "|"
                    nLin += 1
                    @ nLin, 000 PSAY cPulLin
                 Else
                    nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                    For nB := 1 To Len(aMatImp)
                        If aMatImp[nB][5] $ 'IM'
                           For nZ := 1 To Len(aLinha)
                               @ nLin, 002 PSAY aLinha[nZ][1]
                               @ nLin, 006 PSAY "|"
                               IMPX05_1(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, nZ, nA)
                               nLin += 1
                           Next
                        ElseIf aMatImp[nB][5] $ 'P1'
                               @ nLin, 000 PSAY cPulLin
                        Endif
                    Next
                    nLin += 1
                    nCol1 := 08 ; nCol2 := 21 ; nCol3 := 34
                    @ nLin, 000 PSAY "TOTAL |"
                    For nB := nColIni TO nColFim
                        @ nLin, nCol1 PSAY aVolDTt[1][nB] Picture "@E 9,999,999.99"
                        @ nLin, nCol2 PSAY aRecDTt[1][nB] Picture "@E 9,999,999.99"
                        @ nLin, nCol3 PSAY "|"
                        nCol1 += 28 ; nCol2 += 28 ; nCol3 += 28
                    Next
                    nLin += 1
                    @ nLin, 000 PSAY cPulLin
                 Endif
             Next
          Endif
       	Endif
       SET DEVICE TO SCREEN
       cDirOri := "C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original\"
       If !File("C:\Fechamento") //Diretório principal
          MakeDir("C:\Fechamento")
       Endif
       If !File("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))) //Diretório anual
          MakeDir("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4)))
       Endif
       If !File("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original") //Arquivos dos relatórios
          MakeDir("C:\Fechamento\"+Alltrim(StrZero(Year(dDataBase), 4))+"\Original")
       Endif

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
          __CopyFile(__RELDIR+wnrel+".##r", cDirOri+wnrel+"_"+Substr(dtos(dDataBase), 1, 6)+".##r")
       Endif

       MS_FLUSH()

Return

/************************************************************************************************/
/*** IMPX05_1 - Impressão dos dados do faturamento mensal.                                    ***/
/************************************************************************************************/
Static Function IMPX05_1(aVolLin, aRecLin, aVolTot, aRecTot, nLin, nColIni, nColFim, nZ, nA)
       Local nX
       If nA == 1
          nCol1 := 08 ; nCol2 := 21 ; nCol3 := 34
       Else                    //14
          nCol1 := 00 ; nCol2 := 14 ; nCol3 := 27
       Endif
       For nX := nColIni To nColFim
           @ nLin, nCol1 PSAY aVolLin[nZ][nX] Picture "@E 9,999,999.99"
           @ nLin, nCol2 PSAY aRecLin[nZ][nX] Picture "@E 99,999,999.99"
           @ nLin, nCol3 PSAY "|"
             nCol1 += 28 ; nCol2 += 28 ; nCol3 += 28
       Next
       If nImpAcu == nA
          @ nLin, nCol1   PSAY aVolLin[nZ][14] Picture "@E 999,999,999.99"
          @ nLin, nCol2+3 PSAY aRecLin[nZ][14] Picture "@E 999,999,999.99"
          @ nLin, nCol3+5 PSAY "|"
       Endif
Return


/******************************************************************************************************************/
/***                                        BUSCA INFORMAÇÕES DO FATURAMENTO                                    ***/
/******************************************************************************************************************/
Static Function FATX05_2(aVolLin, aVolTot, aRecLin, aRecTot)
    Local cQry1 := ""       

	cQry1 := "SELECT SUBSTRING(D2_COD,4,2) AS LINHA,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"01%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES01,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"02%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES02,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"03%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES03,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"04%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES04,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"05%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES05,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"06%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES06,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"07%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES07,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"08%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES08,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"09%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES09,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"10%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES10,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"11%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES11,"+;
	"SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"12%' THEN CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS QMES12,"+;
	"VMES01 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"01%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES02 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"02%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES03 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"03%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES04 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"04%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES05 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"05%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES06 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"06%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES07 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"07%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES08 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"08%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES09 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"09%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES10 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"10%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES11 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"11%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"+;
	"VMES12 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par01+"12%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END) "+;
	"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = D2_PEDIDO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (D2_COD = B1_COD) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "+;
	"WHERE (SD2.D_E_L_E_T_ <> '*') AND (SD2.D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND (LEN(D2_COD) = 12) " +;
	"AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND ((D2_UM IN ("+cUm+")) OR (D2_SEGUM IN ("+cUm+"))) "
	If !Empty(mv_par03)
		cQry1 += "AND (SUBSTRING(D2_COD,4,2) = '"+PADL(UPPER(ALLTRIM(MV_PAR03)),2,"0")+"') "
	Endif
	If !Empty(mv_par05)
		cQry1 += "AND (F2_VEND1 BETWEEN '"+(ALLTRIM(MV_PAR04))+"' AND '"+(ALLTRIM(MV_PAR05))+"') "		
	Endif
	cQry1 += "AND (SD2.D2_EMISSAO LIKE '"+MV_PAR01+"%') "+;
	"GROUP BY SUBSTRING(D2_COD,4,2) ORDER BY LINHA "
       
	TCQuery cQry1 ALIAS "TCQ" NEW
	nPos := 0
     DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
       		nPos++ 
			aadd(aLinha,  { TCQ->LINHA})
			aadd(aVolLin, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aRecLin, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
			aadd(aVolDLn, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aRecDLn, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })

			aVolLin[nPos][02] += TCQ->QMES01 ; aVolLin[nPos][03] += TCQ->QMES02 ; aVolLin[nPos][04] += TCQ->QMES03
			aVolLin[nPos][05] += TCQ->QMES04 ; aVolLin[nPos][06] += TCQ->QMES05 ; aVolLin[nPos][07] += TCQ->QMES06
   			aVolLin[nPos][08] += TCQ->QMES07 ; aVolLin[nPos][09] += TCQ->QMES08 ; aVolLin[nPos][10] += TCQ->QMES09
                   aVolLin[nPos][11] += TCQ->QMES10 ; aVolLin[nPos][12] += TCQ->QMES11 ; aVolLin[nPos][13] += TCQ->QMES12
                   aVolLin[nPos][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)
                   aRecLin[nPos][02] += TCQ->VMES01 ; aRecLin[nPos][03] += TCQ->VMES02 ; aRecLin[nPos][04] += TCQ->VMES03
                   aRecLin[nPos][05] += TCQ->VMES04 ; aRecLin[nPos][06] += TCQ->VMES05 ; aRecLin[nPos][07] += TCQ->VMES06
                   aRecLin[nPos][08] += TCQ->VMES07 ; aRecLin[nPos][09] += TCQ->VMES08 ; aRecLin[nPos][10] += TCQ->VMES09
                   aRecLin[nPos][11] += TCQ->VMES10 ; aRecLin[nPos][12] += TCQ->VMES11 ; aRecLin[nPos][13] += TCQ->VMES12
                   aRecLin[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)

             aRecTot[1][02] += TCQ->VMES01 ; aRecTot[1][03] += TCQ->VMES02 ; aRecTot[1][04] += TCQ->VMES03
             aRecTot[1][05] += TCQ->VMES04 ; aRecTot[1][06] += TCQ->VMES05 ; aRecTot[1][07] += TCQ->VMES06
             aRecTot[1][08] += TCQ->VMES07 ; aRecTot[1][09] += TCQ->VMES08 ; aRecTot[1][10] += TCQ->VMES09
             aRecTot[1][11] += TCQ->VMES10 ; aRecTot[1][12] += TCQ->VMES11 ; aRecTot[1][13] += TCQ->VMES12
             aRecTot[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             aVolTot[1][02] += TCQ->QMES01 ; aVolTot[1][03] += TCQ->QMES02 ; aVolTot[1][04] += TCQ->QMES03
             aVolTot[1][05] += TCQ->QMES04 ; aVolTot[1][06] += TCQ->QMES05 ; aVolTot[1][07] += TCQ->QMES06
             aVolTot[1][08] += TCQ->QMES07 ; aVolTot[1][09] += TCQ->QMES08 ; aVolTot[1][10] += TCQ->QMES09
             aVolTot[1][11] += TCQ->QMES10 ; aVolTot[1][12] += TCQ->QMES11 ; aVolTot[1][13] += TCQ->QMES12
             aVolTot[1][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)

             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return

/*****************************************************************************************************************/
/***                                        BUSCA INFORMAÇÕES DAS DEVOLUÇÕES                                   ***/
/*****************************************************************************************************************/
Static Function FATX05_3(aVolDLn, aVolDTt, aRecDLn, aRecDTt)
       Local cQry1 := ""
	cQry1 := "SELECT SUBSTRING(D1_COD,4,2) AS LINHA,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"01%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES01,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"02%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES02,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"03%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES03,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"04%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES04,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"05%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES05,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"06%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES06,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"07%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES07,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"08%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES08,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"09%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES09,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"10%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES10,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"11%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES11,"+;
	"SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"12%' THEN CASE WHEN D1_UM = 'L' THEN D1_QUANT WHEN D1_SEGUM = 'L' THEN D1_QTSEGUM WHEN D1_UM IN ('K','KG') THEN D1_QUANT/B1_PESOESP ELSE 0 END ELSE 0 END) AS QMES12,"+;
	"VMES01 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"01%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES02 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"02%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES03 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"03%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES04 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"04%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES05 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"05%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES06 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"06%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES07 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"07%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES08 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"08%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES09 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"09%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES10 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"10%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES11 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"11%' THEN D1_TOTAL ELSE 0 END),"+;
	"VMES12 = SUM(CASE WHEN D1_DTDIGIT LIKE '"+mv_par01+"12%' THEN D1_TOTAL ELSE 0 END) "+;
	"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (D1_COD = B1_COD) "+;
	"WHERE (SD1.D_E_L_E_T_ <> '*') AND (SD1.D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (LEN(D1_COD) = 12) "+;
	"AND (F4_DUPLIC <> 'N') "
	If !Empty(mv_par03)
		cQry1 += "AND (SUBSTRING(D1_COD,4,2) = '"+PADL(UPPER(ALLTRIM(MV_PAR03)),2,"0")+"') "
	Endif
	cQry1 += "AND (SD1.D1_DTDIGIT LIKE '"+MV_PAR01+"%') "+;
	"GROUP BY SUBSTRING(D1_COD,4,2) ORDER BY LINHA "

       TCQuery cQry1 ALIAS "TCQ" NEW
       
       nPos := 0
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
       		nPos++
			aadd(aLinha,  { TCQ->LINHA})
			aadd(aVolLin, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aRecLin, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
			aadd(aVolDLn, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aRecDLn, { TCQ->LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })

                   aVolDLn[nPos][02] += TCQ->QMES01 ; aVolDLn[nPos][03] += TCQ->QMES02 ; aVolDLn[nPos][04] += TCQ->QMES03
                   aVolDLn[nPos][05] += TCQ->QMES04 ; aVolDLn[nPos][06] += TCQ->QMES05 ; aVolDLn[nPos][07] += TCQ->QMES06
                   aVolDLn[nPos][08] += TCQ->QMES07 ; aVolDLn[nPos][09] += TCQ->QMES08 ; aVolDLn[nPos][10] += TCQ->QMES09
                   aVolDLn[nPos][11] += TCQ->QMES10 ; aVolDLn[nPos][12] += TCQ->QMES11 ; aVolDLn[nPos][13] += TCQ->QMES12
                   aVolDLn[nPos][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)
                   aRecDLn[nPos][02] += TCQ->VMES01 ; aRecDLn[nPos][03] += TCQ->VMES02 ; aRecDLn[nPos][04] += TCQ->VMES03
                   aRecDLn[nPos][05] += TCQ->VMES04 ; aRecDLn[nPos][06] += TCQ->VMES05 ; aRecDLn[nPos][07] += TCQ->VMES06
                   aRecDLn[nPos][08] += TCQ->VMES07 ; aRecDLn[nPos][09] += TCQ->VMES08 ; aRecDLn[nPos][10] += TCQ->VMES09
                   aRecDLn[nPos][11] += TCQ->VMES10 ; aRecDLn[nPos][12] += TCQ->VMES11 ; aRecDLn[nPos][13] += TCQ->VMES12
                   aRecDLn[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)

             aVolDTt[1][02] += TCQ->QMES01 ; aVolDTt[1][03] += TCQ->QMES02 ; aVolDTt[1][04] += TCQ->QMES03
             aVolDTt[1][05] += TCQ->QMES04 ; aVolDTt[1][06] += TCQ->QMES05 ; aVolDTt[1][07] += TCQ->QMES06
             aVolDTt[1][08] += TCQ->QMES07 ; aVolDTt[1][09] += TCQ->QMES08 ; aVolDTt[1][10] += TCQ->QMES09
             aVolDTt[1][11] += TCQ->QMES10 ; aVolDTt[1][12] += TCQ->QMES11 ; aVolDTt[1][13] += TCQ->QMES12
             aVolDTt[1][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)
             aRecDTt[1][02] += TCQ->VMES01 ; aRecDTt[1][03] += TCQ->VMES02 ; aRecDTt[1][04] += TCQ->VMES03
             aRecDTt[1][05] += TCQ->VMES04 ; aRecDTt[1][06] += TCQ->VMES05 ; aRecDTt[1][07] += TCQ->VMES06
             aRecDTt[1][08] += TCQ->VMES07 ; aRecDTt[1][09] += TCQ->VMES08 ; aRecDTt[1][10] += TCQ->VMES09
             aRecDTt[1][11] += TCQ->VMES10 ; aRecDTt[1][12] += TCQ->VMES11 ; aRecDTt[1][13] += TCQ->VMES12
             aRecDTt[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return

/******************************************************************************************************************/
/***                                        MONTA CABEÇALHO DO RELATÓRIO                                        ***/
/******************************************************************************************************************/
Static Function fMonCab(aVolTot, aVolDTt, aMeses, Cabec1, Cabec2, cPul01, Cabec3, Cabec4, cPul02, nFol01, nFol02, xUltMes)
       Local nVolZer := 0
       Local nUltMes := 0
       Local lTotMes := .t.
	   Local cUnid   := iif(mv_par06 == 1,"L","K") 
       //Local lTemFol01 := .f.
       Local lTemFol02 := .f.
       Local nY
       //aVolTot("", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) - Matriz
       //         1  2  3  4  5  6  7  8  9  0  1  2  3  4  - Posição
       //            1  2  3  4  5  6  7  8  9  0  1  2     - Mes
       If mv_par02 == 1
          For nY := 2 To 13
              If aVolTot[1][nY] <> 0
                 If nY > 8
                 	lTemFol02 := .t.
				 Endif
              Endif
              If lTotMes
                 If aVolTot[1][nY] == 0
                    //nVolZer := nY - 1 
                    //lTotMes := .f.
                 Endif
              Endif
          Next
       Else
          For nY := 2 To 13
              If lTotMes
                 If aVolDTt[1][nY] == 0
                    //nVolZer := nY - 1 
                    //lTotMes := .f.
                 Endif
              Endif
          Next
       Endif
       nUltMes := Iif(nVolZer == 0, 12, (nVolZer - 1))
       If lTemFol02
       	   nUltMes := 12
       Endif
       nFol01  := Iif(nUltMes < 7, nUltMes, Iif(nUltMes == 7, 7, 7       ))
       nFol02  := Iif(nUltMes < 7, 0      , Iif(nUltMes == 7, 1, nUltMes ))
       nFolAcu := Iif(nUltMes < 7, 1      , Iif(nUltMes == 7, 2, 2       ))
       
       /*** CABEÇALHO DA 1º FOLHA DO RELATÓRIO ***/
       If nFol01 > 0
          Cabec1 := "LINHA |" ; Cabec2 := "      |" ; cPul01 := "------+"
          For nY := 1 To nFol01
              Cabec1 += aMeses[nY] ; Cabec1 += "|" ; Cabec2 += " QTDE. ("+cUnid+")    VALOR (R$)   |" ; cPul01 += "---------------------------+"
          Next 
       Endif
       If nFolAcu == 1
          Cabec1 += "           ACUMULADO            |" ; Cabec2 += "   QTDE. ("+cUnid+")       VALOR (R$)   |" ; cPul01 += "--------------------------------+"
       Endif
       /*** CABEÇALHO DA 2º FOLHA DO RELATÓRIO ***/
       If nFol02 > 0
          For nY := 8 To (nUltMes)
              Cabec3 += aMeses[nY] ; Cabec3 += "|" ; Cabec4 += " QTDE. ("+cUnid+")    VALOR (R$)   |" ; cPul02 += "---------------------------+"
          Next 
       Endif
       If nFolAcu == 2
          Cabec3 += "           ACUMULADO            |" ; Cabec4 += "   QTDE. ("+cUnid+")       VALOR (R$)   |" ; cPul02 += "--------------------------------+"
       Endif
       //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
       //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
       //LINHA |          Janeiro          |         Fevereiro         |           Março           |           Abril           |           Maio            |           Junho           |           Julho           |
       //      |          Agosto           |         Setembro          |          Outubro          |         Novembro          |         Dezembro          |                           |
       //      | QTDE. (L)    VALOR (R$)   | QTDE. (L)    VALOR (R$)   | QTDE. (L)    VALOR (R$)   | QTDE. (L)    VALOR (R$)   | QTDE. (L)    VALOR (R$)   | QTDE. (L)    VALOR (R$)   | QTDE. (L)    VALOR (R$)   |
       //------+---------------------------+---------------------------+---------------------------+---------------------------+---------------------------+---------------------------+---------------------------+
       //  99  | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 |
       //  99  | 6,566,815.78 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 | 9,999,999.99 9,999,999.99 |
       //TOTAL |                                                                                                                                                                       |           ACUMULADO            |
       //                                                                                                                                                                                  QTDE. (L)       VALOR (R$)   |
       //                                                                                                                                                                              | 999,999,999.99  999,999,999.99 |
       //                                                                                                                                                                              |--------------------------------+
       //
       xUltMes := nUltMes
Return

/************************************************************************************************/
/*** VALPERG - Validação das perguntas para o relatório                                       ***/
/************************************************************************************************/
/* DESABILITADO RELEASE 12.1.25
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Ano                    ", "", "", "mv_ch1", "C", 04, 0, 0, "G", "", "mv_par01", ""           , "", "", "", "", ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "02", "Faturamento / Devolução", "", "", "mv_ch2", "N", 01, 0, 0, "C", "", "mv_par02", "Faturamento", "", "", "", "", "Devolução", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "03", "Linha                  ", "", "", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", ""           , "", "", "", "", ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
	   aAdd(aRegs,{cPerg, "04", "Do Representante       ", "", "", "mv_ch4", "C", 06, 0, 0, "G", "", "mv_par04", ""           , "", "", "", "", ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "05", "Até o Representante    ", "", "", "mv_ch5", "C", 06, 0, 0, "G", "", "mv_par05", ""           , "", "", "", "", ""         , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})       
	   PutSX1(cPerg, "06",  "Litro ou Kg", "Litro ou Kg", "Litro ou Kg", "mv_ch6", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par06", "Litros"       , "Litros", "Litros", "","Kilogramas", "Kilogramas","Kilogramas", "","","", "", "", ""     , "5" ,  "",  ""  , {},{},{}     ,cPerg)
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
*/
