import SupportSDK
import Foundation

class ZendeskRequestProvider: SupportRequestProvider {
    
    // MARK: - Properties
    
    private static let requestTags: [String] = ["tag_if_apply"]
    
    private static let customFields: [CustomField] = [
        CustomField(fieldId: 123456789, value: "custom_field_value")
    ]
    
    func fetchUserRequests(completion: @escaping (Result<[SupportRequest], SupportError>) -> Void) {
        ZDKRequestProvider().getAllRequests { (agents, error) in
            guard let requests = agents?.requests else {
                return completion(.success([]))
            }
            
            let supportRequests = requests.map { request in
                return SupportRequest(
                    identifier: request.requestId
                )
            }
            
            completion(.success(supportRequests))
        }
    }
    
    func fetchUpdatesForDevice(completion: @escaping (Result<SupportRequestUpdate, SupportError>) -> Void) {
        ZDKRequestProvider().getUpdatesForDevice { updates in
            let requestUpdate = SupportRequestUpdate(totalUpdates: updates?.totalUpdates ?? 0)
            completion(.success(requestUpdate))
        }
    }
    
    func markRequestAsRead(id: String) {
        ZDKRequestProvider().markRequestAsRead(id, withCommentCount: 0)
    }
    
    func fetchComments(requestId: String, completion: @escaping (Result<[SupportComment], SupportError>) -> Void) {
        ZDKRequestProvider().getCommentsWithRequestId(requestId) { (comments, error) in
            if error != nil {
                return completion(.failure(SupportError.requestCommentsNotFound))
            }
            
            let requestComments = (comments ?? []).map { comment in
                return SupportComment(
                    identifier: Int(truncating: comment.comment?.commentId ?? 0),
                    author: comment.user.name,
                    content: comment.comment.body,
                    isAgent: comment.user.isAgent,
                    date: comment.comment.createdAt
                )
            }
            
            completion(.success(requestComments))
        }
    }
    
    func createRequest(subject: String, description: String, attachment: Data?,
                       completion: @escaping (Result<Bool, SupportError>) -> Void) {
        // create request
        let request = ZDKCreateRequest()
        request.subject = subject
        request.requestDescription = description
        request.tags = Self.requestTags
        request.customFields = Self.customFields
        
        let fileName = "random_file_name.png"
        
        uploadAttachment(attachment: attachment, fileName: fileName) { (response) in
            if let attachmentResponse = response {
                request.attachments.append(attachmentResponse)
            }
            
            // finalize the request creation
            ZDKRequestProvider().createRequest(request) { (result, error) in
                if error != nil {
                    return completion(.failure(SupportError.requestCouldNotBeCreated))
                }
                
                completion(.success(result != nil))
            }
        }
    }
    
    func uploadAttachment(attachment: Data?, fileName: String, callback: @escaping ((ZDKUploadResponse?) -> Void)) {
        guard attachment != nil else {
            callback(nil)
            return
        }
        
        ZDKUploadProvider()
            .uploadAttachment(attachment, withFilename: fileName, andContentType: "image") { (response, error) in
                callback(response)
            }
    }
}
