
#include "topconn.ch"
#include "protheus.ch"
#include 'font.ch' 
#INCLUDE "avprint.ch"
#include 'totvs.ch'
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ZPCPAX4  บ Autor ณ Andr้ Maester      บ Data ณ  30/07/25   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera Ordens de produ็ใo por ponto de pedido.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ZPCPAX4()     
   
   
   Private _cUser
   Private cPerg
   Private cTitulo
   Private lPerg
   Private oDlg2
   Private lJaFech         := .f.
   Private lTelaJaFechada  := .f.
   
   Private aGerTxt         := {}
   Private cUltCod 
   Private oTempTbl1
   Private oTempTbl01
   //Private xLotes          

   Private aCampos := { {"MARCA"         ,"C",02,0},;
                        {"FLAG"          ,"C",01,0},;
                        {"PRODUTO"       ,"C",15,0},;    
                        {"DESCRICAO"     ,"C",40,0},;    
                        {"LOCPAD"        ,"C",09,0},;     
                        {"PPEDIDO"       ,"N",08,0},;     
                        {"ESTSEGURA"     ,"N",08,0},;                             
                        {"LOTEECON"      ,"N",08,0},;                                                     
                        {"LOTEMIN"       ,"N",08,0},;   
                        {"ESTMAX"        ,"N",08,0},;  
                        {"PRAZOPROD"     ,"N",03,0},;                                                                                                                           
                        {"SALDODISP"     ,"N",08,0},;                        
                        {"SALDOTOTAL"    ,"N",08,0},;                        
                        {"OPSABERTO"     ,"N",08,0},;                        
                        {"QPRODUZIR"     ,"N",10,2},;                        
                        {"QTDOPS"        ,"N",08,0},;
                        {"VOLUMES"       ,"N",08,0},;   
                        {"DESCEMB"       ,"C",10,0},;   
                        {"PROD_PI"       ,"C",15,0}}   

   Private aCpoBro := { {"MARCA"          ,OemToAnsi("")               ,""             },;
                        {"PRODUTO"        ,OemToAnsi("Produto")        ,"XXXXXXXXXXXX" },;
                        {"DESCRICAO"      ,OemToAnsi("Descri็ใo")      ,"@!"           },;
                        {"LOCPAD"         ,OemToAnsi("Loc Prod")       ,"@!"           },; 
                        {"PPEDIDO"        ,OemToAnsi("Ponto Pedido")   ,"99999999"     },; 
                        {"ESTSEGURA"      ,OemToAnsi("Estoq. Seg.")    ,"99999999"     },;
                        {"LOTEECON"       ,OemToAnsi("Lote Econo.")    ,"99999999"     },;
                        {"LOTEMIN"        ,OemToAnsi("Lote Minimo")    ,"99999999"     },;
                        {"ESTMAX"         ,OemToAnsi("Estoq. Max.")    ,"99999999"     },;
                        {"PRAZOPROD"      ,OemToAnsi("Prazo Prod")     ,"999"          },;
                        {"SALDODISP"      ,OemToAnsi("Saldo Dispo")    ,"99999999"     },;
                        {"SALDOTOTAL"     ,OemToAnsi("Saldo Total")    ,"99999999"     },;
                        {"OPSABERTO"      ,OemToAnsi("Ops em aberto")  ,"99999999"     },;
                        {"QPRODUZIR"      ,OemToAnsi("Necessidade")    ,"99999999"     },;
                        {"QTDOPS"         ,OemToAnsi("Qtde Ops")       ,"99999999"     },;
                        {"VOLUMES"        ,OemToAnsi("Volumes")        ,"99999999"     }}
   
   Private aLote  :=  { { "LOTE"         ,"C",06,0 }}   

   u_zcfga01( 'ZPCPAX4' ) // Grava็ใo de log de utiliza็ใo da rotina
   
   _cUser := alltrim(upper(cUsername))

	 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	 //ณ Cria indice condicional									  ณ
	 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   If ChkFile("PCPX")
      DbSelectArea("PCPX")
   Endif

   oTempTbl1 := FWTemporaryTable():New( 'PCPX' )
   oTempTbl1:SetFields( aCampos )
   oTempTbl1:Create()

   If ChkFile("XLOTES")
      DbSelectArea("XLOTES")
   Endif

   //xLotes := GetNextAlias()
   oTempTbl01 := FWTemporaryTable():New( 'XLOTES' )
   oTempTbl01:SetFields( aLote )
   oTempTbl01:Create()

   /********************************************************************************************************************************/
   cPerg   := "PCP076"
   cTitulo := OemToAnsi("Gera็ใo de Ops por Ponto de Pedido")
   PCP0762()
   oTempTbl1:Delete()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ PCP0761  บ Autor ณ Andr้ Maester      บ Data ณ  01/08/25   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para busca das informacoes.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PCP0761()

   Local cQry1     := ""
   Local nNeces    := 0
   Local nSaldo    := 0
   Local cCond     := ""
   Private cMarca  := GetMark()

   If ChkFile("PCPX")
      DbSelectArea("PCPX")
      ZAP  
	Endif    

   If (lChkA =.F.) .and. (lChkB =.F.) .and. (lChkC =.F.) 
      MsgAlert("Escolha uma das op็๕es de filtro (Produtos Curva A / B ou C) !!","Atencใo!")
      Return Nil
   Endif

   cQry1 := " " 
   cQry1 += " SELECT '"+cMarca+"' AS MARCA, B1_TIPO, Z5_DESCR AS 'DESCEMB', B1_COD AS PRODUTO, B1_DESC AS DESCRICAO, B1_EMIN AS 'PONTOPEDIDO', B1_ESTSEG AS 'ESTOQUESEGURANCA', B1_LE AS 'LOTEECONOMICO', B1_LM AS 'LOTEMINIMO', B1_EMAX AS 'ESTOQUEMAXIMO', SUM(B2_QATU) AS 'TOTALESTOQUE', "
   cQry1 += " B1_PRODSBP AS 'ATENDENECESSIDADE', B1_PE AS 'PRAZOPRODUCAO', B1_MRP AS 'MRP', B5_DIASES AS 'DIASESTSEG', B3_CLASSE AS 'CLASSEP' , ZZ2_CLASSE AS 'CLASSEC', "
   cQry1 += " CASE WHEN SUM(B2_SALPEDI) <0 THEN 0 ELSE SUM(B2_SALPEDI) END AS 'OPSABERTO', SUM(B2_RESERVA) AS 'RESERVA', dbo.DetVol(B1_FILIAL, B1_COD) AS VOLUME, CASE WHEN B1_LOCPAD IN('02','P1') THEN 'FABRICA 1' ELSE 'FABRICA 2' END AS LOCPAD, G1_COMP AS PROD_PI"
   cQry1 += " FROM SB1010 SB1 WITH (NOLOCK)  "
   cQry1 += " LEFT OUTER JOIN "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) ON B1_FILIAL = G1_FILIAL AND B1_COD = G1_COD AND SUBSTRING(G1_COMP,1,10) = SUBSTRING(B1_COD,1,10) AND SUBSTRING(G1_COMP,11,2) IN('00','99') AND SG1.D_E_L_E_T_ ='' "
   cQry1 += " LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON Z5_FILIAL = Z5_FILIAL AND Z5_EMB = SUBSTRING(B1_COD,11,2) AND SZ5.D_E_L_E_T_ ='' "
   cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ ='' "
   cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB5")+" SB5 WITH (NOLOCK) ON B5_FILIAL = B1_FILIAL AND B1_COD = B5_COD AND SB5.D_E_L_E_T_ ='' "
   cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB3")+" SB3 WITH (NOLOCK) ON B3_FILIAL = B1_FILIAL AND B3_COD = B1_COD AND SB3.D_E_L_E_T_ ='' "
   cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZ2")+" ZZ2 WITH (NOLOCK) ON ZZ2_FILIAL = B1_FILIAL AND ZZ2_COD = B1_COD AND ZZ2.D_E_L_E_T_ ='' "
   cQry1 += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
   cQry1 += " AND B1_TIPO ='PA' AND LEN(B1_COD)=12 "
   cQry1 += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') "
   cQry1 += " AND B1_MRP ='S'  "
   cQry1 += " AND B1_EMIN <> 0 "
   cQry1 += " AND B1_PRODSBP ='P' "
   If lChkF1 
      cCond := " AND B1_LOCPAD IN('02','P1') " 
   Elseif lChkF2 
      cCond := " AND B1_LOCPAD IN('20','P2') " 
   Endif   
   //cQry1 += " AND B1_COD IN('TN 710041605','BT 011500405','AG 100010003') "
   //cQry1 += " AND B1_COD IN('AG 100010003') "
   cQry1 += " AND B2_LOCAL IN('P1','P2','03','A3','G3') "
   If lChkA 
      cCond += " AND ZZ2_CLASSE ='A' " 
   Elseif lChkB 
      cCond += " AND ZZ2_CLASSE ='B' " 
   Elseif lChkC
      cCond += " AND ZZ2_CLASSE IN('C') " 
   Endif   
   cQry1 += +cCond
   cQry1 += " GROUP BY B1_FILIAL, B1_LOCPAD, B1_COD, Z5_DESCR, B1_DESC, B1_CONV, B1_EMIN, B1_ESTSEG, B1_LE, B1_LM, B1_EMAX, B1_PRODSBP, B1_PE, B1_MRP, B5_DIASES, B1_TIPO, B3_CLASSE, ZZ2_CLASSE, G1_COMP "
   cQry1 += " ORDER BY SUBSTRING(B1_COD,4,2),B1_PE, B1_COD "

   TCQUERY cQry1 NEW ALIAS "TPCP"
   DbSelectArea("TPCP")
   DbGoTop()
   ProcRegua(100)
      
   If (TPCP->(EOF()))
		TPCP->(DbCloseArea())
      MsgAlert("Nใo existem produtos cadastrados com necessidade de produ็ใo maior que zero !!","Atencao!")
      Return Nil
   EndIf
   
   While !Eof()
      IncProc("Selecionando registro conforme parametros.")
      nSaldo :=0
      nNeces :=0
      RecLock("PCPX",.t.)
         PCPX->MARCA             := TPCP->MARCA
         PCPX->PRODUTO           := TPCP->PRODUTO
         PCPX->PROD_PI           := TPCP->PROD_PI
         PCPX->DESCEMB           := TPCP->DESCEMB
         PCPX->DESCRICAO         := TPCP->DESCRICAO
         PCPX->LOCPAD            := TPCP->LOCPAD
         PCPX->PPEDIDO           := TPCP->PONTOPEDIDO
         PCPX->ESTSEGURA         := TPCP->ESTOQUESEGURANCA
         PCPX->LOTEECON          := TPCP->LOTEECONOMICO
         PCPX->LOTEMIN           := TPCP->LOTEMINIMO
         PCPX->PRAZOPROD         := TPCP->PRAZOPRODUCAO
         PCPX->ESTMAX            := TPCP->ESTOQUEMAXIMO
         PCPX->SALDODISP         := (TPCP->TOTALESTOQUE-TPCP->RESERVA)//TPCP->TOTALSEPARADO)
         PCPX->SALDOTOTAL        := TPCP->TOTALESTOQUE
         PCPX->OPSABERTO         := TPCP->OPSABERTO
         nSaldo                  := (TPCP->TOTALESTOQUE +  TPCP->OPSABERTO)- TPCP->RESERVA   
         Do Case
         Case nSaldo < 0
            nNeces := Abs(nSaldo) + TPCP->PONTOPEDIDO
         Case ( nSaldo == TPCP->PONTOPEDIDO ) .And. (TPCP->PONTOPEDIDO > 0 ) 
            nNeces := 1
         OtherWise
            nNeces := TPCP->PONTOPEDIDO - nSaldo
         EndCase         
         If nSaldo < TPCP->PONTOPEDIDO
            nNeces += 1
         EndIf
         nNeces += TPCP->ESTOQUESEGURANCA
         PCPX->QPRODUZIR      := nNeces
         If  TPCP->LOTEECONOMICO > 0 .and. PCPX->QPRODUZIR  > 0 //(TPCP->LOTEECONOMICO+TPCP->RESERVA) + (TPCP->PONTOPEDIDO+TPCP->ESTOQUESEGURANCA) >0 
            PCPX->QTDOPS      := CEILING((PCPX->QPRODUZIR) / (TPCP->LOTEECONOMICO))
            If VAL(TPCP->VOLUME) >0 .and. (PCPX->QTDOPS) >0
               PCPX->VOLUMES  := CEILING((PCPX->QTDOPS * TPCP->LOTEECONOMICO) / VAL(TPCP->VOLUME))
            Else
               PCPX->VOLUMES  := 0
            Endif
         Else
            PCPX->QTDOPS      := 0
            PCPX->VOLUMES     := 0
         Endif
      MsUnLock()

      DbSelectArea("TPCP")
      DbSkip()
   Enddo

   DbSelectArea("TPCP")
   DbCloseArea()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ PCP0762  บ Autor ณ Andr้ Maester      บ Data ณ  01/08/25   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para mostrar dados na tela do usuario.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function PCP0762()       
   
   Local ocVolPes
   Private nQtdOp :=0
   Private nVolTot :=0
   Private onVolTot 
   Private onQtdOp

   Private lChkA   := .F.   
   Private lChkB   := .F. 
   Private lChkC   := .F.
   Private lChkF1  := .F. 
   Private lChkF2  := .F.


   SetPrvt("oFont","oGrp1Lib","oSay1Lib","oGet1Lib","oSay2Lib","oSay2Lib","oGet2Lib","onDtLib1","onDtLib2","oBtn1","oBtn2","oBtn3","oChkF1","oChkF2")
   oFont   := TFont():New( "MS Sans Serif", 0, -12, , .T., 0, , 700, .F., .F., , , , , , )

   DbSelectArea("PCPX")
   DbGoTop()

   
   @ 010,012 To 710,1080 Dialog oDlg2 Title OemToAnsi("Consulta / Gera็ใo de OPs por Ponto de Pedido") 
   //@ 004,004 Say   ocDtLib1 Var "Pedidos liberados at้:"  Size 118, 007 COLOR CLR_BLACK   PIXEL OF oDlg2 FONT oFont
   //@ 003,085 MsGet onDtLib2 Var dDtLib2      Picture '@ 99/99/9999'        Size 050, 008 COLOR CLR_HBLUE  WHEN .T. PIXEL OF oDlg2 FONT oFont
   //oCBxFil   := TGet():New( 003, 283, {|u| If(PCount() > 0, cCBxFil := u, cCBxFil)}, oDlg2, 020, 008, '', , CLR_BLACK, CLR_WHITE, oFont, , , .T., "", , , .F., .F., , .F., .F., "98"   , "cCBxFil", , ) //Cod Regiใo
   //oCBxFil:bValid := { || fVRegiao() }
   //oCBxFil1  := TGet():New( 003, 320, {|u| If(PCount() > 0, cCBxFil1 := u, cCBxFil1)}, oDlg2, 120, 008, '', , CLR_BLACK, CLR_WHITE, oFont, , , .T., "", , , .F., .F., , .T. , .F., ""  , "cCBxFil1", , ) //Regiใo
   @ 002,105 CHECKBOX oChkA  VAR lChkA PROMPT OemToAnsi("CURVA A")  SIZE 050,14  OF oDlg2 Pixel On Click fMChkbox()
   @ 002,155 CHECKBOX oChkB  VAR lChkB PROMPT OemToAnsi("CURVA B")  SIZE 050,14  OF oDlg2 Pixel On Click fMChkbox()
   @ 002,195 CHECKBOX oChkC  VAR lChkC PROMPT OemToAnsi("CURVA C")  SIZE 050,14  OF oDlg2 Pixel On Click fMChkbox()

   @ 002,040 CHECKBOX oChkF1  VAR lChkF1 PROMPT OemToAnsi("FABRICA 1")  SIZE 055,14  OF oDlg2 Pixel On Click fFabrica()
   @ 012,040 CHECKBOX oChkF2  VAR lChkF2 PROMPT OemToAnsi("FABRICA 2")  SIZE 055,14  OF oDlg2 Pixel On Click fFabrica()

   oBtn1 := TButton():New( 010, 485, "Carregar Produtos", oDlg2, {|| fCalcVBo()   }, 050, 012, , , , .T., , "", , , , .F. )
   oBtn2 := TButton():New( 310, 405, "Relat๓rio", oDlg2, {|| PCP0765()   }, 040, 012, , , , .T., , "", , , , .F. )
   oBtn3 := TButton():New( 310, 450, "Gera Ops" , oDlg2, {|| PCP0763()   }, 040, 012, , , , .T., , "", , , , .F. )

   @ 310,170 Say   ocVolPes Var "TOTAL OPS    VOLUMES"        Size 095, 007 COLOR CLR_BLACK               PIXEL OF oDlg2 FONT oFont
   @ 325,175 MsGet onQtdOp Var nQtdOp      Picture '@E 9999999'    Size 040, 008 COLOR CLR_HBLUE  WHEN .F.   PIXEL OF oDlg2 FONT oFont
   @ 325,225 MsGet onVolTot Var nVolTot    Picture '@E 9999999999' Size 040, 008 COLOR CLR_HBLUE  WHEN .F.   PIXEL OF oDlg2 FONT oFont

   @ 025,003 To 300,525 Browse "PCPX" Fields aCpoBro ENABLE "FLAG" MARK "MARCA"


   Activate Dialog oDlg2 Centered
