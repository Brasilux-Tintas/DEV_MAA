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
±±ºPrograma  ³ BRSCH013 ºAutor  ³ Luís G. de Souza   º Data ³  01/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baixa de Ordens de produção por processo - Nova Versão     º±±
±±º          ³ para baixa de Ops através da tabela ZZA.                   º±±
±±º          ³             PROCESSO DE FINALIZAÇÃO DE LABORATORIO         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSCH013( _aParm )

     //Local a_cFil       := {"010101","060101"}
     //Local aParm        := Iif(ValType(aParm) == 'U', {"01",a_cFil , "2"}, aParm)
     Local aParm        := Iif( ValType( _aParm) == 'U', {"01", cFilAnt, "2"}, _aParm )
     Local cEmp         := Alltrim(Transform(aParm[1],'@!'))
     Local cFil         := Alltrim(Transform(aParm[2],'@!'))
     Local nOpc         := Alltrim(Transform(aParm[3],'@!')) 
     Private lEndThread
     
     //LGS#20200212 - Adequação de release 12.1.25 e posteriores
     //ConOut("**********************************")
     //ConOut("*  BRSCH013 - BAIXA DE PRODUÇÃO  *")
     //ConOut("**********************************")
     FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "*  BRSCH013 - BAIXA DE PRODUÇÃO  *", 0 )
     //RPCSetType(3)  // Nao utilizar licenca  Retirado pois causa erro ao rodar manual e trocar de móudlo 16/10/13
     bErro := {|e| SCH013_1(e, nOpc)} //Tratamento dos erros cometidos
     lEndThread := .f.
     RpcMyErro()
     ErrorBlock(bErro)
     If nOpc == '1'
		//For i:= 1 to Len(a_cFil) 
        	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SB1", "SC2", "SD3", "SD4", "SH6", "ZZA", "SG2"
    		//PREPARE ENVIRONMENT EMPRESA cEmp FILIAL a_cFil[i] TABLES "SB1", "SC2", "SD3", "SD4", "SH6", "SG2"
	         	//LGS#20200212 - Adequação de release 12.1.25 e posteriores
	         	//ConOut("-- INICIO ")
	         	FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "-- INICIO ", 0 )
			        U_SCH013_3(nOpc, cEmp, cFil) //Faz o processamento das gerações das ordens de produção
	        	//LGS#20200212 - Adequação de release 12.1.25 e posteriores
	        	//ConOut("-- FIM ")
	        	FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "-- FIM ", 0 )
	    	RESET ENVIRONMENT
	     //Next i
     Else
	     Processa( { |lEnd| U_SCH013_3(nOpc, cEmp, cFil ) }, "Baixa de O.P.s - P.I.s", ,.t.) //Faz o processamento das baixas das ordens de produção
     Endif
Return(Nil)

/**************************************************************************************/
/*** SCH013_3 - Faz o processamento de baixa das materias primas.                   ***/
/**************************************************************************************/
User Function SCH013_3(nOpc, cEmp, cFil)
       //Local dDatFin    := ""
       //Local cCodBai    := ""
       //Local cBaiPro    := ""
       //Local dUltFec    := ""
       Local cFlaBai    := ""
       //Local cTipExe    := ""
       //Local cBxLocP    := "" //Parâmetro desativado - 22/06/2011
       Local cArqBloq,aBloq,cAux,_cAreaBloq
       Local nY, nSLT
       Local _dMVULMES  := GETMV("MV_ULMES")
       Local _lMVHABZZF := GetMV("MV_XHABZZF",.F.,.F.)
       Local dDatFin := GETMV('MV_BXOPFEC')     //Data Final para baixa de Ordens de produção
       //Local cCodBai := GETMV('MV_CBAIREQ')     //Código do movimento para as baixas
       //Local cBaiPro := GETMV('MV_BXPROP')      //Baixa proporcional a O.P.
       Local dUltFec := dTos(GETMV('MV_ULMES')) //Ultimo fechamento
       //Local cTipExe := GETMV("MV_PROCEXE")
       //Local cBxLocP := GETMV("MV_BXLOCPD")     //Local para Baixa das Ordens de produção.
       Private lDelOPSC := .t.
       Private lPerdInf := .t.
       Private lProdAut := .f.

