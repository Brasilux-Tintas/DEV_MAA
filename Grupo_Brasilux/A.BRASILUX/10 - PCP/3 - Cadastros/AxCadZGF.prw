#include "rwmake.ch" 
#include "topconn.ch   
#include "protheus.ch"                                                                                     
                                                                                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AXCADZGF  ºAutor  ³Andréº					 Data ³03/02/21º   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±                
±±ºDesc.     ³ 	CADASTRO DE METRICAS DE GGF POR PRODUTO/LINHA			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function AXCADZGF()                                    

Private cVldAlt   := ".T."  // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cRotina   := "AXCADZGF"
Private cCadastro := "Cadastro de métricas de GGF por Linha/Produto"
Private cString   := "ZGF"

Private aRotina   := { {"Pesquisar" 		,"AxPesqui"     , 0, 1},;
                       {"Visualizar"		,"AxVisual"     , 0, 2},;
                       {"Incluir"   		,"AxInclui"     , 0, 3},;
                       {"Alterar"   		,"AxAltera"     , 0, 4},;
                       {"Excluir"   		,"AxDeleta"     , 0, 5} }
                       


//AxCadastro("SA1", "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )
/*
If !u_VldAcesso(funname())
   	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
   	Return 
Endif 
*/

AxCadastro(cString, cCadastro, cVldExc, cVldAlt, aRotina )
DbSelectArea("ZGF")
DbSetOrder(1)


Return