Return


Static Function fMChkbox()

	If lChkF1
		lChkF2 := .f.
		oChkF1:Refresh()
		oChkF2:Refresh()
	ElseIf lChkF2
		lChkF1 := .f.
		oChkF1:Refresh()
		oChkF2:Refresh()
	Endif

Return

Static Function fFabrica()

	If lChkA
		lChkB := .f.
		lChkC := .f. 
		oChkA:Refresh()
		oChkB:Refresh()
		oChkC:Refresh()
	ElseIf lChkB
		lChkA := .f.
		lChkC := .f. 
		oChkA:Refresh()
		oChkB:Refresh()
		oChkC:Refresh()
	ElseIf lChkC
		lChkB := .f.
		lChkC := .f. 
		oChkA:Refresh()
		oChkB:Refresh()
		oChkC:Refresh()
	Endif

Return

Static Function fCalcVBo()

   DbSelectArea("PCPX")
   ZAP
   PCP0761()

   DbSelectArea("PCPX")
   DbGoTop()

	nQtdOp :=0
	nVolTot :=0

	While !Eof()
      If Marked("MARCA")
         nQtdOp += PCPX->QTDOPS
         nVolTot += PCPX->VOLUMES
      Endif
      DbSelectArea("PCPX")
      DbSkip()
   Enddo
   onQtdOp:Refresh()
   onVolTot:Refresh()
   DbSelectArea("PCPX")
   DbGoTop()
      
