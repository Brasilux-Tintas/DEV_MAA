#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRPCPA12³ Autor ³ Luís Gustavo de Souza ³ Data ³ 07/02/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera conteúdo do parâmetro MV_ESTNEG                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRPCPA12
     Local cArqBloq := ""
     Local _cAreaBloq,cAux
     Local lBloqueou := .f.
     Local aBloq := {}
     Private cGet1Est 	:= alltrim(GETMV("MV_ESTNEG"))
     Private cRotUsu   	:= "BRPCPA12"

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1", "oSay1", "oGet1", "oBtn1", "oBtn2")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     If (cGet1Est $ 'N') .and. !Empty(GETMV("MV_BXMANEW"))
       		MsgStop("Atenção existem baixas de ordens de produção processando. O parâmetro não poderá ser alterado agora. Aguarde!!")
        	Return
     Endif
     
     //cArqBloq := "SCHP"+Substr(ALLTRIM(CNumEmp),3,6)+".DTC"
     cArqBloq := "BRPCPA12"+Substr(ALLTRIM(CNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
     if aBloq[1,1] //Já estava bloqueado?
     	cAux := "O programa de baixa de ops já está sendo executado !! Aguarde !! -> "+aBloq[1,2]
		Messagebox(cAux,"Atenção...",64) 			
		PutMv("MV_ESTNEG", cGet1Est)
		return
	endif 
	_cAreaBloq := aBloq[1,4] //Cleber (13/02/20)  -> Reajuste da função  BloqProg
	lBloqueou := .t.

     oFont1     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 091, 232, 184, 508, "Altera MV_ESTNEG", , , .F., , , , , , .T., , , .T. )
     oSay1      := TSay():New( 004, 004, {||"MV_ESTNEG:"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
     oGet1Est   := TGet():New( 002, 067, {|u| If(PCount() > 0, cGet1Est := u, cGet1Est)}, oDlg1, 029, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .T., .F., , .T., .F., "", "cGet1Est", , )
     //oBtn1      := TButton():New( 024, 004, "Altera", oDlg1, { || PutMV("MV_ESTNEG" , Iif(cGet1Est $ 'S', 'N', 'S')) .AND. Iif(cGet1Est $ 'N', PutMv("MV_BXMANEW", "N"+"|"+Alltrim(cUserName)+"|"+Time()+"|"+Dtoc(MsDate())), PutMv("MV_BXMANEW", ""))  , oDlg1:End()}, 037, 012, , , , .T., , "", , , , .F. )
     oBtn1      := TButton():New( 024, 004, "Altera", oDlg1, { || PutMV("MV_ESTNEG" , Iif(cGet1Est $ 'S', 'N', 'S'))  , oDlg1:End()}, 037, 012, , , , .T., , "", , , , .F. )
     
  	oDlg1:Activate(,,,.T.)      
  	
  	if lBloqueou
		DbSelectArea(_cAreaBloq)
		DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
		DbCloseArea()
		//FErase(cArqBloq)           
	endif 

Return
