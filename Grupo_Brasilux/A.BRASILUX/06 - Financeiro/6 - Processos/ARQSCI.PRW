#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ARQSCI   ºAutor  ³                    º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera arquivo para envio ao SCI                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Arqsci()
     Private lCont, aRotina, dDataBkp, VerfParam
VerfParam := .F.

/*
mv_par01 ==> Data inicio processamento
mv_par02 ==> Data fim do processamento
mv_par03 ==> Caminho geração do arquivo
mv_par04 ==> Numero de dias depois de vencimento para negativar
mv_par05 ==> Relatorio ou Arquivo
*/


cString := "SA1"
mVAR    := SPACE(30)
mVAR    := "C:\                     "
dbSelectArea("SA1")
//dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 150,1 TO 380,380 DIALOG oGeraTxt TITLE "        GERACAO SCI / EQUIFAX    " 
@ 10,018 Say " Este programa ira gerar um arquivo padrao TXT  para ser " SIZE 200,200 
@ 18,018 Say " enviado para a SCI. Serao gerados dos arquivos, um com  " SIZE 200,200
@ 26,018 Say " as informacoes dos Clientes pessoa juridica ==>SCICNPJ, " SIZE 200,200
@ 34,018 Say " e outro arquivo sao dos clientes pessoa fisica ==> SCICPF " SIZE 200,200
//@ 67,018 SAY "Caminho.: " SIZE 80,80
//@ 67,050 GET mVAR SIZE 120,120 VALID .T.
@ 90,110 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
@ 90,140 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)
@ 90,080 BMPBUTTON TYPE 5 ACTION FParametros()

Activate Dialog oGeraTxt Centered

Return


Static Function OkGeraTxt
mVAR    := MV_PAR03

If !VerfParam
	msgstop("Favor verificar os parametros da rotina","INFO")
	RETURN
Endif

SET DATE FORMAT "dd/mm/yyyy"
dTEmiDE  := substr(dtoc(mv_par01),-4)+substr(dtoc(mv_par01),4,2)+substr(dtoc(mv_par01),1,2)
dTEmiAte := substr(dtoc(mv_par02),-4)+substr(dtoc(mv_par02),4,2)+substr(dtoc(mv_par02),1,2)
SET DATE FORMAT "dd/mm/yy"


If mv_par05 = 1   //Só relatórios 
	ListaNegCnpj()
	ListaNegCPF()
Else

	Private cArqTxt   := ALLTRIM(mVAR)+"SCICNPJ.TXT"
	Private nHdl      := fCreate(cArqTxt)
	Private cChar14   := "              "

	Private cEOL    := "CHR(13)+CHR(10)"

	If Empty(cEOL)
    	cEOL := CHR(13)+CHR(10)
	Else
    	cEOL := Trim(cEOL)
	    cEOL := &cEOL
	Endif

	If nHdl == -1
    	MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
	    Return
	Endif

	Processa({|| RunCNPJ() },"Processando...")


	Private cArqTxtPP := ALLTRIM(mVAR)+"SCICPF.TXT"
	Private nHdlPP    := fCreate(cArqTxtPP)

	If nHdlPP == -1
    	MsgAlert("O arquivo de nome "+cArqTxtPP+" nao pode ser executado! Verifique os parametros.","Atencao!")
	    Return
	Endif

	Processa({|| RunCPF() },"Processando...")

Endif

Close(oGeraTxt)

Return



