#include "rwmake.ch"
#Include "PROTHEUS.CH"
#include "topconn.ch"
#include "font.ch"

User Function CADFTGUA()
Private aRotina := {}
Private cCadastro := "Ficha de Transporte"
PRIVATE oObjBrow  := Nil
PRIVATE cRotina   := "CADFTGUA"
Private cAlias1 := "Z12"                    // Alias da Enchoice.
Private cAlias2 := "Z13" 
PRIVATE cFiltBM   := ""                    // Alias da GetDados.
PRIVATE _cFiltro  := ""
Private aCores	:=	{{ "Z12_ETAPA=='1'"	, 'ENABLE     '	},;  // Entrada
					{  "Z12_ETAPA=='2'" , 'BR_VERMELHO'	}}  // Saida

TcRefresh(RetSqlName("Z12"))
TcRefresh(RetSqlName("Z13"))

AAdd(aRotina, {"Pesquisar"             , "AxPesqui  "    , 0, 1})
AAdd(aRotina, {"Visualizar"            , "u_FTManut(2)"  , 0, 2})
AAdd(aRotina, {"Entrada"               , "u_FTManut(3)"  , 0, 3})
AAdd(aRotina, {"Saida"                 , "u_FTManut(4)"  , 0, 4})
AAdd(aRotina, {"Alterar"               , "u_FTManut(5)"  , 0, 4})

dbSelectArea(cAlias1)
dbsetorder(1)
dbGoTop()
	_cFiltro   := cFiltBM
	oObjBrow := FWMBrowse():New()
	oObjBrow:SetAlias("Z12")
	oObjBrow:SetMenuDef(cRotina)
	oObjBrow:SetWalkThru(.F.)
	oObjBrow:SetUseFilter(.T.)   
	if type("oObjBrow:lDetails") != "U"
		oObjBrow:lDetails := .F.
	endif
	oObjBrow:SetExecuteDef(2)
	oObjBrow:AddLegend( 'Z12->Z12_ETAPA == "1"' , 'ENABLE'       , "Entrada  ")
	oObjBrow:AddLegend( 'Z12->Z12_ETAPA == "2"' , 'BR_VERMELHO'  , "Saida    ")
	oObjBrow:Activate()
	EndFilBrw("Z12")
Return Nil

User Function FTManut(nOpc)
//Local i        := 0
Local cLinOK   := "AllwaysTrue"
Local cTudoOK  := "u_FTTudOK"
Local nOpcE    := nOpc
Local nOpcG    := nOpc
Local cFieldOK := "AllwaysTrue"
Local lVirtual := .T.
Local nLinhas  := 99
Local nFreeze  := 0
Local lRet     := .T.

Private aCols        := {}
Private aHeader      := {}
Private aCpoEnchoice := {}
Private aAltEnchoice := {}
Private aAlt         := {}

dbSelectArea(cAlias1) 
// Cria variaveis de memoria dos campos da tabela Filho.
RegToMemory(cAlias1, (nOpc==3))
RegToMemory(cAlias2, (nOpc==3))

CriaHeader(nOpc)

CriaCols(nOpc)

lRet := Modelo3(cCadastro, cAlias1, cAlias2, aCpoEnchoice, cLinOK, cTudoOK, nOpcE, nOpcG, cFieldOK, lVirtual, nLinhas, aAltEnchoice	, nFreeze,,{0,0,600,700},200)

If lRet
    If nOpc == 3
           If MsgYesNo("Confirma a entrada do transporte?", cCadastro)
              Processa({||GrvDados()}, cCadastro, "Gravando os dados, aguarde...")
           EndIf
    ElseIf nOpc == 4 
         If MsgYesNo("Confirma a saida do transporte?", cCadastro)
              Processa({||AltDados(nOpc)}, cCadastro, "Alterando os dados, aguarde...")
         EndIf
    ElseIf nOpc == 5
         If MsgYesNo("Confirma a alteração de dados?", cCadastro)
              Processa({||AltDados(nOpc)}, cCadastro, "Alterando os dados, aguarde...")
 	     EndIf
   EndIf
 Else
   RollBackSX8()
