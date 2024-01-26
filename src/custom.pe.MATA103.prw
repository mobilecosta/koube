#include "totvs.ch"

//----------------------------------------------
/*/{Protheus.doc} MT103IPC
PREENCHIMENTO CAMPOS ESPECIFICOS DOCUMENTO DE ENTRADA
Preenche Descrição do Produto e NCM no Documento de Entrada

@type function
@author SOLVS
@version 1.0

@since 24/06/2015

@see https://tdn.totvs.com/display/public/PROT/MT103IPC+-+Atualiza+campos+customizados+no+Documento+de+Entrada
/*/
//----------------------------------------------
User Function MT103IPC() as Logical

	Local aAreaSC7  as Array
	Local _nItem    as Numeric
	Local _nPosDesc as Numeric
	Local _nPosPrd  as Numeric
	Local _nPosIpi	as Numeric

	Local lRet as Logical

	lRet := .t.

	_nItem    := Paramixb[1]
	_nPosDesc := aScan(aHeader, { |x| AllTrim(x[2]) == "D1_XDESCPR"	})
	_nPosPrd  := aScan(aHeader, { |x| AllTrim(x[2]) == "D1_COD"		})
	_nPosIpi  := aScan(aHeader, { |x| AllTrim(x[2]) == "D1_XPOSIPI"	})

	aAreaSC7 := SC7->(GetArea())

	aCols[_nItem,_nPosDesc] := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[_nItem,_nPosPrd],"B1_DESC")
	aCols[_nItem,_nPosIpi ] := SB1->B1_POSIPI

	RestArea(aAreaSC7)

Return lRet
