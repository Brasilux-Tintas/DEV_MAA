#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO4     บ Autor ณ AP6 IDE            บ Data ณ  12/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function LerTanques()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Static oLeTxt
     Static oButt1
     Static oButt2
     Static oPanel
     Static oSay1L
     Static oSay2L

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Montagem da tela de processamento.                                  ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     DEFINE MSDIALOG oLeTxt TITLE "Leitura do Estoque dos Tanques" FROM 000, 000  TO 110, 340 COLORS 0, 16777215 PIXEL
            @ 004, 003 MSPANEL oPanel SIZE 164, 028 OF oLeTxt COLORS 0, 14215660 CENTERED RAISED
            @ 004, 002 SAY oSay1L PROMPT "Este programa ira ler o conteudo de um arquivo texto, conforme" SIZE 160, 007 OF oPanel COLORS 0, 16777215 PIXEL
            @ 012, 002 SAY oSay2L PROMPT "os parametros definidos pelo usuario, com os registros do arquivo" SIZE 160, 007 OF oPanel COLORS 0, 16777215 PIXEL
            DEFINE SBUTTON oButt1 FROM 037, 136 TYPE 02 OF oLeTxt ENABLE ACTION {|| oLeTxt:End() }
            DEFINE SBUTTON oButt2 FROM 037, 089 TYPE 01 OF oLeTxt ENABLE ACTION {|| OkLeTxt()    }
     ACTIVATE MSDIALOG oLeTxt CENTERED
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OKLETXT  บ Autor ณ AP6 IDE            บ Data ณ  12/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao chamada pelo botao OK na tela inicial de processamenบฑฑ
ฑฑบ          ณ to. Executa a leitura do arquivo texto.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OkLeTxt
       Local cSerFTP   := 'ftp.brasilux.com.br'
       Local nPorFTP   := 21
       Local cUseFTP   := 'viamix'
       Local cPatFTP   := '/compras/'
       Local cPasFTP   := '6d8de338sf'
       Local lConnect  := .f.
       Local cPathCOM  := '\SPOOL\COMPRAS\'
       Local cFileCOM  := 'COMPRAS.DAT'
       Local lRet := .t.
       Local cAuxArq,cMens
       Private cArqDes := "C:\TEMP\COMPRAS.DAT"
       Private cArqTxt
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Abertura do arquivo texto                                           ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If GETMV("MV_BXARQCO") == 1
          //Private cArqTxt := "\\10.1.1.160\dados\compras\COMPRAS.DAT"
         cArqTxt := "\\10.1.1.208\BRASILUX\COMPRAS\COMPRAS.DAT"
         cArqTxt := cPathCOM+cFileCOM
         if !file(cArqTxt)
            cMens := "\\10.1.1.204\compras\COMPRAS.DAT"
            cArqTxt := "\\10.1.1.208\BRASILUX\COMPRAS\COMPRAS.DAT"
            if !file(cArqTxt)
               cMens += " ou arquivo "+cArqTxt+" inexistente!"
               lRet := .f.
            endif 
         endif 
         if !lRet
            MsgAlert(cMens, "Aten็ใo" )
            lRet := .f.
         else
            lRet := __CopyFile( cArqTxt, cPathCOM+cFileCOM )
            //cPathCOM := "\\10.1.1.208\BRASILUX\COMPRAS\"
         endif 
       Else
          lConnect := FTPConnect( cSerFTP, nPorFTP, cUseFTP, cPasFTP)
          If !lConnect
             MsgAlert("Falha de conexใo ao servidor FTP...", "Aten็ใo")
             Return
          Else
             lRet := FTPDownLoad( cPathCOM+cFileCOM, cPatFTP+cFileCOM )
             If !lRet
                MsgAlert("Nใo foi possํvel copiar o arquivo do servidor FTP. O arquivo esta ausente ou em uso por outra esta็ใo!!! Por favor aguarde!!", "Aten็ใo" )
                FTPDisconnect()
                Return
             Else
                //MsgAlert("Arquivo enviado com sucesso!", "Informa็ใo")
             Endif
             lConnect := !FTPDisconnect()
             //If lConnect
             //   MsgAlert("Falha ao tentar desconectar", "Aten็ใo")
             //Endif
          Endif
       Endif
       If lRet
          Private nHdl    := fOpen(cPathCOM+cFileCOM, 0)
          Private cEOL    := "CHR(13)+CHR(10)"

          If Empty(cEOL)
             cEOL := CHR(13)+CHR(10)
          Else
             cEOL := Trim(cEOL)
             cEOL := &cEOL
          Endif

          If nHdl == -1
             MsgAlert("O arquivo de nome "+cArqDes+" nao pode ser aberto! ERRO:"+StrZero(FERROR(), 1)+"!", "Atencao!")
             Return
          Endif
       Else
          MsgAlert("Nใo foi possํvel copiar o arquivo de nome "+cArqTxt+"! ERRO:"+StrZero(FERROR(), 1)+"!", "Atencao!")       
          Return
       Endif
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Inicializa a regua de processamento                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       Processa({|| RunCont() }, "Processando...")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ RUNCONT  บ Autor ณ AP5 IDE            บ Data ณ  12/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunCont()
       Local nTamFile, nTamLin, cBuffer, nBtLidos, nY
       Private oTempTable := ""
       SetPrvt("oDlg1Tan", "oBrw1Tan", "oBtn1Tan", "oBtn2Tan")
       //ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
       //บ Lay-Out do arquivo Texto gerado:                                บ
       //ฬออออออออออออออออัออออออออัอออออออออออออออออออออออออออออออออออออออน
       //บCampo           ณ Inicio ณ Tamanho                               บ
       //วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
       //บ ??_FILIAL     ณ 01     ณ 02                                    บ
       //ศออออออออออออออออฯออออออออฯอออออออออออออออออออออออออออออออออออออออผ
       fSeek(nHdl, 0, 0)
       nTamFile := fSeek(nHdl, 0, 2)
       fSeek(nHdl, 0, 0)

       nBtLidos := 0
       lFim     := .f.
       nLinVeri := 0
       aMatEsto := {}
       nNumTan  := 0
       ProcRegua(nTamFile) // Numero de registros a processar
       While nBtLidos <= nTamFile .and. !lFim
             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Incrementa a regua                                                  ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
             IncProc()
             If nBtLidos <= nTamFile
                //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                //ณ Leitura da proxima linha do arquivo texto.                          ณ
                //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                cLinha   := U_fGets(nHdl)
                nBtLidos += Len(cLinha)
                nLinVeri += 1
                If nLinVeri == 1 //Data do Estoque
                   SET CENTURY ON
                   SET DATE FORMAT TO "mm/dd/yy"
                   dDataEstoque := cToD(cLinha)
                   SET CENTURY OFF
                   SET DATE FORMAT TO "dd/mm/yy"
         
                ElseIf nLinVeri == 2 //Linha nใo Utilizada

                ElseIf nLinVeri >= 3 .and. nLinVeri <= 32 //Produtos
                       nNumTan += 1
                       aAdd(aMatEsto, {dDataEstoque, StrZero(nNumTan, 2), Iif( SubStr(cLinha, 1, 1) $ '#', "0"+SubStr(cLinha, 2, 3), SubStr(cLinha, 1, 4) ), 0, 0, 0 } )
                ElseIf nLinVeri == 33 .or. nLinVeri == 34 .or. nLinVeri == 35//Peso Especifico
                       If nLinVeri == 33
                          nPosCol := 6
                       ElseIf nLinVeri == 34
                              nPosCol := 5
                       Else
                          nPosCol := 4
                       Endif
                       aVetorAux := {}
                       For nY := 1 To 31
                           aAdd(aVetorAux, Val(SubStr(Alltrim(cLinha), 1, At(" ", cLinha) - 1) ) )
                           cLinha := Alltrim( SubStr(cLinha, At(" ", cLinha) + 1, Len(cLinha) ) )
                       Next
                       For nY := 1 To 31
                           If nY >= 2
                              aMatEsto[nY - 1][nPosCol] := aVetorAux[nY]
                           Endif
                       Next
                       If nLinVeri >35
                          lFim := .t.
                       Endif
                ElseIf nLinVeri == 36
                      cHora := Substr(cLinha,1,8)
                      lFim := .t. 
                Endif
             Else
                lFim := .t.
             Endif
       EndDo
      
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Abro browse com resultados/valores das linhas lidas do arquivo texto. ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If Len(aMatEsto) > 0
          oDlg1Tan   := MSDialog():New( 095, 232,704, 924, "Saldo dos Tanques em Litros - "+DtoC(dDataEstoque)+" as "+(cHora)+" - MATRIZ/FAB.II", , , .F., , , , , , .T., , , .T. )

          fTbl1Tan(aMatEsto)
          DbSelectArea("TMP")
          DbSetOrder(1)
          oFontTan   := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
          oBrw1Tan   := MsSelect():New( "TMP", "", "", { {"TMP_TANQ", "", "Tanque", "99"}, {"TMP_PROD", "", "Produto", "9999"}, {"TMP_CAPA", "", "Capacidade", "@E 999,999"}, {"TMP_PESP", "", "P. Especifico", "@E 9.999999"}, {"TMP_SALL", "", "Saldo (L)", "@E 999,999"}, {"TMP_SALK", "", "Saldo (Kg)", "@E 999,999"} }, .F., , {004, 004, 280, 340}, , , oDlg1Tan )
          oSay1Tan   := TSay():New( 284, 50, {|| "ATUALIZADO EM: " +DtoC(dDataEstoque)+" AS "+(cHora)}, oDlg1Tan, , oFontTan, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 200, 012)
          oBtn1Tan   := TButton():New( 284, 251, "Confirmar", oDlg1Tan,                      , 037, 012, , , , .T., , "", , , , .F. )
          oBtn2Tan   := TButton():New( 284, 303, "Sair"     , oDlg1Tan, { || oDlg1Tan:End() }, 037, 012, , , , .T., , "", , , , .F. )

          oDlg1Tan:Activate(, , , .T.)
          DbSelectArea("TMP")
          DbCloseArea()
          oTempTable:Delete()
       Else
          MsgStop("Nใo existem dados a serem mostrados.")
       Endif
       
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ณ
       //ณ cao anterior.                                                       ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       fClose(nHdl)
       oLeTxt:End()
