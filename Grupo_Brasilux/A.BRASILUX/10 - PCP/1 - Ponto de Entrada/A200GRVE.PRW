#include "rwmake.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A200GRVE บAutor  ณ Fernando Roquete   บ Data ณ  09/03/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica็ใo da estrutura do produto.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//30/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function A200GRVE() 
     Local cArea    := alias()
     Local aAreaAnt := U_PegaArea({"SB1","SG1","SM2"})
     Local _VlrDolar  := 0

     Local  _cNomArq  := ""
     Local  _aCampos  := {}
     Local  _aCampos3 := {}
     //Local  _aErro    := {}
     //Local  _aTam     := {}
     //Local  _cMsg     := OemToAnsi("Mapa de Divergencias")
     Private _xUmPai
     Private _TpPai
     Private _TotQtd

     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
        aAdd( _aCampos, { "COMP"  , "C", 26, 0})
        aAdd( _aCampos, { "QTD"   , "N", 14, 6})
        aAdd( _aCampos, { "CUSTO" , "N", 14, 3})
        aAdd( _aCampos, { "PERDA" , "N", 10, 6})
        aAdd( _aCampos, { "CUSREA", "N", 14, 3})
        aAdd( _aCampos, { "CUSDOL", "N", 14, 3})
        aAdd( _aCampos, { "PESESP", "N", 13, 5})
        /********************************************************************************************************************************/
        /*** BLOCO ALTERADO EM 30/09/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25                  ***/
        //_cNomArq := CriaTrab(_aCampos, .T.)
        //DbUseArea(.T., , _cNomArq, "CONF", .F., .F.)
        oTempTable := FWTemporaryTable():New( "CONF" )
        oTemptable:SetFields( _aCampos )
        oTempTable:Create()
        /********************************************************************************************************************************/

        cCadastro:= "MAPA DE DIVERGENCIAS - ESPECIFICO"
        _nQtd     := 1
        nEstru    := 0
        _TotQtd   := 0.000
        _cNomeArq := Estrut2(cCodAtual, _nQtd, "EST", , .t.)
        _TpPai    := ""
        _TotRea   := 0.000
        _TotDol   := 0.000
        _cLocal   := ""
        _SomPes   := 0.000
        _VlrDolar := 0 // Deu erro em 20/12/02 para visualizar.

        DbSelectArea("SB1")       // Verificacao da estrutura p/ produtos por indice
        DbSetOrder(1)
        DbSeek(xFilial("SB1")+ccodatual, .f.)
        If Found()
           _xUmPai := SB1->B1_UM
           _TpPai  := SB1->B1_TIPO
           DbSelectArea("EST")
           DbGoTop()
           While !Eof()
                 _CM1 := 0
                 If Val(EST->NIVEL) == 1
                    DbSelectArea("SB1")
                    DbSeek(xFilial("SB1")+EST->COMP, .F.)
                    If Found()
                        // produto de custeio
                        If U_IsProdCusto(EST->COMP)
                           EST->(dbSkip())
                           Loop
                        Endif 
                       _cLocal := SB1->B1_LOCPAD
                       _Pesesp := SB1->B1_PESOESP
                       If SB1->B1_TIPO == "MP"
                          _CM1      := SB1->B1_UPRC //Cleber, 29/08/02 - Pegar ๚lt. pre็o e nใo Custo M้dio
                          _VlrDolar := 0.00
                       Else
                          _CM1 := U_CUSTOPRO(Est->Comp)
                       Endif
                       DbSelectArea("SG1")
                       DbSetOrder(1)
                       DbSeek(xFilial("SG1")+EST->CODIGO+EST->COMP+EST->TRT, .F.)
                       If Found()
                          DbSelectArea("SM2")
                          DbSetOrder(1)
                          DbSeek(dDataBase, .F.)
                          If Found()
                             _VlrDolar := SM2->M2_MOEDA2
                          Endif
                          DbSelectArea("CONF")
                          Reclock("CONF", .T.)
                             CONF->Comp   := EST->COMP
                             CONF->Qtd    := SG1->G1_PERC
                             CONF->CusRea := Round(EST->QUANT * _CM1, 3)
                             CONF->CUSTO  := _CM1
                             CONF->PERDA  := SG1->G1_PERDA
                             If _VlrDolar # 0.00
                                CONF->CUSDOL := Round(EST->QUANT / _VlrDolar, 3)
                             Endif
                             CONF->PESESP := Round(_Pesesp, 5)
                          MsUnlock()
                          _TotQtd := _TotQtd+SG1->G1_PERC
                          _TotRea := _TotRea+CONF->CUSREA
                          _TotDol := _TotDol+CONF->CUSDOL
                          _SOMPES := _SOMPES + (CONF->QTD / CONF->PESESP)
                       Endif
                    Endif
                 Endif
                 DbSelectArea("EST")
                 DbSkip()
           EndDo
           If _TotQtd # 0.00      // Nao exibe o browse na exclusao
              Reclock("CONF", .T.)
                 CONF->COMP   := "TOTAL:(%) "+cCodAtual
                 CONF->QTD    := _TotQtd
                 CONF->CUSREA := _TotRea
                 CONF->CUSDOL := _TotDol
              MsUnlock()
           Endif
        Endif
        If _TotQtd # 0.00      // Nao exibe o browse na exclusao
           DbSelectArea("CONF")
           DbGoTop()
           _cmarca    := Getmark()
           _aCampos3  :={}
           aAdd(_aCampos3, { "COMP"  , "COMPONENTE"  , "@!"               })
           aAdd(_aCampos3, { "QTD"   , "QUANTIDADE"  , "@RE 999999.999999"})
           aAdd(_aCampos3, { "CUSTO" , "CUSTO UN(R$)", "@RE 999,999.999"  })
           aAdd(_aCampos3, { "PERDA" , "PERDA(%)"    , "@RE 999.99999"    })
           aAdd(_aCampos3, { "CUSREA", "CUSTO R$"    , "@RE 999,999.999"  })
           aAdd(_aCampos3, { "CUSDOL", "CUSTO US$"   , "@RE 999,999.999"  })

           /*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            ณ Cria o Dialogo Principal para a Selecao de Opcoes                   ณ
            ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
           @ 020,076 TO 275,500 DIALOG oTools TITLE "Mapa de Divergencias - Especifico"
           @ 005,005 TO 100,200 BROWSE "CONF" FIELDS _aCampos3
           /*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            ณMonta os Botoes de Execucao ou Finalizacao do Dialogo (oTools)       ณ
           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
           @ 105,170 BMPBUTTON TYPE 1 ACTION _Sair()
           /*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            ณAtiva o Dialogo Princial (oTools)                                    ณ
            ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
           ACTIVATE DIALOG oTools CENTERED
        Endif
        // Deleta Arquivo Temporario
        DbSelectArea("CONF")
        DbCloseArea()
        //Ferase(_cNomArq+".DBF")
        oTempTable:Delete()

        U_VoltaArea(aAreaAnt)
        If !empty(cArea)
           DbSelectArea(cArea)
        Endif 
     Endif
Return    

Static Function _Sair()
       Local _xPesoEsp, lAtPesos
       lAtPesos := .f. //Identifica se vai atualizar pesos especํ. de prods rel. e esse PI
       If (_TotQtd # 100) .and. (_TpPai # "PA")
          MsgStop("<A L E R T A>   A ESTRUTURA ESTA INCORRETA DEVE SER ALTERADA!")
       Endif
       If !(cNumEmp == "01010104") .and. (_TpPai # "PA")
          DbSelectArea("SB1")
          DbSetOrder(1)
          DbSeek(xFilial("SB1")+cCodAtual, .t.)
          If Found()
             RecLock("SB1", .f.)
                SB1->B1_PESOESP := (100 / _SOMPES)
             MsUnLock()
             _xPesoEsp := SB1->B1_PESOESP
             lAtPesos := .t.
          Endif   
          DbSelectArea("EST")
          DbGoTop()
          While !Eof()
               // produto de custeio
               If U_IsProdCusto(EST->COMP)
                  EST->(dbSkip())
                  Loop
               Endif 

                If Val(EST->NIVEL) == 1
                   DbSelectArea("SB1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SB1")+EST->COMP, .t.)
                   DbSelectArea("SG1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SG1")+EST->CODIGO+EST->COMP+EST->TRT, .t.)
                   If Found()
                      RecLock("SG1", .f.)
                         If _TpPai == "PA"
                            SG1->G1_QUANT := Round(SG1->G1_PERC, 6)
                         Else
                            If (Alltrim(SB1->B1_UM) == Alltrim(_xUmPai))
                               SG1->G1_QUANT := Round(SG1->G1_PERC / 100, 6)
                            Else
                               SG1->G1_QUANT := Round(_xPesoEsp * (SG1->G1_PERC / 100), 6)
                            Endif
                         Endif
                      MsUnLock()
                   Endif
                Endif
                DbSelectArea("EST")
                DbSkip()
          Enddo
       Endif
       If lAtPesos
                MsgBox("Atencao! O Programa ira' recalcular os Pesos Especificos"+chr(13)+;
                       "e podera' demorar! Nao tente interromper o processamento"+chr(13)+;
                       "pois podera' comprometer as estruturas de Produtos!", "Aten็ใo...", "INFO")
                U_CalcPesoEsp(cCodAtual)
       Endif
       DbSelectArea("EST")
	   DbCloseArea()
	   Close(oTools)
Return
