#!/usr/bin/env node
'use strict'

var connect;
var APP_ID   = process.env.PARSE_APP_ID || null;
var REST_KEY = process.env.PARSE_REST_KEY || null; 

if (APP_ID  === null || REST_KEY === null) {
	console.info( "\u001b[36mTip: set' or 'export' PARSE_APP_ID and PARSE_REST_KEY env vars to your shell to automatically set them for the demo App\u001b[0m" );
}

console.warn("\u001b[31mStarting sParse Demo.\nThis service should never, ever be exposed to the wild\u001b[0m");

(connect = require('connect'))(
).use(
	function(req, res, next) { 
		if (APP_ID !== null && REST_KEY !== null)
		{
			res.setHeader( "X-PARSE-APP-ID",   APP_ID );
			res.setHeader( "X-PARSE-REST-KEY", REST_KEY );
		}

		next()
	}
).use( connect.logger( 'dev' )
).use( connect.static( 'demo' )
).use( connect.favicon()
).listen( 3000, function() { console.log("\u001b[32msParse Demo now available at: \u001b[36mhttp://0.0.0.0:3000\u001b[0m"); } );