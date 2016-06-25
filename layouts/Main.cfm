<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>cbmigrations — Dashboard Panel</title>
    <meta name="description" content="cbmigrations dashboard">
    <meta name="author" content="Eric Peterson">
    <!---Base URL --->
    <base href="#event.getHTMLBaseURL()#" />
    <!---css --->
    <link rel="stylesheet" type="text/css" href="#event.getModuleRoot()#/includes/css/cbmigrations.css" />
</head>
<body>
    <div id="cbmigrations-app-container">
        <h1>cbmigrations</h1>
        <h2>Dashboard Panel</h2>

        <hr />

        <div class="Container">#renderView()#</div>
    </div>

</body>
</html>
</cfoutput>
