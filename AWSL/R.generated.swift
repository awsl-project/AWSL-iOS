//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.color` struct is generated, and contains static references to 1 colors.
  struct color {
    /// Color `AccentColor`.
    static let accentColor = Rswift.ColorResource(bundle: R.hostingBundle, name: "AccentColor")

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func accentColor(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.accentColor, compatibleWith: traitCollection)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func accentColor(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.accentColor.name)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 7 images.
  struct image {
    /// Image `clear`.
    static let clear = Rswift.ImageResource(bundle: R.hostingBundle, name: "clear")
    /// Image `license`.
    static let license = Rswift.ImageResource(bundle: R.hostingBundle, name: "license")
    /// Image `tag`.
    static let tag = Rswift.ImageResource(bundle: R.hostingBundle, name: "tag")
    /// Image `theme_automatic`.
    static let theme_automatic = Rswift.ImageResource(bundle: R.hostingBundle, name: "theme_automatic")
    /// Image `theme_dark`.
    static let theme_dark = Rswift.ImageResource(bundle: R.hostingBundle, name: "theme_dark")
    /// Image `theme_light`.
    static let theme_light = Rswift.ImageResource(bundle: R.hostingBundle, name: "theme_light")
    /// Image `weibo`.
    static let weibo = Rswift.ImageResource(bundle: R.hostingBundle, name: "weibo")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "clear", bundle: ..., traitCollection: ...)`
    static func clear(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.clear, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "license", bundle: ..., traitCollection: ...)`
    static func license(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.license, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "tag", bundle: ..., traitCollection: ...)`
    static func tag(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.tag, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "theme_automatic", bundle: ..., traitCollection: ...)`
    static func theme_automatic(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.theme_automatic, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "theme_dark", bundle: ..., traitCollection: ...)`
    static func theme_dark(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.theme_dark, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "theme_light", bundle: ..., traitCollection: ...)`
    static func theme_light(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.theme_light, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "weibo", bundle: ..., traitCollection: ...)`
    static func weibo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.weibo, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.info` struct is generated, and contains static references to 1 properties.
  struct info {
    struct uiApplicationSceneManifest {
      static let _key = "UIApplicationSceneManifest"
      static let uiApplicationSupportsMultipleScenes = false

      struct uiSceneConfigurations {
        static let _key = "UISceneConfigurations"

        struct uiWindowSceneSessionRoleApplication {
          struct defaultConfiguration {
            static let _key = "Default Configuration"
            static let uiSceneConfigurationName = infoPlistString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication", "Default Configuration"], key: "UISceneConfigurationName") ?? "Default Configuration"
            static let uiSceneDelegateClassName = infoPlistString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication", "Default Configuration"], key: "UISceneDelegateClassName") ?? "$(PRODUCT_MODULE_NAME).SceneDelegate"

            fileprivate init() {}
          }

          fileprivate init() {}
        }

        fileprivate init() {}
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  /// This `R.string` struct is generated, and contains static references to 2 localization tables.
  struct string {
    /// This `R.string.launchScreen` struct is generated, and contains static references to 0 localization keys.
    struct launchScreen {
      fileprivate init() {}
    }

    /// This `R.string.localizable` struct is generated, and contains static references to 26 localization keys.
    struct localizable {
      /// en translation: About
      ///
      /// Locales: zh-Hans, en
      static let about = Rswift.StringResource(key: "About", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Appearance
      ///
      /// Locales: zh-Hans, en
      static let appearance = Rswift.StringResource(key: "Appearance", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Automatic
      ///
      /// Locales: zh-Hans, en
      static let themeAutomatic = Rswift.StringResource(key: "ThemeAutomatic", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Back
      ///
      /// Locales: zh-Hans, en
      static let goBack = Rswift.StringResource(key: "GoBack", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Cancel
      ///
      /// Locales: zh-Hans, en
      static let cancel = Rswift.StringResource(key: "Cancel", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Changing view mode will take effect after restart
      ///
      /// Locales: zh-Hans, en
      static let changeViewModeTip = Rswift.StringResource(key: "ChangeViewModeTip", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Clear disk cache
      ///
      /// Locales: zh-Hans, en
      static let clearCache = Rswift.StringResource(key: "ClearCache", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Compact
      ///
      /// Locales: zh-Hans, en
      static let compactView = Rswift.StringResource(key: "CompactView", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Confirm
      ///
      /// Locales: zh-Hans, en
      static let confirm = Rswift.StringResource(key: "Confirm", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Contact us
      ///
      /// Locales: zh-Hans, en
      static let contactUs = Rswift.StringResource(key: "ContactUs", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Dark mode
      ///
      /// Locales: zh-Hans, en
      static let themeDark = Rswift.StringResource(key: "ThemeDark", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Do you want to clear disk cache?
      ///
      /// Locales: zh-Hans, en
      static let clearCahceTitle = Rswift.StringResource(key: "ClearCahceTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: License
      ///
      /// Locales: zh-Hans, en
      static let openSourceLicense = Rswift.StringResource(key: "OpenSourceLicense", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Light mode
      ///
      /// Locales: zh-Hans, en
      static let themeLight = Rswift.StringResource(key: "ThemeLight", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Loose
      ///
      /// Locales: zh-Hans, en
      static let normalView = Rswift.StringResource(key: "NormalView", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Photos
      ///
      /// Locales: zh-Hans, en
      static let photoList = Rswift.StringResource(key: "PhotoList", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Please allow AWSL to visit your photo library.
      ///
      /// Locales: zh-Hans, en
      static let needPhotoPermission = Rswift.StringResource(key: "NeedPhotoPermission", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Request failed, please try later.
      ///
      /// Locales: zh-Hans, en
      static let networkError = Rswift.StringResource(key: "NetworkError", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Save failed
      ///
      /// Locales: zh-Hans, en
      static let saveFailed = Rswift.StringResource(key: "SaveFailed", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Save photo
      ///
      /// Locales: zh-Hans, en
      static let savePhoto = Rswift.StringResource(key: "SavePhoto", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Save succeeded
      ///
      /// Locales: zh-Hans, en
      static let saveSucceeded = Rswift.StringResource(key: "SaveSucceeded", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Settings
      ///
      /// Locales: zh-Hans, en
      static let settings = Rswift.StringResource(key: "Settings", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Unknown error
      ///
      /// Locales: zh-Hans, en
      static let unknownError = Rswift.StringResource(key: "UnknownError", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: Version
      ///
      /// Locales: zh-Hans, en
      static let version = Rswift.StringResource(key: "Version", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: View mode
      ///
      /// Locales: zh-Hans, en
      static let viewMode = Rswift.StringResource(key: "ViewMode", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)
      /// en translation: View original weibo
      ///
      /// Locales: zh-Hans, en
      static let showWeibo = Rswift.StringResource(key: "ShowWeibo", tableName: "Localizable", bundle: R.hostingBundle, locales: ["zh-Hans", "en"], comment: nil)

      /// en translation: About
      ///
      /// Locales: zh-Hans, en
      static func about(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("About", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "About"
        }

        return NSLocalizedString("About", bundle: bundle, comment: "")
      }

      /// en translation: Appearance
      ///
      /// Locales: zh-Hans, en
      static func appearance(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Appearance", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Appearance"
        }

        return NSLocalizedString("Appearance", bundle: bundle, comment: "")
      }

      /// en translation: Automatic
      ///
      /// Locales: zh-Hans, en
      static func themeAutomatic(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ThemeAutomatic", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ThemeAutomatic"
        }

        return NSLocalizedString("ThemeAutomatic", bundle: bundle, comment: "")
      }

      /// en translation: Back
      ///
      /// Locales: zh-Hans, en
      static func goBack(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("GoBack", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "GoBack"
        }

        return NSLocalizedString("GoBack", bundle: bundle, comment: "")
      }

      /// en translation: Cancel
      ///
      /// Locales: zh-Hans, en
      static func cancel(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Cancel", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Cancel"
        }

        return NSLocalizedString("Cancel", bundle: bundle, comment: "")
      }

      /// en translation: Changing view mode will take effect after restart
      ///
      /// Locales: zh-Hans, en
      static func changeViewModeTip(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ChangeViewModeTip", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ChangeViewModeTip"
        }

        return NSLocalizedString("ChangeViewModeTip", bundle: bundle, comment: "")
      }

      /// en translation: Clear disk cache
      ///
      /// Locales: zh-Hans, en
      static func clearCache(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ClearCache", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ClearCache"
        }

        return NSLocalizedString("ClearCache", bundle: bundle, comment: "")
      }

      /// en translation: Compact
      ///
      /// Locales: zh-Hans, en
      static func compactView(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("CompactView", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "CompactView"
        }

        return NSLocalizedString("CompactView", bundle: bundle, comment: "")
      }

      /// en translation: Confirm
      ///
      /// Locales: zh-Hans, en
      static func confirm(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Confirm", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Confirm"
        }

        return NSLocalizedString("Confirm", bundle: bundle, comment: "")
      }

      /// en translation: Contact us
      ///
      /// Locales: zh-Hans, en
      static func contactUs(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ContactUs", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ContactUs"
        }

        return NSLocalizedString("ContactUs", bundle: bundle, comment: "")
      }

      /// en translation: Dark mode
      ///
      /// Locales: zh-Hans, en
      static func themeDark(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ThemeDark", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ThemeDark"
        }

        return NSLocalizedString("ThemeDark", bundle: bundle, comment: "")
      }

      /// en translation: Do you want to clear disk cache?
      ///
      /// Locales: zh-Hans, en
      static func clearCahceTitle(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ClearCahceTitle", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ClearCahceTitle"
        }

        return NSLocalizedString("ClearCahceTitle", bundle: bundle, comment: "")
      }

      /// en translation: License
      ///
      /// Locales: zh-Hans, en
      static func openSourceLicense(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("OpenSourceLicense", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "OpenSourceLicense"
        }

        return NSLocalizedString("OpenSourceLicense", bundle: bundle, comment: "")
      }

      /// en translation: Light mode
      ///
      /// Locales: zh-Hans, en
      static func themeLight(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ThemeLight", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ThemeLight"
        }

        return NSLocalizedString("ThemeLight", bundle: bundle, comment: "")
      }

      /// en translation: Loose
      ///
      /// Locales: zh-Hans, en
      static func normalView(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("NormalView", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "NormalView"
        }

        return NSLocalizedString("NormalView", bundle: bundle, comment: "")
      }

      /// en translation: Photos
      ///
      /// Locales: zh-Hans, en
      static func photoList(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("PhotoList", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "PhotoList"
        }

        return NSLocalizedString("PhotoList", bundle: bundle, comment: "")
      }

      /// en translation: Please allow AWSL to visit your photo library.
      ///
      /// Locales: zh-Hans, en
      static func needPhotoPermission(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("NeedPhotoPermission", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "NeedPhotoPermission"
        }

        return NSLocalizedString("NeedPhotoPermission", bundle: bundle, comment: "")
      }

      /// en translation: Request failed, please try later.
      ///
      /// Locales: zh-Hans, en
      static func networkError(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("NetworkError", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "NetworkError"
        }

        return NSLocalizedString("NetworkError", bundle: bundle, comment: "")
      }

      /// en translation: Save failed
      ///
      /// Locales: zh-Hans, en
      static func saveFailed(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("SaveFailed", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "SaveFailed"
        }

        return NSLocalizedString("SaveFailed", bundle: bundle, comment: "")
      }

      /// en translation: Save photo
      ///
      /// Locales: zh-Hans, en
      static func savePhoto(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("SavePhoto", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "SavePhoto"
        }

        return NSLocalizedString("SavePhoto", bundle: bundle, comment: "")
      }

      /// en translation: Save succeeded
      ///
      /// Locales: zh-Hans, en
      static func saveSucceeded(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("SaveSucceeded", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "SaveSucceeded"
        }

        return NSLocalizedString("SaveSucceeded", bundle: bundle, comment: "")
      }

      /// en translation: Settings
      ///
      /// Locales: zh-Hans, en
      static func settings(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Settings", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Settings"
        }

        return NSLocalizedString("Settings", bundle: bundle, comment: "")
      }

      /// en translation: Unknown error
      ///
      /// Locales: zh-Hans, en
      static func unknownError(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("UnknownError", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "UnknownError"
        }

        return NSLocalizedString("UnknownError", bundle: bundle, comment: "")
      }

      /// en translation: Version
      ///
      /// Locales: zh-Hans, en
      static func version(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Version", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Version"
        }

        return NSLocalizedString("Version", bundle: bundle, comment: "")
      }

      /// en translation: View mode
      ///
      /// Locales: zh-Hans, en
      static func viewMode(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ViewMode", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ViewMode"
        }

        return NSLocalizedString("ViewMode", bundle: bundle, comment: "")
      }

      /// en translation: View original weibo
      ///
      /// Locales: zh-Hans, en
      static func showWeibo(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("ShowWeibo", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "ShowWeibo"
        }

        return NSLocalizedString("ShowWeibo", bundle: bundle, comment: "")
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController

      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
