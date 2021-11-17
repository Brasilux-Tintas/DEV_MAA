#include "rwmake.ch"
#include "ap5mail.ch"
#Include "PROTHEUS.CH"
#include "topconn.ch"
#include "font.ch"    

user function amostra()  
PRIVATE aRotina   := {}
PRIVATE cCadastro := "Transacoes"
PRIVATE cFiltro   := "Z04_ETAPA"                                           
PRIVATE cRotina   := "Amostra"
PRIVATE cFiltBM   := ""
PRIVATE oObjBrow  := Nil
PRIVATE _cFiltro  := ""

private aCores    :={{"Z04_ETAPA == '1'", "BR_MARROM"},;
	  {"Z04_ETAPA == '2'", "BR_VERDE"},;                        	
      {"Z04_ETAPA == '3'", "BR_AMARELO"},;
      {"Z04_ETAPA == '4'", "BR_AZUL"},;       
      {"Z04_ETAPA == '5'", "BR_LARANJA"},;
      {"Z04_ETAPA == '6'", "BR_VERMELHO"}}

dbSelectArea("Z04")
dbSetOrder(2)   
 
dbGoTop()
	
AAdd(aRotina,{"Visualizar" 	 , "u_Alter(2)"   , 0, 4})            
AAdd(aRotina,{"Incluir"  	 , "u_incAmost"	  , 0, 2})
AAdd(aRotina,{"Responder"    , "u_Alter(1)"   , 0, 3})
AAdd(aRotina,{"Voltar"       , "u_Voltar"     , 0, 1})
AAdd(aRotina,{"Legenda"  	 , "u_Legend"     , 0, 5})
AAdd(aRotina,{"Excluir"  	 , "u_AmostExc"   , 0, 6})
AAdd(aRotina,{"Imprimir"  	 , "u_AmostImp"   , 0, 8})
AAdd(aRotina,{"Etapa 1	"    , "u_AmostEtp(1)", 0, 9})
AAdd(aRotina,{"Etapa 2	"    , "u_AmostEtp(2)", 0, 9})
AAdd(aRotina,{"Etapa 3	"    , "u_AmostEtp(3)", 0,10})
AAdd(aRotina,{"Etapa 4	"    , "u_AmostEtp(4)", 0,11})
AAdd(aRotina,{"Etapa 5	"    , "u_AmostEtp(5)", 0,12})
AAdd(aRotina,{"Cancelado"    , "u_AmostEtp(8)", 0,13})
AAdd(aRotina,{"Finalizados  ", "u_AmostEtp(7)", 0,14})
AAdd(aRotina,{"Todas Etapas	", "u_AmostAll"   , 0,15})

dbSelectArea("Z04")
dbSetOrder(2)
dbGoTop()
	
_cFiltro   := cFiltBM                                  
if empty(_cFiltro)
	// _cFiltro := ".T."
endif 


//mBrowse( 6,1,22,75,"SZM", , , , , , aCores) //, , , , , , , ,_cFilSql
oObjBrow := FWMBrowse():New()
oObjBrow:SetAlias("Z04")		// Indica o Alias da tabela utilizada no Browse
oObjBrow:SetMenuDef(cRotina)
oObjBrow:SetWalkThru(.F.)
oObjBrow:SetUseFilter(.T.)

if type("oObjBrow:lDetails") != "U"
	oObjBrow:lDetails := .F.       
endif 

oObjBrow:SetExecuteDef(2)		// Elemento do aRotina executado no duplo clique 
oObjBrow:AddLegend( 'Z04->Z04_ETAPA == "1"' , 'BR_MARROM'  , "Dep. Comercial" )
oObjBrow:AddLegend( 'Z04->Z04_ETAPA == "2"' , 'ENABLE'     , "Pendente Aprovação" )
oObjBrow:AddLegend( 'Z04->Z04_ETAPA == "3"' , 'BR_AMARELO' , "Dep. Técnico" )
oObjBrow:AddLegend( 'Z04->Z04_ETAPA == "4"' , 'BR_AZUL'    , "Dep. Comercial" )
oObjBrow:AddLegend( 'Z04->Z04_ETAPA == "5"' , 'BR_LARANJA' , "Amostra Finalizada" )
oObjBrow:AddLegend( 'Z04->Z04_ETAPA == "6"' , 'BR_VERMELHO', "Amostra Cancelado" )

oObjBrow:Activate()                     
	  	
EndFilBrw("Z04")
                          
////////////////////////////////////////////////////////////////////////////////////////
/////////////////Folder Incluir- 25/03/2015 - Marcelo Paiva/////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
User Function incAmost()      
private data1,oData1
private cRepres,oRepres
private cECliente,oEcliente
private cCliente,oCliente
private cCidade,oCidade
private cConcorrente,oConcorrente
private nPrecoPg,oPrecoPg
private nPotencial,oPotencial
private cJustificativa,oJustificativa
private cCaracteristica,oCaracteristica
private cLinha,oLinha
private cCor,oCor
private cEmbalagem,oEmbalagem
private nQuantidade,oQuantidade
private cDescricao,oDescricao   
private cTipoCa,oTipoCa
private cProd1,oProd1


dbselectarea("Z04")
dbSetOrder(2)

data1 := date()
cRepres  := "      "
cCliente := "      "
cCidade  := "      "
cConcorrente:= "                                                  "
nPrecoPg:= 0
nPotencial:= 0
cCaracteristica:= "  "
cLinha:= "  "
cCor:= "  "
cEmbalagem:= "  "
nQuantidade := 0
cDescricao:= "                                                  "
etapa:= ""
cProd1 :="               "
define dialog oDlg title "Cadastro Amostra" from 100,100 to 650,800 pixel

aTFolder1 := { "Cadastro de Amostra"}
oTFolder1 := tfolder():new( 0,25,aTFolder1,,oDlg,,,,.t.,,300,240 )    
	
oCadastro:= tsay():new(2,2,{||"Cadastro"}, oTFolder1:aDialogs[1],,,,,,.t.,CLR_RED,CLR_WHITE,96,9) 

