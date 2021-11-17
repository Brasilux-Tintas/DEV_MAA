//#include 'brasilux.ch'
#include "protheus.ch"
#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRSCH009 บAutor  ณ Luํs G. de Souza   บ Data ณ  04/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Baixa de Ordens de produ็ใo por processo - Nova Versใo     บฑฑ
ฑฑบ          ณ para baixa de Ops atrav้s da tabela ZZA.                   บฑฑ
ฑฑบ          ณ             PROCESSO DE FINALIZAวรO DE PESAGEM             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRSCH009(aParm)
     //Local nOpc      := Iif(ValType(aParm) == 'U', 2, 1)
     Local cEmp      := Alltrim(Transform(aParm[1],'@!'))
     Local cFil      := Alltrim(Transform(aParm[2],'@!'))
     Local dDatFin   := ""
     Local cCodBaiR  := ""
     Local cBaiPro   := ""
     Local _cAuxMens := ""

     RPCSetType(3)  // Nao utilizar licenca
     PREPARE ENVIRONMENT EMPRESA '01' FILIAL '010101' TABLES "SB1", "SC2", "SD3", "SD4", "SH6"
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("-- BRSCH009 - BAIXA DE ORDENS DE PRODUวรO")
             //ConOut("-- BRSCH009 - Thread iniciada com sucesso as: "+Time()+" - "+dToc(MSDate()))
             //ConOut("-- BRSCH009 - Empresa: "+cEmp+" - Filial: "+cFil)
             _cAuxMens := "-- BRSCH009 - BAIXA DE ORDENS DE PRODUวรO" + CHR(13) + CHR(10)
             _cAuxMens += "-- BRSCH009 - Thread iniciada com sucesso as: "+Time()+" - "+dToc(MSDate()) + CHR(13) + CHR(10)
             _cAuxMens += "-- BRSCH009 - Empresa: "+cEmp+" - Filial: "+cFil
             //ConOut("--")
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             /***************************************************************************************/
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("-- ABERTURA DA TABELA DE PARAMETROS...")
             _cAuxMens := "-- ABERTURA DA TABELA DE PARAMETROS..."
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
             fBusPar(@dDatFin, @cCodBaiR, @cBaiPro)
             //ConOut("###############################################################################")
             //ConOut("-- FIM")
             /***************************************************************************************/
             If cBaiPro $ 'S'
                //ConOut("##############   BAIXA DE ORDENS DE PRODUCAO ENVASE - PARCIAL   ###############")
                //fProcENP(cEmp, cFil, dDatFin, cCodBaiR)
                //ConOut("###############################################################################")
                //ConOut("--")
                /***************************************************************************************/

                //ConOut("###############   BAIXA DE ORDENS DE PRODUCAO ENVASE - TOTAL   ################")
                //fProcENT(cEmp, cFil, dDatFin, cCodBaiR)
                //ConOut("###############################################################################")
                //ConOut("--")
                /***************************************************************************************/
                //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                //ConOut("-- FIM")
                _cAuxMens := "-- FIM"
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
             Else
                //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                //ConOut("############   BAIXAS DE PRODUวรO NรO EXECUTADA - MV_BXPROP = N   #############")
                //ConOut("-- FIM")
                _cAuxMens := "############   BAIXAS DE PRODUวรO NรO EXECUTADA - MV_BXPROP = N   #############"
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             Endif
     RESET ENVIRONMENT
Return(Nil)

