#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Avprint.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR12 º Autor ³ Luís G. de Souza   º Data ³  31/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relação dos itens que faltam para retirada do estoque.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR12(cOpcMen)
     Local titulo    := "Relação de Faltas"
     Local cQry1     := ""
     Local nY
     Private lEnd    := .f.
     Private aNumPed := {}
     Private aNumCar := {}
 	 Private parpad01 := 0
	 Private parpad02 := ""  
	 Private parpad03 := 0
	 Private parpad04 := 0
	 Private parpad05 := '  /  /  ' 
	 Private parpad06 := 0
	 Private parpad07 := 1
         
    if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  	endif 


     DbSelectArea("ZZC")
     DbSetOrder(1)
     cOpcMen := Iif(cOpcMen == Nil, '', 'M')
     If cOpcMen $ 'M'
        cOpcRel := 2                       //2 - Bordero de Despacho
     Else
        //VldPerg()  //LGS#20200212 - Adequação de release 12.1.25 e posteriores
        If !Pergunte("FAR121", .T.)
           Return
        Endif
        cOpcRel := mv_par01                //Opção do Relatório: 1 - Bordero de Pedidos, 2 - Bordero de Despacho, 3 - Pedido, 4 - Cliente
     Endif

     If cOpcRel == 1                    //Bordero de Pedidos
        If !Pergunte("FAR122", .T.)
           Return
        Else		
           If mv_par03 == 1
              cQry1 += "SELECT ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS ZZC_QUANTI, MAX(SB1.B1_PESBRU) AS B1_PESBRU "
           Else
              cQry1 += "SELECT ZZC.ZZC_PRODUT,                 SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS ZZC_QUANTI, MAX(SB1.B1_PESBRU) AS B1_PESBRU "
           Endif
           cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
           cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (SB1.B1_COD = ZZC.ZZC_PRODUT) "
           cQry1 += "WHERE (ZZC.D_E_L_E_T_ <> '*') AND (ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (ZZC.ZZC_SEPARA = 'N') "
           If mv_par01 == 2 //Por bodero de pedidos
              cQry1 += "  AND (ZZC.ZZC_BORDER = '"+mv_par02+"') "
           Endif
           If mv_par04 == 2     //Base D'Agua
              cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('08', '41', '42', '43', '44', '46', '47', '48', '49', '52', '54', '57', '59','62','84', '88', '89', '90', '91', '92','93') OR SUBSTRING(ZZC.ZZC_PRODUT, 1, 10) IN('NC 0600361','TD 0600363')) "
           //ElseIf mv_par04 == 3 // Linhas Alvaro
                  //cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('00', '04', '11', '22', '23', '24', '26', '34', '80', '84')) "
		  //	  cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('84','85','86','87','88','89') OR SUBSTRING(ZZC.ZZC_PRODUT, 1, 5) IN('PA 15','CF 59','AS 46','ED 59','NC 06','FS 06','TS 06')) "
           ElseIf mv_par04 == 4 //Aut. Poliester (BP 34 E BM BASE POLIESTER ,PREMIUM E BC)+ LINHA 23
                  cQry1 += "  AND ((SUBSTRING(ZZC.ZZC_PRODUT, 1, 5) ='BP 34') OR (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) ='23') OR ((SUBSTRING(ZZC.ZZC_PRODUT, 4, 2)='00' AND (SUBSTRING(ZZC.ZZC_PRODUT, 8, 3) NOT BETWEEN('140') AND ('199')))))
           ElseIf mv_par04 == 5 //Tinta a pó
                  cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('97','98','99')) "
           Endif
           If mv_par03 == 1 .or. mv_par03 == 3
              cQry1 += "GROUP BY ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO "
              cQry1 += "ORDER BY ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO "
           Else
              cQry1 += "GROUP BY ZZC.ZZC_PRODUT "
              cQry1 += "ORDER BY ZZC.ZZC_PRODUT "
           Endif
        Endif
     ElseIf cOpcRel == 2            //Bordero de Despacho
            If cOpcMen $ 'M'
               //LGS#20200212 - Adequação de release 12.1.25 e posteriores
               /*DbSelectArea("SX1")
               DbSetOrder(1)
               DbSeek('FAR123    01  ')
               If Found()
                  RecLock("SX1", .f.)
                     SX1->X1_PRESEL := 2             //01 - Quais Borderos ?
                  MsUnLock()
                  parpad01 := 2
               Endif
               DbSeek('FAR123    02  ')
               If Found()
                  RecLock("SX1", .f.)
                     SX1->X1_CNT01 := SZA->ZA_CODIGO //02 - Numero do Bordero
                  MsUnLock()
                  parpad02 := SZA->ZA_CODIGO
               Endif
               DbSeek('FAR123    03  ')
               If Found()
                  RecLock("SX1", .f.)
                     SX1->X1_PRESEL := 2             //03 - Analítico ou Sintético?
                  MsUnLock()
                  parpad03 := 2
               Endif
               DbSeek('FAR123    04  ')
               If Found()
                  RecLock("SX1", .f.)
                     SX1->X1_PRESEL := 1             //04 - Linhas Moveleira, Automotiva
                  MsUnLock()
                  parpad04 := 1
               Endif
               DbSeek('FAR123    05  ')
               If Found()
                  RecLock("SX1", .f.)
                     SX1->X1_CNT01 := '  /  /  '     //05 - Data de previsão
                  MsUnLock()
                  parpad05 := '  /  /  '
               Endif*/
/*               DbSeek('FAR123    06  ')
               If Found()
                  RecLock("SX1", .f.)
                     SX1->X1_PRESEL := 1             //06 - Geral, Fabrica I ou Fabrica II
                  MsUnLock()
                  parpad06 := 1
               Endif  
               DbSeek('FAR123    07  ')
               If Found()
                  RecLock("SX1", .f.)
                     SX1->X1_PRESEL := 2             //03 - Produto / Quadrante ?
                  MsUnLock()
                  parpad07 := 2
               Endif*/
               
			   parpad01 := 2
               parpad02 := SZA->ZA_CODIGO
               parpad03 := 2
               parpad04 := 1
               parpad05 := '  /  /  '
               parpad06 := 1
               parpad07 := 2

               If !Pergunte("FAR123", .T.)
                  Return
               Else
                  If parpad01 == 2 .and. !empty(parpad02)
                      mv_par01 := parpad01
	                   mv_par02 := parpad02
    	                mv_par04 := parpad04
        	             mv_par05 := parpad05
            	       mv_par06 := parpad06
            	      //mv_par07 := parpad07
               	  Endif	      
               Endif
            Else
               If !Pergunte("FAR123", .T.)
                  Return
               Endif
            Endif
            cQry1 := ""
            
            //mv_par03 := 3
            If mv_par03 == 1 .or. mv_par03 == 3
               cQry1 += "SELECT ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO, ZZC.ZZC_CARGA, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS ZZC_QUANTI, MAX(SB1.B1_PESBRU) AS B1_PESBRU, CASE WHEN SB2.B2_LOCALIZ  ='' OR SB2.B2_LOCALIZ IS NULL  THEN '_ZZZZZZ' ELSE SB2.B2_LOCALIZ END AS B2_LOCALIZ "
            Else
               cQry1 += "SELECT ZZC.ZZC_PRODUT,                 ZZC.ZZC_CARGA, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS ZZC_QUANTI, MAX(SB1.B1_PESBRU) AS B1_PESBRU, CASE WHEN SB2.B2_LOCALIZ  ='' OR SB2.B2_LOCALIZ IS NULL  THEN '_ZZZZZZ' ELSE SB2.B2_LOCALIZ END AS B2_LOCALIZ "
/*
               cQry1 += "SELECT DISTINCT ZZC.ZZC_PRODUT,                 ZZC.ZZC_CARGA, "+;
               "ZZC_QUANTI = (SELECT SUM(ZZCX.ZZC_QUANTI - ZZCX.ZZC_RETIRA) FROM "+RetSqlName("ZZC")+" ZZCX WITH (NOLOCK) "+;
              	"WHERE (ZZCX.D_E_L_E_T_ <> '*') AND (ZZCX.ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (ZZCX.ZZC_SEPARA = 'N') AND (ZZCX.ZZC_PRODUT = ZZC.ZZC_PRODUT)), "+;
               "SB1.B1_PESBRU, CASE WHEN SB2.B2_LOCALIZ  ='' OR SB2.B2_LOCALIZ IS NULL  THEN '_ZZZZZZ' ELSE SB2.B2_LOCALIZ END AS B2_LOCALIZ "
*/              	
            Endif
            cQry1 += " FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
            cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.C6_FILIAL = '"+xFilial("SC6")+"') AND SC6.C6_NUM = ZZC.ZZC_PEDIDO AND SC6.C6_PRODUTO = ZZC.ZZC_PRODUT AND (SC6.D_E_L_E_T_ = '') " // Jose 11/04/2025
            cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (SB1.B1_COD = ZZC.ZZC_PRODUT) AND (SB1.D_E_L_E_T_ ='') "
            If substr(cnumemp,1,2) = "06" // Jose 14/04/2025.
               cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.B2_FILIAL = '"+xFilial("SB2")+"') AND (SB1.B1_COD = SB2.B2_COD) AND (SB1.B1_LOCPAD = SB2.B2_LOCAL) AND (SB2.D_E_L_E_T_ ='') "  
            Else // Jose 14/04/2025.
               cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.B2_FILIAL = '010101') AND (SB1.B1_COD = SB2.B2_COD) AND (CASE WHEN SC6.C6_LOCAL IN('G3') THEN 'A3' ELSE SC6.C6_LOCAL END = SB2.B2_LOCAL) AND (SB2.D_E_L_E_T_ = '')" // Jose 11/04/2025.
            EndIf // Jose 14/04/2025.
            cQry1 += " WHERE (ZZC.D_E_L_E_T_ = '') AND (ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (ZZC.ZZC_SEPARA = 'N') "
