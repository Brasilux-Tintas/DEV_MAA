#include 'rwmake.ch'
#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ BRSCH004 º Autor ³ Luis G. de Souza   º Data ³  02/08/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Reprocessamento dos lotes do plano de produção, para infor-º±±
±±º          ³ mar lotes já baixados. Schedule de hora em hora.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³ BRASILUX TINTAS TËCNICAS LTDA.    						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRSCH004(aParm)
     Local bErro := {|e| SCH004_1(e)}
     Local cEmp  := Alltrim(Transform(aParm[1],'@!'))
     Local cFil  := Alltrim(Transform(aParm[2],'@!'))

     lEndThread := .f.
     RpcMyErro()
     ErrorBlock(bErro)

     While !KillApp() .and. !lEndThread
           SCH004_3(cEmp, cFil)
     Enddo
Return(Nil)

/**************************************************************************************/
/*** SCH004_1 - Tratamento dos erros ocorridos.                                     ***/
/**************************************************************************************/
STATIC Function SCH004_1(e)
       If KillApp() .or. lEndThread
          Return
       Endif
       If e:GenCode == EG_JOB
          Sleep(60000)
          Break
       Else
          If (e:GenCode == EG_ZERODIV)
             Return(0)
          ElseIf (e:GenCode == EG_NOALIAS)
                 //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                 //ConOut("   *** Alias does not exist "+e:Operation)
                 FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   *** Alias does not exist "+e:Operation, 0 )
                 Return
          Endif
       Endif
       //LGS#20200212 - Adequação de release 12.1.25 e posteriores
       //ConOut("   ***"+SCH004_2(e))
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   ***"+SCH004_2(e), 0 )
       __QUIT()
Return(Nil)

/**************************************************************************************/
/*** SCH004_2 - Exibi a mensagem de erro na tela do server.                         ***/
/**************************************************************************************/
STATIC Function SCH004_2(e)
       Local cMessage := If( Empty(e:osCode), If(e:Severity > ES_WARNING, "Error ", "Warning "), "DOS Error "+nTrim(e:osCode)+" )" )
       cMessage += If( ValType(e:SubSystem) == "C", e:SubSystem, "???")
       If ValType(e:Description) == "C"
          cMessage += " "+e:Description
       Endif
       cMessage += If( !Empty(e:FileName), ": "+e:FileName, If( !Empty(e:Operation), ": "+e:Operation, "") )
Return(cMessage)

/**************************************************************************************/
/*** SCH004_3 - Faz o reprocessamento dos lotes de produção.                        ***/
/**************************************************************************************/
STATIC Function SCH004_3(cEmp, cFil)
       //Local cTime := ""  	
       Local cQry  := ""
       
       If ValType(cEmp) == "U" .or. ValType(cFil) == "U"
          lEndThread := .t.
          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
          //ConOut("   *** Erro na Empresa/Filial !!!")
          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   *** Erro na Empresa/Filial !!!", 0 )
       Endif
       If !lEndThread .and. ( Empty(Left(cEmp, 2)) .or. Empty(Left(cFil, 2)) )
          lEndThread := .t.
          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
          //ConOut("   *** Erro na Empresa e/ou Filial !!!")
          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   *** Erro na Empresa e/ou Filial !!!", 0 )
       Endif
       If lEndThread
          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
          //ConOut("   *** Erro na Inicialização do ambiente Local"+GetEnvServer()+".")
          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   *** Erro na Inicialização do ambiente Local"+GetEnvServer()+".", 0 )
          Return(Nil)
       Endif
       tIni := Time()   // Hora de inicio do processamento
       dIni := MSDate() // Data de inicio do processamento
       //LGS#20200212 - Adequação de release 12.1.25 e posteriores
       //ConOut("BRSCH004 - Thread iniciada com sucesso as: "+tIni+" - "+dToc(dIni))
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "BRSCH004 - Thread iniciada com sucesso as: "+tIni+" - "+dToc(dIni), 0 )
       //LGS#20200212 - Adequação de release 12.1.25 e posteriores
       //ConOut("BRSCH004 - Empresa: "+cEmp+" - Filial: "+cFil)
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "BRSCH004 - Empresa: "+cEmp+" - Filial: "+cFil, 0 )
       PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SA1"
               DbSelectArea("ZZ5")
               DbGoTop()
               DbSetOrder(1)
               cQry := ""
               cQry += "SELECT ZZ5.ZZ5_LOTE, "
               cQry += "       ZZ5.ZZ5_OP, "
               cQry += "       ZZ5.ZZ5_FLAG, "
               cQry += "       ZZ5.ZZ5_CODIGO, "
               cQry += "       ISNULL(SC2.C2_PRODUTO,'')  AS C2_PRODUTO, "
               cQry += "       ISNULL(SC2.C2_QUANT  ,0)   AS C2_QUANT, "
               cQry += "       ISNULL(SC2.C2_QUJE   ,0)   AS C2_QUJE, "
               cQry += "       ISNULL(SC2.C2_DATRF  ,'X') AS C2_DATRF "
               cQry += "FROM "+RetSqlName("ZZ5")+" ZZ5 "
               cQry += "LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 ON ZZ5.ZZ5_FILIAL = SC2.C2_FILIAL AND ZZ5.ZZ5_LOTE   = SC2.C2_LOTE AND ZZ5.ZZ5_OP     = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD   AND SC2.D_E_L_E_T_ = '' "
               cQry += "WHERE ZZ5.D_E_L_E_T_ = '' "
               cQry += "  AND ZZ5.ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
               cQry += "  AND ZZ5.ZZ5_FLAG   NOT IN('B','E') "
               cQry += "ORDER BY ZZ5.ZZ5_LOTE "

               TCQUERY cQry Alias "QREP" New
       
               DbSelectArea("QREP")
               DbGoTop()
               While !Eof()        
                     cLote  := QREP->ZZ5_LOTE
                     cOP    := QREP->ZZ5_OP
                     cCodigo:= QREP->ZZ5_CODIGO
                     cStatus := "A"
                     If Empty(QREP->C2_DATRF)
                        If QREP->C2_QUJE == 0
                           If cStatus == "B"
                              cStatus := "P"
                           ElseIf cStatus == "A"
                                  cStatus := "A"
                           Endif
                        Else
                           cStatus := "P"
                        Endif
                     Else
                        If Alltrim(QREP->C2_DATRF) $ "X"
                           cStatus := "E"
                        Else
                           cStatus := "B"
                        Endif
                     Endif
                     DbSelectArea("ZZ5")
                     If !Empty(cLote)
                        DbSetOrder(3)
                        DbSeek(xFilial("ZZ5")+cCodigo+cLote,.t.)
                     Else
                        DbSetOrder(4)
                        DbSeek(xFilial("ZZ5")+cCodigo+cOP,.t.)
                     Endif
                     If Found()
                        RecLock("ZZ5",.f.)
                           ZZ5->ZZ5_FLAG := cStatus
                        MsUnLock()
                     Endif
                     DbSelectArea("QREP")
                     DbSkip()
               Enddo
               DbSelectArea("QREP")
               DbCloseArea()
               tFim      := Time()   // Hora de fim do processamento
               dFim      := MSDate() // Data de fim do processamento
               //LGS#20200212 - Adequação de release 12.1.25 e posteriores
               //ConOut("BRSCH004 - Finalizando Thread do Reprocessamento de Lotes às "+tFim+" - "+dToc(dFim))
               FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "BRSCH004 - Finalizando Thread do Reprocessamento de Lotes às "+tFim+" - "+dToc(dFim), 0 )
               lEndThread := .t.
       RESET ENVIRONMENT
Return(Nil)
