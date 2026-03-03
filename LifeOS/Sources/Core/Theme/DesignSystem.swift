import SwiftUI

// MARK: - Color Palette

enum DSColor {
    // Core
    static let background = Color(hex: "0A0A0A")
    static let surface = Color(hex: "141414")
    static let surfaceLight = Color(hex: "1C1C1E")
    static let cardBorder = Color.white.opacity(0.06)
    
    // Accent
    static let accent = Color(hex: "007AFF")
    static let accentGlow = Color(hex: "007AFF").opacity(0.25)
    
    // Semantic
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9F0A")
    static let error = Color(hex: "FF3B30")
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textTertiary = Color.white.opacity(0.3)
    
    // Energy levels
    static let energyHigh = Color(hex: "FF3B30")
    static let energyMedium = Color(hex: "FF9F0A")
    static let energyLow = Color(hex: "34C759")
    
    // Block types
    static let deepWork = Color(hex: "5E5CE6")
    static let meeting = Color(hex: "FF9F0A")
    static let personal = Color(hex: "30D158")
    static let routine = Color(hex: "636366")
}

// MARK: - Typography

enum DSFont {
    static func largeTitle() -> Font { .system(.largeTitle, design: .default, weight: .bold) }
    static func title() -> Font { .system(.title2, design: .default, weight: .bold) }
    static func headline() -> Font { .system(.headline, design: .default, weight: .semibold) }
    static func body() -> Font { .system(.body, design: .default, weight: .regular) }
    static func subheadline() -> Font { .system(.subheadline, design: .default, weight: .regular) }
    static func caption() -> Font { .system(.caption, design: .default, weight: .medium) }
    static func captionSmall() -> Font { .system(.caption2, design: .default, weight: .regular) }
    static func mono() -> Font { .system(.body, design: .monospaced, weight: .regular) }
}

// MARK: - Spacing

enum DSSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}

// MARK: - Corner Radius

enum DSRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let pill: CGFloat = 100
}

// MARK: - Shadows

enum DSShadow {
    static func soft(_ color: Color = .black) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    static func glow(_ color: Color = DSColor.accent) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 0)
    }
}

// MARK: - View Modifiers

struct GlassCardModifier: ViewModifier {
    var tint: Color
    var padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .fill(tint.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .stroke(DSColor.cardBorder, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassCard(tint: Color = .white, padding: CGFloat = DSSpacing.md) -> some View {
        modifier(GlassCardModifier(tint: tint, padding: padding))
    }
    
    func softShadow() -> some View {
        self.shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    func glowShadow(_ color: Color = DSColor.accent) -> some View {
        self.shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 0)
    }
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Haptics

enum DSHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Animation Constants

enum DSAnimation {
    static let springQuick = Animation.spring(response: 0.25, dampingFraction: 0.8)
    static let springMedium = Animation.spring(response: 0.35, dampingFraction: 0.75)
    static let springBounce = Animation.spring(response: 0.4, dampingFraction: 0.65)
    static let easeQuick = Animation.easeInOut(duration: 0.2)
    static let easeMedium = Animation.easeInOut(duration: 0.3)
}
