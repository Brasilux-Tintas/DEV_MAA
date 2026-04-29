#include "protheus.ch"
#include 'tbiconn.ch'
#include "rwmake.ch"
#include "topconn.ch"
#include 'DIRECTRY.CH'       
#INCLUDE "AP5MAIL.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ BRFAT108 บ Autor ณ Nelieder Corneta   บ Data ณ  01/09/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Exporta XMK CT-e para banco de dados                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


/*
Array
[1]  Status
[2]  Sit.NF
[3]  Sit.Protheus
[4]  Sit.XML
[5]  Manifesto
[6]  Chave CT-E

[7]  Nบ Doc Entrada
[8]  Serie
[9]  Loja
[10] codigo Fornecedor
[11] Nome Fornecedor
[12] Vlr IMCS
[13] Vlr COFINS
[14]  Vlr Pis

[15] CNPJ TRANSP
[16] RAZรO TRANSP
[17] CODIGO TRANSP

[18] Nบ CTE
[19] Serie CTE
[20] Emissao CTE
[21] Vlr CTE
[22] cidade destino
[23] UF destino
[24] Chave SF2

[25] Doc SF2
[26] Serie SF2
[27] Vlr Bruto SF2
[28] Cod Cliente SF2
[29] Nome SF2
[30] Loja SF2
*/


User Function BRFAT108()


    //processa tecpolpa
    RpcSetType(3)
    PREPARE ENVIRONMENT EMPRESA "11" FILIAL "11" TABLES "ZNF","SA2","SA3","SF2","ZA9"
    
    Processa()
    
    TxtMail := "Sincronismo CT-e BRFAT108 "+DToC(dDataBase)+" - "+Time()+" Empresa "+alltrim(FWGrpCompany())
    U_EnvMail("Sincronismo CT-e",TxtMail,"neliedercorneta@brasilux.com.br","","")
    RESET ENVIRONMENT

    // processa Brasilux
    RpcSetType(3)
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" TABLES "ZNF","SA2","SA3","SF2","ZA9"
        
    Processa()

    TxtMail := "Sincronismo CT-e BRFAT108 "+DToC(dDataBase)+" - "+Time()+" Empresa "+alltrim(FWGrpCompany())
    U_EnvMail("Sincronismo CT-e",TxtMail,"neliedercorneta@brasilux.com.br","","")
    RESET ENVIRONMENT

return
    
