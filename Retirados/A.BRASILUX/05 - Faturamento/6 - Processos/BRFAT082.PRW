#include "protheus.ch"
#include "topconn.ch"
//-------------------------------------------------------------------
// Incrementado por Jose Uliana pra enviar e-mail para PCP 04/11/2019 
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#INCLUDE "AP5MAIL.CH" 
// Termino do Incremento feito por José Uliana dia 04/11/2019  -------

#Translate MSGBOX( => IW_MsgBox(
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT082 ºAutor  ³ Cleber O. Dominguesº Data ³  10/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para gravar no cadastro de produtos o campo B1_VEND º±±
±±º          ³ o valor 'N' indicando que o produto não pode ser vendido   º±±
±±º          ³ para os produtos sem faturamento há mais de mv_par01 dias. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT082()
     Local oDlg
     Local cCadastro := OemToAnsi("Bloquear Venda")
     Local nOpca     := 0
     Local aSays     := {}
     Local aButtons  := {}
     Private mv_par01
     aAdd(aSays, "Será bloqueada a venda dos produtos que   ")
     aAdd(aSays, "não tiveram faturamento durante o período ")
     aAdd(aSays, "de dias estipulado no parâmetro!          ")

     if !u_VldAcesso(funname())
	      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	      return 
	 endif      
	
     VldPerg("BRFT82")   
     Pergunte("BRFT82", .F.)      

     aAdd(aButtons, { 5, .T., {| | Pergunte("BRFT82")       }} )
     aAdd(aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() }} )
     aAdd(aButtons, { 2, .T., {|o| nOpca := 2, o:oWnd:End() }} )

     FormBatch( cCadastro, aSays, aButtons )
     If nOpcA == 1
//--------------------------------------------------------------------------------------------
// Incrementado por Jose Uliana pra enviar e-mail para PCP 04/11/2019
       Processa({|lEnd| FAT082_0() })
// Termino do Incremento feito por José Uliana dia 04/11/2019  -------------------------------
        Processa({|lEnd| FAT082_1() })
        MsgBox("Processo Terminado!", "Informacao...", "INFO")
     Endif
     If nOpcA == 5
        Pergunte("BRFT82")
     Endif
Return  
//--------------------------------------------------------------------------------------------
// Incrementado por Jose Uliana pra enviar e-mail para PCP 04/11/2019

Static Function FAT082_0()
   
//    Local cPara    	:= "joseuliana@brasilux.com.br"
    Local cPara     := "grpestoque@brasilux.com.br" //"michelly@brasilux.com.br,tiagobianchi@brasilux.com.br,mirinho@brasilux.com.br,edevilson@brasilux.com.br,eliana@brasilux.com.br"
    Local cAssunto  := "PRODUTOS BLOQUEADOS COM SALDO EM ESTOQUE"
    Local cMsg		:= ""
    Local cQuery    := ""
    Local TM1
    Local cDataRefe := dTos(dDataBase - mv_par01)
    Local cDataBase := dToc(dDataBase)
    Local cDataRefee:= dToc(dDataBase - mv_par01)

    cQuery := "SELECT SB1.B1_FILIAL AS 'VFILIAL', SB1.B1_COD  AS 'VPRODUTO', SB1.B1_DESC AS 'VDESCRICAO', "+;
                      "SB2.B2_LOCAL  AS 'VLOCALIZ', SB2.B2_QATU AS 'VSALDO', "+;
                      "ULTSAIDA = (SELECT TOP 1 CONVERT(varchar(10), CAST(D2_EMISSAO AS DATE),103) FROM "+RetSqlName("SD2")+" WITH (NOLOCK) "+;
               "WHERE (D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND "+;
                      "(D2_ESTOQUE = 'S') AND (D2_COD = SB1.B1_COD) ORDER BY D2_DTDIGIT DESC) "+;
                "FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) "+;
     "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON SB2.B2_FILIAL = SB1.B1_FILIAL AND "+;
                      "SB2.B2_COD = SB1.B1_COD AND SB2.D_E_L_E_T_ = '' "+;
               "WHERE SB1.D_E_L_E_T_ = '' AND (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND "+;
                      "((SB1.B1_VEND <> 'N') OR (SB1.B1_MSBLQL <> '1')) AND (SB1.B1_TIPO = 'PA') AND "+;
                      "(SB2.B2_QATU > 0) AND (SB1.B1_COD NOT IN(SELECT DISTINCT D2_COD FROM "+RetSqlName("SD2")+" SD2 "+;
                      "WHERE (SD2.D2_FILIAL = '"+xFilial("SD2")+"') AND (SD2.D2_EMISSAO >= '"+cDataRefe+"') AND "+;
                      "(SD2.D_E_L_E_T_ <> '*'))) "+;
            "GROUP BY SB1.B1_COD, SB1.B1_DESC, SB2.B2_LOCAL, SB2.B2_QATU, SB1.B1_FILIAL "+; 
            "ORDER BY SB2.B2_LOCAL, SB1.B1_COD "

	TcQuery cQuery ALIAS "TM1" NEW   
	DbSelectArea("TM1")        

   	If TM1->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 TM1->(DbCloseArea()) 
   		 Return()
   	EndIf		
	//		Monta o script HTML para ser enviado por email 	//        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font-size='1'>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FILIAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOCAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SALDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DATA REFERENCIA</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DIAS REF</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DATA BLOQUEIO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DT. ULT. VENDA</th>"

	cMsg+="</tr>"    
	      
   	DbSelectArea("TM1")
           	 //#FFD7D7   #ECFFEC
   	While TM1->(!eof())
		
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->VFILIAL+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->VPRODUTO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->VDESCRICAO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->VLOCALIZ+"</td>"
    	cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(TM1->VSALDO,"@E 99999")+"</td>"	
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(cDataRefee)+"</td>"		
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(mv_Par01,"@E 9999")+"</td>"		
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(cDataBase)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->ULTSAIDA)+"</td>"		

		cMsg+="</tr>" 
			    
	    TM1->(dbSkip())
  	EndDo
   
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>BRFAT082</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
//  	RESET ENVIRONMENT 

