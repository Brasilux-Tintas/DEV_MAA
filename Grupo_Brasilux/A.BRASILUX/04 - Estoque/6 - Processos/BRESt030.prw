#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ BRESt030 บ Autor ณ Nelieder Corneta   บ Data ณ  04/05/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Calculo do IBGE  							              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BREST030 ()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 400
Private nJanAltu  := 250

Private cAnoi,cAnof

Private cMesI,cMesF

Private oIBGE
Private cIBGE       := space(20)

Private oInicio
Private oFim 

Private cInicio := STOD("  /  /    ")
Private cFim := STOD("  /  /    ")

DEFINE MSDIALOG oDlg TITLE "Calculos IBGE" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

    @ 010, 010 SAY OemToAnsi("Data de..? ") SIZE 050,009 PIXEL OF oDlg FONT oFontBtn
    @ 008, 060 MSGET oInicio VAR cInicio PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE PIXEL ON CHANGE oDlg FONT oFontBtn

    @ 030, 010 SAY OemToAnsi("Data At้..? ") SIZE 050,009 PIXEL  OF oDlg FONT oFontBtn
    @ 028, 060 MSGET oFim VAR cFim PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE PIXEL ON CHANGE oDlg FONT oFontBtn

   /* @ 050, 010 SAY OemToAnsi("IBGE.: ") SIZE 020,009 PIXEL  OF oDlg FONT oFontBtn
    @ 048, 060 MSGET oIBGE VAR cIBGE PICTURE "@!" SIZE 060,010 COLOR CLR_BLUE PIXEL ON CHANGE oDlg FONT oFontBtn*/

    @ 090,020 BUTTON oBtnFech PROMPT "Gerar Plnailha" SIZE 080, 018 OF oDlg ACTION MsAguarde({|| Imprimir() },"Calculando..","Aguarde...") FONT oFontBtn PIXEL
    @ 090,120 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL


    oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED



Return


Static Function Imprimir()
Local cArquivo    := GetTempPath()+'IBGE.xml'

if empty(cInicio)
        MsgAlert('Favor informar uma data de inicio valida !')
        oInicio:SetFocus()
        return()
End

if empty(cFim)
        MsgAlert('Favor informar uma data de fim valida !')
        oFim:SetFocus()
        return()
End



cMesI := Month2Str(cInicio)
cMesF := Month2Str(cFim)

cAnoi := Year2Str(cInicio)
cAnof := Year2Str(cFim)

    
    cQuery1 := ""
    cQuery1 += " SELECT SUBSTRING(D3_COD,4,2) AS LINHA,MAX(Z1_DESCR) AS DESCRICAO,ROUND(SUM(D3_QUANT*Z5_VOLUME*CASE WHEN PE.B1_UM IN ('K','KG') THEN 1.0 ELSE PE.B1_PESOESP END),2) AS PESO "
    cQuery1 += " FROM SD3010 SD3 WITH (NOLOCK) "
    cQuery1 += " LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D3_FILIAL = SB1.B1_FILIAL) AND (D3_COD = SB1.B1_COD) "
    cQuery1 += " LEFT OUTER JOIN SZ5010 SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') AND (SUBSTRING(D3_COD,11,2) = SZ5.Z5_EMB) "
	cQuery1 += " LEFT OUTER JOIN SB1010 PE WITH (NOLOCK) ON (PE.D_E_L_E_T_ <> '*') AND (PE.B1_TIPO = 'PI') AND (LEN(PE.B1_COD) = 12) AND (D3_FILIAL = PE.B1_FILIAL) AND (SUBSTRING(D3_COD,1,10) = SUBSTRING(PE.B1_COD,1,10)) AND (PE.B1_UM IN (Z5_UMEMB )) "
    cQuery1 += " LEFT OUTER JOIN SZ1010 SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '01') AND (SUBSTRING(D3_COD,4,2) = SZ1.Z1_LINHA) "
    cQuery1 += " WHERE (SD3.D3_FILIAL = '"+xFilial("SD3")+"') AND "
    cQuery1 += " (LEN(D3_COD) = 12) AND "
    cQuery1 += " (SUBSTRING(D3_COD,11,2) NOT IN('00','99')) AND "
    cQuery1 += " (D3_TM = '010') AND "
    cQuery1 += " (D3_ESTORNO <> 'S') AND "
    cQuery1 += " (SD3.D_E_L_E_T_ <> '*') "
    //cQuery1 += "  AND (SUBSTRING(D3_COD,4,2) IN ('39','40','09')) "
    cQuery1 += " AND (SUBSTRING(SD3.D3_EMISSAO,1,6) >= '"+cAnoi+cMesI+"') "
    cQuery1 += " AND (SUBSTRING(SD3.D3_EMISSAO,1,6) <= '"+cAnof+cMesF+"') "
    cQuery1 += " GROUP BY SUBSTRING(D3_COD,4,2)"

     /* verifica se arquivo estแ aberto e finaliza */
    IF Select("TMP") <> 0
        DbSelectArea("TMP")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery1 NEW ALIAS "TMP" 

    Count To nTotal

    TMP->(dbGoTop())
    
	/*if nTotal > 0
        cIBGE := ROUND(TMP->PESO,0)
    else
        MsgAlert('Nenhum Registro Localizado !')
    End        */

     //Criando o objeto que irแ gerar o conte๚do do Excel
    oFWMsExcel := FWMsExcelEx():New()
     
    //Aba 02 - Pedidos Coca
    oFWMsExcel:AddworkSheet("IBGE")
        //Criando a Tabela
    oFWMsExcel:AddTable("IBGE","IBGE")
    oFWMsExcel:AddColumn("IBGE","IBGE","LINHA",1)
    oFWMsExcel:AddColumn("IBGE","IBGE","DESCRICAO",1)
    oFWMsExcel:AddColumn("IBGE","IBGE","PESO",1,,.T.)

    While !(TMP->(EoF()))

      oFWMsExcel:AddRow("IBGE","IBGE",{;
                                            TMP->LINHA,;
                                            TMP->DESCRICAO,;
                                            TMP->PESO;
            })

      TMP->(DbSkip())
    EndDo

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    MsgRun("Processando...","Aguarde...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
    
        
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexใo com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

	

return
