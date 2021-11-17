#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкммммммяммммммммммммммммммммммммкммммммямммммммммм╩╠╠
╠╠╨Programa  Ё BRPCP090 ╨Autor Ё Jose Uliana            ╨ Data Ё 27/01/21 ╨╠╠
╠╠лммммммммммьммммммммммйммммммоммммммммммммммммммммммммйммммммомммммммммм╧╠╠
╠╠╨Desc.     Ё RelatСrio Especificos Bordero X Saldo Produto             ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasilux Tintas TИcnicas Ltda.                             ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
Parametros de entrada foi criado no SX1 Grupo BRPCP090      
SIGACFG
- Base de Dados 
  - DicionАrio
    - Base de Dados
      - Clicar em Perguntas
        - Clicar em Incluir
         - Colocar o no  do Grupo (Geralmente colocar o nome do programa)
           - Incluir as colunas (parametros Ex:- MV_Par01, MV_Oar02, MV_Par03, e etc)
MV_PAR01 = Filial  DE
MV_PAR02 = Filial  ATE
MV_PAR03 = Bordero DE
MV_PAR04 = Bordero ATE
*/

User Function BRPCP090()     
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,CSTRING")
     SetPrvt("CQUERY","Result")

     Result   := 0
     CbTxt    := ""
     CbCont   := 0
     nOrdem   := 0
     Alfa     := 0
     Z        := 0
     M        := 0
     tamanho  := "M"
     limite   := 110

     titulo   := "Especificos Bordero X Saldo Produto "
     cDesc1   := PADC("RelatСrio Especificos Bordero X Saldo Produto ",74)
     cDesc2   := ""
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Especificos Bordero X Saldo Produto",35)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRPCP090"
     cPerg    := "BRPCP090"
     nLastKey := 0
     lContinua:= .T.
     _nLin    := 90
     nCol     := 60
     wnrel    := "BRPCP090"
     nTipo    := 18
     m_pag    := 01

     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Inicializa  regua de impressao                            Ё
     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

     //		     0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
     //          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
     cCabec1  :="BORDERO    PRODUTO                DESCRICAO	                             TOTALVENDIDO        SALDOTOTAL   OP EM ABERTO    03      30      P1      P2"
     
     cCabec2  :=""   
     cCabec3  :=""

     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Verifica as perguntas selecionadas, busca o padrao                      Ё
     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     cString  :="SZG"

     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Envia controle para a funcao SETPRINT                        Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso nЦo autorizado!---->"+funname(),"AtenГЦo","Alert")
      return 
  endif 

     Pergunte("BRPCP090",.F.)   
     wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,,Tamanho)

     If nLastKey == 27
        Return
     Endif
     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Verifica Posicao do Formulario na Impressora                 Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Inicio do Processamento do Relatorio                         Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

     #IFDEF WINDOWS
            RptStatus({|| RptDetail()})
            Return
            Static Function RptDetail()
     #ENDIF
 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montagem da Query                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cQuery := "SELECT SZG.ZG_FILIAL AS 'FILIAL', SZG.ZG_CODIGO AS 'BORDERO', SC6.C6_PRODUTO AS 'PRODUTO', SC6.C6_DESCRI AS 'DESCRICAO', SUM(SC6.C6_QTDVEN) AS 'TOTALVENDIDO', "
