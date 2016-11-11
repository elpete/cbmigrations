<cfoutput>
    <cfif NOT ArrayIsEmpty(flashMessages)>
        <div class="flash-messages">
            <cfloop array="#flashMessages#" index="flashMessage">
                <cfinclude template="#flashMessageTemplatePath#" runOnce="false" />
            </cfloop>
        </div>
    </cfif>
</cfoutput>