#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBRFIN001  บAutor  ณ                    บ Data ณ  15/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo de juros a receber de clientes que pagaram em car- บฑฑ
ฑฑบ          ณ torio                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRFIN001()
     Private cPerg

cPerg   := "FIN001"
VldPerg()            // Verifica as perguntas selecionadas 
Pergunte(cPerg,.f.)  // Pergunta no SX1

@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Boleto de Juros"

@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa({|lEnd| BRFI001()})
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,16 SAY "Serใo Gerados os Boletos de Juros"
@ 33,16 SAY "para os Clientes que pagaram tํtulos"
@ 43,16 SAY "em Cart๓rio!      "
@ 8,10 TO 84,222
ACTIVATE DIALOG oDlg1

Return            

STATIC Function BRFI001()
Local cQuery,cCliente,cDupl,nValor,cLote,aVetor,cNum,cLoja,nJuros,nVlrRef,aTitulos,i,dVencto
LOCAL aTam := {}
if mv_par01 <= 0   
	MsgBox("Valor Mํnimo Zerado!", "Aten็ใo!", "STOP")
	return
endif 
if mv_par02 <= 0
	MsgBox("Juros Zerados!", "Aten็ใo!", "STOP")
	return
endif 
if empty(mv_par04)
	MsgBox("Preencha o Vencimento!", "Aten็ใo!", "STOP")
	return
endif 

aTam := TamSX3("E1_NUM") // Tamanho do campo E1_NUM
	

nVlrRef := mv_par01
nJuros := mv_par02

dbSelectArea("SX6")
GetMv("MV_NTITJUR")
RecLock("SX6",.F.)

cQuery := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_LOJA, E1_CLIENTE, "
cQuery += " E1_NOMCLI, E1_VENCREA, E1_BAIXA, E1_VALOR, E1_SALDO "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND "
cQuery += " (LEN(E1_PGJURO) = 0) AND "
cQuery += " (E1_NATUREZ = '802024') AND (E1_BAIXA >= '"+dtos(mv_par03)+"') AND "
cQuery += " (D_E_L_E_T_ <> '*') "+iif(!empty(mv_par05)," AND (E1_CLIENTE = '"+mv_par05+"') ","")
cQuery += " ORDER BY E1_CLIENTE, E1_BAIXA "
//TCQuery Abre uma workarea com o resultado da query
TCQUERY cQuery NEW ALIAS "TMP"

cQuery := "SELECT MAX(E1_PGJURO) AS NUM FROM "+RetSqlName("SE1")+" WHERE (E1_FILIAL = '"+xFilial("SE1")+;
"') AND (E1_PREFIXO = 'JUR') AND (D_E_L_E_T_ <> '*')"
TCQUERY cQuery NEW ALIAS "TMPLOTE"
dbselectarea("TMPLOTE")  
dbgotop()
cLote := iif(eof() .or. bof(),"000001",strzero(val(tmplote->num)+1,6))
dbclosearea("TMPLOTE")

cQuery := "SELECT MAX(E1_NUM) AS NUM FROM "+RetSqlName("SE1")+" WHERE (E1_FILIAL = '"+xFilial("SE1")+;
"') AND (E1_PREFIXO = 'JUR') AND (D_E_L_E_T_ <> '*')"
TCQUERY cQuery NEW ALIAS "TMPLOTE"
dbselectarea("TMPLOTE")  
dbgotop()
cNum := iif(eof() .or. bof(),"000001",strzero(val(tmplote->num)+1,6))
dbclosearea("TMPLOTE")

dbselectarea("SE1")
dbsetorder(1)

