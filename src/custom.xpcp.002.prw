#Include 'Protheus.ch'

/*/{Protheus.doc} SeqLotOp
Calculo do D3_LOTECTL 

@type function
@version 1.0
@author Gabriel Souza

@since 28/01/2024
/*/
User Function SeqLotOp(cOp)
Local cRet      := "001"
Local cAliasTrb := GetNextAlias()
Local aArea     := GetArea()
Local cSemaforo := "SEQLOTOP"+cOp

    While !LockByName(cSemaforo)
    End

    BeginSql Alias cAliasTrb
        SELECT COUNT(*) QTDE 
        FROM %table:SD3% 
        WHERE D3_FILIAL = %xFilial:SD3%
            AND D3_OP=%exp:cOp% 
            AND D3_TM='010' 
            AND %notDel%
    EndSql

    If !(cAliasTrb)->(Eof())
        cRet := Strzero((cAliasTrb)->QTDE,3)
    EndIf

    (cAliasTrb)->(DBCloseArea())
    RestArea(aArea)
    UnLockByName(cSemaforo)

Return cRet