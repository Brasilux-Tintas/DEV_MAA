#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TCFAT001  ºAutor ³ Cleber Orati       º Data ³  05/08/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para importar pedidos de clientes Coca Cola via     º±±
±±º          ³ planilha                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TECPOLPA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TCFAT001()
Local _cGrpEmp
Private cPerg, MV_PAR01
_cGrpEmp := alltrim(FWGrpCompany())
if _cGrpEmp != "11"
	MsgBox("Esta operação só pode ser executada na empresa TECPOLPA!", "Atenção!", "STOP")
	return
endif
cPerg := PADR("TCFAT001",10," ")
VldPerg()             // Verifica as perguntas selecionadas
Pergunte(cPerg, .F.)  // Pergunta no SX1
//mv_par01 := getmv("MV_DIRBREP") //"\\10.1.1.146\brasilux\Cast\DATA\entrada\"
if empty(MV_PAR01)
	MV_PAR01 := "C:\TEMP\"
	Pergunte(cPerg, .F.)  // Pergunta no SX1
endif
@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Importar Pedidos Coca Cola"

@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_TCFT001(1)} )
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,016 SAY "Importacao de pedidos planilha Coca Cola."
@ 08,10 TO 84,222
ACTIVATE DIALOG oDlg1 CENTERED
Return

User Function TCFT001(_nOpc)
Local aArqs, i, cArqs, nQtdeArqs,  cUf,ni,aPlan,lSucesso
Local aPed, aPedRel, nQtdeItens, aItensPed,aAux, cCaminho, lErro, cTab,;
cAuxPed,nCont,cCondPag,nVlrUnit,_cLocal,;
cAuxRef,aCampos := {} ,cArqBloq,_cAreaBloq,cProd,nQtde,nRet,cTransp,dEntrega
Private lMsErroAuto
Private lMsHelpAuto := .f.
if _nOpc == 2 //Cleber(05/08/21) ->Caso for implementar Schedule, implantar parâmetro com pasta onde serão salvas as planilhas!
	private MV_PAR01
	MV_PAR01 := getmv("MV_DIRBREP") //"\\10.1.1.146\brasilux\Cast\DATA\entrada\"
	if empty(MV_PAR01)
		MV_PAR01 := "\\10.1.1.208\brasilux\BRASREPRES\"
	endif
endif
lErro := .f.
lSucesso := .t.
// Verificar se tem alguém usando a rotina



cArqBloq := "FT01"+ALLTRIM(cNumEmp)+".DTC"
if file(cArqBloq)
	fErase(cArqBloq)
Endif
_cAreaBloq := U_NovoCursor()
if file(cArqBloq)
	Use (cArqBloq) Alias (_cAreaBloq) VIA "CTREECDX" New
	dbselectarea(_cAreaBloq)
	if !eof() .and. !bof()
		cAux := "O programa já está sendo usado por: "+(_cAreaBloq)->usuario
		if _nOpc == 1
			MsgBox(cAux, "Atenção!", "STOP")
		else
			FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
		endif
		dbclosearea()
		return
	endif
endif

aCampos := { {"USUARIO"    ,"C",20,0} }

dbcreate(cArqBloq, aCampos, "CTREECDX")
Use (cArqBloq) Alias (_cAreaBloq) VIA "CTREECDX" New
dbselectarea(_cAreaBloq)
reclock(_cAreaBloq,.t.)
(_cAreaBloq)->usuario := iif(_nOpc == 1,rtrim(cUserName),"AGENDAMENTO")
msunlock()

