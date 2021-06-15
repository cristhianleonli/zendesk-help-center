import Foundation
import ZendeskCoreSDK
import SupportSDK

struct ZendeskSupportProvider: SupportProvider {
    func initialize() {
        Zendesk.initialize(
            appId: "app_id_from_zendesk_dashboard",
            clientId: "client_id_for_ios_application",
            zendeskUrl: "custom_zendesk_url"
        )
        
        // to avoid keeping user's data, an anonymous identity is created
        let identity = Identity.createAnonymous()
        Zendesk.instance?.setIdentity(identity)
        
        Support.initialize(withZendesk: Zendesk.instance)
    }
}
