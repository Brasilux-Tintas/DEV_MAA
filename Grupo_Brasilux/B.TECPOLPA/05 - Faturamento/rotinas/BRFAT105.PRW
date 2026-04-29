#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ BRFAT105 บ Autor ณ Nelieder Corneta   บ Data ณ  26/10/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Relat๓rio CT-e                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


User Function BRFAT105()

 Local oReport := nil
 Local cPerg   := Padr("BRFAT105",10)
 Local xNome   := "Relat๓rio CT-e"
 Local Xdescri := "Relat๓rio CT-e"


 Private cQuery1    := ""        

   Pergunte(cPerg,.F.)              
   oReport := RptDef(cPerg,xNome,Xdescri)
   oReport:PrintDialog()

return()

Static Function RptDef(xPergunta,xNome,Xdescri)
    
	Local oReport := Nil
    Local oSection1:= Nil
    
    oReport := TReport():New(xPergunta,xNome,xPergunta,{|oReport| ReportPrint(oReport)},Xdescri)
    
    oReport:nfontbody:= 8
    oReport:cfontbody:="Arial"
    
    oReport:SetPortrait(.T.) // retrato    
	oReport:SetLandscape(.F.) // paisagem
    oReport:SetTotalInLine(.F.) // Define se os totalizadores serใo impressos em linha ou coluna
   
  
    oSection1:= TRSection():New(oReport,xNome,,, .F., .T.)

    /* campos para impressใo do relat๓rio */
    //TRCell():New(oSection1,"CHAVE"   ,"QCON","Nบ Chave"        ,"@!"            ,200,,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"cDATA"   ,"QCON","Emissao CT-e"    ,""            ,40, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"CTE"     ,"QCON","Nบ CT-e"         ,"@!"            ,40, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"CTESER"  ,"QCON","CT-e Serie"      ,"@!"            ,40, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"CTE_VAL" ,"QCON","Valor CT-e"      ,"@E 999,999.99" ,45, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"NOTA"    ,"QCON","Nota Fiscal"     ,"@!"            ,50, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"SERIE"   ,"QCON","Serie"           ,"@!"            ,30, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"VLNOTA"  ,"QCON","Vlr Nota Fiscal" ,"@E 999,999.99" ,60, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"CODIGO"  ,"QCON","Cod Cliente"     ,"@!"            ,60, ,,"LEFT" ,  , "LEFT")
    TRCell():New(oSection1,"NOME"    ,"QCON","Nome Cliente"    ,"@!"            ,100,,,"LEFT" ,  , "LEFT")
    
       
