#include 'protheus.ch'    
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Ponto Entrada - Pedidos TLV ³ Autor ³ Janaina      ³ Data ³ 12/03/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Campos Customizados no Pedido - Faturamento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 				                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nao há                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ HISTORICO DE ATUALIZACOES DA ROTINA ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Desenvolvedor   ³ Data   ³Solic.³ Descricao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Mario           ³07/08/09³      ³Gravacao das comissoes de acordo com cadastro. ³±±
±±³                 ³        ³      ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function TMKVFIM (cNumAtend,cNumPedido) 
     Local aArea   := GetArea()
     //Local nVend   := fa440CntVen() // Numero M ximo de Vendedores
     //Local nPos    := 0      
     //Local aComiss := {}
     Local aCab2 := {},aItens2 := {},aAux := {},_cFilial,j
     Local _lOpen        := .F. //LGS#20200204 - Adequação para release 12.1.25
     //Local cPedAnt, i
     Private lMsErroAuto,lMsHelpAuto
     Private _cAliasSX3  := GetNextAlias() //LGS#20200204 - Adequação para release 12.1.25
     /*
     DbSelectArea("SUA")       
     SUA->(DbSetOrder(1))
     SUA->(DbSeek(xFilial("SUA") + cNumAtend))
     */
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        // ABERTURA DO DICIONÁRIO SX3 - LGS#20200204 - Adequação para release 12.1.25
        OpenSXs( NIL, NIL, NIL, NIL, NIL, _cAliasSX3, "SX3", NIL, .F. )
        _lOpen := Select( _cAliasSX3 ) > 0
        
        If _lOpen
           DbSelectArea("SC5")
           SC5->(DbSetOrder(1))
           If SC5->(DbSeek(xFilial("SC5") + cNumPedido))
              Reclock("SC5", .F.)
	             SC5->C5_REDESP 	   := SUA->UA_REDESP  
                 SC5->C5_TIPOVEN 	   := SUA->UA_TIPOVEN
                 SC5->C5_BOLETO 	   := SUA->UA_BOLETO
                 SC5->C5_PEDPROG	   := SUA->UA_PEDPROG
                 //SC5->C5_OBS 	   := SUA->UA_OBS
                 SC5->C5_BANCO 	   := SUA->UA_BANCO
                 SC5->C5_PARC1 	   := SUA->UA_PARC
                 SC5->C5_DATA1	   := SUA->UA_DATA1
                 SC5->C5_PARC2 	   := SUA->UA_PARC2
                 SC5->C5_DATA2 	   := SUA->UA_DATA2
                 SC5->C5_PARC3 	   := SUA->UA_PARC3
                 SC5->C5_DATA3 	   := SUA->UA_DATA3
                 SC5->C5_PARC4     := SUA->UA_PARC4
                 SC5->C5_DATA4     := SUA->UA_DATA4
                 /*SC5->C5_OBSPED	   := SUA->UA_OBSPED
                 SC5->C5_OBSSC5	   := SUA->UA_OBSSC5
                 SC5->C5_OBSNFS	   := SUA->UA_OBSNFS*/
                 SC5->C5_CLIRET	   := SUA->UA_CLIRET
                 SC5->C5_LOJARET   := SUA->UA_LOJARET
              MsUnlock()

              _cFilial := ALLTRIM(SC5->C5_FILIAL)
              aCab2 := DetCampos("SC5")   
              aItens2 := {} 
              dbselectarea("SC6")
              dbsetorder(1)  
              dbseek(xFilial("SC6")+cNumPedido,.t.)
              while !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == _cFilial) .AND. (alltrim(SC6->C6_NUM) == alltrim(cNumPedido))
                    aAux := {}    
                    aadd(aAux,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
                    aadd(aAux,{"AUTDELETA","N",Nil})

                    aLinha := {}
                    aLinha := DetCampos("SC6")
                    for j := 1 to len(aLinha)
                        aadd(aAux,{aLinha[j,1],aLinha[j,2],aLinha[j,3]})
                    next 
                    aadd(aItens2,aAux)		
                    dbselectarea("SC6")
                    dbskip()
              enddo 
              aadd(aCab2,{"C5_NUM"   ,cNumPedido,Nil}) 

              lMsErroAuto := .f.
              lMsHelpAuto := .f.
              MsgRun("Alterando ped atual...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab2, aItens2, 4 ) } )

              /* Gravacao das comissoes
                 dbSelectArea("SC6")
                 SC6->(dbSetOrder(1))
                 SC6->(dbSeek(xFilial("SC6")+SC5->cNumPedido))
                 SC6->C6_ULPRECO := SUB->UB_ULPRECO
                 SC6->C6_CATALIS := SUB->UB_CATALIS
                 SC6->C6_ENTRIME := SUB->UB_ENTRIME
              MsUnlock()*/
           Endif
           DbSelectArea( _cAliasSX3 )
           DbCloseArea()
        Else
           MessageBox( "Não foi possível abrir o dicionário SX3.", "Atenção...", 16 )
        Endif
        RestArea(aArea)
     Endif
Return()

Static Function DetCampos( cAlias )
       Local aArea := GetArea()
       Local aCampos := {},cAux,xValor

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek( cAlias )
       While !EOF() .And. X3_ARQUIVO = cAlias
             If X3Uso(X3_USADO) .AND. !(X3_CONTEXT = "V") .and. !(ALLTRIM(X3_CAMPO) == "C6_FILIAL") .and. !(ALLTRIM(X3_CAMPO) == "C5_NUM") .AND. !(ALLTRIM(X3_CAMPO) == "C5_FILIAL") .AND. !(ALLTRIM(X3_CAMPO) == "C5_NUM")
                cAux := alltrim(cAlias)+"->"+X3_CAMPO
                xValor := &cAux
                If !empty(xValor)
                   aadd(aCampos,{X3_CAMPO   ,xValor,.F.})		
                Endif
             Endif
             dbSkip()
       End*/

       dbSelectArea( _cAliasSX3 )
       dbSetOrder(1)
       dbSeek( cAlias )
       While !EOF() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) = cAlias
             If X3Uso( ( _cAliasSX3 )->( X3_USADO )) .AND. !( ( _cAliasSX3 )->( X3_CONTEXT ) = "V") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_FILIAL") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_NUM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_FILIAL" ) .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_NUM" )
                cAux := Alltrim( cAlias ) + "->" + ( _cAliasSX3 )->( X3_CAMPO )
                xValor := &cAux
                If !empty(xValor)
                   aadd( aCampos, { ( _cAliasSX3 )->( X3_CAMPO ), xValor, .F.} )
                Endif
             Endif
             dbSkip()
       End

       RestArea(aArea)
Return(aCampos)
