#include "protheus.ch"
#include "topconn.ch"
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
  ±±∫Programa  ≥  EMP650  ∫Autor  ≥ LuÌs Gustavo       ∫ Data ≥  14/09/04   ∫±±
  ±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
  ±±∫Desc.     ≥ Ponto de entrada para ajustes na quantidade empenhada, de- ∫±±
  ±±∫          ≥ vido ao ajuste de cor das fÛrmulas.                        ∫±±
  ±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
  ±±∫Uso       ≥ BRASILUX                                                   ∫±±
  ±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
  ±±∫AlteraÁıes  ≥  28/02/14  Tiago Lucio/Chaus  1. AlteraÁ„o do ponto de 	∫±±
  ±±∫						  entrada para correÁ„o do empenho para os 		∫±±
  ±±∫                         armazÈns corretos de acordo processo da 		∫±±
  ±±∫                         Brasilux para as frabricas 1 e 2;       		∫±±
  ±±∫ 			 ≥  14/03/14  Tiago Lucio/Chaus  2. RemoÁ„o dos Materiais 	∫±±
  ±±∫                         de Consumo empenhados na SD4 , È aplicado por ∫±±
  ±±∫                         meio do MV_XHABZZF   							∫±±
  ±±∫ 			 ≥ 29/05/14  Tiago Lucio/Chaus  3. RemoÁ„o dos Materiais 	∫±±
  ±±∫                         que s„o requisitados via armazem              ∫±±
  ±±∫                           							                ∫±±
  ±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

User Function EMP650()
     Local cAlias  := Alias()                                            //Alias Atual
     Local aArea   := U_PegaArea({"SB1","SG1","SC2","SZ1","SZ4"})
     Local _cTipo    := ""
     Local _cNome    := ""
     Local _aArea    := GetArea()
     Local _cProduto
     Local _cOrdem   := SC2->C2_NUM
     Local _cItem    := SC2->C2_ITEM
     Local _cSeqPa   := SC2->C2_SEQUEN
     Local _cIteGrd  := SC2->C2_ITEMGRD
     Local _nVolume  := 0
     Local _nY       := 0
     Local nY
     Local _cGrpEmp := alltrim(FWGrpCompany())


do case 
case _cGrpEmp == '01' //Empresas do grupo BRASILUX

        DbSelectArea("SZ4")                                                 //CaracterÌstica + Linha
        DbSelectArea("SZ1")                                                 //Linhas
        DbSelectArea(cAlias) 
        //DISSOLTEX
       
/*        If (cnumemp == "01060101") // 19/01/15 solicitado por Silene (AndrÈ)
            DbSelectArea("SB1") 
            DbSetOrder(1)    
            DbSeek(xFilial("SB1")+SC2->C2_PRODUTO, .t.)   
            If found() .and. (alltrim(SB1->B1_TIPO) $ ".PA.PI")
                For nY := 1 to Len(aCols)
                    DbSeek(xFilial("SB1")+aCols[nY][1], .t.)   
                    If found()         
                        If Trim(SB1->B1_XREQUIS)=='S' .and. (alltrim(SB1->B1_TIPO) $ "MP.MC")   //Produto È requisitado por prÈ-requisiÁ„o
                            aCols[nY][2]:=0 
                        EndIf
                    Endif
                Next
            Endif
        Endif */
        //MATRIZ E DISSOLTEX
        If (cnumemp == "01010101") .OR. (cnumemp == "01060101") //xFilial("SC2") $ '01'   //Processo somente para a Filial 01 (Matriz)   
           //Cleber(12/01/12) -> Acertar almoxarifados dos empenhos de acordo com o almoxarifado da OP emitida (Fabrica 1 ou 2)
           DbSelectArea("SB1")                                     //Seleciona tabela SB1 (CADASTRO DE PRODUTOS)
           DbSetOrder(1)    
           DbSeek(xFilial("SB1")+SC2->C2_PRODUTO, .t.)   
           If found() .and. (alltrim(SB1->B1_TIPO) $ ".PA.PI.MP")
              For nY := 1 to Len(aCols)
                  DbSeek(xFilial("SB1")+aCols[nY][1], .t.)   
                  If found()         
                     //alterado Tiago Lucio/Chaus 29/05/14    
                     If Trim(SB1->B1_XREQUIS)=='S' .and. (alltrim(SB1->B1_TIPO) $ "MP.MC")  //Produto È requisitado por armazem, nao pode ser empenhado na SD4
                        aCols[nY][2]:=0 
                     EndIf
                     //alterado Tiago Lucio/Chaus 28/02/14  
                     If TRIM(SC2->C2_LOCAL)=='02'  
                        If TRIM(SB1->B1_TIPO)=='MP'  
                           If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriaÁ„o indireta
                              aCols[nY][3] := '99' 
                              //aCols[nY][3] := 'R1' 								
                           ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                  aCols[nY][3] := 'R1' 
                           Else
                              aCols[nY][3] := '01'
                           EndIf	
                        ElseIf TRIM(SB1->B1_TIPO)=='PI'
                               If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriaÁ„o indireta
                                  aCols[nY][3] := '99' 
                                  //aCols[nY][3] := 'R1' 								
                               ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                      aCols[nY][3] := 'R1' 
                               Else
                                  aCols[nY][3] := '02'
                               Endif
                        EndIf
                     ElseIf TRIM(SC2->C2_LOCAL)=='20'  
                            If TRIM(SB1->B1_TIPO)=='MP'
                               If TRIM(SB1->B1_APROPRI)=='I'     //MP de apropriaÁ„o indireta
                                  aCols[nY][3] := '99' 
                                  //aCols[nY][3] := 'R2' 								
                               ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                      aCols[nY][3] := 'R2' 
                               Else
                                  aCols[nY][3] := '10' 
                               EndIf
                            ElseIf TRIM(SB1->B1_TIPO)=='PI'
                                   If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriaÁ„o indireta
                                      aCols[nY][3] := '99' 
                                      //aCols[nY][3] := 'R2' 								
                                   ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                          aCols[nY][3] := 'R2' 
                                   Else
                                      aCols[nY][3] := '20'
                                   Endif
                            EndIf
                     ElseIf TRIM(SC2->C2_LOCAL)$ '03.P1.R1'  //Empenho de MP de Ordem de Envase  fabrica 1
                            If TRIM(SB1->B1_TIPO)=='MP' 
                               If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriaÁ„o indireta
                                  aCols[nY][3] := '99' 
                                  //aCols[nY][3] := 'R1' 
                               ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                      aCols[nY][3] := 'R1' 
                               Else
                                  aCols[nY][3] := '01' 
                               EndIf	
                            ElseIf TRIM(SB1->B1_TIPO)=='PI'
                                   If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriaÁ„o indireta
                                      aCols[nY][3] := '99' 
                                      //aCols[nY][3] := 'R1' 								
                                   ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                          aCols[nY][3] := 'R1' 
                                   Else
                                      aCols[nY][3] := '02'
                                   Endif
                            Endif
                     ElseIf TRIM(SC2->C2_LOCAL)$ '30.P2.R2'  //Empenho de MP de Ordem de Envase  fabrica 2
                            If TRIM(SB1->B1_TIPO)=='MP' 
                               If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriaÁ„o indireta
                                  aCols[nY][3] := '99' 
                                  //aCols[nY][3] := 'R2' 								
                               ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                      aCols[nY][3] := 'R2' 
                               Else
                                  aCols[nY][3] := '10' 
                               EndIf	
                            ElseIf TRIM(SB1->B1_TIPO)=='PI'
                                   If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriaÁ„o indireta
                                      aCols[nY][3] := '99' 
                                      //aCols[nY][3] := 'R2' 								
                                   ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                          aCols[nY][3] := 'R2' 
                                   Else
                                      aCols[nY][3] := '20'
                                   Endif
                            Endif
                     EndIf
                  Endif
              Next
           Endif
        Endif

        U_VoltaArea(aArea)
        DbSelectArea(cAlias)
        
