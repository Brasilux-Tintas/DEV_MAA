#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function DSERASA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCgc := "",nValor,cBaixa,cAuxTit
Private _cString   := "SA1"
Private _cPerg     := "DSERASA"
Private _oGeraTxt  
Private _cPath     := '', _cFile  := ''
Private _cEOL      := "CHR(13)+CHR(10)"
Private _nTotCli   := 0 
Private _nTotcRec  := 0
     u_zcfga01( 'DSERASA' ) //LGS#2021201 - Gravação de log de utilização da rotina
//CriaSX1(_cPerg)  //LGS#20200131 - Adequação para release 12.1.25 e posteriores
Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Geracao de Arquivo Exportacao SERASA")
@ 02,10 TO 060,215
@ 10,018 Say " Este programa ira gerar um arquivo texto com   informações de clientes para o " SIZE 196,0
@ 18,018 Say " SERASA e serão utilizados para informações comerciais.                        " SIZE 196,0

@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkGeraTrb() }) 
@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered

Return
//-------------------------------------
Static Function OkGeraTrb
Local _cTipoMov,_cEmpr,_cFil,nTamFil
_cPath     := Alltrim( mv_par05 )
_cFile     := alltrim(mv_par04)
_cDataIni  := MV_PAR01
_cTipoMov  :=''
_nTotcRec  := 0
Private _nHdl  

if substr(_cPath,len(_cPath),1) != "\"
	_cPath += "\"
endif

_nHdl  := fCreate(_cPath+_cFile + ".TXT")

_cEOL := CHR(13)+CHR(10)

If _nHdl == -1
	MsgAlert("O arquivo "+_cPath+_cFile+".TXT"+" nao pode ser executado! Verifique os parametros.","Atencao!")
	Return
Endif
//  
_cTipoMov := 'S'
Do case 
   case mv_par03 ==1 
       _cTipoMov := 'D'
   case mv_par03 ==2   
       _cTipoMov := 'S' 
   case mv_par03 ==3    
       _cTipoMov := 'Q'
   case mv_par03 ==4    
       _cTipoMov := 'M'   
Endcase  
//    

_cEmpr := FWCompany()
_cFil := xFilial("SE1")
nTamFil := FWSizeFilial()

cQuery := "SELECT E1_FILIAL AS FILIAL,"+;
       "'TPREG'    = 'J',"+;
       "'CNPJ'     = A1_CGC,"+;
       "'CODCLI'     = SA1.A1_COD,  "+;
       "'NOME'     = SA1.A1_NOME,  "+;
       "'FANTASIA' = A1_NREDUZ,"+;
       "'NTZ_END'  = 'D',"+;
       "'ENDERECO' = A1_END,"+;        
       "'CIDADE'   = LEFT(A1_MUN,30),"+;
       "'UF'       = A1_EST,"+;
       "'CEP'      = A1_CEP,"+;         
       "'DDD_TEL'  = LEFT(RTRIM(A1_DDD),2),"+; 
       "'TELEFONE' = SUBSTRING(A1_TEL,1,10),"+;
       "'EMAIL'    = SA1.A1_EMAIL,"+;           
       "'PRICOM'   = A1_PRICOM,"+; 
       "'DATCAD'   = SUBSTRING(A1_PRICOM,5,2)+SUBSTRING(A1_PRICOM,1,4),"+; 
       "'PREF'   =	SE1.E1_PREFIXO,"+;
       "'TITULO'   = SE1.E1_NUM,"+;
       "'PARC'   	 = SE1.E1_PARCELA,"+; 
       "'TIPO'   	 = SE1.E1_TIPO,"+; 
       "'TIPODOC'  = CASE "+;        
       "              WHEN E1_TIPO   =  'NF' THEN 'N' "+;
       "              WHEN E1_TIPO   =  'CH' THEN 'C' "+;
       "              WHEN E1_TIPO   =  'FT' THEN 'F' "+;
       "              WHEN E1_TIPO   =  'DP' THEN 'D' "+;
       "              WHEN E1_NUMBOR <> ''   THEN 'B' "+;   
       "              ELSE 'O' "+;
       "             END,"+; 
       "'VALOR'   = CONVERT(INT,CONVERT(MONEY,(SE1.E1_VALOR*100))),"+;
       "'VLRPAGO' = CONVERT(INT,CONVERT(MONEY,(SE1.E1_VALLIQ*100))),"+; 
       "'DTVENDA' = SE1.E1_EMISSAO,"+;                 
       "'DTVECTO' = SE1.E1_VENCREA,"+;                  
       "'DTBAIXA' = SE1.E1_BAIXA,"+; 
       "'SALDO'   = CONVERT(INT,CONVERT(MONEY,(SE1.E1_SALDO*100))),"+;
       "'REG'     = SE1.R_E_C_N_O_ "+;
 		"FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (E1_CLIENTE = A1_COD) AND (SA1.A1_LOJA = SE1.E1_LOJA) "+;
 		"WHERE (SE1.D_E_L_E_T_ <> '*') AND "+;
 		iif(nTamFil = 2,"(SE1.E1_FILIAL = '"+xFilial("SE1")+"') ",iif(!empty(alltrim(substr(_cFil,1,1))),"(SE1.E1_FILIAL LIKE '"+_cEmpr+"%')",""))+" AND "+;
 		"(SE1.E1_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"') AND "+;
 		"(SE1.E1_FLAGFAT <> 'S') AND (SE1.E1_TIPO NOT IN('NCC','AB-','JP','RA')) AND "+; 
 		"(SA1.A1_EST <> 'EX') AND (LEN(A1_CGC) = 14) "+;
 		"ORDER BY CNPJ,DTVENDA "    