//Bloquear função para acesso exclusivo
cArqBloq := "BRSCH013"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
if aBloq[1,1] //Já estava bloqueado?
	cAux := "O programa SCH013_3 já está sendo executado pelo usuario -> "+aBloq[1,2]
	If nOpc $ '1'
		FwLogMSG( "WARN", , 'SIGAPCP', funname(), '', '01', cAux, 0 )
	Else
		Messagebox(cAux,"Atenção!",48) 	
	Endif
	Return(Nil)
endif 	
_cAreaBloq := aBloq[1,4]

       //LGS#20200212 - Adequação de release 12.1.25 e posteriores
       //Inibi essa função e passei os parâmetros para variáveis local
       //u_fBusPar(@dDatFin, @cCodBai, @cBaiPro, @dUltFec, @cFlaBai, @cTipExe, nOpc, @cBxLocP)
         
       If sTod(dDatFin) > sTod(dUltFec)
          If Empty(cFlaBai)
             //PutMv("MV_BXMANEW", "N"+"|"+Alltrim(Iif(nOpc == "1", "SCHEDULE", cUserName))+"|"+Time()+"|"+Dtoc(MsDate()) )
             PutMv("MV_BXPROP" , "N")
			 PutMv("MV_ESTNEG" , "N")   
			 
 			 cQry2 := "SELECT COUNT(ZZA.ZZA_ORDEM) AS NQTDREG FROM ZZA"+cEmp+"0 ZZA WITH (NOLOCK) " +;
             "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "+;
             "  AND ZZA.D_E_L_E_T_ = '' "+;
             "  AND ZZA.ZZA_FLAG  IN ('4') "+;
             "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "

             TCQuery cQry2 ALIAS "TBAI" NEW
             DbSelectArea("TBAI")                                         
             nQtdRec := TBAI->NQTDREG                                                      
             DbSelectArea("TBAI")
             DbCloseArea()
             If nOpc == "2"
                ProcRegua(nQtdRec)
             Endif

			cQry1 := "SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE, ZZA.ZZA_PRODUT, ZZA.ZZA_QUANT, ZZA.ZZA_DTINI, ZZA.ZZA_HINI, ZZA.ZZA_DTFIM, "+;
			"ZZA.ZZA_HFIM, ZZA.ZZA_HELP, COUNT(ZZF.ZZF_ORDEM) AS QTDZZF, ZZA.R_E_C_N_O_, SC2.C2_QUANT, SC2.C2_ROTEIRO, SC2.C2_LOCAL " +;
			"FROM ZZA"+cEmp+"0 ZZA WITH (NOLOCK) "+;
			"LEFT OUTER JOIN ZZF"+cEmp+"0 ZZF WITH (NOLOCK) ON ZZF.ZZF_FILIAL = ZZA.ZZA_FILIAL AND ZZF.ZZF_ORDEM = ZZA.ZZA_ORDEM AND ZZF.D_E_L_E_T_ = '' AND ZZF.ZZF_FLAG = '2' "+;
            "LEFT OUTER JOIN SC2"+cEmp+"0 SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = '' "+;
            "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "+;
            "  AND ZZA.D_E_L_E_T_ = '' "+;
            "  AND ZZA.ZZA_FLAG  IN ('4') "+;
            "  AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "+;
            "GROUP BY ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE, ZZA.ZZA_PRODUT, ZZA.ZZA_QUANT, ZZA.ZZA_DTINI, ZZA.ZZA_HINI, "+;
			"ZZA.ZZA_DTFIM, ZZA.ZZA_HFIM, ZZA.ZZA_HELP, ZZA.R_E_C_N_O_, SC2.C2_QUANT, SC2.C2_ROTEIRO, SC2.C2_LOCAL "+;	
   			"ORDER BY QTDZZF,ZZA_DTINI,ZZA_HINI " //10, 5, 6

             TCQuery cQry1 ALIAS "TBAI" NEW
             DbSelectArea("TBAI")
             While !Eof()
                   If nOpc == "2"
                      IncProc("Processando Laboratório... "+TBAI->ZZA_ORDEM)
                   Endif
                   //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                   //ConOut("Processando Laboratório... "+TBAI->ZZA_ORDEM)
                   FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Processando Laboratório... "+TBAI->ZZA_ORDEM, 0 )
                   //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                   //If STOD(TBAI->ZZA_DTFIM) <= GETMV("MV_ULMES")
                   If STOD(TBAI->ZZA_DTFIM) <= _dMVULMES
                      //dDatFim := DTOS(GETMV("MV_ULMES") + 1)
                      dDatFim := DTOS( _dMVULMES + 1 )
                   Else
                      dDatFim := TBAI->ZZA_DTFIM
                   Endif
                   If TBAI->QTDZZF == 0  //Quantidade de materias primas que foram baixadas. Se maior que zero tem quantidade pendente.
                      aRotBai := {}
                      u_fBusRot( @aRotBai, TBAI->ZZA_ORDEM, TBAI->ZZA_PRODUT, TBAI->C2_ROTEIRO )
                      If Len(aRotBai) > 0 //Verifica se o produto possui roteiro de operações cadastrado
                         nQtdOri := Round(TBAI->C2_QUANT , 4)
                         nQtdBai := Round(TBAI->ZZA_QUANT, 4)
                         cLocBai := Iif(SubStr(TBAI->ZZA_HELP, 1, 1) $ '1', '02', '20') //Iif(cBxLocP $ 'S', TBAI->C2_LOCAL, Iif(SubStr(TBAI->ZZA_HELP, 1, 1) $ '2', StrZero( Val(TBAI->C2_LOCAL) * 10, 2), TBAI->C2_LOCAL) ) 22/06/2011
                         nQtdJaB := 0
                         lJaBaix := .f.
                         If nQtdBai > 0
                            For nSLT := 1 To Len(aRotBai)
                                If Empty(aRotBai[nSLT][4]) //Se o conteudo for diferente de branco significa que a operação já foi baixada.
                                   aOpeBai := {}
                                   aAdd(aOpeBai, {"H6_OP"     , TBAI->ZZA_ORDEM                         , Nil } )
                                   aAdd(aOpeBai, {"H6_PRODUTO", TBAI->ZZA_PRODUT                        , Nil } )
                                   aAdd(aOpeBai, {"H6_QTDPROD", Round(nQtdBai, 4)                       , Nil } )
                                   aAdd(aOpeBai, {"H6_OPERAC" , aRotBai[nSLT][1]                        , Nil } )
                                   aAdd(aOpeBai, {"H6_RECURSO", aRotBai[nSLT][2]                        , Nil } )
                                   aAdd(aOpeBai, {"H6_DATAINI", STOD(TBAI->ZZA_DTINI)                   , Nil } )
                                   aAdd(aOpeBai, {"H6_HORAINI", TransForm(TBAI->ZZA_HINI, '@R 99:99')   , Nil } )
                                   aAdd(aOpeBai, {"H6_DATAFIN", STOD(dDatFim)                           , Nil } )
                                   aAdd(aOpeBai, {"H6_HORAFIN", TransForm(TBAI->ZZA_HFIM, '@R 99:99')   , Nil } )
                                   aAdd(aOpeBai, {"H6_DTAPONT", dDataBase                               , Nil } )
                                   aAdd(aOpeBai, {"H6_LOCAL"  , cLocBai                                 , Nil } )

                                   If cLocBai $ '20' //.and. cBxLocP $ 'N'
                                      xxx := 1
                                   Endif
                                   lMsErroAuto := .f.
                                   //Verifica se existe retenção e baixa a mesma independente da baixa da OP, para não proporcionalizar a quantidade
                                   If Len(Alltrim(TBAI->ZZA_PRODUT)) == 12 //Produtos do tipo tinta
                                      //Busca retenção na linha
                                      cQry1 := "SELECT SZ1.* FROM "+RetSqlName("SZ1")+" SZ1 WHERE (SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"') AND SZ1.D_E_L_E_T_ = '' AND SZ1.Z1_LINHA = '"+SubStr(TBAI->ZZA_PRODUT, 4, 2)+"' "
                                      TCQuery cQry1 ALIAS "RET" NEW
                                      DbSelectArea("RET")
                                      cProRet := RET->Z1_PRODRET
                                      DbSelectArea("RET")
                                      DbCloseArea()

                                      If !Empty(cProRet)
                                         cQry1 := "SELECT D4_COD,D4_TRT,D4_QUANT,B1_TIPO,B1_UM FROM SD4"+cEmp+"0 SD4 LEFT OUTER JOIN SB1010 SB1 ON SB1.B1_FILIAL = SD4.D4_FILIAL AND SB1.B1_COD = SD4.D4_COD AND SB1.D_E_L_E_T_ = '' WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' AND SD4.D4_OP = '"+TBAI->ZZA_ORDEM+"' AND SD4.D_E_L_E_T_ = '' AND SD4.D4_COD = '"+cProRet+"' AND SD4.D4_QUANT > 0 "
                                         TCQuery cQry1 ALIAS "RET" NEW
                                         DbSelectArea("RET")
                                         aIteMov := {} 
                                      //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                                      //iF GetMV("MV_XHABZZF",.F.,.F.)//Alteração 25/02/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
                                      iF _lMVHABZZF //Alteração 25/02/2014 Tiago Lucio/Chaus - Inclusão de MV para habilitar regra ZZF
	                                         If !Empty(Alltrim(RET->D4_COD))
	                                            cLocRet := Iif(cLocBai $ '02', Iif(RET->B1_TIPO == 'MP', '01', '02'), Iif(RET->B1_TIPO == 'MP', '10', '20') )
	                                            //Cabeçalho do movimento interno para retenção, usar código de movimento especifico 551
	                                            aCabMov := { {"D3_TM"     , '551'    , NIL},;
	                                                         {"D3_EMISSAO", dDataBase, NIL} }
	//                                                         {"D3_EMISSAO", sTod(TBAI->ZZA_DTINI), NIL} }
	                                            //Itens do movimento interno para retenção
	                                            aAuxMov := { {"D3_COD"    , cProRet         , NIL},;
	                                                         {"D3_TRT"    , RET->D4_TRT     , NIL},;
	                                                         {"D3_QUANT"  , RET->D4_QUANT   , NIL},;
	                                                         {"D3_UM"     , RET->B1_UM      , NIL},;
	                                                         {"D3_LOCAL"  , cLocRet         , NIL},;
	                                                         {"D3_OP"     , TBAI->ZZA_ORDEM , NIL},;
	                                                         {"D3_TURNO"  , "BEP"           , NIL} }
	                                            aAdd(aIteMov, aAuxMov)
	                                            
	                                            //Executa a Baixa pelo execauto
	                                            DbSelectArea("SD3")
	                                            lMsErroAuto := .f.
	                                            MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 3)
	                                         Endif
	                                     EndIf  //Fim alteração    
                                         DbSelectArea("RET")
                                         DbCloseArea()
                                      Endif
                                   Endif
                                   If !lMsErroAuto
                                      lMsErroAuto := .f.
                                      DbSelectArea("SF5")
                                      MSFILTER('')
                                      DbSelectArea("SF5")
                                      DbSetOrder(1)
                                      DbSelectArea("SH6")
                                      MsExecAuto( {|x, y| Mata681(x, y)}, aOpeBai, 3)
                                      If !lMsErroAuto
                                         aRotBai[nSLT][4] := aRotBai[nSLT][1] //Da baixa da operação na Matriz do Roteiro
                                         If Len(aRotBai) == nSLT
                                            cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - OP_BAIXAD', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                            If nQtdBai < nQtdOri
                                               If SD3->D3_CF $ 'PR0' .and. Alltrim(SD3->D3_OP) $ Alltrim(TBAI->ZZA_ORDEM)
                                                  lJaBaix := .t.
                                                  nRecSD3 := recno()
                                                  a250End(.t.)
                                               Endif
                                            Endif
                                         Endif
                                         XXX := TCSQLExec(cQry1)
                                      Else
                                         cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                                         If "A680OPTOT" $ cStrErr
                                            cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - A680OPTOT', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                            XXX := TCSQLExec(cQry1)
                                            nSLT := Len(aRotBai)
                                            MEMOWRIT(NomeAutoLog(), " ")
                                         ElseIf "FECHTO" $ cStrErr
                                                cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - FECHTO', ZZA_CAMPO = 'NÃO PODE SER DIGITADO MOVIMENTO COM DATA INFERIOR AO FECHAMENTO.' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                XXX := TCSQLExec(cQry1)
                                                nSLT := Len(aRotBai)
                                                MEMOWRIT(NomeAutoLog(), " ")
                                         ElseIf "MA240NEGAT" $ cStrErr
                                                cString := MemoRead( NomeAutoLog() )
                                                cProLoc := ""
                                                For nY := 1 To MlCount(cString)
                                                    If 'Sem Saldo em ' $ MemoLine( cString, 80, nY)
                                                       cVarAux := MemoLine( cString, 80, nY)
                                                       If Empty(cProLoc)
                                                          cProLoc += Alltrim(SubStr(cVarAux, 1, 21))+'-'+Alltrim(SubStr(cVarAux, 22, 2))
                                                       Else
                                                          cProLoc += " / "+Alltrim(SubStr(cVarAux, 1, 21))+'-'+Alltrim(SubStr(cVarAux, 22, 2))
                                                       Endif
                                                    Endif
                                                Next
                                                cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - MA240NEGAT', ZZA_CAMPO = 'EXISTE MATERIAL COM SALDO NEGATIVO: "+SubStr(cProLoc, 1, 44)+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                                XXX := TCSQLExec(cQry1)
                                                nSLT := Len(aRotBai)
                                                MEMOWRIT(NomeAutoLog(), " ")
                                         Else
                                            cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_CAMPO = 'OPERACAO "+aRotBai[nSLT][1]+" NAO BAIXADA "+NomeAutoLog()+"' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                            nSLT := Len(aRotBai)
                                            XXX := TCSQLExec(cQry1)
                                            MEMOWRIT(NomeAutoLog(), " ")
                                         Endif
                                      Endif
                                   Endif
                                Else
                                   nQtdJaB += 1
                                Endif
                            Next
                            If !lJaBaix
                               If nQtdJaB == Len(aRotBai)
                                  cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_FLAG = '5', ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_CAMPO = '' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                                  XXX := TCSQLExec(cQry1)
                                  DbSelectArea("SD3")
                                  DbSetOrder(1)
                                  DbSeek(xFilial("SD3")+TBAI->ZZA_ORDEM+Space(13 - Len(TBAI->ZZA_ORDEM))+TBAI->ZZA_PRODUT, .t.)
                                  If Found()
                                     While !Eof() .and. Alltrim(SD3->D3_OP) == Alltrim(TBAI->ZZA_ORDEM) .and. Alltrim(SD3->D3_COD) == Alltrim(TBAI->ZZA_PRODUT)
                                           If !SD3->D3_ESTORNO == 'S'
                                              nRecSD3 := recno()
                                              a250End(.t.)
                                           Endif
                                           DbSelectArea("SD3")
                                           DbSkip()
                                     EndDo
                                  Endif
                               Endif
                            Endif
                         Else
                            cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - QTDE_ZERO', ZZA_CAMPO = 'QUANTIDADE FINAL APONTADA IGUAL A ZERO' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                            XXX := TCSQLExec(cQry1)
                         Endif
                      Else
                         //Grava conteudo para ZZA_CAMPO
                         cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - SEM_ROTEI', ZZA_CAMPO = 'ORDEM DE PRODUÇÃO SEM ROTEIRO' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                         XXX := TCSQLExec(cQry1)
                      Endif
                   Else
                      //Grava conteudo para ZZA_CAMPO
                      cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_DTLOG = '"+Dtos(Date())+"', ZZA_HORA = '"+SubStr(Time(), 1, 5)+"', ZZA_HELP = SUBSTRING(ZZA_HELP, 1, 1)+' - SALDO_IND', ZZA_CAMPO = 'FALTA BAIXA DE MATERIAIS - "+StrZero(TBAI->QTDZZF, 2)+" MP.' WHERE R_E_C_N_O_ = "+Alltrim(Str(TBAI->R_E_C_N_O_))
                      XXX := TCSQLExec(cQry1)
                   Endif
                   DbSelectArea("TBAI")
                   DbSkip()
             EndDo
             DbSelectArea("TBAI")
             DbCloseArea()
             //PutMv("MV_BXMANEW",  "")
             PutMv("MV_BXPROP" , "S")
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
                If Hrs2Min( time() ) - Hrs2Min( SubStr( cFlaBai, 2 + At( "|", SubStr( cFlaBai, 3) ) + 1 ) ) >= 45 .or. Hrs2Min( time() ) - Hrs2Min( SubStr( cFlaBai, 2 + At( "|", SubStr( cFlaBai, 3) ) + 1 ) ) < 0
                  // PutMv("MV_BXMANEW", "")
                Endif
             Endif
             lEndThread := .t.
          Endif
       Else
          If nOpc $ '1'
             //LGS#20200212 - Adequação de release 12.1.25 e posteriores
             //ConOut("Data do fechamento de O.P. está menor ou igual ao fechamento do sistema.")
             FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Data do fechamento de O.P. está menor ou igual ao fechamento do sistema.", 0 )
          Else
             MsgStop("Data do fechamento de O.P. está menor ou igual ao fechamento do sistema.", "Atenção")
          Endif
          lEndThread := .t.
       Endif

	//Fechando arquivo de bloqueio do procedimento 
	DbSelectArea(_cAreaBloq)
    DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
    DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg
