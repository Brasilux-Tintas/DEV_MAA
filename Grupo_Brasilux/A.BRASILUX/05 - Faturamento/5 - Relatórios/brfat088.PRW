#include 'rwmake.ch'
#include 'avprint.ch'
#include 'topconn.ch'
#include 'font.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFAT088  ºAutor  ³Microsiga           º Data ³  01/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Carregamento do bordero. Para Expedicao.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT088()
     Private cPerg := "FAT088"

     Private oFont1 := TFont():New( "Courier New Negrito", 9, 19, .F., .T., 5, .T., 5, .F., .F.)
     Private oFont2 := TFont():New( "Courier New Negrito", 9, 12, .F., .T., 5, .T., 5, .F., .F.)
     Private oFont3 := TFont():New( "Courier New Negrito", 9, 11, .F., .T., 5, .T., 5, .F., .F.)
     Private oFont4 := TFont():New( "Courier New"        , 9, 11, .F., .F., 5, .T., 5, .F., .F.)
     Private oFont5 := TFont():New( "Courier New Negrito Itálico", 9, 12, .F., .T., 5, .T., 5, .T., .F.)
          
     if !u_VldAcesso(funname())
     	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
     	return 
     endif 

     //VldPerg()
     If !Pergunte(cPerg,.t.)
        Return
     Else
        MsAguarde({|| FAT0861() },"Aguarde","Buscando informações conforme parâmetros...")
        DbSelectArea('TCQ')
        DbGoTop()
        If Eof()
           MsgBox("Não há dados a serem processados com estes parâmetros!!!","Atenção","STOP")
           DbSelectArea("TCQ")
           DbCloseArea()
           Return
        Else
           Processa({|lEnd| FAT0862()})
           DbSelectArea("TCQ")
           DbCloseArea()
        Endif
     Endif

Return

// Query para busca de informacoes
Static Function FAT0861()
       Local cQry := ""

       cQry += " SELECT ZB_CODIGO,ZB_PEDIDO,ZB_RAZAO,C5_VOLUME1 AS QTDEVOL, C5_NOTA, A1_CODCID AS CODCID,C5_REDESP AS REDESP,Z7_NOME,A4_NOME,A4_DDD,A4_TEL,A1_CGC, C5_PBRUTO, ISNULL(F2_VALBRUT,0) AS F2_VALBRUT "
       cQry += " FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.C5_FILIAL = SZB.ZB_FILIAL) AND (SC5.D_E_L_E_T_ <> '*') AND ((SUBSTRING(C5_FILIAL,5,2)+C5_NUM) = ZB_PEDIDO) "     
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (C5_REDESP = A4_COD)  "     
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (C5_CLIENTE = A1_COD) "     
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (A1_CODCID = Z7_COD)  "     
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.F2_FILIAL = SC5.C5_FILIAL) AND (SF2.D_E_L_E_T_ <> '*') AND (SC5.C5_NUM = SF2.F2_PEDIDO) AND (SC5.C5_NOTA = SF2.F2_DOC) AND (SC5.C5_SERIE = SF2.F2_SERIE) "     
	   cQry += " WHERE (SZB.ZB_FILIAL  = '"+xFilial("SZB")+"') "
       cQry += "  AND SZB.D_E_L_E_T_ <> '*' "
       cQry += "  AND SZB.ZB_CODIGO = '"+mv_par02+"' "       
       If mv_par01 == 1
	       cQry += "ORDER BY ZB_CODIGO "
	   Else	      
	       cQry += "ORDER BY A4_NOME,ZB_PEDIDO "
	   Endif 
       TCQuery cQry ALIAS 'TCQ' NEW

Return

