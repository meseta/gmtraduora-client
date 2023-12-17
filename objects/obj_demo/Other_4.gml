// Create traduora
//traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "<project id>");

//// Authenticate and then backup, and then get the English locale
//traduora.authenticate("<client id>", "<client secret>")
//	.chain_callback(function() {
//		return traduora.backup();
//	})
//	.chain_callback(function() {
//		return traduora.get_locale("en");	
//	})
//	.chain_callback(function(_payload) {
//		show_debug_message(_payload);
//	})
	

//// Authenticate, and then get a bunch of locales in parallel
//traduora.authenticate("<client id>", "<client secret>")
//	.chain_callback(function() {
//		return Chain.concurrent_struct({
//			en: traduora.get_locale("en"),
//			fr: traduora.get_locale("fr"),
//		})	
//	})
//	.chain_callback(function(_results) {
//		show_debug_message(_results.en);
//		show_debug_message(_results.fr);
//	})

traduora = new TraduoraClient("https://traduora-demo.meseta.dev", "9269f1a9-4dc4-4322-9116-dfda16a67991");

//// Authenticate and then backup, and then get the English locale
//traduora.authenticate("5db748b3-a976-4c4e-aa59-a3119485ce61", "K7vAocdrRKd847P1lI9iodIpKPUXbAdP")
//	.chain_callback(function() {
//		return traduora.get_locale("en");	
//	})
	
traduora.get_locale_cached("en");