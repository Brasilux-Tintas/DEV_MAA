#include 'tbiconn.ch'
#include 'error.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include "rwmake.ch"                                         
#include "topconn.ch"

/*
Movimenta Sobra do Apontamento de Produção para tinta pó, transformando sobra de Pi 12 digitos em 0986
*/
User Function BRPCPX71()

Local aSays			:= {}
Local aButtons 		:= {}
//Local a_cFil        := {"010101","060101"}
//Local cMens1

	If !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
		Return 
	Endif 

//    If (!cNumEmp == "01010101") .or. (!cNumEmp == "01060101")  
//        MsgBox("Essa empresa não utiliza esta Rotina! ","ATENÇÃO...","STOP")
//        Return nil
//    Endif

	nOpca	  := 0
	AADD(aSays,"Este programa irá transformar as sobras apontadas")
	AADD(aSays,"na ordem de produção das linhas 97, 98 e 99 em MP")
	AADD(aSays,"para emissão de nota ou reutilização nas ops")

	cCadastro:=OemToAnsi("Processando Sobras de PI Tinta Linhas (97,98 e 99)")

	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}})
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

    If nOpca = 1
		Processa({|| U_PCPX71(1,XFilial("SD3"))})
	Endif

Return(Nil)

User Function PCPX71(_xOpcao,cFil)
     Local cAuxMens      := ""
	Local cQry          := ""
	//Local cEmp          := Substr(cNumEmp,1,2)
	//Local cFilial       := XFILIAL("SD3")	
	Private _aIteAju 	:= {}
	Private _aCabMov 	:= {}
	Private _aAuxMov    := {}
	Private _aAuto 		:= {}
	Private _aItem 		:= {}
	Private lMsErroAuto := .f.   
	Default _xOpcao 	:= 2   

	If ValType(_xOpcao) <> "N"
		_xOpcao := 2
	Endif 
    
	If _xOpcao == 2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Abertura do ambiente                                         |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    	PREPARE ENVIRONMENT EMPRESA "01" FILIAL cFil MODULO "PCP" TABLES "SD3","SB1","SB2","SC2"

		//ConOut(Repl("-",80))
		//ConOut(PadC("****************************************",80))
		//ConOut(PadC("Transformação de PI Tinta Pó 97-98-99   ",80))
		//ConOut(PadC("****************************************",80))
		//ConOut("Inicio: "+Time())
        cAuxMens += Repl( "-", 80 ) + CHR(13) + CHR(10)
		cAuxMens += PadC( "****************************************", 80 ) + CHR(13) + CHR(10)
		cAuxMens += PadC( "Transformação de PI Tinta Pó 97-98-99   ", 80 ) + CHR(13) + CHR(10)
		cAuxMens += PadC( "****************************************", 80 ) + CHR(13) + CHR(10)
		cAuxMens += "Inicio: " + Time()
		FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', cAuxMens, 0 )
	Endif 

    cQry := " SELECT SB2.B2_FILIAL, SB2.B2_COD,SB1.B1_DESC, SB1.B1_UM, SB2.B2_LOCAL, SB2.B2_QATU, SB2.B2_QEMP,B2_RESERVA, SB2.R_E_C_N_O_, Z1_REAPROV,  "
    cQry += " (SELECT COUNT(SC2.C2_PRODUTO) FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) WHERE SC2.C2_FILIAL ='"+XFilial("SB2")+"' AND SC2.D_E_L_E_T_ = '' AND SUBSTRING(SC2.C2_PRODUTO, 1, 10) = SUBSTRING(SB2.B2_COD, 1, 10) AND SC2.C2_DATRF = '' AND SUBSTRING(SC2.C2_PRODUTO, 11, 2) NOT IN('00','99')) AS PA, "
    cQry += " (SELECT COUNT(SC2.C2_PRODUTO) FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) WHERE SC2.C2_FILIAL ='"+XFilial("SB2")+"' AND SC2.D_E_L_E_T_ = '' AND SC2.C2_PRODUTO = SB2.B2_COD AND SC2.C2_DATRF = '') AS PI, "
    cQry += " (SELECT COUNT(ZZA.ZZA_ORDEM)  FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) WHERE ZZA.ZZA_FILIAL ='"+XFilial("SB2")+"' AND ZZA.D_E_L_E_T_ = '' AND SUBSTRING(ZZA.ZZA_PRODUT, 1, 10) = SUBSTRING(SB2.B2_COD, 1, 10) AND ZZA.ZZA_FLAG IN('8', '7')) AS APT "
    cQry += " FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND SB1.D_E_L_E_T_ ='' "
    cQry += " LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH(NOLOCK) ON Z1_FILIAL = '"+xFilial("SZ1")+"' AND Z1_LINHA = SUBSTRING(B2_COD,4,2) AND SZ1.D_E_L_E_T_ ='' "
    cQry += " WHERE SB2.B2_FILIAL = '"+XFilial("SB2")+"'"
    cQry += "   AND SB2.D_E_L_E_T_ = '' "
    cQry += "   AND LEN(SB2.B2_COD) = 12 "
    cQry += "   AND SUBSTRING(SB2.B2_COD, 11, 2) IN('99') AND SUBSTRING(B2_COD,4,2) IN('97','98','99') "
    cQry += "   AND SB2.B2_QATU <> 0 "
    cQry += "   AND (SELECT COUNT(SC2.C2_PRODUTO) FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) WHERE SC2.C2_FILIAL ='"+XFilial("SB2")+"' AND SC2.D_E_L_E_T_ = '' AND SUBSTRING(SC2.C2_PRODUTO, 1, 10) = SUBSTRING(SB2.B2_COD, 1, 10) AND SC2.C2_DATRF = '' AND SUBSTRING(SC2.C2_PRODUTO, 11, 2) NOT IN('00','99')) = 0 "
    cQry += " ORDER BY 2 "


    TCQuery cQry ALIAS "TMPSB2" NEW
    DbSelectArea("TMPSB2")
    DbgoTop()					
	
	While !Eof()

		_aIteAju  := {}
		_aCabMov  := {}
		_aAuxMov  := {}

		If (TMPSB2->B2_QATU < (TMPSB2->B2_QATU + TMPSB2->B2_QEMP + TMPSB2->B2_RESERVA))
			DbSelectArea("TMPSB2")
			DbSkip()
			Loop
		Endif   

		Begin Transaction
			_aAuto     := {}
			_aItem     := {}
							
			cProduto2 := Iif(Alltrim(TMPSB2->Z1_REAPROV) = "",  '0986           ', TMPSB2->Z1_REAPROV)
			cLocDest  := Iif(TMPSB2->B2_LOCAL $ '02', '01', '10' )
			cNumDoc   := NextNumero("SD3",2,"D3_DOC",.T.) 

			aadd(_aAuto,{cNumDoc,dDataBase})  	
			aadd(_aItem,TMPSB2->B2_COD)	 												  //D3_COD		
			aadd(_aItem,TMPSB2->B1_DESC)												  //D3_DESCRI				
			aadd(_aItem,TMPSB2->B1_UM)													  //D3_UM		
			aadd(_aItem,TMPSB2->B2_LOCAL)												  //D3_LOCAL		
			aadd(_aItem,"")			   													  //D3_LOCALIZ		
			aadd(_aItem,cProduto2) 														  //D3_COD		
			aadd(_aItem,Posicione("SB1", 1, xFilial("SB1")+Alltrim(cProduto2), "B1_DESC"))//D3_DESCRI
			aadd(_aItem,Posicione("SB1", 1, xFilial("SB1")+Alltrim(cProduto2), "B1_UM"))  //D3_UM		
			aadd(_aItem,cLocDest)											              //D3_LOCAL		
			aadd(_aItem,"")				   												  //D3_LOCALIZ		
			aadd(_aItem,'ROT. TRANSF. AUTO.')											  //D3_NUMSERI		
			aadd(_aItem,criavar("D3_LOTECTL"))											  //D3_LOTECTL  		
			aadd(_aItem,"")         													  //D3_NUMLOTE		
			aadd(_aItem,criavar("D3_DTVALID"))  										  //D3_DTVALID					
			aadd(_aItem,0)																  //D3_POTENCI		
			aadd(_aItem,TMPSB2->B2_QATU)												  //D3_QUANT		
			aadd(_aItem,criavar("D3_QTSEGUM"))											  //D3_QTSEGUM
			aadd(_aItem,criavar("D3_ESTORNO"))  										  //D3_ESTORNO
			aadd(_aItem,criavar("D3_NUMSEQ"))   										  //D3_NUMSEQ 
			aadd(_aItem,"")																  //D3_LOTECTL
			aadd(_aItem,criavar("D3_DTVALID"))  										  //D3_DTVALID					
			aadd(_aItem,"")					   											  //D3_ITEMGRD
