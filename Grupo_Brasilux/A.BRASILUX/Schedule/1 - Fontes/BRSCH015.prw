#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "topconn.ch"
 
User Function BRSCH015()
     Local cQuery,_cLote,_cDescri,_cLocOri,_cLocDest,cAux,_nSaldo
     //Local _cEstNeg := getmv("MV_ESTNEG")
     Local cArqBloq, aBloq,_cAreaBloq             
     Local cProd	:= ""
     Local _cUm	:= ""
     Local _cDoc	:= ""
     //Local dDatVal	:= ""   
     Local _nQuant	:= 0
     Local lOk	:= .T.
     Local _aItem	:= {} 
     Local _aAuto := {}
     Local nOpcAuto:= 3 // Indica qual tipo de ação será tomada (Inclusão/Exclusão)

     RPCSetType(3)  // Nao utilizar licenca

     PRIVATE lMsHelpAuto := .T.
     PRIVATE lMsErroAuto := .F.

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //| Abertura do ambiente                                         |
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     If Select("SX2") > 0
        lMenu:= .T.
     Else
        lMenu:= .F.
     Endif

     If !lMenu
        PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" MODULO "EST" TABLES "SD3","SB1","SD5","SB2","SB9","Z00"
     Endif

     /*
     cQuery := "SELECT TOP 5 * FROM Z00010 WHERE (D_E_L_E_T_ <> '*') AND (Z00_FILIAL = '01') AND (Z00_STATUS <> '1') ORDER BY Z00_DIA,Z00_LOTE,Z00_COD"
     TCQUERY cQuery NEW ALIAS "TMPTRAN" 
     */     

     
     
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 12/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     //cArqBloq := "SC15"+substr(cNumEmp,1,2)+xFilial("SD3")+".DBF"
     //_cEstNeg := ""
     //_cAreaBloq := U_NovoCursor()
     //aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })     
     //if file(cArqBloq)
     //   Use (cArqBloq) Alias (_cAreaBloq) VIA "DBFCDXADS" New 
     //   dbselectarea(_cAreaBloq)
     //   //recuperar MV_ESTNEG anterior, caso tenha ocorrido uma parada indevida
     //   _cEstNeg := iif(!eof() .and. !bof(),(_cAreaBloq)->estneg,"")
     //   dbclosearea()
     //   fErase(cArqBloq)
     //Endif              
     //if file(cArqBloq)
     //   Use (cArqBloq) Alias (_cAreaBloq) VIA "DBFCDXADS" New 
     //   dbselectarea(_cAreaBloq)
     //   if !eof() .and. !bof()              
     //      cAux := "O programa já está sendo usado por: "+(_cAreaBloq)->usuario
     //      //LGS#20200212 - Adequação de release 12.1.25 e posteriores
     //      //ConOut(cAux)
     //      FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', cAux, 0 )
     //      dbclosearea()
     //      return
     //   endif
     //endif
     /********************************************************************************************************************************/
     If !Empty(GETMV("MV_BXMANEW"))
        //LGS#20200212 - Adequação de release 12.1.25 e posteriores
        //ConOut("Atenção existem baixas de ordens de produção processando. A rotina não podera ser executada agora."+Time())
        FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Atenção existem baixas de ordens de produção processando. A rotina não podera ser executada agora."+Time(), 0 )
        Return
     Endif

     //if !empty(_cEstNeg)
        //	PutMv("MV_ESTNEG", _cEstNeg)
     //endif 

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 12/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     //aCampos := { {"USUARIO"    ,"C",20,0},{"ESTNEG"    ,"C",1,0}}
     //dbcreate(cArqBloq, aCampos, "DBFCDXADS")               
     //Use (cArqBloq) Alias (_cAreaBloq) VIA "DBFCDXADS" New 
     //dbselectarea(_cAreaBloq)
     //reclock(_cAreaBloq,.t.)
     //   (_cAreaBloq)->usuario := "AGENDAMENTO"
     //   (_cAreaBloq)->estneg := getmv("MV_ESTNEG")
     //msunlock()
     
