#include "rwmake.ch" 
#include "topconn.ch   
#include "protheus.ch"                                                                                     
                                                                                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AXCADZZU  ºAutor  ³Andréº					 Data ³05/04/16º   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±                
±±ºDesc.     ³ 															  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AXCADZZU()                                    

//Private cVldAlt   := ".T."  // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
//Private cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cVldAlt   := "u_AXZZU_1()"
Private cVldExc   := "u_AXZZU_2()" // Validacao para a exclusao. Pode-se utilizar ExecBlock                           
Private cRotina   := "AXCADZZU"
Private cCadastro := "Cadastro de Endereços X Pedidos"
Private cString   := "ZZU"
Private oTempTbl1
Private aRotina   := { {"Pesquisar" 		,"AxPesqui"     , 0, 1},;
                       {"Visualizar"		,"AxVisual"     , 0, 2},;
                       {"Incluir"   		,"AxInclui"     , 0, 3},;
                       {"Excluir"   		,"AxDeleta"     , 0, 5},; 
                       {"Endereça Aut."     ,"u_EndAuto()"  , 0, 9} }

                       //{"Alterar"   		,"AxAltera"     , 0, 4},;

//AxCadastro("SA1", "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )

If !u_VldAcesso(funname())
   	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
   	Return 
Endif 

AxCadastro(cString, cCadastro, cVldExc, cVldAlt, aRotina )
DbSelectArea("ZZU")
DbSetOrder(1)


Return


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± AXZZU_1 - Função para validação da Inclusão						      ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function AXZZU_1()

	Local cQry := " "
    Local lRet :=.t.
	If INCLUI
		Begin Transaction
            DbSelectArea("SZG")
            DbSetOrder(2)
            DbSeek(xFilial("SZG")+substr(cNumEmp,1,2)+M->ZZU_PEDIDO, .t.)
            If Found()
            	RecLock("SZG", .f.)
                    SZG->ZG_LOCALIZ := ALLTRIM(M->ZZU_ENDERE) //Cleber (16/01/17), coloquei ALLTRIM por conta de dif. tam ZZU_ENDERE
                MsUnLock()
            Else
		    	Messagebox("Pedido não consta em nenhum bordero de Pedidos, Inclua em algum bordero primeiro !!","Atenção...",64) 			
	   			DbSelectArea("SZG")
   				DbClosearea()
   				lRet :=.f.
       			DisarmTransaction() 
				//Return(lRet) - //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Não é permitido return dentro de Begin transaction			
            Endif	
   			DbSelectArea("SZG")
   			DbClosearea()
   			
   			cQry := " "
			cQry += " UPDATE "+RetSqlName("ZZT")+" SET ZZT_STATUS ='2'"
   			cQry += " WHERE D_E_L_E_T_ ='' AND ZZT_FILIAL ='"+xFilial("ZZT")+"' AND ZZT_CODIGO ='"+M->ZZU_ENDERE+"'"
	   		XXX := TCSQLExec(cQry) 
        
		End Transaction
    Elseif ALTERA
    	Messagebox("Alteração não permitida, Exclua e Inclua Novamente !!","Atenção...",64) 			
		lRet :=.f.    
		Return(lRet)
    Endif
Return(lRet)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± AXZZU_2 - Função para validação da Exclusão						      ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function AXZZU_2()

	Local cQry := " "
	Local lRet := .t.
   	If MsgYesNo("Confirma liberação do endereço alocado para o Pedido ?", "Atenção")	
		Begin Transaction

   			cQry := " "
	   		cQry += " UPDATE "+RetSqlName("ZZU")+" SET D_E_L_E_T_ ='*' "
	   		cQry += " WHERE D_E_L_E_T_ ='' AND ZZU_FILIAL ='"+xFilial("ZZU")+"' AND ZZU_PEDIDO ='"+ZZU->ZZU_PEDIDO+"'"
	   		XXX := TCSQLExec(cQry) 
            	
	   		cQry := " "
   			cQry += " UPDATE "+RetSqlName("ZZT")+" SET ZZT_STATUS ='1' FROM "+RetSqlName("ZZT")+" ZZT LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU "
   			cQry += " ON ZZT_FILIAL = ZZU_FILIAL AND ZZT_CODIGO = ZZU_ENDERE AND ZZU.D_E_L_E_T_ ='' "
	   		cQry += " WHERE ZZT.D_E_L_E_T_ ='' AND ZZT_FILIAL ='"+xFilial("ZZT")+"'"
	   		//cQry += " AND ZZU_PEDIDO IS NULL AND ZZT_CODIGO ='"+ZZU->ZZU_ENDERE+"'"
	   		cQry += " AND ZZU_PEDIDO IS NULL AND ZZT_STATUS ='2'"
	   		XXX := TCSQLExec(cQry) 

            DbSelectArea("SZG")
            DbSetOrder(2)
            DbSeek(xFilial("SZG")+substr(cNumEmp,1,2)+ZZU->ZZU_PEDIDO, .t.)
            If Found()
            	RecLock("SZG", .f.)
                    SZG->ZG_LOCALIZ := ''
                MsUnLock()
            Endif	
   			DbSelectArea("SZG")
   			DbClosearea()

		End Transaction

	Endif