Static Function RunCNPJ
LOCAL _cLin		:= ""
LOCAL _cCpo		:= ""
LOCAL _cQuery	:= ""
Local _lValid   := .F.
Local _cData    := ""
Local _cEol := chr(13)+chr(10)
Local _cMensagem := "",nAux,cAux
cQuery := "SELECT "
cQuery += "       'TPREG'    = 'J'," // Campo 01. Nao negativa clientes
cQuery += "       'CNPJ'     = A1_CGC,"          // Campo 02
cQuery += "       'NOME'     = SA1.A1_NOME,"         // Campo 03
cQuery += "       'FANTASIA' = A1_NREDUZ,"       // Campo 04
cQuery += "       'NTZ_END'  = 'D',"             // Campo 05
cQuery += "       'ENDERECO' = A1_END,"          // Campo 06
cQuery += "       'CIDADE'   = LEFT(A1_MUN,30)," // Campo 07
cQuery += "       'UF'       = A1_EST,"          // Campo 08
cQuery += "       'CEP'      = A1_CEP,"          // Campo 09
cQuery += "       'DDD_TEL'  = LEFT(RTRIM(A1_DDD),2),"  // Campo 10
cQuery += "       'TELEFONE' = SUBSTRING(A1_TEL,1,10)," // Campo 11
cQuery += "       'DDD_FAX'  = LEFT(A1_FAX,2),"         // Campo 12
cQuery += "       'FAX'      = SUBSTRING(A1_FAX,3,10)," // Campo 13
cQuery += "       'EMAIL'    = SA1.A1_EMAIL,"           // Campo 14
cQuery += "       'DATCAD'   = SUBSTRING(A1_PRICOM,5,2)+SUBSTRING(A1_PRICOM,1,4)," // Campo 15
cQuery += "       'TITULO'   = SE1.E1_NUM+SE1.E1_PARCELA," // Campo 16
cQuery += "       'TIPODOC'  = CASE "        // Campo 17
cQuery += "                     WHEN E1_TIPO   =  'NF' THEN 'N'"
cQuery += "                     WHEN E1_TIPO   =  'CH' THEN 'C'"
cQuery += "                     WHEN E1_TIPO   =  'FT' THEN 'F'"
cQuery += "                     WHEN E1_TIPO   =  'DP' THEN 'D'"
cQuery += "                     WHEN E1_NUMBOR <> ''   THEN 'B'"   
cQuery += "                     ELSE 'O'" 
cQuery += "                    END, "
cQuery += "       'MOEDA'   = 'R$  ',"
cQuery += "       'VALOR'   = 	CONVERT(INT,CONVERT(MONEY,(E1_VALOR)*100)) - " // Campo 19 e 20
cQuery += " 	      			(SELECT ISNULL(CONVERT(INT,CONVERT(MONEY,SUM((E5_VALOR-E5_VLJUROS-E5_VLMULTA-E5_VLCORRE+E5_VLDESCO)*100))),0)"
cQuery += "       				FROM "+RetSqlName("SE5")+" SE5"
cQuery += "       				WHERE SE5.E5_FILIAL = SE1.E1_FILIAL"
cQuery += "       				AND   SE5.E5_NUMERO = SE1.E1_NUM"
cQuery += "       				AND   SE5.E5_PARCELA = SE1.E1_PARCELA"
cQuery += "       				AND   SE5.E5_CLIFOR = SE1.E1_CLIENTE"
cQuery += "       				AND   SE5.E5_LOJA   = SE1.E1_LOJA"
cQuery += "       				AND   (((SE5.E5_MOTBX <> 'NOR') AND (SE5.E5_MOTBX <> 'CMP') AND (SE5.E5_MOTBX <> 'CEC') AND (E5_TIPODOC <> 'JR') AND (E5_TIPODOC <> 'DC') AND (E5_TIPODOC <> 'MT') AND (E5_RECPAG = 'R') AND (E5_SITUACA <> 'C'))) "
cQuery += "       				AND   SE5.D_E_L_E_T_ <> '*'),"
cQuery += "       'VLRPAGO' = CONVERT(INT,CONVERT(MONEY,(SE1.E1_VALLIQ*100)))," // Campo 21 e 22
cQuery += "       'DTVENDA' = SE1.E1_EMISSAO,"                 // Campo 23
cQuery += "       'DTVECTO' = SE1.E1_VENCTO,"                  // Campo 24
cQuery += "       'DTBAIXA' = CASE"                            // Campo 25
cQuery += "                    WHEN SE1.E1_EMISSAO = SE1.E1_VENCTO AND SE1.E1_BAIXA <> '' THEN E1_VENCTO "
cQuery += "                    ELSE SE1.E1_BAIXA "
cQuery += "                   END, "
cQuery += "       'SALDO'   = SE1.E1_SALDO "                            
cQuery += " FROM  " + RetSqlName("SA1") + " SA1, "
cQuery +=             RetSqlName("SE1") + " SE1  "
cQuery += " WHERE (SE1.E1_FILIAL = '"+xFilial("SE1")+"') "
cQuery += " AND ((SE1.E1_EMISSAO BETWEEN '"+ DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "') "
cQuery += " OR    (SE1.E1_BAIXA BETWEEN '"+ DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'))  AND (SE1.E1_EMISSAO > '20050101') "
cQuery += " AND   (SE1.E1_FLAGFAT <> 'S') AND (SE1.E1_TIPO NOT IN('NCC','AB-','JP','RA')) AND (SA1.A1_COD  = SE1.E1_CLIENTE) "
cQuery += " AND   (SA1.A1_LOJA = SE1.E1_LOJA)    "
cQuery += " AND   (SA1.A1_EST <> 'EX')         "
cQuery += " AND   LEN(SA1.A1_CGC) = 14         "
cQuery += " AND   SA1.D_E_L_E_T_ <> '*'        "
cQuery += " AND   SE1.D_E_L_E_T_ <> '*'        "

TcQuery cQuery New Alias "REGSCIJ"

IncProc("Totalizando dados de clientes...")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza array                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("REGSCIJ")
dbGoTop()
WHILE !EOF()
	
	_cLin		:= SPACE(387)

