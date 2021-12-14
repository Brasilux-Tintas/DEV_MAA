#include "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M460QRY  ºAutor  ³ Cleber O. Dominguesº Data ³  01/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtrar pedidos que pertençam a um determinado bordero na- º±±
±±º          ³ emissão das Notas Fiscais.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function M460QRY()
     Local _cRet := Paramixb[1]
     Local _cSzg, cQuery
     Local mvpar19, mvpar20
     //Local _cUserId := RetCodUsr()
     u_zcfga01( 'M460QRY' ) //LGS#2021214 - Gravação de log de utilização da rotina

	 If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).
        //_cRet := Paramixb[1] 
        /*if (ValType(mv_par20) = "N")
           mvpar19 := mv_par19
           mvpar20 := mv_par20  
           //Gravar SXK
           GravaXK(_cUserId,"MT461A","19")
           GravaXK(_cUserId,"MT461A","20")
        else 
           //Restaurar SXK
           mvpar19 := VerPergUs(_cUserId,"MT461A","17")	
           mvpar20 := VerPergUs(_cUserId,"MT461A","18")  
        endif */
        // Contornar problema de, em situações indeterminadas, o sistema volta a executar este 
        // ponto de entrada após a confirmação de outros parâmetros
        Pergunte("MT461A",.F.)
        if !empty(_cRet)
           _cRet += " AND "
        endif      
        _cRet += "(C9_APROVA = '"+iif(mv_par20 == 2,"9","1")+"')" // AND C9_PEDIDO NOT IN(SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE (C9_FILIAL = '"+;
        // xFilial("SC9")+"') AND (C9_PEDIDO BETWEEN '"+MV_PAR05+"' AND  '"+MV_PAR06+"') AND (D_E_L_E_T_ <> '*') AND (C9_OK <>''))" 
        If !Empty(mv_par19)
           _cSzg := RetSqlName("SZB") //Verifica qual arquivo SX2 aponta
           _cRet += " AND C9_PEDIDO IN(SELECT RIGHT(ZB_PEDIDO,6) FROM "+_cSzg+" WHERE (ZB_FILIAL = '"+;
	       xFilial("SZB")+"') AND (ZB_CODIGO = '"+mv_par19+"') AND (D_E_L_E_T_ <> '*'))"
        Endif      
     Endif
Return(_cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChkPergUs ³ Autor ³ Nereu Humberto Junior ³ Data ³21/09/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para buscar as perguntas que o usuario nao pode     ³±±
±±³          ³ alterar para impressao de relatorios direto do browse      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkPergUs(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Id do usuario                                     ³±±
±±³          ³ ExpC2 := Grupo de perguntas                                ³±±
±±³          ³ ExpC2 := Numero da sequencia da pergunta                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function VerPergUs(cUserId,cGrupo,cSeq)

Local aArea  := GetArea()
Local cRet   := Nil    
Local aCampos := {} 
Local cArq := "prm"+substr(cNumEmp,1,2)+"0"
Local _cArea,cKey   

_cArea := U_NovoCursor()
if !file(cArq+".dtc") 
	aCampos := {  {"IDUSER"    ,"C",7,0}, {"GRUPO"    ,"C",10,0},{"SEQ"    ,"C",2,0},{"CONTEUD"    ,"C",250,0}}
	dbcreate(cArq, aCampos, "CTREECDX")               
	Use (cArq) Alias (_cArea) VIA "CTREECDX" New  
 	cKey  := "IDUSER+GRUPO+SEQ"
  	DbCreateIndex(cArq+".cdx", cKey, {||cKey} )
   	DbClearIndex()  
ELSE
	Use (cArq) Alias (_cArea) VIA "CTREECDX" New  
ENDIF 
DbSetIndex(cArq)

	
dbselectarea("SX1")
dbsetorder(1)
if dbseek(padr(cGrupo,10)+cSeq)
	dbSelectArea(_cArea)
	If dbSeek(padr("U"+cUserId,7)+padr(cGrupo,10)+cSeq)
		If SX1->X1_TIPO = "C"
			cRet := AllTrim((_cArea)->CONTEUD)
		ElseIf SX1->X1_TIPO = "N"
			cRet := Val(AllTrim((_cArea)->CONTEUD))
		ElseIf SX1->X1_TIPO = "D"
			cRet := CTOD((AllTrim((_cArea)->CONTEUD)))
		Endif
	Endif
endif 
dbselectarea(_cArea)
dbclosearea()

RestArea(aArea)
Return(cRet)
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChkPergUs ³ Autor ³ Nereu Humberto Junior ³ Data ³21/09/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para buscar as perguntas que o usuario nao pode     ³±±
±±³          ³ alterar para impressao de relatorios direto do browse      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkPergUs(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Id do usuario                                     ³±±
±±³          ³ ExpC2 := Grupo de perguntas                                ³±±
±±³          ³ ExpC2 := Numero da sequencia da pergunta                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
Static Function GravaXK(cUserId,cGrupo,cSeq)

Local aArea  := GetArea()
Local cRet   := ""
Local cParam := "MV_PAR"+cSeq
Local cArq := "prm"+substr(cNumEmp,1,2)+"0"
Local _cArea,cKey   

if file (cArq+".dtc")
	_cArea := U_NovoCursor()
	Use (cArq) Alias (_cArea) VIA "CTREECDX" New  
	DbSetIndex(cArq)

	If ValType(&cParam) == "C"
		cRet := AllTrim(&cParam)
	ElseIf 	ValType(&cParam) == "N"
		cRet := AllTrim(str(&cParam))
	ElseIf 	ValType(&cParam) == "D"
		cRet := DTOC(&cParam)
	Endif              

	dbSelectArea(_cArea)

	If !dbSeek(padr("U"+cUserId,7)+padr(cGrupo,10)+cSeq)
		reclock(_cArea,.t.)     
		(_cArea)->GRUPO := cGrupo
		(_cArea)->SEQ := cSeq
		(_cArea)->IDUSER := "U"+cUserId
	else
		reclock(_cArea,.F.)
	Endif

	(_cArea)->CONTEUD := cRet
	dbSelectArea(_cArea)
	msunlock()
endif 
RestArea(aArea)
Return(cRet)
*/
