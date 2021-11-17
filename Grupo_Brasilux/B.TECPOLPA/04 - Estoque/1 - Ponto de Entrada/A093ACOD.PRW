#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
/*----------------------------------------------------+
|Programa: PE para validar preenchimento do campo	  | 
|			CÛdigo do produto	  					  |
|Autor   : Igor Manrique							  |
|Data    : 05/01/2016								  |
+----------------------------------------------------*/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function A093ACOD()
     Local cCodPrd := ALLTRIM(PARAMIXB[1])
     //Local cDesPrd := PARAMIXB[2]
     //Local aCod    := PARAMIXB[3]
     //Local aCodGrd := PARAMIXB[4]
     //Local lGera   := PARAMIXB[5]
     Local aArea   := GetArea()
     Local cNewCod := ""      
     Local cRetCod := "" 
     Local cAuxCod := alltrim(Substr(cCodPrd,3,10))         

     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
     
        IF Select("TMPQUERY") != 0
        	 TMPQUERY->(DbCLoseArea())
        ENDIF
        
        If Substr(cCodPrd,1,2) == 'BL'
           
           //Cleber(19/12/19) -> Corrigindo query, erro de grupamento
           cQuery1 := "SELECT MAX(B1_COD) CODIGO FROM "+RetSqlName("SB1") 
           cQuery1 += " WHERE (B1_FILIAL = '"+xFilial("SB1")+"') AND (SUBSTRING(B1_COD,1,10) = '"+cAuxCod+"') AND (D_E_L_E_T_ <> '*') " 
           cQuery1 += "AND (SUBSTRING(B1_DESC,1,5) = 'BLEND') " 
	    Else
           cQuery1 := "SELECT MAX(B1_COD) CODIGO  FROM "+RetSqlName ("SB1") 
           cQuery1 += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND (SUBSTRING(B1_COD,1,10) = '"+cAuxCod+"') AND (D_E_L_E_T_ <> '*') " 
           If (Substr(cCodPrd,1,2) == 'PI') .OR. (Substr(cCodPrd,1,2) == 'TI') 
              cQuery1 += "AND (SUBSTRING(B1_COD,11,1) <> 'B')" 
           Endif
        Endif
        TCQUERY cQuery1 ALIAS TMPQUERY NEW
        dbSelectArea("TMPQUERY")
        
/*
        If TMPQUERY->(EOF())
		   //LGS#20191227 - Adequação de função para release 12.1.25 e posteriores
           //ConOut("A Query nao retorou dados")
		   FwLogMSG( "WARN", , 'SIGAEST', funname(), '', '01', "A Query nao retorou dados.", 0 )
        Else
           //Cleber(19/12/19)
           cRetCod := ALLTRIM(TMPQUERY->CODIGO)
        Endif
*/

		if !TMPQUERY->(EOF())
			//Cleber(19/12/19)
			cRetCod := ALLTRIM(TMPQUERY->CODIGO)
		endif

        TMPQUERY->(DbCLoseArea()) 
        
        dbSelectArea(aArea)

        //If Substr(cRetCod,11,2) <> '00000' .OR.  Substr(cRetCod,11,2)<> ' '//ajustes cÛdigo do Blend - Igor Manrique/Chaus 
        if !(Substr(cRetCod,11,2) == "00")   // (Cleber 04/02/20)Correção
           If Substr(cCodPrd,1,2) == 'BL'
              If Len(cRetCod) < 12 .OR. empty(cRetCod)
                 cNewCod := cAuxCod + PADL(((cValToChar(Val(Substr(cRetCod,11,2))+1))),12-len(cAuxCod),"B")
              Else
                 cNewCod := Soma1(cRetCod,12)
              Endif
              If Substr(cNewCod,11,2) = 'BZ'
                 ALERT("Na foi possivel incluir produto. Limite de codigo atingido!")
                 Return
              Endif
           Else
              cNewCod := cAuxCod + PADL(((cValToChar(Val(Substr(cRetCod,11,2))+1))),12-len(cAuxCod),"0")
              If Substr(cRetCod,11,2) >= '99'
                 cNewCod := Soma1(cRetCod,12)
              endif
           Endif
        Else 
           ALERT("Nao foi possivel incluir produto, existe produto com final 00! Verifique o codigo!") //Cleber (04/02/20), ajustada a mensagem pra melhor entendimento
        EndIf 
        
        if len(cNewCod) > 12
        	ALERT("ATENÇÃO! Algo saiu errado, código de retorno está com mais de 12 dígitos!!")
        endif 
        
        RestArea(aArea)
     Endif
Return (cNewCod)
