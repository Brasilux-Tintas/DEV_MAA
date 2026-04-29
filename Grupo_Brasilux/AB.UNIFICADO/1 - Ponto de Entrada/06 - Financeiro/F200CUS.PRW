#include "totvs.ch"
#include "fileio.ch"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SF1100I  บAutor  Roberto Velasco      บ Data ณ 28/06/2022  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de entrada na Retorno Cnab a receber                 บฑฑ
ฑฑบDescricao ณ Atualiza SE1 com chave pix retornado pelo banco - tp.reg 3 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function F200CUS()

    private  cPrefixo  := ''
    private  cTitulo   := ''
    private  cParcela  := ''
    private  cvariav   := ''

    // Para Bradesco
    private  Id00   := '00020126970014br.gov.bcb.pix2575' // fixo
    
    private  Id26   := '' // Arquivo retorno Bradesco linha 29 at้ 104 qrpix.bradesco.com.br/qr/v2/cobv/766-e64dc0e08c-ecbb22a68446a2795426fe99e6b
    private  Id52   := '52040000' // fixo
    private  Id53   := '5303986' // fixo
    private  Id58   := '5802BR'
    private  Id59   := '5903PIX' // nome do beneficiario
    //private  Id60   := 'PIX6006Cidade'
    private  Id60   := '6009Sao Paulo'
    
    private  Id62   := '62070503***6304' //fixo
    private  Id63   := '' // Calculado

    
    cBuffer  := paramixb


    IF SubStr(cBuffer,1,1) $ "1"

        //L๊ os valores do arquivo Retorno

        cPrefixo     :=   Substr(cBuffer, 38, 03)
        cTitulo      :=   Substr(cBuffer, 41, 06)  + space(03)
        cParcela     :=   Substr(cBuffer, 47, 01)

        setThreadValue("cChave", (cPrefixo+cTitulo+cParcela))

    else

        /* Pix Itau */
        IF SubStr(cBuffer,1,1) $ "3"

            cPix := Substr(cBuffer, 02, 390)

            cvariav := getThreadValue("cChave")

            If  type("cvariav")   <>  'U'

                SE1->(DbSetOrder(1)) //E1_FILIAL+E1_FORNECE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO   //posicionando primeira parcela
                IF SE1->(DbSeek(Xfilial('SE1')+cvariav))

                    SE1->(Reclock("SE1"))
                    SE1->E1_XPIX  := cPix
                    SE1->(Msunlock())

                Endif    

 
            Endif
        Endif

        /* Pix Bradesco */
        IF SubStr(cBuffer,1,1) $ "4"

            Id26 := AllTrim(Substr(cBuffer, 29, 77))

            Id63 := UPPER(CRC16(Id00+Id26+Id52+Id53+Id58+Id59+Id60+Id62))
            
            cPix := Id00+Id26+Id52+Id53+Id58+Id59+Id60+Id62+Id63

            cvariav := getThreadValue("cChave")

            If  type("cvariav")   <>  'U'

                SE1->(DbSetOrder(1)) //E1_FILIAL+E1_FORNECE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO   //posicionando primeira parcela
                IF SE1->(DbSeek(Xfilial('SE1')+cvariav))

                    SE1->(Reclock("SE1"))
                    SE1->E1_XPIX  := cPix
                    SE1->(Msunlock())

                Endif    

 
            Endif
        Endif

    endif

return(.f.)   //RETORNANDO POIS O DEFAULT ษ .F.


// Calcula CRC16
Static Function CRC16(cInput)
Local nCrc    := 0
Local cRetHex := ""

/*
2 - CRC16_None
3 - CRC16_MODBUS
4 - CRC16_SICK
5 - CRC16_CCITT_XMODEM
6 - CRC16_CCITT_FFFF
7 - CRC16_CCITT_1D0F
8 - CRC16_CCITT_KERMIT
9 - CRC16_DNP
*/ 

//      CRCCalc(<Algoritmo>, <String Entrada>, [<String Hex>])
nCrc := CRCCalc(     6     , cInput          , @cRetHex)
 
return( @cRetHex)
