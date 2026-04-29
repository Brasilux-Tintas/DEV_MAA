#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BRPCP093  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 05/01/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programação da Produção via Browser                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

#Define STR_PULA    Chr(13)+Chr(10) 

User Function BRFAT110()


Private oTempTable
//Tamanho da janela Automatico

Private aSize := MsAdvSize(.F.)
Private nJanLarg := ( aSize[5] - (aSize[5] * 0.04) ) // reduz 5% da tela altura
Private nJanAltu := ( aSize[6] - (aSize[6] * 0.04) ) // reduz 10% da tela altura

Private nGropLarg := ( aSize[5] - (aSize[5] * 0.52) ) // reduz 5% da tela altura
Private nGrouAltu := ( aSize[6] - (aSize[6] * 0.62) ) // reduz 10% da tela altura

Private aCampos := {}
Private cAliasTmp := "TST_" + RetCodUsr()
Private aColunas := {}
Private cPerg   := Padr("BRFAT110",10)
Pergunte(cPerg,.F.)
Private M_VR_M3M  := {'0','0','0'}



//Fontes
Private cFontUti    := "Tahoma"
Private oFontMod    := TFont():New(cFontUti, , -38)
Private oFontSub    := TFont():New(cFontUti, , -20)
Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
Private oFontBtn    := TFont():New(cFontUti, , -14)
Private oFontSay    := TFont():New(cFontUti, , -12)

Private nAtual := 0

Private nTotal := 0

Private oProcess,oFiltro,oStatus,oValor

Private cFiltro,cStatus

Private cValor := SPACE (30)

Private cUsuario := RetCodUsr()

Private cCodSup := MSuper(cUsuario)

Private oData1,oData2
Private cData1 := cTod("  /  /  ")
Private cData2 := cTod("  /  /  ")
Private cTop

Private oDlgm

u_zcfga01( 'BRFAT110' )  //LGS#2021214 - Gravação de log de utilização da rotina

cTop := iif(Empty(MV_PAR03),200,MV_PAR03)

CriaTab()  

//Cria a janela
DEFINE MSDIALOG oDlgg TITLE "Cockpit Vendas"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL

    //Cria a grid            Top  Left                                                    Rigth bottom 
    oPanGrid := tPanel():New(005, 005, "", oDlgg, , , , RGB(000,000,000), RGB(254,254,254), nGropLarg - 10,  nGrouAltu + 8)
    oGetGrid := FWBrowse():New()
    oGetGrid:SetDataTable()
    oGetGrid:SetAlias(cAliasTmp)
    oGetGrid:DisableReport()
    oGetGrid:DisableFilter()
    oGetGrid:DisableConfig()
    oGetGrid:DisableReport()
    oGetGrid:DisableSeek()
    oGetGrid:DisableSaveConfig()
    oGetGrid:SetFontBrowse(oFontSay)
    oGetGrid:AddLegend(cAliasTmp + "->C5_LIBEROK == 'S'  .AND. Empty("+cAliasTmp + "->C5_NOTA)  ","BR_AMARELO" ,"Pedido Liberado")
    oGetGrid:AddLegend(cAliasTmp + "->C5_LIBEROK == 'S'  .AND." + cAliasTmp + "->C5_NOTA != ''  ","BR_VERMELHO","Pedido Faturado")
    oGetGrid:AddLegend(cAliasTmp + "->C5_LIBEROK != 'S'                                         ","BR_VERDE"   ,"Pedido Aberto")
    oGetGrid:AddLegend(cAliasTmp + "->ZA_FLAG == 'S'                                           ","BR_AZUL"    ,"Separado")
    oGetGrid:SetColumns(aColunas)
    oGetGrid:SetOwner(oPanGrid)
    oGetGrid:SetDoubleClick( {|| VPedido() } )
    oGetGrid:Activate()


    //                         Top Lef  Bot  Rig   
    oGrpCab    := TGroup():New(02 ,02  ,nGrouAltu + 20 ,nGropLarg,,oDlgg,CLR_BLACK,CLR_GRAY,.T.)

    //                         Top Lef  Bot  Rig   
    oGrpRod    := TGroup():New(nGrouAltu + 25 ,02  ,nGrouAltu  + 56 ,nGropLarg,,oDlgg,CLR_BLACK,CLR_GRAY,.T.)
    
    oBtnPes    := TButton():New(nGrouAltu + 32, nGropLarg - 253 , "Pesquisar"          , oDlgg, {|| Pesquisar()} , 55, 018, , oFontBtn, , .T., , , , , , )

    oBtnPar    := TButton():New(nGrouAltu + 32, nGropLarg - 194 , "Parâmetros"          , oDlgg, {|| FPerg()} , 55, 018, , oFontBtn, , .T., , , , , , )

    oButton2 := TButton():New(nGrouAltu + 32, nGropLarg - 135 , "Outras Ações", oDlgg, {||} , 75, 018, , oFontBtn, , .T., , , , , , )
    
    oBtnFechar := TButton():New(nGrouAltu + 32, nGropLarg - 55  , "Fechar"             , oDlgg, {|| Sair()}      , 45, 018, , oFontBtn, , .T., , , , , , )
    
    oMenu := tMenu():new(1, 1, 1, 1, .F., "", oDlgg)
   
    // cria os menus 
    oMenu02 := tMenu():new(0, 0, 0, 0, .T., , oMenu) 
  
    // cria os itens dos menus 
    oMenu0201 := tMenuItem():new(oMenu02, "Incluir"             , , , , {||Processa({|| IncluirPV()()},"Incluir Pedido...")}, , , , , , , , , .T.)
    
    oMenu0202 := tMenuItem():new(oMenu02, "Visualizar"          , , , , {||Processa({|| VisualPV()},"Visualizar Pedido...")}, , , , , , , , , .T.)
    
    oMenu0203 := tMenuItem():new(oMenu02, "Alterar"             , , , , {||Processa({|| AlterarPV()},"Alterar Pedido...")}, , , , , , , , , .T.)
    
    oMenu0204 := tMenuItem():new(oMenu02, "Copiar"              , , , , {||Processa({|| CopiarPV()},"Copiar Pedido...")}, , , , , , , , , .T.)

    //oMenu0205 := tMenuItem():new(oMenu02, "Excluir"             , , , , {||Processa({|| ExcluirPV()},"Excluir Pedido...")}, , , , , , , , , .T.)

    oMenu0206 := tMenuItem():new(oMenu02, "Divide Ped"          , , , , {||Processa({|| U_ZFATP01((cAliasTmp)->C5_NUM)},"Carregando Pedido...")}, , , , , , , , , .T.)
    
    oMenu0207 := tMenuItem():new(oMenu02, "Estorna Div Ped"     , , , , {||Processa({|| U_EstDivPed((cAliasTmp)->C5_NUM)},"Carregando Pedido...")}, , , , , , , , , .T.)

    oMenu0208 := tMenuItem():new(oMenu02, "Meus Representantes" , , , , {||Processa({|| Mrep()},"Carregando Representantes...")}, , , , , , , , , .T.)
   
    /*
    1 - Incluir
    2 - Visualizar
    3 - Alterar
    4 - Copiar
    5 - Excluir
    6 - Dividir
    7 - Estornar
    8 - M Repre
    */

    // adiciona o subitem do submenu   
    oMenu02:add(oMenu0201) 
    oMenu02:add(oMenu0202) 
    oMenu02:add(oMenu0203)  
    oMenu02:add(oMenu0204)  
    //oMenu02:add(oMenu0205)  
    oMenu02:add(oMenu0206)  
    oMenu02:add(oMenu0207)  
    oMenu02:add(oMenu0208)  
  
    oButton2:bAction  := {|| } 
    oButton2:setPopupMenu(oMenu02) 
        


    @ nGrouAltu + 28, 310 SAY OemToAnsi("Dt Final")  SIZE 060,09 COLOR CLR_BLACK  PIXEL OF oDlgg
    @ nGrouAltu + 35, 310 MSGET oData2 VAR cData2 SIZE 050,14 PIXEL OF oDlgg
   
    @ nGrouAltu + 28, 256 SAY OemToAnsi("Dt Inicial")  SIZE 060,09 COLOR CLR_BLACK  PIXEL OF oDlgg
    @ nGrouAltu + 35, 256 MSGET oData1 VAR cData1 SIZE 050,14 PIXEL OF oDlgg

    @ nGrouAltu + 28, 190 SAY OemToAnsi("Status")  SIZE 060,09 COLOR CLR_BLACK  PIXEL OF oDlgg
    aStatus := {"1=Todos","2=Em Pedido","3=Aprovados","4=Borderô Pedido","5=Em Separação","7=Separados","8=Faturados","9=Coletados"}
    @ nGrouAltu + 35, 190 MSCOMBOBOX oStatus VAR cStatus ITEMS aStatus SIZE 060, 040 OF oDlgg COLORS 0, 10 PIXEL
    
    @ nGrouAltu + 35, 075 MSGET oValor VAR cValor PICTURE '@!' SIZE 110,14 PIXEL OF oDlgg

    @ nGrouAltu + 28, 011 SAY OemToAnsi("Filtro")  SIZE 060,09 COLOR CLR_BLACK  PIXEL OF oDlgg
    @ nGrouAltu + 35, 010 MSCOMBOBOX oFiltro VAR cFiltro ITEMS{"0=Todos","1=Cod.Cliente","2=Razão Social","3=CNPJ\CPF","4=Nota","5=Pedido","6=Vendedor"};
    SIZE 060, 040 OF oDlgg COLORS 0, 10 ON CHANGE AJUSTACAM()  PIXEL

    Activate MsDialog oDlgg Centered
    
