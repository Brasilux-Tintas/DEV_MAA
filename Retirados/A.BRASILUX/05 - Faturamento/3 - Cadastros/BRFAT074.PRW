#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFAT074 บ Autor ณ Cleber Orati       บ Data ณ  27/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Sele็ใo de Produtos p/ Transfer๊ncia Deposito Fechado      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFAT074()     
     Local _cUser
     //Local lVolJunto,nAuxQtde,nAuxVol
     Local cPerg
     Private oTempTable
     Private cTitulo
     Private lPerg
     Private oDlg2
     Private lJaFech := .f.
     Private lTelaJaFechada := .f. 
     
	 //Bloquear emissใo de TRANSF. para usuแrios nใo autorizados.
	 If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
     	 _cUser := alltrim(upper(cUsername))
      	 If !(_cUser $ "RAMON-GUSTAVO")
			 MsgBox("Acesso nใo autorizado!", "Aten็ใo!", "STOP")
             Return
         Endif 
   	 endif 

     
     Private aCampos := { {"MARCA"    ,"C",02,0},;
                          {"FLAG"     ,"C",01,0},;
                          {"CODPRO"  ,"C",15,0},;     
                          {"DESCRICAO"   ,"C",50,0},;
                          {"QTDE"  ,"N",06,0},;
                          {"VALOR"  ,"N",14,4},;
                          {"PESO"     ,"N",7,1}}
   						
     Private aCpoBro := { {"MARCA"    ,OemToAnsi("")           ,""       },;
                          {"CODPRO"  ,OemToAnsi("C๓d Prod")    ,"@R XXX99.99.999-99"     },;
                          {"DESCRICAO"   ,OemToAnsi("Descri็ใo")     ,"@!" },;
                          {"QTDE"  ,OemToAnsi("Qtde")    ,"@E 999,999" },; 
                          {"PESO"     ,OemToAnsi("P. Bruto")       ,"@E 99,999.9"     }}


 
	 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	 //ณ Cria indice condicional									  ณ
	 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 
	 /* desabilitado release 12.1.25
     _cNomArq1 := U_NovoArqTrab("dtc")
     _cNomArq1 += ".dtc"
     dbcreate(_cNomArq1, aCampos, "CTREECDX")
     Use (_cNomArq1) Alias "CPEDI" VIA "CTREECDX" New 
     */
     
     oTempTable := FWTemporaryTable():New( "CPEDI" )
     oTemptable:SetFields( aCampos )
     oTempTable:Create()
     DbSelectArea( "CPEDI" )
     DbSetOrder(1)

     cPerg   := "BRFAT074"
     cTitulo := OemToAnsi("Transf. Deposito")
     
     //ValidPerg(cPerg)
     lPerg := Pergunte(cPerg,.T.)   
	
	 If lPerg
 	     Processa({|| FAT0741() },cTitulo)
	 Endif

	 DbSelectArea("CPEDI")
	 DbCloseArea()
	 
	 If Valtype(oTempTable)=="O"
	 	oTempTable:Delete()
	 Endif
	 
	 //ferase(_cNomArq1)


Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0741  บ Autor ณ                    บ Data ณ  28/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para busca das informacoes.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0741()
       Local cQuery     := "",cQryBase,nValor
       Private cMarca  := GetMark()
       Private cNumPed := ""


cQryBase := "WITH TMP AS (SELECT ZZC_PRODUT AS CODPRO, ZZC_PEDIDO AS PEDIDO,"+;
"SUM(ZZC.ZZC_RETIRA - ZZC.ZZC_QUANTI) AS QTDE "+;
"FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (ZZC_FILIAL = C5_FILIAL) AND (ZZC_PEDIDO = C5_NUM) "+;
"WHERE (ZZC.D_E_L_E_T_ <> '*') AND (ZZC_FILIAL = '"+xFilial("ZZC")+"') AND (ZZC_SEPARA = 'N') AND (C5_DEPOSI = 'S') AND (C5_NOTA = '') "+;
"GROUP BY ZZC_FILIAL,ZZC_PRODUT,ZZC_PEDIDO "+;
"UNION ALL "+;
"SELECT ZC_FILIAL AS FILIAL,ZC_PRODUTO AS CODPRO,ZC_PEDIDO AS PEDIDO,SUM(ZC_QTDE*-1) AS QTDE "+;
"FROM "+RetSqlName("SZC")+" SZC WITH (NOLOCK) "+;
"WHERE (SZC.D_E_L_E_T_ <> '*') AND (ZC_FILIAL = '"+xFilial("SZC")+"') "+;
"GROUP BY ZC_FILIAL,ZC_PRODUTO,ZC_PEDIDO "+;
"UNION ALL "+;
"SELECT C6_PRODUTO AS CODPRO,C6_NUM AS PEDIDO,SUM(C6_QTDVEN) AS QTDE "+;
"FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = ZF_FILIAL) AND (ZG_CODIGO = ZF_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = C6_FILIAL) AND (ZG_PEDIDO = ('"+SUBSTR(cNumEmp,1,2)+"'+C6_NUM)) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
"WHERE (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = '"+xFilial("SZG")+"') AND (ZF_FLAG IN ('T','R')) AND (C5_NOTA = '') AND (C5_DEPOSI = 'S') "+;
"GROUP BY C6_PRODUTO,C6_NUM),TMP1 AS ("+;
"SELECT PEDIDO,CODPRO,MAX(B1_DESC) AS DESCRICAO,SUM(QTDE) AS QTDE,SUM(B1_PESBRU*QTDE) AS PESO "+;
"FROM TMP "+;
"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (TMP.CODPRO = B1_COD) "+;
"GROUP BY PEDIDO,CODPRO HAVING SUM(QTDE) > 0)) "

cQuery := cQryBase + "SELECT '"+cMarca+"' AS MARCA,CODPRO,MAX(DESCRICAO) AS DESCRICAO,SUM(QTDE) AS QTDE,SUM(PESO) AS PESO "+;
"FROM TMP1 "+;
"GROUP BY CODPRO "+;
"ORDER BY PESO DESC,CODPRO ASC"
TCQUERY cQuery NEW ALIAS "QPED"   
cQuery := cQryBase + "SELECT * FROM TMP1 ORDER BY CODPRO,PEDIDO"
TCQUERY cQuery NEW ALIAS "PEDPROD"   

dbselectarea("SB1")
dbsetorder(1)
dbselectarea("SB5")
dbsetorder(1)

	DbSelectArea("QPED")
	DbGoTop()
    ProcRegua(100)
       While !Eof()
             IncProc("Selecionando registros ...")
       		nValor := 0
			dbselectarea("SB1")
            dbseek(xFilial("SB1")+QPED->CODPRO)
            if found()           
            	IF ALLTRIM(SB1->B1_TIPO) $ "PA-PI"
	            	if SB1->B1_ESTOQUE = "S"
    	        		nValor := SB1->B1_PRV1
        	    	else
            	   		dbselectarea("SB5")
            			dbseek(xFilial("SB5")+QPED->CODPRO)
            			if found()
            				nValor := SB5->B5_PRV2
            			endif
            		endif
            	ELSE
            		nValor := SB1->B1_UPRCD1
            	endif
            endif
			             
             RecLock("CPEDI",.t.)
                CPEDI->MARCA     := QPED->MARCA
                CPEDI->FLAG      := "S"
                CPEDI->CODPRO    := QPED->CODPRO
                CPEDI->DESCRICAO := QPED->DESCRICAO
                CPEDI->QTDE      := QPED->QTDE
                CPEDI->PESO      := QPED->PESO   
                CPEDI->VALOR     := nValor
             MsUnLock()
             DbSelectArea("QPED")
             DbSkip()
       Enddo

       DbSelectArea("QPED")
       DbCloseArea()
       FAT0742()
