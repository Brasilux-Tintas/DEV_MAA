//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "Avprint.ch"
#include 'font.ch' 
#include 'totvs.ch'

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} TCFAT03
Função que cria arquivo de FWMsExcel
@author Jose Uliana
@since 15/08/2023
@version 1.0
@example_cPerg
u_TCFAT03()
/*/

User Function TCFAT03()
    Local   _cPerg       := "TCFAT03   "  

//  if !u_VldAcesso(funname())
//     MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
//     return 
//  endif 

    If !Pergunte( _cPerg ) 
      Return() //Se cancelar as perguntas sai do programa
    Endif

    /* Nelider - crie função para Utilizar a Tela de Progress para o usuário */ //
    MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Aguarde...   Processando Registros...,")
   
Return    

/* Nelider - Crie Função para utilizar a tela de Progress para o usuário */
Static Function Imprimir()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cPedido      := ""
    Local cFiller      := ""
    Local cFiller1     := ">                 Total Pedido -->>"
    Local cFlag        := 0
    Local oFWMsExcel
    Local oExcel
    Local cArquivo     := "C:\Temp\"+"TCFAT03.xml"
    Local nQtde        := 0
    Local nValor       := 0

    //Pegando os dados
    cQuery := "SELECT  ZAB_FILIAL, ZAB_PEDIDO, ZAB_CLIENT, ZAB_LOJA, ZAB_NOME, ZAB_MOTIVO, ZAB_DESCRI, " + STR_PULA
    cQuery += "        C6_QTDVEN,  C6_VALOR,   B1_DESC, " + STR_PULA
    cQuery += "        SUBSTRING(CONVERT(CHAR(8),ZAB.S_T_A_M_P_,112),5,2) AS 'MES', " + STR_PULA
    cQuery +="         SUBSTRING(CONVERT(CHAR(8),ZAB.S_T_A_M_P_,112),1,4) AS 'ANO' "  + STR_PULA
    cQuery += "  FROM  "+RetSqlName("ZAB")+" ZAB WITH (NOLOCK) " + STR_PULA 
    cQuery += "   LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = ZAB_FILIAL AND C6_NUM = ZAB_PEDIDO AND SC6.D_E_L_E_T_ = '*' " + STR_PULA
  	cQuery += "   LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = C6_FILIAL  AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = ''  " + STR_PULA
    cQuery += " WHERE  ZAB.D_E_L_E_T_ = '' "  + STR_PULA
    cQuery += "  AND (ZAB_FILIAL BETWEEN ('"+MV_PAR01+"') AND ('"+MV_PAR02+"')) "  + STR_PULA
    cQuery += "  AND (ZAB_PEDIDO BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')) "  + STR_PULA
    cQuery += "  AND (ZAB_CLIENT BETWEEN ('"+MV_PAR05+"') AND ('"+MV_PAR06+"')) "  + STR_PULA     
    cQuery += "  AND (ZAB_LOJA   BETWEEN ('"+MV_PAR07+"') AND ('"+MV_PAR08+"')) "  + STR_PULA     
    cQuery += "  AND (ZAB_MOTIVO BETWEEN ('"+MV_PAR09+"') AND ('"+MV_PAR10+"')) "  + STR_PULA 
    cQuery += "  AND SUBSTRING(CONVERT(CHAR(8),ZAB.S_T_A_M_P_,112),5,2) = ('"+MV_PAR11+"') " + STR_PULA 
    cQuery += "  AND SUBSTRING(CONVERT(CHAR(8),ZAB.S_T_A_M_P_,112),1,4) = ('"+MV_PAR12+"') " + STR_PULA 