// .And.  REGSCIJ->DTVECTO < DtoS(M->dDataBase)
	
	_lValid := REGSCIJ->VALOR > 0
	
	If _lValid
		
		// Campo 01
		_cCpo		:= PADR(REGSCIJ->TPREG,01)					// Tipo do registro
		_cLin		:= STUFF(_cLin,01,01,_cCpo)
		
		// Campo 02
		_cCpo		:= PADR(REGSCIJ->CNPJ,14)					// Numero do CNPJ
		_cLin		:= STUFF(_cLin,02,15,_cCpo)
		
		// Campo 03
		_cCpo		:= PADR(REGSCIJ->NOME,55)					// Razao social
		_cLin		:= STUFF(_cLin,16,70,_cCpo)
		
		// Campo 04
		_cCpo		:= PADR(REGSCIJ->FANTASIA,55)				// Nome fantasia
		_cLin		:= STUFF(_cLin,71,125,_cCpo)
		
		// Campo 05
		_cCpo		:= PADR(REGSCIJ->NTZ_END,1)				   	// Natureza do endereco
		_cLin		:= STUFF(_cLin,126,126,_cCpo)
		
		// Campo 06
		_cCpo		:= PADR(REGSCIJ->ENDERECO,70)			   	// Endereco
		_cLin		:= STUFF(_cLin,127,196,_cCpo)
		
		// Campo 07
		_cCpo		:= PADR(REGSCIJ->CIDADE,30)			       	// Cidade
		_cLin		:= STUFF(_cLin,197,226,_cCpo)
		
		// Campo 08
		_cCpo		:= PADR(REGSCIJ->UF,2)			       		// UF
		_cLin		:= STUFF(_cLin,227,228,_cCpo)
		
		// Campo 09
		_cCpo		:= PADR(REGSCIJ->CEP,8)			            // CEP
		_cLin		:= STUFF(_cLin,229,236,_cCpo)
		
		// Campo 10
		_cCpo		:= PADR("",4)			        // DDD do telefone
		_cLin		:= STUFF(_cLin,237,240,_cCpo)
		
		// Campo 11
		_cCpo		:= PADR("",10)			    // Numero do telefone
		_cLin		:= STUFF(_cLin,241,250,_cCpo)
		
		// Campo 12
		_cCpo		:= PADR("",4)			        // DDD do fax
		_cLin		:= STUFF(_cLin,251,254,_cCpo)
		
		// Campo 13
		_cCpo		:= PADR("",10)			     	// Numero do fax
		_cLin		:= STUFF(_cLin,255,264,_cCpo)
		
		// Campo 14
		_cCpo		:= PADR("",50)			        // E-MAIL
		_cLin		:= STUFF(_cLin,265,314,_cCpo)
		
		// Campo 15
		_cCpo		:= PADR(REGSCIJ->DATCAD,6)			        // Cliente desde
		_cLin		:= STUFF(_cLin,315,320,_cCpo)
		
		// Campo 16
		_cCpo		:= PADR(REGSCIJ->TITULO,12)			        // Identificador da transacao
		_cLin		:= STUFF(_cLin,321,332,_cCpo)
		
		// Campo 17
		_cCpo		:= PADR(REGSCIJ->TIPODOC,1)			        // Tipo de documento da transacao
		_cLin		:= STUFF(_cLin,333,333,_cCpo)
		
		// Campo 18
		_cCpo		:= PADR(REGSCIJ->MOEDA,4)			        // Moeda
		_cLin		:= STUFF(_cLin,334,337,_cCpo)
		
		// Campos 19 e 20
		_cCpo		:= PADR(STRZERO(REGSCIJ->VALOR,13),13)	    // Valor inteiro da transacao
		_cLin		:= STUFF(_cLin,338,350,_cCpo)
		
		// Campo 21 e 22                            
		nAux = iif(REGSCIJ->SALDO = 0,PADR(STRZERO(REGSCIJ->VALOR,13),13),PADR(STRZERO(REGSCIJ->VLRPAGO,13),13))
		_cCpo		:= nAux 	// Valor inteiro pago
		_cLin		:= STUFF(_cLin,351,363,_cCpo)
		
		// Campo 23
		_cData      := SubStr(REGSCIJ->DTVENDA,7,2) + SubStr(REGSCIJ->DTVENDA,5,2) + SubStr(REGSCIJ->DTVENDA,1,4)
		_cCpo		:= PADR(AllTrim(_cData),8)    // Data da venda
		_cLin		:= STUFF(_cLin,364,371,_cCpo)
		
		// Campo 24         
		cAux := iif(REGSCIJ->DTVECTO < REGSCIJ->DTVENDA,REGSCIJ->DTBAIXA,REGSCIJ->DTVECTO)
		_cData      := SubStr(cAux,7,2) + SubStr(cAux,5,2) + SubStr(cAux,1,4)
		_cCpo		:= PADR(AllTrim(_cData),8)	    // Data do vencimento
		_cLin		:= STUFF(_cLin,372,379,_cCpo)
		
		// Campo 25
		_cData      := SubStr(REGSCIJ->DTBAIXA,7,2) + SubStr(REGSCIJ->DTBAIXA,5,2) + SubStr(REGSCIJ->DTBAIXA,1,4)
		_cCpo		:= PADR(AllTrim(_cData),8)	    // Data da baixa
		_cLin		:= STUFF(_cLin,380,387,_cCpo)
		
		_cLin		+= _cEol
		
		IncProc("Gravando registro! "+Alltrim(REGSCIJ->TITULO))
		
		IF fWrite(nHdl,_cLin,Len(_cLin)) != LEN(_cLin)
			_cMensagem	:= "Ocorreu um erro na gravacao do arquivo. "
			HELP("",1,PROCNAME(),,_cMensagem,1,0)
		ENDIF
	EndIf
	dbSelectArea("REGSCIJ")
	dbSkip()
	