dbselectarea("PEDPROD")
dbclosearea()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0742  บ Autor ณ                    บ Data ณ  04/10/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para mostrar dados na tela do usuario.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0742()       
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       DbSelectArea("CPEDI")
       DbGoTop()

       @ 012,10 To 400,800 Dialog oDlg2 Title OemToAnsi("Itens a Transferir")
       @ 005,005 To 190,360 Browse "CPEDI" Fields aCpoBro ENABLE "FLAG" MARK "MARCA"
       @ 003,363 To 107,395      
       
       @ 010,365 BMPBUTTON Type  1 Action FAT0743()  //ok
       @ 030,365 BMPBUTTON Type  5 Action FAT0744() //parametros
       @ 050,365 BMPBUTTON Type  2 Action FAT0746() //cancelar

       
/*
       @ 10,365 BMPBUTTON Type  1 Action FAT0743()  //ok
       @ 030,365 BMPBUTTON Type  5 Action FAT0744() //parametros
       @ 050,365 BMPBUTTON Type  6 Action FAT0745() //imprimir
       @ 070,365 BMPBUTTON Type  2 Action FAT0746() //cancelar
       @ 090,365 BMPBUTTON Type  3 Action FAT0747() //excluir  
*/       
       Activate Dialog oDlg2 Centered
       If !lJaFech
          lTelaJaFechada := .t.
          FAT0746()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0743  บ Autor ณ                    บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para gerar pedido de transferencia                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0743()
       //Local cQuery
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao da consulta...                                  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
       dbselectarea("SZC")
       dbsetorder(1)
       DbSelectArea("CPEDI")
       DbGoTop()
       lRet := MsgBox("Gera Pedidos Transf. ?","Pergunta","YESNO")
       If lRet
          FAT0745()
       Else
          Return
       Endif
       DbSelectArea("CPEDI")
       DbGoTop()
       While !Eof()
             If Marked("MARCA")   
       			dbselectarea("PEDPROD")
       			dbgotop()
       			LOCATE FOR ALLTRIM(PEDPROD->CODPRO) = ALLTRIM(CPEDI->CODPRO)
                while !eof() .and. (ALLTRIM(PEDPROD->CODPRO) == ALLTRIM(CPEDI->CODPRO))
                	
	       			dbselectarea("SZC")
    	   			dbseek(xFilial("SZC")+PEDPROD->PEDIDO+PEDPROD->CODPRO)
    	   			if !found()
    	   				reclock("SZC",.T.)
    	   				SZC->ZC_FILIAL := xFilial("SZC")
    	   				SZC->ZC_PEDIDO := PEDPROD->PEDIDO
    	   				SZC->ZC_PRODUTO := PEDPROD->CODPRO
    	   			else 
    	   				reclock("SZC",.F.)  
    	   			endif
    	   			SZC->ZC_QTDE += PEDPROD->QTDE
    	   			msunlock()
	       			dbselectarea("PEDPROD")
	       			dbskip()
	       		enddo 
             Endif  
             DbSelectArea("CPEDI")
             DbSkip()
       Enddo
       If !lTelaJaFechada
          Close(oDlg2)
       Endif
       lJaFech := .t.
       DbSelectArea("CPEDI")
       DbCloseArea()             	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0744  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para alteracao dos paramentros da consulta.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0744()
       lPerg := Pergunte(cPerg,.T.)
       If lPerg
          DbSelectArea("CPEDI")
          ZAP
          Close(oDlg2)
          FAT0741()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0745  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao principal para geracao dos pedidos de transf        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0745()         
Local nContItens,nPeso,nMaxItens,nMaxPeso
Local aPed,cObs,aPedRel,cAux,aItensPed,cItem
nMaxItens := 150  //Qtde mแxima de itens por NF
nMaxPeso := 35000 //Peso mแximo para o caminhใo

	aPed := {}
	cObs = "Transfer๊ncias de Mercadorias para DEPำSITO FECHADO!!"
 	//ATENวรO! Ao incluir item, observar o seek em SC5 abaixo!!!!
  	aAdd(aPed, {"C5_TIPO"    , "N"               , NIL})
    aAdd(aPed, {"C5_CLIENTE" , "023818"          , NIL})
    aAdd(aPed, {"C5_CONDPAG" , "001"             , NIL})
	aAdd(aPed, {"C5_EMISSAO" , dDataBase         , NIL})
	aAdd(aPed, {"C5_TRANSP"  , "00250"           , NIL})
 	aAdd(aPed, {"C5_REDESP"  , ""                , NIL})
    aAdd(aPed, {"C5_TPFRETE" , "C"                               , NIL})       
    aAdd(aPed, {"C5_DEPOSI"  , "N"                               , NIL})       
	aAdd(aPed, {"C5_OBSNF"   , cObs, NIL})

aItensPed := {}
nContItens := 0
nPeso := 0
DbSelectArea("CPEDI")
DbGoTop()
While !Eof()
	If Marked("MARCA")  
		nContItens++
		nPeso += CPEDI->PESO
		if (nContItens > nMaxItens) .or. (nPeso > nMaxPeso)
			nContItens--
			nPeso -= CPEDI->PESO
			IncPed(aPed,aItensPed)			
			//Incluir o pedido    
			nContItens := 0
			nPeso := 0  
			aItensPed := {}
			LOOP
		endif  
		If nContItens < 100
			cItem = padl(Alltrim(Str(nContItens)),2,"0")
		Else
			cItem = Alltrim(Str(nContItens))
			cItem = SubStr(cAux, Len(cAux), 1)
   			cItem = Chr(Int((nContItens - 100)/10)+65) + cAux
		Endif  

		aPedRel := {}   
		aAdd(aPedRel, {"C6_ITEM"   , cItem                , Nil})
  		aadd(aPedRel, {"C6_PRODUTO", CPEDI->CODPRO     , NIL})
		aadd(aPedRel, {"C6_QTDVEN" , CPEDI->QTDE, NIL})
		aadd(aPedRel, {"C6_PRCVEN" , CPEDI->VALOR, NIL})
		aadd(aPedRel, {"C6_TES"    , "822", NIL})
		aadd(aItensPed, aPedRel)
		
	endif
	DbSelectArea("CPEDI")
	dbskip()
enddo 
//Incluir pedido remanescente, caso haja	
if len(aItensPed) > 0
	IncPed(aPed,aItensPed)			