Return 

/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ PCP0765  บ Autor ณ Andr้ Maester      บ Data ณ  06/08/25   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao principal para impressao do relatorio.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PCP0765()

   Local aArea        := GetArea()
   Local cArquivo     := "C:\Temp\"+"ZPCPAX4.xml"
   Local _nAtual      := 0
   Local oExcel       := FWMsExcelEx():New()
   Local cNome        := ""

   If lChkA
      cNome := "CURVA A"
   Elseif lChkB
      cNome := "CURVA B"
   Else
      cNome := "CURVA C"
   Endif

   DbSelectArea("PCPX")
   DbGoTop()

   If Eof()
      MsgStop("Nenhum Registro Selecionado..... ", "Aten็ใo")
      Return()
   Else
      //Criando o objeto que irแ gerar o conte๚do do Excel
      //Aba 01 
      oExcel:AddworkSheet(cNome) //Nใo utilizar n๚mero junto com sinal de menos. Ex.: 1-
      //Criando a Tabela   
      ccabecalho := PadR(cNome, 30) + "Data.: " + DTOC(dDataBase) + "   AS   " + Time() + "   GERAวรO DE OPS POR PONTO DE PEDIDO "
      //Criando Colunas
      oExcel:AddTable (cNome,ccabecalho) // Adiciona a tabela 
      oExcel:AddColumn(cNome,ccabecalho,"PRODUTO"             ,1) 
      oExcel:AddColumn(cNome,ccabecalho,"DESCRICAO"           ,1) 
      oExcel:AddColumn(cNome,ccabecalho,"LOC PRODUวรO"        ,1) 
      oExcel:AddColumn(cNome,ccabecalho,"PONTO DE PEDIDO"     ,1) 
      oExcel:AddColumn(cNome,ccabecalho,"EST. SEGURANวA"      ,1)
      oExcel:AddColumn(cNome,ccabecalho,"LOTE ECONO."         ,1)
      oExcel:AddColumn(cNome,ccabecalho,"LOTE MINIMO"         ,1)
      oExcel:AddColumn(cNome,ccabecalho,"EST. MAXIMO"         ,1,2)
      oExcel:AddColumn(cNome,ccabecalho,"PRAZO PROD"          ,1)
      oExcel:AddColumn(cNome,ccabecalho,"SALDO DISP"          ,1,2)
      oExcel:AddColumn(cNome,ccabecalho,"SALDO TOTAL"         ,1,2)
      oExcel:AddColumn(cNome,ccabecalho,"OPS ABERTO"          ,1,2)
      oExcel:AddColumn(cNome,ccabecalho,"QTDE PRODUZIR"       ,1,2)
      oExcel:AddColumn(cNome,ccabecalho,"QTDE LOTES"          ,1,2)
      oExcel:AddColumn(cNome,ccabecalho,"VOLUMES"             ,1,2)

      oExcel:SetCelBold(.T.)
      oExcel:SetCelFont('Arial')
      oExcel:SetCelItalic(.T.)
      oExcel:SetCelUnderLine(.T.)
      oExcel:SetCelSizeFont(10)
      _nAtual           = 0
      While !(PCPX->(EoF()))
         If Marked("MARCA")
            _nAtual++
            oExcel:AddRow(cNome,ccabecalho,{;
            PCPX->PRODUTO,;
            PCPX->DESCRICAO,;
            PCPX->LOCPAD,;
            PCPX->PPEDIDO,;
            PCPX->ESTSEGURA,; 
            PCPX->LOTEECON,; 
            PCPX->LOTEMIN,;
            PCPX->ESTMAX,;
            PCPX->PRAZOPROD,;
            PCPX->SALDODISP,;
            PCPX->SALDOTOTAL,;
            PCPX->OPSABERTO,;
            PCPX->QPRODUZIR,;
            PCPX->QTDOPS,;
            PCPX->VOLUMES;
            })
            oExcel:SetCelBold(.T.)
            oExcel:SetCelFont('Arial')
            oExcel:SetCelItalic(.T.)
            oExcel:SetCelUnderLine(.T.)
            oExcel:SetCelSizeFont(15)
            oExcel:SetCelFrColor("#FFFFFF")
            oExcel:SetCelBgColor("#000666")
         Endif
         PCPX->(DbSkip())
      EndDo  
      
      oExcel:Activate()
      MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oExcel:GetXMLFile(cArquivo) } )
      //Abrindo o excel e abrindo o arquivo xml
      oExcel := MsExcel():New()           //Abre uma nova conexใo com Excel
      oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
      oExcel:SetVisible(.T.)              //Visualiza a planilha
      oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
   Endif

   //PCPX->(DbCloseArea())

