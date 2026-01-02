import UIKit

extension UIColor {
    /// "#RRGGBB", "RRGGBB", "#AARRGGBB", "AARRGGBB" 지원
    /// - opacity: 0.0 ~ 1.0 (옵셔널)
    /// - opacityPercent: 0 ~ 100 (옵셔널)  ※ 제공되면 opacity/hex alpha보다 우선
    convenience init(hex: String, opacity: CGFloat? = nil, opacityPercent: CGFloat? = nil) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }

        guard s.count == 6 || s.count == 8 else {
            assertionFailure("Invalid hex length: \(hex)")
            self.init(white: 0, alpha: 0)
            return
        }

        var value: UInt64 = 0
        guard Scanner(string: s).scanHexInt64(&value) else {
            assertionFailure("Invalid hex value: \(hex)")
            self.init(white: 0, alpha: 0)
            return
        }

        var a: CGFloat = 1.0
        let r, g, b: CGFloat

        if s.count == 6 {
            r = CGFloat((value & 0xFF0000) >> 16) / 255.0
            g = CGFloat((value & 0x00FF00) >> 8) / 255.0
            b = CGFloat(value & 0x0000FF) / 255.0
        } else { // AARRGGBB
            a = CGFloat((value & 0xFF000000) >> 24) / 255.0
            r = CGFloat((value & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((value & 0x0000FF00) >> 8) / 255.0
            b = CGFloat(value & 0x000000FF) / 255.0
        }

        // ✅ 외부에서 투명도 지정 시 우선 적용
        if let p = opacityPercent {
            a = min(max(p, 0), 100) / 100.0
        } else if let o = opacity {
            a = min(max(o, 0), 1)
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
