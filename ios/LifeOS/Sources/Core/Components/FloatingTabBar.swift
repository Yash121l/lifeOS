import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        (DSIcon.dashboard, "Home"),
        (DSIcon.time, "Time"),
        (DSIcon.tasks, "Tasks"),
        (DSIcon.finance, "Finance"),
        (DSIcon.knowledge, "Notes")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation(DSAnimation.springQuick) {
                        selectedTab = index
                        DSHaptics.selection()
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].0)
                            .font(.system(size: 22, weight: selectedTab == index ? .bold : .medium))
                        
                        Text(tabs[index].1)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(selectedTab == index ? DSColor.accent : DSColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(DSColor.hairline, lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.bottom, 10) // Small gap from the home indicator area
    }
}

#Preview {
    ZStack {
        DSColor.background.ignoresSafeArea()
        VStack {
            Spacer()
            FloatingTabBar(selectedTab: .constant(0))
        }
    }
}
