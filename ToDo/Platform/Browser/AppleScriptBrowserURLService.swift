//
//  AppleScriptBrowserURLService.swift
//  ToDo
//
//  Created by syh on 21/04/2026.
//

import Foundation
import AppKit

/// AppleScript implementation for extracting browser URL
final class AppleScriptBrowserURLService: BrowserURLService {

    /// Supported browsers with their bundle identifiers and AppleScript commands
    private enum SupportedBrowser {
        case safari
        case chrome
        case edge
        case firefox
        case arc

        var bundleID: String {
            switch self {
            case .safari: return "com.apple.Safari"
            case .chrome: return "com.google.Chrome"
            case .edge: return "com.microsoft.edgemac"
            case .firefox: return "org.mozilla.firefox"
            case .arc: return "company.thebrowser.Browser"
            }
        }

        var appleScriptName: String {
            switch self {
            case .safari: return "Safari"
            case .chrome: return "Google Chrome"
            case .edge: return "Microsoft Edge"
            case .firefox: return "Firefox"
            case .arc: return "Arc"
            }
        }

        static func from(bundleID: String) -> SupportedBrowser? {
            switch bundleID {
            case "com.apple.Safari": return .safari
            case "com.google.Chrome": return .chrome
            case "com.microsoft.edgemac": return .edge
            case "org.mozilla.firefox": return .firefox
            case "company.thebrowser.Browser": return .arc
            default: return nil
            }
        }
    }

    func getCurrentBrowserURL() -> (url: String, title: String?)? {
        // Get frontmost application
        guard let app = NSWorkspace.shared.frontmostApplication,
              let bundleID = app.bundleIdentifier,
              let browser = SupportedBrowser.from(bundleID: bundleID) else {
            Logger.debug("No supported browser is frontmost", category: "browser")
            return nil
        }

        Logger.debug("Detected browser: \(browser.appleScriptName)", category: "browser")

        // Try to get URL and title via AppleScript
        return extractURLAndTitle(from: browser)
    }

    // MARK: - Private Methods

    private func extractURLAndTitle(from browser: SupportedBrowser) -> (url: String, title: String?)? {
        let script: String

        switch browser {
        case .safari:
            script = """
            tell application "Safari"
                if (count of windows) > 0 then
                    set currentURL to URL of current tab of front window
                    set currentTitle to name of current tab of front window
                    return currentURL & "|||" & currentTitle
                end if
            end tell
            """

        case .chrome, .edge, .arc:
            // Chrome, Edge, and Arc use the same AppleScript structure
            script = """
            tell application "\(browser.appleScriptName)"
                if (count of windows) > 0 then
                    set currentURL to URL of active tab of front window
                    set currentTitle to title of active tab of front window
                    return currentURL & "|||" & currentTitle
                end if
            end tell
            """

        case .firefox:
            // Firefox doesn't support AppleScript well, fallback to clipboard
            Logger.debug("Firefox detected - limited AppleScript support", category: "browser")
            return nil
        }

        return executeAppleScript(script)
    }

    private func executeAppleScript(_ script: String) -> (url: String, title: String?)? {
        var error: NSDictionary?
        guard let scriptObject = NSAppleScript(source: script) else {
            Logger.error("Failed to create AppleScript object", category: "browser")
            return nil
        }

        let output = scriptObject.executeAndReturnError(&error)

        if let error = error {
            Logger.error("AppleScript error: \(error)", category: "browser")
            return nil
        }

        guard let result = output.stringValue else {
            Logger.debug("No result from AppleScript", category: "browser")
            return nil
        }

        // Parse result (format: "url|||title")
        let components = result.components(separatedBy: "|||")
        guard let url = components.first, !url.isEmpty else {
            Logger.debug("Invalid URL in AppleScript result", category: "browser")
            return nil
        }

        let title = components.count > 1 ? components[1] : nil
        Logger.info("Extracted URL: \(url.prefix(50))", category: "browser")

        return (url, title)
    }
}
