component {

    property name="migrationsDir" inject="coldbox:setting:migrationsDirectory@cbmigrations";

    function findAll() {

        var migrationTableInstalled = isMigrationTableInstalled();

        var objectsQuery = directoryList( path = expandPath( migrationsDir ), listInfo = "query" );
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
                componentPath = migrationsDir & "/" & componentName,
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

    function runMigration( direction, componentPath ) {

        var componentName = replaceNoCase( componentPath, migrationsDir & "/", "" );
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

    function logMigration( direction, componentPath ) {
        var componentName = replaceNoCase( componentPath, migrationsDir & "/", "" );
        if ( direction == "up" ) {
            queryExecute(
                "INSERT INTO cbmigrations VALUES ( :name, :time )",
                { name = componentName, time = { value = now(), cfsqltype = "CF_SQL_TIMESTAMP" } }
            );
            flash
        } else {
            queryExecute(
                "DELETE FROM cbmigrations WHERE name = :name",
                { name = componentName }
            );
        }
    }
    function runAllMigrations( direction ) {
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

    function installMigrationTable() {
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
    }

    function isMigrationTableInstalled() {
        cfdbinfo( name="results" type="Tables" );
        
        var tableFound = false;
        for ( var row in results ) {
            if ( row.table_name == "cbmigrations" ) {
                tableFound = true;
                break;
            }
        }

        return tableFound;
    }

    function isMigrationRan( componentName ) {
        var results = queryExecute("
                SELECT 1
                FROM cbmigrations
                WHERE name = :name
            ",
            { name = componentName }
        );

        return results.RecordCount > 0;
    }

    private function getDateTimeColumnType() {
        cfdbinfo( name="results" type="Version" );

        switch( results.database_productName ){
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