Return(lRet)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± AXZZU_3 - Função para validação na digitação do Endereço			      ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function AXZZU_3()

	Local cQry  := " "
  	Local lRet  :=.t.

	cQry := " "
	cQry += " SELECT ZZT_STATUS, ZZU_PEDIDO FROM "+RetSqlName("ZZT")+" ZZT LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU WITH (NOLOCK) "
	cQry += " ON ZZU_FILIAL = ZZT_FILIAL AND ZZU_ENDERE = ZZT_CODIGO AND ZZU.D_E_L_E_T_ ='' "	
	cQry += " WHERE ZZT.D_E_L_E_T_ ='' AND ZZT_FILIAL ='"+xFilial("ZZT")+"' AND ZZT_CODIGO ='"+M->ZZU_ENDERE+"'"
	
	TCQuery cQry ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    
    If !Eof() 
		If TCQ->ZZT_STATUS $ '2' 
	        Messagebox("Endereço já ocupado por outro pedido ( "+TCQ->ZZU_PEDIDO+" ), verifique ou troque o endereço !!","Atenção...",64) 	
			cQry :=.f.
		ElseIF TCQ->ZZT_STATUS $ '3'	
	        Messagebox("Endereço já reservado, provavelmente esta sendo endereçado, verifique !!","Atenção...",64) 	
			cQry :=.f.
		Endif	
	Else
	    Messagebox("Endereço digitado é inválido, verifique !!","Atenção...",64) 			
		//lCont :=.f.
    Endif

    DbSelectArea("TCQ")
    DbCloseArea()    
    	
Return(lRet)



