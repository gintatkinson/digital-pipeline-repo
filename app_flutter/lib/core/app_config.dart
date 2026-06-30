/// Central holder for application-wide constants.
///
/// Every UI layer reads the app and window title from here so that a single
/// change propagates everywhere. Alternative: [StringResources] for
/// user-facing strings that need runtime override.
///
/// No file should hardcode its own copy of the application title.
class AppConfig {
  AppConfig._();
  static const String title = 'Platform Console';
  /// Single source of truth for the application display name.
  ///
  /// All UI code MUST read from this constant rather than hardcoding
  /// the display name. Update this one value to rebrand the application.
  /// Keep `assets/strings.json` sidebar.header value in sync.
  static const String appDisplayName = title;
  static const String windowTitle = 'Pipeline Console';
}
