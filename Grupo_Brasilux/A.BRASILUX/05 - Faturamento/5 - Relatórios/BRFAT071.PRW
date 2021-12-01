#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT071     Data....: 08/05/02         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Vendas no Trimestre					   //
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // À partir de qual mês?               //
/////////////////////////////////////////////////////////

User Function BRFAT071()     
Local CbTxt,CbCont,nOrdem,Alfa,Z,M
Private tamanho,limite,titulo,cDesc1,cDesc2,cDesc3,cCabec,cCabPro
Private cNatureza,aReturn,nomeprog,cPerg,nLastKey,lContinua,nLin,nCol,wnrel,;
nTipo,m_pag,nTamNf,cString

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="G"
limite   :=220
titulo   :="RELATORIO DE VENDAS TRIMESTRAL"
cDesc1   :=PADC("Este programa ira emitir o Rel. Vendas no Trimestre.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Vendas no Trimestre",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT071"
cPerg    :="BRFT71"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT071"
nTipo    := 15
m_pag    := 01     
nTamNf   := 80     // Apenas Informativo
cString  := "SC5"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFAT071' ) //LGS#2021201 - Gravação de log de utilização da rotina
//ValidPerg()
Pergunte(cPerg,.F.)   

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey == 27
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RptDetail()})

Return

Static Function RptDetail()

Local cEmpresa,cEmis01,cEmis02,nAux,cMes,cAno,cQuery
Local nMes01,nMes02,nMes03,nSoma,cAuxCli,cMes01,cMes02,cMes03,cRepres

cMes01 = substr(mv_par01,1,2)+"/"+substr(mv_par01,3,4)
nAux = val(substr(cMes01,1,2))+1
cAno = substr(cMes01,4,4)
if nAux > 12
	nAux = nAux - 12
	cAno = str(val(cAno)+1,4)
endif
cMes = alltrim(str(nAux))
if len(cMes) == 1
	cMes = "0"+cMes
endif  
cMes02 = cMes+"/"+cAno

nAux = val(substr(cMes02,1,2))+1
cAno = substr(cMes02,4,4)
if nAux > 12
	nAux = nAux - 12
	cAno = str(val(cAno)+1,4)
endif
cMes = alltrim(str(nAux))
if len(cMes) == 1
	cMes = "0"+cMes
endif  
cMes03 = cMes+"/"+cAno


cEmis01 = substr(mv_par01,3,4)+substr(mv_par01,1,2)
nAux = val(substr(mv_par01,1,2))+2
cAno = substr(mv_par01,3,4)
if nAux > 12
	nAux = nAux - 12
	cAno = str(val(cAno)+1,4)
endif
cMes = alltrim(str(nAux))
if len(cMes) == 1
	cMes = "0"+cMes
