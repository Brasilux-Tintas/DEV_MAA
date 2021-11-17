#include "rwmake.ch" 
#include "topconn.ch   
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AXCADZZT  ºAutor  ³Andréº					 Data ³05/04/16º   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 															  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AXCADZZT()                                    

Private cVldAlt   := ".T."          // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
//Private cDelFunc  := "u_PCPA06_D()" // Validacao para a exclusao. Pode-se utilizar ExecBlock                           
Private cRotina   := "AXCADZZT"
Private cCadastro := "Cadastro de Endereços para Distribuição de Pedidos"
Private cString := "ZZT"

Private aRotina := { {"Pesquisar" 		,"AxPesqui"  , 0, 1},;
                     {"Visualizar"		,"AxVisual"  , 0, 2},;
                     {"Incluir"   		,"AxInclui"  , 0, 3},;
                     {"Alterar"   		,"AxAltera"  , 0, 4},;
                     {"Excluir"   		,"AxDeleta"  , 0, 5} }


If !u_VldAcesso(funname())
   	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
   	Return 
Endif 

DbSelectArea("ZZT")
DbSetOrder(1)

DbSelectArea(cString)
mBrowse( 6, 1, 22, 75, cString)

Return
