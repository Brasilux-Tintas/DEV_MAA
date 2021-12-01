//#include 'brasilux.ch'
#include "protheus.ch"
#include "topconn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ BRFATX03 ºAutor  ³ Luís G. de Souza   º Data ³  29/11/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Gera informaçòes para demonstrativo de resultados e de fa- º±±
  ±±º          ³ turamento por linha.                                       º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  - MV_PAR01 - MES
  - MV_PAR02 - ANO
  - MV_PAR03 - 1 = FATURAMENTO - 2 = DEVOLUÇÃO - 3 = IMPOSTOS - 4 = COMISSÃO - 5 = CUSTOS */
User Function BRFATX03()
     Local cQry1       := "" ; Local cQry2 := "" ; Local cQry3 := ""
     Private cPerg     := "FTX103"
     Private cRotina   := "BRFATX03  "
     Private cAcessos  := Posicione("SZW", 4, xFilial("SZW")+cRotina+__cUserID+substr(cNumEmp,1,2)+substr(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")
     If !SubStr(cAcessos, 1, 1) $ '*'
        MsgStop('Usuário sem acesso. Consulte o Administrador do Sistema!')
        Return
     Endif

     PFATX03_1()
     If !Pergunte(cPerg, .t.)
        Return
     Endif
     
     Processa({|| FATX03_1()})
     
Return

/*****************************************************************************************************************/
/*** FATX03_1 - Processa de acordo com parâmetros.                                                             ***/
/*****************************************************************************************************************/
Static Function FATX03_1()
     cPriDia := ctod('01/'+StrZero(mv_par01,2)+'/'+mv_par02)
     cUltDia := ctod(strzero(f_ultdia(cPridia),2)+'/'+StrZero(mv_par01,2)+'/'+mv_par02)
     
     If mv_par03 == 1 // PROCESSA FATURAMENTO
        DbSelectArea("SZE")
        DbSetOrder(1)
        cQry1 := "" ; cQry2 := "" ; cQry3 := ""
      
        cQry2 += " SELECT   '"+cEmpAnt+"'         AS EMPRESA,  '"+mv_par02+"' AS ANO, "
        cQry2 += "         D2.D2_COD    AS PRODUTO,  D2.D2_TES    AS TPFAT, "
        cQry2 += "         F2.F2_VEND1  AS VENDEDOR, F2.F2_EST    AS ESTADO, "
        cQry2 += "         D2_QTSEGUM AS QUANTIDADE, "
        cQry2 += "         (D2_TOTAL / (CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS TOTAL "
        cQry3 += " SELECT COUNT(*) AS QTDREC "
        cQry1 += " FROM SD2"+cEmpAnt+"0 D2 WITH (NOLOCK) "
        cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" B1 WITH (NOLOCK) ON (B1.D_E_L_E_T_ <> '*') AND (D2_FILIAL = B1_FILIAL) AND ((SUBSTRING(D2_COD,1,10)+'00') = B1_COD) "
        cQry1 += " INNER JOIN "+RetSqlName("SF2")+" F2 WITH (NOLOCK) ON F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC = D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE "
        cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" C5 WITH (NOLOCK) ON (C5.D_E_L_E_T_ <> '*') AND (F2_FILIAL = C5_FILIAL) AND (F2_PEDIDO = C5_NUM) AND (F2_DOC = C5_NOTA) AND (C5_SERIE = F2_SERIE) "
        cQry1 += " INNER JOIN "+RetSqlName("SZ5")+" Z5 WITH (NOLOCK) ON (Z5.D_E_L_E_T_ <> '*') AND (Z5.Z5_FILIAL = '"+xFilial("SZ5")+"') AND Z5.Z5_EMB = SUBSTRING(D2.D2_COD,11,2) "
        cQry1 += " INNER JOIN "+RetSqlName("SF4")+" F4 WITH (NOLOCK) ON (F4.D_E_L_E_T_ <> '*') AND (F4.F4_FILIAL = '"+xFilial("SF4")+"') AND F4.F4_CODIGO = D2.D2_TES "
        cQry1 += " WHERE D2.D_E_L_E_T_ = '' "
        cQry1 += "  AND F2.D_E_L_E_T_ = '' "
        cQry1 += "  AND Z5.D_E_L_E_T_ = '' "
        cQry1 += "  AND F4.D_E_L_E_T_ = '' "
		cQry1 += "  AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) "
        cQry1 += "  AND D2_FILIAL = '"+xFilial("SD2")+"' "
        cQry1 += "  AND LEN(D2.D2_COD) = 12 "
        cQry1 += "  AND D2.D2_EMISSAO  BETWEEN '"+Dtos(cPriDia)+"' AND '"+Dtos(cUltDia)+"' "
        cQry2 += cQry1
        cQry3 += cQry1
        
        TCQUERY cQry2 NEW ALIAS "QVEN"
        TCQUERY cQry3 NEW ALIAS "QTDV"
        
        DbSelectArea("QTDV")
        ProcRegua(QTDV->QTDREC)
        DbSelectArea("QTDV")
        DbCloseArea()
        
        DbSelectArea("SZE")
        DbSetOrder(2)
        DbGoTop()
        //Zera o mes para o Ano de acordo com os parâmetro
        cUpd := ""
        cUpd += "UPDATE SZE"+cEmpAnt+"0 SET ZE_Q"+StrZero(mv_par01,2)+" = 0, ZE_V"+StrZero(mv_par01,2)+" = 0 WHERE D_E_L_E_T_ = '' AND ZE_ANO = '"+mv_par02+"'"
        TCSQLEXEC(cUpd)

        DbSelectArea("QVEN")
        DbGoTop()
        While !Eof()
              IncProc("Gravando Faturamento...")
              DbSelectArea("SZE")
              DbSetOrder(4)
              DbSeek(xFilial("SZE")+mv_par02+QVEN->EMPRESA+QVEN->PRODUTO+QVEN->VENDEDOR+QVEN->ESTADO,.t.)
              If !Found()
                 RecLock("SZE",.t.)
                    SZE->ZE_FILIAL                      := xFilial("SZE")
                    SZE->ZE_EMPRESA                     := QVEN->EMPRESA
                    SZE->ZE_ANO                         := mv_par02
                    SZE->ZE_PRODUTO                     := QVEN->PRODUTO
                    SZE->ZE_LINHA                       := SubStr(QVEN->PRODUTO,4,2)
//                    SZE->ZE_TES                         := QVEN->TPFAT
                    SZE->ZE_VEND1                       := QVEN->VENDEDOR
                    SZE->ZE_ESTADO                      := QVEN->ESTADO
                    SZE->&("ZE_Q"+StrZero(mv_par01,2))  := QVEN->QUANTIDADE
                    SZE->&("ZE_V"+StrZero(mv_par01,2))  := QVEN->TOTAL
                 MsUnLock()
              Else
                 RecLock("SZE",.f.)
                    SZE->&("ZE_Q"+StrZero(mv_par01,2)) := SZE->&("ZE_Q"+StrZero(mv_par01,2)) + QVEN->QUANTIDADE
                    SZE->&("ZE_V"+StrZero(mv_par01,2)) := SZE->&("ZE_V"+StrZero(mv_par01,2)) + QVEN->TOTAL
                 MsUnLock()
              Endif
              DbSelectArea("QVEN")
              DbSkip()
        Enddo
        DbSelectArea("QVEN")
        DbCloseArea()
     ElseIf mv_par03 == 2 // PROCESSA DEVOLUÇÕES
            DbSelectArea("SZE")
            DbSetOrder(1)
            cQry1 := "" ; cQry2 := "" ; cQry3 := ""
            cQry2 += "SELECT 'DV'         AS EMPRESA , '"+mv_par02+"'     AS ANO   ,  SD1.D1_COD                    AS PRODUTO   ,  SD1.D1_TES    AS TPFAT, "
            cQry2 += "       '      '     AS VENDEDOR, SF1.F1_EST AS ESTADO, (SD1.D1_QUANT * SZ5.Z5_VOLUME)/(CASE WHEN Z5_UMEMB IN ('K','KG') THEN B1_PESOESP ELSE 1 END) AS QUANTIDADE, "
            cQry2 += "       SD1.D1_TOTAL + SD1.D1_VALIPI + SD1.D1_ICMSRET AS TOTAL "
            cQry3 += "SELECT COUNT(*) AS QTDREC "
            cQry1 += "FROM SF1"+cEmpAnt+"0 SF1 WITH (NOLOCK) "
            cQry1 += "LEFT OUTER JOIN SD1"+cEmpAnt+"0 SD1 WITH (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = '' "
	        cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" B1 WITH (NOLOCK) ON (B1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = B1_FILIAL) AND ((SUBSTRING(D1_COD,1,10)+'00') = B1_COD) "
            cQry1 += "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK)ON '"+xFilial("SF4")+"' = SF4.F4_FILIAL AND SD1.D1_TES = SF4.F4_CODIGO AND 'S' = SF4.F4_DUPLIC AND SF4.D_E_L_E_T_ = '' "
            cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON '"+xFilial("SZ5")+"' = SZ5.Z5_FILIAL AND SUBSTRING(SD1.D1_COD, 11, 2) = SZ5.Z5_EMB AND '  ' = SZ5.D_E_L_E_T_ "
            cQry1 += "WHERE SF1.F1_FILIAL   = '"+xFilial("SF1")+"' "
            cQry1 += "  AND SF1.D_E_L_E_T_  = ''
            cQry1 += "  AND SF1.F1_DTDIGIT BETWEEN '"+Dtos(cPriDia)+"' AND '"+Dtos(cUltDia)+"' "
            cQry1 += "  AND SD1.D1_TIPO     = 'D' "
            cQry1 += "  AND LEN(SD1.D1_COD) = 12 "
            cQry2 += cQry1
            cQry3 += cQry1

            TCQUERY cQry2 NEW ALIAS "QVEN"
            TCQUERY cQry3 NEW ALIAS "QTDV"
        
            DbSelectArea("QTDV")
            ProcRegua(QTDV->QTDREC)
            DbSelectArea("QTDV")
            DbCloseArea()

            DbSelectArea("SZE")
            DbSetOrder(2)
            DbGoTop()
            //Zera o mes para o Ano de acordo com os parâmetro
            cUpd := ""
            cUpd += "UPDATE SZE"+cEmpAnt+"0 SET ZE_Q"+StrZero(mv_par01,2)+" = 0, ZE_V"+StrZero(mv_par01,2)+" = 0 WHERE D_E_L_E_T_ = '' AND ZE_ANO = '"+mv_par02+"' AND ZE_EMPRESA = 'DV' "
            TCSQLEXEC(cUpd)
            DbSelectArea("QVEN")
            DbGoTop()
            While !Eof()
                  IncProc("Gravando Devoluções...")
                  DbSelectArea("SZE")
                  DbSetOrder(4)
                  DbSeek(xFilial("SZE")+mv_par02+QVEN->EMPRESA+QVEN->PRODUTO+QVEN->VENDEDOR+QVEN->ESTADO,.t.)
                  If !Found()
                     RecLock("SZE",.t.)
                        SZE->ZE_FILIAL                      := xFilial("SZE")
                        SZE->ZE_EMPRESA                     := QVEN->EMPRESA
                        SZE->ZE_ANO                         := mv_par02
                        SZE->ZE_PRODUTO                     := QVEN->PRODUTO
                        SZE->ZE_LINHA                       := SubStr(QVEN->PRODUTO,4,2)
//                        SZE->ZE_TES                         := QVEN->TPFAT
                        SZE->ZE_VEND1                       := QVEN->VENDEDOR
                        SZE->ZE_ESTADO                      := QVEN->ESTADO
                        SZE->&("ZE_Q"+StrZero(mv_par01,2))  := QVEN->QUANTIDADE
                        SZE->&("ZE_V"+StrZero(mv_par01,2))  := QVEN->TOTAL
                     MsUnLock()
                  Else
                     RecLock("SZE",.f.)
                        SZE->&("ZE_Q"+StrZero(mv_par01,2)) := SZE->&("ZE_Q"+StrZero(mv_par01,2)) + QVEN->QUANTIDADE
                        SZE->&("ZE_V"+StrZero(mv_par01,2)) := SZE->&("ZE_V"+StrZero(mv_par01,2)) + QVEN->TOTAL
                     MsUnLock()
                  Endif
                  DbSelectArea("QVEN")
                  DbSkip()
            Enddo
            DbSelectArea("QVEN")
            DbCloseArea()
     ElseIf mv_par03 == 3 // PROCESSA IMPOSTOS
            DbSelectArea("SZE")
            DbSetOrder(1)
            cQry1 := "" ; cQry2 := "" ; cQry3 := ""
            cQry2 += "SELECT   'IM'          AS EMPRESA,  '"+mv_par02+"'  AS ANO, "
            cQry2 += "         '      '      AS VENDEDOR, '  '         AS ESTADO, "
            cQry2 += "         D2.D2_COD     AS PRODUTO,  "
            cQry2 += "         SUM(D2.D2_VALIPI)  AS VALIPI, "
            cQry2 += "         SUM(D2.D2_ICMSRET) AS ICMSRET, SUM(D2.D2_VALICM) AS VALICM "
            cQry3 += "SELECT COUNT(*) AS QTDREC "
            cQry1 += "FROM SD2"+cEmpAnt+"0 D2 "
            cQry1 += "INNER JOIN SF2"+cEmpAnt+"0 F2 ON F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC = D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE "
            cQry1 += "INNER JOIN "+RetSqlName("SZ5")+" Z5 ON Z5.Z5_FILIAL = '"+xFilial("SZ5")+"' AND Z5.Z5_EMB = SUBSTRING(D2.D2_COD,11,2) "
            cQry1 += "INNER JOIN "+RetSqlName("SF4")+" F4 ON F4.F4_FILIAL = '"+xFilial("SF4")+"' AND F4.F4_CODIGO = D2.D2_TES AND F4.F4_DUPLIC = 'S' "
            cQry1 += "WHERE D2.D_E_L_E_T_ = '' "
            cQry1 += "  AND F2.D_E_L_E_T_ = '' "
            cQry1 += "  AND Z5.D_E_L_E_T_ = '' "
            cQry1 += "  AND F4.D_E_L_E_T_ = '' "
            cQry1 += "  AND D2_FILIAL = '"+xFilial("SD2")+"' "
            cQry1 += "  AND LEN(D2.D2_COD) = 12 "
            cQry1 += "  AND D2.D2_EMISSAO            BETWEEN '"+Dtos(cPriDia)+"' AND '"+Dtos(cUltDia)+"' "
            cQry2 += cQry1
            cQry3 += cQry1
            cQry2 += "GROUP BY D2.D2_COD "
            TCQUERY cQry2 NEW ALIAS "QIMP"
            TCQUERY cQry3 NEW ALIAS "QTDV"
        
            DbSelectArea("QTDV")
            nQtdRec := QTDV->QTDREC
            DbSelectArea("QTDV")
            DbCloseArea()

            DbSelectArea("SZE")
            DbSetOrder(2)
            DbGoTop()
            //Zera o mes para o Ano de acordo com os parâmetro
            cUpd := ""
            cUpd += "UPDATE SZE"+cEmpAnt+"0 SET ZE_Q"+StrZero(mv_par01,2)+" = 0, ZE_V"+StrZero(mv_par01,2)+" = 0 WHERE D_E_L_E_T_ = '' AND ZE_ANO = '"+mv_par02+"' AND ZE_EMPRESA IN('I1','I2','I3','I4','I5') "
            TCSQLEXEC(cUpd)
            DbSelectArea("QIMP")
            DbGoTop()
            ProcRegua(nQtdRec)
            While !Eof()
                  //Gravando o IPI
                  IncProc("Gravando Impostos (IPI)...")
                  DbSelectArea("SZE")
                  DbSetOrder(4)
                  DbSeek(xFilial("SZE")+mv_par02+"I1"+QIMP->PRODUTO+QIMP->VENDEDOR+QIMP->ESTADO,.t.)
                  If !Found()
                     RecLock("SZE",.t.)
                        SZE->ZE_FILIAL                      := xFilial("SZE")
                        SZE->ZE_EMPRESA                     := 'I1'
                        SZE->ZE_ANO                         := mv_par02
                        SZE->ZE_PRODUTO                     := QIMP->PRODUTO
                        SZE->ZE_LINHA                       := SubStr(QIMP->PRODUTO,4,2)
                        SZE->&("ZE_V"+StrZero(mv_par01,2))  := QIMP->VALIPI
                     MsUnLock()
                  Else
                     RecLock("SZE",.f.)
                        SZE->&("ZE_V"+StrZero(mv_par01,2)) := SZE->&("ZE_V"+StrZero(mv_par01,2)) + QIMP->VALIPI
                     MsUnLock()
                  Endif
                  DbSelectArea("QIMP")
                  DbSkip()
            Enddo
            //Gravando o ICMS RETIDO
            DbSelectArea("QIMP")
            DbGoTop()
            ProcRegua(nQtdRec)
            While !Eof()
                  IncProc("Gravando Impostos (ICM Retido)...")
                  DbSelectArea("SZE")
                  DbSetOrder(4)
                  DbSeek(xFilial("SZE")+mv_par02+"I2"+QIMP->PRODUTO+QIMP->VENDEDOR+QIMP->ESTADO,.t.)
                  If !Found()
                     RecLock("SZE",.t.)
                        SZE->ZE_FILIAL                      := xFilial("SZE")
                        SZE->ZE_EMPRESA                     := 'I2'
                        SZE->ZE_ANO                         := mv_par02
                        SZE->ZE_PRODUTO                     := QIMP->PRODUTO
                        SZE->ZE_LINHA                       := SubStr(QIMP->PRODUTO,4,2)
                        SZE->&("ZE_V"+StrZero(mv_par01,2))  := QIMP->ICMSRET
                     MsUnLock()
                  Else
                     RecLock("SZE",.f.)
                        SZE->&("ZE_V"+StrZero(mv_par01,2)) := SZE->&("ZE_V"+StrZero(mv_par01,2)) + QIMP->ICMSRET
                     MsUnLock()
                  Endif
                  
                  DbSelectArea("QIMP")
                  DbSkip()
            Enddo
            //Gravando o ICMS
            DbSelectArea("QIMP")
            DbGoTop()
            ProcRegua(nQtdRec)
            While !Eof()
                  IncProc("Gravando Impostos (ICMS)...")
                  DbSelectArea("SZE")
                  DbSetOrder(4)
                  DbSeek(xFilial("SZE")+mv_par02+"I3"+QIMP->PRODUTO+QIMP->VENDEDOR+QIMP->ESTADO,.t.)
                  If !Found()
                     RecLock("SZE",.t.)
                        SZE->ZE_FILIAL                      := xFilial("SZE")
                        SZE->ZE_EMPRESA                     := 'I3'
                        SZE->ZE_ANO                         := mv_par02
                        SZE->ZE_PRODUTO                     := QIMP->PRODUTO
                        SZE->ZE_LINHA                       := SubStr(QIMP->PRODUTO,4,2)
                        SZE->&("ZE_V"+StrZero(mv_par01,2))  := QIMP->VALICM
                     MsUnLock()
                  Else
                     RecLock("SZE",.f.)
                        SZE->&("ZE_V"+StrZero(mv_par01,2)) := SZE->&("ZE_V"+StrZero(mv_par01,2)) + QIMP->VALICM
                     MsUnLock()
                  Endif
                  DbSelectArea("QIMP")
                  DbSkip()
            Enddo
            DbSelectArea("QIMP")
            DbCloseArea()
     ElseIf mv_par03 == 4 // PROCESSA COMISSÃO
            DbSelectArea("SZE")
            DbSetOrder(1)
            cQry1 := "" ; cQry2 := "" ; cQry3 := ""
            cQry2 += "SELECT   'CM'          AS EMPRESA,  '"+mv_par02+"'  AS ANO, "
            cQry2 += "         '      '      AS VENDEDOR, '  '         AS ESTADO, "
            cQry2 += "         D2.D2_COD     AS PRODUTO, "
            cQry2 += "         SUM(D2.D2_TOTAL * (C5.C5_COMIS1/100)) AS VALCOM " //14/06/21->ANTES ESTAVA SUM(D2.D2_TOTAL * (C5.C5_PORCOM/100)) AS VALCOM
            cQry3 += "SELECT COUNT(*) QTDREC "
            cQry1 += "FROM SD2"+cEmpAnt+"0 D2 "
            cQry1 += "INNER JOIN SF2"+cEmpAnt+"0 F2 ON F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC = D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE "
            cQry1 += "INNER JOIN SC5"+cEmpAnt+"0 C5 ON C5.C5_FILIAL = D2.D2_FILIAL AND C5.C5_NOTA= D2.D2_DOC "
            cQry1 += "INNER JOIN "+RetSqlName("SZ5")+" Z5 ON Z5.Z5_FILIAL = '"+xFilial("SZ5")+"' AND Z5.Z5_EMB = SUBSTRING(D2.D2_COD,11,2) "
            cQry1 += "INNER JOIN "+RetSqlName("SF4")+" F4 ON F4.F4_FILIAL = '"+xFilial("SF4")+"' AND F4.F4_CODIGO = D2.D2_TES AND F4.F4_DUPLIC = 'S' "
            cQry1 += "WHERE D2.D_E_L_E_T_ = '' "
            cQry1 += "  AND F2.D_E_L_E_T_ = '' "
            cQry1 += "  AND C5.D_E_L_E_T_ = '' "
            cQry1 += "  AND Z5.D_E_L_E_T_ = '' "
            cQry1 += "  AND F4.D_E_L_E_T_ = '' "
            cQry1 += "  AND D2_FILIAL = '"+xFilial("SD2")+"' "
            cQry1 += "  AND LEN(D2.D2_COD) = 12 "
            cQry1 += "  AND D2.D2_EMISSAO            BETWEEN '"+Dtos(cPriDia)+"' AND '"+Dtos(cUltDia)+"' "
            cQry2 += cQry1
            cQry3 += cQry1
            cQry2 += "GROUP BY D2.D2_COD "
            TCQUERY cQry2 NEW ALIAS "QCOM"
            TCQUERY cQry3 NEW ALIAS "QTDV"
        
            DbSelectArea("QTDV")
            nQtdRec := QTDV->QTDREC
            DbSelectArea("QTDV")
            DbCloseArea()

            DbSelectArea("SZE")
            DbSetOrder(2)
            DbGoTop()
            //Zera o mes para o Ano de acordo com os parâmetro
            cUpd := ""
            cUpd += "UPDATE SZE"+cEmpAnt+"0 SET ZE_Q"+StrZero(mv_par01,2)+" = 0, ZE_V"+StrZero(mv_par01,2)+" = 0 WHERE D_E_L_E_T_ = '' AND ZE_ANO = '"+mv_par02+"' AND ZE_EMPRESA IN('CM') "
            TCSQLEXEC(cUpd)
            DbSelectArea("QCOM")
            DbGoTop()
            ProcRegua(nQtdRec)
            While !Eof()
                  IncProc("Gravando Comissão...")
                  DbSelectArea("SZE")
                  DbSetOrder(4)
                  DbSeek(xFilial("SZE")+mv_par02+"CM"+QCOM->PRODUTO+QCOM->VENDEDOR+QCOM->ESTADO,.t.)
                  If !Found()
                     RecLock("SZE",.t.)
                        SZE->ZE_FILIAL                      := xFilial("SZE")
                        SZE->ZE_EMPRESA                     := 'CM'
                        SZE->ZE_ANO                         := mv_par02
                        SZE->ZE_PRODUTO                     := QCOM->PRODUTO
                        SZE->ZE_LINHA                       := SubStr(QCOM->PRODUTO,4,2)
                        SZE->&("ZE_V"+StrZero(mv_par01,2))  := QCOM->VALCOM
                     MsUnLock()
                  Else
                     RecLock("SZE",.f.)
                        SZE->&("ZE_V"+StrZero(mv_par01,2)) := SZE->&("ZE_V"+StrZero(mv_par01,2)) + QCOM->VALCOM
                     MsUnLock()
                  Endif
                  DbSelectArea("QCOM")
                  DbSkip()
            Enddo
            DbSelectArea("QCOM")   	
            DbCloseArea()
     ElseIf mv_par03 == 5 // PROCESSA CUSTOS
            DbSelectArea("SZE")
            DbSetOrder(1)
            cQry1 := "" ; cQry2 := "" ; cQry3 := ""
            cQry2 += "SELECT SZE.ZE_ANO, SZE.ZE_EMPRESA, SZE.ZE_PRODUTO, SZE.ZE_VEND1, SZE.ZE_ESTADO, SZE.ZE_LINHA, SZE.ZE_TES, SZE.ZE_Q"+StrZero(mv_par01,2)+" "
            cQry3 += "SELECT COUNT(*) AS QTDREC "
            cQry1 += "FROM "+RetSqlName("SZE")+" SZE "
            cQry1 += "WHERE SZE.ZE_FILIAL = '"+xFilial("SZE")+"' "
            cQry1 += "  AND SZE.D_E_L_E_T_ = '' "
            cQry1 += "  AND SZE.ZE_EMPRESA = '01' "
            cQry1 += "  AND SZE.ZE_Q01 > 0 "
            cQry2 += cQry1
            cQry3 += cQry1
            cQry2 += "ORDER BY SZE.ZE_PRODUTO "
            TCQUERY cQry2 NEW ALIAS "CUS"
            TCQUERY cQry3 NEW ALIAS "QTD"
            DbSelectArea("QTD")
            nQtdRec := QTD->QTDREC
            DbSelectArea("QTD")
            DbCloseArea()

            cUpd := ""
            cUpd += "UPDATE SZE"+cEmpAnt+"0 SET ZE_CMP"+StrZero(mv_par01,2)+" = 0, ZE_CME"+StrZero(mv_par01,2)+" = 0 WHERE D_E_L_E_T_ = '' AND ZE_ANO = '"+mv_par02+"' "
            TCSQLEXEC(cUpd)
            DbSelectArea("CUS")
            DbGoTop()
            ProcRegua(nQtdRec)
            While !Eof()
                  IncProc("Gravando Custos...")
                  nCusTot := Posicione("ZZ9", 3, xFilial("ZZ9")+StrZero(mv_par01, 2)+mv_par02+CUS->ZE_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+CUS->ZE_PRODUTO, "B1_LOCPAD"), "ZZ9_CUSTO") 
                  nQtdFor := Posicione("ZZ9", 3, xFilial("ZZ9")+StrZero(mv_par01, 2)+mv_par02+CUS->ZE_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+CUS->ZE_PRODUTO, "B1_LOCPAD"), "ZZ9_QTDFOR")
                  nQtdEmb := Posicione("ZZ9", 3, xFilial("ZZ9")+StrZero(mv_par01, 2)+mv_par02+CUS->ZE_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+CUS->ZE_PRODUTO, "B1_LOCPAD"), "ZZ9_QTDEMB")
                  nCodEmb := Posicione("ZZ9", 3, xFilial("ZZ9")+StrZero(mv_par01, 2)+mv_par02+CUS->ZE_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+CUS->ZE_PRODUTO, "B1_LOCPAD"), "ZZ9_EMB") 
                  nCusEmb := Posicione("ZZ9", 3, xFilial("ZZ9")+StrZero(mv_par01, 2)+mv_par02+nCodEmb+space(15 - Len(nCodEmb))+Posicione("SB1", 1, xFilial("SB1")+nCodEmb, "B1_LOCPAD")        , "ZZ9_CUSTO")
                  nCusMP  := nCusTot - nCusEmb
                  nQtdTT  := CUS->&("ZE_Q"+StrZero(mv_par01,2)) / nQtdFor
                  DbSelectArea("SZE")
                  DbSetOrder(4)
                  DbSeek(xFilial("SZE")+CUS->ZE_ANO+CUS->ZE_EMPRESA+CUS->ZE_PRODUTO+CUS->ZE_VEND1+CUS->ZE_ESTADO, .t.)
                  If !Found()
                     RecLock("SZE", .t.)
                        SZE->ZE_FILIAL  := xFilial("SZE")
                        SZE->ZE_EMPRESA := CUS->ZE_EMPRESA
                        SZE->ZE_ANO     := CUS->ZE_ANO
                        SZE->ZE_PRODUTO := CUS->ZE_PRODUTO
                        SZE->ZE_LINHA   := CUS->ZE_LINHA
                        SZE->ZE_TES     := CUS->ZE_TES
                        SZE->ZE_VEND1   := CUS->ZE_VEND1
                        SZE->ZE_ESTADO  := CUS->ZE_ESTADO
                        SZE->&("ZE_CMP"+StrZero(mv_par01,2)) := nQtdTT * nCusMP
                        SZE->&("ZE_CME"+StrZero(mv_par01,2)) := nQtdTT * nCusME
                  Else
                     RecLock("SZE", .f.)
                        SZE->&("ZE_CMP"+StrZero(mv_par01,2)) := nQtdTT * nCusMP
                        SZE->&("ZE_CME"+StrZero(mv_par01,2)) := nQtdTT * nCusEmb
                  Endif
                  MsUnLock()
                  DbSelectArea("CUS")
                  DbSkip()
            Enddo
            DbSelectArea("CUS")
            DbCloseArea()
     Endif
