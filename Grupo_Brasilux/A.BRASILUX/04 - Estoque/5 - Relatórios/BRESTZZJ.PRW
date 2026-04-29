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
//PALLETS NÃO TRANSFERIDOS DO DEPÓSITO ARARAQUARA
@type function
@version  v.2022.08.09.001 
@author joseuliana
@since 29/10/2024
@return variant, return 
/*/

User Function BRESTZZJ()
    
    Private mv_par01
    Private mv_par02
    Private cPerg    := 'ESTZZJ'
    Private Titulo   := "Gerando planilha Excel - Pallets"
    Private lPerg

    If !u_VldAcesso(funname())                                                 
        MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")        
        return                                                                   
    Endif     

    ValPerg1()
    lPerg := pergunte(cPerg,.T.) // Parametros para consulta
    If !lPerg
        Return
    Else
        MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Filtrando Registros de acordo com Paramêtros...")
        //Processa({|| Imprimir() },Titulo) 
    Endif
    
    //Pergunte('ESTZZJ',.F.)

    //MsAguarde({|| Imprimir() },"Gerando Planilha Excel   ","Filtrando Registros de acordo com Paramêtros...")

Return    

Static Function Imprimir()
    
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cArquivo     := "C:\Temp\"+"BRESTZZJ.xml"
    Local _nAtual      := 0
    Local oExcel       := FWMsExcelEx():New()


    cQuery := " SELECT ZZJ_CODIGO, CONVERT(VARCHAR,CAST(ZZJ_DTINI as smalldatetime),103) as DATAINICIO, ZH_NOME, ZZJ_BORDER, " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='1' THEN 'AGLUTINADO'    ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='2' THEN 'DEPOSITO'      ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='4' THEN 'EXPORTAÇÃO'    ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='5' THEN 'CARGA FECHADA' ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='6' THEN 'AMOSTRAS'      ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='7' THEN 'VOL QUEBRADO'  ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='' AND ZF_TIPOBOR ='5' THEN 'CARGA FECHADA' ELSE " + STR_PULA
    cQuery += " CASE WHEN ZZJ_TIPBOR ='' AND ZF_TIPOBOR ='2' THEN 'DEPOSITO' END END END END END END END END AS 'TIPOBORDERO',  " + STR_PULA
    cQuery += " ZZJ_BORDER, COUNT(ZZK.R_E_C_N_O_) AS VOLUMES, " + STR_PULA
    cQuery += " STUFF((SELECT '-' + ZZK_PEDIDO as [text()] FROM ZZK010 ZZK WHERE ZZK_FILIAL = ZZJ_FILIAL AND ZZK_CODIGO = ZZJ_CODIGO AND ZZK.D_E_L_E_T_ ='' GROUP BY ZZK_PEDIDO FOR XML PATH('')),1,1,'') AS 'PEDIDOS' " + STR_PULA
    cQuery += " FROM ZZJ010 ZZJ " + STR_PULA
    cQuery += " LEFT OUTER JOIN ZZK010 ZZK ON ZZK_FILIAL = ZZJ_FILIAL AND ZZK_CODIGO = ZZJ_CODIGO AND ZZK.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SC6010 SC6 ON C6_FILIAL  = ZZK_FILIAL AND C6_NUM = ZZK_PEDIDO AND ZZK_PRODUT = C6_PRODUTO AND SC6.D_E_L_E_T_ ='' AND SUBSTRING(C6_LOCAL,1,1)='G' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SZG010 SZG ON ZG_FILIAL  = C6_FILIAL  AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SZG.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SZF010 SZF ON ZF_FILIAL  = ZG_FILIAL  AND ZF_CODIGO = ZG_CODIGO AND SZF.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " LEFT OUTER JOIN SZH010 SZH ON ZH_CODIGO = ZZJ_USER AND SZH.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " WHERE ZZJ_FILIAL ='010101' " + STR_PULA
    cQuery += " AND ZZJ_DTINI BETWEEN '"+DToS(mv_par01)+"' AND '"+DToS(mv_par02)+"' " + STR_PULA
    cQuery += " AND ZZJ.D_E_L_E_T_ ='' " + STR_PULA
    cQuery += " AND ZZJ_LOCALI <>'DEPO' " + STR_PULA
    cQuery += " AND ZZJ_TIPBOR NOT IN('3','8') " + STR_PULA
    cQuery += " AND ZZJ_CARGA ='' " + STR_PULA
    cQuery += " AND ZZK_PEDIDO <>'' " + STR_PULA
    cQuery += " AND SUBSTRING(C6_LOCAL,1,1)='G' " + STR_PULA
    cQuery += " GROUP BY ZZJ_FILIAL,ZZJ_CODIGO, ZZJ_DTINI, ZZJ_USER, ZH_NOME, ZZJ_TIPBOR, ZF_TIPOBOR, ZZJ_BORDER, ZZJ.R_E_C_N_O_ " + STR_PULA
    cQuery += " ORDER BY ZZJ.R_E_C_N_O_  " + STR_PULA

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
    oExcel:AddworkSheet("PALLETS_NAO_TRANSFERIDOS") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela   
    ccabecalho := PadR("BRESTZZJ", 30) + "Data.: " + DTOC(dDataBase) + "   AS   " + Time() + "   PALLETS SEM NOTA DE DEVOLUÇÃO PARA MATRIZ "
    //Criando Colunas
    oExcel:AddTable ("PALLETS_NAO_TRANSFERIDOS",ccabecalho) // Adiciona a tabela 
    oExcel:AddColumn("PALLETS_NAO_TRANSFERIDOS",ccabecalho,"PALLET"            ,1) 
    oExcel:AddColumn("PALLETS_NAO_TRANSFERIDOS",ccabecalho,"DATA"              ,1) 
    oExcel:AddColumn("PALLETS_NAO_TRANSFERIDOS",ccabecalho,"QUEM MONTOU"       ,1) 
    oExcel:AddColumn("PALLETS_NAO_TRANSFERIDOS",ccabecalho,"BORDERO"           ,1)
    oExcel:AddColumn("PALLETS_NAO_TRANSFERIDOS",ccabecalho,"TIPO BORDERO"      ,1)
    oExcel:AddColumn("PALLETS_NAO_TRANSFERIDOS",ccabecalho,"VOLUMES"           ,1)
    oExcel:AddColumn("PALLETS_NAO_TRANSFERIDOS",ccabecalho,"PEDIDOS AFETADOS"  ,1)

    oExcel:SetCelBold(.T.)
    oExcel:SetCelFont('Arial')
    oExcel:SetCelItalic(.T.)
    oExcel:SetCelUnderLine(.T.)
    oExcel:SetCelSizeFont(10)
    _nAtual           = 0

    While !(QRYPRO->(EoF()))
          _nAtual++
          oExcel:AddRow("PALLETS_NAO_TRANSFERIDOS",ccabecalho,{;
          QRYPRO->ZZJ_CODIGO,;
          QRYPRO->DATAINICIO,;
          QRYPRO->ZH_NOME,; 
          QRYPRO->ZZJ_BORDER,; 
          QRYPRO->TIPOBORDERO,;
          QRYPRO->VOLUMES,;
          SUBSTR(TRIM(QRYPRO->PEDIDOS),1,40);
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

Static Function ValPerg1()
    Local aRegs := {}
    Local i,j

    dbSelectArea("SX1")
    dbSetOrder(1)
    cPerg := PADR(cPerg,10)

    // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
    aAdd(aRegs,{cPerg,"01","Da data?        ","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"02","Ate a data?     ","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
Return
