#Include "Protheus.ch"
#Include "TOPCONN.CH"
 
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M460FIM  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 28/07/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE após gravar nota e altera contas a receber       		  ³±±
±±³			 ³ Projeto para desabilitar as triggers do banco de dados     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function M460FIM()


/* Nelieder Corneta 01/08/2022 */
/* Rotina que subistitiu triggers da SE1 */

/* caso não seja brasilux sai da função */
   //If alltrim(FWGrpCompany()) == '01'
      
      /* parametro que habita uso via PE */
      If GETMV("ZP_PAR0060")

             /* trigger SF2010 */   

            If Select("_QRY") <> 0
	            _QRY->(dbCloseArea())
            endif 	 

            //Filtra títulos dessa nota
            cSql := "SELECT SE1.R_E_C_N_O_ AS REC,C5_BANCO,E1_CLIENTE,C5_COMIS1,E1_LOJA,E1_TIPO FROM "+RetSqlName("SE1")+" SE1 "
            cSql += " INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_NUM = E1_PEDIDO AND C5_FILIAL = E1_FILIAL AND C5_CLIENTE = E1_CLIENTE "
            cSql += " AND SC5.D_E_L_E_T_ = '' "
            cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND SE1.D_E_L_E_T_<>'*' "
            cSql += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"' "
            cSql += " AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"' "
            cSql += " AND E1_TIPO = 'NF' "
            TcQuery ChangeQuery(cSql) New Alias "_QRY"
                
            //Enquanto tiver dados na query
            While !_QRY->(eof())
                DbSelectArea("SE1")
                SE1->(DbGoTo(_QRY->REC))

                    RecLock("SE1",.F.)
                        
                        
                        IF (_QRY->E1_TIPO == "NCC") .OR. (_QRY->E1_TIPO == "AB-") .OR. (_QRY->E1_TIPO == "JP") .OR. (_QRY->E1_TIPO == "RA")
                            Replace E1_X_SIM3G  WITH 'N'
                        ELSE
                            Replace E1_X_SIM3G  WITH 'S'
                        ENDIF
                        
                        Replace E1_X_EXPO  WITH  ""

                        If alltrim(FWGrpCompany()) == '11'

                            Replace E1_ITEMCTA  WITH "C"+_QRY->E1_CLIENTE+_QRY->E1_LOJA

                        else
                            
                            Replace E1_BCO      WITH _QRY->C5_BANCO    
                            Replace E1_ITEMCTA  WITH "C"+_QRY->E1_CLIENTE
                            Replace E1_X_DTATU  WITH dDataBase
                            
                            If (SE1->E1_COMIS1 <> _QRY->C5_COMIS1)
                                Replace E1_COMIS1  WITH  _QRY->C5_COMIS1
                            EndIf    

                        endif
            
                    MsUnlock()

                    
                _QRY->(DbSkip())
            Enddo


      Endif

