#include 'totvs.ch'

//----------------------------------------------
/*/{Protheus.doc} AFIN103
Fun��o para Convers�o da Representa��o Num�rica do C�digo de Barras - Linha Digit�vel (LD) em C�digo de Barras (CB).
Para utiliza��o dessa Fun��o, deve-se criar um Gatilho para o campo E2_LINDIG, Conta Dom�nio: E2_CODBAR, Tipo: Prim�rio,
Regra: EXECBLOCK("AFIN103",.T.), Posiciona: N�o.

@type function
@version 1.0
@author Totvs

@since 01/01/2015

@return Character, Valor Convertido

@example
EXECBLOCK("AFIN103",.T.)
/*/
//----------------------------------------------
USER FUNCTION AFIN103() as Character

	Private cStr as Character

	cStr := LTRIM(RTRIM(M->E2_LINDIG))

	IF VALTYPE(M->E2_LINDIG) == NIL .OR. EMPTY(M->E2_LINDIG)
     	// Se o Campo est� em Branco n�o Converte nada.
		cStr := ""
	ELSE
     	// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
     	// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
		cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
	ENDIF

	DO CASE
		CASE LEN(cStr) == 47
			cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
		// fim case

		CASE LEN(cStr) == 48
			cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
		// fim case

		OTHERWISE
			cStr := cStr+SPACE(48-LEN(cStr))
		// fim otherwise
	ENDCASE

RETURN cStr