//          cQry1 += "AND (ZZC.D_E_L_E_T_ = '') AND (SB1.B1_TIPO IN('PI','MP') OR SUBSTRING(SB1.B1_COD,1,5)='ST 55' OR SB1.B1_TIPO IN('PA') AND LEN(SB1.B1_COD) <12) "
            cQry1 += "AND (SB1.B1_TIPO IN('PI','MP','PA','GG')) "

            If mv_par01 == 2     //Por bodero de despacho
               cQry1 += "AND (ZZC.ZZC_CARGA  = '"+mv_par02+"') "
            Else
               cQry2 := ""
               cQry2 += "SELECT ZA_PREVDSP,ZA_REGIAO, ZA_DESCR, ZA_CODIGO "
               cQry2 += "FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) "
               cQry2 += "WHERE (SZA.ZA_FILIAL  = '"+xFilial("SZA")+"') "
               cQry2 += "AND (SZA.D_E_L_E_T_ = '') "
               cQry2 += "AND (SZA.ZA_DTDESPA = '') "
               If !Empty(mv_par05)
                  cQry2 += "AND (SZA.ZA_PREVDSP = '"+Dtos(mv_par05)+"') "
               Endif
               cQry2 += "ORDER BY SZA.ZA_PREVDSP "
               TCQuery cQry2 ALIAS "QCAR" NEW
               DbSelectArea("QCAR")
               DbGoTop()
               nCont   := 0
               cUltPre := ''
               While !Eof()
                     If Empty(QCAR->ZA_PREVDSP)
                        cOrdImp := '999'
                     Else
                        If !QCAR->ZA_PREVDSP == cUltPre
                           nCont   += 1
                           cOrdImp := StrZero(nCont, 3)
                            cUltPre := QCAR->ZA_PREVDSP
                         Endif
                      Endif
                      aadd(aNumCar, {cOrdImp, QCAR->ZA_PREVDSP, QCAR->ZA_REGIAO, QCAR->ZA_DESCR, QCAR->ZA_CODIGO, 0 })
                      DbSelectArea("QCAR")
                      DbSkip()
               EndDo
               DbSelectArea("QCAR")
               DbCloseArea()
               aSort(aNumCar, , , {|x, y| x[1]+x[3] < y[1]+y[3]})
               If Len(aNumCar) <= 0
                  MsgAlert("Não existem cargas para esses parâmetros.", "Aguarde")
               Else
                  cAux1 := "'"
                  For nY := 1 To Len(aNumCar)
                      cAux1 += aNumCar[nY][5]+"', '"
                  Next
                  cAux1 := SubStr( cAux1, 1, Len(cAux1) - 3 )
                  cQry1 += "  AND (ZZC.ZZC_CARGA  IN("+cAux1+")) "
               Endif
            Endif
            If mv_par04 == 2     //Base D'Agua
            	 cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('08', '41', '42', '43', '44', '46', '47', '48', '49', '52', '54', '57', '59','62','84', '88', '89', '90', '91', '92','93') OR SUBSTRING(ZZC.ZZC_PRODUT, 1, 10) IN('NC 0600361','TD 0600363')) "
           	//ElseIf mv_par04 == 3 //Linhas Alvaro
                //cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('00', '04', '11', '22', '23', '24', '26', '34', '80', '84')) "
			//	  cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('84','85','86','87','88','89') OR SUBSTRING(ZZC.ZZC_PRODUT, 1, 5) IN('PA 15','CF 59','AS 46','ED 59','NC 06','FS 06','TS 06')) "
           	ElseIf mv_par04 == 4 //Aut. Poliester (BP 34 E BM BASE POLIESTER , PREMIUM E BC) + LINHA 23
                  cQry1 += "  AND ((SUBSTRING(ZZC.ZZC_PRODUT, 1, 5) ='BP 34') OR (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) ='23') OR ((SUBSTRING(ZZC.ZZC_PRODUT, 4, 2)='00' AND (SUBSTRING(ZZC.ZZC_PRODUT, 8, 3) NOT BETWEEN('140') AND ('199')))))
           	ElseIf mv_par04 == 5 //Tinta a Pó
                 cQry1 += "  AND (SUBSTRING(ZZC.ZZC_PRODUT, 4, 2) IN('97','98','99')) "
           	Endif
            If mv_par06 == 2     //Fabrica I
                cQry1 += "  AND (SB1.B1_LOCPAD IN('01','02','03','P1')) "
            ElseIf mv_par06 == 3 //Fabrica II
                cQry1 += "  AND (SB1.B1_LOCPAD IN('10','20','30','P2')) "
            Endif
            If mv_par03 == 1 .or. mv_par03 == 3 
                cQry1 += "GROUP BY ZZC.ZZC_CARGA, ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO, SB2.B2_LOCALIZ "
                If mv_par03 == 3 
                	cQry1 += "ORDER BY ZZC.ZZC_CARGA, ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO "
                Elseif mv_par07 == 1 .and. mv_par03 <> 3 
      				cQry1 += "ORDER BY ZZC.ZZC_CARGA, ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO "
                Elseif mv_par07 <> 1 .and. mv_par03 <> 3
		    	   	cQry1 += "ORDER BY ZZC.ZZC_CARGA, SB2.B2_LOCALIZ, ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO "           
		    	Endif
 	        Else
               	cQry1 += "GROUP BY ZZC.ZZC_CARGA, ZZC.ZZC_PRODUT, SB2.B2_LOCALIZ "
               	If mv_par07 == 1
					cQry1 += "ORDER BY ZZC.ZZC_CARGA, ZZC.ZZC_PRODUT, SB2.B2_LOCALIZ "
				Else
               		cQry1 += "ORDER BY ZZC.ZZC_CARGA, SB2.B2_LOCALIZ, ZZC.ZZC_PRODUT "
               	Endif
            Endif
     ElseIf cOpcRel == 3                //Pedidos
            If !Pergunte("FAR124", .T.)
               Return
            Endif
            Private cMsgBor := ""
            Private cStaBor := " "
            cNumBor := Posicione("SZG", 2, xFilial("SZG")+substr(cnumemp,1,2)+mv_par01, "ZG_CODIGO")
            If Empty(cNumBor)
               cMsgBor := "PEDIDO NÃO FOI SEPARADO!"
            Else
               cStaBor := Posicione("SZF", 1, xFilial("SZF")+cNumBor, "ZF_FLAG")
               If cStaBor $ 'D.E'
                  cMsgBor := "PEDIDO NÃO FOI SEPARADO!"
               ElseIf cStaBor $ 'P'
                      cMsgBor := "PARCIALMENTE RETIRADO!"
               Else
                  cMsgBor := "."
               Endif
               cQry1 += "SELECT ZZC.ZZC_PRODUT, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS ZZC_QUANTI "
               cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
               cQry1 += "WHERE (ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"') "
               cQry1 += "  AND (ZZC.D_E_L_E_T_ = '') "
               cQry1 += "  AND (ZZC.ZZC_PEDIDO  = '"+mv_par01+"') "
               If mv_par02 == 2
                  cQry1 += "  AND (ZZC.ZZC_SEPARA = 'N') "
               Endif
               cQry1 += "GROUP BY ZZC.ZZC_PRODUT "
               cQry1 += "ORDER BY ZZC.ZZC_PRODUT "
            Endif
     ElseIf cOpcRel == 4                //Cliente
            If !Pergunte("FAR125", .T.)
               Return
            Endif
            cQry2 := ""
            cQry2 += "SELECT SC5.C5_NUM, SC5.C5_TRANSP, SC5.C5_REDESP, SC5.C5_APROVA, SC5.C5_NOTA, SC5.C5_EMISSAO, SC5.C5_VOLUME1, SC5.C5_PBRUTO, SC5.C5_DTAPR "
            cQry2 += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
            cQry2 += "WHERE SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "
            cQry2 += "  AND SC5.D_E_L_E_T_ = '' "
            cQry2 += "  AND SC5.C5_CLIENTE = '"+MV_PAR01+"' "
            cQry2 += "  AND SC5.C5_NOTA    = '' "
            cQry2 += "ORDER BY SC5.C5_NUM DESC "
            TCQuery cQry2 ALIAS "QPED" NEW
            DbSelectArea("QPED")
            DbGoTop()
            While !Eof()  
				dDatLog := SubStr(QPED->C5_DTAPR, 7, 2)+'/'+SubStr(QPED->C5_DTAPR, 5, 2)+'/'+SubStr(QPED->C5_DTAPR, 3, 2)            	
                     
                  //Busca Valor Total do Pedido ou da Nota Fiscal
                  If Empty(QPED->C5_NOTA)
                     cQry1 := ""
                     cQry1 += "SELECT SUM(SC6.C6_VALOR) AS TOTAL "
                     cQry1 += "FROM "+RetSqlName("SC6")+" SC6 "
                     cQry1 += "WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
                     cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
                     cQry1 += "  AND SC6.C6_NUM     = '"+QPED->C5_NUM+"' "
                  Else
                     cQry1 := ""
                     cQry1 += "SELECT SUM(SF2.F2_VALBRUT) AS TOTAL "
                     cQry1 += "FROM "+RetSqlName("SF2")+" SF2 "
                     cQry1 += "WHERE SF2.F2_FILIAL  = '"+xFilial("SF2")+"'
                     cQry1 += "  AND SF2.D_E_L_E_T_ = '' "
                     cQry1 += "  AND SF2.F2_PEDIDO  = '"+QPED->C5_NUM+"' "
                  Endif
                  TCQuery cQry1 ALIAS "QTOT" NEW
                  DbSelectArea("QTOT")
                  cTotPed := Iif(Empty(QPED->C5_NOTA), 'V. MERC..: ', 'V. NOTA..: ')+TransForm(QTOT->TOTAL, "@E 9,999,999.99")
                  DbSelectArea("QTOT")                           
                  DbCloseArea()
                  //Busca informação de itens especificos.
                  cQry1 := ""
                  cQry1 += "SELECT TOP 1 SC6.R_E_C_N_O_ AS NAOEST "
                  cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
                  cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SC6.C6_FILIAL = SB1.B1_FILIAL) AND (SC6.C6_PRODUTO = SB1.B1_COD) AND (SB1.D_E_L_E_T_ = '') "
                  cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB1.B1_FILIAL = SB2.B2_FILIAL) AND (SB1.B1_COD = SB2.B2_COD) AND (B1_LOCPAD = B2_LOCAL) AND (SB2.D_E_L_E_T_ = '') "
                  cQry1 += "WHERE (SC6.C6_FILIAL  = '"+xFilial("SC6")+"') "
                  cQry1 += "  AND (SC6.D_E_L_E_T_ = '') "
                  cQry1 += "  AND (SC6.C6_NUM     = '"+QPED->C5_NUM+"') "
                  cQry1 += "  AND (SB2.B2_LOCALIZ = '') "
                  TCQuery cQry1 ALIAS "QNES" NEW
                  DbSelectArea("QNES")
                  cNaoEst := Iif(!eof() .and. !bof(), 'SIM', 'NAO')
                  DbSelectArea("QNES")
                  DbCloseArea()
                     
                  cStatus := Iif(QPED->C5_APROVA == '0' , 'Não Aprovado', Iif(QPED->C5_APROVA == '1', 'Aprovado', 'Bloqueado'))
                  cEmissa := SubStr(QPED->C5_EMISSAO, 7, 2)+'/'+SubStr(QPED->C5_EMISSAO, 5, 2)+'/'+SubStr(QPED->C5_EMISSAO, 3, 2)
                  cCodBor := Posicione("SZG", 2, xFilial("SZG")+'01'+QPED->C5_NUM, 'ZG_CODIGO')
                  cDatBor := DTOC(Posicione("SZF", 1, xFilial("SZF")+cCodBor, 'ZF_EMISSAO'))
                  cCodDes := Posicione("SZB", 2, xFilial("SZB")+'01'+QPED->C5_NUM, 'ZB_CODIGO')
                  cDesDes := SubStr(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_DESCR'), 1, 25)
                  cDespac := cCodDes+' - '+cDesDes
                  dDatPre := DTOC(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_PREVDSP'))
                  dDatDes := DTOC(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_DTDESPA'))
                  cVolume := Transform(QPED->C5_VOLUME1, "@E 999,999")
                  cPesoBr := Transform(QPED->C5_PBRUTO , "@E 999,999")
                  cPedPro := '  /  /  '
                  cResdes := Alltrim(QPED->C5_REDESP)+'-'+SubStr(Alltrim(Posicione("SA4", 1, xFilial("SA4")+QPED->C5_REDESP, "A4_NOME")), 1, 25)
                  cDesVia := 'DEPO. SP :'+DTOC(Posicione("ZZ0", 4, xFilial("ZZ0")+QPED->C5_NUM, 'ZZ0_ENTREG'))+' - '+SubStr(Posicione("SA4", 1, xFilial("SA4")+Posicione("ZZ0", 4, xFilial("ZZ0")+QPED->C5_NUM, 'ZZ0_REDESP'), 'A4_NOME'), 1, 25)
                  aAdd(aNumPed, {QPED->C5_NUM   ,; //01 - Numero do Pedido          - 01
                                 QPED->C5_TRANSP,; //02 - Código da Transportadora
                                 QPED->C5_REDESP,; //03 - Código do Redespacho
                                 cStatus        ,; //04 - Status do Pedido          - 04
                                 QPED->C5_NOTA  ,; //05 - Numero da Nota Fiscal     - 05
                                 cEmissa        ,; //06 - Data de Emissão do Pedido - 02
                                 cCodBor        ,; //07 - Código do Bordero         - 06
                                 cDatBor        ,; //08 - Data do Bordero           - 07
                                 cDespac        ,; //09 - Despacho                  - 09
                                 dDatLog        ,; //10 - Data do Log de Aprovação  - 03
                                 dDatPre        ,; //11 - Data de Previsão do Desp. - 10
                                 dDatDes        ,; //12 - Data do Despacho          - 11
                                 cVolume        ,; //13 - Volume
                                 cPesoBr        ,; //14 - Peso Bruto
                                 cPedPro        ,; //15 - Pedido Programado
                                 cTotPed        ,; //16 - Total do Pedido
                                 cResDes        ,; //17 - Redespacho
                                 cNaoEst        ,; //18 - Não estoque
                                 cDesVia        }) //19 - Despacho Viamix
                  DbSelectArea("QPED")
                  DbSkip()
            Enddo
            DbSelectArea("QPED")
            DbCloseArea()
            If mv_par02 > 0
               cQry2 := ""
               cQry2 += "SELECT TOP "+StrZero(mv_par02, 1)+" SC5.C5_NUM, SC5.C5_TRANSP, SC5.C5_REDESP, SC5.C5_APROVA, SC5.C5_NOTA, SC5.C5_EMISSAO, "
               cQry2 += "SC5.C5_VOLUME1, SC5.C5_PBRUTO,SC5.C5_DTAPR "
               cQry2 += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
               cQry2 += "WHERE SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "
               cQry2 += "  AND SC5.D_E_L_E_T_ = '' "
               cQry2 += "  AND SC5.C5_CLIENTE = '"+MV_PAR01+"' "
               cQry2 += "  AND SC5.C5_NOTA   <> '' "
               cQry2 += "ORDER BY SC5.C5_NUM DESC "
               TCQuery cQry2 ALIAS "QPED" NEW
               DbSelectArea("QPED")
               DbGoTop()
               While !Eof()
                     dDatLog := SubStr(QPED->C5_DTAPR, 7, 2)+'/'+SubStr(QPED->C5_DTAPR, 5, 2)+'/'+SubStr(QPED->C5_DTAPR, 3, 2)

                     If Empty(QPED->C5_NOTA)
                        cQry1 := ""
                        cQry1 += "SELECT SUM(SC6.C6_VALOR) AS TOTAL "
                        cQry1 += "FROM "+RetSqlName("SC6")+" SC6 "
                        cQry1 += "WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
                        cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
                        cQry1 += "  AND SC6.C6_NUM     = '"+QPED->C5_NUM+"' "
                     Else
                        cQry1 := ""
                        cQry1 += "SELECT SUM(SF2.F2_VALBRUT) AS TOTAL "
                        cQry1 += "FROM "+RetSqlName("SF2")+" SF2 "
                        cQry1 += "WHERE SF2.F2_FILIAL  = '"+xFilial("SF2")+"'
                        cQry1 += "  AND SF2.D_E_L_E_T_ = '' "
                        cQry1 += "  AND SF2.F2_PEDIDO  = '"+QPED->C5_NUM+"' "
                     Endif
                     TCQuery cQry1 ALIAS "QTOT" NEW
                     DbSelectArea("QTOT")
                     cTotPed := Iif(Empty(QPED->C5_NOTA), 'V. MERC..: ', 'V. NOTA..: ')+TransForm(QTOT->TOTAL, "@E 9,999,999.99")
                     DbSelectArea("QTOT")
                     DbCloseArea()

                     //Busca informação de itens especificos.
                     cQry1 := ""
                     cQry1 += "SELECT TOP 1 SC6.R_E_C_N_O_ AS NAOEST "
                     cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
                     cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SC6.C6_FILIAL = SB1.B1_FILIAL) AND (SC6.C6_PRODUTO = SB1.B1_COD) AND (SB1.D_E_L_E_T_ = '') "
                     cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB1.B1_FILIAL = SB2.B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) AND (SB2.D_E_L_E_T_ = '') "
                     cQry1 += "WHERE (SC6.C6_FILIAL  = '"+xFilial("SB1")+"') "
                     cQry1 += "  AND (SC6.D_E_L_E_T_ = '') "
                     cQry1 += "  AND (SC6.C6_NUM     = '"+QPED->C5_NUM+"') "
                     cQry1 += "  AND (SB2.B2_LOCALIZ = '') "
                     TCQuery cQry1 ALIAS "QNES" NEW
                     DbSelectArea("QNES")
                     cNaoEst := Iif(!eof() .and. !bof(), 'SIM', 'NAO')
                     DbSelectArea("QNES")
                     DbCloseArea()

                     cStatus := Iif(QPED->C5_APROVA == '0' , 'Não Aprovado', Iif(QPED->C5_APROVA == '1', 'Aprovado', 'Bloqueado'))
                     cEmissa := SubStr(QPED->C5_EMISSAO, 7, 2)+'/'+SubStr(QPED->C5_EMISSAO, 5, 2)+'/'+SubStr(QPED->C5_EMISSAO, 3, 2)
                     cCodBor := Posicione("SZG", 2, xFilial("SZG")+'01'+QPED->C5_NUM, 'ZG_CODIGO')
                     cDatBor := DTOC(Posicione("SZF", 1, xFilial("SZF")+cCodBor, 'ZF_EMISSAO'))
                     cCodDes := Posicione("SZB", 2, xFilial("SZB")+'01'+QPED->C5_NUM, 'ZB_CODIGO')
                     cDesDes := SubStr(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_DESCR'), 1, 25)
                     cDespac := cCodDes+' - '+cDesDes
                     dDatPre := DTOC(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_PREVDSP'))
                     dDatDes := DTOC(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_DTDESPA'))
                     cVolume := Transform(QPED->C5_VOLUME1, "@E 999,999")
                     cPesoBr := Transform(QPED->C5_PBRUTO , "@E 999,999")
                     cPedPro := '  /  /  '
                     cResdes := Alltrim(QPED->C5_REDESP)+'-'+SubStr(Alltrim(Posicione("SA4", 1, xFilial("SA4")+QPED->C5_REDESP, "A4_NOME")), 1, 25)
                     cDesVia := 'DEPO. SP : '+DTOC(Posicione("ZZ0", 4, xFilial("ZZ0")+QPED->C5_NUM, 'ZZ0_ENTREG'))+' - '+SubStr(Posicione("SA4", 1, xFilial("SA4")+Posicione("ZZ0", 4, xFilial("ZZ0")+QPED->C5_NUM, 'ZZ0_REDESP'), 'A4_NOME'), 1, 25)
                     aAdd(aNumPed, {QPED->C5_NUM   ,; //01 - Numero do Pedido          - 01
                                    QPED->C5_TRANSP,; //02 - Código da Transportadora
                                    QPED->C5_REDESP,; //03 - Código do Redespacho
                                    cStatus        ,; //04 - Status do Pedido          - 04
                                    QPED->C5_NOTA  ,; //05 - Numero da Nota Fiscal     - 05
                                    cEmissa        ,; //06 - Data de Emissão do Pedido - 02
                                    cCodBor        ,; //07 - Código do Bordero         - 06
                                    cDatBor        ,; //08 - Data do Bordero           - 07
                                    cDespac        ,; //09 - Despacho                  - 09
                                    dDatLog        ,; //10 - Data do Log de Aprovação  - 03
                                    dDatPre        ,; //11 - Data de Previsão do Desp. - 10
                                    dDatDes        ,; //12 - Data do Despacho          - 11
                                    cVolume        ,; //13 - Volume
                                    cPesoBr        ,; //14 - Peso Bruto
                                    cPedPro        ,; //15 - Pedido Programado
                                    cTotPed        ,; //16 - Total do Pedido
                                    cResdes        ,; //17 - Redespacho
                                    cNaoEst        ,; //18 - Não estoque
                                    cDesVia        }) //19 - Despacho Viamix
                     DbSelectArea("QPED")
                     DbSkip()
               Enddo
               DbSelectArea("QPED")
               DbCloseArea()
               If Len(aNumPed) <= 0
                  MsgAlert("Não existem pedidos para esse cliente.", "Aguarde")
                  Return
               Endif
            Endif
            If Len(aNumPed) > 0
               cAux1 := "'"
               For nY := 1 To Len(aNumPed)
                   cAux1 += aNumPed[nY][1]+"', '"
               Next
               cAux1 := SubStr( cAux1, 1, Len(cAux1) - 3 )
               cQry1 := ""
               cQry1 += "SELECT ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO, SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA) AS ZZC_QUANTI "
               cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
               cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
               cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
               cQry1 += "  AND ZZC.ZZC_PEDIDO IN("+cAux1+") "
               If mv_par03 == 2
                  cQry1 += "  AND ZZC.ZZC_SEPARA IN('N') "
               Endif
               cQry1 += "GROUP BY ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO "
               cQry1 += "ORDER BY ZZC.ZZC_PRODUT, ZZC.ZZC_PEDIDO "
            Else
               MsgAlert("Não foi encontrado informação para esse relatório", "Atenção")
            Endif
     Endif
     TCQuery cQry1 ALIAS "TCQ" NEW
     Processa({|lEnd| FATR12_1(Titulo, @lEnd) }, Titulo, ,.t.)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR12_1 º Autor ³ Luís G. de Souza   º Data ³  31/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR12_1(Titulo, lEnd)
       Local aMatImp   := {} 
       Local _cEst, nY, nA, nB
       Local cNumped   := ""
//     Local cLocal    := "A3" // Jose 15/04/2025 
       Local cLocaliz  := ""
       
       Private nLin    := 0
       Private nCol    := 30
       Private nLinMax := 2920
       Private nColMax := 2350
       Private nPesoFalta :=0
       nLin := 2920 + 30
       oFont1 := TFont():New("Courier New"        , 9, 19, .F., .F.,  5, .F., 5, .F., .F.)
       oFont2 := TFont():New("Courier New"        , 9, 14, .F., .F.,  5, .F., 5, .F., .F.)
       oFont3 := TFont():New("Courier New"        , 9, 14, .F., .T.,  5, .F., 5, .F., .F.)
       oFont4 := TFont():New("Courier New"        , 9, 13, .F., .F.,  5, .F., 5, .F., .F.)
       oFont5 := TFont():New("Courier New Itálico", 9, 14, .F., .F.,  5, .F., 5, .F., .F.)
       oFont6 := TFont():New("Courier New Itálico", 9, 08, .F., .F.,  5, .F., 5, .F., .F.)
       oFont7 := TFont():New("Courier New"        , 9, 12, .F., .F.,  5, .F., 5, .F., .F.)
       oFont8 := TFont():New("Courier New"        , 9, 12, .F., .T.,  5, .F., 5, .F., .F.)

       If cOpcRel == 1 // Bordeô de Pedidos
          Titulo := 'Faltas - Pedidos '+Iif(mv_par01 == 1, '(TODOS)', mv_par02)
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
                If mv_par03 == 1 .or. mv_par03 == 3
                   cNumPed := TCQ->ZZC_PEDIDO
                Else
                   cNumPed := space(06)
                Endif
                If aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)}) == 0
                   nQtdPro := 0
                   cNumOP:= "'"
                   cNumLT:= "'"
					    cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
				    	 "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
			    		 "WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
				   	 "AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+TCQ->ZZC_PRODUT+"') "+;
					    "GROUP BY SC2.C2_OP, SC2.C2_LOTE"
                   TCQuery cQry2 ALIAS "QOP" NEW
                   DbSelectArea("QOP")
                   While !Eof()
                         nQtdPro += QOP->QUANT
                         cNumOP  += QOP->ORDEM+"', '"
                         cNumLT  += QOP->LOTE+"', '"
                         DbSelectArea("QOP")
                         DbSkip()
                   Enddo
                   DbSelectArea("QOP")
                   DbCloseArea()
                   If !cNumLT == "'"
                      cQry2 := ""
                      cQry2 += "SELECT TOP 1 * "
                      cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                      cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                      //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
                      cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                      cQry2 += "ORDER BY PSQ.FIM "
                      TCQuery cQry2 ALIAS "QOP" NEW
                      If Empty(QOP->STATUS)
                         DbSelectArea("QOP")
                         DbCloseArea()
                         cQry2 := ""
                         cQry2 += "SELECT TOP 1 * "
                         cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                         cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                         //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
					      	 cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                         cQry2 += "ORDER BY PSQ.FIM "
                         TCQuery cQry2 ALIAS "QOP" NEW
                      Endif
                      DbSelectArea("QOP")
                      cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                      DbSelectArea("QOP")
                      DbCloseArea()

                      cQry2 := ""
                      cQry2 += "SELECT TOP 1 * "
                      cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                      cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                      cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                      cQry2 += "ORDER BY PSQ.FIM "
                      TCQuery cQry2 ALIAS "QOP" NEW
                      If Empty(QOP->STATUS)
                         DbSelectArea("QOP")
                         DbCloseArea()
                         cQry2 := ""
                         cQry2 += "SELECT TOP 1 * "
                         cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                         cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                         cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                         cQry2 += "ORDER BY PSQ.FIM "
                         TCQuery cQry2 ALIAS "QOP" NEW
                      Endif
                      DbSelectArea("QOP")
                      cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                      DbSelectArea("QOP")
                      DbCloseArea()
                   Else
                      cPesado := ' '
                      cEnvase := ' '
                   Endif
//   Jose 15/04/2025
                   cQry2 := "SELECT SB2.B2_LOCALIZ "+;
						          "  FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "+;
					             " WHERE (SB2.B2_FILIAL  = '010101') AND (SB2.D_E_L_E_T_ = '') "+;      // "+xFilial("SC2")+"'
				        		    "   AND (SB2.B2_LOCAL   = 'A3') AND (SB2.B2_COD = '"+TCQ->ZZC_PRODUT+"') "+;
						          "GROUP BY SB2.B2_LOCALIZ"
						          If Select( "SB20" ) > 0
                               DbSelectArea( "SB20" )
                               DbCloseArea()
                            Endif
                            TCQuery cQry2 ALIAS "SB20" NEW
                            DbSelectArea("SB20")
                            cLocaliz := ""
                            While !Eof()
                                  cLocaliz := SB20->B2_LOCALIZ
                                  DbSelectArea("SB20")
                                  DbSkip()
                            Enddo
                            DbSelectArea("SB0")
                            DbCloseArea()
// JOSE 14/04/2025   
                   If mv_par02 $ '000000'
/*
                     If Empty(Alltrim(Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ")))
                         aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU})
                      Endif
                   Else
                      aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU})
                   Endif
                Else
                   If mv_par03 == 1 .or. mv_par03 == 3
                      If mv_par02 $ '000000'
                         If Empty(Alltrim(Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ")))
                            aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, '', '', TCQ->B1_PESBRU})
                         Endif
                      Else
                         aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, '', '', TCQ->B1_PESBRU})
                      Endif
                   Else
                      aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)})][2] += TCQ->ZZC_QUANTI
                   Endif
*/
//    jOSE 14/04/2025
                     If Empty(Alltrim(Posicione("SB2", 1, '010101'+TCQ->ZZC_PRODUT+cLocaliz)))
                         aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU})
                      Endif
                   Else
                      aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU})
                   Endif
                Else
                   If mv_par03 == 1 .or. mv_par03 == 3
                      If mv_par02 $ '000000'
                         If Empty(Alltrim(Posicione("SB2", 1, '010101'+TCQ->ZZC_PRODUT+cLocaliz)))
                            aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "R", cNumPed, '', '', TCQ->B1_PESBRU})
                         Endif
                      Else
                         aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "R", cNumPed, '', '', TCQ->B1_PESBRU})
                      Endif
                   Else
                      aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)})][2] += TCQ->ZZC_QUANTI
                   Endif
