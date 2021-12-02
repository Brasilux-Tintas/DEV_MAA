#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "avprint.ch"
#xtranslate TRACO_BOLD1  => oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 ) ;
                          ; oPrn:Line( Linha     , 10 , Linha     , 2340 ) ;
                          ; oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
#xtranslate TRACO_NORMAL => oPrn:Line( Linha     , 10 , Linha     , 2340 )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFIN025  ºAutor  ³ Marcos C.D. Vieira º Data ³  03/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Demonstrativo Financeiro                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN025()
Local nQtdVenGer
     SetPrvt("cPerg,cQuery,nPag,cNomeArq,aCampos,cIndex,aInd,nQtdTot")

     //=//=//=//=//=//=//=//=//=//=//=//=//   
     //           PARAMETROS             //
     //=//=//=//=//=//=//=//=//=//=//=//=//
     //                                  //
     // MV_PAR01 - Data Limite           //
     // MV_PAR02 - Salvar Demonstrativo  //
     //                                  //
     //=//=//=//=//=//=//=//=//=//=//=//=//
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFIN025' ) //LGS#2021202 - Gravação de log de utilização da rotina

     cPerg      := "FIN025"
     VldPerg()       
     Pergunte("FIN025", .F.)
     cIndex     := ""
     aInd       := {}                        
     cNomeArq   := ""
     aCampos    := {}
     Linha      := 0                
     nOpcA      := 0                
     nPag       := 0 
     nQtdTot    := 0
     nPerOcor   := 0
     nTotPer    := 0 
//     dDatIni    := CTOD("")
     dDtFin     := CTOD("")

     oDlg := oSend( MSDialog(), "New", 8, 10, 18, 63,"Conferência Contábil.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
     @ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação      "
     @ 30,18  SAY "de um Demostrativo Financeiro ex.Tit.Carteira, Bcos etc..."
     @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("FIN025"))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )

     If nOpca == 0
        Return
     EndIf

     MsAguarde({|| FIN025_1() }, "Aguarde", "Este processamento poderá levar alguns minutos...")
Return
                         
/*****************************************************************************************************************/
/*** FIN025_1 - Busca dados e imprime relatório                                                                ***/
/*****************************************************************************************************************/
Static Function FIN025_1()
       Local nY
       //Variáveis para Cobrança Simples
       nTitVenBrs := 0 ; nSldVenBrs := 0 ; aTitVenBrs := {} //Banco do Brasil Vencidos
       nTitAVeBrs := 0 ; nSldAVeBrs := 0 ; aTitAVeBrs := {} //Banco do Brasil A Vencer
       nTitTotBrs := 0 ; nSldTotBrs := 0                    //Banco do Brasil Total
       nTitVenBrd := 0 ; nSldVenBrd := 0 ; aTitVenBrd := {} //Banco Bradesco Vencidos
       nTitAVeBrd := 0 ; nSldAveBrd := 0 ; aTitAVeBrd := {} //Banco Bradesco A Vencer
       nTitTotBrd := 0 ; nSldTotBrd := 0                    //Banco Bradesco Total
       nTitVenIta := 0 ; nSldVenIta := 0 ; aTitVenIta := {} //Banco Itaú Vencidos
       nTitAVeIta := 0 ; nSldAVeIta := 0 ; aTitAVeIta := {} //Banco Itaú A Vencer
       nTitTotIta := 0 ; nSldTotIta := 0                    //Banco Itaú Total
       nTitTotCSi := 0 ; nSldTotCSi := 0
       	// Outros Bancos não classificados
		nTitTotOutro := 0
		nSldTotOutro := 0
		nTitVenOutro := 0
		nSldVenOutro := 0
		aTitVenOutro := {}
		nTitAVeOutro := 0
		nSldAVeOutro := 0
		aTitAVeOutro := {}
		
       //Variáveis para Cobrança em Carteira
       nTitVenCar := 0 ; nSldVenCar := 0 ; aTitVenCar := {} //Carteira Vencidos
       nTitAVeCar := 0 ; nSldAVeCar := 0 ; aTitAVeCar := {} //Carteira A Vencer
       nTitTotCar := 0 ; nSldTotCar := 0                    //Carteira Total

       //Variáveis para Cobrança Sem Registro
       nTitVenSRe := 0 ; nSldVenSRe := 0  //Sem Reg. Vencidos
       nTitAVeSRe := 0 ; nSldAVeSRe := 0  //Sem Reg. A Vencer
       nTitCobSRe := 0 ; nSldCobSRe := 0 ; aTitCobSRe := {} //Cobrança Sem Registro

       //Variáveis para Cheques a Receber
       nTitCHQRec := 0 ; nSldCHQRec := 0 ; aTitCHQRec := {} //Cheques a Receber

       //Variáveis para Cheques Devolvidos
       aTitCHQSCD := {} //Cheques Devolvidos
       nTitCHQDev := 0 ; nSldCHQDev := 0                    //Cheques Devolvidos Totais
       
       //Variáveis para Titulos em Poder de Terceiros
       nTitPodTer := 0 ; nSldPodTer := 0 ; aTitPodTer := {} //Titulos de Terceiros

       //Variáveis para Titulos Protestados
       nTitProSPr := 0 ; nSldProSPr := 0 ; aTitProSPr := {} //Titulos Protestado Somente Protestados
       nTitProESC := 0 ; nSldProESC := 0 ; aTitProESC := {} //Titulos Protestado Em Escritório de Cobrança
       nTitProTer := 0 ; nSldProTer := 0 ; aTitProTer := {} //Titulos Protestado Titulos de Terceiros
       nTitTotPro := 0 ; nSldTotPro := 0                    //Titulos Protestado Totais

       //Variáveis para Titulos em Escritório de Cobrança
       nTitEscCob := 0 ; nSldEscCob := 0 ; aTitEscCob := {} //Titulos em Escritório de Cobrança

       //Variáveis para Titulos de Juros s/Titulos pagos em Cartório
       nTitJurCar := 0 ; nSldJurCar := 0 ; aTitJurCar := {} //Titulos de Juros s/Titulos pagos em Cartório

       //Variáveis para Titulos de Recebimento Antecipado
       nTitRecAnt := 0 ; nSldRecAnt := 0 ; aTitRecAnt := {} //Titulos de Recebimento Antecipado

       //Variáveis para Titulos de Lucros e Perdas
       nTitLePEsc := 0 ; nSldLePEsc := 0 ; aTitLePEsc := {} //Titulos de Lucros e Perdas em Escritório
       nTitSomLeP := 0 ; nSldSomLeP := 0 ; aTitSomLeP := {} //Titulos de Lucros e Perdas somente
       nTitTotLeP := 0 ; nSldTotLeP := 0                    //Titulos de Lucros e Perdas somente Total

       //Variáveis para Titulos de NCC
       nTitTotNCC := 0 ; nSldTitNCC := 0 ; aTitTotNCC := {} //Titulos de NCC

       //Variáveis totalizadoras
       nSldTotGer := 0 ; nTitTotGer := 0 ; aTitTotGer := {} //Todos os Titulos
       