/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± EndAuto - Função para Endereçamento automático de Pedidos		      ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function EndAuto()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGet1TBo   := Space(6)
     Private cGet2TBo   := Space(40)
     Private cGet3TBo   := Space(8)
     Private cGet4TBo   := Space(8)
     Private cSay1TBo   := Space(1)
     Private cSay2TBo   := Space(1)
     Private cMarca     := GetMark()

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1TBo", "oSay1TBo", "oSay2TBo", "oSay3TBo", "oSay4TBo", "oRMenu1T", "oGet1TBo", "oGet2TBo", "oGet3TBo", "oGet4TBo", "oBtn1TBo", "oBtn2TBo", "oBtn3TBo")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -17, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1TBo   := MSDialog():New( 091, 232, 556, 857, "Endereçador de Pedidos Automático", , , .F., , , , , , .T., , , .T. )
     oSay1TBo   := TSay():New( 004, 003, {||"Bordero:"}  , oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 064, 012)
     oGet1TBo   := TGet():New( 003, 041, {|u| If(PCount() > 0, cGet1TBo := u, cGet1TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "SZF", "cGet1TBo", , )
     oGet2TBo   := TGet():New( 003, 096, {|u| If(PCount() > 0, cGet2TBo := u, cGet2TBo)}, oDlg1TBo, 095, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F.,      , "cGet2TBo", , )
     oSay3TBo   := TSay():New( 215, 003, {||"Volumes:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
     oGet3TBo   := TGet():New( 214, 045, {|u| If(PCount() > 0, cGet3TBo := u, cGet3TBo)}, oDlg1TBo, 040, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F.,      , "cGet3TBo", , )
     oSay4TBo   := TSay():New( 215, 195, {||"Peso:"}, oDlg1TBo, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 068, 012)
     oGet4TBo   := TGet():New( 214, 220, {|u| If(PCount() > 0, cGet4TBo := u, cGet4TBo)}, oDlg1TBo, 045, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F.,      , "cGet4TBo", , )

     oBtn1TBo   := TButton():New( 002, 266, "Sair"        , oDlg1TBo, { || oDlg1TBo:End() }, 037, 012, , , , .T., , "", , , , .F. )
     //oBtn2TBo   := TButton():New( 019, 266, "Gravar"      , oDlg1TBo, { || fGravEnd()     }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3TBo   := TButton():New( 002, 221, "Gerar End"   , oDlg1TBo, { || fGeraEnd()     }, 037, 012, , , , .T., , "", , , , .F. )
     
     oTbl1TBo()
     DbSelectArea("TMPTBO")
     oBrw1TBo   := MsSelect():New( "TMPTBO", "MARCA", "", { {"MARCA", "", "", ""}, {"PEDID", "", "Pedido", "99999999"}, {"NOMCL", "", "Nome Cliente", "@!"}, {"PALLE", "", "Pallets", "99.999"}, {"VOLUM", "", "Volumes", "99999"}, {"ARMAZ", "", "Localizacao", "@!"}  }, .F., cMarca, {036, 004, 210, 312}, , , oDlg1TBo ) 
     oBrw1TBo:oBrowse:lColDrag    := .t.
     oBrw1TBo:oBrowse:lHasMark    := .t.
     oBrw1TBo:oBrowse:lCanAllmark := .t.
     oBrw1TBo:oBrowse:bAllMark    := {|| InvTrans(cMarca, @oBrw1TBo) }
     oGet1TBo:bValid := {|| fValBorDe() }
     //oGet1TBo:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fCarPall(cGet1Env),"")}
     //oGet2TBo:bValid := {|| fValBorPa() }
     oDlg1TBo:Activate(,,,.T.)
     DbSelectArea("TMPTBO")
     DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1TBo() - Cria temporario para o Alias: TMPTBO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1TBo()
       Local aFds := {}
       //Local cTmp

       Aadd( aFds , {"MARCA", "C", 002, 000} )
       Aadd( aFds , {"PEDID", "C", 008, 000} )
       Aadd( aFds , {"NOMCL", "C", 040, 000} )
       //Aadd( aFds , {"LOCAL", "C", 015, 000} )
       Aadd( aFds , {"ARMAZ", "C", 015, 000} )
       Aadd( aFds , {"PALLE", "N", 007, 004} )
       Aadd( aFds , {"VOLUM", "N", 005, 000} )
       Aadd( aFds , {"TIPOB", "C", 001, 000} )
       Aadd( aFds , {"RANK" , "N", 004, 000} )
       Aadd( aFds , {"OCUPA", "N", 001, 000} )
	   Aadd( aFds , {"CLIEN", "C", 006, 000} )       

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*
       cTmp := U_NovoArqTrab("dbf") 
       dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
       Use (cTmp+".Dbf") Alias "TMPTBO" VIA "DBFCDXADS" New Exclusive
       Index On PEDID To (cTmp) */     
	   
	   //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
	   //DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
       //Use (cTmp+".Dbf") Alias "TMPTBO" VIA "DBFCDXADS" New Exclusive
	   //DbCreateIndex(cTmp+"_1.cdx", "PEDID"	     , {||"PEDID"} )
	   //DbCreateIndex(cTmp+"_2.cdx", "RANK"       , {||"RANK"} )

	   //DbClearInd()
       //DbSetIndex(cTmp+"_1")
       //DbSetIndex(cTmp+"_2")
       oTempTbl1 := FWTemporaryTable():New( 'TMPTBO' )
       oTempTbl1:SetFields( aFds )
       oTempTbl1:AddIndex( "cInd01", { "PEDID" } )
       oTempTbl1:AddIndex( "cInd02", { "RANK"  } )
       oTempTbl1:Create()
       /********************************************************************************************************************************/
       DbSetOrder(2)	   
	   
Return

Static Function fValBorDe()
       
       Local nVolBor :=0
       Local nPesBor :=0
       Local cQry    :=""

	   If Empty(Alltrim(cGet1TBo))
	   	   Return
	   Endif
       
       DbSelectArea("TMPTBO")
       //Zap
       //LGS#20191029 - Substituido comandoZAP devido a utilização de função do banco.
       TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )

       cGet2TBo := space(40)

       DbSelectArea("SZF")
       DbSetOrder(1)
       DbSeek(xFilial("SZF")+cGet1TBo, .t.)
       If Found() .and. (SZF->ZF_FILIAL == XFilial("SZF")) .and. (Alltrim(SZF->ZF_CODIGO) == Alltrim(cGet1TBo))
	   	  If !(ALLTRIM(SZF->ZF_TIPOBOR) $ '3-8') //Cleber (06/11/18 )Chamado 011842, Mirinho pediu pra tratar tipo 8 como tipo 3
	   	     If !SZF->ZF_FLAG $ 'D'		
		          MsgStop("Atenção, o status desse bordero não permite fazer alterações.")
        		  cGet1TBo := space(06)
		          oGet1TBo:Refresh()
		          Return				
    		 Endif
    		 cGet2TBo := IIf(SZF->ZF_TIPOBOR $ '1', 'AGLUTINADO', IIf(SZF->ZF_TIPOBOR $ '2', 'DEPOSITO',IIf(SZF->ZF_TIPOBOR $ '4', 'EXPORTACAO', IIf(SZF->ZF_TIPOBOR $ '5', 'CARGA FECHADA', IIf(SZF->ZF_TIPOBOR $ '6', 'AMOSTRAS', 'VOL. QUEBRADO')))))
		  Else
	          MsgStop("Atenção, tipo do Borderô inválido (Região não se endereça por esta Rotina)")
    	      cGet2TBo := SZF->ZF_TIPOBOR
        	  oGet1TBo:SetFocus()
	          Return
	   	  Endif 	
       Else
          MsgStop("Número de Bordero Inválido !!")
   		  cGet2TBo := IIf(SZF->ZF_TIPOBOR $ '1', 'AGLUTINADO', IIf(SZF->ZF_TIPOBOR $ '2', 'DEPOSITO',IIf(SZF->ZF_TIPOBOR $ '4', 'EXPORTACAO', IIf(SZF->ZF_TIPOBOR $ '5', 'CARGA FECHADA', IIf(SZF->ZF_TIPOBOR $ '6', 'AMOSTRAS', 'VOL. QUEBRADO')))))
          oGet1TBo:SetFocus()
          Return
	   Endif		  	

       oGet2TBo:Refresh()

// ALTERADO DE 0.03 PARA 0.12 O VOLUME PARA QUADRANTES PEQUENOS (SPG) SOLICITADO POR RAMON
       
	   cQry += " SELECT ROW_NUMBER() OVER (ORDER BY C5_VOLUME2 DESC, C5_VOLUME1 DESC, C5_NUM) AS RANK, "
	   cQry += " ZG_CODIGO, C5_NUM, C5_CLIENTE, A1_NOME, C5_VOLUME1, C5_VOLUME2, C5_PBRUTO,  "
	   cQry += " CASE WHEN C5_VOLUME2 <= 0.12                        THEN '1' ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  0.12  AND C5_VOLUME2 <= 7.2 THEN '2' ELSE " 
	   cQry += " CASE WHEN C5_VOLUME2 >  7.2                         THEN '3' END END END AS 'TIPOB', "
	   cQry += " CASE WHEN C5_VOLUME2 <= 0.12                        THEN '1' ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  0.12  AND C5_VOLUME2 <= 1.2 THEN  1  ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  1.2   AND C5_VOLUME2 <= 2.2 THEN  2  ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  2.2   AND C5_VOLUME2 <= 3.2 THEN  3  ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  3.2   AND C5_VOLUME2 <= 4.2 THEN  4  ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  4.2   AND C5_VOLUME2 <= 5.2 THEN  5  ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  5.2   AND C5_VOLUME2 <= 6.2 THEN  6  ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  6.2   AND C5_VOLUME2 <= 7.2 THEN  7  ELSE "
	   cQry += " CASE WHEN C5_VOLUME2 >  7.2                         THEN  1  END END END END END END END END END AS 'OCUPA' "	   
	   cQry += " FROM "+RetSqlName("SZG")+" SZG WITH(NOLOCK) "
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL = ZG_FILIAL AND C5_NUM = SUBSTRING(ZG_PEDIDO,3,6) AND SC5.D_E_L_E_T_ ='' "
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = '"+xFilial("SA1")+"' AND C5_CLIENT = A1_COD AND SA1.D_E_L_E_T_ ='' "
	   cQry += " WHERE SZG.D_E_L_E_T_ ='' "
	   cQry += " AND ZG_CODIGO ='"+cGet1TBo+"'"
	   cQry += " AND ZG_FILIAL ='"+xFilial("SZG")+"'"

	   TCQuery cQry ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()

       While !Eof() 
	        RecLock("TMPTBO", .t.)
    	        TMPTBO->PEDID := TCQ->C5_NUM
                TMPTBO->NOMCL := TCQ->A1_NOME
                TMPTBO->PALLE := TCQ->C5_VOLUME2 //IIf(Ceiling(Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_VOLUME2"))=0,1,Ceiling(Posicione("SC5", 1, xFilial("SC5")+SubStr(SZG->ZG_PEDIDO, 3, 6), "C5_VOLUME2")))
                TMPTBO->VOLUM := TCQ->C5_VOLUME1
				TMPTBO->TIPOB := TCQ->TIPOB
				TMPTBO->OCUPA := TCQ->OCUPA
				TMPTBO->CLIEN := TCQ->C5_CLIENTE
            MsUnLock()
            nPesBor += TCQ->C5_PBRUTO
            nVolBor += TCQ->C5_VOLUME1
            DbSelectArea("TCQ")
            DbSkip()
       EndDo

       DbSelectArea("TCQ")
	   DbCloseArea()	

       DbSelectArea("TMPTBO")
       DbSetOrder(2)
       DbGoTop()
       //oBrw1TBo:oBrowse:lReadOnly := .t.
       oBrw1TBo:oBrowse:Refresh()
       cGet3TBo := nVolBor
       cGet4TBo := Transform(nPesBor, '@E 999,999,999.99')
       oGet2TBo:SetFocus()
	   
	   InvTrans(cMarca, @oBrw1TBo) // INICIAR COM TODOS OS PEDIDOS MARCARDOS

Return

Static Function InvTrans(cMarca, oBrw1TBo)
	
	Local nReg := TMPTBO->(Recno())
    
    DbSelectArea("TMPTBO")
    DbGoTop()
    
    While !Eof()
    	RecLock("TMPTBO", .f.)
        If TMPTBO->MARCA == cMarca
        	TMPTBO->MARCA := "  "
        Else
            TMPTBO->MARCA := cMarca
        Endif
        MsUnLock()
        DbSkip()
    Enddo
    TMPTBO->(dbGoto(nReg))
    oBrw1TBo:oBrowse:Refresh(.t.)
    
Return

// Gera Endereçamento automático de acordo com a regras definidas pela Expedição

// 1-)  PEDIDOS COM C5_VOLUME2 ACIMA DE 7.2, ALOCAR NO ENDEREÇO SPDEP01 (15 DISPONÍVEIS)
// 2-)  PEDIDOS COM C5_VOLUME2 ABAIXO DE 7.2, ALOCAR NOS ENDEREÇOS SP-0001, ATÉ 1,2 
//      CONSIDERAR 1 ENDEREÇO, A PARTIR DAI A CADA 1 M2 (DE 001 A 999)
// 3-)  PEDIDOS COM C5_VOLUME2 ABAIXO DE 0,03 ALOCAR NOS ENDEREÇOS SPG001, BUSCAR OS VAGOS, 
//      SE NÃO TIVER COLOCAR PODE REMONTAR POIS SÃO PEDIDOS QUE OCUPAM MUITO POUCO ESPAÇO NO CHÃO.
//      (60 DISPONÍVEIS)

Static Function fGeraEnd()
    Local j, x, i
	Local cQry   :=""
    //Local EndIni :=""
    Local aMat   :={} 
    Local aSeq   :={}
    Local lContinua := .f.
    Local cEndereco := 'SEM-END' //Cleber (16/01/17), inicializando variável pois estava dando erro de variavel inexistente!
    
	If Empty(cGet1TBo) // .or. (Len(Alltrim(cGet2TBo)) <> 3)
		Return
	Endif
	
	DbSelectArea("SZG")
	DbSetOrder(1)
	DbSeek(xFilial("SZG")+cGet1TBo)     // Filial + Bordero + Pedido
	If Found()
   		If !Empty(Alltrim(SZG->ZG_LOCALIZ))
          MsgStop("Borderô endereçado anteriormente, não é possível repetir a operação !! ")
          DbSelectArea("SZG")
          DbCloseArea()
          Return
		Endif
	Endif	

    DbSelectArea("TMPTBO")
    DbSetOrder(2)
    DbGoTop()

	Begin Transaction

		While !Eof()

			If IsMark("MARCA", cMarca)
	    		If TMPTBO->TIPOB $ '1.3'
					//FEndPed(TMPTBO->PEDID,TMPTBO->TIPOB,TMPTBO->OCUPA)
					cQry := ""
					cQry += " SELECT TOP 1 ZZT_CODIGO "
					cQry += " FROM "+RetSqlName("ZZT")+" ZZT WITH (NOLOCK) "
					cQry += " LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU WITH (NOLOCK) ON ZZU_FILIAL = ZZT_FILIAL AND ZZU_ENDERE = ZZT_CODIGO AND ZZU.D_E_L_E_T_ ='' AND (ZZU_ENDERE) IS NULL "
					cQry += " WHERE ZZT.D_E_L_E_T_ ='' 
					cQry += " AND ZZT_TIPO ='"+TMPTBO->TIPOB+"' AND ZZT_STATUS ='1' 
					cQry += " AND ZZT_LOCAL ='G3' "
					cQry += " ORDER BY ZZT_CODIGO "
		
					TCQuery cQry ALIAS "TCQ" NEW
			        DbSelectArea("TCQ")
			        DbGoTop()
        			If !Eof()
						DbSelectArea("ZZT")
						DbSetOrder(1)
						DbSeek(xFilial("ZZT")+TCQ->ZZT_CODIGO, .t.)
						If Found() .and. (ZZT->ZZT_FILIAL == XFilial("ZZT")) .and. (Alltrim(ZZT->ZZT_CODIGO) == Alltrim(TCQ->ZZT_CODIGO))        	
			               	RecLock("ZZT", .f.)
								ZZT->ZZT_STATUS := '2'
							MsUnlock()
							DbSelectArea("ZZU")
							DbSetOrder(3)
							DbSeek(xFilial("ZZU")+TMPTBO->PEDID+ZZT->ZZT_CODIGO,  .t.)
							If !Found()
								RecLock("ZZU", .t.)
									ZZU->ZZU_FILIAL := xFilial("ZZU")
									ZZU->ZZU_PEDIDO := TMPTBO->PEDID
									ZZU->ZZU_ENDERE := ZZT->ZZT_CODIGO
									ZZU->ZZU_PALLET := TMPTBO->PALLE 
									ZZU->ZZU_DTINCL := DDATABASE
									ZZU->ZZU_CODCLI := TMPTBO->CLIEN									
								MsUnlock()
							Endif								
							cEndereco := TCQ->ZZT_CODIGO            	
						Else
							cEndereco := 'SEM-END'
						Endif
			        Else
			        	cEndereco := 'SEM-END'
		    	    Endif

					TMPTBO->ARMAZ := cEndereco
    	
			        DbSelectArea("TCQ")
		  			DbCloseArea()

				Else				
    	    	   	aMat   :={}
    		   		aSeq   :={}
	        	
			  		cQry := ""
			  		cQry += " SELECT ZZT_CODIGO FROM "+RetSqlName("ZZT")+" ZZT WITH (NOLOCK) "
					cQry += " LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU WITH (NOLOCK) ON ZZU_FILIAL = ZZT_FILIAL AND ZZU_ENDERE = ZZT_CODIGO AND ZZU.D_E_L_E_T_ ='' AND (ZZU_ENDERE) IS NULL "
					cQry += " WHERE ZZT.D_E_L_E_T_ ='' AND ZZT_TIPO ='"+TMPTBO->TIPOB+"' AND ZZT_STATUS ='1' AND ZZT_LOCAL ='G3' "
					cQry += " ORDER BY ZZT_CODIGO "
			
					TCQuery cQry ALIAS "TCQ" NEW
					DbSelectArea("TCQ")
					DbGoTop()
				  	While !Eof()
					  	aAdd(aMat, {TCQ->ZZT_CODIGO})				
		        		DbSelectArea("TCQ")
				        DbSkip() 
					Enddo
	        		DbSelectArea("TCQ")
					DbCloseArea()	            
        	
		            For i := 1 to Len(aMat)
						If TMPTBO->OCUPA = 1  
							DbSelectArea("ZZT")
							DbSetOrder(1)
							DbSeek(xFilial("ZZT")+aMat[i][1] , .t.)
							If Found() .and. (ZZT->ZZT_FILIAL == XFilial("ZZT")) .and. (Alltrim(ZZT->ZZT_CODIGO) == Alltrim(aMat[i][1]))        	
	    			           	RecLock("ZZT", .f.)
									ZZT->ZZT_STATUS := '2'
								MsUnlock()
								DbSelectArea("ZZU")
								DbSetOrder(3)
								DbSeek(xFilial("ZZU")+TMPTBO->PEDID+ZZT->ZZT_CODIGO,  .t.)
								If !Found()
							 		RecLock("ZZU", .t.)
										ZZU->ZZU_FILIAL := xFilial("ZZU")
										ZZU->ZZU_PEDIDO := TMPTBO->PEDID
										ZZU->ZZU_ENDERE := ZZT->ZZT_CODIGO
										ZZU->ZZU_PALLET := TMPTBO->PALLE
										ZZU->ZZU_DTINCL := DDATABASE
										ZZU->ZZU_CODCLI := TMPTBO->CLIEN
									MsUnlock()
								Endif							
								//cEndereco := Substr(ZZT->ZZT_CODIGO,1,5)
								cEndereco := ZZT->ZZT_CODIGO
							Else
								cEndereco := 'SEM-END'
							Endif
		   					i    :=Len(aMat)
		   					TMPTBO->ARMAZ := cEndereco
						Else
							aAdd(aSeq, {aMat[i][1] , i, Val(Substr(aMat[i][1],3,4))})
							If Len(aSeq) = TMPTBO->OCUPA
								For x := 1 to Len(aSeq)
									If (x = Len(aSeq)) .and. ((aSeq[x][3] - aSeq[1][3]) =  (TMPTBO->OCUPA-1))
										lContinua := .t.
		            		        	For j := 1 to Len(aSeq)
											DbSelectArea("ZZT")
											DbSetOrder(1)
											DbSeek(xFilial("ZZT")+aSeq[j][1],  .t.)
											If Found() .and. (ZZT->ZZT_FILIAL == XFilial("ZZT")) .and. (Alltrim(ZZT->ZZT_CODIGO) == Alltrim(aSeq[j][1]))        	
						    		           	RecLock("ZZT", .f.)
													ZZT->ZZT_STATUS := '2'											
												MsUnlock()
												DbSelectArea("ZZU")
												DbSetOrder(3)
												DbSeek(xFilial("ZZU")+TMPTBO->PEDID+ZZT->ZZT_CODIGO,  .t.)
												If !Found()
						    			           	RecLock("ZZU", .t.)
														ZZU->ZZU_FILIAL := xFilial("ZZU")
														ZZU->ZZU_PEDIDO := TMPTBO->PEDID
														ZZU->ZZU_ENDERE := ZZT->ZZT_CODIGO
														ZZU->ZZU_PALLET := TMPTBO->PALLE   
														ZZU->ZZU_DTINCL := DDATABASE
														ZZU->ZZU_CODCLI := TMPTBO->CLIEN
													MsUnlock()
											    Endif
	    	        	                	    If Len(aSeq) = TMPTBO->OCUPA
													cEndereco := Substr(aSeq[1][1],1,6)+'/'+Substr(aSeq[j][1],3,4)          	
												Endif	
											Endif   				
		    	        	        	Next j
									ElseIf (x = Len(aSeq)) .and. ((aSeq[x][3] - aSeq[1][3]) <> (TMPTBO->OCUPA-1))
										aDel(aSeq, 1)
								    	aSize(aSeq,(Len(aSeq)-1))                        	
									Endif   
		                        Next x
	    	    	            If lContinua 
		    	                	i             := Len(aMat)
	            	    	    	j             := 0
	            		        	x             := 0	                    	
				   					TMPTBO->ARMAZ := cEndereco
				   					lContinua     := .f.
		                    		aSize(aMat,0)
			                    	aSize(aSeq,0)
								Endif       	                        
							Endif
						Endif
	            	Next i
				Endif
				If !cEndereco $ 'SEM-END'
					DbSelectArea("SZG")
				    DbSetOrder(1)
				    DbSeek(xFilial("SZG")+cGet1TBo+'01'+TMPTBO->PEDID ,.t.)     // Filial + Bordero + Pedido
					If Found()
	    	    		RecLock("SZG", .f.)
    	    	    		SZG->ZG_LOCALIZ := ALLTRIM(cEndereco)
	               		MsUnLock()
					Endif
        		Endif
    	    Endif   
   	    	DbSelectArea("TMPTBO")
	        DbSkip() 
  		EndDo
	
	End Transaction	

    DbSelectArea("TMPTBO")
    DbSetOrder(2)
    DbGoTop()
    
    DbSelectArea("ZZT")
    DbCloseArea()  

    DbSelectArea("ZZU")
    DbCloseArea()      

Return

/*Static Function FEndPed(cNumPed,cTipoEnd,nOcupa)
	Local cQry := ""
	Local cEndereco := 'SEM-END' //Cleber (16/01/17)->Inicializando variável pois estava dando erro de variável inexistente!

    If cTipoEnd $ '1.3'
		cQry += " SELECT TOP 1 ZZT_CODIGO "
		cQry += " FROM "+RetSqlName("ZZT")+" ZZT WITH (NOLOCK) "
		cQry += " LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU WITH (NOLOCK) ON ZZU_FILIAL = ZZT_FILIAL AND ZZU_ENDERE = ZZT_CODIGO AND ZZU.D_E_L_E_T_ ='' AND (ZZU_ENDERE) IS NULL "
		cQry += " WHERE ZZT.D_E_L_E_T_ ='' 
		cQry += " AND ZZT_TIPO ='"+cTipoEnd+"' AND ZZT_STATUS ='1' 
		cQry += " AND ZZT_LOCAL ='G3' "
		cQry += " ORDER BY ZZT_CODIGO "
		
		TCQuery cQry ALIAS "TCQ" NEW
        DbSelectArea("TCQ")
        DbGoTop()
        If !Eof()
			DbSelectArea("ZZT")
			DbSetOrder(1)
			DbSeek(xFilial("ZZT")+TCQ->ZZT_CODIGO, .t.)
			If Found() .and. (ZZT->ZZT_FILIAL == XFilial("ZZT")) .and. (Alltrim(ZZT->ZZT_CODIGO) == Alltrim(TCQ->ZZT_CODIGO))        	
               	RecLock("ZZT", .f.)
					ZZT->ZZT_STATUS := '3'
				MsUnlock()
				cEndereco := TCQ->ZZT_CODIGO            	
			Else
				cEndereco := 'SEM-END'
			Endif
        Else
        	cEndereco := 'SEM-END'
        Endif
        DbSelectArea("TCQ")
  		DbCloseArea()
	Endif 

Return(cEndereco)*/

/*Static Function fGravEnd()

       Local lcontinua := .f.

       If Empty(cGet1TBo) 
          MsgStop("Não é possível fazer o endereçamento, escolha o Borderô primeiro !! ")
          Return
       Endif

       If MsgYesNo("Grava Endereçamento gerado ?", "Atenção")

	       DbSelectArea("TMPTBO")
    	   DbGoTop()
	       While !Eof()
		       If IsMark("MARCA", cMarca)
    	       	  lcontinua := .t.
        	   Endif
	           DbSelectArea("TMPTBO")
    	       DbSkip() 
    	   Enddo 
    	   
    	   If lcontinua
    	   	
		       DbSelectArea("TMPTBO")
		       DbGoTop()
	
    		   While !Eof()
			       If IsMark("MARCA", cMarca)
				       DbSelectArea("SZG")
			    	   DbSetOrder(1)
			    	   DbSeek(xFilial("SZG")+cGet1TBo+TMPTBO->PEDID ,.t.)     // Filial + Bordero + Pedido
				       If Found()
	    	               RecLock("SZG", .f.)
    	    	               SZG->ZG_LOCALIZ := ALLTRIM(TMPTBO->ARMAZ)
                	       MsUnLock()
				       Endif
		   		   Endif
	    	       DbSelectArea("TMPTBO")
    	    	   DbSkip() 
		       Enddo
               DbSelectArea("SZG")
               DbCloseArea()
		   Else
				MsgBox("É preciso marcar algum pedido antes endereçar !!", "Atenção", "INFO")
				oBrw1TBo:oBrowse:SetFocus()
				oBrw1TBo:oBrowse:Refresh()
		   Endif		
       Endif
 
       DbSelectArea("TMPTBO")
  	   DbGoTop()       
		
Return*/