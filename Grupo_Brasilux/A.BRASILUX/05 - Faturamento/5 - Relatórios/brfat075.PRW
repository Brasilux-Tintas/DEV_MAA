#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   
#INCLUDE "PROTHEUS.CH"
/////////////////////////////////////////////////////////
// Funçào....: BRFAT075     Data....: 02/10/02         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Relacao de Borderôs de Despacho	 	   //
// Uso.......: Todas as Empresas 					   //
/////////////////////////////////////////////////////////  
// Variaveis utilizadas para parametros                //         
// mv_par01     // Data de                             //
// mv_par02     // Data Ate                            //
// mv_par03     // Borderô Despacho De                 //
// mv_par04     // Borderô Despacho Até                //
/////////////////////////////////////////////////////////

User Function BRFAT075()     
     SetPrvt("CBTXT, CBCONT, NORDEM, ALFA, Z, M")
     SetPrvt("TAMANHO, LIMITE, TITULO, CDESC1, CDESC2, CDESC3")
     SetPrvt("CCABEC, CCABPRO, CNATUREZA, ARETURN, NOMEPROG, CPERG")
     SetPrvt("NLASTKEY, LCONTINUA, NLIN, NCOL, WNREL, NTIPO")
     SetPrvt("M_PAG, CCABEC1, CCABEC2, CCABEC3, NTAMNF, CSTRING")
     SetPrvt("CQUERY, _TOTALG, _TOTFIN, _TOTESTE, _TOTESTS, LIMPEST")
     SetPrvt("LIMPFIN, _DTGERAD, _NRAVAR, _TOTAL, _SALIAS, AREGS")

     CbTxt    :=""
     CbCont   :=0
     nOrdem   :=0
     Alfa     :=0
     Z        :=0
     M        :=0
     tamanho  :="G"
     limite   :=220
     titulo   :="BORDERO DE DESPACHO"
     cDesc1   :=PADC("Este programa ira emitir o Rel. de Borderos de Despacho",74)
     cDesc2   :=""
     cDesc3   :=PADC(" ",74)
     cCabec   :=PADC("Rel. Borderos de Despacho",27)
     cCabPro  :=""
     cNatureza:=""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog :="BRFAT075"
     cPerg    :="BRFT75"
     nLastKey := 0
     lContinua:=.T.
     nLin    := 0
     nCol     := 0
     wnrel    := "BRFAT075"
     nTipo    := 15
     m_pag    := 01    

    if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
                                                                                                                                              
//																					999,999.99  999,999.9  99,999
     //               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13       14        15        16       17        18        19         20       21
     //           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     cCabec1  := "BORD     NRO NF  PEDIDO SPRAY DESTINATARIO                              VLR NF     VLR PEDIDO     PESO     VOL CIDADE                        CNPJ                   REDESPACHO     "
     cCabec2  := ""   
     cCabec3  := ""
     nTamNf   := 220     // Apenas Informativo
     cString  := "SZA"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //ValidPerg()
     Pergunte("BRFT75",.F.)   

     wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     
     RptStatus({|| RptDetail()})
     
Return

Static Function RptDetail()

     Local cAux,nQtdeVol,nPesoBruto
     Local nQtdeNf // Qtde total de notas fiscais
	 Local nQtdePD // Qtde total de Pedido de Venda
     Local nValorNF // Valor total da Nf
     Local nSomaNF // Soma dos valores de todas as notas fiscais
	 Local nSomaPD // Soma dos valores de todos pedidos
     Local nSomaVol // Qtde total de volumes
     Local nSomaPesoB // Peso Bruto Total
     Local _cAliasF2 // Conterá alias de sf2(Nf's saída) de outra empresa
     Local _cAliasC5 // Conterá alias de sc5(pedidos) de outra empresa
     Local _cAliasC6 // Conterá alias de sc6(itens de pedidos) de outra empresa
     Local _cCodCid,_cCliente,cEmba,_cCnpj
     Local lAchou,i,aEmbaBord,nVar,cBord, j, cQuery
	 Private oPr := ReturnPrtObj() // imprimir código de barras usando o setprint (sem o tmsprinter)  




