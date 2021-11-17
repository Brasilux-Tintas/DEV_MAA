//#include 'brasilux.ch'
#include "protheus.ch"
#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ BRSCH008 ∫Autor  ≥ LuÌs G. de Souza   ∫ Data ≥  01/04/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Baixa de Ordens de produÁ„o por processo - Nova Vers„o     ∫±±
±±∫          ≥ para baixa de Ops atravÈs da tabela ZZA.                   ∫±±
±±∫          ≥             PROCESSO DE FINALIZA«√O DE PESAGEM             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Brasilux Tintas TÈcnicas Ltda.                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function BRSCH008(aParm)
     //Local nOpc        := Iif(ValType(aParm) == 'U', 2, 1)
     Local cEmp        := Alltrim(Transform(aParm[1],'@!'))
     Local cFil        := Alltrim(Transform(aParm[2],'@!'))
     Local dDatFin     := ""
     Local cCodBaiR    := ""
     Local cBaiPro     := ""
     Local _cAuxMens   := ""
     Private dDataFec  := CTOD("  /  /  ")

     RPCSetType(3)  // Nao utilizar licenca
     PREPARE ENVIRONMENT EMPRESA '01' FILIAL '010101' TABLES "SB1", "SC2", "SD3", "SD4", "SH6"
             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
             //ConOut("-- BRSCH008 - BAIXA DE ORDENS DE PRODU«√O")
             //ConOut("-- BRSCH008 - Thread iniciada com sucesso as: "+Time()+" - "+dToc(MSDate()))
             //ConOut("-- BRSCH008 - Empresa: "+cEmp+" - Filial: "+cFil)
             //ConOut("--")
             _cAuxMens := "-- BRSCH008 - BAIXA DE ORDENS DE PRODU«√O" + CHR(13) + CHR(10)
             _cAuxMens += "-- BRSCH008 - Thread iniciada com sucesso as: "+Time()+" - "+dToc(MSDate())  + CHR(13) + CHR(10)
             _cAuxMens += "-- BRSCH008 - Empresa: "+cEmp+" - Filial: "+cFil
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             /***************************************************************************************/
             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
             //ConOut("-- ABERTURA DA TABELA DE PARAMETROS...")
             _cAuxMens := "-- ABERTURA DA TABELA DE PARAMETROS..."
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             fBusPar(@dDatFin, @cCodBaiR, @cBaiPro)
             //ConOut("###############################################################################")
             //ConOut("--")
             /***************************************************************************************/
             If cBaiPro $ 'S'
                //ConOut("##   BAIXA DE ORDENS DE PRODUCAO SEM LOTE - PASTAS / CONCENTRADOS / SOLUCOES ##")
                //fProcSLT(cEmp, cFil, dDatFin, cCodBaiR)
                //ConOut("###############################################################################")
                //ConOut("--")
                /***************************************************************************************/

                //ConOut("##         PROCESSA DIFERENCAS DE APONTAMENTOS E ENCERRAMENTO DE OPs         ##")
                //fProcAPP(cEmp, cFil, dDatFin, dDataFec)
                //ConOut("###############################################################################")
                //ConOut("--")
                /***************************************************************************************/
                
                //ConOut("###################   BAIXA DE ORDENS DE PRODUCAO COM LOTE   ##################")
                //fProcCLT(cEmp, cFil, dDatFin, cCodBaiR)
                //ConOut("###############################################################################")
                //ConOut("--")
                /***************************************************************************************/

                //ConOut("##         PROCESSA DIFERENCAS DE APONTAMENTOS E ENCERRAMENTO DE OPs         ##")
                //fProcAPL(cEmp, cFil, dDatFin, dDataFec)
                //ConOut("###############################################################################")
                //ConOut("--")
                /***************************************************************************************/
                //ConOut("-- FIM")
             Else
                //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                //ConOut("############   BAIXAS DE PRODU«√O N√O EXECUTADA - MV_BXPROP = N   #############")
                _cAuxMens := "############   BAIXAS DE PRODU«√O N√O EXECUTADA - MV_BXPROP = N   #############"
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                //ConOut("-- FIM")
             Endif
     RESET ENVIRONMENT
