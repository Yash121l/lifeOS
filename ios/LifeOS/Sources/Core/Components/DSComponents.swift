import SwiftUI

// MARK: - DSPill

struct DSPill: View {
    let text: String
    var color: Color = DSColor.accent
    var isSoft: Bool = true
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSoft ? color.opacity(0.15) : color)
            .foregroundStyle(isSoft ? color : .white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - DSSectionHeader

struct DSSectionHeader: View {
    let title: String
    var count: Int? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    init(_ title: String, count: Int? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.count = count
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .kerning(-0.4)
            
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DSColor.accent)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.bottom, 10)
    }
}

// MARK: - DSSparkline

struct DSSparkline: View {
    let data: [Double]
    var color: Color = DSColor.accent
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                let maxVal = data.max() ?? 1
                let minVal = data.min() ?? 0
                let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
                
                // Area under path
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) / CGFloat(data.count - 1) * geo.size.width
                        let y = geo.size.height - (CGFloat(value - minVal) / CGFloat(range) * geo.size.height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: geo.size.height))
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) / CGFloat(data.count - 1) * geo.size.width
                        let y = geo.size.height - (CGFloat(value - minVal) / CGFloat(range) * geo.size.height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - DSSegmentedControl (iOS style)

struct DSSegmentedControl<T: Hashable & CustomStringConvertible>: View {
    let options: [T]
    @Binding var selection: T
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(DSAnimation.springQuick) {
                        selection = option
                    }
                } label: {
                    Text(option.description)
                        .font(.system(size: 13.5, weight: selection == option ? .semibold : .medium))
                        .foregroundStyle(selection == option ? .white : DSColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background {
                            if selection == option {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(DSColor.surfaceElevated)
                                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                            }
                        }
                }
                .padding(2)
            }
        }
        .background(DSColor.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(DSColor.hairline, lineWidth: 0.5)
        )
    }
}
