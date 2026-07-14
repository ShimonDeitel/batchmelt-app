import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            PourListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BMTheme.accent)
    }
}

struct PourListView: View {
    @EnvironmentObject private var store: BatchMeltStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Pour?

    var body: some View {
        NavigationStack {
            ZStack {
                BMTheme.backdrop.ignoresSafeArea()
                if store.pours.isEmpty {
                    ContentUnavailableView("No Pours Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.pours) { item in
                            PourRow(item: item)
                                .listRowBackground(BMTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deletePour(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Melt")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addPourButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                PourFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                PourFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct PourRow: View {
    let item: Pour

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.pieceName)
                .font(BMTheme.headlineFont)
                .foregroundStyle(BMTheme.ink)
            Text(String(describing: item.alloyType))
                .font(.caption)
                .foregroundStyle(BMTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum PourFormMode: Identifiable {
    case add
    case edit(Pour)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct PourFormView: View {
    @EnvironmentObject private var store: BatchMeltStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: PourFormMode

    @State private var draftPieceName: String = ""
    @State private var draftAlloyType: String = ""
    @State private var draftPourTemp: String = ""
    @State private var draftMoldPattern: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BMTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Piece", text: $draftPieceName)
                    .accessibilityIdentifier("pieceNameField")
                Picker("Alloy Type", selection: $draftAlloyType) {
                    ForEach(BMAlloyTypeOption.all, id: \.self) { Text($0) }
                }
                TextField("Pour Temp (F)", text: $draftPourTemp)
                    .accessibilityIdentifier("pourTempField")
                TextField("Mold Pattern", text: $draftMoldPattern)
                    .accessibilityIdentifier("moldPatternField")
                    }
                    .listRowBackground(BMTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("pourSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftPieceName = item.pieceName
        draftAlloyType = item.alloyType
        draftPourTemp = item.pourTemp
        draftMoldPattern = item.moldPattern
        } else {
        draftPieceName = ""
        draftAlloyType = ""
        draftPourTemp = ""
        draftMoldPattern = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addPour(pieceName: draftPieceName, alloyType: draftAlloyType, pourTemp: draftPourTemp, moldPattern: draftMoldPattern, isPro: purchases.isPro)
        case .edit(let item):
            store.updatePour(item.id, pieceName: draftPieceName, alloyType: draftAlloyType, pourTemp: draftPourTemp, moldPattern: draftMoldPattern)
        }
        BMHaptics.success()
        dismiss()
    }
}