// Relatorio
Static Function FAT0862()
       Local aMatDad    := {} 
       Local aCabExcel := {}
       Private nlinMax  := 2280
       Private nColMax  := 3385
       Private nLin     := 0
       Private nCol     := 30

		DbSelectArea("TCQ")
		dbgotop()
		if mv_par05 == 2
       			AVPRINT oPrn NAME "RELATÓRIO PARA CARREGAMENTO"
               	oPrn:SetPage(9)
               	oPrn:SetLandscape()
               	AVPAGE
          		fCab0862()
				While !Eof()
                          oPrn:Line(nlin     , nCol     , nlin+0060, nCol     )
                          nLin += 15 
                          oPrn:Say( nLin, nCol+0015, SubStr(TCQ->ZB_PEDIDO, 01, 02)+'-'+SubStr(TCQ->ZB_PEDIDO,3,6) , oFont4)
                          oPrn:Line(nlin-0010, nCol+0240, nlin+0045, nCol+0240)
      
                          oPrn:Say( nLin, nCol+0015, TCQ->C5_NOTA, oFont4)
                          oPrn:Line(nlin-0010, nCol+0240, nlin+0045, nCol+0240)
      
                          oPrn:Say( nLin, nCol+0270, SubStr(TCQ->ZB_RAZAO , 01, 30)                                , oFont4)
                          oPrn:Line(nlin-0010, nCol+1080, nlin+0045, nCol+1080)
                          oPrn:Say( nLin, nCol+1120, Transform(TCQ->QTDEVOL, "@E 9999")                            , oFont4)
                          oPrn:Line(nlin-0010, nCol+1260, nlin+0045, nCol+1260)
                          oPrn:Say( nLin, nCol+1280, SubStr(Alltrim(TCQ->Z7_NOME), 01, 20), oFont4)
                          oPrn:Line(nlin-0010, nCol+1810, nlin+0045, nCol+1810)
                          oPrn:Say( nLin, nCol+1830, SubStr(Alltrim(TCQ->A4_NOME), 01, 25), oFont4)
                          oPrn:Line(nlin-0010, nCol+2450, nlin+0045, nCol+2450)
                          oPrn:Say( nLin, nCol+2470, Alltrim(TCQ->A4_TEL), oFont4)
                          oPrn:Line(nlin-0010, nCol+2870, nlin+0045, nCol+2870)
                          oPrn:Line(nlin-0010, nColMax  , nlin+0045, nColMax  )
                          nLin += 45
                          oPrn:Line(nlin, nCol    , nlin, nColMax    )
                          If nLin >= nLinMax
                             AVNEWPAGE
                               nLin := 0
                               fCab0862()
                          Endif  
                          DbSelectArea("TCQ")
                          DbSkip()
				Enddo        
               	AVENDPAGE
       			AVENDPRINT
       			MS_FLUSH()
		Else
                    aMatDad := {}
                    While !Eof()
                          aadd(aMatDad, { CHR(160)+SubStr(TCQ->ZB_PEDIDO, 01, 02)+'-'+SubStr(TCQ->ZB_PEDIDO,3,6), ;
                                          CHR(160)+Alltrim(TCQ->C5_NOTA)            				   			, ;
                                          CHR(160)+SubStr(TCQ->ZB_RAZAO , 01, 50)   				   			, ;
                                          CHR(160)+Iif(Len(Alltrim(TCQ->A1_CGC))==14,(Transform(TCQ->A1_CGC,'@R 99.999.999/9999-99')),(Transform(TCQ->A1_CGC,'@R 999.999.999-99'))) 	, ;
                                          Transform(TCQ->QTDEVOL,"@E 9999") 						   			, ;
                                          ROUND(TCQ->C5_PBRUTO,2)  				 				   		    	, ;
                                          Transform(TCQ->F2_VALBRUT, "@E 999,999,999.99")                       , ;
                                          CHR(160)+SubStr(Alltrim(TCQ->Z7_NOME), 01, 50)			   	  		, ;
                                          CHR(160)+SubStr(Alltrim(TCQ->A4_NOME), 01, 50)			   			, ;  
                                          CHR(160)+Alltrim(TCQ->A4_DDD)+' '+Alltrim(TCQ->A4_TEL)   	     		, ;
                                           space(30) } )
                          DbSelectArea("TCQ")
                          DbSkip()
                    Enddo