@ 017, 003 SAY "Tipo Cad: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS  0,0 PIXEL 
@ 015, 030 MSCOMBOBOX oTipoCa VAR cTipoCa ITEMS{"1=Desenvolvimento","2=Existente"} SIZE 040, 040 OF oTFolder1:aDialogs[1] COLORS 0, 10 PIXEL
@ 017, 070 SAY "Data: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS  0, 0 PIXEL
@ 015, 085 MSGET oData1 VAR data1  OF oTFolder1:aDialogs[1] SIZE 50,05 PIXEL WHEN .F. 
@ 017, 135 SAY "Representante: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0  PIXEL
@ 015, 175 MSGET oRepres VAR cRepres  OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SA3" PIXEL
@ 017, 228 SAY "É cliente?" SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0,0 PIXEL    
@ 015, 255 MSCOMBOBOX oECliente VAR cECliente ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[1] COLORS 0, 10 PIXEL
@ 031, 003 SAY "Cliente: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL
@ 029, 030 MSGET oCliente VAR cCliente OF oTFolder1:aDialogs[1]  SIZE 150,007 F3 "SA1" PIXEL
@ 031, 190 SAY "Cidade: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,1540 PIXEL 
@ 029, 215 MSGET oCidade VAR cCidade  OF oTFolder1:aDialogs[1] SIZE 050,007 F3 "SZ7"   PIXEL 
@ 044, 003 SAY "Concorrente que utiliza: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 044, 055 MSGET oConcorrente VAR cConcorrente  OF oTFolder1:aDialogs[1]  SIZE 070,00 PIXEL 
@ 047, 130 SAY "Preço pago: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 044, 163 MSGET oPrecoPago VAR nPrecoPg  PICTURE "@E 999,999.99" OF oTFolder1:aDialogs[1] SIZE 050,00 PIXEL
@ 047, 215 SAY "Potencial: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 044, 244 MSGET oPotencial VAR nPotencial PICTURE "@E 999,999.99" OF oTFolder1:aDialogs[1] SIZE 050,00 PIXEL
@ 069, 003 SAY "Justificativa: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 067, 038 GET oJustificativa VAR cJustificativa MEMO SIZE 255,60 PIXEL OF oTFolder1:aDialogs[1]
@ 142, 003 SAY "Caracteristica: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL
@ 140, 040 MSGET oCaracteristica VAR cCaracteristica  OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SZ4" PIXEL VALID EXISTCPO("SZ4",cCaracteristica) WHEN(cTipoCa == '1')
@ 142, 100 SAY "Linha: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 140, 125 MSGET oLinha VAR cLinha OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SZ1" PIXEL WHEN(cTipoCa == '1')
@ 142, 180 SAY "Cor: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 140, 205 MSGET oCor VAR cCor OF oTFolder1:aDialogs[1]SIZE 050,007 F3 "SZ2" PIXEL WHEN(cTipoCa == '1')
@ 159, 003 SAY "Embalagem: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 157, 035 MSGET oEmbalagem VAR cEmbalagem OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SZ5" PIXEL WHEN(cTipoCa == '1')
@ 159, 90 SAY "Quantidade: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 157, 125 MSGET oQuantidade VAR nQuantidade PICTURE "@E 9999999" OF oTFolder1:aDialogs[1]  SIZE 050,007 PIXEL
@ 176, 003  SAY "Descrição: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 174, 035  MSGET oDescrição VAR cDescricao OF oTFolder1:aDialogs[1]  SIZE 150,007 PIXEL
@ 194, 003  SAY "Produto: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 191, 035  MSGET oProd1 VAR cProd1 OF oTFolder1:aDialogs[1]  SIZE 150,007 F3 "SB1" PIXEL WHEN(cTipoCa == '2')

@210, 100 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] WHEN (!Empty(cRepres).AND.!Empty(cCidade).AND.!Empty(cJustificativa);
.AND.!Empty(nQuantidade));
Action(CadAmostra(cRepres,cECliente,cCliente,cConcorrente,nPrecoPg,nPotencial,cJustificativa,cCaracteristica,cLinha,cCor,cEmbalagem,nQuantidade,cDescricao,cTipoCa,cProd1),oDlg:End())
@210, 150 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(oDlg:End())
  
activate dialog oDlg centered  
                               	
return  


//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////Inserindo dados no Banco- Função Incluir - 25/03/2015//////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
                
	Static Function CadAmostra(cRepres,cECliente,cCliente,cConcorrente,nPrecoPg,nPotencial,cJustificativa,cCaracteristica,cLinha,cCor,cEmbalagem,nQuantidade,cDescricao,cTipoCa,cProd1,; //Etapa 1
cLib,cDesenv,cDsvComp,cObsAprov,;//Etapa 2
cObs,dProdDes,dDataCp,cProd2,;//Etapa 3
cReform,cObsCli,cCliAprov,cFimAm)//Etapa 4
 
dbselectarea("Z04")
dbSetOrder(2)
dbSeek(xFilial("Z04")+Z04->Z04_CODIGO)

if Empty(etapa)
	RecLock("Z04", .T.)
   	Z04->Z04_Filial     := xFilial("Z04")
	Z04->Z04_ETAPA      := "2"
	Z04->Z04_CODIGO     := U_NUMSEQLOTE("Z04",6)
	Z04->Z04_DATA1      := dDatabase
	Z04->Z04_REPRES     := cRepres
	Z04->Z04_LIBCAD    	:= cECliente
	Z04->Z04_CLIENT    	:= cCliente
	Z04->Z04_CIDADE    	:= cCidade
	Z04->Z04_CONCOR    	:= cConcorrente
	Z04->Z04_PREPAG    	:= nPrecoPg
	Z04->Z04_PCOMPR    	:= nPotencial
	Z04->Z04_JUSTIF    	:= cJustificativa
    Z04->Z04_CARACT    	:= cCaracteristica
    Z04->Z04_LINHA     	:= cLinha
    Z04->Z04_COR       	:= cCor
 	Z04->Z04_UNIDAD	   	:= cEmbalagem
    Z04->Z04_QUANT     	:= nQuantidade
    Z04->Z04_DESCRI	   	:= cDescricao
    Z04->Z04_RESP01   	:= RetCodUsr( )
	Z04->Z04_TIPOCA     := cTipoCa
	if 	Z04->Z04_TIPOCA  == '1'
		Z04->Z04_CODGER   := "               "
	else
    	Z04->Z04_CODGER   := cProd1
	endIf
   	dbselectarea("Z04")
    MSUnlock()                   
