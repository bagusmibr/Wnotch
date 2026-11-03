#!/usr/bin/env bash
# Typecheck the Wnotch module with only Command Line Tools (no Xcode).
# Sparkle/Lottie are SPM deps unavailable here, so their two wrapper files are swapped for stubs.
set -euo pipefail
cd "$(dirname "$0")/../Wnotch"
STUBS="$(mktemp -t wnotch-stubs).swift"
cat > "$STUBS" <<'EOF'
import SwiftUI
import Combine
final class SparkleUpdater: ObservableObject {
    static let shared = SparkleUpdater()
    @Published var canCheckForUpdates = false
    @Published var automaticallyChecksForUpdates = false
    @Published var automaticallyDownloadsUpdates = false
    @Published var isUpdateAvailable = false
    @Published var latestVersionString = ""
    func checkForUpdates() {}
}
struct AnimateImage: View { let name: String; var body: some View { EmptyView() } }
EOF
find . -name '*.swift' ! -name SparkleUpdater.swift ! -name AnimateImage.swift -print0 |
  xargs -0 xcrun swiftc -typecheck -module-name Wnotch -target arm64-apple-macos14.0 \
    -swift-version 5 -default-isolation MainActor -enable-upcoming-feature MemberImportVisibility \
    -F Resources/MediaRemoteAdapter "$STUBS" 2>&1 | grep -E ' error: ' || { echo "typecheck OK"; exit 0; }
exit 1