//   Endif

   /* trigger SF2010 */ 
   If alltrim(FWGrpCompany()) == '01'
        If GETMV("ZP_PAR0061")

           If Select("TMP_ZZ0") <> 0
	           TMP_ZZ0->(dbCloseArea())
           endif 	

           BeginSQL Alias "TMP_ZZ0"
                SELECT TOP 1 R_E_C_N_O_ FROM ZZ0040 WHERE D_E_L_E_T_ <> '*' AND ZZ0_FILIAL = %xFilial:SF2% AND 
		        ZZ0_PEDIDO = %exp:SF2->F2_PEDIDO%
            EndSQL    
            cQuery := GetLastQuery()[2]
            RecnoZZ0 := TMP_ZZ0->R_E_C_N_O_
            /* Registros localizados */
            Count To nRecCount
            
            cRecno   := SF2->(RecNo())
            cEmpresa := SUBSTRING(xFilial("SF2"),1,2)

            If nRecCount > 0
            
                
                cSql :=  "UPDATE ZZ0040 SET ZZ0_NFISCA = SF2.F2_DOC,ZZ0_REDESP = SF2.F2_REDESP,ZZ0_VALMER = SF2.F2_VALMERC,"
                cSql += " ZZ0_VOLUME = SF2.F2_VOLUME1,ZZ0_PLIQUI = SF2.F2_PLIQUI,ZZ0_PBRUTO = SF2.F2_PBRUTO,ZZ0_VALFAT = SF2.F2_VALFAT, "
                cSql += " ZZ0_EMPRES = '"+cEmpresa+"', "
                cSql += " ZZ0_BORDER = ISNULL(ZB_CODIGO,ZZ0_BORDER),ZZ0_DTBORD = ISNULL(ZA_EMISSAO,ZZ0_DTBORD),	"  
                cSql += " ZZ0_PEDIDO = '"+SF2->F2_PEDIDO+"', "
                cSql += " ZZ0_CGCRED = ISNULL(A4_CGC,ZZ0_CGCRED),ZZ0_CLIENT = F2_CLIENTE,ZZ0_LOJACL = F2_LOJA, "
                cSql += " ZZ0_RAZAO = F2_RAZAO, "
                cSql += " ZZ0_ENDENT = CASE WHEN ISNULL(A1_ENDENT,'') > '' THEN A1_ENDENT ELSE ISNULL(A1_END,ZZ0_ENDENT) END, "
                cSql += " ZZ0_MUNENT = CASE WHEN ISNULL(A1_ENDENT,'') > '' THEN ISNULL(A1_MUNE,'') ELSE ISNULL(A1_MUN,ZZ0_MUNENT) END, "
                cSql += " ZZ0_ESTENT = CASE WHEN ISNULL(A1_ENDENT,'') > '' THEN ISNULL(A1_ESTE,'') ELSE ISNULL(A1_EST,ZZ0_ESTENT) END, "
                cSql += " ZZ0_CNPJ = ISNULL(A1_CGC,ZZ0_CNPJ),ZZ0_INSCR = ISNULL(A1_INSCR,ZZ0_INSCR),ZZ0_REGIAO = ISNULL(Z7_REGIAO,ZZ0_REGIAO) "
                cSql += " FROM SF2010 SF2  "
                cSql += " LEFT OUTER JOIN ZZ0040 ZZ0 ON ZZ0.R_E_C_N_O_ = "+AllTrim(str(RecnoZZ0))+"  "
                cSql += " LEFT OUTER JOIN SZB010 SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL =  '"+xFilial("SF2")+"') AND (SUBSTRING(ZB_PEDIDO,3,6) = F2_PEDIDO) AND (F2_REDESP > '') "
                cSql += " LEFT OUTER JOIN SZA010 SZA WITH (NOLOCK) ON (SZA.D_E_L_E_T_ <> '*') AND (ZA_FILIAL = ZB_FILIAL) AND (ZA_CODIGO = ZB_CODIGO)  "
                cSql += " LEFT OUTER JOIN SA4010 SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (F2_REDESP = A4_COD)  "
                cSql += " LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (F2_CLIENTE = A1_COD) AND (F2_TIPO = 'N')  "
                cSql += " LEFT OUTER JOIN SZ7010 SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (A1_CODCID = Z7_COD) "
                cSql += " WHERE SF2.R_E_C_N_O_ = "+AllTrim(str(cRecno))+" "
                TCSqlExec(cSql)
            else
                
                If Select("_TMP") <> 0
	                _TMP->(dbCloseArea())
                endif

                /* retorna ultimo recno */
                cSql :=  "SELECT MAX(R_E_C_N_O_)+1 MAX FROM ZZ0040 "
                TcQuery ChangeQuery(cSql) New Alias "_TMP"
                cRecnoZZ4 := AllTrim(str(_TMP->MAX))

                cSql :=  "INSERT INTO ZZ0040 (ZZ0_FILIAL,ZZ0_BORDER,ZZ0_DTBORD,ZZ0_EMPRES,ZZ0_PEDIDO,ZZ0_NFISCA,ZZ0_REDESP,ZZ0_CGCRED,ZZ0_CLIENT, "
			    cSql += " ZZ0_LOJACL,ZZ0_RAZAO,ZZ0_ENDENT,ZZ0_MUNENT,ZZ0_ESTENT,ZZ0_CNPJ,ZZ0_INSCR,ZZ0_VALMER,ZZ0_VOLUME,ZZ0_PLIQUI,ZZ0_PBRUTO, "
			    cSql += " ZZ0_REGIAO,ZZ0_VALFAT,R_E_C_N_O_) SELECT "
			    cSql += " TOP 1 '"+xFilial("SF2")+"',ZB_CODIGO,ZA_EMISSAO,'"+alltrim(FWGrpCompany())+"',F2_PEDIDO,F2_DOC,F2_REDESP,ISNULL(A4_CGC,''), "
			    cSql += " F2_CLIENTE,F2_LOJA,F2_RAZAO,CASE WHEN ISNULL(A1_ENDENT,'') > '' THEN A1_ENDENT ELSE ISNULL(A1_END,'') END, "
			    cSql += " CASE WHEN ISNULL(A1_ENDENT,'') > '' THEN ISNULL(A1_MUNE,'') ELSE ISNULL(A1_MUN,'') END, "
			    cSql += " CASE WHEN ISNULL(A1_ENDENT,'') > '' THEN ISNULL(A1_ESTE,'') ELSE ISNULL(A1_EST,'') END, "
			    cSql += " ISNULL(A1_CGC,''),ISNULL(A1_INSCR,''),F2_VALMERC,F2_VOLUME1,F2_PLIQUI,F2_PBRUTO,ISNULL(Z7_REGIAO,''), "
			    cSql += " F2_VALFAT, '"+cRecnoZZ4+"' "
			    cSql += " FROM SZB010 SZB WITH (NOLOCK)  "
			    cSql += " LEFT OUTER JOIN SZA010 SZA WITH (NOLOCK) ON (SZA.D_E_L_E_T_ <> '*') AND (ZA_FILIAL = ZB_FILIAL) AND (ZA_CODIGO = ZB_CODIGO) "
			    cSql += " LEFT OUTER JOIN SF2010 SF2 on SF2.R_E_C_N_O_ = "+AllTrim(str(cRecno))+" "
			    cSql += " LEFT OUTER JOIN SA4010 SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ <> '*') AND (F2_REDESP = A4_COD) "
			    cSql += " LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (F2_CLIENTE = A1_COD) 
			    cSql += " LEFT OUTER JOIN SZ7010 SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (A1_CODCID = Z7_COD) 
			    cSql += " WHERE (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = '"+xFilial("SF2")+"') AND (SUBSTRING(ZB_PEDIDO,3,6) = F2_PEDIDO) AND 
			    cSql += " (F2_REDESP > '') 
                TCSqlExec(cSql)
            
            
            
            EndIf

            /* atualiza SD2 comissao */
            cSql :=  " UPDATE SD2010 SET D2_COMIS1 = C5_COMIS1 "
            cSql +=  " FROM SD2010 SD2 "
            cSql +=  " INNER JOIN SC5010 SC5 WITH (NOLOCK) ON SC5.D_E_L_E_T_ <> '*' AND D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM "
            cSql +=  " AND SC5.D_E_L_E_T_ <> '*' AND D2_CLIENTE =  C5_CLIENTE AND D2_COMIS1 <> C5_COMIS1 "
            cSql +=  " WHERE D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"'  "
            cSql +=  " AND SD2.D_E_L_E_T_ = '' "
            TCSqlExec(cSql)

            cSql :=  " UPDATE SC6010 SET C6_FCICOD = D2_FCICOD, C6_CLASFIS = D2_CLASFIS "
            cSql +=  " FROM SD2010 SD2 "
            cSql +=  " LEFT OUTER JOIN SC6010 SC6 ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = D2_FILIAL) "
            cSql +=  " AND (C6_NUM = D2_PEDIDO) AND (C6_ITEM = D2_ITEMPV) "
            cSql +=  " WHERE D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND SD2.D_E_L_E_T_ = ''  "
            cSql +=  " AND (D2_TIPO = 'N') AND (D2_FCICOD > '') AND (C6_FCICOD <> D2_FCICOD) "
            TCSqlExec(cSql)




        Endif

    Endif



Return
