//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*-------------------------------------------------------------------/
{Protheus.doc} BREXPR11
Função que cria um exemplo de FWMsExcel
@author Jose Uliana
@since 01/12/2021
@version 1.0
    @example
    u_BREXPR11()
/----------------------------------------------------------------------*/
 
User Function BREXPR11()
     //  jose ---------------------
     Local Emissoo 
     Local Horass
	 Local Hifemm
     //----------------------------
     Local aArea := GetArea()
     Local cQuery:= ""
     Local oFWMsExcel
     Local oExcel
     Local _cPerg :="BREXPR11"
     Local cArquivo:= GetTempPath()+'BREXPR11.xml'

     //  jose ---------------------
     Emissoo:=DATE()
     Horass:=TIME()
     Hifemm:=" -"
     //----------------------------

     //( _cPerg ) Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
     Endif

     // BeginSql Alias _cAlias  // Começo da Consulta SQL =  Query   //Pegando os dados

     If MV_PAR01 == 1
        cQuery :="SELECT ZZL_PRODUT AS 'PRODUTO', B1_DESC AS 'DESCRICAO', B2_LOCALIZ AS 'ESTOQUE', " + CHR(13) + CHR(10) 
        cQuery +=" ZZL_LOCALI AS 'PROVISORIO','' AS 'OBSERVACAO', '' AS 'EMISSAO', '' AS 'HIFEM', '' AS 'HORAS' " + CHR(13) + CHR(10)
        cQuery +="FROM "+RetSqlName("ZZL")+" ZZL " + CHR(13) + CHR(10)
        cQuery +="LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = ZZL.ZZL_FILIAL " + CHR(13) + CHR(10)
        cQuery +=" AND SB1.B1_COD = ZZL.ZZL_PRODUT AND SB1.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
        //  jose 03/12/2021 --------------------------------------------------------------------------------------------------
        cQuery +="LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON SB2.B2_FILIAL = ZZL.ZZL_FILIAL " + CHR(13) + CHR(10)
        cQuery +=" AND SB2.B2_COD = ZZL.ZZL_PRODUT AND SB2.D_E_L_E_T_ = '' AND SB2.B2_LOCALIZ <> '' " + CHR(13) + CHR(10)
        //--------------------------------------------------------------------------------------------------------------------
        cQuery +="WHERE (ZZL_FILIAL='"+xFilial("ZZL")+"') AND (ZZL.D_E_L_E_T_='') AND LEN(B1_COD) = '12' " + CHR(13) + CHR(10)
        cQuery +=" AND (SUBSTRING(B1_COD,4,2) BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')) " + CHR(13) + CHR(10) 
        If !Empty(MV_PAR02) 
           cQuery +="AND UPPER(SUBSTRING(ZZL_LOCALI,1,2)) = '"+MV_PAR02+"' " + CHR(13) + CHR(10)
        EndIf  
        If MV_PAR05 == 1 
           cQuery +="AND ZZL_LOCALI <> '' " + CHR(13) + CHR(10)
        EndIf
        cQuery +="ORDER BY ZZL_LOCALI" + CHR(13) + CHR(10)
     Else
        //  Jose 14/12/2021 ------------
        If MV_PAR05 == 2 .OR. MV_PAR02 = 'X'
           //-------------------------------
           cQuery :="SELECT B1_COD AS 'PRODUTO', B1_DESC AS 'DESCRICAO', B2_LOCALIZ AS 'ESTOQUE', ZZL_LOCALI AS 'PROVISORIO', " + CHR(13) + CHR(10)
           cQuery +=" '' AS 'OBSERVACAO', '' AS 'EMISSAO', '' AS 'HIFEM', '' AS 'HORAS' " + CHR(13) + CHR(10)
           cQuery +="FROM "+RetSqlName("SB1")+" SB1 "
           cQuery +="LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = '"+xFilial("SB2")+"' " + CHR(13) + CHR(10)
           cQuery +=" AND B1_COD = B2_COD AND SB2.D_E_L_E_T_ ='' " + CHR(13) + CHR(10)
           cQuery +="LEFT OUTER JOIN "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK) ON ZZL_FILIAL = '"+xFilial("ZZL")+"' " + CHR(13) + CHR(10)
           cQuery +=" AND B1_COD = ZZL_PRODUT AND ZZL.D_E_L_E_T_ ='' " + CHR(13) + CHR(10)
           cQuery +="WHERE SB1.D_E_L_E_T_ ='' AND B1_FILIAL ='"+xFilial("SB1")+"' " + CHR(13) + CHR(10)
           cQuery +=" AND (SUBSTRING(B1_COD,4,2) BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')) " + CHR(13) + CHR(10)
           cQuery +=" AND B2_LOCALIZ <>'' AND B1_TIPO = 'PA' AND LEN(B1_COD) = '12' " + CHR(13) + CHR(10)
           If !Empty(MV_PAR02) 
              cQuery +="AND UPPER(SUBSTRING(B2_LOCALIZ,1,2)) = '"+MV_PAR02+"' " + CHR(13) + CHR(10)
           EndIf                               
           If MV_PAR05 == 1 
              cQuery +="AND ZZL_LOCALI <> '' " + CHR(13) + CHR(10)
          EndIf
          cQuery +="ORDER BY B2_LOCALIZ" + CHR(13) + CHR(10)    
          // Jose  14/12/2021 -----------------------
       Else
          cQuery :="SELECT B1_COD AS 'PRODUTO', B1_DESC AS 'DESCRICAO', B2_LOCALIZ AS 'ESTOQUE', '' AS 'PROVISORIO', " + CHR(13) + CHR(10)
          cQuery +=" '' AS 'OBSERVACAO', '' AS 'EMISSAO', '' AS 'HIFEM', '' AS 'HORAS' " + CHR(13) + CHR(10)
          cQuery +="FROM "+RetSqlName("SB1")+" SB1 "
          cQuery +="LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = '"+xFilial("SB2")+"' " + CHR(13) + CHR(10)
          cQuery +=" AND B1_COD = B2_COD AND SB2.D_E_L_E_T_ ='' " + CHR(13) + CHR(10)
          cQuery +="WHERE SB1.D_E_L_E_T_ ='' AND B1_FILIAL ='"+xFilial("SB1")+"' " + CHR(13) + CHR(10)
          cQuery +=" AND (SUBSTRING(B1_COD,4,2) BETWEEN ('"+MV_PAR03+"') AND ('"+MV_PAR04+"')) " + CHR(13) + CHR(10)
          cQuery +=" AND B2_LOCALIZ <>'' AND B1_TIPO = 'PA' AND LEN(B1_COD) = '12' " + CHR(13) + CHR(10)
          If !Empty(MV_PAR02) 
             cQuery +="AND UPPER(SUBSTRING(B2_LOCALIZ,1,2)) = '"+MV_PAR02+"' " + CHR(13) + CHR(10)
          EndIf                               
          cQuery +="ORDER BY B2_LOCALIZ" + CHR(13) + CHR(10)        
          //----------------------------------------
       EndIf                                       
    Endif
    TCQuery cQuery New Alias "QRYPRO"
     
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()

    /*------------- Inibido por Jose   03/12/2021    não é necessário esta ABA -----------------------     
    //Aba 01 - Teste
    oFWMsExcel:AddworkSheet("Aba 1 Teste") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
        oFWMsExcel:AddTable("Aba 1 Teste","Titulo Tabela")
        //Criando Colunas
        oFWMsExcel:AddColumn("Aba 1 Teste","Titulo Tabela","Col1",1,1) //1 = Modo Texto
        oFWMsExcel:AddColumn("Aba 1 Teste","Titulo Tabela","Col2",2,2) //2 = Valor sem R$
        oFWMsExcel:AddColumn("Aba 1 Teste","Titulo Tabela","Col3",3,3) //3 = Valor com R$
        oFWMsExcel:AddColumn("Aba 1 Teste","Titulo Tabela","Col4",1,1)
        //Criando as Linhas
        oFWMsExcel:AddRow("Aba 1 Teste","Titulo Tabela",{11,12,13,sToD('20140317')})
        oFWMsExcel:AddRow("Aba 1 Teste","Titulo Tabela",{21,22,23,sToD('20140217')})
        oFWMsExcel:AddRow("Aba 1 Teste","Titulo Tabela",{31,32,33,sToD('20140117')})
        oFWMsExcel:AddRow("Aba 1 Teste","Titulo Tabela",{41,42,43,sToD('20131217')})
    -------------------------------------------------------------------------------------------------*/         

    //Aba 02 - Produtos
    oFWMsExcel:AddworkSheet("Relatório de Estoque por Localização")
    //Criando a Tabela    
    oFWMsExcel:AddTable("Relatório de Estoque por Localização","Relatório de Estoque por Localização")
    oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização","Produto",1)
    oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização","Descricao --/-- Estoque",1)
    oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização","Estoque",1)
    oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização","Provisorio",1)
    oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização","Observacao",1)
	oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização",dToC(Emissoo),1,4)
    oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização",Hifemm,1)
    oFWMsExcel:AddColumn("Relatório de Estoque por Localização","Relatório de Estoque por Localização",Horass,1,4)

    //Criando as Linhas... Enquanto não for fim da query
    While !(QRYPRO->(EoF()))
          oFWMsExcel:AddRow( "Relatório de Estoque por Localização","Relatório de Estoque por Localização",{;
                     QRYPRO->PRODUTO,;
                     QRYPRO->DESCRICAO,;
                     QRYPRO->ESTOQUE,;
                     QRYPRO->PROVISORIO,;
                     QRYPRO->OBSERVACAO,Emissao,Hifem,Horas;
				     } )

          //Pulando Registro

          QRYPRO->(DbSkip())
    EndDo

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)              //Visualiza a planilha
    oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)
