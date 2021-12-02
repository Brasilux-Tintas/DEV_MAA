#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MSD2460  ºAutor  ³ Cleber O. Dominguesº Data ³  02/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Após gravacao do SD2, gravação do local está errada no pro-º±±
±±º          ³ grama original                                             º±±
±±º 25/05/07 ³ Luís Gustavo                                               º±±
±±º          ³ Tirada parte de gravação do Local nos Itens das NFs.       º±±
±±º 07/01/08 ³ Cleber                                                     º±±
±±º          ³ Tirar resíduo de subst. tributária para Cons. Finais de    º±±
±±º          ³ mesmo estado que o de origem.                              º±±
±±º 19/08/08 ³ Cleber                                                     º±±
±±º          ³ Gravar perc. de comissão igual ao SC5 para não atrapalhar  º±±
±±º          ³ cálculo de comissão.                                       º±±
±±º 09/06/14 ³ Cleber                                                     º±±
±±º          ³ Calculo do total de imposto pelo IBPT p. atender lei da    º±±
±±º          ³ transparência fiscal.                                      º±±
±±º 28/02/19 ³ Cleber                                                     º±±
±±º          ³ Gravação de D2_X_SIM3G para envio de informações para Mas- º±±
±±º          ³ terSales                                                   º±±
±±º 25/09/19 ³ Luís Gustavo                                               º±±
±±º          ³ Adequação para release 12.1.25                             º±±
±±º 02/11/20 ³ Cleber Orati                                               º±±
±±º          ³ Inclusão do Bloco C113 para NFs TES 824                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MSD2460()
     Local cArea      := Alias()  
     Local aAreaAnt := U_PegaArea({"SB1","SA1","SC5","SC6","SD1","CLK","SF4"})
     Local lBloqueado := .f.
     Local lBloqueou  := .f.
     Local _cGrpEmp,cEnvVend,nRegD1,cEst,cAux,lPegaSF1,nRegD2,nImpNcm := 0
     u_zcfga01( 'MSD2460' ) //LGS#2021201 - Gravação de log de utilização da rotina
_cGrpEmp := ALLTRIM(FWGrpCompany())
dbselectarea("SF4")
dbsetorder(1)
dbseek(xFilial("SF4")+SD2->D2_TES)

// Cleber(28/02/19) => Mandar informação para MasterSales
IF (SD2->(FieldPos("D2_X_SIM3G")) > 0) 
   cEnvVend := "N"
   IF !(SD2->D2_TIPO = "D")
      cEnvVend := IIF(SF4->F4_DUPLIC = "S","S","N")
   ENDIF
   SD2->D2_X_SIM3G := cEnvVend
   SD2->D2_X_EXPO := " "
ENDIF

//Item Contábil (Cleber 29/07/20)
//If(cTipo$"DB","F","C")+M->D2_CLIENTE                                                                
IF EMPTY(SD2->D2_ITEMCC)
   cAux := iif(alltrim(SD2->D2_TIPO) $ "DB","F","C")+SD2->D2_CLIENTE
   if _cGrpEmp == '11' //TecPolpa utiliza código de loja
      cAux += SD2->D2_LOJA
   endif
   SD2->D2_ITEMCC := cAux
ENDIF 

