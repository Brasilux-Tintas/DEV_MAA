#include "topconn.ch"
User Function PEGAUSERS()
Local i,lNovo,_aRetUser,cCod,_cGrpEmp,cMat,cQry1
//Local cAux
/*
nArray
1 - Informações do usúario
2 - Detalhes do usuário (impressão, configuração de página, tipo de ambiente e etc)
3 - Menus do usuário.

aRet
Informações do usuário:

Índice       Tipo Conteudo
[1][1]   C     Número de identificação seqüencial com o tamanho de 6 caracteres
[1][2]   C     Nome do usuário
[1][3]   C     Senha (criptografada)
[1][4]   C     Nome completo do usuário
[1][5]   A     Vetor contendo as últimas n senhas do usuário
[1][6]   D     Data de validade
[1][7]   N     Número de dias para expirar
[1][8]   L      Autorização para alterar a senha
[1][9]   L      Alterar a senha no próximo logon
[1][10] A     Vetor com os grupos
[1][11] C     Número de identificação do superior
[1][12] C     Departamento
[1][13] C     Cargo
[1][14] C     E-mail
[1][15] N     Número de acessos simultâneos
[1][16] D     Data da última alteração
[1][17] L      Usuário bloqueado
[1][18] N     Número de dígitos para o ano
[1][19] L      Listner de ligações
[1][20] C     Ramal
[1][21] C     Log de operações
[1][22] C     Empresa, filial e matricula
[1][23] A     Informações do sistema 
    [1][23][1]  L  Permite alterar database do sistema
    [1][23][1]  N  Dias a retroceder
    [1][23][1]  N  Dias a avançar
[1][24] D     Data de inclusão no sistema
[1][25] C     Nível global de campo
[1][26] U     Não usado   

[2][1]   A    Vetor contendo os horários dos acessos, cada elemento do vetor corresponde um dia da semana com a hora inicial e final.
[2][2]   N    Uso interno
[2][3]   C    Caminho para impressão em disco
[2][4]   C    Driver para impressão direto na porta. Ex: EPSON.DRV
[2][5]   C    Acessos
[2][6]   A    Vetor contendo as empresas, cada elemento contem a empresa e a filial. Ex:"9901", se existir "@@@@" significa acesso a todas as empresas
[2][7]   C    Elemento alimentado pelo ponto de entrada USERACS
[2][8]   N    Tipo de impressão: 1 - em disco, 2 - via Windows e 3 direto na porta
[2][9]   N    Formato da página: 1 – retrato, 2 - paisagem
[2][10] N    Tipo de Ambiente: 1 – servidor, 2 - cliente
[2][11] L     Priorizar configuração do grupo
[2][12] C    Opção de impressão
[2][13] L    Acessar outros diretórios de impressão

[3]       A    Vetor contendo o módulo, o nível e o menu do usuário. 
      Ex: [3][1] = "019\sigaadv\sigaatf.xnu"
            [3][2] = "029\sigaadv\sigacom.xnu"

Se o parâmetro lNoAll for igual a .F., a dimensão 4 do array também será mostrada.

[4]       A    Vetor contendo as informações do SenhaP
[4][1]  L     Utiliza SenhaP
[4][2]  C    Número de série do SenhaP
[4][3]  C    Não usado
[4][4]  C    Não usado

[5]       A    Array com as informações do painel de gestão
[6]       A    Array com as informações dos indicadores nativos

Informações do grupo:

Índice Tipo Conteudo

[1][1]   C      Número de identificação sequencial com o tamanho de 6 caracteres
[1][2]   C      Nome do grupo
[1][3]   A      Vetor contendo os horários dos acessos,  cada elemento corresponde a um dia da semana com a hora inicial e final.
[1][4]   D      Data de validade
[1][5]   N      Número de dias para expirar
[1][6]   L      Autorização para alterar a senha
[1][7]   N     Uso interno
[1][8]   C     Caminho para impressão em disco
[1][9]   C     Driver para impressão direto na porta. Ex: EPSON.DRV
[1][10] C     Acessos
[1][11] A     Vetor contendo as empresas, cada elemento contem a empresa e a filial. Ex:9901, se existir "@@@@" significa acesso a todas as empresas
[1][12] D     Data da última alteração
[1][13] N     Tipo de impressão: 1 - em disco, 2 - via Windows e 3 direto na porta
[1][14] N     Formato da página: 1 - retrato, 2 - paisagem
[1][15] N     Tipo de Ambiente: 1 - servidor, 2 - cliente
[1][16] C     Opção de impressão
[1][17] L      Acessar outros diretórios de impressão
[1][18] A      Range da database
     [1][18][1] - Permite retroceder ou avançar database.
     [1][18][2] - Dias a retroceder
     [1][18][3] - Dias a avançar
[1][19] D      Data de inclusão
[1][20] C      Nível global de campo

    
*/      

