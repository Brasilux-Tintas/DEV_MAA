//#include 'brasilux.ch'
#include "protheus.ch"                                                                                   
#include "rwmake.ch"
#include 'tbiconn.ch'                                                                                         
#include 'error.ch'
#include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSCH005 ºAutor  ³ Luís G. de Souza   º Data ³  11/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geração de Ordens de produção automáticas por pedidos.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSCH005(aParm)
     Local nOpc  := Iif(ValType(aParm) == 'U', 1, 2) //1 - Manual; 2 - Schedule
     Local bErro := ""
     Local cEmp  := ""
     Local cFil  := ""
     Private aGerTxtOps := {}
     Private cCallMenu  := "E"
     If nOpc == 1
        Processa({|| SCH005_3(nOpc, , )}, OemToAnsi("Processando Pedidos para Produção") ) //Faz o processamento das gerações das ordens de produção
     Else
        bErro := {|e| SCH005_1(e)} //Tratamento dos erros cometidos
        cEmp  := Alltrim(Transform(aParm[1],'@!'))
        cFil  := Alltrim(Transform(aParm[2],'@!'))
        lEndThread := .f.
        RpcMyErro()
        ErrorBlock(bErro)
     
        While !KillApp() .and. !lEndThread
              SCH005_3(nOpc, aParm[1], aParm[2]) //Faz o processamento das gerações das ordens de produção
        Enddo
     Endif
Return(Nil)

/**************************************************************************************/
/*** SCH005_1 - Tratamento dos erros ocorridos.                                     ***/
/**************************************************************************************/
Static Function SCH005_1(e)
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
       //ConOut("   ***"+SCH005_2(e)) //Exibe a mensagem de erro na tela do server
       FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   ***"+SCH005_2(e), 0 )
       __QUIT()
Return(Nil)


/**************************************************************************************/
/*** SCH005_2 - Exibi a mensagem de erro na tela do server.                         ***/
/**************************************************************************************/
Static Function SCH005_2(e)
       Local cMessage := If( Empty(e:osCode), If(e:Severity > ES_WARNING, "Error ", "Warning "), "DOS Error "+nTrim(e:osCode)+" )" )
       cMessage += If( ValType(e:SubSystem) == "C", e:SubSystem, "???")
       If ValType(e:Description) == "C"
          cMessage += " "+e:Description
       Endif
       cMessage += If( !Empty(e:FileName), ": "+e:FileName, If( !Empty(e:Operation), ": "+e:Operation, "") )
