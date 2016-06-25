<cfoutput>
    <h3>Migration Table Installed?</h3>
    <cfif NOT prc.migrationTableInstalled>
        <p>No.</p>
        <form action="#event.buildLink( "cbmigrations.install" )#" method="POST">
            <button type="submit" class="Button">Install Migrations Table</button>
        </form>
        <br />
        <form action="#event.buildLink( "cbmigrations.install" )#" method="POST">
            <input type="hidden" name="runAll" value="true" />
            <button type="submit" class="Button Button--up">Install and Run All Migrations</button>
        </form>
    <cfelse>
        <p>Installed and ready to go!</p>
        <form action="#event.buildLink( "cbmigrations.uninstall" )#" method="POST">
            <button type="submit" class="Button Button--down">
                Rollback All and Uninstall Migrations Table
            </button>
        </form>
    </cfif>

    <h3>All Migrations</h3>

    <div class="ButtonGroup">
        <form action="#event.buildLink( "cbmigrations.up" )#" method="POST">
            <input type="hidden" name="all" value="true" />
            <button
                type="submit"
                class="Button Button--up"
                <cfif NOT prc.migrationTableInstalled>disabled</cfif>
            >
                Run All Remaining
            </button>
        </form>
        <form action="#event.buildLink( "cbmigrations.down" )#" method="POST">
            <input type="hidden" name="all" value="true" />
            <button
                type="submit"
                class="Button Button--down"
                <cfif NOT prc.migrationTableInstalled>disabled</cfif>
            >
                Rollback All
            </button>
        </form>
        <form action="#event.buildLink( "cbmigrations.refresh" )#" method="POST">
            <button
                type="submit"
                class="Button"
                <cfif NOT prc.migrationTableInstalled>disabled</cfif>
            >
                Refresh All
            </button>
        </form>
    </div>
    <table class="Table">
        <tr>
            <th>Migration</th>
            <th>Migrated?</th>
            <th colspan="2">Actions</th>
        </tr>
        <cfloop array="#prc.migrations#" index="migration">
            <tr>
                <td>#migration.componentName#</td>
                <td class="Table__Cell--center">#migration.migrated ? "Yes" : "No"#</td>
                <td>
                    <form action="#event.buildLink( "cbmigrations.up" )#" method="POST">
                        <input type="hidden" name="componentPath" value="#migration.componentPath#" />
                        <button
                            type="submit"
                            class="Button Button--up Button--full-width"
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
                            class="Button Button--down Button--full-width"
                            <cfif NOT migration.canMigrateDown>disabled</cfif>
                        >
                            Down
                        </button>
                    </form>
                </td>
            </tr>
        </cfloop>
    </table>
</cfoutput>