DbSelectarea("SA3")
DbSetOrder(1)
DbSelectArea("SA1")
DbSetOrder(1)
DbSelectArea("SC5")   
dbsetorder(1) 
dbseek(xFilial("SC5"))
dbselectarea("SC6")   
dbsetorder(1)
dbseek(xFilial("SC6"))

	
	aArqs    := {}
	cCaminho := alltrim(MV_PAR01)
	If !empty(cCaminho)
		cCaminho += Iif(SubStr(cCaminho, Len(cCaminho), 1) != "\","\","")
	Endif
	cArqs := cCaminho+"*.xlsx" 
	
	nQtdeArqs = aDir(cArqs, aArqs)
	For i := 1 to nQtdeArqs
//***************************************
		aPlan := {}
		aPlan := u_xlsxToArr(cCaminho+aArqs[i],,";")
		nCont := 0
		cPed := ""
		lIncluiped := .f.
		cErros := ""
		aPed       := {}
		aItensPed  := {} 
		for ni := 2 to len(aPlan)
			if !(cPed == alltrim(aPlan[ni,1]))
				nCont := 0
				if len(aPed) > 0
					lIncluiped := .t.
				endif 
			endif 
			if (ni == len(aPlan)) 
				lIncluiped := .t.
			endif 

			if lIncluiped
				lIncluiped := .f.
				cAuxPed := iif(!empty(cPed),cPed,alltrim(aPlan[ni,1]))
				dbselectarea("SC6")
				dbsetorder(11) //C6_FILIAL+C6_CLI+C6_LOJA+C6_PEDCLI                                                                                                                              
				MsSeek(xFilial("SC6")+cCliente+cLoja+cAuxPed)
				if !found() //Só incluir se o pedido não existir no cadastro
					aAux := aItensPed
					lMsErroAuto := .f.
					lMsHelpAuto := .f.
					dbselectarea("SC6")
					dbsetorder(1)
					MsSeek(xFilial("SC6"))
					DbSelectArea("SC5")   
					if _nOpc == 1
						MsgRun("Incluindo pedido"+cAuxPed+"...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aPed, aAux, 3 ) } )
					else 
						MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aPed, aAux, 3 )
					endif 
					If lMsErroAuto
						cAux := "Nao foi possí­vel incluir pedido "+cAuxPed+" da planilha :"+cCaminho+aArqs[i]
						if _nOpc == 1
							MsgAlert(cAux)
							MostraErro()
						else
							FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
						endif
					endif
					lSucesso := !lMsErroAuto
					lErro    := !lSucesso
					if !lSucesso	
						exit 
					endif 
				endif 
			endif

			if empty(alltrim(aPlan[ni,1]))
				exit 
			endif 
			nCont++ 
			if nCont == 1
				cCliente := padl(alltrim(aPlan[ni,3]),6,"0")
				cLoja := padl(alltrim(aPlan[ni,4]),2,"0")
				DbSelectArea("SA1")
				DbSetOrder(1)
				MsSeek(xFilial("SA1")+cCliente+cLoja,.t.)
				if !found()
					lSucesso = .f.
					cAux := "Não encontrado no cad. o cliente "+cCliente+"-"+cLoja
					if _nOpc == 1
						MsgAlert(cAux)
					else
						FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
					endif 				
				endif 
				IF !lSucesso
					exit 
				ENDIF
				cTransp := alltrim(aPlan[ni,11])
				if !empty(cTransp)
					cTransp := padl(cTransp,6,"0")
					dbselectarea("SA4")
					dbsetorder(1)
					MsSeek(xFilial("SA4")+cTransp)
					if !found()
						cTransp := ""
					endif 
				endif 

				dEntrega := alltrim(aPlan[ni,14])
				if !empty(dEntrega) .and. (type(dEntrega) = "N")
					nPos1 := at("/",dEntrega,1)
					nPos2 := at("/",dEntrega,nPos1+1)
					dEntrega := substr(dEntrega,nPos1+1,nPos2-nPos1)+substr(dEntrega,1,nPos1)+substr(dEntrega,nPos2+1,len(dEntrega)-nPos2)
					//substr(dEntrega,1,at("/",dEntrega,1)-1)
				endif 
				if !empty(dEntrega)
					dEntrega := ctod(dEntrega)
				else 
					dEntrega := ""
				endif 
				cTab := ALLTRIM(SA1->A1_TABELA)
				if empty(cTab)
					cTab := "CC1"
				endif 
				cUf := ALLTRIM(SA1->A1_EST)
				do case 
				case cUf == "SP"
					cTab := "CC1"
				case cUf == "MG"
					cTab := "CC2"
				case cUf $ "RN-AC-AL-BA-CE-DF-ES-GO-MA-MS"
					cTab := "CC3"
				case cUf == "RR"
					cTab := "CC4"
				case cUf == "AM"
					cTab := "CC5"
				case cUf == "AP"
					cTab := "CC6"
				endcase 
				dbselectarea("DA0")
				dbsetorder(1)
				MsSeek(xFilial("DA0")+cTab,.t.)
				if !found()
					lSucesso = .f.
					cAux := "Não encontrada no cad. a tabela "+cTab
					if _nOpc == 1
						MsgAlert(cAux)
					else
						FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
					endif 				
				endif 
				IF !lSucesso
					exit 
				ENDIF
				cCondPag := "P30"
				IF !empty(ALLTRIM(DA0->DA0_CONDPG))
					cCondPag := ALLTRIM(DA0->DA0_CONDPG)
				ENDIF
				dbselectarea("DA1")
				dbsetorder(1) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM                                                                                                            
 
				aPed       := {}
				aItensPed  := {} 
				aAdd(aPed, {"C5_TIPO"    , "N"               , nil})
     			aAdd(aPed, {"C5_CLIENTE" , cCliente          , nil})
     			aAdd(aPed, {"C5_LOJACLI" , cLoja             , nil})
     			aAdd(aPed, {"C5_LOJAENT" , cLoja             , nil})
     			aAdd(aPed, {"C5_CONDPAG" , cCondPag          , nil})
     			aAdd(aPed, {"C5_EMISSAO" , dDataBase         , nil})
     			aAdd(aPed, {"C5_TABELA"  , cTab         	 , nil})
				if !empty(cTransp)
     				aAdd(aPed, {"C5_TRANSP"  , cTransp             , .F.}) //VLR .F.
				endif 
				if !empty(dEntrega)
     				aAdd(aPed, {"C5_FECENT"  , dEntrega            , .F.}) //VLR .F.
				endif 
     			//aAdd(aPed, {"C5_REDESP"  , ""             , .F.}) //VLR .F.
     			aAdd(aPed, {"C5_TPFRETE" , "F"                               , nil})       
     			aAdd(aPed, {"C5_RASTR" ,alltrim(aPlan[ni,1])  , nil})       
     			//aAdd(aPed, {"C5_DEPOSI"  , "N"                               , nil})       
     			//aAdd(aPed, {"C5_OBSNF"   , cObs, nil})
		 		nQtdeItens := 0
			endif 
			
			cProd := PADR(alltrim(aPlan[ni,6]),TamSX3("B1_COD")[1]," ")
 			nQtde := val(u_SoDig(aPlan[ni,8]))
		    nVlrUnit := 0
			dbselectarea("DA1")
			MsSeek(xFilial("DA1")+DA0->DA0_CODTAB+cProd) //+DA1_INDLOT+DA1_ITEM
			if !found()
				lSucesso = .f.
				cAux := "Não encontrado o produto "+cProd+" na tabela de preços "+DA0->DA0_CODTAB+", pedido "+aPlan[ni,1]
				if _nOpc == 1
					MsgAlert(cAux)
				else
					FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
				endif 				
			endif 
			IF !lSucesso
				exit 
			ENDIF
			nVlrUnit := DA1->DA1_PRCVEN 
    		nQtdeItens++ 
    		aPedRel := {}     
   			_cItem = Alltrim(Str(nQtdeItens))
			If nQtdeItens < 100
				_cItem := Alltrim(Str(nQtdeItens))
				If Len(_cItem) == 1
					_cItem = "0"+_cItem
				Endif
			Else
				_cItem := Alltrim(Str(nQtdeItens))
				_cItem := SubStr(_cItem, Len(_cItem), 1)
				_cItem := Chr(Int((nQtdeItens - 100)/10)+65) + _cItem
			Endif  
			dbselectarea("SB1")
			dbsetorder(1)
			MsSeek(xFilial("SB1")+cProd)
			if !found()
				lSucesso = .f.
				cAux := "Não encontrado o produto "+cProd+" no cadastro "
				if _nOpc == 1
					MsgAlert(cAux)
				else
					FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
				endif 				
			endif 
			 _cLocal := ""
			if !empty(alltrim(SB1->B1_LOCPAD))
				_cLocal := SB1->B1_LOCPAD
				dbselectarea("SB2")
				dbsetorder(1)
				MsSeek(xFilial("SB2")+cProd+_cLocal)
				if !found()
					CriaSb2(cProd,_cLocal)
				endif  
			endif 
			aAdd(aPedRel, {"C6_ITEM"   , _cItem     , nil})
			aadd(aPedRel, {"C6_PRODUTO", cProd     , nil})
			if !empty(_cLocal)
				aadd(aPedRel, {"C6_LOCAL", _cLocal     , nil})
			endif 
			aadd(aPedRel, {"C6_QTDVEN" , nQtde, nil})
			aadd(aPedRel, {"C6_PRCVEN" , nVlrUnit , nil})
			aadd(aPedRel, {"C6_OPER" , "SV" , nil})
			aadd(aPedRel, {"C6_PEDCLI" ,ALLTRIM(aPlan[ni,1]) , nil})
			//aadd(aPedRel, {"C6_TES"    , "824", nil})
			aadd(aItensPed, aPedRel)       


			cPed := alltrim(aPlan[ni,1])
		next ni 

//******************
		If lSucesso
			//cAux = cCaminho+aArqs[i]
			//Delete File &cAux
 			// Mover arquivo para pasta de backup
			cAuxRef := cCaminho+"lidos"
			if !ExistDir( cAuxRef )
				nRet := MakeDir( cAuxRef )
				if nRet != 0
					cAux := "Não foi possível criar o diretório "+cAuxRef
					if _nOpc == 1
						MsgAlert(cAux)
					else
						FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
					endif 	
					cAuxRef := ""			
				endif 
			endif 
			if !empty(cAuxRef)
				cAuxRef += "\"
				nRet := frename(cCaminho+aArqs[i],cAuxRef+aArqs[i])
				IF nRet == -1
					cAux := "Não foi possível transf o arquivo "+cCaminho+aArqs[i]+" para a pasta "+cAuxRef+chr(13)+chr(10)+;
					"Código do erro: "+STR(FERROR())
					if _nOpc == 1
						MsgAlert(cAux)
					else
						FWLogMsg("INFO", "LAST", cPerg, ,  , , cAux, 0,0)		
					endif 	
				Endif
			endif 

		Endif
	Next i


dbselectarea(_cAreaBloq)
dbclosearea()
ferase(cArqBloq)
If lErro
	cAux = "Processo Finalizado. Houveram Erros!"
Else
	cAux = "Processo Finalizado!"
Endif
if _nOpc == 1
	MsgBox(cAux, "Aviso", "INFO")
	Close(oDlg1)
else
	ConOut(cAux)
endif

return

//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//
// Funcao...: VldPerg                                             //
// Descricao: Verifica as perguntas, incluindo-as caso nao existam//
//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//

Static Function VldPerg()
Local _sAlias := Alias()

//+---------------------------------------------+
//Â¦ Variaveis utilizadas para parametros        Â¦
//Â¦ mv_par01             // Origem dos Arqs     Â¦
//+---------------------------------------------+

u_xPutSx1(cPerg,"01","Local dos Arquivos", "Local dos Arquivos", "Local dos Arquivos", "mv_ch1", "C",  50, 0, 0, "G", " ", "", " ", " ", "MV_PAR01", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)

if !empty(_sAlias)
	DbSelectArea(_sAlias)
endif
//************
/*
Local aCabExcel :={}
Local aItensExcel :={}
// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
AADD(aCabExcel, {"A1_FILIAL" ,"C", 02, 0})
AADD(aCabExcel, {"A1_COD" ,"C", 06, 0})
AADD(aCabExcel, {"A1_LOJA" ,"C", 02, 0})
AADD(aCabExcel, {"A1_NOME" ,"C", 40, 0})
AADD(aCabExcel, {"A1_MCOMPRA" ,"N", 18, 2})
MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
{|| GProcItens(aCabExcel, @aItensExcel)})
MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
{||DlgToExcel({{"GETDADOS",;
"POSIÇÃO DE TÍTULOS DE VENDOR NO PERÍODO",;
aCabExcel,aItensExcel}})})
*/
//*********** 

Return
