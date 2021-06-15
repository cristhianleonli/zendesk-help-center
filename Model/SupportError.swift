import Foundation

enum SupportError: Error {
    case userRequestsNotFound
    case articlesNotFound
    case sectionsNotFound
    case articleNotFound
    case requestCommentsNotFound
    case requestCouldNotBeCreated
}