// ATÉ AQUI JOSE 14/04/2025
                Endif
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
          DbSelectArea("TCQ")
          DbCloseArea()

          ProcRegua(Len(aMatImp))
          If Len(aMatImp) > 0
             oPrn:= TMSPrinter():New( "Relação de Faltas" )
             oPrn:SetPortrait()      //SetLandscape()
             AVPRINT oPrn NAME "Relação de Faltas"
                     AVPAGE
                       For nY := 1 To Len(aMatImp)
                           If nY == 1
                              nLin := 160
                              FATR12_2(1)     //Cabeçalho
                           ElseIf nLin >= (nLinMax - 100)
                                  FATR12_2(2) //Rodape 
                                  AVNEWPAGE
                                  nLin := 160
                                  FATR12_2(1) //Cabeçalho
                           Endif 
////qui 15/06/2022
                           _cEst := iif(EHESTOQUE(aMatImp[nY][1]),"*"," ")
///-----------------------------------------------------------
                           oPrn:Say(nLin, nCol     , TransForm(aMatImp[nY][2], "@E 99999")                                                                                  , oFont7, , , , ) //Quantidade de Falta
                           oPrn:Say(nLin, nCol+0150, _cEst         , oFont7, , , , ) //Marca de Item de Estoque
                           oPrn:Say(nLin, nCol+0180, TransForm(aMatImp[nY][1], "@R XX 99.99.999-99")                                                                        , oFont7, , , , ) //Código do Produto
                           oPrn:Say(nLin, nCol+0580, SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][1], "B1_DESC")), 1, 20)                                  , oFont7, , , , ) //Descrição do Produto  // jose 16/04/2025 (nLin, nCol+0600
                           oPrn:Say(nLin, nCol+1300, aMatImp[nY][6]                                                                                                         , oFont7, , , , ) // jose 16/04/2025 (nLin, nCol+1400
                           oPrn:Say(nLin, nCol+1500, SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nY][1], 11, 2), "Z5_DESCR"), 1, 11)                           , oFont7, , , , ) //Descrição da Embalagem // jose 16/04/2025 (nLin, nCol+1600
                           oPrn:Say(nLin, nCol+1800, SubStr(Iif(Empty(aMatImp[nY][3]), ' ', SubStr(Alltrim(aMatImp[nY][3]), 1, 15)), 1, 14)                                  , oFont7, , , , ) //Localização // jose 16/04/2025  (nLin, nCol+1900,
                           oPrn:Say(nLin, nCol+2150, aMatImp[nY][7]+Iif((mv_par03 == 1 .or. mv_par03 == 3) .and. aMatImp[nY][5] == 'R', '', TransForm(aMatImp[nY][4], "@E 99999"))+aMatImp[nY][8], oFont7, , , , ) //Qtde. Produção
                           nPesoFalta := ((aMatImp[nY][9] * aMatImp[nY][2]) + nPesoFalta)
                           nLin += 50
                       Next
                       FATR12_2(2) //Rodape 
                     AVENDPAGE
             AVENDPRINT
          Else
             MsgAlert("Não foi encontrado informação para esse relatório", "Atenção")
          Endif
       ElseIf cOpcRel == 2 //Bordero de Despacho
              Titulo := 'Faltas - Despacho '+Iif(mv_par01 == 1, '(TODOS)', mv_par02)
              If mv_par01 == 1
                 For nA := 1 To Len(aNumCar)
                     DbSelectArea("TCQ")
                     DbGoTop()
                     While !Eof()
                           If TCQ->ZZC_CARGA == aNumCar[nA][5]
                              If mv_par03 == 1 .or. mv_par03 == 3
                                 cNumPed := TCQ->ZZC_PEDIDO
                              Else
                                 cNumPed := space(06)
                              Endif
                              If aScan(aMatImp, {|x| Alltrim(x[1]+x[7]) == Alltrim(TCQ->ZZC_PRODUT+TCQ->ZZC_CARGA)}) == 0
                                 nQtdPro := 0
                                 cNumOP:= "'"
                                 cNumLT:= "'"
								cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
								"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
								"WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
								"AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+TCQ->ZZC_PRODUT+"') "+;
								"GROUP BY SC2.C2_OP, SC2.C2_LOTE"
								 
                                 TCQuery cQry2 ALIAS "QOP" NEW
                                 DbSelectArea("QOP")
                                 While !Eof()
                                       nQtdPro += QOP->QUANT
                                       cNumOP  += QOP->ORDEM+"', '"
                                       cNumLT  += QOP->LOTE+"', '"
                                       DbSelectArea("QOP")
                                       DbSkip()
                                 Enddo
                                 DbSelectArea("QOP")
                                 DbCloseArea()
                                 
                                 If !cNumLT == "'"
                                    cQry2 := ""
                                    cQry2 += "SELECT TOP 1 * "
                                    cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                                    cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                    //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
								         	cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                                    cQry2 += "ORDER BY PSQ.FIM "
                                    TCQuery cQry2 ALIAS "QOP" NEW
                                    If Empty(QOP->STATUS)
                                       DbSelectArea("QOP")
                                       DbCloseArea()
                                       cQry2 := ""
                                       cQry2 += "SELECT TOP 1 * "
                                       cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                       cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                                       cQry2 += "ORDER BY PSQ.FIM "
                                       TCQuery cQry2 ALIAS "QOP" NEW
                                    Endif
                                    DbSelectArea("QOP")
                                    cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                                    DbSelectArea("QOP")
                                    DbCloseArea()

                                    cQry2 := ""
                                    cQry2 += "SELECT TOP 1 * "
                                    cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                                    cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                    cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                                    cQry2 += "ORDER BY PSQ.FIM "
                                    TCQuery cQry2 ALIAS "QOP" NEW
                                    If Empty(QOP->STATUS)
                                       DbSelectArea("QOP")
                                       DbCloseArea()
                                       cQry2 := ""
                                       cQry2 += "SELECT TOP 1 * "
                                       cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                       cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                                       cQry2 += "ORDER BY PSQ.FIM "
                                       TCQuery cQry2 ALIAS "QOP" NEW
                                    Endif
                                    DbSelectArea("QOP")
                                    cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                                    DbSelectArea("QOP")
                                    DbCloseArea()
                                 Else
                                    cPesado := ' '
                                    cEnvase := ' '
                                 Endif