Return

/*ฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Function  ณ fTbl1Tan() - Cria temporario para o Alias: TMP
ฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ*/
Static Function fTbl1Tan(aMatEsto)
       Local aFds := {}
       Local nX

       aAdd( aFds , {"TMP_COMP", "C", 002, 000} )
       aAdd( aFds , {"TMP_TANQ", "C", 002, 000} )
       aAdd( aFds , {"TMP_PROD", "C", 004, 000} )
       aAdd( aFds , {"TMP_PPED", "N", 007, 000} )
       aAdd( aFds , {"TMP_CAPA", "N", 007, 000} )
       aAdd( aFds , {"TMP_PESP", "N", 008, 006} )
       aAdd( aFds , {"TMP_SALL", "N", 007, 000} )
       aAdd( aFds , {"TMP_SALK", "N", 007, 000} )

       /*
       cTmp := U_NovoArqTrab("dtc") 
       dbcreate(cTmp+".dtc", aFds, "CTREECDX")
       Use (cTmp+".dtc") Alias "TMP" VIA "CTREECDX" New Exclusive
       Index On TMP_TANQ To (cTmp)
       */
       oTempTable := FWTemporaryTable():New( "TMP" )
       oTemptable:SetFields( aFds )
       oTempTable:AddIndex( "cInd01", { "TMP_TANQ" } )
       oTempTable:Create()
       DbSelectArea( "TMP" )
       DbSetOrder(1)


       For nX := 1 To Len(aMatEsto)
           RecLock("TMP", .t.)
              TMP->TMP_TANQ := aMatEsto[nX][2]
              TMP->TMP_PROD := aMatEsto[nX][3]
              TMP->TMP_PPED := Posicione("SB1", 1, xFilial("SB1")+TMP->TMP_PROD, "B1_EMIN")
              TMP->TMP_CAPA := aMatEsto[nX][4]
              TMP->TMP_PESP := aMatEsto[nX][6]
              TMP->TMP_SALL := aMatEsto[nX][5]
              TMP->TMP_SALK := ( TMP->TMP_PESP * TMP->TMP_SALL )
           MsUnLock()
       Next
       DbSelectArea("TMP")
       DbGoTop()
       
Return
