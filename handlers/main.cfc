component {

    property name="migrationService" inject="MigrationService@cbmigrations";
    property name="config" inject="coldbox:setting:cbmigrations";
    property name="flashmessage" inject="flashmessage@FlashMessage";

    function preHandler( event, action, eventArguments, rc, prc ) {
        var credentials = event.getHTTPBasicCredentials();

        if ( ! structKeyExists( config, "username" ) || ! structKeyExists( config, "password" ) ) {
            // secured content data and skip event execution
            event.renderData(
                data = "<h1>Forbidden Access</h1><p>Access to cbmigrations dashboard is forbidden. Make sure to set your username and password in your `config/ColdBox.cfc` under `modulesSettings.cbmigrations`.</p>",
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
        param rc.next = false;

        var messages = [];
        var statusCode = 201
        transaction action="begin" {
            try {
                if ( rc.all ) {
                    migrationService.runAllMigrations( rc.direction );
                }
                else if ( rc.next ) {
                    migrationService.runNextMigration( rc.direction );
                }
                else if ( event.valueExists( "componentPath" ) ) {
                    migrationService.runMigration( rc.direction, rc.componentPath );
                }
                else {
                    [ "No action was taken" ];
                    statusCode = 200;
                }

                messages = flash.get( "successful.migrations", [] );
            }
            catch( any e ) {
                transaction action="rollback";

                messages = [ "An error occurred running the migration [#flash.get( "error.migration", "" )#].", e.detail ];
                statusCode = 500;
            }
        }

        if ( event.isAjax() ) {
            return event.renderData(
                type = "JSON",
                data = messages,
                statusCode = statusCode
            );
        }
        else {
            for ( var message in messages ) {
                if ( rc.direction == "up" ) {
                    flashmessage.info( "<strong class='text-success'>Migrated:</strong> #message#" );
                }
                else {
                    flashmessage.info( "<strong class='text-danger'>Rollback:</strong> #message#" );
                }
            }
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