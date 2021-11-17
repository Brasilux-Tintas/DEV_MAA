//#include 'brasilux.ch'
#include "protheus.ch"
#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch' 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRSCH010 บAutor  ณ Luํs G. de Souza   บ Data ณ  24/09/08   บฑฑ
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
User Function BRSCH010( _aParm )
     Local aParm     := Iif( ValType( _aParm ) == 'U', {"01", "01", "2"}, _aParm)
     Local cEmp      := Alltrim(Transform(aParm[1],'@!'))
     Local cFil      := Alltrim(Transform(aParm[2],'@!'))
     Local nOpc      := Alltrim(Transform(aParm[3],'@!'))
     Local dDatFin   := ""
     Local cCodBaiR  := ""
     Local cBaiPro   := ""
     Local _cAuxMens := ""
     
     If nOpc == '1'
        RPCSetType(3)  // Nao utilizar licenca
        PREPARE ENVIRONMENT EMPRESA '01' FILIAL '010101' TABLES "SB1", "SC2", "SD3", "SD4", "SH6"
                //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                //ConOut("-- BRSCH010 - BAIXA DE ORDENS DE PRODUวรO")
                //ConOut("-- BRSCH010 - Thread iniciada com sucesso as: "+Time()+" - "+dToc(MSDate()))
                //ConOut("-- BRSCH010 - Empresa: "+cEmp+" - Filial: "+cFil)
                //ConOut("--")
                _cAuxMens := "-- BRSCH010 - BAIXA DE ORDENS DE PRODUวรO" + CHR(13) + CHR(10)
                _cAuxMens += "-- BRSCH010 - Thread iniciada com sucesso as: "+Time()+" - "+dToc(MSDate()) + CHR(13) + CHR(10)
                _cAuxMens += "-- BRSCH010 - Empresa: "+cEmp+" - Filial: "+cFil
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                /***************************************************************************************/
                //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                //ConOut("-- ABERTURA DA TABELA DE PARAMETROS...")
                _cAuxMens := "-- ABERTURA DA TABELA DE PARAMETROS..."
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                fBusPar(@dDatFin, @cCodBaiR, @cBaiPro)
                //ConOut("###############################################################################")
                //ConOut("--")
                /***************************************************************************************/
                If cBaiPro $ 'S'
                   //ConOut("################   BAIXA DE MATERIAIS UTILIZADOS NA PESAGEM   #################")
                   //fProcBPs(cEmp, cFil, dDatFin, cCodBaiR)
                   //ConOut("###############################################################################")
                   //ConOut("--")
                   /***************************************************************************************/

                   //ConOut("##############   BAIXA DE MATERIAIS UTILIZADOS PELO COLORISTA   ###############")
                   //fProcBCl(cEmp, cFil, dDatFin, cCodBaiR)
                   //ConOut("###############################################################################")
                   //ConOut("--")
                   /***************************************************************************************/

                   //ConOut("#############   BAIXA DE MATERIAIS UTILIZADOS PELO LABORATORIO   ##############")
                   //fProcBLb(cEmp, cFil, dDatFin, cCodBaiR)
                   //ConOut("###############################################################################")
                   //ConOut("--")
                   /***************************************************************************************/
                   //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                   //ConOut("##############   GERACAO DAS ORDENS DE PRODUCAO COMPLEMENTARES   ##############")
                   _cAuxMens := "##############   GERACAO DAS ORDENS DE PRODUCAO COMPLEMENTARES   ##############"
                   FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                   fProcCom(cEmp, cFil, dDatFin)
                   //ConOut("###############################################################################")
                   //ConOut("--")
                   /***************************************************************************************/
                   //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                   //ConOut("-- FIM")
                   _cAuxMens := "-- FIM"
                   FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                Else
                   //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                   //ConOut("############   BAIXAS DE PRODUวรO NAO EXECUTADA - MV_BXPROP = N   #############")
                   _cAuxMens := "############   BAIXAS DE PRODUวรO NAO EXECUTADA - MV_BXPROP = N   #############"
                   FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                   //ConOut("-- FIM")
                Endif
        RESET ENVIRONMENT
     Else
        fBusPar(@dDatFin, @cCodBaiR, @cBaiPro, nOpc)
        fProcCom(cEmp, cFil, dDatFin)
     Endif
Return(Nil)

