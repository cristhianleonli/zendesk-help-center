import Foundation

protocol SupportRequestProvider {
    
    /// Gets all requests the user has made
    /// - Parameter completion: returns an array of SupportRequest
    func fetchUserRequests(completion: @escaping (Result<[SupportRequest], SupportError>) -> Void)
    
    /// Gets the unseen updates for the current device
    /// - Parameter completion: returns a SupportRequestUpdate object
    func fetchUpdatesForDevice(completion: @escaping (Result<SupportRequestUpdate, SupportError>) -> Void)
    
    /// Gets all comments for an specific user request
    /// - Parameters:
    ///   - requestId: request identifier
    ///   - completion: return an array of SupportComment
    func fetchComments(requestId: String, completion: @escaping (Result<[SupportComment], SupportError>) -> Void)
    
    func markRequestAsRead(id: String)
    
    func createRequest(subject: String, description: String, attachment: Data?,
                       completion: @escaping (Result<Bool, SupportError>) -> Void)
}