Return

Static Function Sair()
    oDlgg:End()
return()

Static Function FPerg()
    Pergunte(cPerg,.T.)
return()

Static Function Pesquisar()

    oProcess := MsNewProcess():New({|| Consultar(oProcess)}, "Processando...", "Aguarde...", .T.)
    oProcess:Activate()

return()

Static Function CriaTab()

aCampos := {}
//Campos da Temporária
aAdd(aCampos, { "C5_NUM"       , "C", TamSX3("C5_NUM")      [1] , 0                     })
aAdd(aCampos, { "C5_EMISSAO"   , "D", TamSX3("C5_EMISSAO")  [1] , 0                     })
aAdd(aCampos, { "C5_CLIENTE"   , "C", TamSX3("A1_NOME")     [1] , 0                     })
aAdd(aCampos, { "A1_NOME"      , "C", TamSX3("A1_NOME")     [1] , 0                     })
aAdd(aCampos, { "A1_EST"       , "C", TamSX3("A1_EST")      [1] , 0                     })
aAdd(aCampos, { "ESTOQUE"      , "C", TamSX3("A1_EST")      [1] , 0                     })
aAdd(aCampos, { "PRAZO"        , "C", 4                         , 0                     })
aAdd(aCampos, { "DCORRIDO"     , "C", TamSX3("A1_EST")      [1] , 0                     })
aAdd(aCampos, { "PREVISAO"     , "D", TamSX3("C5_EMISSAO")  [1] , 0                     })
aAdd(aCampos, { "DTSESPACHO"   , "D", TamSX3("C5_EMISSAO")  [1] , 0                     })
aAdd(aCampos, { "ZF_EMISSAO"   , "D", TamSX3("ZF_EMISSAO")  [1] , 0                     })
aAdd(aCampos, { "F2_EMISSAO"   , "D", TamSX3("F2_EMISSAO")  [1] , 0                     })
aAdd(aCampos, { "SEPINI"       , "D", TamSX3("F2_EMISSAO")  [1] , 0                     })
aAdd(aCampos, { "SEPFIM"       , "D", TamSX3("F2_EMISSAO")  [1] , 0                     })
aAdd(aCampos, { "ZZ0_ENTREG"   , "D", TamSX3("ZZ0_ENTREG")  [1] , 0                     })
aAdd(aCampos, { "C5_DTAPR"     , "D", TamSX3("C5_DTAPR")    [1] , 0                     })
aAdd(aCampos, { "C5_X_OBSFA"   , "M", 5                         , 0                     })
aAdd(aCampos, { "C5_PEDPROG"   , "D", TamSX3("C5_PEDPROG")  [1] , 0                     })
aAdd(aCampos, { "C5_DESCON4"   , "N", TamSX3("C5_DESCON4")  [1] , 2                     })
  

aAdd(aCampos, { "C5_TPFRETE"   , "C", 10                         , 0                     })
aAdd(aCampos, { "C5_BIPADO "   , "C", 10                         , 0                     })


aAdd(aCampos, { "A1_REGIAO"    , "C", TamSX3("A1_REGIAO")   [1] , 0                     })
aAdd(aCampos, { "C5_VEND1"     , "C", 30                        , 0                     })
aAdd(aCampos, { "C5_CONDPAG"   , "C", 30                        , 0                     })
aAdd(aCampos, { "C5_COMIS1"    , "C", TamSX3("C5_COMIS1")   [1] , 0                     })

aAdd(aCampos, { "C5_LIBEROK"   , "C", TamSX3("C5_LIBEROK")  [1] , 0                     })

aAdd(aCampos, { "C5_NOTA"      , "C", TamSX3("C5_NOTA")     [1] , 0                     })

aAdd(aCampos, { "C5_LIBCAD"    , "C", TamSX3("C5_USRCAD")   [1] , 0                     })
aAdd(aCampos, { "C5_USRCAD"    , "C", TamSX3("C5_USRCAD")   [1] , 0                     })

aAdd(aCampos, { "C5_LIBCRE"    , "C", TamSX3("C5_USRCRE")   [1] , 0                     })
aAdd(aCampos, { "C5_USRCRE"    , "C", TamSX3("C5_USRCRE")   [1] , 0                     })

aAdd(aCampos, { "C5_LIBPED"    , "C", TamSX3("C5_USRPED")   [1], 0                     })
aAdd(aCampos, { "C5_USRPED"    , "C", TamSX3("C5_USRPED")   [1], 0                     })

aAdd(aCampos, { "C5_LIBDIR"    , "C", TamSX3("C5_USRDIR")   [1] , 0                     })
aAdd(aCampos, { "C5_USRDIR"    , "C", TamSX3("C5_USRDIR")   [1] , 0                     })


aAdd(aCampos, { "C5_APROVA"    , "C", 30                        , 0                     })
aAdd(aCampos, { "C5_X_PVSIM"   , "C", TamSX3("C5_X_PVSIM")  [1] , 0                     })

//Cria a tabela temporária
oTempTable:= FWTemporaryTable():New(cAliasTmp)
oTempTable:SetFields( aCampos )
oTempTable:Create()

//Busca as colunas do browse
aColunas := fCriaCols()

return()

