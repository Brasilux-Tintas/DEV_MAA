/*
Copyright 2015 AppSoft - Fabrica de Software

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#Include "Totvs.ch"                 
#Include "AppExcel.ch"
                 

/*/{Protheus.doc} AppExcCellFormat
Classe responsável por gerenciar os formatos da célula 
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0
@type class
/*/
//CLASS AppExcCellFormat FROM LongClassName  //LGS#20200131 - Adequação ao release 12.1.25 e posteriores
CLASS AppExcCellFormat FROM LongNameClass
	DATA nFormat AS INTEGER

	//Class Properties
	DATA cClassName AS STRING HIDDEN         
                                                
	METHOD New( nTypeFormat ) CONSTRUCTOR
	METHOD HasFormat()
	METHOD SetFormat( nTypeFormat )      
	METHOD GetFormat( )      
	METHOD FormatToString()         
	
	//Class Properties
	METHOD Destroy()  
	METHOD ClassName()

ENDCLASS                  
  
/*/{Protheus.doc} AppExcCellFormat:New
Método construtor da classe AppExcCellFormat
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type constructor
@param nFormat, inteiro, código do formato a ser utilizado, os formatos suportados são:|ul||li|NUMBER_CURRENCY_REAL		-> Numero formato moeda em R$|/li||li|NUMBER_CURRENCY_RED_REAL    -> Numero formato moeda em R$, negativos em vermelho|/li||/ul|
/*/
METHOD New( nTypeFormat ) CLASS AppExcCellFormat
	DEFAULT nTypeFormat := 0             
	
	::cClassName := "AppExcCellFormat"

	::nFormat	:= nTypeFormat 

RETURN     
  
   

/*/{Protheus.doc} AppExcCellFormat:HasFormat
Método para indicar se algum formato foi especificado
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@type method
@version 1.0                        
@return logico indica se algum formato foi especificado
/*/
METHOD HasFormat() CLASS AppExcCellFormat
RETURN ::nFormat > 0
  
                                                         
/*/{Protheus.doc} AppExcCellFormat:SetFormat
Método para alterar o formato
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@param nFormat, inteiro, código do formato a ser utilizado, os formatos suportados são:|ul||li|NUMBER_CURRENCY_REAL		-> Numero formato moeda em R$|/li||li|NUMBER_CURRENCY_RED_REAL    -> Numero formato moeda em R$, negativos em vermelho|/li||/ul|
/*/
METHOD SetFormat( nTypeFormat ) CLASS AppExcCellFormat
	::nFormat := nTypeFormat
RETURN
  
   

/*/{Protheus.doc} AppExcCellFormat:GetFormat
Método de acesso para obter o formato da célula
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@return inteiro, retorna o identificador da formatação
/*/
METHOD GetFormat( ) CLASS AppExcCellFormat
RETURN ::nFormat
                                                       
  
  
/*/{Protheus.doc} AppExcCellFormat:FormatToString
Serialização da formatação da célula para o padrão XML Excel
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0     
@type method
@param nRow, inteiro, número da linha que será serializada
@return caractere, String contendo a formatação da célula especificada no padrão XML
/*/
METHOD FormatToString( ) CLASS AppExcCellFormat
	Local cStringFormat := ""       

	If ::HasFormat()
		cStringFormat := GetStringFormat( ::nFormat )                    
	EndIf

RETURN cStringFormat             

       
/*/{Protheus.doc} AppExcCellFormat:ClassName
Método responsável por retornar o nome da classe
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@type method
@version 1.0     
@return caractere, retorna o nome da classe
/*/
METHOD ClassName() CLASS AppExcCellFormat
RETURN ::cClassName

  
/*/{Protheus.doc} AppExcCellFormat:Destroy
Método destrutor do objeto, responsável pela desalocação da memória
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0     
@type method
/*/
METHOD Destroy() CLASS AppExcCellFormat  
	FreeObj(::self)
RETURN 

 
/*/ GetStringFormat
Função estática para conversão do identificador da formatação com a string utilizada pelo XML Excel
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014                                                                                  
@version 1.0                                                                                       
@type function
@param, inteiro, identificador da formação
@return, caractere, string utilizada pelo XML Excel
/*/
Static Function GetStringFormat( nFormat )       
	Local cFormat := ""
	                          
	Do Case
		Case nFormat == NUMBER_CURRENCY_REAL
	   		cFormat := '<NumberFormat ss:Format="&quot;R$&quot;\ #,##0.00"/>'
	   	Case nFormat == NUMBER_CURRENCY_RED_REAL   
	   		cFormat := '<NumberFormat ss:Format="&quot;R$&quot;\ #,##0.00;[Red]&quot;R$&quot;\ #,##0.00"/>'
	   	Case nFormat == NUMBER_SEM_VIRGULA
	   		cFormat := '<NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'
	    Case nFormat == NUMBER_PERCENTUAL
	        cFormat := '<NumberFormat ss:Format="0.00%"/>'
	    Case nFormat == 5
	         cFormat := '<NumberFormat ss:Format="0.000"/>'
	    Case nFormat == 6
	        cFormat := '<NumberFormat ss:Format="0.0000%"/>'
	EndCase      

Return cFormat