RestArea(aArea)

Return


Static Function PCP0763()

   //Local aArea        := GetArea()
   Local _nY           := 0
   Local nConv         := 0
   Local aAreaAnt 	  := U_PegaArea({"SC2"})
   Private _cLote      := ""
   Private dEmissao    := dDataBase
   Private dPrevIni    := dDataBase
   Private dPrevFim    := dDataBase
   Private oLote, oEmissao, oDescric, oPrevIni, oPrevFim, _oProduto, oPrevVol
   Private _CDescEmb   := ""
   Private _cProduto   := ""
   Private _cProd_PI   := ""
   Private cDescric    := ""
   Private _QtdLote    := 0
	Private lRefresh    := .T.
   Private _lSaida     := .f.
   Private cMarca      := ""


   DbSelectArea("PCPX")
   DbGoTop()

   If Eof()
      MsgStop("Nenhum Registro Selecionado..... ", "Aten็ใo")
      Return()
   Endif

      While !(PCPX->(EoF()))
         If Marked("MARCA") .OR. (cMarca == PCPX->MARCA)
            cMarca :=  PCPX->MARCA
            If (PCPX->QTDOPS) > 0
               _QtdPI    := 0
               //_cLote    := U_NumSeqLot("SZZ")
               _cProduto := PCPX->PRODUTO
               _cProd_PI := PCPX->PROD_PI
               _QtdLote  := PCPX->QTDOPS
               cDescric  := PCPX->DESCRICAO
               _cLoteMin := PCPX->LOTEMIN
               _CDescEmb := PCPX->DESCEMB
               dPrevFim  := DaySum(dPrevFim, (PCPX->PRAZOPROD))  
               cRoteiro  := Posicione("SB1", 1, xFilial("SB1")+_cProd_PI, "B1_OPERPAD")
               nConv     := Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_CONV")

               DbSelectArea("SG2")
               DbSetOrder(1)
               DbSeek(xFilial("SG2")+_cProd_PI+cRoteiro, .t.)
               If !Found()
                  MsgBox("Produto "+_cProd_PI+" nใo tem roteiro padrใo de opera็๕es cadastrado. Verifique !", "Informa็ใo...", "INFO")
               Endif
               
               For _nY := 1 to PCPX->QTDOPS
                  If (cNumEmp == "01010101") // Jose 25/03/2025 
                     _cLote := U_NroSqLote("SZZ")  // Jose 25/03/2025
                  Else // Jose 25/03/2025
                     _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                  Endif // Jose 25/03/2025
                  //_cLote    := U_NumSeqLot("SZZ")
                  //_cLote    := NextNumero("SZZ", 1, "ZZ_LOTE", .T.)
                  DbSelectArea(xLotes)
                  RecLock(xLotes, .t.)
                     Replace LOTE with _cLote
                  MsUnLock()
                  
                  DbSelectArea("SZZ")
                  RecLock("SZZ", .t.)
                     SZZ->ZZ_FILIAL  := xFilial("SZZ")
                     SZZ->ZZ_LOTE    := _cLote
                     SZZ->ZZ_DTEMIS  := dEmissao
                     SZZ->ZZ_PRODUTO := _cProduto
                     SZZ->ZZ_DESCR   := cDescric
                     SZZ->ZZ_PREVI   := dPrevIni
                     SZZ->ZZ_PREVF   := dPrevFim
                     SZZ->ZZ_EMB     := Substr(_cProduto,11,2)
                     SZZ->ZZ_DESEMB  := _CDescEmb
                     SZZ->ZZ_QTDETI  := _cLoteMin
                     SZZ->ZZ_PEDIDO  := ""
                     SZZ->ZZ_TPINCL  := "I"
                  MsUnlock()

                  DbSelectArea("SZ5")
                  DbSetOrder(1)
                  DbSeek(xfilial("SZ5")+Substr(_cProduto,11,2),.F.)
                  If Found()
                     DbSelectArea("SG1")
                     DbSetorder(1)
                     DbSeek(xFilial("SG1")+_cProduto, .t.)
                     If !Found()
                        _QtdPI := Round((_cLoteMin * nConv), 2)
                     Else 
                        Do While !(SG1->(EoF())).and. (SG1->G1_FILIAL = xFilial("SG1")) .and. (SG1->G1_COD = _cProduto) 
                           If (SG1->G1_COMP = _cProd_PI)
                              _QtdPI := ((_cLoteMin * SG1->G1_QUANT) / ((100 - SG1->G1_PERDA) / 100))
                           Endif
                           SG1->(DbSkip())
                        Enddo 
                     Endif 
                  Endif
                  DbSelectArea("SC2")
                  CPRODUTO := PCPX->PRODUTO
                  DbSelectArea("SZZ")
                  RecLock("SZZ", .t.)
                     SZZ->ZZ_FILIAL  := xFilial("SZZ")
                     SZZ->ZZ_LOTE    := _cLote
                     SZZ->ZZ_DTEMIS  := dEmissao
                     SZZ->ZZ_PRODUTO := _cProd_PI
                     SZZ->ZZ_DESCR   := cDescric
                     SZZ->ZZ_PREVI   := dPrevIni
                     SZZ->ZZ_PREVF   := dPrevFim
                     SZZ->ZZ_QTDETI  := Round(_QtdPI, 2)
                     SZZ->ZZ_TPINCL  := "I" 
                  MsUnlock()
               Next nY
            Endif
         Endif
         PCPX->(DbSkip())
      EndDo  
      
   Processa({|lEnd| fGerOPs(@aGerTxt) } )
  	If (cNumEmp == "01010101")   // gerar txts somente para Matriz
      Processa({|lEnd| u_fGerTXTOps(aGerTxt) } )
   Endif
   Close(oDlg2)
   //Endif
   //RestArea(aArea)

   U_VoltaArea(aAreaAnt)

