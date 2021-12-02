#Include "RWMAKE.CH"

User function validusr()
Local y
Private cNomAnt, cTipAnt, nValAnt
Private cAlias    := "SZW"
Private aRotina   := {}
Private lRefresh  := .T.
Private cCadastro := "Transferencia de acesso"
PRIVATE cPerg   :="validusr"
Private x := 1 
PRIVATE aAux := {}
     u_zcfga01( 'VALIDUSR' ) //LGS#2021202 - Gravação de log de utilização da rotina
//CriaSX1(cPerg)  //LGS#20200207 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.T.)
  
DbSelectArea("SZW")
DbSetOrder(1)                    
dbSeek(xFilial("SZW") + MV_PAR02 )  
	while !EOF() .AND. (MV_PAR02 == SZW->ZW_USUARIO) 
		RecLock("SZW", .F.)
		dbDelete()
		MSUnLock()
		dbSelectArea("SZW")
		dbSkip()  
	enddo
DbSelectArea("SZW")
DbSetOrder(1)
dbSeek(xFilial("SZW") + MV_PAR01 )

while !EOF() .AND. (MV_PAR01 == SZW->ZW_USUARIO) .AND. SZW->ZW_FILIAL = xFilial("SZW")
	aadd(aAux, {   SZW->ZW_FILIAL,;
					SZW->ZW_ACESSOS,; 
					SZW->ZW_EMPFIL,;
					SZW->ZW_DTINCLU,;
					SZW->ZW_ATIVO,;
					SZW->ZW_ROTINA,;
					SZW->ZW_LOGICO,;
					SZW->ZW_DEPTO,;
					SZW->ZW_USERINC,;
					SZW->ZW_USERALT})
    dbSelectArea("SZW")
    dbSkip()  		
enddo

DbSelectArea("SZW")

For y := 1 To len(aAux)
	RecLock("SZW", .T.)
	SZW->ZW_USUARIO  := MV_PAR02
	SZW->ZW_FILIAL   :=	aAux[y][1]
	SZW->ZW_ACESSOS  :=	aAux[y][2] 
	SZW->ZW_EMPFIL   :=	aAux[y][3]   
	SZW->ZW_DTINCLU  :=	aAux[y][4] 
	SZW->ZW_ATIVO    :=	aAux[y][5] 
	SZW->ZW_ROTINA   :=	aAux[y][6] 
	SZW->ZW_LOGICO   :=	aAux[y][7] 
	SZW->ZW_DEPTO    :=	aAux[y][8] 
	SZW->ZW_USERINC  :=	aAux[y][9] 
	SZW->ZW_USERALT  :=	aAux[y][10]	
	MSUnLock()	
next
Return

//----------------------------------------------------------------------------//
//LGS#20200207 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
      	PutSX1(cPerg, "01","De usuario" ,"","","mv_ch1","C",6,0,0,"G","","SZH","","","MV_PAR01","","","","","","","","","","","","","","","","",NIL,NIL,NIL,"")
	   	PutSX1(cPerg, "02","Para usuario" ,"","","mv_ch2","C",6,0,0,"G","","SZH","","","MV_PAR02","","","","","","","","","","","","","","","","",NIL,NIL,NIL,"")
	   
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return*/