//  cQuery += "GROUP BY ZG_CODIGO, ZB_CODIGO, C5_NUM, C5_PEDPROG, C5_EMISSAO, C5_CLIENTE " + STR_PULA
    cQuery += "Order By ZAB_FILIAL, ZAB_PEDIDO, ZAB_CLIENT, ZAB_LOJA, ZAB_MOTIVO " + STR_PULA

    TCQuery cQuery New Alias "QRYPRO"

    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01 
    oFWMsExcel:AddworkSheet("Pedidos") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    ccabecalho :="Data.: "+DTOC(dDataBase)+"  AS  "+Time()+ "                 "+"Relação de Pedidos Excluidos e os Motivos da Exclusão"
    //Criando Colunas
    oFWMsExcel:AddTable("Pedidos",ccabecalho) // Adiciona a tabela 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"PEDIDO "         ,2) 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"CLIENTE"         ,2) 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"LOJA"            ,2) 
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"NOME CLIENTE    ",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"MOTIVO"          ,2)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"DESC.MOTIVO     ",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"DESC.PRODUTO    ",1)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"VENDIDO"         ,2)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"VALOR A ENTREGAR",2)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"MÊS"             ,2)
    oFWMsExcel:AddColumn("Pedidos",ccabecalho,"ANO"             ,2)
    // PadL  Alinha a Esquerda
    //Criando as Linhas... Enquanto não for fim da query
    While !(QRYPRO->(EoF()))
            If QRYPRO->ZAB_PEDIDO = cPedido
               oFWMsExcel:AddRow("Pedidos",ccabecalho,{;
               cFiller,;
               cFiller,;
               cFiller,;
               cFiller,;
               cFiller,;
               cFiller,;
               QRYPRO->B1_DESC,;
               Alltrim( TransForm( QRYPRO->C6_QTDVEN, "@E 999,999,999.9999" ) ),;
               Alltrim( TransForm( QRYPRO->C6_VALOR,  "@E 999,999,999.99" ) ),;
               cFiller,;
               cfiller;
                })
               nQtde  := nQtde  + QRYPRO->C6_QTDVEN
               nValor := Nvalor + QRYPRO->C6_VALOR
            Else
               // Imprime Linha Total Pedido 
               if cFlag = 1
                  oFWMsExcel:AddRow("Pedidos",ccabecalho,{;
                  cFiller,;
                  cFiller,;
                  cFiller,;
                  cFiller,;
                  cFiller,;
                  cFiller,;
                  cFiller1,;
                  Alltrim( TransForm( nQtde,  "@E 999,999,999.9999" ) ),;
                  Alltrim( TransForm( nValor, "@E 999,999,999.99" ) ),;
                  cFiller,;
                  cfiller;
                   })
                 // Imprime Linha em Branco
                 nQtde   := 0   
                 Nvalor  := 0
                 oFWMsExcel:AddRow("Pedidos",ccabecalho,{;
                 cFiller,;
                 cFiller,;
                 cFiller,;
                 cFiller,;
                 cFiller,;
                 cFiller,;
                 cFiller,;
                 cFiller,;
                 cFiller,;
                 cfiller,;
                 cFiller;
                  })
               Else
                 cFlag  := 1
               EndIf  
               // Emprime Linha Detalhe 
               cPedido := QRYPRO->ZAB_PEDIDO
               oFWMsExcel:AddRow("Pedidos",ccabecalho,{;
               QRYPRO->ZAB_PEDIDO,;
               QRYPRO->ZAB_CLIENT,;
               QRYPRO->ZAB_LOJA,;
               QRYPRO->ZAB_NOME,;
               QRYPRO->ZAB_MOTIVO,;
               QRYPRO->ZAB_DESCRI,;
               QRYPRO->B1_DESC,;
               Alltrim( TransForm( QRYPRO->C6_QTDVEN, "@E 999,999,999.9999" ) ),;
               Alltrim( TransForm( QRYPRO->C6_VALOR,  "@E 999,999,999.99" ) ),;
               QRYPRO->MES,;               
               QRYPRO->ANO;
               })  
               nQtde  := nQtde  + QRYPRO->C6_QTDVEN
               nValor := Nvalor + QRYPRO->C6_VALOR
            EndIf          
       //Pulando Registro
       QRYPRO->(DbSkip())
    EndDo
    // Imprime Linha Total Pedido
    oFWMsExcel:AddRow("Pedidos",ccabecalho,{;
    cFiller,;
    cFiller,;
    cFiller,;
    cFiller,;
    cFiller,;
    cFiller,;
    cFiller1,;
    Alltrim( TransForm( nQtde,  "@E 999,999,999.9999" ) ),;
    Alltrim( TransForm( nValor, "@E 999,999,999.99" ) ),;
    cFiller,;
    cFiller;
    })

    //Ativando o Arquivo e Gerando o Xml
    oFWMsExcel:Activate()
    MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oFWMsExcel:GetXMLFile(cArquivo) } )

    //Abrindo o Excel e Abrindo o Arquivo Xml
    oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)              //Visualiza a planilha
    oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)

Return

