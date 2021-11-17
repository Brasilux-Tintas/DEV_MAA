//#include 'brasilux.ch'
#include "protheus.ch"
#include 'tbiconn.ch'                                                       
#include 'error.ch'                                                
#include 'topconn.ch'                          
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                                                      
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSCH014 ºAutor  ³ Luís G. de Souza   º Data ³  07/06/10   º±±                 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baixa de Ordens de produção por processo - Nova Versão     º±±
±±º          ³ para baixa de Ops através da tabela ZZA.                   º±±
±±º          ³             PROCESSO DE FINALIZAÇÃO DE PRODUTOS ACABADOS.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³Analista Resp.³  Data     ³  Alterações                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Tiago Lucio  ³ 25/02/14  ³   //Inclusão do tratamento para bloquear   ³±±
±±³	o exclusão da SD4 pelo parâmetro MV_XHABZZF nas baixas das matérias   ³±±
±±³	primas.      								  						  ³±± 
±±³                                       								  ³±±
±±³              ³  /  /  ³                                               ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BRSCH014( _aParm )

     //Local a_cFil       := {"010101","060101"}
     //Local aParm        := Iif(ValType(aParm) == 'U', {"01",a_cFil , "2"}, aParm)     
     Local aParm        := Iif( ValType( _aParm ) == 'U', {"01", cFilAnt, "2"}, _aParm )
     Local cEmp         := Alltrim(Transform(aParm[1],'@!'))
     Local cFil         := Alltrim(Transform(aParm[2],'@!'))
     Local nOpc         := Alltrim(Transform(aParm[3],'@!'))
     Local _cAuxMens    := ""
	 Private lEndThread := .f.     
	 
     //LGS#20200212 - Adequação de release 12.1.25 e posteriores
     //ConOut("**********************************")
     //ConOut("*  BRSCH014 - BAIXA DE PRODUÇÃO  *")
     //ConOut("**********************************")
     _cAuxMens    := "*  BRSCH014 - BAIXA DE PRODUÇÃO  *"
     FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
     //RPCSetType(3)  // Nao utilizar licenca   Retirado pq causava erro ao trocar de módulo 16/10/13
     //bErro := {|e| SCH014_1(e, nOpc)} //Tratamento dos erros cometidos
     //RpcMyErro()
     //ErrorBlock(bErro)
     If nOpc == '1'
        //For i:= 1 to Len(a_cFil)     
	       	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SB1", "SC2", "SD3", "SD4", "SH6", "ZZA"
	        	//LGS#20200212 - Adequação de release 12.1.25 e posteriores
	        	//ConOut("-- INICIO ")
	        	_cAuxMens    := "-- INICIO "
	        	FwLogMSG( "ERROR",                  , 'SIGAPCP', funname(), '', '01', _cAuxMens                           , 0 )
	        	      U_SCH014_3(nOpc, cEmp, cFil ) //Faz o processamento das gerações das ordens de produção
                //LGS#20200212 - Adequação de release 12.1.25 e posteriores
	        	//ConOut("-- FIM ")
	        	_cAuxMens    := "-- FIM "
	        	FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
        	RESET ENVIRONMENT
        //Next i
     Else
	     Processa( { |lEnd| U_SCH014_3(nOpc, cEmp, cFil ) }, "Baixa de O.P.s - P.A.s", ,.t.) //Faz o processamento das baixas das ordens de produção
     Endif
Return(Nil) 

/**************************************************************************************/
/*** SCH014_3 - Faz o processamento de baixa das materias primas.                   ***/
/**************************************************************************************/
User Function SCH014_3(nOpc, cEmp, cFil)
       //Local dDatFin    := ""
       //Local cCodBai    := ""
       //Local cBaiPro    := ""
       //Local dUltFec    := ""
       Local cFlaBai    := ""
       //Local cTipExe    := ""                                               
       Local nQtdMaio   := 0
       Local nQUJE      := 0 
       //Local cBxLocP    := "" //Parâmetro desativado - 22/06/2011
       //Local _cLocMP  := ""
       //Local cArqBloq,aBloq,cAux,_cAreaBloq
       Local nY, nSLT
       Local _cAuxMens  := ""
       //Local _cMPInd  := ""
       Local dDatFin := GETMV('MV_BXOPFEC')     //Data Final para baixa de Ordens de produção
       Local cCodBai := GETMV('MV_CBAIREQ')     //Código do movimento para as baixas
       //Local cBaiPro := GETMV('MV_BXPROP')      //Baixa proporcional a O.P.
       Local dUltFec := GETMV('MV_ULMES') //Ultimo fechamento
       Local _lXHABZZF := GetMV("MV_XHABZZF")
       Local _nTOLBOP  := GETMV("MV_TOLBOP")
       //Local cFlaBai := GETMV("MV_BXMANEW")
       //Local cTipExe := GETMV("MV_PROCEXE")
       //Local cBxLocP := GETMV("MV_BXLOCPD")     //Local para Baixa das Ordens de produção.
       Private lDelOPSC := .t.
       Private lPerdInf := .t.
       Private lProdAut := .f.
       Private nRecSD3  := 0

