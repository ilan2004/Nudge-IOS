// Core/Services/PrivateAppIconProvider.swift
#if canImport(UIKit)
import UIKit

final class PrivateAppIconProvider {
    static let shared = PrivateAppIconProvider()
    private let cache = NSCache<NSString, UIImage>()

    func icon(for bundleID: String, preferredSize: CGFloat = 24) -> UIImage? {
        let key = bundleID as NSString
        if let cached = cache.object(forKey: key) { return cached }

        guard let proxyCls: AnyObject = NSClassFromString("LSApplicationProxy") else { return nil }
        guard let unmanagedProxy = proxyCls.perform(NSSelectorFromString("applicationProxyForIdentifier:"), with: bundleID) else { return nil }
        let proxy = unmanagedProxy.takeUnretainedValue() as AnyObject

        // Try a set of common variants from largest to smallest
        let variants: [Int] = [256, 128, 120, 64, 60, 40, 32, 29, 20, 16, 2]
        for v in variants {
            if let unmanagedData = proxy.perform(NSSelectorFromString("iconDataForVariant:"), with: v),
               let data = unmanagedData.takeUnretainedValue() as? Data,
               let img = UIImage(data: data, scale: UIScreen.main.scale) {
                let scaled = scale(img, to: preferredSize)
                cache.setObject(scaled, forKey: key)
                return scaled
            }
            if let unmanagedData = proxy.perform(NSSelectorFromString("primaryIconDataForVariant:"), with: v),
               let data = unmanagedData.takeUnretainedValue() as? Data,
               let img = UIImage(data: data, scale: UIScreen.main.scale) {
                let scaled = scale(img, to: preferredSize)
                cache.setObject(scaled, forKey: key)
                return scaled
            }
        }
        return nil
    }

    private func scale(_ image: UIImage, to size: CGFloat) -> UIImage {
        let target = CGSize(width: size, height: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            let rect = CGRect(origin: .zero, size: target)
            UIBezierPath(roundedRect: rect, cornerRadius: 5).addClip()
            image.draw(in: rect)
        }
    }
}
#endif
