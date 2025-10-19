import SwiftUI
#if canImport(FamilyControls) && canImport(ManagedSettings)
import FamilyControls
import ManagedSettings
#endif

final class RestrictionsController: ObservableObject {
    #if canImport(FamilyControls) && canImport(ManagedSettings)
    @Published var selection = FamilyActivitySelection()
    private let store = ManagedSettingsStore()
    #endif

    @MainActor
    func requestAuthorizationIfNeeded() async {
        #if canImport(FamilyControls)
        do { try await AuthorizationCenter.shared.requestAuthorization(for: .individual) } catch { /* handle */ }
        #endif
    }

    @MainActor
    func applyShields() {
        #if canImport(ManagedSettings) && canImport(FamilyControls)
        store.shield.applications = selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens
        #endif
    }

    @MainActor
    func clearShields() {
        #if canImport(ManagedSettings)
        store.shield.applications = []
        store.shield.webDomains = []
        store.clearAllSettings()
        #endif
    }
}

