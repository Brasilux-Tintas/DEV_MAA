#include "protheus.ch"
#include "topconn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³  EMP650  ºAutor  ³ Luís Gustavo       º Data ³  14/09/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Ponto de entrada para ajustes na quantidade empenhada, de- º±±
  ±±º          ³ vido ao ajuste de cor das fórmulas.                        º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX                                                   º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±ºAlterações  ³  28/02/14  Tiago Lucio/Chaus  1. Alteração do ponto de   º±±
  ±±º						  entrada para correção do empenho para os 		       º±±
  ±±º                         armazéns corretos de acordo processo da 		 º±±
  ±±º                         Brasilux para as frabricas 1 e 2;       		 º±±
  ±±º 			 ³  14/03/14  Tiago Lucio/Chaus  2. Remoção dos Materiais 	 º±±
  ±±º                         de Consumo empenhados na SD4 , é aplicado por º±±
  ±±º                         meio do MV_XHABZZF   						     	 º±±
  ±±º 			 ³ 29/05/14  Tiago Lucio/Chaus  3. Remoção dos Materiais 	 º±±
  ±±º                         que são requisitados via armazem              º±±
  ±±º                           							                         º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function EMP650()
     FWLogMsg("Entrou no PE MA650EMP")

// Jose 17/12/2024 VOLTAR TODOS QUE ESTÃO INIBIDOS CIN==OM O NOME DE JOSE CASO A MICHELLY RESOLVA CONTROLAR AS RETENÇÕES 

//   Local cReten        // jose 15/06/2023
//   Local nX            // jose 15/06/2023
//   Local nA            // jose 15/06/2023
//   Local cCodigo       // jose 15/06/2023
//   Local cTipo         // jose 15/06/2023
     Local cAlias  := Alias()                                            //Alias Atual
     Local aArea   := U_PegaArea({"SB1","SG1","SC2","SZ1","SZ4"})
     Local _cTipo    := ""
     Local _cNome    := ""
     Local _aArea    := GetArea()
     Local _cProduto
     Local _cOrdem   := SC2->C2_NUM
     Local _cItem    := SC2->C2_ITEM
//   Local _cSeqPa   := SC2->C2_SEQUEN
     Local _cIteGrd  := SC2->C2_ITEMGRD
     Local _nVolume  := 0
     Local _nY       := 0
//   Local __nY      := 0 // jOSE 15/06/2023
     Local nY
     Local _cGrpEmp := alltrim(FWGrpCompany())


do case 
case _cGrpEmp == '01' //Empresas do grupo BRASILUX

        DbSelectArea("SZ4")                                                 //Característica + Linha
        DbSelectArea("SZ1")                                                 //Linhas
        DbSelectArea(cAlias) 
        //DISSOLTEX
       