// Verificar se tem alguém usando a rotina
	cArqBloq := "BRSCH015"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
	aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
   	if aBloq[1,1] //Já estava bloqueado?
   		cAux := "O programa já está sendo usado por: "+aBloq[1,2]
   		If lMenu
			Messagebox(cAux,"Atenção!",48) 		
		else
			FwLogMSG( "WARN", , 'SIGAEST', funname(), '', '01', cAux, 0 )
		endif 
		Return
	endif
	_cAreaBloq := aBloq[1,4]


     /*
     If !Empty( Alltrim( GetMV( 'ZP_PAR0016' ) ) )
        cAux := "O programa já está sendo usado por: " + Alltrim( GetMV( 'ZP_PAR0016' ) )
        If lMenu
           MessageBox( cAux, "Atenção!", 16 )
        Else
           FwLogMSG( "WARN", , 'SIGAEST', funname(), '', '01', cAux, 0 )
        Endif
        return
     Else
        PutMV( "ZP_PAR0016", Iif( _xOpcao == 1, RTRIM( cUserName ), "AGENDAMENTO" ) )
     Endif
     */
     
     /********************************************************************************************************************************/
     dbselectarea("SD3")
     dbsetorder(1)
     dbseek(xFilial("SD3"))
     dbselectarea("SB2")
     dbsetorder(1)
     dbseek(xFilial("SB2"))
     dbsetorder(1)
     dbselectarea("Z00")
     DbOrderNickName("Z00_STATUS") 
     dbgotop()
     dbseek(xFilial("Z00"),.f.)
	
     _cLocOri := "30"
     _cLocDest := "03"

	//LGS#20200212 - Adequação de release 12.1.25 e posteriores
	//ConOut(Repl("-",80))
	//ConOut("Inicio: "+Time())
	FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Inicio: "+Time(), 0 )
	dbselectarea("Z00")
	do while !eof() .AND. !(Z00->Z00_STATUS $ '1.2')  
	  	Begin Transaction   
		dbselectarea("Z00")                               
		lOk := reclock("Z00",.F.,.F.,.F.,.T.)
		if lOk
			cProd := padr(ALLTRIM(Z00->Z00_COD),15," ")
			_nQuant := Z00->Z00_QUANT  
			_cLote := Z00->Z00_LOTE
		
			DbSelectArea("SB1")
			DbSetOrder(1)  
			dbseek(xFilial("SB1")+cProd)
			If !found()
				lOk := .F.
				//LGS#20200212 - Adequação de release 12.1.25 e posteriores
				//ConOut(OemToAnsi("Produto: " + cProd+" Inexistente!"))
				FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', OemToAnsi("Produto: " + cProd+" Inexistente!"), 0 )
				dbselectarea("Z00")
				Z00->Z00_OBS := "Produto: " + cProd+" Inexistente!"
			Else	
				_cDescri	:= SB1->B1_DESC
        		_cUm 	:= SB1->B1_UM
			EndIf                      
		endif 		          
		If lOk 
			cQuery := "SELECT "+;
			"SALDO = C2_QUJE - ISNULL((SELECT SUM(D3_QUANT) FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) WHERE (SD3.D_E_L_E_T_ <> '*') AND "+;
			"(D3_TM = '999') AND (D3_LOCAL = '30') AND (D3_FILIAL = SC2.C2_FILIAL) AND (D3_COD = SC2.C2_PRODUTO) AND "+;
			"(D3_NUMSERI = SC2.C2_LOTE)),0) "+;
			"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
			"WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_LOCAL = '30') AND "+;
			"(C2_LOTE = '"+_cLote+"') AND (C2_PRODUTO = '"+alltrim(cProd)+"')"
			TCQuery cQuery ALIAS "TMPOP" NEW   
			dbselectarea("TMPOP")
			if !eof() .and. !bof()
				_nSaldo := iif(TMPOP->SALDO > 0,TMPOP->SALDO,0)
			else
				_nSaldo := 0
			endif 
			if _nSaldo < _nQuant
				lOk := .f.
				dbselectarea("Z00")
				Z00->Z00_OBS := "NAO TRANSF! Sld Disp: "+alltrim(str(_nQuant))  
				Z00->Z00_STATUS ='2'
			endif
			dbselectarea("TMPOP")
			dbclosearea()
		endif 
				
		
		if lOk
				
			dbselectarea("Z00")
 			_cDoc	:=  nextnumero("SD3",2,"D3_DOC",.t.) //GetSxENum("SD3","D3_DOC",1) //
			//LGS#20200212 - Adequação de release 12.1.25 e posteriores
			//ConOut(PadC("Transferindo "+cProd+"...",80))
			FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', PadC("Transferindo "+cProd+"...",80), 0 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Teste de Inclusao                                            |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	
			//Cabecalho a Incluir	
			_aAuto := {}  
			_aItem := {}
			aadd(_aAuto,{_cDoc,dDataBase})  	//Cabecalho
			//Itens a Incluir		
			aadd(_aItem,cProd)  		//D3_COD
			aadd(_aItem,_cDescri)     	//D3_DESCRI		
			aadd(_aItem,_cUm)  			//D3_UM
			aadd(_aItem,_cLocOri)      	//D3_LOCAL
			aadd(_aItem,"")				//D3_LOCALIZ
			aadd(_aItem,cProd)  		//D3_COD
			aadd(_aItem,_cDescri)     	//D3_DESCRI		
			aadd(_aItem,_cUm)  			//D3_UM
			aadd(_aItem,_cLocDest)     	//D3_LOCAL
			aadd(_aItem,"")				//D3_LOCALIZ
			aadd(_aItem,_cLote)         //D3_NUMSERI
			aadd(_aItem,"")				//D3_LOTECTL  
			aadd(_aItem,"")         	//D3_NUMLOTE
			aadd(_aItem,criavar('D3_DTVALID'))	//D3_DTVALID
			aadd(_aItem,0)						//D3_POTENCI
			aadd(_aItem,_nQuant) 				//D3_QUANT
		   	aadd(_aItem,criavar("D3_QTSEGUM"))	//D3_QTSEGUM
			aadd(_aItem,criavar("D3_ESTORNO"))  //D3_ESTORNO
			aadd(_aItem,criavar("D3_NUMSEQ"))   //D3_NUMSEQ 
			aadd(_aItem,"")						//D3_LOTECTL
			aadd(_aItem,criavar("D3_DTVALID"))	//D3_DTVALID
			aadd(_aItem,"")						//D3_ITEMGRD   	
