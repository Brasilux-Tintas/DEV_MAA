#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT034 ºAutor  ³ Cleber O. Dominguesº Data ³  24/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Inscricao Estadual                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT034()
LOCAL i,nCont,nSoma,_cInscr,lDigInv,cDig,nResto,nPrimDig,nSegDig,p,d,cAux
LOCAL c3PrimDig,_cInscrComp,c34Dig,_cAlias,_cEst, _cInscr_Est
LOCAL aPesos:=ARRAY(8)
Local j                                                        
PRIVATE lRet:=.f.

_cAlias:=alias()

if 	_cAlias == 'SA1'			// Clientes
   	_cEst  :=M->A1_EST
   	_cInscr:=alltrim(M->A1_INSCR)
elseif _cAlias == 'SA2'			// Fornecedores
	_cEst  :=M->A2_EST
   	_cInscr:=alltrim(M->A2_INSCR)
elseif _cAlias == 'SA3'			// Vendedores
	_cEst  :=M->A3_EST
   	_cInscr:=alltrim(M->A3_INSCR)
elseif _cAlias == 'SA4'			// Transportadora
	_cEst  :=M->A4_EST
   	_cInscr:=alltrim(M->A4_INSEST)
endif
    

// Nao possui Inscricao Estadual
if upper(alltrim(_cInscr))=='ISENTO'
   return(.t.)
endif                                   


// Verificar IE p/ Acre
If _cEst == 'AC'

	lRet := .t.
	_cInscr_est:=_cInscr

	if (len(alltrim(_cInscr)) != 13) .or. (substr(_cInscr,1,2) != "01")
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,11)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 11 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			nSoma := 0
			nCont := 2
			for i := 12 to 1 step -1
				cDig  := substr(_cInscr,i,1)
				nSoma := nSoma+nCont*val(cDig)
				nCont := nCont+1
				if nCont == 10
					nCont := 2
				endif
			Next
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nSegDig := 0
			else
				nSegDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nSegDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

elseif _cEst = 'SE'
	lRet := .t.
	_cInscr_est:=alltrim(_cInscr)

	if len(alltrim(_cInscr)) != 9
		lRet := .f.
	else
		_cInscr := substr(_cInscr,2,8)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 8 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			if (substr(_cInscr_Est,1,1)+_cInscr) != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
    endif
		
	
// Verificar IE p/ Alagoas, Amazonas, Ceara, Espirito Santo,
// Maranhao, Mato Grosso do Sul, Para, Paraiba, 
// Piaui, Santa Catarina
elseif _cEst == 'AL' .or. _cEst == 'AM' .or. _cEst == 'CE' .or. _cEst == 'ES' .or. ;
	   _cEst == 'MA' .or. _cEst == 'MS' .or. _cEst == 'PA' .or. _cEst == 'PB' .or. ;
	   _cEst == 'PI' .or. _cEst == 'SC'

	lRet := .t.
	_cInscr_est:=_cInscr

	if len(alltrim(_cInscr)) != 9
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,8)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 8 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
    endif

    if _cEst == 'MS'
		if lRet .and. (substr(_cInscr_Est,1,2) != "28")
			lRet := .f.
		endif           
	endif

	if _cEst == 'PA'
		if lRet .and. (substr(_cInscr_Est,1,2) != "15")
			lRet := .f.
		endif
	endif

// Verificar IE p/ Amapa
elseif _cEst == 'AP'

	lRet := .t.
	_cInscr_Est := alltrim(_cInscr)
	if len(alltrim(_cInscr)) != 9
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,8)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 8 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			do case
				case (_cInscr >= "03000001") .and. (_cInscr <= "03017000")
					p := 5
					d := 0
				case (_cInscr >= "03017001") .and. (_cInscr <= "03019022")
					p := 9
					d := 1
				case (_cInscr >= "03019023")
					p := 0
					d := 0
				otherwise
					lDigInv := .t.
			endcase
			if lDigInv
				lRet := .f.
			else
				nResto := mod(nSoma+p,11)
				do case
					case nResto == 1
						nPrimDig := 0
					case nResto == 0
						nPrimDig := d
					otherwise
						nPrimDig := 11 - nResto
				endcase
				_cInscr := _cInscr+str(nPrimDig,1)
				if _cInscr != alltrim(_cInscr_Est)
					lRet := .f.
				endif
			endif
		endif	
	endif

