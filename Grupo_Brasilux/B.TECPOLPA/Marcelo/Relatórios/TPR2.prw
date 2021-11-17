#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "avprint.ch

User Function TPR2()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatório Ordem Produção"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := ""
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "TPR2"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg
PRIVATE Linha := 20
PRIVATE cPerg   := "TPR2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg) //Cleber(17/02/20) -> Refazer após subir dicionário pro BD
Pergunte(cPerg,.F.)

//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "TPR2"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey==27
   dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
   dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
Local nTotal := 0
Local _nCont := 0
Local lNormal
Private _nLin := 7
Private auxOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :=" SELECT 'Quantidade (' + Rtrim(LTrim(SB1.B1_UM))  + ')'QTDUM1,"
cQuery +=" CASE WHEN  SB1.B1_UM = 'LT' AND C2_XCONV <> 0  THEN C2_XCONV * C2_QUANT ELSE  NULL END    QTDKG,"
cQuery +=" C2_XLOTE,NNR_DESCRI,CAST(SC2.C2_EMISSAO AS DATETIME) C2_EMISSAO, SC2.C2_FILIAL,SB1.B1_DESC DESC1,"
cQuery +=" SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD,SC2.C2_DATRF,SC2.C2_PRODUTO,SC2.C2_DESTINA,"
cQuery +=" SC2.C2_PEDIDO,SC2.C2_ROTEIRO,SC2.C2_QUJE,SC2.C2_PERDA,SC2.C2_QUANT,C2_QUANT -C2_QUJE QTDLIQ,"
cQuery +=" SC2.C2_OBS,SC2.C2_TPOP,SC2.R_E_C_N_O_  SC2RECNO ,D4_SEQ, D4_OP,D4_LOCAL,SB1.B1_UM UM1,"
cQuery +=" SB1_.B1_UM UM2,SB1_.B1_DESC DESC2,D4_COD,D4_QTDEORI,CAST(SC2.C2_DATPRI AS DATETIME) C2_DATPRI,"
cQuery +=" CAST(SC2.C2_DATPRF AS DATETIME) C2_DATPRF,SC2.C2_CC,"
cQuery +=" CASE WHEN SC2.C2_DATAJI = ' '  THEN '___/___/___' ELSE SUBSTRING(C2_DATAJI, 7,2) +'/'+SUBSTRING(C2_DATAJI, 5,2) +'/'+ SUBSTRING(C2_DATAJI, 1,4) END C2_DATAJI,"
cQuery +=" CASE WHEN SC2.C2_DATAJF = ' '  THEN '___/___/___' ELSE SUBSTRING(C2_DATAJF, 7,2) +'/'+SUBSTRING(C2_DATAJF, 5,2) +'/'+ SUBSTRING(C2_DATAJF, 1,4) END C2_DATAJF,"
cQuery +=" CASE WHEN C2_STATUS IN ( 'S') THEN 'Sacramentada' WHEN C2_STATUS IN ( 'U') THEN 'Suspensa' WHEN C2_STATUS IN ( 'N') THEN 'Normal' END C2_STATUS,"
cQuery +=" D4_LOTECTL, D4_NUMLOTE"
cQuery +=" FROM "+RetSqlName("SC2110")+" SC2 WITH (NOLOCK)"
cQuery +=" INNER JOIN "+RetSqlName("SB1110")+ " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND C2_PRODUTO = B1_COD AND SB1.D_E_L_E_T_=' '"
cQuery +=" INNER JOIN "+RetSqlName("SD4110")+ " SD4 ON D4_FILIAL = '"+xFilial("SD4")+"' AND C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD = D4_OP AND SD4.D_E_L_E_T_=' '"
cQuery +=" INNER JOIN "+RetSqlName("SB1110")+ " SB1_ ON SB1_.B1_FILIAL = '"+xFilial("SB1")+"' AND D4_COD = SB1_.B1_COD AND SB1_.D_E_L_E_T_=' '"
cQuery +=" LEFT JOIN NNR110 NNR ON NNR.NNR_FILIAL = '11' AND  NNR_CODIGO = D4_LOCAL AND NNR.D_E_L_E_T_=' '"
cQuery +=" WHERE  SC2.C2_FILIAL='"+xFilial("SC2")+"'"
cQuery +=" AND SC2.D_E_L_E_T_=' '"
cQuery +=" AND D4_OP BETWEEN 	'"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"'"
cQuery +=" AND (SC2.C2_DATPRF BETWEEN  ('"+dTos(MV_PAR03)+"') AND ('"+dTos(MV_PAR04)+"'))"
//cQuery +=" AND D4_OP BETWEEN 	'00422201001   ' AND 	'00422201003   '""
//cQuery +=" AND SC2.C2_DATPRF BETWEEN  '' AND 'ZZZZZZZZ'"
cQuery +=" ORDER BY SC2.C2_FILIAL, SC2.C2_DATPRF, D4_OP, SB1_.B1_COD"

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