Return(cMessage)
/**************************************************************************************/
/*** SCH005_3 - Faz o processamento de geração das ordens de produção.              ***/
/**************************************************************************************/
Static Function SCH005_3(nOpc, cEmp, cFil)
       Local lRet := .t.,cUmEmb, nxY
       DbSelectArea("SB2")
       cQryEsp := "SELECT * FROM ESPECIFICOS WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND LOTE = '' ORDER BY ID "
       If nOpc == 1
          /*****************************************************************************************/
          /***             GERA ORDEM DE PRODUÇÃO X PEDIDO - EXECUTADA PELO USUÁRIO              ***/
          /*****************************************************************************************/
          ProcRegua(10)
       Else
          /*****************************************************************************************/
          /***             GERA ORDEM DE PRODUÇÃO X PEDIDO - AUTOMÁTICA PELO SISTEMA             ***/
          /*****************************************************************************************/
          If ValType(cEmp) == "U" .or. ValType(cFil) == "U"
             lEndThread := .t.
             QOut("   *** Erro na Empresa/Filial !!!")
          Endif
          If !lEndThread .and. ( Empty(Left(cEmp, 2)) .or. Empty(Left(cFil, 2)) )
             lEndThread := .t.
             QOut("   *** Erro na Empresa e/ou Filial !!!")
          Endif
          If lEndThread
             QOut("   *** Erro na Inicialização do ambiente Local"+GetEnvServer()+".")
             Return(Nil)
          Endif
          PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SB1", "SC2", "SD4"
       Endif
       /*****************************************************************************************************/
       /***Inicio do Processo                                                                             ***/
       /*****************************************************************************************************/
       TCQuery cQryEsp ALIAS "ESP" NEW
       DbSelectArea("ESP")
       DbGoTop()
       While !Eof()
             cId     := ESP->ID
             lGerLot := .t.
             cBasPro := SubStr(ESP->PRODUTO, 1, 10)
             nQtdPrI := 0
             aGerOPs := {}
             While !Eof() .and. cID == ESP->ID
                   cQry1   := ""
                   cQry1   += "SELECT SUM(QUANT) AS QUANT FROM ESPEPEDIDOS WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND (ID = '"+cId+"') AND SUBSTRING(EMBAL, 11, 2) = '"+SubStr(Alltrim(ESP->PRODUTO), 11, 2)+"' "
                   TCQuery cQry1 ALIAS "QPED" NEW
                   DbSelectArea("QPED")
                   aAdd(aGerOPs, {ESP->ID, ESP->PRODUTO, SubStr(Alltrim(ESP->PRODUTO), 11, 2), QPED->QUANT })
                   DbSelectArea("QPED")
                   DbCloseArea()
                   DbSelectArea("ESP")
                   DbSkip()
             Enddo

             If Len(aGerOPs) > 0
                For nxY := 1 To Len(aGerOPs)
                    If aGerOPs[nxY][4] > 0.00
                       If lGerLot
                          cLote   := U_NumSeqLot("SZZ")
                          cCodPro := aGerOPs[nxY][2]
                          lGerLot := .f.
                       Endif
                       //Grava no Arquivo SZZ (Lotes) dos Produtos Acabados
                       RecLock("SZZ", .t.)
                          SZZ->ZZ_FILIAL  := xFilial("SZZ")
                          SZZ->ZZ_LOTE    := cLote
                          SZZ->ZZ_DTEMIS  := dDataBase
                          SZZ->ZZ_PRODUTO := aGerOPs[nxY][2]
                          SZZ->ZZ_DESCR   := Posicione("SB1", 1, xFilial("SB1")+aGerOPs[nxY][2], "B1_DESC")
                          SZZ->ZZ_PREVI   := dDataBase
                          SZZ->ZZ_PREVF   := dDataBase
                          SZZ->ZZ_EMB     := aGerOPs[nxY][3]
                          SZZ->ZZ_DESEMB  := Posicione("SZ5", 1, xFilial("SZ5")+aGerOPs[nxY][3], "Z5_DESCR")
                          SZZ->ZZ_QTDETI  := aGerOPs[nxY][4]
                          SZZ->ZZ_PEDIDO  := ''
                          SZZ->ZZ_TPINCL  := "A"
                       MsUnlock()
                       lRet := SCH005_4(nOpc, aGerOPs[nxY][4], aGerOPs[nxY][2]) //Gera Ops. dos PAs no SG2
                       If lRet                 
                       		dbselectarea("SZ5") 
                       		dbsetorder(1)
                       		dbseek(xFilial("SZ5")+aGerOPs[nxY][3])
                          //Busca quantidade na estrutura do produto
                          DbSelectArea("SG1")
                          DbSetOrder(1)
                          DbSeek(xFilial("SG1")+aGerOPs[nxY][2]+cBasPro+iif(SZ5->Z5_UMEMB = 'K',"99","00"), .t.)
                          If Found()
                             nQtdPrI += ((aGerOPs[nxY][4] * SG1->G1_QUANT) / ((100 - SG1->G1_PERDA) / 100))
                          Else
                             nQtdPrI += ( aGerOPs[nxY][4] * SZ5->Z5_VOLUME)
                          Endif
                         //Atualiza Tabela de Pedidos (ESPECIFICOS)
                         cQry1 := ""
                         cQry1 += "UPDATE ESPECIFICOS SET LOTE = '"+cLote+"' WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND ID = '"+cID+"' AND PRODUTO = '"+aGerOPs[nxY][2]+"' "
                         TcSQLExec(cQry1)
                         //Atualiza Tabela de Pedidos (SC6)
                         cQry1 := ""
                         cQry1 += "SELECT * FROM ESPEPEDIDOS WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND ID = '"+cID+"' AND SUBSTRING(EMBAL, 11, 2) = '"+aGerOPs[nxY][3]+"' AND SUBSTRING(PEDIDO, 1, 1) <> '9' "
                         TCQuery cQry1 ALIAS "QPED" NEW
                         DbSelectArea("QPED")
                         While !Eof()
                               DbSelectArea("SC6")
                               DbSetOrder(2)
                               DbSeek(xFilial("SC6")+aGerOPs[nxY][2]+QPED->PEDIDO, .t.)
                               If Found()
                                  RecLock("SC6", .f.)
                                     SC6->C6_NUMOP   := SC2->C2_NUM
                                     SC6->C6_ITEMOP  := '01'
                                     SC6->C6_NUMLOTE := cLote
                                  MsUnLock()
                               Endif
                               DbSelectArea("QPED")
                               DbSkip()
                         Enddo
                         DbSelectArea("QPED")
                         DbCloseArea()
                       Else //Se não gerou ordem de produção do PA
                          DbSelectArea("SZZ")
                          DbSetOrder(1)
                          DbSeek(xFilial("SZZ")+cLote+cCodPro, .t.)
                          If Found()
                             RecLock("SZZ", .f.)
                                delete
                             MsUnLock()
                          Endif
                       Endif
                    Else
                      cQry1 := ""
                      cQry1 += "UPDATE ESPECIFICOS SET LOTE = 'XXXXXX' WHERE (EMPRESA = '"+ALLTRIM(cNumEmp)+"') AND ID = '"+cID+"' AND PRODUTO = '"+aGerOPs[nxY][2]+"' "
                      TcSQLExec(cQry1)
                    Endif
                Next
                If nQtdPrI > 0.0
                   If ((nQtdPrI * 100) - Int(nQtdPrI * 100)) > 0
                      nQtdPrI := Int((nQtdPrI * 100)+1) / 100
                   Endif
                   dbselectarea("SZ5")
                   dbsetorder(1)
                   dbseek(xFilial("SZ5")+Substr(ALLTRIM(cCodPro),11,2))
                   cUmEmb := iif(found() .and. (SZ5->Z5_UMEMB $ 'K'),"99","00")
                   DbSelectArea("SZZ")
                   RecLock("SZZ", .t.)
                      SZZ->ZZ_FILIAL  := xFilial("SZZ")
                      SZZ->ZZ_LOTE    := cLote
                      SZZ->ZZ_DTEMIS  := dDataBase
                      SZZ->ZZ_PRODUTO := cBasPro+cUmEmb
                      SZZ->ZZ_DESCR   := Posicione("SB1", 1, xFilial("SB1")+cBasPro+cUmEmb, "B1_DESC")
                      SZZ->ZZ_PREVI   := dDataBase
                      SZZ->ZZ_PREVF   := dDataBase
                      SZZ->ZZ_QTDETI  := Round(nQtdPrI, 2)
                      SZZ->ZZ_TPINCL  := "A"
                   MsUnlock()
				   // inclusão do workflow para geração dos avisos de FNC em 09/08/16 André
		           cQry1 := ""
		           cQry1 += " SELECT QI2_FNC, QI2_DESCR, QI2_CODPRO, QI2_LOTE "
				   cQry1 += " FROM "+RetSqlName("QI2")+" WITH(NOLOCK) "
				   cQry1 += " WHERE D_E_L_E_T_ ='' AND QI2_FILIAL ='"+xFilial("QI2")+"'"
				   cQry1 += " AND QI2_CODPRO <>'' AND QI2_STATUS ='2' "               
		           cQry1 += " AND SUBSTRING(QI2_CODPRO,6,5) = '"+Substr(cBasPro,6,5)+"' "
		           TCQuery cQry1 ALIAS "QI2WF" NEW
		           DbSelectArea("QI2WF")
		           If !Eof()
					   cTexto := "Emissão de Ordem de produção (COR + VARIAÇÃO) com Ficha de Não conformidade em aberto."
					   cTexto += CHR(13)+CHR(10)+"Cor + Variação :  "+Substr(QI2WF->QI2_CODPRO,6,5)+ " Lote FNC ->  "+QI2WF->QI2_LOTE+" - "+" - "+QI2WF->QI2_CODPRO
					   cTexto += CHR(13)+CHR(10)+"Número FNC -> "+QI2WF->QI2_FNC
					   cTexto += CHR(13)+CHR(10)+"Novo Lote  -> "+cLote+" gerado por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
					   cTexto += CHR(13)+CHR(10)+"Prog. Origem : BRSCH005"
					   If Substr(xFilial("SC2"),1,2)== "06"
						    U_EnvMail("DISSOLTEX - Emissão de O.p (Cor + Variação) com FNC aberta. Cor/Variação -> "+Substr(QI2WF->QI2_CODPRO,6,5) ,cTexto,"silene@dissoltex.com.br","") 
		               Else
						    U_EnvMail("BRASILUX  - Emissão de O.p (Cor + Variação) com FNC aberta. Cor/Variação -> "+Substr(QI2WF->QI2_CODPRO,6,5) ,cTexto,"pcp@brasilux.com.br,marciononis@brasilux.com.br","")                       	  
					   Endif
			        Endif    
		            DbSelectArea("QI2WF")
		            DbCloseArea()	

                    // Inclusão do Workflow em 25/10/16 para pegar tb nas ops geradas no brastintas
	                cQry1 := ""
    	            cQry1 += " SELECT DATEDIFF(M,MAX(C2_EMISSAO),GETDATE()) AS 'MESES'  "
	                cQry1 += " FROM "+RetSqlName("SC2")+" WITH(NOLOCK) "
	                cQry1 += " WHERE C2_FILIAL ='"+xFilial("SC2")+"' AND D_E_L_E_T_ ='' AND C2_LOTE <>'' "
	                cQry1 += " AND C2_PRODUTO = '"+cBasPro+cUmEmb+"'"

    	            TCQuery cQry1 ALIAS "SC2WF" NEW
	                DbSelectArea("SC2WF")
	                If !Eof() .and. SC2WF->MESES > 5
				   	   //If SC2WF->MESES > 5
					   	   cTexto := "Emissão de Ordem de produção com última produção a mais de 6 meses."
						   cTexto+= CHR(13)+CHR(10)+"Produto -> "+cBasPro+cUmEmb
						   cTexto+= CHR(13)+CHR(10)+"Lote  -> "+cLote+" gerado por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
						   cTexto+= CHR(13)+CHR(10)+"Qtde  -> "+TRANSFORM(nQtdPrI,'@E 999,999,999.99')
			   			   cTexto+= CHR(13)+CHR(10)+"Produzido a  "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses atrás."
					   	   cTexto+= CHR(13)+CHR(10)+"Prog. Origem : BRSCH005"
						   If Substr(xFilial("SC2"),1,2)== "06"
							    U_EnvMail("DISSOLTEX - Emissão de Ordem de produção com última produção a "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses. " ,cTexto,"silene@dissoltex.com.br","") 
            		       Else
							    U_EnvMail("BRASILUX  - Emissão de Ordem de produção com última produção a "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses. " ,cTexto,"pcp@brasilux.com.br","")                       	  
						   Endif
						//Endif
				    Endif	
	                DbSelectArea("SC2WF")
				    DbCloseArea()

					DbSelectArea("SC2")
					DbSetOrder(2) // Filial + Produto + Entrega
					DbSeek(xFilial("SC2")+(cBasPro+cUmEmb), .t.)
					If !Found() 
			   	   		cTexto := "Emissão de Ordem de produção de produto novo."
				   		cTexto+= CHR(13)+CHR(10)+"Produto -> "+cBasPro+cUmEmb
				   		cTexto+= CHR(13)+CHR(10)+"Lote  -> "+cLote+" gerado por : "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
				   		cTexto+= CHR(13)+CHR(10)+"Qtde  -> "+TRANSFORM(nQtdPrI,'@E 999,999,999.99')
	   		   	   		cTexto+= CHR(13)+CHR(10)+"Prog. Origem : BRSCH005"
				   		If Substr(xFilial("SC2"),1,2)== "06"
					    	U_EnvMail("DISSOLTEX - Emissão de Ordem de produção de produto novo. (Primeira Produção) " ,cTexto,"silene@dissoltex.com.br","") 
       	    	   		Else
					    	U_EnvMail("BRASILUX  - Emissão de Ordem de produção de produto novo. (Primeira Produção) " ,cTexto,"materiais@brasilux.com.br","")                       	  
				   		Endif

 	  	            Endif
		  		    DbSelectArea("SC2")

                    lRet := SCH005_4(nOpc, Round(nQtdPrI, 2), cBasPro+cUmEmb+'   ') //Gera Ops. do PI e SG2
                   /*
                   If lRet
                      cQry1 := ""
                      cQry1 += "SELECT D4_COD,D4_QUANT "
                      cQry1 += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
                      cQry1 += "WHERE SD4.D4_FILIAL  = '"+xFilial("SD4")+"' "
                      cQry1 += "  AND SD4.D_E_L_E_T_ = '' "
                      cQry1 += "  AND SD4.D4_OP      = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+"' "
                      cQry1 += "  AND SUBSTRING(SD4.D4_COD, 1, 5) = '"+SUBSTR(Alltrim(SC2->C2_PRODUTO), 6, 5)+"' "
                      TCQuery cQry1 ALIAS "QEMP" NEW 
                      DbSelectArea("QEMP")
                      nQtdCon := QEMP->D4_QUANT
                      cCodCon := QEMP->D4_COD
                      DbSelectArea("QEMP")
                      DbCloseArea()
                      If !Empty(cCodCon)
                         nQtdLMi := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
                         nTipCon := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
                         nFatCon := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
                         nQtdCo2 := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                         cUniMed := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
                         cRotCon := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                         lTemLoc := !Empty(Posicione("SB2", 1, xFilial("SB2")+Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_COD")+Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD"), "B2_LOCALIZ"))
                         If lTemLoc //Se tem localização
                            If nQtdCon >= 30.0 //Se Quantidade do Concentrado for maior ou igual a 30
                               lGerCon := .t.
                            Else
                               lGerCon := .f.
                            Endif
                         Else
                            lGerCon := .t.
                         Endif
                         If lGerCon
                            cLocPad := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
                            cNumOp  := SC2->C2_NUM
                            //cCodCon := SUBSTR(SC2->C2_PRODUTO, 6, 5)
                            //Gera Fomula do Concentrado
                            aAutoSC2 := {}
                            aadd(aAutoSC2, {"C2_ITEM"   , "02"                           , NIL})
                            aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                            aadd(aAutoSC2, {"C2_NUM"    , cNumOp                         , NIL})
                            aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                            aadd(aAutoSC2, {"AUTEXPLODE", 'S'                            , NIL})
                            aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
                            aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
                            aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
                            aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
                            aadd(aAutoSC2, {"C2_DATPRI" , dDataBase                      , NIL})
                            aadd(aAutoSC2, {"C2_DATPRF" , dDataBase                      , NIL})
                            aadd(aAutoSC2, {"C2_EMISSAO", dDataBase                      , NIL})
                            aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                            aadd(aAutoSC2, {"C2_ROTEIRO", cRotCon                        , NIL})
                            lMsErroAuto := .f.
                            Dbselectarea("SC2")
                            MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
                            If !lMsErroAuto
                               //Gera arquivo TXT para InkMaker
                               SCH005_5(nOpc, {{cCodCon, '      ', SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, SC2->C2_QUANT}}) //Gera OP em TXT para dosador de pastas
                            Endif
                         Endif
                      Endif
                   Endif */
                Endif
             Endif
             DbSelectArea("ESP")
       Enddo
       /*****************************************************************************************************/
       /***Fim do Processo                                                                                ***/
       /*****************************************************************************************************/
       If nOpc == 1
          MsgBox("Fim do Processo !!!", "Atenção...", "INFO")
          DbSelectArea("ESP")
          DbCloseArea()
       Else
                //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                //ConOut("Fim do Processo")
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Fim do Processo", 0 )
                //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                //ConOut("*********************** ("+GetComputerName()+", SCHEDULE__) ************************")
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "*********************** ("+GetComputerName()+", SCHEDULE__) ************************", 0 )
                //ConOut("")
                DbSelectArea("ESP")
                DbCloseArea()
                lEndThread := .t.
          RESET ENVIRONMENT
       Endif
Return(Nil)

/**************************************************************************************/
/*** SCH005_4 - Gera a OP utilizando o MSEXECAUTO.                                  ***/
/**************************************************************************************/
Static Function SCH005_4(nOpc, nQtdOrd, cCodPro)
       Local lRet          := .t.
       Private lMSErroAuto := .f.
       Private lMSHelpAuto := .t.
       cRoteir := Posicione("SB1", 1, xFilial("SB1")+cCodPro, "B1_OPERPAD")
       nPrvEnt := Posicione("SB1", 1, xFilial("SB1")+cCodPro, "B1_PE")
       cLocPad := Posicione("SB1", 1, xFilial("SB1")+cCodPro, "B1_LOCPAD")
       cUniMed := Posicione("SB1", 1, xFilial("SB1")+cCodPro, "B1_UM")
       
       SetFunName("MATA650") //LGS#20200811 - Para funcionar a integração com o PPI Multitask

       If (SZZ->ZZ_PREVI + nPrvEnt) > SZZ->ZZ_PREVF
          dAuxData := SZZ->ZZ_PREVI + nPrvEnt
       Else
          dAuxData := SZZ->ZZ_PREVF
       Endif
       If Empty(cRoteir)
          DbSelectArea("SG2")
          DbSetOrder(1)
          DbSeek(xFilial("SG2")+cCodPro, .t.)
          If Found()
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+cCodPro, .t.)
             If Found()
                RecLock("SB1", .f.)
                   SB1->B1_OPERPAD := SG2->G2_CODIGO
                MsUnLock()
                cRoteir := SG2->G2_CODIGO
             Endif
          Else
             DbSelectArea("SG2")
             If !(Substr(Alltrim(cCodPro),11, 2) $ "00.99") //Produto acabado
                RecLock("SG2", .t.)
                   SG2->G2_FILIAL  := xFilial("SG2")
                   SG2->G2_CODIGO  := '01'
                   SG2->G2_PRODUTO := cCodPro
                   SG2->G2_OPERAC  := '04'
                   SG2->G2_RECURSO := '000005'
                   SG2->G2_DESCRI  := 'ENVASAMENTO'
                   SG2->G2_TEMPAD  := 1.0
                   SG2->G2_TPOPER  := '1'
                MsUnLock()
             Else
                RecLock("SG2", .t.)
                   SG2->G2_FILIAL  := xFilial("SG2")
                   SG2->G2_CODIGO  := '01'
                   SG2->G2_PRODUTO := cCodPro
                   SG2->G2_OPERAC  := '01'
                   SG2->G2_RECURSO := '000002'
                   SG2->G2_DESCRI  := 'PESAGEM'
                   SG2->G2_TEMPAD  := 1.0
                   SG2->G2_TPOPER  := '1'
                MsUnLock()
                RecLock("SG2", .t.)
                   SG2->G2_FILIAL  := xFilial("SG2")
                   SG2->G2_CODIGO  := '01'
                   SG2->G2_PRODUTO := cCodPro
                   SG2->G2_OPERAC  := '02'
                   SG2->G2_RECURSO := '000015'
                   SG2->G2_DESCRI  := 'TINGIMENTO'
                   SG2->G2_TEMPAD  := 1.0
                   SG2->G2_TPOPER  := '1'
                MsUnLock()
             Endif
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+cCodPro, .t.)
             If Found()
                RecLock("SB1", .f.)
                   SB1->B1_OPERPAD := '01'
                MsUnLock()
                cRoteir := '01'
             Endif
          Endif
       Endif

       DbSelectArea("SB1")
       DbSetOrder(1)
       DbSeek(xFilial("SB1")+cCodPro, .t.)
       If Found()
	       nQuant2  := IIF(SB1->B1_TIPCONV != "D", (SZZ->ZZ_QTDETI * SB1->B1_CONV), (SZZ->ZZ_QTDETI / SB1->B1_CONV) )
           cUltRev  := QA_UltRvQ(Alltrim(cCodPro),,.F.)
       Endif	   

       aAutoSC2 := {}
       aadd(aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                , NIL})
       aadd(aAutoSC2, {"C2_ITEM"   , "01"                          , NIL})
       aadd(aAutoSC2, {"C2_SEQUEN" , "001"                         , NIL})
       aadd(aAutoSC2, {"C2_PRODUTO", cCodPro                       , NIL})
   	   aadd(aAutoSC2, {"AUTEXPLODE", 'S'                      	   , NIL})
       aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                       , NIL})
       aadd(aAutoSC2, {"C2_QUANT"  , nQtdOrd                       , NIL})
       aadd(aAutoSC2, {"C2_QTSEGUM", nQuant2					   , NIL})
       aadd(aAutoSC2, {"C2_UM"     , cUniMed                       , NIL})
       aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                 , NIL})
       aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                      , NIL})
       aadd(aAutoSC2, {"C2_EMISSAO", dDataBase                     , NIL})
       aadd(aAutoSC2, {"C2_TPOP"   , "F"                           , NIL})
       aadd(aAutoSC2, {"C2_LOTE"   , SZZ->ZZ_LOTE                  , NIL})
       aadd(aAutoSC2, {"C2_PEDIDO" , " "                           , NIL})
       aadd(aAutoSC2, {"C2_ITEMPV" , " "                           , NIL})
   	   aadd(aAutoSC2, {"C2_ROTEIRO", cRoteir                       , NIL})
	   If SB1->B1_TIPO $ 'PI' .AND. Len(Alltrim(cUltRev)) >0 
           aadd(aAutoSC2, {"C2_REVI"   , cUltRev				   , NIl})
       Endif
       lMsErroAuto := .f.
       Dbselectarea("SC2")
       dbsetorder(1)
       dbseek(xFilial("SC2"))
       MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
       If !lMsErroAuto
          cNumGer := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
          cProGer := SC2->C2_PRODUTO
          DbSelectArea("SZZ")
          DbSetOrder(1)
          DbSeek(xFilial("SZZ")+SC2->C2_LOTE+SC2->C2_PRODUTO, .t.)
          RecLock("SZZ", .f.)
             SZZ->ZZ_FLAG := 'S'
          MsUnLock()
          If (Substr(Alltrim(cCodPro),11,2) $ "00_99") 
             SCH005_5(nOpc, {{cCodPro, SZZ->ZZ_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, SC2->C2_QUANT}}) //Gera OP em TXT para dosador de pastas
             DbSelectArea("SC2")
             DbSetOrder(1)
             DbSeek(xFilial("SC2")+cNumGer, .t.)
          Endif
       Else
          If nOpc == 1
             MsgBox("O Produto "+SZZ->ZZ_PRODUTO+" do Lote "+SZZ->ZZ_LOTE+" não foi processado!", "Atencao!", "STOP")
             MostraErro()
          Else
             //LGS#20200212 - Adequação de release 12.1.25 e posteriores
             //ConOut("O Produto "+SZZ->ZZ_PRODUTO+" do Lote "+SZZ->ZZ_LOTE+" não foi processado!")
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "O Produto "+SZZ->ZZ_PRODUTO+" do Lote "+SZZ->ZZ_LOTE+" não foi processado!", 0 )
          Endif
          lRet := .f.
       Endif