/*
 		"((SE1.E1_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"') "+;
 		"OR    (SE1.E1_BAIXA BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"'))  AND (SE1.E1_EMISSAO > '20060101') "+;
*/
TcQuery cQuery New Alias "REGSCIJ"

dbSelectArea('SA1')
DbSetOrder(1)
DbSeek(xFilial('SA1'))
ProcRegua( lastrec() )
//
// O bloco Abaixo tem como objetivo montar o arquivo com os dados do cliente
// A primeira parte gravará o cabecalho do arquivo
_cLin := '00RELATO COMP NEGOCIOS'+PADR(ALLTRIM(SM0->M0_CGC),14," ")+ dtos( MV_PAR01 ) + dtos( MV_PAR02 ) + _cTipoMov + space(15) + space(3) + space(29) +"V.01"+space(26)+ _cEOL
//
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif
//
ntotReg := 0 
dbselectarea("REGSCIJ")
DBGOTOP()
While !eof()

		
  _cLin := '01'+ PADR(REGSCIJ->CNPJ,14," ") + '01' + REGSCIJ->PRICOM
  //
  IF  DDATABASE  - SA1->A1_PRICOM  >= 365
    _cLin += '1'
  Elseif alltrim( dtos( SA1->A1_PRICOM ) ) <> '' .and. DDATABASE  - SA1->A1_PRICOM  < 365
    _cLin += '2'    
  Elseif alltrim( dtos( SA1->A1_PRICOM ) ) == ''
    _cLin += '3'        
  Endif  
  //
  _cLin += space(103) + _cEOL
  //
  If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
   	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
   		Return
   	Endif
  Endif
  IncProc(OemToAnsi("Lendo Cliente " + REGSCIJ->CODCLI + ' - ' + Alltrim(REGSCIJ->NOME) ))  

  DbSelectArea("REGSCIJ")   
  cCgc := alltrim(REGSCIJ->CNPJ) 
  do while !eof() .and. (cCgc == alltrim(REGSCIJ->CNPJ))