elseif etapa ="1"     
    RecLock("Z04", .T.) 
   	Z04->Z04_Filial    	:= xFilial("Z04")
	Z04->Z04_ETAPA     	:= "2"
	Z04->Z04_CODIGO    	:= U_NUMSEQLOTE("Z04",6)
	Z04->Z04_DATA1     	:= dDatabase
	Z04->Z04_REPRES    	:= cRepres
	Z04->Z04_LIBCAD    	:= cECliente
	Z04->Z04_CLIENT    	:= cCliente
	Z04->Z04_CIDADE    	:= cCidade
	Z04->Z04_CONCOR    	:= cConcorrente
	Z04->Z04_PREPAG    	:= nPrecoPg
	Z04->Z04_PCOMPR    	:= nPotencial
	Z04->Z04_JUSTIF    	:= cJustificativa
    Z04->Z04_CARACT    	:= cCaracteristica
    Z04->Z04_LINHA     	:= cLinha 
    Z04->Z04_COR       	:= cCor
 	Z04->Z04_UNIDAD	   	:= cEmbalagem 
    Z04->Z04_QUANT     	:= nQuantidade
    Z04->Z04_DESCRI	   	:= cDescricao 
    Z04->Z04_RESP01   	:= RetCodUsr( )    
	Z04->Z04_TIPOCA     := cTipoCa 
	if 	Z04->Z04_TIPOCA  == '1'	
		Z04->Z04_CODGER   := "               "
	else
    	Z04->Z04_CODGER   := cProd1
	endIf
	dbselectarea("Z04")
    MSUnlock()  
elseif etapa = "2" 
	RecLock("Z04", .F.)      
	if cLib == '1'	
		if 	SUBSTR(Z04->Z04_TIPOCA,0,1) == '1'
			Z04->Z04_ETAPA     	:= "3"
		else                          
			Z04->Z04_ETAPA     	:= "4"
		EndIf	
	else
		Z04->Z04_ETAPA     	:= "6"
	endif
	Z04->Z04_DATA2     	:= dDatabase
	Z04->Z04_LIBERA    	:= cLib               
	Z04->Z04_SDESN     	:= cDesenv           
	Z04->Z04_DESCOM    	:= cDsvComp          
    Z04->Z04_RESPON    	:= RetCodUsr( )    
    Z04->Z04_OBSAPR 	:= cObsAprov
	dbselectarea("Z04")
	MSUnlock()
elseif etapa = "3" 
 	RecLock("Z04", .F.)  
	Z04->Z04_DATA3     	:= Z04_DATA2  //Data de chegada
	Z04->Z04_ETAPA     	:= "4"
	Z04->Z04_OBS       	:= cObs
	Z04->Z04_DATAIN		:= dProdDes                   
	Z04->Z04_DATACP		:= dDataCp
	Z04->Z04_DATAPA		:= dDatabase
    Z04->Z04_CODGER     := cProd2
    Z04->Z04_RESP02   	:= RetCodUsr( )
	dbselectarea("Z04")
	MSUnlock()      
elseif etapa = "4" 
 	RecLock("Z04", .F.)      
 	if cFimAm == '1'
	 	Z04->Z04_ETAPA     	:= "5"      
    endif
    Z04->Z04_APROV     	:= cCliAprov 	
    Z04->Z04_OBSC      	:= cObsCli
    Z04->Z04_REFORM    	:= cReform    
    Z04->Z04_FIMAM      := cFimAm
	dbselectarea("Z04")
    MSUnlock()
endif          

If (Z04->Z04_ETAPA == "2") 
	cAssunto := "Pendente para liberação - Numero amostra: "+Z04->Z04_CODIGO
	cTexto := ""         	
	WFAMOSTRA('eliana@brasilux.com.br','',cAssunto,cTexto)
elseIf(Z04->Z04_ETAPA == "3")
	cAssunto := "Cadastro de Amostra - Numero amostra: "+Z04->Z04_CODIGO
	cTexto   := "Amostra liberada: "+alltrim(Z04->Z04_CARACT)+alltrim(Z04->Z04_LINHA)+alltrim(Z04->Z04_COR)+CHR(13)+CHR(10)+"Embalagem: "+alltrim(Z04->Z04_UNIDAD)+CHR(13)+CHR(10)+"Quantidade: "+alltrim(transform(Z04_QUANT,"@E 99999"))
	WFAMOSTRA(GetRespon(Z04->Z04_LINHA),alltrim(UsrRetMail(Z04->Z04_RESP01)),cAssunto,cTexto)
elseIf(Z04->Z04_ETAPA == "4")
	cAssunto := "Cadastro de Amostra - Numero amostra: "+Z04->Z04_CODIGO 
	cTexto   := ""
	WFAMOSTRA(alltrim(UsrRetMail(Z04->Z04_RESP01)),'eliana@brasilux.com.br',cAssunto,cTexto)
EndIf

dbSkip()
         
return 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////Altera os dados da proxima etapa - Função Alterar - 25/03/2015/////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                                                                                                              
User function Alter(cNum) 

dbselectarea("Z04")
dbSetOrder(2)
  
etapa := Z04->Z04_ETAPA
if(cNum == 2)
    etapa('9')
else    
	if etapa < '5'
	    etapa(etapa)
	else
	 	Alert("Essa pedido de amostra está finalizada ou cancelada")
	endif
endif
return      

static Function etapa(etapa)   
private data1,oData1
private cRepres,oRepres
private cECliente,oECliente
private cCliente,oCliente
private cCidade,oCidade
private cConcorrente,oConcorrente
private nPrecoPg,oPrecoPg
private nPotencial,oPotencial
private cJustificativa,oJustificativa
private cCaracteristica,oCaracteristica
private cLinha,oLinha
private cCor,oCor
private cEmbalagem,oEmbalagem
private nQuantidade,oQuantidade
private cDescricao,oDescricao
private data2,oData2
private cLib,oLib
private cDesenv,oDesenv
private cDsvComp,oDsvComp
private cRespon,oRespon
private cRespon1,oRespon1
private data6,oData6
private cObs,oObs
private dProdDes,oProdDes
private dDataCp,oDataCp
private dDataPa,oDataPa
private cCliAprov,oCliProv
private cObsCli,oObsCli
private cReform,oReform
private cTipoCa,oTipoCa
private cProd1,oProd1
private cProd2,oProd2
private cRespon2,oRespon2
private cFimAm,oFimAm
private cObsAprov,oObsAprov
dbselectarea("Z04")
dbSetOrder(2)
dbSeek(xFilial("Z04")+Z04->Z04_CODIGO)          

