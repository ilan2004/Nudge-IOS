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
            Color.black.opacity(0.3).ignoresSafeArea()

            // Cream panel
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Focus Settings")
                        .font(.title2.bold())
                        .foregroundColor(.greenText)
                    Spacer()
                    Button("Done") { dismiss() }
                        .foregroundColor(.greenText)
                        .font(.body.weight(.semibold))
                }
                .padding(.bottom, 4)

                // Blocking section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Blocking")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.greenText)

                    Button {
                        showPicker.toggle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.slash")
                                .font(.body.weight(.medium))
                            Text("Choose Apps & Websites")
                                .font(.body.weight(.medium))
                        }
                        .foregroundColor(.greenText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.defaultCream)
                                .shadow(color: Color.greenPrimary.opacity(0.15), radius: 2, x: 0, y: -2)
                                .shadow(color: Color.greenPrimary.opacity(0.1), radius: 8, x: 0, y: -4)
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
                            .foregroundColor(.greenText.opacity(0.6))
                            .font(.subheadline)
                    }
                    #else
                    Text("Screen Time APIs not available in this build environment.")
                        .foregroundColor(.greenText.opacity(0.6))
                        .font(.subheadline)
                    #endif
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Current selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Selection")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.greenText)

                    #if canImport(FamilyControls)
                    if #available(iOS 16.0, *) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Apps: \(restrictions.selection.applicationTokens.count)")
                                .font(.body)
                            Text("Websites: \(restrictions.selection.webDomainTokens.count)")
                                .font(.body)
                        }
                        .foregroundColor(.greenText)
                    }
                    #else
                    Text("N/A")
                        .foregroundColor(.greenText)
                        .font(.body)
                    #endif
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Session policy
                VStack(alignment: .leading, spacing: 12) {
                    Text("Session Policy")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.greenText)

                    HStack(spacing: 12) {
                        Button("Apply Now") {
                            Task { await restrictions.requestAuthorizationIfNeeded(); restrictions.applyShields() }
                        }
                        .foregroundColor(.greenText)
                        .font(.body.weight(.medium))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.defaultCream)
                                .shadow(color: Color.greenPrimary.opacity(0.15), radius: 2, x: 0, y: -2)
                                .shadow(color: Color.greenPrimary.opacity(0.1), radius: 8, x: 0, y: -4)
                        )

                        Button("Clear") {
                            restrictions.clearShields()
                        }
                        .foregroundColor(.greenText)
                        .font(.body.weight(.medium))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.defaultCream)
                                .shadow(color: Color.greenPrimary.opacity(0.15), radius: 2, x: 0, y: -2)
                                .shadow(color: Color.greenPrimary.opacity(0.1), radius: 8, x: 0, y: -4)
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.defaultCream)
                    .shadow(color: Color.greenPrimary.opacity(0.2), radius: 4, x: 0, y: -4)
                    .shadow(color: Color.greenPrimary.opacity(0.15), radius: 16, x: 0, y: -8)
            )
            .padding(.horizontal, 20)
            .task { await restrictions.requestAuthorizationIfNeeded() }
        }
    }
}

#Preview {
    FocusSettingsView()
}