import Foundation
import FirebaseFirestore

struct Exam: Identifiable {
    let id: String
    let subject: String
    let date: Date
    let note: String

    init(id: String = UUID().uuidString, subject: String, date: Date, note: String) {
        self.id = id
        self.subject = subject
        self.date = date
        self.note = note
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "subject": subject,
            "date": Timestamp(date: date),
            "note": note
        ]
    }
}
