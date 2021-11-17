#include "rwmake.ch"       
#include "topconn.ch"
#include "font.ch"   
#include "avprint.ch"    
                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRSACR03  ºAutor  ³Marcos C. Vieira    º Data ³  24/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rel.do SAC Frequência de Reclamações X Tipo de Ocorrências.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSACR03()
     Private nPag
     SetPrvt("cNomeArq,aCampos,cIndex,aInd")

     //VldPerg()  //LGS#20200211 - Adequação de release 12.1.25 e posteriores       
     Pergunte("SACR03", .f.)
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

     oDlg := oSend( MSDialog(), "New", 8, 10, 18, 63,"Frequência de Reclamações X Tipo de Ocorrências.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
     @ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação "
     @ 30,18  SAY "de Frequência de Reclamações X Tipo de Ocorrências."
     @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("SACR03"))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
     If nOpca == 0
        Return
     EndIf

     MsAguarde({|| SACR03_1() },"Aguarde","Este processamento poderá levar alguns minutos...")

     DBSelectArea("TCQ") 
     Dbclosearea()
Return Nil

/*******************************************************************************/
/*** SACR03_1 - Busca dados dos SAC's de acordo com parâmetros.              ***/
/*******************************************************************************/
Static Function SACR03_1()  
       Local cQuery   := ""
       Local cQuery2  := ""
       Local nPos     := 0 
       Local aMatSac  :={}
       Local nQtdTot  := 0     //Qtde total de Sacs
       Local nQtdNP   := 0     //Qtde de Sacs não Procedentes
       Local nQtdNR   := 0     //Qtde de Sacs não Respondidos
       Local cOcorren := ""
       //Local nQtdTot  := 0
       //Local nQtdNP   := 0
       //Local nQtdNR   := 0
       Local dDtInic := Iif(Empty(MV_PAR01), CTOD("01/01/12"), MV_PAR01)
       Local dDtFin  := Iif(Empty(MV_PAR02), dDataBase       , MV_PAR02)
       Local nY
	   	       
       cQuery  +=" SELECT DISTINCT SZQ.ZQ_NUM ,ZR_ASSUNTO, U9_DESC, ZR_OCORREN, SU9.U9_CODIGO FROM "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) "
	   cQuery  +=" LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR WITH (NOLOCK) ON (SZR.D_E_L_E_T_ <> '*') AND (ZR_FILIAL = '"+xFilial("SZR")+"') AND (ZR_NUM = ZQ_NUM) "
	   cQuery  +=" LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (X5_CHAVE = ZR_ASSUNTO) "
	   cQuery  +=" LEFT OUTER JOIN "+RetSqlName("SU9")+" SU9 WITH (NOLOCK) ON (SU9.D_E_L_E_T_ <>'*')  AND (U9_ASSUNTO = ZR_ASSUNTO) AND (ZR_OCORREN = U9_CODIGO) "
	   cQuery  +=" WHERE (SZQ.ZQ_FILIAL ='"+xFilial("SZQ")+"') AND (SZQ.D_E_L_E_T_ <> '*') AND SZQ.ZQ_DATA BETWEEN '"+DTOS(ddtinic)+"' AND '"+DTOS(ddtfin)+"' AND (SX5.D_E_L_E_T_ <> '*') AND (X5_TABELA = 'T1') "
	   If MV_PAR03 = 2
	   		cQuery +=" AND SZQ.ZQ_TIPOSAC ='1' "   // Reclamação
	   Elseif MV_PAR03 = 3                         
			cQuery +=" AND SZQ.ZQ_TIPOSAC ='2' "   // Sugestão
	   Elseif MV_PAR03 = 4
	   		cQuery +=" AND SZQ.ZQ_TIPOSAC ='3' "   // Comodato
	   Elseif MV_PAR03 = 5
	   		cQuery +=" AND SZQ.ZQ_TIPOSAC ='4' "   // Outros
	   Endif
	   cQuery  +=" GROUP BY SZQ.ZQ_NUM, ZR_ASSUNTO, U9_DESC, ZR_OCORREN, SU9.U9_CODIGO "
	   cQuery  +=" ORDER BY SZR.ZR_OCORREN, U9_DESC "
       TCQuery cQuery ALIAS "TCQ" NEW  
       
       DBSelectArea("TCQ")            
       DBGotop()
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
            cQuery2 += " ORDER BY R_E_C_N_O_ DESC "
            TCQuery cQuery2 ALIAS "PRN" NEW
            DbSelectArea("PRN")
            If !Eof()    
                If PRN->ZS_PROCEDE == 'S' // Se procede a reclamação
    				nQtdTot+=1			
    				If cOcorren <> TCQ->ZR_OCORREN
                		cOcorren:= TCQ->ZR_OCORREN
                		aAdd(aMatSac, {Alltrim(TCQ->U9_CODIGO), TCQ->U9_DESC, 1 } )
                	Else
						nPos := aScan( aMatSac, { |x| Alltrim(x[1]) == Alltrim(TCQ->ZR_OCORREN) } )
						aMatSac[nPos][3] += 1						                		 
                    Endif
                Else
                	nQtdNP+=1//Soma Total de Sacs Não Procedentes
				Endif
            Else
            	nQtdNR+=1
            Endif 
                DbSelectArea("PRN")
                DbCloseArea()
       		DbSelectArea("TCQ")
       		DbSkip()
       Enddo         		         
  
       oPrn:= TMSPrinter():New("Frequência de Reclamações X Tipo de Ocorrências.")
       oPrn:SetPortrait()     //SetLandscape()   
	
       AVPRINT oPrn NAME "Frequência de Reclamações X Tipo de Ocorrências."
       ProcRegua(150)
       oFont1    := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
       oFont2    := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
       oFont3    := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
       oFont4    := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.)
       oFont5    := TFont():New("Arial"      ,9,10,.F.,.T.,5,.T.,5,.T.,.F.) 
       AVPAGE
	   For nY:=1 To Len(aMatSac)
			If nPag == 0 .OR. Linha > 3200
            	SACR03_3()
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

       nPerProc  := (nQtdTot * 100 / (nQtdTot+nQtdNP+nQtdNR))
       nPerNProc := (nQtdNP  * 100 / (nQtdTot+nQtdNP+nQtdNR))
       nPercNResp:= (nQtdNR  * 100 / (nQtdTot+nQtdNP+nQtdNR))
       
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
       oPrn:Say( Linha , 0900 , Transform((nQtdTot+nQtdNP+nQtdNR),"@E 999,999") , oFont3 )
       oPrn:Say( Linha , 1380 , Transform((nPerProc+nPerNProc+nPercNResp),"@E 999.99")+"%" , oFont3 )

       AVENDPAGE
       AVENDPRINT


       oFont1:End()
       oFont2:End()
       oFont3:End()
       oFont4:End()
       oFont5:End()

       MS_FLUSH()