EndIf

Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function CriaHeader(nOpc)
       Local _lOpen        := .F. //LGS#20200211 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25

       aHeader      := {}
       aCpoEnchoice := {}
       aAltEnchoice := {}
       PRIVATE aItems,oList,nList

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200211 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       // aHeader é igual ao do Modelo2.
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek(cAlias2)
       While !SX3->(EOF()) .And. SX3->X3_Arquivo == cAlias2
             If X3Uso(SX3->X3_Usado)    .And.;                  // O Campo é usado.
                cNivel >= SX3->X3_Nivel .And. ;
                Trim(SX3->X3_Campo) $"Z13_SERIE/Z13_NF"
                AAdd(aHeader, {Trim(SX3->X3_Titulo),;
                               SX3->X3_Campo       ,;
                               SX3->X3_Picture     ,;
                               SX3->X3_Tamanho     ,;
                               SX3->X3_Decimal     ,;
                               SX3->X3_Valid       ,;
                               SX3->X3_Usado       ,;
                               SX3->X3_Tipo        ,;
                               SX3->X3_Arquivo     ,;
                               SX3->X3_Context})
             EndIf
             SX3->(dbSkip())
       End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek(cAlias2) )
       While !( _cAliasSX3 )->( EOF() ) .And. ( _cAliasSX3 )->( X3_Arquivo ) == cAlias2
             If X3Uso( ( _cAliasSX3 )->( X3_Usado ) )    .And.;                  // O Campo é usado.
                cNivel >= ( _cAliasSX3 )->( X3_Nivel ) .And. ;
                Trim( ( _cAliasSX3 )->( X3_Campo ) ) $"Z13_SERIE/Z13_NF"
                AAdd( aHeader, { Trim( ( _cAliasSX3 )->( X3_Titulo ) ),;
                                 ( _cAliasSX3 )->( X3_Campo )    ,;
                                 ( _cAliasSX3 )->( X3_Picture )  ,;
                                 ( _cAliasSX3 )->( X3_Tamanho )  ,;
                                 ( _cAliasSX3 )->( X3_Decimal )  ,;
                                 ( _cAliasSX3 )->( X3_Valid )    ,;
                                 ( _cAliasSX3 )->( X3_Usado )    ,;
                                 ( _cAliasSX3 )->( X3_Tipo )     ,;
                                 ( _cAliasSX3 )->( X3_Arquivo )  ,;
                                 ( _cAliasSX3 )->( X3_Context ) } )
             EndIf
             ( _cAliasSX3 )->( dbSkip() )
       End
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek(cAlias1)

       While !SX3->(EOF()) .And. SX3->X3_Arquivo == cAlias1
             If X3Uso(SX3->X3_Usado)        // O Campo é usado.
                cNivel >= SX3->X3_Nivel                         // Nivel do Usuario é maior que o Nivel do Campo.
                // Campos da Enchoice.      
                AAdd(aCpoEnchoice, X3_CAMPO)
                AAdd(aAltEnchoice, X3_CAMPO)
             endif 
             SX3->(dbSkip())
       End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek(cAlias1) )
       While !( _cAliasSX3 )->( EOF() ) .And. ( _cAliasSX3 )->( X3_Arquivo ) == cAlias1
             If X3Uso( ( _cAliasSX3 )->( X3_Usado ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_Nivel )
                // Campos da Enchoice.
                AAdd( aCpoEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) )
                AAdd( aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) )
             endif 
             ( _cAliasSX3 )->( dbSkip() )
       End       
       dbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function CriaCols(nOpc)

Local nQtdCpo := 0
Local i       := 0
Local nCols   := 0

nQtdCpo := Len(aHeader)
aCols   := {}
aAlt    := {}

If nOpc == 3       // Inclusao.

   AAdd(aCols, Array(nQtdCpo+1))

   For i := 1 To nQtdCpo
       aCols[1][i] := CriaVar(aHeader[i][2])
   Next

   aCols[1][nQtdCpo+1] := .F.

 Else

   dbSelectArea(cAlias2)
   dbSETORDER(1)
   dbSeek(xFilial(cAlias2) + (cAlias1)->Z12_CODIGO)

   While !EOF() .And. (cAlias2)->Z13_Filial == xFilial(cAlias2) .And. (cAlias2)->Z13_CODIGO== (cAlias1)->Z12_CODIGO

      AAdd(aCols, Array(nQtdCpo+1))
      nCols++

      For i := 1 To nQtdCpo
          If aHeader[i][10] <> "V"
             aCols[nCols][i] := &(cAlias2 +"->" + aHeader[i][2]) //FieldGet(FieldPos(aHeader[i][2]))
           Else
             aCols[nCols][i] := CriaVar(aHeader[i][2], .T.)
          EndIf
      Next

      aCols[nCols][nQtdCpo+1] := .F.

      AAdd(aAlt, Recno())

      dbSelectArea(cAlias2)
      dbSkip()
   End
EndIf
 
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function GrvDados()

Local bCampo := {|nField| Field(nField)}
Local i      := 0
Local y      := 0
Local nItem  := 0
ProcRegua(Len(aCols) + FCount())
// Grava o registro da tabela Pai, obtendo o valor de cada campo
// a partir da var. de memoria correspondente.
dbSelectArea(cAlias1)
RecLock(cAlias1, .T.)

