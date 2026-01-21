user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);                     // enable userChrome.css
user_pref("devtools.chrome.enabled", true);                                                 // enable browser console
user_pref("devtools.debugger.remote-enabled", true);                                        // allow remote control
user_pref("extension.pocket.enabled", false);                                               // disable Pocket
user_pref("extensions.webextensions.addons-restricted-domains@mozilla.com.disabled", true); // allow addons to run in restricted domains
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);                                  // use xdg-desktop-portal-termfilechooser
user_pref("browser.sessionstore.max_windows_undo", 15);                                     // how many closed windows to remember

// dark mode for pdf.js
user_pref("pdfjs.forcePageColors", true);
user_pref("pdfjs.pageColorsBackground", "#1f1f28");
user_pref("pdfjs.pageColorsForeground", "#b8b4d0");