Static Function fCriaCols()
    Local nAtual   := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
      
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, {"C5_NUM"      , "Pedido"                     ,   "C", 4                        , 0, ""                      } )
    aAdd(aEstrut, {"C5_APROVA"   , "Aprovado"                   ,   "C", 10                       , 0, ""                      } )
    aAdd(aEstrut, {"C5_X_OBSFA"  , "Obs"                        ,   "C", 10                       , 0, ""                      } )
    aAdd(aEstrut, {"C5_CLIENTE"  , "Cliente"                    ,   "C", TamSX3('A1_NREDUZ')[01]  , 0, ""                      } )
    aAdd(aEstrut, {"A1_EST"      , "UF"                         ,   "C", TamSX3('A1_EST')   [01]  , 0, ""                      } )
    aAdd(aEstrut, {"C5_VEND1"    , "Repres"                     ,   "C", TamSX3('A3_COD')   [01]  , 0, ""                      } )
    aAdd(aEstrut, {"C5_EMISSAO"  , "Emissão"                    ,   "D", 8                        , 0, ""                      } )  
    aAdd(aEstrut, {"C5_DTAPR"    , "Dt.Aprova"                  ,   "D", TamSX3('C5_DTAPR')  [01] , 0, ""                      } )
    aAdd(aEstrut, {"C5_CONDPAG"  , "Cond.Pag"                   ,   "C", 15                       , 0, ""                      } )
    aAdd(aEstrut, {"PRAZO"       , "Prz Médio"                  ,   "C", 5                        , 0, ""                      } )
    aAdd(aEstrut, {"C5_COMIS1"   , "Comissão"                   ,   "C", 08                       , 0, ""                      } )
    aAdd(aEstrut, {"C5_DESCON4"  , "Desconto  4 "               ,   "N", TamSX3('C5_DESCON4')[01] , 0, ""                      } )
    aAdd(aEstrut, {"C5_TPFRETE"  , "Tp.Frete"                   ,   "C", 08                       , 0, ""                      } )
    aAdd(aEstrut, {"ESTOQUE"     , "Especifico"                 ,   "C", TamSX3('A1_EST')    [01] , 0, ""                      } )
    aAdd(aEstrut, {"PREVISAO"    , "Previsão de Faturamento"    ,   "D", TamSX3('C5_EMISSAO')[01] , 0, ""                      } )
    aAdd(aEstrut, {"C5_PEDPROG"  , "Data Pedido Programado"     ,   "D", TamSX3('C5_PEDPROG')[01] , 0, ""                      } )
    aAdd(aEstrut, {"ZF_EMISSAO"  , "Bord.Pedido"                ,   "D", TamSX3('ZF_EMISSAO')[01] , 0, ""                      } )
    aAdd(aEstrut, {"SEPINI"      , "Ini.Separação"              ,   "D", TamSX3('F2_EMISSAO')[01] , 0, ""                      } )
    aAdd(aEstrut, {"SEPFIM"      , "Fim.Separação"              ,   "D", TamSX3('F2_EMISSAO')[01] , 0, ""                      } )
    aAdd(aEstrut, {"DCORRIDO"    , "Dias Ped\NF"                ,   "C", TamSX3('A1_EST')    [01] , 0, ""                      } )
    aAdd(aEstrut, {"F2_EMISSAO"  , "Faturamento"                ,   "D", TamSX3('F2_EMISSAO')[01] , 0, ""                      } )
    aAdd(aEstrut, {"C5_NOTA"     , "Nota"                       ,   "C", 08                       , 0, ""                      } )
    aAdd(aEstrut, {"ZZ0_ENTREG"  , "Número da Coleta"           ,   "D", TamSX3('C5_EMISSAO')[01] , 0, ""                      } )
    aAdd(aEstrut, {"DTSESPACHO"  , "Data Despacho"              ,   "D", TamSX3('C5_EMISSAO')[01] , 0, ""                      } )
    aAdd(aEstrut, {"C5_LIBCAD"   , "Lib. Cadast"                ,   "C", 10                       , 0, ""                      } )
    aAdd(aEstrut, {"C5_LIBCRE"   , "Lib. Cred"                  ,   "C", 10                       , 0, ""                      } )
    aAdd(aEstrut, {"C5_LIBPED"   , "Ped. Liber"                 ,   "C", 10                       , 0, ""                      } )
    aAdd(aEstrut, {"C5_LIBDIR"   , "Aprovação Final"            ,   "C", 10                       , 0, ""                      } )

    //aAdd(aEstrut, {"A1_REGIAO"   , "Região"            ,   "C", TamSX3('A1_REGIAO') [01] , 0, ""                      } )
    //aAdd(aEstrut, {"C5_LIBEROK"   , "C5_LIBEROK"       ,   "C", TamSX3('C5_LIBEROK') [01] , 0, ""                      } )
    //aAdd(aEstrut, {"C5_BIPADO"   , "Bipado  "          ,   "C", 08                      , 0, ""                      } )
    //aAdd(aEstrut, {"A1_NOME"     , "Nome"              ,   "C", 30                       , 0, ""                      } )
      
  
    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| (cAliasTmp)->" + aEstrut[nAtual][1] +"}"))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
        //oColumn:bHeaderClick := &("{|| fOrdena('" + aEstrut[nAtual][1] + "') }")
  
        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next

Return aColunas

