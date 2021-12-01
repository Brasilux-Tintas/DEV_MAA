#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT091     Data....: 02/10/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Relacao de Borderôs de Despacho, desta  //
// cando volumes a cada pedido.
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Data de                             //
// mv_par02     // Data Ate                            //
// mv_par03     // Borderô Despacho De                 //
// mv_par04     // Borderô Despacho Até                //
/////////////////////////////////////////////////////////

User Function BRFAT091()     

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
     u_zcfga01( 'BRFAT091' ) //LGS#2021201 - Gravação de log de utilização da rotina
CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="G"
limite   :=220
titulo   :="BORDERO DE DESPACHO - ANALITICO DE VOLUMES"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Borderos de Despacho",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Borderos de Despacho",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT091"
cPerg    :="BRFT91"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT091"
nTipo    := 15
m_pag    := 01                                                                                                                                                  
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13       14        15        16       17        18        19         20       21
//           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "NRO NF     PEDIDO  DT. DESP DESTINATARIO                                 VALOR       PESO     VOL CIDADE                                         REDESPACHO     "
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 220     // Apenas Informativo
cString  := "SZA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 



ValidPerg()
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

#IFDEF WINDOWS
  RptStatus({|| RptDetail()})
  Return

Static Function RptDetail()
#ENDIF

