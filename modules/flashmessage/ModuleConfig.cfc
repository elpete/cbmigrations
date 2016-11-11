component {

    // Module Properties
    this.title              = "Flash Message";
    this.author             = "Eric Peterson";
    this.webURL             = "";
    this.description        = "A nice module to produce multiple messages using Flash session storage";
    this.version            = "1.0.0";
    // If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
    this.viewParentLookup   = true;
    // If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
    this.layoutParentLookup = true;
    // Module Entry Point
    this.entryPoint         = "flashmessage";
    // CF Mapping
    this.cfMapping          = "flashmessage";

    function configure(){
    }

    /**
    * Fired when the module is registered and activated.
    */
    function onLoad(){
        // parse parent settings
        parseParentSettings();
    }

    /**
    * Fired when the module is unregistered and unloaded
    */
    function onUnload(){
    }

    /**
    * Prepare settings and returns true if using i18n else false.
    */
    private function parseParentSettings(){
        var oConfig      = controller.getSetting( "ColdBoxConfig" );
        var configStruct = controller.getConfigSettings();
        var flashmessage = oConfig.getPropertyMixin( "flashmessages", "variables", structnew() );

        // Default template
        configStruct.flashmessage = {
            flashKey = "elpete_flashmessage",
            containerTemplatePath = "#moduleMapping#/views/_templates/FlashMessageContainer.cfm",
            messageTemplatePath = "#moduleMapping#/views/_templates/FlashMessage.cfm"
        };

        // Incorporate settings
        structAppend( configStruct.flashmessage, flashmessage, true );
    }

}