Return(Nil)

/******************************************************************************************************************/
/***                                    EXECUTA APONTAMENTO DE PERDA COM LOTE                                   ***/
/******************************************************************************************************************/
/*STATIC Function fProcAPL(cEmp, cFil, dDatFin, dDataFec)
       Local cQry1      := ""
       Local cAlias     := "SD3"
       Local _cAuxMens  := ""
       Private nOpcA    := 2
       Private nRecSD3  := 0
       Private lDelOPSC := .t.
       Private lPerdInf := .t.
       Private lProdAut := .f.
       //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
       //ConOut("-- 06 - BUSCANDO ORDENS DE PRODUCAO PARA SEREM ENCERRADAS.")
       _cAuxMens := "-- 06 - BUSCANDO ORDENS DE PRODUCAO PARA SEREM ENCERRADAS."
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       cQry1 += "SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_PRODUT, ZZA.ZZA_QUANT, SC2.C2_OP, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_QUJE, SC2.C2_DATRF, ZZA_HELP, ZZA_CAMPO "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = '' "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_FLAG   = '5' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "
       cQry1 += "  AND SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) = '00' "
       cQry1 += "  AND SC2.C2_QUJE    < SC2.C2_QUANT "
       cQry1 += "  AND SC2.C2_QUJE   <> 0 "
       cQry1 += "ORDER BY ZZA.ZZA_ORDEM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             DbSelectArea("SD3")
             DbSetOrder(1)
             DbSeek(xFilial("SD3")+TCQ->ZZA_ORDEM+Space(13 - Len(TCQ->ZZA_ORDEM))+TCQ->ZZA_PRODUT, .t.)
             If Found()
                While !Eof() .and. Alltrim(SD3->D3_OP) == Alltrim(TCQ->ZZA_ORDEM) .and. Alltrim(SD3->D3_COD) == Alltrim(TCQ->ZZA_PRODUT)
                      If !SD3->D3_ESTORNO == 'S'
                         //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                         //ConOut("      08/01 - ENCERRANDO ORDEM....: "+SD3->D3_OP)
                         _cAuxMens := "      08/01 - ENCERRANDO ORDEM....: "+SD3->D3_OP
                         FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                         nRecSD3 := recno()
                         a250End(.t.)
                         If Alltrim(SC2->C2_OP) == Alltrim(TCQ->ZZA_ORDEM)
                            cQry1 := ""
                            cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                            cQry1 += "SET ZZA_FLAG = 'P', ZZA_HELP = 'ORDEM DE PRODUCAO BAIXADA', ZZA_CAMPO = '', ZZA_PERDA = "+StrTran(TransForm(SC2->C2_QUANT - SC2->C2_QUJE ,'@E 99999.99999'), ",", ".")+", ZZA_SP = 'P' "
                            cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                            cQry1 += "  AND D_E_L_E_T_ = '' "
                            cQry1 += "  AND ZZA_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                            TCSQLExec(cQry1)
                         Endif
                      Endif
                      DbSelectArea("SD3")
                      DbSkip()
                EndDo
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return(Nil)*/

