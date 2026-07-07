import SwiftUI

@main
struct BatchMeltApp: App {
    @StateObject private var store = BatchMeltStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchmelt_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BMHaptics.enabled = hapticsEnabled
                }
        }
    }
}
