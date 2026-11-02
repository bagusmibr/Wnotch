import XCTest
import AppKit
@testable import Wnotch

final class LocalizationCatalogTests: XCTestCase {
    private static let translatableLanguages = WnotchLanguage.allCases.filter { $0 != .system }

    /// Keys whose value is meaningfully different in every shipped language.
    private static let representativeKeys = [
        "menuBar.settings",
        "common.cancel",
        "settings.section.battery.title",
        "settings.section.lockScreen.title",
        "settings.system.launchAtLogin.title",
        "settings.permissions.status.needsAccess"
    ]

    /// Every key in the catalog that carries printf-style arguments.
    private static let formattedKeys = [
        "menuBar.version",
        "settings.reset.title",
        "settings.screenRecording.desktopFormat",
        "settings.search.empty.subtitle",
        "settings.notch.priorities.row.default",
        "settings.lockScreen.customSound.unavailableFallback"
    ]

    func testEveryLanguageShipsAnLprojDirectory() {
        for language in Self.translatableLanguages {
            let hasBundle = language.bundleLanguageCandidates.contains { candidate in
                Bundle.main.path(forResource: candidate, ofType: "lproj") != nil
            }

            XCTAssertTrue(hasBundle, "No .lproj directory is bundled for \(language.rawValue)")
        }
    }

    func testEveryLanguageTranslatesRepresentativeKeys() {
        for language in Self.translatableLanguages {
            for key in Self.representativeKeys {
                let value = L10n.string(key, language: language)

                XCTAssertNotEqual(value, key, "\(key) is unresolved in \(language.rawValue)")
                XCTAssertFalse(
                    value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "\(key) is empty in \(language.rawValue)"
                )
            }
        }
    }

    func testTranslationsPreserveFormatSpecifiers() throws {
        for key in Self.formattedKeys {
            let english = try formatSpecifiers(in: L10n.string(key, language: .english))
            XCTAssertFalse(english.isEmpty, "\(key) was expected to carry format specifiers")

            for language in Self.translatableLanguages where language != .english {
                let translated = try formatSpecifiers(in: L10n.string(key, language: language))

                XCTAssertEqual(
                    translated,
                    english,
                    "\(key) has mismatched format specifiers in \(language.rawValue)"
                )
            }
        }
    }

    func testEveryLanguageProvidesPresentationMetadata() {
        for language in WnotchLanguage.allCases {
            XCTAssertFalse(language.titleKeyString.isEmpty, "\(language.rawValue) has no title key")
            XCTAssertFalse(language.nativeDisplayName.isEmpty, "\(language.rawValue) has no native name")
            XCTAssertFalse(language.fallbackDisplayName.isEmpty, "\(language.rawValue) has no fallback name")
            XCTAssertEqual(language.accentColors.count, 2, "\(language.rawValue) needs two accent colors")

            guard let assetName = language.flagAssetName else {
                XCTAssertEqual(language, .system, "Only the system entry may omit a flag asset")
                continue
            }

            XCTAssertFalse(assetName.isEmpty, "\(language.rawValue) has empty flag asset name")
        }
    }

