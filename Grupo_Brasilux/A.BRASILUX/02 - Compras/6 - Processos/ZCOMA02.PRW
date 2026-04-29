#include 'totvs.ch'
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} ZCOMA02
Leitura do arquivo de retorno com saldos dos tanques
@type function
@version  v2021.001
@author Luís Gustavo de Souza
@since 13/09/2021
@return variant, Nenhum retorno.
/*/


User Function ZCOMA02()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Static oLeTxt
     Static oButt1
     Static oButt2
     Static oPanel
     Static oSay1L
     Static oSay2L

     u_zcfga01( 'ZCOMA02' )
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Montagem da tela de processamento.                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DEFINE MSDIALOG oLeTxt TITLE "Leitura do Estoque dos Tanques" FROM 000, 000  TO 110, 340 COLORS 0, 16777215 PIXEL
            @ 004, 003 MSPANEL oPanel SIZE 164, 028 OF oLeTxt COLORS 0, 14215660 CENTERED RAISED
            @ 004, 002 SAY oSay1L PROMPT "Este programa ira ler o conteudo de um arquivo texto, conforme"    SIZE 160, 007 OF oPanel COLORS 0, 16777215 PIXEL
            @ 012, 002 SAY oSay2L PROMPT "os parametros definidos pelo usuario, com os registros do arquivo" SIZE 160, 007 OF oPanel COLORS 0, 16777215 PIXEL
            DEFINE SBUTTON oButt1 FROM 037, 136 TYPE 02 OF oLeTxt ENABLE ACTION {|| oLeTxt:End() }
            DEFINE SBUTTON oButt2 FROM 037, 089 TYPE 01 OF oLeTxt ENABLE ACTION {|| COMA01Ler()  }
     ACTIVATE MSDIALOG oLeTxt CENTERED
Return

/*/{Protheus.doc} COMA01Ler
description
@type function
@version  
@author gustavosouza
@since 22/09/2021
@return variant, return_description
/*/
Static Function COMA01Ler()

       Local   _nRet    := 0

       Private _cDirDes := "C:\Temp\"
       Private _cArqDes := "COMPRAS.DAT"
       Private _cArqTxt := GETMV( 'ZP_PAR0032' )
       Private _cExecut := " " + _cArqTxt + " " + _cDirDes
       Private _cEOL    := CHR(13) + CHR(10)
       
       If !ExistDir( _cDirDes, /*uParam2*/, .T. )
            MakeDir( _cDirDes, /*uParam2*/, .T. )
       Endif
       
       FErase( _cDirDes + _cArqDes, /*xParam*/, /*.T.*/ )
       // If FErase( _cDirDes + _cArqDes, /*xParam*/, /*.T.*/ ) == -1
       //    MessageBox( 'Falha na deleção do Arquivo ( FError' + Str( FError(), 4 ) + ' )', "Atenção", nOpc )
       // Endif

       _nRet := ShellExecute( "Open", "C:\Windows\System32\xcopy.exe", _cExecut, "C:\", 1 ) // ,0 )   esta assim voltar caso não funciona Jose 21/07/2022
       sleep(4000)
       
       If _nRet < 32
          MessageBox( 'Arquivo não copiado para diretório de leitura!', 'Atenção', 48 )
       Else
          Private _nHdl := fOpen( _cDirDes + _cArqDes, 0)

          If _nHdl == -1
             MessageBox( 'O arquivo de nome ' + _cArqDes + ' não pode ser aberto. ' + _cEol + 'ERRO: ' + StrZero( FERROR(), 1 ) , 'Atenção', 48 )
          Else
             Processa({|| COMA01Exe() }, "Processando... AGUARDE!!! " )
          Endif
       Endif
Return

Static Function COMA01Exe()
       Local oFWMsExcel
       Local oExcel
       Local cArquivo     := GetTempPath()+'TANQUES.xml'


       Local _nTamFile
       Local _nY
       Local _nX1
       Local _lFim        := .f.
       Local _nBtLidos    := 0
       Local _nLinVeri    := 0
       Local _aMatEsto    := {}
       Local _nNumTan     := 0
       Private oTempTable := ""

       SetPrvt( "oDlg1Tan", "oBrw1Tan", "oBtn1Tan", "oBtn2Tan" )
       //ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
       //º Lay-Out do arquivo Texto gerado:                                º
       //ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
       //ºCampo           ³ Inicio ³ Tamanho                               º
       //ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
       //º ??_FILIAL     ³ 01     ³ 02                                    º
       //ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
       fSeek( _nHdl, 0, 0)
       _nTamFile := fSeek( _nHdl, 0, 2 )
       fSeek( _nHdl, 0, 0 )

       ProcRegua( _nTamFile ) // Numero de registros a processar
       While _nBtLidos <= _nTamFile .and. !_lFim
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Incrementa a regua                                                  ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             IncProc()
             If _nBtLidos <= _nTamFile
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Leitura da proxima linha do arquivo texto.                          ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                cLinha   := U_fGets( _nHdl )
                _nBtLidos += Len(cLinha)
                _nLinVeri += 1
                If _nLinVeri == 1 //Data do Estoque
                   SET CENTURY ON
                   SET DATE FORMAT TO "mm/dd/yyyy"
                   dDataEstoque := cToD(cLinha)
                   SET CENTURY OFF
                   SET DATE FORMAT TO "dd/mm/yyyy"
                ElseIf _nLinVeri == 2 
                       //Linha não Utilizada
                ElseIf _nLinVeri >= 3 .and. _nLinVeri <= 32 //Produtos
                       _nNumTan += 1
                       aAdd( _aMatEsto, {dDataEstoque, StrZero( _nNumTan, 2), Iif( SubStr(cLinha, 1, 1) $ '#', "0"+SubStr(cLinha, 2, 3), SubStr(cLinha, 1, 4) ), 0, 0, 0 } )
                ElseIf _nLinVeri == 33 .or. _nLinVeri == 34 .or. _nLinVeri == 35 //Peso Especifico
                       If _nLinVeri == 33
                          nPosCol := 6
                       ElseIf _nLinVeri == 34
                              nPosCol := 5
                       Else
                          nPosCol := 4
                       Endif
                       aVetorAux := {}
                       For _nY := 1 To 31
                           aAdd(aVetorAux, Val(SubStr(Alltrim(cLinha), 1, At(" ", cLinha) - 1) ) )
                           cLinha := Alltrim( SubStr(cLinha, At(" ", cLinha) + 1, Len(cLinha) ) )
                       Next
                       For _nY := 1 To 31
                           If _nY >= 2
                              _aMatEsto[ _nY - 1 ][nPosCol] := aVetorAux[_nY]
                           Endif
                       Next
                       If _nLinVeri >35
                          _lFim := .t.
                       Endif
                ElseIf _nLinVeri == 36
                       cHora := Substr(cLinha,1,8)
                       _lFim := .t. 
                Endif
             Else
                _lFim := .t.
             Endif
       EndDo
      
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Abro browse com resultados/valores das linhas lidas do arquivo texto. ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//---------------   Jose 21/07/2022 -----------------------------------------------------

       If Len( _aMatEsto ) > 0
//    Inibido por Jose por não usar a Rotina abaixo 22/07/2022
//          fTbl1Tan( _aMatEsto )
//          DbSelectArea("TMP")
//          DbSetOrder(1)
//      até aqui Jose 22/07/2022

          //Criando o objeto que irá gerar o conteúdo do Excel
          oFWMsExcel := FWMSExcel():New()
          //Aba 01 - Teste
          oFWMsExcel:AddworkSheet("TANQUES") //Não utilizar número junto com sinal de menos. Ex.: 1-
          //Criando a Tabela
          ccabecalho := "Saldo dos Tanques em Litros                           ATUALIZADO EM..:  " + DTOC(dDataEstoque) + "    AS    "  + cHora
          oFWMsExcel:AddTable("TANQUES",ccabecalho)
          //Criando Colunas
          oFWMsExcel:AddColumn("TANQUES",ccabecalho,"TANQUE    "       ,1) //1 = Texto
          oFWMsExcel:AddColumn("TANQUES",ccabecalho,"PRODUTO     "     ,1) //1 = Texto
          oFWMsExcel:AddColumn("TANQUES",ccabecalho,"CAPACIDADE    "   ,1) //1 = Texto
          oFWMsExcel:AddColumn("TANQUES",ccabecalho,"P. ESPECIFICO    ",1) //1 = Texto
          oFWMsExcel:AddColumn("TANQUES",ccabecalho,"SALDO (L)     "   ,1) //1 = Texto
          oFWMsExcel:AddColumn("TANQUES",ccabecalho,"SALDO (KG)     "  ,1) //1 = Testo
          //Criando as Linhas... Enquanto não for fim da query
          For _nX1 := 1 To Len( _aMatEsto )
             oFWMsExcel:AddRow("TANQUES",ccabecalho,{;
             _aMatEsto[_nX1][2],;
             _aMatEsto[_nX1][3],;
             TransForm(_aMatEsto[_nX1][4], "@E 9999,999"),;
             TransForm(_aMatEsto[_nX1][6], "@E 9999.999999"),;
             TransForm(_aMatEsto[_nX1][5], "@E 9999,999"),;
             TransForm(_SALK := (_aMatEsto[_nX1][6] * _aMatEsto[_nX1][5] ), "@E 9999,999");
             })
          Next
	       //Ativando o arquivo e gerando o xml
	       oFWMsExcel:Activate()
          MsgRun("Processando, Gerando Arquivo em Excel...","Aguarde...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
   	
          oExcel := MsExcel():New() 
		    oExcel:WorkBooks:Open(cArquivo) 
		    oExcel:SetVisible(.T.)   
  		    oExcel:Destroy()   
       Else
          MsgStop("Não existem dados a serem mostrados.")

       EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
       //³ cao anterior.                                                       ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       fClose( _nHdl )
       oLeTxt:End()
Return

//  Inibido por Jose dia 22/07/2022 por Não usar esta rotina

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTbl1Tan() - Cria temporario para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*---------------------------------------------------------------------------------------------------
Static Function fTbl1Tan( _aMatEsto )
       Local _aFds := {}
       Local _nX

       aAdd( _aFds , {"TMP_COMP", "C", 002, 000} )
       aAdd( _aFds , {"TMP_TANQ", "C", 002, 000} )
       aAdd( _aFds , {"TMP_PROD", "C", 004, 000} )
       aAdd( _aFds , {"TMP_PPED", "N", 007, 000} )
       aAdd( _aFds , {"TMP_CAPA", "N", 007, 000} )
       aAdd( _aFds , {"TMP_PESP", "N", 008, 006} )
       aAdd( _aFds , {"TMP_SALL", "N", 007, 000} )
       aAdd( _aFds , {"TMP_SALK", "N", 007, 000} )

       oTempTable := FWTemporaryTable():New( "TMP" )
       oTemptable:SetFields( _aFds )
       oTempTable:AddIndex( "cInd01", { "TMP_TANQ" } )
       oTempTable:Create()
       DbSelectArea( "TMP" )
       DbSetOrder(1)

       For _nX := 1 To Len( _aMatEsto )
           RecLock("TMP", .t.)
           TMP->TMP_TANQ := _aMatEsto[_nX][2]
           TMP->TMP_PROD := _aMatEsto[_nX][3]
           TMP->TMP_PPED := Posicione( "SB1", 1, xFilial("SB1") + TMP->TMP_PROD, "B1_EMIN" )
           TMP->TMP_CAPA := _aMatEsto[_nX][4]
           TMP->TMP_PESP := _aMatEsto[_nX][6]
           TMP->TMP_SALL := _aMatEsto[_nX][5]
           TMP->TMP_SALK := ( TMP->TMP_PESP * TMP->TMP_SALL )
           MsUnLock()
       Next
       DbSelectArea("TMP")
       DbGoTop()

Return
----------------------------------------------------------------------------------------------------*/