//                    aSort( aMatDad,,,{ |x,y| x[5] < y[5]} )    
            
                    aCabExcel := {}
					AADD(aCabExcel, {"PEDIDO"       ,"C", 09, 0}) 
					AADD(aCabExcel, {"NOTA  "       ,"C", 09, 0}) 
					AADD(aCabExcel, {"DESTINATÁRIO" ,"C", 50, 0}) 
					AADD(aCabExcel, {"CNPJ"         ,"C", 20, 0}) 
					AADD(aCabExcel, {"VOLUME"       ,"N", 04, 0}) 
					AADD(aCabExcel, {"PESO"         ,"N", 05, 2}) 
					AADD(aCabExcel, {"TOTAL NOTA"   ,"N", 09, 2}) 
					AADD(aCabExcel, {"CIDADE"       ,"C", 50, 0}) 
					AADD(aCabExcel, {"REDESPACHO"   ,"C", 50, 0})
					AADD(aCabExcel, {"FONE"         ,"C", 15, 0})
					//AADD(aCabExcel, {"GAIOLA"       ,"C", 50, 0})
                    
					MsgRun("Aguarde.....", "Exportando os Registros para o Excel",; 
					{||DlgToExcel({{"GETDADOS",;
					"RELATÓRIO DE CARREGAMENTO - BORDERO "+mv_par02+chr(13)+chr(10)+;
					"CARGA DO DIA:"+DTOC(Posicione("SZA", 1, xFilial("SZA")+mv_par02, "ZA_EMISSAO"))+;
					"VEICULO:"+SubStr(Alltrim(Posicione("DA3", 1, xFilial("DA3")+mv_par03, "DA3_DESC")), 01, 20)+;
					"MOTORISTA: "+SubStr(Alltrim(Posicione("DA4", 1, xFilial("DA4")+mv_par04, "DA4_NOME")), 01, 30),; 
					aCabExcel,aMatDad}})})     
					
                  
		Endif

Return

//Cabecalho do relatorio
Static Function fCab0862()
       nLin += 30  // linha 30
       oPrn:Box( nLin, nCol, nLin+120, nColMax ) //Box da Linha 30 até a 150
       nLin += 30 // linha 60
       oPrn:Say( nLin, nCol+800, "RELATÓRIO DE CARREGAMENTO - BORDERO "+mv_par02, oFont1)
       nLin += 100 // linha 160
       oPrn:Box( nLin, nCol    , nLin+60, nColMax ) //Box da linha 160 até 220
       nLin += 10 // Linha 170
       oPrn:Say( nLin, nCol+30  , "CARGA DO DIA:", oFont2)
       oPrn:Say( nLin, nCol+420 , DTOC(Posicione("SZA", 1, xFilial("SZA")+mv_par02, "ZA_EMISSAO")), oFont5)
       oPrn:Say( nLin, nCol+800 , "VEICULO:", oFont2)
       oPrn:Say( nLin, nCol+1020, SubStr(Alltrim(Posicione("DA3", 1, xFilial("DA3")+mv_par03, "DA3_DESC")), 01, 20), oFont5)
       oPrn:Say( nLin, nCol+1620, "MOTORISTA: ", oFont2)
       oPrn:Say( nLin, nCol+1920, SubStr(Alltrim(Posicione("DA4", 1, xFilial("DA4")+mv_par04, "DA4_NOME")), 01, 30), oFont5)
       nLin += 60 // Linha 230
       oPrn:Box( nLin, nCol    , nLin+60, nColMax ) //Box da linha 230 até 270
       nLin += 10 // Linha 240
       oPrn:Say( nLin     , nCol+0050, "PEDIDO", oFont3)
       oPrn:Line(nlin-0010, nCol+0240, nlin+0050, nCol+0240)
       oPrn:Say( nLin     , nCol+0050, "NOTA", oFont3)
       oPrn:Line(nlin-0010, nCol+0240, nlin+0050, nCol+0240)
       oPrn:Say( nLin     , nCol+0430, "DESTINATÁRIO", oFont3)
       oPrn:Line(nlin-0010, nCol+1080, nlin+0050, nCol+1080)
       oPrn:Say( nLin     , nCol+1100, "VOLUME"      , oFont3)
       oPrn:Line(nlin-0010, nCol+1260, nlin+0050, nCol+1260)
       oPrn:Say( nLin     , nCol+1440, "CIDADE"      , oFont3)
       oPrn:Line(nlin-0010, nCol+1810, nlin+0050, nCol+1810)
       oPrn:Say( nLin     , nCol+2150, "REDESPACHO"  , oFont3)
       oPrn:Line(nlin-0010, nCol+2870, nlin+0050, nCol+2870)
       oPrn:Say( nLin     , nCol+2980, "Nº. GAIOLA"  , oFont3)
       nLin += 40
Return

