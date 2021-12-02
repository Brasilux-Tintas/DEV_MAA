#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BRTLV001 ¦ Autor ¦ 	                    ¦ Data ¦ 21/10/03 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressão de orçamento do TeleVendas                       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Brasilux                         	                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦

/*/

/////////////////////////////////////////////////////////
// Variaveis utilizadas para parametros                //
// mv_par01     // Do orcamento                        //
// mv_par02     // Ate o orcamento                     //
/////////////////////////////////////////////////////////

User Function BRTLV001()
Private CbTxt    := ""
Private CbCont   := 0
Private nOrdem   := 0
Private Alfa     := 0
Private Z        := 0
Private M        := 0
Private tamanho  := "P"
Private limite   := 80
Private titulo   := "ORCAMENTO DE VENDAS"
Private cDesc1   := PADC("Relatorio de Orcamento de Vendas",74)
Private cDesc2   := PADC(" ",74)
Private cDesc3   := PADC(" ",74)
Private cCabec   := PADC("ORCAMENTO DE VENDAS",27)
Private cCabPro  := ""
Private cNatureza:= ""
Private aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
Private nomeprog := "BRTLV001"
Private cPerg    := "TLV001"
Private nLastKey := 0
Private lContinua:= .T.
Private _nLin    := 90
Private nCol     := 60
Private wnrel    := "BRTLV001"
Private nTipo    := 18
Private m_pag    := 01
Private cCabec1  := ""
Private cCabec2  := ""
Private cCabec3  := ""
Private cxCabec1 := "                      O R Ç A M E N T O   D E   V E N D A S                    "
Private cxCabec2 := ""
Private cxEmp    := Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
Private cxData   := "Televendas - "+DTOC(dDataBase)
Private cxCabec3 := cxEmp+space(79-(Len(cxEmp)+Len(cxData)))+cxData
Private nTamNf   := 83     // Apenas Informativo
Private cString  := "SUB"
     u_zcfga01( 'BRTLV001' ) //LGS#2021201 - Gravação de log de utilização da rotina
ValidPerg()
Pergunte("TLV001",.F.)

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
  Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
  Return
Endif

Processa({|| TLV001_1()}, Titulo)

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ TLV001_1 ¦ Autor ¦ Marcos Cesar Vieira   ¦ Data ¦ 21/10/03 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressão de Orçamento do Televendas                       ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Brasilux                          	                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦

/*/

Static Function TLV001_1()
Local nValorIpi    := 0
Local nSubstrib    := 0
Local nAliqInt     := 0
Local nAliqSol	  := 0
Local cAux
//Local cAux1
Local nPerIcm      := 0     
Local nBaseSubst   := 0
Local nBaseIcms    := 0
Local cUn          := ""
Local nAuxIpi      := 0
Local nLucroST     := 0
Local nAuxIcms     := 0
Local cEmpresa, i
//Local cUf,cComp,nQtdEmba
Private cOrcamento
Private nPercSubst
Private nDescZFR   := 0 // Desc. Zona Franca
Private cAcentos := "€ú‡úŽú"+chr(65533)+"ú…ú†úƒú ú"+chr(65533)+"úˆú‚ú¡ú“ú”ú¢ú™ú£ú"
Private cAcSubst := "C,c,A~A'a`a~a^a'E'e^e'i'o^o~o'O~U'"
Private aCustomText := {}
Private lAbortPrint := .f.
Private cQuery := ""
Private lPulou := .f.
Private cCodigo := ""
Private cLoja:= ""
Private cVend:= ""
Private cTransp:= ""
Private cRedesp := ""

aadd(aCustomText,cxCabec1)
aadd(aCustomText,cxCabec2)
aadd(aCustomText,cxCabec3)
cEmpresa := SubStr(cnumemp,1,2)

