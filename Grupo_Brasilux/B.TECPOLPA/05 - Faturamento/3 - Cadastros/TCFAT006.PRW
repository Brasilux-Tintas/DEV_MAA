//Bibliotecas
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TCFAT006  บAutor ณ Nelieder Corneta   บ Data ณ  13/06/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para rela็ใo de pedidos para planilha               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TECPOLPA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TCFAT006()
Local _cGrpEmp
Private cPerg, MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09

_cGrpEmp := alltrim(FWGrpCompany())

if _cGrpEmp != "11"
	MsgBox("Esta opera็ใo s๓ pode ser executada na empresa TECPOLPA!", "Aten็ใo!", "STOP")
	return
endif

cPerg := PADR("TCFAT006",10," ")
Pergunte(cPerg, .F.)  // Pergunta no SX1

if empty(MV_PAR01)
	MV_PAR01 := "C:\TEMP\"
	Pergunte(cPerg, .F.)  // Pergunta no SX1
endif
@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "EXPORTAR Pedidos de Vendas"

@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_TCFT006()} )
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,016 SAY "EXPORTAR Pedidos de Vendas."
@ 08,10 TO 84,222
ACTIVATE DIALOG oDlg1 CENTERED
Return

 
User Function TCFT006()
    Local cQuery,cEmisNf,cDtEntr,cEmissa,cRealizado
    Local cAgenda,cPrevisto,DiasAtraso
    Local PedNota := 0
    Local cStatus
    Local aArea        := GetArea()
    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'TCFAT006.xml'
    Local cConta := 0
 
    //Pegando os dados
    cQuery := " "
    cQuery += "SELECT A4_NREDUZ AS NTRANSP,C5_RASTR AS PEDCLI,C5_CLIENTE AS CODCLI,C5_LOJACLI AS LOJA,B1_CODGTIN AS DUN,C6_PRODUTO AS CODPRO,A1_NOME NCLIENTE,"
    cQuery += "C5_NUM NPEDIDO,C6_VALOR,AOV_DESSEG SEGMENTO,C6_AGPRV,C6_AGREA,ISNULL(C5_OBS,'') AS OBS, "
    cQuery += "B1_DESC AS DESCRICAO,C6_QTDVEN AS QTDPED,C5_TRANSP AS CODTRAN,C6_NUM AS PEDIDO,ISNULL(D2_QUANT,C6_QTDVEN) AS QTDENT,"
    cQuery += "C5_FECENT AS DTENTR,C6_NOTA AS NRONF,C6_SERIE AS SERIE,C5_EMISSAO EMISSAO, 'PEDIDO' ORIGEM, "
    cQuery += "ISNULL(F2_PBRUTO,C5_PBRUTO) AS PESO,"
    cQuery += "ISNULL(F2_EMISSAO,'') AS EMISNF ,C6_XREFORC,C6_XREDUCA "
    cQuery += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = C6_FILIAL) AND (C6_NUM = C5_NUM) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = C5_CLIENTE) AND (A1_LOJA = C5_LOJACLI) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = C6_PRODUTO) "
    cQuery += "LEFT JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (C6_SERIE = D2_SERIE) AND (C6_NOTA = D2_DOC) AND (C6_ITEM = D2_ITEMPV) AND (C6_PRODUTO = D2_COD) 
    cQuery += "LEFT JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (C6_SERIE = F2_SERIE) AND (C6_NOTA = F2_DOC) "
    cQuery += "LEFT JOIN "+RetSqlName("SA4")+" SA4 ON A4_COD = C5_TRANSP AND SA4.D_E_L_E_T_ = '' AND A4_FILIAL = '"+xFilial("SA4")+"' "
    cQuery += "LEFT JOIN "+RetSqlName("AOV")+" AOV ON AOV_CODSEG = A1_CODSEG AND AOV.D_E_L_E_T_ = '' AND AOV_FILIAL = '"+xFilial("AOV")+"' "
    
    cQuery += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_TIPO = 'N')  AND "

    cQuery += " (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "

    if !empty(MV_PAR05)
        cQuery += "AND (C5_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"') "
    endif 
    if !empty(MV_PAR06)
        cQuery += "AND (C5_LOJACLI BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"') "
    endif 

    if !empty(alltrim(MV_PAR07))
        cQuery += " AND (B1_UM IN "+FilUni()+" )  "
    endif    

    cQuery += "ORDER BY C5_EMISSAO,C5_NUM DESC"
    
    TCQuery cQuery New Alias "QRYPRO"
     
    //Criando o objeto que irแ gerar o conte๚do do Excel
    oFWMsExcel := FWMsExcelEx():New()
     
    //Aba 02 - Pedidos Coca
    oFWMsExcel:AddworkSheet("Pedidos")
        //Criando a Tabela
    oFWMsExcel:AddTable("Pedidos","Pedidos")
    oFWMsExcel:AddColumn("Pedidos","Pedidos","PEDIDO TECPOLPA",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","PEDIDO CLIENTE",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","EMISSAO",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","CLIENTE",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","SEGMENTO",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","PRODUTOS",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","DESCRIวรO",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","QUANTIDADE",1,,.T.)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","VLR ENTREGAR",1,,.T.)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","STATUS DO PEDIDO",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","AGENDADO ",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","AGENDAMENTO PREVISTO",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","AGENDAMENTO REALIZADO",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","DIAS DE ATRASO",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","DIAS PEDIDO\NOTA",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","TRANSPORTADORA",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","OBSERVACOES",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","NF        ",1)
    oFWMsExcel:AddColumn("Pedidos","Pedidos","DATA DO FATURAMENTO",1)
    
    cDtEntr := ""
    cEmisNf := ""
    cEmissa := ""
    DiasAtraso := 0
    PedNota := 0
    cStatus := ""
    cRealizado := ""

 

        //Criando as Linhas... Enquanto nใo for fim da query
        While !(QRYPRO->(EoF()))
            cConta++
            cDtEntr := substr(QRYPRO->DTENTR,7,2)+"/"+substr(QRYPRO->DTENTR,5,2)+"/"+substr(QRYPRO->DTENTR,1,4)
	        cEmisNf := substr(QRYPRO->EMISNF,7,2)+"/"+substr(QRYPRO->EMISNF,5,2)+"/"+substr(QRYPRO->EMISNF,1,4)
            cEmissa := substr(QRYPRO->EMISSAO,7,2)+"/"+substr(QRYPRO->EMISSAO,5,2)+"/"+substr(QRYPRO->EMISSAO,1,4)
            cRealizado := substr(QRYPRO->C6_AGREA,7,2)+"/"+substr(QRYPRO->C6_AGREA,5,2)+"/"+substr(QRYPRO->C6_AGREA,1,4)
            cPrevisto := substr(QRYPRO->C6_AGPRV,7,2)+"/"+substr(QRYPRO->C6_AGPRV,5,2)+"/"+substr(QRYPRO->C6_AGPRV,1,4)
            
            if !Empty(QRYPRO->EMISNF)
                PedNota := DateDiffDay(STOD(QRYPRO->EMISSAO),STOD(QRYPRO->EMISNF))
            else
                PedNota := ""
            Endif    

            if !Empty(QRYPRO->C6_AGPRV)
                cAgenda   := "Sim"
                DiasAtraso := DateDiffDay(STOD(QRYPRO->EMISSAO),STOD(QRYPRO->C6_AGPRV))
            else
                cPrevisto  := ""
                cAgenda    := "Nใo"
                DiasAtraso := 0
            Endif

            If STOD(QRYPRO->C6_AGPRV) >= STOD(QRYPRO->C6_AGREA)
                cStatus := "Dentro do Prazo"
            else
                cStatus := "Fora do Prazo"
            Endif



            oFWMsExcel:AddRow("Pedidos","Pedidos",{;
                                                                    QRYPRO->NPEDIDO,;
                                                                    QRYPRO->PEDCLI,;
                                                                    cEmissa,;
                                                                    QRYPRO->NCLIENTE,;
                                                                    QRYPRO->SEGMENTO,;
                                                                    QRYPRO->CODPRO,;
                                                                    QRYPRO->DESCRICAO,;
                                                                    QRYPRO->QTDPED,;
                                                                    TransForm(QRYPRO->C6_VALOR, "@E 999,999.999"),;
                                                                    cStatus,;
                                                                    cAgenda,;
                                                                    cPrevisto,;
                                                                    cRealizado,;
                                                                    DiasAtraso,;
                                                                    PedNota,;
                                                                    QRYPRO->NTRANSP,;
                                                                    QRYPRO->OBS,;
                                                                    QRYPRO->NRONF,;
                                                                    cEmisNf;
            })
         
            //Pulando Registro
            QRYPRO->(DbSkip())
        EndDo
    
    if cConta > 0
        //Ativando o arquivo e gerando o xml
        oFWMsExcel:Activate()
        MsgRun("Processando...","Aguarde...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
        
            
        //Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New()             //Abre uma nova conexใo com Excel
        oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
        oExcel:SetVisible(.T.)                 //Visualiza a planilha
        oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
    else
        MsgAlert('Nenhum registro localizado !', 'Aten็ใo')
    Endif    
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)
Return

Static Function FilUni()
Local retorna,aString 
Local i

aString := strtokarr (alltrim(MV_PAR07), ",")

retorna := '('
For i := 1 to len(aString)
    retorna := retorna + "'"+aString[i]+"'"
        if (i < len(aString))
            retorna := retorna + ','
        endif
Next

retorna := retorna + ')'

return(retorna)
