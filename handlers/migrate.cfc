component extends="cbrestbasehandler.handlers.BaseHandler" {

    property name="migrationService" inject="MigrationService@cbmigrations";
    
    function up( event, rc, prc ) {
        structAppend( rc, event.getHTTPContent( json = true ) );

        if ( ! event.valueExists( "componentPath" ) ) {
            prc.response
                .setError( true )
                .setStatusCode( 400 )
                .addMessage( "No [componentPath] passed." );
            return;
        }

        try {
            var migration = createObject( "component", rc.componentPath );

            migration.up();

            prc.response.setData( {
                component = migration,
                migrated = true,
                migratedDate = now()
            } );
        }
        catch ( any e ) {
            prc.response
                .setError( true )
                .setStatusCode( 500 )
                .addMessage( serializeJSON( e ) )
                .setData( {
                    component = migration,
                    migrated = false,
                    migratedDate = ""
                } );
        }
    }

    function down( event, rc, prc ) {
        structAppend( rc, event.getHTTPContent( json = true ) );

        if ( ! event.valueExists( "componentPath" ) ) {
            prc.response
                .setError( true )
                .setStatusCode( 400 )
                .addMessage( "No [componentPath] passed." );
            return;
        }

        try {
            var migration = createObject( "component", rc.componentPath );

            // verify it has indeed been ran

            migration.down();

            prc.response.setData( {
                component = migration,
                migrated = false,
                migratedDate = ""
            } );
        }
        catch ( any e ) {
            prc.response
                .setError( true )
                .setStatusCode( 500 )
                .addMessage( serializeJSON( e ) )
                .setData( {
                    component = migration,
                    migrated = true,
                    migratedDate = "?"
                } );
        }
    }

}