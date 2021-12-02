#include "rwmake.ch"
#include "ap5mail.ch"
#Include "PROTHEUS.CH"
#include "topconn.ch"
#include "font.ch"    

User Function CONTSOFT()
     Local _lOpen      := .F. //LGS#20200128 - Adequação para release 12.1.25
     Private aRotina   := {}
     Private cCadastro := "Controle Licença de Software"
     PRIVATE cRotina   := "CONTSOFT"        
     PRIVATE oObjBrow  := Nil
     PRIVATE cFiltBM   := ""                    // Alias da GetDados.
     PRIVATE _cFiltro  := ""
     Private aCores    := { { "Z10_STATUS=='1'", 'BR_VERDE'   },;  // Disponivel
                            { "Z10_STATUS=='2'", 'BR_VERMELHO'},;  // Sem licença
                            { "Z10_STATUS=='3'", 'BR_AMARELO '} }  // Numero de liceças baixo <2
     Private _cAliasSX3  := GetNextAlias() //LGS#20200128 - Adequação para release 12.1.25
     u_zcfga01( 'CONTSOFT' ) //LGS#2021202 - Gravação de log de utilização da rotina
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200128 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     
     If _lOpen
        AAdd(aRotina, {"Pesquisar"             , "AxPesqui    "  , 0, 1})
        AAdd(aRotina, {"Visualizar"            , "u_CSManut(2)"  , 0, 2})
        AAdd(aRotina, {"Incluir"               , "u_CSManut(3)"  , 0, 3})
        AAdd(aRotina, {"Alterar"               , "u_CSManut(4)"  , 0, 4})
        AAdd(aRotina, {"Excluir"               , "u_CSManut(5)"  , 0, 5})
        AAdd(aRotina, {"Conhecimento"          , "MsDocument  "  , 0, 4})
                                               
        dbSelectArea("Z10")
        dbsetorder(1)//dbOrderNickName("NOME")
        dbGoTop()

        mBrowse(1,2,3,4,"Z10",,,,,,aCores)
        
        dbSelectArea( _cAliasSX3 )
        dbCloseArea()
     Else
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
     Endif

Return Nil

//----------------------------------------------------------------------------------------------------------------//
// Modelo 3.
//----------------------------------------------------------------------------------------------------------------//

User Function CSManut(nOpc)

//Local i        := 0
Local cLinOK   := "AllwaysTrue"
Local cTudoOK  := "u_CSTudOK"
Local nOpcE    := nOpc
Local nOpcG    := nOpc
Local cFieldOK := "AllwaysTrue"
Local lVirtual := .T.
Local nLinhas  := 999
Local nFreeze  := 0
Local lRet     := .T.

Private aCols        := {}
Private aHeader      := {}
Private aCpoEnchoice := {}
Private aAltEnchoice := {}
Private aAlt         := {}      

// Cria variaveis de memoria dos campos da tabela Pai.
// 1o. parametro: Alias do arquivo --> é case-sensitive, ou seja precisa ser como está no Dic.Dados.
// 2o. parametro: .T.              --> cria variaveis em branco, preenchendo com o inicializador-padrao.
//                .F.              --> preenche com o conteudo dos campos.
RegToMemory("Z10", (nOpc==3))

// Cria variaveis de memoria dos campos da tabela Filho.
RegToMemory("Z11", (nOpc==3))

CriaHeader()

CriaCols(nOpc)

lRet := Modelo3(cCadastro, "Z10","Z11", aCpoEnchoice, cLinOK, cTudoOK, nOpcE, nOpcG, cFieldOK, lVirtual, nLinhas, aAltEnchoice, nFreeze)

If lRet
   If nOpc == 3
           If MsgYesNo("Confirma a gravação dos dados?", cCadastro)
              Processa({||GrvDados()}, cCadastro, "Gravando os dados, aguarde...")
           EndIf
    ElseIf nOpc == 4
           If MsgYesNo("Confirma a alteração dos dados?", cCadastro)
              Processa({||AltDados()}, cCadastro, "Alterando os dados, aguarde...")
           EndIf
    ElseIf nOpc == 5
           If MsgYesNo("Confirma a exclusão dos dados?", cCadastro)
              Processa({||ExcDados()}, cCadastro, "Excluindo os dados, aguarde...")
           EndIf

   EndIf
 Else
   RollBackSX8()
