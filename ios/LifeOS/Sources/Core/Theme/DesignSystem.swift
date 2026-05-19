import SwiftUI

// MARK: - Color Palette

enum DSColor {
    // Core surfaces
    static let background = Color(hex: "000000")
    static let surface = Color(hex: "131316")
    static let surfaceElevated = Color(hex: "1C1C20")
    static let surfaceLight = Color(hex: "222228")
    static let hairline = Color.white.opacity(0.10)
    static let cardBorder = Color.white.opacity(0.06)
    
    // Accent palette
    static let accent = Color(hex: "6E63FF")
    static let accentLight = Color(hex: "A29BFE")
    static let accentGlow = Color(hex: "6E63FF").opacity(0.25)
    
    // Semantic
    static let success = Color(hex: "2BB673")
    static let warning = Color(hex: "E8A92C")
    static let error = Color(hex: "FF453A")
    static let info = Color(hex: "5BAEFF")
    
    // Legacy support
    static let cyan = Color(hex: "5BAEFF")
    static let amber = Color(hex: "E8A92C")
    static let coral = Color(hex: "FF453A")
    static let mint = Color(hex: "2BB673")
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.32)
    
    // Fill
    static let fill = Color.white.opacity(0.18)
    static let fillSecondary = Color.white.opacity(0.10)
    
    // Energy levels
    static let energyHigh = Color(hex: "FF453A")
    static let energyMedium = Color(hex: "E8A92C")
    static let energyLow = Color(hex: "2BB673")
    
    // Block types
    static let deepWork = Color(hex: "6C5CE7")
    static let meeting = Color(hex: "FDCB6E")
    static let personal = Color(hex: "00B894")
    static let routine = Color(hex: "636E72")
}

// MARK: - Gradients

enum DSGradient {
    static let accent = LinearGradient(
        colors: [Color(hex: "6C5CE7"), Color(hex: "A29BFE")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let success = LinearGradient(
        colors: [Color(hex: "00B894"), Color(hex: "55EFC4")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let error = LinearGradient(
        colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let warm = LinearGradient(
        colors: [Color(hex: "FDCB6E"), Color(hex: "E17055")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let cool = LinearGradient(
        colors: [Color(hex: "74B9FF"), Color(hex: "0984E3")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let surface = LinearGradient(
        colors: [Color(hex: "111113"), Color(hex: "1A1A1F")],
        startPoint: .top, endPoint: .bottom
    )
}

// MARK: - Typography

enum DSFont {
    static func largeTitle() -> Font { .system(.largeTitle, design: .rounded, weight: .bold) }
    static func title() -> Font { .system(.title2, design: .rounded, weight: .bold) }
    static func title3() -> Font { .system(.title3, design: .rounded, weight: .semibold) }
    static func headline() -> Font { .system(.headline, design: .rounded, weight: .semibold) }
    static func body() -> Font { .system(.body, design: .default, weight: .regular) }
    static func subheadline() -> Font { .system(.subheadline, design: .default, weight: .regular) }
    static func caption() -> Font { .system(.caption, design: .default, weight: .medium) }
    static func captionSmall() -> Font { .system(.caption2, design: .default, weight: .regular) }
    static func mono() -> Font { .system(.body, design: .monospaced, weight: .regular) }
    static func monoLarge() -> Font { .system(.title, design: .monospaced, weight: .bold) }
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
    static let huge: CGFloat = 56
}

// MARK: - Corner Radius

enum DSRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let pill: CGFloat = 100
    
    // Design specific
    static let card: CGFloat = 22
    static let row: CGFloat = 16
    static let hero: CGFloat = 28
    static let circle: CGFloat = 999
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
                    .fill(DSColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .fill(tint.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .stroke(DSColor.cardBorder, lineWidth: 1)
                    )
            )
    }
}

struct ElevatedCardModifier: ViewModifier {
    var padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(DSColor.surfaceElevated)
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
    
    func elevatedCard(padding: CGFloat = DSSpacing.md) -> some View {
        modifier(ElevatedCardModifier(padding: padding))
    }
    
    func softShadow() -> some View {
        self.shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
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
    
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
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
    static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let easeQuick = Animation.easeInOut(duration: 0.2)
    static let easeMedium = Animation.easeInOut(duration: 0.3)
    static let easeSlow = Animation.easeInOut(duration: 0.5)
}

// MARK: - SF Symbols

enum DSIcon {
    // Tabs
    static let dashboard = "square.grid.2x2.fill"
    static let time = "calendar"
    static let tasks = "checkmark.circle.fill"
    static let finance = "chart.pie.fill"
    static let knowledge = "book.fill"
    
    // Actions
    static let add = "plus"
    static let delete = "trash"
    static let edit = "pencil"
    static let settings = "gearshape.fill"
    static let search = "magnifyingglass"
    static let filter = "line.3.horizontal.decrease.circle"
    static let sort = "arrow.up.arrow.down"
    static let share = "square.and.arrow.up"
    
    // Status
    static let completed = "checkmark.circle.fill"
    static let pending = "circle"
    static let pinned = "pin.fill"
    static let recurring = "arrow.triangle.2.circlepath"
    static let energy = "bolt.fill"
    
    // Categories
    static let food = "fork.knife"
    static let transport = "car.fill"
    static let shopping = "bag.fill"
    static let entertainment = "gamecontroller.fill"
    static let bills = "lightbulb.fill"
    static let health = "heart.fill"
    static let education = "graduationcap.fill"
    static let subscription = "arrow.triangle.2.circlepath"
    static let salary = "banknote.fill"
    
    // Auth
    static let person = "person.fill"
    static let email = "envelope.fill"
    static let lock = "lock.fill"
    static let signOut = "arrow.right.square"
}