endif  
cEmis02 = cAno+cMes
cEmpresa = substr(cnumemp,1,2)
	cQuery = 	"SELECT SC5.C5_VEND1,C5_CLIENTE,MAX(A3_NOME) AS A3_NOME,"
    cQuery +=	"MAX(A1_NOME) AS A1_NOME,MAX(A1_MUN) AS A1_MUN,"
	cQuery +=	"MAX(A1_EST) AS A1_EST,SUM(SC9.C9_PRCVEN*SC9.C9_QTDLIB) AS VALORMES,"
    cQuery +=	"SUBSTRING(C5_EMISSAO,1,6) AS EMISSAO "
	cQuery +=	"FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
	cQuery +=	"ON (C9_FILIAL = C5_FILIAL) AND (C9_PEDIDO = C5_NUM) "
	cQuery +=	"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (C5_VEND1 = A3_COD) "
	cQuery +=	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (C9_CLIENTE = A1_COD) "
	cQuery +=	"WHERE (SC5.D_E_L_E_T_ <> '*') AND"
	cQuery +=	"(SA1.D_E_L_E_T_ <> '*') AND (SA3.D_E_L_E_T_ <> '*') AND (SC9.D_E_L_E_T_ <> '*')  "
	if !empty(MV_PAR02)
	cQuery += "AND (LEN(C9_PRODUTO) = 12) AND "+U_ParamSql("SUBSTRING(C9_PRODUTO,4,2)",MV_PAR02)+" "
	endif
	cQuery +=	" AND(((LEN(SC9.C9_BLCRED) = 0) AND (LEN(SC9.C9_BLEST) = 0)) OR (LEN(SC9.C9_NFISCAL) <> 0)) AND "
	cQuery +=	"(SUBSTRING(SC5.C5_EMISSAO,1,6) BETWEEN '"+cEmis01+"' AND '"+cEmis02+"') "
	cQuery +=	"GROUP BY SC5.C5_VEND1,SC5.C5_CLIENTE,SUBSTRING(C5_EMISSAO,1,6) ORDER BY C5_VEND1,A1_EST,A1_MUN,C5_CLIENTE,EMISSAO "

	TCQuery cQuery NEW ALIAS "TCQ" 
    
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13      14        15          16       17        18        19
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "NOME DO REPRESENTANTE                           RAZAO SOC. CLIENTE                              CIDADE                UF                 "+cMes01+"        "+cMes02+"        "+cMes03+"          MEDIA     SUG. CRED."

cCabec2  := ""
cCabec3  := ""
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
nLin = 07

  dbSelectArea("TCQ")
  dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetRegua(Reccount())
	cRepres = TCQ->C5_VEND1
  While ! EoF()         
  	nSoma = 0
  	if (nLin > 61) .or. (cRepres != TCQ->C5_VEND1)
		if cRepres != TCQ->C5_VEND1
			cRepres = TCQ->C5_VEND1
		endif
  		nLin++
  		@nLin,000 psay replicate("_",220)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 07
	endif
	dbselectarea("TCQ")
   	nLin++
    @nLin,00  psay TCQ->C5_VEND1+"-"+TCQ->A3_NOME
    @nLin,48  psay TCQ->C5_CLIENTE+"-"+TCQ->A1_NOME
    @nLin,96  psay substr(TCQ->A1_MUN,1,20)
    @nLin,118  psay TCQ->A1_EST
  	
	nMes01 = 0
	nMes02 = 0
	nMes03 = 0
	nSoma = 0
	cAuxCli = TCQ->C5_CLIENTE
	while !eof() .and. (cAuxCli == TCQ->C5_CLIENTE)
		do case
			case substr(tcq->emissao,5,2) == substr(cMes01,1,2)
				nMes01 = tcq->valormes
			case substr(tcq->emissao,5,2) == substr(cMes02,1,2)
				nMes02 = tcq->valormes
			case substr(tcq->emissao,5,2) == substr(cMes03,1,2)
				nMes03 = tcq->valormes
		endcase
		nSoma = nSoma + tcq->valormes    
		dbselectarea("TCQ")
		dbskip()
	  	IncRegua()
	enddo 
    @nLin,130 psay nMes01 picture "@E 999,999,999.99"
    @nLin,145 psay nMes02 picture "@E 999,999,999.99"
    @nLin,160 psay nMes03 picture "@E 999,999,999.99"
    @nLin,175 psay nSoma/3 picture "@E 999,999,999.99"
    @nLin,190 psay (nSoma/3)*1.2 picture "@E 999,999,999.99"
	
	dbselectarea("TCQ")
		   	

  End

  nLin++
  @nLin,00 psay replicate("_",220)
  		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TCQ")
dbCloseArea()

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa  : VALIDPERG   Autor:  Cleber
Data      : 09/05/02
Descricao : Grava Perguntas
/*/
/*
Static Function ValidPerg()
 Local aHelp := {}
 Local _sAlias := Alias()
 Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01     // Mes Inicial                             //

 AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Primeiro Mes(MMAAAA)  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
PutSX1(cPerg,"02","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch2","C",99,00,00,"G","","","","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

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
*/
