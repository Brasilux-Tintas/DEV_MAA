#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ BRPCP032 บ Autor ณ Nelieder Corneta   บ Data ณ  22/11/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Etiqueta de volume via paramentros			              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BRPCP033()
Local cPerg   := Padr("BRPCP033",10)

u_zcfga01("BRPCP033")

if Pergunte(cPerg,.T.) 

    consulta() /* executa consulta de acordo com os paramentros enviados */
    
    if mv_par12 == 3
        ReportPrint() /* impressใo na tela */
    endif

    if mv_par12 == 1
        Zebra() /* impressใo Zebra */
    endif

endif





Return


Static Function consulta()

          

cBordero1 = alltrim(mv_par01) // nบ bordero de pedidos
dDtBord1 = mv_par02 // dt 1 bordero de pedidos
dDtBord2 = mv_par03 // dt 2 bordero de pedidos
cBordesp = alltrim(mv_par04) // nบ de bordero de despacho 
cPedido1 = mv_par05 // Pedido de ?
cPedido2 = mv_par06 // Pedido Ate ?

cProd1 = mv_par07 // produto de ?
cProd2 = mv_par08 // produto ate ?

cLocaliz1 = mv_par09 // quadrante de ?
cLocaliz2 = mv_par10 // quadrante de ?

cImpePed = mv_par11 // imprimir nบ do pedido

cPrint = mv_par12 // qual impressora

//ordem = mv_par13 // ordem de impressใo

cEmpresa = ''

cQry  = " SELECT C9_PEDIDO,C9_CLIENTE,SC5.C5_VOLUME1,ISNULL(A1_NOME,'') AS A1_NOME,ISNULL(A1_MUN,'') AS A1_MUN,ISNULL(A1_EST,'') AS A1_EST, 
cQry += " ISNULL(A2_NOME,'') AS A2_NOME,ISNULL(A2_MUN,'') AS A2_MUN,ISNULL(A2_EST,'') AS A2_EST, A4_NOME,A4_REGIAO "


cQry += " FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "

if !empty(cBordero1) .OR. !empty(dDtBord2)
	cQry += "RIGHT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = '"+xFilial("SZG")+"') AND (C9_PEDIDO = RIGHT(ZG_PEDIDO,6)) "
	IF !empty(cBordero1)
		cQry += "AND (ZG_CODIGO = '"+cBordero1+"') "
	ENDIF 
	IF !empty(dDtBord2) 
		cQry += "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = '"+xFilial("SZF")+"') AND (ZG_CODIGO = ZF_CODIGO) "
	ENDIF 
ENDIF 

IF !EMPTY(cBordesp)
	cQry += "RIGHT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = '"+xFilial("SZB")+"') AND (ZB_CODIGO = '"+cBordesp+"') AND (C9_PEDIDO = RIGHT(ZB_PEDIDO,6)) "
ENDIF 
cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" B1PED WITH (NOLOCK) ON (C9_FILIAL = B1PED.B1_FILIAL) AND (C9_PRODUTO = B1PED.B1_COD) AND (B1PED.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (C9_CLIENTE = A1_COD) AND (SA1.D_E_L_E_T_ <> '*') AND (LEN(C9_CLIENTE) = 6) "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (C9_CLIENTE = A2_COD) AND (SA2.D_E_L_E_T_ <> '*') AND (LEN(C9_CLIENTE) = 5) "

cQry += " LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (SUBSTRING(C9_PRODUTO,4,2) = Z1_LINHA) "
cQry += " AND (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '"+xFilial("SZ1")+"') "

