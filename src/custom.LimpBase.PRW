#include "rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "fileio.ch"
#include "protheus.ch"

//----------------------------------------------
/*/{Protheus.doc} LIMPA_BASE
Rotina para ler arquivos TXT e efetuar a limpeza dos
dos movimentos da base de dados SQL

@type function
@version 1.0
@author Mario Chagas

@since 01/12/2009
/*/
//----------------------------------------------
USER FUNCTION LIMPA_BASE()

	Local cArq  as Character
	Local cTipo as Character

	Private aFilesTxt as Array
	Private nHdl2     as Numeric

	If MsgYesNo("Essa rotina irá limpar os movimentos da base de dados SQL" + CRLF + "Deseja Continuar ?")

		cTipo := "Arquivos de Dados (*.TXT)  |*.TXT | "
		cArq := cGetFile(cTipo, "Selecione o arquivo") // seleciona o arquivo com as tabelas a serem limpas

		aFilesTxt := Directory(cArq)
		If (Len(aFilesTxt) <= 0)
			MsgBox("Arquivo não encontrado !","A T E N C A O","ALERT")
		else
			nHdl2 := FT_FUSE(cArq)
			If nHdl2 == -1
				MsgBox("Problema com leitura do arquivo "+Alltrim(aFilesTxt[i,1]),"A T E N C A O","ALERT")
			Else
				Processa( { || LIMPA() },"Limpando tabelas...")
			Endif
		EndIf
	Endif

Return

//----------------------------------------------
/*/{Protheus.doc} LIMPA
Executa a limpeza.

@type function
@version 1.0
@author Mario Chagas

@since 01/12/2009
/*/
//----------------------------------------------
Static Function LIMPA()

	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())

	While !FT_FEOF() //Processa enqto houver dados no arquivo texto
		IncProc("Processando Leitura do Arquivo Texto..." + Alltrim(aFilesTxt[1,1]))
		cQuery := "DELETE FROM "+Left(Alltrim(FT_FREADLN()),6)
		TCSqlExec(cQuery)
		FT_FSKIP()

	EndDo

	FT_FUSE()

Return