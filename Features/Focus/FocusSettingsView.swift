import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif

struct FocusSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var restrictions = RestrictionsController()

    @State private var showPicker = false

    var body: some View {
        ZStack {
            // Dimmed overlay
            Color.black.opacity(0.2).ignoresSafeArea()

            // Cream panel styled like our components
            VStack(spacing: 16) {
                HStack {
                    Text("Focus Settings")
                        .font(.title2.bold())
                        .foregroundColor(.greenPrimary)
                    Spacer()
                    Button("Done") { dismiss() }
                        .foregroundColor(.greenPrimary)
                }

                // Blocking section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Blocking")
                        .font(.headline)
                        .foregroundColor(.greenPrimary)

                    Button {
                        showPicker.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.slash")
                            Text("Choose Apps & Websites")
                        }
                        .foregroundColor(.greenPrimary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.greenPrimary, radius: 0, x: 0, y: 4)
                                .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
                        )
                    }

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
                        Text("Requires iOS 16+")
                            .foregroundColor(.greenPrimary)
                            .opacity(0.7)
                    }
                    #else
                    Text("Screen Time APIs not available in this build environment.")
                        .foregroundColor(.greenPrimary)
                        .opacity(0.7)
                    #endif
                }

                // Current selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Selection")
                        .font(.headline)
                        .foregroundColor(.greenPrimary)

                    #if canImport(FamilyControls)
                    if #available(iOS 16.0, *) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Apps: \(restrictions.selection.applicationTokens.count)")
                            Text("Websites: \(restrictions.selection.webDomainTokens.count)")
                        }
                        .foregroundColor(.greenPrimary)
                    }
                    #else
                    Text("N/A").foregroundColor(.greenPrimary)
                    #endif
                }

                // Session policy
                VStack(alignment: .leading, spacing: 12) {
                    Text("Session Policy")
                        .font(.headline)
                        .foregroundColor(.greenPrimary)

                    HStack(spacing: 12) {
                        Button("Apply Now") {
                            Task { await restrictions.requestAuthorizationIfNeeded(); restrictions.applyShields() }
                        }
                        .foregroundColor(.greenPrimary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.greenPrimary, radius: 0, x: 0, y: 4)
                                .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
                        )

                        Button("Clear") {
                            restrictions.clearShields()
                        }
                        .foregroundColor(.greenPrimary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.greenPrimary, radius: 0, x: 0, y: 4)
                                .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
                        )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.defaultCream)
                    .shadow(color: Color.greenPrimary, radius: 0, x: 0, y: 4)
                    .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
            )
            .padding(.horizontal, 16)
            .task { await restrictions.requestAuthorizationIfNeeded() }
        }
    }
}

#Preview {
    FocusSettingsView()
}

