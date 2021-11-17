#include "rwmake.ch"       
#include "topconn.ch"
#include "font.ch"   
#include "avprint.ch"    
                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRSACR15  ºAutor  ³André C Maester     º Data ³  16/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rel.do SAC Frequência de Reclamações X Produtos            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSACR15()
     Private nPag
     SetPrvt("cNomeArq,aCampos,cIndex,aInd")

     VldPerg()       
     Pergunte("SACR15", .f.)
     cIndex     := ""
     aInd       := {}                        
     cNomeArq   := ""
     aCampos    := {}
     Linha      := 0                
     nOpcA      := 0                
     nPag       := 0 
     nTotPer    := 0 
     dDtInic    := CTOD("")
     dDtFin     := CTOD("")

     oDlg := oSend( MSDialog(), "New", 8, 11, 19, 63,"Frequência de Reclamações X Produtos.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
     @ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação "
     @ 30,18  SAY "de Frequência de Reclamações X Produto"
     @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("SACR15"))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
     If nOpca == 0
        Return
     EndIf

     MsAguarde({|| SACR15_1() },"Aguarde","Este processamento poderá levar alguns minutos...")

     DBSelectArea("TCQ") 
     Dbclosearea()
Return Nil

/*******************************************************************************/
/*** SACR15_1 - Busca dados dos SAC's de acordo com parâmetros.              ***/
/*******************************************************************************/
Static Function SACR15_1()  
	
	Local cQuery   := ""
    Local cQuery1  := ""
    Local cQuery2  := ""
	Local cQuery3  := ""
    Local nPos     := 0 
    Local aMatSac  :={}
    Local nQtdTot  := 0     //Qtde total de Sacs
    Local nQtdNP   := 0     //Qtde de Sacs não Procedentes
    Local nQtdNR   := 0     //Qtde de Sacs não Respondidos
    Local cOcorren := ""
    //Local nQtdTot  := 0
    //Local nQtdNP   := 0
    //Local nQtdNR   := 0
    Local nTotal   := 0
    Local nY
    //Local dDtInic := Iif(Empty(MV_PAR01), CTOD("01/01/15"), MV_PAR01)
    //Local dDtFin  := Iif(Empty(MV_PAR02), dDataBase       , MV_PAR02)
       
	cQuery  +=" SELECT ZQ_NUM, ZR_PRODUTO, B1_DESC, COUNT(ZR_PRODUTO) AS QTDPROD "
	cQuery1 +=" SELECT COUNT(ZR_PRODUTO) AS NTOTAL"
	cQuery2 +=" FROM "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) " 
	cQuery2 +=" LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON A1_FILIAL = A1_FILIAL AND A1_COD = ZQ_CLIENTE AND SA1.D_E_L_E_T_ =''
	cQuery2 +=" LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR WITH (NOLOCK) ON ZR_FILIAL = ZQ_FILIAL AND ZR_NUM = ZQ_NUM AND SZR.D_E_L_E_T_ =''
	cQuery2 +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = ZR_FILIAL AND B1_COD = ZR_PRODUTO AND SB1.D_E_L_E_T_ =''
	cQuery2 +=" WHERE ZQ_FILIAL =('"+xFilial("SZR")+"') "
	cQuery2 +=" AND SZQ.D_E_L_E_T_ ='' " 
	cQuery2 +=" AND ZQ_DATA BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"') "  
	cQuery2 +=" AND ZR_PRODUTO BETWEEN ('"+(MV_PAR03)+"')  AND ('"+(MV_PAR04)+"') "
	if !empty(MV_PAR05)  
       cQuery2 += "AND (LEN(ZR_PRODUTO) = 12) AND "+U_ParamSql("SUBSTRING(ZR_PRODUTO,4,2)",MV_PAR05)+" "
  	endif    
	cQuery2 +=" AND ZR_ASSUNTO BETWEEN ('"+(MV_PAR05)+"')  AND ('"+(MV_PAR06)+"') " // FILTRA SOMENTE SACS TÉCNICO E PRODUÇÃO
	cQuery2 +=" AND B1_TIPO ='PA' " 
	cQuery3 +=" GROUP BY ZQ_NUM, ZR_PRODUTO, B1_DESC "
	cQuery3 +=" ORDER BY SUBSTRING(ZR_PRODUTO,4,2), ZR_PRODUTO  "

	TCQUERY cQuery1+cQuery2 NEW ALIAS "TCOUNT"

	Dbselectarea("TCOUNT")

	If !Eof()
		nTotal := TCOUNT->NTOTAL 
	Endif

	Dbselectarea("TCOUNT")
	DbCloseArea()
	       

	TCQUERY cQuery+cQuery2+cQuery3 NEW ALIAS "TCQ"

	DbSelectArea("TCQ")
    DbGoTop()

    If EOF()
       	ApMsgStop("Nao ha dados a serem gerados com estes parametros.", "Atenção")
	   	DBSelectArea("TCQ") 
       	Dbclosearea()
       	Return
    Endif
    
    While !Eof()
		cQuery2 := " "
    	cQuery2 += " SELECT TOP 1 SZS.ZS_PROCEDE "
        cQuery2 += " FROM "+RetSQLName("SZS")+" SZS WITH (NOLOCK) "
        cQuery2 += " WHERE SZS.ZS_FILIAL   = '"+xFilial("SZS")+"' "
        cQuery2 += "  AND SZS.D_E_L_E_T_  = '' "
        cQuery2 += "  AND SZS.ZS_NUM      = '"+TCQ->ZQ_NUM+"' "
        cQuery2 += "  AND SZS.ZS_PROCEDE <> '' "
        //cQuery2 += "  AND SZS.ZS_LOG IN('DIR','TEC') "
		cQuery2 += " ORDER BY R_E_C_N_O_ DESC "
        TCQuery cQuery2 ALIAS "PRN" NEW
        DbSelectArea("PRN")
        If !Eof()    
    	    If PRN->ZS_PROCEDE == 'S' // Se procede a reclamação
    			nQtdTot+=TCQ->QTDPROD
    			If Substr(cOcorren,1,10) <> Substr(TCQ->ZR_PRODUTO,1,10)
               		cOcorren:= TCQ->ZR_PRODUTO
			        aAdd(aMatSac, {SUBSTR(TCQ->ZR_PRODUTO,1,10), Alltrim(TCQ->B1_DESC), TCQ->QTDPROD } )
              	Else
					nPos := aScan( aMatSac, { |x| Alltrim(x[1]) == Alltrim(SUBSTR(TCQ->ZR_PRODUTO,1,10)) } )
					aMatSac[nPos][3] += TCQ->QTDPROD						                		 
                Endif
            Else
               	nQtdNP+=TCQ->QTDPROD //Soma Total de Sacs Não Procedentes
			Endif
   		Else
           	nQtdNR+=TCQ->QTDPROD
        Endif 
        
        DbSelectArea("PRN")
        DbCloseArea()
   		
       	DbSelectArea("TCQ")
       	DbSkip()
    Enddo         		         
  
    oPrn:= TMSPrinter():New("Frequência de Reclamações por Produto.")
    oPrn:SetPortrait()     //SetLandscape()   
	
    AVPRINT oPrn NAME "Frequência de Reclamações por Produto."
    ProcRegua(150)
    oFont1    := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
    oFont2    := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
    oFont3    := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
    oFont4    := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.)
    oFont5    := TFont():New("Arial"      ,9,10,.F.,.T.,5,.T.,5,.T.,.F.) 
    AVPAGE
	
	ASORT(aMatSac, , , { | x,y | x[3] > y[3] } )
	
	For nY:=1 To Len(aMatSac)
		If nPag == 0 .OR. Linha > 3200
           	SACR15_3()
   		Endif                               
       
	    nPerOcor := (aMatSac[nY][3] * 100 / nQtdTot)
        nTotPer  += nPerOcor
           
        oPrn:Say( Linha , 0010 , aMatSac[nY][1]+" - "+aMatSac[nY][2]      , oFont4 )
        oPrn:Say( Linha , 0900 , Transform(aMatSac[nY][3] ,"@E 999,999")  , oFont4 )
        oPrn:Say( Linha , 1380 , Transform(nPerOcor     ,"@E 999.99")+"%" , oFont4 )
        Linha += 60
    Next
        
    Linha += 20
    oPrn:Say( Linha , 0010 , "Total de Reclamações Procedentes : " , oFont3 )
    oPrn:Say( Linha , 0900 , Transform(nQtdTot ,"@E 999,999")      , oFont3 )
    oPrn:Say( Linha , 1380 , Transform(nTotPer ,"@E 999.99")+"%"   , oFont3 )

    nPerProc  := (nQtdTot * 100 / (nTotal)) //(nQtdTot+nQtdNP+nQtdNR))  // RECLAMAÇÕES PROCEDENTES
    nPerNProc := (nQtdNP  * 100 / (nTotal))//(nQtdTot+nQtdNP+nQtdNR))  // RECLAMAÇÕES NÃO PROCEDENTES
    nPercNResp:= (nQtdNR  * 100 / (nTotal))//(nQtdTot+nQtdNP+nQtdNR))  // RECLAMAÇÕES SEM RESPOSTA
       
    Linha += 150
    oPrn:Say( Linha , 0010 , "Reclamações Procedentes : "           , oFont4 )
    oPrn:Say( Linha , 0900 , Transform(nQtdTot ,"@E 999,999")       , oFont4 )
    oPrn:Say( Linha , 1380 , Transform(nPerProc,"@E 999.99")+"%"    , oFont4 )
        
    Linha += 50
    oPrn:Say( Linha , 0010 , "Reclamações não Procedentes : "       , oFont4 )
    oPrn:Say( Linha , 0900 , Transform(nQtdNP ,"@E 999,999")        , oFont4 )
    oPrn:Say( Linha , 1380 , Transform(nPerNProc  ,"@E 999.99")+"%" , oFont4 )

    Linha += 50
    oPrn:Say( Linha , 0010 , "Reclamações sem Parecer : "           , oFont4 )
    oPrn:Say( Linha , 0900 , Transform(nQtdNR ,"@E 999,999")        , oFont4 )
    oPrn:Say( Linha , 1380 , Transform(nPercNResp, "@E 999.99")+"%" , oFont4 )
        
    Linha += 50   
    oPrn:Say( Linha , 0010 , "Total: "                                       , oFont3 )
    oPrn:Say( Linha , 0900 , Transform((nTotal),"@E 999,999") , oFont3 )
    oPrn:Say( Linha , 1380 , Transform((nPerProc+nPerNProc+nPercNResp),"@E 999.99")+"%" , oFont3 )
    AVENDPAGE
    AVENDPRINT


    oFont1:End()
    oFont2:End()
    oFont3:End()
    oFont4:End()
    oFont5:End()

    MS_FLUSH()
