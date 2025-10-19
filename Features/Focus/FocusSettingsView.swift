import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif

struct FocusSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var restrictions = RestrictionsController()

    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            List {
                Section("Blocking") {
                    Button("Choose Apps & Websites") { showPicker = true }
                    #if canImport(FamilyControls)
                    if #available(iOS 16.0, *) {
                        FamilyActivityPicker(selection: Binding(get: {
                            restrictions.selection
                        }, set: { new in
                            restrictions.selection = new
                        }))
                        .frame(height: showPicker ? 320 : 0)
                        .clipped()
                        .animation(.default, value: showPicker)
                    } else {
                        Text("Requires iOS 16+").foregroundColor(.secondary)
                    }
                    #else
                    Text("Screen Time APIs not available in this build environment.")
                        .foregroundColor(.secondary)
                    #endif
                }

                Section("Current Selection") {
                    #if canImport(FamilyControls)
                    if #available(iOS 16.0, *) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Apps: \(restrictions.selection.applicationTokens.count)")
                            Text("Websites: \(restrictions.selection.webDomainTokens.count)")
                        }
                    }
                    #else
                    Text("N/A")
                    #endif
                }

                Section("Session Policy") {
                    HStack {
                        Button("Apply Now") { Task { await restrictions.requestAuthorizationIfNeeded(); restrictions.applyShields() } }
                            .buttonStyle(.borderedProminent)
                        Button("Clear") { restrictions.clearShields() }
                            .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("Focus Settings")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .task { await restrictions.requestAuthorizationIfNeeded() }
        }
    }
}

#Preview {
    FocusSettingsView()
}