cTipoCa := Z04->Z04_TIPOCA
data1 := Z04->Z04_DATA1  
cRepres:= Z04->Z04_REPRESEN
cECliente := Z04->Z04_LIBCAD 
cCliente := Posicione("SA1",1,xFilial("SA1")+Z04->Z04_CLIENT,'A1_NOME')
cCidade  := Z04->Z04_CIDADE 
cConcorrente:= Z04->Z04_CONCOR 
nPrecoPg:= Z04->Z04_PREPAG 
nPotencial:= Z04->Z04_PCOMPR 
cJustificativa:= Z04->Z04_JUSTIF 
cCaracteristica:= Z04->Z04_CARACT 
cLinha:= Z04->Z04_LINHA 
cCor:= Z04->Z04_COR 
cEmbalagem:= Z04->Z04_UNIDAD 
nQuantidade:= Z04->Z04_QUANT 
cDescricao:= Z04->Z04_DESCRI
data2:= Z04->Z04_DATA2 
cLib := Z04->Z04_LIBERA 
cDesenv := Z04->Z04_SDESN 
cDsvComp := Z04->Z04_DESCOM 
cRespon := UsrRetName(Z04->Z04_RESPON) 
cRespon1 := UsrRetName(Z04->Z04_RESP01) 
data6 := Z04->Z04_DATA2 
cObs:= Z04->Z04_OBS 
dProdDes := Z04->Z04_DATAIN 
dDataCp := Z04->Z04_DATACP 
dDataPa := Z04->Z04_DATAPA 
cCliAprov := Z04->Z04_APROV 
cObsCli:= Z04->Z04_OBSC 
cReform := Z04->Z04_REFORM   
cProd1 := Z04->Z04_CODGER
cProd2 := Z04->Z04_CODGER
cRespon2 := UsrRetName(Z04->Z04_RESP02)
cFimAm := Z04->Z04_FIMAM  
cObsAprov :=  Z04->Z04_OBSAPR
define dialog oDlg title "Cadastro Amostra" from 100,100 to 650,800 pixel

aTFolder1 := { "Cadastro de Amostra","Aprovação","Tecnico","Comercial"}
oTFolder1 := tfolder():new( 0,25,aTFolder1,,oDlg,,,,.t.,,300,240 )    
oCadastro:= tsay():new(2,2,{||""}, oTFolder1:aDialogs[1],,,,,,.t.,CLR_RED,CLR_WHITE,96,9) 

//------------------------------------------------ETAPA 1--------------------------------------------------

@ 017, 003 SAY "Tipo Cad: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS  0,0 PIXEL 
@ 015, 030 MSCOMBOBOX oTipoCa VAR cTipoCa ITEMS{"1=Desenvolvimento","2=Existente"} SIZE 040, 040 OF oTFolder1:aDialogs[1] COLORS 0, 10 PIXEL
@ 017, 070 SAY "Data: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS  0, 0 PIXEL
@ 015, 085 MSGET oData1 VAR data1  OF oTFolder1:aDialogs[1] SIZE 50,05 PIXEL WHEN .F. 
@ 017, 135 SAY "Representante: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0  PIXEL
@ 015, 175 MSGET oRepres VAR cRepres  OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SA3" PIXEL
@ 017, 228 SAY "É cliente?" SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0,0 PIXEL    
@ 015, 255 MSCOMBOBOX oECliente VAR cECliente ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[1] COLORS 0, 10 PIXEL
@ 031, 003 SAY "Cliente: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL
@ 029, 030 MSGET oCliente VAR cCliente OF oTFolder1:aDialogs[1]  SIZE 150,007 F3 "SA1" PIXEL	
@ 031, 190 SAY "Cidade: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,1540 PIXEL 
@ 029, 215 MSGET oCidade VAR cCidade  OF oTFolder1:aDialogs[1] SIZE 050,007 F3 "SZ7"   PIXEL 
@ 044, 003 SAY "Concorrente que utiliza: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 044, 055 MSGET oConcorrente VAR cConcorrente  OF oTFolder1:aDialogs[1]  SIZE 070,00 PIXEL 
@ 047, 130 SAY "Preço pago: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 044, 163 MSGET oPrecoPago VAR nPrecoPg  PICTURE "@E 999,999.99" OF oTFolder1:aDialogs[1] SIZE 050,00 PIXEL
@ 047, 215 SAY "Potencial: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 044, 244 MSGET oPotencial VAR nPotencial PICTURE "@E 999,999.99" OF oTFolder1:aDialogs[1] SIZE 050,00 PIXEL
@ 069, 003 SAY "Justificativa: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
@ 067, 038 GET oJustificativa VAR cJustificativa MEMO SIZE 255,60 PIXEL OF oTFolder1:aDialogs[1]
@ 142, 003 SAY "Caracteristica: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL
@ 140, 040 MSGET oCaracteristica VAR cCaracteristica  OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SZ4" PIXEL VALID EXISTCPO("SZ4",cCaracteristica) WHEN(cTipoCa == '1')
@ 142, 100 SAY "Linha: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 140, 125 MSGET oLinha VAR cLinha OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SZ1" PIXEL WHEN(cTipoCa == '1')
@ 142, 180 SAY "Cor: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 140, 205 MSGET oCor VAR cCor OF oTFolder1:aDialogs[1]SIZE 050,007 F3 "SZ2" PIXEL WHEN(cTipoCa == '1')
@ 159, 003 SAY "Embalagem: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 157, 035 MSGET oEmbalagem VAR cEmbalagem OF oTFolder1:aDialogs[1]  SIZE 050,007 F3 "SZ5" PIXEL WHEN(cTipoCa == '1')
@ 159, 90 SAY "Quantidade: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 157, 125 MSGET oQuantidade VAR nQuantidade PICTURE "@E 9999999" OF oTFolder1:aDialogs[1]  SIZE 050,007 PIXEL
@ 176, 003  SAY "Descrição: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 174, 035  MSGET oDescrição VAR cDescricao OF oTFolder1:aDialogs[1]  SIZE 150,007 PIXEL
@ 194, 003  SAY "Produto: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 191, 035  MSGET oProd1 VAR cProd1 OF oTFolder1:aDialogs[1]  SIZE 100,007 F3 "SB1" PIXEL WHEN(cTipoCa == '2')
@ 194, 150  SAY "Comercial: " SIZE 052, 020 OF oTFolder1:aDialogs[1] COLORS 8415564,0 PIXEL    
@ 191, 185  MSGET Respon1 VAR cRespon1 OF oTFolder1:aDialogs[1]  SIZE 100,007 PIXEL  WHEN .F.

