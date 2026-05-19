import SwiftUI

// MARK: - DSCard

struct DSCard<Content: View>: View {
    enum Style { case glass, filled, outlined }
    
    let style: Style
    var tint: Color
    var padding: CGFloat
    @ViewBuilder let content: () -> Content
    
    init(
        _ style: Style = .glass,
        tint: Color = .white,
        padding: CGFloat = DSSpacing.md,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.tint = tint
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(cardBackground)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch style {
        case .glass:
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
        case .filled:
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(tint.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(tint.opacity(0.2), lineWidth: 1)
                )
        case .outlined:
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(DSColor.cardBorder, lineWidth: 1)
                )
        }
    }
}

// MARK: - DSButton

struct DSButton: View {
    enum Style { case primary, secondary, destructive, ghost }
    
    let title: String
    let icon: String?
    let style: Style
    var isLoading: Bool
    var isFullWidth: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        isLoading: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }
    
    var body: some View {
        Button {
            DSHaptics.light()
            action()
        } label: {
            HStack(spacing: DSSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text(title)
                        .font(DSFont.headline())
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, DSSpacing.xl)
            .padding(.vertical, DSSpacing.sm)
            .background(buttonBackground)
        }
        .disabled(isLoading)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return DSColor.accent
        case .destructive: return .white
        case .ghost: return DSColor.textSecondary
        }
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        switch style {
        case .primary:
            Capsule().fill(DSGradient.accent)
        case .secondary:
            Capsule()
                .fill(DSColor.accent.opacity(0.12))
                .overlay(Capsule().stroke(DSColor.accent.opacity(0.3), lineWidth: 1))
        case .destructive:
            Capsule().fill(DSGradient.error)
        case .ghost:
            Capsule().fill(Color.clear)
        }
    }
}

// MARK: - DSTextField

struct DSTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var isSecure: Bool = false
    var error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            HStack(spacing: DSSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(error != nil ? DSColor.error : DSColor.textTertiary)
                        .frame(width: 20)
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(DSFont.body())
                        .foregroundStyle(DSColor.textPrimary)
                } else {
                    TextField(placeholder, text: $text)
                        .font(DSFont.body())
                        .foregroundStyle(DSColor.textPrimary)
                }
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(DSColor.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .stroke(error != nil ? DSColor.error.opacity(0.5) : DSColor.cardBorder, lineWidth: 1)
                    )
            )
            
            if let error {
                Text(error)
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.error)
                    .padding(.leading, DSSpacing.xs)
            }
        }
    }
}

// MARK: - DSEmptyState

struct DSEmptyState: View {
    let icon: String
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(DSColor.textTertiary)
            
            VStack(spacing: DSSpacing.xxs) {
                Text(title)
                    .font(DSFont.headline())
                    .foregroundStyle(DSColor.textSecondary)
                
                if let subtitle {
                    Text(subtitle)
                        .font(DSFont.caption())
                        .foregroundStyle(DSColor.textTertiary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let actionTitle, let action {
                DSButton(actionTitle, icon: "plus", style: .secondary, action: action)
            }
        }
        .padding(DSSpacing.xxl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - DSChip

struct DSChip: View {
    let label: String
    var icon: String?
    var isSelected: Bool = false
    var tint: Color = DSColor.accent
    var onTap: (() -> Void)?
    
    var body: some View {
        Button {
            DSHaptics.selection()
            onTap?()
        } label: {
            HStack(spacing: DSSpacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                }
                Text(label)
                    .font(DSFont.caption())
            }
            .foregroundStyle(isSelected ? .white : DSColor.textSecondary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs + 2)
            .background(
                Capsule()
                    .fill(isSelected ? tint : DSColor.surfaceElevated)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? tint.opacity(0.5) : DSColor.cardBorder, lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - DSAvatar

struct DSAvatar: View {
    let initials: String
    var size: CGFloat = 44
    var gradient: LinearGradient = DSGradient.accent
    
    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                Circle().fill(gradient)
            )
            .overlay(
                Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

// MARK: - DSStatCard

struct DSStatCard: View {
    let title: String
    let value: String
    var subtitle: String?
    var icon: String?
    var tint: Color = DSColor.accent
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
            }
            
            Text(value)
                .font(DSFont.title())
                .foregroundStyle(DSColor.textPrimary)
            
            if let subtitle {
                Text(subtitle)
                    .font(DSFont.captionSmall())
                    .foregroundStyle(tint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(tint: tint)
    }
}