//   Jose 15/04/2025
                                 cQry2 := "SELECT SB2.B2_LOCALIZ "+;
						                        "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "+;
					                          "WHERE (SB2.B2_FILIAL  = '010101') AND (SB2.D_E_L_E_T_ = '') "+;      // "+xFilial("SC2")+"'
				        		                 "  AND (SB2.B2_LOCAL   = 'A3') AND (SB2.B2_COD = '"+TCQ->ZZC_PRODUT+"') "+;
						                       "GROUP BY SB2.B2_LOCALIZ"
						               If Select( "SB20" ) > 0
                                    DbSelectArea( "SB20" )
                                    DbCloseArea()
                                 Endif
                                 TCQuery cQry2 ALIAS "SB20" NEW
                                 DbSelectArea("SB20")
                                 cLocaliz := ""
                                 While !Eof()
                                       cLocaliz := SB20->B2_LOCALIZ
                                       DbSelectArea("SB20")
                                       DbSkip()
                                 Enddo
                                 DbSelectArea("SB0")
                                 DbCloseArea()
/* JOSE 14/04/2025
                                 aAdd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, aNumCar[nA][5], aNumCar[nA][1], cPesado, cEnvase })
                                 aNumCar[nA][6] += 1
                              Else
                                 If mv_par03 = 1 .or. mv_par03 == 3
                                    aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, aNumCar[nA][5], aNumCar[nA][1], ' ', ' '})
                                    aNumCar[nA][6] += 1
                                 Else
                                    aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]+x[7]) == Alltrim(TCQ->ZZC_PRODUT+TCQ->ZZC_CARGA)})][2] += TCQ->ZZC_QUANTI
                                 Endif
*/ 
//   JOSE 14/04/2025
//                               aAdd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, '010101'+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "A3"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, aNumCar[nA][5], aNumCar[nA][1], cPesado, cEnvase })
                                 aAdd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "P", cNumPed, aNumCar[nA][5], aNumCar[nA][1], cPesado, cEnvase })
//                               aAdd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, '010108'+TCQ->ZZC_PRODUT+Posicione("SC6", 1, xFilial("SC6")+cNumPed+TCQ->ZZC_PRODUT, "C6_LOCAL"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, aNumCar[nA][5], aNumCar[nA][1], cPesado, cEnvase })
                                 aNumCar[nA][6] += 1
                              Else
                                 If mv_par03 = 1 .or. mv_par03 == 3
//                                  aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, '010101'+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "A3"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, aNumCar[nA][5], aNumCar[nA][1], ' ', ' '})
                                    aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "R", cNumPed, aNumCar[nA][5], aNumCar[nA][1], ' ', ' '})
//                                  aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, '010108'+TCQ->ZZC_PRODUT+Posicione("SC6", 1, xFilial("SC6")+cNumPed+TCQ->ZZC_PRODUT, "C6_LOCAL"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, aNumCar[nA][5], aNumCar[nA][1], ' ', ' '})
                                    aNumCar[nA][6] += 1
                                 Else
                                    aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]+x[7]) == Alltrim(TCQ->ZZC_PRODUT+TCQ->ZZC_CARGA)})][2] += TCQ->ZZC_QUANTI
                                 Endif
//  ATÉ AQUI JOSE 14/04/2005
                              Endif
                           Endif
                           DbSelectArea("TCQ")
                           DbSkip()
                     Enddo
                 Next
                 aAuxMat := {}
                 For nY := 1 To Len(aNumCar)
                     If aNumCar[nY][6] > 0
                        aAdd(aAuxMat, {aNumCar[nY][1], aNumCar[nY][2], aNumCar[nY][3], aNumCar[nY][4], aNumCar[nY][5], aNumCar[nY][6] })
                     Endif
                 Next
                 aNumCar := aAuxMat
              Else
                 While !Eof()
                       If mv_par03 == 1 .or. mv_par03 == 3
                          cNumPed := TCQ->ZZC_PEDIDO
                       Else
                          cNumPed := space(06)
                       Endif
                       If aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)}) == 0
                          nQtdPro := 0
                          cNumOP:= "'"
                          cNumLT:= "'"
						cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
						"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
						"WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
						"AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+TCQ->ZZC_PRODUT+"') "+;
						"GROUP BY SC2.C2_OP, SC2.C2_LOTE"
						  
                          TCQuery cQry2 ALIAS "QOP" NEW
                          DbSelectArea("QOP")
                          While !Eof()
                                nQtdPro += QOP->QUANT
                                cNumOP  += QOP->ORDEM+"', '"
                                cNumLT  += QOP->LOTE+"', '"
                                DbSelectArea("QOP")
                                DbSkip()
                          Enddo
                          DbSelectArea("QOP")
                          DbCloseArea()

                          If !cNumLT == "'"
                             cQry2 := ""
                             cQry2 += "SELECT TOP 1 * "
                             cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                             cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                             //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
                             cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                             cQry2 += "ORDER BY PSQ.FIM "
                             TCQuery cQry2 ALIAS "QOP" NEW
                             If Empty(QOP->STATUS)
                                DbSelectArea("QOP")
                                DbCloseArea()
                                cQry2 := ""
                                cQry2 += "SELECT TOP 1 * "
                                cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
                                cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                                cQry2 += "ORDER BY PSQ.FIM "
                                TCQuery cQry2 ALIAS "QOP" NEW
                             Endif
                             DbSelectArea("QOP")
                             cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                             DbSelectArea("QOP")
                             DbCloseArea()

                             cQry2 := ""
                             cQry2 += "SELECT TOP 1 * "
                             cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                             cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                             cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                             cQry2 += "ORDER BY PSQ.FIM "
                             TCQuery cQry2 ALIAS "QOP" NEW
                             If Empty(QOP->STATUS)
                                DbSelectArea("QOP")
                                DbCloseArea()
                                cQry2 := ""
                                cQry2 += "SELECT TOP 1 * "
                                cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                                cQry2 += "ORDER BY PSQ.FIM "
                                TCQuery cQry2 ALIAS "QOP" NEW
                             Endif
                             DbSelectArea("QOP")
                             cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                             DbSelectArea("QOP")
                             DbCloseArea()
                          Else
                             cPesado := ' '
                             cEnvase := ' '
                          Endif
//   Jose 15/04/2025

                         cQry2 := "SELECT SB2.B2_LOCALIZ "+;
						                "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "+;
					                   "WHERE (SB2.B2_FILIAL  = '010101') AND (SB2.D_E_L_E_T_ = '') "+;      // "+xFilial("SC2")+"'
				        		          "  AND (SB2.B2_LOCAL   = 'A3') AND (SB2.B2_COD = '"+TCQ->ZZC_PRODUT+"') "+;
						                "GROUP BY SB2.B2_LOCALIZ"
						       If Select( "SB2" ) > 0
                            DbSelectArea( "SB2" )
                            DbCloseArea()
                          Endif						  
                          TCQuery cQry2 ALIAS "SB2" NEW
                          DbSelectArea("SB2")
                          cLocaliz := ""
                          While !Eof()
                                cLocaliz := SB2->B2_LOCALIZ
                                DbSelectArea("SB2")
                                DbSkip()
                          Enddo
                          DbSelectArea("SB2")
                          DbCloseArea()

/*   jOSE 14/04/2025               
                          aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU })
                       Else
                          If mv_par03 = 1 .or. mv_par03 == 3
                             aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, ' ', ' ', TCQ->B1_PESBRU })
                          Else
                             aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)})][2] += TCQ->ZZC_QUANTI
                          Endif
*/
// jOSE 14/04/2025
//                        aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "A3"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU })
                          aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU })
//                        aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, '010108'+TCQ->ZZC_PRODUT+Posicione("SC6", 1, xFilial("SC6")+cNumPed+TCQ->ZZC_PRODUT, "C6_LOCAL"), "B2_LOCALIZ"), nQtdPro, "P", cNumPed, cPesado, cEnvase, TCQ->B1_PESBRU })

                       Else
                          If mv_par03 = 1 .or. mv_par03 == 3
//                           aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "A3"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, ' ', ' ', TCQ->B1_PESBRU })
                             aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "R", cNumPed, ' ', ' ', TCQ->B1_PESBRU })
//                           aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, '010108'+TCQ->ZZC_PRODUT+Posicione("SC6", 1, xFilial("SC6")+cNumPed+TCQ->ZZC_PRODUT, "C6_LOCAL"), "B2_LOCALIZ"), nQtdPro, "R", cNumPed, ' ', ' ', TCQ->B1_PESBRU })
                          Else
                             aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)})][2] += TCQ->ZZC_QUANTI
                          Endif