/******************************************************************************************************************/
/***                           BAIXA DA ORDEM DE PRODUวรO DE PRODUTOS ENVASE - TOTAL                            ***/
/******************************************************************************************************************/
/*STATIC Function fProcENT(cEmp, cFil, dDatFin, cCodBaiR)
       Local cQry1    := ""
       Local aRotBai  := ""
       Local cMsgTot  := ""
       Local nY, nSLT
       Local _cAuxMens := ""

       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_FLAG   = '8' "
       cQry1 += "  AND ZZA.ZZA_LOTE  <> '' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "
       cQry1 += "  AND ZZA.ZZA_RAMPA  = 'S' "
       cQry1 += "ORDER BY ZZA.ZZA_DTFIM+ZZA.ZZA_HFIM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             cMsgTot := ""
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("-- 10 - Processando ordem ...: "+TransForm(TCQ->ZZA_ORDEM, "@R 999999-99-999"))
             _cAuxMens := "-- 10 - Processando ordem ...: "+TransForm(TCQ->ZZA_ORDEM, "@R 999999-99-999")
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
             lRet := fAjuEmp(cEmp, cFil, @cMsgTot, dDatFin)
             If lRet
                aRotBai := {}
                //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                //ConOut("   -- 10/01 - Buscando Roteiro de Opera็๕es...")
                _cAuxMens := "   -- 10/01 - Buscando Roteiro de Opera็๕es..."
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                fBusRot(cEmp, cFil, @aRotBai, TCQ->ZZA_ORDEM, TCQ->ZZA_PRODUT, Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_ROTEIRO"))
                If Len(aRotBai) > 0 
                   For nSLT := 1 To Len(aRotBai)
                       If Empty(aRotBai[nSLT][4])
                          cCamp := ""
                          aOpeBai := {}
                          aAdd(aOpeBai, {"H6_OP"     , TCQ->ZZA_ORDEM                      , Nil } )
                          aAdd(aOpeBai, {"H6_PRODUTO", TCQ->ZZA_PRODUT                     , Nil } )
                          aAdd(aOpeBai, {"H6_QTDPROD", Round(TCQ->ZZA_QUANT, 4)            , Nil } )
                          aAdd(aOpeBai, {"H6_OPERAC" , aRotBai[nSLT][1]                    , Nil } )
                          aAdd(aOpeBai, {"H6_RECURSO", aRotBai[nSLT][2]                    , Nil } )
                          aAdd(aOpeBai, {"H6_PT"     , TCQ->ZZA_TPENVA                     , Nil } )
                          aAdd(aOpeBai, {"H6_DATAINI", STOD(TCQ->ZZA_DTINI)                , Nil } )
                          aAdd(aOpeBai, {"H6_HORAINI", TransForm(TCQ->ZZA_HINI, '@R 99:99'), Nil } )
                          aAdd(aOpeBai, {"H6_DATAFIN", STOD(TCQ->ZZA_DTFIM)                , Nil } )
                          aAdd(aOpeBai, {"H6_HORAFIN", TransForm(TCQ->ZZA_HFIM, '@R 99:99'), Nil } )
                          aAdd(aOpeBai, {"H6_DTAPONT", dDataBase                           , Nil } )

                          DbSelectArea("SH6")
                          lMsErroAuto := .f.
                          MsExecAuto( {|x| Mata681(x)}, aOpeBai, 3)
                          If !lMsErroAuto
                             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                             //ConOut("   -- 10/07 - Opera็ใo "+aRotBai[nSLT][1]+" Baixada!")
                             _cAuxMens := "   -- 10/07 - Opera็ใo "+aRotBai[nSLT][1]+" Baixada!"
                             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                             cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'OPERAวรO BAIXADA', ZZA_CAMPO = '', ZZA_OPERAC = '"+aRotBai[nSLT][1]+"' "
                             cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                             cQry1 += "  AND D_E_L_E_T_ = '' "
                             cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                             TCSQLExec(cQry1)
                             aRotBai[nSLT][4] := aRotBai[nSLT][1]
                          Else 
                             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                             //ConOut("   -- 10/08 - Opera็ใo "+aRotBai[nSLT][1]+" nao foi baixada.")
                             _cAuxMens := "   -- 10/08 - Opera็ใo "+aRotBai[nSLT][1]+" nao foi baixada."
                             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                             cErro := NomeAutoLog()
                             cHelp := ""
                             cCamp := "10 - "
                             nLinErr := MlCount(MemoRead(cErro))
                             For nY := 1 To nLinErr
                                 If Empty(cHelp)
                                    If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                       cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    Endif
                                 Endif
                                 If 'MA240NEGAT' $ Upper(Alltrim(cHelp))
                                    If 'SEM SALDO EM ESTOQUE' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                       cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    Endif
                                 ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                        cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                 Endif
                                 If !Empty(cMsgTot)
                                    cCamp := "10 - "+cMsgTot
                                 Endif
                             Next
                             cQry1 := ""
                             cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                             cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"', ZZA_OPERAC = '"+aRotBai[nSLT][1]+"' "
                             cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                             cQry1 += "  AND D_E_L_E_T_ = '' "
                             cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                             TCSQLExec(cQry1)
                          Endif
                       Endif
                   Next
                   //Verifica็ใo de todas as baixas
                   lConBai := .t.
                   For nSLT := 1 To Len(aRotBai)
                       If Empty(aRotBai[nSLT][4])
                          lConBai := .f.
                       Endif
                   Next
                   If lConBai
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                      cQry1 += "SET ZZA_FLAG = '5' "
                      cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                      cQry1 += "  AND D_E_L_E_T_ = '' "
                      cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                      TCSQLExec(cQry1)
                   Endif
                Else
                   //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                   //ConOut("   -- ROTEIRO DE OPERAวีES NรO ENCONTRADO...")
                   _cAuxMens := "   -- ROTEIRO DE OPERAวีES NรO ENCONTRADO..."
                   FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                   cQry1 := ""
                   cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                   cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'ORDEM DE PRODUวรO SEM ROTEIRO', ZZA_CAMPO = '' "
                   cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                   cQry1 += "  AND D_E_L_E_T_ = '' "
                   cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                   TCSQLExec(cQry1)
                Endif
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
Return*/

