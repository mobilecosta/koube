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
         WHERE D3_FILIAL = %xFilial:SD3% AND SUBSTRING(D3_OP, 1,8) = %exp:lEFT(cOp, 8)% AND D3_CF = 'PR0'
          AND D3_ESTORNO <> 'S' AND %notDel%
    EndSql
    cRet := Strzero((cAliasTrb)->QTDE + 1,3)
    cRet := AllTrim(cOp) + cRet
    (cAliasTrb)->(DBCloseArea())
    RestArea(aArea)
    UnLockByName(cSemaforo)
Return cRet