// aTÉ AQUI 14/04/2025

                       Endif
                       DbSelectArea("TCQ")
                       DbSkip()
                 Enddo
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()

              ProcRegua(Len(aMatImp))
              If Len(aMatImp) > 0
                 oPrn:= TMSPrinter():New( "Relação de Faltas" )
                 oPrn:SetPortrait()      //SetLandscape()
                 AVPRINT oPrn NAME "Relação de Faltas"
                         AVPAGE
                           If mv_par01 == 1
                              cDatPre := ''
                              For nA := 1 To Len(aNumCar)
                                  If nA == 1
                                     nLin := 160
                                     FATR12_2(3)     //Cabeçalho
                                     If mv_par03 ==3
                              	  	 	nA:= Len(aNumCar)
                              	  	 Endif
                                  ElseIf nLin >= (nLinMax - 100)
                                         FATR12_2(4) //Rodape 
                                         AVNEWPAGE
                                         nLin := 160
                                         FATR12_2(3) //Cabeçalho
                                  Endif
                                  If Empty(cDatPre)
                                     oPrn:Say(nLin, nCol     , 'PREVISÃO: '+SubStr(aNumCar[nA][2], 7, 2)+'/'+SubStr(aNumCar[nA][2], 5, 2)+'/'+SubStr(aNumCar[nA][2], 1, 4), oFont8, , , , ) //Quebra por Previsão
                                     nLin += 60
                                     cDatPre := aNumCar[nA][2]
                                  Else
                                     If cDatPre <> aNumCar[nA][2]
                                        oPrn:Say(nLin, nCol     , 'PREVISÃO: '+SubStr(aNumCar[nA][2], 7, 2)+'/'+SubStr(aNumCar[nA][2], 5, 2)+'/'+SubStr(aNumCar[nA][2], 1, 4), oFont8, , , , ) //Quebra por Previsão
                                        nLin += 60
                                        cDatPre := aNumCar[nA][2]
                                     Endif
                                  Endif
                                  If aNumCar[nA][6] <= 0
                                     oPrn:Say(nLin, nCol     , 'BORDERO : '                                                                                               , oFont7, , , , ) //Quebra por Bordero+Região
                                     oPrn:Say(nLin, nCol+240 ,              aNumCar[nA][5]                                                                                , oFont8, , , , ) //Quebra por Bordero+Região
                                     oPrn:Say(nLin, nCol+410 ,                             '  -  REGIÃO: '+Alltrim(aNumCar[nA][3])+'-'+aNumCar[nA][4]                     , oFont7, , , , ) //Quebra por Bordero+Região
                                     nLin += 50
                                     oPrn:Say(nLin, nCol+400 , 'NÃO CONSTA NENHUM PRODUTO FALTANDO PARA ESSE DESPACHO.'                                                   , oFont7, , , , ) 
                                     nLin += 50
                                     oPrn:Line(nLin, nCol, nlin, nColMax)
                                     nLin += 60
                                  Else
                                     If mv_par03 <> 3
                                     	oPrn:Say(nLin, nCol     , 'BORDERO : '                                                                                               , oFont7, , , , ) //Quebra por Bordero+Região
                                     	oPrn:Say(nLin, nCol+240 ,              aNumCar[nA][5]                                                                                , oFont8, , , , ) //Quebra por Bordero+Região
                                     	oPrn:Say(nLin, nCol+410 ,                             '  -  REGIÃO: '+Alltrim(aNumCar[nA][3])+'-'+aNumCar[nA][4]                     , oFont7, , , , ) //Quebra por Bordero+Região
                                     Endif
                                     nLin += 50
                                     If mv_par03 ==3 .and. mv_par07 ==1 // chamado 018613 gustavo diniz, ordenar por produto qdo se tirar o relatorio de faltas analitico por produto, ordenava primeiro por bordero, depois por produto
                                         ASORT(aMatImp,,, { |x, y| x[1] < y[1]} )
                                     Endif
                                     For nB := 1 To Len(aMatImp)
                                         //If mv_par03 ==3 .and. mv_par07 ==1 // chamado 018613 gustavo diniz, ordenar por produto qdo se tirar o relatorio de faltas analitico por produto, ordenava primeiro por bordero, depois por produto
                                          
                                           //  ASORT(aMatImp,,, { |x, y| x[1] < y[1]} )
                                         //Endif
                                         If nLin >= (nLinMax - 100)
                                            AVNEWPAGE
                                            nLin := 160
                                            FATR12_2(3) //Cabeçalho
                                         Endif
                                         
                                         If aNumCar[nA][5] == aMatImp[nB][7] .and. mv_par03 <> 3
                                         	oPrn:Say(nLin, nCol     , TransForm(aMatImp[nB][2], "@E 99999")                                                                         , oFont7, , , , ) //Quantidade de Falta
                                         	oPrn:Say(nLin, nCol+0150, IIF(EHESTOQUE(aMatImp[nB][1]), "*", " "), oFont7, , , , ) //Marca de Item de Estoque
                                         	oPrn:Say(nLin, nCol+0180, TransForm(aMatImp[nB][1], "@R XX 99.99.999-99")                                                               , oFont7, , , , ) //Código do Produto
                                         	oPrn:Say(nLin, nCol+0580, SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nB][1], "B1_DESC")), 1, 20)                         , oFont7, , , , ) //Descrição do Produto  jose 15/04/2025  nLin, nCol+0600
                                         	oPrn:Say(nLin, nCol+1300, aMatImp[nB][6]                                                                                                , oFont7, , , , ) // jose 15/04/2025  nCol+1400
                                         	oPrn:Say(nLin, nCol+1500, SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nB][1], 11, 2), "Z5_DESCR"), 1, 11)                  , oFont7, , , , ) //Descrição da Embalagem  jose 15/04/2025  nCol+1600
                                         	oPrn:Say(nLin, nCol+1800, SubStr(Iif(Empty(aMatImp[nB][3]), ' ', SubStr(Alltrim(aMatImp[nB][3]), 1, 15)), 1, 14)                        , oFont7, , , , ) //Localização    jose 15/04/2025  nCol+1900  1, 9)  
                                         	oPrn:Say(nLin, nCol+2150, aMatImp[nB][9]+Iif((mv_par03 == 1 .or. mv_par03 == 3) .and. aMatImp[nB][5] == 'R', '', TransForm(aMatImp[nB][4], "@E 99999"))+aMatImp[nB][10], oFont7, , , , ) //Qtde. Produção  
                                         	nLin += 50
                                         Elseif mv_par03 == 3
                                         	oPrn:Say(nLin, nCol     , TransForm(aMatImp[nB][2], "@E 99999")                                                                         , oFont7, , , , ) //Quantidade de Falta
                                         	oPrn:Say(nLin, nCol+0150, IIF(EHESTOQUE(aMatImp[nB][1]), "*", " "), oFont7, , , , ) //Marca de Item de Estoque
                                         	oPrn:Say(nLin, nCol+0180, TransForm(aMatImp[nB][1], "@R XX 99.99.999-99")                                                               , oFont7, , , , ) //Código do Produto
                                         	oPrn:Say(nLin, nCol+0580, SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nB][1], "B1_DESC")), 1, 20)                         , oFont7, , , , ) //Descrição do Produto jose 15/04/2025  nLin, nCol+0600
                                         	oPrn:Say(nLin, nCol+1300, aMatImp[nB][6]                                                                                                , oFont7, , , , )  // jose 15/04/2025  nCol+1400
                                         	oPrn:Say(nLin, nCol+1500, SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nB][1], 11, 2), "Z5_DESCR"), 1, 11)                  , oFont7, , , , ) //Descrição da Embalagem jose 15/04/2025  nCol+1600
                                         	oPrn:Say(nLin, nCol+1800, SubStr(Iif(Empty(aMatImp[nB][3]), ' ', SubStr(Alltrim(aMatImp[nB][3]), 1, 15)), 1, 14)                         , oFont7, , , , ) //Localização  jose 15/04/2025  nCol+1900  1, 9)  
                                         	oPrn:Say(nLin, nCol+2150, aMatImp[nB][9]+Iif((mv_par03 == 1 .or. mv_par03 == 3) .and. aMatImp[nB][5] == 'R', '', TransForm(aMatImp[nB][4], "@E 99999"))+aMatImp[nB][10], oFont7, , , , ) //Qtde. Produção
                                         	nLin += 50
                                         Endif
                                     Next
                                     oPrn:Line(nLin, nCol, nlin, nColMax)
                                     nLin += 60
                                  Endif
                              Next
                           Else
                              For nY := 1 To Len(aMatImp)
                                  If nY == 1
                                     nLin := 160
                                     FATR12_2(3)     //Cabeçalho
                                  ElseIf nLin >= (nLinMax - 100)
                                         FATR12_2(4) //Rodape 
                                         AVNEWPAGE
                                         nLin := 160
                                         FATR12_2(3) //Cabeçalho
                                  Endif
                                  oPrn:Say(nLin, nCol     , TransForm(aMatImp[nY][2], "@E 99999")                                                                         , oFont7, , , , ) //Quantidade de Falta
                                  oPrn:Say(nLin, nCol+0150, iif(EHESTOQUE(aMatImp[nY][1]), "*", " "), oFont7, , , , ) //Marca de Item de Estoque
                                  oPrn:Say(nLin, nCol+0180, TransForm(aMatImp[nY][1], "@R XX 99.99.999-99")                                                               , oFont7, , , , ) //Código do Produto
                                  oPrn:Say(nLin, nCol+0580, SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][1], "B1_DESC")), 1, 20)                         , oFont7, , , , ) //Descrição do Produto // jose 16/04/2025 (nLin, nCol+0600 ,1,30
                                  oPrn:Say(nLin, nCol+1300, aMatImp[nY][6]                                                                                                , oFont7, , , , ) // jose 16/04/2025 (nLin, nCol+1400
                                  oPrn:Say(nLin, nCol+1500, SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nY][1], 11, 2), "Z5_DESCR"), 1, 11)                  , oFont7, , , , ) //Descrição da Embalagem // jose 16/04/2025 (nLin, nCol+1600
                                  oPrn:Say(nLin, nCol+1800, SubStr(Iif(Empty(aMatImp[nY][3]), ' ', SubStr(Alltrim(aMatImp[nY][3]), 1, 15)), 1, 14)                         , oFont7, , , , ) //Localização // jose 16/04/2025 (nLin, nCol+1900 1,9
                                  nPesoFalta := ((aMatImp[nY][9] * aMatImp[nY][2]) + nPesoFalta)
                                //oPrn:Say(nLin, nCol+2050, Transform(Posicione("SC5", 1, xFilial("SC5")+aMatImp[nY][6], "C5_VOLUME1"), "@E 9999")                        , oFont7, , , , ) //Volume
                                  oPrn:Say(nLin, nCol+2150, aMatImp[nY][7]+Iif((mv_par03 == 1 .or. mv_par03 == 3) .and. aMatImp[nY][5] == 'R', '', TransForm(aMatImp[nY][4], "@E 99999"))+aMatImp[nY][8], oFont7, , , , ) //Qtde. Produção
                                  nLin += 50
                              Next
                              FATR12_2(4) //Rodape 
                           Endif
                         AVENDPAGE
                 AVENDPRINT
              Else
                 MsgAlert("Não foi encontrado informação para esse relatório", "Atenção")
              Endif
       ElseIf cOpcRel == 3 //   Pedidos
              If !Empty(cNumBor)
                 DbSelectArea("TCQ")
                 DbGoTop()
                 While !Eof()
                       If aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)}) == 0
                          nQtdPro := 0
                          cNumOP:= "'"
                          cNumLT:= "'"
							cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
							"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
							"WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
							"AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+TCQ->ZZC_PRODUT+"') "+;
							"GROUP BY SC2.C2_OP, SC2.C2_LOTE"

                          TCQuery cQry2 ALIAS "QOP" NEW
                          DbSelectArea("QOP")
                          While !Eof()
                                nQtdPro += QOP->QUANT
                                cNumOP  += QOP->ORDEM+"', '"
                                cNumLT  += QOP->LOTE+"', '"
                                DbSelectArea("QOP")
                                DbSkip()
                          Enddo
                          DbSelectArea("QOP")
                          DbCloseArea()

                          If !cNumLT == "'"
                             cQry2 := ""
                             cQry2 += "SELECT TOP 1 * "
                             cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                             cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                             cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                             //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
                             cQry2 += "ORDER BY PSQ.FIM "
                             TCQuery cQry2 ALIAS "QOP" NEW
                             If Empty(QOP->STATUS)
                                DbSelectArea("QOP")
                                DbCloseArea()
                                cQry2 := ""
                                cQry2 += "SELECT TOP 1 * "
                                cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
								cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                                //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
                                cQry2 += "ORDER BY PSQ.FIM "
                                TCQuery cQry2 ALIAS "QOP" NEW
                             Endif
                             DbSelectArea("QOP")
                             cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                             DbSelectArea("QOP")
                             DbCloseArea()

                             cQry2 := ""
                             cQry2 += "SELECT TOP 1 * "
                             cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                             cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                             cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                             cQry2 += "ORDER BY PSQ.FIM "
                             TCQuery cQry2 ALIAS "QOP" NEW
                             If Empty(QOP->STATUS)
                                DbSelectArea("QOP")
                                DbCloseArea()
                                cQry2 := ""
                                cQry2 += "SELECT TOP 1 * "
                                cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                                cQry2 += "ORDER BY PSQ.FIM "
                                TCQuery cQry2 ALIAS "QOP" NEW
                             Endif
                             DbSelectArea("QOP")
                             cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                             DbSelectArea("QOP")
                             DbCloseArea()
                          Else
                             cPesado := ' '
                             cEnvase := ' '
                          Endif
//   Jose 15/04/2025
                          cQry2 := "SELECT SB2.B2_LOCALIZ "+;
						                 "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "+;
					                    "WHERE (SB2.B2_FILIAL  = '010101') AND (SB2.D_E_L_E_T_ = '') "+;      // "+xFilial("SC2")+"'
				        		           "  AND (SB2.B2_LOCAL   = 'A3') AND (SB2.B2_COD = '"+TCQ->ZZC_PRODUT+"') "+;
						                 "GROUP BY SB2.B2_LOCALIZ"
						        If Select( "SB20" ) > 0
                             DbSelectArea( "SB20" )
                             DbCloseArea()
                          Endif
                          TCQuery cQry2 ALIAS "SB20" NEW
                          DbSelectArea("SB20")
                          cLocaliz := ""
                          While !Eof()
                                cLocaliz := SB20->B2_LOCALIZ
                                DbSelectArea("SB20")
                                DbSkip()
                          Enddo
                          DbSelectArea("SB0")
                          DbCloseArea()
/* JOSE 14/04/2025

/*  JOSE 14/04/2025
                          aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "P", '', cPesado, cEnvase})
                       Else
                          aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)})][2] += TCQ->ZZC_QUANTI
                       Endif
  jOSE 14/04/2025*/

//   jOSE 14/04/205
//                        aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "A3"), "B2_LOCALIZ"), nQtdPro, "P", '', cPesado, cEnvase})
//                        cNumPed := mv_par01
                          aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "P", '', cPesado, cEnvase})