cQuery := cQuery + "SELECT UA.UA_NUM  AS NUMERO, UA.UA_EMISSAO AS EMISSAO , UA.UA_CLIENTE AS CLIENTE       , UA.UA_LOJA   AS LOJA      , UA.UA_CONDPG  AS PAGAMENTO , UA.UA_DTLIM  AS VALIDADE, UB.UB_TES AS TPSAIDA, "
cQuery := cQuery + "       UB.UB_ITEM AS ITEM  , UB.UB_PRODUTO AS PRODUTO , UB.UB_DESCRI  AS DESCRICAO     , UB.UB_UM     AS UNIDADE   , UB.UB_QUANT   AS QUANTIDADE, UB.UB_VRUNIT AS UNITARIO, UB.UB_VLRITEM AS TOTAL, "
cQuery := cQuery + "       A1.A1_TIPO AS TIPO  , UA.UA_VEND    AS VENDEDOR, UA.UA_TRANSP  AS TRANSPORTADORA, UA.UA_TRANSP AS REDESPACHO, UB.UB_DTENTRE AS ENTREGA   , UA.UA_DESCNT AS CONTATO "
cQuery := cQuery + "FROM SUA"+cEmpresa+"0 UA "
cQuery := cQuery + "INNER JOIN SUB"+cEmpresa+"0 UB ON UB.UB_FILIAL = UA.UA_FILIAL AND UB.UB_NUM = UA.UA_NUM "
cQuery := cQuery + "INNER JOIN "+RetSqlName("SA1")+" A1 ON A1.A1_FILIAL = '' AND A1.A1_COD = UA.UA_CLIENTE AND A1.A1_LOJA = UA.UA_LOJA "
cQuery := cQuery + "WHERE UA.D_E_L_E_T_ = '' "
cQuery := cQuery + "AND UB.D_E_L_E_T_ = '' "
cQuery := cQuery + "AND A1.D_E_L_E_T_ = '' "
cQuery := cQuery + "AND UA.UA_FILIAL = '"	+xFilial("SUA")+"' "
cQuery := cQuery + "AND UA.UA_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery := cQuery + "ORDER BY UB.UB_NUM, UB.UB_ITEM "
cQuery  := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TMP", .F.)  


dbSelectArea("SF4")        // TES
dbSetOrder(1)
dbselectarea("SB1")
dbsetorder(1)
dbSelectArea("SZ5")
dbsetorder(1)
dbSelectArea("SZ8") // Estados Subst. Trib.
dbsetorder(1)       // Z8_FILIAL+Z8_EST+Z8_TIPOCLI
       
nLin := 0
dbSelectArea("TMP")
dbgotop()
       