//			aadd(_aItem,criavar("D3_IDDCF"))											  //D3_IDDCF
			aadd(_aItem,criavar("D3_OBSERVA"))	       									  //D3_OBSERVA  		 
	
			DbSelectArea("SB2")
			DbSetOrder(1)
			SB2->(DBSEEK(xFilial("SB2")+TMPSB2->B2_COD+TMPSB2->B2_LOCAL))  

			lMsErroAuto := .f.
			aadd(_aAuto,_aItem)
		    DbSelectArea("SD3")					

			//PutMv("MV_ESTNEG" , "S")       
			If U_EstaBloqueado('SB2',TMPSB2->R_E_C_N_O_)
				Messagebox("Registro estava Bloqueado !! "+TMPSB2->R_E_C_N_O_,"Atenção...",64)    	
			    DbSelectArea("SB2")
			    MsUnLock()
			Endif

			PutMv("MV_ESTNEG" , "N")       
			MSExecAuto({|x,y| mata261(x,y)},_aAuto,3)				
		
			If lMsErroAuto			
				//PutMv("MV_ESTNEG" , "N")   
				//DisarmTransaction() 
	   			MostraErro()
		   		//Return()		
			Endif
		
		End Transaction
		
		DbSelectArea("TMPSB2")
		DbSkip()
		
	Enddo
	DbSelectArea("TMPSB2")	
	DbCloseArea()
	
Return      