EndIf

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function CriaHeader()
       aHeader      := {}
       aCpoEnchoice := {}
       aAltEnchoice := {}

       // aHeader é igual ao do Modelo2.
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek("Z11")
       While !SX3->(EOF()) .And. SX3->X3_Arquivo == "Z11"
             // cNivel >= SX3->X3_Nivel .And.;                  // Nivel do Usuario é maior que o Nivel do Campo.
             If X3Uso(SX3->X3_Usado)    .And.;                  // O Campo é usado.
                !(Trim(SX3->X3_Campo) $ "Z11_CODIGO*Z11_FILIAL")
                /*
                /Z11_SERIAL/Z11_NOMEPC/Z11_IP/Z11_DTINST/Z11_CAIXA/Z11_QTDINS"  
                */*/ /*      
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
       ( _cAliasSX3 )->( dbSeek("Z11") )
       While !( _cAliasSX3 )->( EOF() ) .And. ( _cAliasSX3 )->( X3_Arquivo ) == "Z11"
             // cNivel >= SX3->X3_Nivel .And.;                  // Nivel do Usuario é maior que o Nivel do Campo.
             If X3Uso( ( _cAliasSX3 )->( X3_Usado ) ) .And. !( Trim( ( _cAliasSX3 )->( X3_Campo ) ) $ "Z11_CODIGO*Z11_FILIAL" )
                /*
                /Z11_SERIAL/Z11_NOMEPC/Z11_IP/Z11_DTINST/Z11_CAIXA/Z11_QTDINS"  
                */      
                AAdd(aHeader, { Trim( ( _cAliasSX3 )->( X3_Titulo ) ), ( _cAliasSX3 )->( X3_Campo ), ( _cAliasSX3 )->( X3_Picture ), ( _cAliasSX3 )->( X3_Tamanho ), ( _cAliasSX3 )->( X3_Decimal ), ( _cAliasSX3 )->( X3_Valid ), ( _cAliasSX3 )->( X3_Usado ), ( _cAliasSX3 )->( X3_Tipo ), ( _cAliasSX3 )->( X3_Arquivo ), ( _cAliasSX3 )->( X3_Context ) } )
             EndIf
             ( _cAliasSX3 )->( dbSkip() )
       End

       // Campos da Enchoice.
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek("Z10")
       While !SX3->(EOF()) .And. SX3->X3_Arquivo == "Z10"
             If X3Uso(SX3->X3_Usado)    .And.;                  // O Campo é usado.
                cNivel >= SX3->X3_Nivel                         // Nivel do Usuario é maior que o Nivel do Campo.
                // Campos da Enchoice.
                AAdd(aCpoEnchoice, X3_Campo)
                // Campos da Enchoice que podem ser editadas.
                // Se tiver algum campo que nao deve ser editado, nao incluir aqui.
                AAdd(aAltEnchoice, X3_Campo)
             EndIf
             SX3->(dbSkip())
       End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek("Z10") )
       While !( _cAliasSX3 )->( EOF() ) .And. ( _cAliasSX3 )->( X3_Arquivo ) == "Z10"
             If X3Uso( ( _cAliasSX3 )->( X3_Usado ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_Nivel )
                // Campos da Enchoice.
                AAdd( aCpoEnchoice, ( _cAliasSX3 )->( X3_Campo ) )
                // Campos da Enchoice que podem ser editadas.
                // Se tiver algum campo que nao deve ser editado, nao incluir aqui.
                AAdd( aAltEnchoice, ( _cAliasSX3 )->( X3_Campo ) )
             EndIf
             ( _cAliasSX3 )->( dbSkip() )
       End
       /********************************************************************************************************************************/
Return Nil

//----------------------------------------------------------------------------------------------------------------//
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

   dbSelectArea("Z11")
   dbSETORDER(1)//OrderNickName("NOME_NR_IT")  // Z2_Filial + Z2_Nome + Z2_Numero + Z2_Item
   dbSeek(xFilial("Z11") + ("Z10")->Z10_CODIGO)

   While !EOF() .And. (Z11->Z11_Filial == xFilial("Z11")) .And. (Z11->Z11_CODIGO== Z10->Z10_CODIGO)

      AAdd(aCols, Array(nQtdCpo+1))
      nCols++

      For i := 1 To nQtdCpo
          If aHeader[i][10] <> "V"
             aCols[nCols][i] := &("Z11" +"->" + aHeader[i][2]) //FieldGet(FieldPos(aHeader[i][2]))
           Else
             aCols[nCols][i] := CriaVar(aHeader[i][2], .T.)
          EndIf
      Next

      aCols[nCols][nQtdCpo+1] := .F.

      AAdd(aAlt, Recno())

      dbSelectArea("Z11")
      dbSkip()

   End

EndIf
 
Return Nil
//----------------------------------------------------------------------------------------------------------------//
Static Function GrvDados()

Local bCampo := {|nField| Field(nField)}
Local i      := 0
Local y      := 0
//Local nItem  := 0
//Local cCount := 0
ProcRegua(Len(aCols) + FCount())

// Grava o registro da tabela Pai, obtendo o valor de cada campo
// a partir da var. de memoria correspondente.

dbSelectArea("Z10")
RecLock("Z10", .T.)
For i := 1 To FCount()
    IncProc()
    If "FILIAL" $ FieldName(i)
       FieldPut(i, xFilial("Z10"))
     
    ELSEIF "Z10_CODIGO" $ FieldName(i)
    	Z10->Z10_CODIGO:= U_NUMSEQLOTE("Z10",6)
     Else
       FieldPut(i, M->&(Eval(bCampo,i)))
    EndIf 
Next
/* 
For x := 1 To Len(aCols)                 
	If !aCols[i][Len(aHeader)+1]
		cCount += aCols[x][6]
	EndIf
Next
*/


if (Z10->Z10_TOLIC >0 .AND. Z10->Z10_TOLIC <= 3)
	Z10->Z10_STATUS:= "3"
elseif Z10->Z10_TOLIC > 3 
	Z10->Z10_STATUS:= "1"
else
	Z10->Z10_STATUS:= "2"  
endif	
MSUnlock()

// Grava os registros da tabela Filho.

dbSelectArea("Z11")
dbSETORDER(1)//OrderNickName("NR_IT")

For i := 1 To Len(aCols)

    IncProc()

    If !aCols[i][Len(aHeader)+1]       // A linha nao esta deletada, logo, pode gravar.

       RecLock("Z11", .T.)

       
       For y := 1 To Len(aHeader)
           FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
       Next
       Z11->Z11_Filial := xFilial("Z11")
       Z11->Z11_CODIGO   := Z10->Z10_CODIGO
    
       MSUnlock()
    EndIf

Next 

Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function AltDados()

Local i      := 0
Local y      := 0
//Local nItem  := 0
Local cCount := 0
Local x
ProcRegua(Len(aCols) + FCount())

dbSelectArea("Z10")
RecLock("Z10", .F.)

For i := 1 To FCount()
    IncProc()
    If "FILIAL" $ FieldName(i)
       FieldPut(i, xFilial("Z10"))
     Else
       FieldPut(i, M->&(fieldname(i)))
    EndIf
Next
 	               
For x := 1 To Len(aCols)                 
		cCount +=  aCols[x][6]
Next
	Z10->Z10_TOLIC := (Z10->Z10_QTDLIC - cCount)  
	Z10->Z10_TOMAQ := (Z10->Z10_QTDINS - Len(aCols)) 
	 
if (Z10->Z10_TOLIC >0 .AND. Z10->Z10_TOLIC <= 3)
	Z10->Z10_STATUS:= "3"
elseif Z10->Z10_TOLIC > 3 
	Z10->Z10_STATUS:= "1"
else
	Z10->Z10_STATUS:= "2"
endif
MSUnlock()

dbSelectArea("Z11")
DBSETORDER(1)//dbOrderNickName("NR_IT")

For i := 1 To Len(aCols)

    If i <= Len(aAlt)
       dbGoTo(aAlt[i])
       RecLock("Z11", .F.)
       If aCols[i][Len(aHeader)+1]
          dbDelete()
       Else
          For y := 1 To Len(aHeader)
              FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
          Next
       EndIf
       MSUnlock()
     Else
       If !aCols[i][Len(aHeader)+1]
          RecLock("Z11", .T.)
          For y := 1 To Len(aHeader)
              FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
          Next
          Z11->Z11_Filial := xFilial("Z11")
          Z11->Z11_CODIGO := ("Z10")->Z10_CODIGO
          MSUnlock()
          
       EndIf

    EndIf           
Next
Return Nil

//----------------------------------------------------------------------------------------------------------------//
Static Function ExcDados()

ProcRegua(Len(aCols)+1)   // +1 é por causa da exclusao do arq. de cabeçalho.

dbSelectArea("Z11")
DBSetOrder(1)
dbSeek(xFilial("Z11") + ("Z10")->Z10_CODIGO)

While !EOF() .And. ("Z11")->Z11_Filial == xFilial("Z11") .And. ("Z11")->Z11_CODIGO == ("Z10")->Z10_CODIGO
   IncProc()
   RecLock("Z11", .F.)
   dbDelete()
   MSUnlock()
   dbSkip()
End

dbSelectArea("Z10")
DBSetOrder(1)

RecLock("Z10", .F.)
dbDelete()
MSUnlock()

Return Nil

//----------------------------------------------------------------------------------------------------------------//
User Function CSTudOK()

Local lRet := .T.
Local i    := 0
Local nDel := 0

For i := 1 To Len(aCols)
    If aCols[i][Len(aHeader)+1]
       nDel++
    EndIf
Next

If nDel == Len(aCols)
   MsgInfo("Para excluir todos os itens, utilize a opção EXCLUIR", cCadastro)
   lRet := .F.
EndIf


Return lRet

User Function CSLeng()

Local	aLegenda  := {	{'BR_VERDE'		,'Disponivel'},;
						{'BR_VERMELHO'	,'Sem Licença'},;
						{'BR_AMARELO'	,''}}

BrwLegenda(cCadastro,'Legenda',aLegenda)                                   

Return .T.
/*
Static FUNCTION HD3SREL                                                                       	
LOCAL aEntidade := {}

AADD( aEntidade, { "Z10", { "Z10_CODIGO" }, { || Z10->Z10_CODIGO } } )

Return aEntidade*/