/******************************************************************************************************************/
/***                                 INCLUSรO DE ORDEM DE PRODUวรO COMPLEMENTAR                                 ***/
/******************************************************************************************************************/
STATIC Function fProcCom(cEmp, cFil, dDatFin)
       Local aAutoSC2 := {}
       Local cQry1    := ""
       Local nY
       Local _cAuxMens := ""
       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_ORDEM = '' "
       cQry1 += "  AND ZZA.ZZA_FLAG IN('7', '8') "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' " 
       cQry1 += "ORDER BY ZZA.ZZA_LOTE "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
             //ConOut("-- 04 - PROCESSANDO LOTE...: "+TCQ->ZZA_LOTE)
             _cAuxMens := "-- 04 - PROCESSANDO LOTE...: "+TCQ->ZZA_LOTE
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
             lMsErroAuto := .f.
             aAutoSC2 := {}
             aAdd(aAutoSC2, {"C2_ITEM"   , "01"                 , NIL})
             aAdd(aAutoSC2, {"C2_SEQUEN" , "001"                , NIL})
             aAdd(aAutoSC2, {"C2_PRODUTO", TCQ->ZZA_PRODUT      , NIL})
             aAdd(aAutoSC2, {"AUTEXPLODE", 'S'                  , NIL})
             aAdd(aAutoSC2, {"C2_LOCAL"  , '03'                 , NIL})
             aAdd(aAutoSC2, {"C2_QUANT"  , TCQ->ZZA_QUANT       , NIL})
             aAdd(aAutoSC2, {"C2_UM"     , 'UN'                 , NIL})
             aAdd(aAutoSC2, {"C2_DATPRI" , StoD(TCQ->ZZA_DTINI) , NIL})
             aAdd(aAutoSC2, {"C2_DATPRF" , MSDate()             , NIL})
             aAdd(aAutoSC2, {"C2_EMISSAO", MSDate()             , NIL})
             aAdd(aAutoSC2, {"C2_TPOP"   , 'F'                  , NIL})
             aAdd(aAutoSC2, {"C2_LOTE"   , TCQ->ZZA_LOTE        , NIL})
             aAdd(aAutoSC2, {"C2_ROTEIRO", '01'                 , NIL})

             MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
             If !lMsErroAuto
                //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                //ConOut("      -- 04/01 - COMPLEMENTO GERADO!")
                _cAuxMens := "      -- 04/01 - COMPLEMENTO GERADO!"
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                //Atualiza Ordem de produ็ใo na tabela - ZZA
                cQry1 := ""
                cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '04 - COMPL_GERADO', ZZA_ORDEM = '"+SC2->C2_OP+"', ZZA_CAMPO = 'ORDEM DE PRODUCAO COMPLEMENTAR GERADA' "
                cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                cQry1 += "  AND D_E_L_E_T_ = '' "
                cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                TCSQLExec(cQry1)
                
                //Atualiza Lote de produ็ใo na tabela - SZZ
                cQry1 := ""
                cQry1 += "SELECT ISNULL(MAX(SZZ.R_E_C_N_O_), 0)+ 1 AS SZZRECNO FROM "+RetSqlName("SZZ")+" SZZ "
                TCQuery cQry1 ALIAS "SZZTCQ" NEW
                DbSelectArea("SZZTCQ")
                nRecno := SZZTCQ->SZZRECNO
                DbSelectArea("SZZTCQ")
                DbCloseArea()
                cQry1 := ""
                cQry1 += "INSERT INTO "+RetSqlName("SZZ")+" "
                cQry1 += "(ZZ_FILIAL , ZZ_LOTE            , ZZ_DTEMIS           , ZZ_PRODUTO           , ZZ_DESCR                                                            , ZZ_EMB                               , ZZ_DESEMB                                                                             , ZZ_QTDETI                 , ZZ_PREVI            , ZZ_PREVF            , ZZ_PEDIDO, ZZ_TPINCL, ZZ_FLAG, ZZ_USERLGI, ZZ_USERLGA, D_E_L_E_T_, R_E_C_N_O_) "
                cQry1 += "VALUES('01', '"+TCQ->ZZA_LOTE+"', '"+TCQ->ZZA_DTFIM+"', '"+TCQ->ZZA_PRODUT+"', '"+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZA_PRODUT, "B1_DESC")+"', '"+SubStr(TCQ->ZZA_PRODUT, 11, 2)+"', '"+Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZA_PRODUT, 11, 2), "Z5_DESCR")+"', "+Str(TCQ->ZZA_QUANT, 6)+", '"+TCQ->ZZA_DTFIM+"', '"+TCQ->ZZA_DTFIM+"', ''       , 'C'      , 'S'    , '"+Embaralha(Subs(cUsername,1,15)+Save4in2(MsDate()-Ctod("01/01/96")), 0)+"', '', '', "+Alltrim(Str(nRecno, 10))+") "
                TCSQLExec(cQry1)
             Else
                //LGS#20200212 - Adequa็ใo de release 12.1.25 e posteriores
                //ConOut("      -- 04/02 - COMPLEMENTO NAO GERADO!")
                _cAuxMens := "      -- 04/02 - COMPLEMENTO NAO GERADO!"
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                cErro := NomeAutoLog()
                cHelp := ""
                cCamp := "04 - "
                nLinErr := MlCount(MemoRead(cErro))
                For nY := 1 To nLinErr
                    If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                       cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                    ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                           cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                    Endif
                Next
                //Atualiza Ordem de produ็ใo na tabela - ZZA, com log de erro gerado.
                cQry1 := ""
                cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+" "+cErro+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"' "
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
Return