/******************************************************************************************************************/
/***                              BAIXA DA ORDEM DE PRODU«√O DE PRODUTOS COM LOTE                               ***/
/******************************************************************************************************************/
/*STATIC Function fProcCLT(cEmp, cFil, dDatFin, cCodBaiR)
       Local cQry1    := ""
       Local aRotBai  := {}
       Local aErrBai  := {}
       Local nY, nSLT
       Local _cAuxMens := ""
       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_LOTE  <> '' "
       cQry1 += "  AND ZZA.ZZA_FLAG   = '4' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "
       cQry1 += "ORDER BY ZZA.ZZA_DTFIM+ZZA.ZZA_HFIM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             aErrBai  := {}
             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
             //ConOut("-- 07 - PROCESSANDO LOTE...: "+TransForm(TCQ->ZZA_LOTE, "@R 999999"))
             //ConOut("      -- 07/01 - VERIFICANDO BAIXAS DOS EMPENHOS")
             _cAuxMens := "-- 07 - PROCESSANDO LOTE...: "+TransForm(TCQ->ZZA_LOTE, "@R 999999") + CHR(13) + CHR(10)
             _cAuxMens += "      -- 07/01 - VERIFICANDO BAIXAS DOS EMPENHOS"
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             cQry1 := ""
             cQry1 += "SELECT ZZF.ZZF_OBS, ZZF.ZZF_CODIGO, ZZF.ZZF_QTDUSA "
             cQry1 += "FROM "+RetSqlName("ZZF")+" ZZF WITH (NOLOCK) "
             cQry1 += "WHERE ZZF.ZZF_FILIAL = '"+cFil+"' "
             cQry1 += "  AND ZZF.D_E_L_E_T_ = '' "
             cQry1 += "  AND ZZF.ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
             cQry1 += "  AND ZZF.ZZF_FLAG  <> '1' "
             TCQuery cQry1 ALIAS "XZZF" NEW
             DbSelectArea("XZZF")
             DbGoTop()
             While !Eof()
                   aAdd(aErrBai, {XZZF->ZZF_OBS, XZZF->ZZF_CODIGO, XZZF->ZZF_QTDUSA} )
                   DbSelectArea("XZZF")
                   DbSkip()
             Enddo
             DbSelectArea("XZZF")
             DbCloseArea()
             If Len(aErrBai) <= 0.0
                //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                //ConOut("      -- 07/02 - BUSCANDO ROTEIRO DE OPERA«’ES")
                _cAuxMens := "      -- 07/02 - BUSCANDO ROTEIRO DE OPERA«’ES"
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                aRotBai := {}
                fBusRot(cEmp, cFil, @aRotBai, TCQ->ZZA_ORDEM, TCQ->ZZA_PRODUT, Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_ROTEIRO"))
                If Len(aRotBai) > 0.0
                   nQtdOri := Round(Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_QUANT"), 4)
                   nQtdBai := Round(TCQ->ZZA_QUANT, 4)
                   For nSLT := 1 To Len(aRotBai)
                       If Empty(aRotBai[nSLT][4]) //VERIFICA SE OPERA«√O J¡ FOI BAIXADA
                          aOpeBai := {}
                          aAdd(aOpeBai, {"H6_OP"     , TCQ->ZZA_ORDEM                          , Nil } )
                          aAdd(aOpeBai, {"H6_PRODUTO", TCQ->ZZA_PRODUT                         , Nil } )
                          aAdd(aOpeBai, {"H6_QTDPROD", Round(TCQ->ZZA_QUANT                    , 4), Nil } )
                          aAdd(aOpeBai, {"H6_OPERAC" , aRotBai[nSLT][1]                        , Nil } )
                          aAdd(aOpeBai, {"H6_RECURSO", aRotBai[nSLT][2]                        , Nil } )
                          aAdd(aOpeBai, {"H6_DATAINI", STOD(TCQ->ZZA_DTINI)                    , Nil } )
                          aAdd(aOpeBai, {"H6_HORAINI", TransForm(TCQ->ZZA_HINI, '@R 99:99')    , Nil } )
                          aAdd(aOpeBai, {"H6_DATAFIN", STOD(TCQ->ZZA_DTFIM)                    , Nil } )
                          aAdd(aOpeBai, {"H6_HORAFIN", TransForm(TCQ->ZZA_HFIM, '@R 99:99')    , Nil } )
                          aAdd(aOpeBai, {"H6_DTAPONT", dDataBase                               , Nil } )

                          lMsErroAuto := .f.
                          MsExecAuto( {|x, y| Mata681(x, y)}, aOpeBai, 3)
                          If !lMsErroAuto
                             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                             //ConOut("      -- 07/03 - OPERACAO "+aRotBai[nSLT][1]+" BAIXADA!")
                             _cAuxMens := "      -- 07/03 - OPERACAO "+aRotBai[nSLT][1]+" BAIXADA!"
                             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                             If nQtdBai >= nQtdOri
                                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'ORDEM DE PRODUCAO BAIXADA', ZZA_CAMPO = '', ZZA_FLAG = 'P' "
                             Else
                                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'APT_PERDA', ZZA_CAMPO = '07 - APONTAMENTO DE PERDA N√O EXECUTADO', ZZA_FLAG = '5' "
                             Endif
                             cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                             cQry1 += "  AND D_E_L_E_T_ = '' "
                             cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                             TCSQLExec(cQry1)
                             aRotBai[nSLT][4] := aRotBai[nSLT][1] //Da baixa da operaÁ„o na Matriz do Roteiro
                          Else
                             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                             //ConOut("      -- 07/03 - OPERACAO "+aRotBai[nSLT][1]+" NAO FOI BAIXADA!")
                             _cAuxMens := "      -- 07/03 - OPERACAO "+aRotBai[nSLT][1]+" NAO FOI BAIXADA!"
                             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                             cErro := NomeAutoLog()
                             cHelp := ""
                             cCamp := "07 - "
                             nLinErr := MlCount(MemoRead(cErro))
                             For nY := 1 To nLinErr
                                 If Empty(cHelp)
                                    If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                       cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    Endif
                                 Endif
                                 If Empty(cCamp)
                                    If 'MA240NEGAT' $ Upper(Alltrim(cHelp))
                                       If 'SEM SALDO EM ESTOQUE' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                          cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                       Endif
                                    ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                           cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    Endif
                                 Endif
                             Next
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                             cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+" "+cErro+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"', ZZA_OPERAC = '"+aRotBai[nSLT][1]+"' "
                             cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                             cQry1 += "  AND D_E_L_E_T_ = '' "
                             cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                             TCSQLExec(cQry1)
                          Endif
                       Endif
                   Next
                Else
                   cQry1 := ""
                   cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                   cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'SEM_ROTEIRO', ZZA_CAMPO = '07 - ORDEM DE PRODU«√O SEM ROTEIRO' "
                   cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                   cQry1 += "  AND D_E_L_E_T_ = '' "
                   cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                   TCSQLExec(cQry1)
                Endif
             Else
                cQry1 := ""
                cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'FALTA_BAIXA', ZZA_CAMPO = '07 - EMPENHOS N√O FORAM BAIXADOS' "
                cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                cQry1 += "  AND D_E_L_E_T_ = '' "
                cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                TCSQLExec(cQry1)
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return*/

