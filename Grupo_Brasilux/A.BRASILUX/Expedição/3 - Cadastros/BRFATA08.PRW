//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "Avprint.ch"
#include 'font.ch'
#include 'totvs.ch'

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

/*/
{Protheus.doc}  BRFATA08
//PRODUTOS A SEREM PRODUZIDOS
@type function
@version  v.2022.08.09.001 
@author joseuliana
@since 29/10/2024
@return variant, return 
/*/

User Function BRFATA08()
//  Local _cPerg       := "BRFATA08"                                            // Aqui
    Private MV_Par01
    Private aMatDad    := {}
 
//   if !u_VldAcesso(funname())                                                 // Aqui
//      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")       // Aqui
//      return                                                                  // Aqui
//  	endif                                                                     // Aqui

//  If !Pergunte( _cPerg )                                                      // Aqui
//   Return() //Se cancelar as perguntas sai do programa                        // Aqui
//  Endif                                                                       // Aqui

    MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Filtrando Registros de acordo com Paramêtros...")
   
Return    

Static Function Imprimir()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local nY           :=0
    Local nPosDad      :=0
    Local cArquivo     := "C:\Temp\"+" BRFATA08.xml"
    Local nAtual       := 0
    Local _cDtApr      := '' 
    Local _cUniFat     := ''
    Local cProduto     := ''
    Local cSaldo       := 0
    Local cPula        := 0
    Local cVolume      := 0
    Local cResto       := 0
    Local cPassou      := 0
    Local Nz           := 0
    Local oExcel       := FWMsExcelEx():New()

    //Pegando os dados
    cQuery := "SELECT SC6.C6_LOCAL,   " + STR_PULA
    cQuery += "       SC5.C5_NUM,     " + STR_PULA
    cQuery += "       CASE            " + STR_PULA
    cQuery += " 	    WHEN            " + STR_PULA
    cQuery += "            SC5.C5_DTAPR = '' THEN SC5.C5_EMISSAO  " + STR_PULA
    cQuery += "       ELSE SC5.C5_DTAPR  END AS C5_DTAPR,         " + STR_PULA
    cQuery += "       SC6.C6_PRODUTO, " + STR_PULA
    cQuery += "       SC6.C6_ITEM,    " + STR_PULA
    cQuery += "       SB1.B1_DESC,    " + STR_PULA
    cQuery += "       SC6.C6_QTDVEN,  " + STR_PULA 
    cQuery += "       SB1.B1_ESTOQUE, " + STR_PULA 
    cQuery += "       SC5.C5_APROVA,  " + STR_PULA
    cQuery += "       SC5.C5_NOTA,    " + STR_PULA   
    cQuery += "       SC5.C5_VOLUME1, " + STR_PULA
    cQuery += "       SC6.C6_VOLITEM, " + STR_PULA
    cQuery += "       ISNULL( SUM( ZZK_QUANT ),0 ) AS BIPADOS, " + STR_PULA
    cQuery += "       ( ( ( ISNULL( SUM( ZZK.ZZK_QUANT ),0 ) / SC6.C6_QTDVEN ) ) * 100 ) AS ATENDIDO, " + STR_PULA 
    cQuery += "       SUM( SB2.B2_QATU ) AS SALATU, " + STR_PULA 
    cQuery += "       ( SUM( SB2.B2_QATU ) - ISNULL( SUM( ZZK_QUANT ),0 ) ) AS SALDO " + STR_PULA
    cQuery += "  FROM "+RetSqlName("SC5")+" SC5 " + STR_PULA
    cQuery += "       LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON SC6.D_E_L_E_T_ = ''             " + STR_PULA
    cQuery += "                                                             AND SC6.C6_FILIAL = SC5.C5_FILIAL   " + STR_PULA
    cQuery += "                                                             AND SC6.C6_NUM    = SC5.C5_NUM      " + STR_PULA
    cQuery += "       LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON ZZK.D_E_L_E_T_ = ''             " + STR_PULA
    cQuery += "       	                                                    AND ZZK.ZZK_FILIAL = SC6.C6_FILIAL  " + STR_PULA                                                                            
    cQuery += "                                                             AND ZZK.ZZK_PRODUT = SC6.C6_PRODUTO " + STR_PULA 
    cQuery += "                                                             AND ZZK.ZZK_PEDIDO = SC6.C6_NUM     " + STR_PULA
    cQuery += "       LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.D_E_L_E_T_ = ''             " + STR_PULA
    cQuery += "       	                                                    AND SB1.B1_FILIAL  = SC6.C6_FILIAL  " + STR_PULA
    cQuery += "       	                                                    AND SB1.B1_COD     = SC6.C6_PRODUTO " + STR_PULA
    cQuery += "       LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON SB2.D_E_L_E_T_ = ''             " + STR_PULA
    cQuery += "       	                                                    AND SB2.B2_FILIAL  = SC6.C6_FILIAL  " + STR_PULA
    cQuery += "       	                                                    AND SB2.B2_COD     = SC6.C6_PRODUTO " + STR_PULA
    cQuery += " WHERE SC5.D_E_L_E_T_ = ''                   " + STR_PULA
    cQuery += "   AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"' " + STR_PULA
    cQuery += "   AND SC5.C5_APROVA  = '1'                  " + STR_PULA
    cQuery += "   AND SC5.C5_NOTA    = ''                   " + STR_PULA
    cQuery += "   AND SC5.C5_TIPO    = 'N'                  " + STR_PULA
    cQuery += "   AND SC5.C5_EMISSAO >= '20240901'          " + STR_PULA                    //  aqui