Static Function Processa()
Local cQuery1
Local cError   := ""
Local cWarning := ""
Local i
Local Array    := {}

    cQuery1 := " SELECT  F1_VALICM,F1_VALIMP5 COFINS,F1_VALIMP6 PIS, "
    cQuery1 += " CASE "
    cQuery1 += " WHEN ZNF_XML IS NULL   AND ZNF_SITNFE <> 3			               				   THEN 'NF COM PENDENCIA' "
    cQuery1 += " WHEN ZNF_DOC = ''      AND ZNF_SITNFE <>  3     AND F1_DOC  IS NULL	   THEN 'NF COM PENDENCIA' "
    cQuery1 += " WHEN ZNF_DOC <> ''     AND ZNF_XML IS NOT NULL  AND ZNF_SITNFE <> 3     THEN 'NF OK' "
    cQuery1 += " WHEN ZNF_SITNFE = 3    AND ZNF_DOC = ''         AND ZNF_SITNFE =  3	   THEN 'NF OK' "
    cQuery1 += " WHEN ZNF_DOC = ''      AND ZNF_SITNFE <>  3     AND F1_DOC  IS NOT NULL THEN 'NF OK' "
    cQuery1 += " END STATUS, "

    cQuery1 += " CASE "
    cQuery1 += " WHEN ZNF_SITNFE = 3  THEN 'NF CANCELADA' "
    cQuery1 += " WHEN ZNF_SITNFE <> 3 THEN 'Uso Autorizado' "
    cQuery1 += " END STNF, "

    cQuery1 += " CASE  "
    cQuery1 += " WHEN F1_DOC  IS NULL     THEN 'NF NAO EXISTE' "
    cQuery1 += " WHEN F1_DOC  IS NOT NULL THEN 'NOTA' "
    cQuery1 += " END SITPROTHEUS, "

    cQuery1 += " CASE "
    cQuery1 += " WHEN ZNF_XML IS NULL      THEN 'XML NรO GUARDADO' "
    cQuery1 += " WHEN ZNF_XML IS NOT NULL  THEN 'XML GUARDADO' "
    cQuery1 += " END SITXML, "
   
    cQuery1 += " CASE  "
    cQuery1 += " WHEN ZNF_SITNFE = '1' THEN 'CTE DISPONIVEL' "
    cQuery1 += " WHEN ZNF_SITNFE = '3' THEN 'SEM MANIFESTACAO' "
    cQuery1 += " END MANIFESTO, * "

    cQuery1 += " FROM "+RetSqlName("ZNF")+" "
    cQuery1 += " LEFT JOIN "+RetSqlName("SF1")+" SF1 ON SF1.D_E_L_E_T_ = '' AND F1_CHVNFE = ZNF_CHAVE "
    cQuery1 += " LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = '' AND F1_FORNECE = A2_COD "
    cQuery1 += " WHERE ZNF_TPDOC IN ('CT-e','CTEC') AND ZNF_XML <> '' "
    //cQuery1 += " AND ZNF_CHAVE = '35221218651210000105570010000000791000001107' "
    cQuery1 += " ORDER BY ZNF_CHAVE "
    //cQuery1 += " ORDER BY ZNF_DTEMIS,ZNF_CHAVE "

     /* verifica se arquivo estแ aberto e finaliza */
    IF Select("QCON") <> 0
        DbSelectArea("QCON")
        DbCloseArea()
    ENDIF
    
    TCQUERY cQuery1 NEW ALIAS "QCON"  
    Count To nTotal 
       
    dbSelectArea("QCON")
    QCON->(dbGoTop())

    While !QCON->(eof())

    Array := {}
    
     /* localiza XML */
     DbSelectArea("ZNF")
     DbSetOrder(1)
     
     //tem chave
     DbSeek(xFilial("ZNF")+QCON->ZNF_CHAVE , .T.)

     Aadd(Array,{QCON->STATUS      ,'Status'})       // 1
     Aadd(Array,{QCON->STNF        ,'Sit.NF'})       // 2
     Aadd(Array,{QCON->SITPROTHEUS ,'Sit.Protheus'}) // 3
     Aadd(Array,{QCON->SITXML      ,'Sit.XML'})      // 4
     Aadd(Array,{QCON->MANIFESTO   ,'Manifesto'})    // 5
     
     Aadd(Array,{QCON->ZNF_CHAVE   ,'Chave CT-E'})   // 6

     
     Aadd(Array,{QCON->F1_DOC      ,'Nบ Doc Entrada'})   // 7 
     Aadd(Array,{QCON->F1_SERIE    ,'Serie'})   // 8 
     Aadd(Array,{QCON->F1_LOJA     ,'Loja'})   // 9 
     Aadd(Array,{QCON->F1_FORNECE  ,'codigo Fornecedor'})   // 10 
     Aadd(Array,{QCON->A2_NOME     ,'Nome Fornecedor'})   // 11 

     Aadd(Array,{QCON->F1_VALICM   ,'Vlr IMCS'})   // 12
     Aadd(Array,{QCON->F1_VALIMP5  ,'Vlr COFINS'})   // 13
     Aadd(Array,{QCON->F1_VALIMP6  ,'Vlr Pis'})   // 14
     

     oXml := XmlParser( ZNF->ZNF_XML, "_", @cError, @cWarning )

    /* verifica se o xml ้ CT-e */
    If(XmlChildEx (oXml,"_CTEPROC") != Nil) .AND. (XmlChildEx (oXml:_CTEPROC:_CTE,"_INFCTE") != Nil) 
      
        if (XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") != Nil)

            If (XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC,"_INFNFE") != Nil) 
        
        
                //Trasnportador
                    If(XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE:_EMIT,"_XNOME") != Nil) 
                        
                        Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT,'CNPJ TRANSP'}) /* 15 CNPJ TRANSP */
                        Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT,' RAZรO TRANSP'}) /* 16 RAZรO TRANSP */
                        
                        DbSelectArea("SA4")
                        DbSetOrder(3)
                        If DbSeek( xFilial("SA4") + PADR(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT,14) )
                            Aadd(Array,{AllTrim(SA4->A4_COD),' CODIGO TRANSP'}) /* 17 CODIGO TRANSP */
                        Else
                            Aadd(Array,{'',' CODIGO TRANSP'}) /* 17 CODIGO TRANSP */
                        EndIf

                    else

                        Aadd(Array,{'','CNPJ TRANSP'})  /* 15  CNPJ TRANSP */
                        Aadd(Array,{'','RAZรO TRANSP'}) /* 16 RAZรO TRANSP */
                        Aadd(Array,{'','CODIGO TRANSP'}) /* 17 CODIGO TRANSP */

                    Endif  
        
                    /* verifica se possui documentos originais SF2 */       
                    If(XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") != Nil) 

                        Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT,'Nบ CTE'}) /* 18 nบ CTE*/

                        Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT,'Serie CTE'}) /* 19 serie CTE */

                        Aadd(Array,{(SUBSTR(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,1,4))+(SUBSTR(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,6,2))+(SUBSTR(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,9,2)),'Emissao CT-e'}) /* 20 Emissao CTE */

                        Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT,'Valor CT-e'}  ) /* 21 Vlr CTE */

                        Aadd(Array,{Alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_XMUN:TEXT),'Cidade Destino'}) /* 22 cidade destino */
                    
                        Aadd(Array,{Alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT),'UF Destino'}) /* 23 UF destino */

                            if ValType(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe) == "O"

                                //ChaveSF2 := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe:_Chave:Text
                                Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe:_Chave:Text,'Chave SF2'}) /* 24 Chave SF2 */
                                LocNota(Array)

                            elseif ValType(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe) == "A"
                                for i := 1 To len(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe)
                                //ChaveSF2  := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe[i]:_Chave:Text
                                Aadd(Array,{Alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infDoc:_infNFe[i]:_Chave:Text),'Chave SF2'}) /* 24 Chave SF2 */
                                LocNota(Array)

                                ADel( Array, 24 )
                                ADel( Array, 25 )
                                ADel( Array, 25 )
                                ADel( Array, 26 )
                                ADel( Array, 27 )
                                ADel( Array, 28 )
                                ADel( Array, 29 )
                                ADel( Array, 30 )
                                ADel( Array, 31 )
                                ASize( Array, 23 )
                                Next i
                            
                            Endif
                    else
                            LocNota(Array)
                    Endif     


            Endif
            
        Endif  

    Endif    

        QCON->(dbSkip())

    
    Enddo

    
