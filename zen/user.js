// Zen preferences applied at every startup (overrides values changed in the UI).
// Only deliberate choices belong here; runtime state stays in prefs.js.

// Interface
user_pref("zen.view.compact.enable-at-startup", true);
user_pref("sidebar.visibility", "hide-launcher");
user_pref("browser.theme.toolbar-theme", 0);

// Language
user_pref("intl.locale.requested", "fr,en-US");
user_pref("browser.translations.neverTranslateLanguages", "fr,en");

// Passwords are handled by an external password manager.
user_pref("signon.rememberSignons", false);

// PDF viewer
user_pref("pdfjs.enableAltText", false);