//Bloquear função para acesso exclusivo
/*
cArqBloq := "SC14"+ALLTRIM(cNumEmp)+".DTC"
aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
if aBloq[1,1] //Já estava bloqueado?
	cAux := "O programa SCH014_3 já está sendo executado pelo usuario -> "+aBloq[1,2]
	If nOpc $ '1'
		ConOut(cAux)
	Else
		MsgStop(cAux)
	Endif
	Return(Nil)
endif 	
_cAreaBloq := aBloq[1,2]
*/
       //LGS#20200212 - Adequação de release 12.1.25 e posteriores - parametros declarados no inicio do programa.                                                  
       //u_fBusPar(@dDatFin, @cCodBai, @cBaiPro, @dUltFec, @cFlaBai, @cTipExe, nOpc, @cBxLocP) //Essa função está no programa BRSCH013
       
         //If sTod(dDatFin) > sTod(dUltFec)  //LGS#20200217 - Adequação de release 12.1.25 e posteriores
         If sTod(dDatFin) > dUltFec
          	If Empty(cFlaBai) //Verifica se o sistema já está processando a baixa
             //PutMv("MV_BXMANEW", "N"+"|"+Alltrim(Iif(nOpc == "1", "SCHEDULE", cUserName))+"|"+Time()+"|"+Dtoc(MsDate()) )
             PutMv("MV_ESTNEG" , "N")
             PutMv("MV_BXPROP" , "S")
             cQry1 := ""
             cQry2 := ""
             cQry3 := ""
             cQry1 += " SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE, ZZA.ZZA_PRODUT, ZZA.ZZA_QUANT, ZZA.ZZA_SEQENV, ZZA.ZZA_DTINI, "+;
             " ZZA.ZZA_HINI, ZZA.ZZA_DTFIM, ZZA.ZZA_HFIM, ZZA.ZZA_HELP, ZZA.ZZA_FLAG, ISNULL(SC2.C2_QUANT, 0) AS C2_QUANT, "+;
             " ISNULL(SC2.C2_QUJE, 0) AS C2_QUJE, ISNULL(SC2.C2_DATRF, 'SC2') AS C2_DATRF, ZZA.R_E_C_N_O_, SC2.C2_ROTEIRO, "+;
             " ZZA.ZZA_RAMPA, ZZA_TPENVA, C2_LOCAL,ZZA_PESESP, ZZA_PROSOB"
             cQry2 += "SELECT COUNT(ZZA.R_E_C_N_O_) AS NQTDREG "
             cQry3 += " FROM ZZA"+cEmp+"0 ZZA WITH (NOLOCK) "
             cQry3 += " LEFT OUTER JOIN SC2"+cEmp+"0 SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = '' "
             cQry3 += " WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
             cQry3 += "  AND ZZA.D_E_L_E_T_ = '' "
             cQry3 += "  AND ZZA.ZZA_FLAG   IN('7', '8', '9', 'E') "
             cQry3 += "  AND ZZA.ZZA_DTFIM  <= '"+dDatFin+"' "
             //cQry3 += "  AND ZZA.ZZA_LOTE IN('664277') "
             cQry2 += cQry3
             TCQuery cQry2 ALIAS "TBAI" NEW
             DbSelectArea("TBAI")
             nQtdRec := TBAI->NQTDREG
             DbSelectArea("TBAI")
             DbCloseArea()
             If nOpc == "2"
                ProcRegua(nQtdRec)
             Endif
             cQry3 += "ORDER BY ZZA.ZZA_FLAG, ZZA_ORDEM, ZZA.ZZA_SEQENV, ZZA.ZZA_DTFIM, ZZA.ZZA_HFIM "
             cQry1 += cQry3
             TCQuery cQry1 ALIAS "TBAI" NEW
             DbSelectArea("TBAI")
             While !Eof()
                   nQtdMaio := 0
                   If nOpc == "2"
                      IncProc("Processando Produtos Acabados... "+TBAI->ZZA_ORDEM+"-"+TBAI->ZZA_SEQENV)
                   Endif
                   //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                   //ConOut("Processando Produtos Acabados... "+TBAI->ZZA_ORDEM+"-"+TBAI->ZZA_SEQENV)
                   _cAuxMens    := "Processando Produtos Acabados... "+TBAI->ZZA_ORDEM+"-"+TBAI->ZZA_SEQENV
                   FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
                   //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                   //If STOD(TBAI->ZZA_DTFIM) <= GETMV("MV_ULMES") 
                   If STOD(TBAI->ZZA_DTFIM) <= dUltFec
                      //dDatFim := DTOS( GETMV("MV_ULMES") + 1)
                      dDatFim := DTOS( dUltFec + 1)
                   Else
                      dDatFim := TBAI->ZZA_DTFIM
                   Endif
                   If Empty(TBAI->C2_DATRF)
                      aRotBai := {}
                      u_fBusRot( @aRotBai, TBAI->ZZA_ORDEM, TBAI->ZZA_PRODUT, TBAI->C2_ROTEIRO, TBAI->ZZA_SEQENV )
                      If Len(aRotBai) > 0
                         cQry4 := ""
                         cQry4 += "SELECT ZZA.ZZA_PRODUT, ZZA.ZZA_FLAG, ZZA.ZZA_QUANT, SB2.B2_QATU "
                         cQry4 += "FROM "+RetSqlName("ZZA")+" ZZA WITH(NOLOCK) "
                         cQry4 += "LEFT OUTER JOIN SB2010 SB2 WITH(NOLOCK) ON SB2.B2_FILIAL = ZZA.ZZA_FILIAL AND SB2.D_E_L_E_T_ = '' AND SB2.B2_COD = ZZA.ZZA_PRODUT AND SB2.B2_LOCAL = '"+Iif(SubStr(TBAI->ZZA_HELP, 1, 1) $ '1', '02', '20')+"' "
                         cQry4 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
                         cQry4 += "  AND ZZA.D_E_L_E_T_ = '' "
                         cQry4 += "  AND ZZA.ZZA_LOTE = '"+TBAI->ZZA_LOTE+"' "
                         cQry4 += "  AND SUBSTRING(ZZA.ZZA_PRODUT, 11, 2) IN ('00','99') "
                         TCQuery cQry4 ALIAS "TLIT" NEW
                         DbSelectArea("TLIT")
                         If TLIT->ZZA_FLAG $ '5' //Verifica se o PI Tinta foi baixado
                             //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                             //If TBAI->ZZA_RAMPA $ 'S' .OR. !GetMV("MV_XHABZZF")//Alteração para remover rampa do processo14/04/2014 Tiago Lucio/Chaus
                             If TBAI->ZZA_RAMPA $ 'S' .OR. !_lXHABZZF //Alteração para remover rampa do processo14/04/2014 Tiago Lucio/Chaus
                               For nSLT := 1 To Len(aRotBai)
                                   If !aRotBai[nSLT][5] $ TBAI->ZZA_SEQENV
                                      cLocBai := Iif(SubStr(TBAI->ZZA_HELP, 1, 1) $ '1', 'P1', Iif(SubStr(TBAI->ZZA_HELP, 1, 1) $ '2', 'P2', Posicione("SB1", 1, xFilial("SB1")+TBAI->ZZA_PRODUT, "B1_LOCPAD"))) //Iif(SubStr(TBAI->ZZA_HELP, 1, 1) $ '1', '03', '30')
                                      lPodeExecutar := .t.
                                      //Apontamento Total                       // buscar quantidade atualizada do cw_quje 2/10/14
                                      nQUJE := Posicione("SC2", 1, xFilial("SC2")+TBAI->ZZA_ORDEM, "C2_QUJE")
                                      If TBAI->ZZA_FLAG $ '8' .and.  ( TBAI->C2_QUANT < (TBAI->ZZA_QUANT + nQUJE)) // ( TBAI->C2_QUANT < (TBAI->ZZA_QUANT + TBAI->QUJE)) .and. SUBSTR(cLocBai,1,1) <> SUBSTR(TBAI->C2_LOCAL,2,1) //.and. ( TBAI->C2_QUANT < (TBAI->ZZA_QUANT + Posicione("SC2", 1, xFilial("SC2")+TBAI->ZZA_ORDEM, "C2_QUJE"))) //.and. // // ( TBAI->C2_QUANT < (TBAI->ZZA_QUANT + TBAI->QUJE))// .and. SUBSTR(cLocBai,1,1) <> SUBSTR(TBAI->C2_LOCAL,2,1)
                                         //Tem que ajustar o empenho
                                         cQry1 := ""
                                         cQry1 += "SELECT SG1.G1_COMP, SB1.B1_DESC, SG1.G1_TRT, SG1.G1_QUANT, SB2.B2_QATU "
                                         cQry1 += "FROM SG1010 SG1 WITH (NOLOCK) "
                                         cQry1 += "LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON SB1.B1_FILIAL  = SG1.G1_FILIAL AND SB1.B1_COD     = SG1.G1_COMP AND SB1.D_E_L_E_T_ = '' "+U_IsFQProdCusto() /* produto de custeio*/
                                         cQry1 += "LEFT OUTER JOIN SB2010 SB2 WITH (NOLOCK) ON SB2.B2_FILIAL  = SB1.B1_FILIAL AND SB2.B2_COD     = SB1.B1_COD AND SB2.B2_LOCAL   = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = '' "
                                         cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
                                         cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
                                         cQry1 += "  AND G1_COD         = '"+TBAI->ZZA_PRODUT+"' "
                                         cQry1 += "ORDER BY SG1.G1_TRT "
                                         TCQUERY cQry1 ALIAS "TEMA" NEW
                                         DbSelectArea("TEMA")
                                         While !Eof()
                                               // produto de custeio
                                               If U_IsProdCusto(TEMA->G1_COMP)
                                                   TEMA->(dbSkip())
                                                   Loop
                                               Endif    
                                               nQtdOri := TBAI->C2_QUANT * TEMA->G1_QUANT
                                               nQtdAju := (TBAI->ZZA_QUANT + TBAI->C2_QUJE) * TEMA->G1_QUANT
                                               nQtdMaio:= ((TBAI->ZZA_QUANT + nQUJE) - TBAI->C2_QUANT) // identificar produção a maior
                                               nQtdRes := TBAI->ZZA_QUANT * TEMA->G1_QUANT
                                               DbSelectArea("SD4")
                                               DbSetOrder(1)
                                               DbSeek(xFilial("SD4")+TEMA->G1_COMP+Alltrim(TBAI->ZZA_ORDEM)+Space(13 - Len(Alltrim(TBAI->ZZA_ORDEM)))+TEMA->G1_TRT, .t.)
                                               If Found()
                                                  aEmpMov := {}
                                                  If TBAI->C2_QUJE == 0 //Não existe quantidade apontada (Apontamento Parcial)
                                                     If QtdComp(Round(SD4->D4_QUANT, 4)) <> QtdComp(Round(nQtdAju, 4))
                                                        aEmpMov := { {"D4_FILIAL" , xFilial("SD4")                                                          , NIL },;
                                                                     {"D4_OP"     , Alltrim(TBAI->ZZA_ORDEM) + Space(14 - Len( Alltrim(TBAI->ZZA_ORDEM)))   , NIL },;
                                                                     {"D4_COD"    , TEMA->G1_COMP                                                           , NIL },;
                                                                     {"D4_TRT"    , TEMA->G1_TRT                                                            , NIL },;
                                                                     {"D4_QTDEORI", Round(nQtdAju, 4)                                                       , NIL },;
                                                                     {"D4_QUANT"  , Round(nQtdAju, 4)                                                       , NIL } }
                                                     Endif
                                                  ElseIf TBAI->C2_QUJE > 0 //Existe quantidade apontada.
                                                         If QtdComp(Round(SD4->D4_QUANT, 4)) <> QtdComp(Round(nQtdRes, 4))
                                                             aEmpMov := { {"D4_FILIAL" , xFilial("SD4")                                                          , NIL },;
                                                                          {"D4_OP"     , Alltrim(TBAI->ZZA_ORDEM) + Space( 14 - Len(Alltrim(TBAI->ZZA_ORDEM)))   , NIL },;
                                                                          {"D4_COD"    , TEMA->G1_COMP                                                           , NIL },;
                                                                          {"D4_TRT"    , TEMA->G1_TRT                                                            , NIL },;
                                                                          {"D4_QTDEORI", Round(nQtdAju, 4)                                                       , NIL },;
                                                                          {"D4_QUANT"  , Round(nQtdRes, 4)                                                       , NIL } }
                                                         Endif                                                                                   
                                                         //lPodeExecutar := .f.
                                                         //cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - DESENVOLVI', ZZA_CAMPO = 'FALTA DESENVOLVIMENTO.' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                         //XXX := TCSQLExec(cQry1)
                                                  Endif
                                                  If Len(aEmpMov) > 0
                                                     DbSelectArea("SD4")
                                                     lMsErroAuto := .f.
                                                     MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 4)
                                                     If lMsErroAuto
                                                        //Falha na alteração do empenho
      			        		                  		//ConOut(TBAI->ZZA_ORDEM)
      			        		                  		//MostraErro()
                                                        lPodeExecutar := .f.
                                                     Endif
                                                  Endif
                                               Endif
                                               DbSelectArea("TEMA")
                                               DbSkip()
                                         EndDo
                                         DbSelectArea("TEMA")
                                         DbCloseArea()
                                      Endif
                                      If !lPodeExecutar
                                         nSLT := Len(aRotBai)+1
                                         Loop
                                      Endif
                                      PutMv("MV_ESTNEG" , "N")

                                      aOpeBai := {}
                                      aAdd(aOpeBai, {"H6_OP"     , TBAI->ZZA_ORDEM                                   , Nil } )
                                      aAdd(aOpeBai, {"H6_PRODUTO", TBAI->ZZA_PRODUT                                  , Nil } )
                                      aAdd(aOpeBai, {"H6_QTDPROD", Round(TBAI->ZZA_QUANT, 4)                         , Nil } )
                                      aAdd(aOpeBai, {"H6_OPERAC" , aRotBai[nSLT][1]                                  , Nil } )
                                      aAdd(aOpeBai, {"H6_RECURSO", aRotBai[nSLT][2]                                  , Nil } )
                                      aAdd(aOpeBai, {"H6_PT"     , Iif(TBAI->ZZA_TPENVA $ 'C', 'T', TBAI->ZZA_TPENVA), Nil } )
                                      aAdd(aOpeBai, {"H6_OBSERVA", TBAI->ZZA_SEQENV                                  , Nil } )
                                      aAdd(aOpeBai, {"H6_DATAINI", STOD(TBAI->ZZA_DTINI)                             , Nil } )
                                      aAdd(aOpeBai, {"H6_HORAINI", TransForm(TBAI->ZZA_HINI, '@R 99:99')             , Nil } )
                                      aAdd(aOpeBai, {"H6_DATAFIN", STOD(dDatFim)                                     , Nil } )
                                      aAdd(aOpeBai, {"H6_HORAFIN", TransForm(TBAI->ZZA_HFIM, '@R 99:99')             , Nil } )
                                      aAdd(aOpeBai, {"H6_DTAPONT", dDataBase                                         , Nil } )
                                      aAdd(aOpeBai, {"H6_LOCAL"  , cLocBai                                           , Nil } )
                                      
                                      If nQtdMaio > 0
                                          aAdd(aOpeBai, {"H6_QTMAIOR"  , nQtdMaio                                    , Nil } )	
                                      Endif
                                      nQtdMaio :=0	
                                      
                                     
                                      lMsErroAuto := .f.
                                      DbSelectArea("SF5")
                                      MSFILTER('')
                                      DbSelectArea("SF5")
                                      DbSetOrder(1)
                                      DbSelectArea("SH6")
                                      //Apontamento Parcial
                                      If TBAI->ZZA_FLAG $ '7' //Envase Parcial
                                         lNaoBaixou := .f.
                                       	 //If (cLocBai $ '30') .or. (cLocBai $ '03' .and. TBAI->C2_QUJE == 0) //.and. cBxLocP $ 'N'   
                                         If (cLocBai $ '03.30.P1.P2') //.and. TBAI->C2_QUJE == 0 //.and. cBxLocP $ 'N'     
                                          //Verificar e Ajustar empenhos para baixa dessa quantidade.
                                            lNaoExclui := .f.
                                            
                                            /*
                                            If GetMV("MV_XHABZZF")//Alteração 25/02/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                            DbSelectArea("SD4")
	                                            DbSetOrder(7)
	                                            DbSeek(xFilial("SD4")+TBAI->ZZA_ORDEM, .t.)
	                                            If Found()
	                                               //Exclui os empenhos originais e passa a empenhar por OP.+Sequencia na Tabela ZZF devido ao almoxarifado
	                                               While !Eof() .and. Alltrim(SD4->D4_OP) == Alltrim(TBAI->ZZA_ORDEM)
	                                                     aEmpMov := {}
	                                                     aEmpMov := { {"D4_FILIAL" , xFilial("SD4")   , NIL },;
	                                                                  {"D4_OP"     , SD4->D4_OP       , NIL },;
	                                                                  {"D4_COD"    , SD4->D4_COD      , NIL },;
	                                                                  {"D4_LOCAL"  , SD4->D4_LOCAL    , NIL },;
	                                                                  {"D4_TRT"    , SD4->D4_TRT      , NIL } }
	                                                     DbSelectArea("SD4")
	                                                     lMsErroAuto := .f.
	                                                     MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
	                                                     If lMsErroAuto
	                                                        lNaoExclui := .t.
	                                                     Endif
	                                                     DbSelectArea("SD4")
	                                                     DbSetOrder(7)
	                                                     DbSeek(xFilial("SD4")+TBAI->ZZA_ORDEM, .t.)
	                                                     Loop
	                                               EndDo
	                                            Endif
	                                        EndIf //Fim alteração   
                                            */
                                            //Gera empenho para o local correto.
                                            //VERIFICAR SE JÁ EXISTE SD3 PARA ESSA ORDEM PARA A SEQUENCIA DE PRODUÇÃO
                                            If !lNaoExclui
                                               cNumDoc := ""
                                               DbSelectArea("SH6")
                                               DbSetOrder(1)
                                               DbSeek(xFilial("SH6")+TBAI->ZZA_ORDEM, .t.)
                                               If Found()
                                                  While !Eof() .and. Alltrim(SH6->H6_OP) == Alltrim(TBAI->ZZA_ORDEM)
                                                        If Alltrim(SH6->H6_OBSERVA) == Alltrim(TBAI->ZZA_SEQENV)
                                                           cNumDoc := SH6->H6_IDENT
                                                        Endif
                                                        DbSelectArea("SH6")
                                                        DbSkip()
                                                  EndDo
                                               Endif
                                               If Empty(cNumDoc)
                                                  If Empty(TBAI->ZZA_PROSOB)
                                                     DbSelectArea("SG1")
                                                     DbSetOrder(1)
                                                     DbSeek(xFilial("SG1")+TBAI->ZZA_PRODUT, .t.)
                                                     If Found()
                                                        aIteMov := {}
                                                        While !Eof() .and. Alltrim(SG1->G1_COD) == Alltrim(TBAI->ZZA_PRODUT) 
                                                            // produto de custeio
                                                            If U_IsProdCusto(SG1->G1_COMP)
                                                               SG1->(dbSkip())
                                                               Loop
                                                            Endif   

                                                        	  _cTipo   := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_TIPO")
                                                        	  _cLocPad := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_LOCPAD")
                                                              //_cMPInd  := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_APROPRI")
                                                              aAuxMov := {}
                                                              aAuxMov := { {"D3_COD"    , SG1->G1_COMP                                             , NIL},;
                                                                           {"D3_TRT"    , SG1->G1_TRT                                              , NIL},;
                                                                           {"D3_QUANT"  , SG1->G1_QUANT * TBAI->ZZA_QUANT                          , NIL},;
                                                                           {"D3_LOCAL"  , Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','P1',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','P2',_cLocPad)))), NIL},; //Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99'), NIL},;
                                                                           {"D3_UM"     , Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_UM"), NIL},;
                                                                           {"D3_OP"     , TBAI->ZZA_ORDEM , NIL},;
                                                                           {"D3_TURNO"  , "BEP"           , NIL} }
                                                              aAdd(aIteMov, aAuxMov)
                                                              DbSelectArea("SG1")
                                                              DbSkip()
                                                        EndDo
                                                        //Executar a Baixa das MPs.
                                                        lNaoBaixou := .f.
                                                        aCabMov := { {"D3_TM"     , cCodBai      , NIL},;
                                                                     {"D3_EMISSAO", sTod(dDatFim), NIL} }
                                                        lMsErroAuto := .f.
                                                        //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                                                        //If GetMV("MV_XHABZZF")  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
                                                        If _lXHABZZF  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                                        MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 3)
	                                                    EndIf //Fim alteração    
                                                        If lMsErroAuto
                                                           cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                                                           If "MA240NEGAT" $ cStrErr
                                                              cString := MemoRead( NomeAutoLog() )
                                                              cProLoc := ""
                                                              aIteAju := {}
                                                              For nY := 1 To MlCount(cString)
                                                                  If 'D3_COD' $ MemoLine( cString, 80, nY)
                                                                     cVarAux := MemoLine( cString, 80, nY) 
                                                                     _cAuxProd := Alltrim(SubStr(cVarAux, 37, 15))+Space( 15 - Len( Alltrim(SubStr(cVarAux, 37, 15)) ) )   
                                                                     _cLocPad  := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_LOCPAD")
                                                                     _cTipo    := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_TIPO")
                                                                     //_cMPInd   := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_APROPRI")
                                                                     _cLocal   := Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', iif(_cTipo $ 'PA','P2',_cLocPad) ) ) )//Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99')
                                                                     nQtdEst := Posicione("SB2", 1, xFilial("SB2")+_cAuxProd+_cLocal, "B2_QATU")
															         nQtdNec := Posicione("SB1", 1, xFilial("SB1")+TBAI->ZZA_PRODUT, "B1_CONV") * TBAI->ZZA_QUANT
                                                                     If Empty(cProLoc)
                                                                        cProLoc += Alltrim(SubStr(cVarAux, 37, 15))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 9999.99")+')'
                                                                     Else
                                                                        cProLoc += " / "+Alltrim(SubStr(cVarAux, 37, 15))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 9999.99")+')'
                                                                     Endif
                                                                     /*
                                                                     If SubStr(Alltrim(SubStr(cVarAux, 37, 15)), 1, 10) $ SubStr(Alltrim(TBAI->ZZA_PRODUT), 1, 10)
                                                                        If (nQtdEst - nQtdNec) < 0 .and. TLIT->ZZA_QUANT * ( GETMV("MV_TOLBOP") / 100 ) >= Abs( nQtdEst - nQtdNec ) 
                                                                           _cTipo   := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_TIPO")
                                                                           _cLocPad := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_LOCPAD")       
                                                                           //_cMPInd  := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_APROPRI")
                                                                           aAuxMov := {}
                                                                           aAuxMov := { {"D3_COD"    , Alltrim(SubStr(cVarAux, 37, 15))                                , NIL},;
                                                                                        {"D3_QUANT"  , ABS(nQtdEst - nQtdNec)                                          , NIL},;
                                                                                        {"D3_UM"     , Posicione("SB1", 1, xFilial("SB1")+Alltrim(SubStr(cVarAux, 37, 15)), "B1_UM"), NIL},;
                                                                                        {"D3_LOCAL"  , Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', iif(_cTipo $ 'PA','P2',_cLocPad) ) ) ), NIL},; //Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99'), NIL},;
                                                                                        {"D3_OP"     , TBAI->ZZA_ORDEM , NIL},;
                                                                                        {"D3_TURNO"  , "BEP"           , NIL} }

                                                                           aAdd(aIteAju, aAuxMov)
                                                                           aCabMov := { {"D3_TM"     , '110'        , NIL},;
                                                                                        {"D3_EMISSAO", sTod(dDatFim), NIL} }
                                                                           lMsErroAuto := .f. 
                                                                           If GetMV("MV_XHABZZF")  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                                                           MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteAju, 3)
	                                                                       EndIf //Fim alteração    
                                                                           If !lMsErroAuto
                                                                              cProLoc := 'AJUSTADO'+'('+TransForm(nQtdEst - nQtdNec, "@E 999,999.99999")+')'
                                                                           Endif
                                                                        Endif
                                                                     Endif */
                                                                  Endif
                                                              Next
                                                              cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - MA240NEGAT', ZZA_CAMPO = 'EXISTE MATERIAL COM SALDO NEGATIVO: "+SubStr(cProLoc, 1, 44)+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                              XXX := TCSQLExec(cQry1)
                                                              MEMOWRIT(NomeAutoLog(), " ")
                                                              lNaoBaixou := .t.
                                                           Endif
                                                        Else
                                                           cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_PROSOB = '"+SD3->D3_DOC+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                           XXX := TCSQLExec(cQry1)
                                                        Endif
                                                     Endif
                                                  Endif
                                               Endif
                                            Endif
                                         Endif
                                         If !lNaoBaixou
                                            Begin Transaction
                                            PutMv("MV_ESTNEG" , "N")
                                            DbSelectArea("SH6")
                                            lMsErroAuto := .f.
                                            MsExecAuto( {|x, y| Mata681(x, y)}, aOpeBai, 3)   
                                            If !lMsErroAuto
                                                aRotBai[nSLT][5] += "."+TBAI->ZZA_SEQENV //Da baixa da operação na Matriz do Roteiro
                                                cQry1 := ""
                                                If Len(aRotBai) == nSLT
                                                   cQry1 += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - BAIXADA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                Endif
                                                XXX := TCSQLExec(cQry1)
                                            Else
                                               cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                                               If "MA240NEGAT" $ cStrErr
                                                  cString := MemoRead( NomeAutoLog() )
                                                  cProLoc := ""
                                                  aIteAju := {}
                                                  For nY := 1 To MlCount(cString)
                                                      If 'Sem Saldo em ' $ MemoLine( cString, 80, nY)
                                                         cVarAux := MemoLine( cString, 80, nY)    
														 _cAuxProd := Alltrim(SubStr(cVarAux, 1, 21))+Space( 15 - Len( Alltrim(SubStr(cVarAux, 1, 21)) ) )   
                                                       	 _cLocPad  := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_LOCPAD")
                                                    	 _cTipo    := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_TIPO")
                                               			 //_cMPInd   := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_APROPRI")
                                               			 _cLocal := Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', iif(_cTipo $ 'PA','P2',_cLocPad) ) ) )//Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99')