/*      If (cnumemp == "01060101") // 19/01/15 solicitado por Silene (André)
            DbSelectArea("SB1") 
            DbSetOrder(1)    
            DbSeek(xFilial("SB1")+SC2->C2_PRODUTO, .t.)   
            If found() .and. (alltrim(SB1->B1_TIPO) $ ".PA.PI")
                For nY := 1 to Len(aCols)
                    DbSeek(xFilial("SB1")+aCols[nY][1], .t.)   
                    If found()         
                        If Trim(SB1->B1_XREQUIS)=='S' .and. (alltrim(SB1->B1_TIPO) $ "MP.MC")   //Produto é requisitado por pré-requisição
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
              For nY := 1  to Len(aCols) //  For nY := 1 to Len(aCols) 
                  aCols[nY][20] := SC2->C2_LOTE // jose 16/12/2024
                  DbSeek(xFilial("SB1")+aCols[nY][1], .t.)   
                  If found()         
                     //alterado Tiago Lucio/Chaus 29/05/14    
                     If Trim(SB1->B1_XREQUIS)=='S' .and. (alltrim(SB1->B1_TIPO) $ "MP.MC")  //Produto é requisitado por armazem, nao pode ser empenhado na SD4
                        aCols[nY][2]:=0 
                     EndIf
                     //alterado Tiago Lucio/Chaus 28/02/14  
                     If TRIM(SC2->C2_LOCAL)=='02'  
                        If TRIM(SB1->B1_TIPO)=='MP'  
                           If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriação indireta
                              aCols[nY][3] := '99' 
                            //aCols[nY][3] := 'R1' 								
                           ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                  aCols[nY][3] := 'R1' 
                           Else
                              aCols[nY][3] := '01'
                           EndIf	
                        ElseIf TRIM(SB1->B1_TIPO)=='PI'
                               If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriação indireta
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
                               If TRIM(SB1->B1_APROPRI)=='I'     //MP de apropriação indireta
                                  aCols[nY][3] := '99' 
                                //aCols[nY][3] := 'R2' 								
                               ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                      aCols[nY][3] := 'R2' 
                               Else
                                  aCols[nY][3] := '10' 
                               EndIf
                            ElseIf TRIM(SB1->B1_TIPO)=='PI'
                                   If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriação indireta
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
                               If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriação indireta
                                  aCols[nY][3] := '99' 
                                //aCols[nY][3] := 'R1' 
                               ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                      aCols[nY][3] := 'R1' 
                               Else
                                  aCols[nY][3] := '01' 
                               EndIf	
                            ElseIf TRIM(SB1->B1_TIPO)=='PI'
                                   If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriação indireta
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
                               If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriação indireta
                                  aCols[nY][3] := '99' 
                                //aCols[nY][3] := 'R2' 								
                               ElseIf Substr(SB1->B1_LOCPAD,1,1)=='R'
                                      aCols[nY][3] := 'R2' 
                               Else
                                  aCols[nY][3] := '10' 
                               EndIf	
                            ElseIf TRIM(SB1->B1_TIPO)=='PI'
                                   If TRIM(SB1->B1_APROPRI)=='I'   //MP de apropriação indireta
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

//****************   Colocar aqui a rotina para pegar os Produtos de RETENÇÂO  *********************************************
/*   jOSE 15/06/2023 -------------------------------------------------------------------------------------------------------
        // INCLUSÃO DA EMBALAGEM DE RETENÇÃO QUANDO OP ATINGIR O VOLUME MV_QTDRETE. CARATER INFORMATIVO, JÁ QUE ESSES PRODUTOS NÃO ESTÃO MAIS NA ESTRUTURA. ANDRÉ 16/09/14
           // SZ1 - Linha de Produto
           // SC2 - Ordem Produção
        cTipo := Posicione("SB1", 1, xFilial("SB1")+SC2->C2_PRODUTO, "B1_TIPO")
        If cTipo = "PI"
           For nX := 1 To Len(aCols)
               nA := nX
           Next
           __nY := nX
           If (!Empty(Posicione("SZ1", 1, xFilial("SZ1")+Substr(SC2->C2_PRODUTO, 04, 2), "Z1_PRODRET"))) 
       	      cReten := Posicione("SZ1", 1, xFilial("SZ1")+Substr(SC2->C2_PRODUTO, 04, 2), "Z1_PRODRET")
       	      If !(SuperGetMV("ZP_PAR0004",.F.,"") == SUBSTR( SC2->C2_PRODUTO, 4, 2)) 
   	              If (Alltrim(cReten) $  GETMV("MV_RETENOP")) .and.(SC2->C2_QUANT >= GETMV("MV_QTDRETE"))
                        aadd(aCols, {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' }) //, "'','','',''", .F. } ) // Jose 16/12/2024 acrestei mais um ''
                        cCodigo :=  Posicione( "SB1", 1, xFilial("SB1")+cReten, "B1_COD,B1_LOCPAD,B1_UM,B1_SEGUM,SB1->B1_DESC,SB1->B1_TIPO" ) 
                        aCols[__nY][01] := SB1->B1_COD      // Código do Produto a ser empenhado
                        aCols[__nY][02] := 1                // Quantidade do empenho
                        aCols[__nY][03] := SB1->B1_LOCPAD   // Almoxarifado do empenho
                        aCols[__nY][04] := '999'            // Sequência do componente na estrutura (Campo G1_TRT)
                        aCols[__nY][05] := ''               // Sub-Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade do tipo "S")
                        aCols[__nY][06] := ''               // Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade)
                        aCols[__nY][07] := ctod('')         // Data de validade do Lote (Somente deve ser preenchido se o  produto utilizar rastreabilidade)
                        aCols[__nY][08] := 0                // Potencia 
                        aCols[__nY][09] := ''               // Localização utilizada no empenho (Somente deve ser preenchido se o produto utilizar controle de localização física)
                        aCols[__nY][10] := ''               // Número de Série (Somente deve ser preenchido se o produto utilizar controle de localização física)
                        aCols[__nY][11] := SB1->B1_UM       // 1a. Unidade de Medida do Produto
                        aCols[__nY][12] := 0                // Quantidade do Empenho na 2a. Unidade de Medida
                        aCols[__nY][13] := SB1->B1_SEGUM    // 2a. Unidade de Medida do Produto
                        aCols[__nY][14] := SB1->B1_DESC     // Descrição
                        aCols[__nY][15] := ' '              // Operação
                        aCols[__nY][16] := ''               // Prd Original
                        aCols[__nY][17] :='Não'             // Alternativo
                        aCols[__nY][18] := ''               // Seq. Original
                        aCols[__nY][19] := 0                // Acerto de Cor
                        aCols[__nY][20] := 0                // Lote  // Jose 16/12/2024
//                      aCols[__nY][20] := {'','','',''}
//                      aCols[__nY][21] := '.F.'
                    Endif
               Else
//   	              If (Alltrim(cReten) $  GETMV("MV_RETENOP")) .and.(SC2->C2_QUANT >= GETMV("MV_QTDRETE"))
                        aadd(aCols, {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '' }) //, "'','','',''", .F. } ) // Jose 16/12/2024 acrescentei mais um ''
                        cCodigo :=  Posicione( "SB1", 1, xFilial("SB1")+cReten, "B1_COD,B1_LOCPAD,B1_UM,B1_SEGUM" ) 
                        aCols[__nY][01] := SB1->B1_COD      // Código do Produto a ser empenhado
                        aCols[__nY][02] := 1                // Quantidade do empenho
                        aCols[__nY][03] := SB1->B1_LOCPAD   // Almoxarifado do empenho
                        aCols[__nY][04] := '999'            // Sequência do componente na estrutura (Campo G1_TRT)
                        aCols[__nY][05] := ''               // Sub-Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade do tipo "S")
                        aCols[__nY][06] := ''               // Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade)
                        aCols[__nY][07] := ctod('')         // Data de validade do Lote (Somente deve ser preenchido se o  produto utilizar rastreabilidade)
                        aCols[__nY][08] := 0                // Potencia 
                        aCols[__nY][09] := ''               // Localização utilizada no empenho (Somente deve ser preenchido se o produto utilizar controle de localização física)
                        aCols[__nY][10] := ''               // Número de Série (Somente deve ser preenchido se o produto utilizar controle de localização física)
                        aCols[__nY][11] := SB1->B1_UM       // 1a. Unidade de Medida do Produto
                        aCols[__nY][12] := 0                // Quantidade do Empenho na 2a. Unidade de Medida
                        aCols[__nY][13] := SB1->B1_SEGUM    // 2a. Unidade de Medida do Produto
                        aCols[__nY][14] := SB1->B1_DESC     // Descrição
                        aCols[__nY][15] := ' '              // Operação
                        aCols[__nY][16] := ''               // Prd Original
                        aCols[__nY][17] :='Não'             // Alternativo
                        aCols[__nY][18] := ''               // Seq. Original
                        aCols[__nY][19] := 0                // Acerto de Cor
                        aCols[__nY][20] := 0                // Lote  // Jose 16/12/2024
//                      aCols[__nY][20] := {'','','',''}
//                      aCols[__nY][21] := '.F.'
		         Endif	
	        Endif
        EndIf 
---------------------------------------------------------------------------------------------------------------------*/
        U_VoltaArea(aArea)
        DbSelectArea(cAlias)
        