// Verificar IE p/ Bahia
elseif _cEst == 'BA'

	lRet = .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) < 8
		lRet := .f.
	else
		lDigInv := .f.
		for i := 1 to len(alltrim(_cInscr))
			if !isdigit(substr(_cInscr,i,1))
				lDigInv := .t.
				exit
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			_cInscr := substr(_cInscr,1,6)
			if substr(_cInscr,1,1) $ "0_1_2_3_4_5_8"
				nCont := 2
				nSoma := 0
				for i := 6 to 1 step -1
					cDig := substr(_cInscr,i,1)
					nSoma := nSoma+nCont*val(cDig)
					nCont := nCont+1
					if nCont == 10
						nCont := 2
					endif
				Next
				nResto := mod(nSoma,10)
				if (nResto == 0)
					nSegDig := 0
				else
					nSegDig := 10 - nResto
				endif
				_cInscr := _cInscr+str(nSegDig,1)
	
				nCont := 2
				nSoma := 0
				for i := 7 to 1 step -1
					cDig  := substr(_cInscr,i,1)
					nSoma := nSoma+nCont*val(cDig)
					nCont := nCont+1
					if nCont == 10
						nCont := 2
					endif
				Next
				nResto := mod(nSoma,10)
				if (nResto == 0)
					nPrimDig := 0
				else
					nPrimDig := 10 - nResto
				endif
				_cInscr := substr(_cInscr,1,6)+str(nPrimDig,1)+str(nSegDig,1)
	
				if _cInscr != alltrim(_cInscr_Est)
					lRet := .f.
				endif
			else
				nCont := 2
				nSoma := 0
				for i := 6 to 1 step -1
					cDig  := substr(_cInscr,i,1)
					nSoma := nSoma+nCont*val(cDig)
					nCont := nCont+1
					if nCont == 10
						nCont := 2
					endif
				Next
				nResto := mod(nSoma,11)
				if (nResto == 0) .or. (nResto == 1)
					nSegDig := 0
				else
					nSegDig := 11 - nResto
				endif
				_cInscr := _cInscr+str(nSegDig,1)

				nCont := 2
				nSoma := 0
				for i := 7 to 1 step -1
					cDig  := substr(_cInscr,i,1)
					nSoma := nSoma+nCont*val(cDig)
					nCont := nCont+1
					if nCont == 10
						nCont := 2
					endif
				Next
				nResto := mod(nSoma,11)
				if (nResto == 0) .or. (nResto == 1)
					nPrimDig := 0
				else
					nPrimDig := 11 - nResto
				endif
				_cInscr := substr(_cInscr,1,6)+str(nPrimDig,1)+str(nSegDig,1)
	
				if _cInscr != alltrim(_cInscr_Est)
					lRet := .f.
				endif
			endif
		endif
	endif

// Verificar IE p/ Distrito Federal
elseif _cEst ==  'DF'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) != 13
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,11)
		nCont   := 2
		nSoma   := 0
		lDigInv := .f.
		for i := 11 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			nSoma := 0
			nCont := 2
			for i := 12 to 1 step -1
				cDig  := substr(_cInscr,i,1)
				nSoma := nSoma+nCont*val(cDig)
				nCont := nCont+1
				if nCont == 10
					nCont := 2
				endif
			Next
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nSegDig := 0
			else
				nSegDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nSegDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

//Verificar IE p/ GO
elseif _cEst == 'GO'

	lRet := .t.
	_cInscr_Est := _cInscr
	if (len(alltrim(_cInscr)) != 9) .or. !(substr(_cInscr,1,2) $ "10_11_15")
		lRet := .f.
	else
		if (_cInscr != "110944020") .or. (_cInscr != "110944021")
			_cInscr := substr(_cInscr,1,8)
			nCont := 2
			nSoma := 0
			lDigInv := .f.
			for i := 8 to 1 step -1
				cDig := substr(_cInscr,i,1)
				if !isdigit(cDig)
					lDigInv := .t.
					exit
				endif
				nSoma := nSoma+nCont*val(cDig)
				nCont := nCont+1
				if nCont == 10
					nCont := 2
				endif
			Next
			if lDigInv 
				lRet := .f.
			else
				nResto := mod(nSoma,11)
				do case
					case (nResto == 0)
						nPrimDig := 0
					case (nResto == 1)
						if (_cInscr >= "10103105") .and. (_cInscr <= "10119997")
							nPrimDig := 1
						else
							nPrimDig := 0
						endif
					otherwise
						nPrimDig := 11 - nResto
				endcase
				_cInscr := _cInscr+str(nPrimDig,1)
				if _cInscr != alltrim(_cInscr_Est)
					lRet := .f.
				endif
			endif
		endif
	endif

