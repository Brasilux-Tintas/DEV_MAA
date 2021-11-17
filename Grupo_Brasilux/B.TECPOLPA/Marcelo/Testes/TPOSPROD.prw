#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"
  
User Function TPOSPROD()
  
PRIVATE nomeprog:= "TPOSPROD"
PRIVATE cPerg   := "TPOSPROD"
 
CriaSX1(cPerg)
Pergunte(cPerg,.T.)

Return
                      

Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol

AAdd(aHelp,"Informar numero da Ordem de Produção inicial."   )
AAdd(aHelp,"Informar numero da Ordem de Produção final"  )
AAdd(aHelp,"Informar data de emissão da Ordem de Produção inicio" )
AAdd(aHelp,"Informar data de emissão da Ordem de Produção final")


//         X1_GRUPO , X1_ORDEM, X1_PERGUNT             , X1_VAR01  , X1_VARIAVL, X1_TIPO, X1_TAMANHO, X1_DECIMAL, X1_GSC, X1_VALID    , X1_F3   , X1_PICTURE , X1_DEF01   , X1_DEF02         , X1_DEF03, X1_DEF04, X1_DEF05, X1_HELP
//u_zPutSX1( _cPerg   , "01"    , "Codigo do Armazem    ", "mv_par01", "mv_ch1"  , "C"    ,  2        , 0         , "G"   , ""          , "NNR"   , ""         , ""         , ""               , ""      , ""      , ""      , aHelpPor[1] )
u_zPutSX1(cPerg,"01","de OP?   " ,"MV_PAR01","mv_ch1","C",15,00,"G","","","","","","","","",aHelp[1])
u_zPutSX1(cPerg,"02","ate OP?  " ,"MV_PAR02","mv_ch2","C",15,00,"G","","","","","","","","",aHelp[2])
u_zPutSX1(cPerg,"03","Data emissao de? " ,"MV_PAR03","mv_ch3","D",08,00,"G","","","","","","","","",aHelp[3])
u_zPutSX1(cPerg,"04","Data emissao ate?" ,"MV_PAR04","mv_ch4","D",08,00,"G","","","","","","","","",aHelp[4])

Return 