//       dDatIni   := CTOD("01/01/01")

       cQuery  := "SELECT SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, "+;
       "SE1.E1_NATUREZ, SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VENCREA, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_SITUACA, "+;
       "SE1.E1_INSTCOB, SE1.E1_PORTADO,E1_CHQDEV "
       cQuery  += "FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "
       cQuery  += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
       cQuery  += "  AND (SE1.E1_EMISSAO <= '"+DTOS(mv_par01)+"') "
       cQuery  += "  AND (SE1.E1_SALDO <> 0) "
       cQuery  += "  AND (SE1.D_E_L_E_T_ <> '*') AND (SE1.E1_TIPO <> 'AB-') "
       cQuery  += "ORDER BY SE1.E1_VENCTO "
       TCQuery cQuery ALIAS "TCQ" NEW
       cLogTot := ""
       cLogVen := ""
       cLogAVe := ""
       DbSelectArea("TCQ")
       DbGotop()
       While !Eof()
       		//nSldAbat := SomaAbat(TCQ->E1_PREFIXO, TCQ->E1_NUM, TCQ->E1_PARCELA, "R", 1, TCQ->E1_EMISSAO, TCQ->E1_CLIENTE, TCQ->E1_LOJA)
//       		nSldAbat := SumAbatRec( TCQ->E1_PREFIXO, TCQ->E1_NUM, TCQ->E1_PARCELA, 1, "S", TCQ->E1_EMISSAO)
       		nSldAbat := SumAbatRec( TCQ->E1_PREFIXO, TCQ->E1_NUM, TCQ->E1_PARCELA, 1, "S")

			nTitTotGer += 1
   			nSldTotGer += TCQ->E1_SALDO - iif(alltrim(TCQ->E1_TIPO) $ "RA_NCC",0,nSldAbat)

			do case 
   			// Titulos de Recebimento Antecipado(RA)
      		case AllTrim(TCQ->E1_TIPO) == "RA"
             	nTitRecAnt += 1
              	nSldRecAnt += TCQ->E1_SALDO // - nSldAbat
                aAdd(aTitRecAnt, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, Iif(Alltrim(TCQ->E1_TIPO) $ 'RA.NCC', TCQ->E1_SALDO*(-1), TCQ->E1_SALDO) - nSldAbat})


			//Titulos De NCC
   			case AllTrim(TCQ->E1_TIPO) == "NCC"
                nTitTotNCC += 1
                nSldTitNCC += TCQ->E1_SALDO //- nSldAbat
                aAdd(aTitTotNCC, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})


   			// Titulos em Lucros e Perdas 
   			case AllTrim(TCQ->E1_SITUACA) == "6" // "801004"
      			nTitTotLeP += 1
                nSldTotLeP += TCQ->E1_SALDO - nSldAbat
                If !Empty(TCQ->E1_INSTCOB)        			//Em Escritório de Cobrança
                	nTitLePEsc += 1
                 	nSldLePEsc += TCQ->E1_SALDO - nSldAbat
                   	aAdd(aTitLePEsc, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_SALDO, nSldAbat, TCQ->E1_SALDO})
         		else      
                	nTitSomLeP += 1
                 	nSldSomLeP += TCQ->E1_SALDO - nSldAbat
                   	aAdd(aTitSomLeP, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_SALDO, nSldAbat,  TCQ->E1_SALDO})
           		endif 
            //Titulos em Escritório de Cobrança
            case ALLTRIM(TCQ->E1_SITUACA) == "5"    
            	nTitEscCob += 1
   	         	nSldEscCob += TCQ->E1_SALDO - nSldAbat
       	        aAdd(aTitEscCob, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})

   			// Cheques a Receber
      		case TCQ->E1_TIPO = 'CH'
             	// Cheques Devolvidos