/******************************************************************************************************************/
/***                                        EXECUTA APONTAMENTO DE PERDA                                        ***/
/******************************************************************************************************************/
/*STATIC Function fProcAPP(cEmp, cFil, dDatFin, dDataFec)
       Local cQry1      := ""
       Local cAlias     := "SD3"
       Private nOpcA    := 2
       Private nRecSD3  := 0
       Private lDelOPSC := .t.
       Private lPerdInf := .t.
       Private lProdAut := .f.
       //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
       //ConOut("-- 06 - BUSCANDO ORDENS DE PRODUCAO PARA SEREM ENCERRADAS.")
       _cAuxMens := "-- 06 - BUSCANDO ORDENS DE PRODUCAO PARA SEREM ENCERRADAS."
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       cQry1 += "SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_PRODUT, ZZA.ZZA_QUANT, SC2.C2_OP, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_QUJE, SC2.C2_DATRF, ZZA_HELP, ZZA_CAMPO "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = '' "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_LOTE   = '' "
       cQry1 += "  AND ZZA.ZZA_FLAG   = '5' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "
       cQry1 += "  AND SC2.C2_QUJE    < SC2.C2_QUANT "
       cQry1 += "ORDER BY ZZA.ZZA_ORDEM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             DbSelectArea("SD3")
             DbSetOrder(1)
             DbSeek(xFilial("SD3")+TCQ->ZZA_ORDEM+Space(13 - Len(TCQ->ZZA_ORDEM))+TCQ->ZZA_PRODUT, .t.)
             If Found()
                While !Eof() .and. Alltrim(SD3->D3_OP) == Alltrim(TCQ->ZZA_ORDEM) .and. Alltrim(SD3->D3_COD) == Alltrim(TCQ->ZZA_PRODUT)
                      If !SD3->D3_ESTORNO == 'S'
                         //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                         //ConOut("      06/01 - ENCERRANDO ORDEM....: "+SD3->D3_OP)
                         _cAuxMens := "      06/01 - ENCERRANDO ORDEM....: "+SD3->D3_OP
                         FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                         nRecSD3 := recno()
                         a250End(.t.)
                         If Alltrim(SC2->C2_OP) == Alltrim(TCQ->ZZA_ORDEM)
                            cQry1 := ""
                            cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                            cQry1 += "SET ZZA_FLAG = 'P', ZZA_HELP = 'ORDEM DE PRODUCAO BAIXADA', ZZA_CAMPO = '', ZZA_PERDA = "+StrTran(TransForm(SC2->C2_QUANT - SC2->C2_QUJE ,'@E 99999.99999'), ",", ".")+", ZZA_SP = 'P' "
                            cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                            cQry1 += "  AND D_E_L_E_T_ = '' "
                            cQry1 += "  AND ZZA_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                            TCSQLExec(cQry1)
                         Endif
                      Endif
                      DbSelectArea("SD3")
                      DbSkip()
                EndDo
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return(Nil)*/

