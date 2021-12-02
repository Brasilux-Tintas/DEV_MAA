#include "protheus.ch"
/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFISR02     Data....: 19/10/2021       //
// Autor.....: Cleber Orati			                   //
// Descriçao.: Rel. de informações auxiliares para a   //
// DIPAM-B  										   //
// Uso.......: Todas as Empresas 					   //
// 22/10/21(Cleber)->Alteração p/ padrão R4 para se    //
// poder gerar Excel                                   //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Per. de                             //
// mv_par02     // Per Ate                             //
// mv_par03     // Produto(s)                          //
/////////////////////////////////////////////////////////

User Function BRFISR02()
Local oReport := nil
PRIVATE cPerg,MV_PAR01,MV_PAR02,MV_PAR03 
     u_zcfga01( 'BRFISR02' ) //LGS#2021201 - Grava��o de log de utiliza��o da rotina
cPerg    :="BRFISR02"
MV_PAR03 := ""
ValidPerg()
Pergunte(cPerg,.F.)   
//Chama a função para carregar a Classe tReport
oReport := RptDef()
oReport:PrintDialog()

Return(.t.)

Static Function RptDef()
Local oReport := Nil
Local oSection1:= Nil
//Local oBreak
//Local oFunction
//Sintaxe: 
//Classe TReport
//cNome: Nome físico do relatório
//cTitulo: Titulo do Relario
//cPergunta: Nome do grupo de pergunta que sera carredo em parâmetros
//bBlocoCodigo: Execura a função que ira alimenter as TRSection
//TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)
oReport:=TReport():New("INFORMACOES AUXILIARES PARA DIPAM-B", "INFORMACOES AUXILIARES PARA DIPAM-B",cPerg,{|oReport| ReportPrint( oReport ) }, "Rel. de Informações Auxiliares para DIPAM-B")

// Relatorio em retrato 
//oReport:SetPortrait()
oReport:SetLandscape()
// Define se os totalizadores serão impressos em linha ou coluna
oReport:SetTotalInLine(.F.)
//Monstando a primeira seção
oSection1:= TRSection():New(oReport, "Inf. DIPAM-B", NIL, NIL, .F., .T.)
  //               0       1           2        3           4       5         6        7           8      9         10          11       12		  13        14        15        16       17         18
  //           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//cCabec2  := "Tipo NF Nro Nf        Fornecedor                                        Produto                                                  Municipio (ibge)                        Dt Digitação Valor Contábil Cfop TES"

TRCell():New(oSection1, "D1_TIPO" ,"SD1","Tipo NF" ,"@!",1 )
TRCell():New(oSection1, "D1_DOC" ,"SD1","Nro Nf" ,"@!",14)
TRCell():New(oSection1, "A2_NOME" ,"SA2","Fornecedor" ,"@!",50 )
TRCell():New(oSection1, "B1_DESC" ,"SB1","Produto" ,"@!",57 )
TRCell():New(oSection1, "A2_MUN" ,"SA2","Municipio (ibge)" ,"@!",42 )
TRCell():New(oSection1, "D1_DTDIGIT" ,"SD1","Dt Digit" ,"",10 )
TRCell():New(oSection1, "FT_VALCONT" ,"SFT","Valor Contábil" ,"@E 99,999,999,999.99",14 )
TRCell():New(oSection1, "D1_CF" ,"SD1","Cfop" ,"",4 )
TRCell():New(oSection1, "D1_TES" ,"SD1","TES" ,"",3 )


//O parâmetro que indica qual célula o totalizador se refere ,
//será utilizado para posicionamento de impressão do totalizador quando 
//estiver definido que a impressão será por coluna e como conteúdo para a 
//função definida caso não seja informada uma fórmula para o totalizador
//TRFunction():New(oSection1:Cell("B1_COD"),NIL,"COUNT",,,,,.F.,.T.)
Return(oReport)

Static Function ReportPrint(oReport)
Local cAuxSFT,cAuxSD1
Local oSection1 := oReport:Section(1)
Local cAlias := GetNextAlias()
cAuxSFT := "%(SFT.D_E_L_E_T_ <> '*') AND (FT_TIPOMOV = 'E') AND (FT_FILIAL = '"+xFilial("SFT")+"') AND (FT_CLIEFOR = D1_FORNECE) AND (FT_LOJA = D1_LOJA) AND (FT_ITEM = D1_ITEM) AND (FT_NFISCAL = D1_DOC) AND (FT_SERIE = D1_SERIE) AND (FT_CFOP = D1_CF) AND (FT_ENTRADA = D1_DTDIGIT) %"
cAuxSD1 := "%(D1_TIPO NOT IN ('D','B')) AND (D1_TES > '') AND (SFT.R_E_C_N_O_ IS NOT NULL) AND (D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
if !empty(MV_PAR03)
	cAuxSD1 += "AND "+U_ParamSql("D1_COD",MV_PAR03)
