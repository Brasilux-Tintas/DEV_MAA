#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'FWLIBVERSION.CH'
#INCLUDE 'TOPCONN.ch'
 
USER FUNCTION NFCA020()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.
Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''
Local cClasse    := ''
 
If ( aParam <> NIL )
    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]
    lIsGrid    := iif(aParam[3] == "SC8DETAIL", .t., .f.)
    cClasse    := oObj:ClassName()
 
    If ( lIsGrid )
        nQtdLinhas := oObj:GetQtdLine()
        nLinha     := oObj:nLine
    EndIf
 
    If ( cIdPonto == 'MODELPOS' )
        cMsg := 'Chamada na validação total do modelo (MODELPOS).' + CRLF
        cMsg += 'ID ' + cIdModel + CRLF
         
        If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
             Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
        EndIf
 
        ElseIf ( cIdPonto == 'FORMPOS' )
            cMsg := 'Chamada na validação total do formulário (FORMPOS).' + CRLF
            cMsg += 'ID ' + cIdModel + CRLF
             
            If ( cClasse == 'FWFORMGRID' )
                cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
                cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
             
            ElseIf ( cClasse == 'FWFORMFIELD' )
                cMsg += 'É um FORMFIELD' + CRLF
            EndIf
 
            If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                Help( ,, 'Help',, 'O FORMPOS retornou .F.', 1, 0 )
            EndIf
 
             
        ElseIf ( cIdPonto == 'FORMLINEPRE' )
            If ( aParam[5] == 'DELETE' )
                cMsg := 'Chamada na pre validação da linha do formulário (FORMLINEPRE).' + CRLF
                cMsg += 'Onde esta se tentando deletar uma linha' + CRLF
                cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
                cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
                cMsg += 'ID ' + cIdModel + CRLF
             
                If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                    Help( ,, 'Help',, 'O FORMLINEPRE retornou .F.', 1, 0 )
                EndIf
 
             EndIf
 
       ElseIf ( cIdPonto == 'FORMLINEPOS' )
            cMsg := 'Chamada na validação da linha do formulário (FORMLINEPOS).' + CRLF
            cMsg += 'ID ' + cIdModel + CRLF
            cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
            cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
 
            If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                Help( ,, 'Help',, 'O FORMLINEPOS retornou .F.', 1, 0 )
            EndIf
 
        ElseIf ( cIdPonto == 'MODELCOMMITTTS' )
            ApMsgInfo('Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel )
 
        ElseIf ( cIdPonto == 'MODELCOMMITNTTS' )
            ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)
 
        ElseIf ( cIdPonto == 'FORMCOMMITTTSPOS' )
            ApMsgInfo('Chamada apos a gravação da tabela do formulário (FORMCOMMITTTSPOS).' + CRLF + 'ID ' + cIdModel)
 
        ElseIf ( cIdPonto == 'MODELCANCEL' )
            cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'
 
            If !( xRet := ApMsgYesNo( cMsg ) )
                Help( ,, 'Help',, 'O MODELCANCEL retornou .F.', 1, 0 )
            EndIf
 
        ElseIf cIdPonto == 'BUTTONBAR'
            ApMsgInfo('Adicionando Botao na Barra de Botoes (BUTTONBAR).' + CRLF + 'ID ' + cIdModel )
            xRet := { {'Salvar', 'SALVAR', { || Alert( 'Salvou' ) }, 'Este botao Salva' } }
        EndIf
 
EndIf
 
Return xRet