Return

// Termino do incremento feito por José Uliana dia 04/11/2019   -------------------------------------------
//---------------------------------------------------------------------------------------------------------

/*******************************************************************************/
/*** FAT082_1 - Processa função de acordo com os parâmetros.                 ***/
/*** Autor:                                                                  ***/
/*** Data :                                                                  ***/
/*******************************************************************************/
Static Function FAT082_1()
       Local cQuery   := ""
       Local cDataRef := dTos(dDataBase - mv_par01)
       //Cleber(12/09/17) => Gustavo Diniz pediu pra bloquear o produto totalmente ao invés de pôr somente como Não Vender
 
       cQuery = "UPDATE "+RetSqlName("SB1")+" SET B1_VEND = 'N',B1_MSBLQL = '1' WHERE (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_TIPO = 'PA') AND "+;
                "((B1_VEND <> 'N') OR (B1_MSBLQL <> '1')) AND (D_E_L_E_T_ <> '*') AND "+;
                "B1_COD NOT IN(SELECT DISTINCT SD2.D2_COD FROM "+RetSqlName("SD2")+" SD2 "+;
                " WHERE (SD2.D2_FILIAL = '"+xFilial("SD2")+"') AND (SD2.D2_EMISSAO >= '"+cDataRef+"') AND (SD2.D_E_L_E_T_ <> '*') "
/*---------------------------------------------------------------------------------
       If cNumEmp == "01010101"
          cQuery += "UNION ALL "+;
                    "SELECT DISTINCT D2_COD FROM "+RetSqlName("SD2")+;
                    " WHERE (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_EMISSAO >= '"+cDataRef+"') AND (D_E_L_E_T_ <> '*')"
       Endif
-----------------------------------------------------------------------------------*/       
       cQuery += ")"
       TCSQLEXEC(cQuery)   
Return

/*******************************************************************************/
/*** VldPerg  - Atualização do arquivo de perguntas SX1                      ***/
/*** Autor:                                                                  ***/
/*** Data :                                                                  ***/
/*******************************************************************************/
Static Function VldPerg(cPerg)
       Local aRegs   :={}
       Local _sAlias := Alias()
       Local i, j

       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aAdd(aRegs, {cPerg, "01", "Qtde Dias s/ Fat", "", "", "mv_ch1", "N", 06, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       For i := 1 TO Len(aRegs)
           If !DbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 TO FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return