If _cGrpEmp <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        DbSelectArea("SD2")
        nRegD2     := RecNo()
        lBloqueado := U_EstaBloqueado('SD2', nRegD2)
	     cEst       := alltrim(getmv("MV_ESTADO"))

        // Gravar NCM, e Nome de Produtos
        DbSelectArea("SB1")     
        DbSetOrder(1)                      
        DbSeek(xFilial("SB1")+SD2->D2_COD)
        If Found()              
           dbselectarea("CLK")
           dbsetorder(2)  //CLK_FILIAL+CLK_CODNCM+CLK_EX+CLK_UF+DTOS(CLK_DTINIV)+DTOS(CLK_DTFIMV)                                                                                           
           dbseek(xFilial("CLK")+SB1->B1_POSIPI+SB1->B1_EX_NCM+cEst+substr(DTOS(dDataBase),1,4))
           while !eof() .and. (CLK->CLK_FILIAL = xFilial("CLK")) .AND. (CLK->CLK_CODNCM = SB1->B1_POSIPI) .AND. (CLK->CLK_EX = SB1->B1_EX_NCM) .AND. (CLK->CLK_UF = cEst) .and. (DTOS(CLK->CLK_DTINIV) = substr(DTOS(dDataBase),1,4)) 
			/*
			0 – Nacional, exceto ao indicados nos códigos 3, 4, 5 e 8;
			1 – Estrangeira – Importação direta, exceto a indicada no código 6;
			2 – Estrangeira – Adquirida no mercado interno, exceto a indicada no código 7;
			3 – Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40% e inferior ou igual a 70%;
			4 – Nacional cuja produção tenha sido feita em conformidade com os processos produtivos básicos de que tratam o Decreto Lei n} 286/67, e as Leis nºs 8.248/91, 8.387/91, 10.176/01 e 11.484/07; (*)
			5 – Nacional, mercadoria ou bem com Conteúdo de Importação inferior ou igual a 40%;
			6 – Estrangeira – Importação direta, sem similar nacional, constante em lista de Resolução da CAMEX;
			7 – Estrangeira – Adquirida no mercado interno, sem similar nacional, constante em lista de Resolução da CAMEX;
			8 – Nacional, mercadoria ou bem com conteúdo de importação superior a 70%.
			*/
   			nImpNcm := IIF(SUBSTR(SD2->D2_CLASFIS,1,1) $ "1-2-6-7",CLK->CLK_ALQIMP,CLK->CLK_ALQNAC)+CLK->CLK_ALQEST+CLK->CLK_ALQMUN
	   		dbselectarea("CLK")
	   		dbskip()
           enddo 

           DbSelectArea("SD2")
           If !lBloqueado .and. !lBloqueou
              RecLock("SD2", .F.)
              lBloqueou := .t.	
           Endif
           SD2->D2_POSIPI := SB1->B1_POSIPI
           SD2->D2_DESCRI := SB1->B1_DESC  
           //Cleber (30-03-15)
           //nImpNcm := SB1->B1_IMPNCM 
        Endif
        IF SD2->D2_TIPO = "N"
           dbselectarea("SA1")
           dbsetorder(1)
           dbseek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
           //Cleber (09/06/14) -> LEI DA TRANSPARÊNCIA P/ CONSUMIDOR FINAL
           if (nImpNcm > 0) .AND. (SA1->A1_CLAS $ "C.N") .AND. (SD2->D2_TOTIMP == 0.00)  
              SD2->D2_TOTIMP := round(SD2->D2_VALBRUT*nImpNcm/100,TamSX3("D2_TOTIMP")[2])  
              SF2->F2_TOTIMP += SD2->D2_TOTIMP 
           endif
           /*	
           // 07/01/08 => Zerar Subst. Tributária p/ Cons. Final de mesmo estado!!!!
           cEst := getmv("MV_ESTADO")
           if (cEst = SD2->D2_EST) 
              IF (SA1->A1_COD = SD2->D2_CLIENTE) .and. (SA1->A1_CLAS = 'C') .AND. (SD2->D2_ICMSRET != 0) .AND. (SD2->D2_ICMSRET >= -0.03)  .AND. (SD2->D2_ICMSRET <= 0.03)
                 SD2->D2_BRICMS := 0
                 SD2->D2_ICMSRET := 0
              ENDIF 
           endif 
           */
           // Cleber(19/08/08) => Gravar perc. de comissão igual ao SC5
           if !empty(SD2->D2_PEDIDO) 
              DbSelectArea("SC5")     
              DbSetOrder(1)  
              dbseek(xFilial("SC5")+SD2->D2_PEDIDO)
              /*
              //CLEBER(31/03/21), troca p/ C5_COMIS1
              If found() .and. (SD2->D2_COMIS1 != SC5->C5_PORCOM)   
                 dbselectarea("SD2")
                 SD2->D2_COMIS1 := SC5->C5_PORCOM
              endif    
              */                
              If found() .and. (SD2->D2_COMIS1 != SC5->C5_COMIS1)   
                 dbselectarea("SD2")
                 SD2->D2_COMIS1 := SC5->C5_COMIS1
              endif                    
           endif  
        ENDIF 

        IF ((cNumEmp = "01010106") .or. (cNumEmp = "01010107")) .and. (SD2->D2_CF <> '5907') .AND. (SD2->D2_TES <> '993') //Cleber(17/08/20) TES 993 criada pelo depto fiscal com finalidade específica para anular saldo fiscal e não saldo físico
           //Gravar registro de movimentação de saída para depósito p/ ref. p/ movim. interna na filial 010101
           dbselectarea("ZZY")
           RecLock("ZZY", .T.)
              ZZY->ZZY_FILIAL := "010101"
              ZZY->ZZY_DOC := nRegD2
              ZZY->ZZY_TIPO := "S"
              ZZY->ZZY_TAB := "SD2"
           MsUnLock()
        ENDIF   	
        DbSelectArea("SD2")
        If !lBloqueado .and. lBloqueou
           MsUnLock()
        Endif
