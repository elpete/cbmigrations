component singleton {

    property name="config" inject="coldbox:setting:cbmigrations";
    property name="cache" inject="cachebox:default";

    variables.cacheKeys = {
        "migrationTableInstalled" = "cbmigrations.migrationTableInstalled",
        "dbVersion" = "cbmigrations.dbVersion"
    };

    public array function findAll() {

        var migrationTableInstalled = isMigrationTableInstalled();

        var objectsQuery = directoryList( path = expandPath( config.migrationsDir ), listInfo = "query" );
        var objectsArray = [];
        for ( var row in objectsQuery ) {
            arrayAppend( objectsArray, row );
        }
        var onlyCFCs = arrayFilter( objectsArray, function( object ) {
            return object.type == "File" && right( object.name, 4 ) == ".cfc";
        } );

        var prequisitesInstalled = true;
        var migrations = arrayMap( onlyCFCs, function( file ) {
            var timestampString = left(file.name, 17);
            var timestampParts = listToArray(timestampString, "_");
            var timestamp = createDateTime(timestampParts[1], timestampParts[2], timestampParts[3], mid(timestampParts[4], 1, 2), mid(timestampParts[4], 3, 2), mid(timestampParts[4], 5, 2));

            var componentName = left( file.name, len( file.name ) - 4 );
            var migrationRan = migrationTableInstalled ? isMigrationRan( componentName ) : false;

            var migration = {
                fileName = file.name,
                componentName = componentName,
                absolutePath = file.directory & "/" & file.name,
                componentPath = config.migrationsDir & "/" & componentName,
                timestamp = timestamp,
                migrated = migrationRan,
                canMigrateUp = !migrationRan && prequisitesInstalled,
                canMigrateDown = migrationRan,
                migratedDate = ""
            };

            prequisitesInstalled = migrationRan;

            return migration;
        } );

        if ( ! migrationTableInstalled && ! arrayIsEmpty( migrations ) ) {
            arrayEach( migrations, function( migration ) {
                migration.canMigrateUp = false;
                migration.canMigrateDown = false;
            } );

            // sort in the correct order
            arraySort( migrations, function( a, b ) {
                return dateCompare( a.timestamp, b.timestamp );
            } );

            return migrations;
        }

        // sort in reversed order to get which migrations can be brought down
        arraySort( migrations, function( a, b ) {
            return dateCompare( b.timestamp, a.timestamp );
        } );

        var laterMigrationsNotInstalled = true;
        arrayEach( migrations, function( migration ) {
            migration.canMigrateDown = migration.migrated && laterMigrationsNotInstalled;
            laterMigrationsNotInstalled = !migration.migrated;
        } );

        // sort in the correct order
        arraySort( migrations, function( a, b ) {
            return dateCompare( a.timestamp, b.timestamp );
        } );

        return migrations;
    }

    public void function runNextMigration( required string desiredDirection ) {
        var migrations = findAll();

        for ( var migration in migrations ) {
            var canMigrateInDesiredDirection = migration[ "canMigrate#desiredDirection#" ];
            if ( canMigrateInDesiredDirection ) {
                runMigration( arguments.desiredDirection, migration.componentPath );
                return;
            }
        }
    }

    public void function runMigration( direction, componentPath ) {
        install();

        var componentName = replaceNoCase( componentPath, config.migrationsDir & "/", "" );
        var migrationRan = isMigrationRan( componentName );

        if ( migrationRan && direction == "up" ) {
            throw("Cannot run a migration that has already been ran.");
        }
        
        if ( ! migrationRan && direction == "down" ) {
            throw("Cannot rollback a migration if it hasn't been ran yet.");
        }

        var migration = createObject( "component", componentPath );
        var runMigration = migration[ direction ];
        runMigration();

        logMigration( direction, componentPath );
    }

    private void function logMigration( direction, componentPath ) {
        var componentName = replaceNoCase( componentPath, config.migrationsDir & "/", "" );
        if ( direction == "up" ) {
            queryExecute(
                "INSERT INTO cbmigrations VALUES ( :name, :time )",
                { name = componentName, time = { value = now(), cfsqltype = "CF_SQL_TIMESTAMP" } }
            );
        } else {
            queryExecute(
                "DELETE FROM cbmigrations WHERE name = :name",
                { name = componentName }
            );
        }
    }

    public void function runAllMigrations( direction ) {
        var migrations = arrayFilter( findAll(), function( migration ) {
            return direction == "up" ? !migration.migrated : migration.migrated;
        } );

        if ( direction == "down" ) {
            // sort in reversed order to get which migrations can be brought down
            arraySort( migrations, function( a, b ) {
                return dateCompare( b.timestamp, a.timestamp );
            } );
        }

        arrayEach( migrations, function( migration ) {
            runMigration( direction, migration.componentPath );
        } );
    }

    public void function install( runAll = false ) {
        if ( isMigrationTableInstalled() ) {
            return;
        }

        queryExecute("
            CREATE TABLE cbmigrations (
                name VARCHAR(200) NOT NULL,
                migration_ran #getDateTimeColumnType()# NOT NULL,
                PRIMARY KEY (name)
            )
        ");

        cache.set( variables.cacheKeys.migrationTableInstalled, true );

        if ( runAll ) {
            runAllMigrations( "up" );
        }
    }

    public void function uninstall() {
        if ( ! isMigrationTableInstalled() ) {
            return;
        }

        runAllMigrations( "down" );
        
        queryExecute( "DROP TABLE cbmigrations" );

        cache.set( variables.cacheKeys.migrationTableInstalled, false );
    }

    public boolean function isMigrationTableInstalled() {
        return cache.getOrSet( variables.cacheKeys.migrationTableInstalled, function() {
            cfdbinfo( name="results" type="Tables" );
            for ( var row in results ) {
                if ( row.table_name == "cbmigrations" ) {
                    return true;
                }
            }
            return false;
        }, 60 * 24 * 7 );
    }

    private boolean function isMigrationRan( componentName ) {
        var migrations = queryExecute("
            SELECT name
            FROM cbmigrations
        ");
        
        for ( var migration in migrations ) {
            if ( migration.name == componentName ) {
                return true;
            }
        }
        return false;
    }

    private string function getDateTimeColumnType() {
        cfdbinfo( name="results" type="Version" );

        switch( results.database_productName ) {
            case "PostgreSQL" : {
                return "TIMESTAMP";
            }
            case "MySQL" : {
                return "DATETIME";
            }
            case "Microsoft SQL Server" : {
                return "DATETIME";
            }
            case "Oracle" :{
                return "DATE";
            }
            default : {
                return "DATETIME";
            }
        }   
    }

}