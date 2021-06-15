import Foundation

class SupportSection: SupportItem {
    
    // MARK: Properties
    
    var identifier: Int
    var title: String
    
    var isOpen: Bool = false
    var articles: [SupportArticle] = []
    
    // MARK: Life cycle
    
    init(identifier: Int, title: String) {
        self.identifier = identifier
        self.title = title
    }
}