/******************************************************************************************************************/
/***                              BAIXA DA ORDEM DE PRODU«√O DE PRODUTOS SEM LOTE                               ***/
/******************************************************************************************************************/
/*STATIC Function fProcSLT(cEmp, cFil, dDatFin, cCodBaiR)
       Local cQry1    := ""
       Local aRotBai  := {}
       Local aErrBai  := {}
       Local cMenRet  := ""
       Local nY, nSLT

       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_FLAG   = '4' "
       cQry1 += "  AND ZZA.ZZA_LOTE   = '' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "
       cQry1 += "ORDER BY ZZA.ZZA_DTFIM+ZZA.ZZA_HFIM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             aErrBai  := {}
             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
             //ConOut("-- 05 - PROCESSANDO ORDEM...: "+TransForm(TCQ->ZZA_ORDEM, "@R 999999-99-999"))
             //ConOut("      -- 05/01 - VERIFICANDO BAIXAS DOS EMPENHOS")
             _cAuxMens := "-- 05 - PROCESSANDO ORDEM...: "+TransForm(TCQ->ZZA_ORDEM, "@R 999999-99-999") + CHR(13) + CHR(10)
             _cAuxMens += "      -- 05/01 - VERIFICANDO BAIXAS DOS EMPENHOS"
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             cQry1 := ""
             cQry1 += "SELECT ZZF.ZZF_OBS, ZZF.ZZF_CODIGO, ZZF.ZZF_QTDUSA "
             cQry1 += "FROM "+RetSqlName("ZZF")+" ZZF WITH (NOLOCK) "
             cQry1 += "WHERE ZZF.ZZF_FILIAL = '"+cFil+"' "
             cQry1 += "  AND ZZF.D_E_L_E_T_ = '' "
             cQry1 += "  AND ZZF.ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
             cQry1 += "  AND ZZF.ZZF_FLAG  <> '1' "
             TCQuery cQry1 ALIAS "XZZF" NEW
             DbSelectArea("XZZF")
             DbGoTop()
             While !Eof()
                   aAdd(aErrBai, {XZZF->ZZF_OBS, XZZF->ZZF_CODIGO, XZZF->ZZF_QTDUSA} )
                   DbSelectArea("XZZF")
                   DbSkip()
             Enddo
             DbSelectArea("XZZF")
             DbCloseArea()
             If Len(aErrBai) <= 0.0
                //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                //ConOut("      -- 05/02 - BUSCANDO ROTEIRO DE OPERA«’ES")
                _cAuxMens := "      -- 05/02 - BUSCANDO ROTEIRO DE OPERA«’ES"
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                aRotBai := {}
                fBusRot(cEmp, cFil, @aRotBai, TCQ->ZZA_ORDEM, TCQ->ZZA_PRODUT, Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_ROTEIRO"))
                If Len(aRotBai) > 0.0
                   nQtdOri := Round(Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_QUANT"), 4)
                   nQtdBai := Round(TCQ->ZZA_QUANT, 4)
                   For nSLT := 1 To Len(aRotBai)
                       If Empty(aRotBai[nSLT][4]) //VERIFICA SE OPERA«√O J¡ FOI BAIXADA
                          aOpeBai := {}
                          aAdd(aOpeBai, {"H6_OP"     , TCQ->ZZA_ORDEM                          , Nil } )
                          aAdd(aOpeBai, {"H6_PRODUTO", TCQ->ZZA_PRODUT                         , Nil } )
                          aAdd(aOpeBai, {"H6_QTDPROD", Round(TCQ->ZZA_QUANT                    , 4), Nil } )
                          aAdd(aOpeBai, {"H6_OPERAC" , aRotBai[nSLT][1]                        , Nil } )
                          aAdd(aOpeBai, {"H6_RECURSO", aRotBai[nSLT][2]                        , Nil } )
                          aAdd(aOpeBai, {"H6_DATAINI", STOD(TCQ->ZZA_DTINI)                    , Nil } )
                          aAdd(aOpeBai, {"H6_HORAINI", TransForm(TCQ->ZZA_HINI, '@R 99:99')    , Nil } )
                          aAdd(aOpeBai, {"H6_DATAFIN", STOD(TCQ->ZZA_DTFIM)                    , Nil } )
                          aAdd(aOpeBai, {"H6_HORAFIN", TransForm(TCQ->ZZA_HFIM, '@R 99:99')    , Nil } )
                          aAdd(aOpeBai, {"H6_DTAPONT", dDataBase                               , Nil } )

                          lMsErroAuto := .f.
                          MsExecAuto( {|x, y| Mata681(x, y)}, aOpeBai, 3)
                          If !lMsErroAuto
                             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                             //ConOut("      -- 05/03 - OPERACAO "+aRotBai[nSLT][1]+" BAIXADA!")
                             _cAuxMens := "      -- 05/03 - OPERACAO "+aRotBai[nSLT][1]+" BAIXADA!"
                             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                             If nQtdBai >= nQtdOri
                                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'ORDEM DE PRODUCAO BAIXADA', ZZA_CAMPO = '', ZZA_FLAG = 'P' "
                             Else
                                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'APT_PERDA', ZZA_CAMPO = '05 - APONTAMENTO DE PERDA N√O EXECUTADO', ZZA_FLAG = '5' "
                             Endif
                             cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                             cQry1 += "  AND D_E_L_E_T_ = '' "
                             cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                             TCSQLExec(cQry1)
                             aRotBai[nSLT][4] := aRotBai[nSLT][1] //Da baixa da operaÁ„o na Matriz do Roteiro
                          Else
                             //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
                             //ConOut("      -- 05/03 - OPERACAO "+aRotBai[nSLT][1]+" NAO FOI BAIXADA!")
                             _cAuxMens := "      -- 05/03 - OPERACAO "+aRotBai[nSLT][1]+" NAO FOI BAIXADA!"
                             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                             cErro := NomeAutoLog()
                             cHelp := ""
                             cCamp := "05 - "
                             nLinErr := MlCount(MemoRead(cErro))
                             For nY := 1 To nLinErr
                                 If Empty(cHelp)
                                    If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                       cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    Endif
                                 Endif
                                 If Empty(cCamp)
                                    If 'MA240NEGAT' $ Upper(Alltrim(cHelp))
                                       If 'SEM SALDO EM ESTOQUE' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                          cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                       Endif
                                    ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                           cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    Endif
                                 Endif
                             Next
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                             cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+" "+cErro+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"', ZZA_OPERAC = '"+aRotBai[nSLT][1]+"' "
                             cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                             cQry1 += "  AND D_E_L_E_T_ = '' "
                             cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                             TCSQLExec(cQry1)
                          Endif
                       Endif
                   Next
                Else
                   cQry1 := ""
                   cQry1 += "UPDATE "+RetSqlName("ZZA")+' "
                   cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'SEM_ROTEIRO', ZZA_CAMPO = '05 - ORDEM DE PRODU«√O SEM ROTEIRO' "
                   cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                   cQry1 += "  AND D_E_L_E_T_ = '' "
                   cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                   TCSQLExec(cQry1)
                Endif
             Else
                cQry1 := ""
                cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'FALTA_BAIXA', ZZA_CAMPO = '05 - EMPENHOS N√O FORAM BAIXADOS' "
                cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                cQry1 += "  AND D_E_L_E_T_ = '' "
                cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                TCSQLExec(cQry1)
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return*/