Local cAux,nQtdeVol,lOutroF2,nPesoBruto
Local nQtdeNf // Qtde total de notas fiscais
Local nValorNF // Valor total da Nf
Local nSomaNF // Soma dos valores de todas as notas fiscais
Local nSomaVol // Qtde total de volumes
Local nSomaPesoB // Peso Bruto Total
Local _cAliasF2 // Conterá alias de sf2(Nf's saída) de outra empresa
Local _cAliasC5 // Conterá alias de sc5(pedidos) de outra empresa
Local _cAliasC6 // Conterá alias de sc6(itens de pedidos) de outra empresa
Local _cCodCid,lAbreF2,lAbreC5,_cCliente,cEmba,nAux,nCont,nQtde,lAbreC6
Local cAuxProd,lAchou,nVar,i,lEmbaemG1,aEmbaBord,cComp,nQtdComp, j




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


  cQuery = "SELECT * FROM "+U_VerSx2("SZA")+" SZA "
  cQuery = cQuery + " WHERE (SZA.ZA_FILIAL = '"+xFilial("SZA")+"')"
  cQuery = cQuery + " AND (D_E_L_E_T_ <> '*')"
  cQuery = cQuery + " AND ZA_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"'"
  cQuery = cQuery + " AND ZA_CODIGO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
  cQuery = cQuery + " ORDER BY ZA_CODIGO "
  TCQuery cQuery NEW ALIAS "TCQ" 
    
  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
  While ! EoF()         
	Cabec(titulo+" NRO "+TCQ->ZA_CODIGO,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	nLin := 08
	nQtdeNF = 0  // Qtde total de Notas Fiscais
	nSomaNF = 0 // Soma dos valores de todas as notas fiscais  
	nSomaVol = 0 // Qtde total de volumes
	nSomaPesoB = 0 // Peso Bruto Total
	aEmbaBord := {}
  	dbselectarea("SZB")
    dbseek(xFilial("SZB")+TCQ->ZA_CODIGO,.T.) 
    while !eof() .and. (SZB->ZB_CODIGO = TCQ->ZA_CODIGO)
	    If nlin >= 63
    		nLin+=1
    		@nLin,000 psay replicate("_",220)
	      	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  	nLin := 08    
	    Endif       
    	nLin+=1
    	nValorNf := 0         
    	cPedido := SZB->ZB_PEDIDO
    	lAbreF2 := .f.
   		lAbreC5 := .f.
   		lAbreC6 := .f.
    	if substr(cPedido,1,2) # substr(cnumemp,1,2)
    		lAbreF2 := .t.
			_cAliasF2 := "TMP"
			nCont := 0
			do while SELECT(_cAliasF2) # 0 
				nCont++
				_cAliasF2 := "TMP"+alltrim(str(nCont))
			enddo
			AbreF2(substr(cPedido,1,2),_cAliasF2)
    		lAbreC5 := .t.
			_cAliasC5 := "TMP"
			nCont := 0
			do while SELECT(_cAliasC5) # 0 
				nCont++
				_cAliasC5 := "TMP"+alltrim(str(nCont))
			enddo
			AbreC5(substr(cPedido,1,2),_cAliasC5)

    		lAbreC6 := .t.
			_cAliasC6 := "TMP"
			nCont := 0
			do while SELECT(_cAliasC6) # 0 
				nCont++
				_cAliasC6 := "TMP"+alltrim(str(nCont))
			enddo
			AbreC6(substr(cPedido,1,2),_cAliasC6)
		else
			_cAliasF2 = "SF2"
			_cAliasC5 = "SC5" 
			_cAliasC6 = "SC6"
		endif        


		//Cleber (18/10/10) -> Verificar se rel. de volumes estão coerentes antes     
		//U_VerificaVolumes(substr(cPedido,3,6)) //Cleber(27/08/2015) -> retirado

		_cCodCid := ""
		nQtdeVol := 0
		nPesoBruto := 0
		dbselectarea(_cAliasC5)
		dbseek(xFilial("SC5")+substr(cPedido,3,6))
		if found()            
			_cCliente := &(_cAliasC5+"->C5_CLIENTE")    
			nQtdeVol := &(_cAliasC5+"->C5_VOLUME1")
			nPesoBruto := &(_cAliasC5+"->C5_PBRUTO")
			_cAuxAprova := &(_cAliasC5+"->C5_APROVA")    
			if _cAuxAprova != "1"
				_cCodCid := "** PEDIDO NAO APROVADO!! ***
			else
				if C5_TIPO $ "D_B"
					dbselectarea("SA2")
					dbseek(xFilial("SA2")+_cCliente)
					if found()
						_cCodCid := alltrim(SA2->A2_MUN)+"-"+SA2->A2_EST
					endif
				else
					dbselectarea("SA1")
					dbseek(xFilial("SA1")+_cCliente)
					if found()
						_cCodCid := alltrim(SA1->A1_MUN)+"-"+SA1->A1_EST
					else
						_cCodCid := ""
					endif
				endif
			endif 
		endif
		nSomaVol += nQtdeVol 
		dbselectarea(_cAliasF2)
		dbseek(xFilial("SF2")+substr(cPedido,3,6),.f.)  
    	if dbseek(xFilial("SF2")+substr(cPedido,3,6),.f.) 
    		cAux = _cAliasF2+"->"+"F2_VALFAT"
    		nValorNf := &cAux
			cAux = "ALLTRIM("+_cAliasF2+"->F2_SERIE)+"+_cAliasF2+"->F2_DOC"
	    	@nLin,000 psay &cAux
			@nLin,011 psay cPedido picture "@R 99-999999"
	    	cAux = "SUBSTR("+_cAliasF2+"->F2_RAZAO,1,40)"
    		@nLin,027 psay &cAux   
    		cAux = _cAliasF2+"->"+"F2_VALFAT"
   			@nLin,068 psay &cAux picture "@E 999,999.99"
   			cAux = _cAliasF2+"->"+"F2_PBRUTO"           
   			nPesoBruto := &cAux
	    	@nLin,79 psay nPesoBruto picture "@E 999,999.99"
    		@nLin,90 psay nQtdeVol picture "@E 999,999"
    		@nLin,98 psay _cCodCid
			nQtdeNF++   
			nSomaNF += nValorNf
		else
			@nLin,011 psay cPedido picture "@R 99-999999" 
			@nLin,027 psay substr(alltrim(SZB->ZB_RAZAO),1,40)
			@nLin,068 psay "NAO FAT!!"
//	    	cAux = _cAliasF2+"->"+"F2_VOLUME1"	
	    	@nLin,79 psay nPesoBruto picture "@E 999,999.99"
    		@nLin,90 psay nQtdeVol picture "@E 999,999"
    		@nLin,98 psay _cCodCid
		endif         
		nSomaPesoB += nPesoBruto
 		cAux := &(_cAliasC5+"->C5_REDESP")
// 		_cAliasF2+"->"+"F2_REDESP"
   		if !empty(cAux)
	   		@nLin,145 psay cAux
	   		dbselectarea("SA4")
	   		dbseek(xFilial("SA4")+  cAux)
	   		if found()
	   			@nLin,150 psay "-"+SA4->A4_NOME+" - "+SA4->A4_TEL
	   		endif 
	   	endif 

/*			nLin+=1
			@nLin,000 psay "Embalagem "
			@nLin,025 psay "          Qtde."
			@nLin,042 psay "  Qtde. Volumes" */
                           //9,999.99999
            @ nLin,058 psay "Cubagem(M3)"
		
			dbselectarea("SZ5")
			dbsetorder(1) 
			dbselectarea("ZZO")
			dbseek(xFilial("ZZO")+substr(cPedido,3,6),.f.)			
			while !eof() .and. (xFilial("ZZO") == ZZO->ZZO_FILIAL) .and. (ZZO->ZZO_PEDIDO == substr(cPedido,3,6))			
			    If nlin >= 63
		    		nLin+=1
		    		@nLin,000 psay replicate("_",220)
			      	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		    	  	nLin := 08    
			    Endif       
				nLin+=1    
				dbselectarea("SZ5")
				dbseek(xFilial("SZ5")+ZZO->ZZO_EMBA)
				cEmba = iif(found(),SZ5->Z5_DESCR,"Diversos")
				@nLin,005 psay alltrim(ZZO->ZZO_EMBA)+"-"+alltrim(cEmba)
				@nLin,030 psay ZZO->ZZO_QTDE picture "@E 999,999,999,999"
				@nLin,047 psay ZZO->ZZO_QTDVOL picture "@E 999,999,999,999"
                @ nLin,058 psay ZZO->ZZO_CUBAGE picture "@E 9,999.99999"

				lAchou := .f.  
				for j := 1 to Len(aEmbaBord)
					if aEmbaBord[j][1] == ZZO->ZZO_EMBA //aEmba[i][1]
						lAchou = .t.
						nVar := j
					endif
				next
				if !lAchou
					//Tipo de embalagem correspondente armazenado 
					aadd(aEmbaBord,{ZZO->ZZO_EMBA,ZZO->ZZO_QTDE,ZZO->ZZO_QTDVOL,ZZO->ZZO_CUBAGE})
				else
					aEmbaBord[nVar][2] := aEmbaBord[nVar][2]+ZZO->ZZO_QTDE
					aEmbaBord[nVar][3] := aEmbaBord[nVar][3]+ZZO->ZZO_QTDVOL
					aEmbaBord[nVar][4] := aEmbaBord[nVar][4]+ZZO->ZZO_CUBAGE
				endif

				
				dbselectarea("ZZO")
				dbskip()
		    enddo 
			//********************************************************************************

			
		if lAbreF2
			dbselectarea(_cAliasF2)
			dbclosearea(_cAliasF2)
		endif                           
		if lAbreC5
			dbselectarea(_cAliasC5)
			dbclosearea(_cAliasC5)
		endif
		if lAbreC6
			dbselectarea(_cAliasC6)
			dbclosearea(_cAliasC6)
		endif
		dbselectarea("SZB")
		dbskip()
	enddo

   	If nlin >= 58
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
   	Endif        
   	 
   	nLin++
   	@nLin,000 psay replicate("_",220)
   	nLin++
   	@nLin,000 psay "Qtde de Notas: "+alltrim(transform(nQtdeNf,"@E 999,999"))
   	@nLin,054  psay "TOTAIS => "
   	@nLin,065 psay nSomaNf picture "@E 9,999,999.99"
	@nLin,79 psay nSomaPesoB picture "@E 999,999.99"
   	@nLin,090 psay nSomaVol picture "@E 999,999"
   	nLin++
   	@nLin,000 psay replicate("_",220)

	if nLin >= 59
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 08
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
	      	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  	nLin := 08    
	    Endif       
		nLin+=1    
		dbselectarea("SZ5")
		dbseek(xFilial("SZ5")+aEmbaBord[i][1])
		cEmba = iif(found(),SZ5->Z5_DESCR,"Diversos")
		
		@nLin,000 psay alltrim(aEmbaBord[i][1])+"-"+alltrim(cEmba)
		nQtdeVol := aEmbaBord[i][3]
		@nLin,025 psay aEmbaBord[i][2] picture "@E 999,999,999,999"
		@nLin,042 psay nQtdeVol picture "@E 999,999,999,999"
		@nLin,058 psay aEmbaBord[i][4] picture "@E 9,999.99999"
	    
    next

   	dbselectarea("TCQ")
   	dbskip()
   	IncRegua()

 End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TCQ")
dbCloseArea("TCQ")

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa  : VALIDPERG   Autor:  Marcos Cesar     
Data      : 28/01/02
Descricao : Grava Perguntas
/*/

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
AADD(aRegs,{cPerg,"01","Data De  ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Ate ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
dbSelectArea(_sAlias)
Return

Static Function AbreF2(_cNumemp,_cAliasF2)
Local _cTab,_cIndice
	_cTab := "SF2"+_cNumemp+"0"
	_cIndice := _cTab+"7"
    USE &_cTab ALIAS &_cAliasF2 INDEX &_cIndice SHARED NEW VIA "TOPCONN"
return                

Static Function AbreC5(_cNumemp,_cAliasC5)
Local _cTab,_cIndice
	_cTab := "SC5"+_cNumemp+"0"
	_cIndice := _cTab+"1"
    USE &_cTab ALIAS &_cAliasC5 INDEX &_cIndice SHARED NEW VIA "TOPCONN"
return                

Static Function AbreC6(_cNumemp,_cAliasC6)
Local _cTab,_cIndice
	_cTab := "SC6"+_cNumemp+"0"
	_cIndice := _cTab+"1"
    USE &_cTab ALIAS &_cAliasC6 INDEX &_cIndice SHARED NEW VIA "TOPCONN"
return                