return()



Static Function LocNota (Array)
Local cQuery2
Local iTotal

   //If(XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") != Nil)

            /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			  # localiza NF de Saida Original pela chave                                  #
		    ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
            cQuery2 := " SELECT * FROM "+RetSqlName("SF2")+" SF2 "
            cQuery2 += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_COD = F2_CLIENTE AND SA1.D_E_L_E_T_ = '' AND F2_LOJA = A1_LOJA AND A1_FILIAL = '"+xFilial("SA1")+"' "
            cQuery2 += " WHERE F2_CHVNFE = '"+Array[24][1]+"' AND F2_FILIAL = '"+xFilial("SF2")+"'  "
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
                Aadd(Array,{TSF2->F2_DOC     ,'Nota    SF2'}) /* 25 Doc SF2 */ 
                Aadd(Array,{TSF2->F2_SERIE   ,'Serie   SF2'}) /* 26 Serie SF2 */
                Aadd(Array,{TSF2->F2_VALBRUT ,'Vlr     SF2'}) /* 27 Vlr Bruto SF2 */
                
                Aadd(Array,{TSF2->F2_CLIENTE ,'Cod Cli SF2'}) /* 28 Cod Cliente SF2 */
                Aadd(Array,{TSF2->A1_NREDUZ  ,'Nome    SF2'}) /* 29 Nome SF2 */
                
                Aadd(Array,{TSF2->F2_LOJA    ,'Loja    SF2'}) /* 30 Loja SF2 */

                // incluido em 03/05/2023
                If  (XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE,"_COMPL") != Nil) 
                    If  (XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE:_COMPL,"_XOBS") != Nil) 
                        Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_COMPL:_XOBS:TEXT,' OBS'}) /* 31 OBSERVAวรO */
                    Else
                        Aadd(Array,{'',' OBS'}) /* 31 OBSERVAวรO */
                    EndIf 
                Else 
                       Aadd(Array,{'',' OBS'}) /* 31 OBSERVAวรO */
                EndIf    
                

            else

                Aadd(Array,{"",'Nota    SF2'}) /* 25 Doc SF2 */ 
                Aadd(Array,{"",'Serie   SF2'}) /* 26 Serie SF2 */ 
                Aadd(Array,{0 ,'Vlr     SF2'}) /* 27 Vlr SF2 */ 
                Aadd(Array,{"",'Cod Cli SF2'}) /* 28 Cod Cli SF2 */ 
                Aadd(Array,{"",'Nome    SF2'}) /* 29 Nome SF2 */ 
                Aadd(Array,{"",'Loja    SF2'}) /* 30 Loja SF2 */ 

                 // incluido em 02/03/2023
                If Type("oXml:_CTEPROC:_CTE:_INFCTE:_COMPL") <> "U"
                    If(XmlChildEx (oXml:_CTEPROC:_CTE:_INFCTE:_COMPL,"_XOBS") != Nil) 

                        If ValType(oXml:_CTEPROC:_CTE:_INFCTE:_COMPL) == "O"
                            Aadd(Array,{oXml:_CTEPROC:_CTE:_INFCTE:_COMPL:_XOBS:TEXT,' OBS'}) /* 31 OBSERVAวรO */
                        Else
                            Aadd(Array,{'','OBS'}) /* 31 OBSERVAวรO */ 
                        EndIf    

                    Else
                        Aadd(Array,{'','OBS'}) /* 31 OBSERVAวรO */ 
                    EndIf    
                else
                        Aadd(Array,{'','OBS'}) /* 31 OBSERVAวรO */ 
                EndIf    

            EndIf  

            SF1->(dbSetOrder(8))
            If SF1->(dbSeek(xFilial("SF1")+PadR(Array[24][1],Len(SF1->F1_CHVNFE))))
                ENTRADA(Array)  // Quando Tecpolpa nao for Remetende na Danfe NF de Entrada
            Else
                INSERE(Array) // Quando Tecpolpa for Remetende na Danfe pega NF de Saida
            EndIf 

 //Endif

