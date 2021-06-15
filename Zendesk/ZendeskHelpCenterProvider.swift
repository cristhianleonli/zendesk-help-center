import SupportSDK
import Foundation

class ZendeskHelpCenterProvider: SupportHelpCenterProvider {
    
    private static let categoryIdentifier: UInt64 = 123456789 // category id if apply
    
    func fetchArticle(id: Int, completion: @escaping (Result<SupportArticle, SupportError>) -> Void) {
        ZDKHelpCenterProvider().getArticleWithId("\(id)") { (result, error) in
            if error != nil {
                return completion(.failure(SupportError.sectionsNotFound))
            }
            
            guard let article = result?.first as? ZDKHelpCenterArticle else {
                return completion(.failure(.articleNotFound))
            }
            
            let supportArticle = Self.convertZendeskToDomainArticle(article)
            completion(.success(supportArticle))
        }
    }
    
    func fetchArticles(completion: @escaping (Result<[SupportItem], SupportError>) -> Void) {
        ZDKHelpCenterProvider()
            .getSectionsWithCategoryId("\(Self.categoryIdentifier)") { [weak self] (list, error) in
                if error != nil {
                    return completion(.failure(SupportError.sectionsNotFound))
                }
                
                guard let elements = list as? [ZDKHelpCenterSection] else {
                    completion(.success([]))
                    return
                }
                
                // Load sections from zendesk
                let result = elements
                    .map { element -> SupportSection in
                        SupportSection(
                            identifier: Int(truncating: element.identifier),
                            title: element.name
                        )
                    }
                    .sorted { left, right -> Bool in
                        left.title.lowercased() < right.title.lowercased()
                    }
                
                // Load articles for each section
                // This needs to be done this way, because Zendesk doesn't provide another way to do it
                
                // In order to avoid deadlocks or race conditions while loading the articles for every section
                // for that, a DispatchGroup aka. Semaphore to wait until the last task finished.
                // This behaviour might be refactored when async/await take place into this project.
                let group = DispatchGroup()
                
                result.forEach { section in
                    group.enter()
                    
                    self?.fetchArticles(sectionId: section.identifier) { articles in
                        section.articles = articles
                        group.leave()
                    }
                }
                
                // tell the main thread, the task was finished, and finally callback with the result
                group.notify(queue: .main) {
                    completion(.success(result))
                }
            }
    }
    
    func searchArticles(text: String, completion: @escaping (Result<[SupportArticle], SupportError>) -> Void) {
        let search = ZDKHelpCenterSearch()
        search.query = text
        search.categoryIds = [NSNumber(value: Self.categoryIdentifier)]
        
        ZDKHelpCenterProvider().searchArticles(search) { (list, error) in
            if error != nil {
                return completion(.failure(SupportError.articlesNotFound))
            }
            
            guard let articles = list as? [ZDKHelpCenterArticle] else {
                return completion(.success([]))
            }
            
            let result = articles.map { article in
                return Self.convertZendeskToDomainArticle(article)
            }
            
            completion(.success(result))
        }
    }
    
    func downVoteArticle(id: Int, completion: @escaping () -> Void) {
        ZDKHelpCenterProvider().downVoteArticle(withId: String(id)) { (result, error) in
            completion()
        }
    }
    
    func upVoteArticle(id: Int, completion: @escaping () -> Void) {
        ZDKHelpCenterProvider().upVoteArticle(withId: String(id)) { (result, error) in
            completion()
        }
    }
}

// MARK: - Private methods

private extension ZendeskHelpCenterProvider {
    func fetchArticles(sectionId: Int, completion: @escaping ([SupportArticle]) -> Void) {
        ZDKHelpCenterProvider().getArticlesWithSectionId("\(sectionId)") { (list, error) in
            guard let elements = list as? [ZDKHelpCenterArticle] else {
                return completion([])
            }
            
            let result = elements.map { article in
                return Self.convertZendeskToDomainArticle(article)
            }
            
            completion(result)
        }
    }
    
    static func convertZendeskToDomainArticle(_ article: ZDKHelpCenterArticle) -> SupportArticle {
        return SupportArticle(
            identifier: Int(truncating: article.identifier),
            title: article.title,
            body: article.body,
            author: article.author_name,
            date: article.created_at,
            upVoteCount: article.getUpvoteCount(),
            voteCount: Int(truncating: article.voteCount)
        )
    }
}
