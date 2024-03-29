#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "totvs.ch"
//--------------------------------------------
/*/{Protheus.doc} CUSTOM.XPCP.001
RELATORIO IMPRESSAO DE ETIQUETA
@type function
@version 1.0
@author:
@since:
@alterado por: Roberto R. Mezzalira - 23/02/2024
/*/
//--------------------------------------------

User Function APCPET001()

	If ValidPerg()
		MsAguarde({|| ImpEtiq() },"Impress�o de etiqueta","Aguarde...")
	EndIf
 
Return 

   
Static Function ImpEtiq()
	Local cQuery	:= ""
	Local nQuant	:= MV_PAR05
	Local oFont32   := TFont():New('Arial',32,32,,.F.,,,,.T.,.F.,.F.)
	Local oFont16	:= TFont():New('Arial',16,16,,.F.,,,,.T.,.F.,.F.)
	Local oFont10	:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
	Local oFont45	:= TFont():New('Arial',45,45,,.F.,,,,.T.,.F.,.F.)

	Local cLote		:= "001"
	Local cData     := STOD("  /  /  ")
	Local cDatav    := " "
 	Local lAdjustToLegacy 	:= .F.
 
	Local nLin		:= 0
	Local nCol		:= 0
	Local nLinC		:= 0
	Local nColC		:= 0
	Local nWidth	:= 0
	Local nHeigth   := 0
	Local lBanner	:= .T.		//Se imprime a linha com o c�digo embaixo da barra. Default .T.
	Local nPFWidth	:= 0
	Local nPFHeigth	:= 0
	Local lCmtr2Pix	:= .T.		//Utiliza o m�todo Cmtr2Pix() do objeto Printer.Default .T.

    Local oSqlMov      := Nil
	Local cAliasTmp    := " "
	Local nR           := 0
	Local cLocal       := "c:\temp\"
    Local cFile        := 'ETQOP'+ALLTRIM(MV_PAR01)+'.PDF'
	Local cSession		:= GetPrinterSession()
	Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION
	Local nLocal		:= 1
	Local nOrdem		:= 1
	Local nOrient		:= 1
	Local nPrintType	:= 6
	Local oPrinter		:= Nil
	Local oSetup		:= Nil
	Local aOrdem		:= {"Padrao" }
	Local aDevice		:= {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
	Local bParam		:= {|| ValidPerg() }
	Local cDevice		:= ""

	cSession	:= GetPrinterSession()
	cDevice		:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	nOrient		:= 1
	nLocal		:= 1
	nPrintType	:= aScan(aDevice,{|x| x == cDevice })     

	MsProcTxt("Identificando a impressora...")
    oPrinter := FWMSPrinter():New(cFile, 6, lAdjustToLegacy ,cLocal, .T.)
	oSetup	 := FWPrintSetup():New (nFlags,cFile)

	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrient)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetOrderParms(aOrdem,@nOrdem)
	oSetup:SetUserParms(bParam)

	If oSetup:Activate() == PD_OK 
		fwWriteProfString(cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )	
		fwWriteProfString(cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )	
		fwWriteProfString(cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
			
		oPrinter:lServer			:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER	
		oPrinter:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
		oPrinter:setCopies(1)
		oPrinter:SetPaperSize(0,60,100)
		
		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oPrinter:nDevice		:= IMP_SPOOL
			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			oPrinter:cPrinter		:= oSetup:aOptions[PD_VALUETYPE]
		Else 
			oPrinter:nDevice		:= IMP_PDF
			oPrinter:cPathPDF		:= oSetup:aOptions[PD_VALUETYPE]
			oPrinter:SetViewPDF(.T.)
		Endif
	Else 
		MsgInfo("Relat�rio cancelado pelo usu�rio.")
		oPrinter:Cancel()

		Return
	EndIf

	cAliasTmp	:= GetNextAlias()
 	cQuery := " SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_OP,C2_PRODUTO,C2_DATPRI, "+CRLF 
	cQuery += "        B1_DESC ,B1_CODGTIN ,B1_PRVALID ,B5_ONU ,DY3_ONU ,DY3_DESCRI , DY3_NRISCO"+CRLF 
	cQuery += " FROM " + RetSqlName("SC2") + " SC2 "+CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "+CRLF 
	cQuery += " ON SB1.B1_FILIAL='" + xFilial("SB1")+"' AND B1_COD=C2_PRODUTO AND SB1.D_E_L_E_T_ = ' '"+CRLF 
	cQuery += " LEFT JOIN " + RetSqlName("SB5") + " SB5"+CRLF 
	cQuery += " ON SB5.B5_FILIAL = '" + xFilial("SB1") + "'AND SB5.B5_COD = SC2.C2_PRODUTO AND SB5.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " LEFT JOIN " + RetSqlName("DY3") + " DY3 "+CRLF
	cQuery += " ON DY3.DY3_FILIAL = '"+SUBSTR(xFilial("SB1"),1,4)+"'AND DY3.DY3_ONU = SB5.B5_ONU AND DY3_ITEM ='01' AND DY3.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " WHERE SC2.C2_FILIAL ='" + xFilial("SC2")+"' AND "+CRLF
	cQuery += "       SC2.C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "+CRLF 
	cQuery += "       SC2.C2_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "+CRLF 
    cQuery += "       SC2.D_E_L_E_T_=' '"+CRLF  
      
	oSqlMov:= FWPreparedStatement():New()
	oSqlMov:SetQuery(cQuery)
	cQry:= oSqlMov:GetFixQuery()
	cAliasTmp := MpSysOpenQuery(cQry)	
	Dbselectarea((cAliasTmp))

	(cAliasTmp)->(DbGoTop())
 
	oPrinter:SetMargin(001,001,001,001)
 
	DO While (cAliasTmp)->(!Eof())

		For nR := 1 to nQuant

			nLin := 10
			nCol := 15 // 22
 
			MsProcTxt("Imprimindo "+alltrim((cAliasTmp)->B1_CODGTIN) + " - " + alltrim((cAliasTmp)->B1_DESC)+"...")

			oPrinter:StartPage()
			nLinC		:= 4.95		//Linha que ser� impresso o C�digo de Barra
			nColC		:= 1.6		//Coluna que ser� impresso o C�digo de Barra
			nWidth	 	:= 0.0164	//Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta � 0.0164
			nHeigth   	:= 0.6		//Numero da Altura da barra. Default 1.5 --- limite de altura � 0.3
			lBanner		:= .T.		//Se imprime a linha com o c�digo embaixo da barra. Default .T.
			nPFWidth	:= 0.8		//N�mero do �ndice de ajuste da largura da fonte. Default 1
			nPFHeigth	:= 0.9		//N�mero do �ndice de ajuste da altura da fonte. Default 1
			lCmtr2Pix	:= .T.		//Utiliza o m�todo Cmtr2Pix() do objeto Printer.Default .T.
			
			oPrinter:Box(40, 60, 100, 180, "-3")                                                               

			oPrinter:Say(80,85, alltrim((cAliasTmp)->C2_PRODUTO) ,oFont32)

 			oPrinter:Say(nLin,nCol +195, "ONU " + alltrim((cAliasTmp)->DY3_ONU),oFont10)
			oPrinter:Say(nLin + 10, nCol + 040, alltrim((cAliasTmp)->DY3_DESCRI) + "  RISCO " + (cAliasTmp)->DY3_NRISCO ,oFont10)
			nLin+= 5
			nLin+= 5
			//linha coluna
			cData := DTOC(DaySum( stod((cAliasTmp)->C2_DATPRI), (cAliasTmp)->B1_PRVALID ))
			cDatav:= SUBSTR(cData,4,2)+"/"+SUBSTR(cData,9,2)//validade

			//coluna linha tamanho - N�o informado onde buscar o a sequencia do lote, Op��o D3_LOTECTL
			oPrinter:Say(210, 120, alltrim((cAliasTmp)->DY3_NRISCO) ,oFont45)
			oPrinter:DataMatrix(190,110,alltrim((cAliasTmp)->C2_NUM + " " + (cAliasTmp)->C2_ITEM  + " " +  (cAliasTmp)->C2_SEQUEN)+" "+cDatav, 80)

			nLin+= 95

			oPrinter:Say(nLin + 10,nCol + 50, alltrim((cAliasTmp)->B1_DESC) ,oFont16)
			nLin+= 12
			oPrinter:Say(nLin + 10,nCol + 50,"Ordem de Produ��o: " + alltrim((cAliasTmp)->C2_NUM + " " + (cAliasTmp)->C2_ITEM  + " " + (cAliasTmp)->C2_SEQUEN) ,oFont10)
			nLin+= 12

			cLote := (cAliasTmp)->C2_NUM+(cAliasTmp)->C2_ITEM+(cAliasTmp)->C2_SEQUEN+'001'
			If cLote = " " 
				cLote := "xxxxxx"
			Endif	
			oPrinter:Say(nLin + 10,nCol + 50,"Lote: " + alltrim(cLote) ,oFont10)
			nLin+= 12
   			oPrinter:Say(nLin + 10,nCol + 50,"Validade: " + cDatav ,oFont10)
			// FWMsPrinter():FWMsBar(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
            oPrinter:FwMsBar(	"CODE128" /* cTypeBar */, 0.8 /* nRow */, 1 /* nCol */,AllTrim((cAliasTmp)->B1_CODGTIN) /* cCode */, oPrinter /* oPrint */,;
								.F. /* lCheck */, NIL /* Color */, .f. /* lHorz */, 0.0164 /* nWidth */, 0.8 /* nHeigth */, .F. /* lBanner */,;
								 /* cFont */ , /* cMode */, .F. /* lPrint */,  1 /* nPFWidth */, 1 /*nPFHeigth */, .F. /*lCmtr2Pix*/)
			oPrinter:EndPage()

		Next
		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())
	
	//oPrinter:Preview()
	oPrinter:Print()
	
 