//                                                         nQtdNec := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TBAI->ZZA_PRODUT, 11, 2), "Z5_VOLUME") * TBAI->ZZA_QUANT
                                                         nQtdNec := Posicione("SB1", 1, xFilial("SB1")+TBAI->ZZA_PRODUT, "B1_CONV") * TBAI->ZZA_QUANT
                                                         nQtdEst := Posicione("SB2", 1, xFilial("SB2")+_cAuxProd+_cLocal, "B2_QATU")
                                                         If Empty(cProLoc)
                                                            cProLoc += Alltrim(SubStr(cVarAux, 1, 21))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 9999.99")+')'
                                                         Else
                                                            cProLoc += " / "+Alltrim(SubStr(cVarAux, 1, 21))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 9999.99")+')'
                                                         Endif
                                                         /*
                                                         If SubStr(Alltrim(SubStr(cVarAux, 37, 15)), 1, 10) $ SubStr(Alltrim(TBAI->ZZA_PRODUT), 1, 10)
                                                            If (nQtdEst - nQtdNec) < 0 .and. TLIT->ZZA_QUANT * ( GETMV("MV_TOLBOP") / 100 ) >= Abs( nQtdEst - nQtdNec ) 
                                                               _cTipo   := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_TIPO")
                                                               _cLocPad := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_LOCPAD")
                                                               //_cMPInd  := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_APROPRI")
                                                               aAuxMov := {}
                                                               aAuxMov := { {"D3_COD"    , Alltrim(SubStr(cVarAux, 37, 15))                                , NIL},;
                                                                            {"D3_QUANT"  , ABS(nQtdEst - nQtdNec)                                   , NIL},;
                                                                            {"D3_UM"     , Posicione("SB1", 1, xFilial("SB1")+Alltrim(SubStr(cVarAux, 37, 15)), "B1_UM"), NIL},;
                                                                            {"D3_LOCAL"  , Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', Iif( _cTipo $ 'PA', 'P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', Iif( _cTipo $ 'PA', 'P2',_cLocPad) ) ) ), NIL},;	//Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99'), NIL},;
                                                                            {"D3_OP"     , TBAI->ZZA_ORDEM , NIL},;
                                                                            {"D3_TURNO"  , "BEP"           , NIL} }
                                                               aAdd(aIteAju, aAuxMov)
                                                               aCabMov := { {"D3_TM"     , '110'        , NIL},;
                                                                            {"D3_EMISSAO", sTod(dDatFim), NIL} }
                                                               lMsErroAuto := .f.           
                                                               If GetMV("MV_XHABZZF")  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                                               MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteAju, 3)
	                                                           EndIf  //Fim alteração    
                                                               If !lMsErroAuto
                                                                  cProLoc := 'AJUSTADO'+'('+TransForm(nQtdEst - nQtdNec, "@E 999,999.99999")+')'
                                                               Endif
                                                            Endif
                                                         Endif */
                                                      Endif
                                                  Next
                                                  cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - MA240NEGAT', ZZA_CAMPO = 'EXISTE MATERIAL COM SALDO NEGATIVO: "+SubStr(cProLoc, 1, 44)+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                  XXX := TCSQLExec(cQry1)
                                                  nSLT := Len(aRotBai)
                                                  MEMOWRIT(NomeAutoLog(), " ")
                                               Else
                                                  cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - "+cStrErr+".' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                  XXX := TCSQLExec(cQry1)
                                                  nSLT := Len(aRotBai)
                                                  MEMOWRIT(NomeAutoLog(), " ")
                                               Endif
                                            Endif
										    End Transaction	                                            
                                         Endif
                                      //Apontamento Total
                                      ElseIf TBAI->ZZA_FLAG $ '8' //Envase Total
                                             lNaoBaixou := .f.
                                             If ((cLocBai $ '03.30.P1.P2') ) //.and. TBAI->C2_QUJE == 0 //.and. cBxLocP $ 'N'
                                           //  If cLocBai $ '30' .or. (cLocBai $ '03' .and. TBAI->C2_QUJE == 0) //.and. cBxLocP $ 'N'
                                                //Verificar e Ajustar empenhos para baixa dessa quantidade.
                                                lNaoExclui := .f.
                                                /*
                                                If GetMV("MV_XHABZZF")  //Alteração 25/02/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                                DbSelectArea("SD4")
	                                                DbSetOrder(7)
	                                                DbSeek(xFilial("SD4")+TBAI->ZZA_ORDEM, .t.)
	                                                If Found()
	                                                   //Exclui os empenhos originais e passa a empenhar por OP.+Sequencia na Tabela ZZF devido ao almoxarifado
	                                                   While !Eof() .and. Alltrim(SD4->D4_OP) == Alltrim(TBAI->ZZA_ORDEM)
	                                                         aEmpMov := {}
	                                                         aEmpMov := { {"D4_FILIAL" , xFilial("SD4")   , NIL },;
	                                                                      {"D4_OP"     , SD4->D4_OP       , NIL },;
	                                                                      {"D4_COD"    , SD4->D4_COD      , NIL },;
	                                                                      {"D4_LOCAL"  , SD4->D4_LOCAL    , NIL },;
	                                                                      {"D4_TRT"    , SD4->D4_TRT      , NIL } }
	                                                         DbSelectArea("SD4")
	                                                         lMsErroAuto := .f.
	                                                         MSExecAuto({|x, y| MATA380(x, y)}, aEmpMov, 5)
	                                                         If lMsErroAuto
	                                                            lNaoExclui := .t.
	                                                         Endif
	                                                         DbSelectArea("SD4")
	                                                         DbSetOrder(7)
	                                                         DbSeek(xFilial("SD4")+TBAI->ZZA_ORDEM, .t.)
	                                                         Loop
	                                                   EndDo
	                                                Endif
	                                            EndIf //FIm alteração   
	                                            */
                                                //Gera empenho para o local correto.
                                                //VERIFICAR SE JÁ EXISTE SD3 PARA ESSA ORDEM PARA A SEQUENCIA DE PRODUÇÃO
                                                If !lNaoExclui
                                                   cNumDoc := ""
                                                   DbSelectArea("SH6")
                                                   DbSetOrder(1)
                                                   DbSeek(xFilial("SH6")+TBAI->ZZA_ORDEM, .t.)
                                                   If Found()
                                                      While !Eof() .and. Alltrim(SH6->H6_OP) == Alltrim(TBAI->ZZA_ORDEM)
                                                            If Alltrim(SH6->H6_OBSERVA) == Alltrim(TBAI->ZZA_SEQENV)
                                                               cNumDoc := SH6->H6_IDENT
                                                            Endif
                                                            DbSelectArea("SH6")
                                                            DbSkip()
                                                      EndDo
                                                   Endif
                                                   If Empty(cNumDoc)
                                                      If Empty(TBAI->ZZA_PROSOB)
                                                         //VERIFICAR SE JÁ HOUVE BAIXA PARA ESSA OP+SEQUENCIA.
                                                         DbSelectArea("SG1")
                                                         DbSetOrder(1)
                                                         DbSeek(xFilial("SG1")+TBAI->ZZA_PRODUT, .t.)
                                                         If Found()
                                                            aIteMov := {}
                                                            While !Eof() .and. Alltrim(SG1->G1_COD) == Alltrim(TBAI->ZZA_PRODUT) 
                                                                 // produto de custeio
                                                                 If U_IsProdCusto(SG1->G1_COMP)
                                                                    SG1->(dbSkip())
                                                                    Loop
                                                                 Endif   

                                                            	  _cTipo   := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_TIPO")
                                                            	  _cLocPad := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_LOCPAD")
                                                              	  //_cMPInd  := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_APROPRI")
                                                             	  aAuxMov := { {"D3_COD"    , SG1->G1_COMP                                             , NIL},;
                                                                               {"D3_TRT"    , SG1->G1_TRT                                              , NIL},;
                                                                               {"D3_QUANT"  , SG1->G1_QUANT * TBAI->ZZA_QUANT                          , NIL},;
                                                                               {"D3_LOCAL"  , Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', Iif( _cTipo $ 'PA', 'P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', Iif( _cTipo $ 'PA', 'P2',_cLocPad) ) ) ), NIL},; //Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99'), NIL},;
                                                                               {"D3_UM"     , Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_UM"), NIL},;
                                                                               {"D3_OP"     , TBAI->ZZA_ORDEM , NIL},;
                                                                               {"D3_TURNO"  , "BEP"           , NIL} }
                      
                                                                  aAdd(aIteMov, aAuxMov)
                                                                  DbSelectArea("SG1")
                                                                  DbSkip()
                                                            EndDo
                                                            //Executar a Baixa das MPs.
                                                            lNaoBaixou := .f.
                                                            aCabMov := { {"D3_TM"     , cCodBai      , NIL},;
                                                                         {"D3_EMISSAO", sTod(dDatFim), NIL} }
                                                            lMsErroAuto := .f.           
                                                            //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                                                            //If GetMV("MV_XHABZZF")  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
                                                            If _lXHABZZF  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                                            MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 3)
	                                                        EndIf //Fim alteração    
                                                            If lMsErroAuto
                                                               cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                                                               If "MA240NEGAT" $ cStrErr
                                                                  cString := MemoRead( NomeAutoLog() )
                                                                  cProLoc := ""
                                                                  aIteAju := {}
                                                                  For nY := 1 To MlCount(cString)
                                                                      If 'D3_COD' $  MemoLine( cString, 80, nY)
                                                                         cVarAux  := MemoLine( cString, 80, nY)
                                                                     	 _cAuxProd := Alltrim(SubStr(cVarAux, 37, 15))+Space( 15 - Len( Alltrim(SubStr(cVarAux, 37, 15)) ) )
                                                                     	 _cLocPad  := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_LOCPAD")
                                                                     	 _cTipo    := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_TIPO")
                                                                     	 //_cMPInd   := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_APROPRI")
                                                                     	 _cLocal   := Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', iif(_cTipo $ 'PA','P2',_cLocPad) ) ) ) // Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99')
                                                                         nQtdEst := Posicione("SB2", 1, xFilial("SB2")+_cAuxProd+_cLocal, "B2_QATU")
                                                 			             nQtdNec := Posicione("SB1", 1, xFilial("SB1")+TBAI->ZZA_PRODUT, "B1_CONV") * TBAI->ZZA_QUANT
                                                                         If Empty(cProLoc)
                                                                            cProLoc += Alltrim(SubStr(cVarAux, 37, 15))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 999,999.999")+')'
                                                                         Else
                                                                            cProLoc += " / "+Alltrim(SubStr(cVarAux, 37, 15))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 999,999.999")+')'
                                                                         Endif
                                                                         If SubStr(Alltrim(SubStr(cVarAux, 37, 15)), 1, 10) $ SubStr(Alltrim(TBAI->ZZA_PRODUT), 1, 10)
                                                                            //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                                                                            //If (nQtdEst - nQtdNec) < 0 .and. TLIT->ZZA_QUANT * ( GETMV("MV_TOLBOP") / 100 ) >= Abs( nQtdEst - nQtdNec )  
                                                                            If (nQtdEst - nQtdNec) < 0 .and. TLIT->ZZA_QUANT * ( _nTOLBOP / 100 ) >= Abs( nQtdEst - nQtdNec )
                                                                            	_cTipo   := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_TIPO")
                                                                            	_cLocPad := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_LOCPAD")
                                                                            	//_cMPInd  := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_APROPRI")
                                                                                aAuxMov := {}
                                                                                aAuxMov := { {"D3_COD"    , Alltrim(SubStr(cVarAux, 37, 15))                                , NIL},;
                                                                                            {"D3_QUANT"  , ABS(nQtdEst - nQtdNec)                                   , NIL},;
                                                                                            {"D3_UM"     , Posicione("SB1", 1, xFilial("SB1")+Alltrim(SubStr(cVarAux, 37, 15)), "B1_UM"), NIL},;
                                                                                            {"D3_LOCAL"  , Iif(cLocBai $ '03.P1', iif(_cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', Iif( _cTipo $ 'PA', 'P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', Iif( _cTipo $ 'PA', 'P2',_cLocPad) ) ) ), NIL},; //	Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99'), NIL},;
                                                                                            {"D3_OP"     , TBAI->ZZA_ORDEM , NIL},;
                                                                                            {"D3_TURNO"  , "BEP"           , NIL} }
                                                                               aAdd(aIteAju, aAuxMov)
                                                                               aCabMov := { {"D3_TM"     , '110'        , NIL},;
                                                                                            {"D3_EMISSAO", sTod(dDatFim), NIL} }
                                                                               lMsErroAuto := .f.           
                                                                               //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                                                                               //If GetMV("MV_XHABZZF")  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
                                                                               If _lXHABZZF  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                                                               MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteAju, 3)                                             		
	                                                                           EndIf   //Fim alteração    
                                                                               If !lMsErroAuto
                                                                                  cProLoc := 'AJUSTADO'+'('+TransForm(nQtdEst - nQtdNec, "@E 999,999.9999")+')'
                                                                               Endif
                                                                            Endif
                                                                         Endif
                                                                      Endif
                                                                  Next
                                                                  cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - MA240NEGAT', ZZA_CAMPO = 'EXISTE MATERIAL COM SALDO NEGATIVO: "+SubStr(cProLoc, 1, 44)+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                                  XXX := TCSQLExec(cQry1)
                                                                  MEMOWRIT(NomeAutoLog(), " ")
                                                                  lNaoBaixou := .t.
                                                               Endif
                                                            Else
                                                               cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_PROSOB = '"+SD3->D3_DOC+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                               XXX := TCSQLExec(cQry1)
                                                            Endif
                                                         Endif
                                                      Endif
                                                   Endif
                                                Endif
                                             Endif
                                             If !lNaoBaixou
                                                 lFalBai := .f.
                                                 cQry1 := ""
                                                 cQry1 += "SELECT ZZA.ZZA_FLAG, SUM(ZZA.ZZA_QUANT) AS ZZA_QUANT, SC2.C2_QUJE, SC2.C2_DATRF "
                                                 cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH (NOLOCK) "
                                                 cQry1 += "LEFT OUTER JOIN SC2"+cEmp+"0 SC2 ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = '' "
                                                 cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
                                                 cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                                                 cQry1 += "  AND ZZA.ZZA_ORDEM  = '"+TBAI->ZZA_ORDEM+"' "
                                                 cQry1 += "GROUP BY ZZA.ZZA_FLAG, SC2.C2_QUJE, SC2.C2_DATRF "
                                                 cQry1 += "ORDER BY ZZA.ZZA_FLAG "
                                                 TCQuery cQry1 ALIAS "TMPFEC" NEW
                                                 DbSelectArea("TMPFEC")
                                                 While !Eof()
                                                       If !TMPFEC->ZZA_FLAG $ '5.8'
                                                          lFalBai := .t.
                                                       Endif
                                                       DbSelectArea("TMPFEC")
                                                       DbSkip()
                                                 EndDo
                                                 DbSelectArea("TMPFEC")
                                                 DbCloseArea()
                                                 If !lFalBai
                                                    Begin Transaction
                                                    PutMv("MV_ESTNEG" , "N")
                                                    DbSelectArea("SH6")
                                                    lMsErroAuto := .f.
                                                    MsExecAuto( {|x, y| Mata681(x, y)}, aOpeBai, 3)
                                                    If !lMsErroAuto
                                                       aRotBai[nSLT][5] += "."+TBAI->ZZA_SEQENV //Da baixa da operação na Matriz do Roteiro
                                                       cQry1 := ""
                                                       If Len(aRotBai) == nSLT
                                                          cQry1 += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - BAIXADA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                       Endif
                                                       XXX := TCSQLExec(cQry1)
                                                    Else
                                                       cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                                                       If "MA240NEGAT" $ cStrErr
                                                          cString := MemoRead( NomeAutoLog() )
                                                          cProLoc := ""
                                                          aIteAju := {}
                                                          For nY := 1 To MlCount(cString)
                                                              If 'Sem Saldo em ' $ MemoLine( cString, 80, nY)
                                                                 cVarAux := MemoLine( cString, 80, nY)
                                                                 _cAuxProd := Alltrim(SubStr(cVarAux, 1, 21))+Space( 15 - Len( Alltrim(SubStr(cVarAux, 1, 21)) ) )
                                                                 _cLocPad  := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_LOCPAD")
                                                                 _cTipo    := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_TIPO")
                                                                 //_cMPInd   := Posicione("SB1", 1, xFilial("SB1")+_cAuxProd, "B1_APROPRI")
                                                                 _cLocal := Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','P1',_cLocPad) ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', iif(_cTipo $ 'PA','P2',_cLocPad) ) ) )//Iif(! _cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99')	
                                                                 nQtdEst := Posicione("SB2", 1, xFilial("SB2")+_cAuxProd+_cLocal, "B2_QATU")
                                                                 //nQtdNec := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TBAI->ZZA_PRODUT, 11, 2), "Z5_VOLUME") * TBAI->ZZA_QUANT
                                                                 nQtdNec := Posicione("SB1", 1, xFilial("SB1")+TBAI->ZZA_PRODUT, "B1_CONV") * TBAI->ZZA_QUANT

                                                                 If Empty(cProLoc)
                                                                    cProLoc += Alltrim(SubStr(cVarAux, 1, 21))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 999,999.999")+')'
                                                                 Else
                                                                    cProLoc += " / "+Alltrim(SubStr(cVarAux, 1, 21))+'-'+_cLocal+'('+TransForm(nQtdEst - nQtdNec, "@E 9999.99")+')'
                                                                 Endif
                                                                 If SubStr(Alltrim(SubStr(cVarAux, 37, 15)), 1, 10) $ SubStr(Alltrim(TBAI->ZZA_PRODUT), 1, 10)
                                                                    //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                                                                    //If (nQtdEst - nQtdNec) < 0 .and. TLIT->ZZA_QUANT * ( GETMV("MV_TOLBOP") / 100 ) >= Abs( nQtdEst - nQtdNec )
                                                                    If (nQtdEst - nQtdNec) < 0 .and. TLIT->ZZA_QUANT * ( _nTOLBOP / 100 ) >= Abs( nQtdEst - nQtdNec )
                                                                    	_cTipo   := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_TIPO")
                                                                    	_cLocPad := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_LOCPAD")
                                                                    	//_cMPInd  := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_APROPRI")
                                                                        aAuxMov := {}
                                                                        aAuxMov := {{"D3_COD"    , Alltrim(SubStr(cVarAux, 37, 15))                                , NIL},;
                                                                                    {"D3_QUANT"  , ABS(nQtdEst - nQtdNec)                                   , NIL},;
                                                                                    {"D3_UM"     , Posicione("SB1", 1, xFilial("SB1")+Alltrim(SubStr(cVarAux, 37, 15)), "B1_UM"), NIL},;
                                                                                    {"D3_LOCAL"  , Iif(cLocBai $ '03.P1', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', Iif( _cTipo $ 'PA', 'P1',_cLocPad)  ) ), Iif( _cTipo $ 'MP', '10', Iif( _cTipo $ 'PI', '20', Iif( _cTipo $ 'PA', 'P2',_cLocPad) ) ) ), NIL},; //Iif(!_cMPInd $ 'I', Iif(cLocBai $ '03', Iif( _cTipo $ 'MP', '01', Iif( _cTipo $ 'PI', '02', iif(_cTipo $ 'PA','03',_cLocPad))), Iif( _cTipo $ 'MP', '10', iif(_cTipo $ 'PI', '20', iif(_cTipo $ 'PA','30',_cLocPad)))), '99'), NIL},;	
                                                                                    {"D3_OP"     , TBAI->ZZA_ORDEM , NIL},;
                                                                                    {"D3_TURNO"  , "BEP"           , NIL} }
                                                                       aAdd(aIteAju, aAuxMov)
                                                                       aCabMov := { {"D3_TM"     , '110'        , NIL},;
                                                                                    {"D3_EMISSAO", sTod(dDatFim), NIL} }
                                                                       lMsErroAuto := .f. 
                                                                       //LGS#20200217 - Adequação de release 12.1.25 e posteriores
                                                                       //If GetMV("MV_XHABZZF")  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
                                                                       If _lXHABZZF  //Alteração 15/04/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                                                       MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteAju, 3)
	                                                                   EndIf //Fim alteração    
                                                                       If !lMsErroAuto
                                                                          cProLoc := 'AJUSTADO'+'('+TransForm(nQtdEst - nQtdNec, "@E 999,999.99999")+')'
                                                                       Endif
                                                                    Endif
                                                                 Endif                                                                 
                                                              Endif
                                                          Next
                                                          cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - MA240NEGAT', ZZA_CAMPO = 'EXISTE MATERIAL COM SALDO NEGATIVO: "+SubStr(cProLoc, 1, 44)+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                          XXX := TCSQLExec(cQry1)
                                                          nSLT := Len(aRotBai)
                                                          MEMOWRIT(NomeAutoLog(), " ")
                                                       ElseIf "MA250PERDA" $ cStrErr
                                                              cString := MemoRead( NomeAutoLog() )
                                                              cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - MA250PERDA', ZZA_CAMPO = 'APONTAMENTO MAIOR DO QUE A QTDE. DA O.P.' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                              XXX := TCSQLExec(cQry1)
                                                              nSLT := Len(aRotBai)
                                                              MEMOWRIT(NomeAutoLog(), " ")
                                                       Else
                                                          cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - "+cStrErr+".' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                          XXX := TCSQLExec(cQry1)
                                                          nSLT := Len(aRotBai)
                                                          MEMOWRIT(NomeAutoLog(), " ")
                                                       Endif
                                                    Endif
                                                    End Transaction
                                                 Else
                                                    cQry1 := ""
                                                    cQry1 += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - FALTA_OBX', ZZA_CAMPO = 'FALTA BAIXA DE OPS PARCIAIS' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                    XXX := TCSQLExec(cQry1)
                                                 Endif
                                             Endif
                                      ElseIf TBAI->ZZA_FLAG $ '9' //EXCLUSÃO
                                             lExclui := .t.
                                             cQry1 := ""
                                             cQry1 += "SELECT * "
                                             cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH (NOLOCK) "
                                             cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
                                             cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                                             cQry1 += "  AND ZZA.ZZA_LOTE  = '"+TBAI->ZZA_LOTE+"' "
                                             TCQuery cQry1 ALIAS "TENC" NEW
                                             DbSelectArea("TENC")
                                             DbGoTop()
                                             While !Eof()
                                                   If !TENC->ZZA_FLAG $ '5.9' .and. TENC->ZZA_ORDEM+TENC->ZZA_SEQENV <> TBAI->ZZA_ORDEM+TBAI->ZZA_SEQENV
                                                      lExclui := .F.
                                                   Endif
                                                   DbSelectArea("TENC")
                                                   DbSkip()
                                             Enddo
                                             DbSelectArea("TENC")
                                             DbCloseArea()
                                             If lExclui
                                                cQry1 := ""
                                                cQry1 += "SELECT COUNT(*) as NQTDREG "
                                                cQry1 += "FROM SC2"+cEmp+"0 SC2 "
                                                cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                                                cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                                                cQry1 += "  AND SC2.C2_OP      = '"+TBAI->ZZA_ORDEM+"' "
                                                TCQuery cQry1 ALIAS "TEXC" NEW
                                                DbSelectArea("TEXC")
                                                nQtdExc := TEXC->NQTDREG
                                                DbSelectArea("TEXC")
                                                DbCloseArea()
                                                If nQtdExc > 0
                                                   lMsErroAuto := .f.
                                                   aAutoSC2 := {}
                                                   aAdd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
                                                   aAdd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                                                   aAdd(aAutoSC2, {"C2_NUM"    , SubStr(TBAI->ZZA_ORDEM, 1, 6)  , NIL})
                                                   aAdd(aAutoSC2, {"C2_PRODUTO", TBAI->ZZA_PRODUT               , NIL})
                                                   DbSelectArea("SC2")
                                                   MSExecAuto({|x, y| MATA650(x, y)}, aAutoSC2, 5)    //SigaAuto de Exclusão da O.P.
                                                   If !lMsErroAuto
                                                      cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - EXCLUIDA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                      XXX := TCSQLExec(cQry1)
                                                   Else
                                                      cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - NÃO EXCLUIDA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                      XXX := TCSQLExec(cQry1)
                                                   Endif
                                                Endif
                                             Endif
                                      ElseIf TBAI->ZZA_FLAG $ 'E' //ENCERRADA
                                             lEncerra := .t.
                                             cQry1 := ""
                                             cQry1 += "SELECT * "
                                             cQry1 += "FROM ZZA"+cEmp+"0 ZZA WITH (NOLOCK) "
                                             cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
                                             cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
                                             cQry1 += "  AND ZZA.ZZA_ORDEM  = '"+TBAI->ZZA_ORDEM+"' "
                                             TCQuery cQry1 ALIAS "TENC" NEW
                                             DbSelectArea("TENC")
                                             DbGoTop()
                                             While !Eof()
                                                   If !TENC->ZZA_FLAG $ '5' .and. TENC->ZZA_SEQENV <> TBAI->ZZA_SEQENV
                                                      lEncerra := .f.
                                                   Endif
                                                   DbSelectArea("TENC")
                                                   DbSkip()
                                             Enddo
                                             DbSelectArea("TENC")
                                             DbCloseArea()
                                             If lEncerra
                                                cQry1 := ""
                                                cQry1 += "SELECT * "
                                                cQry1 += "FROM SC2"+cEmp+"0 SC2 "
                                                cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                                                cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                                                cQry1 += "  AND SC2.C2_OP      = '"+TBAI->ZZA_ORDEM+"' "
                                                TCQuery cQry1 ALIAS "TFEC" NEW
                                                If Empty(TFEC->C2_DATRF)
                                                   cQry1 := ""
                                                   cQry1 += "SELECT MAX(SH6.H6_OBSERVA) AS H6_OBSERVA, SD3.D3_DOC, SD3.D3_NUMSEQ "
                                                   cQry1 += "FROM SH6"+cEmp+"0 SH6 WITH (NOLOCK) "
                                                   cQry1 += "LEFT OUTER JOIN SD3"+cEmp+"0 SD3 WITH (NOLOCK) ON SD3.D3_FILIAL = SH6.H6_FILIAL AND SD3.D3_OP = SH6.H6_OP AND SD3.D3_IDENT = SH6.H6_IDENT AND SD3.D_E_L_E_T_ = '' ""
                                                   cQry1 += "WHERE SH6.H6_FILIAL  = '"+xFilial("SH6")+"' ""
                                                   cQry1 += "  AND SH6.D_E_L_E_T_ = '' ""
                                                   cQry1 += "  AND SH6.H6_OP      = '"+TBAI->ZZA_ORDEM+"' "
                                                   cQry1 += "  AND SD3.D3_TM      = '010' "
                                                   cQry1 += "GROUP BY SD3.D3_DOC, SD3.D3_NUMSEQ "
                                                   cQry1 += "ORDER BY 1 DESC "
                                                   TCQuery cQry1 ALIAS "TENC" NEW
                                                   DbSelectArea("TENC")
                                                   DbGoTop()

                                                   DbSelectArea("SD3")
                                                   DbSetOrder(8)
                                                   DbSeek(xFilial("SD3")+TENC->D3_DOC+TENC->D3_NUMSEQ, .t.)
                                                   If Found()
                                                      nRecSD3 := TENC->D3_NUMSEQ
                                                      a250End(.t.)
                                                   Endif
                                                   cQry1 := ""
                                                   cQry1 += "SELECT C2_DATRF "
                                                   cQry1 += "FROM SC2"+cEmp+"0 SC2 WITH (NOLOCK) "
                                                   cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                                                   cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
                                                   cQry1 += "  AND SC2.C2_OP      = '"+TBAI->ZZA_ORDEM+"' "
                                                   TCQuery cQry1 ALIAS "TFEX" NEW
                                                   dbselectarea("TFEX")
                                                   If !eof() .and. !bof() .and. !Empty(TFEX->C2_DATRF)
                                                      cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - ENCERRADA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                      XXX := TCSQLExec(cQry1)
                                                   Endif
                                                   DbSelectArea("TFEC")
                                                   DbCloseArea()
                                                   DbSelectArea("TFEX")
                                                   DbCloseArea()
                                                   DbSelectArea("TENC")
                                                   DbCloseArea()
                                                Else
                                                   cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - ENCERRADA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                   XXX := TCSQLExec(cQry1)
                                                   DbSelectArea("TFEC")
                                                   DbCloseArea()
                                                Endif
                                             Endif
                                      Endif
                                   Else
                                      If Len(aRotBai) == nSLT
                                         cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - BAIXADA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                      Else
                                         cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - AVS_OPERACAO', ZZA_CAMPO = 'OPERACAO "+aRotBai[nSLT][1]+" BAIXADA "+NomeAutoLog()+".' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                      Endif
                                      XXX := TCSQLExec(cQry1)
                                   Endif
                               Next
                            Else
                               cQry1 := ""
                               cQry1 += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - FALTA_RAM', ZZA_CAMPO = 'FALTA BAIXA DE RAMPA' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                               XXX := TCSQLExec(cQry1)
                            Endif
                         Else
                            cQry1 := ""
                            cQry1 += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - FALTA_BPI', ZZA_CAMPO = 'FALTA BAIXA DO P.I.' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                            XXX := TCSQLExec(cQry1)
                         Endif
                         DbSelectArea("TLIT")
                         If ChkFile("TLIT")
                            DbCloseArea()
                         Endif
                      Else
                         //Grava conteudo para ZZA_CAMPO
                         cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - SEM_ROTEI', ZZA_CAMPO = 'ORDEM DE PRODUÇÃO SEM ROTEIRO' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                         XXX := TCSQLExec(cQry1)
                      Endif
                   Else
                      //Grava conteudo para ZZA_CAMPO
                      If TBAI->C2_DATRF $ 'SC2'
                         cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - ORDEM DE PRODUCAO BAIXADA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                      Else
                         cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - ORDEM DE PRODUCAO EXCLUIDA', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                      Endif
                      XXX := TCSQLExec(cQry1)
                   Endif
                   DbSelectArea("TBAI")
                   DbSkip()
             EndDo
             DbSelectArea("TBAI")
             DbCloseArea()
             //PutMv("MV_BXMANEW", "")
             lEndThread := .t.
          Else
             cAuxQbr := cFlaBai
             cQbr1Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
             cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
             cQbr2Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
             cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
             cQbr3Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
             cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
             cQbr4Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1)  )
             cMsgTel := "O sistema de baixa já está sendo rodado pelo usuário: "+cQbr2Tx+", desde às: "+cQbr3Tx+" do dia "+cQbr4Tx+"."
             If nOpc $ '1'
                //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                //ConOut(cMsgTel)
                FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', cMsgTel, 0 )
             Else
                MsgStop(cMsgTel)
             Endif
             If MsDate() - ctod(cQbr4Tx) > 0
                //PutMv("MV_BXMANEW", "")
             Else
                If Hrs2Min( time() ) - Hrs2Min( SubStr( cFlaBai, 2 + At( "|", SubStr( cFlaBai, 3) ) + 1 ) ) >= 60 .or. Hrs2Min( time() ) - Hrs2Min( SubStr( cFlaBai, 2 + At( "|", SubStr( cFlaBai, 3) ) + 1 ) ) < 0
                   //PutMv("MV_BXMANEW", "")
                Endif
             Endif
             lEndThread := .t.
          Endif
       Else
          If nOpc $ '1'
             //LGS#20200212 - Adequação de release 12.1.25 e posteriores
             //ConOut("Data do fechamento de O.P. está menor ou igual ao fechamento do sistema.")
             _cAuxMens    := "Data do fechamento de O.P. está menor ou igual ao fechamento do sistema."
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', _cAuxMens, 0 )
          Else
             MsgStop("Data do fechamento de O.P. está menor ou igual ao fechamento do sistema.", "Atenção")
          Endif
          lEndThread := .t.
       Endif
    /*
	DbSelectArea(_cAreaBloq)
	DbCloseArea()
	FErase(cArqBloq)           
    */   
