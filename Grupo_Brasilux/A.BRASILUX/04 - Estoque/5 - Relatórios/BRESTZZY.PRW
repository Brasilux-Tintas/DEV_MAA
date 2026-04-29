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
{Protheus.doc}  BRFATA09
//PRODUTOS A SEREM PRODUZIDOS
@type function
@version  v.2022.08.09.001 
@author joseuliana
@since 29/10/2024
@return variant, return 
/*/

User Function BRESTZZY()

    //Local _cPerg       := "BRESTZZY"                                             

    Private MV_Par01
    Private MV_Par02

    If !u_VldAcesso(funname())                                                 
        MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")        
        return                                                                   
    Endif                                                                      

    //If !Pergunte( _cPerg )                                                      
    //    Return() //Se cancelar as perguntas sai do programa                        
    //Endif                                                                      

    MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Filtrando Registros de acordo com Paramêtros...")

Return    

Static Function Imprimir()
    
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cArquivo     := "C:\Temp\"+"BRESTZZY.xml"
    Local _nAtual      := 0
    Local oExcel       := FWMsExcelEx():New()


    cQuery := " WITH TMP AS( " + STR_PULA
    cQuery += " SELECT ZZY.R_E_C_N_O_,ZZY_FILIAL, ZZY_TIPO,ZZY_TAB, " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN D1_FILIAL ELSE D2_FILIAL END AS 'FILIAL', " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN D1_COD ELSE D2_COD END AS 'CODIGO', " + STR_PULA
    cQuery += " B1_DESC AS 'DESCRIÇÃO', " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN D1_QUANT ELSE D2_QUANT END AS 'QUANTIDADE', " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN D1_LOCAL ELSE D2_LOCAL END AS 'LOCAL', " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN SB2E.B2_QATU ELSE SB2S.B2_QATU END AS 'SALDO', " + STR_PULA
    cQuery += " CASE WHEN ((CASE WHEN ZZY_TAB ='SD1' THEN SB2E.B2_QATU ELSE SB2S.B2_QATU END) -(CASE WHEN ZZY_TAB ='SD1' THEN D1_QUANT ELSE D2_QUANT END )) >0 THEN 0 ELSE ((CASE WHEN ZZY_TAB ='SD1' THEN SB2E.B2_QATU ELSE SB2S.B2_QATU END) -(CASE WHEN ZZY_TAB ='SD1' THEN D1_QUANT ELSE D2_QUANT END )) END  AS 'FALTANDO', " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN SD1.D_E_L_E_T_ ELSE SD2.D_E_L_E_T_  END AS 'DELETADO', " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN SUBSTRING(D1_DTDIGIT,7,2)+'/'+SUBSTRING(D1_DTDIGIT,5,2)+'/'+SUBSTRING(D1_DTDIGIT,1,4) ELSE SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4)  END AS 'DATA', " + STR_PULA
    cQuery += " CASE WHEN ZZY_TAB ='SD1' THEN D1_SERIE+' - '+D1_DOC ELSE D2_SERIE+' - '+D2_DOC END AS 'SERIE / DOC' " + STR_PULA
    cQuery += " FROM ZZY010 ZZY  " + STR_PULA
    cQuery += " LEFT OUTER JOIN SD1010 SD1 ON SD1.R_E_C_N_O_ = ZZY_DOC --AND SD1.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SD2010 SD2 ON SD2.R_E_C_N_O_ = ZZY_DOC --AND SD2.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SB2010 SB2E ON SB2E.B2_FILIAL = '010101' AND SB2E.B2_COD = D1_COD AND SB2E.B2_LOCAL = CASE WHEN D1_LOCAL = 'G1' THEN '01'  ELSE CASE WHEN D1_LOCAL ='G4' THEN '04' ELSE '03' END END AND SB2E.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SB2010 SB2S ON SB2S.B2_FILIAL = '010101' AND SB2S.B2_COD = D2_COD AND SB2S.B2_LOCAL = D2_LOCAL AND SB2S.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SB1010 SB1 ON B1_FILIAL = '010101' AND B1_COD = (CASE WHEN ZZY_TAB ='SD1' THEN D1_COD ELSE D2_COD END) AND SB1.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " WHERE ZZY.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " AND B1_TIPO IN('PA','MP','PI')) " + STR_PULA
    cQuery += " SELECT FILIAL, ZZY_TIPO AS 'TIPOMOV' ,  TRIM(CODIGO)+' - '+DESCRIÇÃO AS PRODUTO, QUANTIDADE,  " + STR_PULA
    cQuery += " CASE WHEN ZZY_TIPO ='S' THEN LOCAL ELSE  " + STR_PULA
    cQuery += " CASE WHEN ZZY_TIPO ='E' AND LOCAL IN('G1') THEN '01' ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZY_TIPO ='E' AND LOCAL IN('G2') THEN '02' ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZY_TIPO ='E' AND LOCAL IN('G4') THEN '04' ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZY_TIPO ='E' AND LOCAL IN('G3','A3') THEN '03' ELSE LOCAL END END END END END AS 'ORIGEM', " + STR_PULA
    cQuery += " LOCAL AS 'DESTINO', SALDO, (FALTANDO*-1) AS FALTANDO, DATA, [SERIE / DOC] AS NF " + STR_PULA
    cQuery += " FROM TMP " + STR_PULA
    cQuery += " WHERE FALTANDO <0 AND DELETADO ='' " + STR_PULA
    cQuery += " ORDER BY FILIAL, PRODUTO, NF " + STR_PULA

    If Select("QRYPRO") <> 0
        DbSelectArea("QRYPRO")
        DbCloseArea()
    Endif

    TCQuery cQuery New Alias "QRYPRO"
    
    If Eof()
        MsgStop("Nenhum Registro Selecionado de Acordo com os Parametros Informados ..... ", "Atenção")
        QRYPRO->(DbCloseArea())
        Return()
    Endif

    MsProcTxt("Aguarde...   Processando Registros Selecionados... ")  

    //Criando o objeto que irá gerar o conteúdo do Excel
    //Aba 01 
    oExcel:AddworkSheet("PENDENCIAS") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela   
    ccabecalho := PadR("BRESTZZY", 30) + "Data.: " + DTOC(dDataBase) + "   AS   " + Time() + "   PRODUTOS COM PENDÊNCIA DE SALDO "
    //Criando Colunas
    oExcel:AddTable ("PENDENCIAS",ccabecalho) // Adiciona a tabela 
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"FILIAL"            ,1) 
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"TIPO MOV."         ,1) 
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"PRODUTO"           ,1) 
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"QUANTIDADE"        ,1,2)
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"ORIGEM"            ,1)
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"DESTINO"           ,1)
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"SALDO"             ,1,2)
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"FALTANDO"          ,1,2)
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"DATA"              ,1,2)
    oExcel:AddColumn("PENDENCIAS",ccabecalho,"NOTA FISCAL"       ,1,2)

    oExcel:SetCelBold(.T.)
    oExcel:SetCelFont('Arial')
    oExcel:SetCelItalic(.T.)
    oExcel:SetCelUnderLine(.T.)
    oExcel:SetCelSizeFont(10)
    _nAtual           = 0

    While !(QRYPRO->(EoF()))
          _nAtual++
          oExcel:AddRow("PENDENCIAS",ccabecalho,{;
          QRYPRO->FILIAL,;
          QRYPRO->TIPOMOV,;
          QRYPRO->PRODUTO,; 
          QRYPRO->QUANTIDADE,; 
          QRYPRO->ORIGEM,;
          QRYPRO->DESTINO,;
          QRYPRO->SALDO,;
          QRYPRO->FALTANDO,;
          QRYPRO->DATA,;
          QRYPRO->NF;
          })
          oExcel:SetCelBold(.T.)
          oExcel:SetCelFont('Arial')
          oExcel:SetCelItalic(.T.)
          oExcel:SetCelUnderLine(.T.)
          oExcel:SetCelSizeFont(15)
          oExcel:SetCelFrColor("#FFFFFF")
          oExcel:SetCelBgColor("#000666")
          //Pulando Registro
          QRYPRO->(DbSkip())
    EndDo  
    /*
    If _nAtual > 0   
          oExcel:AddRow("LISTA_PENDENCIAS",ccabecalho,{;
          _espaco,;
          _espaco,;
          _espaco,;
          _espaco1,; 
          _volumesseparados,;
          _totallitroskg,;
          _totalpeso,; 
          _valoritens;
          })
          oExcel:SetCelBold(.T.)
          oExcel:SetCelFont('Arial')
          oExcel:SetCelItalic(.T.)
          oExcel:SetCelUnderLine(.T.)
          oExcel:SetCelSizeFont(15)
          oExcel:SetCelFrColor("#FFFFFF")
          oExcel:SetCelBgColor("#000666")
         //Pulando Registro
    */
         //Ativando o arquivo e gerando o xml
         oExcel:Activate()
         MsgRun("Processando...","Aguarde Gerando arquivo em Excel...",{|| oExcel:GetXMLFile(cArquivo) } )
         //Abrindo o excel e abrindo o arquivo xml
         oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
         oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
         oExcel:SetVisible(.T.)              //Visualiza a planilha
         oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
    /*
    Else
         MsgStop("Nenhum Registro Selecionado de Acordo com os Parametros Informados ..... ", "Atenção")
    EndIf     
    */
QRYPRO->(DbCloseArea())
RestArea(aArea)
         
Return