case _cGrpEmp == "11" //Grupo TECPOLPA
        // altera o lote economico do blend para gerar os empenhos
        //conforme a quebra definida no campo Vol p. Tanque
        /*
        Data: 29/06/2016 - Autor: Mauricio/Chaus
        Objetio: Ponto de entrada executado pela rotina MATA650 - Abertura de Ordens de Produ¡Ño e o
                 mesmo » executado antes do sistema gerar os empenhos dos insumos (SD4), onde pose
                 ser feito adequa¡oes nos insumos empenhados.
        Objetivo:
                 1) Na geraÁ„o do empenho mudar o almoxarifado da SB1( Padr„o TOTVS) para o almoxarifado
                 de produÁ„o definido no par‚metro GetMV("TP_ALMPCP")  ==> EPCP
        aCols[n,x] - Onde o n e o  numero da linha  e x pode ser:
        [1] CÛdigo do Produto a ser empenhado
        [2] Quantidade do empenho
        [3] Almoxarifado do empenho
        [4] Sequ’ncia do componente na estrutura (Campo G1_TRT)
        [5] Sub-Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade do tipo "S")
        [6] Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade)
        [7] Data de validade do Lote (Somente deve ser preenchido se o  produto utilizar rastreabilidade)
        [8] Localiza°—o utilizada no empenho (Somente deve ser preenchido se o produto utilizar controle de localiza°—o f√sica)
        [9] Numero de Sªrie (Somente deve ser preenchido se o produto utilizar controle de localiza°—o f√sica)
        [10] 1a. Unidade de Medida do Produto
        [11] Quantidade do Empenho na 2a. Unidade de Medida
        [12] 2a. Unidade de Medida do Produto
        [13] Coluna com valor lÄgico que indica se a linha esta deletada (.T.) ou n—o (.F.)
        */
        //If _cSeqPa != "001"
           For _nY := 1 TO LEN(aCols)
               _cProduto  	:= aCols[_nY,1]
               _cTipo := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"B1_TIPO")
               _cNome := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"B1_DESC")
               If _cTipo == "PI" .AND. SUBSTR( _cNome, 1, 5 ) == "BLEND"
                  dbSelectArea("SC2") //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD                                                                                                                   
                  dbSetOrder(1)
                  dbSeek( xFilial("SC2") + _cOrdem + _cItem + "001" + _cIteGrd )

                 _nVolume := SC2->C2_XVOLTNQ

                 DbSelectArea("SB1")
                 DbSetOrder(1)
                 dbSeek( xFilial("SB1") + _cProduto )
                 RecLock( "SB1", .F. )
                  SB1->B1_LE := _nVolume
                 MsUnlock()
              Endif
          Next
       //Endif
       Restarea( _aArea )
       xEMP650()
endcase 
Return(.t.)

Static Function xEMP650()
       Local _aArea := GetArea()
       Local _cLocPad := GetMV("TP_ALMPCP") //Almoxarifado padr—o para empenho
       Local _I

       For _I := 1 to len(aCols)
           aCols[_I,3] := _cLocPad
       Next _I
       RestArea(_aArea)
Return()
