#IFNDEF WINDOWS
 #DEFINE PSAY SAY
#ENDIF

#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT072     Data....: 09/05/02         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Clientes que não faturam no Período	   //
// Uso.......: Todas as Empresas 						//
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Há quantos dias?		               //
// mv_par02  // Representante de ?						//
// mv_par03  // Representante até ?						//
/////////////////////////////////////////////////////////

User Function BRFAT072()     
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
tamanho  :="M"
limite   :=136
titulo   :="CLIENTES QUE NAO FATURAM"
cDesc1   :=PADC("Este programa ira emitir o Rel. Clientes que Nao Faturam.",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Cliente que Nao Faturam",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT072"
cPerg    :="BRFT72"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT072"
nTipo    := 15
m_pag    := 01     
nTamNf   := 136     // Apenas Informativo
cString  := "SA1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


ValidPerg()
Pergunte(cPerg,.F.)   

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

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

#IFDEF WINDOWS
  RptStatus({|| RptDetail()})
  Return

Static Function RptDetail()
#ENDIF

Local cData,dAux,nCont,cRepres,nAux,cAux,cFilterUser

cData = dtos(date() - mv_par01)


cFilterUser := U_TRATAFILTRO(aReturn[7]) // Chama Func. p/ tratar filtro p/ SQL Server
cQuery = "SELECT A1_VEND,A3_NOME,A1_COD AS CODIGO,A1_NOME AS RAZAO,RTRIM(A1_DDD)+'-'+A1_TEL AS FONE,A1_MUN AS CIDADE,"+;
"A1_EST AS ESTADO,A1_ULTCOM AS ULTIMACOMP FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (A1_VEND = A3_COD) "+;
"WHERE (SA1.D_E_L_E_T_ <> '*') AND (SA3.D_E_L_E_T_ <> '*') AND (A1_ULTCOM < '"+cData+"') AND "+;  
"(LEN(A1_ULTCOM) > 0) AND "
if !empty(cFilterUser)
	cQuery = cQuery + "("+cFilterUser+") AND "
endif
cQuery += "A1_VEND BETWEEN '"+mv_par02+"' AND '"+mv_par03+"' ORDER BY A1_VEND,A1_ULTCOM"

TCQuery cQuery NEW ALIAS "TCQ" 
    
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13      14        15          16       17        18        19
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec2  := "RAZAO SOCIAL DO CLIENTE                           FONE CLIENTE             CIDADE                             ULT. COMPRA  QTDE DIAS"

cCabec1  := "CLIENTES QUE NAO FATURAM HA' MAIS DE "+ALLTRIM(STR(MV_PAR01))+" DIAS"
cCabec3  := ""
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
nLin = 08

dbSelectArea("TCQ")
dbgotop()
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Reccount())   
cRepres = ""
nCont = 0
While ! EoF()         
	nCont++
  	if (nLin > 60)
  		nLin++
  		@nLin,000 psay replicate("_",136)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08
	endif   
   	if a1_vend != cRepres
	  	if (nLin > 58)
	  		nLin++
  			@nLin,000 psay replicate("_",136)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			nLin := 08
		endif   
   		cRepres = a1_vend
   		cAux = alltrim(a1_vend+"-"+a3_nome)
   		nLin++                           
   		nAux = round(68 - (len(cAux)/2),0)
   		@nLin,nAux psay replicate("-",len(cAux))
   		nLin++
   		@nLin,nAux psay a1_vend+"-"+a3_nome
   		nLin++
   		@nLin,nAux psay replicate("-",len(cAux))
   	endif

   	nLin++
    @nLin,00  psay codigo+"-"+razao
    @nLin  ,50  psay fone
    @nLin  ,75  psay alltrim(cidade)+"-"+estado
    @nLin  ,110 psay substr(ultimacomp,7,2)+"/"+substr(ultimacomp,5,2)+"/"+substr(ultimacomp,1,4)
    dAux = CTOD(substr(ultimacomp,7,2)+"/"+substr(ultimacomp,5,2)+"/"+substr(ultimacomp,1,4))
    @nLin  ,125 psay date() - dAux picture "999,999"
  	
	dbselectarea("TCQ")
	dbskip()  
	IncRegua()		   	

End
nLin++
@nLin,00 psay replicate("_",136)
if (nLin > 59)
	nLin++
 	@nLin,000 psay replicate("_",136)
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	nLin := 08
endif
nLin++
@nLin,00 psay "TOTAL DE CLIENTES => "+alltrim(str(nCont))
nLin++
@nLin,00 psay replicate("_",136)
  		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TCQ")
dbCloseArea("TCQ")

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
Data      : 10/05/02
Descricao : Grava Perguntas
/*/

Static Function ValidPerg()
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// mv_par01     // Mes Inicial                             //


// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Ha'quantos dias  ?","","","mv_ch1","N",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Repres. De  ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"03","Repres Ate ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})

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