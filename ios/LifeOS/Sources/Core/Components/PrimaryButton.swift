import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: PrimaryButtonStyle
    
    enum PrimaryButtonStyle {
        case solid
        case outline
        case ghost
    }
    
    init(_ title: String, icon: String? = nil, style: PrimaryButtonStyle = .solid, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            DSHaptics.light()
            action()
        }) {
            HStack(spacing: DSSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(DSFont.headline())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.md)
            .background(backgroundView)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .stroke(style == .outline ? DSColor.cardBorder : Color.clear, lineWidth: 1)
            )
        }
        .contentShape(RoundedRectangle(cornerRadius: DSRadius.lg))
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .solid:
            DSColor.accent
        case .outline, .ghost:
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .solid:
            return .white
        case .outline, .ghost:
            return DSColor.accent
        }
    }
}