ProcRegua(Reccount())
While !EoF() .and. lContinua
  cValidade  := SUBSTR(TMP->VALIDADE,7,2)+'/'+SUBSTR(TMP->VALIDADE,5,2)+'/'+SUBSTR(TMP->VALIDADE,3,2)
  cEntrega   := SUBSTR(TMP->ENTREGA,7,2)+'/'+SUBSTR(TMP->ENTREGA,5,2)+'/'+SUBSTR(TMP->ENTREGA,3,2)
  cPagamen   := TMP->PAGAMENTO
  nVol       := 0
  cCodigo    := TMP->CLIENTE
  cLoja      := TMP->LOJA
  cVend      := TMP->VENDEDOR
  cTransp    := TMP->TRANSPORTADORA
  cRedesp    := TMP->REDESPACHO
  cOrcamento := TMP->NUMERO
  nPag       := 1
  nValorPed  := 0 // Valor Total do Orcamento
  nPesoLiquTotal := 0
  nPesoBrutTotal := 0   
  nValorIpi      := 0 // Guarda o valor total do IPI
  nSubstrib      := 0 // Guarda o valor total da Subst. Trib.
  nDescZFR       := 0 // Vlr do Desc. 7% Zona Franca
  
  If lAbortPrint
    @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
    lContinua := .F.
    Exit
  Endif
  
  TLV001_2()
             
  // Det. da Aliq. ICM interna do estado e Alíquto de ICMS Próprio
  DbSelectArea("SA1")
  DbSetOrder(1)
  DbSeek(xFilial("SA1")+cCodigo+cLoja,.t.)
  nAliqInt := U_Aliqinterna(SA1->A1_EST)
  nPerIcm  := AliqIcms('N','S',TMP->TIPO)/100 // Alíquota de ICMS

  DbSelectArea("TMP")
  While !Eof() .and. (TMP->NUMERO == cOrcamento) .AND. lContinua
    If lAbortPrint
      @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
      lContinua := .F.
      Exit
    Endif    

    DbSelectArea("SB1")
    DbSeek(xFilial("SB1")+TMP->PRODUTO)
		
    // Cálculo da Subst. Trib. e IPi
    DbSelectArea("SF4")
    DbSeek(xFilial("SF4")+TMP->TPSAIDA)
    If found()

		nAliqSol := nAliqInt + iif((SA1->A1_EST = "RJ") .AND. (SF4->F4_ISEFECP <> '1'),0.01,0) // Consid. 1% fundo pobreza RJ

      nAuxIpi := 0
      If SF4->F4_IPI == "S"
        nAuxIpi := TMP->TOTAL * (SB1->B1_IPI/100)
        nValorIpi += nAuxIpi
      Endif
      If SF4->F4_INCSOL == "S"
        nBaseIcms = TMP->TOTAL + iif(SF4->F4_INCIDE == "S",nAuxIpi,0)
        nAuxIcms   := nBaseIcms * nPerIcm
        nLucroST   := (1+(nPercSubst/100))
        nBaseSubst := (TMP->TOTAL + nAuxIpi)*nLucroST*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1)
        nSubstrib  += (nBaseSubst*nAliqSol) - nAuxIcms
      Endif
    Endif

    cUn := SB1->B1_UM  // Guarda Unidade de Medida, Inicialmente
    nPesoLiqu := 0
    nPesobrut := 0
    //Det. dos Pesos Liq./Bruto e da Qtde de Volumes
    If Len(alltrim(TMP->PRODUTO)) == 12
      DbSelectArea("SZ5")
      DbSeek(xFilial("SZ5")+substr(TMP->PRODUTO,11,2))
      If found()   
        cUn := "("+ALLTRIM(SZ5->Z5_DESCR)+")" // Guardar a descrição da Embalagem
      Endif
      DbSelectArea("SB1")
      nRegB1 = recno()
      DbSeek(xFilial("SB1")+ substr(TMP->PRODUTO,1,10)+"00")
      If found()
        nPesoliqu = TMP->QUANTIDADE*SZ5->Z5_VOLUME*SB1->B1_PESOESP
      Endif
      nPesobrut = npesoliqu+(SZ5->Z5_PESO*TMP->QUANTIDADE)

    Else
      	npesoliqu := (SB1->B1_PESO * TMP->QUANTIDADE)
      	nPesoBrut := nPesoLiqu
    Endif
    nPesoLiquTotal := nPesoLiquTotal + nPesoLiqu
    nPesoBrutTotal := nPesoBrutTotal + nPesoBrut
    nLin+=1
    @ nLin,000 psay ALLTRIM(TMP->PRODUTO)
    @ nLin,013 psay substr(TMP->DESCRICAO,1,30)
    @ nLin,044 psay TMP->QUANTIDADE picture "@E 9999"
    @ nLin,049 psay substr(cUn,1,20)
    @ nLin,070 psay TMP->UNITARIO picture "@E 999,999.99"
    nValorPed += TMP->QUANTIDADE * TMP->UNITARIO
    If nLin >= 59
      TLV001_3()
	  TLV001_2()
    Endif
    nLin += 1
    @ nLin,000 psay Replicate("—",80)
    If nLin >= 59
      TLV001_3()
	  TLV001_2()
    Endif
    DbSelectArea("TMP")
    DbSkip()
    IncProc()
  Enddo
  If (SA1->A1_CALCSUF != "N") .and. !empty(SA1->A1_SUFRAMA)
    nDescZFR := nValorPed*0.07
  Endif
  nLin+=1