/******************************************************************************************************************/
/***                                    BAIXA DAS MATERIAS PRIMAS LABORATORIO                                   ***/
/******************************************************************************************************************/
/*STATIC Function fProcBLb(cEmp, cFil, dDatFin, cCodBaiR)
       Local cQry1    := ""
       Local cAuxQry1 := ""
       Local cAuxQry2 := ""
       Local aEmpenho := {}
       Local nY

       //1บ)Busca Ordens de produ็ใo com pesagem finalizadas
       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_DTPES <= '"+dDatFin+"' "
       cQry1 += "  AND ZZA.ZZA_FLAG  = '4' "
       cQry1 += "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' " 
       cQry1 += "ORDER BY ZZA.ZZA_LOTE "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             aEmpenho := {}
             ConOut("-- 03 - BAIXANDO EMPENHO DO LOTE...: "+TCQ->ZZA_LOTE)
             //2บ) Busca excess๕es para baixas
             ConOut("      -- 03/01 - BUSCANDO EXCESSOES")
             fBusExc(cEmp, cFil, TCQ->ZZA_PRODUTO, @cAuxQry1, @cAuxQry2)
             cQry1 := ""
             cQry1 += "SELECT ZZF.ZZF_CODIGO, ZZF.ZZF_LOCAL, ZZF.ZZF_QTDUSA, ZZF.ZZF_TRT, SB1.B1_UM, ZZF.ZZF_QTDORI, SB2.B2_QATU "
             cQry1 += "FROM ZZF"+cEmp+"0 ZZF WITH (NOLOCK) "
             cQry1 += "LEFT OUTER JOIN SB1"+cEmp+"0 SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = ZZF.ZZF_FILIAL AND SB1.B1_COD = ZZF.ZZF_CODIGO AND SB1.D_E_L_E_T_ = '' "
             cQry1 += "LEFT OUTER JOIN SB2"+cEmp+"0 SB2 WITH (NOLOCK) ON SB2.B2_FILIAL = ZZF.ZZF_FILIAL AND SB2.B2_COD = ZZF.ZZF_CODIGO AND SB2.B2_LOCAL = ZZF.ZZF_LOCAL AND SB2.D_E_L_E_T_ = '' "
             cQry1 += "WHERE ZZF.ZZF_FILIAL = '"+cFil+"' "
             cQry1 += "  AND ZZF.D_E_L_E_T_ = '' "
             cQry1 += "  AND ZZF.ZZF_TIPEMP IN('C', 'P', 'L') "
             cQry1 += "  AND ZZF.ZZF_FLAG   = '2' "
             cQry1 += "  AND ZZF.ZZF_LOCAL <> '99' "
             cQry1 += "  AND ZZF.ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
             If !Empty(cAuxQry2)
                cQry1 += cAuxQry2
             Endif
             TCQuery cQry1 ALIAS "XZF" NEW
             DbSelectArea("XZF")
             DbGoTop()
             While !Eof()
                   ConOut("      -- 03/02 - BUSCANDO PRODUTOS.: "+XZF->ZZF_CODIGO)
                   If !XZF->B2_QATU >= XZF->ZZF_QTDUSA .and. XZF->ZZF_QTDUSA > 0.0
                      ConOut("      -- 03/03 - SALDO INDISPONIVEL")
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                      cQry1 += "   SET ZZF_OBS = '02 - INDISPONIVEL' "
                      cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                      cQry1 += "  AND D_E_L_E_T_ = '' "
                      cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                      cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                      cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                      cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                      TCSQLExec(cQry1)
                   Else
                      If XZF->ZZF_QTDUSA <= 0.0
                         ConOut("      -- 03/04 - PRODUTO NAO UTILIZADO")
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
                         cQry1 += "WHERE SD4.D4_FILIAL  = '01' "
                         cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SD4.D4_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "  AND SD4.D4_COD     = '"+XZF->ZZF_CODIGO+"' "
                         cQry1 += "  AND SD4.D4_TRT     = '"+XZF->ZZF_TRT+"' "
                         TCQuery cQry1 ALIAS "TSD4" NEW
                         DbSelectArea("TSD4")
                         If !Empty(TSD4->D4_COD)
                            lMsErroAuto := .f.

                            DbSelectArea("SD4")
                            aEmpMov := {}
                            aEmpMov := { {"D4_FILIAL", cFil           , NIL },;
                                         {"D4_OP"    , Alltrim(TCQ->ZZA_ORDEM) + Space( 13 - Len( Alltrim(TCQ->ZZA_ORDEM) ) ) , NIL },;
                                         {"D4_COD"   , XZF->ZZF_CODIGO, NIL },;
                                         {"D4_TRT"   , XZF->ZZF_TRT   , NIL } }
                            MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
                            If !lMsErroAuto
                               ConOut("               -- 03/05 - EMPENHO EXCLUIDO")
                               cQry1 := ""
                               cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                               cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '02 - EXCLUIDO' "
                               cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                               cQry1 += "  AND D_E_L_E_T_ = '' "
                               cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                               cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                               cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                               cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                               TCSQLExec(cQry1)
                            Else
                               ConOut("               -- 03/06 - EMPENHO NAO EXCLUIDO")
                               cQry1 := ""
                               cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                               cQry1 += "   SET ZZF_OBS = '02 - NAO EXCLUIDO' "
                               cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                               cQry1 += "  AND D_E_L_E_T_ = '' "
                               cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                               cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                               cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                               cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                               TCSQLExec(cQry1)
                            Endif
                         Else
                            cQry1 := ""
                            cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                            cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '02 - EXCLUIDO' "
                            cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                            cQry1 += "  AND D_E_L_E_T_ = '' "
                            cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                            cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                            cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                            cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                            TCSQLExec(cQry1)
                         Endif
                         DbSelectArea("TSD4")
                         DbCloseArea()
                      Else
                         aAdd(aEmpenho, {XZF->ZZF_CODIGO, XZF->ZZF_TRT, XZF->ZZF_QTDUSA, XZF->B1_UM, XZF->ZZF_LOCAL})
                         //Apagar os empenhos pois os mesmos serใo baixados
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
                         cQry1 += "WHERE SD4.D4_FILIAL  = '01' "
                         cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SD4.D4_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "  AND SD4.D4_COD     = '"+XZF->ZZF_CODIGO+"' "
                         cQry1 += "  AND SD4.D4_TRT     = '"+XZF->ZZF_TRT+"' "
                         TCQuery cQry1 ALIAS "TSD4" NEW
                         DbSelectArea("TSD4")
                         If !Empty(TSD4->D4_COD)
                            lMsErroAuto := .f.

                            DbSelectArea("SD4")
                            aEmpMov := {}
                            aEmpMov := { {"D4_FILIAL", cFil           , NIL },;
                                         {"D4_OP"    , Alltrim(TCQ->ZZA_ORDEM) + Space( 13 - Len( Alltrim(TCQ->ZZA_ORDEM) ) ) , NIL },;
                                         {"D4_COD"   , XZF->ZZF_CODIGO, NIL },;
                                         {"D4_TRT"   , XZF->ZZF_TRT   , NIL } }
                            MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
                            If !lMsErroAuto
                               ConOut("               -- 03/07 - EMPENHO EXCLUIDO")
                            Else
                               ConOut("               -- 03/08 - EMPENHO NAO EXCLUIDO")
                            Endif
                         Endif
                         DbSelectArea("TSD4")
                         DbCloseArea()
                      Endif
                   Endif
                   DbSelectArea("XZF")
                   DbSkip()
             Enddo
             DbSelectArea("XZF")
             DbCloseArea()
             //Baixa de todos os Itens 
             If Len(aEmpenho) > 0
                aCabMov := { {"D3_TM"     , cCodBaiR            , NIL},;
                             {"D3_EMISSAO", Stod(TCQ->ZZA_DTPES), NIL} }
                aAuxMov := {}
                aIteMov := {}
                For nY := 1 To Len(aEmpenho)
                    aAuxMov := {}
                    aAuxMov := { {"D3_COD"    , aEmpenho[nY][1], NIL},;
                                 {"D3_TRT"    , aEmpenho[nY][2], NIL},;
                                 {"D3_QUANT"  , aEmpenho[nY][3], NIL},;
                                 {"D3_UM"     , aEmpenho[nY][4], NIL},;
                                 {"D3_LOCAL"  , aEmpenho[nY][5], NIL},;
                                 {"D3_OP"     , TCQ->ZZA_ORDEM , NIL},;
                                 {"D3_TURNO"  , "BEC"          , NIL} }
                    aAdd(aIteMov, aAuxMov)
                Next
                If Len(aIteMov) > 0
                   ConOut("               -- 03/09 - BAIXANDO EMPENHOS")
                   lMsErroAuto := .f.
                   MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 3)
                   If !lMsErroAuto
                      For nY := 1 To Len(aEmpenho)
                          cQry1 := ""
                          cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                          cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '01 - BAIXADO' "
                          cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                          cQry1 += "  AND D_E_L_E_T_ = '' "
                          cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                          cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                          cQry1 += "  AND ZZF_CODIGO = '"+aEmpenho[nY][1]+"' "
                          cQry1 += "  AND ZZF_TRT    = '"+aEmpenho[nY][2]+"' "
                          TCSQLExec(cQry1)
                      Next
                   Else
                      ConOut("               -- 03/10 - OCORREU ERRO NA BAIXA")
                      cErro := NomeAutoLog()
                      cHelp := ""
                      cCamp := "03 - "
                      nLinErr := MlCount(MemoRead(cErro))
                      For nY := 1 To nLinErr
                          If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                             cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                          ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                 cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                          Endif
                      Next
                      //Atualiza Ordem de produ็ใo na tabela - ZZA, com log de erro gerado.
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                      cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+" "+cErro+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"' "
                      cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                      cQry1 += "  AND D_E_L_E_T_ = '' "
                      cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                      TCSQLExec(cQry1)
                   Endif
                Endif
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
Return*/