/******************************************************************************************************************/
/*** FBUSPAR - BUSCA PAR¬METROS UTILIZADOS NO PROCESSAMENTO                                                     ***/
/******************************************************************************************************************/
STATIC Function fBusPar(dDatFin, cCodBaiR, cBaiPro)
//Local cAuxMv
		dDatFin := getmv("MV_BXOPFEC")
		cCodBaiR := getmv("MV_CBAIREQ")
		dDataFec := getmv("MV_ULMES")
		cBaiPro := GETMV("MV_BXPROP")
		/*
       ConOut("-- ABRINDO SX6...")
       DbUseArea(.t., __LocalDrive, 'SX6'+substr(cNumEmp,1,2)+'0', 'TSX6', .t., .f.)
       ConOut("   -- Tabela Aberta...")
       DbSelectArea("TSX6")
       DbSetOrder(1)
       DbSeek('  MV_BXOPFEC')  //Data Final para baixa de Ordens de produÁ„o
       If Found()
          dDatFin := Alltrim(TSX6->X6_CONTEUD) 
       Endif
	   */
       //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
       //ConOut("      -- Data Final para baixa..............: "+DtoC(Stod(dDatFin)))
       _cAuxMens := "      -- Data Final para baixa..............: "+DtoC(Stod(dDatFin))
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       /*
	   DbSeek('  MV_CBAIREQ')
       If Found()
          cCodBaiR    := Alltrim(TSX6->X6_CONTEUD)
       Endif
       DbSeek('01MV_ULMES')
       If Found()
          dDataFec    := STOD(Alltrim(TSX6->X6_CONTEUD))
       Endif
	   */
       //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
       //ConOut("      -- Data Ultimo Fechamento.............: "+Dtoc(dDataFec))
       _cAuxMens := "      -- Data Ultimo Fechamento.............: "+Dtoc(dDataFec)
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
	   /*
       DbSeek('01MV_BXPROP')
       If Found()
          cBaiPro    := Alltrim(TSX6->X6_CONTEUD)
       Endif
	   */
	   //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
       //ConOut("      -- Codigo para Requisicao de Materiais: "+cCodBaiR)
       _cAuxMens := "      -- Codigo para Requisicao de Materiais: "+cCodBaiR
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       //ConOut("--")
       If cBaiPro $ 'N'
          //LGS#20200212 - AdequaÁ„o de release 12.1.25 e posteriores
          //ConOut("      -- Processo de Baixa antigo deve estar rodando.: "+cBaiPro)
          _cAuxMens := "      -- Processo de Baixa antigo deve estar rodando.: "+cBaiPro
          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
          //ConOut("--")
       Endif
	   /*
       TSX6->(DbCloseArea())
       ConOut("-- Tabela Fechada!")
	   */