Return(Nil)

/**************************************************************************************/
/*** SCH013_2 - Exibi a mensagem de erro na tela do server.                         ***/
/**************************************************************************************/
Static Function SCH013_2(e)
       Local cMessage := If( Empty(e:osCode), If(e:Severity > ES_WARNING, "Error ", "Warning "), "DOS Error "+nTrim(e:osCode)+" )" )
       cMessage += If( ValType(e:SubSystem) == "C", e:SubSystem, "???")
       If ValType(e:Description) == "C"
          cMessage += " "+e:Description
       Endif
       cMessage += If( !Empty(e:FileName), ": "+e:FileName, If( !Empty(e:Operation), ": "+e:Operation, "") )
Return(cMessage)

/**************************************************************************************/
/*** SCH013_1 - Tratamento dos erros ocorridos.                                     ***/
/**************************************************************************************/
Static Function SCH013_1(e, nOpc)
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
                    //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                    //ConOut("   *** Alias does not exist "+e:Operation)
                    FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   *** Alias does not exist "+e:Operation, 0 )
                 Else
                    MsgStop("   *** Alias does not exist "+e:Operation, "Atenção...")
                 Endif
                 Return
          Endif
       Endif
       If nOpc == '1'
          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
          //ConOut("   ***"+SCH013_2(e)) //Exibe a mensagem de erro na tela do server
          FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "   ***"+SCH013_2(e), 0 )
       Else
          MsgStop("   ***"+SCH013_2(e))
       Endif
       If nOpc $ '1'
          __QUIT()
       Else
          lEndThread := .t.
       Endif
