component {

    this.name = "cbmigrations";
    this.author = "Eric Peterson";
    this.description = "Keep track of database migrations using ColdBox";
    this.version = "1.0.0";
    this.cfmapping = "cbmigrations";
    this.entryPoint = "/cbmigrations";

    function configure() {
        settings = {
            migrationsDirectory = "/resources/database/migrations"
        };

        routes = [
            { module = "cbmigrations", pattern = "/", handler = "main", action = "index" },
            { module = "cbmigrations", pattern = "/install", handler = "main", action = { POST = "install" } },
            { module = "cbmigrations", pattern = "/up", handler = "main", action = { POST = "migrate" }, direction = "up" },
            { module = "cbmigrations", pattern = "/down", handler = "main", action = { POST = "migrate" }, direction = "down" },
            { module = "cbmigrations", pattern = "/refresh", handler = "main", action = { POST = "refresh" } }
        ];
    }

}