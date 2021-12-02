#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} ZGPER02
(long_description)
@type function
@author gustavosouza
@since 16/08/2018
@version 1.0
@return ${Nil}, ${Vazio}
@example
(examples)
@see (links_or_references)
/*/
User Function ZGPER02()        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
     //+--------------------------------------------------------------+
     //?Define Variaveis Locais (Basicas)                            ?
     //+--------------------------------------------------------------+
     Private aVetor := {}
     Private aInfo  := {}
     Private lEnd   := .F.
     Private cString:= "SRA"  			// alias do arquivo principal (Base)
     Private nLin   := 0
     Private nQtdEtq:= 0
     cPerg          := "ZGPER02   "
     //fValPerg( cPerg )  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     cAcessaSRA	    := &( " { || " + ChkRH( "ETIQAS" , "SRA" , "2" ) + " } " )
     u_zcfga01( 'ZGPER02' ) //LGS#2021202 - Gravação de log de utilização da rotina
     //+--------------------------------------------------------------+
     //?Verifica as perguntas selecionadas                           ?
     //+--------------------------------------------------------------+
     If !Pergunte( cPerg, .T. )
        Return
     Else
        //+--------------------------------------------------------------+
        //?Variaveis utilizadas para parametros                         ?
        //?MV_PAR01        //  Filial De                                ?
        //?MV_PAR02        //  Filial Ate                               ?
        //?MV_PAR03        //  Centro de Custo De                       ?
        //?MV_PAR04        //  Centro de Custo Ate                      ?
        //?MV_PAR05        //  Matricula De                             ?
        //?MV_PAR06        //  Matricula Ate                            ?
        //?MV_PAR07        //  Nome De                                  ?
        //?MV_PAR08        //  Nome Ate                                 ?
        //?MV_PAR09        //  Categorias                               ?
        //?MV_PAR10        //  Periodo De                               ?
        //?MV_PAR11        //  Periodo Ate                              ?
        //?MV_PAR12        //  Sindicato (99 Todos)                     ?
        //?MV_PAR13        //  Numero de Colunas                        ?
        //?MV_PAR14        //  Esp.Estabelecimento                      ?
        //?MV_PAR15        //  Tipo                                     ?
        //?MV_PAR16        //  Situa?es                                ?
        //+--------------------------------------------------------------+
        //If mv_par19 == 1
        //   Processa( { || fGPE02QAS( ) }, 'Buscando informações')
        //Else
           Processa( { || fGPE02FER( ) }, 'Buscando informações')
        //Endif
     Endif
Return Nil

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	function GR320Imp
/*Static function fGPE02QAS()
       //Local cStartPath  := GetSrvProfString("Startpath","")
       Local T
       Local cSimb    := SuperGetmv("MV_SIMB1")
       Local lNewProf := SuperGetMv("MV_NCPROF",,"2") == "1" // 1-Novo calculo da folha de professores; 2-Calculo antigo da folha de professores
       Local cDescTar := ""
       Local nCont    := 2
       Local dDataTar := Ctod("//")
       Local bTarOk   := { || .T. }
       Local lFirst   := .T.
       Local cTpAlt   := ""
       Private nMaxCol:= 2330
       Private oPrint
       Private oFont1
       Private oFont2
       Private oCouNew10N
       Private oCouNew10S

       //+--------------------------------------------------------------+
       //?Define Variaveis Locais (Programa)                           ?
       //+--------------------------------------------------------------+
       cMostra := "S"
       cDet    := ""
       nTot    := ""
       cCab    := ""
       cNome   := ""
       cFim    := ""
       nTam    := 0
       nPula   := 1

       //+--------------------------------------------------------------+
       //?Carregando variaveis MV_PAR?? para Variaveis do Sistema.     ?
       //+--------------------------------------------------------------+
       cFilDe     := MV_PAR01
       cFilAte    := MV_PAR02
       cCcDe      := MV_PAR03
       cCcAte     := MV_PAR04
       cMatDe     := MV_PAR05
       cMatAte    := MV_PAR06
       cNomeDe    := MV_PAR07
       cNomeAte   := MV_PAR08
       cCategoria := MV_PAR09
       dPerDe     := MV_PAR10
       dPerAte    := MV_PAR11
       cSindicato := MV_PAR12
       nColunas   := If( MV_PAR13 > 3 , 3 , MV_PAR13 )
       cSituacao  := MV_PAR16
       nOrdem     := MV_PAR18

       oPrint := TMSPrinter():New("Etiqueta 3 Colunas A4")
       oPrint:SetPortrait()
       oPrint:Setup()
       oPrint:StartPage()
       oPrint:SetPaperSize( 9 )
       oFont1     := TFont():New('Courier New', 08, 08, .T., .T.)
       oFont2     := TFont():New('Courier New', 10, 10,    , .F., , , , .T., .T.) //Sublinhada
       oCouNew10N := TFont():New("Courier New", 10, 10,    , .T., , , , .T., .F.) //Negrito
       oCouNew10S := TFont():New("Courier New", 10, 10,    , .F., , , , .T., .T.) //SubLinhado
       nLin    := 0000 //Linha Inicial

       DbSelectArea( "SRA" )
       If nOrdem == 1
          dbSetOrder( 1 )
       ElseIf nOrdem == 2
              dbSetOrder( 2 )
       ElseIf nOrdem == 3
              dbSetOrder(3)
       Endif

       dbGoTop()

       If nOrdem == 1
          dbSeek(cFilDe + cMatDe,.T.)
          cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
          cFim    := cFilAte + cMatAte
       ElseIf nOrdem == 2
              dbSeek(cFilDe + cCcDe + cMatDe,.T.)
              cInicio := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
              cFim    := cFilAte + cCcAte + cMatAte
       ElseIf nOrdem == 3
              DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
              cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
              cFim    := cFilAte + cNomeAte + cMatAte
       Endif

       dbSelectArea( "SRA" )
       ProcRegua( RecCount() / 3 )
       Chave := 0
       nCol  := 0005
       nAlin := 0
       //Determina a Coluna Incial
       If ( mv_par17 > nColunas ) .or. ( mv_par17 == 1 )
          nAlin := 0
       ElseIf mv_par17 == 2
              nAlin := 1
       Else
          nAlin := 2
       Endif
       //Determina a Linha Inicial
       If ( mv_par20 >= 12 ) .or. ( mv_par20 == 1 ) 
          nLin := 0
       Else
          nLin    := 272 * ( mv_par20 - 1)
          nQtdEtq := ( mv_par20 - 1 ) 
       Endif
       For T := 1 TO nColunas
           aAdd( aVetor, { " ", " ", " ", " ", " ", " " } )
       Next T
       cFil  := Space(FWGETTAMFILIAL)

       dbSelectArea( "SRA" )
       While !Eof() .And. Chave == 0
             //+--------------------------------------------------------------+
             //?Movimenta Regua Processamento                                ?
             //+--------------------------------------------------------------+

             IncProc()
             //+--------------------------------------------------------------+
             //?Verifica Quebra de Filial                                    ?
             //+--------------------------------------------------------------+
             If SRA->RA_FILIAL != cFil
                If !fInfo(@aInfo,SRA->RA_FILIAL)
                   Exit
                Endif
                cFil:=SRA->RA_FILIAL
             Endif

             While !Eof() .And. SRA->RA_FILIAL == cFil 
                   //+--------------------------------------------------------------+
                   //?Movimenta Regua Processamento                                ?
                   //+--------------------------------------------------------------+
                   IncProc()

                   //+--------------------------------------------------------------+
                   //?Verifica o De / Ate Solicitado                               ?
                   //+--------------------------------------------------------------+
                   If nOrdem == 1
                      If SRA->RA_FILIAL + SRA->RA_MAT > cFilAte + cMatAte
                         Chave := 1
                         Exit
                      Endif
                   Elseif nOrdem == 2
                          If SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT > cFilAte + cCcAte + cMatAte
                             Chave := 1
                             Exit
                          Endif
                   Elseif nOrdem == 3
                          If SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT > cFilAte + cNomeAte + cMatAte
                             Chave := 1
                             Exit
                          Endif
                   Endif

                   //+--------------------------------------------------------------+
                   //?Cancela Impres? ao se pressionar <ALT> + <A>                ?
                   //+--------------------------------------------------------------+
                   If lEnd
                      Chave := 1
                      Exit
                   EndIF

                   //+--------------------------------------------------------------+
                   //?Consiste Parametrização do Intervalo de Impress?            ?
                   //+--------------------------------------------------------------+
                   If (Sra->Ra_Nome < cNomeDe) .Or. (Sra->Ra_Nome > cNomeAte) .Or. ;
                      (Sra->Ra_Mat  < cMatDe ) .Or. (Sra->Ra_Mat  > cMatAte ) .Or. ;
                      (Sra->Ra_CC   < cCcDe  ) .Or. (Sra->Ra_CC   > cCCAte  )
                      dbSkip(1)
                      Loop
                   EndIf

                   IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
                      dbSelectArea("SRA")
                      dbSkip()
                      Loop
                   EndIF

                   //+--------------------------------------------------------------+
                   //?Verifica Situacao e Categoria do Funcionario                  ?
                   //+--------------------------------------------------------------+
                   If !( SRA->RA_SITFOLH $ cSituacao ) .OR. !( SRA->RA_CATFUNC $ cCategoria )
                      dbSkip()
                      Loop
                   Endif

                   //+--------------------------------------------------------------+
                   //?Verifica Sindicatos - 99 Todos                               ?
                   //+--------------------------------------------------------------+
                   If cSindicato #"99" .And. SRA->RA_SINDICA # cSindicato
                      dbSkip()
                      Loop
                   EndIf

                   cTipPagto := If( SRA->RA_CATFUNC$ "M*C*I", " POR MES", If( SRA->RA_CATFUNC = "H", " POR HRS", " POR DIA" ) )
		
                   If SRA->RA_CATFUNC $ "I*J" .And. lNewProf
                      dbSelectArea( "SRO" )
                      dbSetOrder(1)
                      IF dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
                         // Para prof. mensalista, imprime apenas tarefas fixas
                         If SRA->RA_CATFUNC == "I"
                            bTarOk := { || SRO->RO_TIPO == "1" }
                         Else
                            bTarOk := { || .T. }
                         EndIf
                         While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRO->RO_FILIAL + SRO->RO_MAT
                               If SRO->RO_DATA >= dPerDe .And. SRO->RO_DATA <= dPerAte
                                  dDataTar := SRO->RO_DATA
                                  cTpAlt   := SRO->RO_TPALT
                                  nCont    := 2
                                  lFirst   := .T.
                                  While !Eof() .And. SRO->RO_DATA == dDataTar .And. SRO->RO_TPALT == cTpAlt .And. nCont < 4
                                        If Eval(bTarOk) .And. SRO->RO_QUANT # 0
                                           dDtReaj := SRO->RO_DATA
                                           If lFirst
                                              nAlin++
                                              lFirst := .F.
                                           EndIf

                                           dbSelectArea( "SX5" )
                                           If dbSeek( xFilial( "SX5" ) + "41" + SRO->RO_TPALT )
                                              cMotivo := fTAcento( SubStr(X5Descri(),1,15) )						
                                           Else
                                              cMotivo := "Nao Cad.Tab. 41"
                                           Endif

                                           dbSelectArea( "SRX" )
                                           dbSetOrder(1)
                                           If dbSeek( xFilial("SRX") + "59" + SRO->RO_CODTAR + "1" )
                                              If SRA->RA_CATFUNC == "I"	
                                                 cDescTar := Left( SRX->RX_TXT, 15 ) + Space(1) + "R$" + Transform(SRO->RO_VALTOT,"@E 9,999.99")
                                              Else
                                                 cDescTar := Left( SRX->RX_TXT, 16 ) + Space(1) + "R$" + Transform(SRO->RO_VALOR,"@E 999.99")
                                              EndIf
                                           EndIf

                                           If SRA->RA_CATFUNC == "I"
                                              aVetor[nAlin,nCont]:= cDescTar + OemtoAnsi( " POR MES + D.S.R. + H.A." )
                                           Else
                                              aVetor[nAlin,nCont]:= cDescTar + OemtoAnsi( " POR AULA + D.S.R. + H.A." )
                                           EndIf

                                           nCont++
                                        EndIf
                                        dbSelectArea( "SRO" )
                                        dbSkip()
                                  EndDo
                                  If nAlin > 0 .And. !Empty( aVetor[nAlin,2] )
                                     aVetor[nAlin,1] := "FIL.: " + SRA->RA_FILIAL + "  " + "MATRIC: " + SRA->RA_MAT + "  " + OemtoAnsi( "AUMENTADO EM " ) + DtoC( dDtReaj )
                                     aVetor[nAlin,4] := "POR MOTIVO DE " + SubStr( cMotivo, 1, 36 )
                                     aVetor[nAlin,5] := " "
                                     aVetor[nAlin,6] := " "
                                     cTipo           := "I"
                                     FChkET320()
                                  EndIf
                               Else
                                  dbSelectArea( "SRO" )
                                  dbSkip()
                               EndIf
                         Enddo
                      EndIf
                   Else
                      dbSelectArea( "SR3" )
                      IF dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
                         While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SR3->R3_FILIAL + SR3->R3_MAT 
                               If SR3->R3_DATA >= dPerDe .And. SR3->R3_DATA <= dPerAte .And. SR3->R3_PD == "000"
                                  nAlin:=nAlin+1
                                  dbSelectArea( "SX5" )
                                  If dbSeek( xFilial( "SX5" ) + "41" + SR3->R3_TIPO )
                                     cMotivo := fTAcento( SubStr(X5Descri(),1,15) )						
                                  Else
                                     cMotivo := "Nao Cad.Tab. 41"
                                  Endif
                                  dbSelectArea( "SR7" )
                                  If dbSeek(SR3->R3_FILIAL+SR3->R3_MAT+DTOS(SR3->R3_DATA))
                                      cFun:= DescFun(SR7->R7_FUNCAO,SR7->R7_FILIAL)
                                  Else
                                     cFun:= "*** Nao Cadastrado ***"
                                  Endif
				
                                  dbSelectArea( "SR3" )
                                  //              1   FL. 999999 MAT. 999999 C.PROF. 99999/999
                                  //                           1         2         3         4
                                  //                  1234567890123456789012345678901234567890
                                  //              2   XXXXXXXXX XX 99/99/9999 P/ R$ 99,999.99
                                  //              3   NA FUNÇÃO DE XXXXXXXXXXXXXXXXXXXXXXXXXXX
                                  //              4   CBO 999999 POR MOTIVO DE XXXXXXXXXXXXXXX
                                  //                  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                  //
                                  //              6        BRASILUX TINTAS TECNICAS LTDA.
                                  //aVetor[nAlin,1] := "FIL.: " + SRA->RA_FILIAL + " " + "MATRIC: " + SRA->RA_MAT + " " + Iif( cPaisLoc == "BRA", "CART.PROF: " + AllTrim( SRA->RA_NUMCP ) + "/" + SRA->RA_SERCP , "" )
                                  //aVetor[nAlin,2] := "AUMENTADO EM " + DtoC(SR3->R3_DATA) + " P/ " + cSimb + " " + ALLTRIM( Transform( SR3->R3_VALOR, "@E 99,999.99" ) )
                                  cFun := Alltrim( cFun ) + Space(50)
                                  cFun := SubStr( cFun, 1, 27)
                                  //aVetor[nAlin,3] := "NA FUNCAO DE "  + cFun + Iif( cPaisLoc == "BRA", " C.B.O. " + fCodCBO( SRA->RA_FILIAL, SR7->R7_FUNCAO, dDataBase ), "" )
                                  //aVetor[nAlin,4] := "POR MOTIVO DE " + SubStr( cMotivo, 1, 36 )
                                  //aVetor[nAlin,5] := " "
                                  //aVetor[nAlin,6] := " "
                                  //aVetor[nAlin,1] := "FL. " + SRA->RA_FILIAL + " MAT. " + SRA->RA_MAT + Iif( cPaisLoc == "BRA", " C.PROF. " + AllTrim( SRA->RA_NUMCP ) + "/" + SRA->RA_SERCP , "" )
                                  aVetor[nAlin,1] := "AUMENTADO EM " + DTOC( SR3->R3_DATA ) + " P/ " + cSimb + " " + ALLTRIM( Transform( SR3->R3_VALOR, "@E 99,999.99" ) )
                                  aVetor[nAlin,2] := "NA FUNÇÃO DE " + cFun
                                  aVetor[nAlin,3] := Iif( cPaisLoc == "BRA", "CBO " + fCodCBO( SRA->RA_FILIAL, SR7->R7_FUNCAO, dDataBase ), "" ) + " POR MOTIVO DE " + SubStr( cMotivo, 1, 15 )
                                  aVetor[nAlin,4] := ""
                                  aVetor[nAlin,5] := ""
                                  aVetor[nAlin,6] := PADC( Alltrim( SM0->M0_NOMECOM ), 40 )
                                  cTipo           := "I"
                                  FChkET320()
                               Endif
                               dbSkip()	
                         Enddo
                      Endif
                   EndIf
                   dbSelectArea( "SRA" )
                   dbSkip()
             Enddo
             IF Chave == 1
                Exit
             Endif

             If Eof()
                Exit
             Endif
       Enddo
       cTipo := "F"
       FChkET320()
       //+--------------------------------------------------------------+
       //?Termino do Relatorio                                         ?
       //+--------------------------------------------------------------+
       dbSelectArea( "SRA" )
       Set Filter to
       dbSetOrder(1)
Return*/