// Verificar IE p/ Minas Gerais
elseif _cEst == 'MG'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) != 13
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,11)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 11 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			cAux := alltrim(str(nCont*val(cDig)))
			for j := 1 to len(cAux)
				nSoma := nSoma+val(substr(cAux,j,1))
			Next
			nCont := nCont+1
			if nCont == 3
				nCont := 1
			endif
			if i == 4
				nCont := 1
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nPrimDig := 10 - ((nSoma/10) - int(nSoma/10))*10
			if nPrimDig == 10
				nPrimDig := 0
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			nSoma := 0
			nCont := 2
			for i := 12 to 1 step -1
				cDig  := substr(_cInscr,i,1)
				nSoma := nSoma+nCont*val(cDig)
				nCont := nCont+1
				if nCont == 12
					nCont := 2
				endif
			Next
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nSegDig := 0
			else
				nSegDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nSegDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

//Verificar IE p/ Mato Grosso
elseif _cEst == 'MT'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) < 9
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,08)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 08 to 1 step -1                                        
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif
// Verificar IE p/ Pernambuco
elseif _cEst == 'PE'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) # 9
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,7)
		nSoma := 0   
		nCont = 8
		for i := 1 to 7
			nSoma += val(substr(_cInscr,i,1))*nCont
			nCont = nCont - 1
		next 
		nResto := mod(nSoma,11)
		if (nResto == 1) .or. (nResto == 0)
			nPrimDig := 0
		else
			nPrimDig := 11 - nResto
		endif
		_cInscr := _cInscr+str(nPrimDig,1)

		nSoma := 0   
		nCont = 9
		for i := 1 to 8
			nSoma += val(substr(_cInscr,i,1))*nCont
			nCont = nCont - 1
		next 
		nResto := mod(nSoma,11)
		if (nResto == 1) .or. (nResto == 0)
			nPrimDig := 0
		else
			nPrimDig := 11 - nResto
		endif
		_cInscr := _cInscr+str(nPrimDig,1)

		if _cInscr != alltrim(_cInscr_Est)
			lRet := .f.
		endif
	endif

// Verificar IE p/ Parana
elseif _cEst == 'PR'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) < 10
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,8)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 8 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 8
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			nCont := 2
			nSoma := 0
			for i := 9 to 1 step -1
				cDig  := substr(_cInscr,i,1)
				nSoma := nSoma+nCont*val(cDig)
				nCont := nCont+1
				if nCont == 8
					nCont := 2
				endif
			Next
			nResto = mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nSegDig := 0
			else
				nSegDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nSegDig,1)
	
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

// Verificar IE p/ Rio de Janeiro
elseif _cEst == 'RJ'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) < 8
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,7)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 7 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 8
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

// Verificar IE p/ Rio Grande do Norte
elseif _cEst == 'RN'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) < 9
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,8)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 8 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma*10,11)
			if (nResto > 9)
				nPrimDig := 0
			else
				nPrimDig := nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

// Verificar IE p/ Rondonia
elseif _cEst == 'RO'
	lRet := .t.
	_cInscr_Est := _cInscr
	if (len(alltrim(_cInscr)) < 14)
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,13)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 13 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont > 9
			   nCont:=2
			endif
		Next                       
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)   
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 1 - nResto
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