Return

//Sintaxe AddWorkSheet ----------------------
/*--------------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():AddWorkSheet(< cWorkSheet >)-> lRet
Descrição
Adiciona uma Worksheet ( Planilha )
Parâmetros
Nome	    Tipo	    Descrição	                           Default	 Obrigatório  	Referência
cWorkSheet	Caracteres	Nome da planilha que será adicionada                  X	
------------------------------------------------------------------------------*/

//Sintaxe AddTable ------------------------------------------------
/*-----------------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():AddTable(< cWorkSheet >, < cTable >)-> NIL
Descrição
Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
Parâmetros
Nome	    Tipo	    Descrição	                            Default	 Obrigatório	Referência
cWorkSheet	Caracteres	Nome da planilha                                     X	
cTable	    Caracteres	Titulo da tabela que será adicionada                 X	
--------------------------------------------------------------------------------*/

//Sintaxe AADColumn -----------------------------------------------------
/*------------------------------------------------------------------------
Sintaxe
FWMsExcel():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
Descrição
Adiciona uma coluna a tabela de uma Worksheet.
Parâmetros
Nome	    Tipo	    Descrição	                                                       Default	  Obrigatório	 Referência
cWorkSheet	Caracteres	Nome da planilha	                                                              X	
cTable	    Caracteres	Nome da planilha                                                                  X	
cColumn	    Caracteres	Titulo da tabela que será adicionada                                              X	
nAlign	    Numérico	Alinhamento da coluna ( 1-Left,2-Center,3-Right )                                 X	
nFormat	    Numérico	Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )	              X	
lTotal	    Lógico	    Indica se a coluna deve ser totalizada                                            X	
--------------------------------------------------------------------------------------------------*/

