#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
#include 'font.ch' 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFAT076 บ Autor ณ Luํs Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta de Pedidos Liberados para producao.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ 30/04/14 ณ MV_XHABBOR Habilita a impressใo dos pedidos aprovados      บฑฑ
ฑฑบ          ณ dando a op็ใo de imprimir e gerar border๔ divididos por    บฑฑ
ฑฑบ          ณ regiใo, dep๓sito ou exporta็ใo  (Andr้ Maester)            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFAT076()     
     //Local nAuxQtde,nAuxVol,lVolJunto
     Private _cUser
     Private cPerg
     Private cTitulo
     Private lPerg
     Private oDlg2
     Private lJaFech := .f.
     Private lTelaJaFechada := .f.
     Private cUltCod 
     Private ncBxFil := '1'
     Private oTempTbl1
     Private aCampos := { {"MARCA"    ,"C",02,0},;
                          {"FLAG"     ,"C",01,0},;
                          {"EMPRESA"  ,"C",02,0},;     
                          {"PEDIDO"   ,"C",06,0},;
                          {"CLIENTE"  ,"C",06,0},;
                          {"NOME"     ,"C",40,0},;
                          {"MUNICIPIO","C",30,0},;
                          {"ESTADO"   ,"C",02,0},;
                          {"DTCREDITO","D",08,0},;
                          {"DTEMISSAO","D",08,0},;
                          {"DTPEDPROG","D",08,0},;
                          {"TRANSPOR" ,"C",10,0},;        
                          {"TRANSP"   ,"C",05,0},;        
                          {"VOLUME"   ,"N",08,2},;        
                          {"VOLQUEB"  ,"C",01,0} }        
                          //{"TINTAPO"  ,"C",01,0} }        

						
     Private aCpoBro := { {"MARCA"    ,OemToAnsi("")           ,""       },;
                          {"EMPRESA"  ,OemToAnsi("Empresa")    ,"99"     },;
                          {"PEDIDO"   ,OemToAnsi("Pedido")     ,"999999" },;
                          {"CLIENTE"  ,OemToAnsi("Cliente")    ,"999999" },; 
                          {"NOME"     ,OemToAnsi("Nome")       ,"@!"     },;
                          {"MUNICIPIO",OemToAnsi("Municipio")  ,"@!"     },;
                          {"ESTADO"   ,OemToAnsi("Estado")     ,"@!"     },;
                          {"DTEMISSAO",OemToAnsi("Dt. Emissao"),""       },;
                          {"DTPEDPROG",OemToAnsi("Dt. Programa"),""      },;
                          {"TRANSPOR ",OemToAnsi("Op็ใo filtro"),"@!"    },;
                          {"TRANSP  " ,OemToAnsi("Transpor")    ,"99999" },;
						  {"VOLUME"   ,OemToAnsi("Volume")      ,"999999"},;
						  {"VOLQUEB"  ,OemToAnsi("Vol.Quebr")   ,""      }}
						  //{"TINTAPO"  ,OemToAnsi("Tinta Po")    ,""      } }
     u_zcfga01( 'BRFAT076' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
     _cUser := alltrim(upper(cUsername))

	 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	 //ณ Cria indice condicional									  ณ
	 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     If ChkFile("CPEDI")
	     DbSelectArea("CPEDI")
	     //ZAP
     Endif
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25                  ***/

     oTempTbl1 := FWTemporaryTable():New( 'CPEDI' )
     oTempTbl1:SetFields( aCampos )
     oTempTbl1:Create()
     /********************************************************************************************************************************/
     cPerg   := "FAT076"
     cTitulo := OemToAnsi("Pedidos Liberados")
     //ValidPerg(cPerg)
     //If !GETMV("MV_XHABBOR")
     //	lPerg := Pergunte(cPerg,.T.)   
     //	If !lPerg
     //   	DbSelectArea("CPEDI")
     //   	DbCloseArea()
     //   	Return
     //	Endif
     //   Processa({|| FAT0761() },cTitulo)
    // Else
        FAT0762()
    // Endif
     oTempTbl1:Delete()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0761  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para busca das informacoes.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0761()
       Local cQry1     := ""
       //Local cAlt      :=.f.
       Local cCond     := ""
       Private cMarca  := GetMark()
       Private cNumPed := ""
       //Private ncBxFil := "1"
       ncBxFil := "1"
       If ChkFile("CPEDI")
	       DbSelectArea("CPEDI")
           ZAP  
	   Endif       //ZF_TIPOBOR - 1 - AGLUTINADO /  2 - DEPOSITO  / 3 - REGIAO SP / 4 - EXPORTACAO / 5 - RETIRA  / 6 - AMOSTRA
       If lChkDep .and. lChkReg .and. (lChkRet =.F.)
           cCond := " AND C5_TRANSP NOT IN('00572','01444','00250','00556','00313') " 
           ncBxFil :='1'
       Elseif lChkDep .and. lChkRet .and. (lChkReg =.F.) 
           cCond := " AND C5_TRANSP IN('00700','00800','01444','00572','00250','00556','00313','00573','099999') "
           ncBxFil :='1'
       Elseif lChkDep .and. (lChkReg =.F.) .and. (lChkRet =.F.) 
           cCond := " AND C5_TRANSP IN('00700','00573','099999','00800') "
           ncBxFil := Iif(lChkExp,'1','2')
       Elseif lChkReg .and. lChkRet .and. (lChkDep =.F.)
           cCond := " AND C5_TRANSP NOT IN('00700','00573','099999','00800')  "
   	       ncBxFil :='3'                                   
   	   Elseif lChkReg .and. (lChkRet = .F.) .and. (lChkDep =.F.)
		   cCond := " AND C5_TRANSP NOT IN('01444','00572','00250','00556','00313','00700','00573','099999','00800') ) "   	   	   
   	       ncBxFil := Iif(lChkExp,'1','3')
   	   Elseif lChkRet .and. (lChkReg = .F.) .and. (lChkDep =.F.)
		   cCond := " AND C5_TRANSP IN('01444','00572','00250','00556','00313') "   	   	   
		   ncBxFil := Iif(lChkExp,'1','3')
   	   Elseif (lChkDep =.F.) .and. (lChkReg =.F.) .and. (lChkRet =.F.) .and. (lChkExp =.F.) .and. (lChkAmt =.F.)// .and. (lChkTPo = .F.) 
   	       cCond := " AND C5_TRANSP IN('111111111') " 
   	   Elseif (lChkDep =.F.) .and. (lChkReg =.F.) .and. (lChkRet =.F.) .and. lChkExp 
   	       cCond := " AND (A1_EST ='EX') "
   	       ncBxFil :='4'
   	   Endif
   	   cQry1 += " SELECT DISTINCT SC9.C9_PEDIDO AS PEDIDO, '"+cMarca+"' AS MARCA, '"+cEmpAnt+"' AS EMPRESA, C5_CLIENTE AS CLIENTE, A1_NOME AS NOME, A1_MUN AS MUNICIPIO, A1_EST AS ESTADO, C9_DTLCRED AS DTCREDITO, "
   	   cQry1 += " C5_EMISSAO AS DTEMISSAO,C5_FLAG AS FLAG, C5_PEDPROG AS DTPEDPROG, C5_APROVA AS APROVA, C5_TRANSP AS TRANSP, C5_VOLUME1 AS VOLUME, C5_VOLQUEB AS VOLQUEB "
	   //cQry1 += " ,CASE WHEN SUBSTRING(C6_PRODUTO,4,2) IN ('97','98','99') THEN 'X' ELSE '' END AS TINTAPO "
       cQry1 += " FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
	   cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (C6_FILIAL = C9_FILIAL) AND (C6_NUM = C9_PEDIDO) AND (C6_ITEM = C9_ITEM) AND (C6_PRODUTO = C9_PRODUTO) AND (SC6.D_E_L_E_T_ ='')
       cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (C5_FILIAL = C9_FILIAL) AND (C5_NUM = C9_PEDIDO) AND (SC5.D_E_L_E_T_ = '') "
       cQry1 += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (A1_FILIAL = '"+xFilial("SA1")+"')  AND (A1_COD = C5_CLIENTE) AND (SA1.D_E_L_E_T_ = '') "
       cQry1 += " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"' "
       cQry1 += "  AND SC9.D_E_L_E_T_ = '' "
       If GetMv("MV_XHABBOR")
	       cQry1 +=" AND SC6.C6_ENTREG < ='"+dTos(dDtLib2)+"' "
       Else
           cQry1 +=" AND SC9.C9_DTLCRED < ='"+dTos(dDtLib2)+"' "
       Endif
       If cNumEmp ='01010101'
           If !lChkAmt
           	   cCond += " AND (SC6.C6_TES NOT IN('614','615','616','617','618','661','664')) "//OR (SUBSTRING(SC6.C6_PRODUTO,4,2) NOT IN('97','98','99')) "
           	   cQry1 += cCond
           Else
               ncBxFil := '6'
               cQry1 += " AND (SC6.C6_TES IN('614','615','616','617','618','661','664')) "// OR (SUBSTRING(SC6.C6_PRODUTO,4,2) IN('97','98','99'))"
           Endif		
           /*
           If !lChkTPo 
           	   If !lChkAmt
    	       	   cCond += " AND SUBSTRING(SC6.C6_PRODUTO,4,2) NOT IN('97','98','99') "
	           	   cQry1 += cCond
           	   Endif
           Else
               ncBxFil := '8'
               cQry1 += " AND SUBSTRING(SC6.C6_PRODUTO,4,2) IN('97','98','99') "
           Endif		
			*/
       Endif
       If cNumEmp ='01010101' .and. (lChkExp = .F.)
           cQry1 += " AND (A1_EST <>'EX') "
	   Endif
       cQry1 +=" AND (C5_TIPO  =  'N')  AND (C5_FLAG  <> 'S') AND (C5_APROVA = '1')  "
       cQry1 +=" AND (C9_NFISCAL = '') "
       cQry1 +=" ORDER BY EMPRESA, PEDIDO "

       TCQUERY cQry1 NEW ALIAS "QPED"
       DbSelectArea("QPED")
       DbGoTop()
       ProcRegua(100)
       If (QPED->(EOF()))
			QPED->(DbCloseArea())
           	MsgAlert("Nใo existem pedidos liberados nใo impressos com estes parametros. Verifique se a data de libera็ใo e o tipo de border๔ !!","Atencao!")
	   		Return Nil

	   EndIf
       While !Eof()
       		IncProc("Selecionando registro conforme parametros.")
             RecLock("CPEDI",.t.)
                CPEDI->MARCA     := QPED->MARCA
                CPEDI->FLAG      := Iif(QPED->FLAG $ 'N',' ',QPED->FLAG)
                CPEDI->EMPRESA   := QPED->EMPRESA
                CPEDI->PEDIDO    := QPED->PEDIDO
                CPEDI->CLIENTE   := QPED->CLIENTE
                CPEDI->NOME      := QPED->NOME
                CPEDI->MUNICIPIO := QPED->MUNICIPIO
                CPEDI->ESTADO    := QPED->ESTADO
                CPEDI->DTCREDITO := CTOD(SUBSTR(QPED->DTCREDITO,7,2)+"/"+SUBSTR(QPED->DTCREDITO,5,2)+"/"+SUBSTR(QPED->DTCREDITO,1,4))
                CPEDI->DTEMISSAO := CTOD(SUBSTR(QPED->DTEMISSAO,7,2)+"/"+SUBSTR(QPED->DTEMISSAO,5,2)+"/"+SUBSTR(QPED->DTEMISSAO,1,4))
                CPEDI->DTPEDPROG := CTOD(SUBSTR(QPED->DTPEDPROG,7,2)+"/"+SUBSTR(QPED->DTPEDPROG,5,2)+"/"+SUBSTR(QPED->DTPEDPROG,1,4))
                CPEDI->TRANSPOR  := IIF(ALLTRIM(QPED->ESTADO) $ 'EX','EXPORTACAO', IIF(ALLTRIM(QPED->TRANSP) $ '00700.099999.00800' .AND. !ALLTRIM(QPED->ESTADO) $ 'EX', 'DEPOSITO', IIF(ALLTRIM(QPED->TRANSP) $ '00572.01444.00250.00556.00313' .AND. !ALLTRIM(QPED->ESTADO) $ 'EX', 'RETIRA', 'REGIAO SP')))
				CPEDI->TRANSP    := QPED->TRANSP
				CPEDI->VOLUME    := QPED->VOLUME
				CPEDI->VOLQUEB   := IIF(QPED->VOLQUEB $ 'S', 'X', '')
				//CPEDI->TINTAPO   := IIF(QPED->TINTAPO $ 'X', 'X', '')
             MsUnLock()
             DbSelectArea("QPED")
             DbSkip()
       Enddo

       DbSelectArea("QPED")
       DbCloseArea()
       //If !GETMV("MV_XHABBOR")
       //	  FAT0762()
       //Endif
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0762  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para mostrar dados na tela do usuario.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FAT0762()       
	   Local ocVolTot
	   Local ocVolDep
	   Local ocVolExp
	   Local ocVolReg
	   Local ocVolRet
       Local ocDtLib1
       //Local ocDtLib2
   	   Local nAuxDia   := 0
   	   Local  nY       
       Private nVolTot :=0
       Private nVolDep :=0
       Private nVolExp :=0
       Private nVolReg :=0
       Private nVolRet :=0  
       Private dDtLib2 
       //Private ncBxFil := '1'	
       Private lChkDep := .F.       
       Private lChkReg := .F.
       Private lChkExp := .F.
       Private lChkRet := .F.       
       Private lChkAmt := .F.
       //Private lChkTPo := .F.     
       Private onVolTot 
       //Private nVolTot 

       Private onVolReg 
       //Private nVolReg

       Private onVolDep 
       //Private nVolDep 

       Private onVolExp 
       //Private nVolExp 

       Private onVolRet 
       //Private nVolRet 
       
       SetPrvt("oFont","oGrp1Lib","oSay1Lib","oGet1Lib","oSay2Lib","oSay2Lib","oGet2Lib","onDtLib1","onDtLib2","oCBxFil","oBtn1")
       
	   If cNumEmp <> '01010101'
	   	   lChkDep := .F.       
           lChkReg := .F.
           lChkExp := .F.
           lChkRet := .F.    	
       Endif
           
       DbSelectArea("CPEDI")
       DbGoTop()

       oFont   := TFont():New( "MS Sans Serif", 0, -12, , .T., 0, , 700, .F., .F., , , , , , )
       @ 010,012 To 410,810 Dialog oDlg2 Title OemToAnsi("Consulta / Impressใo de Pedidos Aprovados") 
       @ 004,004 Say   ocDtLib1 Var "Ped. liberados com data de entrega at้:"             Size 118, 006 COLOR CLR_BLACK   PIXEL OF oDlg2 FONT oFont
       @ 002,120 MsGet onDtLib2 Var dDtLib2      Picture '@ 99/99/9999'    Size 033, 008 COLOR CLR_HBLUE  WHEN .T. PIXEL OF oDlg2 FONT oFont
	   If (cNumEmp ='01010101')
	   //  @ 004,210 Say   ocDtLib2 Var "Tipo Bordero:"        Size 040, 006 COLOR CLR_BLACK                           PIXEL OF oDlg2 FONT oFont
       //  oCBxFil := TComboBox():New( 002, 250, {|u| If(PCount() > 0, nCBxFil := u, nCBxFil)}, {"TODOS", "DEPOSITO", "REGIAO SP", "EXPORTACAO", "RETIRA"}, 072, 014, oDlg2, , , , CLR_BLACK, CLR_WHITE, .T., oFont, "", , , , , , , nCBxFil )
       
       	   @ 002,180 CHECKBOX oChkDep VAR lChkDep PROMPT OemToAnsi("Dep๓sito")        SIZE 050,14    OF oDlg2 Pixel On Click fMChkbox()
           @ 011,180 CHECKBOX oChkExp VAR lChkExp PROMPT OemToAnsi("Exporta็ใo")      SIZE 050,14    OF oDlg2 Pixel On Click fMChkbox()
           @ 002,240 CHECKBOX oChkRet VAR lChkRet PROMPT OemToAnsi("Retira")          SIZE 050,14    OF oDlg2 Pixel On Click fMChkbox()
           @ 011,240 CHECKBOX oChkReg VAR lChkReg PROMPT OemToAnsi("Regiใo SP")       SIZE 050,14    OF oDlg2 Pixel On Click fMChkbox()
           @ 011,300 CHECKBOX oChkAmt VAR lChkAmt PROMPT OemToAnsi("Amostras")        SIZE 050,14    OF oDlg2 Pixel On Click fMChkbox()
           //@ 002,300 CHECKBOX oChkTPo VAR lChkTPo PROMPT OemToAnsi("Tinta P๓")        SIZE 050,14    OF oDlg2 Pixel On Click fMChkbox()

       Endif
       oBtn1 := TButton():New( 004, 350, "Carregar Pedidos", oDlg2, {|| fCalcVBo()   }, 045, 011, , , , .T., , "", , , , .F. )
       @ 040,365 Say   ocVolDep Var "Dep๓sito:"          Size 030, 006 COLOR CLR_BLACK                             PIXEL OF oDlg2 FONT oFont
       @ 050,365 MsGet onVolDep Var nVolDep      Picture '@E 9999999'    Size 030, 008 COLOR CLR_HBLUE  WHEN .F.   PIXEL OF oDlg2 FONT oFont
       @ 065,365 Say   ocVolReg Var "Regiใo-SP:"         Size 035, 006 COLOR CLR_BLACK                             PIXEL OF oDlg2 FONT oFont
       @ 075,365 MsGet onVolReg Var nVolReg      Picture '@E 9999999'    Size 030, 008 COLOR CLR_HBLUE  WHEN .F.   PIXEL OF oDlg2 FONT oFont
       @ 090,365 Say   ocVolExp Var "Exporta็ใo:"        Size 035, 006 COLOR CLR_BLACK                             PIXEL OF oDlg2 FONT oFont
       @ 100,365 MsGet onVolExp Var nVolExp      Picture '@E 9999999'    Size 030, 008 COLOR CLR_HBLUE  WHEN .F.   PIXEL OF oDlg2 FONT oFont
       @ 115,365 Say   ocVolRet Var "Retira:"            Size 030, 006 COLOR CLR_BLACK                             PIXEL OF oDlg2 FONT oFont
       @ 125,365 MsGet onVolRet Var nVolRet      Picture '@E 9999999'    Size 030, 008 COLOR CLR_HBLUE  WHEN .F.   PIXEL OF oDlg2 FONT oFont
       @ 140,365 Say   ocVolTot Var "Total:"             Size 030, 006 COLOR CLR_BLACK                             PIXEL OF oDlg2 FONT oFont
       @ 150,365 MsGet onVolTot Var nVolTot      Picture '@E 9999999'    Size 033, 008 COLOR CLR_HBLUE  WHEN .F.   PIXEL OF oDlg2 FONT oFont
       @ 020,003 To 190,360 Browse "CPEDI" Fields aCpoBro ENABLE "FLAG" MARK "MARCA"
          
       @ 175,370  BMPBUTTON Type  6 Action FAT0765() // IMPRIMIR
       @ 003,363 To 107,395
       If Empty(dDtLib2)  // sistema sugere 3 dias ๚teis a partir da database do sistema 
           For nY := 1 To 3
               If CDOW(ddatabase + nY) $ 'Saturday.Sunday'
                   nAuxDia += 1
               Endif
           Next
           dDtLib2 := DataValida(ddatabase + 3 + nAuxDia)
   	   Endif

       Activate Dialog oDlg2 Centered

       If !lJaFech
          lTelaJaFechada := .t.
          FAT0766()
       Endif
Return


Static Function fMChkbox()

	If lChkAmt
		lChkDep := .f.
		lChkExp := .f.
		lChkRet := .f.
		lChkReg := .f.
		//lChkTPo := .f.
		oChkDep:Refresh()
		oChkExp:Refresh()
		oChkRet:Refresh()
		oChkReg:Refresh()
		oChkAmt:Refresh()
		//oChkTPo:Refresh()
	ElseIf lChkDep
		lChkAmt := .f.
		lChkExp := .f.
		lChkRet := .f.
		lChkReg := .f.
		//lChkTPo := .f.
		oChkDep:Refresh()
		oChkExp:Refresh()
		oChkRet:Refresh()
		oChkReg:Refresh()
		oChkAmt:Refresh()
	ElseIf lChkExp
		lChkAmt := .f.
		lChkDep := .f.
		lChkRet := .f.
		lChkReg := .f.
		//lChkTPo := .f.
		oChkDep:Refresh()
		oChkExp:Refresh()
		oChkRet:Refresh()
		oChkReg:Refresh()
		oChkAmt:Refresh()
	Endif
	If (lChkRet .or. lChkReg)
		lChkAmt := .f.
		lChkDep := .f.
		lChkExp := .f.
		lChkRet := .t.		
		lChkReg := .t.
		//lChkTPo := .f.
		oChkDep:Refresh()
		oChkExp:Refresh()
		oChkRet:Refresh()
		oChkReg:Refresh()
		oChkAmt:Refresh()
	Endif

	/*
	If lChkTPo
		lChkDep := .f.
		lChkExp := .f.
		lChkRet := .f.
		lChkReg := .f.
		lChkAmt := .f.
		oChkDep:Refresh()
		oChkExp:Refresh()
		oChkRet:Refresh()
		oChkReg:Refresh()
		oChkAmt:Refresh()
	Endif */

	If (lChkDep .or. lChkExp .or. lChkRet .or. lChkReg)
		lChkAmt := .f.
		//lChkTPo := .f.		
		oChkAmt:Refresh()
    	//oChkTPo:Refresh()
	Endif			

Return

Static Function fCalcVBo()

    DbSelectArea("CPEDI")
    ZAP
    FAT0761()
    
    DbSelectArea("CPEDI")
    DbGoTop()

	nVolExp :=0
	nVolDep :=0
	nVolRet :=0
	nVolReg :=0
	nVolTot :=0
	DbSelectArea("CPEDI")
    DbGoTop()
    
    //If Getmv("MV_XHABBOR")
		While !Eof()
       		If Marked("MARCA")
       			IF ALLTRIM(CPEDI->TRANSPOR) $ 'EXPORTACAO' .AND. CPEDI->FLAG <> "S"
             		nVolExp += CPEDI->VOLUME
            	Elseif ALLTRIM(CPEDI->TRANSPOR) $ 'DEPOSITO' .AND. CPEDI->FLAG <> "S"
              		nVolDep += CPEDI->VOLUME  
            	Elseif ALLTRIM(CPEDI->TRANSPOR) $ 'RETIRA'.AND. CPEDI->FLAG <> "S"
					nVolRet += CPEDI->VOLUME                  
    			Elseif ALLTRIM(CPEDI->TRANSPOR) $ 'REGIAO SP'.AND. CPEDI->FLAG <> "S"
	        		nVolReg += CPEDI->VOLUME
          		Endif
            	nVolTot += IIF(CPEDI->FLAG <> "S",CPEDI->VOLUME,0)
            Endif
            DbSelectArea("CPEDI")
            DbSkip()
       	Enddo
	//Endif	   		       

	DbSelectArea("CPEDI")
    DbGoTop()
      
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0763  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para finalizacao da consulta. (Grava)               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*
Static Function FAT0763()
       Local cQuery
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao da consulta...                                  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       DbSelectArea("CPEDI")
       DbGoTop()
       lRet := MsgBox("Deseja imprimir os relatorios antes de sair ?'","Pergunta","YESNO")
       If lRet
          FAT0765()
       Else
          Return
       Endif
       While !Eof()
             If Marked("MARCA")
               
               // cQuery := ""
              //  cQuery := cQuery + "UPDATE "+RetSqlName("SC5")+" "
              //  cQuery := cQuery + "SET C5_FLAG = 'S' "
              //  cQuery := cQuery + "WHERE (D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = '"+CPEDI->PEDIDO+"')"
              //  TcSqlExec(cQuery) 

                DbSelectArea("SC5")
                DbSetOrder(1)
                DbSeek(xFilial("SC5")+CPEDI->PEDIDO,.t.)
                If Found()
	            	RecLock("SC5",.f.)
                         SC5->C5_FLAG := "S"
                    MsUnLock()
                    If SC5->C5_LAUDO = 'S'
						cAuxMens := "Solicita็ใo de Laudo T้cnico para Pedido"+;
						chr(13)+chr(10)+"Usuแrio que incluiu/alterou o pedido: "+(SC5->C5_ALT)+;
						chr(13)+chr(10)+"Nro do Pedido: "+SC5->C5_NUM+;
					    chr(13)+chr(10)+"Cliente: "+SC5->C5_CLIENTE+" - "+Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_NOME")+;
   						chr(13)+chr(10)+"Prog. BRFAT076"
   						If Substr(xFilial("SC5"),1,2)== "06"
   						    U_EnvMail("DISSOLTEX - Pedido "+SC5->C5_NUM+" com solicita็ใo de Laudo T้cnico" ,cAuxMens,"silene@dissoltex.com.br,ricardo@dissoltex.com.br","") 
                      	Else
   						    U_EnvMail("BRASILUX  - Pedido "+SC5->C5_NUM+" com solicita็ใo de Laudo T้cnico" ,cAuxMens,"laudo@brasilux.com.br","")                       	  
						Endif
                    Endif
             	Endif
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
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0764  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para alteracao dos paramentros da consulta.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/*
Static Function FAT0764()
       lPerg := Pergunte(cPerg,.T.)
       If lPerg
          DbSelectArea("CPEDI")
          ZAP
          Close(oDlg2)
          FAT0761()
       Endif
Return
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FAT0765  บ Autor ณ Luis Gustavo       บ Data ณ  04/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao principal para impressao do relatorio.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FAT0765()
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
       Private cString  := "SC5"
       Private aResumo  := {}

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
       
       //Private oPr := ReturnPrtObj() // imprimir c๓digo de barras usando o setprint (sem o tmsprinter)  
	   
       DbSelectArea("SC5") // Cabecalho dos Pedidos
       DbSetorder(1)
       DbSeek(xFilial("SC5")+cPedido,.F.)
       
       Dbselectarea("SE4") // Cond. Pagamento
       Dbsetorder(1)
       Dbseek(xFilial("SE4")+SC5->C5_CONDPAG)

       nLin = 1
       @ nLin,000 psay "PEDIDOS - RELATORIO PARA PRODUCAO"
	   @ nLin,035 psay "EXP.POR : "+cUsername
       @ nLin,060 psay "EXPEDICAO : "+DTOC(DATE())
       //MSBAR3("CODE128", 0.1, 8.8 ,Alltrim(cPedido),oPr,Nil,Nil,Nil,nil ,0.8 ,Nil,Nil,Nil)
       nLin += 1
       @nLin, 000 PSAY REPLICATE("_",80)
       nLin+=1
       @ nLin,000 psay "PEDIDO : "+SubStr(cnumemp,1,2)+"-"+cPedido
       @ nLin,020 psay "COND. PAGTO : "+SC5->C5_CONDPAG+"-"+SE4->E4_DESCRI
	   //@ nLin,064 psay "EXPED : "+DTOC(DATE())
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
	   MSBAR3("CODE128", 13.2, 8.6 ,Alltrim(cPedido),oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
       nLin = nLin+1
       @nLin,000 psay replicate("_",71)
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
       //Local cTexto := "Numero Pedido "
       //Local cAux1
       Local nPerIcm    := 0     
       Local nBaseSubst := 0
       Local nBaseIcms  := 0
       Local cUn        := ""
       Local nAuxIpi    := 0
       Local nLucroST   := 0
       Local nAuxIcms   := 0
       Local nTXPIS     := GETMV("MV_TXPIS")
       Local nTXCOFIN   := GETMV("MV_TXCOFIN")
       Local nFrete
       Local nValorPed
       Local lGeraDuplic
       Local cNumPed    := "('"
       Local nVol       := 0
       Local aGerLog := {}
       Local i
       Private nSomaVlrProd
       Private cPedido
       Private nPercSubst
       Private nDescZFR   := 0 // Desc. Zona Franca
       Private cQuery
       Private nImp     := 0
       Private lAbortPrint := .f.
       Private cxEntrega := ""
       Private oPr := ReturnPrtObj() // imprimir c๓digo de barras usando o setprint (sem o tmsprinter)  
       
       DbSelectArea("CPEDI")
       DbGoTop()
       ProcRegua(RecCount())
       While !Eof()
			//Cleber (18/10/10) -> Verificar se rel. de volumes estใo coerentes antes     
	 		U_VerificaVolumes(CPEDI->PEDIDO) //Cleber (27/08/15) ->Retirado //Cleber (01/03/18) -> Inserido
	 		//U_CorrigeVol(CPEDI->PEDIDO) //Cleber(20/11/17) ->Recalcular volumes de cada pedido antes de ser impresso devido a problemas ap๓s virada de versใo
             If Marked("MARCA") .and. CPEDI->FLAG $ ' '
                _cEmp := CPEDI->EMPRESA
                cQuery := ""
                cQuery := cQuery + " SELECT C6.C6_NUM AS PEDIDO, B2.B2_LOCALIZ AS QUADRANTE, C6.C6_PRODUTO AS PRODUTO, C6.C6_TES AS TES, C6.C6_VALOR AS VALOR, C6.C6_QTDVEN AS QTDEVEN, C6.C6_DESCRI AS DESCRICAO, C6.C6_LOCAL AS LOCAL, C6.C6_PRCVEN AS PRECO,C5_ESPECI4, C6.C6_PALLET, "
                cQuery := cQuery + " B1_ESTOQUE, 'ORDEM' = CASE WHEN SUBSTRING(C6.C6_PRODUTO, 1, 2) = 'BM' THEN C6.C6_NUM+'ZZ'+SUBSTRING(C6_PRODUTO,4,9)+SUBSTRING(C6_PRODUTO,1,3) ELSE C6.C6_NUM+SUBSTRING(C6_PRODUTO,4,9)+SUBSTRING(C6_PRODUTO,1,3) END "
                cQuery := cQuery + " FROM "+RetSqlName("SC6")+" C6 WITH (NOLOCK) "
                cQuery := cQuery + " LEFT OUTER JOIN "+RetSqlName("SC5")+" C5 WITH (NOLOCK) ON ((C5.C5_FILIAL+C5.C5_NUM) = (C6.C6_FILIAL + C6.C6_NUM)) AND (C5.D_E_L_E_T_ <> '*') "
                cQuery := cQuery + " LEFT OUTER JOIN "+RetSqlName("SB1")+" B1 WITH (NOLOCK) ON (C6.C6_FILIAL = B1.B1_FILIAL) AND (C6.C6_PRODUTO = B1.B1_COD) AND (B1.D_E_L_E_T_ <> '*') "
                cQuery := cQuery + " LEFT OUTER JOIN "+RetSqlName("SB2")+" B2 WITH (NOLOCK) ON (B1.B1_FILIAL = B2.B2_FILIAL) AND (B1.B1_LOCPAD = B2.B2_LOCAL) AND (B1.B1_COD = B2.B2_COD) AND (B2.D_E_L_E_T_ <> '*') "
                cQuery := cQuery + " WHERE "
                cQuery := cQuery + "   (C6.C6_FILIAL = '"+xFilial("SC6")+"') "
                cQuery := cQuery + "   AND C6.C6_NUM = '"+CPEDI->PEDIDO+"' "
                cQuery := cQuery + "   AND C6.D_E_L_E_T_ <> '*' "
                cQuery := cQuery + "   ORDER BY ORDEM "

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
                            @ nLin,013 psay substr(TCQP->DESCRICAO,1,29)
                            @ nLin,043 psay TCQP->QTDEVEN picture "@E 99,999"  //*IIF(LEN(ALLTRIM(TCQP->C5_ESPECI4)) > 0,2,1)
                            @ nLin,050 psay substr(cUn,1,10)
                            If !empty(TCQP->QUADRANTE)           
                               cAuxQ = alltrim(alltrim(TCQP->QUADRANTE))
                               cAuxQ = substr(cAuxQ,1,9)
                               @ nLin,061 psay cAuxQ
                            Endif  
                            

                            @ nLin, 070 psay TCQP->PRECO picture "@E 999,999.99"
                            nValorPed += TCQP->QTDEVEN*TCQP->PRECO
                            //nPallets  += TCQP->C6_PALLET
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
                         //nDescPisCof := nValorPed*(GETMV("MV_TXPIS")+GETMV("MV_TXCOFIN"))/100 release 12.1.25
                         nDescPisCof := nValorPed*(nTXPIS+nTXCOFIN)/100 
                      Endif 
                      nLin += 1
                      @ nLin,000 psay "QTDE DE VOLUMES : "
                      @ nLin,018 psay SC5->C5_VOLUME1 picture "@E 9,999"
                      @ nLin,024 psay "CUBAGEM : "
                      @ nLin,034 psay SC5->C5_VOLUME2 picture "@E 999.999"
                      @ nLin,045 psay "VALOR TOTAL PRODUTOS : "
                      @ nLin,068 psay (nValorPed - nDescZFR - nDescPisCof) picture "@E 9,999,999.99"
                      nLin += 1
                      @ nLin,050 psay "PESO BRUTO : "                // RAMON SOLICITOU JOGAR NA LINHA DE BAIXO O PESO.
                      @ nLin,068 psay ROUND(SC5->C5_PBRUTO,0) picture "@E 999,999"                
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
                          	nVol      += ZZO->ZZO_QTDVOL
                          	nPallets  += ZZO->ZZO_CUBAGE
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
				      MSBAR3("CODE128", 13.34, 8.6 ,Alltrim(cPedido),oPr,Nil,Nil,Nil,nil ,0.6 ,Nil,Nil,Nil)
                      nLin = nLin+1
                      @ nLin,000 psay replicate("_",71)
                      nPag += 1
                      dbSelectArea("TCQP")
                Enddo
                DbSelectArea("TCQP")
                DbCloseArea()
                DbSelectArea("CPEDI")
                RecLock("CPEDI",.f.)
                   CPEDI->FLAG := 'S'
                MsUnLock()
                //If !lChkAmt
	                aadd(aresumo,{CPEDI->EMPRESA+"-"+CPEDI->PEDIDO           ,;
    	                          CPEDI->CLIENTE+"-"+CPEDI->NOME             ,;
        	                      ALLTRIM(CPEDI->MUNICIPIO)+"-"+CPEDI->ESTADO,;
            	                  Dtoc(CPEDI->DTEMISSAO)                     ,;
                	              Dtoc(CPEDI->DTCREDITO)                     ,;
	                              ''                                         ,;
    	                          nVol                                       ,;
        	                      Dtoc(CPEDI->DTPEDPROG)                     ,;
        	                      CPEDI->VOLQUEB                             })
        	                      //CPEDI->TINTAPO                             })
            	//Endif
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
                      If SC5->C5_LAUDO = 'S'
					   	  cAuxMens := "Solicita็ใo de Laudo T้cnico para Pedido"+;
						  chr(13)+chr(10)+"Usuแrio que incluiu/alterou o pedido: "+(SC5->C5_ALT)+;
						  chr(13)+chr(10)+"Nro do Pedido: "+SC5->C5_NUM+;
						  chr(13)+chr(10)+"Cliente: "+SC5->C5_CLIENTE+" - "+Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE, "A1_NOME")
   						  If Substr(xFilial("SC5"),1,2)== "06"
   						  	  U_EnvMail("DISSOLTEX - Pedido "+SC5->C5_NUM+" com solicita็ใo de Laudo T้cnico" ,cAuxMens,"silene@dissoltex.com.br,ricardo@dissoltex.com.br","") 
                      	  Else
   						  	  U_EnvMail("BRASILUX  - Pedido "+SC5->C5_NUM+" com solicita็ใo de Laudo T้cnico" ,cAuxMens,"laudo@brasilux.com.br","")                       	  
						  Endif
                      Endif
                      RecLock("ZZB", .t.)
                         ZZB->ZZB_FILIAL := xFilial("ZZB")
                         ZZB->ZZB_PEDIDO := SC5->C5_NUM
                         ZZB->ZZB_IDLOG  := 'IAU'
                         ZZB->ZZB_USRLOG := cUsername
                         ZZB->ZZB_DATLOG := dDataBase
                         ZZB->ZZB_HORLOG := Time()
                      MsUnLock()
                      cNumPed += CPEDI->PEDIDO+"','"
                      aadd(aGerLog, {Substr(cnumemp,3,6), CPEDI->PEDIDO, CPEDI->CLIENTE} )
                      //If !Empty(SC5->C5_OBSEXP)
        			  //	cTexto += " "+CHR(13)+CHR(10)+CHR(13)+CHR(10)+SC5->C5_NUM+" - "+SC5->C5_OBSEXP
        			  //EndIf
                   Endif
                Endif
             Endif    
             
             DbSelectArea("CPEDI")
             DbSkip()
       Enddo  
       //MailExp(cTexto) 
       cNumPed := SubStr(cNumPed, 1, Len(cNumPed) - 2)+")"
       //If GetMv("MV_XHABBOR")    // Gera Log dos pedidos Impressos
       		FGeraLog(aGerLog)
       //Endif
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
          //If !lChkAmt
	          FAT07654(aResumo)
    	  //Endif	
          //FAT0768(cNumPed, mv_par01, mv_par02)
       Endif

       DbSelectArea("CPEDI")
       DbGoTop()
Return

//GERA LOG DOS PEDIDOS QUE FORAM IMPRESSOS E SERรO INCLUอDOS EM BORDERO
// ANDRษ 08/05/14
Static Function FGeraLog(aGerLog)
	Local cLin      := ""
	Local nY
    Private cArqTxt := ""
    Private nHandle := ""
    Private nTamLin := 21
    Private cEOL    := "CHR(13)+CHR(10)"
    If Empty(cEOL)
	    cEOL := CHR(13)+CHR(10)
    Else
    	cEOL := Trim(cEOL)
        cEOL := &cEOL
    Endif
	cArqTxt += "\SYSTEM\BORDPED"
	cArqTxt += SUBSTR(DTOS(DATE()),7,2)
	cArqTxt += SUBSTR(DTOS(DATE()),5,2)
	cArqTxt += SUBSTR(TIME(),1,2)
	cArqTxt += SUBSTR(TIME(),4,2)
    cArqTxt += SUBSTR(TIME(),7,2)	
	cArqTxt += ".TXT"
    If Len(aGerLog) > 0
    	nHandle := FCREATE(cArqTxt)          
		cLin := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
		cLin := 'FILIAL PEDIDO CLIENTE    -> GERADO POR : '+_cUser 
		FWrite(nHandle, cLin + cEOL)           
        For nY := 1 To Len(aGerLog) 
			cLin := Space(nTamLin)+cEOL 
           	cCpo := PADR(aGerLog[nY][01], 08) 
           	cLin := Stuff(cLin, 0001, 0008, cCpo)
            cCpo := PADR(aGerLog[nY][02], 06)  
            cLin := Stuff(cLin, 0008, 0006, cCpo)
            cCpo := PADR(aGerLog[nY][03], 06) 
            cLin := Stuff(cLin, 0015, 0006, cCpo)
           	If fWrite(nHandle, cLin, Len(cLin)) != Len(cLin)
            	If !MsgAlert("Ocorreu um erro na gravacao do arquivo do Log ?","Atencao!")
                	Exit
             	Endif
   			Endif
      	Next
		cLin := 'FIM DA GERAวรO DE PEDIDOS PARA BORDERO'
		FWrite(nHandle, cLin + CRLF)   
		FClose(nHandle)
	EndIf
          
          
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
Static Function FAT07654(aResumo)
       Local nX
       //Local nxContFl   := 1
       Local nCont
       Local cCabec1, cCabec2, cCabec3
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
       Private cString  := "SC5"

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

       //For nI := 1 to nxContFl
		   cCabec2  := "PEDIDO    CLIENTE                                                     CIDADE                                  EMISSAO    DT PROGRAMA. TRANSPORTADORA                            BORDERO          VOLUME   VOL.QUEB" // T.Pำ"
           //           99-999999 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX          99/99/99   99/99/99     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999             9999       9
           //           0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
           //           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
           IF !GETMV("MV_XHABBOR")
           		cCabec1  := "PEDIDOS COM DATA DE LIBERAวรO ATษ "+dtoc(dDtLib2) //+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
           //     cCabec2  := "PEDIDO    CLIENTE                                                     CIDADE                                  EMISSAO    DT LIB CRED  TRANSPORTADORA                            BORDERO       VOLUME "
           ELSE
           		cCabec1  := "PEDIDOS COM DATA DE ENTREGA ATษ "+dtoc(dDtLib2) 
           ENDIF
           cCabec3  := ""
           Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
           nLin = 08

           DbSelectArea("CPEDI")
           DbGoTop()
  
           //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
           //ณ Inicializa  regua de impressao                            ณ
           //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
           //SetRegua(Len(aResumo))
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
               @ nLin,010 psay aResumo[nX][2]
               @ nLin,070 psay aResumo[nX][3]
               @ nLin,110 psay aResumo[nX][4]
               @ nLin,121 psay aResumo[nX][8]
               @ nLin,134 psay SubStr(Posicione("SA4", 1, xFilial("SA4")+Posicione("SC5", 1, xFilial("SC5")+SubStr(aResumo[nX][1], 4, 6), "C5_REDESP"), "A4_NOME"), 1, 40)
               @ nLin,176 PSAY SubStr(aResumo[nX][6],1,14) Picture "@!"
           	   @ nLin,195 PSAY Posicione("SC5", 1, xFilial("SC5")+SubStr(aResumo[nX][1], 4, 6), "C5_VOLUME1")
           	   @ nLin,207 PSAY aResumo[nX][9]
           	   //@ nLin,214 PSAY aResumo[nX][10]
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
/*/
Static Function FAT0766()
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao da consulta...                                  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If !lTelaJaFechada
          Close(oDlg2)                                         
       Endif
       If GetMv("MV_XHABBOR") .AND. !Empty(cUltCod)
           Processa( { |lEnd| U_BRFATLIBEST(cValToChar(cUltCod),"1",1,"") }, "Reservando estoque dos produtos do Border๔ "+cUltCod, ,.t.) 
		// BORDERO A SER PROCESSADO -NUMERO DO BORDERO    
		// TIPO PEDIDO A PROCESSAR  -1-NรO PROCESSADOS / 2-JA PROCESSADOS
		// TIPO BAIXA               -1-TODOS OU 2-SOMENTE INCOMPLETOS   
		// PRODUTO                  -CODIGO DO PRODUTO
  	    //   Processa( { |lEnd|  U_GERAOP_1(aParm) }, "Gera็ใo de OPs para border๔ de pedidos", ,.t.) // GERA ORDENS DE PRODUวยO DAS NECESSIDADES DO BORDERO
       Endif                 
       lJaFech := .t.
       DbSelectArea("CPEDI")
       DbCloseArea()             	
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
/*/
/*
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
Return
*/
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
/*
Static Function ValidPerg(cPerg) 

Local _sAlias,aRegs,aHelPor1
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid      /Var01/Def01     /Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Data Lib De  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01",""           ,"","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"02","Data Lib Ate ?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""           ,"","","","","","","","","","","","","","","","","","","","","","","","",""})

       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j := 1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next 
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
*/
return(nValorPed)

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
/*
Static Function FAT0768(cNumPed)
       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Saldo dos Produtos nos Pedidos"
       //Local cPict         := ""
       Local titulo        := "Saldo dos Produtos nos Pedidos"
       Local nLin          := 80
       Local Cabec1        := "                 PRODUTO"
       Local Cabec2        := "CำDIGO          DESCRIวรO                  QTD. PEDID SLD. ESTOQ LOCALIZAวรO"
       //Local imprime       := .T.
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
       //Private cbtxt       := Space(10)
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
*/
/*
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

Return
*/
Static Function FAT0769(aResumo)

       //Local cQry1   := ""
       //Local cQry2   := ""
       //Local cQry3   := ""
       Local cBorVolQ, nY
       Local aIncBor := {}
       Local lIncNov := .f.
       Local lBorVolQ:= .f.
       Local cQdrDia := GETMV("MV_QDRTDIA")
       Local lXHABBOR:= GETMV("MV_XHABBOR")
       
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
       If ChkFile("TMPCAB")
	       DbSelectArea("TMPCAB")
		   DbCloseArea()
	   Endif
       
       //ZF_TIPOBOR - 1 - TODOS /  2 - DEPOSITO  / 3 - REGIAO SP / 4 - EXPORTACAO / 5 - RETIRA / 6 - AMOSTRA  / 7 - VOLUME QUEBRADO / 8 - TINTA Pำ
       /*
       cQry1 +=" SELECT TOP 1 ZG_CODIGO AS ZF_CODIGO "
       cQry1 +=" FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) "
       cQry1 +=" LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = ZG_FILIAL) AND (ZF_CODIGO = ZG_CODIGO) "
       cQry1 +=" LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = C5_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = C5_NUM) "
       cQry1 +=" WHERE (SZG.D_E_L_E_T_ = '') AND (ZG_FILIAL = '"+xFilial("SZG")+"') AND (ZF_EMISSAO = '"+Dtos(dDataBase)+"')  AND (ZF_FLAG = 'D') " 
       cQry2 += cQry1
       If Alltrim(ncBxFil)='6'
	       cQry1 +=" AND ZF_TIPOBOR ='"+Alltrim(ncBxFil)+"'"
       ElseIf Alltrim(ncBxFil)='8'
	       cQry1 +=" AND ZF_TIPOBOR ='"+Alltrim(ncBxFil)+"'"
       Else
       	   cQry1 +=" AND ZF_TIPOBOR NOT IN('8','7','6','') "
       Endif	
                                                            
       TCQuery cQry1 ALIAS "TZF" NEW
       DbSelectArea("TZF")
   	   If !Eof() .and. !Bof()
	       cUltCod := TZF->ZF_CODIGO
	       lIncNov := .f.
           DbSelectArea("TZF")
           DbCloseArea("TZF")
	   Else 
       */
       	   cUltCod := U_NumSeqLot("SZF") //StrZero(Val(TZF->CODIGO)+1, 6)
	       lIncNov := .t.
           //DbSelectArea("TZF")
       	   //DbCloseArea("TZF")
       //Endif
       // CRIAวรO DO BORDERO ESPECอFICO PARA VOLUMES QUEBRADOS (DIVIDIR NA IMPRESSรO)
       If !Alltrim(ncBxFil) $ '6.8'
	       //cQry3 += " AND ZF_TIPOBOR IN('7') "
    	   //TCQuery cQry2+cQry3 ALIAS "TZVOL" NEW

		   For nY := 1 To Len(aResumo)
	       	   If aResumo[nY][9] $ 'X'
    	      	  lBorVolQ :=.t.
        	   Endif
	       Next
	   
		   If (Len(aResumo) > 0 .and. lBorVolQ .and. !ncBxFil $ '6.8')
			   //cBorVolQ := Iif ((!Eof() .and. !Bof()), TZVOL->ZF_CODIGO, U_NumSeqLot("SZF") )
			   cBorVolQ := U_NumSeqLot("SZF")
	    	   //DbSelectArea("TZVOL")	
		       If Eof() 
			       DbSelectArea("SZF")
		    	   RecLock("SZF", .t.)
				       SZF->ZF_FILIAL  := xFilial("SZF")
				       SZF->ZF_CODIGO  := cBorVolQ
			    	   SZF->ZF_EMISSAO := dDataBase
		    		   SZF->ZF_FLAG    := "D"
			           SZF->ZF_TIPOBOR := "7"
    	    	   MsUnLock()
	    	   Endif
		       For nY := 1 To Len(aResumo)
		           DbSelectArea("SZG")
		           DbSetOrder(2)
        		   DbSeek(xFilial("SZG")+Alltrim(SubStr(aResumo[nY][1], 1, 2)+SubStr(aResumo[nY][1], 4, 6)), .t.)
                   If !Found() .and. aResumo[nY][9] $ 'X'
	   			   	   DbSelectArea("SZG")
    	   			   RecLock("SZG", .t.)
	   		    		   SZG->ZG_FILIAL  := xFilial("SZG")
   	        			   SZG->ZG_CODIGO  := cBorVolQ
	   	        		   SZG->ZG_PEDIDO  := SubStr(aResumo[nY][1], 1, 2)+SubStr(aResumo[nY][1], 4, 6)
        	        	   SZG->ZG_LOCALIZ := ''
	   		        	   //If GetMV("MV_XHABBOR")
		    	   	       //	  SZG->ZG_FLAGLIB := '1'   //PEDIDOS A PROCESSAR RESERVA
    		    	       //Endif
	   		    	   MsUnLock()
			   	   Endif	
			   Next
               If cNumEmp ='01010101'
  	        	   u_WfResBord(cBorVolQ) //Resumo Bordero
    	       Endif
	       Endif

    	   //DbSelectArea("TZVOL")
	       //DbCloseArea("TZVOL")
       Endif

       For nY := 1 To Len(aResumo)
           DbSelectArea("SZG")
           DbSetOrder(2)
           DbSeek(xFilial("SZG")+Alltrim(SubStr(aResumo[nY][1], 1, 2)+SubStr(aResumo[nY][1], 4, 6)), .t.)
           If Found()
              //                 12345678901234
              //                 XXXXX (999999)
              aResumo[nY][6] := "OUTRO ("+SZG->ZG_CODIGO+") "
           Else
              cQdrExp := Iif(aResumo[nY][7] > 12, cLtrDia+cSeqDia, '')
              cSeqDia := Iif(aResumo[nY][7] > 12, StrZero(Val(cSeqDia)+1, 2), cSeqDia)
              aResumo[nY][6] := cUltCod+Iif(Empty(cQdrExp), " ", "                 / "+Alltrim(cQdrExp))
              //If !GETMV("MV_XHABBOR") release 12.1.25
              	If !lXHABBOR
                  If aResumo[nY][8] == '  /  /  '
                      aAdd(aIncBor, {xFilial("SZG"), cUltCod, SubStr(aResumo[nY][1], 1, 2)+SubStr(aResumo[nY][1], 4, 6), cQdrExp, aResumo[nY][9] })//, aResumo[nY][10] })
              	  Endif
              Else
                  aAdd(aIncBor, {xFilial("SZG"), cUltCod, SubStr(aResumo[nY][1], 1, 2)+SubStr(aResumo[nY][1], 4, 6), cQdrExp, aResumo[nY][9] })//, aResumo[nY][10] })
              Endif
           Endif
       Next
       PUTMV("MV_QDRTDIA", cDatDia+cLtrDia+cSeqDia)
       If Len(aIncBor) > 0
          If lIncNov //.and. !lChkAmt 
             //Incluir SZF (Cabe็alho do Bordero)
             DbSelectArea("SZF")
             RecLock("SZF", .t.)
                SZF->ZF_FILIAL  := xFilial("SZF")
                SZF->ZF_CODIGO  := cUltCod   	 
                SZF->ZF_EMISSAO := dDataBase
                SZF->ZF_FLAG    := "D"
                SZF->ZF_TIPOBOR := Iif(ncBxFil ="", '1',ncBxFil)
                //SZF->ZF_TIPOBOR := Iif(ncBxFil = 'RETIRA','5', Iif(ncBxFil = 'DEPOSITO', '2', Iif(ncBxFil = 'REGIAO SP', '3', Iif(ncBxFil = 'EXPORTACAO', '4', '1' ))))  // GRAVA TIPO DO BORDERO (TODOS OS PEDIDOS, DEPำSITO, REGIAO OU RETIRA)
             MsUnLock()
          Endif
          //Incluir SZG (Itens do Bordero)
          For nY := 1 To Len(aIncBor)
 	         If (!aIncBor[nY][5] $ 'X') .or. (Alltrim(ncBxFil) $ '6.8')
    	          DbSelectArea("SZG")
        	      RecLock("SZG", .t.)
	                 SZG->ZG_FILIAL  := aIncBor[nY][1]
    	             SZG->ZG_CODIGO  := aIncBor[nY][2]
					 cAux            := alltrim(aIncBor[nY][3])
					 cAux            := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                	 SZG->ZG_PEDIDO  := cAux //aIncBor[nY][3]
	                 SZG->ZG_LOCALIZ := ''//aIncBor[nY][4]
    	             //If GetMV("MV_XHABBOR")
        	         //	SZG->ZG_FLAGLIB := '1'   //PEDIDOS A PROCESSAR RESERVA
	                 //Endif
    	          MsUnLock()
 		     Endif
      	  Next
          If cNumEmp ='01010101'
          	u_WfResBord(cUltCod)
          Endif
       Endif

Return

/*
Static FUNCTION MailExp(cTexto) 
dbselectarea("Z06")
cPara :="valdirene@brasilux.com.br"
cAssunto := "Pedidos com observa็ใo"
cCC      := "expedicao@brasilux.com.br"
cArquivo := ''
				U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo) 
Return nil
*/
