component {

    property name="migrationService" inject="MigrationService@cbmigrations";

    function index( event, rc, prc ) {
        prc.errors = flash.get( "cbmigrations_errors", [] );
        prc.messages = flash.get( "cbmigrations_messages", [] );
        prc.migrationTableInstalled = migrationService.isMigrationTableInstalled();
        prc.migrations = migrationService.findAll();

        event.setLayout( name = "Main", module = "cbmigrations" );
    }

    function install( event, rc, prc ) {
        migrationService.installMigrationTable();
        flash.set( "cbmigrations_messages", "Migration table successfully installed." );
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
            flash.put( "cbmigrations_errors", "No componentPath specified." );
            setNextEvent( "cbmigrations" );
            return;
        }

        try {
            migrationService.runMigration( rc.direction, rc.componentPath );

            setNextEvent( "cbmigrations" );
            return
        }
        catch ( any e ) {
            flash.put( "cbmigrations_errors", serializeJSON( e ) );
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