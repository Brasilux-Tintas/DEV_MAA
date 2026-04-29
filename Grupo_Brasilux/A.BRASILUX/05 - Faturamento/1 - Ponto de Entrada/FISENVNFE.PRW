#include "rwmake.ch"
#include 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
 
User Function FISENVNFE()
Local aIdNfe    := PARAMIXB[1]
Local cIdsNfe   := ""
Local nX        := 0
Local cDoc      := ""
Local cSerie    := ""
Local ccLote    := ""
Local ccCliente := ""
Local ccLoja    := ""
Local cEmail    := ""
Local cNumEmp   := ""
Local cProduto  := ""
Local ccDoc     := ""
Local ccSerie   := "" 
Local cEmp      := ""
Local ccFilial  := ""
Local cEmpresa  := ""
Local cPedido   := 0
Local cTemLaudo := 0
Local cQuimicos := 0  // Jose 08/03/2024
Local xCorpos   := "" // Jose 08/03/2024
Local xEmail    := "" // Jose 08/03/2024
Local _ZPPAR0220 := GetMV( "ZP_PAR0220" ) // .T. Envia Certificado  /  .F. Não Envia Certificado  // Jose 01/03/2024

Private aAnexoss := {}


 If !_ZPPAR0220 // Jose 01/03/2024
    return // Jose 01/03/2024
 EndIf  // Jose 01/03/2024

cEmpresa := Substr(RetSqlName("SD2"),4,2) 
// jose 29/02/2024 tirar quando entrar Dissoltex  If cEmpresa <> "11"
//  If cEmpresa = "01"
  If cEmpresa <> "11"
    If Len(aIdNfe) > 0
         For nX := 1 To Len(aIdNfe)
            aAnexoss := {}
            cIdsNfe := aIdNfe[Nx] 
            cSerie := SUBSTR(cIdsNfe,1,3) // Serie NF
            cDoc   := SUBSTR(cIdsNfe,4,9) // Nº Nota
            // Consulta que localiza o nº do Pedido de Venda
            cQryAux := "SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_PEDIDO, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_CLIENTE, SD2.D2_LOJA, " + CRLF
            cQryAux += "       ZZK.ZZK_LOTE, ZZK.ZZK_PEDIDO, ZZK.ZZK_PRODUT, SUM(ZZK.ZZK_QUANT) ZZK_QUANT, " + CRLF
            cQryAux += "       QPK.QPK_LOTE, QPK.QPK_PRODUT, QPK.QPK_NUMSER, QPK.QPK_OP,  QPK.QPK_LAUDO, " + CRLF
            cQryAux += "       SA1.A1_COD, LOWER(SA1.A1_EMAIL) AS A1_EMAIL, " + CRLF
	         cQryAux += "       SC5.C5_LAUDO  " + CRLF
            cQryAux += "  FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)  " + CRLF 
            cQryAux += "       LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK)ON     " + CRLF 
	         cQryAux += "                              ZZK.D_E_L_E_T_  = ''              AND " + CRLF
            cQryAux += "                              ZZK.ZZK_FILIAL  = SD2.D2_FILIAL   AND " + CRLF
	         cQryAux += "							         ZZK.ZZK_PEDIDO  = SD2.D2_PEDIDO   AND " + CRLF
	         cQryAux += "							         ZZK.ZZK_PRODUT  = SD2.D2_COD          " + CRLF
	         cQryAux += "       LEFT OUTER JOIN "+RetSqlName("QPK")+" QPK WITH(NOLOCK)ON     " + CRLF 
	         cQryAux += "                              QPK.D_E_L_E_T_  = ''              AND " + CRLF
            cQryAux += "                              QPK.QPK_FILIAL  = SD2.D2_FILIAL   AND " + CRLF
	         cQryAux += "							         QPK.QPK_LOTE    = ZZK.ZZK_LOTE        " + CRLF
	         cQryAux += "       LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK)ON     " + CRLF   
	         cQryAux += "                              SA1.D_E_L_E_T_  = ''              AND " + CRLF 
            cQryAux += "                              SA1.A1_COD      = SD2.D2_CLIENTE  AND " + CRLF
            cQryAux += "  						            SA1.A1_LOJA     = SD2.D2_LOJA         " + CRLF
	         cQryAux += "       LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK)ON     " + CRLF     
	         cQryAux += "                                SC5.D_E_L_E_T_  = ''            AND " + CRLF
	         cQryAux += "							           SC5.C5_FILIAL   = SD2.D2_FILIAL AND " + CRLF
	         cQryAux += "							           SC5.C5_NUM      = SD2.D2_PEDIDO AND " + CRLF
	         cQryAux += "				   		           SC5.C5_LAUDO    = 'S'               " + CRLF
            cQryAux += " WHERE SD2.D_E_L_E_T_  = ''           AND     " + CRLF
            cQryAux += "       SD2.D2_DOC      = '"+cDoc+"'   AND     " + CRLF
	         cQryAux += "       SD2.D2_SERIE    = '"+cSerie+"' AND     " + CRLF
	         cQryAux += "       SD2.D2_FILIAL   = '"+xFilial("SF2")+"' " + CRLF    
            cQryAux += "GROUP BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_PEDIDO, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_CLIENTE, SD2.D2_LOJA, " + CRLF
            cQryAux += "         ZZK.ZZK_LOTE, ZZK.ZZK_PEDIDO, ZZK.ZZK_PRODUT, ZZK.ZZK_QUANT,  " + CRLF 
	         cQryAux += "         QPK.QPK_LOTE, QPK.QPK_PRODUT, QPK.QPK_OP, QPK.QPK_LAUDO, SA1.A1_COD, SA1.A1_EMAIL, QPK.QPK_NUMSER, " + CRLF
	         cQryAux += "         SC5.C5_LAUDO  " + CRLF

            IF Select("QLOTE") <> 0
               DbSelectArea("QLOTE")
               DbCloseArea()
            ENDIF

            TCQuery cQryAux New Alias "QLOTE"
            //Enquanto houver registros
            cTemLaudo = 0
            cQuimicos = 0
            xCorpos   = ""
            While !QLOTE->(EoF())
                  ccLote    := QLOTE->QPK_LOTE
                  cProduto  := QLOTE->D2_COD
                  ccDoc     := QLOTE->D2_DOC
                  ccSerie   := QLOTE->D2_SERIE
                  ccCliente := QLOTE->D2_CLIENTE
                  ccloja    := QLOTE->D2_LOJA
                  cPedido   := QLOTE->D2_PEDIDO
                  cEmail    := QLOTE->A1_EMAIL     