//  @ nLin,000 psay "VOLUMES: "+Transform(nVol,"@E 9,999")
  @ nLin,050 psay "TOTAL DOS PRODUTOS: "+Transform((nValorPed - nDescZFR),"@E 999,999.99")
  nLin += 1
  @ nLin,000 psay "IPI: "+Transform(nValorIpi,"@E 99,999.99")
  @ nLin,016 psay "SUBST. TRIB.: "+Transform(nSubstrib,"@E 99,999.99")
  @ nLin,050 psay "TOTAL DO ORCAMENTO: "+Transform((nValorPed+nValorIpi+nSubstrib-nDescZFR),"@E 999,999.99")
  If nLin >= 59
    TLV001_3()
    TLV001_2()
  Endif
  nLin += 1
  @ nLin,000 psay Replicate("—",80)
  nLin += 1
  @ nLin,000 psay "PAGAMENTO: "+cPagamen+"-"+SUBSTR(SE4->E4_DESCRI,1,28)
  @ nLin,044 psay "VALIDADE: "+cValidade
  @ nLin,063 psay "ENTREGA: "+cEntrega
  nLin += 1
  If nLin >= 59
    TLV001_3()
    TLV001_2()
  Endif
             
  cMens = ""
  If nDescZFR > 0
    cMens = cMens+iif(!empty(cMens),"**","")+"Desc. Zona Franca(7%)"+;
    alltrim(transform(nDescZFR,"999,999.99"))
  Endif
  nQtdeLin := 0
  If !empty(cMens)
    nQtdeLin = len(cMens)/80
    If int(nQtdeLin) < nQtdeLin
      nQtdeLin = int(len(cMens)/80)+1
    Endif
  Endif
  For i = 1 to nQtdeLin
    cAux = substr(cMens,i*80 - 79,80)
    nLin += 1
    @ nLin,000 psay cAux
    If nLin >= 59
      TLV001_3()
      nLin := 1
    Endif
  Next        
  @ nLin,000 psay Replicate("—",80)
  If nLin >= 59
    TLV001_3()
    nLin := 1
  Endif
  nLin += 2
  If nLin >= 59
    TLV001_3()
    nLin := 1
    lPulou := .t.
  Endif                        
  If lPulou 
    nLin := nLin + 10
  Else
    nLin := nLin + 4
  Endif
  @ nLin, 054 psay "__________________________"
  nLin += 1
  @ nLin, 054 psay "     Depto. de Vendas     "
  nLin += 1
  @ nLin, 054 psay " Brasilux Tintas Técnicas "
  nLin += 1
  nAux = 60 - nLin
  nLin = nLin+nAux
  @ nLin,000 psay Replicate("—",80)
  nLin = nLin+1
  @ nlin,000 PSAY "Pagina: "
  @ nLin,008 psay nPag picture "99"
  @ nLin,015 psay " http://www.brasilux.com.br    -    comercial@brasilux.com.br"
  nLin = nLin+1
  @ nLin,000 psay Replicate("—",80)
  nPag += 1
  DbSelectArea("TMP")
Enddo
DbSelectArea("TMP")
DbCloseArea()

Set Device To Screen
If aReturn[5] == 1
  Set Printer TO
  dbcommitAll()
  ourspool(wnrel)
Endif
Return



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ TLV001_2   ¦ Autor ¦ Marcos Cesar Vieira ¦ Data ¦21/10/03  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Cabeçalho do relatório.                                    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function TLV001_2()
dbSelectArea("SUA") // Cabecalho dos Orcamentos
dbSetorder(1)
dbSeek(xFilial("SUA")+cOrcamento,.F.)     