//  If MV_PAR01 = 3                                                                         //  Aqui
//     cQuery += "   AND SC6.C6_LOCAL  = 'G3'  " + STR_PULA                                 //  aqui
//  EndIf                                                                                   //  Aqui
//  If MV_PAR01 = 2                                                                         //  Aqui
//     cQuery += "   AND SC6.C6_LOCAL  = 'A3'  " + STR_PULA                                 //  aqui
//  EndIf                                                                                   //  Aqui
//  If MV_PAR01 = 1                                                                         //  Aqui
//     cQuery += "   AND (SC6.C6_LOCAL  <> 'G3'  " + STR_PULA                               //  aqui
//     cQuery += "   AND  SC6.C6_LOCAL  <> 'A3') " + STR_PULA                               //  aqui
//  EndIf                                                                                   //  Aqui
    cQuery += "GROUP BY SC6.C6_LOCAL, SC5.C5_NUM, SC5.C5_DTAPR, SC6.C6_PRODUTO, SC6.C6_ITEM, SB1.B1_DESC, SC6.C6_QTDVEN,      " + STR_PULA
    cQuery += "         SB1.B1_ESTOQUE, SC5.C5_APROVA, SC5.C5_NOTA, SC5.C5_VOLUME1, SC6.C6_VOLITEM, ZZK_QUANT, SC5.C5_EMISSAO " + STR_PULA
//  cQuery += "HAVING (SUM(ZZK_QUANT) IS NULL) " + STR_PULA
    cQuery += "ORDER BY C6_PRODUTO, C5_DTAPR, SC5.C5_NUM " + STR_PULA     //(( SUM(ZZK.ZZK_QUANT /SC6.C6_QTDVEN) ) * 100) DESC , SC5.C5_NUM, C6_PRODUTO " + STR_PULA
    /* verifica se arquivo está aberto e finaliza */
    IF Select("QRYPRO") <> 0
       DbSelectArea("QRYPRO")
       DbCloseArea()
    ENDIF

    TCQuery cQuery New Alias "QRYPRO"

    MsProcTxt("Aguarde...   Processando Registros Selecionados... ")  
 
    While !(QRYPRO->(EoF()))
          If QRYPRO->C6_PRODUTO <> cProduto
             cProduto := QRYPRO->C6_PRODUTO
             cSaldo   := QRYPRO->SALDO
             cPlula   := 0
             cVolume  := 0
             cResto   := 0
             cPassou  := 0
          Endif
          If cSaldo < QRYPRO->C6_QTDVEN
             cPassou = 0
             If cSaldo > 0
                cResto  = QRYPRO->C6_QTDVEN - cSaldo
                cVolume = ( ( ( ( cResto / QRYPRO->C6_QTDVEN ) * 100 ) - 100 ) *-1 )
                cSaldo  = cSaldo - QRYPRO->C6_QTDVEN
                cPassou = 1
                cPula   = 0
             Endif
             If ( cSaldo < 0 .OR. cSaldo = 0 )  .AND. cPassou = 0
                cVolume = 100
                cPula   = 0
             EndIf
          Else
             cSaldo  = cSaldo - QRYPRO->C6_QTDVEN
             cVolume = 0 
