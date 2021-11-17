#include "totvs.ch"
#include "rwmake.ch"        
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP050 ºAutor ³ André Maester          º Data ³ 11/03/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Produtos sem Cadastro de Inspeção             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros

mv_par01  -  Produto De
mv_par02  -  Produto Até
mv_par03  -  De Linha
mv_par04  -  Até Linha
mv_par05  -  Unidade de Medida 

*/
User Function BRPCP050()     
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

     CbTxt    := ""
     CbCont   := 0
     nOrdem   := 0
     Alfa     := 0
     Z        := 0
     M        := 0
     tamanho  := "P"
     limite   := 80
     titulo   := "RELAÇÃO DE PRODUTOS SEM INSPEÇÃO"
     cDesc1   := PADC("Este programa irá emitir o Relatório de Produtos sem cadastro de Inspeção",74)
     cDesc2   := PADC("Atenção para a Unid. de medida escolhida( K para PI Kg e L para PI Litro )",74)
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Rel. Prod sem Inspeção",27)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRPCP050"
     cPerg    := "BRPC50"
     nLastKey := 0
     lContinua:= .T.
     _nLin    := 90
     nCol     := 60
     wnrel    := "BRPCP050"
     nTipo    := 18
     m_pag    := 01
     //				0         1         2         3        4         5          6        7         8           
     //          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
     cCabec1  :="COD. PRODUTO     DESCRICAO                                 TIPO   UND         "
     cCabec2  :=""                                                                             
     cCabec3  :=""

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica as perguntas selecionadas, busca o padrao                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cString  :="SB1"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //ValidPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte("BRPC50",.F.)   

     wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,,Tamanho)

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

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     // Buscar todos os produtos do Tipo PI que não possue cadastro na Tabela QP6 para Inspeção do produto no módulo 25-Inspeção de Processos
     // Un K - PIs em Kg UN L - PIs em Litro
     cQuery := "SELECT B1_COD, B1_DESC, B1_TIPO, ISNULL(QP6.QP6_PRODUT,'NAO') AS QP6_INSP, B1_UM "
     cQuery += " FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) " 
	 cQuery += " LEFT OUTER JOIN "+RetSqlName("QP6")+" QP6 WITH (NOLOCK) ON B1_FILIAL=QP6_FILIAL AND B1_COD=QP6_PRODUT AND QP6.D_E_L_E_T_ ='' "
	 cQuery += " WHERE (B1_FILIAL = '"+xFilial("SB1")+"')"
     cQuery += " AND B1_COD  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
     If Len(MV_PAR04) > 0 .AND. ALLTRIM(MV_PAR05) $ 'L' // SE FOR PI LITRO TEM A OPÇÃO DE ESCOLHER POR LINHA
     	cQuery += " AND SUBSTRING(B1_COD,4,2) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND LEN(B1_COD) =12 "
     Endif	 
     cQuery += " AND B1_UM ='"+MV_PAR05+"' "
     cQuery += " AND SB1.D_E_L_E_T_ = '' AND B1_MSBLQL <>'1' AND B1_TIPO ='PI' "
     cQuery += " GROUP BY B1_COD, B1_DESC, B1_TIPO, QP6_PRODUT, B1_UM " 
     cQuery += " ORDER BY B1_UM, B1_COD "
     
     TCQuery cQuery NEW ALIAS "TCQ" 

     _nLin := 80	
     DbSelectArea("TCQ")
     DbGoTop()

     SetRegua(Reccount())
     While !EoF()      
     	If Substr(Alltrim(TCQ->QP6_INSP),1,3) $ 'NAO' 
        	If _nlin >= 60
            	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              	_nLin:= 08 
           	Endif
           	//0         1         2         3         4         5         6         7         8
           	//012345678901234567890123456789012345678901234567890123456789012345678901234567890
           	@ _nLin,000 PSAY Alltrim(TCQ->B1_COD)        Picture "@R XXX99.99.999-99"
           	@ _nlin,017 PSAY Substr(TCQ->B1_DESC, 1, 40) Picture "@!"
           	@ _nlin,061 PSAY TCQ->B1_TIPO                Picture "@!"
           	@ _nlin,067 PSAY TCQ->B1_UM                  Picture "@!"
           	_nlin++  
       	Endif
       	DbSelectArea("TCQ")              
       	DbSkip()
     EndDo
	 
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	 //³                      FIM DA IMPRESSAO                        ³
   	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("TCQ")
     DbCloseArea()

     Set Device To Screen
     If aReturn[5] == 1
     	Set Printer TO
       	DbCommitAll()
       	OursPool(wnrel)
    Endif

Return


/*****************************************************************************/
/*** VALIDPERG - Ajusta dicionario de perguntas SX1                        ***/
/*****************************************************************************/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Cod.Produto     De  ?", "", "", "mv_ch1", "C", 15, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       aAdd(aRegs,{cPerg, "02", "Cod.Produto     Ate ?", "", "", "mv_ch2", "C", 15, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       aAdd(aRegs,{cPerg, "03", "Linha de            ?", "", "", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" , ""})
       aAdd(aRegs,{cPerg, "04", "Linha Até           ?", "", "", "mv_ch4", "C", 02, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" , ""})
       aAdd(aRegs,{cPerg, "05", "Unid. de Medida     ?", "", "", "mv_ch5", "C", 02, 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SAH" , ""})
       

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
       DbSelectArea(_sAlias)
Return*/