Return

/******************************************************************************************************************/
/*** FBUSEXC - BUSCA CODIGO DE RETEN«√O E FILTROS QUE N√O SERAM BAIXADOS NA PESAGEM DA F”RMULA                  ***/
/******************************************************************************************************************/
/*STATIC Function fBusExc(cEmp, cFil, cPro, cAuxQry1, cAuxQry2)
       cAuxQry1 := ""
       cAuxQry2 := ""
       If Len(Alltrim(TCQ->ZZA_PRODUT)) == 12
          cQry1 := ""
          cQry1 += "SELECT * "
          cQry1 += "FROM "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) "
          cQry1 += "WHERE SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"' "
          cQry1 += "  AND SZ1.D_E_L_E_T_ = '' "
          cQry1 += "  AND SZ1.Z1_LINHA = '"+SubStr(cPro, 4, 2)+"' "
          TCQuery cQry1 ALIAS "XZ1" NEW
          DbSelectArea("XZ1")
          DbGoTop()
          If !Empty(XZ1->Z1_PRODRET)
             cAuxQry1 += "  AND SD4.D4_COD NOT IN('"+XZ1->Z1_PRODRET+"' "
             cAuxQry2 += "  AND ZZF.ZZF_CODIGO NOT IN('"+XZ1->Z1_PRODRET+"' "
          Endif
          If !Empty(cAuxQry1)
             If !Empty(XZ1->Z1_CODFILT)
                cAuxQry1 += ", '"+XZ1->Z1_CODFILT+"') "
                cAuxQry2 += ", '"+XZ1->Z1_CODFILT+"') "
             Else
                cAuxQry1 += ") "
                cAuxQry2 += ") "
             Endif
          Else
             If !Empty(XZ1->Z1_CODFILT)
                cAuxQry1 += "  AND SD4.D4_COD NOT IN('"+XZ1->Z1_CODFILT+"') "
                cAuxQry2 += "  AND ZZF.ZZF_CODIGO NOT IN('"+XZ1->Z1_CODFILT+"') "
             Endif
          Endif
          DbSelectArea("XZ1")
          DbCloseArea()
       Endif
Return*/