Return(Nil)

/**************************************************************************************/
/*** SCH014_2 - Exibi a mensagem de erro na tela do server.                         ***/
/**************************************************************************************/
/*Static Function SCH014_2(e)
       Local cMessage := If( Empty(e:osCode), If(e:Severity > ES_WARNING, "Error ", "Warning "), "DOS Error "+nTrim(e:osCode)+" )" )
       cMessage += If( ValType(e:SubSystem) == "C", e:SubSystem, "???")
       If ValType(e:Description) == "C"
          cMessage += " "+e:Description
       Endif
       cMessage += If( !Empty(e:FileName), ": "+e:FileName, If( !Empty(e:Operation), ": "+e:Operation, "") )
Return(cMessage)*/

/**************************************************************************************/
/*** SCH014_1 - Tratamento dos erros ocorridos.                                     ***/
/**************************************************************************************/
/*Static Function SCH014_1(e, nOpc)
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
                 If nOpc == '1'
                    ConOut("   *** Alias does not exist "+e:Operation)
                 Else
                    MsgStop("   *** Alias does not exist "+e:Operation, "Atenção...")
                 Endif
                 Return
          Endif
       Endif
       If nOpc == '1'
          ConOut("   ***"+SCH014_2(e)) //Exibe a mensagem de erro na tela do server
       Else
          MsgStop("   ***"+SCH014_2(e))
       Endif
       If nOpc $ '1'
          __QUIT()
       Else
          lEndThread := .t.
       Endif
Return(Nil)*/