//             cPula   = 1
          Endif          

          if cPula = 0
             nPosDad ++  
             aadd(aMatDad, {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' })
             aMatDad[nPosDad][1]  = QRYPRO->C6_LOCAL
             aMatDad[nPosDad][2]  = QRYPRO->C5_NUM
             aMatDad[nPosDad][3]  = QRYPRO->C5_DTAPR
             aMatDad[nPosDad][4]  = QRYPRO->C6_PRODUTO
             aMatDad[nPosDad][5]  = QRYPRO->B1_DESC
             aMatDad[nPosDad][6]  = QRYPRO->C6_ITEM
             aMatDad[nPosDad][7]  = QRYPRO->C6_QTDVEN
             aMatDad[nPosDad][8]  = cVolume  // QRYPRO->ATENDIDO
             aMatDad[nPosDad][9]  = QRYPRO->B1_ESTOQUE
             aMatDad[nPosDad][10] = cSaldo                                //  tirar depois             
          EndIf
      //Pulando Registro
      QRYPRO->(DbSkip())
    EndDo         

//Classificcando o conteúdo do Excel
MsProcTxt("Aguarde.. Classificando Regist. Selecionados..")  
 
For nZ := 1 To Len(aMatDad)
    aSort( aMatDad,,,{ |x, y| x[3]+x[2]+x[4] < y[3]+y[2]+y[4] } ) // aSort( aMatDad,,,{ |x, y| x[3] < y[3] } ) 
Next

//Criando o objeto que irá gerar o conteúdo do Excel
//Aba 01 
oExcel:AddworkSheet("Faltantes") //Não utilizar número junto com sinal de menos. Ex.: 1-
//Criando a Tabela   
//ccabecalho :="BRFATA08                           Data.: "+DTOC(dDataBase)+"   AS   "+Time()+ "                   PRODUTOS A SEREM PRODUZIDOS"
ccabecalho := PadR("BRFATA08", 30) + "Data.: " + DTOC(dDataBase) + "   AS   " + Time() + "   PRODUTOS A SEREM PRODUZIDOS"
//Criando Colunas
oExcel:AddTable ("Faltantes",ccabecalho) // Adiciona a tabela 
oExcel:AddColumn("Faltantes",ccabecalho,"UNIDADE FAT"   ,1) 
oExcel:AddColumn("Faltantes",ccabecalho,"PEDIDO       " ,1,2) 
oExcel:AddColumn("Faltantes",ccabecalho,"DT.APROVAÇÃO"  ,1,2) 
oExcel:AddColumn("Faltantes",ccabecalho,"PRODUTO      " ,1)
oExcel:AddColumn("Faltantes",ccabecalho,"ITEM"          ,1,2)
oExcel:AddColumn("Faltantes",ccabecalho,"DESCRIÇÃO"     ,1)
oExcel:AddColumn("Faltantes",ccabecalho,"QTDE PEDIDO"   ,1,2)
oExcel:AddColumn("Faltantes",ccabecalho,"% FALTA   "    ,1,2)
oExcel:AddColumn("Faltantes",ccabecalho,"ESTOQ/ESPEC"   ,1,2)
oExcel:AddColumn("Faltantes",ccabecalho,"SALDO"         ,1,2)
oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Arial')
oExcel:SetCelItalic(.T.)
oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(10)

For nY := 1 To Len(aMatDad)
    nAtual++
    If aMatDad[nY][1] = "G3"
       _cUniFat = 'GUARULHOS'
    Else
       If aMatDad[nY][1] = "A3"
          _cUniFat = 'ARARAQUARA'
       Else 
          _cUniFat = 'MATÃO'   
       EndIf
    EndIf 
    _cDtApr = ctod(substr(aMatDad[nY][3],7,2)+"/"+substr(aMatDad[nY][3],5,2)+"/"+substr(aMatDad[nY][3],1,4))
    oExcel:AddRow("Faltantes",ccabecalho,{;
    _cUniFat,;             // UNIDADE FAT
    aMatDad[nY][2],;       // PEDIDO 
    _cDtApr,;              // DT.APROVAÇÃO
    aMatDad[nY][4],;       // PRODUTO 
    aMatDad[nY][6],;       // ITEM
    aMatDad[nY][5],;       // DESCRIÇÃO
    aMatDad[nY][7],;       // QTDE PEDIDO
    INT(aMatDad[nY][8]),;  // % FALTA
    aMatDad[nY][9],;       // ESTOQ/ESPEC
    aMatDad[nY][10];       // SALDO
    })
    oExcel:SetCelBold(.T.)
    oExcel:SetCelFont('Arial')
    oExcel:SetCelItalic(.T.)
    oExcel:SetCelUnderLine(.T.)
    oExcel:SetCelSizeFont(15)
    oExcel:SetCelFrColor("#FFFFFF")
    oExcel:SetCelBgColor("#000666")
Next
//Ativando o arquivo e gerando o xml
oExcel:Activate()
MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oExcel:GetXMLFile(cArquivo) } )
//Abrindo o excel e abrindo o arquivo xml
oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
oExcel:SetVisible(.T.)              //Visualiza a planilha
oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas

QRYPRO->(DbCloseArea())
RestArea(aArea)
         
Return
