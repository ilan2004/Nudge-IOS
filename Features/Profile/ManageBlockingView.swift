import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif

struct ManageBlockingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var restrictions: RestrictionsController
    
    // Fallback mock state when FamilyControls not available
    @State private var blocked: Set<String> = ["instagram", "youtube", "tiktok"]
    private let candidates = ["Instagram", "YouTube", "TikTok", "Twitter", "Reddit"]
    
    #if canImport(FamilyControls)
    @State private var showingPicker = false
    #endif

    var body: some View {
        NavigationView {
            List {
                #if canImport(FamilyControls)
                Section(header: Text("Focus Mode Selection")) {
                    HStack { Text("Apps Selected"); Spacer(); Text("\(restrictions.selection.applicationTokens.count)") }
                    HStack { Text("Web Domains Selected"); Spacer(); Text("\(restrictions.selection.webDomainTokens.count)") }
                    Button("Choose Apps & Websites") { showingPicker = true }
                }
                Section(footer: Text("Grant permission first if prompted. Apply shields to enforce during focus.")) {
                    HStack {
                        Button("Request Permission") {
                            Task { await restrictions.requestAuthorizationIfNeeded() }
                        }
                        Spacer()
                        Button("Apply Shields") { restrictions.applyShields() }
                        Button("Clear") { restrictions.clearShields() }
                    }
                }
                #else
                Section(header: Text("Focus Mode Blocked Apps (Mock)")) {
                    ForEach(candidates, id: \.self) { app in
                        HStack {
                            Text(app)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { blocked.contains(app.lowercased()) },
                                set: { isOn in
                                    if isOn { blocked.insert(app.lowercased()) } else { blocked.remove(app.lowercased()) }
                                }
                            ))
                            .labelsHidden()
                        }
                    }
                }
                Section(footer: Text("This is a mock UI on this build configuration.")) { EmptyView() }
                #endif
            }
            .navigationTitle("Manage Blocking")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
            #if canImport(FamilyControls)
            .sheet(isPresented: $showingPicker) {
                FamilyActivityPicker(selection: $restrictions.selection)
            }
            #endif
        }
    }
}

#Preview {
    ManageBlockingView().environmentObject(RestrictionsController())
}

