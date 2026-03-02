import SwiftUI
import SwiftData

struct TaskNLPInputView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var textInput: String = ""
    
    var body: some View {
        HStack {
            TextField("e.g. Call Mom tomorrow urgent...", text: $textInput)
                .textFieldStyle(.roundedBorder)
            
            Button(action: processNLP) {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func processNLP() {
        guard !textInput.isEmpty else { return }
        let newTask = NLPTaskParser.parse(input: textInput)
        modelContext.insert(newTask)
        textInput = ""
    }
}