Return(Nil)

/******************************************************************************************************************/
/*** FBUSPAR - BUSCA PARÂMETROS UTILIZADOS NO PROCESSAMENTO                                                     ***/
/******************************************************************************************************************/
/*USER Function fBusPar(dDatFin, cCodBai, cBaiPro, dUltFec, cFlaBai, cTipExe, nOpc, cBxLocP)
       
       If nOpc == '1'
  	      If Select("SX6") == 0
		   	  PREPARE environment EMPRESA substr(cNumEmp,1,2) FILIAL substr(cNumEmp,3,6) MODULO "PCP"
          Endif
          DbUseArea(.t., __LocalDrive, 'SX6'+substr(cNumEmp,1,2)+'0', 'TSX6', .t., .f.)
          DbSelectArea("TSX6")
          DbSetOrder(1)
          DbSeek(cFilAnt+'MV_BXOPFEC') //Data Final para baixa de Ordens de produção
          If Found()
             dDatFin := Alltrim(TSX6->X6_CONTEUD) 
          Endif
          DbSeek('      MV_CBAIREQ') //Código do movimento para as baixas
          If Found()
             cCodBai := Alltrim(TSX6->X6_CONTEUD)
          Endif
          DbSeek(cFilAnt+'MV_BXPROP') //Baixa proporcional a O.P.
          If Found()
             cBaiPro := Alltrim(TSX6->X6_CONTEUD)
          Endif
          DbSeek(cFilAnt+'MV_ULMES')  //Ultimo fechamento
          If Found()
             dUltFec := dTos(cTod(Alltrim(TSX6->X6_CONTEUD)))
          Endif
          //DbSeek(cFilAnt+'MV_BXMANEW')  //Verifica se a baixa está sendo processada
          //If Found()
          //   cFlaBai := Alltrim(TSX6->X6_CONTEUD)
          //Endif
          DbSeek(cFilAnt+'MV_PROCEXE')  //Verifica o flag da baixa que será processado P=Pesagem, C=Colorista, L=Laboratorio
          If Found()
             cTipExe := Alltrim(TSX6->X6_CONTEUD)
          Endif
          DbSeek(cFilAnt+'MV_BXLOCPD')  //Verifica o local para baixa das Ordens de produção.
          If Found()
             cBxLocP := Alltrim(TSX6->X6_CONTEUD)
          Endif
          TSX6->(DbCloseArea())
       Else 
          dDatFin := GETMV('MV_BXOPFEC')     //Data Final para baixa de Ordens de produção
          cCodBai := GETMV('MV_CBAIREQ')     //Código do movimento para as baixas
          cBaiPro := GETMV('MV_BXPROP')      //Baixa proporcional a O.P.
          dUltFec := dTos(GETMV('MV_ULMES')) //Ultimo fechamento
          //cFlaBai := GETMV("MV_BXMANEW")
          cTipExe := GETMV("MV_PROCEXE")
          cBxLocP := GETMV("MV_BXLOCPD")     //Local para Baixa das Ordens de produção.
       Endif
Return*/