Static function fGPE02FER()
       Local T
       Local cSimb    := SuperGetmv("MV_SIMB1")

       //+--------------------------------------------------------------+
       //?Define Variaveis Locais (Programa)                           ?
       //+--------------------------------------------------------------+
       lEnd       := .F.
       cMostra    := "S"
       cDet       := ""
       nTot       := ""
       cCab       := ""
       cNome      := ""
       cFim       := ""
       nTam       := 0
       nLC        := 189
       nLN        := 105
       nPula      := 1
       cAbono 	  := If(GetMv("MV_ABOPEC")=="S","1","2")
       aVetor     := {}  
       nAlin      := 0

       //+--------------------------------------------------------------+
       //?Carregando variaveis mv_par?? para Variaveis do Sistema.     ?
       //+--------------------------------------------------------------+
       cFilDe     := mv_par01
       cFilAte    := mv_par02
       cCcDe      := mv_par03
       cCcAte     := mv_par04
       cMatDe     := mv_par05
       cMatAte    := mv_par06
       cNomeDe    := mv_par07
       cNomeAte   := mv_par08
       cCategoria := mv_par09
       dDtfDe     := mv_par10
       dDtfAte    := mv_par11
       cSindicato := mv_par12
       dPerDe     := MV_PAR10
       dPerAte    := MV_PAR11

       nColunas   := If( mv_par13 > 3 , 3 , mv_par13 )
       nOrdem     := mv_par18

       oPrint := TMSPrinter():New("Etiqueta 3 Colunas A4")
       oPrint:SetPortrait()
       oPrint:Setup()
       oPrint:StartPage()
       oPrint:SetPaperSize( 9 )
       oFont1     := TFont():New('Courier New', 08, 08, .T., .T.)
       oFont2     := TFont():New('Courier New', 10, 10,    , .F., , , , .T., .T.) //Sublinhada
       oCouNew10N := TFont():New("Courier New", 10, 10,    , .T., , , , .T., .F.) //Negrito
       oCouNew10S := TFont():New("Courier New", 10, 10,    , .F., , , , .T., .T.) //SubLinhado
       nLin    := 0000 //Linha Inicial

       For T := 1 TO nColunas
           aAdd( aVetor, { " ", " ", " ", " ", " ", " " } )
       Next T

       dbSelectArea( "SRA" )
       If nOrdem == 1
          dbSetOrder( 1 )
       ElseIf nOrdem == 2
              dbSetOrder( 2 )
       ElseIf nOrdem == 3
              dbSetOrder(3)
       Endif

       dbGoTop()
       If nOrdem == 1
          dbSeek(cFilDe + cMatDe,.T.)
          cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
          cFim    := cFilAte + cMatAte
       ElseIf nOrdem == 2
              dbSeek(cFilDe + cCcDe + cMatDe,.T.)
              cInicio := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
              cFim    := cFilAte + cCcAte + cMatAte
       ElseIf nOrdem == 3
              DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
              cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
              cFim    := cFilAte + cNomeAte + cMatAte
       Endif

       dbSelectArea( "SRA" )
       ProcRegua( RecCount() / 3 )
       Chave := 0
       nCol  := 1
       nAlin := 0
       //Determina a Coluna Incial
       If ( mv_par17 > nColunas ) .or. ( mv_par17 == 1 )
          nAlin := 0
       ElseIf mv_par17 == 2
              nAlin := 1
       Else
          nAlin := 2
       Endif
       //Determina a Linha Inicial
       If ( mv_par20 >= 12 ) .or. ( mv_par20 == 1 ) 
          nLin := 0
       Else
          nLin    := 272 * ( mv_par20 - 1)
          nQtdEtq := ( mv_par20 - 1 ) 
       Endif

       dbSelectArea( "SRA" )
       While !Eof() .And. Chave == 0
             cFil := SRA->RA_FILIAL

             //+--------------------------------------------------------------+
             //?Movimenta Regua Processamento                                ?
             //+--------------------------------------------------------------+
             IncProc()

             While !Eof() .And. SRA->RA_FILIAL == cFil 

                   //+--------------------------------------------------------------+
                   //?Movimenta Regua Processamento                                ?
                   //+--------------------------------------------------------------+
                   IncProc()

                   //+--------------------------------------------------------------+
                   //?Verifica o De / Ate Solicitado                               ?
                   //+--------------------------------------------------------------+
                   If nOrdem == 1
                      If SRA->RA_FILIAL + SRA->RA_MAT > cFilAte + cMatAte
                         Chave := 1
                         Exit
                      Endif
                   Elseif nOrdem == 2
                          If SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT > cFilAte + cCcAte + cMatAte
                             Chave := 1
                             Exit
                          Endif
                   Elseif nOrdem == 3
                          If SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT > cFilAte + cNomeAte + cMatAte
                             Chave := 1
                             Exit
                          Endif
                   Endif

                   //+--------------------------------------------------------------+
                   //?Cancela Impres? ao se pressionar <ALT> + <A>                ?
                   //+--------------------------------------------------------------+
                   If lEnd
                      Chave := 1
                      Exit
                   EndIF
	
                   //+--------------------------------------------------------------+
                   //?Consiste Parametrização do Intervalo de Impress?            ?
                   //+--------------------------------------------------------------+
                   If (Sra->Ra_Nome < cNomeDe) .Or. (Sra->Ra_Nome > cNomeAte) .Or. ;
                      (Sra->Ra_Mat  < cMatDe ) .Or. (Sra->Ra_Mat  > cMatAte ) .Or. ;
                      (Sra->Ra_CC   < cCcDe  ) .Or. (Sra->Ra_CC   > cCCAte  )
                      dbSkip(1)
                      Loop
                   EndIf
		
                   IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
                      dbSelectArea("SRA")
                      dbSkip()
                      Loop
                   EndIF
			
                   //+--------------------------------------------------------------+
                   //?Verifica Situacao e Categoria do Funcionario                 ?
                   //+--------------------------------------------------------------+
                   If !( SRA->RA_CATFUNC $ cCategoria )
                      dbSkip()
                      Loop
                   Endif
	
                   //+--------------------------------------------------------------+
                   //?Verifica Sindicatos - 99 Todos                               ?
                   //+--------------------------------------------------------------+
                   If cSindicato #"99" .And. SRA->RA_SINDICA # cSindicato
                      dbSkip()
                      Loop
                   EndIf

                   //+--------------------------------------------------------------+
                   //?Procura No Arquivo de Ferias o Periodo a Ser Listado         ?
                   //+--------------------------------------------------------------+
                   If mv_par19 == 2 .or. mv_par19 == 3
		              dbSelectArea( "SRH" )
                      If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
                         While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRH->RH_FILIAL + SRH->RH_MAT
                               lAbopec := !Empty(SRH->RH_ABOPEC)	//SE O PERIODO DE ABONO PECUNIARIO FOI DEFINIDO NA HORA DO CALCULO
                               cDatAbo := "NAO"
                               If SRH->RH_DATAINI >= dDtfDe .And. SRH->RH_DATAINI <= dDtfAte
                                  If SRH->RH_DABONPE > 0 .And. lAbopec	//DIAS ABONO PECUNIARIO # PERIODO DE ABONO
                                     If SRH->RH_ABOPEC == "1"
                                        cDatAbo:= DtoC(SRH->RH_DATAINI-SRH->RH_DABONPE)+" A "+Dtoc(SRH->RH_DATAINI-1)
                                     ElseIf SRH->RH_ABOPEC == "2"
                                            cDatAbo:= DtoC( SRH->RH_DATAFIM + 1 )+" A "+Dtoc(SRH->RH_DATAFIM+SRH->RH_DABONPE)
                                     Endif
                                  ElseIf SRH->RH_DABONPE > 0 .And. !lAbopec   
                                         If cAbono == "1"	//PARAMETRO MV_ABOPEC = 'S'
                                            cDatAbo:= DtoC(SRH->RH_DATAINI-SRH->RH_DABONPE)+" A "+Dtoc(SRH->RH_DATAINI-1)
                                         Else
                                            cDatAbo:= DtoC( SRH->RH_DATAFIM + 1 )+" A "+Dtoc(SRH->RH_DATAFIM+SRH->RH_DABONPE)
                                         Endif
                                  Endif

                                  nALin := nAlin + 1  

                                  //aVetor[nAlin,1]:= "FIL.: " + SRA->RA_FILIAL + " " + "MATRIC: " + SRA->RA_MAT + " " + "CART.PROF: " + AllTrim( SRA->RA_NUMCP ) + "/" + SRA->RA_SERCP
                                  //aVetor[nAlin,2]:= "PERIODO AQUISITIVO " + DTOC( SRH->RH_DATABAS ) + " A " + DTOC( SRH->RH_DBASEAT )
                                  //aVetor[nAlin,3]:= "PERIODO GOZO       " + DTOC( SRH->RH_DATAINI ) + " A " + DTOC( SRH->RH_DATAFIM )
                                  //aVetor[nAlin,4]:= "PERIODO ABONO      " + cDatAbo
                                     //              1         2         3         4
                                     //              1234567890123456789012345678901234567890
                                     //          2   GOZOU  FÉRIAS  RELATIVAS  AO  PERIODO DE
                                     //              99/99/9999 A 99/99/9999 DE 99/99/9999 A
                                  //aVetor[nAlin,1]:= "FL. " + SRA->RA_FILIAL + " MAT. " + SRA->RA_MAT + Iif( cPaisLoc == "BRA", " C.PROF. " + AllTrim( SRA->RA_NUMCP ) + "/" + SRA->RA_SERCP , "" ) 
                                  aVetor[nAlin,1]:= "GOZOU  FÉRIAS  RELATIVAS  AO  PERIODO DE"
                                  aVetor[nAlin,2]:= DTOC( SRH->RH_DATABAS ) + " A " + DTOC( SRH->RH_DBASEAT ) + " DE " + DTOC( SRH->RH_DATAINI ) + " A "
                                  aVetor[nAlin,3]:= DTOC( SRH->RH_DATAFIM ) + ". "
                                  aVetor[nAlin,4]:= mv_par14 
                                  aVetor[nAlin,5]:= " " 
                                  aVetor[nAlin,6]:= PADC( Alltrim( SM0->M0_NOMECOM ), 40 )
                                  cTipo:="I"
                                  FChkET320()
                               Endif
                               dbSkip()
                         Enddo
                      Endif
                   Endif
                   If mv_par19 == 1 .or. mv_par19 == 3
                      dbSelectArea( "SR3" )
                      IF dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
                         While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SR3->R3_FILIAL + SR3->R3_MAT 
                               If SR3->R3_DATA >= dPerDe .And. SR3->R3_DATA <= dPerAte .And. SR3->R3_PD == "000"
                                  nAlin:=nAlin+1
                                  dbSelectArea( "SX5" )
                                  If dbSeek( xFilial( "SX5" ) + "41" + SR3->R3_TIPO )
                                     cMotivo := fTAcento( SubStr(X5Descri(),1,15) )						
                                  Else
                                     cMotivo := "Nao Cad.Tab. 41"
                                  Endif
                                  dbSelectArea( "SR7" )
                                  If dbSeek(SR3->R3_FILIAL+SR3->R3_MAT+DTOS(SR3->R3_DATA))
                                     cFun:= DescFun(SR7->R7_FUNCAO,SR7->R7_FILIAL)
                                  Else
                                     cFun:= "*** Nao Cadastrado ***"
                                  Endif
			                      dbSelectArea( "SR3" )
                                  //              1   FL. 999999 MAT. 999999 C.PROF. 99999/999
                                  //                           1         2         3         4
                                  //                  1234567890123456789012345678901234567890
                                  //              2   XXXXXXXXX XX 99/99/9999 P/ R$ 99,999.99
                                  //              3   NA FUNÇÃO DE XXXXXXXXXXXXXXXXXXXXXXXXXXX
                                  //              4   CBO 999999 POR MOTIVO DE XXXXXXXXXXXXXXX
                                  //                  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                  //
                                  //              6        BRASILUX TINTAS TECNICAS LTDA.
                                  //aVetor[nAlin,1] := "FIL.: " + SRA->RA_FILIAL + " " + "MATRIC: " + SRA->RA_MAT + " " + Iif( cPaisLoc == "BRA", "CART.PROF: " + AllTrim( SRA->RA_NUMCP ) + "/" + SRA->RA_SERCP , "" )
                                  //aVetor[nAlin,2] := "AUMENTADO EM " + DtoC(SR3->R3_DATA) + " P/ " + cSimb + " " + ALLTRIM( Transform( SR3->R3_VALOR, "@E 99,999.99" ) )
                                  cFun := Alltrim( cFun ) + Space(50)
                                  cFun := SubStr( cFun, 1, 27)
                                  //aVetor[nAlin,3] := "NA FUNCAO DE "  + cFun + Iif( cPaisLoc == "BRA", " C.B.O. " + fCodCBO( SRA->RA_FILIAL, SR7->R7_FUNCAO, dDataBase ), "" )
                                  //aVetor[nAlin,4] := "POR MOTIVO DE " + SubStr( cMotivo, 1, 36 )
                                  //aVetor[nAlin,5] := " "
                                  //aVetor[nAlin,6] := " "
                                  //aVetor[nAlin,1] := "FL. " + SRA->RA_FILIAL + " MAT. " + SRA->RA_MAT + Iif( cPaisLoc == "BRA", " C.PROF. " + AllTrim( SRA->RA_NUMCP ) + "/" + SRA->RA_SERCP , "" )
                                  aVetor[nAlin,1] := "AUMENTADO EM " + DTOC( SR3->R3_DATA ) + " P/ " + cSimb + " " + ALLTRIM( Transform( SR3->R3_VALOR, "@E 99,999.99" ) )
                                  aVetor[nAlin,2] := "NA FUNÇÃO DE " + cFun
                                  aVetor[nAlin,3] := Iif( cPaisLoc == "BRA", "CBO " + fCodCBO( SRA->RA_FILIAL, SR7->R7_FUNCAO, dDataBase ), "" ) + " POR MOTIVO DE " + SubStr( cMotivo, 1, 15 )
                                  aVetor[nAlin,4] := ""
                                  aVetor[nAlin,5] := ""
                                  aVetor[nAlin,6] := PADC( Alltrim( SM0->M0_NOMECOM ), 40 )
                                  cTipo           := "I"
                                  FChkET320()
                               Endif
                               dbSkip()	
                         Enddo
                      Endif         
                   Endif
                   dbSelectArea( "SRA" )
                   dbSkip()
             Enddo
             IF Chave == 1
                Exit
             Endif
             If Eof()
                Exit
             Endif
       Enddo
       cTipo := "F"
       FChkET320()

       //+--------------------------------------------------------------+
       //?Termino do Relatorio                                         ?
       //+--------------------------------------------------------------+
       dbSelectArea( "SRA" )
       Set Filter to
       dbSetOrder(1)