//         _cLin  := '01' + PADR(REGSCIJ->CNPJ,14," ") + '05'+ padr( ALLTRIM(REGSCIJ->TITULO) + '/' + REGSCIJ->PARC, 10 ) + REGSCIJ->DTVENDA + PADL(ALLTRIM(STR(REGSCIJ->VALOR)),14,"0")
	nValor := REGSCIJ->VALOR //iif(REGSCIJ->SALDO > 0,REGSCIJ->SALDO,REGSCIJ->VALOR)
	cBaixa := iif(REGSCIJ->SALDO > 0,"",IIF(REGSCIJ->DTBAIXA > dtos(mv_par02),"",REGSCIJ->DTBAIXA))
	_cLin  := '01' + PADR(alltrim(REGSCIJ->CNPJ),14," ") + '05'+ padr( ALLTRIM(STR(REGSCIJ->REG)), 10 ) + REGSCIJ->DTVENDA + PADL(ALLTRIM(STR(nValor)),13,"0")
	_cLin  += iif(REGSCIJ->DTVECTO < REGSCIJ->DTVENDA,REGSCIJ->DTVENDA,REGSCIJ->DTVECTO) + PADL(cBaixa,8," ")  
    cAuxTit := "#D"+PADR(REGSCIJ->FILIAL,FWSizeFilial()," ")+PADR(REGSCIJ->PREF,TamSX3("E1_PREFIXO")[1]," ")+PADR(REGSCIJ->TITULO,TamSX3("E1_NUM")[1]," ")+PADR(REGSCIJ->PARC,TamSX3("E1_PARCELA")[1]," ")+PADR(REGSCIJ->TIPO,TamSX3("E1_TIPO")[1]," ")
    _cLin += PADR(cAuxTit,34," ")+space(31)+_cEOL
	If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			Return
		Endif
	Endif
	_nTotcRec ++

	 DbSelectArea("REGSCIJ")
  	 DbSkip()
   Enddo
  ntotReg ++
  DbSelectArea("REGSCIJ")
  // 
Enddo

  // O bloco abaixo gravara o footer do arquivo.
DbSelectArea("REGSCIJ")
dbclosearea()
 _cLin  := '99'+ strzero( ntotReg , 11 ) + space(44) + strzero( _nTotcRec, 11 )  + space(62) + _ceol
 If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
    If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
  	  Return
    Endif
 Endif
//
fClose(_nHdl)
//
Return  

/*/
Programa  : CRIASX1   Autor:  
Data      : 01/03/02
Descricao : Grava Perguntas
/*/
//LGS#20200131 - Adequação para release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//            Texto do help em português                , inglês, espanhol
AAdd(aHelp, {{"Data Inicial do Movimento Financeiro"},  {"Data Inicial do Movimento Financeiro"}, {"Data Inicial do Movimento Financeiro"}})
AAdd(aHelp, {{"Data Final do Movimento Financeiro"}, {"Data Final do Movimento Financeiro"}, {"Data Final do Movimento Financeiro"}})
AAdd(aHelp, {{"Informe o período em que se informa"}, {"Informe o período em que se informa"}, {"Informe o período em que se informa"}})
AAdd(aHelp, {{"Nome do arquivo (somente nome SEM EXTENSÃO)"}, {"Nome do arquivo (somente nome SEM EXTENSÃO)"}, {"Nome do arquivo (somente nome SEM EXTENSÃO)"}})
AAdd(aHelp, {{"Caminho onde será salvo o arquivo"}, {"Caminho onde será salvo o arquivo"}, {"Caminho onde será salvo o arquivo"}})

PutSX1(cPerg,"01",  "Periodo de  ?", "Periodo de  ?", "Periodo de  ?", "mv_ch1", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par01", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , aHelp[1,1],aHelp[1,2],aHelp[1,3]    , cPerg )
PutSX1(cPerg,"02",  "Periodo ate  ?", "Periodo ate  ?", "Periodo ate  ?", "mv_ch2", "D",  8, 0, 0, "G", " ", ""   , " ", " ", "mv_par02", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "  ,aHelp[2,1],aHelp[2,2],aHelp[2,3] , cPerg )
PutSX1(cPerg,"03",  "Periodicidade?", "Periodicidade?", "Periodicidade?", "mv_ch3", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par03", "Diário"         , "Diário", "Diário"     , " "   , "Semanal", "Semanal", "Semanal" , "Quinzenal" ,"Quinzenal","Quinzenal", "Mensal" , "Mensal", "Mensal", Nil,  Nil,  Nil , aHelp[3,1],aHelp[3,2],aHelp[3,3] , cPerg )
PutSX1(cPerg,"04",  "Nome do Arquivo?"  ,"Nome do Arquivo?","Nome do Arquivo?","mv_ch4","C",20,00,00,"G","",""   ,"","","mv_Par04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],cPerg)
PutSX1(cPerg,"05",  "Salvar em?"  ,"Salvar em?","Salvar em?","mv_ch5","C",40,00,00,"G","",""   ,"","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],cPerg)

Return
*/
