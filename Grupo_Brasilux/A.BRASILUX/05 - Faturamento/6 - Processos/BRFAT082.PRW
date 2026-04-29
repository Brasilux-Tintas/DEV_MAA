#include "protheus.ch"
#include "topconn.ch"
#Include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#INCLUDE "AP5MAIL.CH" 


#Translate MSGBOX( => IW_MsgBox(
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT082 ºAutor  ³ Cleber O. Dominguesº Data ³  10/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para gravar no cadastro de produtos o campo B1_VEND º±±
±±º          ³ o valor 'N' indicando que o produto não pode ser vendido   º±±
±±º          ³ para os produtos sem faturamento há mais de mv_par01 dias. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

// PROGRAMA REMODELADO PARA ATENDER O CHAMADO 025708 ABERTO POR FILIPE
// ATUALIZADO ANDRÉ MAESTER EM 09-03-2022
*/
User Function BRFAT082()
       
       Local cCadastro := OemToAnsi("Bloquear produtos sem movimentação")
       Local nOpca     := 0
       Local aSays     := {}
       Local aButtons  := {}
       Private mv_par01
       Private qtdias  := GETMV("ZP_PAR0350")
       
       aAdd(aSays, "Esta rotina fará o Bloqueio do produto e marcará o campo Não Vender")
       aAdd(aSays, "para os produtos que estiverem com as seguintes condições :")
       aAdd(aSays, "")
       aAdd(aSays, " 1 ) Não conter estoque ")
       aAdd(aSays, " 2 ) Não conter pedidos em aberto ")
       aAdd(aSays, " 3 ) Não ter venda nos últimos "+cValToChar(qtdias)+" dias ")
       aAdd(aSays, " Esta rotina só processa itens Não Estoque ")

       If !u_VldAcesso(funname())
              MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
              Return 
       Endif      

       Pergunte("BRFT82", .F.)      

       aAdd(aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() }} )
       aAdd(aButtons, { 2, .T., {|o| nOpca := 2, o:oWnd:End() }} )

       FormBatch( cCadastro, aSays, aButtons )

       If nOpcA == 1
              Processa( { || FAT082_0() }, "Aguarde..." )
              MsgBox("Produtos bloqueados, enviado e-mail com os itens !", "Informacão...", "INFO")
       Endif
Return  