//             	If AllTrim(TCQ->E1_NATUREZ) == "802004" 
				IF (TCQ->E1_CHQDEV = "1")

                   	nTitCHQDev += 1
                   	nSldCHQDev += TCQ->E1_SALDO - nSldAbat

                   	aAdd(aTitCHQSCD, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})

             	else    
             		//Cheques a compensar
        			nTitCHQRec += 1
          			nSldCHQRec += TCQ->E1_SALDO - nSldAbat
                	aAdd(aTitCHQRec, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
             	Endif

             // Titulos Protestados
            case (ALLTRIM(TCQ->E1_SITUACA) == "F") .OR. (AllTrim(TCQ->E1_NATUREZ) == "802016") //Consid. Natureza p/ títulos antigos que não foram transferidos
   				nTitTotPro += 1
       			nSldTotPro += TCQ->E1_SALDO - nSldAbat
   				if TCQ->E1_TIPO == "DPT"                   //Titulos de Terceiros
       				nTitProTer += 1
           			nSldProTer += TCQ->E1_SALDO - nSldAbat
              		aAdd(aTitProTer, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                Else                                           //Somente Protestados
                	nTitProSPr += 1
                 	nSldProSPr += TCQ->E1_SALDO - nSldAbat
                   	aAdd(aTitProSPr, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                Endif

             //Titulos de Terceiros
/*			case Alltrim(TCQ->E1_TIPO) == "DPT" .and. TCQ->E1_SITUACA == "0"
   				nTitPodTer += 1
       			nSldPodTer += TCQ->E1_SALDO - nSldAbat
          		aAdd(aTitPodTer, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO - nSldAbat})

*/

			//Titulos Juros s/ Titulos Pagos em Cartorio
			case Alltrim(TCQ->E1_NATUREZ) == "802025"
   				nTitJurCar += 1
       			nSldJurCar += TCQ->E1_SALDO - nSldAbat
          		aAdd(aTitJurCar, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})


             // Titulos em Cobrança sem registro
			case Alltrim(TCQ->E1_NATUREZ) == "802021"
   				nTitCobSRe += 1
       			nSldCobSRe += TCQ->E1_SALDO - nSldAbat
                aAdd(aTitCobSRe, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
				If TCQ->E1_VENCREA < DTOS(mv_par01)     // Vencidos                
                	nTitVenSRe ++ 
                	nSldVenSRe += TCQ->E1_SALDO - nSldAbat
    			else
       				nTitAVeSRe++			
       				nSldAVeSRe += TCQ->E1_SALDO - nSldAbat
				endif 
				
             // Titulos em Cobrança Simples
   			case TCQ->E1_SITUACA == "1"
      			nTitTotCSi += 1
         		nSldTotCSi += TCQ->E1_SALDO - nSldAbat
                If TCQ->E1_PORTADO == "001"                    // Banco do Brasil
                	nTitTotBrs    += 1
                 	nSldTotBrs    += TCQ->E1_SALDO - nSldAbat
                  	If TCQ->E1_VENCREA < DTOS(mv_par01)     // Vencidos
                   		nTitVenBrs += 1
                     	nSldVenBrs += TCQ->E1_SALDO - nSldAbat
                      	aAdd(aTitVenBrs, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                   	Else                                    // A Vencer
                    	nTitAVeBrs += 1
                     	nSldAVeBrs += TCQ->E1_SALDO - nSldAbat
                      	aAdd(aTitAVeBrs, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                  	Endif
                ElseIf TCQ->E1_PORTADO == "237"                // Banco Bradesco
                	nTitTotBrd    += 1
                 	nSldTotBrd    += TCQ->E1_SALDO - nSldAbat
                	If TCQ->E1_VENCREA < DTOS(mv_par01)     // Vencidos
                 		nTitVenBrd += 1
                   		nSldVenBrd += TCQ->E1_SALDO - nSldAbat
                     	aAdd(aTitVenBrd, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                 	Else                                    // A Vencer
                  		nTitAVeBrd += 1
                    	nSldAveBrd += TCQ->E1_SALDO - nSldAbat
                     	aAdd(aTitAVeBrd, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                 	Endif
                ElseIf TCQ->E1_PORTADO == "341"                // Banco Itaú
                	nTitTotIta    += 1
                 	nSldTotIta    += TCQ->E1_SALDO - nSldAbat
                  	If TCQ->E1_VENCREA < DTOS(mv_par01)     // Vencidos
                   		nTitVenIta += 1
                     	nSldVenIta += TCQ->E1_SALDO - nSldAbat
                      	aAdd(aTitVenIta, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                  	Else                                    // A Vencer
                   		nTitAVeIta += 1
                     	nSldAVeIta += TCQ->E1_SALDO - nSldAbat
                      	aAdd(aTitAVeIta, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                  	Endif
                else     										//Outro Banco
                	nTitTotOutro    += 1
                 	nSldTotOutro    += TCQ->E1_SALDO - nSldAbat
                  	If TCQ->E1_VENCREA < DTOS(mv_par01)     // Vencidos
                   		nTitVenOutro += 1
                     	nSldVenOutro += TCQ->E1_SALDO - nSldAbat
                      	aAdd(aTitVenOutro, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                  	Else                                    // A Vencer
                   		nTitAVeOutro += 1
                     	nSldAVeOutro += TCQ->E1_SALDO - nSldAbat
                      	aAdd(aTitAVeOutro, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                  	Endif
                Endif

			otherwise
   				// Titulos em Carteira
       			nTitTotCar += 1
          		nSldTotCar += TCQ->E1_SALDO - nSldAbat
             	//If TCQ->E1_SITUACA == "0"
                If TCQ->E1_VENCREA < DTOS(mv_par01)         // Vencidos
                	nTitVenCar += 1
                 	nSldVenCar += TCQ->E1_SALDO - nSldAbat
                   	aAdd(aTitVenCar, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO})
                Else                                        // A Vencer
                	nTitAVeCar += 1
                 	nSldAVeCar += TCQ->E1_SALDO - nSldAbat
                   	aAdd(aTitAVeCar, {TCQ->E1_CLIENTE+'-'+TCQ->E1_LOJA+'-'+TCQ->E1_NOMCLI, TCQ->E1_PREFIXO+'-'+TCQ->E1_NUM+'-'+TCQ->E1_PARCELA, TCQ->E1_TIPO, TCQ->E1_NATUREZ, TCQ->E1_EMISSAO, TCQ->E1_VENCTO, TCQ->E1_VENCREA, TCQ->E1_VALOR, nSldAbat, TCQ->E1_SALDO - nSldAbat})
                Endif
             	//Endif
			endcase 


             DBSelectArea("TCQ")
             DBSkip()
       Enddo
       
       //Geração de Arquivos Texto
         //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         //CLIENT LJ NOME CLIENTE         PRF NUMERO P TIP NATUREZA   EMISSAO  VENCTO   VENC. R. VALOR          ABAT.      TITULO
         //999999-99-XXXXXXXXXXXXXXXXXXXX XXX-999999-X XXX 9999999999 99/99/99 99/99/99 99/99/99 999,999,999.99 999,999.99 999,999,999.99
         //           [nY][01]              [nY][02]   [nY][03] [nY][04] [nY][05] [nY][06] [nY][07] [nY][08] [nY][09] [nY][10]
         //Titulos em Cobrança Simples
           //Brasil
             //Vencidos
             //cLog := ""
             //For nY := 1 To Len(aTitVenBrs)
             //    cLog += aTitVenBrs[nY][01]+' '+aTitVenBrs[nY][02]+' '+aTitVenBrs[nY][03]+' '+aTitVenBrs[nY][04]+' '+SubStr(aTitVenBrs[nY][05], 7, 2)+'/'+SubStr(aTitVenBrs[nY][05], 5, 2)+'/'+SubStr(aTitVenBrs[nY][05], 3, 2)+' '+SubStr(aTitVenBrs[nY][06], 7, 2)+'/'+SubStr(aTitVenBrs[nY][06], 5, 2)+'/'+SubStr(aTitVenBrs[nY][06], 3, 2)+' '+SubStr(aTitVenBrs[nY][07], 7, 2)+'/'+SubStr(aTitVenBrs[nY][07], 5, 2)+'/'+SubStr(aTitVenBrs[nY][07], 3, 2)+' '+Transform(aTitVenBrs[nY][08], '@E 999,999,999.99')+' '+Transform(aTitVenBrs[nY][09], '@E 999,999.99')+' '+Transform(aTitVenBrs[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             //Next
             //MemoWrite("LOG03.LOG", cLog)
             //A Vencer
             //cLog := ""
             //For nY := 1 To Len(aTitAVeBrs)
             //    cLog += aTitAVeBrs[nY][01]+' '+aTitAVeBrs[nY][02]+' '+aTitAVeBrs[nY][03]+' '+aTitAVeBrs[nY][04]+' '+SubStr(aTitAVeBrs[nY][05], 7, 2)+'/'+SubStr(aTitAVeBrs[nY][05], 5, 2)+'/'+SubStr(aTitAVeBrs[nY][05], 3, 2)+' '+SubStr(aTitAVeBrs[nY][06], 7, 2)+'/'+SubStr(aTitAVeBrs[nY][06], 5, 2)+'/'+SubStr(aTitAVeBrs[nY][06], 3, 2)+' '+SubStr(aTitAVeBrs[nY][07], 7, 2)+'/'+SubStr(aTitAVeBrs[nY][07], 5, 2)+'/'+SubStr(aTitAVeBrs[nY][07], 3, 2)+' '+Transform(aTitAVeBrs[nY][08], '@E 999,999,999.99')+' '+Transform(aTitAVeBrs[nY][09], '@E 999,999.99')+' '+Transform(aTitAVeBrs[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             //Next
             //MemoWrite("LOG04.LOG", cLog)
           //Bradesco
             //Vencidos
             //cLog := ""
             //For nY := 1 To Len(aTitVenBrd)
             //    cLog += aTitVenBrd[nY][01]+' '+aTitVenBrd[nY][02]+' '+aTitVenBrd[nY][03]+' '+aTitVenBrd[nY][04]+' '+SubStr(aTitVenBrd[nY][05], 7, 2)+'/'+SubStr(aTitVenBrd[nY][05], 5, 2)+'/'+SubStr(aTitVenBrd[nY][05], 3, 2)+' '+SubStr(aTitVenBrd[nY][06], 7, 2)+'/'+SubStr(aTitVenBrd[nY][06], 5, 2)+'/'+SubStr(aTitVenBrd[nY][06], 3, 2)+' '+SubStr(aTitVenBrd[nY][07], 7, 2)+'/'+SubStr(aTitVenBrd[nY][07], 5, 2)+'/'+SubStr(aTitVenBrd[nY][07], 3, 2)+' '+Transform(aTitVenBrd[nY][08], '@E 999,999,999.99')+' '+Transform(aTitVenBrd[nY][09], '@E 999,999.99')+' '+Transform(aTitVenBrd[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             //Next
             //MemoWrite("LOG06.LOG", cLog)
             //A Vencer
             //cLog := ""
             //For nY := 1 To Len(aTitAVeBrd)
             //    cLog += aTitAVeBrd[nY][01]+' '+aTitAVeBrd[nY][02]+' '+aTitAVeBrd[nY][03]+' '+aTitAVeBrd[nY][04]+' '+SubStr(aTitAVeBrd[nY][05], 7, 2)+'/'+SubStr(aTitAVeBrd[nY][05], 5, 2)+'/'+SubStr(aTitAVeBrd[nY][05], 3, 2)+' '+SubStr(aTitAVeBrd[nY][06], 7, 2)+'/'+SubStr(aTitAVeBrd[nY][06], 5, 2)+'/'+SubStr(aTitAVeBrd[nY][06], 3, 2)+' '+SubStr(aTitAVeBrd[nY][07], 7, 2)+'/'+SubStr(aTitAVeBrd[nY][07], 5, 2)+'/'+SubStr(aTitAVeBrd[nY][07], 3, 2)+' '+Transform(aTitAVeBrd[nY][08], '@E 999,999,999.99')+' '+Transform(aTitAVeBrd[nY][09], '@E 999,999.99')+' '+Transform(aTitAVeBrd[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             //Next
             //MemoWrite("LOG07.LOG", cLog)
           //Itau
             //Vencidos
             //cLog := ""
             //For nY := 1 To Len(aTitVenIta)
             //    cLog += aTitVenIta[nY][01]+' '+aTitVenIta[nY][02]+' '+aTitVenIta[nY][03]+' '+aTitVenIta[nY][04]+' '+SubStr(aTitVenIta[nY][05], 7, 2)+'/'+SubStr(aTitVenIta[nY][05], 5, 2)+'/'+SubStr(aTitVenIta[nY][05], 3, 2)+' '+SubStr(aTitVenIta[nY][06], 7, 2)+'/'+SubStr(aTitVenIta[nY][06], 5, 2)+'/'+SubStr(aTitVenIta[nY][06], 3, 2)+' '+SubStr(aTitVenIta[nY][07], 7, 2)+'/'+SubStr(aTitVenIta[nY][07], 5, 2)+'/'+SubStr(aTitVenIta[nY][07], 3, 2)+' '+Transform(aTitVenIta[nY][08], '@E 999,999,999.99')+' '+Transform(aTitVenIta[nY][09], '@E 999,999.99')+' '+Transform(aTitVenIta[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             //Next
             //MemoWrite("LOG09.LOG", cLog)
             //A Vencer
             //cLog := ""
             //For nY := 1 To Len(aTitAVeIta)
             //    cLog += aTitAVeIta[nY][01]+' '+aTitAVeIta[nY][02]+' '+aTitAVeIta[nY][03]+' '+aTitAVeIta[nY][04]+' '+SubStr(aTitAVeIta[nY][05], 7, 2)+'/'+SubStr(aTitAVeIta[nY][05], 5, 2)+'/'+SubStr(aTitAVeIta[nY][05], 3, 2)+' '+SubStr(aTitAVeIta[nY][06], 7, 2)+'/'+SubStr(aTitAVeIta[nY][06], 5, 2)+'/'+SubStr(aTitAVeIta[nY][06], 3, 2)+' '+SubStr(aTitAVeIta[nY][07], 7, 2)+'/'+SubStr(aTitAVeIta[nY][07], 5, 2)+'/'+SubStr(aTitAVeIta[nY][07], 3, 2)+' '+Transform(aTitAVeIta[nY][08], '@E 999,999,999.99')+' '+Transform(aTitAVeIta[nY][09], '@E 999,999.99')+' '+Transform(aTitAVeIta[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             //Next
             //MemoWrite("LOG10.LOG", cLog)
         //Titulos em Carteira
             //Vencidos
             cLog := ""
             For nY := 1 To Len(aTitVenCar)
                 cLog += aTitVenCar[nY][01]+' '+aTitVenCar[nY][02]+' '+aTitVenCar[nY][03]+' '+aTitVenCar[nY][04]+' '+SubStr(aTitVenCar[nY][05], 7, 2)+'/'+SubStr(aTitVenCar[nY][05], 5, 2)+'/'+SubStr(aTitVenCar[nY][05], 3, 2)+' '+SubStr(aTitVenCar[nY][06], 7, 2)+'/'+SubStr(aTitVenCar[nY][06], 5, 2)+'/'+SubStr(aTitVenCar[nY][06], 3, 2)+' '+SubStr(aTitVenCar[nY][07], 7, 2)+'/'+SubStr(aTitVenCar[nY][07], 5, 2)+'/'+SubStr(aTitVenCar[nY][07], 3, 2)+' '+Transform(aTitVenCar[nY][08], '@E 999,999,999.99')+' '+Transform(aTitVenCar[nY][09], '@E 999,999.99')+' '+Transform(aTitVenCar[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             Next
             MemoWrite("LOG12.LOG", cLog)
             //A Vencer
             cLog := ""
             For nY := 1 To Len(aTitAveCar)
                 cLog += aTitAveCar[nY][01]+' '+aTitAveCar[nY][02]+' '+aTitAveCar[nY][03]+' '+aTitAveCar[nY][04]+' '+SubStr(aTitAveCar[nY][05], 7, 2)+'/'+SubStr(aTitAveCar[nY][05], 5, 2)+'/'+SubStr(aTitAveCar[nY][05], 3, 2)+' '+SubStr(aTitAveCar[nY][06], 7, 2)+'/'+SubStr(aTitAveCar[nY][06], 5, 2)+'/'+SubStr(aTitAveCar[nY][06], 3, 2)+' '+SubStr(aTitAveCar[nY][07], 7, 2)+'/'+SubStr(aTitAveCar[nY][07], 5, 2)+'/'+SubStr(aTitAveCar[nY][07], 3, 2)+' '+Transform(aTitAveCar[nY][08], '@E 999,999,999.99')+' '+Transform(aTitAveCar[nY][09], '@E 999,999.99')+' '+Transform(aTitAveCar[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
             Next
             MemoWrite("LOG13.LOG", cLog)
            
            //Cheques Devolvidos
            cLog := ""
            For nY := 1 To Len(aTitCHQSCD)
                cLog += aTitCHQSCD[nY][01]+' '+aTitCHQSCD[nY][02]+' '+aTitCHQSCD[nY][03]+' '+aTitCHQSCD[nY][04]+' '+SubStr(aTitCHQSCD[nY][05], 7, 2)+'/'+SubStr(aTitCHQSCD[nY][05], 5, 2)+'/'+SubStr(aTitCHQSCD[nY][05], 3, 2)+' '+SubStr(aTitCHQSCD[nY][06], 7, 2)+'/'+SubStr(aTitCHQSCD[nY][06], 5, 2)+'/'+SubStr(aTitCHQSCD[nY][06], 3, 2)+' '+SubStr(aTitCHQSCD[nY][07], 7, 2)+'/'+SubStr(aTitCHQSCD[nY][07], 5, 2)+'/'+SubStr(aTitCHQSCD[nY][07], 3, 2)+' '+Transform(aTitCHQSCD[nY][08], '@E 999,999,999.99')+' '+Transform(aTitCHQSCD[nY][09], '@E 999,999.99')+' '+Transform(aTitCHQSCD[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
            Next
            MemoWrite("LOG18.LOG", cLog)

         // Titulos Protestados
            // Titulos Protestado Somente Protestados
               cLog := ""
               For nY := 1 To Len(aTitProSPr)
                   cLog += aTitProSPr[nY][01]+' '+aTitProSPr[nY][02]+' '+aTitProSPr[nY][03]+' '+aTitProSPr[nY][04]+' '+SubStr(aTitProSPr[nY][05], 7, 2)+'/'+SubStr(aTitProSPr[nY][05], 5, 2)+'/'+SubStr(aTitProSPr[nY][05], 3, 2)+' '+SubStr(aTitProSPr[nY][06], 7, 2)+'/'+SubStr(aTitProSPr[nY][06], 5, 2)+'/'+SubStr(aTitProSPr[nY][06], 3, 2)+' '+SubStr(aTitProSPr[nY][07], 7, 2)+'/'+SubStr(aTitProSPr[nY][07], 5, 2)+'/'+SubStr(aTitProSPr[nY][07], 3, 2)+' '+Transform(aTitProSPr[nY][08], '@E 999,999,999.99')+' '+Transform(aTitProSPr[nY][09], '@E 999,999.99')+' '+Transform(aTitProSPr[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
               Next
               MemoWrite("LOG21.LOG", cLog)

            // Titulos Protestado Titulos de Terceiros
               cLog := ""
               For nY := 1 To Len(aTitProTer)
                   cLog += aTitProTer[nY][01]+' '+aTitProTer[nY][02]+' '+aTitProTer[nY][03]+' '+aTitProTer[nY][04]+' '+SubStr(aTitProTer[nY][05], 7, 2)+'/'+SubStr(aTitProTer[nY][05], 5, 2)+'/'+SubStr(aTitProTer[nY][05], 3, 2)+' '+SubStr(aTitProTer[nY][06], 7, 2)+'/'+SubStr(aTitProTer[nY][06], 5, 2)+'/'+SubStr(aTitProTer[nY][06], 3, 2)+' '+SubStr(aTitProTer[nY][07], 7, 2)+'/'+SubStr(aTitProTer[nY][07], 5, 2)+'/'+SubStr(aTitProTer[nY][07], 3, 2)+' '+Transform(aTitProTer[nY][08], '@E 999,999,999.99')+' '+Transform(aTitProTer[nY][09], '@E 999,999.99')+' '+Transform(aTitProTer[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
               Next
               MemoWrite("LOG23.LOG", cLog)

         // Titulos em Lucros e Perdas
            // Titulos de Lucros e Perdas somente
               cLog := ""
               For nY := 1 To Len(aTitSomLeP)
                   cLog += aTitSomLeP[nY][01]+' '+aTitSomLeP[nY][02]+' '+aTitSomLeP[nY][03]+' '+aTitSomLeP[nY][04]+' '+SubStr(aTitSomLeP[nY][05], 7, 2)+'/'+SubStr(aTitSomLeP[nY][05], 5, 2)+'/'+SubStr(aTitSomLeP[nY][05], 3, 2)+' '+SubStr(aTitSomLeP[nY][06], 7, 2)+'/'+SubStr(aTitSomLeP[nY][06], 5, 2)+'/'+SubStr(aTitSomLeP[nY][06], 3, 2)+' '+SubStr(aTitSomLeP[nY][07], 7, 2)+'/'+SubStr(aTitSomLeP[nY][07], 5, 2)+'/'+SubStr(aTitSomLeP[nY][07], 3, 2)+' '+Transform(aTitSomLeP[nY][08], '@E 999,999,999.99')+' '+Transform(aTitSomLeP[nY][09], '@E 999,999.99')+' '+Transform(aTitSomLeP[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
               Next
               MemoWrite("LOG33.LOG", cLog)
            // Titulos de Lucros e Perdas em Escritório
               cLog := ""
               For nY := 1 To Len(aTitLePEsc)
                   cLog += aTitLePEsc[nY][01]+' '+aTitLePEsc[nY][02]+' '+aTitLePEsc[nY][03]+' '+aTitLePEsc[nY][04]+' '+SubStr(aTitLePEsc[nY][05], 7, 2)+'/'+SubStr(aTitLePEsc[nY][05], 5, 2)+'/'+SubStr(aTitLePEsc[nY][05], 3, 2)+' '+SubStr(aTitLePEsc[nY][06], 7, 2)+'/'+SubStr(aTitLePEsc[nY][06], 5, 2)+'/'+SubStr(aTitLePEsc[nY][06], 3, 2)+' '+SubStr(aTitLePEsc[nY][07], 7, 2)+'/'+SubStr(aTitLePEsc[nY][07], 5, 2)+'/'+SubStr(aTitLePEsc[nY][07], 3, 2)+' '+Transform(aTitLePEsc[nY][08], '@E 999,999,999.99')+' '+Transform(aTitLePEsc[nY][09], '@E 999,999.99')+' '+Transform(aTitLePEsc[nY][10], '@E 999,999,999.99')+Chr(13)+Chr(10)
               Next
               MemoWrite("LOG34.LOG", cLog)

       DbSelectArea("TCQ")            
       DbGotop()
       If EOF()
          MsgStop("Nao ha dados a serem gerados com estes parametros.")
          DBSelectArea("TCQ")
          DbCloseArea()
          Return nil
       Endif

       dDataFim  := DATAFINAL(mv_par01)   

       If MV_PAR02 == 1
          DBSelectArea("ZZ8")
          DbSetOrder(1)
          DbSeek(xFilial("ZZ8")+DTOS(dDataFim))
          If Found()
             Reclock("ZZ8",.F.)
          Else
             Reclock("ZZ8",.T.)  
             ZZ8_FILIAL := xFilial("ZZ8")
             ZZ8_DATA   := dDataFim 
          Endif
          ZZ8_TVLPP  := nSldTotPro              // Saldo de Titulos Protestados Total
          ZZ8_TVLPS  := nSldProSPr              // Saldo de Titulos Protestado Somente Protestado
//          ZZ8_TVLPE  := nSldProESC              // Saldo de Titulos Protestado Em Escritório de Cobrança
          ZZ8_TVLPT  := nSldProTer              // Saldo de Titulos Protestado Titulos de Terceiros
          ZZ8_TVLLP  := nSldTotLeP              // Saldo de Titulos de Lucros e Perdas Total
          ZZ8_TVLLPS := nSldSomLeP              // Saldo de Titulos de Lucros e Perdas somente
          ZZ8_TVLLPE := nSldLePEsc              // Saldo de Titulos de Lucros e Perdas em Escritório
          ZZ8_TVLRA  := nSldRecAnt              // Saldo de Titulos de Recebimento Antecipado
//          ZZ8_VLTT   := nSldPodTer              // Saldo de Titulos em Poder de Terceiros
          ZZ8_TVLEC  := nSldEscCob              // Saldo de Titulos em Escritório de Cobrança
          ZZ8_TVLCRT := nSldTotCar              // Saldo de Carteira Total
          ZZ8_TVLCV  := nSldVenCar              // Saldo de Carteira Vencidos
          ZZ8_TVLCAV := nSldAVeCar              // Saldo de Carteira A Vencer
          ZZ8_TVLCSR := nSldCobSRe              // Saldo de Cobrança Sem Registro
          ZZ8_TVLJCA := nSldJurCar              // Saldo de Juros s/Titulos pagos em Cartório
          ZZ8_TVLCS  := nSldTotCSi              // Saldo de Cobrança Simples
          ZZ8_VLBB   := nSldVenBrs + nSldAVeBrs // Saldo de Titulos Banco do Brasil Total
          ZZ8_VLBBV  := nSldVenBrs              // Saldo de Titulos Banco do Brasil Vencidos
          ZZ8_VLBBAV := nSldAVeBrs              // Saldo de Titulos Banco do Brasil A Vencer
          ZZ8_VLBRAD := nSldVenBrd + nSldAveBrd // Saldo de Titulos Banco Bradesco Total
          ZZ8_VLBDV  := nSldVenBrd              // Saldo de Titulos Banco Bradesco Vencidos
          ZZ8_VLBDAV := nSldAveBrd              // Saldo de Titulos Banco Bradesco A Vencer
          ZZ8_VLITAU := nSldVenIta + nSldAVeIta // Saldo de Titulos Banco Itaú Total
          ZZ8_VLITV  := nSldVenIta              // Saldo de Titulos Banco Itaú Vencidos
          ZZ8_VLITAV := nSldAVeIta              // Saldo de Titulos Banco Itaú A Vencer
          ZZ8_TVLCAR := nSldCHQRec              // Saldo de Cheques a Receber
          ZZ8_TVLCD  := nSldCHQDev              // Saldo de Cheques Devolvidos Totais
//          ZZ8_TVLCDS := nSldCHQSCD              // Saldo de Cheques Devolvidos
//          ZZ8_TVLCDE := nSldCHQDEC              // Saldo de Cheques Devolvidos em Escritório de Cobrança
          ZZ8_TVLNCC := nSldTitNCC              // Saldo de Titulos de NCC
          ZZ8_TVLTOT := nSldTotGer - (nSldTitNCC + nSldTotLeP + nSldRecAnt)
          ZZ8_TVENCS := nSldVenBrs + nSldVenBrd + nSldVenIta + nSldVenOutro
          ZZ8_TTVENC := ZZ8->ZZ8_TVENCS + nSldVenCar + nSldCHQDev + nSldTotPro + nSldEscCob
          ZZ8_TGCART := nSldTotCar+nSldCHQDev+nSldCHQRec+nSldJurCar
          ZZ8_TGCARV := nSldVenCar + nSldCHQDev
          ZZ8_TGCARA := nSldAVeCar + nSldCHQRec + nSldJurCar
       Endif

       dDatAnt := DATAFINAL(dDataFim - 32)

       DBSelectArea("ZZ8")
       DbSetOrder(1)
       DbSeek(xFilial("ZZ8")+DTOS(dDatAnt))

       cMes01 := MesExtenso(Month(mv_par01))
       cMes02 := MesExtenso(Month(dDatAnt))

       oPrn := TMSPrinter():New( "Relatório de Demonstrativo Financeiro." )
       oPrn:SetPortrait()

       AVPRINT oPrn NAME "Relatório de Demonstrativo Financeiro."
               oFont1 := TFont():New("Arial"      , 9, 07, .F., .T., 5, .T., 5, .T., .F.)
               oFont2 := TFont():New("Courier New", 9, 14, .F., .T., 5, .F., 5, .T., .F.)
               oFont3 := TFont():New("Courier New", 9, 12, .F., .T., 5, .F., 5, .T., .F.)
               oFont4 := TFont():New("Courier New", 9, 12, .F., .F., 5, .T., 5, .T., .F.)
               oFont5 := TFont():New("Arial"      , 9, 10, .F., .T., 5, .T., 5, .T., .F.) 

               AVPAGE
                 FIN025CAB() //Impressão do Cabeçalho
                 //TITULOS EM COBRANÇA SIMPLES
                 nDif := ( (nSldTotCSi / ZZ8->ZZ8_TVLCS) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS EM COBRANÇA SIMPLES"                            , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLCS           , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldTotCSi               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotCSi               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50

                 //BANCO DO BRASIL
                 nDif := (((nSldVenBrs + nSldAVeBrs) / ZZ8->ZZ8_VLBB) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Banco do Brasil"                                     , oFont3 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLBB            , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform((nSldVenBrs + nSldAVeBrs), "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotBrs               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldVenBrs / ZZ8->ZZ8_VLBBV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "      Vencidos"                                         , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLBBV           , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldVenBrs               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitVenBrs               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldAVeBrs / ZZ8->ZZ8_VLBBAV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "      A Vencer"                                         , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLBBAV          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldAVeBrs               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitAVeBrs               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50

                 //BANCO BRADESCO
                 nDif := (((nSldVenBrd + nSldAveBrd) / ZZ8->ZZ8_VLBRAD) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Banco Bradesco"                                      , oFont3 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLBRAD          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldVenBrd + nSldAveBrd  , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotBrd               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldVenBrd / ZZ8->ZZ8_VLBDV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "      Vencidos"                                         , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLBDV           , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldVenBrd               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitVenBrd               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldAveBrd / ZZ8->ZZ8_VLBDAV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "      A Vencer"                                         , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLBDAV          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldAveBrd               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitAVeBrd               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50

                 //BANCO ITAÚ
                 nDif := (((nSldVenIta + nSldAVeIta) / ZZ8->ZZ8_VLITAU) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Banco Itaú"                                          , oFont3 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLITAU          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldVenIta + nSldAVeIta  , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotIta               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldVenIta / ZZ8->ZZ8_VLITV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "      Vencidos"                                         , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLITV           , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldVenIta               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitVenIta               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldAVeIta / ZZ8->ZZ8_VLITAV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "      A Vencer"                                         , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLITAV          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldAVeIta               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitAVeIta               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 
                 

                 //Outros Bancos não classificados 
                 if nTitTotOutro > 0
	                 Linha += 50

	                 oPrn:Say( Linha , 0010 , "   Outros Bcos"                                          , oFont3 )
    	             oPrn:Say( Linha , 1000 , Transform(nSldTotOutro          , "@E 999,999,999.99"), oFont3 )
        	         oPrn:Say( Linha , 1400 , Transform(nSldVenOutro + nSldAVeOutro  , "@E 999,999,999.99"), oFont3 )
            	     oPrn:Say( Linha , 1870 , Transform(nTitTotOutro               , "@E 99999")         , oFont3 )
	
    	             Linha += 50
        	         oPrn:Say( Linha , 0010 , "      Vencidos"                                         , oFont4 )
	                 oPrn:Say( Linha , 1400 , Transform(nSldVenOutro               , "@E 999,999,999.99"), oFont4 )
    	             oPrn:Say( Linha , 1870 , Transform(nTitVenOutro               , "@E 99999")         , oFont4 )

        	         Linha += 50
            	     oPrn:Say( Linha , 0010 , "      A Vencer"                                         , oFont4 )
	                 oPrn:Say( Linha , 1400 , Transform(nSldAVeOutro               , "@E 999,999,999.99"), oFont4 )
    	             oPrn:Say( Linha , 1870 , Transform(nTitAVeOutro               , "@E 99999")         , oFont4 )

    			 endif 
                 Linha += 80

                 //TITULOS EM CARTEIRA
                 nDif := ((nSldTotCar / ZZ8->ZZ8_TVLCRT) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS EM CARTEIRA"                                    , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLCRT          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldTotCar               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotCar               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldVenCar / ZZ8->ZZ8_TVLCV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Vencidos"                                            , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLCV           , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldVenCar               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitVenCar               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldAVeCar / ZZ8->ZZ8_TVLCAV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   A Vencer"                                            , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLCAV          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldAVeCar               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitAVeCar               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80

                 //TITULOS EM COBRANÇA SEM REGISTRO
                 nDif := ((nSldCobSRe / ZZ8->ZZ8_TVLCSR) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS EM COBRANÇA SEM REGISTRO"                       , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLCSR          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldCobSRe               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitCobSRe               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50                                             
                 oPrn:Say( Linha , 0010 , "   Vencidos"                                            , oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldVenSRe               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitVenSRe               , "@E 99999")         , oFont4 )
                 Linha += 50
                 oPrn:Say( Linha , 0010 , "   A Vencer"                                            , oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldAVeSRe               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitAVeSRe               , "@E 99999")         , oFont4 )

                 Linha += 80

                 //CHEQUES A RECEBER
                 nDif := ((nSldCHQRec / ZZ8->ZZ8_TVLCAR) * 100) - 100
                 oPrn:Say( Linha , 0010 , "CHEQUES A RECEBER"                                      , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLCAR          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldCHQRec               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitCHQRec               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80

                 //CHEQUES DEVOLVIDOS
                 nDif := ((nSldCHQDev / ZZ8->ZZ8_TVLCD) * 100) - 100
                 oPrn:Say( Linha , 0010 , "CHEQUES DEVOLVIDOS"                                     , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLCD           , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldCHQDev               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitCHQDev               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80


                 //TITULOS DE TERCEIROS
/*                 nDif := ((nSldPodTer / ZZ8->ZZ8_VLTT) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS DE TERCEIROS"                                   , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_VLTT            , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldPodTer               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitPodTer               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80
*/
  
                 //TITULOS PROTESTADOS
                 nDif := ((nSldTotPro / ZZ8->ZZ8_TVLPP) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS PROTESTADOS"                                    , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLPP           , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldTotPro                , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotPro               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldProSPr / ZZ8->ZZ8_TVLPS) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Somente Protestados"                                 , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLPS           , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldProSPr               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitProSPr               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldProTer / ZZ8->ZZ8_TVLPT) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Titulos de Terceiros"                                , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLPT           , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldProTer               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitProTer               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80

                 //TITULOS EM ESCRITÓRIO DE COBRANÇA
                 nDif := ((nSldEscCob / ZZ8->ZZ8_TVLEC) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS EM ESCRITÓRIO COBRANÇA"                         , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLEC           , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldEscCob               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitEscCob               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80

                 nDif := ((nSldJurCar / ZZ8->ZZ8_TVLJCAR) * 100) - 100
                 oPrn:Say( Linha , 0010 , "JUROS S/TITULOS PAGOS EM CARTORIO"                      , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLJCAR         , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldJurCar               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitJurCar               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 120

                 nSldTotGer -= (nSldTitNCC + nSldTotLeP + nSldRecAnt)
                 nTitTotGer -= (nTitTotLeP + nTitTotNCC + nTitRecAnt)
                 nDif := ((nSldTotGer / ZZ8->ZZ8_TVLTOT) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TOTAL"                                                  , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLTOT          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldTotGer               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotGer               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )

                 Linha  += 100
                 TRACO_NORMAL
                 Linha  += 50

                 //TOTAL GERAL EM CARTEIRA
                 nTotCarGer := nSldTotCar+nSldCHQDev+nSldCHQRec+nSldJurCar
                 nQtdCarGer := nTitTotCar+nTitCHQDev+nTitCHQRec+nTitJurCar
                 nDif := ((nTotCarGer / ZZ8->ZZ8_TGCART) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TOTAL GERAL EM CARTEIRA"                                , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TGCART          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nTotCarGer               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nQtdCarGer               ,"@E 99999")          , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )

                 Linha += 50   
                 nTotCarVen := nSldVenCar + nSldCHQDev
                 nQtdCarVen := nTitVenCar + nTitCHQDev
                 nDif := ((nTotCarVen / ZZ8->ZZ8_TGCARV) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Vencidos"                                            , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TGCARV          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nTotCarVen               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nQtdCarVen               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )

                 Linha += 50
                 nTotCarAVe := nSldAVeCar + nSldCHQRec + nSldJurCar
                 nQtdCarAVe := nTitAVeCar + nTitCHQRec + nTitJurCar
                 nDif := ((nTotCarAVe / ZZ8->ZZ8_TGCARA) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   A Vencer"                                            , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TGCARA          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nTotCarAVe               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nQtdCarAVe               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80   

                 //VENCIDOS EM COBRANÇA SIMPLES
                 nTotVenCSi := nSldVenBrs + nSldVenBrd + nSldVenIta + nSldVenOutro
                 nQtdVenCSi := nTitVenBrs + nTitVenBrd + nTitVenIta + nTitVenOutro
                 nDif := ((nTotVenCSi / ZZ8->ZZ8_TVENCS) * 100) - 100
                 oPrn:Say( Linha , 0010 , "VENCIDOS EM COBRANÇA SIMPLES"                           , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVENCS          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nTotVenCSi               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nQtdVenCSi               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80


                 //TOTAL DE TITULOS VENCIDOS
                 nTotVenGer := nSldVenBrs + nSldVenBrd + nSldVenIta + nSldVenOutro + nSldVenCar + nSldCHQDev + nSldTotPro + nSldEscCob + nSldVenSRe
                 nQtdVenGer := nTitVenBrs + nTitVenBrd + nTitVenIta + nTitVenOutro + nTitVenCar + nTitCHQDev + nTitTotPro + nTitEscCob + nTitVenSRe
                 nDif := ((nTotVenGer / ZZ8->ZZ8_TTVENC) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TOTAL DE TITULOS VENCIDOS"                              , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TTVENC          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nTotVenGer               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nQtdVenGer               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )

                 Linha  += 100
                 TRACO_NORMAL
                 Linha  += 50

                 //TITULOS DE RECEBIMENTO ANTECIPADO
                 nDif := ((nSldRecAnt / ZZ8->ZZ8_TVLRA) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS DE REC.ANTECIPADO"                              , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLRA           , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldRecAnt               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitRecAnt               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80

                 //TITULOS EM LUCROS E PERDAS
                 nDif := ((nSldTotLeP / ZZ8->ZZ8_TVLLP) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS EM LUCROS E PERDAS ( - )"                       , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLLP           , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldTotLeP               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotLeP               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldSomLeP / ZZ8->ZZ8_TVLLPS) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Somente Lucros e Perdas"                             , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLLPS          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldSomLeP               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitSomLeP               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 50
                 nDif := ((nSldLePEsc / ZZ8->ZZ8_TVLLPE) * 100) - 100
                 oPrn:Say( Linha , 0010 , "   Em Escritório Cobrança"                              , oFont4 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLLPE          , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1400 , Transform(nSldLePEsc               , "@E 999,999,999.99"), oFont4 )
                 oPrn:Say( Linha , 1870 , Transform(nTitLePEsc               , "@E 99999")         , oFont4 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )
                 Linha += 80

                 //TITULOS DE NCC
                 nDif := ((nSldTitNCC / ZZ8->ZZ8_TVLNCC) * 100) - 100
                 oPrn:Say( Linha , 0010 , "TITULOS DE NCC( - )"                                    , oFont2 )
                 oPrn:Say( Linha , 1000 , Transform(ZZ8->ZZ8_TVLNCC          , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1400 , Transform(nSldTitNCC               , "@E 999,999,999.99"), oFont3 )
                 oPrn:Say( Linha , 1870 , Transform(nTitTotNCC               , "@E 99999")         , oFont3 )
                 oPrn:Say( Linha , 2160 , Transform(nDif                     , "@E 999.99%")       , oFont3 )

                 Linha  += 100
                 TRACO_NORMAL
                 Linha  += 100

               AVENDPAGE
       AVENDPRINT

       oFont1:End()
       oFont2:End()
       oFont3:End()
       oFont4:End()
       oFont5:End()

       DBSelectArea("TCQ")
       Dbcloseare()

       MS_FLUSH()
Return Nil 

*-------------------------*
Static FUNCTION FIN025Cab()
*-------------------------*      

If Linha <> 0
  AVNEWPAGE
Endif    

nPag   += 1
Linha  := 10                           
cMes01 := MesExtenso(Month(mv_par01))
cMes02 := MesExtenso(Month(dDatAnt))

oPrn:Say( Linha , 010  , ALLTRIM(SM0->M0_FILIAL)+"/BRFIN025"               , oFont1 )
oPrn:Say( Linha , 500  , "D E M O N S T R A T I V O   F I N A N C E I R O" , oFont2 )
oPrn:Say( Linha , 2100 , "PAG........:"                        , oFont1 )
oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                       , oFont1 ) 
Linha += 70
oPrn:Say( Linha , 10   , "Posição até: "+DTOC(mv_par01)        , oFont1 )        
oPrn:Say( Linha , 2100 , "Emissão.:"                           , oFont1 )
oPrn:Say( Linha , 2240 , DTOC(dDataBase)                       , oFont1 ) 
Linha += 40
TRACO_BOLD1 
Linha += 20   
oPrn:Say( Linha , 0010 , "DESCRIÇÃO"                           , oFont3 ) 
oPrn:Say( Linha , 1100 , UPPER(cMes02)                         , oFont3 ) 
oPrn:Say( Linha , 1500 , UPPER(cMes01)                         , oFont3 )
oPrn:Say( Linha , 1850 , "QTD.TIT."                            , oFont3 ) 
oPrn:Say( Linha , 2200 , "Dif.%"                               , oFont3 )
Linha += 70
TRACO_BOLD1
Linha += 30 

Return Nil





STATIC FUNCTION DATAFINAL(dData)
/*
dDtFim := CTOD("")
IF SUBSTR(DTOC(dData),4,2)$"01*03*05*07*08*10*12"
  dDtFim := CTOD("31/"+SUBSTR(DTOC(dData),4,5))
ELSEIF SUBSTR(DTOC(dData),4,2)$"04*06*09*11"
  dDtFim := CTOD("30/"+SUBSTR(DTOC(dData),4,5))
ELSEIF SUBSTR(DTOC(dData),4,2) == "02"          
  dDtFim := CTOD("28/"+SUBSTR(DTOC(dData),4,5))
ENDIF */
dDtFim := CTOD(StrZero(F_ULTDIA(dData), 2)+'/'+StrZero(Month(dData), 2)+'/'+StrZero(Year(dData), 4))
Return dDtFim


//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
// Função....: VldPerg                             //
// Data......: 03/02/04                            //
// Descrição.: Verifica as perguntas incluindo-as  //
//             caso não existam                    //
// Uso.......: BRFIN025                            //
//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
*-----------------------*
Static Function VldPerg() 
*-----------------------*     
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

//=//=//=//=//=//=//=//=//=//=//=//=//   
//           PARAMETROS             //
//=//=//=//=//=//=//=//=//=//=//=//=//
//                                  //
// MV_PAR01 - Data Limite           //
// MV_PAR02 - Salvar Demonstrativo  //
//                                  //
//=//=//=//=//=//=//=//=//=//=//=//=//
cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data Limite?          ","","","mv_ch1","D",08,0,0,"G","","mv_par01",""   ,""   ,""   ,"","",""   ,""  ,""  ,"","","","","","","","","","","","","","","","","",""}) 
AADD(aRegs,{cPerg,"02","Gravar Demonstrativo? ","","","mv_ch2","N",01,0,2,"C","","mv_par02","Sim","Si" ,"Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
  If ! dbSeek(cPerg+aRegs[i,2])
	RecLock("SX1",.T.)
	For j:=1 to FCount()
      If j <= Len(aRegs[i])
		FieldPut(j,aRegs[i,j])
	  Endif
	Next
	MsUnlock()
  Endif
Next
dbSelectArea(_sAlias)

Return

/*/
Tabela de Cores p/ fun‡„o GRF_SetData()
00 Preto         01 Marrom      02 Verde    03 Verde Oliva
04 Azul Navy     05 Purpura     06 Ciano    07 Cinza
08 Prata         09 Vermelho    10 Visgo    11 Amarelo
12 Azul          13 Fuchsia     14 Aqua     15 Cinza Claro
16 Cinza Escuro  17 Branco

DEFINE MSDIALOG oDlg FROM 10,10 TO 500,650 TITLE "DEMONSTRATIVO FINANCEIRO" PIXEL

oGrafico := GRF_CreateNew(oDlg)		  // Cria o gráfico
GRF_ChartType(oGrafico,1)			  // Define tipo de grafico
GRF_WinSet(oGrafico,20,5,400,595)     // Define coordenadas dentro do dialogo oDlg
GRF_Chart3d(oGrafico,.T.)			  // Define aparencia 3D ou 2D
GRF_InitData(oGrafico)				  // Zera a série de Dados

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLPP ,UPPER(SUBSTR(cMes01,1,3))+" - Protesto",01)
GRF_SetData(oGrafico,0,0,nSldTotPro      ,UPPER(SUBSTR(cMes02,1,3))+" - Protesto",00)

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLPP ,UPPER(SUBSTR(cMes01,1,3)),02)
GRF_SetData(oGrafico,0,0,nSldTotLeP      ,UPPER(SUBSTR(cMes02,1,3)),03)

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLRA ,UPPER(SUBSTR(cMes01,1,3)),04)
GRF_SetData(oGrafico,0,0,nSldRecAnt      ,UPPER(SUBSTR(cMes02,1,3)),05) 

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_VLTT  ,UPPER(SUBSTR(cMes01,1,3)),06)
GRF_SetData(oGrafico,0,0,nVlDptTer      ,UPPER(SUBSTR(cMes02,1,3)),07) 

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLEC ,UPPER(SUBSTR(cMes01,1,3)),08)
GRF_SetData(oGrafico,0,0,nSldEscCob      ,UPPER(SUBSTR(cMes02,1,3)),09) 

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLCRT,UPPER(SUBSTR(cMes01,1,3)),10)
GRF_SetData(oGrafico,0,0,nVlCartei      ,UPPER(SUBSTR(cMes02,1,3)),11) 

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLCSR,UPPER(SUBSTR(cMes01,1,3)),12)
GRF_SetData(oGrafico,0,0,nVlCobSre      ,UPPER(SUBSTR(cMes02,1,3)),13)

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLCS ,UPPER(SUBSTR(cMes01,1,3)),14)
GRF_SetData(oGrafico,0,0,nSldTotCSi     ,UPPER(SUBSTR(cMes02,1,3)),15)

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLCAR,UPPER(SUBSTR(cMes01,1,3)),16)
GRF_SetData(oGrafico,0,0,nVlChqRec      ,UPPER(SUBSTR(cMes02,1,3)),17) 

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLCD ,UPPER(SUBSTR(cMes01,1,3)),18)
GRF_SetData(oGrafico,0,0,nVlChqDev      ,UPPER(SUBSTR(cMes02,1,3)),19) 

GRF_SetData(oGrafico,0,0,ZZ8->ZZ8_TVLNCC,UPPER(SUBSTR(cMes01,1,3)),20)
GRF_SetData(oGrafico,0,0,nSldTitNCC         ,UPPER(SUBSTR(cMes02,1,3)),21) 

GRF_EndData(oGrafico,500)		// Finaliza entrada de dados 

ACTIVATE MSDIALOG odlg CENTERED

/*/