ENDDO

dbCloseArea("REGSCIJ")



fClose(nHdl)


Return



Static Function RunCPF
LOCAL _cLin		:= ""
LOCAL _cCpo		:= ""
LOCAL _cQuery	:= ""
Local _lValid   := .F.
Local _cData    := ""
Local _cMensagem := ""
Local _cEol := chr(13)+chr(10),nAux,cAux
ProcRegua(1)


_cQuery	:= "SELECT 'TPREG'    = 'F', "            // Campo 01
_cQuery	+= "       'CNPJ'     = A1_CGC,"          // Campo 02
_cQuery	+= "       'RG'       = SPACE(20),"       // Campo 03
_cQuery	+= "       'EMISSOR'  = SPACE(04),"       // Campo 04
_cQuery	+= "       'NOME'     = SA1.A1_NOME,"     // Campo 05
_cQuery	+= "       'NTZ_END'  = 'D',"             // Campo 06
_cQuery	+= "       'ENDERECO' = A1_END,"          // Campo 07
_cQuery	+= "       'CIDADE'   = LEFT(A1_MUN,30)," // Campo 08
_cQuery	+= "       'UF'       = A1_EST,"          // Campo 09
_cQuery	+= "       'CEP'      = A1_CEP,"          // Campo 10
_cQuery	+= "       'DDD_TEL'  = LEFT(RTRIM(A1_DDD),2),"  // Campo 11
_cQuery	+= "       'TELEFONE' = SUBSTRING(A1_TEL,1,10)," // Campo 12
_cQuery	+= "       'DDD_FAX'  = LEFT(A1_FAX,2),"         // Campo 13
_cQuery	+= "       'FAX'      = SUBSTRING(A1_FAX,3,10)," // Campo 14
_cQuery	+= "       'EMAIL'    = SA1.A1_EMAIL,"           // Campo 15
_cQuery	+= "       'DATCAD'   = SUBSTRING(A1_PRICOM,5,2)+SUBSTRING(A1_PRICOM,1,4)," // Campo 16
_cQuery	+= "       'TITULO'   = SE1.E1_NUM+SE1.E1_PARCELA," // Campo 17
_cQuery	+= "       'TIPODOC'  = CASE"         // Campo 18
_cQuery	+= "                     WHEN E1_TIPO   =  'NF' THEN 'N'"
_cQuery	+= "                     WHEN E1_TIPO   =  'CH' THEN 'C'"
_cQuery	+= "                     WHEN E1_TIPO   =  'FT' THEN 'F'"
_cQuery	+= "                     WHEN E1_TIPO   =  'DP' THEN 'D'"
_cQuery	+= "                     WHEN E1_NUMBOR <> ''   THEN 'B'"
_cQuery	+= "                    END,"
_cQuery	+= "       'MOEDA'   = 'R$  ',"    // Campo 19
_cQuery += "       'VALOR'   = 	CONVERT(INT,CONVERT(MONEY,(E1_VALOR)*100)) - " // Campo 20 e 21
_cQuery += " 	      			(SELECT ISNULL(CONVERT(INT,CONVERT(MONEY,SUM((E5_VALOR-E5_VLJUROS-E5_VLMULTA-E5_VLCORRE+E5_VLDESCO)*100))),0)"
_cQuery += "       				FROM "+RetSqlName("SE5")+" SE5"
_cQuery += "       				WHERE SE5.E5_FILIAL = SE1.E1_FILIAL"
_cQuery += "       				AND   SE5.E5_NUMERO = SE1.E1_NUM"
_cQuery += "       				AND   SE5.E5_PARCELA = SE1.E1_PARCELA"
_cQuery += "       				AND   SE5.E5_CLIFOR = SE1.E1_CLIENTE"
_cQuery += "       				AND   SE5.E5_LOJA   = SE1.E1_LOJA"
_cQuery += "       				AND   (((SE5.E5_MOTBX <> 'NOR') AND (SE5.E5_MOTBX <> 'CMP') AND (SE5.E5_MOTBX <> 'CEC') AND (E5_TIPODOC <> 'JR') AND (E5_TIPODOC <> 'DC') AND (E5_TIPODOC <> 'MT') AND (E5_RECPAG = 'R') AND (E5_SITUACA <> 'C'))) "
_cQuery += "       				AND   SE5.D_E_L_E_T_ <> '*'),"
_cQuery	+= "       'VLRPAGO' = CONVERT(INT,CONVERT(MONEY,(SE1.E1_VALLIQ*100)))," // Campo 22 e 23
_cQuery	+= "       'DTVENDA' = SE1.E1_EMISSAO,"                 // Campo 24
_cQuery	+= "       'DTVECTO' = SE1.E1_VENCTO,"                  // Campo 25
_cQuery	+= "       'DTBAIXA' = CASE"                  // Campo 26
_cQuery += "                    WHEN SE1.E1_EMISSAO = E1_VENCTO AND SE1.E1_BAIXA <> '' THEN SE1.E1_VENCTO "
_cQuery += "                    ELSE SE1.E1_BAIXA"
_cQuery += "                   END,"
_cQuery += "       'SALDO'   = SE1.E1_SALDO "                            
_cQuery	+= " FROM " + RetSqlName("SA1") + " SA1, "
_cQuery	+=            RetSqlName("SE1") + " SE1 "
_cQuery += " WHERE (SE1.E1_FILIAL = '"+xFilial("SE1")+"') "
_cQuery += " AND ((SE1.E1_EMISSAO BETWEEN '"+ DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "') "
_cQuery += " OR    (SE1.E1_BAIXA BETWEEN '"+ DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'))  AND (SE1.E1_EMISSAO > '20050101') "
_cQuery += " AND   (SE1.E1_FLAGFAT <> 'S') AND (SE1.E1_TIPO NOT IN('NCC','AB-','JP','RA')) AND (SA1.A1_COD  = SE1.E1_CLIENTE) "
_cQuery	+= " AND   SA1.A1_LOJA = SE1.E1_LOJA "
_cQuery	+= " AND   LEN(SA1.A1_CGC) = 11 "
_cQuery += " AND   (SA1.A1_EST <> 'EX')         "
_cQuery	+= " AND   SA1.D_E_L_E_T_ <> '*' "
_cQuery	+= " AND   SE1.D_E_L_E_T_ <> '*' "