// Sintaxe AddRow -------------------------------------------------------
/*----------------------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():AddRow(< cWorkSheet >, < cTable >, < aRow >)-> lRet
Descrição
Adiciona uma linha a tabela de uma Worksheet.
Parâmetros
Nome	    Tipo	            Descrição	                                Default	 Obrigatório	Referência
cWorkSheet	Caracteres	        Nome da planilha                                         X	
cTable	    Caracteres       	Nome da planilha                                         X	
aRow	    Array of Records	Array com as informações da linha da linha               X	
-----------------------------------------------------------------------------------*/

// Sintaxe GetXMLFile --------------------------------------------------------
/*-----------------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():GetXMLFile(< cFile >)-> lRet
Descrição
Cria um arquivo no formato Xlsx. Nome mantido por compatibilidade.
Parâmetros
Nome	Tipo	    Descrição	             Default	Obrigatório	 Referência
cFile	Caracteres	Nome do arquivo fisico                   X	
---------------------------------------------------------------------------*/

// Sintaxe IsWorkSheet  -----------------------------------------
/*---------------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():IsWorkSheet(< cWorkSheet >)-> lRet
Descrição
Verifica se um nome já foi utilizado para definir uma WorkSheet
Parâmetros
Nome	    Tipo	    Descrição	Default 	Obrigatório 	Referência
cWorkSheet	Caracteres	Nome                       X	
-----------------------------------------------------------------------------*/

// Sintaxe SetFontSize ----------------------------------------
/*---------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():SetFontSize(< nFontSize >)-> NIL
Descrição
Define o tamanho para a fonte para todos os estilos da planilha
Parâmetros
Nome      	Tipo	    Descrição	 Default	Obrigatório 	Referência
nFontSize	Numérico	Tamanho                      X	
--------------------------------------------------------------------*/

// Sintaxe SetFont ---------------------------------------------
/*-------------------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():SetFont(< cFont >)-> NIL
Descrição
Define a fonte que será utilizada para todos os estilos da planilha. Caso fonte não seja encontrada será usada Calibri como fonte.
Parâmetros
Nome	Tipo	    Descrição	    Default	 Obrigatório	Referência
cFont	Caracteres	Nome da Fonte                X	
----------------------------------------------------------------------*/

// Sintaxe SetItalic  --------------------------------------------
/*----------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():SetItalic(< lItalic >)-> NIL
Descrição
Define se a fonte terá a configuração "Italico" para todos os estilos da planilha
Parâmetros
Nome	Tipo	Descrição	          Default	Obrigatório 	Referência
lItalic	Lógico	.T. indica que sim	                X	
----------------------------------------------------------------------*/

// Sintaxe SetBold    ----------------------------------------------
/*----------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():SetBold(< lBold >)-> NIL
Descrição
Define se a fonte terá a configuração "Negrito" para todos os estilos da planilha
Parâmetros
Nome	Tipo	 Descrição	         Default	Obrigatório 	Referência
lBold	Lógico	 .T. indica que sim	                X	
----------------------------------------------------------------------*/

// Sintaxe SetUnderLine ------------------------------------------------
/*----------------------------------------------------------------------
Sintaxe
FwMsExcelXlsx():SetUnderLine(< lUnderline >)-> NIL
Descrição
Define se a fonte terá a configuração "Sublinhado" para todos os estilos da planilha
Parâmetros
Nome	    Tipo	    Descrição	           Default	Obrigatório 	Referência
lUnderline	Lógico  	.T. indica que sim                  X	
----------------------------------------------------------------------*/
