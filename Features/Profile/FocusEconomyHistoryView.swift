import SwiftUI

struct FocusEconomyHistoryView: View {
    @EnvironmentObject var economy: EconomyService
    @Environment(\.dismiss) private var dismiss

    struct Entry: Identifiable { let id = UUID(); let date: String; let points: Int; let coins: Int; let note: String }
    private var mock: [Entry] = [
        .init(date: "Today", points: 74, coins: 10, note: "Deep Focus session"),
        .init(date: "Yesterday", points: 50, coins: 5, note: "Group battle"),
        .init(date: "Mon", points: 32, coins: 3, note: "Solo focus")
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Totals").textCase(.uppercase)) {
                    HStack { Text("Focus Points"); Spacer(); Text("\(economy.totalFocusPoints)").bold() }
                    HStack { Text("Focus Coins"); Spacer(); Text("\(economy.totalFocusCoins)").bold() }
                }
                Section(header: Text("Recent Sessions").textCase(.uppercase)) {
                    ForEach(mock) { e in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(e.date).font(.headline)
                                Text(e.note).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("+\(e.points) FP").foregroundColor(.green)
                                Text("+\(e.coins) Coins").foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Points & Coins History")
            .toolbar { ToolbarItem(placement: .primaryAction) { Button("Close") { dismiss() } } }
        }
    }
}

#Preview {
    FocusEconomyHistoryView().environmentObject(EconomyService())
}

