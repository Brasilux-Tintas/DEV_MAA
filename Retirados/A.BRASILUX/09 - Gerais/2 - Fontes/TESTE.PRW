#INCLUDE 'Protheus.ch'
#include "topconn.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include 'DIRECTRY.CH' 
#include "TbiConn.ch"
#include 'appexcel.ch'

/*
  Local nHandle := TCLink( "MSSQL/DSN1", "127.0.0.1", 7890 )
  Local cTable := "MYTABLE"
  Local cRDD := "TOPCONN"
*/
User Function TESTE()
Local aPed,aItensPed,cCliente,cObs,nQtdeItens,i,_cLocal,nQtde,cProd,aAux,cErros,_cItem,cAviso,cErro ,cAuxCod,nAuxQtde,lSucesso,lIncluiped,cLoja
Local aFields := {}
Local oTempTable,lSucesso
Local nI
Local cAlias := "SX5"
Local cQuery,aPlan,nCont
Private cEdit1,_DESCdigit,_NCMdigit,lOut,lOk,_oPT00005,cCodPrf,lFimDlg,cInstr


if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),__CUSERID) <> 0 
	MsgAlert("Acesso somente p/ usuario com perm. Admin", "Aviso")
	RETURN
endif 

lOut := .f. //Sair do programa
cBuffer := ""
cInstr := space(600)

Do While .T.
	_oPT00005 := nil
	DEFINE MSDIALOG _oPT00005 FROM  50, 050 TO 400,500 TITLE OemToAnsi('Instru��es de Comando') PIXEL	// "Movimenta��o Banc�ria"
	
	@ 003,005 Say OemToAnsi("Instru��o: ") Size 040,030
	
	@ 003,030 Get cInstr  Picture "@!S600"  Size 150,150 // Valid AchaFile(@cArquivo)
	
	
	@ 100,110 Button OemToAnsi("Ok")  Size 036,016 Action (_oPT00005:End())
	@ 100,160 Button OemToAnsi("Sair")   Size 036,016 Action Fecha()
	
	Activate Dialog _oPT00005 CENTERED


	if lOut
		exit
	else 
		cQuery := alltrim(cInstr)
		if (TCSqlExec(cQuery) < 0 )
			cAux := "Processo Finalizado. Houveram Erros!"
		else
			cAux := "Processo Finalizado!"	
		endif
		MsgAlert(cAux, "Aviso")

	endif 
ENDDO 

RETURN 

StatiC Function Fecha()
cInstr := ""
Close(_oPT00005)     
lOut := .t.
Return


U_zCadSX5('ZV')
/*
		cQuery := "Exec dbo.CopiarProduto '"+MV_PAR01+"','"+MV_PAR02+"','"+TCQ->B1_COD+"' "
		if (TCSqlExec(cQuery) < 0 )
			cAux := "Processo Finalizado!"	
		else
			cAux := "Processo Finalizado. Houveram Erros!"
		endif
 */

RETURN NIL




Static Function ProdKit(_cOp)
Local lRet,aVetor,nOpc,dData
private lMsErroAuto,lMsHelpAuto
lRet := .t.
lMsErroAuto := .F.
	aVetor := {}         
	nOpc   := 3 //-Opção de execução da rotina, informado nos parametros quais as opções possiveisl
	dbselectarea("SC2")
	dbsetorder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD    
	msseek(xFilial("SC2")+_cOp,.t.)                                                                                                               
	dData:=dDataBase
	aVetor := {; 
          {"D3_OP"     ,_cOp   ,NIL},;
          {"D3_TM"     ,"001"          ,NIL},;
          {"D3_LOTECTL",SC2->C2_XLOTE          ,NIL},;
          {"D3_DTVALID",SC2->C2_DATPRF        ,NIL}}                                      
 
	MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc ) 
if lMsErroAuto
	MostraErro()
	lRet := .f.
endif 

return(lRet)

Static Function ExcluiKit(_cOp)
Local aMATA650      := {}       //-Array com os campos
Private lMsErroAuto,lMsHelpAuto
lRet := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao     ³
//³ 4 - Alteracao    ³
//³ 5 - Exclusao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbselectarea("SC2")
	dbsetorder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD    
	msseek(xFilial("SC2")+_cOp,.t.)                                                                                                               
  
aMata650  := {  {'C2_FILIAL'   ,xFilial("SC2")              ,NIL},;
                {'C2_PRODUTO'  ,SC2->C2_PRODUTO       ,NIL},;         
  	            {'C2_NUM'     ,SC2->C2_NUM                    ,NIL},;         
  	            {'C2_ITEM'     ,SC2->C2_ITEM                    ,NIL},;         
                {'C2_SEQUEN'   ,SC2->C2_SEQUEN                  ,NIL}}           
                  

lMsErroAuto := .f.  
      
msExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)
if lMsErroAuto
	MostraErro()
	lRet := .f.
endif 

return(lRet)