cQry += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (C9_FILIAL = C5_FILIAL) AND (C9_PEDIDO = C5_NUM) AND (SC5.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SC5.C5_REDESP = A4_COD) AND (SA4.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+xFilial("SB2")+"') AND (B1PED.B1_COD = B2_COD) AND (B1PED.B1_LOCPAD = B2_LOCAL) "
cQry += "WHERE "
cQry +=  "(SC9.D_E_L_E_T_ <>  '*') AND (SC9.C9_FILIAL = '"+xFilial('SC9')+"') AND (SC5.C5_APROVA = '1') AND (LEN(B2_LOCALIZ) > 0) "
if !empty(cPedido2) .and. (cPedido2 >= cPedido1)
	cQry +=  "AND (SC9.C9_PEDIDO BETWEEN '"+cPedido1+"' AND '"+cPedido2+"') "
ENDIF

IF !EMPTY(cLocaliz2)
	cQry +=  "AND (SB2.B2_LOCALIZ BETWEEN '"+ALLTRIM(cLocaliz1)+"' AND '"+cLocaliz2+"') "
endif
	

if !empty(cProd2) .and. (cProd2 >= cProd1)
	cQry += "AND (SC9.C9_PRODUTO >= '"+cProd1+"') AND (SC9.C9_PRODUTO <= '"+cProd2+"') "
endif

if !empty(dDtBord2)
	cQry += "AND SZF.ZF_EMISSAO BETWEEN '"+dtos(dDtBord1)+"' AND '"+dtos(dDtBord2)+"')"
endif

cQry += " GROUP BY C9_PEDIDO,C9_CLIENTE,SC5.C5_VOLUME1,A1_NOME,A1_MUN,A1_EST, "
cQry += " A2_NOME,A2_MUN,A2_EST,A4_NOME,A4_REGIAO "

/* verifica quem ้ o usuแrio */
    cUsuario = PswChave(RetCodUsr())
    if (cUsuario == 'neliedercorneta') 
        /* gera log do script sql */
        GravaSQL(cQry)
    Endif

 /* verifica se arquivo estแ aberto e finaliza */
    IF Select("QCON") <> 0
        DbSelectArea("QCON")
        DbCloseArea()
    ENDIF
    
    //TMPP QCON
    TCQUERY cQry NEW ALIAS "QCON"  
    //Count To nTotal 

    dbSelectArea("QCON")
    QCON->(dbGoTop())

return()

Static Function ReportPrint()

Local cloop := 0
Local nloop := 0

Private oPrint
Private oFont10     := TFont():New('Arial',,10,,.F.,,,,.F.,.F.)
Private oFont10n    := TFont():New('Arial',,10,,.T.,,,,.F.,.F.)


dbSelectArea("QCON")
QCON->(dbGoTop())

    oPrint := TMSPrinter():New(OemToAnsi('Etiqueta de produto'))
    oPrint:SetPortrait()
    
    oPrint:StartPage()  
    nLin  := 0050
    nRow1 := 0
    cPage := 0
    cont := 0
    col2 := 0
    ////TMSPrinter(): Line ( [ nTop], [ nLeft], [ nBottom], [ nRight], [ uParam5] ) -->
    
    While !QCON->(eof())
        nloop := QCON->C5_VOLUME1      
       
        For cloop := 1 to nloop

                cPage++
                oPrint:Say(nLin,0110+col2,OemToAnsi('Pedido : '),oFont10,,,,0)

                if mv_par11 == 1                    
                    //oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(QCON->C9_PEDIDO)+'  '+cValToChar(cloop)),oFont10n,,,,0)
                    oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(QCON->C9_PEDIDO)),oFont10n,,,,0)
                endif    

                nLin += 040
                oPrint:Line (nLin,010+col2,nLin,900+col2)
                
                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi(Alltrim(QCON->A1_NOME)),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)

                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi('Cidade'),oFont10,,,,0)
                oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(QCON->A1_MUN)),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)


                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi('REDESP'),oFont10,,,,0)
                oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(QCON->A4_NOME)),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)

                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi('Q VOL'),oFont10,,,,0)
                oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(cValToChar(QCON->C5_VOLUME1))),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)

                if col2 == 1000
                    col2 = 0
                     nLin := nLin + 250
                else
                    col2 = 1000
                    nLin := nLin - 250
                endif                    
                
        if cPage == 12
            oPrint:EndPage()
            cPage := 0
            nRow1 := 0
            nLin  := 0050
        endif            

        next 
    
    

     QCON->(dbSkip())
    enddo 

    oPrint:Preview()
    oPrint:end()

return


Static Function GravaSQL(script)

Local cArq := ""


cArq := "C:\Temp\sql.txt" //a pasta deve ser vแlida.


MemoWrite ( cArq , script )


Return


Static Function Zebra()
Local cPorta 	:= "LPT1"
Local cModelo 	:= "ZEBRA"

Local cloop := 0
Local nloop := 0

dbSelectArea("QCON")
QCON->(dbGoTop())

    
    While !QCON->(eof())
        nloop := QCON->C5_VOLUME1      
       
        For cloop := 1 to nloop

            MSCBPRINTER(cModelo, cPorta,,12,.F.,,,,,,.F.,)
            MSCBCHKSTATUS(.F.)
            MSCBBEGIN(1,6)

            
            /* Pedido e Codigo do Produto */
            MSCBSAY(03,04,"PEDIDO:","N","A","015,008")
            if mv_par11 == 1                    
                MSCBSAY(14,03.5,Alltrim(QCON->C9_PEDIDO), "N", "0", "030,040") // negrito
            endif    

            //MSCBSAY(31,04,cEspe+cCod+"("+cValToChar(qLib)+"/"+cValToChar(qtdevol)+")", "N","0","020,028")
            MSCBLineH(00,7,190,3,'B')
            

            /* Nome do Cliente  */

            cCliente = Alltrim(QCON->A1_NOME)
            //cCliente = 'FIGUEIRA E SOARES COMERCIO DE TINTAS LTD'

            MSCBSAY(03,09,cCliente, "N", "0", "020,026") // negrito
            MSCBLineH(00,12,190,3,'B')

            /* Cidade */
            MSCBSAY(03,14,"Cidade: ","N","A","015,008") // negrito
            MSCBSAY(13,14,Alltrim(QCON->A1_MUN)+"-"+Alltrim(QCON->A1_EST), "N", "0", "020,030")
            MSCBLineH(00,17,190,3,'B')

            /* Transportadora */
            MSCBSAY(03,19,"REDESP: ","N","A","015,008")
            MSCBSAY(13,19,Alltrim(QCON->A4_NOME), "N", "0", "020,025")
            MSCBLineH(00,22,190,3,'B')

            /* volume */
            MSCBSAY(03,24,"Q VOL.: ","N","A","015,008")
            MSCBSAY(14,23.5,Alltrim(STR(QCON->C5_VOLUME1))+" L.: ", "N", "0", "030,040") // negrito
            MSCBLineH(00,27,190,3,'B')

            //MSCBSAY(02,30,"Q:"+Alltrim(QCON->ZG_LOCALIZ),  "N", "0","40,70") // negrito
            MSCBEND()

            MSCBCLOSEPRINTER()

        next 

     QCON->(dbSkip())
    enddo 


return




