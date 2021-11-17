#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP049 ºAutor ³ Cleber Orati Domingues º Data ³ 15/05/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Último Preço de Produto                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros

mv_par01  -  Tipo De
mv_par02  -  Tipo Ate
mv_par03  -  Produto De
mv_par04  -  Produto Ate
*/
User Function BRPCP049()     
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
     titulo   := "RELACAO DE ULT. PRECO PRO"
     cDesc1   := PADC("Este programa ira emitir o Rel. Últ. Preco Prod.",74)
     cDesc2   := ""
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Rel. Ult. Preco",27)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRPCP049"
     cPerg    := "BRPC49"
     nLastKey := 0
     lContinua:= .T.
     _nLin    := 90
     nCol     := 60
     wnrel    := "BRPCP049"
     nTipo    := 18
     m_pag    := 01
     //				0         1         2         3        4         5          6        7         8           
     //          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
     cCabec1  :="COD. PRODUTO     DESCRICAO                                 TP  UN  ULTIMO PRECO"
     cCabec2  :=""   
     cCabec3  :=""

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica as perguntas selecionadas, busca o padrao                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cString  :="SB1"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

     //ValidPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte("BRPC49",.F.)   

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
     //Local cQualLucro

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     cQuery := "SELECT B1_COD,B1_DESC,B1_TIPO,B1_UM,B1_UPRC FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) " 
     cQuery := cQuery + " WHERE (B1_FILIAL = '"+xFilial("SB1")+"')"
     cQuery := cQuery + " AND B1_COD  BETWEEN '"+Mv_Par01+"' AND '"+Mv_Par02+"'"
     cQuery := cQuery + " AND B1_TIPO BETWEEN '"+Mv_Par03+"' AND '"+Mv_Par04+"'"   
     cQuery := cQuery + " AND (D_E_L_E_T_ <> '*')"
     cQuery := cQuery + " ORDER BY B1_COD "

     TCQuery cQuery NEW ALIAS "TCQ" 

     _nLin := 80	
     DbSelectArea("TCQ")
     DbGoTop()

     SetRegua(Reccount())
     While !EoF()      
           If _nlin >= 60
              Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              _nLin:= 08 
           Endif
           //0         1         2         3         4         5         6         7         8
           //012345678901234567890123456789012345678901234567890123456789012345678901234567890
           //XXX99.99.999-99  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX  XX  9,999,999.99
           //123456789012345  12345678901234567890123456789012345678    12  12  123456789012
           //COD. PRODUTO     DESCRICAO                                 TP  UN  ULTIMO PRECO
           @ _nLin,000 PSAY Alltrim(TCQ->B1_COD)        Picture "@R XXX99.99.999-99"
           @ _nlin,017 PSAY Substr(TCQ->B1_DESC, 1, 38) Picture "@!"
           @ _nlin,059 PSAY TCQ->B1_TIPO                Picture "@!"
           @ _nlin,063 PSAY TCQ->B1_UM                  Picture "@!"
           @ _nlin,067 PSAY TCQ->B1_UPRC                Picture "@E 9,999,999.99"  
           _nlin++  
           DbSelectArea("TCQ")              
           DbSkip()
     EndDo

     Roda(cbcont,cbtxt,tamanho)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³                      FIM DA IMPRESSAO                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("TCQ")
     DbCloseArea()

     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        DbCommitAll()
        ourspool(wnrel)
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
       aAdd(aRegs,{cPerg, "01", "Cod.Produto    De  ?", "", "", "mv_ch1", "C", 15, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       aAdd(aRegs,{cPerg, "02", "Cod.Produto    Ate ?", "", "", "mv_ch2", "C", 15, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       aAdd(aRegs,{cPerg, "03", "Tipo Produto   De  ?", "", "", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , ""})
       aAdd(aRegs,{cPerg, "04", "Tipo Produto   Ate ?", "", "", "mv_ch4", "C", 02, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , ""})

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