//------------------------------------------------ETAPA 2--------------------------------------------------

@ 017, 003 SAY "Data: " SIZE 052, 007 OF oTFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
@ 015, 030 MSGET oData2 VAR data2  OF oTFolder1:aDialogs[2] SIZE 50,05 PIXEL  WHEN .F.
@ 035, 003 SAY "Liberado para desenvolvimento? " SIZE 062, 020 OF oTFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
@ 037, 070 MSCOMBOBOX oLib VAR cLib ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[2] COLORS 0, 10 PIXEL
@ 060, 003 SAY "Somente desenvolvimento de cor? " SIZE 062, 020 OF oTFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
@ 062, 070 MSCOMBOBOX oDesenv VAR cDesenv ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[2] COLORS 0, 10 PIXEL 
@ 090, 003 SAY "Desenvolvimento completo? " SIZE 052, 020 OF oTFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL    
@ 088, 050 MSCOMBOBOX oDsvComp VAR cDsvComp ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[2] COLORS 0, 10 PIXEL
@ 115, 003 SAY "Ass. Dep. Comercial ou Diretoria: " SIZE 080, 015 OF oTFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
@ 113, 090 MSGET oRespon VAR cRespon OF oTFolder1:aDialogs[2] SIZE 50,05 PIXEL WHEN .F.  
@ 132, 003 SAY "Obs: " SIZE 052, 020 OF oTFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
@ 130, 038 GET oObsAprov VAR cObsAprov MEMO SIZE 255,60 PIXEL OF oTFolder1:aDialogs[2]

//------------------------------------------------ETAPA 3--------------------------------------------------

@ 017, 003 SAY "Solicitação ao dep. Tec. cadastro do prod. no sistema na data: " SIZE 100, 015 OF oTFolder1:aDialogs[3] COLORS 0, 16777215 PIXEL
@ 019, 095 MSGET oData6 VAR data6  OF oTFolder1:aDialogs[3] SIZE 50,05 PIXEL WHEN .F.
@ 040, 003 SAY "Obs Produto: " SIZE 052, 020 OF oTFolder1:aDialogs[3] COLORS 0, 16777215 PIXEL
@ 042, 038 GET oObs VAR cObs MEMO SIZE 255,60 PIXEL OF oTFolder1:aDialogs[3] 
@ 110, 003 SAY "Produto desenvolvido: " SIZE 080, 015 OF oTFolder1:aDialogs[3] COLORS 0, 16777215 PIXEL
@ 112, 090 MSGET oProdDes VAR dProdDes OF oTFolder1:aDialogs[3] SIZE 50,05 PIXEL
@ 132, 003 SAY "Produto cadastrado data: " SIZE 080, 015 OF oTFolder1:aDialogs[3] COLORS 0, 16777215 PIXEL
@ 134, 090 MSGET oDataCp VAR dDataCp  OF oTFolder1:aDialogs[3] SIZE 50,05 PIXEL
@ 157, 003 SAY "Encaminhamento ao departamento comercial: " SIZE 080, 015 OF oTFolder1:aDialogs[3] COLORS 0, 16777215 PIXEL
@ 162, 090 MSGET oDataPa VAR dDataPa  OF oTFolder1:aDialogs[3] SIZE 50,05 PIXEL WHEN .F.  
@ 182, 003  SAY "Produto: " SIZE 052, 020 OF oTFolder1:aDialogs[3] COLORS 8415564,0 PIXEL    
@ 180, 035  MSGET oProd2 VAR cProd2 OF oTFolder1:aDialogs[3]  SIZE 100,007 F3 "SB1" PIXEL 
@ 182, 150  SAY "Tecnico: " SIZE 052, 020 OF oTFolder1:aDialogs[3] COLORS 8415564,0 PIXEL    
@ 180, 185  MSGET oRespon2 VAR cRespon2 OF oTFolder1:aDialogs[3]  SIZE 100,007 PIXEL WHEN .F.
//------------------------------------------------ETAPA 4--------------------------------------------------

@ 017, 003 SAY "Cliente Aprovou? " SIZE 052, 020 OF oTFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL    
@ 019, 090 MSCOMBOBOX oCliAprov VAR cCliAprov ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[4] COLORS 0, 10 PIXEL
@ 040, 003 SAY "Obs do Cliente: " SIZE 052, 020 OF oTFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
@ 042, 038 GET oObsCli VAR cObsCli MEMO SIZE 255,60 PIXEL OF oTFolder1:aDialogs[4]
@ 110, 003 SAY "Caso não aprovou, reformulação? " SIZE 052, 020 OF oTFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL    
@ 112, 090 MSCOMBOBOX oReform VAR cReform ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[4] COLORS 0, 10 PIXEL
@ 135, 003 SAY "Finalizar amostra? " SIZE 052, 020 OF oTFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL    
@ 133, 090 MSCOMBOBOX oFimAm VAR cFimAm ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oTFolder1:aDialogs[4] COLORS 0, 10 PIXEL	
//botão        
if(etapa < '9')
	if(etapa == '0' .or. etapa == '1')     
		@210, 100 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] WHEN (!Empty(cRepres).AND.!Empty(cCidade).AND.!Empty(cJustificativa);
.AND.!Empty(nQuantidade));
		Action(CadAmostra(cRepres,cECliente,cCliente,cConcorrente,nPrecoPg,nPotencial,cJustificativa,cCaracteristica,cLinha,cCor,cEmbalagem,nQuantidade,cDescricao,cTipoCa,cProd1),oDlg:End())
		@210, 150 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(oDlg:End())
	elseif(etapa == '2')
		@210, 100 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[2] WHEN (!Empty(cLib) .AND.!Empty(cDesenv) .AND. !Empty(cDsvComp));
		Action(CadAmostra(,,,,,,,,,,,,,,,cLib,cDesenv,cDsvComp,cObsAprov),oDlg:End())
		@210, 150 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[2] Action(oDlg:End())
	elseif(etapa == '3')
		@210, 100 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[3] WHEN (!EMPTY(cObs) .AND. !EMPTY(dProdDes) .AND. !EMPTY(dDataCp));
		Action(CadAmostra(,,,,,,,,,,,,,,,,,,,cObs,dProdDes,dDataCp,cProd2),oDlg:End())
		@210, 150 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[3] Action(oDlg:End())
	elseif(etapa == '4')
		@210, 100 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[4] WHEN (!EMPTY(cReform) .AND. !EMPTY(cObsCli) .AND. !EMPTY(cCliAprov));
		Action(CadAmostra(,,,,,,,,,,,,,,,,,,,,,,,cReform,cObsCli,cCliAprov,cFimAm),oDlg:End())
		@210, 150 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[4] Action(oDlg:End())
	EndIf
