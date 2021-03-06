component {

    this.name = "cbmigrations";
    this.author = "Eric Peterson";
    this.description = "Keep track of database migrations using ColdBox";
    this.version = "1.0.0";
    this.cfmapping = "cbmigrations";
    this.entryPoint = "/cbmigrations";

    function configure() {
        settings = {
            migrationsDir = "/resources/database/migrations"
        };

        routes = [
            { module = "cbmigrations", pattern = "/install", handler = "main", action = { POST = "install" } },
            { module = "cbmigrations", pattern = "/uninstall", handler = "main", action = { POST = "uninstall" } },
            { module = "cbmigrations", pattern = "/up", handler = "main", action = { POST = "migrate" }, direction = "up" },
            { module = "cbmigrations", pattern = "/nextUp", handler = "main", action = { POST = "migrate" }, direction = "up", next = true },
            { module = "cbmigrations", pattern = "/down", handler = "main", action = { POST = "migrate" }, direction = "down" },
            { module = "cbmigrations", pattern = "/nextDown", handler = "main", action = { POST = "migrate" }, direction = "down", next = true },
            { module = "cbmigrations", pattern = "/refresh", handler = "main", action = { POST = "refresh" } },
            { module = "cbmigrations", pattern = "/", handler = "main", action = "index" }
        ];
    }

}