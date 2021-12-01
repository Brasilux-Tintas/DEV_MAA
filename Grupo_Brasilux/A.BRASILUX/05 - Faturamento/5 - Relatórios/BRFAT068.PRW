#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT068     Data....: 28/03/02         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçao.: Produtos de Pedidos Liberados, prontos p/ FAturar//
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Dt. Lib. de                          //
// mv_par02     // Dt. Lib Ate                          //
/////////////////////////////////////////////////////////

User Function BRFAT068()     
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

     CbTxt    :=""
     CbCont   :=0
     nOrdem   :=0
     Alfa     :=0
     Z        :=0
     M        :=0
     tamanho  :="P"
     limite   :=80
     titulo   :="PRODUTOS LIBERADOS, PRONTOS P/ FATURAR"
     cDesc1   :=PADC("Este programa ira emitir o Rel. de Pedidos Prontos p/ Faturar.",74)
     cDesc2   :=""
     cDesc3   :=PADC(" ",74)
     cCabec   :=PADC("Prod. Liberados",27)
     cCabPro  :=""
     cNatureza:=""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog :="BRFAT068"
     cPerg    :="BRFT68"
     nLastKey := 0
     lContinua:=.T.
     nLin    := 0
     nCol     := 0
     wnrel    := "BRFAT068"
     nTipo    := 18
     m_pag    := 01     
     nTamNf   := 80     // Apenas Informativo
     cString  := "SC9"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFAT068' ) //LGS#2021201 - Gravação de log de utilização da rotina
     //ValidPerg()
     Pergunte(cPerg,.F.)   

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

     Local cEmpresa,cProduto,nTotal,cQuery
     cEmpresa = substr(cnumemp,1,2)
     cQuery = "SELECT C9_PRODUTO,SUM(C9_QTDLIB) AS QTDE "+;
              " FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "+;
              " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.C5_FILIAL = SC9.C9_FILIAL) AND (SC5.C5_NUM = SC9.C9_PEDIDO) WHERE "+;
              " (SC9.C9_FILIAL = '"+xFilial("SC9")+"')"+;
              " AND SC9.C9_DTLCRED BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"'"
     If !Empty(mv_par04)
        cQuery += " AND SC5.C5_EMISSAO BETWEEN '"+DTOS(Mv_Par04)+"' AND '"+DTOS(Mv_Par05)+"'"
     Endif
    if !empty(MV_PAR03)
	cQuery += "AND (LEN(C9_PRODUTO) = 12) AND "+U_ParamSql("SUBSTRING(C9_PRODUTO,4,2)",MV_PAR03)+" "
	endif
     cQuery := cQuery + " AND (LEN(SC9.C9_BLCRED) = 0) AND (LEN(SC9.C9_BLEST) = 0)"+;
                        " AND (SC9.D_E_L_E_T_ <> '*')  AND (SC5.D_E_L_E_T_ <> '*')"+;
                        " AND LEN(SC9.C9_PRODUTO) = 12 "+;
                        " GROUP BY C9_PRODUTO "
     cQuery = cQuery + " ORDER BY C9_PRODUTO "

     TCQuery cQuery NEW ALIAS "TCQ" 
    
     //               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
     //           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     cCabec2  := "Produto         Descricao                     Localizacao      Qtde Liberada"
     cCabec1  := "PERIODO DE LIBERACAO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
     cCabec3  := ""
     Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
     nLin = 08
     dbselectarea("SB1")
     dbsetorder(1)
     dbselectarea("SB2")
     dbsetorder(1)

     dbSelectArea("TCQ")
     dbgotop()

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SetRegua(Reccount())
     While !EoF()         
           if nLin > 60
              nLin++
              @nLin,000 psay replicate("_",80)
              Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              nLin := 08
           endif
           nLin++
           @nLin,00 psay alltrim(TCQ->C9_PRODUTO) picture "@R XXX99.99.999.99"
           dbselectarea("SB1")
           dbseek(xFilial("SB1")+TCQ->C9_PRODUTO)
           if found()
              @nLin,16 psay SB1->B1_DESC 
              dbselectarea("SB2")
              dbseek(xFilial("SB2")+TCQ->C9_PRODUTO+SB1->B1_LOCPAD)
              if found()
                 @nLin,046 psay SB2->B2_LOCALIZ
              endif
           endif
           dbselectarea("TCQ")
           cProduto = TCQ->C9_PRODUTO                      
           nTotal = 0
           while !eof() .and. (cProduto == TCQ->C9_PRODUTO)
                 nTotal += TCQ->QTDE
                 dbskip()
                 IncRegua()
           enddo
           @nLin,67 psay nTotal picture "@E 9,999,999"
     Enddo

     nLin++
     @nLin,00 psay replicate("_",80)
  		
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

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa  : VALIDPERG   Autor:  M
Data      : 28/03/02
Descricao : Grava Perguntas
/*/
/* DESABILITADO RELEASE 12.1.25
Static Function ValidPerg()
       Local aHelp := {}
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs:={}
	 
	   AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Data Lib De      ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"02","Data Lib Ate     ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	   PutSX1(cPerg,"03","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch3","C",99,00,00,"G","","","","","mv_Par03","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
       AADD(aRegs,{cPerg,"04","Data Emissao De  ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"05","Data Emissao Ate ?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
*/
