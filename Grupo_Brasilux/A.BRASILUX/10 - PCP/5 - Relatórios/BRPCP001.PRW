#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP001 ºAutor ³ Cleber Orati Domingues º Data ³ 22/05/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Produção no Período, Prod, QTde OPs e Volume               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros

mv_par01  -  Período de?
mv_par02  -  Período até?
mv_par03  -  Ordem de?(1-Cód. Prod;2-Qtde Op's)
mv_par04  -  Turno?
mv_par05  -  Kilos ou Litros?
*/
User Function BRPCP001()     
     Local CbTxt, CbCont, nOrdem, Alfa, Z, M
     //Local nSomaOp,nSomaQtde, cUm
     Private tamanho, limite, titulo, cDesc1, cDesc2, cDesc3, cCabec, cCabPro
     Private cNatureza, aReturn, nomeprog, cPerg, nLastKey, lContinua, nLin, nCol, wnrel, nTipo, m_pag, nTamNf, cString

     CbTxt     := ""
     CbCont    := 0
     nOrdem    := 0
     Alfa      := 0
     Z         := 0
     M         := 0
     tamanho   := "M"
     limite    := 132
     titulo    := "PRODUCAO NO PERIODO"
     cDesc1    := PADC("Emissao de Relatorio de Producao no Periodo.",130)
     cDesc2    := PADC("Produtos com Unid. MEDIDA em Litros ou Kilogramas",130)
     cDesc3    := PADC(" ",130)
     cCabec    := PADC("Producao no Periodo",27)
     cCabPro   := ""
     cNatureza := ""
     aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog  := "BRPCP001"
     cPerg     := "BRPC01"
     nLastKey  := 0
     lContinua := .T.
     nLin      := 0
     nCol      := 0
     wnrel     := "BRPCP001"
     nTipo     := 18
     m_pag     := 01     
     nTamNf    := 132     // Apenas Informativo
     cString   := "SB1"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //ValidPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg,.F.)   

     wnrel := SetPrint(cString, wnrel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .F., , .F., Tamanho)
     If nLastKey == 27
        Return
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn,cString)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     #IFDEF WINDOWS
            RptStatus({|| RptDetail()})
            Return

            Static Function RptDetail()
     #ENDIF

     //Local Ordem

     If mv_par03 == 1
        cOrdem = "D3_COD"
     Else
        cOrdem = "QTDE DESC"
     Endif       
     
     if mv_par05 == 2
     	cUm := "K"
     else
     	cUm := "L"
     endif

     cQuery = "SELECT D3_COD,COUNT(D3_COD) AS QTDE,SUM(D3_QUANT) AS VOLUME FROM "+RetSqlName("SD3")+;
     " WHERE (D3_FILIAL = '"+xFilial("SD3")+"') AND (D3_TM = '010') "+;
       "AND (RTRIM(D3_UM) = '"+cUm+"') AND (D3_ESTORNO <> 'S') "
     If !empty(mv_par04)
        cQuery += "AND (D3_TURNO = '"+mv_par04+"') "
     Endif
     cQuery += "AND (D3_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+;
     "') AND (D_E_L_E_T_ <> '*') GROUP BY D3_COD ORDER BY "+cOrdem

     TCQuery cQuery NEW ALIAS "TCQ" 
    
     //               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13      14        15          16       17        18        19
     //           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     cCabec2  := "PRODUTO                                                       LOCAL   QTDE OP'S        QTDE("+cUm+")"
     cCabec1  := "PRODUCAO NO PERIODO DE "+dtoc(mv_par01)+" ATE' "+dtoc(mv_par02)
     If !Empty(mv_par04)
        cCabec1 += "(TURNO "+mv_par04+")"
     Endif
     cCabec3  := ""
     nLin = 08

     DbSelectArea("SB1")
     DbSetOrder(1)
     DbSelectArea("SB2")
     DbSetOrder(1)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SetRegua(Reccount())   
     Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
     
		nSomaOp := 0
		nSomaQtde := 0
     DbSelectArea("TCQ")
     DbGoTop()
     While !EoF()
           If (nLin > 60)
              nLin++
              @nLin,00 psay replicate("_",132)
              Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
              nLin := 08
           Endif   
           nLin++
           @nLin,00 psay TCQ->D3_COD picture "@R XXX99.99.999-99"
           DbSelectArea("SB1")
           DbSeek(xFilial("SB1")+TCQ->D3_COD)
           If Found()
              @nLin,16 psay substr(SB1->B1_DESC,1,45)
              DbSelectArea("SB2")
              DbSeek(xFilial("SB2")+TCQ->D3_COD+SB1->B1_LOCPAD)
              If Found()
                 @nLin,62 psay SUBSTR(alltrim(SB2->B2_LOCALIZ),1,6)
              Endif
           Endif 
           @nLin,69 psay TCQ->QTDE picture "@E 99,999,999"
           @nLin,82 psay TCQ->VOLUME picture "@E 9,999,999.99"
           nSomaOp += TCQ->QTDE
           nSomaQtde += TCQ->VOLUME
 	       DbSelectArea("TCQ")
           DbSkip()  
 	       IncRegua()		   	
     EndDo
     nLin++
     @nLin,00 psay replicate("_",132)
     nLin++
     @nLin,69 psay nSomaOp picture "@E 99,999,999"
     @nLin,82 psay nSomaQtde picture "@E 9,999,999.99"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³                      FIM DA IMPRESSAO                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("TCQ")
     DbCloseArea()

     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        DbCommitAll()
        OurSpool(wnrel)
     Endif
Return

/***************************************************************************/
/*** VALIDPERG - Ajuste de perguntas no SX1                              ***/
/***************************************************************************/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs:={}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Periodo de              ?", "", "", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01", "","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg, "02", "Periodo ate             ?", "", "", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", "","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg, "03", "Ordem de                ?", "", "", "mv_ch3", "N", 01, 0, 2, "C", "", "mv_par03", "COD PROD","COD PROD" ,"COD PROD","","","QTDE OP'S","QTDE OP'S" ,"QTDE OP'S" ,"","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg, "04", "Turno(Em brco p/ todos) ?", "", "", "mv_ch4", "C", 03, 0, 0, "G", "", "mv_par04", "","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg, "05", "Litros ou Kilos         ?", "Litros ou Kilos         ?", "Litros ou Kilos         ?", "mv_ch5", "N", 01, 0, 2, "C", "", "mv_par05", "Litros","Litros" ,"Litros","","","KG","KG" ,"KG" ,"","","","","","","","","","","","","","","","","",""})

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