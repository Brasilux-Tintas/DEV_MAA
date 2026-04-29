/*
+------------------------------------------------------------------+
|  CONSOLIDAC190.PRW                                               |
|  Consolidador de Registros C190 Duplicados - SPED Fiscal         |
|  Autor  : Gerado via Claude / Anthropic                          |
|  Data   : 2026                                                   |
+------------------------------------------------------------------+
|  Identifica registros C190 com mesma chave                       |
|  (CST_ICMS + CFOP + ALIQ_ICMS) dentro do mesmo C100,            |
|  soma os campos de valor e remove as linhas duplicatas.          |
|                                                                  |
|  Estrutura C190:                                                 |
|  |C190|CST|CFOP|ALIQ|VL_OPR|VL_BC_ICMS|VL_ICMS|               |
|  |VL_BC_ST|VL_ICMS_ST|VL_RED_BC|VL_IPI|COD_OBS|               |
+------------------------------------------------------------------+
*/

#Include "Protheus.ch"
#Include "FWMVCDef.ch"

// ---------------------------------------------------------------------------
// Funcao principal - chamada pelo menu ou direto
// ---------------------------------------------------------------------------
User Function CONSOLC190()

    Local cArqEntrada  := ""
    Local cArqSaida    := ""
    Local aDados       := {}
    Local nRet         := 0

    // Solicita arquivo de entrada via dialogo
    cArqEntrada := cGetFile( "Arquivos TXT|*.txt|Todos|*.*", ;
                             "Selecione o arquivo SPED Fiscal", ;
                             1, GetTempPath(), .F. )

    If Empty( cArqEntrada )
        MsgInfo( "Operacao cancelada pelo usuario.", "Consolidar C190" )
        Return
    EndIf

    // Define arquivo de saida automaticamente
    cArqSaida := FWFilePath( cArqEntrada ) + ;
                 FWFileName( cArqEntrada ) + ;
                 "_consolidado.txt"

    // Confirmacao
    nRet := MsgYesNo( "Arquivo de entrada:" + CRLF + cArqEntrada + CRLF + CRLF + ;
                      "Arquivo de saida sera:" + CRLF + cArqSaida + CRLF + CRLF + ;
                      "Deseja continuar?", "Consolidar C190" )

    If !nRet
        Return
    EndIf

    // Processa
    u_ProcC190( cArqEntrada, cArqSaida )

Return

