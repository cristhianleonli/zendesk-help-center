import Foundation

struct SupportArticle: SupportItem {
    
    // MARK: Properties
    
    var identifier: Int
    var title: String
    var body: String
    var author: String
    var date: Date?
    var upVoteCount: Int
    var voteCount: Int
}