dbselectarea("SF2")
DbOrderNickName("SF2001")
dbselectarea("SZB")
dbsetorder(1)
dbselectarea("SA1")
dbsetorder(1)
dbselectarea("SA2")
dbsetorder(1)
dbselectarea("SC5")
dbsetorder(1)
dbselectarea("SC6")
dbsetorder(1)
dbselectarea("SA4")
dbsetorder(1)
dbSelectArea("SG1")
dbSetorder(1)                
dbSelectArea("SB1")
dbSetorder(1)                
dbSelectArea("ZZO")
dbSetorder(1)                

  cQuery := " "
  cQuery += " SELECT ZA_CODIGO,ZB_PEDIDO,ZB_RAZAO,C5_NUM FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "
  cQuery += " LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON (SZA.D_E_L_E_T_ <> '*') AND (ZA_FILIAL = ZB_FILIAL) AND (ZA_CODIGO = ZB_CODIGO) "
  cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = SUBSTRING(ZB_PEDIDO,3,6)) "
  cQuery += " WHERE (SZB.ZB_FILIAL = '"+xFilial("SZB")+"')"
  cQuery += " AND (SZB.D_E_L_E_T_ <> '*')"
  cQuery += " AND (ZA_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"')"
  cQuery += " AND (ZB_CODIGO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"')"
  IF mv_par05 == 1
	  cQuery += " ORDER BY ZB_CODIGO,ZB_PEDIDO "
  ELSE
	  cQuery += " ORDER BY ZB_CODIGO,C5_REDESP "
  ENDIF 
  TCQuery cQuery NEW ALIAS "TCQ" 
    
  dbSelectArea("TCQ")
  
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  While ! EoF()         
//	Cabec(titulo+" NRO "+TCQ->ZA_CODIGO,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	nLin := 90
	nQtdeNF = 0  // Qtde total de Notas Fiscais
	nQtdePD = 0  // Qtde total de Pedido de Vendas
	nSomaNF = 0 // Soma dos valores de todas as notas fiscais  
	nSomaPD  = 0 // Soma dos valores de todos os pedidos
	nSomaVol = 0 // Qtde total de volumes
	nSomaPesoB = 0 // Peso Bruto Total
	aEmbaBord := {}
	cBord := TCQ->ZA_CODIGO
  	dbselectarea("TCQ")
    while !eof() .and. (TCQ->ZA_CODIGO == cBord)
	    If nlin >= 63
    		nLin+=1
    		@nLin,000 psay replicate("_",220)
	      	Cabec(titulo+" NRO "+cBord,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  	nLin := 08    
		    //MSBAR3("CODE128", 0.4, 8.9 ,cBord,oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
	    Endif       
    	nLin+=1
    	nValorNf := 0         
    	cPedido := TCQ->ZB_PEDIDO

			_cAliasF2 = "SF2"
			_cAliasC5 = "SC5" 
			_cAliasC6 = "SC6"

		//Cleber (18/10/10) -> Verificar se rel. de volumes estão coerentes antes     
		//U_VerificaVolumes(substr(cPedido,3,6)) //Cleber (27/08/15) ->Retirado


		_cCodCid := ""
		nQtdeVol := 0
		nPesoBruto := 0
		dbselectarea(_cAliasC5)
		dbseek(xFilial("SC5")+substr(cPedido,3,6))
		if found()            
			_cCliente := &(_cAliasC5+"->C5_CLIENTE")    
			nQtdeVol := &(_cAliasC5+"->C5_VOLUME1")
			_cAuxAprova := &(_cAliasC5+"->C5_APROVA")    
			if _cAuxAprova != "1"
				_cCodCid := "** PEDIDO NAO APROVADO!! ***
			else
				if C5_TIPO $ "D_B"
					dbselectarea("SA2")
					dbseek(xFilial("SA2")+_cCliente)
					if found()
						_cCodCid := alltrim(SA2->A2_MUN)+"-"+SA2->A2_EST
						If Len(SA2->A2_CGC) > 11
			            	_cCnpj := SA2->A2_CGC 
			            EndIf
			  		endif
				else
					dbselectarea("SA1")
					dbseek(xFilial("SA1")+_cCliente)
					if found()
						_cCodCid := alltrim(SA1->A1_MUN)+"-"+SA1->A1_EST
			            If Len(SA1->A1_CGC) > 11
			            	_cCnpj := (SA1->A1_CGC) 
			            EndIf
			 		else
						_cCodCid := ""
						_cCnpj :=""
					endif
				endif
			endif 
		endif
		coluna := 15
		nSomaVol += nQtdeVol 
		dbselectarea("SF2")
		dbseek(xFilial("SF2")+substr(cPedido,3,6),.f.)  
		lFaturado = found()
//    	if dbseek(xFilial("SF2")+substr(cPedido,3,6),.f.) 

    		nValorNf := iif(lFaturado,SF2->F2_VALFAT,0)
			cAux = iif(lFaturado,ALLTRIM(SF2->F2_SERIE)+"-"+ALLTRIM(SF2->F2_DOC)," ") //"ALLTRIM("+_cAliasF2+"->F2_SERIE)+"+_cAliasF2+"->F2_DOC"
	    	@nLin,000 psay cBord
	    	@nLin,008 psay cAux
			@nLin,019 psay PADC(cPedido,6)//+iif(!lFaturado,"*"," ") 
	    	@nLin,025 psay Iif(u_fTemSpray(Alltrim(cPedido)), '*','   ')   
    		@nLin,028 psay SUBSTR(iif(lFaturado,SF2->F2_RAZAO,TCQ->ZB_RAZAO),1,38)

   			//@nLin,067 psay IIF(lFaturado,nValorNf,SC5->C5_VLRDUP) picture "@E 999,999.99"

			@nLin,067 psay nValorNf picture "@E 999,999.99"   /* valor nf */

			@nLin,067+coluna psay SC5->C5_VLRDUP picture "@E 999,999.99"   /* valor pedido */

   			nPesoBruto := iif(lFaturado,SF2->F2_PBRUTO,	SC5->C5_PBRUTO) 
	    	@nLin,078+coluna psay nPesoBruto picture "@E 999,999.9"
    		@nLin,089+coluna psay nQtdeVol picture "@E 99,999"
    		@nLin,096+coluna psay substr((_cCodCid),1,29)
			@nLin,126+coluna psay _cCnpj picture "@R 99.999.999/9999-99"
			nQtdeNF += iif(lFaturado,1,0)   

			IF !EMPTY(TCQ->C5_NUM)
				nQtdePD++	
			endif

			nSomaNF += nValorNf
			nSomaPD += SC5->C5_VLRDUP
/*		else
			@nLin,010 psay cPedido picture "@R 99-999999" 
	    	@nLin,021 psay Iif(u_fTemSpray(Alltrim(cPedido)), '*','')   
			@nLin,024 psay substr(alltrim(TCQ->ZB_RAZAO),1,40)
			@nLin,066 psay "NAO FAT!!"
//	    	cAux = _cAliasF2+"->"+"F2_VOLUME1"	
	    	@nLin,77 psay nPesoBruto picture "@E 999,999.99"
    		@nLin,87 psay nQtdeVol picture "@E 999,999"
    		@nLin,95 psay substr((_cCodCid),1,29)
    		@nLin,127 psay _cCnpj picture "@R 99.999.999/9999-99"
		endif         
*/    		
		nSomaPesoB += nPesoBruto
   		if !empty(SC5->C5_REDESP)
	   		dbselectarea("SA4")
	   		dbseek(xFilial("SA4")+SC5->C5_REDESP)
	   		if found()
		   		@nLin,149+coluna psay SC5->C5_REDESP+"-"+SA4->A4_NOME+" - "+SUBSTR(SA4->A4_DDD,1,4)+" "+SA4->A4_TEL
	   		endif 
	   	endif
	   	cAuxTra := SC5->C5_TRANSP
//	   	@ nLin,210 psay cAuxTra              // desativado impressão do transporte p/ caber cnpj - 09/09/11
		dbselectarea("ZZO")
		dbseek(xFilial("ZZO")+substr(cPedido,3,6))
		while !eof() .and. (xFilial("ZZO") == ZZO->ZZO_FILIAL) .and. (ZZO->ZZO_PEDIDO == substr(cPedido,3,6))
			lAchou := .f.  
			for j := 1 to Len(aEmbaBord)
				if aEmbaBord[j][1] == ZZO->ZZO_EMBA
					lAchou = .t.
					nVar := j
				endif
			next
			if !lAchou
				//Tipo de embalagem correspondente armazenado em B1_RELCAT1
				aadd(aEmbaBord,{ZZO->ZZO_EMBA,ZZO->ZZO_QTDE,ZZO->ZZO_QTDVOL,ZZO->ZZO_CUBAGE})
			else
				aEmbaBord[nVar][2] := aEmbaBord[nVar][2]+ZZO->ZZO_QTDE
				aEmbaBord[nVar][3] := aEmbaBord[nVar][3]+ZZO->ZZO_QTDVOL
				aEmbaBord[nVar][4] := aEmbaBord[nVar][4]+ZZO->ZZO_CUBAGE
			endif                      
			dbselectarea("ZZO")
			dbskip()
		enddo 
			
		dbselectarea("TCQ")
		dbskip()
	enddo

   	If nlin >= 63
   		Cabec(titulo+" NRO "+cBord,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
	    //MSBAR3("CODE128", 0.4, 8.9 ,cBord,oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
   	Endif        
   	 
   	nLin++
   	@nLin,000 psay replicate("_",220)
   	nLin++
   	@nLin,000 psay "Qtde de Notas: "+alltrim(transform(nQtdeNf,"@E 999,999"))

	/* incluido por nelieder em  07/03/2022 */   	
	@nLin,020 psay "Qtde de Pedidos: "+alltrim(transform(nQtdePD,"@E 999,999"))



   	@nLin,057  psay "TOTAIS => "
   	@nLin,066  psay nSomaNf picture "@E 9,999,999.99" /* TOTAL NF*/
    @nLin,080  psay nSomaPD picture "@E 9,999,999.99" /* TOTAL PEDIDO */
	@nLin,093  psay nSomaPesoB picture "@E 999,999.9" /* TOTAL PESO */
   	@nLin,101  psay nSomaVol picture "@E 999,999" /* TOTAL VOLUME */
   	nLin++
   	@nLin,000 psay replicate("_",220)

	if nLin >= 63
   		Cabec(titulo+" NRO "+cBord,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
	    //MSBAR3("CODE128", 0.4, 8.9 ,cBord,oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
	endif

	nLin+=1
	@nLin,000 psay "Embalagem "
	@nLin,025 psay "          Qtde."
	@nLin,042 psay "  Qtde. Volumes"
                   //9,999.99999
	@ nLin,058 psay "Cubagem(M3)"

	dbselectarea("SZ5")
	dbsetorder(1) 
	aEmbaBord := ASORT(aEmbaBord,,, { |x, y| x[1] < y[1] })	
    for i := 1 to len(aEmbaBord)
	    If nlin >= 63
    		nLin+=1
    		@nLin,000 psay replicate("_",220)
	      	Cabec(titulo+" NRO "+cBord,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  	nLin := 08    
		    //MSBAR3("CODE128", 0.4, 8.9 ,cBord,oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
	    Endif       
		nLin+=1    
		dbselectarea("SZ5")
		dbseek(xFilial("SZ5")+aEmbaBord[i][1])
		cEmba = iif(found(),SZ5->Z5_DESCR,"Diversos")
		
		@nLin,000 psay alltrim(aEmbaBord[i][1])+"-"+alltrim(cEmba)
		@nLin,025 psay aEmbaBord[i][2] picture "@E 999,999,999,999"
		@nLin,042 psay aEmbaBord[i][3] picture "@E 999,999,999,999"
		@nLin,058 psay aEmbaBord[i][4] picture "@E 9,999.99999"
	    
    next

   	dbselectarea("TCQ")
   	IncRegua()

 End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TCQ")
dbCloseArea()

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

MS_FLUSH()

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa  : VALIDPERG   Autor:  Marcos Cesar     
Data      : 28/01/02
Descricao : Grava Perguntas
/*/
/* DESABILITADA RELEASE 12.1.25
Static Function ValidPerg()     
Local _sAlias,i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01     // Data de                             //
// mv_par02     // Data Ate                            //
// mv_par03     // Bordero desp. de                  //
// mv_par04     // Bordero despacho ate             //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data De  ?"       ,"","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Ate ?"       ,"","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Bord Despacho de?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Bord Despach Ate?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
PutSX1(cPerg, "05"  ,  "Ordem de     ?", "Ordem de     ?", "Ordem de     ?", "mv_ch5", "N",  1, 0, 1, "C"  , "","","","","mv_par05","Bord+Pedido", "Bord+Pedido", "Bord+Pedido"   , ""   , "Bord+TRANSP", "Bord+TRANSP", "Bord+TRANSP", , , , "", "", "",  "", "", "",{},{},{}, "" )

dbSelectArea(_sAlias)
Return

*/
