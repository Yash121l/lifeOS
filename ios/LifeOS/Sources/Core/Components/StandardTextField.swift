import SwiftUI

struct StandardTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?
    
    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(DSColor.textSecondary)
            }
            
            TextField(placeholder, text: $text)
                .font(DSFont.body())
                .foregroundColor(DSColor.textPrimary)
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(DSColor.surfaceLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .stroke(DSColor.cardBorder, lineWidth: 1)
            // Add a subtle glow when focused conceptually if possible,
            // standard SwiftUI TextField focus isn't easily customized without FocusState,
            // we'll keep it simple and elegant.
        )
    }
}
