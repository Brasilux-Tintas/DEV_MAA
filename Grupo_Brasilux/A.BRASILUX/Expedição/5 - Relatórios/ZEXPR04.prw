//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "Avprint.ch"
#include 'font.ch'
#include 'totvs.ch'

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} TESTXCEL
Função que cria arquivo de FWMsExcel
@author Atilio
@since 26/07/2022
@version 1.0
    @example_cPerg
    u_ZEXPR04()
/*/

User Function ZEXPR04()
    Local _cPerg       := "ZEXPR04   "  
    Private MV_Par01
    

    if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  	endif 

    If !Pergunte( _cPerg ) 
      Return() //Se cancelar as perguntas sai do programa
    Endif

    /* nelider - crie função para utilizar a tela de progress para o usuário */ //
    MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Aguarde...   Processando Registros...,")
   
Return    

/* nelider - crie função para utilizar a tela de progress para o usuário */
Static Function Imprimir()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cQuery1      := ""
    Local oFWMsExcel
    Local oExcel
//  Local cArquivo     := GetTempPath()+'ZEXPR04.xml'
    Local cArquivo     := "C:\Temp\"+"ZEXPR04.xml"

    Local nTotal       := 0
    Local nAtual       := 0

    //  Gerando total registro
    cQuery1 := "SELECT COUNT(*) AS 'Total' " + STR_PULA
    cQuery1 += "FROM   "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) " + STR_PULA
    cQuery1 += " WHERE  SC5.D_E_L_E_T_ ='' AND C5_FILIAL ='010101' AND C5_NOTA ='' AND (C5_EMISSAO > '"+Dtos(mv_par01)+"') AND C5_FLAG ='S' " + STR_PULA
 
    TCQuery cQuery1 New Alias "QRYQTD" 

    //Pegando os dados
    cQuery := "SELECT  ISNULL(ZG_CODIGO,'') AS 'BORDPEDIDO',ISNULL(ZB_CODIGO,'') AS 'BORDDESPACHO', C5_NUM AS 'PEDIDO', " + STR_PULA
    cQuery += "        SUBSTRING(C5_PEDPROG,7,2) + '/' + SUBSTRING(C5_PEDPROG,5,2) + '/' + SUBSTRING(C5_PEDPROG,1,4) AS 'PROGRAMADO', " + STR_PULA
    cQuery += "        SUBSTRING(C5_EMISSAO,7,2) + '/' + SUBSTRING(C5_EMISSAO,5,2) + '/' + SUBSTRING(C5_EMISSAO,1,4) AS 'EMISSAO', " + STR_PULA
    cQuery += "        C5_CLIENTE AS 'CLIENTE' " + STR_PULA
    cQuery += "  FROM  "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) " + STR_PULA
    cQuery += "   LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = C5_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C5_NUM  AND  SZG.D_E_L_E_T_ ='' "  + STR_PULA
	cQuery += "   LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON ZB_FILIAL = C5_FILIAL AND SUBSTRING(ZB_PEDIDO,3,6) = C5_NUM  AND  SZB.D_E_L_E_T_ ='' "  + STR_PULA
    cQuery += " WHERE  SC5.D_E_L_E_T_ ='' AND C5_FILIAL ='010101' AND C5_NOTA ='' AND (C5_EMISSAO > '"+Dtos(mv_par01)+"') AND C5_FLAG ='S' " + STR_PULA
    cQuery += "GROUP BY ZG_CODIGO, ZB_CODIGO, C5_NUM, C5_PEDPROG, C5_EMISSAO, C5_CLIENTE " + STR_PULA
//    cQuery += "Order By ZG_CODIGO " + STR_PULA
    cQuery += "Order By C5_NUM " + STR_PULA

    TCQuery cQuery New Alias "QRYPRO"


    While !(QRYQTD->(EoF()))
          nTotal := QRYQTD->total
       QRYQTD->(DbSkip())
    EndDo

    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01 
    oFWMsExcel:AddworkSheet("Pedidos") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    ccabecalho :="Data.: "+DTOC(dDataBase)+"  AS  "+Time()+ "                 "+"Pedido Impresso Sem Bordero Pedido ou Sem Bordero Despacho"
    //Criando Colunas
    oFWMsExcel:AddTable("Pedidos",ccabecalho) // Adiciona a tabela 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"BORD/PEDIDO   ",1) 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"BORD/DESPACHO ",1) 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"PEDIDO        ",1) 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"PROGRAMADO    ",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"EMISSÃO       ",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"CLIENTE       ",1)

    //Criando as Linhas... Enquanto não for fim da query
    While !(QRYPRO->(EoF()))
                nAtual++
                MsProcTxt("Gerando Planilha Excel - Qtde Registros " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "")
                oFWMsExcel:AddRow("Pedidos",ccabecalho,{;
                QRYPRO->BORDPEDIDOD,;
                QRYPRO->BORDDESPACHO,;
                QRYPRO->PEDIDO,;
                QRYPRO->PROGRAMADO,;
                QRYPRO->EMISSAO,;
                QRYPRO->CLIENTE;
                })
       //Pulando Registro
       QRYPRO->(DbSkip())
    EndDo
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )

    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)              //Visualiza a planilha
    oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)

Return

