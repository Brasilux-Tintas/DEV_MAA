#Include "PROTHEUS.CH"
#Include "COLORS.CH"
#Include "TOPCONN.CH"
#include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "sigawin.ch"
#include "STDWIN.CH"
#INCLUDE "TBICONN.CH"
// Ponto de entrada para estornar a transferencia multipla
// Dyego Figueiredo - www.chaus.com.br
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA261EXC()
     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        u_MA260EXC()
     Endif
Return

