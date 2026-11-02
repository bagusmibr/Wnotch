//
//  AboutApp.swift
//  Wnotch
//
//  Created by M on 3/6/26.
//

import SwiftUI

struct AboutAppSettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var applicationSettings: ApplicationSettingsStore
    @ObservedObject private var updater = SparkleUpdater.shared
    
    let onRequestInternetAccess: () -> Bool
    
    private var currentVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "\(version)"
    }
    
    private var appVersionText: String {
        "v\(currentVersion)"
    }
    
    var body: some View {
        aboutTab
        .accessibilityIdentifier("settings.about.root")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Text(appVersionText)
                    .padding(.horizontal, 10)
            }
        }
    }
    
    private var aboutTab: some View {
        SettingsPageScrollView {
            headerCard
            softwareUpdateCard
            socialLinksCard
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: 16) {
            Image("logo")
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFill()
                .frame(width: 90, height: 90)
                .cornerRadius(20)
                .scaleEffect(0.9)
                .background(LinearGradient.logoGradient.blur(radius: 20))
                .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("Wnotch")
                    .font(.system(size: 20, weight: .bold))
                
                Text("settings.about.description")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
            }
        }
    }
    
    private var softwareUpdateCard: some View {
        SettingsCard {
            SettingsButtonRow(
                title: "settings.section.softwareUpdate.title",
                description: "Version \(currentVersion)",
                buttonTitle: "settings.update.checkNow",
                isButtonDisabled: !updater.canCheckForUpdates,
                accessibilityIdentifier: "settings.update.versionCard"
            ) {
                updater.checkForUpdates()
            }
            
            Divider()
                .opacity(0.6)
            
            SettingsToggleRow(
                title: "settings.update.autoCheck.title",
                description: "settings.update.autoCheck.desc",
                systemImage: "bell.badge.fill",
                color: .red,
                isOn: $updater.automaticallyChecksForUpdates,
                accessibilityIdentifier: "settings.update.automaticallyChecks"
            )
            
            Divider()
                .opacity(0.6)
                .padding(.leading, 43)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            SettingsToggleRow(
                title: "settings.update.autoDownload.title",
                description: "settings.update.autoDownload.desc",
                systemImage: "arrow.down.circle.dotted",
                color: .blue,
                isOn: $updater.automaticallyDownloadsUpdates,
                accessibilityIdentifier: "settings.update.automaticallyDownloads"
            )
            .disabled(!updater.automaticallyChecksForUpdates)
            .opacity(!updater.automaticallyChecksForUpdates ? 0.5 : 1)
        }
    }
    
    private var socialLinksCard: some View {
        SettingsCard(title: "settings.about.card.socialLinks", spacing: 0, padding: 0) {
            SettingsUrlRowView(
                title: "settings.about.website.title",
                description: "settings.about.website.desc",
                systemImage: "globe",
                color: .blue,
                position: .first,
                url: "https://portobagusmibr.vercel.app/",
                onRequestInternetAccess: onRequestInternetAccess
            )
            
            SettingsUrlRowView(
                title: "settings.about.instagram.title",
                description: "settings.about.instagram.desc",
                systemImage: "camera.fill",
                color: .pink,
                position: .last,
                url: "https://instagram.com/bagusmibr",
                onRequestInternetAccess: onRequestInternetAccess
            )
        }
    }
    
    private func open(_ value: String) {
        guard let url = URL(string: value) else { return }
        openInternetURL(url)
    }
    
    private func openInternetURL(_ url: URL) {
        guard onRequestInternetAccess() else { return }
        openURL(url)
    }
}