TcQuery _cQuery New Alias "REGSCIF"

dbSelectArea("REGSCIF")
dbGoTop()
WHILE !EOF()
	
	_cLin		:= SPACE(353)
	
	_lValid := REGSCIF->VALOR > 0 .And.  REGSCIF->DTVECTO < DtoS(M->dDataBase)
	
	If _lValid
		// Campo 01
		_cCpo		:= PADR(REGSCIF->TPREG,01)		           	// Tipo do registro
		_cLin		:= STUFF(_cLin,01,01,_cCpo)
		
		// Campo 02
		_cCpo		:= PADR(REGSCIF->CNPJ,11)		            // CPF
		_cLin		:= STUFF(_cLin,02,12,_cCpo)
		
		// Campo 03
		_cCpo		:= PADR(SPACE(20),13)			            // RG
		_cLin		:= STUFF(_cLin,13,32,_cCpo)
		
		// Campo 04
		_cCpo		:= PADR(SPACE(04),04)		   		        // Orgao emissor
		_cLin		:= STUFF(_cLin,33,36,_cCpo)
		
		// Campo 05
		_cCpo		:= PADR(REGSCIF->NOME,55)					// Nome do consumidor
		_cLin		:= STUFF(_cLin,37,91,_cCpo)
		
		// Campo 06
		_cCpo		:= PADR(REGSCIF->NTZ_END,1)				    // Natureza do endereco
		_cLin		:= STUFF(_cLin,92,92,_cCpo)
		
		// Campo 07
		_cCpo		:= PADR(REGSCIF->ENDERECO,70) 		        // Endereco
		_cLin		:= STUFF(_cLin,93,162,_cCpo)
		
		// Campo 08
		_cCpo		:= PADR(REGSCIF->CIDADE,30)			        // Cidade
		_cLin		:= STUFF(_cLin,163,192,_cCpo)
		
		// Campo 09
		_cCpo		:= PADR(REGSCIF->UF,2)			            // UF
		_cLin		:= STUFF(_cLin,193,194,_cCpo)
		
		// Campo 10
		_cCpo		:= PADR(REGSCIF->CEP,8)			            // CEP
		_cLin		:= STUFF(_cLin,195,202,_cCpo)
		
		// Campo 11
		_cCpo		:= PADR("",4)			        // DDD do telefone
		_cLin		:= STUFF(_cLin,203,206,_cCpo)
		
		// Campo 12
		_cCpo		:= PADR("",10)			    // Numero do telefone
		_cLin		:= STUFF(_cLin,207,216,_cCpo)
		
		// Campo 13
		_cCpo		:= PADR("",4)			        // DDD do fax
		_cLin		:= STUFF(_cLin,217,220,_cCpo)
		
		// Campo 14
		_cCpo		:= PADR("",10)			        // Numero do fax
		_cLin		:= STUFF(_cLin,221,230,_cCpo)
		
		// Campo 15
		_cCpo		:= PADR("",50)			        // E-MAIL
		_cLin		:= STUFF(_cLin,231,280,_cCpo)
		
		// Campo 16
		_cCpo		:= PADR(REGSCIF->DATCAD,6)			        // Cliente desde
		_cLin		:= STUFF(_cLin,281,286,_cCpo)
		
		// Campo 17
		_cCpo		:= PADR(REGSCIF->TITULO,12)			        // Identificador da transacao
		_cLin		:= STUFF(_cLin,287,298,_cCpo)
		
		// Campo 18
		_cCpo		:= PADR(REGSCIF->TIPODOC,1)			        // Tipo de documento da transacao
		_cLin		:= STUFF(_cLin,299,299,_cCpo)
		
		// Campo 19
		_cCpo		:= PADR(REGSCIF->MOEDA,4)			        // Moeda
		_cLin		:= STUFF(_cLin,300,303,_cCpo)
		
		// Campo 20 e 21
		_cCpo		:= PADR(STRZERO(REGSCIF->VALOR,13),13)	    // Valor inteiro da transacao
		_cLin		:= STUFF(_cLin,304,316,_cCpo)
		
		// Campo 22 e 23
		nAux = iif(REGSCIF->SALDO = 0,PADR(STRZERO(REGSCIF->VALOR,13),13),PADR(STRZERO(REGSCIF->VLRPAGO,13),13))
		_cCpo		:= nAux 	// Valor inteiro pago
		_cLin		:= STUFF(_cLin,317,329,_cCpo)
		
		// Campo 24
		_cData      := SubStr(REGSCIF->DTVENDA,7,2) + SubStr(REGSCIF->DTVENDA,5,2) + SubStr(REGSCIF->DTVENDA,1,4)
		_cCpo		:= PADR(AllTrim(_cData),8)    // Data da venda
		_cLin		:= STUFF(_cLin,330,337,_cCpo)
		
		// Campo 25  
		cAux := iif(REGSCIF->DTVECTO < REGSCIF->DTVENDA,REGSCIF->DTBAIXA,REGSCIF->DTVECTO)
		_cData      := SubStr(cAux,7,2) + SubStr(cAux,5,2) + SubStr(cAux,1,4)
		_cCpo		:= PADR(AllTrim(_cData),8)	    // Data do vencimento
		_cLin		:= STUFF(_cLin,338,345,_cCpo)
		
		// Campo 26
		_cData      := SubStr(REGSCIF->DTBAIXA,7,2) + SubStr(REGSCIF->DTBAIXA,5,2) + SubStr(REGSCIF->DTBAIXA,1,4)
		_cCpo		:= PADR(AllTrim(_cData),8)	    // Data da baixa
		_cLin		:= STUFF(_cLin,346,353,_cCpo)
		
		_cLin		+= _cEol
		
		IncProc("Gravando registro! "+Alltrim(REGSCIF->TITULO))
		
		IF fWrite(nHdl,_cLin,Len(_cLin)) != LEN(_cLin)
			_cMensagem	:= "Ocorreu um erro na gravacao do arquivo. "
			HELP("",1,PROCNAME(),,_cMensagem,1,0)
		ENDIF
	EndIf
	dbSelectArea("REGSCIF")
	dbSkip()
	
