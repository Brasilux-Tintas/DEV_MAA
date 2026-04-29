#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} MT110TOK
Grava Log de SC.
@type function Processamento
@version  1.0
@author marioantonaccio
@since 09/02/2026
@return logical, retorna oK
/*/
User Function MT110TOK()
    Local aArea := FWGetArea()  as Character
    Local lRet  := .T.          as Logical

    If ALTERA
       BRLOGSC()
    End
    FWRestArea(aArea)

Return( lRet )

/*/{Protheus.doc} BRLOGSC
Rotina que faz a verificação de alteração de campos na SC
@type function Processamento
@version  1.0
@author marioantonaccio
@since 09/02/2026
@return Character, sem retorno
/*/
Static Function BRLOGSC()

    //  Local nPosObs   := GDFieldPos("C1_OBS") as Numeric
    Local aAlterCpo := {}          as Array
    Local aArea     := FWGetArea() as Array
    Local cInstr    := " "         as Character
    Local cItem                    as Character
    Local nLinha                   as Numeric

    //Percorrendo a grid com os itens
    For nLinha := 1 To Len(aCols)

        cItem:=GDFieldGet("C1_ITEM",nLinha)

        SC1->(dbSetOrder(1))
        If SC1->(dbSeek(xFilial("SC1")+ca110Num+cItem))

            If AllTrim(Upper(SC1->C1_ORIGEM)) <> "MATA170"
                Loop
            End

            If GDDeleted(nLinha)
                AADD(aAlterCpo,{ "C1_ITEM",cItem,"Excluido" ,"X" ,nLinha ,cItem,ca110Num})
                Loop
            End

            If SC1->C1_PRODUTO  != GDFieldGet("C1_PRODUTO",nLinha)
                AADD(aAlterCpo,{ "C1_PRODUTO",SC1->C1_PRODUTO,GDFieldGet("C1_PRODUTO",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_QUANT  != GDFieldGet("C1_QUANT",nLinha)
                AADD(aAlterCpo,{ "C1_QUANT",SC1->C1_QUANT,GDFieldGet("C1_QUANT",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_UM  != GDFieldGet("C1_UM",nLinha)
                AADD(aAlterCpo,{ "C1_UM",SC1->C1_UM,GDFieldGet("C1_UM",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_SEGUM  != GDFieldGet("C1_SEGUM",nLinha)
                AADD(aAlterCpo,{ "C1_SEGUM",SC1->C1_SEGUM,GDFieldGet("C1_QUANT",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_QTSEGUM  != GDFieldGet("C1_QTSEGUM",nLinha)
                AADD(aAlterCpo,{ "C1_QTSEGUM",SC1->C1_QTSEGUM,GDFieldGet("C1_QTSEGUM",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_DATPRF  != GDFieldGet("C1_DATPRF",nLinha)
                AADD(aAlterCpo,{ "C1_DATPRF",SC1->C1_DATPRF,GDFieldGet("C1_DATPRF",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_LOCAL  != GDFieldGet("C1_LOCAL",nLinha)
                AADD(aAlterCpo,{ "C1_LOCAL",SC1->C1_LOCAL,GDFieldGet("C1_LOCAL",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_OP  != GDFieldGet("C1_OP",nLinha)
                AADD(aAlterCpo,{ "C1_OP",SC1->C1_OP,GDFieldGet("C1_OP",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If SC1->C1_CC  != GDFieldGet("C1_CC",nLinha)
                AADD(aAlterCpo,{ "C1_CC",SC1->C1_CC,GDFieldGet("C1_CC",nLinha) ,"" ,nLinha,cItem })
            EndIf

            If Upper(AllTrim(SC1->C1_OBS)) $ "SC GERADA POR PONTO DE PEDIDO."
                GDFieldPut("C1_OBS", " ", nLinha)
                AADD(aAlterCpo,{ "C1_ITEM",SC1->C1_OBS,"Cancelada Cond de SC p/ PP" ,"" ,nLinha,cItem })
            End
        Else
            AADD(aAlterCpo,{ "C1_ITEM",cItem,"Inclusao" ,"I" ,nLinha,cItem })
        End
    Next

    //Se houve alteração de linhas
    If Len(aAlterCpo) > 0
        ZAJ->(dbSetOrder(1))
        For nLinha:=1 To Len(aAlterCpo)
            RecLock("ZAJ",.T.)
            ZAJ->ZAJ_FILIAL := FWxFilial( 'ZAJ' )
            ZAJ->ZAJ_NUMERO := ca110Num
            ZAJ->ZAJ_FORNEC := aAlterCpo[nLinha][6]
            ZAJ->ZAJ_LOJA   := " "
            ZAJ->ZAJ_PROD   := GDFieldGet("C1_PRODUTO",aAlterCpo[nLinha][5])
            ZAJ->ZAJ_CAMPO  := aAlterCpo[nLinha][1]
            ZAJ->ZAJ_DE     := cValToChar(aAlterCpo[nLinha][2])
            ZAJ->ZAJ_PARA   := cValToChar(aAlterCpo[nLinha][3])
            ZAJ->ZAJ_SEQ    := aAlterCpo[nLinha][4]
            ZAJ->ZAJ_DTALT  := dDataBase
            ZAJ->ZAJ_HORA   := Time()
            ZAJ->ZAJ_USRALT := cUserName
            ZAJ->ZAJ_TIPO   := "SC"
            MsUnLock()
        Next
        cInstr:="UPDATE "+RetSQLName("SC1")+ " SET C1_ORIGEM =' ' WHERE C1_NUM='"+ca110Num+"'"
        TCSQLExec(cInstr)
    End

    FWRestArea(aArea)

Return (NIL)
