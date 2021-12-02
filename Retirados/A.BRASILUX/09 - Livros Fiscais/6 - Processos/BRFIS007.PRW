#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

/*
/////////////////////////////////////////////////////////
// Funçào....: BRFIS003     Data....: 23/03/2006         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçào.: Gerar arq. txt para Secretarias de Fazenda //
// ADAPTAÇÃO P/ A MUDANÇA  EM 2006, alertada pelo estado da Bahia
// Uso.......: Qquer empresa/Filial                      //
// Variaveis utilizadas para parametros        
// mv_par01             // Data de ?   		
// mv_par02             // Data Até ? 		
// mv_par03             // Estado				
// mv_par04             // Local de Gravação	                          
*/  


User Function BRFIS007()  

private cPERG,mv_par01,mv_par02,mv_par03,mv_par04,nReg

cPerg   := "BRFI03"
                      
VldPerg()            // Verifica as perguntas selecionadas 
Pergunte(cPerg,.F.)  // Pergunta no SX1
@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Gerar Arquivo TXT para GNRE's CFOP 4 DIG."

@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa({|lEnd| BRFI032()})
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,16 SAY "Geracao do Arquivo segundo o Convenio ICMS 57/95  "
@ 33,16 SAY "com movimentacoes fiscais. O arquivo e' gerado na  "
@ 43,16 SAY "pasta definida nos parametros => CFOP 4 DIGITOS!!  "
@ 8,10 TO 84,222
ACTIVATE DIALOG oDlg1
Return

static Function BRFI032()
       Local _nX
       Local _lCont       := .T.
       Local _aRetInf     := FWGetSX5 ( "12" )
       //Local i,cPer1,cPer2,cCond,cNcm
       Local cMes,dPer1,dPer2,cAno
       Private oTempTable
       Private cArq       := GetNextAlias()

       If mv_par01 > mv_par02 //substr(dtos(mv_par01),5,2) > substr(dtos(mv_par02),5,2)
          MsgStop("Periodo Invalido!")	
       Else 
          /********************************************************************************************************************************/
          /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
          //Dbselectarea("SX5")
          //Dbsetorder(1)
          //If Empty(mv_par03)                                                  
          //   DbSeek( xFilial('SX5') + '12' )
          //   cCond := "(xFilial('SX5')+SX5->X5_TABELA) = (xFilial('SX5')+'12')"
          //Else
          //   Dbseek(xFilial('SX5')+'12'+mv_par03)
          //   cCond := "(xFilial('SX5')+SX5->X5_TABELA+SX5->X5_CHAVE) = (xFilial('SX5')+'12'+'"+mv_par03+"')"
          //Endif
          //DbSelectarea("SX5")
          //Do while !eof() .and. &cCond
          //   mv_par03 := alltrim(SX5->X5_CHAVE)
          //   nReg := recno()      
          //   dPer1 = mv_par01
          //   dPer2 = mv_par02
          //   DO WHILE dPer1 < mv_par02
          //      nMes = Val( Substr( dtos( dPer1 ), 5, 2 ) ) + 1 //MONTH(dPer_Inic)+1
          //      IF nMes > 12
          //         nMes = 1
          //         nAno = Val( Substr( Dtos( dPer1 ), 1, 4 ) ) + 1
          //      Else
          //         nAno = Val( Substr( Dtos( dPer1 ), 1, 4 ) )
          //      Endif              
          //      cMes  = Alltrim( Str( nMes ) )
          //      If Len( cMes ) == 1
          //         cMes = "0"+cMes
          //      Endif
          //      cAno  = Alltrim( Str( nAno ) )
          //      cAno  = Replicate( "0", 4 - Len( cAno ) ) + cAno
          //      dPer2 = Ctod("01/" + cMes + "/" + cAno ) - 1  //   DATE(nAno,nMes,1) - 1
          //      brfi031(dPer1,dPer2)
          //      dPer1 = dPer2+1
          //   ENDDO
          //   DbSelectArea("SX5")
          //   DbGoto(nReg)
          //   DbSkip()
          //Enddo

          For _nX := 1 TO Len( _aRetInf )
              If Empty( mv_par03 ) //Executa para todos os estados
                 mv_par03 := _aRetInf[_nX][3] //Passo a chave(Sigla do Estado) para o parâmetro
                 _lCont := .T.
              Else //Executa somente 1 vez para o estado do parâmetro mv_par03
                 If _nX > 1 
                    _lCont := .F.
                 Endif
              Endif
              If _lCont
                 dPer1 = mv_par01
                 dPer2 = mv_par02
                 DO WHILE dPer1 < mv_par02
                    nMes = Val( Substr( dtos( dPer1 ), 5, 2 ) ) + 1 //MONTH(dPer_Inic)+1
                    IF nMes > 12
                       nMes = 1
                       nAno = Val( Substr( Dtos( dPer1 ), 1, 4 ) ) + 1
                    Else
                       nAno = Val( Substr( Dtos( dPer1 ), 1, 4 ) )
                    Endif              
                    cMes  = Alltrim( Str( nMes ) )
                    If Len( cMes ) == 1
                       cMes = "0"+cMes
                    Endif
                    cAno  = Alltrim( Str( nAno ) )
                    cAno  = Replicate( "0", 4 - Len( cAno ) ) + cAno
                    dPer2 = Ctod("01/" + cMes + "/" + cAno ) - 1  //   DATE(nAno,nMes,1) - 1
                    brfi031(dPer1,dPer2)
                    dPer1 = dPer2+1
                 ENDDO
              Endif
          Next
          /********************************************************************************************************************************/ 
