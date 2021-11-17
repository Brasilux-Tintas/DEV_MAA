#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFAT078 บ Autor ณ Luํs Gustavo       บ Data ณ  15/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Orcamento de Vendas.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/////////////////////////////////////////////////////////
// Variaveis utilizadas para parametros                //
// mv_par01     // Do orcamento                        //
// mv_par02     // Ate o orcamento                     //
/////////////////////////////////////////////////////////

User Function BRFAT078()
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
     Private nomeprog := "BRFAT078"
     Private cPerg    := "FAT078"
     Private nLastKey := 0
     Private lContinua:= .T.
     Private _nLin    := 90
     Private nCol     := 60
     Private wnrel    := "BRFAT078"
     Private nTipo    := 18
     Private m_pag    := 01
     Private cCabec1  := ""
     Private cCabec2  := ""
     Private cCabec3  := ""
     Private cxCabec1 := "                      O R ว A M E N T O   D E   V E N D A S                    "
     //                   12345678901234567890123456789012345678901234567890123456789012345678901234567890
     //                            1         2         3         4         5         6         7         8    
     Private cxCabec2 := ""
     Private cxEmp    := Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
     Private cxData   := DTOC(dDataBase)
     Private cxCabec3 := cxEmp+space(79-(Len(cxEmp)+Len(cxData)))+cxData
     Private nTamNf   := 83     // Apenas Informativo
     Private cString  := "SCK"

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Envia controle para a funcao SETPRINT                        ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     
     cPRWRotina := funname()
   
       
     If !u_VldAcesso(funname())
     	MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      	Return 
	 Endif 
	
     ValidPerg()
     Pergunte("FAT078",.F.)

     wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

     If nLastKey == 27
        Return
     Endif
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Verifica Posicao do Formulario na Impressora                 ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Inicio do Processamento do Relatorio                         ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Processa({|| FAT0781()}, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FAT0781  บ Autor ณ Luํs Gustavo       บ Data ณ  15/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de Orcamento de Vendas.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0781()
       Local nValorIpi    := 0
       Local nSubstrib    := 0
       Local nAliqInt     := 0
       Local nAliqSol	  := 0
       Local cAux
       Local cAux1
       Local nPerIcm      := 0     
       Local nBaseSubst   := 0
       Local nBaseIcms    := 0
       Local cUn          := ""
       Local nAuxIpi      := 0
       Local nLucroST     := 0
       Local nAuxIcms     := 0
       Local cEmpresa
       Local cUf,lEmbaemG1,cDescrEmba,cComp,nQtdEmba
       Loca i, nLoop
       Private cOrcamento
       Private nPercSubst
       Private nDescZFR   := 0 // Desc. Zona Franca
       Private cAcentos := "€๚๚๚"+chr(65533)+"๚…๚๚๚ ๚"+chr(65533)+"๚๚๚ก๚“๚”๚ข๚๚ฃ๚"
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

       cQuery := cQuery + "SELECT CJ.CJ_NUM AS NUMERO, CJ.CJ_EMISSAO AS EMISSAO, CJ.CJ_CLIENTE AS CLIENTE, CJ.CJ_LOJA AS LOJA, CJ.CJ_CONDPAG AS PAGAMENTO, CJ.CJ_VALIDA AS VALIDADE, CK.CK_TES AS TPSAIDA, "
       cQuery := cQuery + "       CK.CK_ITEM AS ITEM, CK.CK_PRODUTO AS PRODUTO, CK.CK_DESCRI AS DESCRICAO, CK.CK_UM AS UNIDADE, CK.CK_QTDVEN AS QUANTIDADE, CK.CK_PRCVEN AS UNITARIO, CK.CK_VALOR AS TOTAL, "
       cQuery := cQuery + "       A1.A1_TIPO AS TIPO, CJ.CJ_VEND1 AS VENDEDOR, CJ.CJ_TRANSP AS TRANSPORTADORA, CJ.CJ_REDESP AS REDESPACHO, CK.CK_ENTREG AS ENTREGA, CJ.CJ_OBSORC AS OBS "
       cQuery := cQuery + "FROM "+RetSqlName("SCJ")+" CJ WITH(NOLOCK) "
       cQuery := cQuery + "INNER JOIN "+RetSqlName("SCK")+" CK WITH(NOLOCK) ON CK.CK_FILIAL = CJ.CJ_FILIAL AND CK.CK_NUM = CJ.CJ_NUM "
       cQuery := cQuery + "INNER JOIN "+RetSqlName("SA1")+" A1 WITH(NOLOCK) ON A1.A1_FILIAL = '' AND A1.A1_COD = CJ.CJ_CLIENTE AND A1.A1_LOJA = CJ.CJ_LOJA "
       cQuery := cQuery + "WHERE CJ.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND CK.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND A1.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND CJ.CJ_FILIAL = '"+xFilial("SCJ")+"' "
       cQuery := cQuery + "  AND CJ.CJ_NUM    BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       //cQuery := cQuery + "  AND CJ.CJ_STATUS = 'A' "
       cQuery := cQuery + "ORDER BY CK.CK_NUM, SUBSTRING(CK.CK_PRODUTO,4,2), CK.CK_PRODUTO "
       
       TCQuery cQuery NEW ALIAS "TCQ"

       dbSelectArea("SF4")        // TES
       dbSetOrder(1)

       dbselectarea("SB1")
       dbsetorder(1)

       dbSelectArea("SZ5")
       dbsetorder(1)

       dbSelectArea("SZ8") // Estados Subst. Trib.
       dbsetorder(1)       // Z8_FILIAL+Z8_EST+Z8_TIPOCLI
       
       nLin := 0
       dbSelectArea("TCQ")
       dbgotop()
       
       ProcRegua(Reccount())
       While !EoF() .and. lContinua
             cValidade := SUBSTR(TCQ->VALIDADE,7,2)+'/'+SUBSTR(TCQ->VALIDADE,5,2)+'/'+SUBSTR(TCQ->VALIDADE,3,2)
             cEntrega  := SUBSTR(TCQ->ENTREGA,7,2)+'/'+SUBSTR(TCQ->ENTREGA,5,2)+'/'+SUBSTR(TCQ->ENTREGA,3,2)
             cPagamen  := TCQ->PAGAMENTO
             cCodigo   := TCQ->CLIENTE
             cLoja     := TCQ->LOJA
             cVend     := TCQ->VENDEDOR
             cTransp   := TCQ->TRANSPORTADORA
             cRedesp   := TCQ->REDESPACHO

             cOrcamento     := TCQ->NUMERO
             nPag            = 1
             nValorPed      := 0 // Valor Total do Orcamento
             nPesoLiquTotal := 0
             nPesoBrutTotal := 0   
             nValorIpi      := 0   // Guarda o valor total do IPI
             nSubstrib      := 0 // Guarda o valor total da Subst. Trib.
             nDescZFR       := 0 //Vlr do Desc. 7% Zona Franca
             If lAbortPrint
                @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
                lContinua := .F.
                Exit
             Endif
             FAT0782()
             
             // Det. da Aliq. ICM interna do estado e Alํquto de ICMS Pr๓prio
             DbSelectArea("SA1")
             DbSetOrder(1)
             DbSeek(xFilial("SA1")+cCodigo+cLoja,.t.)
             nAliqInt := U_Aliqinterna(SA1->A1_EST)
             nPerIcm  := AliqIcms('N','S',TCQ->TIPO)/100 // Alํquota de ICMS

             DbSelectArea("TCQ")
             While !Eof() .and. (TCQ->NUMERO == cOrcamento) .AND. lContinua
                   If lAbortPrint
                      @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
                      lContinua := .F.
                      Exit
                   Endif    

                   //**************************************************************************
                   DbSelectArea("SB1")
                   DbSeek(xFilial("SB1")+TCQ->PRODUTO)
		
                   // Cแlculo da Subst. Trib. e IPi
                   DbSelectArea("SF4")
                   DbSeek(xFilial("SF4")+TCQ->TPSAIDA)
                   If found()
	 					nAliqSol := nAliqInt + iif((SA1->A1_EST = "RJ") .AND. (SF4->F4_ISEFECP <> '1'),0.01,0) // Consid. 1% fundo pobreza RJ

                      nAuxIpi := 0
                      If SF4->F4_IPI == "S"
                         nAuxIpi := TCQ->TOTAL * (SB1->B1_IPI/100)
                         nValorIpi += nAuxIpi
                      Endif
                      If SF4->F4_INCSOL == "S"
                         nBaseIcms = TCQ->TOTAL + iif(SF4->F4_INCIDE == "S",nAuxIpi,0)
                         nAuxIcms   := nBaseIcms * nPerIcm                               
                         nLucroST   := (1+(nPercSubst/100))
                         nBaseSubst := (TCQ->TOTAL + nAuxIpi)*nLucroST
                         nSubstrib  += (nBaseSubst*nAliqSol)*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1) - nAuxIcms
                      Endif
                   Endif

                   cUn := SB1->B1_UM  // Guarda Unidade de Medida, Inicialmente
                   nPesoLiqu = 0
                   nPesobrut = 0
                   //Det. dos Pesos Liq./Bruto
                   If Len(alltrim(TCQ->PRODUTO)) == 12
                      DbSelectArea("SZ5")
                      DbSeek(xFilial("SZ5")+substr(TCQ->PRODUTO,11,2))
                      If found()   
                         cUn := "("+ALLTRIM(SZ5->Z5_DESCR)+")" // Guardar a descri็ใo da Embalagem
                      Endif
                      DbSelectArea("SB1")
                      nRegB1 = recno()
                      DbSeek(xFilial("SB1")+ substr(TCQ->PRODUTO,1,10)+"00")
                      If found()
                         nPesoliqu = TCQ->QUANTIDADE*SZ5->Z5_VOLUME*SB1->B1_PESOESP
                      Endif
                      nPesobrut = npesoliqu+(SZ5->Z5_PESO*TCQ->QUANTIDADE)

                      DbSelectArea("SB1")
                      DbGoTo(nRegB1)
                   Else
                      npesoliqu = (SB1->B1_PESO * TCQ->QUANTIDADE)
                      nPesoBrut = nPesoLiqu
                   Endif
                   nPesoLiquTotal := nPesoLiquTotal + nPesoLiqu
                   nPesoBrutTotal := nPesoBrutTotal + nPesoBrut
                   //*******************************************************************
                   nLin+=1
                   @ nLin,000 psay ALLTRIM(TCQ->PRODUTO)
                   @ nLin,013 psay substr(TCQ->DESCRICAO,1,30)
                   @ nLin,044 psay TCQ->QUANTIDADE picture "@E 9999"
                   @ nLin,049 psay substr(cUn,1,20)
                   @ nLin,070 psay TCQ->UNITARIO picture "@E 999,999.99"
                   nValorPed += TCQ->QUANTIDADE * TCQ->UNITARIO
                   If nLin >= 59
                      FAT0783()
			          FAT0782()
                   Endif
                   nLin += 1
                   //@ nLin,000 psay Replicate("—",80)
                   @ nLin, 000 psay __PrtThinLine()
                   If nLin >= 59
                      FAT0783()
                      FAT0782()
                   Endif
                   DbSelectArea("TCQ")
                   DbSkip()
                   IncProc()
             Enddo
             If (SA1->A1_CALCSUF != "N") .and. !empty(SA1->A1_SUFRAMA)
                nDescZFR := nValorPed*0.07
             Endif
             nLin+=1
             @ nLin,050 psay "TOTAL DOS PRODUTOS: "+Transform((nValorPed - nDescZFR),"@E 999,999.99")
             nLin += 1
             //               0         1         2         3         4         5         6         7         8
             //               012345678901234567890123456789012345678901234567890123456789012345678901234567890
             //               VOLUMES: 9,999                                    TOTAL DOS PRODUTOS: 999,999.99
             //               IPI: 99,999.99  SUBST. TRIB.: 99,999.99           TOTAL DO ORCAMENTO: 999,999.99
             //               PAGAMENTO: 999-XXXXXXXXXXXXXXXXXXXXXXXXXXXX VALIDADE: 99/99/99 ENTREGA: 99/99/99
             //               BRASILUX TINTAS TECNICAS LTDA.
             //               RUA ITALO FERREIRA, 300 - CENTRO
             //               MATรO - SP - CEP: 15990-670 Cx. Postal 222
             //               CGC.: 72.770.878/0001-17                               __________________________
             //               I.E.: 441.029.187.111 Fone: (16)283-7000                    Depto. de Vendas
             //               www.brasilux.com.br  comercial@brasilux.com.br          Brasilux Tintas T้cnicas
             @ nLin,000 psay "IPI: "+Transform(nValorIpi,"@E 99,999.99")
             @ nLin,016 psay "SUBST. TRIB.: "+Transform(nSubstrib,"@E 99,999.99")
             @ nLin,050 psay "TOTAL DO ORCAMENTO: "+Transform((nValorPed+nValorIpi+nSubstrib-nDescZFR),"@E 999,999.99")
             If nLin >= 59
                FAT0783()
                FAT0782()
             Endif
             nLin += 1
             //@ nLin,000 psay Replicate("—",80)
             @ nLin, 000 psay __PrtThinLine()
             nLin += 1
             @ nLin,000 psay "PAGAMENTO: "+cPagamen+"-"+SUBSTR(SE4->E4_DESCRI,1,28)
             @ nLin,044 psay "VALIDADE: "+cValidade
             // @ nLin,063 psay "ENTREGA: "+cEntrega   // Tirado em 29/03/04 por Marcos
                                                       // a pedido de Concei็ใo
             nLin += 1
             If nLin >= 59
                FAT0783()
                FAT0782()
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
                    FAT0783()
                    nLin := 1
                 Endif
             Next        
             //@ nLin,000 psay Replicate("—",80)
             @ nLin, 000 psay __PrtThinLine()
             If nLin >= 59
                FAT0783()
                nLin := 1
             Endif
             nLin += 2
             If nLin >= 59
                FAT0783()
                nLin := 1
                lPulou := .t.
             Endif
             DbSelectArea("SCJ")
             DbSetOrder(1)
             DbSeek(xFilial("SCJ")+cOrcamento,.t.)
             If Found()
                cMemo   := MSMM(,80,,SCJ->CJ_OBSORC,,,"SCJ",)
                nMCount := MlCount( cMemo, 80 )
                If !Empty(nMCount)
                   For nLoop := 1 To nMCount
                       cLinha := MemoLine( cMemo, 80, nLoop )
                       @ nlin,000 PSAY StrTran( cLinha, Chr(13)+Chr(10), "" )
                       nlin++
                   Next nLoop 
                Endif
             Endif
             If nLin >= 59
                FAT0783()
                nLin := 1
                lPulou := .t.
             Endif
             If lPulou 
                nLin := nLin + 10
             Else
                nLin := nLin + 4
             Endif
             @ 060, 057 psay "__________________________"
             nLin += 1
             @ 061, 057 psay "     Depto. de Vendas     "
             nLin += 1
             @ 062, 057 psay " Brasilux Tintas T้cnicas "
             nLin += 1
             //               0         1         2         3         4        5 
             //               01234567890123456789012345678901234567890124567890123456
             //               | BRASILUX TINTAS TECNICAS LTDA.                 |
             //               |RUA ITALO FERREIRA, 300 - CENTRO
             //               |MATรO - SP - CEP: 15990-670 Cx. Postal 222
             //               |CGC.: 72.770.878/0001-17                               __________________________
             //               |I.E.: 441.029.187.111 Fone: (16)283-7000               xxxxxDepto. de Vendasxxxxx
             //               | www.brasilux.com.br  comercial@brasilux.com.br |       Brasilux Tintas T้cnicas
             nAux = 60 - nLin
             nLin = nLin+nAux
             //@ nLin,000 psay Replicate("—",80)
             @ 063, 000 psay __PrtThinLine()
             nLin = nLin+1
             @ 064,000 PSAY "Pagina: "
             @ 064,008 psay nPag picture "99"
             @ 064,015 psay " http://www.brasilux.com.br    -    comercial@brasilux.com.br"
             nLin = nLin+1
             //@ nLin,000 psay Replicate("—",80)
             @ 065, 000 psay __PrtThinLine()
             nPag += 1
             DbSelectArea("TCQ")
       Enddo
       
       DbSelectArea("TCQ")
       DbCloseArea("TCQ")

       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          dbcommitAll()
          ourspool(wnrel)
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  FAT0782 บ Autor ณ Luis Gustavo       บ Data ณ  15/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime cabecalho do relatorio.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0782()
       dbSelectArea("SCJ") // Cabecalho dos Orcamentos
       dbSetorder(1)
       dbSeek(xFilial("SCJ")+cOrcamento,.F.)
       
       dbselectarea("SE4") // Cond. Pagamento
       dbsetorder(1)
       dbseek(xFilial("SE4")+TCQ->PAGAMENTO)

       nLin = 1
       nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo,aCustomText)
       nLin := nLin + 1
       @ nLin,000 psay "ORวAMENTO.....: "+SubStr(cnumemp,1,2)+"-"+cOrcamento
       nPercSubst := 0        // Perc. de Lucro p/ Subst. Tributแria
       If (TCQ->TIPO $ "D_B")
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
       @ nLin,000 psay "CONTATO.......: "+Alltrim(SA1->A1_CONTATO)
       nLin += 1
       @ nLin,000 psay "FONE..........: "+TRIM(SA1->A1_DDD)+'-'+SA1->A1_TEL
       @ nLin,040 psay "CIDADE: "+AllTrim(SA1->A1_MUN)+"-"+SA1->A1_EST
       nLin += 1
       @ nLin,000 psay "ENDEREวO......: "+ALLTRIM(SUBSTR(SA1->A1_END,1,40))+" - "+SA1->A1_BAIRRO
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
          @ nLin,000 psay "REDESPACHO....: "+cRedesp+"-"+ALLTRIM(SA4->A4_NOME)+" Regiใo: "+alltrim(SA4->A4_REGIAO)
       Endif
       nLin += 1
       @ nLin,000 psay replicate("=",80)
       nLin += 1
       @ nLin,000 psay "   CODIGO              DESCRICAO            QTD.       UNIDADE        PRECO UNIT."
       nLin += 1
       @ nLin,000 psay replicate("=",80)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  FAT0783 บ Autor ณ Luis Gustavo       บ Data ณ  15/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime linhas do relatorio.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0783()
       nAux = 60 - nLin
       nLin = nLin + nAux
       
       //@ nLin,000 psay Replicate("—",80)
       @ nLin, 000 psay __PrtThinLine()
       nLin = nLin + 1
       @ nlin,000 PSAY "Pagina: "
       @ nLin,008 psay nPag picture "99"
       nLin = nLin + 1
       //@ nLin,000 psay Replicate("—",80)
       @ nLin, 000 psay __PrtThinLine()
       nPag += 1
Return