Endif //Fim If FWCodEmp() <> '11'
//BLOCO C113
lPegaSF1 := .F. // Pega dados de NF de origem seja porque é devolução ou porque é remessa simbolica de vendas
IF !empty(alltrim(SF4->F4_CODINFC)) .and. !EMPTY(ALLTRIM(SD2->D2_NFORI)) .AND. !EMPTY(ALLTRIM(SD2->D2_ITEMORI))
   dbselectarea("SF1")
   dbsetorder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                                                                                                                             
   dbseek(xFilial("SF1")+SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA)
   if found()
      if  (ALLTRIM(SD2->D2_TIPO) $ "D-B") .OR. (SF1->F1_TIPO = "B") //Se NF usa fornecedor ou então se a NF de origem utiliza o código de cliente (tipo B-Beneficiamento)
         lPegaSF1 := .t.
      endif 
   endif 
ENDIF 
IF !lPegaSF1 .AND.  (SC6->(FieldPos("C6_XREGD1D")) > 0)  .and. !empty(alltrim(SF4->F4_CODINFC)) //Remessas Simbólicas de compras
   dbselectarea("SC6")
   dbsetorder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                             
   dbseek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)
   if found() 
      nRegD1 := SC6->C6_XREGD1D 
   	if (ValType(nRegD1) = "N") .AND. (nRegD1 > 0) // Se existe registro de SD1 de referência no pedido de saída
         dbselectarea("SD1")
         dbgotop()
         dbgoto(nRegD1)
         if !eof() .and. !bof() .and. (SD1->D1_FILIAL == xFilial("SD1")) .AND. !empty(SD1->D1_DOC)
            dbselectarea("SF1")
            dbsetorder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO  
            dbseek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
            if found()
               lPegaSF1 := .t.
            endif 
         endif 
      ENDIF 
   endif 
ENDIF 


IF lPegaSF1 // Se for referenciar SF1 p/ bloco C113
		dbselectarea("CDD")
		dbsetorder(1) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF                                                          
		dbseek(xFilial("CDD")+"S"+padr(ALLTRIM(SD2->D2_DOC),TamSx3("CDD_DOC")[1]," ")+padr(alltrim(SD2->D2_SERIE),TamSx3("CDD_SERIE")[1]," ")+padr(SD2->D2_CLIENTE,TamSx3("CDD_CLIFOR")[1]," ")+SD2->D2_LOJA+padr(SF1->F1_DOC,TamSx3("CDD_DOCREF")[1]," ")+padr(SF1->F1_SERIE,TamSx3("CDD_SERREF")[1]," ")+padr(SF1->F1_FORNECE,TamSx3("CDD_PARREF")[1]," ")+SF1->F1_LOJA)
		if !found() 
			reclock("CDD",.T.)
			CDD->CDD_FILIAL := xFilial("CDD")
			CDD->CDD_TPMOV := "S"
			CDD->CDD_DOC := SD2->D2_DOC
			CDD->CDD_SERIE := SD2->D2_SERIE
			CDD->CDD_CLIFOR := SD2->D2_CLIENTE
			CDD->CDD_LOJA := SD2->D2_LOJA
			CDD->CDD_DOCREF := SF1->F1_DOC
			CDD->CDD_SERREF := SF1->F1_SERIE
			CDD->CDD_PARREF := SF1->F1_FORNECE
			CDD->CDD_LOJREF := SF1->F1_LOJA
		else
			reclock("CDD",.f.)
      endif 
		CDD->CDD_IFCOMP := SF4->F4_CODINFC
		CDD->CDD_CHVNFE := SF1->F1_CHVNFE
		CDD->CDD_SDOC := SD2->D2_SERIE
		CDD->CDD_SDOCRF := SF1->F1_SERIE
		CDD->CDD_ENTSAI := "1"

		msunlock()

 
ENDIF 


U_VoltaArea(aAreaAnt)
if !empty(cArea)
	dbselectarea(cArea)
endif
Return(.t.)