ENDDO

dbCloseArea("REGSCIF")

fClose(nHdlPP)

Return
        
Static Function ListaNegCNPJ()

cAlias     := "SE1"
titulo     := "RELATORIO DE CLIENTES QUE SERAO NEGATIVADOS - PESSOA JURIDICA"
cabec1     := "Tit/Parc      Dt.Emissao  Dt.Venc.           Valor          Cod/Loja    Razao Social"
cabec2     := ""
aReturn    := { "Cheque", 1,"Administra‡„o", 1, 2, 1, "",1 }
cNomeRel   := "SCICNPJ"
NomeProg   := "SCICNPJ"
nLastKey   := 0
cPerg      := ""
cDesc2     := "Este programa ir  imprimir os clientes pessoa Juridica "
cDesc3     := "e titulos que serao negativados e enviados ao SCI/EQUIFAX"
cDesc1     := "RELATORIO CLIENTES NEGATIVADOS PESSOA JURIDICA" 
cDesc4     := ""
Tamanho   := "M"
nLargura   := 80
cPag       := 0
TOTDIA1    := 0.00
TOTDIA2    := 0.00
TOTREL1    := 0.00 
TOTREL2    := 0.00
nLin       := 80
cDia       := Date()
m_pag      := 01
cPerg      :=" "
nTipo      := 15


Pergunte(cPerg,.F.)   //F = zera variaveis

wnrel := SetPrint(cAlias,cNomeRel,cPerg,cDesc1,cDesc2,cDesc3,cDesc4,.T.,,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cAlias)  // equivale ao SET DEVICE TO PRINTER/SCREEN

If nLastKey == 27
	Return
Endif

RptStatus({|| DetCNPJ() })

Return()



Static Function DetCNPJ()



//ProcRegua(RecCount()) // Numero de registros a processar


