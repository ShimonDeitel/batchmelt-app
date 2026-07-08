import Foundation

struct Pour: Identifiable, Codable, Equatable {
    let id: UUID
    var pieceName: String
    var alloyType: String
    var pourTemp: String
    var moldPattern: String
    var createdDate: Date

    init(id: UUID = UUID(), pieceName: String = "Belt Buckle", alloyType: String = "Aluminum", pourTemp: String = "1350", moldPattern: String = "Sand - 2 part", createdDate: Date = Date()) {
        self.id = id
        self.pieceName = pieceName
        self.alloyType = alloyType
        self.pourTemp = pourTemp
        self.moldPattern = moldPattern
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Alloy Melting-Point Library.
struct BMProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var alloyType: String
    var meltPointF: String
    var pourPointF: String
    var shrinkPercent: String
    var createdDate: Date

    init(id: UUID = UUID(), alloyType: String = "Aluminum", meltPointF: String = "1220", pourPointF: String = "1350", shrinkPercent: String = "1.3", createdDate: Date = Date()) {
        self.id = id
        self.alloyType = alloyType
        self.meltPointF = meltPointF
        self.pourPointF = pourPointF
        self.shrinkPercent = shrinkPercent
        self.createdDate = createdDate
    }
}

enum BMAlloyTypeOption {
    static let all = ["Aluminum", "Bronze", "Brass", "Pewter", "Iron"]
}
