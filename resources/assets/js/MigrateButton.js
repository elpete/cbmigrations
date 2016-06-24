import Vue from 'vue';

export default Vue.component( "MigrateButton", {

    props: [
        "direction",
        "base-url",
        "component-path",
        "inactive"
    ],
    
    template: `
        <button
            @click="migrate"
            :disabled="inactive"
        >
            <slot />
        </button>
    `,

    methods: {
        migrate() {
            this.$http.post( `${this.baseUrl}cbmigrations/${this.direction}`, {
                componentPath: this.componentPath
            } ).then( function( response ) {
                console.log( "success", response );
            }, function( err ) {
                console.error( "error", err );
            } );
        }
    }
} );