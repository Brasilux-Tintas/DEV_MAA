#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TCFAT002  บAutor ณ Cleber Orati       บ Data ณ  05/08/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para EXPORTAR pedidos de clientes Coca Cola p/      บฑฑ
ฑฑบ          ณ planilha                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TECPOLPA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TCFAT002()
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
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_TCFT002()} )
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,016 SAY "EXPORTAR Pedidos Coca Cola p/ Planilha."
@ 08,10 TO 84,222
ACTIVATE DIALOG oDlg1 CENTERED
Return

User Function TCFT002()
Local cQuery,nCont,cEmisNf,cDtEntr,cPedCli
Local aCabExcel :={}
Local aItensExcel :={}

if Select("TMP")<>0		
	dbselectarea("TMP")
	dbclosearea()
endif 
cQuery := "SELECT C5_RASTR AS PEDCLI,C5_CLIENTE AS CODCLI,C5_LOJACLI AS LOJA,B1_CODGTIN AS DUN,C6_PRODUTO AS CODPRO,B1_DESC AS DESCRICAO,"+;
"C6_QTDVEN AS QTDPED,C5_TRANSP AS CODTRAN,C6_NUM AS PEDIDO,ISNULL(D2_QUANT,C6_QTDVEN) AS QTDENT,C5_FECENT AS DTENTR,C6_NOTA AS NRONF,C6_SERIE AS SERIE,ISNULL(F2_PBRUTO,C5_PBRUTO) AS PESO,ISNULL(F2_EMISSAO,'') AS EMISNF "+;
"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = C6_FILIAL) AND (C6_NUM = C5_NUM) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = C5_CLIENTE) AND (A1_LOJA = C5_LOJACLI) "+;
"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = C6_PRODUTO) "+;
"LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (C6_SERIE = D2_SERIE) AND (C6_NOTA = D2_DOC) AND (C6_ITEM = D2_ITEMPV) AND (C6_PRODUTO = D2_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (C6_SERIE = F2_SERIE) AND (C6_NOTA = F2_DOC) "+;
"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_TIPO = 'N') AND (C5_RASTR > '') AND "+;
"(C5_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
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

cQuery += "ORDER BY PEDIDO"
TCQuery cQuery ALIAS "TMP" NEW

// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
cCampo := "C6_PEDCLI"
AADD(aCabExcel, {"PEDIDO DE COMPRA" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
AADD(aCabExcel, {"FABRICANTE" ,"C", 11, 0})
cCampo := "C5_CLIENTE"
AADD(aCabExcel, {"CำDIGO DO CLIENTE (NO CP)" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "C5_LOJACLI"
AADD(aCabExcel, {"LOJA (CP)" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "B1_CODGTIN"
AADD(aCabExcel, {"DUN" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "C6_PRODUTO"
AADD(aCabExcel, {"CำDIGO" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "B1_DESC"
AADD(aCabExcel, {"DESCRIวรO" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "C6_QTDVEN"
AADD(aCabExcel, {"QUANTIDADE" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
AADD(aCabExcel, {"REFORวO" ,"C", 10, 0})
AADD(aCabExcel, {"REDUวรO" ,"C", 10, 0})
cCampo := "C5_TRANSP"
AADD(aCabExcel, {"CำDIGO DA TRANSPORTADORA (NO CP)" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "C6_NUM"
AADD(aCabExcel, {"ORDEM DE VENDA CP" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "C6_QTDVEN"
AADD(aCabExcel, {"QUANTIDADE ATENDIDA" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "C5_FECENT"
AADD(aCabExcel, {"DATA DA COLETA" ,"C", 11, 0})
AADD(aCabExcel, {"HORมRIO" ,"C", 5, 0})
AADD(aCabExcel, {"OBSERVACOES" ,"C", 20, 0})
AADD(aCabExcel, {"DATA DO FATURAMENTO" ,"C", 11, 0})
cCampo := "C6_NOTA"
AADD(aCabExcel, {"NRO DA NF(CP)" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})
cCampo := "F2_PBRUTO"
AADD(aCabExcel, {"PESO(CP)" ,GetSx3Cache(cCampo,"X3_TIPO"), TamSX3(cCampo)[01], TamSX3(cCampo)[02]})

nCont := 0
dbselectarea("TMP")
dbgotop()
do while !eof()
	nCont++
	cDtEntr := substr(TMP->DTENTR,7,2)+"/"+substr(TMP->DTENTR,5,2)+"/"+substr(TMP->DTENTR,1,4)
	cEmisNf := substr(TMP->EMISNF,7,2)+"/"+substr(TMP->EMISNF,5,2)+"/"+substr(TMP->EMISNF,1,4)
	cPedCli := TMP->PEDCLI
	aadd(aItensExcel,{cPedCli,SPACE(11),CHR(160)+TMP->CODCLI,CHR(160)+TMP->LOJA,CHR(160)+TMP->DUN,TMP->CODPRO,TMP->DESCRICAO,TMP->QTDPED,SPACE(10),SPACE(10),CHR(160)+TMP->CODTRAN,CHR(160)+TMP->PEDIDO,TMP->QTDENT, cDtEntr,"  :  ",SPACE(20),cEmisNf,CHR(160)+TMP->NRONF,TMP->PESO,"" })
	dbselectarea("TMP")
	dbskip()
enddo 
MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
{||DlgToExcel({{"GETDADOS",;
,;
aCabExcel,aItensExcel}})})


if Select("TMP")<>0		
	dbselectarea("TMP")
	dbclosearea()
endif 
return

//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//
// Funcao...: VldPerg                                             //
// Descricao: Verifica as perguntas, incluindo-as caso nao existam//
//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//

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