Static Function Consultar(oObj)
Local cQuery1 := ""
    Pergunte(cPerg,.F.)

	// retorna para casos em que não existe supervisor e filtro
    If (cFiltro == "0") .AND. Empty(cCodSup)
        Return()
    EndIf

    cTop := iif(Empty(MV_PAR03),200,MV_PAR03)

    If ValType (cTop) == "N"
        cQuery1 := " SELECT TOP "+AllTrim(Str(cTop))+" C5_NUM,C5_EMISSAO,C5_CLIENTE,C5_VEND1 AS C5_VEND1,C5_COMIS1,C5_LIBEROK,C5_NOTA," + STR_PULA
    Else
        cQuery1 := " SELECT TOP 200 C5_NUM,C5_EMISSAO,C5_CLIENTE,C5_VEND1+'-'+A3_NOME AS C5_VEND1,C5_COMIS1,C5_LIBEROK,C5_NOTA," + STR_PULA
    EndIf

	
	cQuery1 += " C5_DTAPR,C5_USRAPR,C5_PEDDIV,C5_XNROCOL,C5_X_PVSIM," + STR_PULA
    
    cQuery1 += " C5_PEDPROG,C5_DATA1,C5_DATA2,C5_DATA3,C5_DATA4,C5_PEDPROG," + STR_PULA
    cQuery1 += " C5_PARC1,C5_PARC2,C5_PARC3,C5_PARC4," + STR_PULA
    cQuery1 += " A1_NOME,A1_EST,A1_REGIAO," + STR_PULA

    cQuery1 += " C5_USRPED,C5_LIBPED, " + STR_PULA
    cQuery1 += " C5_LIBCAD,C5_USRCAD, " + STR_PULA
    cQuery1 += " C5_LIBCRE,C5_USRCRE, " + STR_PULA
    cQuery1 += " C5_LIBDIR,C5_USRDIR, " + STR_PULA

    cQuery1 += " C5_PEDPROG,C5_DESCON4, " + STR_PULA

    cQuery1 += " C5_CONDPAG+'-'+E4_DESCRI AS C5_CONDPAG, " + STR_PULA

    cQuery1 += " CASE " + STR_PULA
    cQuery1 += "    WHEN C5_NOTA <> '' THEN DATEDIFF(DAY,C5_EMISSAO,F2_EMISSAO)  " + STR_PULA
    cQuery1 += "    WHEN C5_NOTA = '' THEN DATEDIFF(DAY,C5_EMISSAO,GETDATE())    " + STR_PULA
    cQuery1 += " END DIAS_CORRIDO, " + STR_PULA

    cQuery1 += " CASE " + STR_PULA
    cQuery1 += "    WHEN C5_TPFRETE = 'F' THEN 'FOB'  " + STR_PULA
    cQuery1 += "    WHEN C5_TPFRETE = 'C' THEN 'CIF'  " + STR_PULA
    cQuery1 += " END C5_TPFRETE, " + STR_PULA

    
    
    cQuery1 += " ( " + STR_PULA
    cQuery1 += " SELECT COUNT(B1_ESTOQUE) FROM SC6010 C6  " + STR_PULA
    cQuery1 += " INNER JOIN SB1010 B1 ON B1.D_E_L_E_T_ = '' AND B1.B1_FILIAL = C5_FILIAL AND B1.B1_COD = C6.C6_PRODUTO " + STR_PULA
    cQuery1 += " AND B1_ESTOQUE = 'N' " + STR_PULA
    cQuery1 += " WHERE C6.C6_NUM = C5_NUM AND C6.C6_FILIAL = C5_FILIAL AND C6.D_E_L_E_T_ = '' "  + STR_PULA
    cQuery1 += " )ESTOQUE, " + STR_PULA

    cQuery1 += " CASE " + STR_PULA
    cQuery1 += "WHEN C5_APROVA = '0' THEN 'Aguardando liberação\Recusa' " + STR_PULA
    cQuery1 += "WHEN C5_APROVA = '1' THEN 'Liberado' " + STR_PULA
    cQuery1 += "WHEN C5_APROVA = '2' THEN 'Recusado' " + STR_PULA
    cQuery1 += " END C5_APROVA  " + STR_PULA

    cQuery1 += " ,SZB.ZB_CODIGO,ZA_PREVDSP PREVISAO,ZA_CODIGO,ZA_DTDESPA DTSESPACHO " + STR_PULA

    cQuery1 += " ,ZF_CODIGO,ZF_EMISSAO,F2_EMISSAO,ZZ0_ENTREG,C5_DTAPR, "  + STR_PULA // Bordero de Pedidos

    cQuery1 += " ISNULL(CAST(CAST(C5_X_OBSFA AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C5_X_OBSFA " + STR_PULA
    
    cQuery1 += " FROM  "+RetSqlName("SC5")+" SC5  " + STR_PULA
    cQuery1 += " INNER JOIN "+RetSqlName("SA3")+" SA3 ON SA3.D_E_L_E_T_ = '' AND A3_COD = C5_VEND1 " + STR_PULA
    cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_ = '' AND A1_COD = C5_CLIENTE " + STR_PULA
    cQuery1 += " LEFT  JOIN "+RetSqlName("SE4")+" SE4 ON SE4.D_E_L_E_T_ = '' AND E4_CODIGO = C5_CONDPAG " + STR_PULA
    cQuery1 += " LEFT  JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_ = '' AND F2_FILIAL = C5_FILIAL AND F2_DOC = C5_NOTA AND F2_SERIE = C5_SERIE " + STR_PULA
    cQuery1 += " LEFT  JOIN "+RetSqlName("ZZ0")+" ZZ0 ON (ZZ0.D_E_L_E_T_ <> '*') AND (ZZ0_FILIAL = '"+xFilial("ZZ0")+"') AND (C5_NUM = ZZ0_PEDIDO) " + STR_PULA

    //ITENS DE BORDERO DE DESPACHO  
    cQuery1 += " LEFT JOIN SZB010 SZB ON SZB.D_E_L_E_T_ = '' AND SUBSTRING(ZB_PEDIDO,3,6) =  C5_NUM AND ZB_FILIAL = C5_FILIAL " + STR_PULA
    
    // Bordero de Despacho
    cQuery1 += " LEFT JOIN "+RetSqlName("SZA")+" SZA  ON SZA.D_E_L_E_T_ = '' AND SZA.ZA_CODIGO = SZB.ZB_CODIGO AND SZA.ZA_FILIAL = C5_FILIAL "  + STR_PULA
    
    //ITENS BORDERO PEDIDOS         
    cQuery1 += " LEFT OUTER JOIN "+RETSQLNAME("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = C5_FILIAL) AND (C5_NUM = RIGHT(ZG_PEDIDO,6)) " + STR_PULA
    
    //BORDERO DE PEDIDOS APROVADOS
    cQuery1 += "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = '"+xFilial("SZF")+"') AND (ZG_CODIGO = ZF_CODIGO) " + STR_PULA

    cQuery1 += " WHERE SC5.D_E_L_E_T_ = '' AND C5_TIPO = 'N' " + STR_PULA       
    //cQuery1 += " AND A3_SUPER  = '002088' "
    
    If (cFiltro == "0")
        cQuery1 += " AND (A3_SUPER  = '"+cCodSup+"' OR A3_XSUPER  = '"+cCodSup+"') " + STR_PULA
    Endif
    //cQuery1 += " AND A3_USUCORP  = '"+cCodSup+"' "

    cQuery1 += " AND C5_FILIAL = '"+xFilial("SC5")+"' " + STR_PULA

    cValor := AllTrim(cValor)
    If (cFiltro != "0") .AND. (Empty(cValor))
        FWAlertInfo("Atenção: Informe um valor para a Pesquisa! ", "Atenção!")
        return()
    EndIf

    If  cFiltro == "1" 
        cQuery1 += " AND A1_COD = '"+cValor+"'  " + STR_PULA
    elseif cFiltro == "2"
        cQuery1 += " AND (A1_NOME LIKE '%"+cValor+"%' OR A1_NREDUZ LIKE '%"+cValor+"%' ) " + STR_PULA
    elseif cFiltro == "3"
        cQuery1 += " AND A1_CGC LIKE '%"+cValor+"%' " + STR_PULA
    elseif cFiltro == "4"
        cQuery1 += " AND C5_NOTA = '"+cValor+"' " + STR_PULA
    elseif cFiltro == "5"     
        cQuery1 += " AND C5_NUM = '"+cValor+"' " + STR_PULA
    elseif cFiltro == "6"             
        cQuery1 += " AND (C5_VEND1 = '"+cValor+"' OR A3_NOME = '"+cValor+"' ) " + STR_PULA
    Endif 

    //aStatus := {"1=Todos","2=Em Pedido","3=Aprovados","4=Borderô Pedido","5=Em Separação","7=Separados","8=Faturados","9=Coletados"}

    If cStatus == "2"
        cQuery1 += " AND C5_APROVA <> '1' AND C5_LIBEROK = '' " + STR_PULA
    elseif cStatus == "3"
        cQuery1 += " AND C5_APROVA = '1' AND C5_LIBEROK <> '' AND C5_NOTA = ''  " + STR_PULA
        cQuery1 += " AND ZF_EMISSAO IS NULL " + STR_PULA
    elseif cStatus == "4"
        cQuery1 += " AND ZF_EMISSAO IS NOT NULL AND C5_NOTA = '' AND ZA_DTDESPA = ''  " + STR_PULA
        cQuery1 += " AND NOT EXISTS (SELECT  TOP 1 ZZK_DATA " + STR_PULA
        cQuery1 += " FROM "+RETSQLNAME("SC5")+" C5 "  + STR_PULA
        cQuery1 += " INNER JOIN "+RETSQLNAME("ZZK")+" ZZK ON ZZK.D_E_L_E_T_ = '' AND ZZK_PEDIDO = C5.C5_NUM AND ZZK_FILIAL = C5.C5_FILIAL  " + STR_PULA
        cQuery1 += " WHERE C5.D_E_L_E_T_ = '' AND C5.C5_FILIAL = '"+xFilial("SC5")+"' " + STR_PULA
        cQuery1 += " AND C5_NUM = SC5.C5_NUM " + STR_PULA
        cQuery1 += " ORDER BY ZZK_DATA )" + STR_PULA                 

    elseif cStatus == "5"
        cQuery1 += " AND ZA_DTDESPA = ''  "   + STR_PULA
        cQuery1 += " AND C5_NOTA = ''  "   + STR_PULA
        cQuery1 += " AND EXISTS (SELECT  TOP 1 ZZK_DATA " + STR_PULA
        cQuery1 += " FROM "+RETSQLNAME("SC5")+" C5 "  + STR_PULA
        cQuery1 += " INNER JOIN "+RETSQLNAME("ZZK")+" ZZK ON ZZK.D_E_L_E_T_ = '' AND ZZK_PEDIDO = C5.C5_NUM AND ZZK_FILIAL = C5.C5_FILIAL  " + STR_PULA
        cQuery1 += " WHERE C5.D_E_L_E_T_ = '' AND C5.C5_FILIAL = '"+xFilial("SC5")+"' " + STR_PULA
        cQuery1 += " AND C5_NUM = SC5.C5_NUM " + STR_PULA
        cQuery1 += " ORDER BY ZZK_DATA ) "  + STR_PULA
        cQuery1 += " AND ZA_FLAG NOT IN ('T','S')   "  + STR_PULA                
    
    elseif cStatus == "7"
        cQuery1 += " AND ZA_FLAG IN ('T','S') "  + STR_PULA     
        //cQuery1 += " AND C5_NOTA = ''  "           
                      
    elseif cStatus == "8"
        cQuery1 += " AND C5_NOTA <> ''  "    + STR_PULA
    elseif cStatus == "9"  
        cQuery1 += " AND ZZ0_ENTREG <> ''  "    + STR_PULA
    EndIf

    If (cData1 != cTod("  /  /  ")) .And. (cData2 != cTod("  /  /  "))
        cQuery1 += " AND C5_EMISSAO BETWEEN '"+DTOS(cData1)+"' AND '"+DTOS(cData2)+"' "    + STR_PULA
    EndIf

    If (MV_PAR02 == 1) .AND. (cFiltro == "0")
        cQuery1 += "AND C5_APROVA <> '2' "
    EndIf

    If (MV_PAR04 == 2)
        cQuery1 += "AND C5_X_OBSFA <> '' "
    EndIf

    cQuery1 += " ORDER BY "+ FOrden() + STR_PULA

    /* verifica quem é o usuário */
    cUsuario = PswChave(RetCodUsr())
    if (cUsuario == 'neliedercorneta') 
        /* gera log do script sql */
        GravaSQL(cQuery1)
    Endif

    /* 
        
        SZG ITENS BORDERO PEDIDOS         

        SZA BORDERO DE DESPACHO           
        SZB ITENS DE BORDERO DE DESPACHO  

        SZF BORDERO DE PEDIDOS APROVADOS   

        { 'SZA->ZA_FLAG == "C"', 'BR_AMARELO'},; //Conferência
        { 'SZA->ZA_FLAG == "P"', 'BR_AZUL'   },; //Separado Parcialmente
        { 'SZA->ZA_FLAG == "T"', 'BR_PRETO'  },; //Separado Totalmente
        { 'SZA->ZA_FLAG == "S"', 'DISABLE'   } } //Baixado


    
    /* verifica se arquivo está aberto e finaliza */
    IF Select("TMP") <> 0
        DbSelectArea("TMP")
        DbCloseArea()
    ENDIF
    
    
    TCQUERY cQuery1 NEW ALIAS "TMP"  
    Count To nTotal
    oObj:SetRegua1(nTotal)
    
    // Alimenta a Grid com os dados da consulta
    Popular(oObj) 

return()


Static Function Popular(oObj)
Local cPrazo := {}
Local _cCondPag
Local _nQtdeParc := 0
Local _aPrazos := {}
Local _nPrzMedio := 0 
Local _lRet 

TMP->(dbGoTop())

IF Select(cAliasTmp) <> 0
        DbSelectArea(cAliasTmp)
        DbCloseArea()
        CriaTab()
        //oTempTable:Delete()
ENDIF



nAtual := 0

While TMP->(!EOF()) 
        
        //Incrementa a mensagem na régua
        nAtual++
        oObj:IncRegua1("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

        //Grava na temporária
        RecLock(cAliasTmp, .T.)
            (cAliasTmp)->C5_NUM      := TMP->C5_NUM
            (cAliasTmp)->C5_EMISSAO  := SToD(TMP->C5_EMISSAO)
            (cAliasTmp)->C5_TPFRETE  := TMP->C5_TPFRETE


            (cAliasTmp)->C5_CLIENTE  := AllTrim(TMP->C5_CLIENTE)+' - '+AllTrim(TMP->A1_NOME)
            //(cAliasTmp)->A1_NOME     := TMP->A1_NOME            
            (cAliasTmp)->A1_EST      := TMP->A1_EST
            (cAliasTmp)->ESTOQUE     := AllTrim(Str(TMP->ESTOQUE))

            (cAliasTmp)->C5_CONDPAG  := TMP->C5_CONDPAG

            (cAliasTmp)->C5_X_OBSFA  := TMP->C5_X_OBSFA
            (cAliasTmp)->C5_DESCON4  := TMP->C5_DESCON4

            

            //if nAtual == 101
               // MsgAlert("aa")
            //EndIf
            @_cCondPag := SUBSTR(TMP->C5_CONDPAG,1,3)
            fCalPrzMed( @_cCondPag, @_nQtdeParc, @_aPrazos, @_nPrzMedio, @_lRet )
            

            //cPrazo := fCalcPrazo( dDataBase, SUBSTR(TMP->C5_CONDPAG,1,3) )
            cPrazo := AllTrim(Str(@_nPrzMedio))

            (cAliasTmp)->PRAZO       := cPrazo //AllTrim(Str(cPrazo[2]))      

            (cAliasTmp)->C5_BIPADO   := Bipado(TMP->C5_NUM)

            (cAliasTmp)->DCORRIDO    := AllTrim(Str(TMP->(DIAS_CORRIDO)))            
            (cAliasTmp)->PREVISAO    := sToD(TMP->(PREVISAO))            
            (cAliasTmp)->DTSESPACHO  := sToD(TMP->(DTSESPACHO))   
            (cAliasTmp)->ZF_EMISSAO  := sToD(TMP->(ZF_EMISSAO))
            (cAliasTmp)->F2_EMISSAO  := sToD(TMP->(F2_EMISSAO))
            (cAliasTmp)->ZZ0_ENTREG  := sToD(TMP->(ZZ0_ENTREG))
            (cAliasTmp)->C5_DTAPR    := sToD(TMP->(C5_DTAPR))
            (cAliasTmp)->C5_PEDPROG  := sToD(TMP->(C5_PEDPROG))
            


            (cAliasTmp)->SEPINI      := sToD(SepIni(TMP->C5_NUM))
            
            if cStatus != "5"
                (cAliasTmp)->SEPFIM      := sToD(SepFim(TMP->C5_NUM))
            EndIf
         
            
            
            (cAliasTmp)->A1_REGIAO   := TMP->A1_REGIAO            
                       
            
            (cAliasTmp)->C5_VEND1    := TMP->C5_VEND1            
            (cAliasTmp)->C5_COMIS1   := AllTrim(Str(TMP->C5_COMIS1))            
            (cAliasTmp)->C5_LIBEROK  := TMP->C5_LIBEROK            
            (cAliasTmp)->C5_NOTA     := TMP->C5_NOTA            
            
            If TMP->C5_LIBCAD == "T"
                (cAliasTmp)->C5_LIBCAD   := TMP->C5_USRCAD  
            else
                (cAliasTmp)->C5_LIBCAD   := ""
            EndIf        

            
            If TMP->C5_LIBCRE == "T"
                (cAliasTmp)->C5_LIBCRE   := TMP->C5_USRCRE  
            else
                (cAliasTmp)->C5_LIBCRE   := ""
            EndIf        
            //(cAliasTmp)->C5_LIBCRE   := TMP->C5_LIBCRE  
            
            If TMP->C5_LIBPED == "T"
                (cAliasTmp)->C5_LIBPED   := TMP->C5_USRPED  
            else
                (cAliasTmp)->C5_LIBPED   := ""
            EndIf        
            
            If TMP->C5_LIBDIR == "T"
                (cAliasTmp)->C5_LIBDIR   := TMP->C5_USRDIR  
            else
                (cAliasTmp)->C5_LIBDIR   := ""
            EndIf  
            
           // (cAliasTmp)->C5_LIBDIR   := TMP->C5_LIBDIR   
            (cAliasTmp)->C5_APROVA   := TMP->C5_APROVA   
            
                     
            
            (cAliasTmp)->(MsUnlock())
        TMP->(DBSKIP())
    Enddo 
     (cAliasTmp)->(dbGoTop())
     oGetGrid:Activate()
    

return()


Static Function GravaSQL(script)

Local cArq := ""


cArq := "C:\Temp\sql.txt" //a pasta deve ser válida.


MemoWrite ( cArq , script )


Return

/*/{Protheus.doc} fCalcPrazo
Calcula prazos de pagamentos - Desenvolvida a partir do MTA410, regras de negócios comerciais (Politica de Vendas Brasilux/Dissoltex)
@type function
@version  v.2022,01
@author Luis Gustavo de Souza
@since 19/01/2022
@param _dDiaFat, variant, Data que o pedido será faturado
@param _cCondPag, variant, Condição de pagamento do pedido
@return array, Array contendo três parâmetros array com os prazos, prazo médio, array contendo vencimentos
/*/
Static Function fCalcPrazo( _dDiaFat, _cCondPag )
       Local _aVenctos := {}
       Local _nQtdePar := 0
       Local _nPrazoMd := 0
       Local _nTotTp9  := 0
       Local _nY
       Local _cCampo   := ""
       Local _aPrazos  := {}
       
       DbSelectArea('SE4')
       SE4->( DbSetOrder( 1 ) )
       If SE4->( DbSeek( xFilial('SE4') + _cCondPag ) )
          If SE4->E4_TIPO == "9"
             For _nY := 1 to 4
                 _cCampo := "M->C5_DATA" + Alltrim( Str( _nY ) )
                 If !Empty( &_cCampo )
                    aAdd( _aVenctos, { &_cCampo, 0 } )
                    _cCampo  := "TMP->C5_PARC" + Alltrim (Str( _nY ) )
                    _nTotTp9 += &_cCampo
                    _aVenctos[_nY][2] := &_cCampo
                    _nQtdePar++
                 Endif
             Next
             If _nQtdePar == 0
                _nQtdePar := 1
                _nTotTp9  := 1
                aAdd( _aVenctos, { dDataBase, 1 } )
             Endif
          Else
             //Verifica se a condição é a vista ( menor igual a 7 dias ) e considera a condição 001
             If ( SE4->E4_TIPO == "1" ) .AND. LEN( ( ALLTRIM( SE4->E4_COND ) ) ) == 1
                If Val( Alltrim( SE4->E4_COND ) ) <= 7
                   _cCondPag := "001"
                Endif
             Endif
             _aVenctos := Condicao( 100, _cCondPag, 0.00, _dDiaFat, 0.00 )
          Endif
       Else
          _nTotTp9  := 1
          _aVenctos := {}
          aAdd( aVenctos, { dDataBase, 1 } )
       Endif
       If ( _nTotTp9 > 0 )
          If !Empty( TMP->C5_PEDPROG )
             _dDiaFat := TMP->C5_PEDPROG //Considerar dia do Faturamento data do pedido programado para o caso de datas fixas de vencimento (Chamado 014805)
          Endif
       Endif
       //Monta vetor com prazos em dias + % de cada parcela sobre total e cálculo do prazo médio
       _nPrazoMd := 0
       For _nY := 1 To Len( _aVenctos )
            if _nTotTp9 <> 1
                aAdd( _aPrazos, { _aVenctos[_nY][1] - _dDiaFat + 1, Iif( _nTotTp9 > 0, _aVenctos[_nY][2] / _nTotTp9, 1 / Len( _aVenctos ) ) } )
                _nPrazoMd += _aPrazos[_nY][1]
            EndIf    
       Next
       If Len( _aVenctos ) > 0
          _nPrazoMd := _nPrazoMd / Len( _aVenctos )
       Endif
Return { _aPrazos, _nPrazoMd, _aVenctos }


Static Function MSuper(cUsuario)
Local cRet := ""
Local cQuery3
Local qTotal

    // verificar se o usuário está cadastrado em algum representante
    cQuery3 := " SELECT TOP 1  A3_SUPER,A3_COD,A3_NOME "
    cQuery3 += " FROM "+RetSqlName("SA3")+" SA3 "
    cQuery3 += " WHERE A3_CODUSR = '"+cUsuario+"' AND SA3.D_E_L_E_T_ = '' "
    

    IF Select("TCX") <> 0
        DbSelectArea("TCX")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery3 NEW ALIAS "TCX" 
    Count To qTotal
    TCX->(dbGoTop())
    If qTotal > 0
        cRet := TCX->A3_COD
    else
       FWAlertInfo("Atenção: Usuário "+AllTrim(cUsuario)+ " não está cadastrado em nenhum Vendedor !", "Atenção!")
    Endif


     // verificar se o representante é supervisor de algum representante.
    cQuery3 := " SELECT TOP 1  A3_SUPER,A3_COD,A3_NOME "
    cQuery3 += " FROM "+RetSqlName("SA3")+" SA3 "
    cQuery3 += " WHERE A3_SUPER = '"+cRet+"' AND SA3.D_E_L_E_T_ = '' "
    

    IF Select("TCX") <> 0
        DbSelectArea("TCX")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery3 NEW ALIAS "TCX" 
    Count To qTotal
    TCX->(dbGoTop())
    If qTotal == 0
        FWAlertInfo("Atenção: O Representante "+AllTrim(cRet)+ " não é supervisor de nenhum representante !", "Atenção!")
    Endif


return(cRet)

Static Function Mrep()

   Local oDlg, oLbx
   Local aCpos  := {}
   Local aRet   := {}
   Local cQuery := ""
   Local cAlias := GetNextAlias()
   Local lRet   := .F.

   If  !Empty(cCodSup)       
        
        cQuery := " SELECT A3_COD,A3_NOME,TRIM(A3_MUN)+'-'+A3_EST AS A3_MUN FROM SA3010 WHERE (A3_SUPER = '"+cCodSup+"' OR A3_XSUPER  = '"+cCodSup+"') AND D_E_L_E_T_ = '' " 
        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

        While (cAlias)->(!Eof())
            aAdd(aCpos,{(cAlias)->(A3_COD), (cAlias)->(A3_NOME), (cAlias)->(A3_MUN)})
            (cAlias)->(dbSkip())
        End
        (cAlias)->(dbCloseArea())

    EndIf        

   If Len(aCpos) < 1
      aAdd(aCpos,{" "," "," "})
   EndIf

   DEFINE MSDIALOG oDlg TITLE "Meus Representantes" FROM 0,0 TO 240,500 PIXEL

     @ 10,10 LISTBOX oLbx FIELDS HEADER 'Codigo' /*"Roteiro"*/, 'Nome' /*"Produto"*/, 'Cidade' SIZE 230,95 OF oDlg PIXEL

     oLbx:SetArray( aCpos )
     oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
     oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3]}}}
    
     @ 107,010 SAY OemToAnsi("Codigo Supervisor : "+cCodSup+" Usuário Totvs :"+cUsuario)  SIZE 300,09 COLOR CLR_BLACK  PIXEL OF oDlg

  DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End())  ENABLE OF oDlg
  ACTIVATE MSDIALOG oDlg CENTER

