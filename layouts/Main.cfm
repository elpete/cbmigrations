<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>cbmigrations</title>
    <meta name="description" content="cbmigrations dashboard">
    <meta name="author" content="Eric Peterson">
    <!---Base URL --->
    <base href="#event.getHTMLBaseURL()#" />
    <!---css --->
</head>
<body>
    <h1>cbmigrations</h1>

    <!---Container And Views --->
    <div class="container">#renderView()#</div>

</body>
</html>
</cfoutput>
