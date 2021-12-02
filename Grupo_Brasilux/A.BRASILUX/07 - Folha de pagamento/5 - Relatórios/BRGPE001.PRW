#INCLUDE "rwmake.ch"
#INCLUDE "avprint.ch"
#INCLUDE "TOPCONN.CH"
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRGPE001 º Autor ³ Luís Gustavo       º Data ³  08/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão de etiquetas de funcionários.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRGPE001()
     Local   cQry    := ''
     //Local   aEtqExp := {}
     //Local   cEmpresa
     //Local   _cFilial, nY
     Local nI, oPrn

     Private cPerg
     u_zcfga01( 'BRGPE001' ) //LGS#2021202 - Gravação de log de utilização da rotina
     cPerg := "BRGP01"
     ValidPerg()                     
     Pergunte(cPerg,.T.)

     oPrn:= TMSPrinter():New( "Etiquetas de Clientes" )
     oPrn:SetPortrait()      // ou SetLandscape()

     AVPRINT oPrn NAME "Etiquetas Clientes"

             oFont1  := TFont():New("Arial"      ,9,10,.F.,.F.,5,.T.,5,.T.,.F.)
             oFont4  := TFont():New("Arial"      ,9,12,.F.,.T.,5,.F.,5,.T.,.F.) 
             oFont2  := TFont():New("Arial Black",9,12,.F.,.F.,5,.T.,5,.T.,.F.)
             oFont3  := TFont():New("Arial Black",9,14,.F.,.F.,5,.T.,5,.T.,.F.)
     AVPAGE

     nLin    := 50
     nCol    := 060      
     nContEtq := 0
     
     cQry := ""     
     cQry += "SELECT * "
     cQry += "FROM "+RetSqlName("SRA")+" SRA "
     cQry += "WHERE SRA.D_E_L_E_T_ = '' "
     cQry += "  AND SRA.RA_FILIAL = '"+xFilial("SRA")+"' "
     cQry += "  AND SRA.RA_MAT BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
     If !Empty(mv_par03)
        For nI := 1 to Len(mv_par03)
            If nI == 1
               cAux := "  AND SRA.RA_SITFOLH IN('"+SubStr(mv_par03, nI, 1)
            Else
               If !SubStr(mv_par03, nI, 1) == '*'
                  cAux += "','"+SubStr(mv_par03, nI, 1)
               Endif
            Endif
        Next
        cQry += cAux + "') "
     Endif
     If !Empty(mv_par04)
        For nI := 1 to Len(mv_par04)
            If nI == 1
               cAux := "  AND SRA.RA_CATFUNC IN('"+SubStr(mv_par04, nI, 1)
            Else
               If !SubStr(mv_par04, nI, 1) == '*'
                  cAux += "','"+SubStr(mv_par04, nI, 1)
               Endif
            Endif
        Next
        cQry += cAux + "') "
     Endif
     If mv_par05 == 1
        cQry += "ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "
     Else
        cQry += "ORDER BY SRA.RA_FILIAL, SRA.RA_NOME "
     Endif
     TCQuery cQry New Alias "TCQ"


     DbSelectArea("TCQ")
     While !EOF()
           nLinIni = nLin	

           oPrn:Say (nLin, nCol, SUBSTR(TCQ->RA_NOME,1,34),oFont1)
           nLin += 30
           oPrn:Say (nLin, nCol, TCQ->RA_ENDERECO,oFont1)
           nLin += 30
           oPrn:Say (nLin, nCol, Iif(!Empty(TCQ->RA_COMPLEME), TCQ->RA_COMPLEME+' ', '') + TCQ->RA_BAIRRO,oFont1)
           nLin += 30
           oPrn:Say (nLin, nCol, ALLTRIM(TCQ->RA_MUNICIP)+"-"+TCQ->RA_ESTADO+'  '+Left(SRA->RA_CEP,5)+'-'+Right(SRA->RA_CEP,3), oFont1)
           nLin += 30
           oPrn:Say (nLin, nCol, TCQ->RA_FILIAL+"-"+TCQ->RA_MAT+'-'+TCQ->RA_CC, oFont1)
    
           nContEtq++	
           Do Case
              Case nCol == 60
                   nCol = 840
                   nLin = nLinIni
              Case nCol == 840
                   nCol = 1680
                   nLin = nLinIni
              Case nCol == 1680
                   nCol = 60
                   nLin += 155
           Endcase
			   
          If ncontEtq == 36
             AVNEWPAGE	       
             nLin     := 050
             nCol     := 060   
             nContEtq := 0
          Endif   
          Dbselectarea("TCQ")
          Dbskip()    	
     Enddo

     AVENDPAGE
     AVENDPRINT
     oFont1:End()
     oFont2:End()
     oFont3:End()
     oFont4:End()

     MS_FLUSH() 
     DbSelectArea("TCQ")
     DbCloseArea()
Return

/****************************************************************/
/*** VALPERG - Valida perguntas SX1                           ***/
/****************************************************************/
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aadd(aRegs, {cPerg, '01', 'Do Funcionario ?      ', ' ', ' ', 'mv_ch1', 'C',  6, 0, 0, 'G', '          ', 'mv_par01', '         ', ' ', ' ', ' ', ' ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SRA', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '02', 'Ate o Funcionario ?   ', ' ', ' ', 'mv_ch2', 'C',  6, 0, 0, 'G', '          ', 'mv_par02', '         ', ' ', ' ', ' ', ' ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SRA', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '03', 'Situacao ?            ', ' ', ' ', 'mv_ch3', 'C',  5, 0, 0, 'G', 'fSituacao ', 'mv_par03', '         ', ' ', ' ', ' ', ' ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '   ', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '04', 'Categoria ?           ', ' ', ' ', 'mv_ch4', 'C', 15, 0, 0, 'G', 'fCategoria', 'mv_par04', '         ', ' ', ' ', ' ', ' ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '   ', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '05', 'Ordem de impressão ?  ', ' ', ' ', 'mv_ch5', 'N',  1, 0, 1, 'C', 'naovazio  ', 'mv_par05', 'Matricula', ' ', ' ', ' ', ' ', 'Nome', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '   ', 'S', ' ', ' ' } )
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