Static Function FAT082_0()
       
       Local cPara     := ""
       Local cAssunto  := "PRODUTOS BLOQUEADOS POR FALTA DE MOVIMENTAÇÃO E ESTOQUE ZERO "
       Local cMsg	  := ""
       Local cQuery    := ""
       
       Local nTotal    := 0       
       Local nAtual    := 0
       Local _aVetor   := {}
       Private lMsErroAuto    := .F.
       Private lMsHelpAuto    := .F.

       cQuery := " WITH TMP AS( "
       cQuery += " SELECT B1_FILIAL AS 'FILIAL', B1_COD AS 'CODIGO', B1_DESC AS 'DESCRICAO', B1_TIPO AS 'TIPO',  "
       cQuery += " CASE WHEN DATEDIFF(DAY,(SELECT TOP 1 D2_EMISSAO FROM "+RetSqlName("SD2")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (D2_FILIAL = B1_FILIAL) AND (D2_ESTOQUE = 'S') AND (D2_COD = SB1.B1_COD) ORDER BY R_E_C_N_O_ DESC),GETDATE()) < "+TRANSFORM(qtdias,'@E 9999')+" THEN 1 ELSE 0 END AS 'MESESSEMSAIDA', 0 AS 'TEMESTOQUE', 0 AS 'PEDIDOEMABERTO' "
       cQuery += " FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
       cQuery += " WHERE SB1.D_E_L_E_T_ ='' "
       cQuery += " AND B1_FILIAL ='"+Xfilial("SB1")+"'"
       cQuery += " AND B1_TIPO ='PA' "
       cQuery += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') "
       cQuery += " AND B1_MSBLQL <>'1' "
       cQuery += " AND B1_ESTOQUE <>'S' "
       cQuery += " UNION ALL "
       cQuery += " SELECT C6_FILIAL AS 'FILIAL', C6_PRODUTO AS 'CODIGO', B1_DESC AS 'DESCRICAO', B1_TIPO AS TIPO, 0 AS 'MESESSEMSAIDA', 0 AS 'TEMESTOQUE', CASE WHEN C6_PRODUTO <>'' THEN 1 ELSE 0 END AS 'PEDIDOEMABERTO' "
       cQuery += " FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
       cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "
       cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC5.D_E_L_E_T_ ='' "
       cQuery += " WHERE SC6.D_E_L_E_T_ ='' "
       cQuery += " AND B1_FILIAL ='"+Xfilial("SB1")+"'"
       cQuery += " AND B1_TIPO ='PA' "
       cQuery += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') "
       cQuery += " AND B1_MSBLQL <>'1' "
       cQuery += " AND B1_ESTOQUE <>'S' "       
       cQuery += " AND C6_NOTA ='' "
       cQuery += " AND DATEDIFF(DAY,C5_EMISSAO,GETDATE())< "+TRANSFORM(qtdias,'@E 9999')+" 
       cQuery += " AND C5_TIPO ='N' "
       cQuery += " UNION ALL "
       cQuery += " SELECT B2_FILIAL AS 'FILIAL', B2_COD AS 'CODIGO', B1_DESC AS 'DESCRICAO', B1_TIPO AS 'TIPO',  0 AS 'MESESSEMSAIDA', CASE WHEN SUM(B2_QATU) <>0 THEN 1 ELSE 0 END AS 'TEMESTOQUE', 0 AS 'PEDIDOEMABERTO' "
       cQuery += " FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
       cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = B2_FILIAL AND B1_COD = B2_COD AND SB1.D_E_L_E_T_ ='' "
       cQuery += " WHERE SB2.D_E_L_E_T_ =''
       cQuery += " AND B1_FILIAL ='"+Xfilial("SB1")+"'"
       cQuery += " AND B1_TIPO ='PA' "
       cQuery += " AND B1_GRUPO BETWEEN('PA00') AND ('PA99') "
       cQuery += " AND B1_MSBLQL <>'1' "
       cQuery += " AND B1_ESTOQUE <>'S' "       
       cQuery += " AND B2_QATU <>0 "
       cQuery += " AND B2_LOCAL IN('03','30','G3','P1','P2','R0','D1','KT','A3') "
       cQuery += " GROUP BY B2_FILIAL, B2_COD, B1_DESC, B1_TIPO) "
       cQuery += " SELECT ROW_NUMBER() OVER(ORDER BY CODIGO DESC) AS 'LINHA', FILIAL, CODIGO, DESCRICAO, SUM(MESESSEMSAIDA) AS MESESSEMSAIDA, SUM(TEMESTOQUE) AS TEMESTOQUE, SUM(PEDIDOEMABERTO) AS PEDIDOEMABERTO "
       cQuery += " FROM TMP "
       cQuery += " GROUP BY FILIAL, CODIGO, DESCRICAO " 
       cQuery += " HAVING SUM(MESESSEMSAIDA) =0 AND SUM(TEMESTOQUE) =0 AND SUM(PEDIDOEMABERTO) =0 "
       cQuery += " ORDER BY CODIGO ASC "

	TcQuery cQuery ALIAS "TM1" NEW   
	DbSelectArea("TM1")        

   	If TM1->(eof()) 
              TM1->(DbCloseArea()) 
              MessageBox( "Não existe produtos a serem bloqueados...", "Atenção", 48 )
              Return()
       EndIf		

       nTotal := TM1->LINHA
       ProcRegua( nTotal )

       cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font-size='1'>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FILIAL</th>"
       cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>"
	
	cMsg+="</tr>"
       DbSelectArea("TM1")
       While TM1->(!eof())
              nAtual++

              IncProc( "Bloqueando Produtos " + Alltrim( TM1->CODIGO ) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")..." )
		
              If SB1->( DbSeek( xFilial("SB1") + TM1->CODIGO ) )
                     _aVetor := {}
                     _aVetor := {  { "B1_COD"      , TM1->CODIGO , NIL },;
                                   { "B1_VEND"     , 'N' , NIL },;
                                   { "B1_MSBLQL"   , '1' , NIL } }

                     MSExecAuto( { | x, y | Mata010( x , y ) }, _aVetor, 4 )
                     If lMsErroAuto
                            //MostraErro()
                     Else
                            cMsg+="<tr>"
                            cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->FILIAL+"</td>"
                            cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->CODIGO+"</td>"
                            cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->DESCRICAO+"</td>"
                            cMsg+="</tr>" 
                     Endif
              Endif
              TM1->(dbSkip())
       EndDo

	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>BRFAT082</p>"
	cMsg+="</footer>"
       cMsg+="</body>"
       cMsg+="</html>" 

       If TM1->FILIAL == "010101"
              cPara := "pcp@brasilux.com.br;andre@brasilux.com.br"
       Elseif TM1->FILIAL =="060101"
              cPara := "silene@brasilux.com.br;andre@brasilux.com.br"//"silene@brasilux.com.br"
       Endif

       DbSelectArea("TM1")
       DbCloseArea() 

       U_EnvMail(cAssunto, cMsg, cPara)

Return