cQuery:="SELECT TIPO = CASE WHEN SE1.E1_BAIXA <> ' ' "
cQuery+="              THEN 'J' "
cQuery+="		       WHEN CAST(SE1.E1_VENCREA AS DATETIME) <= CAST('"+dTEmiAte+"' AS DATETIME) "
cQuery+="			   AND (CAST(SE1.E1_VENCREA AS DATETIME)+ "+str(mv_par04)+") <= CAST('"+dTEmiAte+"' AS DATETIME) "
cQuery+="              THEN 'U'  "
cQuery+="              ELSE 'J' END, "
cQuery+="       SA1.A1_CGC AS CNPJ, SA1.A1_COD AS CODCLI, SA1.A1_LOJA AS LOJA, "
cQuery+="		SUBSTRING(SA1.A1_NREDUZ, 1, 55) AS NREDUZ, SE1.E1_NUM AS NUM, "
cQuery+="	    SE1.E1_PARCELA AS PARCELA, SE1.E1_VALOR AS VALOR, SE1.E1_EMISSAO AS EMISSAO, "
cQuery+="	    SE1.E1_VENCREA AS VENCREA "
cQuery+="FROM "+RetSqlName("SA1")+ " SA1 "+" INNER JOIN "
cQuery+="     "+RetSqlName("SE1")+ " SE1 "+" ON "
cQuery+="		SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA "
cQuery+="WHERE (SA1.D_E_L_E_T_ <> '*') "
cQuery+="		AND (SE1.D_E_L_E_T_ <> '*') "
cQuery+="		AND (LEN(SA1.A1_CGC) = 14) "
cQuery+="		AND (SE1.E1_EMISSAO >= '"+dTEmiDE+"') "
cQuery+="		AND (SE1.E1_EMISSAO <= '"+dTEmiAte+"') "
cQuery+="		AND (SE1.E1_ORIGEM = 'MATA460')   "
cQuery+="		AND CASE WHEN SE1.E1_BAIXA <> ' ' THEN 'J' "
cQuery+=" 	    WHEN CAST(SE1.E1_VENCREA AS DATETIME) <= CAST('"+dTEmiAte+"' AS DATETIME) "
cQuery+="  	    AND (CAST(SE1.E1_VENCREA AS DATETIME)+ "+str(mv_par04)+") <= CAST('"+dTEmiAte+"' AS DATETIME) "
cQuery+="	    THEN 'U'  ELSE 'J' END = 'U' "
cQuery+="	    ORDER BY SE1.E1_NUM, SE1.E1_PARCELA"

TCQUERY cQuery ALIAS TMP NEW

dbSelectArea("TMP")
dbGoTop()
While !EOF() 

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

   @ nLin,00 PSay alltrim(TMP->NUM) +"/"
   @ nLin,11 PSay TMP->PARCELA
   @ nLin,14 PSAY SUBSTR(TMP->EMISSAO,-2)+"/"+SUBSTR(TMP->EMISSAO,5,2)+"/"+SUBSTR(TMP->EMISSAO,1,4)
   @ nLin,25 PSAY SUBSTR(TMP->VENCREA,-2)+"/"+SUBSTR(TMP->VENCREA,5,2)+"/"+SUBSTR(TMP->VENCREA,1,4)
   @ nLin,38 PSay TMP->VALOR  Picture "@E 99,999,999.99"
   @ nLin,58 PSay TMP->CODCLI +" - "
   @ nLin,67 PSay TMP->LOJA
   @ nLin,71 PSay TMP->NREDUZ
   dbSelectArea("TMP")
   dbSkip()
   nLin := nLin + 1
EndDo
DbCloseArea("TMP")
 
If aReturn[5]==1  
        dbCommitAll()
        Set Printer to 
        OurSpool(cNomeRel) 
endif 

MS_FLUSH()

Return


//mgv

Static Function ListaNegCPF()

cAlias     := "SE1"
titulo     := "RELATORIO DE CLIENTES QUE SERAO NEGATIVADOS PESSOA FISICA"
cabec1     := "Tit/Parc      Dt.Emissao  Dt.Venc.           Valor          Cod/Loja    Razao Social"
cabec2     := ""
aReturn    := { "Cheque", 1,"Administra‡„o", 1, 2, 1, "",1 }
cNomeRel   := "SCICPF"
NomeProg   := "SCICPF"
nLastKey   := 0
cPerg      := ""
cDesc2     := "Este programa ir  imprimir os clientes pessao fisica "
cDesc3     := "e titulos que serao negativados e enviados ao SCI/EQUIFAX"
cDesc1     := "RELATORIO CLIENTES NEGATIVADOS PESSOA FISICA" 
cDesc4     := ""
Tamanho   := "M"
nLargura   := 80
cPag       := 0
TOTDIA1    := 0.00
TOTDIA2    := 0.00
TOTREL1    := 0.00 
TOTREL2    := 0.00
nLin       := 80
cDia       := Date()
m_pag      := 01
cPerg      :=" "
nTipo      := 15


Pergunte(cPerg,.F.)   //F = zera variaveis

wnrel := SetPrint(cAlias,cNomeRel,cPerg,cDesc1,cDesc2,cDesc3,cDesc4,.T.,,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cAlias)  // equivale ao SET DEVICE TO PRINTER/SCREEN

If nLastKey == 27
	Return
Endif

RptStatus({|| DetCPF() })// Substituido pelo assistente de conversao do AP5 IDE em 30/11/00 ==> RptStatus({|| Execute(Detalhes) })

Return()



Static Function DetCPF()