// ---------------------------------------------------------------------------
// u_ProcC190 - Processa o arquivo SPED e consolida os C190
// ---------------------------------------------------------------------------
User Function ProcC190( cEntrada, cSaida )

    Local nHdEnt       := 0         // Handle arquivo entrada
    Local nHdSai       := 0         // Handle arquivo saida
    Local cLinha       := ""
    Local aPartes      := {}
    Local cRegistro    := ""

    // Bloco corrente (linhas que nao sao C190)
    Local aBlocoAtual  := {}

    // Hash de C190 consolidados: chave = "CST|CFOP|ALIQ"
    // valor = array com os campos do C190
    Local aC190Hash    := {}        // array de arrays { cChave, aCampos }
    Local aC190Ordem   := {}        // ordem das chaves

    Local lDentroBlocoC := .F.

    // Estatisticas
    Local nTotalLinhas  := 0
    Local nDocumentos   := 0
    Local nC190Lidos    := 0
    Local nC190Removidos:= 0
    Local nC190Unicos   := 0

    Local cMsgFim      := ""

    // Abre entrada
    nHdEnt := FOpen( cEntrada, FO_READ )
    If nHdEnt < 0
        MsgStop( "Nao foi possivel abrir o arquivo: " + cEntrada, "Erro" )
        Return
    EndIf

    // Abre saida
    nHdSai := FCreate( cSaida )
    If nHdSai < 0
        FClose( nHdEnt )
        MsgStop( "Nao foi possivel criar o arquivo de saida: " + cSaida, "Erro" )
        Return
    EndIf

    // Processa linha a linha
    While !FEoF( nHdEnt )

        cLinha := u_LeLinha( nHdEnt )
        If Empty( AllTrim( cLinha ) )
            Loop
        EndIf

        nTotalLinhas++

        aPartes   := u_SplitPipe( cLinha )
        cRegistro := If( Len(aPartes) > 1, aPartes[2], "" )

        Do Case

            // ---- Novo documento ----------------------------------------
            Case cRegistro == "C100"

                If lDentroBlocoC
                    u_FlushBloco( nHdSai, @aBlocoAtual, @aC190Hash, @aC190Ordem )
                EndIf

                lDentroBlocoC := .T.
                nDocumentos++
                AAdd( aBlocoAtual, cLinha )

            // ---- Registro C190 -----------------------------------------
            Case cRegistro == "C190" .And. lDentroBlocoC

                nC190Lidos++

                // Garante ao menos 13 campos
                Do While Len( aPartes ) < 13
                    AAdd( aPartes, "" )
                EndDo

                Local cCST  := AllTrim( aPartes[3] )  // CST_ICMS
                Local cCFOP := AllTrim( aPartes[4] )  // CFOP
                Local cAliq := AllTrim( aPartes[5] )  // ALIQ_ICMS
                Local cChave := cCST + "|" + cCFOP + "|" + cAliq

                Local nPos := u_ASearchChave( aC190Hash, cChave )

                If nPos == 0
                    // Primeira ocorrencia
                    AAdd( aC190Hash,  { cChave, AClone(aPartes) } )
                    AAdd( aC190Ordem, cChave )
                    nC190Unicos++
                Else
                    // Duplicata: soma campos de valor
                    // Indices em aPartes (base 1, com vazio em [1]):
                    // [6]=VL_OPR [7]=VL_BC_ICMS [8]=VL_ICMS
                    // [9]=VL_BC_ST [10]=VL_ICMS_ST [11]=VL_RED_BC [12]=VL_IPI
                    Local aCamposExist := aC190Hash[nPos][2]
                    Local nIdx         := 0

                    For nIdx := 6 To 12
                        Local nExist := Val( StrTran( If(Len(aCamposExist)>=nIdx, aCamposExist[nIdx], "0"), ",", "." ) )
                        Local nNovo  := Val( StrTran( If(Len(aPartes)>=nIdx,      aPartes[nIdx],      "0"), ",", "." ) )
                        aCamposExist[nIdx] := u_FmtDecimal( nExist + nNovo )
                    Next nIdx

                    nC190Removidos++
                EndIf

            // ---- Encerramento do bloco C --------------------------------
            Case cRegistro == "C990"

                If lDentroBlocoC
                    u_FlushBloco( nHdSai, @aBlocoAtual, @aC190Hash, @aC190Ordem )
                    lDentroBlocoC := .F.
                EndIf
                u_GravaLinha( nHdSai, cLinha )

            // ---- Outros registros dentro do bloco C --------------------
            Case lDentroBlocoC
                AAdd( aBlocoAtual, cLinha )

            // ---- Fora do bloco C ----------------------------------------
            Otherwise
                u_GravaLinha( nHdSai, cLinha )

        EndCase

    EndDo

    // Caso arquivo termine sem C990
    If lDentroBlocoC
        u_FlushBloco( nHdSai, @aBlocoAtual, @aC190Hash, @aC190Ordem )
    EndIf

    FClose( nHdEnt )
    FClose( nHdSai )

    // Relatorio final
    cMsgFim := "Processamento concluido!" + CRLF + CRLF + ;
               "Linhas lidas            : " + cValToChar( nTotalLinhas   ) + CRLF + ;
               "Documentos (C100)       : " + cValToChar( nDocumentos    ) + CRLF + ;
               "Registros C190 lidos    : " + cValToChar( nC190Lidos     ) + CRLF + ;
               "C190 unicos mantidos    : " + cValToChar( nC190Unicos    ) + CRLF + ;
               "Duplicatas removidas    : " + cValToChar( nC190Removidos ) + CRLF + CRLF + ;
               "Arquivo gerado em:" + CRLF + cSaida

    MsgInfo( cMsgFim, "Consolidar C190 - Resultado" )

Return

