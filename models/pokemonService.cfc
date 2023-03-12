component output="false" displayname="pokemonService" accessors="true" {

	//param name="pokemonId" default="1";

	/**
		 * Pokemon access details 
	*/
	variables.requestURL = 'https://pokeapi.co/api/v2/pokemon/';
	variables.httpMethod = 'GET';
	
	/***************************************************************************************
	************************************* API Methods **************************************
	***************************************************************************************/

	function init(){
		
		return this;
	}

	struct function httpRequest(
		numeric pokemonId = 1
	) {
		// Do HTTP request and handle return of struct

		local = {};
		local.returnResponse = "I've downloaded and stored data for Pokemon with id: #arguments.pokemonId#";
		local.httpMethod = variables.httpMethod;
		local.requestURL = variables.requestURL;
		
		local.cfhttpResponse = "";
		local.excepresponse = "";
		local.jsonResult = "";
		local.icntr = 0;


		try {

			cfhttp(method="#local.httpMethod#", url="#local.requestURL##pokemonId#", result="local.cfhttpResponse") {
			}


			/* Check if there is an API Error call */

	      	if(local.cfhttpResponse.ResponseHeader.status_code eq 200) {

	      		transaction action="begin" {
	  			
	  				try {
						
						local.jsonResult = DESERIALIZEJSON(local.cfhttpResponse.filecontent);

						if(ArrayIsEmpty(local.jsonResult.held_items)) {

							local.jsonResult.items = "";
						
						} else {
						
							local.jsonResult.items = arrayNew(1);
							for(local.icntr=1;local.icntr<=ArrayLen(local.jsonResult.held_items);local.icntr++) {
								local.jsonResult.items[local.icntr].name = local.jsonResult.held_items[local.icntr].item.name;
								local.jsonResult.items[local.icntr].url = local.jsonResult.held_items[local.icntr].item.url;
							}
						}

						/* Check if the PokeMon ID exists */
						local.sql.setsql = 'SELECT ID FROM POKEMON WHERE ID = :id';
						local.sql.options = { datasource: "pokemondns", result: "local.sql.dataResult" };

						local.sql.param = {};
						local.sql.param[ "ID" ] = { value: local.jsonResult.id, sqltype: "integer" };
			  			local.sql.param[ "SPECIES" ] = { value: local.jsonResult.species.name, sqltype: "varchar" };
			  			local.sql.param[ "URL" ] = { value: local.jsonResult.species.url, sqltype: "varchar" };
			  			local.sql.param[ "HEIGHT" ] = { value: local.jsonResult.height, sqltype: "varchar" };

			  			local.sql.result = queryExecute( local.sql.setsql, local.sql.param, local.sql.options );

			  			/* if the PokeMon ID doen't exists */
			  			if(local.sql.result.recordcount eq 0) {

							local.sql.setsql = 'INSERT INTO POKEMON (ID, SPECIES, URL, HEIGHT) values (:id, :species, :url, :height)';


				  		} else {

				  			local.sql.setsql = 'UPDATE POKEMON SET SPECIES = :species, URL = :url, HEIGHT = :height WHERE ID =:id';

				  		}

			  			local.sql.result = queryExecute( local.sql.setsql, local.sql.param, local.sql.options );
			  			

			  			if(ArrayLen(local.jsonResult.held_items)) {
			  				
			  				
			  				local.sql.options = { datasource: "pokemon", result: "local.sql.insertItem" };
			  				local.sql.params = {};
							local.sql.values = [];

				  			for(local.icntr=1;local.icntr<=ArrayLen(local.jsonResult.items);local.icntr++) {
				  				
				  				local.sql.param = {};
			  					local.sql.param[ "POKEMONID" ] = { value: local.jsonResult.id, sqltype: "integer" };
			  					local.sql.param[ "NAME" ] = { value: local.jsonResult.items[local.icntr].name, sqltype: "varchar" };
			  					local.sql.param[ "URL" ] = { value: local.jsonResult.items[local.icntr].url, sqltype: "varchar" };

			  					local.sql.params.Append( local.sql.param );
			  					local.sql.values.Append( "( #local.jsonResult.id#, '#local.jsonResult.items[local.icntr].name#', '#local.jsonResult.items[local.icntr].url#' )" );

			  					//local.sql.result = queryExecute( local.sql.setsql, local.sql.param, local.sql.options );
							}

							local.sql.setsql = 'INSERT INTO CUPIDMEDIA_POKEMON.ITEM (POKEMONID, [NAME], URL) values #local.sql.values.ToList()#;';

							local.sql.result = queryExecute( local.sql.setsql, local.sql.params, local.sql.options );
							
						}

					}
					catch (any excp) {
				    	transactionRollback();
				    	
				    	cfsavecontent( variable="local.excepresponse" ) {
							WriteDump(var=#excp#);
						}
				    	
				  	}

				}
			}

      	}

		catch(any excp) {
			
			cfsavecontent( variable="local.excepresponse" ) {
				WriteDump(var=#excp#);
			}
			
      	}

		return local;

    }

}