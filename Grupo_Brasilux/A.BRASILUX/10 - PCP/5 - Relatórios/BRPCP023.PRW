#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP023 ºAutor ³ Cleber Orati Domingues º Data ³ 15/02/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Produtos c/ Local e Cod. antigo               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros

mv_par01  -  Produto de
mv_par02  -  Produto Ate
mv_par03  -  Odem de (1-Local;2-Produto)
mv_par04  -  Da Localização
mv_par05  -  Ate a Localizacao
mv_par06  -  Tipo de
mv_par07  -  Tipo Até
*/

User Function BRPCP023()     
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
     u_zcfga01( 'BRPCP023' ) //LGS#2021201 - Gravação de log de utilização da rotina
     CbTxt    := ""
     CbCont   := 0
     nOrdem   := 0
     Alfa     := 0
     Z        := 0
     M        := 0
     tamanho  := "P"
     limite   := 132
     titulo   := "REL. QUADRANTES PRODUTOS"
     cDesc1   := PADC("Este programa ira emitir o Rel. de Prod. por Ordem de Quadrante",74)
     cDesc2   := ""
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Rel. Produtos por Quadrante",27)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRPCP023"
     cPerg    := "BRPC23"
     nLastKey := 0
     lContinua:= .T.
     nLin     := 0
     nCol     := 0
     wnrel    := "BRPCP023"
     nTipo    := 18
     m_pag    := 01     
     //               0       1           2        3           4       5         6        7           8
     //           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
     //           XXX99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    99  
     cCabec1  := "PRODUTO         DESCRICAO                         LC  LOCALIZACAO    SALDO ATU."
     cCabec2  := ""   
     cCabec3  := ""
     nTamNf   := 80     // Apenas Informativo
     cString  := "SB2"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //ValidPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte("BRPC23",.F.)   

     wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.T.,Tamanho)

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
     Local cOrdem

     cQuery = "SELECT B2_COD,B1_DESC,B2_LOCALIZ,B1_XCODANT, B2_QATU, B2_LOCAL FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "+;
	 "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB2.B2_FILIAL = SB1.B1_FILIAL) AND (SB2.B2_LOCAL = SB1.B1_LOCPAD) AND (SB2.B2_COD = SB1.B1_COD) "+;
              "AND (SB1.D_E_L_E_T_ <> '*')"+;
              " WHERE (SB2.B2_FILIAL = '"+xFilial("SB2")+"') "+;
              " AND (LEN(B2_LOCALIZ) > 0) AND (SB2.D_E_L_E_T_ <> '*')"
     If !Empty(mv_par02) .and. (mv_par02 >= mv_par01)
        cQuery = cQuery + " AND B2_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
     Endif                    
     If !Empty(mv_par05) .and. (mv_par05 >= mv_par04)
        cQuery = cQuery + " AND B2_LOCALIZ BETWEEN '"+mv_par04+"' AND '"+mv_par05+"'"
     Endif                    
     If !Empty(mv_par07) .and. (mv_par07 >= mv_par06)
        cQuery = cQuery + " AND B1_TIPO BETWEEN '"+mv_par06+"' AND '"+mv_par07+"'"
     Endif                    
     If mv_par03 == 1
        cOrdem := "B2_LOCALIZ,B2_COD"
     Else
        cOrdem := "B2_COD,B2_LOCALIZ"
     Endif  	
     cQuery = cQuery + " ORDER BY "+cOrdem
     TCQuery cQuery NEW ALIAS "TCQ" 
    
     Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
     nLin := 08
     dbSelectArea("TCQ")
     dbgotop()
  
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SetRegua(Reccount())
     While !EoF()         
           If nlin >= 61
              nLin += 1
              @nLin,000 psay replicate("_",80)
              Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              nLin := 08    
           Endif       
           nLin += 1
           @nLin,000 psay TCQ->B2_COD      Picture "@R XXX99.99.999-99"
           @nLin,016 psay TCQ->B1_DESC     Picture "@!"
           @nLin,050 psay TCQ->B2_LOCAL    Picture "@R 99"
           @nLin,054 psay TCQ->B2_LOCALIZ  Picture "@!"
           //@nLin,070 psay TCQ->B1_XCODANT   Picture "@R 99.99.999"
           @nlin,070 psay TCQ->B2_QATU     picture "@E 999,999.99"
           dbselectarea("TCQ")
           dbskip()
           IncRegua()
     Enddo
     If nlin >= 60
        Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
        nLin := 08
     Endif         
     nLin += 1
     @nLin,000 psay replicate("_",80)

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
//³                   FUNCOES ESPECIFICA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Programa  : VALIDPERG   Autor:  Marcos Cesar     
Data      : 28/01/02
Descricao : Grava Perguntas
/*/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Produto De      ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"02","Produto Ate     ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg,"03","Ordem de        ?","","","mv_ch3","N",01,0,2,"C","","mv_par03","LOCALIZACAO","LOCALIZACAO" ,"LOCALIZACAO","","","PRODUTO","PRODUTO" ,"PRODUTO" ,"","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"04","Localizacao de  ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"05","Localizacao Ate ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"06","Tipo De         ?","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg,"07","Tipo Ate        ?","","","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","02",""})

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
Return*/
