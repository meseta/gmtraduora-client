// Create traduora
traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "<project id>");

// Authenticate and then backup, and then get the English locale
traduora.authenticate("<client id>", "<client secret>")
	.chain_callback(function() {
		return traduora.backup();
	})
	.chain_callback(function() {
		return traduora.get_locale("en");	
	})
	.chain_callback(function(_payload) {
		show_debug_message(_payload);
	})
	

// Authenticate, and then get a bunch of locales in parallel
traduora.authenticate("<client id>", "<client secret>")
	.chain_callback(function() {
		return Chain.concurrent_struct({
			en: traduora.get_locale("en"),
			fr: traduora.get_locale("fr"),
		})	
	})
	.chain_callback(function(_results) {
		show_debug_message(_results.en);
		show_debug_message(_results.fr);
	})