/******************************************************************************************************************/
/***                                    BAIXA DAS MATERIAS PRIMAS COLORISTA                                     ***/
/******************************************************************************************************************/
/*STATIC Function fProcBCl(cEmp, cFil, dDatFin, cCodBaiR)
       Local cQry1    := ""
       Local cAuxQry1 := ""
       Local cAuxQry2 := ""
       Local aEmpenho := {}
       Local nY

       //1บ)Busca Ordens de produ็ใo com pesagem finalizadas
       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_DTCOL <= '"+dDatFin+"' "
       cQry1 += "  AND ZZA.ZZA_FLAG  IN('3', '4') "
       cQry1 += "ORDER BY ZZA.ZZA_LOTE "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             aEmpenho := {}
             ConOut("-- 02 - BAIXANDO EMPENHO DO LOTE...: "+TCQ->ZZA_LOTE)
             //2บ) Busca excess๕es para baixas
             ConOut("      -- 02/01 - BUSCANDO EXCESSOES")
             fBusExc(cEmp, cFil, TCQ->ZZA_PRODUTO, @cAuxQry1, @cAuxQry2)
             cQry1 := ""
             cQry1 += "SELECT ZZF.ZZF_CODIGO, ZZF.ZZF_LOCAL, ZZF.ZZF_QTDUSA, ZZF.ZZF_TRT, SB1.B1_UM, ZZF.ZZF_QTDORI, SB2.B2_QATU "
             cQry1 += "FROM ZZF"+cEmp+"0 ZZF WITH (NOLOCK) "
             cQry1 += "LEFT OUTER JOIN SB1"+cEmp+"0 SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = ZZF.ZZF_FILIAL AND SB1.B1_COD = ZZF.ZZF_CODIGO AND SB1.D_E_L_E_T_ = '' "
             cQry1 += "LEFT OUTER JOIN SB2"+cEmp+"0 SB2 WITH (NOLOCK) ON SB2.B2_FILIAL = ZZF.ZZF_FILIAL AND SB2.B2_COD = ZZF.ZZF_CODIGO AND SB2.B2_LOCAL = ZZF.ZZF_LOCAL AND SB2.D_E_L_E_T_ = '' "
             cQry1 += "WHERE ZZF.ZZF_FILIAL = '"+cFil+"' "
             cQry1 += "  AND ZZF.D_E_L_E_T_ = '' "
             cQry1 += "  AND ZZF.ZZF_TIPEMP IN('C', 'P') "
             cQry1 += "  AND ZZF.ZZF_FLAG   IN('2', '3') "
             cQry1 += "  AND ZZF.ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
             If !Empty(cAuxQry2)
                cQry1 += cAuxQry2
             Endif
             TCQuery cQry1 ALIAS "XZF" NEW
             DbSelectArea("XZF")
             DbGoTop()
             While !Eof()
                   ConOut("      -- 02/02 - BUSCANDO PRODUTOS.: "+XZF->ZZF_CODIGO)
                   If !XZF->B2_QATU >= XZF->ZZF_QTDUSA .and. XZF->ZZF_QTDUSA > 0.0
                      ConOut("      -- 02/03 - SALDO INDISPONIVEL")
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                      cQry1 += "   SET ZZF_OBS = '02 - INDISPONIVEL' "
                      cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                      cQry1 += "  AND D_E_L_E_T_ = '' "
                      cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                      cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                      cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                      cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                      TCSQLExec(cQry1)
                   Else
                      If XZF->ZZF_QTDUSA <= 0.0
                         ConOut("      -- 02/04 - PRODUTO NAO UTILIZADO")
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
                         cQry1 += "WHERE SD4.D4_FILIAL  = '01' "
                         cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SD4.D4_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "  AND SD4.D4_COD     = '"+XZF->ZZF_CODIGO+"' "
                         cQry1 += "  AND SD4.D4_TRT     = '"+XZF->ZZF_TRT+"' "
                         TCQuery cQry1 ALIAS "TSD4" NEW
                         DbSelectArea("TSD4")
                         If !Empty(TSD4->D4_COD)
                            lMsErroAuto := .f.

                            DbSelectArea("SD4")
                            aEmpMov := {}
                            aEmpMov := { {"D4_FILIAL", cFil           , NIL },;
                                         {"D4_OP"    , Alltrim(TCQ->ZZA_ORDEM) + Space( 13 - Len( Alltrim(TCQ->ZZA_ORDEM) ) ) , NIL },;
                                         {"D4_COD"   , XZF->ZZF_CODIGO, NIL },;
                                         {"D4_TRT"   , XZF->ZZF_TRT   , NIL } }
                            MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
                            If !lMsErroAuto
                               ConOut("               -- 02/05 - EMPENHO EXCLUIDO")
                               cQry1 := ""
                               cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                               cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '02 - EXCLUIDO' "
                               cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                               cQry1 += "  AND D_E_L_E_T_ = '' "
                               cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                               cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                               cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                               cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                               TCSQLExec(cQry1)
                            Else
                               ConOut("               -- 02/06 - EMPENHO NAO EXCLUIDO")
                               cQry1 := ""
                               cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                               cQry1 += "   SET ZZF_OBS = '02 - NAO EXCLUIDO' "
                               cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                               cQry1 += "  AND D_E_L_E_T_ = '' "
                               cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                               cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                               cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                               cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                               TCSQLExec(cQry1)
                            Endif
                         Endif
                         DbSelectArea("TSD4")
                         DbCloseArea()
                      Else
                         aAdd(aEmpenho, {XZF->ZZF_CODIGO, XZF->ZZF_TRT, XZF->ZZF_QTDUSA, XZF->B1_UM, XZF->ZZF_LOCAL})
                         //Apagar os empenhos pois os mesmos serใo baixados
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SD4")+' SD4 WITH (NOLOCK) "
                         cQry1 += "WHERE SD4.D4_FILIAL  = '01' "
                         cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SD4.D4_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "  AND SD4.D4_COD     = '"+XZF->ZZF_CODIGO+"' "
                         cQry1 += "  AND SD4.D4_TRT     = '"+XZF->ZZF_TRT+"' "
                         TCQuery cQry1 ALIAS "TSD4" NEW
                         DbSelectArea("TSD4")
                         If !Empty(TSD4->D4_COD)
                            lMsErroAuto := .f.

                            DbSelectArea("SD4")
                            aEmpMov := {}
                            aEmpMov := { {"D4_FILIAL", cFil           , NIL },;
                                         {"D4_OP"    , Alltrim(TCQ->ZZA_ORDEM) + Space( 13 - Len( Alltrim(TCQ->ZZA_ORDEM) ) ) , NIL },;
                                         {"D4_COD"   , XZF->ZZF_CODIGO, NIL },;
                                         {"D4_TRT"   , XZF->ZZF_TRT   , NIL } }
                            MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
                            If !lMsErroAuto
                               ConOut("               -- 02/07 - EMPENHO EXCLUIDO")
                            Else
                               ConOut("               -- 02/08 - EMPENHO NAO EXCLUIDO")
                            Endif
                         Endif
                         DbSelectArea("TSD4")
                         DbCloseArea()
                      Endif
                   Endif
                   DbSelectArea("XZF")
                   DbSkip()
             Enddo
             DbSelectArea("XZF")
             DbCloseArea()
             //Baixa de todos os Itens 
             If Len(aEmpenho) > 0
                aCabMov := { {"D3_TM"     , cCodBaiR            , NIL},;
                             {"D3_EMISSAO", Stod(TCQ->ZZA_DTPES), NIL} }
                aAuxMov := {}
                aIteMov := {}
                For nY := 1 To Len(aEmpenho)
                    aAuxMov := {}
                    aAuxMov := { {"D3_COD"    , aEmpenho[nY][1], NIL},;
                                 {"D3_TRT"    , aEmpenho[nY][2], NIL},;
                                 {"D3_QUANT"  , aEmpenho[nY][3], NIL},;
                                 {"D3_UM"     , aEmpenho[nY][4], NIL},;
                                 {"D3_LOCAL"  , aEmpenho[nY][5], NIL},;
                                 {"D3_OP"     , TCQ->ZZA_ORDEM , NIL},;
                                 {"D3_TURNO"  , "BEC"          , NIL} }
                    aAdd(aIteMov, aAuxMov)
                Next
                If Len(aIteMov) > 0
                   ConOut("               -- 02/09 - BAIXANDO EMPENHOS")
                   lMsErroAuto := .f.
                   MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 3)
                   If !lMsErroAuto
                      For nY := 1 To Len(aEmpenho)
                          cQry1 := ""
                          cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                          cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '01 - BAIXADO' "
                          cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                          cQry1 += "  AND D_E_L_E_T_ = '' "
                          cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                          cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                          cQry1 += "  AND ZZF_CODIGO = '"+aEmpenho[nY][1]+"' "
                          cQry1 += "  AND ZZF_TRT    = '"+aEmpenho[nY][2]+"' "
                          TCSQLExec(cQry1)
                      Next
                   Else
                      ConOut("               -- 02/10 - OCORREU ERRO NA BAIXA")
                      cErro := NomeAutoLog()
                      cHelp := ""
                      cCamp := "02 - "
                      nLinErr := MlCount(MemoRead(cErro))
                      For nY := 1 To nLinErr
                          If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                             cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                          ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                 cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                          Endif
                      Next
                      //Atualiza Ordem de produ็ใo na tabela - ZZA, com log de erro gerado.
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                      cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+" "+cErro+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"' "
                      cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                      cQry1 += "  AND D_E_L_E_T_ = '' "
                      cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                      TCSQLExec(cQry1)
                   Endif
                Endif
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
Return*/

