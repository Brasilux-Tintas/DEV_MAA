#INCLUDE "rwmake.ch"
#INCLUDE "avprint.ch"
#INCLUDE "TOPCONN.CH"
          
/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT070     Data....: 02/05/02         //
// Autor.....: Cleber Orati Domingues				  //
// Descriçao.: Etiquetas Repr.                     //
// Uso.......: Todas as Empresas                         //
//                                                     //
///////////////////////////////////////////////////////// 
//                                                     //
// mv_par01 - Repr  De:      - Caracter             //
// mv_par02 - Repr Até:     - Caracter              //
//                                                     //
/////////////////////////////////////////////////////////

User Function BRFAT070()
Local cQry    := ''
Local aEtqExp := {}
Local cEmpresa,_cFilial

SetPrvt("CPERG","mv_par01","mv_par02")

if !u_VldAcesso(funname())
    MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	return 
endif 
     u_zcfga01( 'BRFAT070' ) //LGS#2021201 - Gravação de log de utilização da rotina
cPerg := "BRFT70"
ValidPerg()                     
Pergunte(cPerg,.T.)

oPrn:= TMSPrinter():New( "Etiquetas Representantes" )
oPrn:SetPortrait()      // ou SetLandscape()

AVPRINT oPrn NAME "Etiquetas Representantes"

oFont1  := TFont():New("Arial"      ,9,10,.F.,.F.,5,.T.,5,.T.,.F.)
oFont4  := TFont():New("Arial"      ,9,12,.F.,.T.,5,.F.,5,.T.,.F.) 
oFont2  := TFont():New("Arial Black",9,12,.F.,.F.,5,.T.,5,.T.,.F.)
oFont3  := TFont():New("Arial Black",9,14,.F.,.F.,5,.T.,5,.T.,.F.)

AVPAGE

nLin    := 120
nCol    := 40      
nContEtq := 0
auxCont :=0                   

// mv_par01 - Repr  De:      - Caracter             //
// mv_par02 - Repr Até:     - Caracter              //


DbSelectArea("SA3")
dbsetorder(1)
_cFilial := xFilial("SA3")
dbseek(_cFilial+mv_par01)                                        	
While !EOF() .and. (A3_FILIAL = _cFilial) .and. (SA3->A3_COD >= mv_par01) .and. (SA3->A3_COD <= mv_par02)
	if SA3->A3_ATIVO <> 'S'
		dbselectarea("SA3")
		dbskip()
		loop
	endif	
	nLinIni = nLin	

    oPrn:Say (nLin,nCol,SUBSTR(SA3->A3_NOME,0,30),oFont1)
    nLin+=30
    oPrn:Say (nLin,nCol,SUBSTR(SA3->A3_END,0,30),oFont1)
    nLin+=30
    oPrn:Say (nLin,nCol,SA3->A3_BAIRRO,oFont1)
    nLin+=30
    oPrn:Say (nLin,nCol,ALLTRIM(SA3->A3_MUN)+"-"+SA3->A3_EST,oFont1)
    nLin+=30
    oPrn:Say (nLin,nCol,SUBSTR(SA3->A3_CEP,1,5)+"-"+SUBSTR(SA3->A3_CEP,6,3),oFont1)
    
	nContEtq++	
	DO CASE
		case nCol == 40
			nCol := 880
			nLin = nLinIni
		case nCol == 880
			nCol += 840
			nLin = nLinIni
		case nCol == 1720
			nCol := 40
			nLin += 190-auxCont //190-auxCont
			auxCont +=2
	endcase
			   
	If nContEtq == 30
      AVNEWPAGE	       
      nLin     := 120
      nCol     := 40   
      nContEtq := 0
      auxCont := 0
    Endif   
	dbselectarea("SA3")
	dbskip()    	
enddo

AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

MS_FLUSH() 

Return  


/*/
Programa  : VALIDPERG   Autor:  Marcos Cesar     
Data      : 28/01/02
Descricao : Grava Perguntas
/*/

Static Function ValidPerg()
Local _sAlias := Alias()
Local i, j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Repres. De  ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{cPerg,"02","Repres Ate ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})

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
