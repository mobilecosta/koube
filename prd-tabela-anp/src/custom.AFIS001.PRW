#Include 'Protheus.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------------------------
/*/{Protheus.doc} AFIS001
Cadastro de Códigos ANP

@type function
@version 1.0
@author Mauricio Silva

@since 15/03/2022
/*/
//-----------------------------------------------------------------------------
User Function AFIS001()

	Local oBrowse as Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z01")
	oBrowse:SetMenuDef("custom.AFIS001")
	oBrowse:SetDescription("Tabela ANP")
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cria o menu principal da rotina

@type function
@version 1.0
@author Mauricio Silva

@since 15/03/2022

@return Array, Array contendo os menus
/*/
//-----------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"             OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.custom.AFIS001" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"	  ACTION "VIEWDEF.custom.AFIS001" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.custom.AFIS001" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.custom.AFIS001" OPERATION 5 ACCESS 0

Return aRotina

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria o modelo de dados p/ a rotina.
Pode ser utilizado p/ execuções automática

@type function
@version 1.0
@author Mauricio Silva

@since 15/03/2022

@return Object, Objeto MpFormModel
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruM := FWFormStruct(1, 'Z01')
	Local oModel := MPFormModel():New('AFISM001')

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('MESTRE', /*cOwner*/, oStruM, /*bPreValidacao*/,  /*pOSvALIDACAO*/, /*bCarga*/ )
	//Adiciona Descricao
	oModel:SetDescription("Tabela ANP")
	//Ordem
	oModel:SetPrimaryKey({"Z01_FILIAL", "Z01_CODANP"})

Return oModel

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria o objeto visual da tela.

@type function
@version 1.0
@author Mauricio Silva

@since 15/03/2022

@return Object, Instância da classe fwFormView
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("custom.AFIS001")
	Local oStruM := FWFormStruct(2, 'Z01')
	Local oView

	//Cria Objeto de View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Define Mestre
	oView:AddField('VIEW', oStruM, 'MESTRE')

Return oView