Return 

Static Function Bipado (cPedido)
Local cRet := "Não"
Local cQuery
Local xTotal

 // produto foi bipado
    cQuery := " SELECT C6_NUM "
    cQuery += " FROM "+RetSqlName("SC6")+" SC6 "
    cQuery += " INNER JOIN "+RetSqlName("ZZK")+" ZZK ON ZZK.D_E_L_E_T_ = '' AND ZZK_PEDIDO = C6_NUM AND ZZK_FILIAL = C6_FILIAL "
    cQuery += " AND ZZK_PRODUT = C6_PRODUTO "
    cQuery += " WHERE C6_NUM = '"+cPedido+"' AND SC6.D_E_L_E_T_ = '' AND C6_FILIAL = '"+xFilial("SC6")+"' "
    //cQuery += " AND C6_PRODUTO = '"+aBrowser[nAtual,03]+"' "
    cQuery += " GROUP BY C6_NUM "


    IF Select("TCP") <> 0
        DbSelectArea("TCP")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery NEW ALIAS "TCP" 
    Count To xTotal
    If xTotal > 0
        cRet := "Sim"
    Endif


return(cRet)

Static Function VPedido()
Local lLegenda := .T. //.T. se tiver bolinha de legenda e .F. se não tiver, para poder subtrair da linha abaixo
Local nColuna  := oGetGrid:ColPos() - Iif(lLegenda, 1, 0)
Local cTitulo
Local xConteu

