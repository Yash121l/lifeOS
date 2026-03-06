import SwiftUI

// A convenient container view that applies the standard glassCard modifier
struct GlassCard<Content: View>: View {
    let padding: CGFloat
    let tint: Color
    @ViewBuilder let content: () -> Content
    
    init(padding: CGFloat = DSSpacing.md, tint: Color = .white, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.tint = tint
        self.content = content
    }
    
    var body: some View {
        content()
            .glassCard(tint: tint, padding: padding)
    }
}
