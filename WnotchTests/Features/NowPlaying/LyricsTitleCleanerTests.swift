import XCTest
@testable import Wnotch

final class LyricsTitleCleanerTests: XCTestCase {
    func testStripsSpotifySuffixes() {
        let cases: [(String, String)] = [
            ("The Hanging Tree - From \"The Hunger Games: Mockingjay\" Soundtrack", "The Hanging Tree"),
            ("Bohemian Rhapsody - Remastered 2011", "Bohemian Rhapsody"),
            ("Stay (with Justin Bieber)", "Stay"),
            ("Peaches (feat. Daniel Caesar & Giveon)", "Peaches"),
            ("Don't Stop Me Now - Live at Wembley", "Don't Stop Me Now"),
        ]
        for (input, expected) in cases {
            XCTAssertEqual(LyricsTitleCleaner.cleanedTitle(input), expected, input)
        }
    }

    func testKeepsTitlesWithoutSuffix() {
        for title in ["Mr. Brightside", "Re: Stacks", "Self-Control", "(I Can't Get No) Satisfaction"] {
            XCTAssertEqual(LyricsTitleCleaner.cleanedTitle(title), title)
        }
    }

    func testSearchPairsAreDeduplicated() {
        XCTAssertEqual(LyricsTitleCleaner.searchPairs(title: "Mr. Brightside", artist: "The Killers").count, 1)
        let pairs = LyricsTitleCleaner.searchPairs(title: "Stay (with Justin Bieber)", artist: "The Kid LAROI, Justin Bieber")
        XCTAssertEqual(pairs.last?.title, "Stay")
        XCTAssertEqual(pairs.last?.artist, "The Kid LAROI")
    }
}
