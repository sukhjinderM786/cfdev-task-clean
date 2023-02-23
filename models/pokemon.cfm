<cfparam name="pokemonId" default="1">

<CFHTTP url="https://pokeapi.co/api/v2/pokemon/#rc.pokemonId#" method="GET" result="result">

<cfset jsonResult = DESERIALIZEJSON(result.filecontent)>

<cfset thingsweneed = StructNew()>
<cfset thingsweneed.id = jsonResult.id>
<cfset thingsweneed.height = jsonResult.height>
<cfset thingsweneed.species = jsonResult.species.name>
<cfset thingsweneed.url = jsonResult.species.url>

<CFIF ArrayIsEmpty(jsonResult.held_items)>
	<cfset thingsweneed.items = "">
<CFELSE>
	<CFSET thingsweneed.items = ArrayNew(1)>
	<CFLOOP FROM="1" TO="#ArrayLen(jsonResult.held_items)#" INDEX="i">
		<cfset thingsweneed.items[i].name = jsonResult.held_items[i].item.name>
		<cfset thingsweneed.items[i].url = jsonResult.held_items[i].item.url>
	</CFLOOP>
</CFIF>

<CFQUERY NAME="insertpokemon" datasource="pokemon">
INSERT INTO CUPIDMEDIA_POKEMON.POKEMON (ID, SPECIES, URL, HEIGHT)
VALUES (#thingsweneed.id#, '#thingsweneed.species#', '#thingsweneed.url#', #thingsweneed.height#)
</CFQUERY>

<CFLOOP FROM="1" TO="#ArrayLen(thingsweneed.items)#" INDEX="j">
	<CFQUERY NAME="insertitem" datasource="pokemon">
		INSERT INTO CUPIDMEDIA_POKEMON.ITEM (POKEMONID, NAME, URL)
		VALUES (#thingsweneed.id#, '#thingsweneed.items[j].name#', '#thingsweneed.items[j].url#')
	</CFQUERY>
</CFLOOP>

<cfset response = "I've downloaded and stored data for Pokemon with id: #rc.pokemonId#">
