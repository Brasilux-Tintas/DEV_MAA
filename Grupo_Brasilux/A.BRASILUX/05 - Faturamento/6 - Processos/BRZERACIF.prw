#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function BRZERACIF()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _cPerg     := "BRZERACIF "
Private _oGeraTxt,MV_PAR01
MV_PAR01 := ""

if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
endif 

    u_zcfga01( 'BRZERACIF' ) //LGS#2021123 - Gravação de log de utilização da rotina    
//CriaSX1(_cPerg)
Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Zerar CIF de Pedido")
@ 02,10 TO 060,215
@ 10,018 Say "Zerar FRETE de Pedido CIF ESTORNANDO SUAS LIBERAÇÕES!!! " SIZE 196,0

@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkGeraTrb() }) 
@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered

Return
//-------------------------------------
Static Function OkGeraTrb
Local _cPed,nVlrUnit,nTam1
Local aCab2 := {},aItens2 := {},aAux := {},_cFilial
Local nDesc1,nDesc2,nDesc3,nDesc4
Private lMsErroAuto,lMsHelpAuto
 
_cPed := ALLTRIM(MV_PAR01)

if empty(_cPed)
	MsgAlert("Defina o número do Pedido!","Atenção!")
	return
endif 

	
dbselectarea("SC5")
dbsetorder(1)
dbseek(xFilial("SC5")+_cPed)
if !found()
	MsgAlert("Pedido "+_cPed+" INEXISTENTE!","Atenção!")
	return
endif 

if !(SC5->C5_TPFRETE = "C") .OR. (SC5->C5_XVLRFRE <= 0.0) .OR. (SC5->C5_TIPO <> "N") .OR. !(SC5->C5_APROVA = '1')
	MsgAlert("Pedido "+_cPed+" NÃO NECESSITA de ZERAR FRETE CIF OU NÃO É FRETE CIF!","Atenção!")
	return
endif

begin transaction

Reclock("SC5", .F.)
nDesc1 := SC5->C5_DESCON1
nDesc2 := SC5->C5_DESCON2
nDesc3 := SC5->C5_DESCON3
nDesc4 := SC5->C5_DESCON4