/*Local aArea := GetArea()
Private Inclui    := .F.
Private Altera    := .F.
Private nOpca     := 2   
Private cCadastro := "Pedido de Vendas"  
Private aRotina := {}*/
 
    //Se for uma coluna válida (não for legenda)
    If nColuna != 0
        cTitulo  := Alltrim(aColunas[nColuna]:cTitle)
        xConteu  := eVal(aColunas[nColuna]:bData)
 
        //Tratativa se for numérico ou caractere para exibir como caractere
        If aColunas[nColuna]:cType == "N"
            xConteu := cValToChar(xConteu)
        ElseIf aColunas[nColuna]:cType == "D"
            xConteu := dToC(xConteu)
        EndIf

        If cTitulo == "Pedido"
            Processa({|| VisualPV()},"Carregando Pedido...")
        elseif cTitulo == "Obs"
            Fobs(xConteu)  
        EndIf 
    EndIf

return()


Static Function VisualPV()
    Local lLegenda := .T. //.T. se tiver bolinha de legenda e .F. se não tiver, para poder subtrair da linha abaixo
    Local aArea := GetArea()
    Local nColuna  := oGetGrid:ColPos() - Iif(lLegenda, 1, 0)

    Private Inclui    := .F.
    Private Altera    := .F.
    Private nOpca     := 2   
    Private cCadastro := "Pedido de Vendas"  
    Private aRotina := {}
    
    If nColuna != 0
        DbSelectArea('SC5')
        SC5->( DbSetOrder( 1 ) )
        nRecno := SC5->(Recno())
        SC5->( DbSeek( xFilial('SC5') + (cAliasTmp)->C5_NUM ) )
        MATA410( Nil, Nil, Nil, Nil, "A410Visual" )
    EndIF    
        
    RestArea(aArea)
