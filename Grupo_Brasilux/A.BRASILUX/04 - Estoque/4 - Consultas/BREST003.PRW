//#include 'brasilux.ch'
#include "protheus.ch"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BREST003 ºAutor  ³ Cleber O. Dominguesº Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Planilha de Custos                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BREST003()
     Local nArq, cPlanilha, nLidos, cLinha, lOk, aAux, cVar, dAux, i
     Private cPerg, mv_par01, aPrazos
     Private cRotina := "BREST003  "
     Private cCodUsr := RetCodUsr()
     Private lAcsAtv := .t.

     //LGS#12/07/2023 - Ajuste dos parametros da função PSWAdmin
	//If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) != 0
     //If PSWADMIN( , , cCodUsr ) != 0
		lAcsAtv := Iif(SubStr(Posicione("SZW", 4, xFilial("SZW")+cRotina+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS"), 9, 1) $ '*', .t., .f.)
		If !lAcsAtv
			MsgBox("Usuário não autorizado!!!", "Atenção", "STOP")
			Return
		Endif
	//ENDIF
     u_zcfga01( 'BREST003' ) //LGS#2021119 - Gravação de log de utilização da rotina
     aPrazos  := {}
     aAdd(aPrazos,0) 
     mv_par01 := ""
     DbSelectArea("Sx3")
     DbSetOrder(1)     
     DbSelectArea("SB1")
     DbSetOrder(1)
     cPerg = "ES"+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)
     ValidPerg()
     Pergunte(cPerg)   

     nOpcx    := 6
     nUsado   := 0
     aHeader  := {}
     cPlanilha = Alltrim(mv_par01)+".pdv"
     nArq      = fOpen(cPlanilha)
     nLidos    = 0
     If nArq > 0 
        fSeek(nArq, 0, 0)
        nTamArq := fSeek(nArq, 0, 2)
        fSeek(nArq, 0, 0)
        lOk   = .f.
        aAux := {}
        While nLidos < nTamArq
              cLinha = U_fGets(nArq, nTamArq)
              If (SubStr(cLinha, 6, 3) $ "PIS_IVA_COF") 
                 lOk = .t.
              Endif
              If lOk
                 nUsado := nUsado+1
                 cVar    = "V"+Alltrim(Str(nUsado))
                 aAdd(aHeader, {Trim(SubStr(cLinha, 6, 30)), cVar, "@E 999.99", 6, 2, 'ExecBlock("BRES03", .F., .F., "'+cVar+'")', "€€€€€€€€€€€€€€ ", "N", "", " " } )
                 aAdd(aAux, {cVar, U_cTon(Alltrim(SubStr(cLinha, 36, 10)))})
              Endif
              If (SubStr(cLinha, 6, 16) == "DESP. COMERCIAIS")
                 lOk = .f.
              Endif
              nLidos += Len(cLinha)+2
        EndDo
        fClose(nArq)
     Else
        MsgBox("Impossível abrir planilha: "+cPlanilha, "Atenção...", "STOP")
        Return
     Endif

     /*	
     nUsado  := 0
     aHeader := {}
     While !fEof(nArq) 
           If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
              nUsado := nUsado + 1
              aAdd(aHeader, {Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, "AllwaysTrue()", X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
           Endif
           DbSkip()
     EndDo
     */
     aCols := Array(1, nUsado+1)
     /*
     DbSelectArea("SX3")
     DbSeek("SX5")
     nUsado := 0
     While !Eof() .And. (X3_ARQUIVO == "SX5")
           If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
              nUsado := nUsado + 1
              If nOpcx == 3
                 If X3_TIPO == "C"
                    aCols[1][nUsado] := Space(X3_TAMANHO)
                 ElseIf X3_TIPO == "N"
                        aCols[1][nUsado] := 0
                 ElseIf X3_TIPO == "D"
                        aCols[1][nUsado] := dDataBase
                 ElseIf X3_TIPO == "M"
                        aCols[1][nUsado] := ""
                 Else
                    aCols[1][nUsado] := .F.
                 Endif
              Endif
           Endif
           DbSkip()
     EndDo
     */
     aCols[1][nUsado+1] := .F.
     For i = 1 To Len(aAux)
         aCols[1][i] := aAux[i][2]
     Next
     cProduto    = Space(15)
     nMO         = 0
     _nJuros     := GETMV("MV_JUROS")    
     nDolar := 0
     dbselectarea("SM2")
     dbsetorder(1)    
     dAux = dDataBase       
     dbseek(dAux)
     if !found()
     	dbgobottom()
     endif 
     do while !bof() .and. (SM2->M2_MOEDA2 = 0)
     	dbskip(-1)
     enddo 
     if !eof() .and. !bof() 
     	nDolar := SM2->M2_MOEDA2
     endif 
     nCusto      = 0   
     nCustoD    := 0
     nLucro      = 0
     nComissao   = 0
     nPreco      = 0  
     nPrecoUS   := 0
     nLinGetD   := 0    
     nIcms      := GETMV("MV_ICMPAD")
     DbSelectArea("SE4")
     DbSetOrder(1)
     DbGoTop()
     cCondPagto := SE4->E4_CODIGO
     cTitulo    := "Formação de Preços, Planilha "+mv_par01
     aC         := {}
     // aC[n,1] = Nome da Variavel Ex.:"cCliente"
     // aC[n,2] = Array com coordenadas do Get [x,y], em
     // Windows estao em PIXEL
     // aC[n,3] = Titulo do Campo
     // aC[n,4] = Picture
     // aC[n,5] = Validacao
     // aC[n,6] = F3
     // aC[n,7] = Se campo e' editavel .t. se nao .f.
     AADD(aC,{"cProduto"  ,{15, 010}, "Cod. do Produto"  , "@R XXX99.99.999.XX", 'EXECBLOCK("BRES031", .F., .F.    )',"SB1",    })
     AADD(aC,{"nCusto"    ,{15, 150}, "Custo"            , "@E 999,999.9999"   , 'EXECBLOCK("BRES03" , .F., .F., "")',     , .f.})
     AADD(aC,{"nMo"       ,{15, 230}, "Mao-de-Obra"      , "@E 999,999.99"     , 'EXECBLOCK("BRES03" , .F., .F., "")',     ,    })
     AADD(aC,{"nDolar"    ,{15, 310}, "Vlr do Dolar"     , "@E 999,999.99"     , 'EXECBLOCK("BRES03" , .F., .F., "")',"SB1",    })
     AADD(aC,{"nIcms"     ,{30, 010}, "ICMS(%) : "       , "@E 999.99"         , 'EXECBLOCK("BRES03" , .F., .F., "")',     ,    })
     AADD(aC,{"nLucro"    ,{30, 070}, "Lucro(%) : "      , "@E 999.99"         , 'EXECBLOCK("BRES03" , .F., .F., "")',     ,    })
     AADD(aC,{"nComissao" ,{30, 135}, "Comissao(%) : "   , "@E 999.99"         , 'EXECBLOCK("BRES03" , .F., .F., "")',     ,    })
     AADD(aC,{"_nJuros"    ,{30, 230}, "Juros(%) : "      , "@E 999.99"         , 'EXECBLOCK("BRES03" , .F., .F., "")',     ,    })
     AADD(aC,{"cCondPagto",{45, 010}, "Cond. Pagto :"    , "@R 999"            , 'EXECBLOCK("BRES032", .F., .F.    )',"SE4",    })
     AADD(aC,{"nPreco"    ,{45, 100}, "Preco de Venda : ", "@E 999,999.99"     ,                                     ,     , .f.})
     AADD(aC,{"nPrecoUS"  ,{45, 210}, "Preço (U$->R$) : ", "@E 999,999.99"     ,                                     ,     , .f.})
     aR       := {}
     // aR[n,1] = Nome da Variavel Ex.:"cCliente"
     // aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
     // aR[n,3] = Titulo do Campo
     // aR[n,4] = Picture
     // aR[n,5] = Validacao
     // aR[n,6] = F3
     // aR[n,7] = Se campo e' editavel .t. se nao .f.
     /*
     #IFDEF WINDOWS
            AADD(aR,{"nLinGetD" ,{120,10},"Linha na GetDados", "@E 999",,,.F.})
     #ELSE
         AADD(aR,{"nLinGetD" ,{19,05},"Linha na GetDados", "@E 999",,,.F.})
     #ENDIF
     */
     aCGD     := {085, 05, 300, 750}
     aCord    := {050, 40, 700, 1200}
     cLinhaOk := "AllwaysTrue()"
     cTudoOk  := "AllwaysTrue()"
     // lRet = .t. se confirmou
     // lRet = .f. se cancelou
     lRet     := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk, , , , , aCord)
     // No Windows existe a funcao de apoio CallMOd2Obj() que
     // retorna o objeto Getdados Corrente
Return

/******************************************************************************************************************/
/*** VALIDPERG - Validação das perguntas na tabela SX1                                                          ***/
/******************************************************************************************************************/
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local j, i
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Planilha  ?", "", "", "mv_ch1", "C", 10, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

       For i := 1 To Len(aRegs)
           If !DbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .t.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return

User Function BRES03()
     Local nSomaCusto,nPerc,nContCols,nQtdeCols,cAux,nQtdeParc,i,nJur

     nQtdeParc = len(aPrazos)
     nJur = 0
     For i := 1 to nQtdeParc
         nJur += 1/((1+(_nJuros/100))^((12*aPrazos[i])/365))
     Next                                              
     nJur = (1/nQtdeParc)*nJur

     nSomaCusto = nCusto + nMo
     nPerc      = nIcms + nLucro + nComissao
     nQtdeCols  = Len(aHeader)
     For nContCols = 1 to nQtdeCols    
         cAux = alltrim(aHeader[nContCols,2])
         If cAux == Paramixb
            nPerc += &cAux
         Else
            nPerc += aCols[1,nContCols]
         Endif
     Next
     nPreco = nSomaCusto/(nJur - (nPerc/100)) 
	DbSelectArea("SB1")
	If DbSeek(xFilial("SB1")+cProduto)
		nCustoD    = U_DCustoPro(cProduto,nDolar)
	endif 
      
     nPrecoUS := (nCustoD+nMo)/(nJur - (nPerc/100))
Return(.t.)

User Function BRES031()
     Private aArray
     aArray = {}
     aadd(aArray, {"", "", "", cProduto})
     nCusto = 0
     If !Empty(cProduto)
        DbSelectArea("SB1")
        If DbSeek(xFilial("SB1")+cProduto)
           nCusto    = U_CustoPro(cProduto)
           nMo       = ExecBlock("BRPCP011", .F., .F., "MO")
           nLucro    = ExecBlock("BRPCP011", .F., .F., "LU")
           nComissao = ExecBlock("BRPCP011", .F., .F., "CO")
           ExecBlock("BRES03", .F., .F., "")
		Else 
           MsgBox("Produto Inexistente!", "Atenção", "STOP")
        Endif
     Endif
Return(.t.)

User Function BRES032()
     Local nPos1, i, nPos2, cAux, lRet
     lRet = .t.
     // Criando vetor c/ prazos de pagamento
     aPrazos := {}

     DbSelectArea("SE4")        // COND. PAGTO
     DbSetOrder(1)
     DbSeek(xFilial("SE4")+cCondPagto)
     If !Found() .or. (Found() .and. (SE4->E4_TIPO != "1"))
        aAdd(aPrazos, 0)
        MsgBox("Cond. Pagto não encontrada ou Tipo Inválido!", "Atenção", "STOP")
        lRet = .f.
     Else
        cAux := Alltrim(SE4->E4_COND)
        If Len(cAux) == 0
           aAdd(aPrazos, 0)
        Else
           nPos1 = 1
           For i := 1 To Len(cAux)
               If SubStr(cAux, i, 1) == ","
                  aAdd(aPrazos, Val(SubStr(cAux, nPos1, nPos2-nPos1+1)))
                  nPos1 = i+1
               Else
                  nPos2 = i
                  If i == Len(cAux)
                     aAdd(aPrazos, Val(SubStr(cAux, nPos1, nPos2-nPos1+1)))
                  Endif
               Endif
           Next
        Endif
        ExecBlock("BRES03", .F., .F., "")
     Endif
Return(lRet)   