Return(oReport)


Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local cError    := ""
Local cWarning  := ""
Local ChaveSF2    := ""
Local cCTE      := ""
Local cCTESER   := "" 
Local cCTEVAL   := ""
Local cNota     := ""
Local cSerie    := ""
Local cVLnota   := ""
Local cCodCli   := ""
Local cNome     := ""
Local i

    

    oReport:SetMsgPrint("Aguarde selecionando Registros...")

    cQuery1 := " SELECT * FROM "+RetSqlName("ZNF")+" ZNF WHERE "
    cQuery1 += " ZNF_DTEMIS BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"' AND ZNF_TPDOC = 'CT-e' " 
    cQuery1 += " AND D_E_L_E_T_ = '' ORDER BY ZNF_DTEMIS,ZNF_TPDOC "

     /* verifica se arquivo estแ aberto e finaliza */
    IF Select("QCON") <> 0
        DbSelectArea("QCON")
        DbCloseArea()
    ENDIF
    
    TCQUERY cQuery1 NEW ALIAS "QCON"  
    Count To nTotal 
    //oReport:SetMsgPrint("Registros encontrados "+cValToChar(nTotal)) 
    
    dbSelectArea("QCON")
    QCON->(dbGoTop())

    While !QCON->(eof())

     /* localiza XML */
     DbSelectArea("ZNF")
     DbSetOrder(1)
     
     //tem chave
     DbSeek(xFilial("ZNF")+QCON->ZNF_CHAVE , .T.)
     vChave := QCON->ZNF_CHAVE
     oXml := XmlParser( ZNF->ZNF_XML, "_", @cError, @cWarning )

    /* verifica se o xml ้ CT-e */
    If(XmlChildEx (oXml,"_CTEPROC") != Nil) .AND. (XmlChildEx (oXml:_CTEPROC:_CTE,"_INFCTE") != Nil) 
      
     if (XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") != Nil)

      If (XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC,"_INFNFE") != Nil) 
      
    
        /* verifica se possui documentos originais SF2 */       
        If(XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") != Nil) 
            if ValType(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe) == "O"
                ChaveSF2 := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe:_Chave:Text
                cCTE    := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT
                cCTESER := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT
                cCTEVAL := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT
                cNota   := ""
                cSerie  := ""
                cVLnota := ""   
                cCodCli := ""
                cNome   := ""
                Printa(oReport,vChave,cCTE,cCTESER,cCTEVAL,cNota,cSerie,cVLnota,cCodCli,cNome,ChaveSF2)
            elseif ValType(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe) == "A"
                for i := 1 To len(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe)
                cPassou := i 
                ChaveSF2  := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe[i]:_Chave:Text
                cCTE    := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT
                cCTESER := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT
                cCTEVAL := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT
                Printa(oReport,vChave,cCTE,cCTESER,cCTEVAL,cNota,cSerie,cVLnota,cCodCli,cNome,ChaveSF2)
                Next i
            
            Endif
        else
            Printa(oReport,vChave,cCTE,cCTESER,cCTEVAL,cNota,cSerie,cVLnota,cCodCli,cNome,ChaveSF2)
        Endif     

        ChaveSF2  := ""
        cCTE    := ""
        cCTESER := ""
        cCTEVAL := ""
        cNota   := ""
        cSerie  := ""
        cVLnota := ""   
        cCodCli := ""
        cNome   := ""

        Endif
      Endif  
    Endif    

        QCON->(dbSkip())

    
    Enddo

    //finalizo a primeira se็ใo
    oSection1:Finish()


Return()

Static Function Printa(oReport,vChave,cCTE,cCTESER,cCTEVAL,cNota,cSerie,cVLnota,cCodCli,cNome,ChaveSF2)
Local oSection1 := oReport:Section(1)
Local cQuery2
Local iTotal

 

        If(XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") != Nil)
            
            
            /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			# localiza NF de Saida Original pela chave                                  #
		    ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
            cQuery2 := " SELECT * FROM "+RetSqlName("SF2")+" SF2 "
            cQuery2 += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_COD = F2_CLIENTE AND SA1.D_E_L_E_T_ = '' AND F2_LOJA = A1_LOJA AND A1_FILIAL = '"+xFilial("SA1")+"' "
            cQuery2 += " WHERE F2_CHVNFE = '"+ChaveSF2+"' AND F2_FILIAL = '"+xFilial("SF2")+"'  "
            cQuery2 += " AND SF2.D_E_L_E_T_ = '' "

            /* verifica se arquivo estแ aberto e finaliza */
            IF Select("TSF2") <> 0
                DbSelectArea("TSF2")
                DbCloseArea()
            ENDIF
        
            TCQUERY cQuery2 NEW ALIAS "TSF2"  

            Count To iTotal 

            if (iTotal > 0)
                dbSelectArea("TSF2")
                TSF2->(dbGoTop())
                cNota   := TSF2->F2_DOC
                cSerie  := TSF2->F2_SERIE
                cVLnota := TSF2->F2_VALBRUT
                cCodCli := TSF2->F2_CLIENTE
                cNome   := TSF2->A1_NREDUZ

                /* inicializo a primeira se็ใo */
                oSection1:Init()

                //oSection1:Cell("CHAVE"):SetValue(vChave)
                oSection1:Cell("cDATA"):SetValue(sTOd(QCON->ZNF_DTEMIS))
                //oSection1:Cell("cDATA"):SetValue('')
                
                oSection1:Cell("CTE"):SetValue(cCTE)

                oSection1:Cell("CTESER"):SetValue(cCTESER)

                oSection1:Cell("CTE_VAL"):SetValue(Val(cCTEVAL))

                oSection1:Cell("NOTA"):SetValue(cNota)

                oSection1:Cell("SERIE"):SetValue(cSerie)
                
                oSection1:Cell("VLNOTA"):SetValue(cVLnota)

                oSection1:Cell("CODIGO"):SetValue(cCodCli)

                oSection1:Cell("NOME"):SetValue(cNome)       
                
                oSection1:Printline()
                oReport:SkipLine()
                oReport:ThinLine()

            Endif   

        Endif     

      


Return()