// 08/03/2024     cEmail    := "joseuliana@brasilux.com.br" //  Jose 08/03/2024    tirar e voltar o de cima 
                  cEmp      := Substr(RetSqlName("SD2"),4,2) 
                  ccFilial  := xFilial("SF2") 
                  cNumEmp   := cEmp + ccFilial    
                  IF  ( ((cNumEmp = "01010101") .or. (cNumEmp = "01060101")) .and. (QLOTE->C5_LAUDO = "S") .and. (QLOTE->QPK_LOTE <> '') .and. (QLOTE->QPK_LAUDO = 'A') )  
//Inibido dia 19/04/2024 entrou DIssoltex   IF  ( (cNumEmp = "01010101") .and. (QLOTE->C5_LAUDO = "S") .and. (QLOTE->QPK_LOTE <> '') .and. (QLOTE->QPK_LAUDO = 'A') )  
                      If Substr(xFilial("SF2"),1,2)== "06"
                         cEmail += "; " + "tintapo@dissoltex.com.br; fernando@dissoltex.com.br; laudo@dissoltex.com.br"  // "joseuliana@brasilux.com.br; sabrina@brasilux.com.br"   //   //     Jose 29/02/2024
                      Else
                         cEmail += "; " + "marciononis@brasilux.com.br; nataliaserafim@brasilux.com.br; qualidade@brasilux.com.br; laudo@brasilux.com.br; faturamento@brasilux.com.br"  // "joseuliana@brasilux.com.br; sabrina@brasilux.com.br" //   //    Jose 29/02/2024
                      EndIf
                      U_BRQIP050(ccLote,ccCliente,ccLoja,@aAnexoss) // Jose 18/01/2024
                      cTemLaudo = 1  // Jose 18/01/2024
//                EndIf    // Jose 18/01/2024
//                  Else
//                      IF ( (QLOTE->QPK_LOTE = '') .and. (QLOTE->C5_LAUDO = "S") )  
//                      Endif
                  Else  // Jose 08/03/2024
                      If ( ((cEmp = '01') .or. (cEmp = '06')) .and. ( QLOTE->QPK_LAUDO <> 'A' ) .and. ( QLOTE->C5_LAUDO = "S" ) .and. (QLOTE->QPK_LOTE <> '' ) )   // Jose 08/03/2024
                          xCorpos := xCorpos + " Produto: " + cProduto + " Cliente: " + ccCliente + " Loja: " + ccloja  + " Pedido: " + cPedido  + " Lote: " + QLOTE->ZZK_LOTE  + " .                            ." // Jose 08/03/2024
                          cQuimicos = 1   // Jose 08/03/2024
                      EndIf   // Jose 08/03/2024
                  Endif

                  QLOTE->(DbSkip())
            EndDo

            If cTemLaudo = 1
               cPara    := cEmail 
               cAssunto := "Laudo !! do Produto BRASILUX"   
               cCorpo   := "Certificado de Qualidade dos Produtos da Nota Fiscal....:  " + ccDoc + "          Serie....: " + ccSerie 
               zEnvMail(cPara, cAssunto, cCorpo, aAnexoss)
            EndIf

            If cQuimicos = 1  // Jose 08/03/2024
               If (cEmp = '01')
                   xEmail   := "julieli@brasilux.com.br; marcosantunes@brasilux.com.br; qualidade@brasilux.com.br; marciononis@brasilux.com.br; nataliaserafim@brasilux.com.br" // "joseuliana@brasilux.com.br; sabrina@brasilux.com.br" //   // Jose 08/03/2024   
               Else
                   xEmail   := "qualidade@brasilux.com.br; tintapo@dissoltex.com.br; fernando@dissoltex.com.br; laudo@dissoltex.com.br: faturamento@dissoltex.com.br"  // "joseuliana@brasilux.com.br; sabrina@brasilux.com.br"   //   //     Jose 29/02/2024 // "joseuliana@brasilux.com.br; sabrina@brasilux.com.br" //   // Jose 08/03/2024   
               Endif
               cPara    := xEmail   // Jose 08/03/2024
               cAssunto := "Produto com Restrições, Necessário Avaliação. "   // Jose 08/03/2024   
               cCorpo   := xCorpos   // Jose 08/03/2024
               zEnvMail(cPara, cAssunto, cCorpo)  // Jose 08/03/2024
            EndIf  // Jose 08/03/2024

            cTemLaudo = 0
            cQuimicos = 0
            QLOTE->(DbCloseArea())

         Next nX    

    Endif 

  EndIf

Return Nil

Static Function zEnvMail(cPara, cAssunto, cCorpo, aAnexoss)
    Local aArea    := GetArea()
    Local lEnvioOK := .F.
    lEnvioOK := GPEMail(cAssunto, cCorpo, cPara, aAnexoss)
    RestArea(aArea)
Return lEnvioOK