Return

/*******************************************************************************/
/*** SACR15_3 - Cabeçalho do SAC.                                            ***/
/*******************************************************************************/
Static Function SACR15_3()
       If Linha <> 0
          AVNEWPAGE
       Endif

       nPag  += 1
       Linha := 10
       cMes  := MesExtenso(Month(MV_PAR01))

       oPrn:Say( Linha , 010  , ALLTRIM(SM0->M0_FILIAL)+"/BRSACR15"                , oFont1 )
       oPrn:Say( Linha , 520  , "FREQUÊNCIA DE RECLAMAÇÕES POR PRODUTO"  , oFont2 )
       oPrn:Say( Linha , 2100 , "PAG........:"                                     , oFont1 )
       oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                                    , oFont1 )
       Linha += 70
       oPrn:Say( Linha , 10   , "Ref.ao Período: "+DTOC(ddtinic)+" a "+DTOC(ddtfin), oFont3 )
       oPrn:Say( Linha , 2100 , "Emissao.:"                                        , oFont3 )
       oPrn:Say( Linha , 2240 , DTOC(dDataBase)                                    , oFont3 )
       Linha += 40
       //TRACO_BOLD1
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
       Linha += 20
       oPrn:Say( Linha , 0010 , "PRODUTOS"     				                      , oFont3 )
       oPrn:Say( Linha , 0900 , "RECL.PROCEDENTES"                                , oFont3 )
       oPrn:Say( Linha , 1350 , "PERCENTUAL"                                      , oFont3 )
       Linha += 70
       //TRACO_BOLD1
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
       Linha += 30 
