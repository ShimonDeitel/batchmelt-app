import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchMeltStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchmelt_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchmelt_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BMTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BMTheme.accent)
                                Text("Batch Melt Pro active")
                                    .foregroundStyle(BMTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BMTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BMTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BMTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BMTheme.card)

                    if purchases.isPro {
                        Section("Alloy Melting-Point Library") {
                            Text("Reference library of alloy melting points and shrinkage rates.")
                                .font(.caption)
                                .foregroundStyle(BMTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.alloyType)
                                        .foregroundStyle(BMTheme.ink)
                                    Spacer()
                                    Text(p.meltPointF)
                                        .font(.caption)
                                        .foregroundStyle(BMTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BMTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BMHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BMTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddPourButton")
                    }
                    .listRowBackground(BMTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchmelt-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchmelt-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BMTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BMTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                PourFormView(mode: .add)
            }
        }
    }
}