Return

/*****************************************************************************************************************/
/*** fGerOPS - Gera as ordens de produ็๕es pelos lotes.                                                        ***/
/*****************************************************************************************************************/
Static Function fGerOPS(aGerTxt)


   Local _cMVXSOLUC := GetMv('MV_XSOLUCA') // Solucoes que ao atingir quantidades superiores a 300 kg na estrutura das formulas, deverao gerar ops automaticamente com a quantidade exata da formula Utilizado Programa BRPCPX04 - Gerar O.P x Lote 
   Local _cMVXSOLU0 := GetMv('MV_XSOLUC0') // Solucoes que ao atingir qualquer quantidade na estrutura das formulas, deverao gerar ops automaticamente com a quantidade exata da formula Utilizado Programa BRPCPX04 - Gerar O.P x Lote     
   Local _cMVXSOLU5 := GetMv('MV_XSOLUC5') // Solucoes que ao atingir quantidades superiores a 500 kg na estrutura das formulas, deverao gerar ops automaticamente com a quantidade exata da formula Utilizado Programa BRPCPX04 - Gerar O.P x Lote
   Local aerro    := ""  // Jose 13/05/2025
   Private lMSErroAuto := .f.
   Private lMSHelpAuto := .t.

   
   //If Select( xLotes ) > 0 
   //   DbCloseArea()
   //EndIf
   //DbSelectArea("XLOTES")
   //DbGoTop()
   //nContReg := RecCount()
   
   //If nContReg > 0
   //   MsgBox("Serใo geradas as Ordens de Produ็๕es junto com as Intermediarias!", "Aten็ใo", "INFO")
   //   ProcRegua(nContReg, 21, 6)
   //Endif
   //nContOcorr := 0

   If Select( xLotes ) > 0 // Jose 26/06/2024

      DbSelectArea(xLotes)
      DbGoTop()

      While !eof()
         cAuxLote = LOTE
         cAuxFilial = xFilial("SZZ")
         DbSelectArea("SZZ")
         DbSeek(cAuxFilial+cAuxLote, .t.)
         While !eof() .and. (cAuxFilial == xFilial("SZZ")) .and. (cAuxLote == SZZ->ZZ_LOTE)
            lVerSol := .f.
            If SZZ->ZZ_FLAG == 'S'
               Dbselectarea("SZZ")
               DbSkip()
               Loop
            Endif
            DbSelectArea("SB1")
            DbSetOrder(1)
            DbSeek(xFilial("SB1")+SZZ->ZZ_PRODUTO)
               If Found()
                  If SB1->B1_TIPO $ "PI"
                     cAutExpl = "S"
                     lVerSol := .t.
                  Else
                     cAutExpl = "N"
                  Endif
                  cRoteiro := Posicione("SB1", 1, xFilial("SB1")+SZZ->ZZ_PRODUTO, "B1_OPERPAD")
                  nQuant2  := IIF(SB1->B1_TIPCONV != "D", (SZZ->ZZ_QTDETI * SB1->B1_CONV), (SZZ->ZZ_QTDETI / SB1->B1_CONV) )
                  If (SZZ->ZZ_PREVI + SB1->B1_PE) > SZZ->ZZ_PREVF
                     dAuxData := SZZ->ZZ_PREVI + SB1->B1_PE
                  Else
                     dAuxData := SZZ->ZZ_PREVF
                  Endif
                  If SZZ->ZZ_TPINCL $ 'C'
                     dAuxData := dDataBase
                  Endif
                  If dAuxData < dDataBase
                     dAuxData := dDataBase
                  Endif 
                  aAutoSC2 := {}
                  aadd(aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 , NIL})
                  aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
                  aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                  aadd(aAutoSC2, {"C2_PRODUTO", SZZ->ZZ_PRODUTO                , NIL})
                  aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                  aadd(aAutoSC2, {"C2_LOCAL"  , SB1->B1_LOCPAD                 , NIL})
                  aadd(aAutoSC2, {"C2_QUANT"  , SZZ->ZZ_QTDETI                 , NIL})
                  aadd(aAutoSC2, {"C2_QTSEGUM", nQuant2                        , NIL})
                  aadd(aAutoSC2, {"C2_UM"     , SB1->B1_UM                     , NIL})
                  aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                  aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                  aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                  aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                  aadd(aAutoSC2, {"C2_LOTE"   , SZZ->ZZ_LOTE                   , NIL})
                  aadd(aAutoSC2, {"C2_PEDIDO" , SubStr(SZZ->ZZ_PEDIDO, 3, 6)   , NIL})
                  aadd(aAutoSC2, {"C2_ITEMPV" , SubStr(SZZ->ZZ_PEDIDO, 1, 2)   , NIL})
                  aadd(aAutoSC2, {"C2_REVI"   , QA_UltRvQ(SZZ->ZZ_PRODUTO,,.F.), NIl})
                  If (cAutExpl == "S") .AND. (Len(Alltrim(SZZ->ZZ_PRODUTO)) == 12)
                     aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                    , NIL})
                  Endif

                  lMsErroAuto := .f.
                  Dbselectarea("SC2")
                  dbsetorder(1)
                  dbseek(xFilial("SC2")) //  jose 06/03/2025 aq1ui esta dando erro
                  MSExecAuto( {|x| MATA650(x)}, aAutoSC2)  
                  aerro := "" // Jose 07/04/2025   jose 13/05/2025
                  If ("C650NOREV" <> aerro) // jose 13/05/2025 saindo em duplicidade o PA quando fazia complemento 
                     DbSelectArea("SZZ")
                     RecLock("SZZ", .f.)
                        SZZ->ZZ_FLAG := 'S'
                     MsUnLock()
                     If SZZ->ZZ_TPINCL == 'C'
                        aAutoSC2 := {}
                        aAutoSC2  := { { 'C2_FILIAL'   , SC2->C2_FILIAL                        , NIL },;
                                       { 'C2_PRODUTO'  , SC2->C2_PRODUTO                       , NIL },;          
                                       { 'C2_NUM'      , SC2->C2_NUM                           , NIL },;          
                                       { 'C2_ITEM'     , SC2->C2_ITEM                          , NIL },;
                                       { 'C2_SEQUEN'   , SC2->C2_SEQUEN                        , NIL },;
                                       { 'C2_OBS'      , "Complemento" + AllTrim( SC2->C2_OBS ), NIL } }
                        msExecAuto( { | x, Y | Mata650( x, Y ) }, aAutoSC2, 4 )
                        If lMsErroAuto