endif
cAuxSD1 += "%"
BeginSql alias cAlias

    SELECT D1_TIPO,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,A2_NOME,D1_COD,B1_DESC,A2_MUN,A2_EST,CC2_CODMUN,D1_DTDIGIT, FT_VALCONT ,D1_CF AS CFOP,D1_TES,D1_TOTAL 
    FROM %table:SD1% SD1 
    LEFT OUTER JOIN %table:SFT% SFT ON %Exp:cAuxSFT% 
    LEFT OUTER JOIN %table:SB1% SB1 ON (SB1.%notDel% ) AND (B1_FILIAL = %xfilial:SB1%) AND (B1_COD = D1_COD) 
    LEFT OUTER JOIN %table:SA2% SA2 ON SA2.%notDel% AND (A2_FILIAL = %xfilial:SA2%) AND (A2_COD = D1_FORNECE) AND (A2_LOJA = D1_LOJA) 
    LEFT OUTER JOIN %table:CC2% CC2 ON (CC2.%notDel% ) AND (CC2_FILIAL = %xfilial:CC2% ) AND (CC2_EST = A2_EST) AND (CC2_CODMUN = A2_COD_MUN) 
    WHERE SD1.%notDel% AND D1_FILIAL = %xfilial:SD1% AND %Exp:cAuxSD1% ORDER BY D1_TIPO,D1_SERIE,D1_DOC,D1_FORNECE 

EndSql
dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
oReport:SetMeter((cAlias)->(LastRec()))
While !(cAlias)->( EOF() )
    If oReport:Cancel()
        Exit
    EndIf
    oReport:IncMeter()
    IncProc("Imprimindo " + alltrim((cAlias)->D1_DOC))
    //inicializo a primeira seção
    oSection1:Init()
    //imprimo a seção, relacionando os campos da section com os 
    //valores da tabela


    oSection1:Cell("D1_TIPO" ):SetValue((cAlias)->D1_TIPO )
    oSection1:Cell("D1_DOC" ):SetValue(ALLTRIM((cAlias)->D1_DOC)+"/"+(cAlias)->D1_SERIE )
    oSection1:Cell("A2_NOME" ):SetValue((cAlias)->D1_FORNECE+"-"+(cAlias)->D1_LOJA+"-"+SUBSTR((cAlias)->A2_NOME,1,40) )
    oSection1:Cell("B1_DESC"):SetValue((cAlias)->D1_COD+"-"+SUBSTR((cAlias)->B1_DESC,1,40) )
    oSection1:Cell("A2_MUN"):SetValue(ALLTRIM((cAlias)->A2_MUN)+"/"+(cAlias)->A2_EST+"("+(cAlias)->CC2_CODMUN+")")
    oSection1:Cell("D1_DTDIGIT"):SetValue(SUBSTR((cAlias)->D1_DTDIGIT,7,2)+"/"+SUBSTR((cAlias)->D1_DTDIGIT,5,2)+"/"+SUBSTR((cAlias)->D1_DTDIGIT,1,4))
    oSection1:Cell("FT_VALCONT" ):SetValue((cAlias)->FT_VALCONT )
    oSection1:Cell("D1_CF" ):SetValue((cAlias)->CFOP )
    oSection1:Cell("D1_TES" ):SetValue((cAlias)->D1_TES )
oSection1:Printline()
(cAlias)->(dbSkip())
//imprimo uma linha 
oReport:ThinLine()
Enddo
//finalizo seção
oSection1:Finish()
Return( NIL )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa  : VALIDPERG   Autor: Cleber Orati
Descricao : Grava Perguntas
/*/
Static Function ValidPerg()
Local _sAlias := Alias()




u_xPutSX1(cPerg,"01","Data Dig De ?"      ,"Data Dig De ?" ,"Data Dig De ?"  ,"mv_ch1" ,"D",08,0,0,"G",""  ,"","","","MV_PAR01",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSX1(cPerg,"02","Data Dig Ate ?"      ,"ata Dig Ate ?" ,"ata Dig Ate ?"  ,"mv_ch2" ,"D",08,0,0,"G",""  ,"","","","MV_PAR02",""     ,""     ,""     ,"",""     ,""     ,""     ,"","","","","","","","","",Nil         ,Nil         ,Nil         ,cPerg)
u_xPutSx1(cPerg,"03","Produto(s) ?", "Produto(s) ?", "Produto(s) ?", "mv_ch3", "C",  99, 0, 0, "G", " ", "SB1", " ", " ", "MV_PAR03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)


dbSelectArea(_sAlias)
Return
