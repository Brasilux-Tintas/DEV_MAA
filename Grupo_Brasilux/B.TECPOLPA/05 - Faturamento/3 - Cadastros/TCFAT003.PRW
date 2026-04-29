//Bibliotecas
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TCFAT002  บAutor ณ Nelieder Corneta   บ Data ณ  13/06/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para EXPORTAR pedidos de clientes Coca Cola p/      บฑฑ
ฑฑบ          ณ planilha                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TECPOLPA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TCFAT003()
Local _cGrpEmp
Private cPerg, MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,MV_PAR09
_cGrpEmp := alltrim(FWGrpCompany())
if _cGrpEmp != "11"
	MsgBox("Esta opera็ใo s๓ pode ser executada na empresa TECPOLPA!", "Aten็ใo!", "STOP")
	return
endif
cPerg := PADR("TCFAT002",10," ")
VldPerg()             // Verifica as perguntas selecionadas
Pergunte(cPerg, .F.)  // Pergunta no SX1
//mv_par01 := getmv("MV_DIRBREP") //"\\10.1.1.146\brasilux\Cast\DATA\entrada\"
if empty(MV_PAR01)
	MV_PAR01 := "C:\TEMP\"
	Pergunte(cPerg, .F.)  // Pergunta no SX1
endif
@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "EXPORTAR Pedidos Coca Cola"

