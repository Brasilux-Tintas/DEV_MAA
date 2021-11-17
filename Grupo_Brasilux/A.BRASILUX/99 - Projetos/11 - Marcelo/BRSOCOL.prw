///ALterar volume do pedido
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch" 
#include 'font.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "DIRECTRY.CH"

User Function BRSOCOL()
Private aRotina := {}
Private cCadastro := "Cadastro "
Private cAlias := "SC5"
TcRefresh(RetSqlName("SC5"))

AAdd(aRotina, {"Pesquisar"             , "AxPesqui"  , 0, 1})
AAdd(aRotina, {"Visualizar"            , "AxVisual"  , 0, 2})
AAdd(aRotina, {"Alterar"               , "u_AltCol"  , 0, 3})

if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
endif 
  
dbSelectArea("SC5")
dbGoTop()


mBrowse( ,,,,"SC5")         

Return Nil  

User Function AltCol()                                                            
	  
dbSelectArea("SC5")   
dbsetorder(1)
dbseek(xFilial("SC5")+SC5->C5_NUM) 
if found()      
	define dialog oDlg title "Alterar Pedido" from 100,100 to 450,600 pixel
	
	aTFolder1 := { "Pedido        "+C5_NUM}
	oTFolder1 := tfolder():new( 0,25,aTFolder1,,oDlg,,,,.t.,,200,150 )    
    
   	cCliente := POSICIONE("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,"A1_NOME")  
	@ 017, 003 SAY "Razão: " SIZE 180, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
	@ 015, 035 MSGET oCliente VAR cCliente OF oTFolder1:aDialogs[1] SIZE 120,05 PIXEL WHEN .F.
	
	cPesoL := C5_PESOL
	@ 031, 003 SAY "Peso Liquido: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
	@ 029, 035 MSGET oPesoL VAR cPesoL PICTURE "@E 99,999.999" OF oTFolder1:aDialogs[1	] SIZE 50,05 PIXEL WHEN .F.
	  	
	cPesoB:= C5_PBRUTO
	@ 031, 100 SAY "Peso Bruto: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,1540 PIXEL 
	@ 029, 135 MSGET oPesoB VAR cPesoB  PICTURE "@E 99,999.999" OF oTFolder1:aDialogs[1] SIZE 050,007 PIXEL WHEN .F.
	
	cColeta:= C5_XNROCOL
	@ 047, 003 SAY "Num Coleta: " SIZE 150, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0  PIXEL
	@ 045, 035 MSGET oColeta VAR cColeta OF oTFolder1:aDialogs[1]  SIZE 150,007 PIXEL 
  
	@100, 060 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(altColx(cColeta),oDlg:End())
	@100, 110 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(oDlg:End())
	
	activate dialog oDlg centered  
endif	
return

static function altColx(cColeta)
local lInclui
dbselectarea("SC5")
dbSetOrder(1)
dbSeek(xFilial("SC5")+SC5->C5_NUM)
IF FOUND()
	RecLock("SC5", .F.)  
	SC5->C5_XNROCOL := cColeta
	MSUnlock()  
	if !empty(cColeta)
		dbselectarea("ZZ0")
		dbsetorder(4)
		dbseek(xFilial("ZZ0")+SC5->C5_NUM)
		lInclui := !found()
		Reclock("ZZ0",lInclui)
			ZZ0->ZZ0_FILIAL := xFilial("ZZ0")
			ZZ0->ZZ0_PEDIDO := SC5->C5_NUM
			ZZ0->ZZ0_NROCOL := cColeta
			ZZ0->ZZ0_NFISCA := SC5->C5_NOTA
			ZZ0->ZZ0_REDESP := SC5->C5_REDESP
			ZZ0->ZZ0_CLIENT := SC5->C5_CLIENTE
			ZZ0->ZZ0_BORDER := Posicione("SZB", 2, xFilial("SZB")+'01'+SC5->C5_NUM, "ZB_CODIGO")
			ZZ0->ZZ0_DTBORD := Posicione("SZA", 1, xFilial("SZA")+ZZ0->ZZ0_BORDER, "ZA_DTDESPA")				
		MsUnlock()
	endif 		
	dbselectarea("SC5")
	dbSkip()  
ENDIF
return