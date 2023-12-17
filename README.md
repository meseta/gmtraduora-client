## What is it?
gmtraduora-client is a GameMaker client for [Traduora](https://traduora.co), an open source Translation Management System, which can be used to manage localization for your GameMaker game

## Features
Traduora uses the Chain library to provide chainable callbacks to requests. See below examples for usage

### Fetching a single translation
Traduora client needs to first be authenticated before any further requests can be made. It is possible to chain together multiple requests using the `chain_callback()` method provided by the Chain library

```gml
// Create traduora
traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "<project id>");

// Authenticate and then backup, and then get the English locale
traduora.authenticate("<client id>", "<client secret>")
	.chain_callback(function() {
		return traduora.get_locale("en");	
	})
	.chain_callback(function(_payload) {
		show_debug_message(_payload);
	})
```

In the above code, once the value is back, the `_payload`` will contain all the terms. It's the same format as if you had exported the terms for that locale, using the nested JSON option.

### Using the cache
Every time you do `get_locale()`, this library will save the json for you, so that next time it is available immediately. You can check for this using:

```gml
// Create traduora
traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "<project id>");

// Check for cached translation
var _translation = traduora.get_locale_cached("en");
if (!is_undefined(_translation)) {
  load_translation(_translation); // your function here
}

// Authenticate and then backup, and then get the English locale
traduora.authenticate("<client id>", "<client secret>")
	.chain_callback(function() {
		return traduora.get_locale("en");	
	})
	.chain_callback(function(_payload) {
    load_translation(_payload); // your function here
	});
```

In the above code, we first try and fetch the cached copy of the translation, and if it's available load it. Then we fetch the latest translation from Traduora, and load it again, just in case there was an update.

### Concurrency
The Chain library has some useful utilities to make multiple requests in parallel. This is useful for fetching multiple translations at once:

```gml
// Create traduora
traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "<project id>");

// Authenticate, and then get a bunch of locales in parallel
traduora.authenticate("<client id>", "<client secret>")
	.chain_callback(function() {
		return Chain.concurrent_struct({
			en: traduora.get_locale("en"),
			fr: traduora.get_locale("fr"),
			es: traduora.get_locale("es"),
			de: traduora.get_locale("de"),
		})	
	})
	.chain_callback(function(_results) {
		show_debug_message(_results.en);
		show_debug_message(_results.fr);
		show_debug_message(_results.es);
		show_debug_message(_results.de);
	})
```

The above will execute four language fetches in parallel, and the last callback will run once the values have returned.

### Get all the things
We can also query for all the available locales to populate a menu, or... just request all of them

```gml
// Create traduora
traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "<project id>");

// Authenticate, and then get a bunch of locales in parallel
traduora.authenticate("<client id>", "<client secret>")
  .chain_callback(function() {
		return traduora.get_locales();
	})
	.chain_callback(function(_locales) {
		return Chain.concurrent_struct(
			array_reduce(_locales, function(_struct, _locale) {
				_struct[$ _locale] = traduora.get_locale(_locale);
			}, {})
		)
	})
	.chain_callback(function(_results) {
		show_debug_message(_results);
	})
```

The above will fetch a list of locales, `_locales` will have a value like `["en", "es", "fr", "de"]` or whatever is available in the project. The next callback constructs a similar Chain concurrent struct as the previous section, but dynamically using this array. Once all the languages have been fetched, the result is debug logged.

### Backing up
Because Traduora doesn't provide an easy way to back up all the terms using the web UI, I've provided a function to run that'll save all the terms to a local file:

```gml
// Create traduora
traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "<project id>");

// Authenticate and then backup, and then get the English locale
traduora.authenticate("<client id>", "<client secret>")
	.chain_callback(function() {
		return traduora.backup();
	});
```

## Where to get it
Download the package from the following locations:
- https://github.com/meseta/gmtraduora-client/releases

You can import the package into your project from the GMS2 menu Tools > Import Local Package.

## Change log
- v0.9.0 Initial release