//****************************
Alert("Processo Finalizado!" + CHR(13)+CHR(10))
			
endif 
Return

STATIC Function BRFI031(dPer1,dPer2)
local cEmis01,cEmis02,cArqRem,nCont,nHandle,cLinha
Local nCont10,nCont11,cInscr_est,cCgc,cAux,i,nCont51,nCont53,nCont54,;
nCont55,nCont75,nCont90,cAuxVlr,cAux1,cNfiscal,nOrdem,cArq
//Local cInd01, cKey01
Local nBaseIcm,cEmitente,cDescrProd
Local _nICMPAD := GETMV("MV_ICMPAD")
ProcRegua(9,21,6)


cEmis01 = dtos(dPer1)
cEmis02 = dtos(dPer2)
dbselectarea("SF2")
dbsetorder(1)
nCont = 1 
cArqRem = alltrim(mv_par04)
cArqRem += mv_par03
cArqRem += "\RE"
cArqRem += SUBSTR(DTOS(DATE()),7,2)
cArqRem += SUBSTR(DTOS(DATE()),5,2)
cArqRem += alltrim(str(nCont))
cArqRem += ".TXT"
do while file(cArqRem)
	nCont = nCont+1
	cArqRem = alltrim(mv_par04)+mv_par03+"\RE"+SUBSTR(DTOS(DATE()),7,2)+SUBSTR(DTOS(DATE()),5,2)+;
	alltrim(str(nCont))+".TXT"
enddo

//****************************
nHandle = fcreate(cArqRem)
if nHandle < 0 
  MsgStop("Não foi possível criar arquivo "+cArqRem+"!")
