component {

    this.name = "cbmigrations";
    this.author = "Eric Peterson";
    this.description = "Keep track of database migrations using ColdBox";
    this.version = "1.0.0";
    this.cfmapping = "cbmigrations";
    this.entryPoint = "/cbmigrations";

    function configure() {
        parseParentSettings();

        routes = [
            { module = "cbmigrations", pattern = "/", handler = "main", action = "index" },
            { module = "cbmigrations", pattern = "/install", handler = "main", action = { POST = "install" } },
            { module = "cbmigrations", pattern = "/uninstall", handler = "main", action = { POST = "uninstall" } },
            { module = "cbmigrations", pattern = "/up", handler = "main", action = { POST = "migrate" }, direction = "up" },
            { module = "cbmigrations", pattern = "/down", handler = "main", action = { POST = "migrate" }, direction = "down" },
            { module = "cbmigrations", pattern = "/refresh", handler = "main", action = { POST = "refresh" } }
        ];
    }

    private function parseParentSettings(){
        var oConfig = controller.getSetting( "ColdBoxConfig" );
        var configStruct = controller.getConfigSettings();
        var cbmigrations = oConfig.getPropertyMixin( "cbmigrations", "variables", structnew() );

        //defaults
        configStruct.cbmigrations = {
            migrationsDir = "/resources/database/migrations",
            username = "cbmigrations",
            password = "cbmigrations"
        };

        // incorporate settings
        structAppend( configStruct.cbmigrations, cbmigrations, true );
    }

}