@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_TCFT003()} )
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,016 SAY "EXPORTAR Pedidos Coca Cola p/ Planilha."
@ 08,10 TO 84,222
ACTIVATE DIALOG oDlg1 CENTERED
Return

 
User Function TCFT003()
    Local cQuery,cEmisNf,cDtEntr,cEmissa
    Local aArea         := GetArea()
    Local oFWMsExcel
    Local oExcel
    Local cArquivo      := GetTempPath()+'zTstExc1.xml'
    Local Fabric        := ""
 
    //Pegando os dados
    cQuery := " "
    cQuery += "SELECT A1_NREDUZ,C5_RASTR AS PEDCLI,C5_CLIENTE AS CODCLI,C5_LOJACLI AS LOJA,B1_CODGTIN AS DUN,C6_PRODUTO AS CODPRO,"
    cQuery += "B1_DESC AS DESCRICAO,C6_QTDVEN AS QTDPED,C5_TRANSP AS CODTRAN,C6_NUM AS PEDIDO,ISNULL(D2_QUANT,C6_QTDVEN) AS QTDENT,"
    cQuery += "C5_FECENT AS DTENTR,C6_NOTA AS NRONF,C6_SERIE AS SERIE,C5_EMISSAO EMISSAO, 'PEDIDO' ORIGEM, "
    cQuery += "ISNULL(F2_PBRUTO,C5_PBRUTO) AS PESO,"
    cQuery += "ISNULL(F2_EMISSAO,'') AS EMISNF ,C6_XREFORC,C6_XREDUCA "
    cQuery += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = C6_FILIAL) AND (C6_NUM = C5_NUM) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = C5_CLIENTE) AND (A1_LOJA = C5_LOJACLI) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = C6_PRODUTO) "
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (C6_SERIE = D2_SERIE) AND (C6_NOTA = D2_DOC) AND (C6_ITEM = D2_ITEMPV) AND (C6_PRODUTO = D2_COD) 
    cQuery += "LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (C6_SERIE = F2_SERIE) AND (C6_NOTA = F2_DOC) "
    
    cQuery += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_TIPO = 'N') AND (C5_RASTR > '') AND "
    cQuery += " (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "

    if !empty(MV_PAR05)
        cQuery += "AND (C5_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"') "
    endif 
    if !empty(MV_PAR06)
        cQuery += "AND (C5_LOJACLI BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"') "
    endif 
    if !empty(MV_PAR07)
        cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR07)+") "
    endif

    if !empty(MV_PAR09)
        cQuery += "AND (F2_EMISSAO BETWEEN '"+DTOS(MV_PAR08)+"' AND '"+DTOS(MV_PAR09)+"')  "
    endif


    
    cQuery += "UNION ALL "
    cQuery += "SELECT A1_NREDUZ,ZC6_NUM AS PEDCLI,ZC6_CLIENT AS CODCLI,ZC6_LOJA AS LOJA,B1_CODGTIN AS DUN,ZC6_PRODUT AS CODPRO,B1_DESC AS DESCRICAO,ZC6_QTD AS QTDPED,"
    cQuery += "ZC6_TRANSP AS CODTRAN,'' AS PEDIDO, '0' QTDENT,ZC6_EMISSA AS DTENTR , '' AS NRONF , '' AS SERIE,ZC6_EMISSA EMISSAO, 'RR' ORIGEM, "
    cQuery += " '' PESO ,'' AS EMISNF,ZC6_XREFOR AS C6_XREFORC,ZC6_XREDUC AS C6_XREDUCA "
    cQuery += "FROM "+RetSqlName("ZC6")+" ZC6 "
    cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = ZC6_PRODUT) "
    cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = ZC6_CLIENT) AND (A1_LOJA = ZC6_LOJA)  "
    
    cQuery += "WHERE (ZC6.D_E_L_E_T_ <> '*') "
    cQuery += "AND ZC6_EMISSA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "

    if !empty(MV_PAR05)
        cQuery += "AND (ZC6_CLIENT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"') "
    endif 
    if !empty(MV_PAR06)
        cQuery += "AND (ZC6_LOJA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"') "
    endif 
    if !empty(MV_PAR07)
        cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR07)+") "
    endif

    cQuery += "ORDER BY PEDIDO"
    
    TCQuery cQuery New Alias "QRYPRO"
     
    //Criando o objeto que irแ gerar o conte๚do do Excel
    oFWMsExcel := FWMsExcelEx():New()
     
    //Aba 02 - Pedidos Coca
    oFWMsExcel:AddworkSheet("Pedidos")
        //Criando a Tabela
    ccabecalho := "Data..: "+DTOC(dDataBase)+" Pedidos Coca " + " Hora..:"+ Time()      
    oFWMsExcel:AddTable("Pedidos",ccabecalho)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"PEDIDO DE COMPRA",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"FABRICANTE",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"CำDIGO DO CLIENTE (NO CP)",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"LOJA (CP)",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"DUN",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"CำDIGO",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"DESCRIวรO",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"QUANTIDADE",1,,.T.)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"REFORวO",1,,.T.)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"REDUวรO",1,,.T.)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"CำDIGO DA TRANSPORTADORA (NO CP)",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"ORDEM DE VENDA CP",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"QUANTIDADE ATENDIDA",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"DATA DA COLETA",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"EMISSAO",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"HORมRIO",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"OBSERVACOES",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"DATA DO FATURAMENTO",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"NRO DA NF(CP)",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"ORIGEM",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"PESO(CP)",1)

    //AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)
    
    
    cDtEntr := ""
    cEmisNf := ""
    cEmissa := ""

 

        //Criando as Linhas... Enquanto nใo for fim da query
        While !(QRYPRO->(EoF()))
            cDtEntr := substr(QRYPRO->DTENTR,7,2)+"/"+substr(QRYPRO->DTENTR,5,2)+"/"+substr(QRYPRO->DTENTR,1,4)
	        cEmisNf := substr(QRYPRO->EMISNF,7,2)+"/"+substr(QRYPRO->EMISNF,5,2)+"/"+substr(QRYPRO->EMISNF,1,4)
            cEmissa := substr(QRYPRO->EMISSAO,7,2)+"/"+substr(QRYPRO->EMISSAO,5,2)+"/"+substr(QRYPRO->EMISSAO,1,4)

            /*codigos FEMSA*/
            ArrayTem := strtokarr (alltrim(MV_PAR10), ",")
            if (aScan(ArrayTem, {|x| AllTrim(Upper(x)) == Alltrim(QRYPRO->CODCLI)})) > 0
                Fabric := GETMV("ZP_PAR0055")
            else
                Fabric := ""
            Endif                
            /*if Alltrim(MV_PAR10) $ Alltrim(QRYPRO->CODCLI)
                Fabric := GETMV("ZP_PAR0055")
            else
                Fabric := ""
            Endif    */

            oFWMsExcel:AddRow("Pedidos",ccabecalho,{;
                                                                    QRYPRO->PEDCLI,;
                                                                    Fabric,;
                                                                    CHR(160)+QRYPRO->CODCLI,;
                                                                    CHR(160)+QRYPRO->LOJA,;
                                                                    CHR(160)+QRYPRO->DUN,;
                                                                    QRYPRO->CODPRO,;
                                                                    QRYPRO->DESCRICAO,;
                                                                    QRYPRO->QTDPED,;
                                                                    QRYPRO->C6_XREFORC,;
                                                                    QRYPRO->C6_XREDUCA,;
                                                                    CHR(160)+QRYPRO->CODTRAN,;
                                                                    CHR(160)+QRYPRO->PEDIDO,;
                                                                    QRYPRO->QTDENT,;
                                                                    cDtEntr,;
                                                                    cEmissa,;
                                                                    "  :  ",;
                                                                    SPACE(20),;
                                                                    cEmisNf,;
                                                                    CHR(160)+QRYPRO->NRONF,;
                                                                    QRYPRO->ORIGEM,;
                                                                    PESO;
            })
         
            //Pulando Registro
            QRYPRO->(DbSkip())
        EndDo
    
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    MsgRun("Processando...","Aguarde...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )
    
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexใo com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)
Return

