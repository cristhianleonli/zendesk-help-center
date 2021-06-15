import Foundation

struct SupportRequestUpdate {
    ///  The total unread comments on all the user's requests.
    let totalUpdates: Int
}

struct SupportRequest {
    
    // MARK: Properties
    
    var identifier: String
    var comments: [SupportComment] = []
    
    init(identifier: String) {
        self.identifier = identifier
    }
}