Return NIL                              
    
/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg() 

Local aHelpPor := {}

   AAdd(aHelpPor, {{"Informe a data Inicial a ser consultada"			  }, {""}, {""}})
   AAdd(aHelpPor, {{"Informe a data final a ser consultada"				  }, {""}, {""}})
   AAdd(aHelpPor, {{"Informe o código do produto"                         }, {""}, {""}})
   AAdd(aHelpPor, {{"Informe o código do produto"                         }, {""}, {""}})
   AAdd(aHelpPor, {{"Apenas a(s) linha(s) de Prod?"                       }, {""}, {""}})
   //AAdd(aHelpPor, {{"Informe o tipo de relatório (Analitico ou Sintético)"}, {""}, {""}})
       
   PutSx1( 'SACR15', '01', 'Da Data             ? ' , '', '', 'mv_ch1', 'D',08,00,00, 'G', '', ''        , ''          , '', 'mv_par01', ''         , '', ''		 , '', ''     , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[1,1], {}, {} )
   PutSx1( 'SACR15', '02', 'Ate a Data          ? ' , '', '', 'mv_ch2', 'D',08,00,00, 'G', '', ''        , ''          , '', 'mv_par02', ''         , '', ''		 , '', ''     , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[2,1], {}, {} )
   PutSX1( 'SACR15', '03', 'Do Produto          ? ' , '', '', 'mv_ch3', 'C',15,00,00, 'G', '', 'SB1'	 , ''          , '', 'mv_par03', ''		    , '', ''		 , '', ''	  , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[3,1], {}, {} )
   PutSX1( 'SACR15', '04', 'Até o Produto       ? ' , ''               , ''               ,'mv_ch4','C',15,00,00,'G','','SB1','', '','mv_par04', ''		    , '', ''		 , '', ''	  , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[4,1], {}, {} )
   PutSX1( 'SACR15', "05","Linha(s) Produto"        ,"Linha(s) Produto","Linha(s) Produto","mv_ch5","C",99,00,00,"G","","", "", "", "mv_Par05",""           ,"" ,""          ,"" ,""      ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" , aHelpPor[5,1], {}, {},"")
   PutSX1( 'SACR15', '06', 'De Assunto          ? ' , '', '', 'mv_ch6', 'C',6,00,00, 'G','','T1','','','mv_par05', '', '', '', '', ''	  , '', '', '', '', '', '', '', '', '', '', '',{} , {}, {} )
   PutSX1( 'SACR15', '07', 'Até Assunto       ?   ' , '', '', 'mv_ch7', 'C',6,00,00,'G','' ,'T1','','','mv_par06', '', '', '', '', ''	  , '', '', '', '', '', '', '', '', '', '', '', {}, {}, {} )
    //PutSX1( 'BRSACR15', '05', 'Analitico/Sintético ? ' , '', '', 'mv_ch7', 'N',01,00,01, 'C', '', ''        , ''          , '', 'mv_par07', 'Analitico', '', 'Sintético', '', ''     , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[5,1], {}, {} )
Return*/