/******************************************************************************************************************/
/***                                     BAIXA DAS MATERIAS PRIMAS PESAGEM                                v.1.01***/
/******************************************************************************************************************/
/*STATIC Function fProcBPS(cEmp, cFil, dDatFin, cCodBaiR)
       Local cQry1    := ""
       Local cAuxQry1 := ""
       Local cAuxQry2 := ""
       Local aEmpenho := {}
       Local nY

       //1บ)Busca Ordens de produ็ใo com pesagem finalizadas
       cQry1 += "SELECT * "
       cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH(NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+cFil+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_DTPES <= '"+dDatFin+"' "
       cQry1 += "  AND ZZA.ZZA_FLAG  = '2' "
       cQry1 += "ORDER BY ZZA.ZZA_LOTE "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             aEmpenho := {}
             ConOut("-- 01 - BAIXANDO EMPENHO DO LOTE...: "+TCQ->ZZA_LOTE)
             //2บ) Busca excess๕es para baixas
             ConOut("      -- 01/01 - BUSCANDO EXCESSOES")
             fBusExc(cEmp, cFil, TCQ->ZZA_PRODUTO, @cAuxQry1, @cAuxQry2)
             cQry1 := ""
             cQry1 += "SELECT ZZF.ZZF_CODIGO, ZZF.ZZF_LOCAL, ZZF.ZZF_QTDUSA, ZZF.ZZF_TRT, SB1.B1_UM, ZZF.ZZF_QTDORI, SB2.B2_QATU "
             cQry1 += "FROM ZZF"+cEmp+"0 ZZF WITH (NOLOCK) "
             cQry1 += "LEFT OUTER JOIN SB1"+cEmp+"0 SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = ZZF.ZZF_FILIAL AND SB1.B1_COD = ZZF.ZZF_CODIGO AND SB1.D_E_L_E_T_ = '' "
             cQry1 += "LEFT OUTER JOIN SB2"+cEmp+"0 SB2 WITH (NOLOCK) ON SB2.B2_FILIAL = ZZF.ZZF_FILIAL AND SB2.B2_COD = ZZF.ZZF_CODIGO AND SB2.B2_LOCAL = ZZF.ZZF_LOCAL AND SB2.D_E_L_E_T_ = '' "
             cQry1 += "WHERE ZZF.ZZF_FILIAL = '"+cFil+"' "
             cQry1 += "  AND ZZF.D_E_L_E_T_ = '' "
             cQry1 += "  AND ZZF.ZZF_TIPEMP = 'P' "
             cQry1 += "  AND ZZF.ZZF_FLAG   = '2' "
             cQry1 += "  AND ZZF.ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
             If !Empty(cAuxQry2)
                cQry1 += cAuxQry2
             Endif
             TCQuery cQry1 ALIAS "XZF" NEW
             DbSelectArea("XZF")
             DbGoTop()
             While !Eof()
                   ConOut("      -- 01/02 - BUSCANDO PRODUTOS.: "+XZF->ZZF_CODIGO)
                   If !XZF->B2_QATU >= XZF->ZZF_QTDUSA .and. XZF->ZZF_QTDUSA > 0.0
                      ConOut("      -- 01/03 - SALDO INDISPONIVEL")
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                      cQry1 += "   SET ZZF_OBS = '01 - INDISPONIVEL' "
                      cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                      cQry1 += "  AND D_E_L_E_T_ = '' "
                      cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                      cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                      cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                      cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                      TCSQLExec(cQry1)
                   Else
                      If XZF->ZZF_QTDUSA <= 0.0
                         ConOut("      -- 01/04 - PRODUTO NAO UTILIZADO")
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
                         cQry1 += "WHERE SD4.D4_FILIAL  = '01' "
                         cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SD4.D4_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "  AND SD4.D4_COD     = '"+XZF->ZZF_CODIGO+"' "
                         cQry1 += "  AND SD4.D4_TRT     = '"+XZF->ZZF_TRT+"' "
                         TCQuery cQry1 ALIAS "TSD4" NEW
                         DbSelectArea("TSD4")
                         If !Empty(TSD4->D4_COD)
                            lMsErroAuto := .f.

                            DbSelectArea("SD4")
                            aEmpMov := {}
                            aEmpMov := { {"D4_FILIAL", cFil           , NIL },;
                                         {"D4_OP"    , Alltrim(TCQ->ZZA_ORDEM) + Space( 13 - Len( Alltrim(TCQ->ZZA_ORDEM) ) ) , NIL },;
                                         {"D4_COD"   , XZF->ZZF_CODIGO, NIL },;
                                         {"D4_TRT"   , XZF->ZZF_TRT   , NIL } }
                            MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
                            If !lMsErroAuto
                               ConOut("               -- 01/05 - EMPENHO EXCLUIDO")
                               cQry1 := ""
                               cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                               cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '01 - EXCLUIDO' "
                               cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                               cQry1 += "  AND D_E_L_E_T_ = '' "
                               cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                               cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                               cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                               cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                               TCSQLExec(cQry1)
                            Else
                               ConOut("               -- 01/06 - EMPENHO NAO EXCLUIDO")
                               cQry1 := ""
                               cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                               cQry1 += "   SET ZZF_OBS = '01 - NAO EXCLUIDO' "
                               cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                               cQry1 += "  AND D_E_L_E_T_ = '' "
                               cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                               cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                               cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                               cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                               TCSQLExec(cQry1)
                            Endif
                         Else
                            cQry1 := ""
                            cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                            cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '01 - EXCLUIDO' "
                            cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                            cQry1 += "  AND D_E_L_E_T_ = '' "
                            cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                            cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                            cQry1 += "  AND ZZF_CODIGO = '"+XZF->ZZF_CODIGO+"' "
                            cQry1 += "  AND ZZF_TRT    = '"+XZF->ZZF_TRT+"' "
                            TCSQLExec(cQry1)
                         Endif
                         DbSelectArea("TSD4")
                         DbCloseArea()
                      Else
                         aAdd(aEmpenho, {XZF->ZZF_CODIGO, XZF->ZZF_TRT, XZF->ZZF_QTDUSA, XZF->B1_UM, XZF->ZZF_LOCAL})
                         //Apagar os empenhos pois os mesmos serใo baixados
                         cQry1 := ""
                         cQry1 += "SELECT * "
                         cQry1 += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
                         cQry1 += "WHERE SD4.D4_FILIAL  = '01' "
                         cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                         cQry1 += "  AND SD4.D4_OP      = '"+TCQ->ZZA_ORDEM+"' "
                         cQry1 += "  AND SD4.D4_COD     = '"+XZF->ZZF_CODIGO+"' "
                         cQry1 += "  AND SD4.D4_TRT     = '"+XZF->ZZF_TRT+"' "
                         TCQuery cQry1 ALIAS "TSD4" NEW
                         DbSelectArea("TSD4")
                         If !Empty(TSD4->D4_COD)
                            lMsErroAuto := .f.

                            DbSelectArea("SD4")
                            aEmpMov := {}
                            aEmpMov := { {"D4_FILIAL", cFil           , NIL },;
                                         {"D4_OP"    , Alltrim(TCQ->ZZA_ORDEM) + Space( 13 - Len( Alltrim(TCQ->ZZA_ORDEM) ) ) , NIL },;
                                         {"D4_COD"   , XZF->ZZF_CODIGO, NIL },;
                                         {"D4_TRT"   , XZF->ZZF_TRT   , NIL } }
                            MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
                            If !lMsErroAuto
                               ConOut("               -- 01/07 - EMPENHO EXCLUIDO")
                            Else
                               ConOut("               -- 01/08 - EMPENHO NAO EXCLUIDO")
                            Endif
                         Endif
                         DbSelectArea("TSD4")
                         DbCloseArea()
                      Endif
                   Endif
                   DbSelectArea("XZF")
                   DbSkip()
             Enddo
             DbSelectArea("XZF")
             DbCloseArea()

             //Baixa de todos os Itens 
             If Len(aEmpenho) > 0
                aCabMov := { {"D3_TM"     , cCodBaiR            , NIL},;
                             {"D3_EMISSAO", Stod(TCQ->ZZA_DTPES), NIL} }
                aAuxMov := {}
                aIteMov := {}
                For nY := 1 To Len(aEmpenho)
                    aAuxMov := {}
                    aAuxMov := { {"D3_COD"    , aEmpenho[nY][1], NIL},;
                                 {"D3_TRT"    , aEmpenho[nY][2], NIL},;
                                 {"D3_QUANT"  , aEmpenho[nY][3], NIL},;
                                 {"D3_UM"     , aEmpenho[nY][4], NIL},;
                                 {"D3_LOCAL"  , aEmpenho[nY][5], NIL},;
                                 {"D3_OP"     , TCQ->ZZA_ORDEM , NIL},;
                                 {"D3_TURNO"  , "BEP"          , NIL} }
                    aAdd(aIteMov, aAuxMov)
                Next
                If Len(aIteMov) > 0
                   ConOut("               -- 01/09 - BAIXANDO EMPENHOS")
                   lMsErroAuto := .f.
                   MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 3)
                   If !lMsErroAuto
                      For nY := 1 To Len(aEmpenho)
                          cQry1 := ""
                          cQry1 += "UPDATE "+RetSqlName("ZZF")+" "
                          cQry1 += "   SET ZZF_FLAG  = '1', ZZF_OBS = '01 - BAIXADO' "
                          cQry1 += "WHERE ZZF_FILIAL = '"+cFil+"' "
                          cQry1 += "  AND D_E_L_E_T_ = '' "
                          cQry1 += "  AND ZZF_ORDEM  = '"+TCQ->ZZA_ORDEM+"' "
                          cQry1 += "  AND ZZF_LOTE   = '"+TCQ->ZZA_LOTE+"' "
                          cQry1 += "  AND ZZF_CODIGO = '"+aEmpenho[nY][1]+"' "
                          cQry1 += "  AND ZZF_TRT    = '"+aEmpenho[nY][2]+"' "
                          TCSQLExec(cQry1)
                      Next
                   Else
                      ConOut("               -- 01/10 - OCORREU ERRO NA BAIXA")
                      cErro := NomeAutoLog()
                      cHelp := ""
                      cCamp += "01 - "
                      nLinErr := MlCount(MemoRead(cErro))
                      For nY := 1 To nLinErr
                          If 'HELP' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                             cHelp := Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                          ElseIf 'INVALIDO' $ Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                                 cCamp += Upper(MEMOLINE(MemoRead(cErro), 80, nY))
                          Endif
                      Next
                      //Atualiza Ordem de produ็ใo na tabela - ZZA, com log de erro gerado.
                      cQry1 := ""
                      cQry1 += "UPDATE "+RetSqlName("ZZA")+" "
                      cQry1 += "SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = '"+Alltrim(cHelp)+" "+cErro+"', ZZA_CAMPO = '"+Alltrim(cCamp)+"' "
                      cQry1 += "WHERE ZZA_FILIAL = '"+cFil+"' "
                      cQry1 += "  AND D_E_L_E_T_ = '' "
                      cQry1 += "  AND R_E_C_N_O_ = "+Alltrim(Str(TCQ->R_E_C_N_O_, 10))+" "
                      TCSQLExec(cQry1)
                   Endif
                Endif
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
Return*/

