var elixir = require( "coldbox-elixir" );

elixir( function( mix ) {
    mix.browserify( "app.js" );
} );