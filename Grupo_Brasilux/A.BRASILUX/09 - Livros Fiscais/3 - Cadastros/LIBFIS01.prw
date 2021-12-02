#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function LIBFIS01()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local cCgc := "",nValor,cBaixa,cAuxTit
Private _cString   := "SA1"
Private  cPerg     := "LIBFIS01"
Private _oGeraTxt  
Private _cPath     := '', _cFile  := ''
Private _cEOL      := "CHR(13)+CHR(10)"
Private _nTotCli   := 0 
Private _nTotcRec  := 0   
Private MV_PAR01:=MV_PAR02:=MV_PAR03:=MV_PAR05:=MV_PAR08:=MV_PAR10:=MV_PAR11:=MV_PAR12:=""                                       
Private MV_PAR04:=MV_PAR06:=MV_PAR07 := MV_PAR09:=(ctod(space(8)))

  if !u_VldAcesso(funname())
      	  MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
    	  return 
  endif 
     u_zcfga01( 'LIBFIS01' ) //LGS#2021201 - Gravação de log de utilização da rotina

CriaSX1(cPerg) //LGS#20200131 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("CONS. COMPLI. EXP.")
@ 02,10 TO 060,215
@ 10,018 Say " Este programa ira gerar dados de notas fiscais  " SIZE 196,0
@ 18,018 Say " complementares de exportação " SIZE 196,0

@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| BTNGerNF() }) 
@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered                            

Return
//-------------------------------------        
                                                             
Static Function BTNGerNF() 
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal,cQuery
Private _nLin := 7


	cQuery := "EXEC COMPLEMENTOEXPORTACAO '"+xFilial("SF2")+"','"+alltrim(mv_par01)+"', "
	cQuery += "'"+alltrim(MV_PAR02)+"','"+alltrim(MV_PAR03)+"','"+dtos(MV_PAR04)+"', "
	cQuery += "'"+alltrim(MV_PAR05)+"','"+dtos(MV_PAR06)+"','"+dtos(MV_PAR07)+"', "
	cQuery += "'"+alltrim(MV_PAR08)+"','"+dtos(MV_PAR09)+"','"+alltrim(MV_PAR10)+"', "
	cQuery += "'"+alltrim(MV_PAR11)+"','"+alltrim(MV_PAR12)+"'"
	TCQuery cQuery NEW ALIAS "TCQ"  
	                        

If(!Empty(MV_PAR01).AND.!Empty(MV_PAR02).AND.!Empty(MV_PAR03).AND.!Empty(MV_PAR04).AND.!Empty(MV_PAR05).AND.!Empty(MV_PAR06).AND.!Empty(MV_PAR07).AND. ;
!Empty(MV_PAR08).AND.!Empty(MV_PAR09).AND.!Empty(MV_PAR10).AND.!Empty(MV_PAR11).AND.!Empty(MV_PAR12))
	  
	  MsgBox(TCQ->MENSAGEM,iif(TCQ->RETORNO = 0,"Erro!","Ok"),iif(TCQ->RETORNO = 0,"ERROR","ALERT"))
Else
 	MsgBox("Preencher todos os parametros","Atenção","Alert")
endif	
	
dbselectArea("TCQ")
dbclosearea()
Return
//LGS#20200131 - Adequação de release 12.1.25 e posteriores

Static Function CriaSX1(cPerg)
_sAlias := Alias()
cPerg := PADR(cPerg, 10)

//            Texto do help em português                , inglês, espanhol

u_xPutSX1(cPerg,"01","Serie NF         ","Periodo de  ?"   ,"Periodo de  ?"   ,"mv_ch1","C", 3, 0, 0,"G","","","","","mv_par01","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"02","Numero NF        ","Periodo ate  ?"  ,"Periodo ate  ?"  ,"mv_ch2","C", 9, 0, 0,"G","","","","","mv_par02","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"03","Numero DE        ","Periodicidade?"  ,"Periodicidade?"  ,"mv_ch3","C",20, 0, 0,"G","","","","","mv_par03","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"04","Data De          ","Nome do Arquivo?","Nome do Arquivo?","mv_ch4","D", 8,00, 0,"G","","","","","mv_Par04","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"05","Numero RE        ","Salvar em?"      ,"Salvar em?"      ,"mv_ch5","C",20,00, 0,"G","","","","","mv_Par05","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"06","Data RE          ","Salvar em?"      ,"Salvar em?"      ,"mv_ch6","D", 8,00, 0,"G","","","","","mv_Par06","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"07","Data averbação   ","Periodo de  ?"   ,"Periodo de  ?"   ,"mv_ch7","D", 8, 0, 0,"G","","","","","mv_par07","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"08","Nro Conhecimento ","Periodo ate  ?"  ,"Periodo ate  ?"  ,"mv_ch8","C",20, 0, 0,"G","","","","","mv_par08","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"09","Data Conhecimento","Periodicidade?"  ,"Periodicidade?"  ,"mv_ch9","D", 8, 0, 0,"G","","","","","mv_par09","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"10","Tipo Conhecimento","Nome do Arquivo?","Nome do Arquivo?","mv_cha","C", 2,00, 0,"G","","SV","","","mv_Par10","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"11","UF Embarque      ","Salvar em?"      ,"Salvar em?"      ,"mv_chb","C", 2,00, 0,"G","","","","","mv_Par11","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
u_xPutSX1(cPerg,"12","Local Embarque   ","Salvar em?"      ,"Salvar em?"      ,"mv_chc","C",60,00, 0,"G","","","","","mv_Par12","      ","      ","      ","","","","","","","","","","","","","","","","",cPerg)
                   
DbSelectArea(_sAlias)
Return 