/******************************************************************************************************************/
/*** FBUSEXC - BUSCA CODIGO DE RETENวรO E FILTROS QUE NรO SERAM BAIXADOS NA PESAGEM DA FำRMULA                  ***/
/******************************************************************************************************************/
/*STATIC Function fBusExc(cEmp, cFil, cPro, cAuxQry1, cAuxQry2)
       cAuxQry1 := ""
       cAuxQry2 := ""
       If Len(Alltrim(TCQ->ZZA_PRODUT)) == 12
          cQry1 := ""
          cQry1 += "SELECT * "
          cQry1 += "FROM "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) "
          cQry1 += "WHERE (SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"') "
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
/*** FBUSPAR - BUSCA PARยMETROS UTILIZADOS NO PROCESSAMENTO                                                     ***/
/******************************************************************************************************************/
STATIC Function fBusPar(dDatFin, cCodBaiR, cBaiPro, nOpc)
       /*If nOpc == '1'
          ConOut("-- ABRINDO SX6...")
          DbUseArea(.t., __LocalDrive, 'SX6'+substr(cNumEmp,1,2)+'0', 'TSX6', .t., .f.)
          ConOut("   -- Tabela Aberta...")
          DbSelectArea("TSX6")
          DbSetOrder(1)
          DbSeek('  MV_BXOPFEC')  //Data Final para baixa de Ordens de produ็ใo
          If Found()
             dDatFin := Alltrim(TSX6->X6_CONTEUD) 
          Endif
          ConOut("      -- Data Final para baixa..............: "+DtoC(Stod(dDatFin)))
          DbSeek('  MV_CBAIREQ')
          If Found()
             cCodBaiR    := Alltrim(TSX6->X6_CONTEUD)
          Endif
          DbSeek('01MV_BXPROP')
          If Found()
             cBaiPro    := Alltrim(TSX6->X6_CONTEUD)
          Endif
          ConOut("      -- Codigo para Requisicao de Materiais: "+cCodBaiR)
          ConOut("--")
          If cBaiPro $ 'N'
             ConOut("      -- Processo de Baixa antigo deve estar rodando.: "+cBaiPro)
             ConOut("--")
          Endif
          TSX6->(DbCloseArea())
          ConOut("-- Tabela Fechada!")
       Else*/
          dDatFin  := GETMV('MV_BXOPFEC')
          cCodBaiR := GETMV('MV_CBAIREQ')
          cBaiPro  := GETMV('MV_BXPROP')
      // Endif
Return
