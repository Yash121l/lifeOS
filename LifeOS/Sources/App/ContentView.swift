import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
            
            TimeView()
                .tabItem {
                    Label("Time", systemImage: "calendar")
                }
            
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            FinanceView()
                .tabItem {
                    Label("Finance", systemImage: "dollarsign.circle")
                }
            
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