/******************************************************************************************************************/
/***                          BAIXA DA ORDEM DE PRODUวรO DE PRODUTOS ENVASE - PARCIAL                           ***/
/******************************************************************************************************************/
/*STATIC Function fProcENP(cEmp, cFil, dDatFin, cCodBaiR)
       Local cQry1    := ""
       Local aRotBai  := ""
       Local nY, nSLT
       Local _cAuxMens := ""

       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_FLAG   = '7' "
       cQry1 += "  AND ZZA.ZZA_LOTE  <> '' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "
       cQry1 += "  AND ZZA.ZZA_RAMPA  = 'S' "
       cQry1 += "ORDER BY ZZA.ZZA_DTFIM+ZZA.ZZA_HFIM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("-- 09 - Processando ordem ...: "+TransForm(TCQ->ZZA_ORDEM, "@R 999999-99-999"))
             _cAuxMens := "-- 09 - Processando ordem ...: "+TransForm(TCQ->ZZA_ORDEM, "@R 999999-99-999")
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             aRotBai := {}
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("   -- 09/01 - Buscando Roteiro de Opera็๕es...")
             _cAuxMens := "   -- 09/01 - Buscando Roteiro de Opera็๕es..."
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
             fBusRot(cEmp, cFil, @aRotBai, TCQ->ZZA_ORDEM, TCQ->ZZA_PRODUT, Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_ROTEIRO"))
             If Len(aRotBai) > 0 
                For nSLT := 1 To Len(aRotBai)
                    If Empty(aRotBai[nSLT][4])
                       aOpeBai := {}
                       aAdd(aOpeBai, {"H6_OP"     , TCQ->ZZA_ORDEM                      , Nil } )
                       aAdd(aOpeBai, {"H6_PRODUTO", TCQ->ZZA_PRODUT                     , Nil } )
                       aAdd(aOpeBai, {"H6_QTDPROD", Round(TCQ->ZZA_QUANT, 4)            , Nil } )
                       aAdd(aOpeBai, {"H6_OPERAC" , aRotBai[nSLT][1]                    , Nil } )
                       aAdd(aOpeBai, {"H6_RECURSO", aRotBai[nSLT][2]                    , Nil } )
                       aAdd(aOpeBai, {"H6_PT"     , TCQ->ZZA_TPENVA                     , Nil } )
                       aAdd(aOpeBai, {"H6_DATAINI", STOD(TCQ->ZZA_DTINI)                , Nil } )
                       aAdd(aOpeBai, {"H6_HORAINI", TransForm(TCQ->ZZA_HINI, '@R 99:99'), Nil } )
                       aAdd(aOpeBai, {"H6_DATAFIN", STOD(TCQ->ZZA_DTFIM)                , Nil } )
                       aAdd(aOpeBai, {"H6_HORAFIN", TransForm(TCQ->ZZA_HFIM, '@R 99:99'), Nil } )
                       aAdd(aOpeBai, {"H6_DTAPONT", dDataBase                           , Nil } )

                       DbSelectArea("SH6")
                       lMsErroAuto := .f.
                       MsExecAuto( {|x| Mata681(x)}, aOpeBai, 3)
                       If !lMsErroAuto
                          //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                          ConOut("   -- 09/01 - Opera็ใo "+aRotBai[nSLT][1]+" Baixada!")
                          _cAuxMens := "   -- 09/01 - Opera็ใo "+aRotBai[nSLT][1]+" Baixada!"
                          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
                          cQry1 := ""
                          cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                          cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'ORDEM DE PRODUCAO BAIXADA', ZZA_CAMPO = '', ZZA_FLAG = '5' "
                          cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                          cQry1 += "  AND D_E_L_E_T_ = '' "
                          cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                          TCSQLExec(cQry1)
                          aRotBai[nSLT][4] := aRotBai[nSLT][1]
                       Else 
                          //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                          ConOut("   -- 09/02 - Opera็ใo "+aRotBai[nSLT][1]+" nao foi baixada.")
                          _cAuxMens := "   -- 09/02 - Opera็ใo "+aRotBai[nSLT][1]+" nao foi baixada."
                          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
                          cErro := NomeAutoLog()
                          cHelp := ""
                          cCamp := "09 - "
                          nLinErr := MlCount(MemoRead(cErro))
                          For nY := 1 To nLinErr
                              If Empty(cHelp)
                                 If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                 Endif
                              Endif
                              If 'MA240NEGAT' $ Upper(Alltrim(cHelp))
                                 If 'SEM SALDO EM ESTOQUE' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                    cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                 Endif
                              ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                     cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                              Endif
                          Next
                          cQry1 := ""
                          cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                          cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"', ZZA_OPERAC = '"+aRotBai[nSLT][1]+"' "
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
                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'SEM_ROTEIRO', ZZA_CAMPO = '09 - ORDEM DE PRODUวรO SEM ROTEIRO' "
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
/*** FBUSPAR - BUSCA PARยMETROS UTILIZADOS NO PROCESSAMENTO                                                     ***/
/******************************************************************************************************************/
STATIC Function fBusPar(dDatFin, cCodBaiR, cBaiPro)
       Local _cAuxMens := "" 
	dDatFin := ALLTRIM(GETMV("MV_BXOPFEC"))
	cCodBaiR := GETMV("MV_CBAIREQ")
	cBaiPro := GETMV("MV_BXPROP")
	
	/*
       ConOut("-- ABRINDO SX6...")
       DbUseArea(.t., __LocalDrive, 'SX6'+substr(cNumEmp,1,2)+'0', 'TSX6', .t., .f.)
       ConOut("   -- Tabela Aberta...")
       DbSelectArea("TSX6")
       DbSetOrder(1)
       DbSeek('  MV_BXOPFEC')  //Data Final para baixa de Ordens de produ็ใo
       If Found()
          dDatFin := Alltrim(TSX6->X6_CONTEUD) 
       Endif
	  */
	  //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
       //ConOut("      -- Data Final para baixa..............: "+DtoC(Stod(dDatFin)))
       _cAuxMens := "      -- Data Final para baixa..............: "+DtoC(Stod(dDatFin))
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 ) 
	   /*
       DbSeek('  MV_CBAIREQ')
       If Found()
          cCodBaiR    := Alltrim(TSX6->X6_CONTEUD)
       Endif
       DbSeek('01MV_BXPROP')
       If Found()
          cBaiPro    := Alltrim(TSX6->X6_CONTEUD)
       Endif
	   */
       //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
       //ConOut("      -- Codigo para Requisicao de Materiais: "+cCodBaiR)
       //ConOut("--")
       _cAuxMens := "      -- Codigo para Requisicao de Materiais: "+cCodBaiR
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       If cBaiPro $ 'N'
          //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
          //ConOut("      -- Processo de Baixa antigo deve estar rodando.: "+cBaiPro)
          //ConOut("--")
          _cAuxMens := "      -- Processo de Baixa antigo deve estar rodando.: "+cBaiPro
          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       Endif
	   /*
       TSX6->(DbCloseArea())
       ConOut("-- Tabela Fechada!")
	   */