oPrn:= TMSPrinter():New( "..." )
oPrn:SetLandscape()
      
AVPRINT oPrn NAME "..."
ProcRegua(150)

oFont1 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .T., 5, .T., .F.)
oFont2 := TFont():New("Courier New", 9, 14, .F., .T., 5, .F., 5, .T., .F.)
oFont3 := TFont():New("Courier New", 9, 10, .F., .T., 5, .F., 5, .T., .F.)
oFont4 := TFont():New("Courier New", 9, 10, .F., .F., 5, .T., 5, .T., .F.)
oFont5 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .F., 5, .T., .F.)
oFont6 := TFont():New("Arial"      , 9, 15, .F., .F., 5, .T., 5, .T., .F.)
oFont7 := TFont():New("Arial"      , 9, 25, .F., .F., 5, .T., 5, .T., .F.)

AVPAGE
DbSelectArea("TCQ")
DbGotop()
auxOP := TCQ->D4_OP
WHILE !EOF()
   // produto de custeio
   If U_IsProdCusto(TCQ->D4_COD)
      TCQ->(dbSkip())
      Loop
   Endif   
	R2CABEC()
	WHILE auxOP == TCQ->D4_OP .AND. !EOF()
	  	R2CORPO()
	  	auxOP := TCQ->D4_OP
		DbSelectArea("TCQ")
		DbSkip()
    ENDDO
    auxOP := TCQ->D4_OP
    R2RODAPE()
    IF !EOF() 
    	AVNEWPAGE 
    ENDIF		
ENDDO

  dbSelectArea("TCQ")
  dbCloseArea("TCQ")    
    
AVENDPAGE
AVENDPRINT
oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End()
oFont6:End()
oFont7:End()
MS_FLUSH()
Return
/*
//Cleber(17/02/20) -> Refazer após subir dicionário pro BD
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol

AAdd(aHelp,"de Op"   )
AAdd(aHelp,"ate OP"  )
AAdd(aHelp,"de Data" )
AAdd(aHelp,"ate Data")


//         X1_GRUPO , X1_ORDEM, X1_PERGUNT             , X1_VAR01  , X1_VARIAVL, X1_TIPO, X1_TAMANHO, X1_DECIMAL, X1_GSC, X1_VALID    , X1_F3   , X1_PICTURE , X1_DEF01   , X1_DEF02         , X1_DEF03, X1_DEF04, X1_DEF05, X1_HELP
//u_zPutSX1( _cPerg   , "01"    , "Codigo do Armazem    ", "mv_par01", "mv_ch1"  , "C"    ,  2        , 0         , "G"   , ""          , "NNR"   , ""         , ""         , ""               , ""      , ""      , ""      , aHelpPor[1] )
u_zPutSX1(cPerg,"01","de OP:   " ,"MV_PAR01","mv_ch1","C",15,00,"G","","","","","","","","",aHelp[1])
u_zPutSX1(cPerg,"02","ate OP:  " ,"MV_PAR02","mv_ch2","C",15,00,"G","","","","","","","","",aHelp[2])
u_zPutSX1(cPerg,"03","de Data: " ,"MV_PAR03","mv_ch3","D",08,00,"G","","","","","","","","",aHelp[3])
u_zPutSX1(cPerg,"04","ate Data:" ,"MV_PAR04","mv_ch4","D",08,00,"G","","","","","","","","",aHelp[4])

Return 
*/
//CRIA O CABEÇADO DO RELATORIO
STATIC FUNCTION R2CABEC()	