_cGrpEmp := FWGrpCompany()

If _cGrpEmp != "01"
	MsgBox("Esta operação só pode ser executada no grupo 01-BRASILUX!", "Atenção!", "STOP")
	Return
Endif 


cQry1 := "SELECT USR.USR_ID AS CODIGO,USR.USR_CODIGO AS NOMELOGIN,UPPER(USR.USR_NOME) AS NOME,USR.USR_MSBLQL AS BLOQUEADO,"+;
"ISNULL(VIN.USR_CODFUNC,'') AS MATRICULA,LOWER(USR.USR_EMAIL) AS EMAIL,USR.USR_RAMAL AS RAMAL ,"+;
"ISNULL(VIN.USR_GRPEMP,'') AS GRPEMP,ISNULL(VIN.USR_FILIAL,'') AS FILIAL "+;
"FROM SYS_USR USR  WITH (NOLOCK) "+;
"LEFT OUTER JOIN SYS_USR_VINCFUNC VIN WITH (NOLOCK) ON (VIN.D_E_L_E_T_ <> '*') AND (USR.USR_ID = VIN.USR_ID) "+;
"WHERE (USR.D_E_L_E_T_ <> '*') ORDER BY CODIGO "

TCQuery cQry1 ALIAS "TCQ" NEW
DbSelectArea("TCQ")

dbselectarea("SZH")
dbsetorder(1)

// Definir a ordem
//PswOrder(1) // Ordem de nome  

DbSelectArea("TCQ")
dbgotop()
do while !eof()
//for i = 1 to 1500
	// Efetuo a pesquisa, definindo se pesquiso usuário ou grupo 
	//cCod := padl(alltrim(str(i)),6,"0")
	//If PswSeek(cCod,.T.)
		cCod := alltrim(TCQ->CODIGO)
   		// Obtenho o resultado conforme vetor
   		//_aRetUser := PswRet(1)  
		dbselectarea("SZH")
		dbseek(xFilial("SZH")+cCod)
		lNovo := !found()
		reclock("SZH",lNovo)
		SZH->ZH_FILIAL := xFilial("SZH")
		SZH->ZH_CODIGO := cCod
		SZH->ZH_LOGIN := TCQ->NOMELOGIN //_aRetUser[1,2]
		SZH->ZH_NOME := ALLTRIM(TCQ->NOME) //UPPER(_aRetUser[1,4])
		SZH->ZH_MSBLQL := TCQ->BLOQUEADO //iif(_aRetUser[1,17],"1","2")   
/*
		cMat := alltrim(_aRetUser[1,22])
		*/

		cMat := ""
		IF !EMPTY(ALLTRIM(TCQ->GRPEMP)) .AND. !EMPTY(ALLTRIM(TCQ->FILIAL)) .AND. !EMPTY(ALLTRIM(TCQ->MATRICULA))
			cMat := PADR(ALLTRIM(TCQ->GRPEMP)+ALLTRIM(TCQ->FILIAL),8," ")+ALLTRIM(TCQ->MATRICULA)
		ENDIF 
		SZH->ZH_MAT := cMat
		SZH->ZH_EMAIL := TCQ->EMAIL //lower(_aRetUser[1,14])   
		SZH->ZH_RAMAL := TCQ->RAMAL //_aRetUser[1,20]
		dbselectarea("SZH")
		msunlock()   		
	/*
	else
		dbselectarea("SZH")
		dbseek(xFilial("SZH")+cCod)
		if found()
			reclock("SZH",.f.)
			dbdelete()
			msunlock()
		endif 
 	endif
	*/
 //next
	DbSelectArea("TCQ")
	dbskip()
enddo 
DbSelectArea("TCQ")
dbclosearea()
return    