//                             MostraErro()    Jose 07/04/2025
                        EndIf

                        aerro := "" // Jose 21/05/2025
                        If ("C650NOREV" <> aerro) // jose 21/05/2025 saindo em duplicidade o PA quando fazia complemento 
                           DbSelectArea("SZZ") // Jose 21/05/2025
                           RecLock("SZZ", .f.) // Jose 21/05/2025
                              SZZ->ZZ_FLAG := 'S' // Jose 21/05/2025
                           MsUnLock() // Jose 21/05/2025
                        EndIf // Jose 21/05/2025
                     Endif
                     If Substr(Alltrim(SZZ->ZZ_PRODUTO),11, 2) $ '00.99' //.Or. Posicione("SB1", 1, xFilial("SB1")+SZZ->ZZ_PRODUTO, "B1_TIPO") $ 'PI'
                        aAdd(aGerTxt, {SZZ->ZZ_PRODUTO, SZZ->ZZ_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, SC2->C2_QUANT })
                     Endif
                     // VERIFICAR SE EXISTEM SOLUวีES COM QUANTIDADE MAIOR DO QUE 300 KG NA FORMULA. SE EXISTIR DEVE SER GERADO OP COM ESTE CONCENTRADO.
                     If lVerSol        // CHAMADO 000782 - MICHELLY EM 27/10/14
                        cQry1 := ""
                        cQry1 += " SELECT D4_OP,D4_COD,D4_QUANT, C2_QUANT "
                        cQry1 += " FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) " 
                        cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK)  ON SB1.B1_FILIAL = SD4.D4_FILIAL AND SB1.B1_COD = SD4.D4_COD AND SB1.D_E_L_E_T_ ='' "
                        cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK)  ON SD4.D4_FILIAL = SC2.C2_FILIAL AND SD4.D4_OP  = SC2.C2_OP  AND SC2.D_E_L_E_T_ ='' "
                        cQry1 += " WHERE SD4.D4_FILIAL  = '"+xFilial("SD4")+"' "
                        cQry1 += "  AND SD4.D_E_L_E_T_  = '' "
                        cQry1 += "  AND SD4.D4_OP       = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+"' "
                        //cQry1 += "  AND SD4.D4_COD IN ("+GetMv('MV_XSOLUCA')+")"
                        cQry1 += "  AND SD4.D4_COD IN (" + _cMVXSOLUC + ',' + _cMVXSOLU0 + ',' +  _cMVXSOLU5 + ")" 
                        //cQry1 += "  AND SB1.B1_XSOLUCA  = 'S' "
                        TCQuery cQry1 ALIAS "QEMP" NEW 
                        DbSelectArea("QEMP")
                        nQtdCon := QEMP->D4_QUANT
                        nQtdTota:= QEMP->C2_QUANT
                        cCodCon := QEMP->D4_COD
                        DbSelectArea("QEMP")
                        DbCloseArea()
                        If Alltrim(cCodCon) $ Alltrim(_cMVXSOLUC) .and. nQtdTota > 200 .and. !Empty(cCodCon)  // alterado de 300 para 200 conforme chamado 007431
                           nQtdLMi  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
                           nTipCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
                           nFatCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
               	         nQtdCo2  := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                           cUniMed  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
                           cLocPad  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
                           cOpObs   := 'ROT. AUT. OP ORIG.: '+SC2->C2_NUM
                           cRoteiro := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                           If (cNumEmp == "01010101") // Jose 25/03/2025
                              _cLote := U_NroSqLote("SZZ") // Jose 25/03/2025
                           Else // Jose 25/03/2025
                              _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                           Endif // Jose 25/03/2025

                           aAutoSC2 := {}
                           aadd(aAutoSC2, {"C2_FILIAL"  , xFilial("SC2")                , NIL})
                           aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
                           aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                           aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                           aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                           aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
                           aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
                           aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
                           aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
                           aadd(aAutoSC2, {"C2_LOTE"   , _cLote                         , NIL})
                           aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                           aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                           aadd(aAutoSC2, {"C2_OBS"    , cOpObs                         , NIL})																				
                           aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                           aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                           aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                       , NIL})
                           lMsErroAuto := .f.
                           Dbselectarea("SC2")
                           DbSetorder(1)
                           Dbseek(xFilial("SC2"))
                           MSExecAuto( {|x| MATA650(x)}, aAutoSC2)

                           If !lMsErroAuto
                              aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon })
                           Else
   	                       	MostraErro() // ver 07/04/2025
                           Endif
                        Endif 
                        //-------------     Acrescentado Jose 05/09/2024 --------------
                        If Alltrim(cCodCon) $ Alltrim(_cMVXSOLU0) .and. !Empty(cCodCon) 
                           nQtdLMi  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
                           nTipCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
                           nFatCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
                           nQtdCo2  := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                           cUniMed  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
                           cLocPad  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
                           cOpObs   := 'ROT. AUT. OP ORIG.: '+SC2->C2_NUM
                           cRoteiro := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                           If (cNumEmp == "01010101") // Jose 25/03/2025
                              _cLote := U_NroSqLote("SZZ") // Jose 25/03/2025
                           Else // Jose 25/03/2025
                              _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                           Endif // Jose 25/03/2025
                           aAutoSC2 := {}
                           aadd(aAutoSC2, {"C2_FILIAL"  , xFilial("SC2")                , NIL})
                           aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
                           aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                           aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                           aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                           aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
                           aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
                           aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
                           aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
                           aadd(aAutoSC2, {"C2_LOTE"   , _cLote                         , NIL})
                           aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                           aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                           aadd(aAutoSC2, {"C2_OBS"    , cOpObs                         , NIL})																				
                           aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                           aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                           aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                       , NIL})
                           lMsErroAuto := .f.
                           Dbselectarea("SC2")
                           DbSetorder(1)
                           Dbseek(xFilial("SC2"))
                           MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
                           If !lMsErroAuto
                              aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon })
                           Else
                              MostraErro()   //  Ver  Jose 07/04/2025
                           Endif
                        Endif 

                        If Alltrim(cCodCon) $ Alltrim(_cMVXSOLU5) .and. nQtdTota > 500 .and. !Empty(cCodCon) 
                           nQtdLMi  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
                           nTipCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
                           nFatCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
                           nQtdCo2  := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                           cUniMed  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
                           cLocPad  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
                           cOpObs   := 'ROT. AUT. OP ORIG.: '+SC2->C2_NUM
                           cRoteiro := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                           If (cNumEmp == "01010101") // Jose 25/03/2025
                              _cLote := U_NroSqLote("SZZ") // Jose 25/03/2025
                           Else // Jose 25/03/2025
                              _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                           Endif // Jose 25/03/2025
                           aAutoSC2 := {}
                           aadd(aAutoSC2, {"C2_FILIAL"  , xFilial("SC2")                , NIL})
                           aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
                           aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
                           aadd(aAutoSC2, {"C2_PRODUTO", cCodCon                        , NIL})
                           aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
                           aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad                        , NIL})
                           aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon                        , NIL})
                           aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2                        , NIL})
                           aadd(aAutoSC2, {"C2_UM"     , cUniMed                        , NIL})
                           aadd(aAutoSC2, {"C2_LOTE"   , _cLote                         , NIL})
                           aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
                           aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
                           aadd(aAutoSC2, {"C2_OBS"    , cOpObs                         , NIL})																				
                           aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
                           aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
                           aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                       , NIL})
                           lMsErroAuto := .f.
                              
                           Dbselectarea("SC2")
                           DbSetorder(1)
                           Dbseek(xFilial("SC2"))
                           MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
                                          
                           If !lMsErroAuto
                              aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon })
                           Else
                              MostraErro()  //   Ver Jose 07/04/2025
                           Endif
                        Endif 
                     Endif 
                  Else
   //  Jose 20/03/2025      MsgBox("O Produto "+SZZ->ZZ_PRODUTO+" do Lote "+cAuxLote+" nใo foi processado!", "Atencao!", "STOP")
   //  Jose 20/03/2025      MostraErro()
                  Endif
               Endif
               DbSelectArea("SZZ")
               DbSkip()
            Enddo
            DbSelectArea(xLotes)
            DbSkip()
            IncProc()      
      Enddo
   EndIf   //  Jose 26/06/2024
   //If (nContOcorr == 0) .and. (nContReg > 0)
   //   MsgBox("Nenhuma Ocorrencia!", "Aten็ใo", "INFO")
   //endif