Return

/******************************************************************************************************************/
/*** FBUSROT - BUSCA ROTEIRO DE OPERAวรO PARA BAIXAS DAS ORDENS DE PRODUวีES                                    ***/
/******************************************************************************************************************/
/*STATIC Function fBusRot(cEmp, cFil, aRotBai, cOrdem, cProduto, cRoteiro)
       Local cCodOpe := ''

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
             If !Empty(Posicione("SH6", 1, cFil+SubStr(cOrdem+space(10), 1, 13)+cProduto+ROT->G2_OPERAC, "H6_OPERAC"))
                If Posicione("SH6", 1, cFil+SubStr(cOrdem+space(10), 1, 13)+cProduto+ROT->G2_OPERAC, "H6_PT") $ 'P'
                   cCodOpe := space(02)
                Else
                   cCodOpe := Posicione("SH6", 1, cFil+SubStr(cOrdem+space(10), 1, 13)+cProduto+ROT->G2_OPERAC, "H6_OPERAC")
                Endif
             Else
                cCodOpe := Posicione("SH6", 1, cFil+SubStr(cOrdem+space(10), 1, 13)+cProduto+ROT->G2_OPERAC, "H6_OPERAC")
             Endif
             aAdd(aRotBai, {ROT->G2_OPERAC, ROT->G2_RECURSO, ROT->G2_DESCRI, cCodOpe})
             DbSelectArea("ROT")
             DbSkip()
       Enddo
       DbSelectArea("ROT")
       DbCloseArea()
Return*/

