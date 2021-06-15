import Foundation

protocol SupportHelpCenterProvider {
    
    /// Gets the articles from the knowledge base
    /// - Parameter completion: returns an array of SupportItem
    func fetchArticles(completion: @escaping (Result<[SupportItem], SupportError>) -> Void)
    
    /// Finds the articles given a text
    /// - Parameters:
    ///   - text: text to base the article search
    ///   - completion: returns an array of SupportArticle
    func searchArticles(text: String, completion: @escaping (Result<[SupportArticle], SupportError>) -> Void)
    
    /// Gets a single support article
    /// - Parameters:
    ///   - id: article identifier
    ///   - completion: returns a SupportArticle object
    func fetchArticle(id: Int, completion: @escaping (Result<SupportArticle, SupportError>) -> Void)
    
    /// Votes down for an specific article
    /// - Parameters:
    ///   - id: article identifier
    ///   - completion: callback to be executed after the down vote happened
    func downVoteArticle(id: Int, completion: @escaping () -> Void)
    
    /// Votes up for an specific article
    /// - Parameters:
    ///   - id: article identifier
    ///   - completion: callback to be executed after the up vote happened
    func upVoteArticle(id: Int, completion: @escaping () -> Void)
}
