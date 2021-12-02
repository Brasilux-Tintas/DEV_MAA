#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function LIBFIS02()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local cCgc := "",nValor,cBaixa,cAuxTit
Private _cString   := "SA1"
Private  cPerg     := "LIBFIS02"
Private _oGeraTxt  
Private _cPath     := '', _cFile  := ''
Private _cEOL      := "CHR(13)+CHR(10)"
Private _nTotCli   := 0 
Private _nTotcRec  := 0   
Private MV_PAR01:=MV_PAR02:= ""                                       

  if !u_VldAcesso(funname())
      	  MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
    	  return 
  endif 
     u_zcfga01( 'LIBFIS02' ) //LGS#2021201 - Gravação de log de utilização da rotina
//CriaSX1(cPerg) //LGS#20200131 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("CONS. COMPLI. IMP.")
@ 02,10 TO 060,215
@ 10,018 Say " Este programa ira gerar entrada  " SIZE 196,0
@ 18,018 Say " de nota fiscal " SIZE 196,0

@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| BTNGerNF() }) 
@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered                            

Return
//-------------------------------------        
                                                             
Static Function BTNGerNF() 
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal,cQuery
Private _nLin := 7

	cQuery := "Exec COMPLEMENTOIMPORTACAO '"+xFilial("SD1")+"','"+MV_PAR01+"','"+MV_PAR02+"'"
	TCQuery cQuery NEW ALIAS "TCQ"  
	                        
If(!Empty(MV_PAR01).AND.!Empty(MV_PAR02))
	  MsgBox(TCQ->MENSAGEM,iif(TCQ->RETORNO = 0,"Erro!","Ok"),iif(TCQ->RETORNO = 0,"ERROR","ALERT"))
	Else
 MsgBox("Preencher todos os parametros","Atenção","Alert")
endif	
dbselectArea("TCQ")
dbclosearea()
Return
//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}
//            Texto do help em português                , inglês, espanhol
PutSX1(cPerg,"01","Serie NF         ","Periodo de  ?"   ,"Periodo de  ?"   ,"mv_ch1","C", 3, 0, 0,"G","","","","","mv_par01","      ","      ","      ","","","","","","","","","","","","","",Nil,Nil,Nil,cPerg)
PutSX1(cPerg,"02","Numero NF        ","Periodo ate  ?"  ,"Periodo ate  ?"  ,"mv_ch2","C", 9, 0, 0,"G","","","","","mv_par02","      ","      ","      ","","","","","","","","","","","","","",Nil,Nil,Nil,cPerg)

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
Return */