elseif(etapa == '9')
		@210, 125 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(oDlg:End())
EndIf
	activate dialog oDlg centered
	

return


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////Voltar etapa 25-03//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////       

user function voltar()

dbselectarea("Z04")
dbSetOrder(2)
dbSeek(xFilial("Z04")+Z04->Z04_CODIGO)

etapa := Z04->Z04_ETAPA

RecLock("Z04", .F.)

if (((PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) == 0) .OR. RetCodUsr() == '000005' .OR. RetCodUsr() == '000264') .AND. etapa =="2")
	Z04->Z04_ETAPA := "1"
elseif(((PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) == 0) .OR. RetCodUsr() == '000005' .OR. RetCodUsr() == '000264') .AND.  etapa =="3")
   Z04->Z04_ETAPA := "2"
elseif (((PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) == 0) .OR. RetCodUsr() == '000005' .OR. RetCodUsr() == '000264') .AND.  etapa =="4")
   Z04->Z04_ETAPA := "3"
elseif (((PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) == 0) .OR. RetCodUsr() == '000005' .OR. RetCodUsr() == '000264') .AND.  etapa =="5")
   Z04->Z04_ETAPA := "4"
else
   Alert("Não pode voltar etapa de um pedido de amostra Cancelado ou Finalizado!!!")
endif
MSUnlock()
return

//------------------------------------------------------Filtro--------------------------------------------------------

User Function AmostEtp(nEtapa)
Local nOrdem,nReg,lReg,cEtapa,cAux

cEtapa := alltrim(str(nEtapa))

dbselectarea("Z04")
nOrdem := IndexOrd()
if !eof() .and. !bof()
	lReg := .t.
	nReg := recno()
else
	lReg := .f.
endif 

if oObjBrow:Filtrate()
	oObjBrow:DeleteFilter("Etapas")
	if lReg
		dbgoto(nReg)
	endif
endif
SET FILTER TO
dbselectarea("Z04")
dbsetorder(1)
dbseek(xFilial("Z04")+cEtapa)
if found()
	dbsetorder(nOrdem)
  	_cFiltro := 'Z04_ETAPA = "'+cEtapa+'"'
  	oObjBrow:AddFilter("Etapas",_cFiltro,,.t.,,,,"Etapas")
   	//oObjBrow:SetFilterDefault(_cFiltro)
   	//cAux := "SET FILTER TO Z04_ETAPA = '"+cEtapa+"'"
   	//&cAux
else
	dbsetorder(nOrdem)
	alert("Não existe nenhum registro na etapa "+cEtapa+"!")
endif
		
Return

User Function AmostAll(nEtapa)

dbselectarea("Z04")
			if oObjBrow:Filtrate()
	/*			oObjBrow:CleanFilter()
				oObjBrow:CleanExFilter()
				oObjBrow:CleanProfile()
	*/			nReg := recno()
				oObjBrow:DeleteFilter("Etapas") 
				dbgoto(nReg)
			endif
			  	/*
			  	_cFiltro := 'Z04_ETAPA'
			  	oObjBrow:AddFilter("Etapas",_cFiltro,,.t.,,,,"Etapas")
			   	//oObjBrow:SetFilterDefault(_cFiltro) 
			   	*/
			   	SET FILTER TO 
			//oObjBrow:ExecuteFilter (.t.)
	Return
		
//-----------------------------------------------------------------Excluir-------------------------------------------------------------
User Function AmostExc()

dbSelectArea("Z04")
dbSetOrder(2)
dbSeek(xFilial("Z04")+Z04->Z04_CODIGO)
  
if ((Z04->Z04_RESP01== RetCodUsr()).OR. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) == 0))
	if  Z04_ETAPA < '6' 
		RecLock("Z04", .F.)
		dbDelete()
		MSUnlock()
	else 
	   	Alert("Não pode excluir um pedido de amostra Cancelado ou Finalizado!!!")	  
	endif
endif
	dbSelectArea("Z04")
	dbSkip()

Return Nil      
//----------------------------------------------------LEGENDA-------------------------------------------------------------/

User Function Legend()
Local cCadastro := OemToAnsi('Status de Pedido')
     BrwLegenda(cCadastro,"Status",;
      {{"BR_MARROM" ,"Dep. Comercial"},;
      {"BR_VERDE"   ,"Pendente Aprovação"},;                                                                                                 
      {"BR_AMARELO" ,"Dep. Técnico   "},;
      {"BR_AZUL"    ,"Dep. Comercial "},;
      {"BR_LARANJA" ,"Finalizado"},;
      {"BR_VERMELHO","Amostra Cancelado"}})
Return(.t.)

//----------------------------------------------------Imprimir-------------------------------------------------------------/

user Function AmostImp()
PRIVATE CbTxt
PRIVATE Titulo := "Pedido Amostra"
PRIVATE cDesc1 := "Este relatorio ira emitir o Pedido de "
PRIVATE cDesc2 := "Amostra"
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "G"                                                          
PRIVATE Limite := 220
PRIVATE cString:= "SA1"
PRIVATE m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="PEDIDOAM"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="PEDIDOAM"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="PEDIDOAM"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

