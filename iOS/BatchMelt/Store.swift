import Foundation

@MainActor
final class BatchMeltStore: ObservableObject {
    @Published private(set) var pours: [Pour] = []
    @Published private(set) var proEntries: [BMProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchmelt_pours.json")
        self.proFileURL = dir.appendingPathComponent("batchmelt_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if pours.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        pours = [
            Pour(pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part"),
            Pour(pieceName: "Bell", alloyType: "Bronze", pourTemp: "2100", moldPattern: "Lost Wax")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BMProEntry(alloyType: "Aluminum", meltPointF: "1220", pourPointF: "1350", shrinkPercent: "1.3"),
            BMProEntry(alloyType: "Bronze", meltPointF: "1900", pourPointF: "2100", shrinkPercent: "1.5")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || pours.count < Self.freeLimit
    }

    @discardableResult
    func addPour(pieceName: String, alloyType: String, pourTemp: String, moldPattern: String, isPro: Bool) -> Bool {
        let trimmed = pieceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Pour(pieceName: pieceName, alloyType: alloyType, pourTemp: pourTemp, moldPattern: moldPattern)
        pours.append(item)
        save()
        return true
    }

    func updatePour(_ id: UUID, pieceName: String, alloyType: String, pourTemp: String, moldPattern: String) {
        guard let idx = pours.firstIndex(where: { $0.id == id }) else { return }
        pours[idx].pieceName = pieceName
        pours[idx].alloyType = alloyType
        pours[idx].pourTemp = pourTemp
        pours[idx].moldPattern = moldPattern
        save()
    }

    func deletePour(_ id: UUID) {
        pours.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        pours = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(alloyType: String, meltPointF: String, pourPointF: String, shrinkPercent: String) -> Bool {
        let entry = BMProEntry(alloyType: alloyType, meltPointF: meltPointF, pourPointF: pourPointF, shrinkPercent: shrinkPercent)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Pour]
    }
    private struct ProSnapshot: Codable {
        var items: [BMProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            pours = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: pours)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