/******************************************************************************************************************/
/*** FBUSROT - BUSCA ROTEIRO DE OPERAÇÃO PARA BAIXAS DAS ORDENS DE PRODUÇÕES                                    ***/
/******************************************************************************************************************/
User Function fBusRot(aRotBai, cOrdem, cProduto, cRoteiro, cSeqEnv)
     cQrySG2 := ""
     cQrySG2 += "SELECT SG2.G2_OPERAC, SG2.G2_RECURSO, SG2.G2_DESCRI, SH6.H6_OPERAC, SH6.H6_OBSERVA "
     cQrySG2 += "FROM "+RetSqlName("SG2")+" SG2 "
     cQrySG2 += "LEFT OUTER JOIN "+RetSqlName("SH6")+" SH6 WITH (NOLOCK) ON SH6.H6_FILIAL = SG2.G2_FILIAL AND SH6.D_E_L_E_T_ = '' AND SH6.H6_OP = '"+cOrdem+"' AND SH6.H6_OPERAC = SG2.G2_OPERAC "
     cQrySG2 += "WHERE SG2.G2_FILIAL  = '"+xFilial("SG2")+"' "
     cQrySG2 += "  AND SG2.D_E_L_E_T_ = '' "
     cQrySG2 += "  AND SG2.G2_CODIGO  = '"+cRoteiro+"' "
     cQrySG2 += "  AND SG2.G2_PRODUTO = '"+cProduto+"' "
     cQrySG2 += "ORDER BY SG2.G2_OPERAC "
     TCQuery cQrySG2 ALIAS "ROT" NEW
     DbSelectArea("ROT")
     While !Eof()
           If aScan(aRotBai, { |x| x[1] == ROT->G2_OPERAC } ) == 0
              aAdd( aRotBai, { ROT->G2_OPERAC, ROT->G2_RECURSO, ROT->G2_DESCRI, ROT->H6_OPERAC, Alltrim(ROT->H6_OBSERVA) } )
           Else
              aRotBai[ aScan(aRotBai, { |x| x[1] == ROT->G2_OPERAC } ) ][ 5 ] += '.'+Alltrim(ROT->H6_OBSERVA)
           Endif
           DbSelectArea("ROT")
           DbSkip()
     Enddo
     DbSelectArea("ROT")
     DbCloseArea()
Return
