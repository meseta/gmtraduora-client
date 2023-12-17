/** A client for Traduora
 * @param {String} _server_url The URL for the traduora server
 * @param {String} _project_id The project ID to use
 * @param {Struct.Logger*} _parent_logger A parent logger to use
 * @author Meseta https://meseta.dev
 */
function TraduoraClient(_server_url, _project_id, _parent_logger=undefined) : HttpClient($"{_server_url}/api/v1", "Traduora", _parent_logger) constructor {
	/* @ignore */ self.__project_id = _project_id;

	/** Get a saved copy of the locale
	 * @param {String} _locale The Locale
	 * @return {Struct|undefined}
	 */
	static get_locale_cached = function(_locale, _callback) {
		var _filename = self.__make_filename(_locale);
		if (!file_exists(_filename)) {
			return undefined;
		}
		
		var _buff = buffer_load(_filename);
		var _json_str = buffer_read(_buff, buffer_text);
		buffer_delete(_buff);
		return json_parse(_json_str);
	};
	
	/** Get all the terms for a given language, and also saves it
	 * @param {String} _locale The Locale
	 * @return {Struct.Chain}
	 */
	static get_locale = function(_locale) {
		var _filename = self.__make_filename(_locale);
		return self.get($"/projects/{self.__project_id}/exports?format=jsonnested&locale={_locale}")
			.chain_callback(method({this: other, filename: _filename}, function(_payload) {
				this.logger.info("Got locale, saving", {filename: filename});
				var _json_str = json_stringify(_payload);
				var _buff = buffer_create(string_byte_length(_json_str), buffer_fixed, 1);
				buffer_write(_buff, buffer_text, _json_str);
				buffer_save(_buff, filename);
				buffer_delete(_buff);
				return _payload;
			}))
			.on_error(function(_err) {
				self.logger.warning("Could not get translation", {err: _err});	
			});
	};
	
	/** Get a list of locales available
	 * @return {Struct.Chain}
	 */
	static get_locales = function() {
		return self.get($"/projects/{self.__project_id}/translations")
			.chain_callback(function(_payload) {
				return array_map(_payload.data, function(_item) { return _item.locale.code; });
			})
			.on_error(function(_err) {
				self.logger.warning("Could not get locales list", {err: _err});	
			});
	};
	
	/** Authenticate with Traduora server
	 * @param {String} _client_id The client ID
	 * @param {String} _client_secret The client secret
	 * @return {Struct.Chain}
	 */
	static authenticate = function(_client_id, _client_secret) {
		return self.post("/auth/token", {
			  grant_type: "client_credentials",
			  client_id: _client_id,
			  client_secret: _client_secret,
			})
			.chain_callback(function(_payload) {
				self.logger.debug("Authenticated", {bearer: _payload.access_token});	
				self.add_header("Authorization", $"Bearer {_payload.access_token}");
			})
			.on_error(function(_err) {
				self.logger.warning("Could not authenticate", {err: _err});	
			});
	};
	
	/** Save all terms, this is used during development to back up all the terms
	 * @return {Struct.Chain}
	 */
	 static backup = function() {
		return self.get($"/projects/{self.__project_id}/terms")
			.chain_callback(function(_payload) {
				var _filename = "traduora.json";
				self.logger.info("Got terms, saving", {filename: _filename});
				var _json_str = json_stringify(_payload);
				var _buff = buffer_create(string_byte_length(_json_str), buffer_fixed, 1);
				buffer_write(_buff, buffer_text, _json_str);
				buffer_save(_buff, _filename);
				buffer_delete(_buff);
				return _payload;
			})
			.on_error(function(_err) {
				self.logger.warning("Could not back up", {err: _err});	
			});
	 };
	 	
	/** Make the filename for a locale
	 * @param {String} _locale The Locale
	 * @return {String}
	 * @ignore
	 */
	static __make_filename = function(_locale) {
		return $"traduora_{_locale}.json";
	}
}