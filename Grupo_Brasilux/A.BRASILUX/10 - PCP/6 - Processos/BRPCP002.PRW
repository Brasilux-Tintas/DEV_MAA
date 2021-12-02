#include 'rwmake.ch'
#include "topconn.ch"
#include "avprint.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                             

±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP002 ºAutor  ³ Cleber Orati       º Data ³  05/04/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formular atraves da maquina coloriance a partir de uma OP  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRPCP002()    
Local lSair := .f.
     Private _cPerg := "PCP002"
     Private nLin  := 30
     Private nCol  := 30
     Private nLinMax := 2920
     Private nColMax := 2350
     u_zcfga01( 'BRPCP002' ) //LGS#2021201 - Gravação de log de utilização da rotina
     
	//ValidPerg(_cPerg) //LGS#20200206 - Adequação de release 12.1.25 e posteriores
	
	do while !lSair    
       //lSair := !Pergunte(_cPerg,.t.)
       lSair := fPegPrg()
       if !lSair     
          MsAguarde({|| PCP002_1() },"Aguarde","Processando...")     
	   Endif
    enddo 

Return

Static Function fPegPrg()
       Local _lRet
       lRet := !Pergunte(_cPerg,.t.)
Return _lRet

/**********************************************************************************************************/
/*** PCP002_1 - Gera arquivo CL_Link.txt																***/
/**********************************************************************************************************/
Static Function PCP002_1()
//Local cCond    := ""
Local cQuery   := ""   
//Local nQtdeItens := 0
Local lSucesso := .t.
Local _cPath     := Alltrim( mv_par02 )
Local _cFile     := "CL_Link.txt"
Local _cEOL := CHR(13)+CHR(10)
Local cStringarq := "" && Nova máquina, gerar arquivo .txt
Local nContPig := 0 && qtde pigmentos formula

Private _nHdl  

if substr(_cPath,len(_cPath),1) != "\"
	_cPath += "\"
endif

cAux := _cPath+_cFile
if file(cAux)
	ferase(cAux)
endif 


cQuery := "SELECT D4_COD AS CODPRO,SUM(D4_QUANT*1000/(CASE WHEN B1_PESOESP > 0 THEN B1_PESOESP ELSE 1 END)) AS QTDEML "+;
"FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = D4_COD) "+;
"WHERE (SD4.D_E_L_E_T_ <> '*') AND (D4_FILIAL = '"+xFilial("SD4")+"') AND (D4_OP = '"+alltrim(MV_PAR01)+"') "+;
"AND (D4_QUANT > 0) "+;
"GROUP BY D4_COD ORDER BY CODPRO"
If Select("TCQ") <> 0
	dbclosearea()
endif 
TCQuery cQuery NEW ALIAS "TCQ"
	
cStringarq := "" && Nova máquina, gerar arquivo .txt
nContPig := 0 && qtde pigmentos formula

dbselectarea("TCQ")
dbgotop()
do while lSucesso .and. !eof()     
	DO CASE
	CASE TCQ->CODPRO = "0844"
		cPigto := "LS"
	CASE TCQ->CODPRO = "0849"
		cPigto := "US"
	CASE TCQ->CODPRO = "0866"
		cPigto := "FT"
	CASE TCQ->CODPRO = "0878"
		cPigto := "MM"
	CASE TCQ->CODPRO = "0871"
		cPigto := "RS"
	CASE TCQ->CODPRO = "0872"
		cPigto := "RT"
	CASE TCQ->CODPRO = "0891"
		cPigto := "TT"
	CASE TCQ->CODPRO = "0893"
		cPigto := "VT"
	CASE TCQ->CODPRO = "0892"
		cPigto := "XT"
	CASE TCQ->CODPRO = "0868"
		cPigto := "ZT"
	CASE TCQ->CODPRO = "0846"
		cPigto := "MS"
	CASE TCQ->CODPRO = "0869"
		cPigto := "ZC"
	OTHERWISE
		cPigto := ""
	ENDCASE 

	IF !EMPTY(cPigto)
		if TCQ->QTDEML <= 2000
			cStringarq = cStringarq + cPigto+"="+ALLTRIM(transform(TCQ->QTDEML,"999999.99"))+_cEOL
			nContPig = nContPig + 1 
		else
			MsgBox("Qtde para o produto "+ALLTRIM(TCQ->CODPRO)+" MAIOR QUE 2(DOIS) LITROS! Dosagem IGNORADA!","Atenção","Alert")
		endif 
			
	ENDIF

	dbselectarea("TCQ")
	dbskip()
ENDDO    
IF nContPig = 0
	MsgBox("Empenho Zerado!","Atenção","Alert")
	return(.f.)
ENDIF 
	

_nHdl  := fCreate(_cPath+_cFile )
If _nHdl == -1
	MsgAlert("O arquivo "+_cPath+_cFile+" nao pode ser criado! ","Atencao!")
	Return
Endif

_cLin := "[FORMULA1]"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "NumColorants="+ALLTRIM(STR(nContPig))+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "ColorName=OP "+MV_PAR01+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "MainProduct=OP "+MV_PAR01+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "SubProduct=OP "+MV_PAR01+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "CanSize=2000"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "DispenseUnit=ml"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "FractionalPart=ml"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "PartialShots=ml"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "Base=Sunguard A"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "RGB=0"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "FanDeck=COLOUR SENSATION"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "TypeID=COLOUR SENSATION"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := " "+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "[INGREDIENTS1]"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := cStringarq+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "[SPECTRAL1]"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "GlossValue= 20"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "GlossGeometry=2"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := " "+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "[STATUS]"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "Cancel=0"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "[SUMMARY]"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
_cLin := "TotalFormulas=1"+_cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
fClose(_nHdl)

MsgBox("ARQUIVO GERADO!","Atenção","Info")
	
Return

/**********************************************************************************************************/
/*** VldPerg - Monta perguntas na tabela SX1                                                            ***/
/**********************************************************************************************************/
//LGS#20200206 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg(_cPerg)
Local _sAlias,aHelp := {}
_sAlias := Alias()
_cPerg := PADR(_cPerg,10)

AAdd(aHelp, {{"Nro da OP"},  {"Nro da OP"}, {"Nro da OP"}})
AAdd(aHelp, {{"Caminho onde será salvo o arquivo"}, {"Caminho onde será salvo o arquivo"}, {"Caminho onde será salvo o arquivo"}})

PutSX1(_cPerg,"01",  "Nro da OP   ?", "Nro da OP   ?", "Nro da OP   ?", "mv_ch1", "C",11, 0, 0,"G"," ", "SC2", " ", " ", "mv_par01", "", " ", " " , " ", "", " ", " " , "", " ", " ", " ", " ", " " , " "," "," ", aHelp[1,1],aHelp[1,2],aHelp[1,3] , _cPerg  )
PutSX1(_cPerg,"02",  "Salvar em?"   ,"Salvar em?"    ,"Salvar em?"    ,"mv_ch2" , "C",40,00,00,"G","","","","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],_cPerg)

  

dbSelectArea(_sAlias)
Return*/
