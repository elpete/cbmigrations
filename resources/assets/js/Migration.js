import Vue from 'vue';

export default Vue.component( "Migration", {

    props: [ "item", "baseUrl" ],

    template: `
        <tr>
            <td>{{ item.componentname }}</td>
            <td>
                <span v-if="item.migrated">{{ item.migrateddate }}</span>
                <span v-else>No</span>
            </td>
            <td>
                <button
                    @click.prevent="migrate('up')"
                    :disabled="inactive"
                >
                    Up
                </button>
            </td>
            <td>
                <button
                    @click.prevent="migrate('down')"
                    :disabled="~inactive"
                >
                    Down
                </button>
            </td>
        </tr>
    `,

    methods: {
        migrate( direction ) {
            this.$http.post( `${this.baseUrl}cbmigrations/${direction}`, {
                componentPath: this.item.componentpath
            } ).then( function( response ) {
                console.log( "success", response );
            }, function( err ) {
                console.error( "error", err );
            } );
        }
    }

} );