/*dbSelectArea("SE2") 
dbSetOrder(10)
dbGoTop()

//SET SOFTSEEK ON
dbSeek(xFilial()+DTOS(mv_par02))
//SET SOFTSEEK OFF

*/

//ProcRegua(RecCount()) // Numero de registros a processar


cQuery:="SELECT TIPO = CASE WHEN SE1.E1_BAIXA <> ' ' "
cQuery+="              THEN 'F' "
cQuery+="      		   WHEN CAST(SE1.E1_VENCREA AS DATETIME) <= CAST('"+dTEmiAte+"' AS DATETIME)  "
cQuery+="			   AND (CAST(SE1.E1_VENCREA AS DATETIME)+ "+str(mv_par04)+") <= CAST('"+dTEmiAte+"' AS DATETIME) "
cQuery+="              THEN 'I' "
cQuery+="			   ELSE 'F' END, "
cQuery+="       SA1.A1_CGC AS CNPJ, SA1.A1_COD AS CODCLI, SA1.A1_LOJA AS LOJA, "
cQuery+="		SUBSTRING(SA1.A1_NREDUZ, 1, 55) AS NREDUZ, SE1.E1_NUM AS NUM, "
cQuery+="	    SE1.E1_PARCELA AS PARCELA, SE1.E1_VALOR AS VALOR, SE1.E1_EMISSAO AS EMISSAO, "
cQuery+="	    SE1.E1_VENCREA AS VENCREA "
cQuery+="FROM "+RetSqlName("SA1")+ " SA1 "+" INNER JOIN "
cQuery+="     "+RetSqlName("SE1")+ " SE1 "+" ON "
cQuery+="		SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA "
cQuery+="WHERE (SA1.D_E_L_E_T_ <> '*') "
cQuery+="		AND (SE1.D_E_L_E_T_ <> '*') "
cQuery+="		AND (LEN(SA1.A1_CGC) = 11) "
cQuery+="		AND (SE1.E1_EMISSAO >= '"+dTEmiDE+"') "
cQuery+="		AND (SE1.E1_EMISSAO <= '"+dTEmiAte+"') "
cQuery+="		AND (SE1.E1_ORIGEM = 'MATA460')   "
cQuery+="		AND CASE WHEN SE1.E1_BAIXA <> ' ' THEN 'F' "
cQuery+=" 	    WHEN CAST(SE1.E1_VENCREA AS DATETIME) <= CAST('"+dTEmiAte+"' AS DATETIME) "
cQuery+="  	    AND (CAST(SE1.E1_VENCREA AS DATETIME)+ "+str(mv_par04)+") <= CAST('"+dTEmiAte+"' AS DATETIME) "
cQuery+="	    THEN 'I'  ELSE 'F' END = 'I' "
cQuery+="	    ORDER BY SE1.E1_NUM, SE1.E1_PARCELA"
TCQUERY cQuery ALIAS TMP NEW

dbSelectArea("TMP")
dbGoTop()
While !EOF() 

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

   @ nLin,00 PSay alltrim(TMP->NUM) +"/"
   @ nLin,11 PSay TMP->PARCELA
   @ nLin,14 PSAY SUBSTR(TMP->EMISSAO,-2)+"/"+SUBSTR(TMP->EMISSAO,5,2)+"/"+SUBSTR(TMP->EMISSAO,1,4)
   @ nLin,26 PSAY SUBSTR(TMP->VENCREA,-2)+"/"+SUBSTR(TMP->VENCREA,5,2)+"/"+SUBSTR(TMP->VENCREA,1,4)
   @ nLin,38 PSay TMP->VALOR  Picture "@E 99,999,999.99"
   @ nLin,58 PSay TMP->CODCLI +" - "
   @ nLin,67 PSay TMP->LOJA
   @ nLin,71 PSay TMP->NREDUZ
   dbSelectArea("TMP")
   dbSkip()
   nLin := nLin + 1
EndDo
DbCloseArea("TMP")
 
If aReturn[5]==1  
        dbCommitAll()
        Set Printer to 
        OurSpool(cNomeRel) 
endif 

MS_FLUSH()

Return

//mgv

Static Function FParametros()

VerfParam := .T.
ValidPerg("ARQSCI")
Pergunte("ARQSCI",.T.)

Return()              

/*/
Programa  : VALIDPERG 
Data      : 28/01/02
Descricao : Grava Perguntas
/*/

Static Function ValidPerg(cPerg)  
Local _sAlias,i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data De            ?","¨De Fecha          ?","From Date          ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Ate           ?","¨A  Fecha          ?","To Date            ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Caminho arquivo TXT?","¨Camino archivo TXT?","TXT File Path      ?","mv_ch3","C",30,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Num Dias Negativar ?","Num Dias Negativar ?","Num Dias Negativar ?","mv_ch4","N",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Relato/Arquivo SCI? ","¨Analitico/Sintetic?","Detail/Summary     ?","mv_ch5","N",01,0,1,"C","","mv_par05","Relatorio","Relatorio","Relatorio","","","ArquivoSCI","ArquivoSCI","ArquivoSCI","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return