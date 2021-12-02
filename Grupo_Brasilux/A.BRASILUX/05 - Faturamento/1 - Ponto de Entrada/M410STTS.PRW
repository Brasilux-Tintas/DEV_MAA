#include 'protheus.ch'
#include 'topconn.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M410STTS  ºAutor  ³ Cleber Orati      º Data ³  28/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Está em todas as rotinas de alteração, inclusão, exclusão eº±±
±±º          ³ devolução de compras. Executado após todas as alterações noº±±
±±º          ³  arquivo de pedidos terem sido feitas.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function M410STTS()
     u_zcfga01( 'M410STTS' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).
        If (INCLUI .OR. ALTERA)
           IF !EMPTY(M->C5_OBS)
              MSMM(SC5->C5_OBSSC5,     ,     , M->C5_OBS  , 1   ,         ,      , "SC5" , "C5_OBSSC5"             )
           ENDIF
           IF !EMPTY(M->C5_OBSNF)
              MSMM(SC5->C5_OBSNFS,     ,     , M->C5_OBSNF, 1   ,         ,      , "SC5" , "C5_OBSNFS"             )
           ENDIF          
           IF (cNumEmp = "01010101") .or. (cNumEmp = "01060101")
              U_EnviaRec("SC5",SC5->C5_NUM,.f.,SC5->C5_VEND1)      
           ENDIF 
        Endif 
     Endif
Return Nil