    func testResolvedFallsBackToSystemForUnknownValues() {
        XCTAssertEqual(WnotchLanguage.resolved(nil), .system)
        XCTAssertEqual(WnotchLanguage.resolved("klingon"), .system)
        XCTAssertEqual(WnotchLanguage.resolved("tr"), .turkish)
        XCTAssertEqual(WnotchLanguage.resolved("de"), .german)
        XCTAssertEqual(WnotchLanguage.resolved("fr"), .french)
        XCTAssertEqual(WnotchLanguage.resolved("pt"), .portuguese)
        XCTAssertEqual(WnotchLanguage.resolved("ja"), .japanese)
        XCTAssertEqual(WnotchLanguage.resolved("ko"), .korean)
        XCTAssertEqual(WnotchLanguage.resolved("it"), .italian)
        XCTAssertEqual(WnotchLanguage.resolved("pl"), .polish)
        XCTAssertEqual(WnotchLanguage.resolved("vi"), .vietnamese)
        XCTAssertEqual(WnotchLanguage.resolved("id"), .indonesian)
        XCTAssertEqual(WnotchLanguage.resolved("nl"), .dutch)
        XCTAssertEqual(WnotchLanguage.resolved("zh-Hant"), .traditionalChinese)
        XCTAssertEqual(WnotchLanguage.resolved("uk"), .ukrainian)
        XCTAssertEqual(WnotchLanguage.resolved("sv"), .swedish)
        XCTAssertEqual(WnotchLanguage.resolved("cs"), .czech)
        XCTAssertEqual(WnotchLanguage.resolved("ar"), .arabic)
        XCTAssertEqual(WnotchLanguage.resolved("hi"), .hindi)
        XCTAssertEqual(WnotchLanguage.resolved("th"), .thai)
        XCTAssertEqual(WnotchLanguage.resolved("ro"), .romanian)
        XCTAssertEqual(WnotchLanguage.resolved("hu"), .hungarian)
        XCTAssertEqual(WnotchLanguage.resolved("el"), .greek)
        XCTAssertEqual(WnotchLanguage.resolved("da"), .danish)
        XCTAssertEqual(WnotchLanguage.resolved("fi"), .finnish)
        XCTAssertEqual(WnotchLanguage.resolved("nb"), .norwegian)
        XCTAssertEqual(WnotchLanguage.resolved("ms"), .malay)
        XCTAssertEqual(WnotchLanguage.resolved("he"), .hebrew)
        XCTAssertEqual(WnotchLanguage.resolved("bg"), .bulgarian)
        XCTAssertEqual(WnotchLanguage.resolved("ca"), .catalan)
        XCTAssertEqual(WnotchLanguage.resolved("sk"), .slovak)
        XCTAssertEqual(WnotchLanguage.resolved("hr"), .croatian)
        XCTAssertEqual(WnotchLanguage.resolved("sr"), .serbian)
        XCTAssertEqual(WnotchLanguage.resolved("fil"), .filipino)
        XCTAssertEqual(WnotchLanguage.resolved("kk"), .kazakh)
        XCTAssertEqual(WnotchLanguage.resolved("fa"), .persian)
        XCTAssertEqual(WnotchLanguage.resolved("bn"), .bengali)
    }
}

private extension LocalizationCatalogTests {
    /// Returns the ordered argument positions and conversion characters of a format string,
    /// so a translation can be compared against its source regardless of word order.
    func formatSpecifiers(in value: String) throws -> [String] {
        let pattern = "%(?:(\\d+)\\$)?[-+ #0]*[0-9]*(?:\\.[0-9]+)?(?:hh|h|ll|l|L|z|j|t|q)?([@diouxXeEfgGaAcsp%])"
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(value.startIndex..., in: value)

        let specifiers = regex.matches(in: value, range: range).enumerated().compactMap { index, match -> String? in
            guard let conversion = Range(match.range(at: 2), in: value) else { return nil }

            let position: Int
            if let explicit = Range(match.range(at: 1), in: value), let parsed = Int(value[explicit]) {
                position = parsed
            } else {
                position = index + 1
            }

            return "\(position)\(value[conversion])"
        }

        return specifiers.sorted()
        XCTAssertEqual(WnotchLanguage.resolved("he"), .hebrew)
        XCTAssertEqual(WnotchLanguage.resolved("bg"), .bulgarian)
        XCTAssertEqual(WnotchLanguage.resolved("ca"), .catalan)
        XCTAssertEqual(WnotchLanguage.resolved("sk"), .slovak)
        XCTAssertEqual(WnotchLanguage.resolved("hr"), .croatian)
        XCTAssertEqual(WnotchLanguage.resolved("sr"), .serbian)
        XCTAssertEqual(WnotchLanguage.resolved("fil"), .filipino)
        XCTAssertEqual(WnotchLanguage.resolved("kk"), .kazakh)
        XCTAssertEqual(WnotchLanguage.resolved("fa"), .persian)
        XCTAssertEqual(WnotchLanguage.resolved("bn"), .bengali)
    }
}