Return


Static Function IncluirPV()
    Local aArea := GetArea()
    Private Inclui    := .F.
    Private Altera    := .F.
    Private nOpca     := 0   
    Private cCadastro := "Pedido de Vendas"  
    Private aRotina := {}
    Private l410Auto := .F.
    
    DbSelectArea('SC5')
    SC5->( DbSetOrder( 1 ) )
    nRecno := SC5->(Recno())
    SC5->( DbSeek( xFilial('SC5') + (cAliasTmp)->C5_NUM ) )
      MATA410( Nil, Nil, Nil, Nil, "A410Inclui" )
        
    RestArea(aArea)
Return

Static Function AlterarPV()
    //Local aArea := GetArea()
    Local lLegenda := .T. //.T. se tiver bolinha de legenda e .F. se não tiver, para poder subtrair da linha abaixo
    Local nColuna  := oGetGrid:ColPos() - Iif(lLegenda, 1, 0)

    Private Inclui    := .F.
    Private Altera    := .F.
    Private nOpca     := 4   
    Private cCadastro := "Pedido de Vendas"  
    Private aRotina := {}
    Private l410Auto := .F.
    
    If nColuna != 0
        If !Empty((cAliasTmp)->C5_NUM)
            DbSelectArea('SC5')
            SC5->( DbSetOrder( 1 ) )
            nRecno := SC5->(Recno())
            SC5->( DbSeek( xFilial('SC5') + (cAliasTmp)->C5_NUM ) )
            MATA410( Nil, Nil, Nil, Nil, "A410Altera" )
        else
            FWAlertInfo("Atenção: Selecione um Pedido de Venda ! ", "Atenção!")    
        EndIf        
        //Pesquisar()
    EndIf

    //RestArea(aArea)
Return

Static Function CopiarPV()
    Local aArea := GetArea()
    Local lLegenda := .T. //.T. se tiver bolinha de legenda e .F. se não tiver, para poder subtrair da linha abaixo
    Local nColuna  := oGetGrid:ColPos() - Iif(lLegenda, 1, 0)

    Private Inclui    := .F.
    Private Altera    := .F.
    Private Copiar    := .T.
    Private nOpca     := 1   
    Private cCadastro := "Pedido de Vendas"  
    Private aRotina := {}
    Private l410Auto := .F.

    If nColuna != 0
    
        If !Empty((cAliasTmp)->C5_NUM)
            DbSelectArea('SC5')
            SC5->( DbSetOrder( 1 ) )
            nRecno := SC5->(Recno())
            SC5->( DbSeek( xFilial('SC5') + (cAliasTmp)->C5_NUM ) )
            //a410Copia("SC5",nRecno,4)
            a410PCopia('SC5',SC5->(RecNo()),4)
            //MATA410( Nil, Nil, Nil, Nil, "a410Copia" )
        else
            FWAlertInfo("Atenção: Selecione um Pedido de Venda ! ", "Atenção!")    
        EndIf        

        //Pesquisar()
    EndIf    

    RestArea(aArea)
Return

Static Function ExcluirPV()
    Local aArea := GetArea()
    Private Inclui    := .F.
    Private Altera    := .F.
    Private Excluir    := .T.
    Private nOpca     := 5   
    Private cCadastro := "Pedido de Vendas"  
    Private aRotina := {}
    Private l410Auto := .F.
    
    
    If !Empty((cAliasTmp)->C5_NUM)
        DbSelectArea('SC5')
        SC5->( DbSetOrder( 1 ) )
        nRecno := SC5->(Recno())
        SC5->( DbSeek( xFilial('SC5') + (cAliasTmp)->C5_NUM ) )
        MATA410( Nil, Nil, Nil, Nil, "A410Exclui" )
        //A410Deleta('SC5',SC5->(RecNo()),5)


    else
        FWAlertInfo("Atenção: Selecione um Pedido de Venda ! ", "Atenção!")    
    EndIf        
    RestArea(aArea)
    //Pesquisar()
Return


Static Function SepIni (cPedido)
Local cRet := ""
Local cQuery2
Local fTotal


    cQuery2 := " SELECT  TOP 1 ZZK_DATA "
    cQuery2 += " FROM "+RetSqlName("SC5")+" SC5 "
    cQuery2 += " INNER JOIN "+RetSqlName("ZZK")+" ZZK ON ZZK.D_E_L_E_T_ = '' AND ZZK_PEDIDO = C5_NUM AND ZZK_FILIAL = C5_FILIAL "
    cQuery2 += " WHERE C5_NUM = '"+cPedido+"' AND SC5.D_E_L_E_T_ = '' AND C5_FILIAL = '"+xFilial("SC5")+"' "
    cQuery2 += " ORDER BY ZZK_DATA "

    IF Select("TCA") <> 0
        DbSelectArea("TCA")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "TCA" 
    Count To fTotal
    TCA->(dbGoTop())
    If fTotal > 0
        cRet := TCA->ZZK_DATA
    Endif


return(cRet)

Static Function SepFim (cPedido)
Local cRet := ""
Local cQuery2
Local fTotal


    cQuery2 := " SELECT  TOP 1 ZZK_DATA "
    cQuery2 += " FROM "+RetSqlName("SC5")+" SC5 "
    cQuery2 += " INNER JOIN "+RetSqlName("ZZK")+" ZZK ON ZZK.D_E_L_E_T_ = '' AND ZZK_PEDIDO = C5_NUM AND ZZK_FILIAL = C5_FILIAL "
    cQuery2 += " WHERE C5_NUM = '"+cPedido+"' AND SC5.D_E_L_E_T_ = '' AND C5_FILIAL = '"+xFilial("SC5")+"' "
    cQuery2 += " ORDER BY ZZK_DATA DESC "

    IF Select("TCA") <> 0
        DbSelectArea("TCA")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery2 NEW ALIAS "TCA" 
    Count To fTotal
    TCA->(dbGoTop())
    If fTotal > 0
        cRet := TCA->ZZK_DATA
    Endif