dbselectarea("TMP")
dbgotop()
ProcRegua(300)
IncProc()
DO WHILE ! eof()
  	cCliente := TMP->E1_CLIENTE 
  	cLoja := TMP->E1_LOJA
  	cDupl    := "Tํtulos: "
  	nValor   := 0
  	aTitulos := {}
	While ! eof() .and. (TMP->E1_CLIENTE = cCliente)
      	nJuro  := fCalcJuros(CTOD(SUBSTR(TMP->E1_BAIXA,7,2)+"/"+SUBSTR(TMP->E1_BAIXA,5,2)+"/"+SUBSTR(TMP->E1_BAIXA,3,2)) - CTOD(SUBSTR(TMP->E1_VENCREA,7,2)+"/"+SUBSTR(TMP->E1_VENCREA,5,2)+"/"+SUBSTR(TMP->E1_VENCREA,3,2)),nJuros)
  		nValor := nValor + (TMP->E1_VALOR * nJuro)   
	  	cDupl += ALLTRIM(TMP->E1_PREFIXO)+ALLTRIM(TMP->E1_NUM)+ALLTRIM(TMP->E1_PARCELA)+"/"
	  	aadd(aTitulos,TMP->E1_CLIENTE+TMP->E1_LOJA+TMP->E1_PREFIXO+PADR(TMP->E1_NUM,aTam[1])+TMP->E1_PARCELA+TMP->E1_TIPO)
	  	dbSelectArea("TMP")
		DbSkip()
  	Enddo
  	If nValor > nVlrRef   
  		for i := 1 to len(aTitulos)
	  		dbselectarea("SE1")
  			dbsetorder(2)
  			dbseek(xFilial("SE1")+aTitulos[i])
  			if found()
  				reclock("SE1",.F.)
  				SE1->E1_PGJURO := cLote
  				msunlock()
  			endif
  		next 
    	// Cria titulo dos juros

		aVetor  := { {"E1_PREFIXO" ,"JUR",Nil},;
	    {"E1_NUM"    ,cNum         ,Nil},;
	    {"E1_PARCELA" ," "             ,Nil},;
	    {"E1_TIPO"    ,"DP "            ,Nil},;
	    {"E1_NATUREZ" ,"802025"      ,Nil},;
	    {"E1_CLIENTE" ,cCliente        ,Nil},;
	    {"E1_LOJA"    ,cLoja            ,Nil},;
	    {"E1_EMISSAO" ,dDataBase       ,Nil},;
	    {"E1_VENCTO" ,mv_par04       ,Nil},;
	    {"E1_PGJURO" ,cLote       ,Nil},;
	    {"E1_PORTADO" ,"001"       ,Nil},;
	    {"E1_HIST" ,cDupl       ,Nil},;
	    {"E1_VEND1" ,""       ,Nil},;
	    {"E1_VALOR" ,nValor             ,Nil }}
 
     	lMsErroAuto := .f.
      	lMsHelpAuto := .f.
		MsgRun("Incluindo boletos...", "Aguarde", {|| MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) } )
  		If lMsErroAuto
    		MostraErro()
    		exit
      	Endif

    	cNum := StrZero(val(cNum)+1,6)	
	Endif			
   	dbSelectArea("TMP")
Enddo	              
dbselectarea("TMP")
dbclosearea()

dbSelectArea("SX6")
msunlock()
return



//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//
// Funcao...: VldPerg                                             //
// Descricao: Verifica as perguntas, incluindo-as caso nao existam//       
//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//

Static Function VldPerg() 
lOCAL _sAlias,aRegs,i,j,lInclui
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01     // Mes Inicial                             //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Vlr Minimo Boleto","","","mv_ch1","N",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Juros(%) ","","","mv_ch2","N",6,2,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Baixado เ partir de ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs,{cPerg,"04","Vencimento ","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})
aAdd(aRegs, {cPerg, "05", "Apenas o Cliente?", "", "", "mv_ch5", "C", 6, 0, 0, "G", "", "mv_par05", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1", ""})

For i:=1 to Len(aRegs) 
	lInclui = !dbSeek(cPerg+aRegs[i,2])
     RecLock("SX1",lInclui)
     For j:=1 to FCount()
        If j <= Len(aRegs[i])
          FieldPut(j,aRegs[i,j])
        Endif
     Next
     MsUnlock()
Next
dbSelectArea(_sAlias)
Return

/////////////////////////////////             
// Calculo do percentual de    //
// juros                       //
/////////////////////////////////
Static Function fCalcJuros(nDias,nJuros)
local nJuro,nRet

nJuro := 1 + (nJuros/100)
nRet  := exp(((nDias*12)/365)*log(nJuro)) - 1

return(nRet)