return

Static Function INSERE(Array)
Local Tipo := 0


/*
 Tipo 0 = Nใo existe na base, entใo cria
 Tipo 1 = Existe na base, mas nใo faz nada
 Tipo 2 = Exclui e recria
*/

   /* verifica se jแ tem Chave Cadastrada */ 
   ZA9->(DbSetOrder(2)) 
   IF ZA9->(DbSeek(Xfilial('ZA9')+Array[6][1]))
        If ZA9->ZA9_CHVSF2 == Array[24][1]
            Tipo := 2
        else
            Tipo := 0    
        Endif        

        /* Caso tenha altera็ใo do Status Atualiza a Tabela */
        Do Case
            Case  ZA9->ZA9_STATUS <> Array[1][1]
                Tipo := 2
            Case   ZA9->ZA9_SITNF <> Array[2][1]    
                Tipo := 2
            Case  ZA9->ZA9_SITPRO <> Array[3][1]                    
                Tipo := 2
            Case  ZA9->ZA9_SITXML <> Array[4][1]                    
                Tipo := 2
            Case  ZA9->ZA9_MANIFE <> Array[5][1]                    
                Tipo := 2
            Case  (Alltrim(ZA9->ZA9_DOCDCO) <> Alltrim(Array[25][1])) .AND. (Alltrim(ZA9->ZA9_CHVSF2) == Alltrim(Array[24][1]))
            //Case  Alltrim(ZA9->ZA9_DOCDCO) <> Alltrim(Array[25][1])                    
                Tipo := 2    
            EndCase  

   EndIf

   If (Tipo == 2)
        // Exclui
         RecLock("ZA9", .F.)
         ZA9->(dbDelete()) 
         MsUnlock()
   Endif 
  
    If (Tipo == 0) .OR. (Tipo == 2)

        DbSelectArea("ZA9")
        RecLock("ZA9", .T.)
            ZA9->ZA9_FILIAL := xFilial("ZA9")
            ZA9->ZA9_STATUS := Array[1][1]  /* Status         */
            ZA9->ZA9_SITNF  := Array[2][1]  /* Sit.NF         */
            ZA9->ZA9_SITPRO := Array[3][1]  /* Sit.Protheus   */
            ZA9->ZA9_SITXML := Array[4][1]  /* Sit.XML        */
            ZA9->ZA9_MANIFE := Array[5][1]  /* Manifesto      */
            ZA9->ZA9_CHVCTE := Array[6][1]  /* Chave CT-E     */
            ZA9->ZA9_DOCENT := Array[7][1]  /* Doc.Entrada    */
            ZA9->ZA9_SERIEN := Array[8][1]  /* Serie.Entrada  */
            ZA9->ZA9_LOJA   := Array[9][1]  /* Loja.Fornec    */
            ZA9->ZA9_FORNEC := Array[10][1] /* Codigo.Fornec  */
            ZA9->ZA9_NOMFOR := Array[11][1] /* Nome.Fornec    */
            ZA9->ZA9_VALICM := Array[12][1] /* Vlr.ICMS       */
            ZA9->ZA9_VALCOF := Array[13][1] /* Vlr.Cofins     */
            ZA9->ZA9_PIS    := Array[14][1] /* Vlr.Pis        */
            ZA9->ZA9_CNPJTR := Array[15][1] /* CNPJ.Transp    */
            ZA9->ZA9_RTRANS := Array[16][1] /* Razใo.Transp   */
            ZA9->ZA9_TRANSP := Array[17][1] /* Codigo.Transp  */    
            
            ZA9->ZA9_DOC    := Array[18][1] /* No.Docto CT-E    */
            ZA9->ZA9_SERIE  := Array[19][1] /* Serie CT-E    */
            ZA9->ZA9_DATEMI := Stod(Array[20][1]) /* Emissao CT-E    */
            ZA9->ZA9_VALMER := Val(Array[21][1]) /* Valor CT-E    */

            ZA9->ZA9_MUIN   := Array[22][1] /* CIDADE SF2    */
            ZA9->ZA9_EST    := Array[23][1] /* ESTADO SF2    */

            ZA9->ZA9_CHVSF2 := Array[24][1] /* Chave SF2      */    
            ZA9->ZA9_DOCDCO := Array[25][1] /* DOC SF2    */
            ZA9->ZA9_SERDCO := Array[26][1] /* SERIE SF2    */
            
            ZA9->ZA9_VLRSAI := Array[27][1] /* Vlr Saida SF2    */
            
            ZA9->ZA9_CLIDES := Array[28][1] /* CLIENTE SF2    */
            ZA9->ZA9_NOMDES := Array[29][1] /* NOME SF2  */

            ZA9->ZA9_LOJDES := Array[30][1] /* LOJA SF2  */
            ZA9->ZA9_OBS    := Array[31][1] /* Campo Obs  */
        MsUnlock()

    Endif    

