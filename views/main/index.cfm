<cfoutput>
    <div id="cbmigrations-app-container">

        <cfif NOT arrayIsEmpty( prc.errors )>
            <div>
                <cfloop array="#prc.errors#" index="error">
                    <div class="cbmigrations_error">#error#</div>
                </cfloop>
            </div>
        </cfif>

        <cfif NOT arrayIsEmpty( prc.messages )>
            <div>
                <cfloop array="#prc.messages#" index="error">
                    <div class="cbmigrations_message">#error#</div>
                </cfloop>
            </div>
        </cfif>
        
        <h3>Migration Table Installed?</h3>
        <cfif prc.migrationTableInstalled EQ false>
            <form action="#event.buildLink( "cbmigrations.install" )#" method="POST">
                No. <button type="submit" class="cbmigration_button">Click here to install it.</button>
            </form>
        <cfelse>
            Installed and ready to go!
        </cfif>

        <h3>All Migrations</h3>
            <form action="#event.buildLink( "cbmigrations.up" )#" method="POST">
                <input type="hidden" name="all" value="true" />
                <button type="submit" class="cbmigration_button">
                    Run All Remaining
                </button>
            </form>
            <form action="#event.buildLink( "cbmigrations.down" )#" method="POST">
                <input type="hidden" name="all" value="true" />
                <button type="submit" class="cbmigration_button">
                    Rollback All
                </button>
            </form>
            <form action="#event.buildLink( "cbmigrations.refresh" )#" method="POST">
                <button type="submit" class="cbmigration_button">
                    Refresh All
                </button>
            </form>
        <table>
            <tr>
                <th>Migration</th>
                <th>Migrated?</th>
                <th colspan="2">Actions</th>
            </tr>
            <cfloop array="#prc.migrations#" index="migration">
                <tr>
                    <td>#migration.componentName#</td>
                    <td>#migration.migrated ? "Yes" : "No"#</td>
                    <td>
                        <form action="#event.buildLink( "cbmigrations.up" )#" method="POST">
                            <input type="hidden" name="componentPath" value="#migration.componentPath#" />
                            <button
                                type="submit"
                                class="cbmigration_button"
                                <cfif NOT migration.canMigrateUp>disabled</cfif>
                            >
                                Up
                            </button>
                        </form>
                    </td>
                    <td>
                        <form action="#event.buildLink( "cbmigrations.down" )#" method="POST">
                            <input type="hidden" name="componentPath" value="#migration.componentPath#" />
                            <button
                                type="submit"
                                class="cbmigration_button"
                                <cfif NOT migration.canMigrateDown>disabled</cfif>
                            >
                                Down
                            </button>
                        </form>
                    </td>
                </tr>
            </cfloop>
        </table>
    </div>
</cfoutput>