/******************************************************************************************************************/
/*** FAJUEMP - EXECUTA O AJUSTE DE EMPENHO PARA PRODUTOS QUE FICARAM NO ULTIMO PROCESSO                         ***/
/******************************************************************************************************************/
/*STATIC Function fAjuEmp(cEmp, cFil, cMsgTot, dDatFin)
       Local lRet    := .t.
       Local nSomPar := 0
       Local lParSAp := .f.
       Local nQtdOrd := 0
       Local aEmpPro := {}
       Local nConAju := 0
       Local nY
       Local _cAuxMens := ""
       
       lRet := .f.
       //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
       //ConOut("   -- 10/01 - Verificando baixas parciais para a OP: "+TCQ->ZZA_ORDEM)
       _cAuxMens := "   -- 10/01 - Verificando baixas parciais para a OP: "+TCQ->ZZA_ORDEM
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       cQry1 := ""
       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_LOTE  <> '' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "
       cQry1 += "  AND ZZA.ZZA_TPENVA <> 'T' "
       cQry1 += "  AND ZZA.ZZA_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
       cQry1 += "ORDER BY ZZA.ZZA_DTFIM+ZZA.ZZA_HFIM "
       TCQuery cQry1 ALIAS "TSTR" NEW
       DbSelectArea("TSTR")
       While !Eof()
             nSomPar += TSTR->ZZA_QUANT
             If TSTR->ZZA_FLAG $ '7'
                lParSAp := .t.
             Endif
             DbSelectArea("TSTR")
             DbSkip()
       EndDo
       DbSelectArea("TSTR")
       DbCloseArea()

       //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
       //ConOut("   -- 10/02 - Verificando quantidade total para a: "+TCQ->ZZA_ORDEM)
       _cAuxMens := "   -- 10/02 - Verificando quantidade total para a: "+TCQ->ZZA_ORDEM
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
       cQry1 := ""
       cQry1 += "SELECT * "
       cQry1 += "FROM SC2"+cEmp+"0 SC2 WITH(NOLOCK) "
       cQry1 += "WHERE SC2.C2_FILIAL  = '"+cFil+"' "
       cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
       cQry1 += "  AND SC2.C2_OP      = '"+TCQ->ZZA_ORDEM+"' "
       TCQuery cQry1 ALIAS "TSTR" NEW
       DbSelectArea("TSTR")
       While !Eof()
             nQtdOrd := TSTR->C2_QUANT
             DbSelectArea("TSTR")
             DbSkip()
       EndDo
       DbSelectArea("TSTR")
       DbCloseArea()

       If !lParSAp //Se nใo existirem Ordens de produ็ใo em aberto, dar continuidade no ajuste de empenhos.
          If (nSomPar + TCQ->ZZA_QUANT) > nQtdOrd
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("   -- 10/03 - Ajustando quantidades...")
             _cAuxMens := "   -- 10/03 - Ajustando quantidades..."
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             //Buscando Quantidades para 1 unidade
             cQry1 := ""
             cQry1 += "SELECT SG1.G1_COMP, SG1.G1_TRT, SG1.G1_QUANT "
             cQry1 += "FROM SG1"+cEmp+"0 SG1 WITH (NOLOCK) "
             cQry1 += "WHERE SG1.G1_FILIAL  = '"+cFil+"' "
             cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
             cQry1 += "  AND SG1.G1_COD     = '"+TCQ->ZZA_PRODUT+"' "
             TCQuery cQry1 ALIAS "TSTR" NEW
             DbSelectArea("TSTR")
             While !Eof()
                   aAdd(aEmpPro, {TSTR->G1_COMP, TSTR->G1_TRT, TSTR->G1_QUANT, "", 0, 0, 0, 0, 0})
                   DbSelectArea("TSTR")
                   DbSkip()
             Enddo
             DbSelectArea("TSTR")
             DbCloseArea()
             
             For nY := 1 To Len(aEmpPro)
                 cQry1 := ""
                 cQry1 += "SELECT * "
                 cQry1 += "FROM SD4"+cEmp+"0 SD4 WITH (NOLOCK) "
                 cQry1 += "WHERE SD4.D4_FILIAL  = '"+cFil+"' "
                 cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SD4.D4_OP      = '"+TCQ->ZZA_ORDEM+"' "
                 cQry1 += "  AND SD4.D4_COD     = '"+aEmpPro[nY][1]+"' "
                 cQry1 += "  AND SD4.D4_TRT     = '"+aEmpPro[nY][2]+"' "
                 TCQuery cQry1 ALIAS "TSD4" NEW
                 DbSelectArea("TSD4")
                 aEmpPro[nY][04] := TSD4->D4_LOCAL                                          //Local da Baixa do item
                 aEmpPro[nY][05] := aEmpPro[nY][03] * nSomPar                               //Quantidade do Apontamento Parcial
                 aEmpPro[nY][06] := aEmpPro[nY][03] * TCQ->ZZA_QUANT                        //Quantidade do Apontamento Final
                 aEmpPro[nY][07] := aEmpPro[nY][05] + aEmpPro[nY][06]                       //Soma do total dos empenhos
                 aEmpPro[nY][08] := TSD4->D4_QUANT   + (aEmpPro[nY][07] - TSD4->D4_QTDEORI) //Saldo a ser ajustada
                 aEmpPro[nY][09] := TSD4->D4_QTDEORI + (aEmpPro[nY][07] - TSD4->D4_QTDEORI) //Quantidade a ser ajustada
                 If Posicione("SB2", 1, xFilial("SB2")+aEmpPro[nY][01]+aEmpPro[nY][04], "B2_QATU") < aEmpPro[nY][08]
                    //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                    //ConOut("   -- 10/04 - Verificando saldos...")
                    _cAuxMens := "   -- 10/04 - Verificando saldos..."
                    FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                    cMsgTot += Alltrim(aEmpPro[nY][1])+" - "+TransForm(aEmpPro[nY][08] - Posicione("SB2", 1, xFilial("SB2")+aEmpPro[nY][01]+aEmpPro[nY][04], "B2_QATU"), "@E 999,999.999")+"| "
                 Endif
                 DbSelectArea("TSD4")
                 DbCloseArea()
             Next
             For nY := 1 To Len(aEmpPro)
                 aEmpMov := {}
                 lMsErroAuto := .f.
                 aEmpMov := { {"D4_FILIAL" , cFil                                        , NIL },;
                              {"D4_OP"     , TCQ->ZZA_ORDEM+space(13-Len(TCQ->ZZA_ORDEM)), NIL },;
                              {"D4_TRT"    , aEmpPro[nY][2]                              , NIL },;
                              {"D4_COD"    , aEmpPro[nY][1]                              , NIL },;
                              {"D4_LOCAL"  , aEmpPro[nY][4]                              , NIL },;
                              {"D4_QTDEORI", aEmpPro[nY][9]                              , NIL },;
                              {"D4_QUANT"  , aEmpPro[nY][8]                              , NIL } }
                 DbSelectArea("SD4")
                 MSExecAuto({|x,y| MATA380(x, y)}, aEmpMov, 4)
                 If !lMsErroAuto
                    //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                    //ConOut("   -- 10/05 - Empenho para o Produto "+Alltrim(aEmpPro[nY][1])+" foi ajustado!")
                    _cAuxMens := "   -- 10/05 - Empenho para o Produto "+Alltrim(aEmpPro[nY][1])+" foi ajustado!"
                    FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                 Else
                    //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                    //ConOut("   -- 10/06 - Empenho para o Produto "+Alltrim(aEmpPro[nY][1])+" nใo foi ajustado!")
                    _cAuxMens := "   -- 10/06 - Empenho para o Produto "+Alltrim(aEmpPro[nY][1])+" nใo foi ajustado!"
                    FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                    nConAju += 1
                 Endif
             Next
             If nConAju > 0
                cQry1 := ""
                cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'AJUSTE_EMPENHO', ZZA_CAMPO = '10 - UM OU MAIS PRODUTO(S) ESTA(AO) SEM AJUSTE DE EMPENHO(S)' "
                cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                cQry1 += "  AND D_E_L_E_T_ = '' "
                cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                TCSQLExec(cQry1)
                lRet := .f.
             Else
                lRet := .t.
             Endif
          Else
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("   -- 10/04 - Nใo necessita de ajuste de quantidades...")
             _cAuxMens := "   -- 10/04 - Nใo necessita de ajuste de quantidades..."
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             lRet := .t.
          Endif
       Else
          cQry1 := ""
          cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
          cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = 'BAIXA_PARCIAL', ZZA_CAMPO = '10 - FALTA(M) BAIXA(S) PARCIAL(IS) PARA ESSA O.P.' "
          cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
          cQry1 += "  AND D_E_L_E_T_ = '' "
          cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
          TCSQLExec(cQry1)
          lRet := .f.
       Endif
Return lRet*/