For i := 1 To FCount()
    IncProc()
    If "FILIAL" $ FieldName(i)
       FieldPut(i, xFilial(cAlias1))
    ELSEIF "Z12_CODIGO" $ FieldName(i)
    	Z12->Z12_CODIGO:= U_NUMSEQLOTE("Z12",6)
    else
    	if("Z12_ETAPA" $ FieldName(i)) .and. empty(M->Z12_HRSAID) 
    		Z12_ETAPA := "1"
    	elseif("Z12_ETAPA" $ FieldName(i)) .and. !empty(M->Z12_HRSAID)
    		Z12_ETAPA := "2"
    	else
    		FieldPut(i, M->&(Eval(bCampo,i)))
		endif
	endif
Next

MSUnlock()
// Grava os registros da tabela Filho.

dbSelectArea(cAlias2)
DBSETORDER(1)

nItem := Len(aAlt) + 1

For i := 1 To Len(aCols) 

    If i <= Len(aAlt)

       dbGoTo(aAlt[i])            
       
       If aCols[i][Len(aHeader)+1]
          dbDelete()
       Else
      	  For y := 1 To Len(aHeader)
          Next               
       EndIf
     Else
       If !aCols[i][Len(aHeader)+1]
          RecLock(cAlias2, .T.)
       
          For y := 1 To Len(aHeader)
        
              FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
        	 	
		    Next
          (cAlias2)->Z13_Filial := xFilial(cAlias2)
          (cAlias2)->Z13_CODIGO := (cAlias1)->Z12_CODIGO
          
          MSUnlock()
          nItem++
       EndIf
    EndIf
Next


Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------//     
User Function FTTudOK()
Local lRet := .T.
Local i    := 0
Local nDel := 0

For i := 1 To Len(aCols)
    If aCols[i][Len(aHeader)+1]
       nDel++
    EndIf
Next

Return lRet

//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------//

/*Static Function Legend()
Local cCadastro := OemToAnsi('Status de Pedido')
     BrwLegenda(cCadastro,"Status",{{"BR_VERDE", "Entrada  "},;                                                                                                 
       				 		       {"BR_VERMELHO","Saida   "}})
Return(.t.)*/        
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function AltDados(nOpc)
Local i      := 0
Local  y      := 0
Private nItem  := 0
Private getAdm := 0
Private getMensagem 
Private ConvData
PRivate flag := 0

ProcRegua(Len(aCols) + FCount())

dbSelectArea(cAlias1)
RecLock(cAlias1, .F.) 
if nOpc == 4 
	For i := 1 To FCount()
	    IncProc()
	    If "FILIAL" $ FieldName(i)
	       FieldPut(i, xFilial(cAlias1))
	    elseif("Z12_ETAPA" $ FieldName(i)) .and. empty(M->Z12_HRSAID)
	       Z12_ETAPA := "1"
	    elseif("Z12_ETAPA" $ FieldName(i)) .and. !empty(M->Z12_HRSAID)
	       Z12_ETAPA := "2"
	 	Else
	       FieldPut(i, M->&(fieldname(i)))
	    EndIf
	 Next 
elseif nOpc == 5
	For i := 1 To FCount()
	    IncProc()    
	    If "FILIAL" $ FieldName(i)
	       FieldPut(i, xFilial(cAlias1))
	    elseif("Z12_ETAPA" $ FieldName(i)) .and. empty(M->Z12_HRSAID)
	       Z12_ETAPA := "1"
	    elseif("Z12_ETAPA" $ FieldName(i)) .and. !empty(M->Z12_HRSAID)
	       Z12_ETAPA := "2"
	 	Else
	       FieldPut(i, M->&(fieldname(i)))
	    EndIf
	 Next 
endif     

 MSUnlock() 
 
 dbSelectArea(cAlias2)
DBSETORDER(1)

nItem := Len(aAlt) + 1

For i := 1 To Len(aCols) 

    If i <= Len(aAlt)

       dbGoTo(aAlt[i])            
       
       If aCols[i][Len(aHeader)+1]
          dbDelete()
       Else
      	  For y := 1 To Len(aHeader)
          Next               
       EndIf
     Else
       If !aCols[i][Len(aHeader)+1]
          RecLock(cAlias2, .T.)
       
          For y := 1 To Len(aHeader)
        
              FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
        	 	
		    Next
          (cAlias2)->Z13_Filial := xFilial(cAlias2)
          (cAlias2)->Z13_CODIGO := (cAlias1)->Z12_CODIGO
          
          MSUnlock()
          nItem++
       EndIf
    EndIf
Next
Return