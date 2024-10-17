import Foundation
/**
 - optionally, set the `Content-Type` header, to specify `how the request body was encoded`,
 in case `server` might `accept different types of requests`;
 
 - optionally, set the `Accept header`, to request `how the response body should be encoded`,
 in case the `server` might `generate different types of responses`; and
 
 - set the `httpBody` to be `properly encoded for the specific Content-Type`;
 `e.g. if application/x-www-form-urlencoded request, we need to percent-encode the body of the request.`
 
 - `JSON-encoding` the post usually `preserves` the` data types of the values that are sent `in (as long as they are valid JSON datatypes),
 
 - whereas `application/x-www-form-urlencoded`will usually have `all properties converted to strings`.
 
 - in `RFC 9110 (June 2022)`, The fact that `request bodies` on` GET, HEAD, and DELETE` are `not interoperable` has been `clarified`.
 */

class SessionURLRequest {
    
    static func urlRequest(_ requestParams: APIRequestParams, _ boundary: String? = nil) -> URLRequest? {
        
        guard let apiRequestURL = generateRequestURL(requestParams) else {
            LogHandler.reportLogOnConsole(.nullData, "null_url_request".localized())
            return nil
        }
        
        var request = URLRequest.init(url: apiRequestURL)
        
        // set authorization type and it's value in header
        if let bearerToken = APIRequestAuthorizationType.value(type: .bearerToken) {
            request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        }
        
        // Assign Method Type
        if let type = requestParams.contentType {
            
            request.httpMethod = requestParams.methodType.rawValue
            request.setValue(type.value(boundary: boundary), forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            switch requestParams.methodType {
            case .get, .delete: break
            default:
                if type == .json, let params = requestParams.params {
                    request.httpBody = try? JSONSerialization.data(withJSONObject: params)
                } else if type == .form, let params = requestParams.params {
                    request.httpBody = params.percentEncoded()
                } else if type == .data {
                    if let requestModelData = requestParams.requestModelData {
                        request.httpBody = requestModelData
                    } else {
                        LogHandler.reportLogOnConsole(.nullData, "null_request_param_data".localized())
                        return nil
                    }
                } else if type == .multipartFormData { } else { }
            }
        }
        return request
    }
    
    static fileprivate func generateRequestURL(_ requestParams: APIRequestParams) -> URL? {
        guard let baseURL = AppConfiguration.shared.baseURL else {
            LogHandler.reportLogOnConsole(nil, "Please base url in AppConstants.plist file"); return nil
        }
        
        let endpoint = requestParams.endpoint.urlComponent()
        var completeEndpoint = "\(baseURL)/\(endpoint)"
        
        if let remoteRequestTail = requestParams.remoteRequestTail {
            completeEndpoint = "\(completeEndpoint)/\(remoteRequestTail)"
        }
        
        guard var apiRequestURL = URL(string: completeEndpoint) else { return nil }
        // Now check if method type is Get or Delete, then append query params into generated api request url
        if requestParams.methodType == .get || requestParams.methodType == .delete,
           let queryParams = requestParams.params, !queryParams.isEmpty {
            let dict = APISharedMethods.shared.convertStringAnyDictToStringDict(queryParams)
            guard let requestURLWithQueryParams = apiRequestURL.append(queryParameters: dict)
            else { return nil }
            apiRequestURL = requestURLWithQueryParams
        }
        return apiRequestURL
    }
}
