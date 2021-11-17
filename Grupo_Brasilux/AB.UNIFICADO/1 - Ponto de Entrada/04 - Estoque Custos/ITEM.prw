#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include 'parmtype.ch'
/*/{Protheus.doc} ITEM
//TODO Pontos de entrada MVC da rotina MATA010.
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author 
@since   /  /    
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ITEM()//Nome o ID do Modelo de Dados (Model) ou Nome da rotina
     Local aParam     := PARAMIXB
     Local xRet       := .T.
     Local oObj       := ''
     Local cIdPonto   := ''
     Local cIdModel   := ''
     Local lIsGrid    := .F.
     Local nLinha     := 0
     Local nQtdLinhas := 0
     Local cMsg       := ''
     Local _cAlias    := Alias()
     Local aAreaAnt   := u_PegaArea({"SB1"})
   Local _cGrpEmp := ALLTRIM(FWGrpCompany())

do case 
case  _cGrpEmp == '01' //Empresas do grupo BRASILUX
        If aParam <> NIL
           oObj     := aParam[1]
           cIdPonto := aParam[2]
           cIdModel := aParam[3]
           lIsGrid  := ( Len( aParam ) > 3 )

           If cIdPonto == 'MODELPOS'
              /*cMsg := 'Chamada na validação total do modelo.' + CRLF
              cMsg += 'ID ' + cIdModel + CRLF
              xRet := ApMsgYesNo( cMsg + 'Continua ?' ) */
           ElseIf cIdPonto == 'MODELCOMMITTTS'
           /*
                  IF INCLUI
                     xRet := U_MT010INC()
                     U_VoltaArea(aAreaAnt)
                     IF !EMPTY(_cAlias)
                        DbSelectArea(_cAlias)
                     ENDIF
                  ENDIF
                  IF ALTERA
                     xRet := U_MT010ALT()
                     U_VoltaArea(aAreaAnt)
                     IF !EMPTY(_cAlias)
                        DbSelectArea(_cAlias)
                     ENDIF
                  ENDIF
*/
                  //IF (cCadastro <> NIL) .AND. (SUBSTR(cCadastro,len(cCadastro)-6,7) == "EXCLUIR")
                  IF oObj:nOperation == 5
                     U_MTA010E()
                     U_VoltaArea(aAreaAnt)
                     IF !EMPTY(_cAlias)
                        DbSelectArea(_cAlias)
                     ENDIF
                  ENDIF
            ElseIf cIdPonto == 'MODELPOS'
                  IF INCLUI
                     xRet := U_MT010INC()
                     U_VoltaArea(aAreaAnt)
                     IF !EMPTY(_cAlias)
                        DbSelectArea(_cAlias)
                     ENDIF
                  ENDIF
                  IF ALTERA
                     xRet := U_MT010ALT()
                     U_VoltaArea(aAreaAnt)
                     IF !EMPTY(_cAlias)
                        DbSelectArea(_cAlias)
                     ENDIF
                  ENDIF

                  /*ElseIf cIdPonto == 'FORMLINEPRE'
                         If aParam[5] == 'DELETE'
                            cMsg := 'Chamada na pre validação da linha do formulário. ' + CRLF
                            cMsg += 'Onde esta se tentando deletar a linha' + CRLF
                            cMsg += 'ID ' + cIdModel + CRLF
                            cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
                            cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
                            xRet := ApMsgYesNo( cMsg + 'Continua ?' )
                         EndIf
                  ElseIf cIdPonto == 'FORMPOS'
                         cMsg := 'Chamada na validação total do formulário.' + CRLF
                         cMsg += 'ID ' + cIdModel + CRLF
                         If lIsGrid
                            cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
                            cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
                         Else
                            cMsg += 'É um FORMFIELD' + CRLF
                         EndIf
                         xRet := ApMsgYesNo( cMsg + 'Continua ?' )
                  ElseIf cIdPonto == 'FORMLINEPOS'
                         cMsg := 'Chamada na validação da linha do formulário.' + CRLF
                         cMsg += 'ID ' + cIdModel + CRLF
                         cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
                         cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
                         xRet := ApMsgYesNo( cMsg + 'Continua ?' )
                  ElseIf cIdPonto == 'MODELCOMMITTTS'
                         //ApMsgInfo('Chamada apos a gravação total do modelo e dentro da transação.')
                         IF EMPTY(ALLTRIM(M->B1_POSIPI))
                            MsgBox("Preencha o NCM!", "Atenção", "STOP")
                            xRet := .f.
                         endif
                  ElseIf cIdPonto == 'MODELCOMMITNTTS'
                         ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação.')
                  ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
                         ApMsgInfo('Chamada apos a gravação da tabela do formulário.')
                  ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
                         ApMsgInfo('Chamada apos a gravação da tabela do formulário.')
                  ElseIf cIdPonto == 'MODELCANCEL'
                         cMsg := 'Deseja Realmente Sair ?'
                         xRet := ApMsgYesNo( cMsg )
                  ElseIf cIdPonto == 'BUTTONBAR'
                         xRet := { {'Confirmar', 'CONFIRMAR', { || u_TESTEX() } } }
                  */
           EndIf
        EndIf
case _cGrpEmp == "11"
        If aParam <> NIL
           oObj       := aParam[1]
           cIdPonto   := aParam[2]
           cIdModel   := aParam[3]
           lIsGrid    := ( Len( aParam ) > 3 )

           If cIdPonto == 'FORMLINEPOS'
              If oObj:isInserted()
                 If SUPERGETMV("CF_ATIVARP", .F. , .F.)
                    u_CHROTP03()
                 Endif
                 //MsgAlert("Linha Inserida.")
              Endif
           Endif
        ElseIf SUPERGETMV("CF_ATIVARP", .F. , .F.)
            u_CHROTP03()
        Endif
endcase 
Return xRet