Static Function VldPerg()
Local _sAlias := Alias()

//+---------------------------------------------+
//ยฆ Variaveis utilizadas para parametros        ยฆ
//+---------------------------------------------+

u_xPutSX1(cPerg,"01","Data Emissao De  ?"      ,"Data Emissao De  ?" ,"Data Emissao De  ?"  ,"mv_ch1" ,"D",08,0,0,"G",""  ,"","","","MV_PAR01",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSX1(cPerg,"02","Data Emissao Ate ?"      ,"Data Emissao Ate ?" ,"Data Emissao Ate ?"  ,"mv_ch2" ,"D",08,0,0,"G",""  ,"","","","MV_PAR02",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSx1(cPerg,"03","Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch3", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "MV_PAR03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"04","Loja Cliente de", "Loja Cliente de", "Loja Cliente de", "mv_ch4", "C",  2, 0, 0, "G", " ", "", " ", " ", "MV_PAR04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"05","At้ o Cliente      ", "At้ o Cliente      ", "At้ o Cliente      ", "mv_ch5", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "MV_PAR05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
u_xPutSx1(cPerg,"06","Loja Cliente Ate", "Loja Cliente Ate", "Loja Cliente Ate", "mv_ch6", "C",  2, 0, 0, "G", " ", "", " ", " ", "MV_PAR06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
U_xPutSx1(cPerg,"07","Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_ch7", "C", 99,00,00, "G",  "", "",  "",  "", "MV_PAR07","","","","","","","","","","","","","","","","",Nil         ,Nil         ,Nil     ,cPerg)
u_xPutSX1(cPerg,"08","Data Fatur De  ?"      ,"Data Fatur De  ?" ,"Data Fatur De  ?"  ,"mv_ch8" ,"D",08,0,0,"G",""  ,"","","","MV_PAR08",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSX1(cPerg,"09","Data Fatur Ate ?"      ,"Data Fatur Ate ?" ,"Data Fatur Ate ?"  ,"mv_ch9" ,"D",08,0,0,"G",""  ,"","","","MV_PAR09",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)

if !empty(_sAlias)
	DbSelectArea(_sAlias)
endif
//************
/*
*/
//*********** 

Return
