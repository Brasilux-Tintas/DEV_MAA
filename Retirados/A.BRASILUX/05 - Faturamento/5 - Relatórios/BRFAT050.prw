#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT050     Data....: 29.01.02         //
// Autor.....: Edmar                                   //
// Ult. Alteraçao: Cleber Orati Domingues => 23/02/02  //
// Descriçao.: Relatorio Destinos de pedidos Aprovados //
// Uso.......: Brasilux/Resina                         //
//                                                     //
/////////////////////////////////////////////////////////
//                                                     //
// Variaveis utilizadas para parametros                //
//                                                     //
// mv_par01     // Data Aprovacao de                   //
// mv_par02     // Data Aprovacao ate                  //
// mv_par03     // Borderô de                          //
// mv_par04     // Bordero Até                         //
// mv_par05     // Dt. Bordero de                      //
// mv_par06     // Dt. Bordero Ate                     //
// mv_par07     // Order (Localizacao ou Produto)      //
// mv_par08     // Sintético/Analítico                 //
/////////////////////////////////////////////////////////


User Function BRFAT050()
     
     Private nTipo, Tamanho, cPerg, titulo, MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, ALFA, Z, M, LIMITE,CDESC1,CDESC2,CDESC3
     Private CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG, NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING
     
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

     Alfa     := 0
     Z        := 0
     MV_PAR07 := 1
     mv_par08 := 1
     M        := 0
     tamanho  := "P"
     limite   := 80
     titulo   := "DEST(CLIENTE)PED APROVADOS"
     cDesc1   := PADC("Este programa ira emitir o Rel. de Pedidos Aprovados",74)
     cDesc2   := PADC("relacionando o seu destino(cliente)",74)
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Rel. destino(cliente) de pedidos aprovados",27)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRFAT050"
     cPerg    := "BRFT50"
     nLastKey := 0
     lContinua:= .T.
     _nLin    := 90
     nCol     := 60
     wnrel    := "BRFAT050"
     nTipo    := 18
     m_pag    := 01
     nTamNf   := 132     // Apenas Informativo
     cString  := "SC9"

     //ValidPerg()
     Pergunte(cPerg, .F.)
     //                   0        1          2        3           4         5       6        7           8
     //               0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
     cCabec1  := ""
     cCabec2  := ""
     cCabec3  := ""
     Tamanho  := "P"
     nTipo     = 18
     titulo    = titulo+iif(mv_par07 == 1,"(QUADRANTE)","(PRODUTO)") 
     wnrel    := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

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
    
    Local nQtdeProd := 0, cEmpresa, _aCampos,  nTotVol, cProduto, cDescrEmba
    Local cQuery := ""
    Private oTempTable
    Private oTempTable1
    
	dbselectarea("SC6")
	dbsetorder(1)
       //             0         1         2         3         4         5         6         7         8
       //             0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
       If mv_par08 == 1
          cCabec1 := "PRODUTO                                      UN "
          cCabec2 := "PEDIDO     CLIENTE                                  REG/REGTR  QTDE LOCALIZ."
       Else
          cCabec1 := "PRODUTO                                      UN             LOCALIZ         QTDE"
          cCabec2 := "Borderos de "+mv_par03+" ate' "+mv_par04
       Endif 
       cCabec3 := ""

       If mv_par07 = 1
          cIndTrb := ' SB2.B2_LOCALIZ, A.C9_PRODUTO, A.EMPRESA, A.C9_PEDIDO, A.C9_CLIENTE, A.C9_LOJA '
       ElseIf mv_par07 = 2
          cIndTrb := ' A.C9_PRODUTO, SB2.B2_LOCALIZ, A.EMPRESA, A.C9_PEDIDO, A.C9_CLIENTE, A.C9_LOJA '
       Else
          cIndTrb := ' SUBSTRING(A.C9_PRODUTO, 06, 05), SUBSTRING(A.C9_PRODUTO, 04, 02), SUBSTRING(A.C9_PRODUTO, 01, 03), SB2.B2_LOCALIZ, A.EMPRESA, A.C9_PEDIDO, A.C9_CLIENTE, A.C9_LOJA '
       Endif

       cEmpresa = SubStr(cnumemp,1,2)
       cQuery := ""
       cQuery += "SELECT '"+SubStr(cnumemp,1,2)+"' AS EMPRESA, "
       cQuery += " C9_PEDIDO,C9_CLIENTE,C9_QTDLIB,C9_PRODUTO,C9_ITEM, "
       cQuery += " C9_SEQUEN,C9_FLGIMP,C9_LOCAL, "
       cQuery += " C9_LOJA,SB2.B2_COD,SB2.B2_LOCALIZ,C5_VOLUME1 AS QTDEVOL, C5_ESPECI4 "
       cQuery += " FROM "+RetSqlName("SC9")+" A WITH (NOLOCK) "
       cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (A.C9_FILIAL = B1_FILIAL) AND (A.C9_PRODUTO = B1_COD) "
       cQuery += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "+;
                         " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON "+;
                          "(C9_FILIAL = C5_FILIAL) AND (C9_PEDIDO = C5_NUM)) AND (SC5.D_E_L_E_T_ <> '*')"
       cQuery += " WHERE (C9_FILIAL = '"+xFilial("SC9")+"')"
       cQuery += " AND (C9_DTLCRED BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"')"
       cQuery += " AND (C9_BLEST = '  ') AND (C9_BLCRED = '  ') AND  (C9_BLOQUEI = '  ')"
       cQuery += " AND A.D_E_L_E_T_ <> '*'"
       If !Empty(mv_par04)
          cQuery += " AND C9_PEDIDO IN (SELECT SUBSTRING(ZG_PEDIDO,3,6) FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND "+; 
                    "ZG_FILIAL = '"+xFilial("SZG")+"' "+;
                    "AND (SUBSTRING(ZG_PEDIDO,1,2) = '"+substr(cnumemp,1,2)+"') "+;
                    "AND ZG_CODIGO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
       Endif

       If !Empty(mv_par06)
          cQuery += " AND C9_PEDIDO IN (SELECT SUBSTRING(ZG_PEDIDO,3,6) FROM "+RetSqlName("SZG")+;
					" SZG WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SZG")+" SZF WITH (NOLOCK) "+;
                    "ON ((SZG.ZG_FILIAL+ = SZF.ZF_FILIAL) AND (SZG.ZG_CODIGO = SZF.ZF_CODIGO) AND (SZF.D_E_L_E_T_ <> '*') "+;
                    "WHERE (SZG.D_E_L_E_T_ <> '*') AND "+; 
                    "SZG.ZG_FILIAL = '"+xFilial("SZG")+"' "+;
                    "AND (SUBSTRING(SZG.ZG_PEDIDO,1,2) = '"+substr(cnumemp,1,2)+"') " +;
                    "AND SZF.ZF_EMISSAO BETWEEN '"+dtos(mv_par05)+"' AND '"+dtos(mv_par06)+"')"
       Endif
       cQuery += " ORDER BY "+cIndTrb

       TCQuery cQuery NEW ALIAS "TCQ"

       _aCampos = {}    

       AADD(_aCampos,{"PEDIDO" , "C", 8, 0})
       AADD(_aCampos,{"REGIAO" , "C", 3, 0})
       AADD(_aCampos,{"QTDEVOL", "N", 9, 0})

       /* DESABILITADA EM FUNÇÃO DA RELEASE 12.1.25
       cArqPed = criatrab(_aCampos,.t.)
       use &cArqPed alias TMPPED new
       index on pedido tag pedido
       DbSetIndex(cArqPed)
       DbSetOrder(1)
       */
       oTempTable := FWTemporaryTable():New( "TMPPED" )
       oTemptable:SetFields( _aCampos )
       oTempTable:AddIndex( "cInd01", { "PEDIDO" } )
       oTempTable:Create()
       
       DbSelectArea( "TMPPED" )
       DbSetOrder(1)

       _aCampos = {}    

       AADD(_aCampos,{"REGIAO","C",3,0})
       AADD(_aCampos,{"QTDEVOL","N",9,0})
	
       /* DESABILITADA EM FUNÇÃO DA RELEASE 12.1.25
       cArqReg = criatrab(_aCampos,.t.)
       use &cArqReg alias TMPREG new
       index on regiao tag regiao
       DbSetIndex(cArqReg)
       DbSetOrder(1)
       */
       
       oTempTable1 := FWTemporaryTable():New( "TMPREG" )
       oTemptable1:SetFields( _aCampos )
       oTempTable1:AddIndex( "cInd01", { "REGIAO" } )
       oTempTable1:Create()
       
       DbSelectArea( "TMPREG" )
       DbSetOrder(1)

       DbSelectArea("TCQ")
       cProduto := SPACE(15)
       dbSelectArea("TCQ")
       dbgotop()

       SetRegua(RecCount())

       While !Eof()
       		If _nlin >= 60
                //cAux = titulo+iif(mv_par07 == 1,"(QUADRANTE)","(PRODUTO)")
                _nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                _nLin += 1
            Endif

            DbSelectArea("SZ1")	
            DbSetOrder(1)
             
            DbSelectArea("SB1")
            DbSetorder(1)
            DbSeek(xFilial("SB1")+TCQ->C9_PRODUTO,.F.)
             
            DbSelectArea("SZ5")
            DbSetOrder(1)
            DbSeek(xFilial("SZ5")+SubStr(TCQ->C9_PRODUTO,11,2))
            If Found()
                cDescrEmba = alltrim(substr(SZ5->Z5_DESCR,1,10))
            Else
                cDescrEmba = ""
            Endif
             
            DbSelectArea("TCQ")
            _nlin := _nlin + 1
            @ _nlin,000 PSAY ALLTRIM(TCQ->C9_PRODUTO) picture "@R XXX99.99.999-99"
            @ _nLin,015 psay "-"+substr(SB1->B1_DESC ,1,30)
            @ _nLin,045 PSAY "("+substr(TCQ->C9_PRODUTO,11,2)+"-"+cDescrEmba+")"  
            @ _nlin,iif(mv_par08 == 1,068,060) PSAY iif(empty(tcq->b2_localiz)," ",alltrim(tcq->b2_localiz))
            If mv_par08 == 1
                _nlin := _nlin + 1
            Endif

            cProduto  := TCQ->C9_PRODUTO
            cLocaliz  := TCQ->B2_LOCALIZ
            nQtdeProd := 0
            nTotVol   := 0 // Totaliza a qtde de volumes por produto, no relatório analítico
            While !Eof() .and. (TCQ->C9_PRODUTO == cProduto) .and. (TCQ->B2_LOCALIZ == cLocaliz)
                   DbSelectArea("SB1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SB1")+TCQ->C9_PRODUTO,.F.)

                   DbSelectArea("SB2")
                   DbSetOrder(1)
                   DbSeek(xFilial("SB2")+TCQ->C9_PRODUTO+TCQ->B2_LOCALIZ,.F.)

                   DbSelectArea("SA1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SA1")+TCQ->C9_CLIENTE+TCQ->C9_LOJA,.F.)

                   DbSelectArea("SZ7")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZ7")+SA1->A1_CODCID,.F.)

                   DbSelectArea("SC5")
                   DbSetorder(1)
                   DbSeek(xFilial("SC5")+TCQ->C9_PEDIDO,.F.)

                   DbSelectArea("SA4")
                   DbSetorder(1)
                   DbSeek(xFilial("SA4")+SC5->C5_TRANSP,.F.)

                   If _nlin >= 60
                      //cAux = titulo+iif(mv_par07 == 1,"(QUADRANTE)","(PRODUTO)")
                      _nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                      _nLin += 2
                      @ _nlin,000 PSAY ALLTRIM(TCQ->C9_PRODUTO) picture "@R XXX99.99.999-99"
                      @ _nlin,015 psay "-"+substr(SB1->B1_DESC ,1,30)
                      @ _nLin,045 PSAY "("+substr(TCQ->C9_PRODUTO,11,2)+"-"+cDescrEmba+")"
                      @ _nlin,iif(mv_par08 == 1,068,060) PSAY iif(empty(tcq->b2_localiz)," ",alltrim(tcq->b2_localiz))
                      If mv_par08 == 1
                         _nlin := _nlin + 1
                      Endif
                   Endif
                   DbSelectArea("TMPPED")
                   DbSeek(TCQ->EMPRESA+TCQ->C9_PEDIDO)
                   If !Found()
                      RecLock("TMPPED", .T.)
                         tmpped->pedido := TCQ->EMPRESA+TCQ->C9_PEDIDO
                         tmpped->regiao := ALLTRIM(SZ7->Z7_REGIAO)
                         tmpped->qtdevol := tcq->qtdevol //*iif(!empty(TCQ->C5_ESPECI4),2,1)
                      MsUnLock()
                   Endif 
                   If mv_par08 == 1
                      @ _nlin,001 PSAY TCQ->EMPRESA+"-"+TCQ->C9_PEDIDO
                      @ _nlin,011 PSAY ALLTRIM(TCQ->C9_CLIENTE)+"-"+SUBSTR(SA1->A1_NOME,1,32)
                      @ _nlin,051 PSAY ALLTRIM(SZ7->Z7_REGIAO)
                      @ _nlin,054 PSAY "/"
                      @ _nlin,055 PSAY ALLTRIM(SA4->A4_REGIAO)
                      @ _nlin,057 PSAY TCQ->C9_QTDLIB    Picture "@E 999999" //*Iif(!Empty(TCQ->C5_ESPECI4),2,1)
                      @ _nlin,068 PSAY iif(empty(tcq->b2_localiz)," ",alltrim(tcq->b2_localiz))
                      dbselectarea("SC6")
                      dbseek(xFilial("SC6")+TCQ->C9_PEDIDO+TCQ->C9_ITEM+TCQ->C9_PRODUTO)
                      if found()
							nTotVol += SC6->C6_VOLITEM
					  endif	
                      _nlin := _nlin + 1
                   Endif
                   nQtdeProd += TCQ->C9_QTDLIB //*iif(!empty(TCQ->C5_ESPECI4),2,1)
                   DbSelectArea("TCQ")
                   TCQ->(dbskip())
            EndDo
            If mv_par08 == 1
                @ _nlin,000 PSAY REPLICATE("_",80)
                _nlin := _nlin + 1
                If _nlin >= 58
                   //cAux = titulo+iif(mv_par07 == 1,"(QUADRANTE)","(PRODUTO)")
                   _nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                   _nLin += 1
                Endif
                _nLin++       
                @ _nLin,032  psay "Qtde Total do Produto => "
                @ _nLin,057 psay nQtdeProd picture "@E 999999"
                @ _nLin,064 psay "Q. Vol "
                @ _nLin,070 psay nTotVol picture "@E 9999"
                _nLin++       
                @ _nlin,000 PSAY REPLICATE("=",80)
            Else
                @ _nlin,074 PSAY nQtdeProd  Picture "@E 999999"
                _nLin++
                @ _nlin,000 PSAY REPLICATE("_",80)
            Endif
       EndDo

       // Resumo de Qtdes de Volumes por Região
       DbSelectArea("TMPPED")
       DbGoTop()
       While !Eof()
             DbSelectArea("TMPREG")
             DbSeek(tmpped->regiao)
             If !Found()
                RecLock("TMPREG", .T.)
             Else
                RecLock("TMPREG", .F.)
             Endif
             TMPREG->REGIAO  := TMPPED->REGIAO
             TMPREG->QTDEVOL := TMPREG->QTDEVOL + TMPPED->QTDEVOL
             MsUnLock()
             DbSelectArea("TMPPED")
             DbSkip()
       Enddo

       @ _nlin,000 PSAY REPLICATE("_",80)
       _nlin := _nlin + 1
       If _nlin >= 58
          //cAux = titulo+iif(mv_par07 == 1,"(QUADRANTE)","(PRODUTO)")
          _nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
          _nLin += 1
       Endif
       _nLin++                
       //               0         1        2    999,999.99      
       //               012345678901234567890123456789012345678901234567890123456789
       @_nLin,00  psay "REGIAO                           QTDEVOL"

       DbSelectArea("TMPREG")
       DbGoTop()
       While !Eof()
             If _nlin >= 58
                //cAux = titulo+iif(mv_par07 == 1,"(QUADRANTE)","(PRODUTO)")
                _nLin := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                _nLin += 1
             Endif
             _nLin++                
             @_nLin,00 psay TMPREG->REGIAO+"-"+FDesc("SX5","98"+TMPREG->REGIAO,"X5_DESCRI",25)
             @_nLin,30 psay TMPREG->QTDEVOL picture "@E 999,999.99"
             DbSelectArea("TMPREG")
             DbSkip()
       Enddo

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³                      FIM DA IMPRESSAO                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPPED")
       DbCloseArea()
       DbSelectArea("TMPREG")
       DbCloseArea()
       

       /*** BLOCO ALTERADO EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*
       If File(cArqPed+".dbf")
          cAux = cArqPed+".dbf"
          Delete File &cAux
       Endif
       If file(cArqPed+".cdx")
          cAux = cArqPed+".cdx"
          Delete File &cAux
       Endif
       If File(cArqReg+".dbf")
          cAux = cArqReg+".dbf"
          Delete File &cAux
       Endif
       If file(cArqReg+".cdx")
          cAux = cArqReg+".cdx"
          Delete File &cAux
       Endif
       */
       If ValType(oTempTable)== "O"    
           oTempTable:Delete()
       Endif    
       If ValType(oTempTable1)== "O"    
           oTempTable1:Delete()
       Endif
       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif

