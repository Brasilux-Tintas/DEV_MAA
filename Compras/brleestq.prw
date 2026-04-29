#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BRLEESTQ
Rotina de Importação de Dados em CSV/TXT de campos de Estoque no SB1 - Tela de introdução
@type function Processamento
@version  1.0
@author marioantonaccio
@since 27/10/2025
@return character, sem retorno
/*/
User Function BRLEESTQ()

    LOCAL aArrSay := {}
    LOCAL aArrBut := {}
    Local lExeFun:=.F.

    AADD(aArrSay, 'Esta rotina tem o objetivo de importar e preencher os campos ')
    AADD(aArrSay, 'de acordo com o arquivo enviado em formato texto.')
    AADD(aArrSay, ' ')
    AADD(aArrSay, 'Para visualizar quais campos devem ser incluidos no arquivo TXT/CSV clique no botao ')
    AADD(aArrSay,'<b><u>'+'VISUALIZAR'+'</b></u>')
    
    AADD(aArrBut, {1, .T., {|| lExeFun := .T., FechaBatch()}})
    AADD(aArrBut, {2, .T., {|| lExeFun := .F., FechaBatch()}})
    AADD(aArrBut, {15, .T., {|| TELATXT()}})

    FormBatch('Importacão Dados Estoque', aArrSay, aArrBut)

    If lExeFun
        BRLEEST01()
    End

Return Nil

/*/{Protheus.doc} BRLEEST01
Rotina de Seleçao de arquivo CSV/TXT para importação
@type function Processamento
@version  1.00
@author marioantonaccio
@since 27/10/2025
@return character, sem retorno
/*/
Static Function BRLEEST01()
    Local cArquivo

    //Chamando o cGetFile para pegar um arquivo txt ou xml, mostrando o servidor
    cArquivo := cGetFile( 'Arquivo CSV|*.csv| Arquivo TXT|*.txt| Todos Arquivos|*.*',; //[ cMascara],
        'Selecao do Arquivo a Importar',;                  //[ cTitulo],
        0,;                                      //[ nMascpadrao],
        'C:\',;                                  //[ cDirinicial],
        .F.,;                                    //[ lSalvar],
        GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes],
        .T.)                                     //[ lArvore]

    If .NOT. Empty(cArquivo)
        // MsgInfo('O arquivo escolhido é '+cArquivo, 'Atenção')
        MsAguarde({|| BRLEEST02(@cArquivo) },"Aguarde","Verificando as informações do arquivo..")
    else
        FWAlertInfo("Não foi Selecionado Arquivo!!", "Nao Selecionado")
    End
Return

/*/{Protheus.doc} BRLEEST02
Verificação e analise do arquivo de importação de TXT/CSV para importação
@type function Processamento
@version  1.0
@author marioantonaccio
@since 27/10/2025
@param cArq, character, nome do arquivo selecionado para importação
@return character, sem retorno
/*/

Static FUnction BRLEEST02(cArq)
    Local aErro     := {}
    Local aLinha    := {}
    Local aLinhaOk  := {}
    Local cCodigo
    Local cLinAtu
    Local cLinAtu1
    Local cLinAtu2
    Local cLinha
    Local cMsg      := ""
    Local l24       := .T. // indicador elemntos na linha - mantido 23 por causa arquivo inicial/compatibilidade
    Local nLinCabec := 0
    Local nQtdBlq   := 0
    Local nQtdLin   := 0
    Local nQtdNE    := 0
    Local oFile

    AADD(aErro,{"Filial   ","Codigo ","Descrição ","Erro"})

    oFile := FWFileReader():New(cArq)

    If .NOT. oFile:Open()
        FWAlertError("Problema em abrir o arquivo: " + cArq, "Erro Leitura Arquivo")
        Return
    Else

        //Se não for fim do arquivo
        If .NOT. (oFile:EoF())

            //Enquanto houver linhas a serem lidas
            While (oFile:HasLine())

                //Buscando o texto da linha atual
                cLinha := oFile:GetLine()

                cLinAtu2:=StrTran(cLinha,";","; ") //Equaliza tamanho da linha para 8 ou 24 posições
                cLinAtu1:=StrTran(cLinAtu2,".","") // Retira os pontos de milhar dos numeros
                cLinAtu :=StrTran(cLinAtu1,",",".") //troca as virgulas de decimais por ponto - padrao BD

                aLinha:={}
                aLinha:=StrTokArr2( cLinAtu,";")
                //(*) Campos de Informações atuais no arquivo
                //(**) Campos Importantes para essa funcao
                //(***) Versão reduzida
                //[01] Filial(**)(***)
                //[02] Tipo
                //[03] Codigo (**)(***)
                //[04] Descricao
                //[05] Unidade
                //[06] Local Padrao
                //[07] Grupo
                //[08] Ponto Pedido (*)
                //[09] Lote Economico (*)
                //[10] Lote Minimo (*)
                //[11] Prod. Import
                //[12] Ativo
                //[13] Bloqueado(*)
                //[14] Dias Estoque Segurança
                //[15] Lead Time(**)(***)
                //[16] Consumo Diário (6m)
                //[17] Consumo Diário (12m)
                //[18] Estoque Segurança (**)(***)
                //[19] PP Criado(**)(***)
                //[20] Estoque Máximo(**)(***)
                //[21] Pedido Min
                //[22] Pedido Max
                //[23] Lote Economico(**)(***)
                //[24] Entra MRP(**)(***)
                //[25] Grupo
                nQtdLin++

                If Len(aLinha) <> 25
                    l24:=.F.
                End

                //Linha de cabeçalho
                If  "Filial" $ AllTrim(aLinha[01] )
                    nLinCabec++
                    Loop
                End

                //Pega o coidgo conforme tamanhho da matriz
                cCodigo:=AllTrim(aLinha[If(l24,03,02)])

                //Verifica Produto
                //Se Existe
                SB1->(dbSetOrder(1))
                If SB1->(dbSeek(AllTrim(aLinha[01])+cCodigo))
                    //Se estiver bloqueado, nao vai atualizar -  ignora a matriz
                    If SB1->B1_MSBLQL =="1"
                        nQtdBlq++
                        Loop
                    End
                Else
                    AADD(aErro,{aLinha[01],cCodigo,If(l24,Substr(Alltrim(aLinha[04]),1,30),"Sem Descricao"),"Nao Encontrado"})
                    nQtdNE++
                    Loop
                End

                AADD(aLinhaOK,{;
                    AllTrim(aLinha[01]),;
                    cCodigo,;
                    Val(aLinha[If(l24,15,03)]),;
                    Val(aLinha[If(l24,18,04)]),;
                    Val(aLinha[If(l24,19,05)]),;
                    Val(aLinha[If(l24,20,06)]),;
                    Val(aLinha[If(l24,23,07)]),;
                    aLinha[If(l24,24," ")],;
                    Val(aLinha[If(l24,08,05)])})
            EndDo
        EndIf

        //Fecha o arquivo e finaliza o processamento
        oFile:Close()

        cMsg := "Linhas Processadas: "+cValToChar(nQtdLin)+CRLF+;
            "Produtos Bloqueados: "+cValToChar(nQtdBlq)+CRLF+;
            "Produtos Nao Encontrados: "+cValToChar(nQtdNE)+CRLF+;
            If(nLinCabec>0,"Linhas de Cabecalho: "+cValToChar(nLinCabec),)+CRLF+;
            "Linhas Aptas a Processar: "+cValToChar(Len(aLinhaOk))+CRLF+CRLF+;
            "<b>"+"Continua a Atualização?"+"</b>"

        If FWAlertYesNo(cMsg, "Resumo Processamento")
            Processa({|| BRLEEST03(@aLinhaOk,@aErro)})
        End

    EndIf
Return NIL

/*/{Protheus.doc} BRLEEST03
Atualização dos registros da SB1
@type function processamento
@version  1.0
@author marioantonaccio
@since 27/10/2025
@param aLinhas, array, array com os dados a serem atualizados
@param aErro, array, array contendo os erros de produto
@return character, sem retorno
/*/
Static Function BRLEEST03(aLinhas,aErro)
    Local nI
    Local nZ
    Local cMsgErro:=""

    ProcRegua(Len(aLinhas))

    For nI:=1 to Len(aLinhas)
        IncProc("Atualizando produto " + aLinhas[nI][2]+" da FIlial "+aLinhas[nI][1]+"...")
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(aLinhas[nI][1]+aLinhas[nI][2]))

        If SOFTLOCK("SB1") //varifica se pode travar o registro
            //Trava o registro para atualizações
            RecLock('SB1', .F.)
            SB1->B1_PE      :=If(aLinhas[nI][3]>0,aLinhas[nI][3],SB1->B1_PE)   //LeadTime
            SB1->B1_ESTSEG  :=If(aLinhas[nI][4]>0,aLinhas[nI][4],SB1->B1_ESTSEG) // Estoque seguranca
            SB1->B1_EMIN    :=If(aLinhas[nI][5]>0,aLinhas[nI][5],If( aLinhas[nI][9] == 0,0,SB1->B1_EMIN)) //PONTO PEDIDO/estoque Minimo
            SB1->B1_EMAX    :=If(aLinhas[nI][6]>0,aLinhas[nI][6],SB1->B1_EMAX) //Estoque maximo
            SB1->B1_LE      :=If(aLinhas[nI][7]>0,aLinhas[nI][7],SB1->B1_LE) //Lote econnomico
            SB1->B1_MRP     :=If(.NOT. Empty(aLinhas[nI][8]),Upper(Substr(AllTrim(aLinhas[nI][8]),1,1)),SB1->B1_MRP) // Entra MRP
            MsUnLock()
        End
    Next
 
    If Len(aErro) > 1

        If FWAlertNoYes("Existem Erros na Importação."+CRLF+"Deseja Visualizar? ", "Erros Importação")
            For nI:=1 To Len(aErro)
                If nI==1
                    cMsgErro+="<b>"
                End
                For nZ:=1 To Len(aErro[1])
                    cMsgErro+=aErro[nI][nZ]+" "
                Next    
                If nI==1
                    cMsgErro+="</b>"
                End               
                cMsgErro+=CRLF
            Next
            FWAlertInfo(cMsgErro, "Informação de Erros")
        End    
    End
 
    FWAlertSuccess("Produtos Atualizados com Sucesso!!", "Processo Finalizado")

Return Nil

/*/{Protheus.doc} TELATXT
Tela informativa dos campos do CSV/TXT que deem ser gerados apra importação
@type function Tela
@version  1.00
@author marioantonaccio
@since 27/10/2025
@return character, sem retorno
/*/
Static Function TELATXT()
Local cMsg

cMsg:="<u>"+"Formatação do CSV/TXT para importação"+"</u>"+CRLF+CRLF
cMsg+="Campo 01 : "+"<b>"+"FILIAL"+"</b>"+CRLF+CRLF
cMsg+="Campo 02 : "+"<b>"+"CODIGO PRODUTO"+"</b>"+CRLF+CRLF
cMsg+="Campo 03 : "+"<b>"+"PRAZO DE ENTREGA DO FORNECEDOR (LEAD TIME)"+"</b>"+CRLF+CRLF
cMsg+="Campo 04 : "+"<b>"+"ESTOQUE DE SEGURANÇA"+"</b>"+CRLF+CRLF
cMsg+="Campo 05 : "+"<b>"+"ESTOQUE MINIMO (PONTO DE PEDIDO)"+"</b>"+CRLF+CRLF
cMsg+="Campo 06 : "+"<b>"+"ESTOQUE MAXIMO"+"</b>"+CRLF+CRLF
cMsg+="Campo 07 : "+"<b>"+"LOTE ECONOMICO FORNECEDOR"+"</b>"+CRLF+CRLF
cMsg+="Campo 08 : "+"<b>"+"ENTRA MRP? (S)IM (N)AO "+"</b>"+CRLF+CRLF

FWAlertInfo(cMsg, "Formatação do CSV")

Return NIL