Return 


Static Function ENTRADA(Array)
Local Tipo := 2
    /*
 Tipo 0 = Nใo existe na base, entใo cria
 Tipo 1 = Existe na base, mas nใo faz nada
 Tipo 2 = Exclui e recria
*/

/* verifica se jแ tem Chave Cadastrada */ 

ZA9->(DbSetOrder(2)) 
ZA9->(DbSeek(Xfilial('ZA9')+Array[6][1]))
While !ZA9->(eof()) .AND. (Array[6][1] == ZA9->ZA9_CHVCTE)
    if Empty(ZA9->ZA9_TIPO)
        RecLock("ZA9", .F.)
            ZA9->(dbDelete()) 
        MsUnlock()
    EndIf
    ZA9->(dbSkip())
Enddo 


ZA9->(DbSetOrder(2)) 
IF ZA9->(DbSeek(Xfilial('ZA9')+Array[6][1]))
    Tipo := 1

    /* Caso tenha altera็ใo do Status Atualiza a Tabela */
    Do Case
        Case  ZA9->ZA9_STATUS <> Array[1][1]
            Tipo := 2
        Case   ZA9->ZA9_SITNF <> Array[2][1]    
            Tipo := 2
        Case  ZA9->ZA9_SITPRO <> Array[3][1]                    
            Tipo := 2
        Case  ZA9->ZA9_SITXML <> Array[4][1]                    
            Tipo := 2
        Case  ZA9->ZA9_MANIFE <> Array[5][1]                    
            Tipo := 2
        /*Case  Alltrim(ZA9->ZA9_DOC) <> Alltrim(Array[7][1])                    
            Tipo := 2 */   
        EndCase  

