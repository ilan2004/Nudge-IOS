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
            // Background
            Color(red: 0.96, green: 0.96, blue: 0.94)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Focus Settings")
                            .font(.title2.bold())
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
                        Spacer()
                        Button("Done") { dismiss() }
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
                            .font(.body.weight(.semibold))
                    }
                    .padding(.bottom, 4)

                    // Blocking section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Blocking")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))

                        Button {
                            showPicker.toggle()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "lock.slash")
                                    .font(.body.weight(.medium))
                                Text("Choose Apps & Websites")
                                    .font(.body.weight(.medium))
                            }
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                                .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), radius: 0, x: 0, y: 4)
                                .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)).opacity(0.2), radius: 12, x: 0, y: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), lineWidth: 2)
                        )

                        #if canImport(FamilyControls)
                        if #available(iOS 16.0, *) {
                            if showPicker {
                                FamilyActivityPicker(selection: Binding(get: {
                                    restrictions.selection
                                }, set: { new in
                                    restrictions.selection = new
                                }))
                                .frame(height: 320)
                            }
                        } else {
                            Text("Requires iOS 16+")
                                .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)).opacity(0.6))
                                .font(.subheadline)
                        }
                        #else
                        Text("Screen Time APIs not available in this build environment.")
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)).opacity(0.6))
                            .font(.subheadline)
                        #endif
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Current selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Selection")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))

                        #if canImport(FamilyControls)
                        if #available(iOS 16.0, *) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Apps: \(restrictions.selection.applicationTokens.count)")
                                    .font(.body)
                                Text("Websites: \(restrictions.selection.webDomainTokens.count)")
                                    .font(.body)
                            }
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
                        }
                        #else
                        Text("N/A")
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
                            .font(.body)
                        #endif
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Session policy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Policy")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))

                        HStack(spacing: 12) {
                            Button("Apply Now") {
                                Task { 
                                    await restrictions.requestAuthorizationIfNeeded()
                                    restrictions.applyShields()
                                }
                            }
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
                            .font(.body.weight(.medium))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                                    .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), radius: 0, x: 0, y: 4)
                                    .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)).opacity(0.2), radius: 12, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), lineWidth: 2)
                            )

                            Button("Clear") {
                                restrictions.clearShields()
                            }
                            .foregroundColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
                            .font(.body.weight(.medium))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                                    .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), radius: 0, x: 0, y: 4)
                                    .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)).opacity(0.2), radius: 12, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, big: 0.30)), lineWidth: 2)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(24)
            }
        }
        .task { await restrictions.requestAuthorizationIfNeeded() }
    }
}

#Preview {
    FocusSettingsView()
}