Linha  := 1
oPrn:Say ( 100        , 2000 , "Data "+ dtoc(DATE())                      , oFont6 ) 
oPrn:Say ( 100        , 0500 , "Ordens de Produção "                      , oFont7 )
Linha += 100  
oPrn:Say ( 200        , 2000 , "Hora "+TIME()                             , oFont6 )
Linha += 150
oPrn:Line( Linha - 1  , 0010 ,      Linha - 1                             , 3340   )
oPrn:Line( Linha + 1  , 0010 ,  Linha + 1                                 , 3340   )
Linha += 50
oPrn:Say ( Linha      , 0100 , "Ordens de Produção "                      , oFont1 )
oPrn:Say ( Linha      , 0600 , TCQ->D4_OP                                 , oFont1 )
oPrn:Say ( Linha      , 1200 , "Lote "                                    , oFont1 )
oPrn:Say ( Linha      , 1500 , TCQ->C2_XLOTE                              , oFont1 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Produto "                                 , oFont1 )
oPrn:Say ( Linha      , 0600 , TCQ->C2_PRODUTO                            , oFont1 )
oPrn:Say ( Linha      , 1200 , "Descrição "                               , oFont1 )
oPrn:Say ( Linha      , 1500 , TCQ->DESC1                                 , oFont1 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Emissão "                                 , oFont1 )
oPrn:Say ( Linha      , 0600 , SUBSTR(DTOS(TCQ->C2_EMISSAO),7,2)+'/'+SUBSTR(DTOS(TCQ->C2_EMISSAO),5,2)+'/'+SUBSTR(DTOS(TCQ->C2_EMISSAO),1,4), oFont1 )
Linha += 70
oPrn:Say ( Linha      , 0100 , TCQ->QTDUM1                                , oFont1 )
oPrn:Say ( Linha      , 0600 , TRANSFORM(TCQ->QTDLIQ,'@E 99,999,999.9999'), oFont1 )
oPrn:Say ( Linha      , 1200 , "Quantidade (KG)"                          , oFont1 )
oPrn:Say ( Linha      , 1500 , TRANSFORM(TCQ->QTDKG, '@E 99,999,999.9999'), oFont1 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Centro de Custo "                         , oFont1 )
oPrn:Say ( Linha      , 0600 , TCQ->C2_CC                                 , oFont1 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Situação "                                , oFont1 )
oPrn:Say ( Linha      , 0600 , TCQ->C2_STATUS                             , oFont1 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Previsão Ini. "                           , oFont1 )
oPrn:Say ( Linha      , 0600 , SUBSTR(DTOS(TCQ->C2_DATPRI),7,2)+'/'+SUBSTR(DTOS(TCQ->C2_DATPRI),5,2)+'/'+SUBSTR(DTOS(TCQ->C2_DATPRI),1,4)   , oFont1 )
oPrn:Say ( Linha      , 1200 , "Entrega "                                 , oFont1 )
oPrn:Say ( Linha      , 1500 , SUBSTR(DTOS(TCQ->C2_DATPRF),7,2)+'/'+SUBSTR(DTOS(TCQ->C2_DATPRF),5,2)+'/'+SUBSTR(DTOS(TCQ->C2_DATPRF),1,4)   , oFont1 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Qtde. Real Produzida "                    , oFont1 )
oPrn:Say ( Linha-25   , 0600 , "______________"                           , oFont6 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Real Ini."                                , oFont1 )
oPrn:Say ( Linha- 25  , 0600 , "___/___/___"                              , oFont6 )
oPrn:Say ( Linha      , 1200 , "Hora Ini."                                , oFont1 )
oPrn:Say ( Linha- 25  , 1500 , "___:___"                                  , oFont6 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Real Fim "                                , oFont1 )
oPrn:Say ( Linha- 25  , 0600 , "___/___/___"                              , oFont6 )
oPrn:Say ( Linha      , 1200 , "Hora Fim "                                , oFont1 )
oPrn:Say ( Linha- 25  , 1500 , "___:___"                                  , oFont6 )
Linha += 70
oPrn:Say ( Linha      , 0100 , "Observação"                               , oFont1 )
oPrn:Say ( Linha      , 0600 , TCQ->C2_OBS                                , oFont1 )
oPrn:Line( Linha - 1  , 1900 , Linha - 1                                  , 2400   )
oPrn:Line( Linha + 1  , 1900 , Linha + 1                                  , 2400   )
Linha += 60
oPrn:Say ( Linha-50   , 2000 , "Assinatura Blendista"                     , oFont1 )
oPrn:Line( Linha      , 1900 , Linha - 60                                 , 1900   )
oPrn:Line( Linha      , 1900 , Linha - 60                                 , 1900   )
oPrn:Line( Linha - 1  , 1900 , Linha - 1                                  , 2400   )
oPrn:Line( Linha + 1  , 1900 , Linha + 1                                  , 2400   )
oPrn:Line( Linha      , 2400 , Linha - 60                                 , 2400   )
oPrn:Line( Linha      , 2400 , Linha - 60                                 , 2400   )
Linha += 80
oPrn:Line( Linha      , 1900 , Linha - 80                                 , 1900   )
oPrn:Line( Linha      , 1900 , Linha - 80                                 , 1900   )
oPrn:Line( Linha - 1  , 1900 , Linha - 1                                  , 2400   )
oPrn:Line( Linha + 1  , 1900 , Linha + 1                                  , 2400   )
oPrn:Line( Linha      , 2400 , Linha - 80                                 , 2400   )
oPrn:Line( Linha      , 2400 , Linha - 80                                 , 2400   )
Linha += 80
oPrn:Line( Linha - 1  , 0000 , Linha - 1                                  , 2600   )
oPrn:Line( Linha + 1  , 0000 , Linha + 1                                  , 2600   )
Linha += 60
oPrn:Say ( Linha- 50  , 0000 , "Código"                                   , oFont1 )
oPrn:Say ( Linha- 50  , 0310 , "Descrição"                                , oFont1 )
oPrn:Say ( Linha- 50  , 1375 , "Quantidade"                               , oFont1 )
oPrn:Say ( Linha- 50  , 1625 , "UM"                                       , oFont1 )
oPrn:Say ( Linha- 50  , 1700 , "Arm."                                     , oFont1 )
//oPrn:Say ( Linha- 50  , 1375 , "Descrição"                                , oFont1 )
oPrn:Say ( Linha- 50  , 1875 , "Check"                                    , oFont1 )
oPrn:Say ( Linha- 50  , 2000 , "Seq."                                     , oFont1 )
oPrn:Say ( Linha- 50  , 2100 , "Lote"                                     , oFont1 )
oPrn:Say ( Linha- 50  , 2400 ,  "Perda"                                   , oFont1 )
oPrn:Line( Linha - 1  , 0000 , Linha - 1                                  , 2600   )
oPrn:Line( Linha + 1  , 0000 , Linha + 1                                  , 2600   )

RETURN


STATIC FUNCTION R2CORPO()

Linha += 60
oPrn:Say ( Linha - 40   , 0000 , TCQ->D4_COD                                      , oFont1 )
oPrn:Say ( Linha - 40   , 0310 , SUBSTR(TCQ->DESC2,1,44)                          , oFont1 )
oPrn:Say ( Linha - 40   , 1375 , TRANSFORM(TCQ->D4_QTDEORI,'@E 99,999,999.9999')  , oFont1 )
oPrn:Say ( Linha - 40   , 1625 , TCQ->UM2                                         , oFont1 )
oPrn:Say ( Linha - 40   , 1700 , TCQ->D4_LOCAL                                    , oFont1 )
oPrn:Say ( Linha - 40   , 2000 , TCQ->D4_SEQ                                      , oFont1 )
oPrn:Say ( Linha - 40   , 2100 , TCQ->D4_LOTECTL                                  , oFont1 )
oPrn:Say ( Linha - 40   , 2400 , TCQ->D4_NUMLOTE                                  , oFont1 )

oPrn:Line( Linha - 60   , 1875 , Linha  - 60                                      , 1950   )
oPrn:Line( Linha - 59   , 1875 , Linha  - 59                                      , 1950   )
oPrn:Line( Linha -  1   , 1875 , Linha  - 1                                       , 1950   )
oPrn:Line( Linha +  1   , 1875 , Linha  + 1                                       , 1950   )
oPrn:Line( Linha - 60   , 1875 , Linha  + 1                     	                  , 1875   )
oPrn:Line( Linha - 60   , 1875 , Linha  + 1                                       , 1875   )
oPrn:Line( Linha - 60   , 1950 , Linha  + 1                                       , 1950   )
oPrn:Line( Linha - 60   , 1950 , Linha  + 1                                       , 1950   )

RETURN

STATIC FUNCTION R2RODAPE()  

Linha += 100
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
Linha += 10
oPrn:Say ( Linha    , 1100, "Análise para liberação de Tanque", oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )

Linha += 10
oPrn:Say ( Linha    , 0860, "Brix Original (°)"               , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 0860, "Brix Corrigido(°)"               , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 0860, "Acidez(%)"                       , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 0860, "Ratio"                           , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 0860, "pH"                              , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 0860, "Sabor"                           , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 0860, "Cor"                             , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 860 , "Defeito"                         , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 860 , "Hora de Análise"                 , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
Linha += 10
oPrn:Say ( Linha    , 860, "Analista"                         , oFont5 )
Linha += 70
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha    , 0850, Linha - 80                        , 0850   )
oPrn:Line( Linha - 1, 0850, Linha - 1                         , 1850   )
oPrn:Line( Linha + 1, 0850, Linha + 1                         , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1850, Linha - 80                        , 1850   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )
oPrn:Line( Linha    , 1325, Linha - 80                        , 1325   )

Return
