#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} MT120ALT
VAlida a Execução da rotina dentro do pedido de compras
@type function Telas
@version  1.0
@author marioantonaccio
@since 10/12/2025
@return logical, permite ou nao a execução da rotina
/*/
User Function MT120ALT()
    Local lExecuta := .T.

    If Paramixb[1] == 3  // Inclusao

        If SuperGetMV("BR_NINCPCM",.F.,.T.) .and. ;
                (AllTrim(FunName()) <> "MATA122" .or. AllTrim(FunName()) <> "CNTA121")
            FWAlertError("Inclusao de Pedido de Compra diretamente nao permitida!"+CRLF+CRLF+;
                "Utilize a "+"<b><u>"+" ROTINA DE COTAÇAO (NFC)"+"</u></b>","Nao Permitida")
            lExecuta:=.F.
        End

    EndIf

    If Paramixb[1] == 4  // Alteração
        If SuperGetMV("BR_ALPCLIB",.F.,.F.)
            dbSelectArea('SC7')
            If SC7->C7_TIPO == 1 .And. SC7->C7_CONAPRO == "L"
                If .NOT. FWAlertYesNo("Esse Pedido está liberado!!!" + ;
                        CRLF+CRLF+"<b><u>"+"CASO HAJA ALTERAÇÂO DE QUANTIDADE OU VALOR"+"</u></b>"+;
                        CRLF+" maior que "+cValToCHar(SuperGetMv("BR_TOLPRC",.F.,5))+" %"+;
                        CRLF+CRLF+"o mesmo retornarará para "+"<b><u>"+"NOVA LIBERACAO"+"</u></b>"+;
                        CRLF+CRLF+"Deseja continuar comn a ALTERACAO ? ", "Alerta de Alteração")
                    lExecuta:=.F.
                End
            EndIf
        End
    EndIf

Return( lExecuta )