endif 
		

	
       SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
       SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
       SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
       SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
       SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
       SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
       SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
       Private CbTxt    := ""
       Private CbCont   := 0
       Private nOrdem   := 0
       Private Alfa     := 0
       Private Z        := 0
       Private M        := 0
       Private tamanho  := "P"
       Private limite   := 80
       Private titulo   := "PEDIDOS - RELATORIO P/ PRODUCAO"
       Private cDesc1   := PADC("Programa para emitir Pedidos",74)
       Private cDesc2   := PADC(" ",74)
       Private cDesc3   := PADC(" ",74)
       Private cCabec   := PADC("PEDIDOS - RELATำRIO P/ PRODUCAO",27)
       Private cCabPro  := ""
       Private cNatureza:= ""
       Private aReturn  := { "Especial", 1,"Administracao", 2, 2, 1,"",1 }
       Private nomeprog := "FAT0765"
       Private cPerg    := ""
       Private nLastKey := 0
       Private lContinua:= .T.
       Private _nLin    := 90
       Private nCol     := 60
       Private wnrel    := "FAT0765"
       Private nTipo    := 18
       Private m_pag    := 01
       //                   012345678901234567890123456789012345678901234567890123456789012345678901234567890
       Private cCabec1  := "PRODUTO "
       Private cCabec2  := "PEDIDO    CLIENTE                                  REG/REGTR QUANTIDADE LOCALIZ."
       Private cCabec3  := ""
       Private nTamNf   := 83     // Apenas Informativo
       Private cString  := "SC9"

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Envia controle para a funcao SETPRINT                        ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       Pergunte("FAT076",.F.)

       wnrel := SetPrint(cString,wnrel,,Titulo,cDesc1,cDesc2,cDesc3,.t.,,.t.,"P")

       If nLastKey == 27
          Return
       Endif
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Verifica Posicao do Formulario na Impressora                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SetDefault(aReturn,cString)

       If nLastKey == 27
          Return
       Endif

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Inicio do Processamento do Relatorio                         ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       Processa({|| FAT07653() },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT07651 บ Autor ณ Luis Gustavo       บ Data ณ  07/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para impressao do cabecalho do relatorio.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT07651()
       DbSelectArea("SC5") // Cabecalho dos Pedidos
       DbSetorder(1)
       DbSeek(xFilial("SC5")+cPedido,.F.)
       
       Dbselectarea("SE4") // Cond. Pagamento
       Dbsetorder(1)
       Dbseek(xFilial("SE4")+SC5->C5_CONDPAG)

       nLin = 1
       @ nLin,000 psay "PEDIDOS - RELATORIO PARA PRODUCAO"
	   @nLin, 035 psay "EXP. POR : "+cUsername
       @ nLin,060 psay "EXPEDICAO : "+DTOC(DATE())
       nLin += 1
       @nLin, 000 PSAY REPLICATE("_",80)
       nLin+=1
       @ nLin,000 psay "PEDIDO : "+SubStr(cnumemp,1,2)+"-"+cPedido
       @ nLin,020 psay "COND. PAGTO : "+SC5->C5_CONDPAG+"-"+SE4->E4_DESCRI

       nPercSubst := 0 // Perc. de Lucro p/ Subst. Tributแria
       If (SC5->C5_TIPO $ "D_B")
          Dbselectarea("SA2")
          DbSetorder(1)
          DbSeek(xFilial("SA2")+SC5->C5_CLIENTE,.F.)
          If found()
             DbSelectArea("SZ8")
             DbSeek(xFilial("SZ8")+SA2->A2_EST+SA2->A2_CLAS)
             If found()
                nPercSubst := SZ8->Z8_PERC
             Endif
          Endif
       Else
          DbSelectArea("SA1")
          DbSetorder(1)
          DbSeek(xFilial("SA1")+SC5->C5_CLIENTE,.F.)
          If found()
             DbSelectArea("SZ8")
		     DbSeek(xFilial("SZ8")+SA1->A1_EST+SA1->A1_CLAS)
             If Found()
                nPercSubst := SZ8->Z8_PERC
             Endif
             cClas := ""
             If SA1->A1_CLAS $ "C"
                cClas := "Consumidor Final" 
             ElseIf SA1->A1_CLAS $ "I"
                    cClas := "Industrializacao" 
             ElseIf SA1->A1_CLAS $ "N"
                    cClas := "Nao Contribuinte" 
             ElseIf SA1->A1_CLAS $ "V"
                    cClas := "Comercio/Revenda" 
             ElseIf SA1->A1_CLAS $ "D"
                    cClas := "Com. Distrib." 
             Else
                cClas := "" 
             Endif
          Endif
       Endif
       nLin += 1
       @ nLin,000 psay "CLIENTE : "+SC5->C5_CLIENTE+"-"+iif(SC5->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME)+"   "+iif(SC5->C5_TIPO $ "D_B","",cCLAS)
       nLin += 1
       @ nLin,000 psay "FONE    : "+iif(SC5->C5_TIPO $ "D_B",TRIM(SA2->A2_DDD)+"-"+SA2->A2_TEL,TRIM(SA1->A1_DDD)+"-"+SA1->A1_TEL)
       @ nLin,035 psay "CIDADE : "+AllTrim(iif(SC5->C5_TIPO $ "D_B",SA2->A2_MUN,SA1->A1_MUN)) + "-" + iif(SC5->C5_TIPO $ "D_B",SA2->A2_EST,SA1->A1_EST)
       nLin+= 1
       @ nLin,000 psay "ENDERECO : "+ALLTRIM(SUBSTR(iif(SC5->C5_TIPO $ "D_B",SA2->A2_END,SA1->A1_END),1,40))+" - "+iif(SC5->C5_TIPO $ "D_B",SA2->A2_BAIRRO,SA1->A1_BAIRRO)
       nLin += 1
       DbSelectArea("SA3")
       dbSetorder(1)
       dbseek(xFilial("SA3")+SC5->C5_VEND1)
       If Found()  
          @ nLin,000 psay "REPRES : "+SC5->C5_VEND1+"-"+SA3->A3_NOME
       Endif
       If !Empty(SC5->C5_PEDPROG)
          @ nLin,059 PSAY "PED. PROG.: "+DTOC(SC5->C5_PEDPROG)
       Endif
       nLin += 1
       DbSelectArea("SA4")
       DbSetOrder(1)
       DbSeek(xFilial("SA4")+SC5->C5_TRANSP)
       If Found()
          @ nLin,000 psay "TRANSPORTADORA : "+SC5->C5_TRANSP+"-"+SA4->A4_NOME
       Endif
       nLin += 1
       DbSeek(xFilial("SA4")+SC5->C5_REDESP)
       If Found()
          @ nLin,000 psay "REDESPACHO : "+SC5->C5_REDESP+"-"+ALLTRIM(SA4->A4_NOME)+" Regiใo : "+alltrim(SA4->A4_REGIAO)
       Endif
       If !EMPTY(SA1->A1_ENDENT)
          If !SC5->C5_TIPO $ "D_B"
             cxEntrega := "ENTREGA: "+Alltrim(SA1->A1_ENDENT)+Iif(Empty(SA1->A1_BAIRROE),""," - BAIRRO : "+ALLTRIM(SA1->A1_BAIRROE))+IIf(Empty(SA1->A1_CEPE),""," - "+Transform(SA1->A1_CEPE,"@R 99999-999"))
          Endif
       Endif

       nLin += 1
       @ nLin,000 psay replicate("=",80)
       nLin += 1
       @ nLin,000 psay "COD PRODUTO"
       @ nLin,013 PSAY "DESCRICAO"
       @ nLin,044 psay "  QTDE"
       @ nLin,051 psay "UNIDADE"
       @ nLin,062 psay "QUADRTE"
       @ nLin,070 psay "  Pr. Unit."
       nLin += 1
       @ nLin,000 psay replicate("=",80)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT07652 บ Autor ณ Luis Gustavo       บ Data ณ  07/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para impressao do rodape do relatoio.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT07652()
       nAux = 60 - nLin
       nLin = nLin+nAux
       @ nLin,000 psay replicate("_",80)
       nLin = nLin+1
       @nlin,000 PSAY "Pagina: "
       @nLin,8 psay nPag picture "99"
       @nLin,17 psay "CLIENTE : "+SC5->C5_CLIENTE+"-"+substr(iif(SC5->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME),1,30)
       @nLin,64 psay "|PED : "+SubStr(cnumemp,1,2)+"-"+cPedido
       nLin = nLin+1
       @nLin,000 psay replicate("_",80)
       nPag+=1
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT07653 บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para impressao do relatorio.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT07653()
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Inicializa  regua de impressao                            ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       Local nValorIpi  := 0
       Local nSubstrib  := 0
       Local nAliqInt   := 0
       Local nAliqSol   := 0
       Local cUf := ""
       //Local cAux
       //Local cAux1
       Local nPerIcm    := 0     
       Local nBaseSubst := 0
       Local nBaseIcms  := 0
       Local cUn        := ""
       Local nAuxIpi    := 0
       Local nLucroST   := 0
       Local nAuxIcms   := 0
       Local nFrete
       Local nValorPed
       //Local cComp,cDescrEmba, cEmpresa, nRelVol, nSomaVol, nQtdComp
       Local lGeraDuplic
       Local cNumPed    := "('"
       Local nVol       := 0
       Local i
       Local nTXPIS     := GETMV("MV_TXPIS")
       Local nTXCOFIN   := GETMV("MV_TXCOFIN")
       
       Private nSomaVlrProd
       Private cPedido
       Private nPercSubst
       Private nDescZFR   := 0 // Desc. Zona Franca
       Private cQuery
       Private nImp     := 0
       Private lAbortPrint := .f.
       Private cxEntrega := ""
       Private aResumo  := {}
       
       DbSelectArea("CPEDI")
       DbGoTop()
       ProcRegua(RecCount())
       While !Eof()
			//Cleber (18/10/10) -> Verificar se rel. de volumes estใo coerentes antes     
	 		//U_VerificaVolumes(CPEDI->PEDIDO) //Cleber(27/08/15) -> retirado

             If Marked("MARCA") .and. CPEDI->FLAG $ ' '
                _cEmp := CPEDI->EMPRESA
                cQuery := ""
                cQuery := cQuery + "SELECT C6.C6_NUM AS PEDIDO, B2.B2_LOCALIZ AS QUADRANTE, C6.C6_PRODUTO AS PRODUTO, C6.C6_TES AS TES, C6.C6_VALOR AS VALOR, C6.C6_QTDVEN AS QTDEVEN, C6.C6_DESCRI AS DESCRICAO, C6.C6_LOCAL AS LOCAL, C6.C6_PRCVEN AS PRECO,C5_ESPECI4, C6.C6_PALLET, "
                cQuery := cQuery + "B1_ESTOQUE, 'ORDEM' = CASE WHEN SUBSTRING(C6.C6_PRODUTO, 1, 2) = 'BM' THEN C6.C6_NUM+'ZZ'+SUBSTRING(C6_PRODUTO,4,9)+SUBSTRING(C6_PRODUTO,1,3) ELSE C6.C6_NUM+SUBSTRING(C6_PRODUTO,4,9)+SUBSTRING(C6_PRODUTO,1,3) END "
                cQuery := cQuery + "FROM SC6"+cEmpAnt+"0 C6 WITH (NOLOCK) "
                cQuery := cQuery + "LEFT OUTER JOIN SC5"+cEmpAnt+"0 C5 WITH (NOLOCK) ON ((C5.C5_FILIAL+C5.C5_NUM) = (C6.C6_FILIAL + C6.C6_NUM)) AND (C5.D_E_L_E_T_ <> '*') "
                cQuery := cQuery + "LEFT OUTER JOIN SB1"+iif(cEmpAnt == "02","01",cEmpAnt)+"0 B1 WITH (NOLOCK) ON (C6.C6_FILIAL = B1.B1_FILIAL) AND (C6.C6_PRODUTO = B1.B1_COD) AND (B1.D_E_L_E_T_ <> '*') "
                cQuery := cQuery + "LEFT OUTER JOIN SB2"+iif(cEmpAnt == "02","01",cEmpAnt)+"0 B2 WITH (NOLOCK) ON (B1.B1_FILIAL = B2.B2_FILIAL) AND (B1.B1_LOCPAD = B2.B2_LOCAL) AND (B1.B1_COD = B2.B2_COD) AND (B2.D_E_L_E_T_ <> '*') "
                cQuery := cQuery + "WHERE "
                cQuery := cQuery + "  (C6.C6_FILIAL = '"+xFilial("SC6")+"') "
                cQuery := cQuery + "  AND C6.C6_NUM = '"+CPEDI->PEDIDO+"' "
                cQuery := cQuery + "  AND C6.D_E_L_E_T_ <> '*' "
                cQuery := cQuery + "  ORDER BY ORDEM "

                TCQuery cQuery NEW ALIAS "TCQP"

                dbSelectArea("ZZO")   // Qtde de Volumes por Embalagem
                dbSetOrder(1)
				
                dbSelectArea("SF4")   // TES
                dbSetOrder(1)

                dbselectarea("SB1")
                dbsetorder(1)

                dbSelectArea("SZ5")
                dbsetorder(1)

                dbSelectArea("SZ8")   // Estados Subst. Trib.
                dbsetorder(1)         // Z8_FILIAL+Z8_EST+Z8_TIPOCLI

                nLin = 0
                dbSelectArea("TCQP")
                dbgotop()
                While !EoF() .and. lContinua
                      cPedido        := TCQP->PEDIDO
                      nSomaVlrProd   := 0 // Usado para saber o valor total do produto antecipadamente p/ efeito de cแlc. de Subst. Trib. proporcional em rela็ใo ao frete
                      lGeraDuplic    := GeraDuplic(cPedido) // Verifica se tem algum item que nใo gera duplicata
                      nPag            = 1
                      nValorPed      := 0 // Valor Total do Pedido
                      nValorIpi      := 0   // Guarda o valor total do IPI
                      nSubstrib      := 0 // Guarda o valor total da Subst. Trib.
                      nDescZFR       := 0 //Vlr do Desc. 7% Zona Franca
                      nDescPisCof    := 0 //Vlr do Desc. Pis/Cofins Zona Franca Manaus, portaria Suframa 162/2005
                      lCliZFR        := .f.
                      If lAbortPrint
                         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
                         lContinua := .F.
                         Exit
                      Endif
                      FAT07651()

                      If !lGeraDuplic
                         nLin++
                         @nLin,00 psay "              ***********************************************"
                         nLin++
                         @nLin,00 psay "              *           PEDIDO SEM DUPLICATA!!            *"
                         nLin++
                         @nLin,00 psay "              ***********************************************"
                      Else
                         If SC5->C5_NAOCONF == "S"
                            nLin++
                            @nLin,00 psay "           ****************************************************"
                            nLin++
                            @nLin,00 psay "           *    Pedido em DESACORDO com a politica p/ Revenda *"
                            nLin++
                            @nLin,00 psay "           ****************************************************"
                         Endif
                      Endif
                      lCliZFR := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_CODCID") $ '002054.002259' .and. Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_CALCSUF") $ 'S'
					  cUf := iif(SC5->C5_TIPO $ "D_B",SA2->A2_EST,SA1->A1_EST)                    
                      // Det. da Aliq. ICM interna do estado e Alํquto de ICMS Pr๓prio
                      nAliqInt := U_Aliqinterna(cUf) //val(SUBSTR(cAux,at(cUf,cAux)+2,2))/100
                      nPerIcm := AliqIcms(SC5->C5_TIPO,'S',SC5->C5_TIPOCLI)/100 // Alํquota de ICMS
                                          //nSomaVlrProd := ValorPed(cPedido)  // Calc. vlr. ped antecipadamente, p/ fazer proporcao de frete 
                      lDescPisCof := .f.
                      nPallets    := 0
                      dbselectarea("TCQP")
                      While !eof() .and. (TCQP->PEDIDO == cPedido) .AND. lContinua
                            If lAbortPrint
                               @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
                               lContinua := .F.
                               Exit
                            Endif    
				            // Determinar em lVolJunto se produto junta volume c/ outros ou nใo, p/ efeito de cแlculo de volumes
    	    			    lVolJunto := U_VolJunto(TCQP->PRODUTO) 

                            //**************************************************************************
                            DbSelectArea("SB1")
                            Dbseek(xFilial("SB1")+TCQP->PRODUTO)
                            // Cแlculo da Subst. Trib. e IPi
                            DbSelectArea("SF4")
                            DbSeek(xFilial("SF4")+TCQP->TES)
                            If Found()    
                            	nAliqSol := nAliqInt + iif((cUf = "RJ") .AND. (SF4->F4_ISEFECP <> '1'),0.01,0) // Consid. 1% fundo pobreza RJ
                            		
                               If (SF4->F4_PISCRED = '4') .AND. (SF4->F4_PISCOF = '3') .and. lCliZFR
                                  lDescPisCof := .t.
                               Endif 
                               nAuxIpi := 0
                               If SF4->F4_IPI == "S"
                                  nAuxIpi := TCQP->VALOR * (SB1->B1_IPI/100)
                                  nValorIpi += nAuxIpi
                               Endif
                               If SF4->F4_INCSOL == "S"  
                               	  nFrete := (TCQP->VALOR/nSomaVlrProd)*SC5->C5_FRETE
                                  nBaseIcms = TCQP->VALOR + nFrete+ iif(SF4->F4_INCIDE == "S",nAuxIpi,0)
                                  nAuxIcms := nBaseIcms * nPerIcm                               
                                  nLucroST := (1+(nPercSubst/100))
                                  nBaseSubst := (TCQP->VALOR + nFrete + nAuxIpi)*nLucroST*IIF(SF4->F4_BSICMST > 0,SF4->F4_BSICMST/100,1)
                                  nSubstrib += (nBaseSubst*nAliqSol) - nAuxIcms
                               Endif
                            Endif
				
                            cUn := SB1->B1_UM  // Guarda Unidade de Medida, Inicialmente
                            //Det. dos Pesos Liq./Bruto e da Qtde de Volumes
                            If (LEN(alltrim(TCQP->PRODUTO)) == 12) .and. (substr(TCQP->PRODUTO,11,2) # "00")

                               dbSelectArea("SZ5")
                               dbseek(xFilial("SZ5")+substr(TCQP->PRODUTO,11,2))
                               If found()   
                                  cUn := "("+ALLTRIM(SZ5->Z5_DESCR)+")" // Guardar a descri็ใo da Embalagem
                               Endif
                            Endif
                            //*******************************************************************
                            nLin += 1
                            @ nLin,000 psay ALLTRIM(TCQP->PRODUTO)+iif(TCQP->B1_ESTOQUE == 'S', "*", "")
                            @ nLin,013 psay substr(TCQP->DESCRICAO,1,30)
                            @ nLin,044 psay TCQP->QTDEVEN picture "@E 99,999"  //*IIF(LEN(ALLTRIM(TCQP->C5_ESPECI4)) > 0,2,1)
                            @ nLin,051 psay substr(cUn,1,10)
                            If !empty(TCQP->QUADRANTE)           
                               cAuxQ = alltrim(alltrim(TCQP->QUADRANTE))
                               cAuxQ = substr(cAuxQ,1,7)
                               @ nLin,062 psay cAuxQ
                            Endif  
                            

                            @ nLin, 70 psay TCQP->PRECO picture "@E 999,999.99"
                            nValorPed += TCQP->QTDEVEN*TCQP->PRECO
                            nPallets  += TCQP->C6_PALLET
                            If nLin >= 59
                               FAT07652()
                               FAT07651()
                            Endif
                            nLin += 1
                            @ nLin,000 psay replicate("_",80)
                            If nLin >= 59
                               FAT07652()
                               FAT07651()
                            Endif
                            DbSelectArea("TCQP")
                            Dbskip()
                            IncProc("Processando relatorio!!!")
                      Enddo                             
                      nValorPed += SC5->C5_FRETE
                      If !(SC5->C5_TIPO $ "D_B") .and. (SA1->A1_CALCSUF != "N") .and. !empty(SA1->A1_SUFRAMA)
                         nDescZFR := nValorPed*0.07
                      Endif
                      If lDescPisCof
                         //nDescPisCof := nValorPed*(GETMV("MV_TXPIS")+GETMV("MV_TXCOFIN"))/100 desabilitado release 12.1.25
                         nDescPisCof := nValorPed*(nTXPIS+nTXCOFIN)/100 
                      Endif 
                      nLin += 1
                      @ nLin,000 psay "QTDE DE VOLUMES : "
                      @ nLin,018 psay SC5->C5_VOLUME1 picture "@E 9,999"
                      @ nLin,024 psay "CUBAGEM : "
                      @ nLin,034 psay SC5->C5_VOLUME2 picture "@E 999.999"
                      @ nLin,043 psay "VALOR TOTAL DOS PRODUTOS : "
                      @ nLin,070 psay (nValorPed - nDescZFR - nDescPisCof) picture "@E 999,999.99"
                      nLin += 1                
                      /*
                      //Cleber (21/08/13) -> Retirei inf. impostos, prefer๊ncia tirar Pr้-Nota
                      @ nLin,000 psay "IPI : "
                      @ nLin,006 psay nValorIpi picture "@E 99,999.99"
                      @ nLin,016 psay "SUBST. TRIB. : "
                      @ nLIn,031 psay nSubstrib picture "@E 99,999.99"
                      @ nLin,045 psay "VALOR TOTAL DO PEDIDO : "
                      @ nLin,070 psay ((nValorPed-nDescZFR - nDescPisCof)+nValorIpi+nSubstrib) picture "@E 999,999.99"
                      */
                      
                      If nLin >= 59
                         FAT07652()
                         FAT07651()
                      Endif
                      nLin +=1
                      @ nLin,000 psay replicate("-",80)
                      If nLin >= 59
                         FAT07652()
                         FAT07651()
                      Endif
                      //cMens = u_tiraacento(alltrim(SC5->C5_OBS))
                      cMens = u_tiraacento(alltrim(MSMM(SC5->C5_OBSSC5)))
                      If nDescZFR > 0
                         cMens += Iif(!empty(cMens),"**","")+"Desc. Zona Franca(7%) R$ "+alltrim(transform(nDescZFR,"999,999.99"))
                      Endif
                      If nDescPisCof > 0
                         cMens += Iif(!empty(cMens)," **","")+"Desc. PIS/COFINS ZFM (9,25%)R$ "+Alltrim(Transform(nDescPisCof,"999,999.99"))
                      Endif
                      nQtdeLin := 0
                      If !empty(cMens)
                         nQtdeLin = len(cMens)/80
                         If int(nQtdeLin) < nQtdeLin
                            nQtdeLin = int(len(cMens)/80)+1
                         Endif
                      Endif
                      For i = 1 to nQtdeLin
                          cAuxM = substr(cMens,i*80 - 79,80)
                          nLin += 1
                          @ nLin,000 psay cAuxM
                          If nLin >= 59
                             FAT07652()
                             nLin := 1
                          Endif
                      Next        
                      nLin += 1
                      @ nLin,000 psay replicate("-",80)
                      If nLin >= 59
                         FAT07652()
                         nLin := 1
                      Endif
                      nLin += 1
                      @ nLin,000 psay "Embalagem "
                      @ nLin,025 psay "          Qtde."
                      @ nLin,042 psay "  Qtde. Volumes"
                                     //9,999.99999
                      @ nLin,058 psay "Cubagem(M3)"
                      If nLin >= 59
                         FAT07652()      
                         nLin := 1
                      Endif
                      dbselectarea("ZZO")
                      dbseek(xFilial("ZZO")+cPedido)
                      while !eof()  .and. (ZZO->ZZO_FILIAL = xFilial("ZZO")) .and. (ZZO->ZZO_PEDIDO == cPedido)
                          	nLin+=1    
                           dbSelectArea("SZ5")
                           dbseek(xFilial("SZ5")+ZZO->ZZO_EMBA)
                      		If found()   
                           		cUn := +ALLTRIM(SZ5->Z5_DESCR)
                        	else 
                        		cUn := "Diversos"
                        	Endif
                          	@ nLin,000 psay ZZO->ZZO_EMBA+"-"+alltrim(substr(cUn,1,18))
							@ nLin,025 psay ZZO->ZZO_QTDE picture "@E 999,999,999,999"
                          	@ nLin,042 psay ZZO->ZZO_QTDVOL picture "@E 999,999,999,999"
                          	@ nLin,058 psay ZZO->ZZO_CUBAGE picture "@E 9,999.99999"
                          	nVol += ZZO->ZZO_QTDVOL
                          	If nLin >= 59
                             	FAT07652()
                             	nLin := 1
                          	Endif
                          	dbselectarea("ZZO")
                          	dbskip()
                      enddo 
                      nLin := nLin + 2
                      If !Empty(cxEntrega)
                         @ nLin,000 PSAY "OBSERVAวรO: "
                         nLin := nLin + 1
                         @ nLin,000 PSAY cxEntrega
                         nLin := nLin + 2
                      Endif
                      @ nLin, 000 PSAY "PALLET(S): "+Transform(nPallets, "@E 999.99")
                      nLin += 1

                      nAux = 60 - nLin
                      nLin = nLin+nAux
                      @ nLin,000 psay replicate("_",80)
                      nLin = nLin+1
                      @ nlin,000 PSAY "Pagina: "
                      @ nLin,8 psay nPag picture "99"
                      @ nLin,17 psay "CLIENTE : "+SC5->C5_CLIENTE+"-"+substr(iif(SC5->C5_TIPO $ "D_B",SA2->A2_NOME,SA1->A1_NOME),1,30)
                      @ nLin,64 psay "|PED : "+SubStr(cnumemp,1,2)+"-"+cPedido
                      nLin = nLin+1
                      @ nLin,000 psay replicate("_",80)
                      nPag += 1
                      dbSelectArea("TCQP")
                Enddo
                DbSelectArea("TCQP")
                DbCloseArea()
                DbSelectArea("CPEDI")
                RecLock("CPEDI",.f.)
                   CPEDI->FLAG := 'S'
                MsUnLock()
                aadd(aResumo,{CPEDI->EMPRESA+"-"+CPEDI->PEDIDO           ,;
                              CPEDI->CLIENTE+"-"+CPEDI->NOME             ,;
                              ALLTRIM(CPEDI->MUNICIPIO)+"-"+CPEDI->ESTADO,;
                              Dtoc(CPEDI->DTEMISSAO)                     ,;
                              Dtoc(CPEDI->DTCREDITO)                     ,;
                              ''                                         ,;
                              nVol                                       ,;
                              Dtoc(CPEDI->DTPEDPROG)                     })
                nVol := 0
                nImp := nImp + 1
                If CPEDI->EMPRESA $ "01"
                   DbSelectArea("SC5")
                   DbSetOrder(1)
                   DbSeek(xFilial("SC5")+CPEDI->PEDIDO,.t.)
                   If Found()
                      RecLock("SC5",.f.)
                         SC5->C5_FLAG := "S"
                      MsUnLock()
                      RecLock("ZZB", .t.)
                         ZZB->ZZB_FILIAL := xFilial("ZZB")
                         ZZB->ZZB_PEDIDO := SC5->C5_NUM
                         ZZB->ZZB_IDLOG  := 'IAU'
                         ZZB->ZZB_USRLOG := cUsername
                         ZZB->ZZB_DATLOG := dDataBase
                         ZZB->ZZB_HORLOG := Time()
                      MsUnLock()
                      cNumPed += CPEDI->PEDIDO+"','"
                   Endif
                   /*********************************************************************************************/
                   /***                                                                                       ***/
                   /*********************************************************************************************/
                Else
                   cQuery := ""
                   cQuery := cQuery + "UPDATE SC5020 "
                   cQuery := cQuery + "SET C5_FLAG = 'S' "
                   cQuery := cQuery + "WHERE C5_FILIAL = '01' AND C5_NUM = '"+CPEDI->PEDIDO+"'"
                   
                   TcSqlExec(cQuery)
                Endif
             Endif
             DbSelectArea("CPEDI")
             DbSkip()
       Enddo   
       cNumPed := SubStr(cNumPed, 1, Len(cNumPed) - 2)+")"
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ                      FIM DA IMPRESSAO                        ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
       If nImp > 0
          FAT0769(@aResumo)
          FAT07654(aResumo)
          //FAT0768(cNumPed, mv_par01, mv_par02)
       Endif

       DbSelectArea("CPEDI")
       DbGoTop()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT07654 บ Autor ณ Luis Gustavo       บ Data ณ  08/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para impressao do resumo final.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT07654( aResumo )
       Local nX
       Local nCont
       Local cCabec1, cCabec2, cCabec3
       //Local nxContFl   := 1
       Private CbTxt    := ""
       Private CbCont   := 0
       Private nOrdem   := 0
       Private Alfa     := 0
       Private Z        := 0
       Private M        := 0
       Private tamanho  := "G"
       Private limite   := 220
       Private titulo   := "PEDIDOS LIBERADOS, PRONTOS P/ FATURAR"
       Private cDesc1   := PADC("Este programa ira emitir o Rel. de Pedidos Prontos p/ Faturar.",74)
       Private cDesc2   := ""
       Private cDesc3   := PADC(" ",74)
       Private cCabec   := PADC("Ped. Liberados",27)
       Private cCabPro  := ""
       Private cNatureza:= ""
       Private aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
       Private nomeprog := "FAT07654"
       Private cPerg    := ""
       Private nLastKey := 0
       Private lContinua:= .T.
       Private nLin     := 0
       Private nCol     := 0
       Private wnrel    := "FAT07654"
       Private nTipo    := 15
       Private m_pag    := 01     
       Private nTamNf   := 80     // Apenas Informativo
       Private cString  := "SC9"

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Envia controle para a funcao SETPRINT                        ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       Pergunte("FAT076",.F.)   

       wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

       If nLastKey == 27
          Return
       Endif
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Verifica Posicao do Formulario na Impressora                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SetDefault(aReturn,cString)

       If nLastKey == 27
          Return
       Endif

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Inicio do Processamento do Relatorio                         ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       /*#IFDEF WINDOWS
              RptStatus({|| RptDetail()})
              Return

              Static Function RptDetail()
       #ENDIF*/

       //For nX := 1 to nxContFl
           cCabec2  := "PEDIDO    CLIENTE                                                     CIDADE                                  EMISSAO    DT LIB CRED  TRANSPORTADORA                            BORDERO       VOLUME "
           //           99-999999 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX          99/99/99   99/99/99     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999
           //           0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20
           //           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
           cCabec1  := "PERIODO DE LIBERACAO DE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
           cCabec3  := ""
           Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
           nLin = 08

           DbSelectArea("CPEDI")
           DbGoTop()
  
           //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
           //ณ Inicializa  regua de impressao                            ณ
           //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
           SetRegua(Len(aResumo))
           nCont = 0
           For nX := 1 to Len(aResumo)
               If nLin > 60
                  nLin++
                  @ nLin,000 psay replicate("_",132)
                  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                  nLin := 08
               Endif
               nCont++
               nLin++
               @ nLin,000 psay aResumo[nX][1]
               @ nLin,10 psay aResumo[nX][2]
               @ nLin,070 psay aResumo[nX][3]
               @ nLin,110 psay aResumo[nX][4]
               @ nLin,121 psay aResumo[nX][5]
               @ nLin,134 psay SubStr(Posicione("SA4", 1, xFilial("SA4")+Posicione("SC5", 1, xFilial("SC5")+SubStr(aResumo[nX][1], 4, 6), "C5_REDESP"), "A4_NOME"), 1, 40)
               @ nLin,176 PSAY SubStr(aResumo[nX][6],1,6) Picture "@!"
           	   @ nLin,190 PSAY Posicione("SC5", 1, xFilial("SC5")+SubStr(aResumo[nX][1], 4, 6), "C5_VOLUME1")
           Next
           nLin++     
           @ nLin,000 psay Replicate("_",220)
           nLin++
       //Next
  		
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ                      FIM DA IMPRESSAO                        ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0766  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para finalizacao da consulta. (Abandona)            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*//*
Static Function FAT0766()
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao da consulta...                                  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If !lTelaJaFechada
          Close(oDlg2)
       Endif
       lJaFech := .t.
       DbSelectArea("CPEDI")
       DbCloseArea()             	
Return*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0767  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para finalizacao da consulta. (Abandona)            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*//*
Static Function FAT0767()
       DbSelectArea("CPEDI")
       DbGoTop()
       While !Eof()
             RecLock("CPEDI",.f.)
                CPEDI->FLAG := ' '
             MsUnLock()
             DbSkip()
       Enddo
       DbGotop()
Return*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/* release 12.1.25
Static Function ValidPerg(cPerg) 
Local _sAlias
//Local aRegs,aHelPor1
Local aHelp := {}

_sAlias := Alias()
cPerg := PADR(cPerg,10)


//            Texto do help em portugu๊s    , ingl๊s, espanhol
AAdd(aHelp, {{"Bordero(s)->Separe por Virula"},  {"BRANCO = TODOS"}, {""}})

//SX1 (<cGrupo>, <cOrdem>, <cPergunt>, <cPergSpa>, <cPergEng>, <cVar>, <cTipo>, <nTamanho>, [nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Bordero(s)"    ,"","","mv_ch1","C",69,00,00,"G","","","","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

DbSelectArea(_sAlias)
Return
*/
/*
Static Function ValorPed(cPedido)
       Local nValorPed,_nReg,_lReg
       Local nArea := Alias() 
       Local _cFilial
       _cFilial = xFilial("SC6")
       dbselectarea("SC6")        
if !eof() .and. !bof()
	_lReg = .t.
	_nReg = recno()
else
	_lReg = .f.
endif 
dbseek(_cFilial+cPedido,.f.) 
nValorPed = 0
do while !eof() .and. (SC6->C6_FILIAL == _cFilial) .and. (SC6->C6_NUM == cPedido)
	nValorPed += SC6->C6_QTDVEN*SC6->C6_PRCVEN // Calcular vlr total dos produtos antecipadamente
	dbskip()
enddo 
if _lReg
	dbselectarea("SC6")
	dbgoto(_nReg)
endif 
dbselectarea(nArea)

return(nValorPed)*/

Static Function GeraDuplic(cPedido)
       Local nArea := Alias()
       Local _cFilial, lGeraDuplic, nReg
       lGeraDuplic := .t.
       DbSelectArea("SF4")
       nReg = recno()
       _cFilial = xFilial("SC6")
       DbSelectArea("SC6")
       DbSeek(_cFilial+cPedido,.f.)
       While !Eof() .and. (SC6->C6_FILIAL == _cFilial) .and. (SC6->C6_NUM == cPedido)
             DbSelectArea("SF4")
             DbSeek(xFilial("SF4")+SC6->C6_TES)
             If Found() .and. (SF4->F4_DUPLIC # "S")
                lGeraDuplic := .f.
                Exit
             Endif
             DbSelectArea("SC6")
             nSomaVlrProd += SC6->C6_QTDVEN * SC6->C6_PRCVEN // Calcular vlr total dos produtos antecipadamente
             DbSkip()
       Enddo
       DbSelectArea("SF4")
       DbGoTo(nReg)
       DbSelectArea(nArea)
Return(lGeraDuplic)

/*Static Function FAT0768(cNumPed)
       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Saldo dos Produtos nos Pedidos"
       Local cPict         := ""
       Local titulo        := "Saldo dos Produtos nos Pedidos"
       Local nLin          := 80
       Local Cabec1        := "                 PRODUTO"
       Local Cabec2        := "CำDIGO          DESCRIวรO                  QTD. PEDID SLD. ESTOQ LOCALIZAวรO"
       Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       Private CbTxt       := ""
       Private limite      := 80
       Private tamanho     := "P"
       Private nomeprog    := "FAT0768" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cbtxt       := Space(10)
       Private cbcont      := 00
       Private CONTFL      := 01
       Private m_pag       := 01
       Private wnrel       := "FAT0768" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := "SB2"

       DbSelectArea("SB2")
       DbSetOrder(1)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Monta a interface padrao com o usuario...                           ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       wnrel := SetPrint(cString, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

       If nLastKey == 27
          Return
       Endif

       SetDefault(aReturn,cString)

       If nLastKey == 27
          Return
       Endif

       nTipo := If(aReturn[4]==1, 15, 18)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       RptStatus({|| FAT07681(Cabec1, Cabec2, Titulo, nLin, cNumPed) }, Titulo)
Return

Static Function FAT07681(Cabec1, Cabec2, Titulo, nLin, cNumPed)
       Local cQry1 := ""
       DbSelectArea(cString)
       DbSetOrder(1)
       cQry1 := ""
       cQry1 += "SELECT C9_PRODUTO, C9_LOCAL, SUM(C9_QTDLIB) AS C9_QTDLIB, B2_LOCALIZ "
       cQry1 += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (C9_FILIAL = B1_FILIAL) AND (C9_PRODUTO = B1_COD) AND (SB1.D_E_L_E_T_ = '') "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) AND (SB2.D_E_L_E_T_ = '') "
       cQry1 += "WHERE (C9_FILIAL  = '"+xFilial("SC9")+"') "
       cQry1 += "AND (SC9.D_E_L_E_T_ = '') "
       cQry1 += "AND (C9_PEDIDO IN "+cNumPed+") "
       cQry1 += "GROUP BY C9_PRODUTO, C9_LOCAL, B2_LOCALIZ "
       cQry1 += "ORDER BY B2_LOCALIZ "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       nQtdAtu := 0
       While !Eof()
             //0         1         2         3         4         5         6         7         8
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789
             //                 PRODUTO
             //CำDIGO          DESCRIวรO                  QTD. PEDID SLD. ESTOQ LOCALIZAวรO
             //XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXX 999,999.99 999,999.99 123456789012345
             If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif
             nQtdAtu := Posicione("SB2", 1, xFilial("SB2")+TCQ->C9_PRODUTO+TCQ->C9_LOCAL, "B2_QATU")
             cNomPro := SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->C9_PRODUTO, "B1_DESC"), 1, 26)
             @ nLin, 000 PSAY TCQ->C9_PRODUTO Picture "@R XX 99.99.999-99"
             @ nLin, 016 PSAY cNomPro         Picture "@!"
             @ nLin, 043 PSAY TCQ->C9_QTDLIB  Picture "@E 999,999.99"
             @ nLin, 054 PSAY nQtdAtu         Picture "@E 999,999.99"
             @ nlIN, 065 PSAY TCQ->B2_LOCALIZ Picture "@!"
             nLin += 1
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       SET DEVICE TO SCREEN
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       
       MS_FLUSH()

Return*/

Static Function FAT0769(aResumo)
       Local cQry1   := ""
       Local aIncBor := {}
       Local lIncNov := .f.
       Local cQdrDia := GETMV("MV_QDRTDIA")
       Local nY
       If !SubStr(cQdrDia, 1, 8) $ dtos(dDataBase)
          cDatDia := dtos(dDataBase)
          cLtrAtu := SubStr(cQdrDia, 9, 1)
          If cLtrAtu $ 'P'
             cLtrDia := CHR(ASC(SubStr(cQdrDia, 9, 1)) + 2)
          ElseIf cLtrAtu $ 'Z'
                 cLtrDia := 'A'
          Else
             cLtrDia := CHR(ASC(SubStr(cQdrDia, 9, 1)) + 1)
          Endif
          PUTMV("MV_QDRTDIA", cDatDia+cLtrDia+'00')
          cQdrDia := GETMV("MV_QDRTDIA")
          cDatDia := SubStr(cQdrDia, 01, 08)
          cLtrDia := SubStr(cQdrDia, 09, 01)
          cSeqDia := SubStr(cQdrDia, 10, 02)
       Else
          cQdrDia := GETMV("MV_QDRTDIA")
          cDatDia := SubStr(cQdrDia, 01, 08)
          cLtrDia := SubStr(cQdrDia, 09, 01)
          cSeqDia := SubStr(cQdrDia, 10, 02)
       Endif
       cQry1 := "SELECT TOP 1 ZG_CODIGO AS ZF_CODIGO "+;
       "FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) "+;
       "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = ZG_FILIAL) AND (ZF_CODIGO = ZG_CODIGO) "+;
       "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = C5_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = C5_NUM) "+;
       "WHERE (SZG.D_E_L_E_T_ = '') AND (ZG_FILIAL = '"+xFilial("SZG")+"') AND (ZF_EMISSAO = '"+Dtos(dDataBase)+"')  AND (ZF_FLAG = 'D') " 
//       "AND (C5_TRANSP "+IIF(MV_PAR04 == 1,"=","<>")+" 00700)"
       
       TCQuery cQry1 ALIAS "TZF" NEW
       DbSelectArea("TZF")
       If !Eof() .and. !Bof()
          cUltCod := TZF->ZF_CODIGO
          lIncNov := .f.
          DbSelectArea("TZF")
          DbCloseArea()
       Else
          DbSelectArea("TZF")
          DbCloseArea()
          /*
          cQry1 := ""
          cQry1 += "SELECT MAX(ZF_CODIGO) AS CODIGO FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) WHERE (ZF_FILIAL = '"+xFilial("SZF")+"') AND (SZF.D_E_L_E_T_ = '') "
          TCQuery cQry1 ALIAS "TZF" NEW
          DbSelectArea("TZF")          
          */
          cUltCod := U_NumSeqLot("SZF") //StrZero(Val(TZF->CODIGO)+1, 6)
          /*
          DbSelectArea("TZF")
          DbCloseArea("TZF")
          */
          lIncNov := .t.
       Endif
       For nY := 1 To Len(aResumo)
           DbSelectArea("SZG")
           DbSetOrder(2)
           DbSeek(xFilial("SZG")+Alltrim(SubStr(aResumo[nY][1], 1, 2)+SubStr(aResumo[nY][1], 4, 6)), .t.)
           If Found()
              //                 1234567890123456789012345678901234567890
              //                 XXXXXXXXXXXXX (999999) / XXX
              //                 999999                 / XXX
              aResumo[nY][6] := "OUTRO BORDERO ("+SZG->ZG_CODIGO+") "+Iif(Empty(SZG->ZG_LOCALIZ), " ", "/ "+Alltrim(SZG->ZG_LOCALIZ) )
           Else
              cQdrExp := Iif(aResumo[nY][7] > 12, cLtrDia+cSeqDia, '')
              cSeqDia := Iif(aResumo[nY][7] > 12, StrZero(Val(cSeqDia)+1, 2), cSeqDia)
              aResumo[nY][6] := cUltCod+Iif(Empty(cQdrExp), " ", "                 / "+Alltrim(cQdrExp))
              If aResumo[nY][8] == '  /  /  '
                 aAdd(aIncBor, {xFilial("SZG"), cUltCod, SubStr(aResumo[nY][1], 1, 2)+SubStr(aResumo[nY][1], 4, 6), cQdrExp })
              Endif
           Endif
       Next
       PUTMV("MV_QDRTDIA", cDatDia+cLtrDia+cSeqDia)
       If Len(aIncBor) > 0
          If lIncNov
             //Incluir SZF (Cabe็alho do Bordero)
             DbSelectArea("SZF")
             RecLock("SZF", .t.)
                SZF->ZF_FILIAL  := xFilial("SZF")
                SZF->ZF_CODIGO  := cUltCod
                SZF->ZF_EMISSAO := dDataBase
                SZF->ZF_FLAG    := "D"
             MsUnLock()
          Endif
          //Incluir SZG (Itens do Bordero)
          For nY := 1 To Len(aIncBor)
              DbSelectArea("SZG")
              RecLock("SZG", .t.)
                 SZG->ZG_FILIAL  := aIncBor[nY][1]
                 SZG->ZG_CODIGO  := aIncBor[nY][2]
				 cAux := alltrim(aIncBor[nY][3])
				 cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                 SZG->ZG_PEDIDO  := cAux //aIncBor[nY][3]
                 SZG->ZG_LOCALIZ := ''//aIncBor[nY][4]
              MsUnLock()
          Next
       Endif
Return    

Static Function IncPed(aPed,aItensPed)
private lMsErroAuto := .f.
private	lMsHelpAuto := .f.

       DbSelectarea("SA3")
       DbSetOrder(1)
       DbSelectarea("SA2")
       DbSetOrder(1)
       DbSelectArea("SA1")
       DbSetOrder(1)
       DbSelectArea("SB2")
       DbSetOrder(1)
       DbSelectArea("SB5")
       DbSetOrder(1)
       DbSelectArea("SC5")
       DbSetOrder(1)
       DbSelectArea("SD1")
       DbSetOrder(1)
       DbSelectArea("SF1")
       DbSetOrder(1)
       DbSelectArea("SF4")
       DbSetOrder(1)
       DbSelectArea("SG1")
       DbSetOrder(1)
       DbSelectArea("SZ1")
       DbSetOrder(1)
       DbSelectArea("SZ5")
       DbSetOrder(1)
       DbSelectArea("ZZO")
       DbSetOrder(1)

       DbSelectArea("SC6")
       DbSetOrder(1)
		
		
	DbSelectArea("SC5")    
	MsgRun("Incluindo pedido(s)...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aPed, aItensPed, 3 ) } )
	If lMsErroAuto
			Alert("Nao foi possํvel incluir pedido !")
			MostraErro()
	Endif

return(!lMsErroAuto)