Return

/*

   Local _cMVXSOLUC := GetMv('MV_XSOLUCA')
   Private lMSErroAuto := .f.
   Private lMSHelpAuto := .t.
   
   Dbselectarea(xLotes)
   nContReg := RecCount()

   If nContReg > 0
      //MsgBox("Serใo geradas as Ordens de Produ็๕es junto com as Intermediarias!", "Aten็ใo", "INFO")
      ProcRegua(nContReg, 21, 6)
   Endif
   
   nContOcorr := 0
   DbSelectArea(xLotes)
   DbGoTop()
   
   While !eof()
      cAuxLote = LOTE
      cAuxFilial = xFilial("SZZ")
      DbSelectArea("SZZ")
      DbSeek(cAuxFilial+cAuxLote, .t.)
      While !eof() .and. (cAuxFilial == xFilial("SZZ")) .and. (cAuxLote == SZZ->ZZ_LOTE)
         lVerSol := .f.
         If SZZ->ZZ_FLAG == 'S'
            Dbselectarea("SZZ")
            DbSkip()
            Loop
         Endif
         
         DbSelectArea("SB1")
         DbSetOrder(1)
         DbSeek(xFilial("SB1")+SZZ->ZZ_PRODUTO)
         If Found()
            If SB1->B1_TIPO $ "PI"
               cAutExpl = "S"
               lVerSol := .t.
            Else
               cAutExpl = "N"
            Endif
            cRoteiro := Posicione("SB1", 1, xFilial("SB1")+SZZ->ZZ_PRODUTO, "B1_OPERPAD")
            nQuant2  := IIF(SB1->B1_TIPCONV != "D", (SZZ->ZZ_QTDETI * SB1->B1_CONV), (SZZ->ZZ_QTDETI / SB1->B1_CONV) )
            If (SZZ->ZZ_PREVI + SB1->B1_PE) > SZZ->ZZ_PREVF
               dAuxData := SZZ->ZZ_PREVI + SB1->B1_PE
            Else
               dAuxData := SZZ->ZZ_PREVF
            Endif
            If dAuxData < dDataBase
               dAuxData := dDataBase
            Endif 
            
            aAutoSC2 := {}
            aadd(aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 , NIL})
            aadd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
            aadd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
            aadd(aAutoSC2, {"C2_PRODUTO", SZZ->ZZ_PRODUTO                , NIL})
            aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
            aadd(aAutoSC2, {"C2_LOCAL"  , SB1->B1_LOCPAD                 , NIL})
            aadd(aAutoSC2, {"C2_QUANT"  , SZZ->ZZ_QTDETI                 , NIL})
            aadd(aAutoSC2, {"C2_QTSEGUM", nQuant2                        , NIL})
            aadd(aAutoSC2, {"C2_UM"     , SB1->B1_UM                     , NIL})
            aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
            aadd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
            aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
            aadd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
            aadd(aAutoSC2, {"C2_LOTE"   , SZZ->ZZ_LOTE                   , NIL})
            aadd(aAutoSC2, {"C2_PEDIDO" , SubStr(SZZ->ZZ_PEDIDO, 3, 6)   , NIL})
            aadd(aAutoSC2, {"C2_ITEMPV" , SubStr(SZZ->ZZ_PEDIDO, 1, 2)   , NIL})
            aadd(aAutoSC2, {"C2_REVI"   , QA_UltRvQ(SZZ->ZZ_PRODUTO,,.F.), NIl})
            If (cAutExpl == "S") .AND. (Len(Alltrim(SZZ->ZZ_PRODUTO)) == 12)
               aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro                    , NIL})
            Endif

            lMsErroAuto := .f.
            Dbselectarea("SC2")
            Dbsetorder(1)
            DbSeek(xFilial("SC2"))
            
            MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
            If !lMsErroAuto
               DbSelectArea("SZZ")
               RecLock("SZZ", .f.)
                  SZZ->ZZ_FLAG := 'S'
               MsUnLock()

               If Substr(Alltrim(SZZ->ZZ_PRODUTO),11, 2) $ '00.99' //.Or. Posicione("SB1", 1, xFilial("SB1")+SZZ->ZZ_PRODUTO, "B1_TIPO") $ 'PI'
                  aAdd(aGerTxt, {SZZ->ZZ_PRODUTO, SZZ->ZZ_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, SC2->C2_QUANT })
               Endif

               nContOcorr++
               // VERIFICAR SE EXISTEM SOLUวีES COM QUANTIDADE MAIOR DO QUE 300 KG NA FORMULA. SE EXISTIR DEVE SER GERADO OP COM ESTE CONCENTRADO.
               If lVerSol        // CHAMADO 000782 - MICHELLY EM 27/10/14
                  cQry1 := ""
                  cQry1 += " SELECT D4_OP,D4_COD,D4_QUANT, C2_QUANT "
                  cQry1 += " FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) " 
                  cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK)  ON SB1.B1_FILIAL = SD4.D4_FILIAL AND SB1.B1_COD = SD4.D4_COD AND SB1.D_E_L_E_T_ ='' "
                  cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK)  ON SD4.D4_FILIAL = SC2.C2_FILIAL AND SD4.D4_OP  = SC2.C2_OP  AND SC2.D_E_L_E_T_ ='' "
                  cQry1 += " WHERE SD4.D4_FILIAL  = '"+xFilial("SD4")+"' "
                  cQry1 += " AND SD4.D_E_L_E_T_  = '' "
                  cQry1 += " AND SD4.D4_OP       = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+"' "
                  cQry1 += " AND SD4.D4_COD IN (" + _cMVXSOLUC + ")" 
                  
                  TCQuery cQry1 ALIAS "QEMP" NEW 
                  DbSelectArea("QEMP")
                  nQtdCon := QEMP->D4_QUANT
                  nQtdTota:= QEMP->C2_QUANT
                  cCodCon := QEMP->D4_COD
                  DbSelectArea("QEMP")
                  DbCloseArea()

                  If nQtdTota > 200 .and. !Empty(cCodCon)  // alterado de 300 para 200 conforme chamado 007431
                     nQtdLMi  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LM")
                     nTipCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_TIPCONV")
                     nFatCon  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_CONV")
               	   nQtdCo2  := IIF(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon) )
                     cUniMed  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_UM")
                     cLocPad  := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_LOCPAD")
                     cOpObs      := 'ROT. AUT. OP ORIG.: ' +SC2->C2_NUM
                     cRoteiro    := Posicione("SB1", 1, xFilial("SB1")+cCodCon, "B1_OPERPAD")
                     
                     If (cNumEmp == "01010101") // Jose 25/03/2025 
                        _cLote := U_NroSqLote("SZZ")  // Jose 25/03/2025
                     Else // Jose 25/03/2025
                        _cLote := U_NumSeqLot("SZZ") // Jose 25/03/2025
                     Endif // Jose 25/03/2025
                     //_cLote      := U_NumSeqLot("SZZ")
                     aAutoSC2    := {}
                     aadd(aAutoSC2, {"C2_FILIAL" , xFilial("SC2"), NIL})
                     aadd(aAutoSC2, {"C2_ITEM"   , "01"          , NIL})
                     aadd(aAutoSC2, {"C2_SEQUEN" , "001"         , NIL})
                     aadd(aAutoSC2, {"C2_PRODUTO", cCodCon       , NIL})
                     aadd(aAutoSC2, {"AUTEXPLODE", cAutExpl      , NIL})
                     aadd(aAutoSC2, {"C2_LOCAL"  , cLocPad       , NIL})
                     aadd(aAutoSC2, {"C2_QUANT"  , nQtdCon       , NIL})
                     aadd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2       , NIL})
                     aadd(aAutoSC2, {"C2_UM"     , cUniMed       , NIL})
                     aadd(aAutoSC2, {"C2_LOTE"   , _cLote        , NIL})
                     aadd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI , NIL})
                     aadd(aAutoSC2, {"C2_DATPRF" , dAuxData      , NIL})
                     aadd(aAutoSC2, {"C2_OBS"    , cOpObs        , NIL})
                     aadd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS, NIL})
                     aadd(aAutoSC2, {"C2_TPOP"   , "F"           , NIL})
                     aadd(aAutoSC2, {"C2_ROTEIRO", cRoteiro      , NIL})
                     lMsErroAuto := .f.

                     Dbselectarea("SC2")
                     DbSetorder(1)
                     Dbseek(xFilial("SC2"))
                     MSExecAuto( {|x| MATA650(x)}, aAutoSC2)
                     If !lMsErroAuto
                        aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon })
                     Else
                        MostraErro()
                     Endif
                  Endif 
               Endif 
            Else
            //   MsgBox("O Produto "+SZZ->ZZ_PRODUTO+" do Lote "+cAuxLote+" nใo foi processado!", "Atencao!", "STOP")
            //   MostraErro()
            Endif
         Endif
         DbSelectArea("SZZ")
         DbSkip()
      Enddo
      DbSelectArea(xLotes)
      DbSkip()
      IncProc()      
   Enddo
   If (nContOcorr == 0) .and. (nContReg > 0)
      MsgBox("Nenhuma Ocorrencia!", "Aten็ใo", "INFO")
   Endif
   
   // Apagar Arq. Temporแrio
   DbSelectArea(xLotes)
   DbCloseArea( )

   //oTempTbl01:Delete()  

Return
