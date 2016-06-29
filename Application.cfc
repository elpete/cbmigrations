component displayname="Application" {

    this.name = "cbmigrations" & "_tests_" & hash(getCurrentTemplatePath());
    this.sessionManagement  = true;
    this.sessionTimeout     = createTimeSpan( 0, 0, 15, 0 );
    this.applicationTimeout = createTimeSpan( 0, 0, 15, 0 );
    this.setClientCookies   = true;

    // Create testing mapping
    this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
    // Map back to its root
    rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
    this.mappings["/root"]   = rootPath;

}