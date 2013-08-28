#!/usr/bin/env node
'use strict'

var connect;
var APP_ID;
var REST_KEY; 

if (!(APP_ID = process.env.PARSE_APP_ID) || !(REST_KEY = process.env.PARSE_REST_KEY)) {
	console.error( "\u001b[31mERROR: env vars PARSE_APP_ID or PARSE_REST_KEY not defined.\n'set' or 'export' these vars to your shell to use the demo\u001b[0m" );
	process.exit();
}

console.warn("\u001b[31mStarting sParse Demo Connect Server.\nThis should never, ever be exposed to the wild\u001b[0m");

(connect = require('connect'))(
).use(
	function(req, res, next) { 
		res.setHeader( "X-PARSE-APP-ID",   APP_ID );
		res.setHeader( "X-PARSE-REST-KEY", REST_KEY );
		next()
	}
).use( connect.logger( 'dev' )
).use( connect.static( 'demo' )
).use( connect.favicon()
).listen( 3000, function() { console.log("\u001b[32msParse Demo now available at: \u001b[36mhttp://0.0.0.0:3000\u001b[0m"); } );