Return

/*****************************************************************************************************************/
/*** PFATX03_1 - Ajusta parâmetros.                                                                            ***/
/*****************************************************************************************************************/
Static Function PFATX03_1()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg, "01", "Mes          ?", "", "", "mv_ch1", "N", 02, 0, 0, "G", "Entre(1, 12, mv_par01)"         , "mv_par01", ""           , "", "", "", "", ""         , "", "", "", "", ""        , "", "", "", "", ""        , "", "", "", "", ""      , "", "", "", "", ""})
       AADD(aRegs,{cPerg, "02", "Ano          ?", "", "", "mv_ch2", "C", 04, 0, 0, "G", "Entre('2000', '2100', mv_par02)", "mv_par02", ""           , "", "", "", "", ""         , "", "", "", "", ""        , "", "", "", "", ""        , "", "", "", "", ""      , "", "", "", "", ""})
       AADD(aRegs,{cPerg, "03", "Gerar para   ?", "", "", "mv_ch3", "N", 01, 0, 0, "C", ""                               , "mv_par03", "Faturamento", "", "", "", "", "Devolução", "", "", "", "", "Impostos", "", "", "", "", "Comissão", "", "", "", "", "Custos", "", "", "", "", ""})
       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j := 1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next     
       DbSelectArea(_sAlias)
Return
