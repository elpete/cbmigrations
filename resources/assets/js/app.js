import Vue from "vue";

import VueResource from "vue-resource";
Vue.use( VueResource );

import Migration from "./Migration";

Vue.config.devtools = true;

new Vue( {

    el: "#cbmigrations-app-container",

    data: { baseUrl, migrations },

    methods: {
        shouldDisable( direction, migration ) {
            console.log(! migration.migrated);
            return ! migration.migrated;

            var migrated = migration.migrated;
            console.log( migration.componentname );
            console.log( "direction", direction );
            console.log( "migrated?", migrated );
            let prequisitesRan = true;
            for ( let i in this.migrations ) {
                let m = this.migrations[ i ];
                if ( m.componentname == migration.componentname ) {
                    break;
                }

                prequisitesRan = m.migrated;
            }
            console.log( "prerequisites ran", prequisitesRan );

            var ableToRun = direction === "up" ? !migration.migrated : migration.migrated;

            console.log( "able to run", ableToRun );

            return ! ableToRun || ! prequisitesRan;
        },

        install() {
            console.log( "install" );
        },

        migrate( direction, componentPath ) {
            this.$http.post( `${this.baseUrl}cbmigrations/${direction}`, { componentPath } )
                .then( function( response ) {
                    console.log( "success", response );
                }, function( err ) {
                    console.error( "error", err );
                } );
        }
    }

} );