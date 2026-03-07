import SwiftUI

struct TaskNLPInputView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var textInput: String = ""
    @State private var isProcessing = false
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 14))
                .foregroundStyle(textInput.isEmpty ? DSColor.textTertiary : DSColor.accent)
            
            TextField("Try: \"Call Mom tomorrow high priority\"", text: $textInput)
                .font(DSFont.subheadline())
                .foregroundStyle(DSColor.textPrimary)
                .tint(DSColor.accent)
                .onSubmit {
                    processNLP()
                }
            
            if !textInput.isEmpty {
                Button(action: processNLP) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(DSColor.accent)
                        .scaleEffect(isProcessing ? 0.85 : 1)
                        .animation(DSAnimation.springQuick, value: isProcessing)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(DSColor.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(textInput.isEmpty ? DSColor.cardBorder : DSColor.accent.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    
    private func processNLP() {
        guard !textInput.isEmpty else { return }
        isProcessing = true
        DSHaptics.success()
        
        let newTask = NLPTaskParser.parse(input: textInput)
        Task {
            try? await store.saveTask(newTask, userId: userId)
        }
        
        withAnimation(DSAnimation.springQuick) {
            textInput = ""
            isProcessing = false
        }
    }
}
