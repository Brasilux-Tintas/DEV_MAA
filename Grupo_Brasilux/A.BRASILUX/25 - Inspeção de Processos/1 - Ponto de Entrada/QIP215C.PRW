#Include "Protheus.ch"

/*/
{Protheus.doc} QIP215C
description Chama o Programa BRQIPR050 - Certificado de Qualidade 
@type function
@version  V.1
@author joseuliana
@since 09/02/2023
@return variant, return_description
/*/
User Function QIP215C()
Local nOP

nOP := QPK->QPK_OP

U_BRQIPR050(nOP)

return()