Return
 
/*Montagem da tela de perguntas*/
Static Function ValidPerg()
	Local aParamBox	:= {}
	Local lRet 		:= .F.
	Local cProdDe	:= ""
	Local cProdAte	:= ""
	Local nTamop    := (TamSX3("C2_NUM")[1])+(TamSX3("C2_ITEM")[1])+(TamSX3("C2_SEQUEN")[1])
	Local cOpde	    := SPACE(nTamop)
	Local cOpate	:= SPACE(nTamop)
	Local nQuant    := 1
	
	cProdDe := space(TamSX3("B1_COD")[1])
	cProdAte:= REPLICATE("Z",TAMSX3("B1_COD")[1])
    
	aAdd(aParamBox,{01,"Ordem Produ��o de"	 	,cOpde 	    ,""					,"","SC2KOB","", 60,.F.})	// MV_PAR01
	aAdd(aParamBox,{01,"Ordem Produ��o ate"	  	,cOpate   	,""					,"","SC2KOB","", 60,.T.})	// MV_PAR02
	aAdd(aParamBox,{01,"Produto de"	  			,cProdDe 	,""					,"","SB1"	,"", 60,.F.})	// MV_PAR03
	aAdd(aParamBox,{01,"Produto ate"	   		,cProdAte	,""					,"","SB1"	,"", 60,.T.})	// MV_PAR04
	aAdd(aParamBox,{01,"Quantidade Etiqueta"	,nQuant		,"@E 9999"			,"",""		,"", 60,.F.})	// MV_PAR05
  	
	IF ParamBox(aParamBox,"Etiqueta Produto",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,FUNNAME(),.T.,.T.)
		lRet := .T.
	EndIf

Return lRet