cQuery := cQuery + "(ISNULL(SB21.B2_QATU,0) + ISNULL(SB22.B2_QATU,0) + ISNULL(SB23.B2_QATU,0) + ISNULL(SB24.B2_QATU,0)) AS 'SALDOTOTAL', "
cQuery := cQuery + "SB2.B2_SALPEDI AS 'OPEMABERTO', "
cQuery := cQuery + "ISNULL(SB21.B2_QATU,0) AS 'P03', ISNULL(SB22.B2_QATU,0) AS 'P30', ISNULL(SB23.B2_QATU,0) AS 'P1', "
cQuery := cQuery + "ISNULL(SB24.B2_QATU,0) AS 'P2' "
cQuery := cQuery + "FROM SZG010 SZG "
cQuery := cQuery + "LEFT OUTER JOIN SC6010 SC6  ON SZG.ZG_FILIAL = SC6.C6_FILIAL AND SUBSTRING(SZG.ZG_PEDIDO,3,6) = SC6.C6_NUM AND SC6.D_E_L_E_T_ ='' "
cQuery := cQuery + "LEFT OUTER JOIN SB1010 SB1  ON SC6.C6_FILIAL = SB1.B1_FILIAL AND SC6.C6_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ ='' "
cQuery := cQuery + "LEFT OUTER JOIN SB2010 SB2  ON SB1.B1_FILIAL = SB2.B2_FILIAL AND SB1.B1_COD = SB2.B2_COD AND SB1.B1_LOCPAD = SB2.B2_LOCAL "
cQuery := cQuery + "AND SB2.D_E_L_E_T_ ='' "
cQuery := cQuery + "LEFT OUTER JOIN SB2010 SB21 ON SB1.B1_FILIAL = SB21.B2_FILIAL AND SB1.B1_COD = SB21.B2_COD AND SB21.B2_LOCAL ='03' "
cQuery := cQuery + "AND SB21.D_E_L_E_T_ ='' "
cQuery := cQuery + "LEFT OUTER JOIN SB2010 SB22 ON SB1.B1_FILIAL = SB22.B2_FILIAL AND SB1.B1_COD = SB22.B2_COD AND SB22.B2_LOCAL ='30' " 
cQuery := cQuery + "AND SB22.D_E_L_E_T_ ='' "
cQuery := cQuery + "LEFT OUTER JOIN SB2010 SB23 ON SB1.B1_FILIAL = SB23.B2_FILIAL AND SB1.B1_COD = SB23.B2_COD AND SB23.B2_LOCAL ='P1' "
cQuery := cQuery + "AND SB23.D_E_L_E_T_ =''  "
cQuery := cQuery + "LEFT OUTER JOIN SB2010 SB24 ON SB1.B1_FILIAL = SB24.B2_FILIAL AND SB1.B1_COD = SB24.B2_COD AND SB24.B2_LOCAL ='P2' " 
cQuery := cQuery + "AND SB24.D_E_L_E_T_ ='' "
cQuery := cQuery + "WHERE SZG.D_E_L_E_T_ = ''  AND SC6.C6_NOTA ='' AND SB2.B2_LOCALIZ ='' "
cQuery := cQuery + "AND LEN(SC6.C6_PRODUTO)=12 "
cQuery := cQuery + "AND SZG.ZG_FILIAL BETWEEN "+ MV_PAR01 +" AND "+ MV_PAR02 +" "
CQuery := cQuery + "AND SZG.ZG_CODIGO BETWEEN "+ MV_PAR03 +" AND "+ MV_PAR04 +" "
cQuery := cQuery + "AND SB1.B1_TIPO ='PA' AND SUBSTRING(SC6.C6_PRODUTO,4,2)<>'55' "
cQuery := cQuery + "GROUP BY SZG.ZG_FILIAL, SZG.ZG_CODIGO, SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_FILIAL,SB21.B2_QATU, SB22.B2_QATU,SB23.B2_QATU, SB24.B2_QATU, SB2.B2_SALPEDI "
cQuery := cQuery + "ORDER BY PRODUTO "

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
     //   "BORDERO    PRODUTO                DESCRICAO	                             TOTALVENDIDO        SALDOTOTAL   OP EM ABERTO    03      30      P1      P2"     
     //     Result:=(TCQ->SALDOTOTAL + TCQ->OPEMABERTO - TCQ->TOTALVENDIDO)       tirado porque se tem OP em aberto nЦo pode reformular
          if ((TCQ->TOTALVENDIDO > TCQ->SALDOTOTAL) .AND. (TCQ->OPEMABERTO = 0))
     //     If Result < 0          faz parte do if acima inibido
           @ _nLin,000 PSAY Alltrim(TCQ->BORDERO)         Picture "@E 999999"
           @ _nLin,010 PSAY Alltrim(TCQ->PRODUTO)         Picture "@R XXX99.99.999-99"
           @ _nlin,030 PSAY Substr(TCQ->DESCRICAO, 1, 38) Picture "@!"
           @ _nlin,071 PSAY TCQ->TOTALVENDIDO             Picture "@E 9,999,999"
           @ _nlin,091 PSAY TCQ->SALDOTOTAL               Picture "@E 9,999,999"
           @ _nlin,104 PSAY TCQ->OPEMABERTO               Picture "@E 999,999"  
           @ _nlin,116 PSAY TCQ->P03                      Picture "@E 999,999"  
           @ _nlin,124 PSAY TCQ->P30                      Picture "@E 999,999"  
           @ _nlin,132 PSAY TCQ->P1                       Picture "@E 999,999"  
           @ _nlin,140 PSAY TCQ->P2                       Picture "@E 999,999"  
            _nlin++  
           DbSelectArea("TCQ")  
          Endif
           DbSkip()
     EndDo

     Roda(cbcont,cbtxt,tamanho)

     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё                      FIM DA IMPRESSAO                        Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     DbSelectArea("TCQ")
     DbCloseArea()

     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        DbCommitAll()
        ourspool(wnrel)
     Endif

Return