//Busca informacoes referente aos dados de volume e redespacho
Static Function fBusVol()
       Local cQry := ""
       Local nQtdVol :=0
       Local cCodCid :=""
       Local cCodRed :=""
       
       If SubStr(TCQ->ZB_PEDIDO, 01, 02) == '01'
          DbSelectArea("SF2")
          DbOrderNickName("SF2001")
          DbSeek(xFilial("SF2")+SubStr(TCQ->ZB_PEDIDO, 03, 06), .t.)
          If Found()
             nQtdVol := SF2->F2_VOLUME1
             cCodCid := SF2->F2_CODCID
             cCodRed := SF2->F2_REDESP
          Else
             nQtdVol := Posicione("SC5", 1, xFilial("SC5")+SubStr(TCQ->ZB_PEDIDO, 03, 06), "C5_VOLUME1")
             cCodCid := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SubStr(TCQ->ZB_PEDIDO, 03, 06), "C5_CLIENTE"), "A1_CODCID")
             cCodRed := Posicione("SC5", 1, xFilial("SC5")+SubStr(TCQ->ZB_PEDIDO, 03, 06), "C5_REDESP")
          Endif
       Else
          cQry := ""
          cQry += "SELECT F2_VOLUME1, F2_CODCID, F2_REDESP "
          cQry += "FROM SF2020 SF2 WITH (NOLOCK) "
          cQry += "WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"' "
          cQry += "  AND SF2.F2_PEDIDO = '"+SubStr(TCQ->ZB_PEDIDO, 03, 06)+"' "
          TCQuery cQry ALIAS "TMPSF2" NEW
          DbSelectArea("TMPSF2")
          DbGoTop()
          nQtdVol := TMPSF2->F2_VOLUME1
          cCodCid := TMPSF2->F2_CODCID
          cCodRed := TMPSF2->F2_REDESP
          
          DbSelectArea("TMPSF2")
          DbCloseArea()
          If nQtdVol <= 0
             cQry := ""
             cQry += "SELECT C5_VOLUME1, C5_CLIENTE,  C5_REDESP "
             cQry += "FROM SC5020 SC5 "
             cQry += "WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
             cQry += "  AND SC5.C5_NUM = '"+SubStr(TCQ->ZB_PEDIDO, 03, 06)+"' "
             TCQuery cQry ALIAS "TMPSC5" NEW
             DbSelectArea("TMPSC5")
             DbGoTop()
             nQtdVol := TMPSC5->C5_VOLUME1
             cCodCid := Posicione("SA1", 1, xFilial("SA1")+TMPSC5->C5_CLIENTE, "A1_CODCID")
             cCodRed := TMPSC5->C5_REDESP
             DbSelectArea("TMPSC5")
             DbCloseArea()
          Endif
       Endif
Return({nQtdVol, cCodCid, cCodRed})

/*
Static Function VldPerg()
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       aRegs:={}
       cPerg := PADR(cPerg,10)
       //Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       //          01    02     03                     04  05  06        07   08  09 10 11   12  13          14         15  16  17  18  19             20  21  22  23  24   25  26  27  28  29   30  31  32  33  34   35  36  37  38     39  40  41
       AADD(aRegs,{cPerg, "01", "Ordem             ?", "", "", "mv_ch1", "N", 01, 0, 0, "C", "", "mv_par01", "Pedidos", "", "", "", "", "Redespacho" , "", "", "", "", "" , "", "", "", "", "" , "", "", "", "", "" , "", "", "", ""   , "", "", "" })
       AADD(aRegs,{cPerg, "02", "Bordero           ?", "", "", "mv_ch2", "C", 06, 0, 0, "G", "", "mv_par02", " "      , "", "", "", "", " "          , "", "", "", "", " ", "", "", "", "", " ", "", "", "", "", " ", "", "", "", ""   , "", "", "" })
       AADD(aRegs,{cPerg, "03", "Veiculo           ?", "", "", "mv_ch3", "C", 08, 0, 0, "G", "", "mv_par03", " "      , "", "", "", "", " "          , "", "", "", "", " ", "", "", "", "", " ", "", "", "", "", " ", "", "", "", "DA3", "", "", "" })
       AADD(aRegs,{cPerg, "04", "Motorista         ?", "", "", "mv_ch4", "C", 06, 0, 0, "G", "", "mv_par04", " "      , "", "", "", "", " "          , "", "", "", "", " ", "", "", "", "", " ", "", "", "", "", " ", "", "", "", "DA4", "", "", "" })
       For i:=1 to Len(aRegs)
           If ! dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next      
		PutSX1(cPerg, "05"  ,  "Gerar EXCEL     ?", "Gerar EXCEL     ?", "Gerar EXCEL     ?", "mv_ch5", "N",  1, 0, 1, "C"  , "","","","", "mv_par05","Sim", "Si", "Yes"   , ""   , "Não", "No", "No", "", "", "" , "", "", "", "", "", "",{},{},{}, "" )
       
       dbSelectArea(_sAlias)
Return
*/