return

Static Function RptDetail()
Local nTotal := 0
Local cNomeCor
Local cNomeRepres
Local cNomeLinhha
Local cNomeCaract
Local cNomeEmb
Local cNomeCidade
Local cNomeClient
Local _nCont := 0
Local lNormal
Private _nLin := 7   
Private mcodigo
/////////////////////////////////////////////////////////////////
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿//
//³ Inicializa  regua de impressao                            ³//
//³                                                           ³//
//³ CODIGO SQL                                                ³//
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ//
/////////////////////////////////////////////////////////////////
SetRegua(RECCOUNT("1")) 

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

dbselectarea("SZ4")
dbgotop()
dbSetOrder(1)
dbSeek(xFilial("SZ4")+Z04->Z04_CARACT)

dbselectarea("SA3")
dbgotop()
dbSetOrder(1)
dbSeek(xFilial("SA3")+Z04->Z04_REPRES)

dbselectarea("SZ7")
dbgotop()
dbSetOrder(1)
dbSeek(xFilial("SZ7")+Z04->Z04_CIDADE)
dbselectarea("SA1")
dbgotop()
dbSetOrder(1)
dbSeek(xFilial("SA1")+Z04->Z04_CLIENT)

dbSelectArea("Z04")
dbSetOrder(2)

dbSeek(xFilial("Z04")+Z04->Z04_CODIGO)

cNomeCaract  :=  iif(found(),SZ4->Z4_DESCR,"")
cNomeCaract  :=  iif(found(),ALLTRIM(SZ4->Z4_DESCR),"")

cNomeCliente :=  iif(found(),SA1->A1_NOME,"")
cNomeCliente :=  iif(found(),ALLTRIM(SA1->A1_NOME),"")

cNomeCidade  :=  iif(found(),SZ7->Z7_NOME,"")
cNomeCidade  :=  iif(found(),ALLTRIM(SZ7->Z7_NOME),"")

cNomeRepres  :=  iif(found(),SA3->A3_NOME,"")
cNomeRepres  :=  iif(found(),ALLTRIM(SA3->A3_NOME),"")

  _nLin := 07
@ _nLin,000 psay "Data: "+substr(dtos(Z04_DATA1),7,2)+"/"+substr(dtos(Z04_DATA1),5,2)+"/"+substr(dtos(Z04_DATA1),1,4)
@ _nLin,107 psay "|"
@ _nLin,110 psay "Data: "+substr(dtos(Z04_DATA3),7,2)+"/"+substr(dtos(Z04_DATA3),5,2)+"/"+substr(dtos(Z04_DATA3),1,4)
  _nLin++
@ _nLin,000 psay "Representante: "+cNomeRepres
@ _nLin,107 psay "|"
@ _nLin,110 psay "Observacoes do produto : "+substr(Z04->Z04_OBS,0,75)
  _nLin++	
@ _nLin,000 psay "Cliente: "+cNomeCliente
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,76,100)
  _nLin++	
@ _nLin,000 psay "Cidade: "+cNomeCidade
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,177,100)
  _nLin++	            
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,278,100)
@ _nLin,000 psay replicate("_",105)
_nLin++
@ _nLin,000 psay "Embalagem        Quant.    Descricao                             Linha                          Cor "
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,379,100)
_nLin++
@ _nLin,000 psay replicate("-",105) 
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,480,100)
_nLin++
mcodigo := Z04_CODIGO
While !EOF() .And. ((Z04->Z04_CODIGO) == (mcodigo))
	dbselectarea("SZ2")
	dbgotop()
	dbSetOrder(1)
	dbSeek(xFilial("SZ2")+Z04->Z04_COR)
	
	dbselectarea("SZ1")
	dbgotop()
	dbSetOrder(1)
	dbSeek(xFilial("SZ1")+Z04->Z04_LINHA)
	
	dbselectarea("SZ5")
	dbgotop()
	dbSetOrder(1)
	dbSeek(xFilial("SZ5")+Z04->Z04_UNIDAD)
	cNomeEmb 	 :=  iif(found(),SZ5->Z5_DESCR,"")
	cNomeEmb 	 :=	 iif(found(),ALLTRIM(SZ5->Z5_DESCR),"")
	@ _nLin,000 psay cNomeEmb                             	
	@ _nLin,017 psay transform(Z04->Z04_QUANT,"@E 999999")
	@ _nLin,028 psay substr(Z04->Z04_DESCRI,0,35)
	cNomeLinha 	 :=  iif(found(),SZ1->Z1_DESCR,"")
	cNomeLinha 	 :=  iif(found(),ALLTRIM(SZ1->Z1_DESCR),"")
	@ _nLin,065 psay Z04->Z04_LINHA+"- "+substr(cNomeLinha,0,20)
	cNomeCor     :=  iif(found(),SZ2->Z2_DESCR,"")
	cNomeCor 	 :=  iif(found(),ALLTRIM(SZ2->Z2_DESCR),"")                                   
	
	@ _nLin,095 psay cNomeCor
	@ _nLin,107 psay "|"
	  _nLin++
	
	dbSelectArea("Z04")
	dbSkip()
end 
dbSelectArea("Z04")
dbSetOrder(2)
dbSeek(xFilial("Z04")+Mcodigo)
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,581,100)
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,682,100)	
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,783,100)
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,884,100)                                              	
  _nLin++	            
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,985,100)
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBS,1086,100)
  _nLin++	            
@ _nLin,107 psay "|"
  _nLin++	            
@ _nLin,107 psay "|"
@ _nLin,110 psay "Produto desenvolvido data : "+substr(dtos(Z04_PRODDE),7,2)+"/"+substr(dtos(Z04_PRODDE),5,2)+"/"+substr(dtos(Z04_PRODDE),1,4)	  
  _nLin++	
@ _nLin,000 psay replicate("_",105)
@ _nLin,107 psay "|"
  _nLin++