Return

Static FuncTion FChkET320()
       Local C
       Local I

       If (cTipo == "I" .And. nAlin == nColunas) .Or. (cTipo == "F" .And. nAlin > 0)
          For C := 1 To 6
              nCol := 0005
              For I := 1 To nColunas
                  oPrint:Say(nLin, nCol, aVetor[I,C], oFont1, 100, CLR_BLACK )
                  nCol += 835
                  aVetor[I,C] := " "
              Next
              If C == 5
                 nLin += 0037.3
              Else
                 nLin += 0037.5
              Endif
          Next
          nLin += 47.2
          nQtdEtq++
          If nQtdEtq >= 12
             nQtdEtq := 1
             oPrint:EndPage()
             oPrint:StartPage()
             nLin    := 0000
          Endif
          nAlin:=0
       Endif

       If cTipo == "F"
          oPrint:EndPage()     
          oPrint:Preview() 
       Endif
Return( nil )

/*
Função para geração dos parâmetros
*/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function fValPerg( _cPerg )
       Local _aArea   := GetArea()
       Local aHelpPor := {}
       //Local aHelpEng := {}
       //Local aHelpSpa := {}

       //           X1_GRUPO , X1_ORDEM, X1_PERGUNT             , X1_VAR01  , X1_VARIAVL, X1_TIPO, X1_TAMANHO, X1_DECIMAL, X1_GSC, X1_VALID    , X1_F3   , X1_PICTURE , X1_DEF01   , X1_DEF02         , X1_DEF03, X1_DEF04, X1_DEF05, X1_HELP
       //u_zPutSX1( _cPerg   , "01"    , "Codigo do Armazem    ", "mv_par01", "mv_ch1"  , "C"    ,  2        , 0         , "G"   , ""          , "NNR"   , ""         , ""         , ""               , ""      , ""      , ""      , aHelpPor[1] )
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "01" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código da Filial Inicial para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "01"    , "Filial De ?          ", "mv_par01", "mv_ch1"  , "C"    ,  6        , 0         , "G"   , ""          , "XM0"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "02" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código da Filial Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "02"    , "Filial AtÚ ?         ", "mv_par02", "mv_ch2"  , "C"    ,  6        , 0         , "G"   , "NaoVazio"  , "XM0"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "03" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código do Centro de Custo Inicial para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "03"    , "Centro de Custo De ? ", "mv_par03", "mv_ch3"  , "C"    ,  9        , 0         , "G"   , ""          , "CTT"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "04" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código do Centro de Custo Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "04"    , "Centro de Custo Até ?", "mv_par04", "mv_ch4"  , "C"    ,  9        , 0         , "G"   , "NaoVazio"  , "CTT"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "05" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código de Matrícula Inicial para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "05"    , "Matricula De ?       ", "mv_par05", "mv_ch5"  , "C"    ,  6        , 0         , "G"   , ""          , "SRA02A", ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "06" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código de Matrícula Final para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "06"    , "Matricula Até ?      ", "mv_par06", "mv_ch6"  , "C"    ,  6        , 0         , "G"   , "NaoVazio  ", "SRA02A", ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "07" ) )
          aAdd( aHelpPor, "Informe o Nome do Funcionário Inicial para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "07"    , "Nome De ?            ", "mv_par07", "mv_ch7"  , "C"    , 30        , 0         , "G"   , "          ", ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "08" ) )
          aAdd( aHelpPor, "Informe o Nome do Funcionário Final para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "08"    , "Nome Até ?           ", "mv_par08", "mv_ch8"  , "C"    , 30        , 0         , "G"   , "NaoVazio  ", ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "09" ) )
          aAdd( aHelpPor, "Informe ou selecione uma Categoria p/ Funcionários para filtro dos dados.")
          u_zPutSX1( _cPerg   , "09"    , "Categorias ?         ", "mv_par09", "mv_ch9"  , "C"    , 15        , 0         , "G"   , "fCategoria", ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "10" ) )
          aAdd( aHelpPor, "Informe a Data do Período Inicial que deseja filtrar os dados.")
          u_zPutSX1( _cPerg   , "10"    , "Periodo De ?         ", "mv_par10", "mv_cha"  , "D"    ,  8        , 0         , "G"   , "NaoVazio"  , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "11" ) )
          aAdd( aHelpPor, "Informe a Data do Período Final que desejá filtrar os dados.")
          u_zPutSX1( _cPerg   , "11"    , "Periodo Ate ?        ", "mv_par11", "mv_chb"  , "D"    ,  8        , 0         , "G"   , "NaoVazio"  , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "12" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código do Sindicato que deseja imprimir, ou informe 99, que estará selecionando todos os sindicatos cadastrados.")
          u_zPutSX1( _cPerg   , "12"    , "Sindicato(99-Todos) ?", "mv_par12", "mv_chc"  , "C"    ,  2        , 0         , "G"   , "NaoVazio"  , "RCE"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "13" ) )
          aAdd( aHelpPor, "Informe o Número de Colunas que desejam configurar para impressão das Etiquetas.")
          u_zPutSX1( _cPerg   , "13"    , "Numero Colunas ?     ", "mv_par13", "mv_chd"  , "N"    ,  1        , 0         , "G"   , "naovazio"  , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "14" ) )
          aAdd( aHelpPor, "Informe para Férias.")
          u_zPutSX1( _cPerg   , "14"    , "Informe para férias  ", "mv_par14", "mv_che"  , "C"    , 40        , 0         , "G"   , ""          , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "15" ) )
          aAdd( aHelpPor, "Informe o tipo de Etiqueta que  será impressa: Entrada (Admissão) ou Saída (Demissão).")
          u_zPutSX1( _cPerg   , "15"    , "Tipo ?               ", "mv_par15", "mv_chf"  , "N"    ,  1        , 0         , "C"   , ""          , ""      , ""        , "Entrada"  , "Saida"          , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "16" ) )
          aAdd( aHelpPor, "Informe ou Selecione as Situações dos Funcionários para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "16"    , "Situações ?          ", "mv_par16", "mv_chg"  , "C"    ,  5        , 0         , "G"   , "fSituacao" , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "17" ) )
          aAdd( aHelpPor, "Informe em qual coluna se inicia a impressão das informações")
          u_zPutSX1( _cPerg   , "17"    , "Coluna Inicial       ", "mv_par17", "mv_chh"  , "N"    ,  1        , 0         , "G"   , ""          , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "18" ) )
          aAdd( aHelpPor, "Informe a ordem das etiquetas para que sejam impressas.")
          u_zPutSX1( _cPerg   , "18"    , "Ordem de Impressao   ", "mv_par18", "mv_chi"  , "N"    ,  1        , 0         , "C"   , ""          , ""      , ""        , "Matricula", "Centro de Custo", "Nome"  , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "19" ) )
          aAdd( aHelpPor, "Escolha o tipo de etiqueta a ser impressa. Alteração Salarial ou Férias.")
          u_zPutSX1( _cPerg   , "19"    , "Tipo de Etiqueta     ", "mv_par19", "mv_chj"  , "N"    ,  1        , 0         , "C"   , ""          , ""      , ""        , "Alteração Salarial", "Férias", ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "20" ) )
          aAdd( aHelpPor, "Informe em qual linha de etiqueta se inicia a impressão das informações")
          u_zPutSX1( _cPerg   , "20"    , "Linha Inicial       ", "mv_par20", "mv_chh"  , "N"    ,  2        , 0         , "G"   , ""          , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif

       RestArea( _aArea )
Return*/
