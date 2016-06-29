component {

    property name="migrationService" inject="MigrationService@cbmigrations";
    property name="config" inject="coldbox:setting:cbmigrations";

    function preHandler( event, action, eventArguments, rc, prc ) {
        var credentials = event.getHTTPBasicCredentials();

        if ( ! structKeyExists( config, "username" ) || ! structKeyExists( config, "password" ) ) {
            // secured content data and skip event execution
            event.renderData(
                data = "<h1>Forbidden Access</h1><p>Access to cbmigrations dashboard is forbidden.</p>",
                statusCode = "403",
                statusText = "Forbidden"
            ).noExecution();            
        }
        else if ( config.username != credentials.username ||
             config.password != credentials.password ) {

            // Not secure!
            event.setHTTPHeader(
                name = "WWW-Authenticate",
                value = 'basic realm="Please enter your username and password for cbmigrations!"'
            );

            // secured content data and skip event execution
            event.renderData(
                data = "<h1>Unathorized Access</h1><p>Content Requires Authentication</p>",
                statusCode = "401",
                statusText = "Unauthorized"
            ).noExecution();
        }
    }

    function index( event, rc, prc ) {
        prc.migrationTableInstalled = migrationService.isMigrationTableInstalled();
        prc.migrations = migrationService.findAll();
    }

    function install( event, rc, prc ) {
        param rc.runAll = false;
        migrationService.install( rc.runAll );
        setNextEvent( "cbmigrations" );
    }

    function uninstall( event, rc, prc ) {
        migrationService.uninstall();
        setNextEvent( "cbmigrations" );
    }

    function migrate( event, rc, prc ) {
        param rc.all = false;

        if ( rc.all ) {
            migrationService.runAllMigrations( rc.direction );
            setNextEvent( "cbmigrations" );
            return;
        }

        if ( ! event.valueExists( "componentPath" ) ) {
            setNextEvent( "cbmigrations" );
            return;
        }

        try {
            migrationService.runMigration( rc.direction, rc.componentPath );

            setNextEvent( "cbmigrations" );
            return
        }
        catch ( any e ) {
            setNextEvent( "cbmigrations" );
            return;
        }
    }

    function refresh( event, rc, prc ) {
        migrationService.runAllMigrations( "down" );
        migrationService.runAllMigrations( "up" );
        setNextEvent( "cbmigrations" );
        return;
    }

}