SC5->C5_APROVA := "0"
SC5->C5_DESCON1 := 0
SC5->C5_DESCON2 := 0
SC5->C5_DESCON3 := 0
SC5->C5_DESCON4 := 0
MsUnlock()
nTam1 := TamSX3("C6_PRCVEN")[2]
 	_cFilial := ALLTRIM(SC5->C5_FILIAL)
	//aCab2 := DetCampos("SC5")   
	aCab2 := U_DetCposTab("SC5","C5_NUM-C5_FILIAL")
	aItens2 := {} 
	dbselectarea("SC6")
	dbsetorder(1)  
	dbseek(xFilial("SC6")+_cPed,.t.)
	do while !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == _cFilial) .AND. (alltrim(SC6->C6_NUM) == _cPed)
		/*
		aAux := {}    
		aadd(aAux,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
		aadd(aAux,{"AUTDELETA","N",Nil})
		*/
		
		//Voltar vlr anterior
		nVlrUnit := SC6->C6_XVLRFRE //round(((SC6->C6_QTDVEN*SC6->C6_PRCVEN) - SC6->C6_XVLRFRE)/SC6->C6_QTDVEN,nTam1)

		aAux := U_DetCposTab("SC6","C6_PRCVEN-C6_PRUNIT-C6_XVLRFRE-C6_FILIAL-C6_ITEM-C6_NUM-C6_BLOQUEI-C6_BLQ-C6_GEROUPV-C6_QTDEMP-C6_QTDEMP2-C6_QTDENT-C6_QTDENT2-C6_QTDLIB-C6_QTDLIB2-C6_QTDRESE-C6_SLDALIB-C6_SUGENTR-C6_TRT")
		aadd(aAux,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
		aadd(aAux,{"AUTDELETA","N",Nil})
		aadd(aAux,{"C6_PRCVEN",nVlrUnit,Nil})		
		aadd(aAux,{"C6_PRUNIT",nVlrUnit,Nil})		
		aadd(aAux,{"C6_XVLRFRE",0.0,Nil})		
		aadd(aItens2,aAux)		
/*
		aadd(aAux,{"C6_PRODUTO",SC6->C6_PRODUTO,Nil})		
		aadd(aAux,{"C6_QTDVEN",SC6->C6_QTDVEN,Nil})		
		aadd(aAux,{"C6_PRCVEN",nVlrUnit,Nil})		
		aadd(aAux,{"C6_TES",SC6->C6_TES,Nil})		
		aadd(aAux,{"C6_XVLRFRE",0.0,Nil})		
		aadd(aItens2,aAux)		
*/
		dbselectarea("SC6")
		dbskip()
	enddo 
	aadd(aCab2,{"C5_NUM"   ,_cPed,Nil}) 
	 	
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
	MsgRun("Retirando aprovação...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab2, aItens2, 4 ) } )
	if lMsErroAuto
		MostraErro()
	endif 

	dbselectarea("SC5")
	Reclock("SC5", .F.)
	SC5->C5_DESCON1 := nDesc1
	SC5->C5_DESCON2 := nDesc2
	SC5->C5_DESCON3 := nDesc3
	SC5->C5_DESCON4 := nDesc4
	if lMsErroAuto
		SC5->C5_APROVA := "1"
	endif 
	MsUnlock()
end transaction
Return  

/*/
Programa  : CRIASX1   Autor:  
Data      : 10/10/18
Descricao : Grava Perguntas
/*/

/* DESABILITADO EM FUNÇÃO DE ADEQUAÇÃO PARA A RELEASE 12.1.25
Static Function CriaSX1(cPerg)

Local aHelp := {}

//            Texto do help em português                , inglês, espanhol
AAdd(aHelp, {{"Nro do Pedido"},  {"Nro do Pedido"}, {"Nro do Pedido"}})

xPutSX1(cPerg,"01",  "Pedido?"  ,"Pedido?","Pedido?","mv_ch1","C",6,00,00,"G","","SC5"   ,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)

Return

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lPort := .f. 
Local lSpa := .f. 
Local lIngl := .f. 

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
cF3      := Iif( cF3           == NIl, " ", cF3          ) 
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 

dbSelectArea( "SX1" ) 
dbSetOrder( 1 ) 

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
// RFC - 15/03/2007 
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

If !( DbSeek( cGrupo + cOrdem )) 

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     Reclock( "SX1" , .T. ) 

     Replace X1_GRUPO   With cGrupo 
     Replace X1_ORDEM   With cOrdem 
     Replace X1_PERGUNT With cPergunt 
     Replace X1_PERSPA With cPerSpa 
     Replace X1_PERENG With cPerEng 
     Replace X1_VARIAVL With cVar 
     Replace X1_TIPO    With cTipo 
     Replace X1_TAMANHO With nTamanho 
     Replace X1_DECIMAL With nDecimal 
     Replace X1_PRESEL With nPresel 
     Replace X1_GSC     With cGSC 
     Replace X1_VALID   With cValid 

     Replace X1_VAR01   With cVar01 

     Replace X1_F3      With cF3 
     Replace X1_GRPSXG With cGrpSxg 

     If Fieldpos("X1_PYME") > 0 
          If cPyme != Nil 
               Replace X1_PYME With cPyme 
          Endif 
     Endif 

     Replace X1_CNT01   With cCnt01 
     If cGSC == "C"               // Mult Escolha 
          Replace X1_DEF01   With cDef01 
          Replace X1_DEFSPA1 With cDefSpa1 
          Replace X1_DEFENG1 With cDefEng1 

          Replace X1_DEF02   With cDef02 
          Replace X1_DEFSPA2 With cDefSpa2 
          Replace X1_DEFENG2 With cDefEng2 

          Replace X1_DEF03   With cDef03 
          Replace X1_DEFSPA3 With cDefSpa3 
          Replace X1_DEFENG3 With cDefEng3 

          Replace X1_DEF04   With cDef04 
          Replace X1_DEFSPA4 With cDefSpa4 
          Replace X1_DEFENG4 With cDefEng4 

          Replace X1_DEF05   With cDef05 
          Replace X1_DEFSPA5 With cDefSpa5 
          Replace X1_DEFENG5 With cDefEng5 
     Endif 

     Replace X1_HELP With cHelp 

     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

     MsUnlock() 
Else 

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

   If lPort .Or. lSpa .Or. lIngl 
          RecLock("SX1",.F.) 
          If lPort 
        SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
          EndIf 
          If lSpa 
               SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
          EndIf 
          If lIngl 
               SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
          EndIf 
          SX1->(MsUnLock()) 
     EndIf 
Endif 

RestArea( aArea ) 

Return


Static Function DetCampos( cAlias )
Local aArea := GetArea()
Local aCampos := {},cAux,xValor
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( cAlias )
While !EOF() .And. X3_ARQUIVO = cAlias
	If X3Uso(X3_USADO) .AND. !(X3_CONTEXT = "V") .and. !(ALLTRIM(X3_CAMPO) == "C6_FILIAL") .and. !(ALLTRIM(X3_CAMPO) == "C5_NUM") .AND. !(ALLTRIM(X3_CAMPO) == "C5_FILIAL") 
		
		cAux := alltrim(cAlias)+"->"+X3_CAMPO
		xValor := &cAux
		if !empty(xValor)
			aadd(aCampos,{X3_CAMPO   ,xValor,.F.})		
		endif 
	Endif
	dbSelectArea("SX3")
	dbSkip()
End
RestArea(aArea)
Return(aCampos)

*/