case _cGrpEmp == "11" //Grupo TECPOLPA
        // altera o lote economico do blend para gerar os empenhos
        //conforme a quebra definida no campo Vol p. Tanque
        /*
        Data: 29/06/2016 - Autor: Mauricio/Chaus
        Objetio: Ponto de entrada executado pela rotina MATA650 - Abertura de Ordens de Produção e o
                 mesmo È executado antes do sistema gerar os empenhos dos insumos (SD4), onde pode
                 ser feito adequações nos insumos empenhados.
        Objetivo:
                 1) Na geração do empenho mudar o almoxarifado da SB1( Padrão TOTVS) para o almoxarifado
                 de produção definido no parâmetro GetMV("TP_ALMPCP")  ==> EPCP
        aCols[n,x] - Onde o n é o  numero da linha  e x pode ser:
        [01] Código do Produto a ser empenhado
        [02] Quantidade do empenho
        [03] Almoxarifado do empenho
        [04] SequÕncia do componente na estrutura (Campo G1_TRT)
        [05] Sub-Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade do tipo "S")
        [06] Lote utilizado no empenho (Somente deve ser preenchido se o produto utilizar rastreabilidade)
        [07] Data de validade do Lote (Somente deve ser preenchido se o  produto utilizar rastreabilidade)
        [08] Localiza¡Ño utilizada no empenho (Somente deve ser preenchido se o produto utilizar controle de localiza¡Ño fÃsica)
        [09] Numero de S»rie (Somente deve ser preenchido se o produto utilizar controle de localiza¡Ño fÃsica)
        [10] 1a. Unidade de Medida do Produto
        [11] Quantidade do Empenho na 2a. Unidade de Medida
        [12] 2a. Unidade de Medida do Produto
        [14] Descrição
        [15] Operação
        [16] Prd Original
        [17] Alternativo
        [18] Seq. Original
        [19] Acerto de Cor
        [20] Lote  // Jose 16/12/2024
        [21] Coluna com valor lógico que indica se a linha esta deletada (.T.) ou não (.F.)
        */
        //If   != "001"
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
       Local _cLocPad := GetMV("TP_ALMPCP") //Almoxarifado padrão para empenho
       Local _I

       For _I := 1 to len(aCols)
           aCols[_I,3] := _cLocPad
       Next _I
       RestArea(_aArea)
Return()
