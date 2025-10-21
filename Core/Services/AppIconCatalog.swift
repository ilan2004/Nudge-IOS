// Core/Services/AppIconCatalog.swift
import SwiftUI

// App Store–safe curated mapping from bundle identifiers to asset catalog icon names.
// Add corresponding images to Assets.xcassets using these keys.
public enum AppIconCatalog {
    // Common social/media/productivity apps
    private static let map: [String: String] = [
        // Social
        "com.burbn.instagram": "appicon.instagram",
        "com.snapchat.snapchat": "appicon.snapchat",
        "com.zhiliaoapp.musically": "appicon.tiktok",
        "com.facebook.Facebook": "appicon.facebook",
        "com.hammerandchisel.discord": "appicon.discord",
        "com.reddit.Reddit": "appicon.reddit",
        "com.twitter.twitter": "appicon.twitter",   // legacy
        "com.atebits.Tweetie2": "appicon.twitter",   // legacy
        // Messaging
        "net.whatsapp.WhatsApp": "appicon.whatsapp",
        "com.apple.MobileSMS": "appicon.messages",
        // Video/Audio
        "com.google.ios.youtube": "appicon.youtube",
        "com.netflix.Netflix": "appicon.netflix",
        "com.spotify.client": "appicon.spotify",
        // Browsers / Mail
        "com.apple.mobilesafari": "appicon.safari",
        "com.google.chrome.ios": "appicon.chrome",
        "com.google.Gmail": "appicon.gmail",
    ]

    public static func assetName(for bundleID: String) -> String? {
        let key = bundleID.lowercased()
        // Try exact match first
        if let name = map[bundleID] { return name }
        // Case-insensitive fallback
        return map.first { $0.key.lowercased() == key }?.value
    }
}