dbselectarea("SE4") // Cond. Pagamento
dbsetorder(1)
dbseek(xFilial("SE4")+TMP->PAGAMENTO)

nLin := 1
nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo,aCustomText)
nLin := nLin + 1
@ nLin,000 psay "ORÇAMENTO.....: "+SubStr(cnumemp,1,2)+"-"+cOrcamento
nPercSubst := 0        // Perc. de Lucro p/ Subst. Tributária
If (TMP->TIPO $ "D_B")
  DbSelectArea("SA2")
  DbSetorder(1)
  DbSeek(xFilial("SA2")+cCodigo,.F.)
  If found()
    dbselectarea("SZ8")
    dbseek(xFilial("SZ8")+SA2->A2_EST+SA2->A2_CLAS)
    If found()
      nPercSubst := SZ8->Z8_PERC
    Endif
  Endif
Else
  DbSelectArea("SA1")
  DbSetorder(1)
  DbSeek(xFilial("SA1")+cCodigo,.F.)
  If Found()
    DbSelectArea("SZ8")
    DbSeek(xFilial("SZ8")+SA1->A1_EST+SA1->A1_CLAS)
    If found()
      nPercSubst := SZ8->Z8_PERC
    Endif
  Endif
Endif
nLin += 1
@ nLin,000 psay "CLIENTE.......: "+cCodigo+"-"+SA1->A1_NOME
nLin += 1
@ nLin,000 psay "CONTATO.......: "+Alltrim(TMP->CONTATO)
nLin += 1
@ nLin,000 psay "FONE..........: "+TRIM(SA1->A1_DDD)+'-'+TRIM(SA1->A1_TEL)
@ nLin,040 psay "CIDADE: "+AllTrim(SA1->A1_MUN)+"-"+SA1->A1_EST
nLin += 1
@ nLin,000 psay "ENDEREÇO......: "+ALLTRIM(SUBSTR(SA1->A1_END,1,40))+" - "+SA1->A1_BAIRRO
nLin += 1
DbSelectArea("SA3")
DbSetOrder(1)
DbSeek(xFilial("SA3")+cVend,.t.)
If Found()
  @ nLin,000 psay "REPRESENTANTE.: "+cVend+"-"+SA3->A3_NOME
Endif
nLin += 1
DbSelectArea("SA4")
DbSetOrder(1)
DbSeek(xFilial("SA4")+cTransp,.t.)
If found()
  @ nLin,000 psay "TRANSPORTADORA: "+cTransp+"-"+SA4->A4_NOME
Endif
nLin += 1
DbSeek(xFilial("SA4")+cRedesp)
If found()
  @ nLin,000 psay "REDESPACHO....: "+cRedesp+"-"+ALLTRIM(SA4->A4_NOME)+" Região: "+alltrim(SA4->A4_REGIAO)
Endif
nLin += 1
@ nLin,000 psay replicate("=",80)
nLin += 1
@ nLin,000 psay "   CODIGO              DESCRICAO            QTD.       UNIDADE        PRECO UNIT."
nLin += 1
@ nLin,000 psay replicate("=",80)
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ TLV001_3   ¦ Autor ¦ Marcos Cesar Vieira ¦ Data ¦21/09/03  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Imprime linhas do relatorio.                               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/


Static Function TLV001_3()
nAux = 60 - nLin
nLin = nLin + nAux
@ nLin,000 psay Replicate("—",80)
nLin = nLin + 1
@ nlin,000 PSAY "Pagina: "
@ nLin,008 psay nPag picture "99"
nLin = nLin + 1
@ nLin,000 psay Replicate("—",80)
nPag += 1
Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ VALIDPERG  ¦ Autor ¦ Marcos Cesar Vieira ¦ Data ¦21/10/03  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Perguntas/Parametros.                                      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidPerg()
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Orcamento de  ?","","","mv_ch1" ,"C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Orcamento Ate ?","","","mv_ch2" ,"C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