/******************************************************************************************************************/
/*** FBUSROT - BUSCA ROTEIRO DE OPERA«√O PARA BAIXAS DAS ORDENS DE PRODU«’ES                                    ***/
/******************************************************************************************************************/
/*STATIC Function fBusRot(cEmp, cFil, aRotBai, cOrdem, cProduto, cRoteiro)
       cQrySG2 := ""
       cQrySG2 += "SELECT SG2.G2_OPERAC, SG2.G2_RECURSO, SG2.G2_DESCRI "
       cQrySG2 += "FROM SG2"+cEmp+"0 SG2 "
       cQrySG2 += "WHERE SG2.G2_FILIAL  = '"+cFil+"' "
       cQrySG2 += "  AND SG2.D_E_L_E_T_ = '' "
       cQrySG2 += "  AND SG2.G2_CODIGO  = '"+cRoteiro+"' "
       cQrySG2 += "  AND SG2.G2_PRODUTO = '"+cProduto+"' "
       cQrySG2 += "ORDER BY SG2.G2_OPERAC "
       TCQuery cQrySG2 ALIAS "ROT" NEW
       DbSelectArea("ROT")
       While !Eof()
             aAdd(aRotBai, {ROT->G2_OPERAC, ROT->G2_RECURSO, ROT->G2_DESCRI, Posicione("SH6", 1, cFil+SubStr(cOrdem+space(10), 1, 13)+cProduto+ROT->G2_OPERAC, "H6_OPERAC")})
             DbSelectArea("ROT")
             DbSkip()
       Enddo
       DbSelectArea("ROT")
       DbCloseArea()
Return*/