Return(lRet)

/**************************************************************************************/
/*** SCH005_5 - Gera a OP em arquivo TXT para DOSADOR de pastas.                    ***/
/**************************************************************************************/
Static Function SCH005_5(nOpc, aGerTxt)
       Local lExiste   := .f.
       Local nX, nY
       Local _cMVRETENO := GETMV("MV_RETENOP")
       Local _cDOSADOR  := GETMV("MV_DOSADOR")
       Private cArqTxt := ""
       Private nHdl    := 0
       Private cEOL    := CHR(13)+CHR(10)
       If Len(aGerTxt) > 0
          For nY := 1 To Len(aGerTXT)
              lExiste := .f.
              cDescri := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[nY][1], "B1_DESC")
              aQtdMat := {} ; aVolMat := {}
              aCodMat := {}
              aadd(aQtdMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
              aadd(aCodMat, {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
              aadd(aVolMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
              nPos    := 1
              DbSelectArea("SD4")
              DbSetOrder(2)
              DbSeek(xFilial("SD4")+aGerTxt[nY][3], .t.)
              If Found()
                 While !Eof() .and. Alltrim(SD4->D4_OP) == Alltrim(aGerTxt[nY][3])
                       If nPos <= 20
                          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                          //If !Alltrim(SD4->D4_COD) $ Alltrim(GETMV("MV_RETENOP"))
                          If !Alltrim(SD4->D4_COD) $ Alltrim( _cMVRETENO )
                             aQtdMat[1][nPos] := SD4->D4_QUANT
                             aCodMat[1][nPos] := Alltrim(SD4->D4_COD)
                             aVolMat[1][nPos] := SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP")
                             nPos += 1
                             If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
                                lExiste := .t.
                             Endif
                          Endif
                       Endif
                       DbSelectArea("SD4")
                       DbSkip()
                 Enddo
              Endif
              nQtdMat := 0
              For nX := 1 To 20
                  nQtdMat += aQtdMat[1][nX]
              Next
              If nQtdMat <= 0
                 Loop
              Endif
              If !lExiste
                 Loop
              Endif
              //LGS#20200212 - Adequação de release 12.1.25 e posteriores
              //lPatTxt := File(GETMV("MV_DOSADOR")+"DOSADOR.CFG")
              lPatTxt := File( _cDOSADOR + "DOSADOR.CFG")
              If lPatTxt
                 //cPatTxt := Alltrim(GETMV("MV_DOSADOR"))
                 cPatTxt := Alltrim( _cDOSADOR )
              Else
                 cPatTxt := Alltrim("F:\TEMP\DOSADOR\")
              Endif
              cArqTxt := cPatTxt+SubStr(aGerTxt[nY][3], 1, 6)+'.DAT'
              nHdl    := fCreate(cArqTxt)
              If nHdl == -1
                 If nOpc == 1
                    MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.", "Atencao!")
                 Else
                    //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                    //ConOut("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.")
                    FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.", 0 )
                 Endif
                 Loop
              Endif
              
              aCodEmb := { "", "", "", "", "", ""}
              aDesEmb := { "", "", "", "", "", ""}
              aOPSEmb := { "", "", "", "", "", ""}
              aQtdEmb := {  0,  0,  0,  0,  0,  0}
              aLocEmb := { "", "", "", "", "", ""}
              nPos := 1
              DbSelectArea("SC2")
              DbOrderNickName("SC2001")
              DbSeek(xFilial("SC2")+aGerTxt[nY][2], .t.)
              While !Eof() .and. SC2->C2_LOTE == aGerTxt[nY][2]
                    If !(Substr(Alltrim(SC2->C2_PRODUTO),11, 2) $ "00.99") 
                       If nPos <= 6
                          aCodEmb[nPos] := SubStr(Alltrim(SC2->C2_PRODUTO), 11, 2)
                          aDesEmb[nPos] := Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(SC2->C2_PRODUTO), 11, 2), "Z5_DESCR"))
                          aOPSEmb[nPos] := SC2->C2_OP
                          aQtdEmb[nPos] := SC2->C2_QUANT
                          aLocEmb[nPos] := SC2->C2_LOCAL
                          nPos += 1
                       Endif
                    Endif
                    DbSelectArea("SC2")
                    DbSkip()
              EndDo
              cProduto := aGerTxt[nY][1]
              cCatalis := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[nY][1], "B1_CATALIS")
              dEmissao := DTOC(aGerTxt[nY][4])
              nVolume  := aGerTxt[nY][5]
              nPeso    := aGerTxt[nY][5] * Posicione("SB1", 1, xFilial("SB1")+aGerTXT[nY][1], "B1_PESOESP")
              cNumOrd  := aGerTxt[nY][3]
              cNumLot  := aGerTxt[nY][2]
              /******************************************************************/
              /*** MONTAGEM DO ARQUIVO TEXTO                                  ***/
              /******************************************************************/
              /*** Linha 1 - Descrição do produto ***/
              cLin := ""
              cCpo := PADR(cDescri, 040)
              cLin := Stuff(cLin, 001, 040, cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 2 - Quantidades de matérias primas ***/
              cLin := ""
              cCpo := ""
              For nX := 1 To 20
                  cCpo += Alltrim(Stuff( TransForm(aQtdMat[1][nX], "@E 99999.999999"), At(",", TransForm(aQtdMat[1][nX], "@E 99999.999999")), 1 , "."))+' '
              Next
              cCpo := PADR(Alltrim(cCpo), Len(Alltrim(cCpo)))
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), Alltrim(cCpo))+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 3 - Materias Primas ***/
              cLin := ""
              cCpo := ""
              For nX := 1 To 20
                  If !Empty(aCodMat[1][nX])
                     cCpo += Alltrim(aCodMat[1][nX])+' '
                  Else
                     cCpo += "0000 "
                  Endif
              Next
              cCpo := PADR(Alltrim(cCpo), Len(Alltrim(cCpo)))
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 4 - Código do Produto ***/
              cLin := ""
              cCpo := Alltrim(cProduto)
              cLin := Stuff(cLin, 001, Len(Alltrim(cProduto)), cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 5 - Data de Emissão ***/
              cLin := ""
              cCpo := Alltrim(dEmissao)
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 6 - Volume e Peso ***/
              cLin := ""
              cCpo := Alltrim(Stuff(TransForm(nVolume, "@E 99999.999999"), At(",", TransForm(nVolume, "@E 99999.999999")), 1, "."))+' '+Alltrim(Stuff(TransForm(nPeso, "@E 99999.999999"), At(",", TransForm(nPeso, "@E 99999.999999")), 1, "."))
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 7 - Numero da Ordem de Produção ***/
              cLin := ""
              cCpo := Alltrim(cNumOrd)
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 8 - Numero do Lote ***/
              cLin := ""
              cCpo := Alltrim(cNumLot)
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 09 a 14 - Código da Embalagem ***/
              For nX := 1 To 6
                  cLin := ""
                  cCpo := Alltrim(aCodEmb[nX])
                  cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
                  fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              Next
              /*** Linha 15 a 20 - Descrição da Embalagem ***/
              For nX := 1 To 6
                  cLin := ""
                  cCpo := Alltrim(aDesEmb[nX])
                  cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
                  fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              Next
              /*** Linha 21 a 26 - Numero da Ordem de Produção ***/
              For nX := 1 To 6
                  cLin := ""
                  cCpo := Alltrim(aOPSEmb[nX])
                  cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
                  fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              Next
              /*** Linha 27 - Código do Catalisador ***/
              cLin := ""
              cCpo := Alltrim(cCatalis)
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 28 - Quantidade por Embalagem ***/
              cLin := ""
              cCpo := ""
              For nX := 1 To 6
                  cCpo += Alltrim(Stuff( TransForm(aQtdEmb[nX], "@E 99999.999999"), At(",", TransForm(aQtdEmb[nX], "@E 99999.999999")), 1 , "."))+' '
              Next
              cCpo := PADR(Alltrim(cCpo), Len(Alltrim(cCpo)))
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), Alltrim(cCpo))+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Linha 29 a 34 - Local do Produto Embalado ***/
              For nX := 1 To 6
                  cLin := ""
                  cCpo := Alltrim(aLocEmb[nX])
                  cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), cCpo)+cEol
                  fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              Next
              /*** Linha 35 - Volumes das matérias primas ***/
              cLin := ""
              cCpo := ""
              For nX := 1 To 20
                  cCpo += Alltrim(Stuff( TransForm(aVolMat[1][nX], "@E 99999.999999"), At(",", TransForm(aVolMat[1][nX], "@E 99999.999999")), 1 , "."))+' '
              Next
              cCpo := PADR(Alltrim(cCpo), Len(Alltrim(cCpo)))
              cLin := Stuff(cLin, 001, Len(Alltrim(cCpo)), Alltrim(cCpo))+cEol
              fWrite(nHdl, cLin, Len(cLin)) //!= Len(cLin)
              /*** Finaliza arquivo ***/
              fClose(nHdl)
          Next
       Endif
Return