// ---------------------------------------------------------------------------
// u_FlushBloco - Despeja bloco acumulado para o arquivo, inserindo C190
// ---------------------------------------------------------------------------
Static Function u_FlushBloco( nHd, aBlocoAtual, aC190Hash, aC190Ordem )

    Local nI       := 0
    Local nPosC100 := 0
    Local aC190Lin := {}
    Local cChave   := ""
    Local nPos     := 0
    Local aCampos  := {}
    Local cLinha   := ""

    // Monta linhas C190 consolidadas na ordem original
    For nI := 1 To Len( aC190Ordem )
        cChave := aC190Ordem[nI]
        nPos   := u_ASearchChave( aC190Hash, cChave )
        If nPos > 0
            aCampos := aC190Hash[nPos][2]
            cLinha  := "|" + u_JoinPipe( aCampos ) + "|"
            AAdd( aC190Lin, cLinha )
        EndIf
    Next nI

    // Localiza posicao do C100 no bloco para inserir C190 logo apos
    For nI := 1 To Len( aBlocoAtual )
        If u_GetRegistro( aBlocoAtual[nI] ) == "C100"
            nPosC100 := nI
            Exit
        EndIf
    Next nI

    // Grava: parte antes do C190, os C190 consolidados, resto do bloco
    For nI := 1 To Len( aBlocoAtual )
        u_GravaLinha( nHd, aBlocoAtual[nI] )
        If nI == nPosC100
            // Injeta C190 logo apos o C100
            Local nJ := 0
            For nJ := 1 To Len( aC190Lin )
                u_GravaLinha( nHd, aC190Lin[nJ] )
            Next nJ
        EndIf
    Next nI

    // Limpa acumuladores
    aBlocoAtual := {}
    aC190Hash   := {}
    aC190Ordem  := {}

Return

// ---------------------------------------------------------------------------
// u_GravaLinha - Grava uma linha no arquivo com CRLF
// ---------------------------------------------------------------------------
Static Function u_GravaLinha( nHd, cLinha )
    FWrite( nHd, cLinha + CRLF )
Return

// ---------------------------------------------------------------------------
// u_LeLinha - Le uma linha do arquivo (ate CRLF ou LF)
// ---------------------------------------------------------------------------
Static Function u_LeLinha( nHd )

    Local cChar  := ""
    Local cLinha := ""

    Do While !FEoF( nHd )
        cChar := FReadStr( nHd, 1 )
        If cChar == Chr(10)  // LF - fim de linha
            Exit
        ElseIf cChar == Chr(13)  // CR - ignora (CRLF)
            Loop
        EndIf
        cLinha += cChar
    EndDo

Return cLinha

// ---------------------------------------------------------------------------
// u_SplitPipe - Divide string por "|" retornando array
// ---------------------------------------------------------------------------
Static Function u_SplitPipe( cStr )

    Local aResult := {}
    Local nPos    := 0
    Local cResto  := cStr

    // Remove | inicial se houver
    If Left( cResto, 1 ) == "|"
        cResto := SubStr( cResto, 2 )
        AAdd( aResult, "" )  // campo vazio antes do primeiro |
    EndIf

    Do While .T.
        nPos := At( "|", cResto )
        If nPos == 0
            AAdd( aResult, cResto )
            Exit
        EndIf
        AAdd( aResult, Left( cResto, nPos - 1 ) )
        cResto := SubStr( cResto, nPos + 1 )
    EndDo

Return aResult

// ---------------------------------------------------------------------------
// u_JoinPipe - Une array em string separada por "|" (sem | nas pontas)
// ---------------------------------------------------------------------------
Static Function u_JoinPipe( aCampos )

    Local cResult := ""
    Local nI      := 0

    For nI := 1 To Len( aCampos )
        If nI == 1
            cResult := aCampos[nI]
        Else
            cResult += "|" + aCampos[nI]
        EndIf
    Next nI

Return cResult

// ---------------------------------------------------------------------------
// u_GetRegistro - Extrai o nome do registro de uma linha SPED
// ---------------------------------------------------------------------------
Static Function u_GetRegistro( cLinha )

    Local aPartes := u_SplitPipe( cLinha )

Return If( Len(aPartes) > 1, aPartes[2], "" )

// ---------------------------------------------------------------------------
// u_ASearchChave - Busca uma chave no array aC190Hash
// Retorna posicao ou 0 se nao encontrado
// ---------------------------------------------------------------------------
Static Function u_ASearchChave( aHash, cChave )

    Local nI := 0

    For nI := 1 To Len( aHash )
        If aHash[nI][1] == cChave
            Return nI
        EndIf
    Next nI

Return 0

// ---------------------------------------------------------------------------
// u_FmtDecimal - Formata numero para string com 2 casas decimais
// ---------------------------------------------------------------------------
Static Function u_FmtDecimal( nValor )

    Local cResult := ""

    // Arredonda para 2 casas
    nValor  := Round( nValor, 2 )
    cResult := StrZero( Int( nValor * 100 ), 1 )

    // Usa Transform para formatar com 2 decimais sem ponto de milhar
    cResult := Transform( nValor, "@E 9999999999.99" )
    cResult := AllTrim( cResult )
    // Troca ponto por virgula (padrao SPED brasileiro)
    cResult := StrTran( cResult, ".", "," )

Return cResult
