#INCLUDE "rwmake.ch"
#Include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCADZZE     บ Autor ณ AP6 IDE           บ Data ณ  27/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Erros do Apontamento Automแtico de OP          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CADZZE

Private cPerg   := ""
Private cCadastro := "Cadastro de Erros do Apontamento Automatico de OP"

aCores :=   {{'ZZE_RESOLV == "1" ' , 'ENABLE'},;		// RESOLVIDO 
             {'ZZE_RESOLV == "2" ' , 'BR_VERMELHO' }}	// PENDENTE	             
             
Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","AxVisual",0,2} ,;
             {"Legenda","U_LegCadZZE()",0,6},;
             {"Corrigir OP","U_APONTAOP",0,7}}

/*
{"Incluir","AxInclui",0,3} ,;
{"Alterar","AxAltera",0,4} ,;
{"Excluir","AxDeleta",0,5},;
*/
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "ZZE"

dbSelectArea("ZZE")
dbSetOrder(1)
cPerg   := ""
dbSelectArea(cString)
//mBrowse( 6,1,22,75,cString)
//mBrowse( 6,1,22,75,cString,,,,,6,aCores)
MBrowse( 6,1,22,75,cString,,,,,6,aCores,,,,,,,,,60000,{|| o := GetMBrowse(), o:GoBottom(), o:GoTop(), o:Refresh() }) 
Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

Return


User Function LegCadZZE()
        aLegenda := {{"BR_VERDE","RESOLVIDO"},;
                     {"BR_VERMELHO", "PENDENTE"}} 

BrwLegenda("Situa็ใo do Atendimento no Sistema","Legenda",aLegenda)
Return