return(cRet)

Static Function Fobs (cMemo)
Local oMemo
local aArea := GetArea()
Local lLegenda := .T. //.T. se tiver bolinha de legenda e .F. se não tiver, para poder subtrair da linha abaixo
Local nColuna  := oGetGrid:ColPos() - Iif(lLegenda, 1, 0)

  If nColuna != 0
    DEFINE MSDIALOG oDlgm TITLE "Observação Pedido "+(cAliasTmp)->C5_NUM FROM 0,0 TO 240,500 PIXEL
    @ 010, 010 GET oMemo Var cMemo MEMO SIZE 220,90 PIXEL OF oDlgm

    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (SaveObs (cMemo))  ENABLE OF oDlgm
    ACTIVATE MSDIALOG oDlgm CENTER
  EndIf  
  RestArea(aArea)

   oGetGrid:Refresh()  
return()

Static Function SaveObs (cObs)

    DbSelectArea('SC5')
    SC5->( DbSetOrder( 1 ) )
    nRecno := SC5->(Recno())
    SC5->( DbSeek( xFilial('SC5') + (cAliasTmp)->C5_NUM ) )

    RecLock("SC5", .F.)
        SC5->C5_X_OBSFA := cObs
    MsUnLock()   

    //Altera na temporária
    RecLock(cAliasTmp, .F.)
        (cAliasTmp)->C5_X_OBSFA := cObs
    (cAliasTmp)->(MsUnlock())
    
            
    oGetGrid:LineRefresh(oGetGrid:Nat)
    oDlgm:End()
    
    



return()

/*/{Protheus.doc} fCalPrzMed
Função criada para calculo do prazo médio de pagamento.
@type function
@version v2022.0527
@author Luís Gustavo Souza
@since 27/05/2022
@param _cCondPag, Character, Código da codição de pagamento digitada no pedido
@param _nQtdeParc, Numeric, Quantidade de parcelas da condição de pagamento
@param _Prazos, Array, Vetor com prazos em dias + % de cada parcela sobre total e cálculo do prazo médio
@param _nPrzMedio, Numeric, Valor do prazo médio de pagamento
@param _lRet, Logical, Retorna verdadeiro ou falso conforme a validação efetuada
/*/
Static Function fCalPrzMed( _cCondPag, _nQtdeParc, _aPrazos, _nPrzMedio, _lRet )
       Local _dDiaFat   := dDataBase //Considerar dia do Faturamento data de hoje para cálculo do prazo médio
       Local _aVenctos  := {}        //Vetor com prazos de pagamentos
       Local _nI        := 0
       Local _nTotalTp9 := 0         //Valor total dos valores das parcelas tipo 9
       Local _cAuxMens  := ""
       Local _cAuxCPO

       DbSelectArea("SE4")  // Condição de Pagamento
       SE4->( DbSetOrder(1) )
       If SE4->( DbSeek( xFilial("SE4") + _cCondPag ) )
          //Cleber(24/07/18) Solicitação Eliana, chamado 010813 -> pedidos com cond. pgto até 7 dias calcular comissão como se fosse à vista
          _cCondPag := fEhAvista( _cCondPag )
          If SE4->E4_TIPO <> "9"
             _aVenctos := Condicao( 100, _cCondPag, 0.00, _dDiaFat, 0.00 ) //Condicao( nValTot, cCond, nVIPI, dData, nVSol )
          Else
             For _nI := 1 To 4
                 _cAuxCPO := "M->C5_DATA" + Alltrim( Str( _nI ) )
                 If !Empty( &_cAuxCPO )
                    aAdd( _aVenctos, { &_cAuxCPO, 0 } )
                    _cAuxCPO  := "M->C5_PARC" + Alltrim( Str( _nI ) )
                    If &_cAuxCPO <= 0
                       _lRet := .f.
                       _cAuxMens := "Preencha Todos os Valores para os Vencimentos Apontados!"
                       If fValAtrib( "l410Auto" ) <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01"
                          FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', _cAuxMens, 0 )
                       Else
                          MessageBox( _cAuxMens, "Atenção", 48 )
                       Endif
                       Exit
                    Endif
                    _nTotalTp9        += &_cAuxCPO
                    _aVenctos[_nI][2] := &_cAuxCPO
                    _nQtdeParc++
                 Else
                    _cAuxCPO := "M->C5_PARC" + Alltrim( Str( _nI ) )
                    If &_cAuxCPO > 0
                       _lRet := .f.
                       _cAuxMens := "Preencha Todos os Vencimentos para os Valores Apontados!"
                       If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01"
                          FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', _cAuxMens, 0 )
                       Else
                          MessageBox( _cAuxMens, "Atenção", 48 )
                       Endif
                       Exit
                    Endif
                 Endif
             Next
             If _nQtdeParc == 0
                _nQtdeParc := 1
                _nTotalTp9 := 1
                M->C5_DATA1 := dDataBase
                aAdd( _aVenctos, { dDataBase, 1 } )
             Endif
          Endif
       Else
          _nTotalTp9 := 1
          _aVenctos  := {}
          aAdd( _aVenctos, { dDataBase, 1 } )
       Endif
       //Chamado 014805, problema com cond. pgto datas fixas vencto, comissionamento muda devido a não se saber dia do faturamento,
       //considerar data do ped programado como ref. para cálculo do prazo médio
       If _nTotalTp9 > 0 .and. SC5->( FieldPos( "C5_PEDPROG" ) ) > 0
          If !Empty( M->C5_PEDPROG )
             _dDiaFat := M->C5_PEDPROG //Considerar dia do Faturamento data do pedido programado para o caso de datas fixas de vencimento (Chamado 014805)
          Endif
       Endif

       For _nI := 1 to Len( _aVenctos )
           aAdd( _aPrazos, { _aVenctos[_nI][1] - _dDiaFat + 1, Iif( _nTotalTp9 > 0, _aVenctos[_nI][2] / _nTotalTp9, 1 / Len( _aVenctos ) ) } )
           _nPrzMedio += _aPrazos[_nI][1]
       Next
       If Len( _aVenctos ) > 0
          _nPrzMedio := _nPrzMedio / Len( _aVenctos )
       Endif
Return

Static Function AJUSTACAM()

cValor := PadR(cValor,30) 
oValor:Setfocus()

return()

/*/{Protheus.doc} fEhAvista
Função p/ Brasilux que verifica se cond. for menor que 7 dias então considera cond à vista (001)
@type function
@version  v.2022.05.27
@author Cleber Orati Domingues
@since 27/05/2022
@param _cCond, Character, Código da condição de pagamento que será verificado
@return Character, Retorna o código da condição de pagamento
/*/
Static Function fEhAvista( _cCond )
       Local _aArea := GetArea()
       Local _cRet  := _cCond

       DbSelectArea("SE4")  // Condição de Pagamento
       SE4->( DbSetOrder(1) )
       If SE4->( DbSeek( xFilial("SE4") + _cCond ) )
          //Cleber(24/07/18) Solicitação Eliana, chamado 010813 -> pedidos com cond. pgto até 7 dias calcular comissão como se fosse à vista
          If SE4->E4_TIPO = "1" .AND. Len( ( Alltrim( SE4->E4_COND ) ) ) == 1
             If Val( Alltrim( SE4->E4_COND ) ) <= 7
                _cRet := "001"
             Endif
          Endif
       Endif 
       RestArea( _aArea )
Return _cRet


Static Function FOrden()
Local cRet

 If MV_PAR01 ==  1
    cRet := "C5_NUM DESC"
 elseif MV_PAR01 == 2
    cRet := "C5_EMISSAO DESC"
 elseif MV_PAR01 == 3
    cRet := "C5_CLIENTE,C5_EMISSAO DESC"
 EndIF

return(cRet)


