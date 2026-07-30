#include "Rwmake.ch"

User Function SPEDPROD()
    Local cAlias     := Iif(Len(paramixb) >= 1, paramixb[1], '')
   // Local cRegspd    := Iif(Len(paramixb) >= 2, paramixb[2], '')
  //  Local cUnid      := Iif(Len(paramixb) >= 3, paramixb[3], '')
    Local aProd      := {}
    Local lFTProduto := .F.
    Local lB1Cod     := .F.
    Local lCodItem   := .F.
    Local lD2Cod     := .F.
    Local lCF8Item   := .F.
    Local aArea:=FWGetArea()
    Local cArmazem:=" " as character
    Local cProd:=" "    
    Local cEmpFil:=" "
    Local lOkSB5:=.F.

    Do Case
        //Verifica se o campo FT_PRODUTO existe no alias
        Case (cAlias)->(FieldPos('FT_PRODUTO')) > 0
            cEmpFil:=(cAlias)->FT_FILIAL
            cProd:=(cAlias)->FT_PRODUTO

            If  (cAlias)->FT_TIPOMOV == "E"
                SD1->(dbSetOrder(1))
                If  SD1->(dbSeek(cEmpFil+(cAlias)->FT_NFISCAL+(cAlias)->FT_SERIE+(cAlias)->FT_CLIEFOR+(cAlias)->FT_LOJA+(cAlias)->FT_PRODUTO))
                    cArmazem:=SD1->D1_LOCAL
                End
            End
            If  (cAlias)->FT_TIPOMOV == "S"
                SD2->(dbSetOrder(3))
                If  SD2->(dbSeek(cEmpFil+(cAlias)->FT_NFISCAL+(cAlias)->FT_SERIE+(cAlias)->FT_CLIEFOR+(cAlias)->FT_LOJA+(cAlias)->FT_PRODUTO+(cAlias)->FT_ITEM))
                    cArmazem:=SD2->D2_LOCAL
                End
            Else
                cArmazem:=Space(02)
            End
            lFTProduto := .T.
           
            //Verifica se o campo B1_COD existe no alias
        Case (cAlias)->(FieldPos('B1_COD')) > 0
            lB1Cod := .T.
            cProduto:=(cAlias)->B1_COD
            cEmpFil:=(cAlias)->B1_FILIAL
            //Verifica se o campo COD_ITEM existe no alias
        Case (cAlias)->(FieldPos('COD_ITEM')) > 0
            lCodItem := .T.
            //Verifica se o campo D2_COD existe no alias
        Case (cAlias)->(FieldPos('D2_COD')) > 0
            lD2Cod := .T.
            cProduto:=(cAlias)->D2_COD
            cArmazem:=(cAlias)->D2_LOCAL
            cEmpFil:=(cAlias)->D2_FILIAL
            //Verifica se o campo CF8_ITEM existe no alias
        Case (cAlias)->(FieldPos('CF8_ITEM')) > 0
            lCF8Item := .T.
        Case (cAlias)->(FieldPos('D1_COD')) > 0
            lD2Cod := .T.
            cProduto:=(cAlias)->D1_COD
            cArmazem:=(cAlias)->D1_LOCAL
            cEmpFil:=(cAlias)->D1_FILIAL
    EndCase

    If cFilAnt == "010101"
        If cArmazem $ "G1/G3/AF/A3"
            AADD(aProd," ")
        End
    ElseIf cFilAnt == "010106"
        If cArmazem $ "AF/A3"
            AADD(aProd," ")
        End
    ElseIf cFilAnt == "010108"
        If cArmazem $ "G1/G3"
            AADD(aProd," ")
        End
    Else
        SB1->(dbSetOrder(1))
        If SB1->(dbSeek(cEmpFil+cProduto))
            SB5->(dbSetOrder(1))
            lOkSB5:=(SB5->(dbSeek(SB1->B1_FILIAL+SB1->B1_COD)))
             
            aadd(aProd, SB1->B1_COD) // aProd[1] - Código do Produto(campo padrão B1_COD )
            aadd(aProd, SB1->B1_DESC) // aProd[2] - Descrição do produto(campo padrão B1_DESC)
            aadd(aProd, If(lOkSB5,SB5->B5_2CODBAR,SB1->B1_CODBAR)) // aProd[3] - Código de barras(campo padrão B1_CODBAR)
            aadd(aProd, SB1->B1_CODANT) // aProd[4] - Código Anterior(campo padrão B1_CODANT)
            aadd(aProd, SB1->B1_UM) // aProd[5] - Unidade de medida(campo padrão B1_UM)
            aadd(aProd, Substr(Tabela("02", SB1->B1_TIPO, .F.),1,2)) // aProd[6] - Tipo do Item
            aadd(aProd, SB1->B1_POSIPI) // aProd[7] - Código de NCM(campo padrão B1_POSIPI)
            aadd(aProd, SB1->B1_EX_NCM) // aProd[8] - Exceção da NCM(campo padrão B1_EX_NCM)
            aadd(aProd, Substr(SB1->B1_POSIPI,1,2)) // aProd[9] - Código do gênero do item (2 primeiros caracteres do NCM obs.:
            //            (se for um item de serviço o código do genero é 00))(campo padrão B1_POSIPI)
            aadd(aProd, SB1->B1_CODISS) // aProd[10] - Código de ISS(campo padrão B1_CODISS)
            aadd(aProd, SB1->B1_PCIM) // aProd[11] - Alíquota de ICMS(campo padrão B1_PICM)
            aadd(aProd, SB1->B1_CEST) // aProd[12] - CEST - Código Especificador da Substituição Tributária(campo padrão B1_CEST)
        End
    End
    FwRestArea(aArea)
Return (aProd)


