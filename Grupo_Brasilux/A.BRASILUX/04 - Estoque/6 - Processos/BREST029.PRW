#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

/*
/////////////////////////////////////////////////////////
// Funçào....: BREST029     Data....: 20/04/2006         //
// Autor.....: Cleber Orati Domingues                   //
// Descriçào.: Agualizar campo B5_PRV3 c/ preços em Dólar //
// Uso.......: Qquer empresa/Filial                      //
// Variaveis utilizadas para parametros        
// mv_par01             // Vlr Dólar ?   		
*/  


User Function BREST029()  

private cPERG,mv_par01
     u_zcfga01( 'BREST029' ) //LGS#2021118 - Gravação de log de utilização da rotina
cPerg   := "BRES29"
                      
VldPerg()            // Verifica as perguntas selecionadas 
Pergunte(cPerg,.F.)  // Pergunta no SX1
@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Atualizar tabela de Preços em Dólar"

@ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 91,168 BMPBUTTON TYPE 1 ACTION Processa({|lEnd| BRES29_1()})
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
@ 23,16 SAY "Atualização dos Preços de Produtos para os   "
@ 33,16 SAY "valores em Dólar  "
@ 8,10 TO 84,222
ACTIVATE DIALOG oDlg1
Return


static Function BRES29_1()
local cJuros,cDolar,cPisCofins
if mv_par01 <= 0
	MsgStop("Valor do Dólar Inválido!")	
else     
	cDolar = strtran(alltrim(str((mv_par01),12,5)),",",".")
	cJuros = strtran(alltrim(str(1+(getmv("MV_JUROS")/100),12,5)),",",".") 
	cPisCofins = strtran(alltrim(str(GETMV("MV_TXPIS") + GETMV("MV_TXCOFIN"),12,5)),",",".")
	cQuery = "UPDATE "+RetSqlName("SB5")+" SET B5_PRV3 = (B1_CUSTOR/((1/(POWER("+cJuros+",(720.00000/365.00000))) - (Z1_LUCROUS/100) - "+;
	"((B1_PERINT - "+cPisCofins+")/100))))/"+cDolar+;
	" FROM "+RetSqlName("SB5")+" SB5 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (B5_FILIAL = B1_FILIAL) AND (B5_COD = B1_COD) AND (SB1.D_E_L_E_T_ <> '*') "+;
	"LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (Z1_FILIAL = '"+xFilial("SZ1")+"') AND (SUBSTRING(B5_COD,4,2) = Z1_LINHA) AND (SZ1.D_E_L_E_T_ <> '*') "+;
	"WHERE (B5_FILIAL = '"+xFilial("SB5")+"') AND (LEN(B5_COD) = 12) AND (SB5.D_E_L_E_T_ <> '*') AND (B1_COD IS NOT NULL)"
	TCSQLEXEC(cQuery)
    
	
/*	cAux = "SELECT B5_COD FROM "+RetSqlName("SB5")+" WHERE (B5_FILIAL = '"+xFilial("SB5")+"') AND (LEN(B5_COD) = 12) AND (D_E_L_E_T_ <> '*')"
	cQuery = "UPDATE "+RetSqlName("ZZ6")+" SET ZZ6_PROCES = 'N' WHERE (ZZ6_TABELA = 'SB1') AND (ZZ6_PROCES = 'S') AND "+;
	"(D_E_L_E_T_ <> '*') AND (ZZ6_EMPR = '"+xFilial("SB1")+"') AND (ZZ6_CHAVE IN ("+cAux+"))"
	TCSQLEXEC(cQuery)
*/
	Alert("Processo Finalizado!" + CHR(13)+CHR(10))
			
endif 

                     
//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//
// Funcao...: VldPerg                                             //
// Descricao: Verifica as perguntas, incluindo-as caso nao existam//       
// Uso......: BRFIS003                                            // 
//==//==//==//==//==//==//==//==//==//==//==/==//==//==//==/==//==//

Static Function VldPerg()  
Local i, j
Local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}
      
//+---------------------------------------------+                                                                            
//¦ Variaveis utilizadas para parametros        ¦
//¦ dPer1             // Da Data de Emissao  ¦
//¦ dPer2             // Reprocessamento(S/N)¦                          
//+---------------------------------------------+                          
cPerg := PADR(cPerg,10)
aAdd(aRegs,{cPerg,"01","Valor do Dólar       ?","","","mv_ch1","N",08,3,0,"G","NaoVazio","mv_par01",""	  ,""   ,""	  ,"","",""	  ,""   ,""	  ,"","","","","","","","","","","","","","","","","",""})

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

