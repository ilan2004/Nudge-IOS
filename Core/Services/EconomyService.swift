import SwiftUI
import Combine

final class EconomyService: ObservableObject {
    @Published var totalFocusPoints: Int = 0 {
        didSet { save() }
    }
    @Published var totalFocusCoins: Int = 0 {
        didSet { save() }
    }

    private let defaults = UserDefaults.standard
    private let fpKey = "nudge_total_fp"
    private let fcKey = "nudge_total_fc"
    private let initKey = "nudge_economy_initialized"

    init() { load() }

    func load() {
        let initialized = defaults.bool(forKey: initKey)
        if !initialized {
            // Seed with mock data for first run
            totalFocusPoints = 742
            totalFocusCoins = 120
            save()
            defaults.set(true, forKey: initKey)
            return
        }
        totalFocusPoints = defaults.integer(forKey: fpKey)
        totalFocusCoins = defaults.integer(forKey: fcKey)
    }

    func save() {
        defaults.set(totalFocusPoints, forKey: fpKey)
        defaults.set(totalFocusCoins, forKey: fcKey)
    }
}