// Verificar IE p/ Roraima
elseif _cEst == 'RR'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) < 9
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,8)
		nSoma := 0
		lDigInv := .f.
		for i := 1 to 8
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+i*val(cDig)
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,9)
			nPrimDig := nResto
			_cInscr := _cInscr+str(nPrimDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

// Verificar IE p/ Rio Grande do Sul
elseif _cEst == 'RS'

	lRet := .t.
	_cInscr_Est := _cInscr
	if len(alltrim(_cInscr)) < 10
		lRet := .f.
	else
		_cInscr := substr(_cInscr,1,9)
		nCont := 2
		nSoma := 0
		lDigInv := .f.
		for i := 9 to 1 step -1
			cDig := substr(_cInscr,i,1)
			if !isdigit(cDig)
				lDigInv := .t.
				exit
			endif
			nSoma := nSoma+nCont*val(cDig)
			nCont := nCont+1
			if nCont == 10
				nCont := 2
			endif
		Next
		if lDigInv 
			lRet := .f.
		else
			nResto := mod(nSoma,11)
			if (nResto == 1) .or. (nResto == 0)
				nPrimDig := 0
			else
				nPrimDig := 11 - nResto
			endif
			_cInscr := _cInscr+str(nPrimDig,1)
			if _cInscr != alltrim(_cInscr_Est)
				lRet := .f.
			endif
		endif
	endif

// Verificar IE p/ Sao Paulo
elseif _cEst == 'SP'

	lRet := .t.
	aPesos[1] := 1
	aPesos[2] := 3
	aPesos[3] := 4
	aPesos[4] := 5
	aPesos[5] := 6
	aPesos[6] := 7
	aPesos[7] := 8
	aPesos[8] := 10

	_cInscr_Est := _cInscr
	if (len(alltrim(_cInscr)) < 12) .or. ((len(alltrim(_cInscr)) == 13) .and. (substr(_cInscr,1,1) != "P"))
		lRet := .f.
	else
		if len(alltrim(_cInscr)) == 12
			nSoma := 0
			lDigInv := .f.
			for i := 1 to 8
				cDig := substr(_cInscr,i,1)
				if !isdigit(cDig)
					lDigInv := .t.
					exit
				endif
				nSoma := nSoma+aPesos[i]*val(cDig)
			Next
			if lDigInv
				lRet := .f.
			else
				nResto := mod(nSoma,11)
				nPrimDig := ((nResto/10) - int(nResto/10))*10
				_cInscrComp := substr(_cInscr,1,8)+str(nPrimDig,1)
				if _cInscrComp != substr(_cInscr,1,9)
					lRet := .f.
				else
					_cInscr := substr(_cInscr,1,11)
					nCont := 2
					nSoma := 0
					lDigInv := .f.
					for i := 11 to 1 step -1
						cDig := substr(_cInscr,i,1)
						if !isdigit(cDig)
							lDigInv := .t.
							exit
						endif
						nSoma := nSoma+nCont*val(cDig)
						nCont := nCont+1
						if nCont == 11
							nCont := 2
						endif
					Next
					if lDigInv
						lRet := .f.
					else
						nResto := mod(nSoma,11)
						nSegDig := ((nResto/10) - int(nResto/10))*10
						_cInscr := _cInscr+str(nSegDig,1)
						if _cInscr != alltrim(_cInscr_Est)
							lRet := .f.
						endif
					endif
	
				endif
			endif
		else // Se não for 12 o tam e sim 13

			nSoma := 0
			lDigInv := .f.
			for i := 2 to 9
				cDig := substr(_cInscr,i,1)
				if !isdigit(cDig)
					lDigInv := .t.
					exit
				endif
				nSoma := nSoma+aPesos[i-1]*val(cDig)
			Next
			if lDigInv
				lRet := .f.
			else
				nResto := mod(nSoma,11)
				nPrimDig := ((nResto/10) - int(nResto/10))*10
				_cInscrComp := "P"+substr(_cInscr,2,8)+str(nPrimDig,1)+substr(_cInscr,11,3)
				if _cInscrComp != substr(_cInscr,1,9)
					lRet := .f.
				else
					lDigInv := .f.
					for i := 11 to 13
						cDig := substr(_cInscr,i,1)
						if !isdigit(cDig)
							lDigInv := .t.
							exit
						endif
					Next
					if lDigInv
						lRet := .f.
					endif
				endif
			endif
		endif
	endif

// Verificar IE p/ Tocantis
elseif _cEst == 'TO'
       lRet        := .t.
       _cInscr_Est := _cInscr
       c34Dig      := ""
       If (Len(Alltrim(_cInscr)) # 11) .and. (Len(Alltrim(_cInscr)) # 9)
          lRet := .f.
       Endif
       If lRet
          If Len(Alltrim(_cInscr)) == 11
             c34Dig := SubStr(_cInscr, 3, 2) //Iif((Len(Alltrim(_cInscr)) == 11), SubStr(_cInscr, 3, 2), "")
             If !(c34Dig $ "01_02_03_99")
                lRet := .f.
             Endif
          Else
             lRet := .t.
          Endif
       Endif
       If lRet
          cAux := _cInscr
          If (Len(Alltrim(_cInscr)) == 11)
             _cInscr := SubStr(cAux, 1, 2)+SubStr(cAux, 5, 6)
          Endif 
          nCont  := 2
          nSoma  := 0
          lDigInv:= .f.
          For i := 8 to 1 step -1
              cDig := SubStr(_cInscr, i, 1)
              If !IsDigit(cDig)
                 lDigInv := .t.
                 Exit
              Endif
              nSoma := nSoma + nCont*Val(cDig)
              nCont := nCont+1
              If nCont == 10
                 nCont := 2
              Endif
          Next
          If lDigInv 
             lRet := .f.
          Else
             nResto := Mod(nSoma, 11)
             If (nResto == 1) .or. (nResto == 0)
                nPrimDig := 0
             Else
                nPrimDig := 11 - nResto
             Endif
             cAux := _cInscr
             If Len(Alltrim(_cInscr)) == 11
                _cInscr := SubStr(cAux, 1, 2)+c34Dig+SubStr(cAux, 3, 6)+Str(nPrimDig, 1)
             Else
                _cInscr := SubStr(cAux, 1, 8)+Str(nPrimDig, 1)
             Endif
             If _cInscr != Alltrim(_cInscr_Est)
                lRet := .f.
             Endif
          Endif
       Endif
Endif
If !lRet
   MsgStop("Inscricao Estadual inválida")
Endif

Return(lRet)