/**
 * Cupid Pokemon Handler
 */
component extends="coldbox.system.RestHandler" {

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only      = "";
	this.prehandler_except    = "";
	this.posthandler_only     = "";
	this.posthandler_except   = "";
	this.aroundHandler_only   = "";
	this.aroundHandler_except = "";

	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};

	/**
	 * Retrieve and store a Pokemon
	 *
	 * Maps to GET /api/pokemon/{pokemonID}
	 */
	function getAPokemon( event, rc, prc ) {

		include "/models/pokemon.cfm";

		event.getResponse().setData( response );
	}

}