//                        aadd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, '010108'+TCQ->ZZC_PRODUT+Posicione("SC6", 1, xFilial("SC6")+cNumPed+TCQ->ZZC_PRODUT, "C6_LOCAL"), "B2_LOCALIZ"), nQtdPro, "P", '', cPesado, cEnvase})  // Jose 15/04/2025  xFilial("SB2")
                       Else
                          aMatImp[aScan(aMatImp, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZZC_PRODUT)})][2] += TCQ->ZZC_QUANTI
                       Endif
  //   aTÉ AQUII  jOSE 14/04/2025
                       DbSelectArea("TCQ")
                       DbSkip()
                 Enddo
                 DbSelectArea("TCQ")
                 DbCloseArea()
              Endif

              Titulo := 'Pedido '+mv_par01
              oPrn:= TMSPrinter():New( "Relação de Faltas" )
              oPrn:SetPortrait()      //SetLandscape()
              AVPRINT oPrn NAME "Relação de Faltas"
                      AVPAGE
                        nLin := 160
                        FATR12_2(5)     //Cabeçalho

                        //Log do Status do Pedido         
                        DBSELECTAREA("SC5")
                        dbsetorder(1)
                        dbseek(xFilial("SC5")+mv_par01) 
                        IF !FOUND()
							dDatLog := "  /  /  "
							nTotal := 0
						ELSE                         
                          //dDatLog := SubStr((SC5->C5_DTAPR), 7, 2)+'/'+SubStr((SC5->C5_DTAPR), 5, 2)+'/'+SubStr((SC5->C5_DTAPR), 3, 2)
                        	dDatLog := Dtoc(SC5->C5_DTAPR)
	                        //Valor total da Mercadoria do Pedido ou Nota Fiscal
    	                    If EMPTY(SC5->C5_NOTA)
    	                    	nTotal := SC5->C5_VLRDUP
    	                    ELSE
    	                    	dbselectarea("SF2")
     							DbOrderNickName("SF2001")
     							dbseek(xFilial("SF2")+SC5->C5_NUM)
   								nTotal := IIF(FOUND(),SF2->F2_VALFAT,0)
							ENDIF     								
						ENDIF 

                        cTotPed := Iif(Empty(Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_NOTA')), 'V. MERC..: ', 'V. NOTA..: ')+TransForm(nTotal, "@E 9,999,999.99")

                        //Busca informação de itens especificos. AND SC6.C6_LOCAL = SB1.B1_LOCPAD
                        cQry1 := ""
                        cQry1 += "SELECT TOP 1 SC6.R_E_C_N_O_ AS NAOEST "
                        cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
                        cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SC6.C6_FILIAL = SB1.B1_FILIAL) AND (SC6.C6_PRODUTO = SB1.B1_COD) AND (SB1.D_E_L_E_T_ = '') "
//                      cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB1.B1_FILIAL = B2_FILIAL ) AND (SB1.B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) AND (SB1.D_E_L_E_T_ = '') " // Jose 15/04/2025
                        cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB1.B1_FILIAL = B2_FILIAL ) AND (SB1.B1_COD = B2_COD) AND (B2_LOCAL = 'A3') AND (SB1.D_E_L_E_T_ = '') " // Jose 15/04/2025
                        cQry1 += "WHERE (SC6.C6_FILIAL  = '"+xFilial("SB1")+"') "
                        cQry1 += "  AND (SC6.D_E_L_E_T_ = '') "
                        cQry1 += "  AND (SC6.C6_NUM = '"+mv_par01+"') "
                        cQry1 += "  AND (SB2.B2_LOCALIZ = '') "
                        TCQuery cQry1 ALIAS "QNES" NEW
                        DbSelectArea("QNES")
                        cNaoEst := Iif(!EOF() .AND. !BOF(), 'SIM', 'NAO')
                        DbSelectArea("QNES")
                        DbCloseArea()

                        //Busca outras informações do Cabeçalho
                        cPedido := mv_par01
                        cEmissa := DTOC(Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_EMISSAO'))
                        cStatus := Iif(Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_APROVA') == '0' , 'Não Aprovado', Iif(Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_APROVA') == '1', 'Aprovado', 'Bloqueado'))
                        cVolume := Transform(Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_VOLUME1'), "@E 999,999")
                        cPesoBr := Transform(Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_PBRUTO'), "@E 999,999")
                        cPedPro := '  /  /  '
                        cNumNot := Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_NOTA')
                        cCodBor := Posicione("SZG", 2, xFilial("SZG")+'01'+mv_par01, 'ZG_CODIGO')
                        cDatBor := DTOC(Posicione("SZF", 1, xFilial("SZF")+cCodBor, 'ZF_EMISSAO'))
                        cCodDes := Posicione("SZB", 2, xFilial("SZB")+'01'+mv_par01, 'ZB_CODIGO')
                        cDesDes := SubStr(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_DESCR'), 1, 25)
                        cDespac := cCodDes+' - '+cDesDes
                        dDatPre := DTOC(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_PREVDSP'))
                        dDatDes := DTOC(Posicione("SZA", 1, xFilial("SZA")+cCodDes, 'ZA_DTDESPA'))
                        cResdes := Alltrim(Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_REDESP'))+'-'+SubStr(Alltrim(Posicione("SA4", 1, xFilial("SA4")+Posicione("SC5", 1, xFilial("SC5")+mv_par01, 'C5_REDESP'), "A4_NOME")), 1, 25)
                        cDesVia := 'DEPO. SP : '+DTOC(Posicione("ZZ0", 4, xFilial("ZZ0")+mv_par01, 'ZZ0_ENTREG'))+' - '+SubStr(Posicione("SA4", 1, xFilial("SA4")+Posicione("ZZ0", 4, xFilial("ZZ0")+mv_par01, 'ZZ0_REDESP'), 'A4_NOME'), 1, 25)
                        oPrn:Say(nLin, nCol     , 'PEDIDO...: '+cPedido, oFont8, , , , ) //Quebra por Pedido
                        oPrn:Say(nLin, nCol+0515, 'EMISSÃO..: '+cEmissa, oFont7, , , , ) //Emissão do Pedido
                        oPrn:Say(nLin, nCol+1120, 'DT. APRO.: '+dDatLog, oFont7, , , , ) //Data da Aprovação
                        oPrn:Say(nLin, nCol+1800, 'STATUS...: '+cStatus, oFont7, , , , ) //Status
                        nLin += 50
                        oPrn:Say(nLin, nCol     , 'VOLUME...: '+cVolume, oFont7, , , , ) //Volume
                        oPrn:Say(nLin, nCol+0515, 'PESO BRU.: '+cPesoBr, oFont7, , , , ) //Peso Bruto
                        oPrn:Say(nLin, nCol+1120,               cTotPed, oFont7, , , , ) //Valor do Pedido/Nota
                        oPrn:Say(nLin, nCol+1800, 'P. PROGR.: '+cPedPro, oFont7, , , , ) //Pedido Programado
                        nLin += 50
                        oPrn:Say(nLin, nCol     , 'N.FISCAL.: '+cNumNot, oFont8, , , , ) //Numero da NF
                        oPrn:Say(nLin, nCol+0515, 'BOR. PED.: '+cCodBor, oFont7, , , , ) //Numero do Bordero de Pedidos
                        oPrn:Say(nLin, nCol+1120, 'DT. BORD.: '+cDatBor, oFont7, , , , ) //Data do Bordero de Pedidos
                        oPrn:Say(nLin, nCol+1800, 'ESPECIF..: '+cNaoEst, oFont7, , , , ) //Especificos
                        nLin += 50
                        oPrn:Say(nLin, nCol     , 'BOR. DES.: '+cDespac, oFont7, , , , ) //Bordero de Despacho
                        oPrn:Say(nLin, nCol+1120, 'PREVISÃO.: '+dDatPre, oFont8, , , , ) //Previsão de Despacho
                        oPrn:Say(nLin, nCol+1800, 'DT. DESP.: '+dDatDes, oFont7, , , , ) //Data do Despacho
                        nLin += 50
                        oPrn:Say(nLin, nCol     , 'REDESP.  : '+cResDes, oFont7, , , , ) //Redespacho
                        oPrn:Say(nLin, nCol+1120,               cDesVia, oFont7, , , , ) //Viamix
                        nLin += 50
                        oPrn:Line(nLin, nCol, nlin, nColMax)
                        nLin += 60
                        If cStaBor $ 'D.E. '
                           oPrn:Say(nLin, 600, cMsgBor, oFont3, , , , )
                           lImpInt := .t.
                        ElseIf cStaBor $ 'P'
                               oPrn:Say(nLin, 600, cMsgBor, oFont3, , , , )
                               lImpInt := .t.
                        ElseIf cStaBor $ 'T.R'
                               lImpInt := .t.
                        Else
                           lImpInt := .t.
                        Endif
                        nLin += 60
                        If lImpInt
                           ProcRegua(Len(aMatImp))
                           For nY := 1 To Len(aMatImp)
                               If nLin >= (nLinMax - 100)
                                  //FATR12_2(6, aMatImp) //Rodape  //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                                  FATR12_2(6)
                                  AVNEWPAGE
                                  nLin := 160
                                  FATR12_2(5) //Cabeçalho
                               Endif
                               oPrn:Say(nLin, nCol     , TransForm(aMatImp[nY][2], "@E 99999")                                                                         , oFont7, , , , ) //Quantidade de Falta
                               oPrn:Say(nLin, nCol+0150, iif(EHESTOQUE(aMatImp[nY][1]), "*", " "), oFont7, , , , ) //Marca de Item de Estoque
                               oPrn:Say(nLin, nCol+0180, TransForm(aMatImp[nY][1], "@R XX 99.99.999-99")                                                               , oFont7, , , , ) //Código do Produto
                               oPrn:Say(nLin, nCol+0580, SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][1], "B1_DESC")), 1, 20)                         , oFont7, , , , ) //Descrição do Produto  // Jose 16/04/2025  (nLin, nCol+0600 ,1,30
                               oPrn:Say(nLin, nCol+1500, SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nY][1], 11, 2), "Z5_DESCR"), 1, 11)                  , oFont7, , , , ) //Descrição da Embalagem // Jose 16/04/2025 (nLin, nCol+1600
                               oPrn:Say(nLin, nCol+1800, SubStr(Iif(Empty(aMatImp[nY][3]), ' ', SubStr(Alltrim(aMatImp[nY][3]), 1, 15)), 1, 9)                         , oFont7, , , , ) //Localização // Jose 16/04/2025  (nLin, nCol+1900  ,1,9
                               oPrn:Say(nLin, nCol+2150, aMatImp[nY][7]+TransForm(aMatImp[nY][4], "@E 99999")+aMatImp[nY][8]                                           , oFont7, , , , ) //Qtde. Produção
                               nLin += 50
                           Next
                        Endif
                        //FATR12_2(6, aMatImp) //Rodape   //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                        FATR12_2(6)
                      AVENDPAGE
              AVENDPRINT
       ElseIf cOpcRel == 4 //  Clientes
              Titulo := 'Cliente '+mv_par01
              DbSelectArea("TCQ")
              DbGoTop()
              While !Eof()
                    nQtdPro := 0
                    cNumOP:= "'"
                    cNumLT:= "'"
					cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
					"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
					"WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
					"AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+TCQ->ZZC_PRODUT+"') "+;
					"GROUP BY SC2.C2_OP, SC2.C2_LOTE"
					
                    TCQuery cQry2 ALIAS "QOP" NEW
                    DbSelectArea("QOP")
                    While !Eof()
                          nQtdPro += QOP->QUANT
                          cNumOP  += QOP->ORDEM+"', '"
                          cNumLT  += QOP->LOTE+"', '"
                          DbSelectArea("QOP")
                          DbSkip()
                    Enddo
                    DbSelectArea("QOP")
                    DbCloseArea()

                    If !cNumLT == "'"
                       cQry2 := ""
                       cQry2 += "SELECT TOP 1 * "
                       cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                       cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                       //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
                       cQry2 += "ORDER BY PSQ.FIM "
                       TCQuery cQry2 ALIAS "QOP" NEW
                       If Empty(QOP->STATUS)
                          DbSelectArea("QOP")
                          DbCloseArea()
                          cQry2 := ""
                          cQry2 += "SELECT TOP 1 * "
                          cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                          cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                          cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TCQ->ZZC_PRODUT, 11, 02), "Z5_UMEMB"))='K','99','00')+"' "
                          //cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(TCQ->ZZC_PRODUT), 1, 10)+"00' "
                          cQry2 += "ORDER BY PSQ.FIM "
                          TCQuery cQry2 ALIAS "QOP" NEW
                       Endif
                       DbSelectArea("QOP")
                       cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                       DbSelectArea("QOP")
                       DbCloseArea()

                       cQry2 := ""
                       cQry2 += "SELECT TOP 1 * "
                       cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                       cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                       cQry2 += "ORDER BY PSQ.FIM "
                       TCQuery cQry2 ALIAS "QOP" NEW
                       If Empty(QOP->STATUS)
                          DbSelectArea("QOP")
                          DbCloseArea()
                          cQry2 := ""
                          cQry2 += "SELECT TOP 1 * "
                          cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                          cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                          cQry2 += "  AND PSQ.PRODUTO = '"+TCQ->ZZC_PRODUT+"' "
                          cQry2 += "ORDER BY PSQ.FIM "
                          TCQuery cQry2 ALIAS "QOP" NEW
                       Endif
                       DbSelectArea("QOP")
                       cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                       DbSelectArea("QOP")
                       DbCloseArea()
                    Else
                       cPesado := ' '
                       cEnvase := ' '
                    Endif
//   Jose 15/04/2025
                    cQry2 := "SELECT SB2.B2_LOCALIZ "+;
						           "  FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "+;
					              " WHERE (SB2.B2_FILIAL  = '010101') AND (SB2.D_E_L_E_T_ = '') "+;      // "+xFilial("SC2")+"'
				        		     "   AND (SB2.B2_LOCAL   = 'A3') AND (SB2.B2_COD = '"+TCQ->ZZC_PRODUT+"') "+;
						           "GROUP BY SB2.B2_LOCALIZ"
						           If Select( "SB20" ) > 0
                                DbSelectArea( "SB20" )
                                DbCloseArea()
                             Endif
                             TCQuery cQry2 ALIAS "SB20" NEW
                             DbSelectArea("SB20")
                             cLocaliz := ""
                             While !Eof()
                                   cLocaliz := SB20->B2_LOCALIZ
                                   DbSelectArea("SB20")
                                   DbSkip()
                             Enddo
                             DbSelectArea("SB0")
                             DbCloseArea()