EndIf

   /*If Empty(ZA9->ZA9_TIPO)
     Tipo := 2   
   EndIf */ 

   If (Tipo == 2) .AND. ZA9->(Deleted()) 
        // Exclui
         RecLock("ZA9", .F.)
         ZA9->(dbDelete()) 
         MsUnlock()
   Endif 
  
    If (Tipo == 0) .OR. (Tipo == 2)

        DbSelectArea("ZA9")
        RecLock("ZA9", .T.)
        ZA9->ZA9_FILIAL := xFilial("ZA9")
        ZA9->ZA9_STATUS := Array[1][1]      /* Status         */
        ZA9->ZA9_SITNF  := Array[2][1]      /* Sit.NF         */
        ZA9->ZA9_SITPRO := Array[3][1]      /* Sit.Protheus   */
        ZA9->ZA9_SITXML := Array[4][1]      /* Sit.XML        */
        ZA9->ZA9_MANIFE := Array[5][1]      /* Manifesto      */
        ZA9->ZA9_CHVCTE := Array[6][1]      /* Chave CT-E     */

        SF1->(dbSetOrder(8))
        SF1->(dbSeek(xFilial("SF1")+PadR(Array[6][1],Len(SF1->F1_CHVNFE))))
        ZA9->ZA9_DOCENT := SF1->F1_DOC      /* Doc.Entrada    */
        ZA9->ZA9_SERIEN := SF1->F1_SERIE    /* Serie.Entrada  */
        ZA9->ZA9_LOJA   := SF1->F1_LOJA     /* Loja.Fornec    */
        
        
        ZA9->ZA9_VALICM := SF1->F1_VALICM    /* Vlr.ICMS       */
        ZA9->ZA9_VALCOF := SF1->F1_VALIMP5   /* Vlr.Cofins     */
        ZA9->ZA9_PIS    := SF1->F1_VALIMP6    /* Vlr.Pis        */
        
        
        ZA9->ZA9_DOC    := Array[18][1] /* No.Docto CT-E    */
        ZA9->ZA9_SERIE  := Array[19][1] /* Serie CT-E    */
        ZA9->ZA9_DATEMI := Stod(Array[20][1]) /* Emissao CT-E    */
        ZA9->ZA9_VALMER := Val(Array[21][1]) /* Valor CT-E    */

        SA2->(DbSeek(xFilial("SA2")+PadR(SF1->F1_FORNECE, tamsx3('A2_COD') [1]) + PadR(SF1->F1_LOJA, tamsx3('A2_LOJA') [1]))) //A2_FILIAL + A2_COD + A2_LOJA
        ZA9->ZA9_CNPJTR := SA2->A2_CGC       /* CNPJ.Transp    */
        ZA9->ZA9_RTRANS := SA2->A2_NOME      /* Razใo.Transp   */
        ZA9->ZA9_TRANSP := SA2->A2_COD       /* Codigo.Transp  */    

        ZA9->ZA9_FORNEC := SF1->F1_FORNECE  /* Codigo.Fornec  */
        ZA9->ZA9_NOMFOR := SA2->A2_NOME  /* Nome.Fornec    */

        ZA9->ZA9_CHVSF2 := Array[24][1]   /* Chave SF2      */    
        
        SF1->(dbSetOrder(8))
        SF1->(dbSeek(xFilial("SF1")+PadR(Array[24][1],Len(SF1->F1_CHVNFE))))

        ZA9->ZA9_DOCDCO := SF1->F1_DOC      /* DOC SF2    */
        ZA9->ZA9_SERDCO := SF1->F1_SERIE    /* SERIE SF2    */
        
        ZA9->ZA9_VLRSAI := SF1->F1_VALBRUT  /* Vlr Saida SF2    */
        
        ZA9->ZA9_CLIDES := SF1->F1_FORNECE  /* CLIENTE SF2    */

        
        
        SA2->(DbSeek(xFilial("SA2")+PadR(SF1->F1_FORNECE, tamsx3('A2_COD') [1]) + PadR(SF1->F1_LOJA, tamsx3('A2_LOJA') [1]))) //A2_FILIAL + A2_COD + A2_LOJA

        ZA9->ZA9_NOMDES := SA2->A2_NOME    /* NOME SF2  */
        ZA9->ZA9_MUIN   := SA2->A2_MUN    /* CIDADE SF2    */
        ZA9->ZA9_EST    := SA2->A2_EST   /* ESTADO SF2    */


        ZA9->ZA9_LOJDES := SF1->F1_LOJA    /* LOJA SF2  */

        ZA9->ZA9_OBS    := Array[31][1] /* Campo Obs  */

        
        ZA9->ZA9_TIPO :=  "SD1"
        MsUnlock()

    Endif  



return()
