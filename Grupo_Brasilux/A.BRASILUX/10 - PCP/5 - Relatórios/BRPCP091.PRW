#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP091 ºAutor ³ Jose Uliana            º Data ³ 27/01/21 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório  Apontamentos de produção - Saldo PI Litros      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Parametros de entrada foi criado no SX1 Grupo BRPCP091      
SIGACFG
- Base de Dados 
  - Dicionário
    - Base de Dados
      - Clicar em Perguntas
        - Clicar em Incluir
         - Colocar o no  do Grupo (Geralmente colocar o nome do programa)
           - Incluir as colunas (parametros Ex:- MV_Par01, MV_Oar02, MV_Par03, e etc)
MV_PAR01 = Local  DE
MV_PAR02 = Local  ATE
*/

User Function BRPCP091()     
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,CSTRING")
     SetPrvt("CQUERY,Result,cdia")

     Result   := 0
     CbTxt    := ""
     CbCont   := 0
     nOrdem   := 0
     Alfa     := 0
     Z        := 0
     M        := 0
     tamanho  := "M"
     limite   := 110

     titulo   := "Apontamentos de produção - Saldo PI Litros "
     cDesc1   := PADC("Relatório Apontamentos de produção - Saldo PI Litros ",74)
     cDesc2   := ""
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Apontamentos de produção - Saldo PI Litros",35)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRPCP091"
     cPerg    := "BRPCP091"
     nLastKey := 0
     lContinua:= .T.
     _nLin    := 90
     nCol     := 60
     wnrel    := "BRPCP091"
     nTipo    := 18
     m_pag    := 01
     cDIA     := 22

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //		    0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
     //          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
     cCabec1  :="PRODUTO         DESCRICAO	                                 APROPRI LOCAL       QTD ATUAL	           EMPENHO    	    DISPONÍVEL   ENTR.PREVISTA   MEDIA     DIAS"
     cCabec2  :=""   
     cCabec3  :=""

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica as perguntas selecionadas, busca o padrao                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cString  :="SZG"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

     Pergunte("BRPCP091",.F.)   
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
//³ Montagem da Query                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := "SELECT SB2.B2_COD AS 'PRODUTO', SB1.B1_DESC AS 'DESCRICAO', " + CHR(13) + CHR(10)
cQuery := cQuery + "CASE WHEN SB1.B1_APROPRI ='I' THEN 'INDIRETO' ELSE 'DIRETO' END AS 'APROPRI', SB2.B2_LOCAL AS 'LOCALI', " + CHR(13) + CHR(10)
cQuery := cQuery + "          SB2.B2_QATU AS 'QTDATUAL', SB2.B2_QEMP AS 'EMPENHO', " + CHR(13) + CHR(10)
cQuery := cQuery + "   ROUND((SB2.B2_QATU - SB2.B2_QEMP - SB2.B2_RESERVA - SB2.B2_QEMPN),2) AS 'DISPONIVEL', " + CHR(13) + CHR(10)
cQuery := cQuery + "          SB2.B2_SALPEDI AS 'ENTRPREVISTA', ISNULL(ZZ2.ZZ2_MEDIA,0) AS 'MEDIA', " + CHR(13) + CHR(10)
cQuery := cQuery + "CASE WHEN ISNULL(ZZ2.ZZ2_MEDIA,0) <= 0 THEN 0 ELSE " + CHR(13) + CHR(10)
cQuery := cQuery + "   ROUND((SB2.B2_QATU-SB2.B2_QEMP-SB2.B2_RESERVA-SB2.B2_QEMPN+SB2.B2_SALPEDI) / (ISNULL(ZZ2.ZZ2_MEDIA,0) / 22),0) END AS 'DIAS' " + CHR(13) + CHR(10)
cQuery := cQuery + "FROM SB2010 SB2 WITH(NOLOCK) " + CHR(13) + CHR(10)
cQuery := cQuery + "  LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON SB2.B2_FILIAL  = SB1.B1_FILIAL AND SB2.B2_COD  = SB1.B1_COD AND SB1.D_E_L_E_T_ ='' " + CHR(13) + CHR(10)
cQuery := cQuery + "  LEFT OUTER JOIN ZZ2010 ZZ2 WITH(NOLOCK) ON ZZ2.ZZ2_FILIAL = SB1.B1_FILIAL AND ZZ2.ZZ2_COD = SB1.B1_COD AND ZZ2.D_E_L_E_T_ ='' " + CHR(13) + CHR(10)
cQuery := cQuery + "WHERE SB2.D_E_L_E_T_ ='' AND SB2.B2_FILIAL ='010101' " + CHR(13) + CHR(10)          // AND  SB2.B2_LOCAL IN ('02','20','99','R1','R2') AND SB1.B1_TIPO ='PI' " Inibido para colocar os paramentros
cQuery := cQuery + "  AND SB2.B2_LOCAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' AND SB1.B1_TIPO ='PI' " + CHR(13) + CHR(10)
cQuery := cQuery + "  AND (SB2.B2_LOCAL <> 'R0' AND SB2.B2_LOCAL <> '40' AND SB2.B2_LOCAL <> '98') " + CHR(13) + CHR(10)
cQuery := cQuery + "  AND LEN(SB2.B2_COD)< 12 AND (SB2.B2_QATU <> 0 OR SB2.B2_SALPEDI <> 0 OR SB2.B2_QEMP <> 0) " + CHR(13) + CHR(10)
cQuery := cQuery + "ORDER BY SB1.B1_APROPRI, SB2.B2_COD, SB2.B2_LOCAL " + CHR(13) + CHR(10)

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
     //	 0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
     //   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
     //   "PRODUTO        DESCRICAO	                                 APROPRI  LOCAL QTD ATUAL	      EMPENHO 	  DISPONÍVEL	ENTR.PREVISTA  MEDIA   DIAS"     
           @ _nLin,000 PSAY Alltrim(TCQ->PRODUTO)         Picture "@R XXX999999999"
           @ _nLin,016 PSAY Substr(TCQ->DESCRICAO, 1, 38) Picture "@!"
           @ _nlin,059 PSAY Substr(TCQ->APROPRI, 1, 09)   Picture "@!"
           @ _nlin,068 PSAY Substr(TCQ->LOCALI, 1, 03)    Picture "@!"
           @ _nlin,074 PSAY TCQ->QTDATUAL                 Picture "@E 9999,999.9999"
           @ _nlin,092 PSAY TCQ->EMPENHO                  Picture "@E 9999,999.9999"  
           @ _nlin,110 PSAY TCQ->DISPONIVEL               Picture "@E 9999,999.9999"  
           @ _nlin,126 PSAY TCQ->ENTRPREVISTA             Picture "@E 9999,999.9999"  
           @ _nlin,140 PSAY TCQ->MEDIA                    Picture "@E 999,999"  
           @ _nlin,150 PSAY TCQ->DIAS                     Picture "@E 999999"
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