/* JOSE 14/04/2025

/*    jOSE 14/04/205                   
                    aAdd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), nQtdPro, "P", TCQ->ZZC_PEDIDO, cPesado, cEnvase })
   jOSE 14/04/2025  */
//    JOSE 14/04/2025
//                  aAdd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, Posicione("SB2", 1, xFilial("SB2")+TCQ->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+TCQ->ZZC_PRODUT, "A3"), "B2_LOCALIZ"), nQtdPro, "P", TCQ->ZZC_PEDIDO, cPesado, cEnvase })
                    aAdd(aMatImp, {TCQ->ZZC_PRODUT, TCQ->ZZC_QUANTI, cLocaliz, nQtdPro, "P", TCQ->ZZC_PEDIDO, cPesado, cEnvase })
//   ATÉ AQUI JOSE  14/04/2025
                    DbSelectArea("TCQ")
                    DbSkip()
              Enddo
              DbSelectArea("TCQ")
              DbCloseArea()

              ProcRegua(Len(aNumPed))
              If Len(aNumPed) > 0
                 oPrn:= TMSPrinter():New( "Relação de Faltas" )
                 oPrn:SetPortrait()      //SetLandscape()
                 AVPRINT oPrn NAME "Relação de Faltas"
                         AVPAGE
                           For nA := 1 To Len(aNumPed)
                               If nA == 1
                                  nLin := 160
                                  FATR12_2(7)     //Cabeçalho
                               ElseIf nLin >= (nLinMax - 100)
                                      AVNEWPAGE
                                      nLin := 160
                                      FATR12_2(7) //Cabeçalho
                               Endif
                               //         1         2         3         4         5         6         7         8         9  
                               //12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
                               //PEDIDO...: 999999   EMISSÃO..: 99/99/99    DT. APRO.: 99/99/99       STATUS...: XXXXXXXXXXXX
                               //N.FISCAL.: 999999   BOR. PED.: 999999      DT. BORD.: 99/99/99       ESPECIF..: XXX
                               //BOR. DES.: 999999 - XXXXXXXXXXXXXXXXXXXXXX PREVISÃO.: 99/99/99       DT. DESP.: 99/99/99
                               //oPrn:Say(nLin, nCol     , '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890', oFont8, , , , ) //Quebra por Pedido
                               //nLin += 50
                               oPrn:Say(nLin, nCol     , 'PEDIDO...: '+aNumPed[nA][01], oFont8, , , , ) //Quebra por Pedido
                               oPrn:Say(nLin, nCol+0515, 'EMISSÃO..: '+aNumPed[nA][06], oFont7, , , , ) //Emissão do Pedido
                               oPrn:Say(nLin, nCol+1120, 'DT. APRO.: '+aNumPed[nA][10], oFont7, , , , ) //Data da Aprovação
                               oPrn:Say(nLin, nCol+1800, 'STATUS...: '+aNumPed[nA][04], oFont7, , , , ) //Status
                               nLin += 50
                               oPrn:Say(nLin, nCol     , 'VOLUME...: '+aNumPed[nA][13], oFont7, , , , ) //Volume
                               oPrn:Say(nLin, nCol+0515, 'PESO BRU.: '+aNumPed[nA][14], oFont7, , , , ) //Peso Bruto
                               oPrn:Say(nLin, nCol+1120,               aNumPed[nA][16], oFont7, , , , ) //Valor do Pedido/Nota
                               oPrn:Say(nLin, nCol+1800, 'P. PROGR.: '+aNumPed[nA][15], oFont7, , , , ) //Pedido Programado
                               nLin += 50
                               oPrn:Say(nLin, nCol     , 'N.FISCAL.: '+aNumPed[nA][05], oFont8, , , , ) //Numero da NF
                               oPrn:Say(nLin, nCol+0515, 'BOR. PED.: '+aNumPed[nA][07], oFont7, , , , ) //Numero do Bordero de Pedidos
                               oPrn:Say(nLin, nCol+1120, 'DT. BORD.: '+aNumPed[nA][08], oFont7, , , , ) //Data do Bordero de Pedidos
                               oPrn:Say(nLin, nCol+1800, 'ESPECIF..: '+aNumPed[nA][18], oFont7, , , , ) //Especificos
                               nLin += 50
                               oPrn:Say(nLin, nCol     , 'BOR. DES.: '+aNumPed[nA][09], oFont7, , , , ) //Bordero de Despacho
                               oPrn:Say(nLin, nCol+1120, 'PREVISÃO.: '+aNumPed[nA][11], oFont8, , , , ) //Previsão de Despacho
                               oPrn:Say(nLin, nCol+1800, 'DT. DESP.: '+aNumPed[nA][12], oFont7, , , , ) //Data do Despacho

                               nLin += 50
                               oPrn:Say(nLin, nCol     , 'REDESP.  : '+aNumPed[nA][17], oFont7, , , , ) //Redespacho
                               oPrn:Say(nLin, nCol+1120, aNumPed[nA][19], oFont7, , , , ) //Viamix
                               nLin += 50
                               oPrn:Line(nLin, nCol, nlin, nColMax)
                               nLin += 60
                               For nY := 1 To Len(aMatImp)
                                   If nLin >= (nLinMax - 100)
                                      AVNEWPAGE
                                      nLin := 160
                                      FATR12_2(7) //Cabeçalho
                                   Endif
                                   If aMatImp[nY][6] == aNumPed[nA][1]
                                      oPrn:Say(nLin, nCol     , TransForm(aMatImp[nY][2], "@E 99999")                                                                         , oFont7, , , , ) //Quantidade de Falta
                                      oPrn:Say(nLin, nCol+0150, IIF(EHESTOQUE(aMatImp[nY][1]), "*", " "), oFont7, , , , ) //Marca de Item de Estoque
                                      oPrn:Say(nLin, nCol+0180, TransForm(aMatImp[nY][1], "@R XX 99.99.999-99")                                                               , oFont7, , , , ) //Código do Produto
                                      oPrn:Say(nLin, nCol+0580, SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+aMatImp[nY][1], "B1_DESC")), 1, 20)                         , oFont7, , , , ) //Descrição do Produto // Jose 16/04/2025 (nLin, nCol+0600 1,30
                                      oPrn:Say(nLin, nCol+1500, SubStr(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(aMatImp[nY][1], 11, 2), "Z5_DESCR"), 1, 11)                  , oFont7, , , , ) //Descrição da Embalagem // Jose 16/04/2025 (nLin, nCol+1600
                                      oPrn:Say(nLin, nCol+1800, SubStr(Iif(Empty(aMatImp[nY][3]), ' ', SubStr(Alltrim(aMatImp[nY][3]), 1, 15)), 1, 14)                         , oFont7, , , , ) //Localização // Jose 16/04/2025 (nLin, nCol+1900 1,9
                                      oPrn:Say(nLin, nCol+2150, aMatImp[nY][7]+TransForm(aMatImp[nY][4], "@E 99999")+aMatImp[nY][8]                                           , oFont7, , , , ) //Qtde. Produção
                                      nLin += 50
                                   Endif
                               Next
                               oPrn:Line(nLin, nCol, nlin, nColMax)
                               nLin += 60
                           Next
                         AVENDPAGE
                 AVENDPRINT
              Else
                 MsgAlert("Não foi encontrado informação para esse relatório", "Atenção")
              Endif
       Endif
Return