//		    aadd(_aItem,criavar("D3_IDDCF"))											  //D3_IDDCF
		    aadd(_aItem,criavar("D3_OBSERVA"))											//D3_OBSERVA  
			
			aadd(_aAuto,_aItem)
			//LGS#20200212 - Adequação de release 12.1.25 e posteriores
			//_cEstNeg := getmv("MV_ESTNEG")

	  	//	PutMv("MV_ESTNEG", "S")   
			dbselectarea("SD3")
		    lMSErroAuto = .F.
		   	MSExecAuto({|x,y| mata261(x,y)},_aAuto,nOpcAuto)
		   	//MSExecAuto({|x| MATA261(x)},_aAuto,nOpcAuto)
			If lMsErroAuto
				cMens := "Erro na inclusao do lote "+Z00->Z00_LOTE+", PRODUTO "+cProd
				//LGS#20200212 - Adequação de release 12.1.25 e posteriores
				//ConOut(cMens)
				FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', cMens, 0 )
				dbselectarea("Z00")
				Z00->Z00_OBS := SUBSTR(cMens,1,30)
				IF lMenu
				   MostraErro() 
				Endif
			else
				Z00->Z00_STATUS := "1"
				Z00->Z00_OBS := "TRANSFERIDO"
			EndIf    
	  	//	PutMv("MV_ESTNEG", _cEstNeg)
 	
		EndIf      
		End Transaction
		dbselectarea("Z00")
		msunlock()
		dbgotop()
		dbseek(xFilial("Z00"),.F.)
	enddo 

     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg

	//PutMV( "ZP_PAR0016", '' )

	//LGS#20200212 - Adequação de release 12.1.25 e posteriores
	//ConOut("Fim  : "+Time())  
    FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Fim  : "+Time(), 0 )
   //	PutMv("MV_BXMANEW", "")

If !lMenu
	RESET ENVIRONMENT
Endif

Return Nil
/*
Exemplo Estorno: 

User Function Tmata261()

Local aAUTO := {}
Local cDoc	:= "000113001"
Local cProd	:= "TESTE          "

Private lMsErroAuto := .F.
                                          
RpcSetEnv("99","01",,,,,,,,,)

DbSelectArea("SD3")
DbSetOrder(2)
DbSeek(xFilial("SD3")+cDoc+cProd)

aAuto := {}
					
MSExecAuto({|x,y| mata261(x,y)},aAuto,6)

If !lMsErroAuto
	ALERT("Incluido com sucesso! ")
	ALERT(CVALTOCHAR(LMSERROAUTO))	
Else
	ALERT("Erro na inclusao!")  
	MostraErro()
EndIf

Return
*/