@ _nLin,000 psay "Caracteristica desejada pelo cliente: "+cNomeCaract
@ _nLin,107 psay "|"
@ _nLin,110 psay "Valor somente do produto : "+transform(Z04->Z04_VALORP,"@E 99,999,999.99")
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay "Encaminhado ao departamento comercial data : "+substr(dtos(Z04_ENCAMI),7,2)+"/"+substr(dtos(Z04_ENCAMI),5,2)+"/"+substr(dtos(Z04_ENCAMI),1,4)	  
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay replicate("_",100)   
  _nLin++             
@ _nLin,107 psay "|"
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay replicate("_",100)
  _nLin++
@ _nLin,000 psay "Concorrente utiliza (S/N): "+Z04->Z04_CONCOR
@ _nLin,107 psay "|"
  _nLin++
@ _nLin,000 psay "Preco pago: "+transform(Z04->Z04_PREPAG,"@E 99,999,999.99")
@ _nLin,107 psay "|"
@ _nLin,110 psay "Liberacao para cadastro ( caso cor ) ou amostra (S/N): "+Z04->Z04_LIBCAD
  _nLin++
@ _nLin,000 psay "Potencial de compra: "+transform(Z04->Z04_PCOMPR,"@E 99,999,999.99")
@ _nLin,107 psay "|"
@ _nLin,110 psay "Solicitacao ao dep. Tec. cadastro do prod. no sistema na data : "+substr(dtos(Z04_SOLICI),7,2)+"/"+substr(dtos(Z04_SOLICI),5,2)+"/"+substr(dtos(Z04_SOLICI),1,4)
  _nLin++	
@ _nLin,000 psay "Justificativa do Repres : "+substr(Z04->Z04_JUSTIF,0,79)
@ _nLin,107 psay "|"
@ _nLin,110 psay replicate("_",100) 
  _nLin++
@ _nLin,000 psay substr(Z04->Z04_JUSTIF,80,105)
@ _nLin,107 psay "|"
  _nLin++
@ _nLin,000 psay replicate("_",105)
@ _nLin,107 psay "|"
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay "Data do cadastro do Produto : "+substr(dtos(Z04_DATACP),7,2)+"/"+substr(dtos(Z04_DATACP),5,2)+"/"+substr(dtos(Z04_DATACP),1,4) 
@ _nLin,170 psay "Codigo Gerado : "+Z04_CODGER
  _nLin++
@ _nLin,000 psay replicate("_",105)
@ _nLin,107 psay "|"
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay "Preparacao da amostra data : "+substr(dtos(Z04_DATAPA),7,2)+"/"+substr(dtos(Z04_DATAPA),5,2)+"/"+substr(dtos(Z04_DATAPA),1,4)
  _nLin++             
@ _nLin,107 psay "|"
@ _nLin,110 psay "Data cadastro inspecao : "+substr(dtos(Z04_DATAIN),7,2)+"/"+substr(dtos(Z04_DATAIN),5,2)+"/"+substr(dtos(Z04_DATAIN),1,4)
  _nLin++
@ _nLin,000 psay "Data: "+substr(dtos(Z04_DATA2),7,2)+"/"+substr(dtos(Z04_DATA2),5,2)+"/"+substr(dtos(Z04_DATA2),1,4)
@ _nLin,107 psay "|"
@ _nLin,110 psay replicate("_",100)
  _nLin++            
@ _nLin,107 psay "|"
@ _nLin,110 psay "Cliente aprovou (S/N): "+Z04->Z04_APROV
  _nLin++
@ _nLin,000 psay "Produto liberado para Desenvolvimento (S/N): "+Z04->Z04_LIBERA
@ _nLin,107 psay "|"
  _nLin++
@ _nLin,000 psay "Somente desenvolvimento de cor  (S/N): "+Z04->Z04_SDESN
@ _nLin,107 psay "|"
@ _nLin,110 psay "Observacao do cliente : ( elogio ou critica ) "+substr(Z04->Z04_OBSC,0,52)
  _nLin++
@ _nLin,000 psay "Desenvolvimento completo  (S/N): "+Z04->Z04_DESCOM 
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBSC,53,100)
 _nLin++
@ _nLin,000 psay "Responsavel  : "+UsrRetName(Z04_RESPON)
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBSC,154,100)
  _nLin++            
@ _nLin,107 psay "|"
@ _nLin,110 psay substr(Z04->Z04_OBSC,255,100)
  _nLin++
@ _nLin,000 psay "Ass. Dep. Comercial  : "+replicate("_",67)                         
@ _nLin,107 psay "|"
  _nLin++
@ _nLin,107 psay "|"
@ _nLin,110 psay "Caso nao aprovou, reformulacao (S/N): "+Z04->Z04_REFORM
  _nLin++
@ _nLin,000 psay replicate("_",220)

dbSelectArea("Z04")
dbSkip()
dbSelectArea("Z04")

dbselectarea("Z04")
dbclosearea("Z04")

Set Device To Screen

Set Printer TO
dbcommitAll()
ourspool(wnrel)                                           

MS_FLUSH()

Return

Static Function WFAMOSTRA(cPara,respon,cAssunto,cTexto)
local cCC,cArquivo
cCC 	 :=	respon
cArquivo := ''
U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo)
return  nil

Static Function GetRespon(cLinha)

cQuery :="SELECT rtrim(ZH_EMAIL) AS MAIL "
cQuery +="FROM "+RetSqlName("SX5")+" SX5 WITH(NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SZH")+" SZH WITH(NOLOCK) ON ZH_FILIAL = '"+xFilial("SZH")+"' AND ZH_CODIGO = X5_CHAVE AND SZH.D_E_L_E_T_ <> '*' "
cQuery +="WHERE X5_TABELA = 'W0' AND SX5.D_E_L_E_T_ <> '*' AND X5_FILIAL = '"+xFilial("SX5")+"' AND ZH_MSBLQL <> '1' AND X5_DESCRI = '"+SUBSTR(cNumemp,3,6)+cLinha+"' AND ZH_EMAIL <> '' "
cQuery +="ORDER BY SUBSTRING(X5_DESCRI,7,2) "
          
TCQUERY cQuery ALIAS "TCQ" NEW

dbselectarea("TCQ")

cPara := ""
while !EoF()
	cPara += ""+TCQ->MAIL+","
	dbselectarea("TCQ")	 
	dbskip() 
endDo

dbSelectArea("TCQ")
dbCloseArea("TCQ")

return cPara