Return

/*/
Programa  : VALIDPERG 
Data      : 28/01/02
Descricao : Grava Perguntas
/*/

/* DESABILITADA EM FUNÇÃO DA RELEASE 12.1.25
Static Function ValidPerg()  
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Data Aprov.Ped. De  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"02","Data Aprov.Ped. Ate ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"03","Bord de(Brco desconsid)","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SZF",""})
       aAdd(aRegs,{cPerg,"04","Bord até(Brco desconsid)","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SZF",""})
       aAdd(aRegs,{cPerg,"05","Emis Bord de(Bco desconsid)?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"06","Emis Borde Ate(Bco desconsid)?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"07","Ordem de            ?","","","mv_ch7","N",01,0,2,"C","","mv_par07","QUADRANTE","QUADRANTE" ,"QUADRANTE","","","PRODUTO","PRODUTO" ,"PRODUTO" ,"","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"08","Tipo        ?","","","mv_ch8","N",01,0,2,"C","","mv_par08","ANALITICO","ANALITICO" ,"ANALITICO","","","SINTETICO","SINTETICO" ,"SINTETICO" ,"","","","","","","","","","","","","","","","","",""})

       For i := 1 To Len(aRegs)
           If !DbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
                 For j := 1 To FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j,aRegs[i,j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return
*/