/**********************************************************************************************************/
/*** FATR12_2 - Monta cabeçalho do Relatório                                                            ***/
/**********************************************************************************************************/
Static Function FATR12_2(nOpc)
       Local dPrevis
       Local cRegiao
       Local cFabrica
       If nOpc == 1  //Cabeçalho Bordero de Pedidos
          oPrn:Say(nLin   , nCol      , "Data..:"+DtoC(dDataBase)  , oFont4,,,,)
          oPrn:Say(nLin   , nCol + 550, "PRODUTOS NÃO SEPARADOS - Pedidos: ", oFont2,,,,)
          oPrn:Say(nLin   , nCol +1600, Iif(mv_par01 == 1, '(TODOS)', mv_par02), oFont3,,,,)
          oPrn:Say(nLin   , nCol +1900, "Hora..:"+Time()           , oFont4,,,,)
          nLin += 50
          oPrn:Line(nLin, nCol, nlin, nColMax)
          nLin += 10
          If mv_par03 == 1 .or. mv_par03 == 3
             oPrn:Say(nLin, nCol, "QTDE.        PRODUTO      DESCRIÇÃO                               PEDIDO     EMBAL.         QUADR.             PROD.", oFont4, , , , )
          Else
             oPrn:Say(nLin, nCol, "QTDE.        PRODUTO      DESCRIÇÃO                                          EMBAL.         QUADR.             PROD.", oFont4, , , , )
          Endif    
          nLin += 50
          oPrn:Line(nLin, nCol, nlin, nColMax)
       ElseIf nOpc == 2  //Rodapé do Bordero de Pedidos
              nLin := nLinMax - 100
              nLin += 50
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
          	  oPrn:Say(nLin, nCol + 1400, "Peso das faltas até esta página :"+Transform(nPesoFalta,'@E 999999.99')+" Kg", oFont4,,,,)
       ElseIf nOpc == 3  //Cabeçalho do Bordero de Despacho
              oPrn:Say(nLin   , nCol      , "Data..:"+DtoC(dDataBase)  , oFont4,,,,)
              oPrn:Say(nLin   , nCol + 550, "PRODUTOS NÃO SEPARADOS - Despacho: ", oFont2,,,,)
              oPrn:Say(nLin   , nCol +1600, Iif(mv_par01 == 1, '(TODOS)', mv_par02), oFont3,,,,)
              oPrn:Say(nLin   , nCol +1900, "Hora..:"+Time()           , oFont4,,,,)
              nLin += 50
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
              If mv_par03 == 1 .or. mv_par03 == 3
                 oPrn:Say(nLin, nCol, "QTDE.        PRODUTO      DESCRIÇÃO                               PEDIDO     EMBAL.         QUADR.             PROD.", oFont4, , , , )
              Else
                 oPrn:Say(nLin, nCol, "QTDE.        PRODUTO      DESCRIÇÃO                                          EMBAL.         QUADR.             PROD.", oFont4, , , , )
              Endif
              nLin += 50
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
       ElseIf nOpc == 4  //Rodapé do Bordero de Despacho
              nLin := nLinMax - 100
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
              If mv_par01 == 1
                 oPrn:Say(nLin, nCol, "(TODOS)", oFont4,,,,)
              Else
                 cRegiao  := Alltrim(Posicione("SZA", 1, xFilial("SZA")+mv_par02, "ZA_DESCR"))
                 dPrevis  := dTOc( Posicione("SZA", 1, xFilial("SZA")+mv_par02, "ZA_PREVDSP") )
                 cFabrica := Iif(mv_par06 =2,'Falta(s) da Fabrica I',Iif(mv_par06 =3,'Falta(s) da Fabrica II','Falta(s) em geral Fab. I e II'))

                 oPrn:Say(nLin, nCol      , cRegiao , oFont4,,,,)
                 oPrn:Say(nLin, nCol + 600, cFabrica, oFont4,,,,)
                 oPrn:Say(nLin, nCol + 1550, "Dt. Prev.:"+dPrevis, oFont4,,,,)
                 nLin += 55
                 oPrn:Say(nLin, 1100, "Peso das faltas até esta página :"+Transform(nPesoFalta,'@E 999999.99')+" Kg", oFont4,,,,)
                 
              Endif
       ElseIf nOpc == 5  //Cabeçalho do Pedido
              oPrn:Say(nLin   , nCol      , "Data..:"+DtoC(dDataBase)            , oFont4,,,,)
              oPrn:Say(nLin   , nCol + 550, "PRODUTOS NÃO SEPARADOS  -  Pedido: ", oFont2,,,,)
              oPrn:Say(nLin   , nCol +1600, mv_par01                             , oFont3,,,,)
              oPrn:Say(nLin   , nCol +1900, "Hora..:"+Time()                     , oFont4,,,,)
              nLin += 50
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
              oPrn:Say(nLin, nCol, "QTDE.        PRODUTO      DESCRIÇÃO                                          EMBAL.        QUADR.              PROD.", oFont4, , , , )
              nLin += 50
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
       ElseIf nOpc == 6  //Rodapé do Pedido
              cCodCli := Posicione("SC5", 1, xFilial("SC5")+mv_par01, "C5_CLIENTE")
              cNomCli := Alltrim(Posicione("SA1", 1, xFilial("SA1")+cCodCli, "A1_NOME"))
              cStaPed := Posicione("SC5", 1, xFilial("SZB")+'01'+mv_par01, "C5_APROVA")
              cCodBor := Alltrim(Posicione("SZG", 2, xFilial("SZG")+'01'+mv_par01, "ZG_CODIGO"))
              cCodCar := Alltrim(Posicione("SZB", 2, xFilial("SZB")+'01'+mv_par01, "ZB_CODIGO"))
              cDesCar := Alltrim(Posicione("SZA", 1, xFilial("SZA")+cCodCar, "ZA_DESCR"))
              dPreCar := dTOc( Posicione("SZA", 1, xFilial("SZA")+cCodCar, "ZA_PREVDSP") )
              dDespac := dTOc( Posicione("SZA", 1, xFilial("SZA")+cCodCar, "ZA_DTDESPA") )
              //If Len(aMatImp) > 0
                 nLin := nLinMax - 100
                 oPrn:Line(nLin, nCol, nlin, nColMax)
                 nLin += 10
                 cMsgRod := 'Cliente: '+cCodCli+'-'+cNomCli+'  /  Status: '+Iif(cStaPed == '0', 'Não Aprovado', Iif(cStaPed == '1', 'Aprovado', 'Bloqueado'))
                 oPrn:Say(nLin, nCol, cMsgRod, oFont4,,,,)
                 nLin += 50
                 cMsgRod := 'Retirada: '+cCodBor+'  /  Despacho: '+cCodCar+'-'+cDesCar+' - Previsão: '+dPreCar
                 oPrn:Say(nLin, nCol, cMsgRod, oFont4,,,,)
              //Else
              //   cMsgRod := 'Cliente: '+cCodCli+'-'+cNomCli+'  /  Status: '+Iif(cStaPed == '0', 'Não Aprovado', Iif(cStaPed == '1', 'Aprovado', 'Bloqueado'))+Chr(13)+Chr(10)
              //   cMsgRod += 'Retirada: '+cCodBor+'  /  Despacho: '+cCodCar+'-'+cDesCar+' - Previsão: '+dPreCar+Chr(13)+Chr(10)
              //   cMsgRod += 'Despacho: '+dDespac
              //   MsgBox(cmsgRod, "Informação do Pedido", "INFO")
              //Endif
       ElseIf nOpc == 7  //Cabeçalho do Cliente
              oPrn:Say(nLin   , nCol      , "Data..:"+DtoC(dDataBase)            , oFont4,,,,)
              oPrn:Say(nLin   , nCol + 500, "CLIENTE: "+mv_par01+' - '+SubStr(Posicione("SA1", 1, xFilial("SA1")+mv_par01, 'A1_NOME'), 1, 28), oFont2,,,,)
              oPrn:Say(nLin   , nCol +1900, "Hora..:"+Time()                     , oFont4,,,,)
              nLin += 50
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
              oPrn:Say(nLin, nCol, "QTDE.        PRODUTO      DESCRIÇÃO                                          EMBAL.         QUADR.             PROD.", oFont4, , , , )
              nLin += 50
              oPrn:Line(nLin, nCol, nlin, nColMax)
              nLin += 10
       Endif
Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200212 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg()
//                  6     2                                   30                              30                              30        6    1       2        1         1        1                                                                 60      3     3       1                    15               15               15                   15                                                              60                  15                 15                 15                 15                 15                 15                 15                 15                 15                 15                 15                 15                                         10
//             123456    12       123456789012345678901234567890  123456789012345678901234567890  123456789012345678901234567890   123456    1      12        1         1        1       123456789012345678901234567890123456789012345678901234567890    123   123       1       123456789012345   123456789012345    123456789012345    123456789012345    123456789012345123456789012345123456789012345123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345    123456789012345                                  1234567890
//     PutSx1( cGrupo  , cOrdem,  cPergunt                      , cPerSpa                       , cPerEng                       ,  cVar   ,  cTipo, nTamanho, nDecimal, nPresel,  cGSC,  cValid                                                       ,  cF3 , cGrpSxg,  cPyme,  cVar01         ,  cDef01          ,  cDefSpa1        ,  cDefEng1        ,  cCnt01                                                       ,  cDef02          ,  cDefSpa2        ,  cDefEng2        ,  cDef03          ,  cDefSpa3        ,  cDefEng3        ,  cDef04          ,  cDefSpa4        ,  cDefEng4        ,  cDef05          ,  cDefSpa5        ,  cDefEng5        , aHelpPor, aHelpEng, aHelpSpa,  cHelp)
       PutSX1("FAR121    ", "01"   , "Opção do relatório "          , ""                            , ""                            , "mv_ch1", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par01"      , "Bor. Pedidos   ", "               ", "               ", "                                                            ", "Bor. Despacho  ", "               ", "               ", "Pedido         ", "               ", "               ", "Cliente        ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12101." )
       aHelPor1 := {}
       aAdd(aHelPor1, 'Selecione o tipo de relatório a ser im- ')
       aAdd(aHelPor1, 'presso.                                 ')
       PutSX1Help("P.FAR12101.", aHelPor1, Nil, Nil)

       //Para Bordero de Pedidos
       PutSX1("FAR122    ", "01"   , "Quais borderos?    "          , ""                            , ""                            , "mv_ch1", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par01"      , "Todos          ", "               ", "               ", "                                                            ", "Específico     ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12201." )
       aHelPor1 := {}
       aAdd(aHelPor1, 'Selecione quais borderos serão impressos')
       aAdd(aHelPor1, 'Todos ou Específico de acordo com o pa -')
       aAdd(aHelPor1, 'râmetro 2 abaixo.                       ')
       PutSX1Help("P.FAR12201.", aHelPor1, Nil, Nil)

       PutSX1("FAR122    ", "02"   , "Numero Bordero     "          , ""                            , ""                            , "mv_ch2", "C"   , 06      , 0       , 0      , "G"  , "                                                            ", "SZF", "   "  , "   " , "mv_par02"      , "               ", "               ", "               ", "                                                            ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12202." )
       aHelPor2 := {}
       aAdd(aHelPor2, 'Para o parâmetro 1 = especifico selecio-')
       aAdd(aHelPor2, 'ne o numero do bordero.                 ')
       PutSX1Help("P.FAR12202.", aHelPor2, Nil, Nil)

       PutSX1("FAR122    ", "03"   , "Anali./Sintético/Anali. Prod"          , ""                            , ""                            , "mv_ch3", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par03"      , "Analítico      ", "               ", "               ", "                                                            ", "Sintético      ", "               ", "               ", "Anali. Produto      ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12203." )
       aHelPor3 := {}
       aAdd(aHelPor3, 'Informar se o relatório será analítico -')
       aAdd(aHelPor3, 'ou sintético. Analítico informa o numero')
       aAdd(aHelPor3, 'do pedido.                              ')
       PutSX1Help("P.FAR12203.", aHelPor3, Nil, Nil)

       PutSX1("FAR122    ", "04"   , "Linha ?            "          , ""                            , ""                            , "mv_ch4", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par04"      , "Geral          ", "               ", "               ", "                                                            ", "Base D'Água  ", "               ", "               ", "Automotivo       ", "               ", "               ", "Aut. Poliester ", "               ", "               ", "Moveleira       ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12204." )
       aHelPor4 := {}
       aAdd(aHelPor4, "Informar as linhas escolhidas para     '")
       aAdd(aHelPor4, 'visualizar o relatório por linha.       ')
       PutSX1Help("P.FAR12204.", aHelPor4, Nil, Nil)

       //Para Bordero de Despacho
       PutSX1("FAR123    ", "01"   , "Quais borderos?    "          , ""                            , ""                            , "mv_ch1", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par01"      , "Todos          ", "               ", "               ", "                                                            ", "Específico     ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12301." )
       aHelPor1 := {}
       aAdd(aHelPor1, 'Selecione quais borderos serão impressos')
       aAdd(aHelPor1, 'Todos ou Específico de acordo com o pa -')
       aAdd(aHelPor1, 'râmetro 2 abaixo.                       ')
       PutSX1Help("P.FAR12301.", aHelPor1, Nil, Nil)

       PutSX1("FAR123    ", "02"   , "Numero Bordero     "          , ""                            , ""                            , "mv_ch2", "C"   , 06      , 0       , 0      , "G"  , "                                                            ", "SZA", "   "  , "   " , "mv_par02"      , "               ", "               ", "               ", "                                                            ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12302." )
       aHelPor2 := {}
       aAdd(aHelPor2, 'Para o parâmetro 1 = específico selecio-')
       aAdd(aHelPor2, 'ne o numero do bordero.                 ')
       PutSX1Help("P.FAR12302.", aHelPor2, Nil, Nil)

       PutSX1("FAR123    ", "03"   , "Analitico/Sintético"          , ""                            , ""                            , "mv_ch3", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par03"      , "Analítico      ", "               ", "               ", "                                                            ", "Sintético      ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12303." )
       aHelPor3 := {}
       aAdd(aHelPor3, 'Informar se o relatório será analítico -')
       aAdd(aHelPor3, 'ou sintético. Analítico informa o numero')
       aAdd(aHelPor3, 'do pedido.                              ')
       PutSX1Help("P.FAR12303.", aHelPor3, Nil, Nil)

       PutSX1("FAR123    ", "04"   , "Linha ?            "          , ""                            , ""                            , "mv_ch4", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par04"      , "Geral          ", "               ", "               ", "                                                            ", "Base D'Água  ", "               ", "               ", "Automotivo       ", "               ", "               ", "B.P + Linha 23 ", "               ", "               ", "Moveleira       ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12304." )
       aHelPor4 := {}
       aAdd(aHelPor4, "Informar as linhas escolhidas para     '")
       aAdd(aHelPor4, 'visualizar o relatório por linha.       ')
       PutSX1Help("P.FAR12304.", aHelPor4, Nil, Nil)

       PutSX1("FAR123    ", "05"   , "Data de Previsão   "          , ""                            , ""                            , "mv_ch5", "D"   , 08      , 0       , 0      , "G"  , "                                                            ", "   ", "   "  , "   " , "mv_par05"      , "               ", "               ", "               ", "                                                            ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12305." )
       aHelPor5 := {}
       aAdd(aHelPor5, "Parametro utilizado somente quando o pri")
       aAdd(aHelPor5, 'meiro for para todos, para especificar a')
       aAdd(aHelPor5, 'data de previsão de despacho.           ')
       PutSX1Help("P.FAR12305.", aHelPor5, Nil, Nil)

       PutSX1("FAR123    ", "06"   , "Fabrica            "          , ""                            , ""                            , "mv_ch6", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par06"      , "Geral          ", "               ", "               ", "                                                            ", "Fabrica I      ", "               ", "               ", "Fabrica II      ", "               ", "               ", "              ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12306." )
       aHelPor6 := {}
       aAdd(aHelPor6, "Geral para as duas fábricas ou escolha '")
       aAdd(aHelPor6, 'Entre Fábrica I ou Fábrica II.          ')
       PutSX1Help("P.FAR12306.", aHelPor6, Nil, Nil)

       PutSX1("FAR123    ", "07"   , "Ordem de Produto/Quadrante? "          , ""                            , ""                            , "mv_ch7", "N"   , 01      , 0       , 1      , "C"  , "                                                             ", "   ", "   "  , "   " , "mv_par07"      , "Produto         ", "               ", "               ", "                                                            ", "Quadrante        ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12307." )
       aHelPor7 := {}
       aAdd(aHelPor3, 'Informar se o relatório será ordenado   ')
       aAdd(aHelPor3, 'por quadrante ou por código de produto  ')
       PutSX1Help("P.FAR12307.", aHelPor7, Nil, Nil)

       //Para Pedidos              
       PutSX1("FAR124    ", "01"   , "Numero do Pedido       "      , ""                            , ""                            , "mv_ch1", "C"   , 06      , 0       , 0      , "G"  , "NaoVazio()                                                  ", "SC5", "   "  , "   " , "mv_par01"      , "               ", "               ", "               ", "                                                            ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12401." )
       PutSX1("FAR124    ", "02"   , "Imprime todos os itens "      , ""                            , ""                            , "mv_ch2", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par02"      , "Sim"            , "               ", "               ", "                                                            ", "Não"            , "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12402." )
       aHelPor2 := {}
       aAdd(aHelPor2, "Parametro utilizado somente quando o pri")
       aAdd(aHelPor2, 'meiro for para todos, para especificar a')
       aAdd(aHelPor2, 'data de previsão de despacho.           ')
       PutSX1Help("P.FAR12402.", aHelPor2, Nil, Nil)
       
       //Para Clientes             
       PutSX1("FAR125    ", "01"   , "Código do Cliente  "          , ""                            , ""                            , "mv_ch1", "C"   , 06      , 0       , 0      , "G"  , "NaoVazio()                                                  ", "CLI", "   "  , "   " , "mv_par01"      , "               ", "               ", "               ", "                                                            ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12501." )
       PutSX1("FAR125    ", "02"   , "Qtde. Pedidos Fat. "          , ""                            , ""                            , "mv_ch2", "N"   , 01      , 0       , 0      , "G"  , "                                                            ", "   ", "   "  , "   " , "mv_par02"      , "               ", "               ", "               ", "                                                            ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12502." )
       PutSX1("FAR125    ", "03"   , "Imprime todos os itens "      , ""                            , ""                            , "mv_ch3", "N"   , 01      , 0       , 1      , "C"  , "                                                            ", "   ", "   "  , "   " , "mv_par03"      , "Sim"            , "               ", "               ", "                                                            ", "Não"            , "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", "               ", Nil     , Nil     , Nil     , ".FAR12503." )
       aHelPor3 := {}
       aAdd(aHelPor3, "Parametro utilizado somente quando o pri")
       aAdd(aHelPor3, 'meiro for para todos, para especificar a')
       aAdd(aHelPor3, 'data de previsão de despacho.           ')
       PutSX1Help("P.FAR12503.", aHelPor3, Nil, Nil)
       
Return  */

//Verifica se é produto de estoque
Static Function EHESTOQUE(_cCod)
Local aAlias := getarea()
Local aArea := {}
Local lRet := .f.
	aArea := U_PegaArea({"SB1","SB2"})   
	dbselectarea("SB1")
	dbsetorder(1)
	dbseek(xFilial("SB1")+_cCod,.F.)

/* Inibibito dia 15/06/2022   jose ----------------------
	if found()
		dbselectarea("SB2")
		dbsetorder(1)
		dbseek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD,.f.)
		if found() 
			if !empty(trim(SB2->B2_LOCALIZ))
				lRet := .t. // É PRODUTO DE ESTOQUE QUANDO HÁ LOCALIZAÇÃO!!
			endif 
 		endif
	endif       
--------------------  até aqui 15/06/2022 --------------*/
//   acrescentei aqui 16/06/2022 ---------------------------------

	if (SB1->B1_ESTOQUE = "S")
		lRet := .t. // É PRODUTO DE ESTOQUE QUANDO HÁ LOCALIZAÇÃO!!
	endif 

//---------------------------- até aqui 15/06/2022  ------------------

	U_VoltaArea(aArea)	
	restarea(aAlias)
return(lRet)