Return nil

/*******************************************************************************/
/*** SACR03_3 - Cabeçalho do SAC.                                            ***/
/*******************************************************************************/
Static Function SACR03_3()
       If Linha <> 0
          AVNEWPAGE
       Endif

       nPag  += 1
       Linha := 10
       cMes  := MesExtenso(Month(MV_PAR01))

       oPrn:Say( Linha , 010  , ALLTRIM(SM0->M0_FILIAL)+"/BRSACR03"                , oFont1 )
       oPrn:Say( Linha , 520  , "FREQUÊNCIA DE RECLAMAÇÕES X TIPO DE OCORRÊNCIAS"  , oFont2 )
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
       oPrn:Say( Linha , 0010 , "TIPO DE OCORRÊNCIAS"                             , oFont3 )
       oPrn:Say( Linha , 0900 , "QTD.OCORRÊNCIAS"                                 , oFont3 )
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
       Local aHelp       := {}  
       aAdd( aHelp, "Informe o periodo desejado para" )
       aAdd( aHelp, "a emissão do relatório.        " )

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inclui parametros de consulta                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      //     X1_GRUPO  X1_ORDEM  X1_PERGUNT     X1_PERSPA      X1_PERENG      X1_VARIAVL X1_TIPO X1_TAMANHO X1_DECIMAL X1_PRESEL X1_GSC X1_VALID X1_F3 X1_GRPSXG X1_PYME X1_VAR01    X1_DEF01 X1_DEFSPA1 X1_DEFENG1 X1_CNT01 X1_VAR02 X1_DEF02 X1_DEFSPA2 X1_DEFENG2 X1_CNT02 X1_VAR03 X1_DEF03 X1_DEFSPA3 X1_DEFENG3 X1_CNT03 X1_VAR04 X1_DEF04 X1_DEFSPA4 X1_DEFENG4 X1_CNT04 X1_VAR05 X1_DEF05 X1_DEFSPA5 X1_DEFENG5 X1_CNT05 X1_HELP
      PutSX1("SACR03    ", "01",          "Do Periodo ", "Do Periodo           ", "Do Periodo           ", "mv_ch1",  "D",    8,     0,     0,    "G",   " ",     " ",  " ",      " ",    "mv_par01",     " ",     " ",       " ",      " ",          " ",         " ",         " ",        Nil,        Nil,        Nil,        Nil,        Nil,        Nil,      Nil,      Nil,      Nil,     aHelp,     aHelp,     Nil )
      PutSX1("SACR03    ", "02",          "Até Periodo", "Até Periodo          ", "Até Periodo          ", "mv_ch2",  "D",    8,     0,     0,    "G",   " ",     " ",  " ",      " ",    "mv_par02",     " ",     " ",       " ",      " ",          " ",         " ",         " ",        Nil,        Nil,        Nil,        Nil,        Nil,        Nil,      Nil,      Nil,      Nil,     aHelp,     aHelp,     Nil )
	  PutSX1("SACR03    ", "08","Escolha o tipo de Sac", "Escolha o tipo de Sac", "Escolha o tipo de Sac", "mv_ch3",  "N",    1,     0,     1,    "C",   " ",     " ",  " ",      " ",    "mv_par03", "Todos", "Todos",   "Todos",      " ", "Reclamação","Reclamação","Reclamação", "Sugestão", "Sugestão", "Sugestão", "Comodato", "Comodato", "Comodato", "Outros", "Outros", "Outros",     aHelp,     aHelp,     Nil )
Return*/