else
	// Reg. tipo 10
	nCont10 = 0

	cLinha = "10"+SM0->M0_CGC+SM0->M0_INSC+SUBSTR(SM0->M0_NOMECOM,1,35)+;
				 SM0->M0_CIDENT+SPACE(10)+SM0->M0_ESTENT
	//Fax
	cAux = ALLTRIM(SM0->M0_FAX)
	if len(cAux) > 10
		cAux = substr(cAux,2,10)
	endif
	cAux = replicate("0",10-len(cAux))+cAux
	cLinha = cLinha+cAux+DTOS(dPer1)+;
				 dtos(dPer2)+"321"+chr(13)+chr(10)
	fwrite(nHandle,cLinha,len(cLinha))		

	nCont10 = nCont10+1
		
	IncProc()

	// Reg. tipo 11
	nCont11 = 0
		
	cLinha = "11"+SM0->M0_ENDENT+SPACE(4)+REPLICATE('0',5-LEN(ALLTRIM(SM0->M0_COMPENT)))+;
	ALLTRIM(SM0->M0_COMPENT)+space(22)+SUBSTR(SM0->M0_BAIRENT,1,15)+;
	SM0->M0_CEPENT+"CLEBER ORATI DOMINGUES"+SPACE(6)
	cAux = alltrim(SM0->M0_TEL)
	cAux1 = ""
	for i = 1 to len(cAux)
		if isdigit(substr(cAux,i,1))
			cAux1 = cAux1+substr(cAux,i,1)
		endif
	next
	cAux = cAux1
	cLinha += REPLICATE('0',12-LEN(ALLTRIM(cAux)))+;
	cAux+chr(13)+chr(10)

	fwrite(nHandle,cLinha,len(cLinha))		

	nCont11 = nCont11+1
		
	IncProc()
	// Reg. tipo 50
	nCont50 = 0
	dbselectarea("SF3")
	dbsetorder(1)
	dbseek(xFilial("SF3")+dtos(dPer1),.t.)
	while !eof() .and. (F3_FILIAL == xFilial("SF3")) .and. ;
		(SF3->F3_ENTRADA >= dPer1) .and. (SF3->F3_ENTRADA <= dPer2)
		if (SF3->F3_ESTADO == mv_par03) .AND. EMPTY(SF3->F3_DTCANC) .and. ;
			(SUBSTR(SF3->F3_CFO,1,1) >= "5") // Somente Saídas, por enquanto

			cCgc = replicate("0",14)
			cInscr_est = space(14)
			dbselectarea("SF2")
			dbseek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE,.t.)
			if found()
				cCgc = ALLTRIM(SF2->F2_CGC)
				cInscr_est = ALLTRIM(SF2->F2_INSCR)
			endif
			dbselectarea("SF3")
			cCfop = alltrim(SF3->F3_CFO)
			cCfop = replicate("0",4-len(cCfop))+cCfop
			cCgc = alltrim(cCgc)
			cCgc = replicate("0",14-len(cCgc))+cCgc
				
			cInscr_est = alltrim(cInscr_est)
			if empty(cInscr_est)
				cInscr_est = "ISENTO"
			endif
			cInscr_est = cInscr_est+replicate(" ",14 - len(cInscr_est))
			//cNronf = SF3->F3_NFISCAL+SF3->F3_SERIE
			cLinha = "50"+cCgc+cInscr_est+dtos(SF3->F3_ENTRADA)+mv_par03+"01"+SF3->F3_SERIE+; 
			alltrim(SF3->F3_NFISCAL)+cCfop // SUBSTR(SF3->F3_CFO,1,4)
			cEmitente := "P" // P->Próprio; T->Terceiros(NF de compra?)
			cLinha += cEmitente


			cAuxVlr = alltrim(substr(transform(SF3->F3_VALCONT,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_VALCONT,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr

			cAuxVlr = alltrim(substr(transform(SF3->F3_BASEICM,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_BASEICM,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr
			cAuxVlr = alltrim(substr(transform(SF3->F3_VALICM,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_VALICM,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr

			cAuxVlr = alltrim(substr(transform(SF3->F3_ISENICM,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_ISENICM,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr
				
			// Cpo p/ outras
			cAuxVlr = alltrim(substr(transform(SF3->F3_OUTRICM,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_OUTRICM,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr
				
			cAuxVlr = alltrim(substr(transform(iif(SF3->F3_BASEICM > 0,SF3->F3_ALIQICM,0),"99.99"),1,2))
			cAuxVlr = replicate("0",2-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(iif(SF3->F3_BASEICM > 0,SF3->F3_ALIQICM,0),"99.99"),4,2)
			cLinha = cLinha+cAuxVlr
				
			cLinha = cLinha+"N"+chr(13)+chr(10)
			fwrite(nHandle,cLinha,len(cLinha))		
			nCont50 = nCont50+1
		endif
		dbselectarea("SF3")
		dbskip()
	enddo
				
	IncProc()
	// Reg. tipo 51
	nCont51 = 0
	dbselectarea("SF3")
	dbseek(xFilial("SF3")+dtos(dPer1),.t.)
	while !eof() .and. (F3_FILIAL == xFilial("SF3")) .and. ;
		(SF3->F3_ENTRADA >= dPer1) .and. (SF3->F3_ENTRADA <= dPer2)
		if (SF3->F3_ESTADO == mv_par03) .AND. EMPTY(SF3->F3_DTCANC) .and. ;
			(SUBSTR(SF3->F3_CFO,1,1) >= "5") // Somente Saídas, por enquanto

			cCgc = replicate("0",14)
			cInscr_est = space(14)
			dbselectarea("SF2")
			dbseek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE,.t.)
			cCgc = replicate("0",14)
			cInscr_est = space(14)
			if found()
				cCgc = ALLTRIM(SF2->F2_CGC)
				cInscr_est = ALLTRIM(SF2->F2_INSCR)
				cCgc = replicate("0",14-len(cCgc))+cCgc
				if empty(cInscr_est)
					cInscr_est = "ISENTO"
				endif
				cInscr_est = cInscr_est+space(14-len(cInscr_est))
			endif
			dbselectarea("SF3")
			cCfop = alltrim(SF3->F3_CFO)
			cCfop = replicate("0",4-len(cCfop))+cCfop
			cLinha = "51"+cCgc+cInscr_est+dtos(SF3->F3_ENTRADA)+mv_par03+SF3->F3_SERIE+; 
			alltrim(SF3->F3_NFISCAL)+cCfop //SUBSTR(SF3->F3_CFO,1,4)
			cAuxVlr = alltrim(substr(transform(SF3->F3_VALCONT,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_VALCONT,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr

			cAuxVlr = alltrim(substr(transform(SF3->F3_VALIPI,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_VALIPI,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr

			cAuxVlr = alltrim(substr(transform(SF3->F3_ISENIPI,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_ISENIPI,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr
				
			// Cpo p/ outras
			cAuxVlr = alltrim(substr(transform(SF3->F3_OUTRIPI,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_OUTRIPI,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr
				
			cLinha = cLinha+space(20) 
				
			cLinha = cLinha+"N"+chr(13)+chr(10)
			fwrite(nHandle,cLinha,len(cLinha))		
			nCont51 = nCont51+1
		endif
		dbselectarea("SF3")
		dbskip()
	enddo
				
	IncProc()
	// Reg. tipo 53
	nCont53 = 0
	dbselectarea("SF3")
	dbseek(xFilial("SF3")+dtos(dPer1),.t.)
	while !eof() .and. (SF3->F3_FILIAL == xFilial("SF3")) .and. ;
		(SF3->F3_ENTRADA >= dPer1) .and. (SF3->F3_ENTRADA <= dPer2)
		if (SF3->F3_ESTADO == mv_par03) .AND. EMPTY(SF3->F3_DTCANC) .and. ;
			(SF3->F3_BASERET > 0) .AND. (SUBSTR(SF3->F3_CFO,1,1) >= "5") // Somente Saídas, por enquanto

			cCgc = replicate("0",14)
			cInscr_est = space(14)
			dbselectarea("SF2")
			dbseek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE,.t.)
			if found()
				cCgc = ALLTRIM(SF2->F2_CGC)
				cInscr_est = ALLTRIM(SF2->F2_INSCR)
				cCgc = replicate("0",14-len(cCgc))+cCgc
				if empty(cInscr_est)
					cInscr_est = "ISENTO"
				endif
				cInscr_est = cInscr_est+space(14-len(cInscr_est))
			endif
			dbselectarea("SF3")
			cCfop = alltrim(SF3->F3_CFO)
			cCfop = replicate("0",4-len(cCfop))+cCfop
			cLinha = "53"+cCgc+cInscr_est+dtos(SF3->F3_ENTRADA)+mv_par03+"01"+SF3->F3_SERIE+; 
					alltrim(SF3->F3_NFISCAL)+cCfop // SUBSTR(SF3->F3_CFO,1,4)
			cEmitente := "P" //P->Próprio; T->Terceiros
			cLinha += cEmitente
			cAuxVlr = alltrim(substr(transform(SF3->F3_BASERET,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_BASERET,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr

			cAuxVlr = alltrim(substr(transform(SF3->F3_ICMSRET,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_ICMSRET,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr
				
			cAuxVlr = alltrim(substr(transform(SF3->F3_DESPESA,"99999999999.99"),1,11))
			cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
			cAuxVlr = cAuxVlr+substr(transform(SF3->F3_DESPESA,"99999999999.99"),13,2)
			cLinha = cLinha+cAuxVlr

			cLinha = cLinha+"N"
			cLinha = cLinha+space(30)+chr(13)+chr(10)
			fwrite(nHandle,cLinha,len(cLinha))		
			nCont53 = nCont53+1
		endif
		dbselectarea("SF3")
		dbskip()

	enddo

	IncProc()

	// Reg. tipo 54
	cQuery = "SELECT F2_PEDIDO,F2_CGC,F2_INSCR,F2_CLIENTE,F2_LOJA,F2_SERIE,F2_DOC,F2_EMISSAO,"+;
	"D2_CF,D2_ITEM,D2_COD,D2_QUANT,D2_TOTAL,D2_PRCVEN,D2_DESC,D2_BASEICM,D2_BRICMS,"+;
	"D2_VALIPI,D2_PICM,D2_POSIPI,D2_IPI,D2_DESCRI,D2_UM,D2_CLASFIS,D2_DESCZFR,"+;
	"SD2.R_E_C_N_O_ AS REG FROM "+RetSqlName("SF2")+" SF2 "+;
	"LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 ON "+;
	"(F2_FILIAL =D2_FILIAL) AND (F2_DOC = D2_DOC) AND (F2_SERIE = D2_SERIE) AND (SD2.D_E_L_E_T_ <> '*') WHERE "+;
	"(F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_EMISSAO BETWEEN '"+;
	dtos(dPer1)+"' AND '"+dtos(dPer2)+"') AND "+;
	"(F2_EST = '"+mv_par03+"') AND (SF2.D_E_L_E_T_ <> '*') "+;
	"ORDER BY "+;
	"F2_EMISSAO,F2_SERIE,F2_DOC,D2_ITEM"
	TCQUERY cQuery NEW ALIAS "TMP54"

	dbselectarea("SC5")
	dbsetorder(1)
	dbselectarea("SD2")
	dbsetorder(3)
	dbselectarea("SB1")
	dbsetorder(1)

	aTcq = {}    
	AADD(aTcq,{"per_inic","D",8,0})
	AADD(aTcq,{"per_final","D",8,0})
	AADD(aTcq,{"codpro","C",15,0})
	AADD(aTcq,{"cf","C",8,0})
	AADD(aTcq,{"DESCRICAO","C",40,0})
	AADD(aTcq,{"un","C",2,0})
	AADD(aTcq,{"cst","C",3,0})
	AADD(aTcq,{"ipi","N",5,2})
	AADD(aTcq,{"icms","N",5,2})
	
	/********************************************************************************************************************************/
    /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	//cArq = criatrab(aTcq,.t.)
    //cKey01  := "CODPRO+CF+UN"
    //cInd01  := SubStr(cArq, 1, 10)+"_1" //"SC"+SubStr(cNomArq, 8, 6)+"_1"
    //DbUseArea(.t., , cArq, cArq, .t., .f.)
    //DbCreateIndex(cInd01, cKey01, {||cKey01} )
    //DbClearIndex()
    //DbSetIndex(cInd01)
    oTempTable := FWTemporaryTable():New( cArq )
    oTemptable:SetFields( aTcq )
    oTempTable:AddIndex( "cInd01", { "CODPRO", "cf", "un" } )
    oTempTable:Create()
	/********************************************************************************************************************************/

//	use &cArq alias &cArq new
//	index on codpro+cf+un tag ind //+cst+transform(ipi,"99.99")+descricao+transform(icms,"99.99")
//	DbSetIndex(cArq)
	dbselectarea(cArq)
	DbSetOrder(1)


	nCont54 = 0
	cNfiscal = ""
	dbselectarea("SF3")
	nOrdem = IndexOrd()
	dbsetorder(4)   
	dbselectarea("TMP54")
	dbgotop()
	while !eof() // Somente Saídas, por enquanto
			cDescrProd := tmp54->d2_descri
			if empty(alltrim(tmp54->d2_descri))
				dbselectarea("SD2")
				dbgoto(tmp54->reg)
				if !eof() .and. !bof()
					dbselectarea("SB1")
					dbseek(xFilial("SB1")+tmp54->d2_cod)
					if found()
						dbselectarea("SD2")
					    RecLock("SD2",.F.)
					    SD2->D2_DESCRI := SB1->B1_DESC
					    msunlock()
					    cDescrProd := sb1->b1_desc
					 endif
				endif
			endif 				

			dbselectarea("SF3")
			dbseek(xFilial("SF3")+TMP54->F2_CLIENTE+TMP54->F2_LOJA+TMP54->F2_DOC+TMP54->F2_SERIE)
			if !found() .OR. (found() .and. (SUBSTR(SF3->F3_CFO,1,1) < "5"))
				dbselectarea("TMP54")
				dbskip()
				loop
			endif 
			      
			// Tirar itens de pedidos de compl. ICMS/IPI
			if !empty(tmp54->f2_pedido)
				dbselectarea("SC5")
				dbseek(xFilial("SC5")+tmp54->f2_pedido)
				if found() .and. (SC5->C5_TIPO $ "I_P")
					dbselectarea("TMP54")
					dbskip()
					loop
				endif
			endif

			cCgc = replicate("0",14)
			cInscr_est = space(14)
			cCgc = ALLTRIM(TMP54->F2_CGC)
			cInscr_est = ALLTRIM(TMP54->F2_INSCR)
			if empty(cInscr_est)
				cInscr_est = "ISENTO"
			endif
			cInscr_est = cInscr_est+space(14-len(cInscr_est))
			cCgc = replicate("0",14-len(cCgc))+cCgc
			cAuxLin = "54"+cCgc+"01"+TMP54->F2_SERIE+alltrim(TMP54->F2_DOC)
			cNcm := SUBSTR(alltrim(TMP54->D2_POSIPI),1,8)
			if empty(alltrim(cNcm))
				dbselectarea("SB1")
				dbseek(xFilial("SB1")+TMP54->D2_COD,.f.)
				if found()
					cNcm := substr(alltrim(B1_POSIPI),1,8)
				endif
			endif 
			if len(cNcm) < 8
				cNcm += replicate(" ",8-len(cNcm))
			endif 
			dbselectarea(cArq)
			dbseek(TMP54->D2_COD+cNcm+TMP54->D2_UM)
				//+TMP54->D2_CLASFIS+transform(TMP54->D2_IPI,"99.99")) 
				//+SUBSTR(TMP54->D2_DESCRI,1,40)+transform(TMP54->D2_PICM,"99.99"))
				if !found()
					RECLOCK(cArq,.t.)
				else
					reclock(cArq,.f.)
				endif
				cAux = substr(TMP54->F2_EMISSAO,7,2)+"/"+substr(TMP54->F2_EMISSAO,5,2)+"/"+substr(TMP54->F2_EMISSAO,1,4)
				if empty(per_inic)            
					replace per_inic with ctod(cAux)
				endif
				replace per_final with ctod(cAux)
				replace	codpro with TMP54->D2_COD           
				replace cf with cNcm //SUBSTR(TMP54->D2_POSIPI,1,8)
				replace descricao with cDescrProd
				replace un with TMP54->D2_UM
				replace cst with TMP54->D2_CLASFIS
				replace ipi with TMP54->D2_IPI
				//LGS#20200203 - Adequação do release 12.1.25
				//replace icms with GETMV("MV_ICMPAD")
				replace icms with _nICMPAD
				msunlock()

				cAuxVlr = CONVITEM(TMP54->D2_ITEM)
				cAuxVlr = replicate("0",3 - len(cAuxVlr))+cAuxVlr
				cAuxProd = alltrim(TMP54->D2_COD) 
				cAux = substr(alltrim(TMP54->D2_CF),1,4)
				if len(cAux) < 4
					cAux = replicate("0",4-len(cAux))+cAux
				endif 
				cLinha = cAuxLin+cAux+TMP54->D2_CLASFIS+cAuxVlr+cAuxProd+space(14-len(cAuxProd))

				cAuxVlr = alltrim(substr(transform(TMP54->D2_QUANT,"99999999.999"),1,8))
				cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
				cAuxVlr = cAuxVlr+substr(transform(TMP54->D2_QUANT,"99999999.999"),10,3)
				cLinha = cLinha+cAuxVlr

				cAuxVlr = alltrim(substr(transform(TMP54->D2_QUANT*TMP54->D2_PRCVEN,"9999999999.99"),1,10))
				cAuxVlr = replicate("0",10-len(cAuxVlr))+cAuxVlr
				cAuxVlr = cAuxVlr+substr(transform(TMP54->D2_QUANT*TMP54->D2_PRCVEN,"9999999999.99"),12,2)
				cLinha = cLinha+cAuxVlr
	
				cAuxVlr = alltrim(substr(transform(TMP54->D2_DESC,"9999999999.99"),1,10))
				cAuxVlr = replicate("0",10-len(cAuxVlr))+cAuxVlr
				cAuxVlr = cAuxVlr+substr(transform(TMP54->D2_DESC,"9999999999.99"),12,2)
				cLinha = cLinha+cAuxVlr
				// Na geração de NF a base icm fica zero em SF2 e valor # 0 em D2,o que é errado!!!
				if TMP54->D2_DESCZFR > 0
					nBaseIcm := 0
				else
					nBaseIcm := TMP54->D2_BASEICM
				endif
				cAuxVlr = alltrim(substr(transform(nBaseIcm,"9999999999.99"),1,10))
				cAuxVlr = replicate("0",10-len(cAuxVlr))+cAuxVlr
				cAuxVlr = cAuxVlr+substr(transform(nBaseIcm,"9999999999.99"),12,2)
						
				cLinha = cLinha+cAuxVlr
				
				cAuxVlr = alltrim(substr(transform(TMP54->D2_BRICMS,"9999999999.99"),1,10))
				cAuxVlr = replicate("0",10-len(cAuxVlr))+cAuxVlr
				cAuxVlr = cAuxVlr+substr(transform(TMP54->D2_BRICMS,"9999999999.99"),12,2)
				cLinha = cLinha+cAuxVlr

				
				cAuxVlr = alltrim(substr(transform(TMP54->D2_VALIPI,"9999999999.99"),1,10))
				cAuxVlr = replicate("0",10-len(cAuxVlr))+cAuxVlr
				cAuxVlr = cAuxVlr+substr(transform(TMP54->D2_VALIPI,"9999999999.99"),12,2)
				cLinha = cLinha+cAuxVlr

				cAuxVlr = alltrim(substr(transform(iif(nBaseIcm > 0,TMP54->D2_PICM,0),"99.99"),1,2))
				cAuxVlr = replicate("0",2-len(cAuxVlr))+cAuxVlr
				cAuxVlr = cAuxVlr+substr(transform(iif(nBaseIcm > 0,TMP54->D2_PICM,0),"99.99"),4,2)
				cLinha = cLinha+cAuxVlr
				cLinha = cLinha+chr(13)+chr(10)
				fwrite(nHandle,cLinha,len(cLinha))		
				nCont54 = nCont54+1
		

		dbselectarea("TMP54")
		dbskip()
	enddo

	dbselectarea("SF3")
	dbsetorder(nOrdem)

	dbselectarea("TMP54")
	dbclosearea()	
	IncProc()
	// Reg. tipo 55
	nCont55 = 0    
	cAux = substr(dtos(dPer1),5,2)+substr(dtos(dPer1),1,4) // Data de Ref.
	cQuery = "SELECT * FROM "+RetSqlName("SZ9")+" SZ9 WHERE "+;
	"(Z9_FILIAL = '"+xFilial("SZ9")+"') AND (Z9_UF = '"+mv_par03+"') AND "+;
	"(LEN(Z9_IEST) = 0) AND "+;  //Por enquanto,não consid. guias p/ Estados Conveniados
	"(SUBSTRING(Z9_REF,2,6) = '"+cAux+"') AND (D_E_L_E_T_ <> '*') ORDER BY Z9_EMISSAO"
	TCQUERY cQuery NEW ALIAS "TMP"
	dbSelectArea("TMP")
	dbGoTop()                    
	while !eof()
		cLinha = "55"+TMP->Z9_CNPJCPF
		cInscr_est = ALLTRIM(TMP->Z9_IEST) 
		if empty(cInscr_est)
			cInscr_est = "INEXISTENTE   "
		else                    
			cAux = ""
			for i = 1 to len(cInscr_est)
				if isdigit(substr(cInscr_est,i,1))
					cAux += substr(cInscr_est,i,1)
				endif
			next
			cInscr_est = cAux
			cInscr_est = cInscr_est+replicate(" ",14-len(cInscr_est))
		endif
		cLinha = cLinha+cInscr_est+tmp->z9_dtvenc+tmp->z9_est+tmp->z9_uf+;
		tmp->z9_bco         
		// Det. Agência
		cAux = substr(alltrim(tmp->z9_agencia),1,4)
		cAux = replicate("0",4-len(cAux))+cAux
		cLinha = cLinha+cAux
		// Det. Nro Autenticacao
		cAux = alltrim(tmp->z9_nroaute)
		cAux = cAux+space(20-len(cAux))
		cLinha = cLinha+cAux

		cAuxVlr = alltrim(substr(transform(TMP->Z9_TOTAREC,"99999999999.99"),1,11))
		cAuxVlr = replicate("0",11-len(cAuxVlr))+cAuxVlr
		cAuxVlr = cAuxVlr+substr(transform(TMP->Z9_TOTAREC,"99999999999.99"),13,2)
		cLinha = cLinha+cAuxVlr+tmp->z9_dtvenc+substr(tmp->z9_ref,2,6)+tmp->z9_conveni+chr(13)+chr(10)
		fwrite(nHandle,cLinha,len(cLinha))		
		nCont55 = nCont55+1
		dbselectarea("TMP")
		dbskip()
	enddo
		
	dbselectarea("TMP")
	dbclosearea()		

	IncProc()

	// Reg. tipo 75
	nCont75 = 0 
	dbselectarea(cArq)
	dbgotop()
	while !eof()
		cLinha = "75"+dtos(per_inic)+dtos(per_final)
		cAux = alltrim(codpro)
		cAux = cAux +replicate(" ",14-len(alltrim(codpro)))
		cLinha = cLinha+cAux+cf+alltrim(descricao)+;
		replicate(" ",53-len(alltrim(descricao)))+;
		un+space(4)  //+cst   
		/*
		cAux = alltrim(transform(ipi,"99.99"))
		cAux = replicate("0",5-len(cAux))+cAux
		cLinha = cLinha+substr(cAux,1,2)+substr(cAux,4,2)
			
		cAux = alltrim(transform(icms,"99.99"))
		cAux = replicate("0",5-len(cAux))+cAux
		cLinha = cLinha+substr(cAux,1,2)+substr(cAux,4,2)

		*/
		cAux = alltrim(transform(ipi,"999"))
		cAux = replicate("0",3-len(cAux))+cAux+"00"
		cLinha = cLinha+cAux
			
		cAux = alltrim(transform(icms,"99"))
		cAux = replicate("0",2-len(cAux))+cAux+"00"
		cLinha = cLinha+cAux
		
		cLinha = cLinha+"00000"+replicate("0",13)+chr(13)+chr(10)

		fwrite(nHandle,cLinha,len(cLinha))		
		nCont75 = nCont75+1
		skip
	enddo
		
	IncProc()
		
	// Reg. tipo 90
	nCont90 = 1

	cLinha = "90"+SM0->M0_CGC+SM0->M0_INSC
	if nCont50 > 0
		cAuxVlr = alltrim(str(nCont50,8))
		cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
		cLinha = cLinha+"50"+cAuxVlr
	endif
	if nCont51 > 0
		cAuxVlr = alltrim(str(nCont51,8))
		cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
		cLinha = cLinha+"51"+cAuxVlr
	endif
	if nCont53 > 0
		cAuxVlr = alltrim(str(nCont53,8))
		cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
		cLinha = cLinha+"53"+cAuxVlr
	endif
	if nCont54 > 0
		cAuxVlr = alltrim(str(nCont54,8))
		cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
		cLinha = cLinha+"54"+cAuxVlr
	endif
	if nCont55 > 0
		cAuxVlr = alltrim(str(nCont55,8))
		cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
		cLinha = cLinha+"55"+cAuxVlr
	endif
	if nCont75 > 0
		cAuxVlr = alltrim(str(nCont75,8))
		cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
		cLinha = cLinha+"75"+cAuxVlr
	endif
		

	nAux = nCont10+nCont11+nCont50+nCont51+nCont53+nCont54+nCont55+;
	nCont75+1

	cAuxVlr = alltrim(str(nAux,8))
	cAuxVlr = replicate("0",8-len(cAuxVlr))+cAuxVlr
	cLinha = cLinha+"99"+cAuxVlr

	cLinha = alltrim(cLinha)
	cLinha = cLinha+replicate(space(1),125-len(cLinha))+"1"+chr(13)+chr(10)
	fwrite(nHandle,cLinha,len(cLinha))		
	IncProc()
		
	FCLOSE(nHandle)
	dbSelectArea(cArq)
	dbCloseArea()
	oTempTable:Delete()
	/*LGS#20200203 - Adequação do release 12.1.25
	if file(cArq+".dbf")
		cAux = cArq+".dbf"
		delete file &cAux
	endif
	if file(cArq+".cdx")
		cAux = cArq+".cdx"
		delete file &cAux
	endif*/
endif

		


 	
Return

                     
//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//
// Funcao...: VldPerg                                             //
// Descricao: Verifica as perguntas, incluindo-as caso nao existam//       
// Uso......: BRFIS003                                            // 
//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//

Static Function VldPerg()  
Local i, j
Local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}
      
//+---------------------------------------------+                                                                            
//¦ Variaveis utilizadas para parametros        ¦
//¦ dPer1             // Da Data de Emissao  ¦
//¦ dPer2             // Reprocessamento(S/N)¦                          
//+---------------------------------------------+                          
cPerg := PADR(cPerg,10)
aAdd(aRegs,{cPerg,"01","Período de       ?","","","mv_ch1","D",08,0,0,"G","NaoVazio","mv_par01",""	  ,""   ,""	  ,"","",""	  ,""   ,""	  ,"","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate'       ?","","","mv_ch2","D",08,0,0,"G","NaoVazio","mv_par02",""	  ,""   ,""	  ,"","",""	  ,""   ,""	  ,"","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Estado    ?","","","mv_ch3","C",02,0,0,"G","NaoVazio","mv_par03",""	  ,""   ,""	  ,"","",""	  ,""   ,""	  ,"","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Local de Gravacao?","","","mv_ch4","C",40,0,0,"G","","mv_par04",""	  ,""   ,""	  ,"","",""	  ,""   ,""	  ,"","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
  If !dbSeek(cPerg+aRegs[i,2])
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

Static Function CONVITEM(cNroItem)
Local cDig,nAux,nNum
//Local cAux
cRet = cNroItem
if len(alltrim(cNroItem)) == 2
	cDig = substr(cNroItem,1,1)
	IF cDig < "A"
		cRet = cNroItem
	ELSE 
		nAux = (asc(cDig) - 55)
		nNum = nAux*36
		cDig = substr(cNroItem,2,1)
		if cDig >= 'A'
			nAux = (asc(cDig) - 55)
		else
			nAux = val(cDig)
		endif                
		nNum = nNum +  nAux - 260
		cRet = alltrim(str(nNum))
	ENDIF 
	cRet = replicate("0",3-len(cRet))+cRet
endif
return(cRet)
