///ALterar volume do pedido
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch" 
#include 'font.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "DIRECTRY.CH"

User Function BRALTVOL()
Private aRotina := {}
Private cCadastro := "Cadastro "
Private cAlias := "SC5"
TcRefresh(RetSqlName("SC5"))

AAdd(aRotina, {"Pesquisar"             , "AxPesqui"  , 0, 1})
AAdd(aRotina, {"Visualizar"            , "AxVisual"  , 0, 2})
AAdd(aRotina, {"Alterar"               , "u_Altvolx1"  , 0, 3})

if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
endif 
  
dbSelectArea("SC5")
dbGoTop()
mBrowse( ,,,,"SC5")         
Return Nil  

User Function Altvolx1()        
dbSelectArea("SC5")   
dbsetorder(1)
dbseek(xFilial("SC5")+SC5->C5_NUM) 
if found()      
	define dialog oDlg title "Alterar Pedido" from 100,100 to 450,600 pixel
	
	aTFolder1 := { "Pedido        "+C5_NUM}
	oTFolder1 := tfolder():new( 0,25,aTFolder1,,oDlg,,,,.t.,,200,150 )    
	  
	cVolume:= C5_VOLUME1
	@ 017, 003 SAY "Volume: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0  PIXEL
	@ 015, 050 MSGET oVolume VAR cVolume PICTURE "@E 999999" OF oTFolder1:aDialogs[1]  SIZE 050,007 PIXEL 
		
	cPesoL := C5_PESOL
	@ 031, 003 SAY "Peso Liquido: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
	@ 029, 035 MSGET oPesoL VAR cPesoL PICTURE "@E 99,999.999" OF oTFolder1:aDialogs[1	] SIZE 50,05 PIXEL 
	  	
	cPesoB:= C5_PBRUTO
	@ 031, 100 SAY "Peso Bruto: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,1540 PIXEL 
	@ 029, 135 MSGET oPesoB VAR cPesoB  PICTURE "@E 99,999.999" OF oTFolder1:aDialogs[1] SIZE 050,007 PIXEL
	
	cCubo:= C5_VOLUME2
	@ 047, 003 SAY "M. Cubicos: " SIZE 50, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0  PIXEL
	@ 045, 035 MSGET oCubo VAR cCubo PICTURE "@E 99,999.999" OF oTFolder1:aDialogs[1]  SIZE 50,007 PIXEL 
	                 
	@100, 060 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(altVol(cVolume,cPesoL,cPesoB,cCubo),oDlg:End())
	@100, 110 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(oDlg:End())
	
	activate dialog oDlg centered  
endif	
return

static function altVol(cVolume,cPesoL,cPesoB,cCubo)
dbselectarea("SC5")
dbSetOrder(1)
dbSeek(xFilial("SC5")+SC5->C5_NUM)
RecLock("SC5", .F.)  
SC5->C5_VOLUME1 := cVolume
SC5->C5_PESOL := cPesoL
SC5->C5_PBRUTO := cPesoB 
SC5->C5_VOLUME2 :=cCubo
MSUnlock()  
dbSkip() 
return