import Foundation
import Combine
import SwiftUI

final class RemoteRequestManager {
    
    // MARK: Shared Instance -
    static let shared = RemoteRequestManager()
    
    // MARK: Shared Variables -
    let publisher = PassthroughSubject<Double, APIFailureTypes>()
    
    // MARK: init -
    private init() {}
    
    // MARK: Send remote request via Data Task Publisher
    func dataTask<T: Decodable>(type: T.Type, requestParams: APIRequestParams) -> AnyPublisher<T, APIFailureTypes> {
        guard let request = SessionURLRequest.urlRequest(requestParams) else {
            LoaderUtil.shared.hideLoading()
            return Fail(error: APIFailureTypes.invalidRequest).eraseToAnyPublisher()
        }
        
        if !requestParams.isHideLoadingIndicator {
            LoaderUtil.shared.showLoading()
        }
        
        // LogHandler.requestLog(request)
        
        ConnectivityMonitor.default?.startListening { status in
            if ConnectivityMonitor.default?.isReachable == true {
                
            } else {
                LoaderUtil.shared.hideLoading()
                LoaderUtil.shared.noInternetConnection()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap(APIResponseHandler.shared.dataTaskPublisherOutput)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                LoaderUtil.shared.hideLoading()
                if let apiError = error as? APIFailureTypes {
                    switch apiError {
                    case .unAuthorizedUser:
                        DispatchQueue.main.async {
                            // TODO: Handle Unauthorization case
                        }
                    default: break
                    }
                    return apiError
                } else {
                    return APIFailureTypes.networkError(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: Upload remote request via Upload Task
    func uploadTask<T: Decodable>(type: T.Type, requestParams: APIRequestParams) -> AnyPublisher<T, APIFailureTypes> {
        let session = APIConstants.remoteRequestSession
        let boundary = UUID().uuidString
        
        guard let request = SessionURLRequest.urlRequest(requestParams, boundary) else {
            LoaderUtil.shared.hideLoading()
            return Fail(error: APIFailureTypes.invalidRequest).eraseToAnyPublisher()
        }
        
        if !requestParams.isHideLoadingIndicator { LoaderUtil.shared.showLoading() }
        // LogHandler.requestLog(request)
        
        let data = uploadTaskParams(boundary: boundary, remoteRequestParams: requestParams)
        
        // Send a POST request to the URL, with the data we created earlier
        return Future<T, APIFailureTypes> { promise in
            let task = session.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    // Check for connectivity issues
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .networkConnectionLost:
                            promise(.failure(.connectivityError))
                            return
                        default: break
                        }
                    }
                    // For other errors, wrap the original error
                    promise(.failure(.unknownError(error)))
                } else {
                    // Parse and handle the response
                    APIResponseHandler.shared.uploadTaskResponse(data: data, response: response, promise: promise)
                }
            }
            
            _ = task.progress.observe(\.fractionCompleted) { progress, _ in
                self.publisher.send(progress.fractionCompleted)
            }
            task.resume()
        }
        .eraseToAnyPublisher()
    }
    
    fileprivate func uploadTaskParams(boundary: String, remoteRequestParams: APIRequestParams) -> Data? {
        var data = Data()
        if let params = remoteRequestParams.params {
            // LogHandler.reportLogOnConsole(nil, "params is: \(remoteRequestParams.params ?? [:])")
            for(key, value) in params {
                // Add the reqtype field and its value to the raw http request data
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)".data(using: .utf8)!)
            }
        }
        
        if let medias = remoteRequestParams.mediaContent, medias.count > 0 {
            for media in medias {
                let keyname = media.keyname.rawValue
                let filename = media.filename
                let contentType = media.contentType.rawValue
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(keyname)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                // data.append("Content-Type: \r\n\r\n".data(using: .utf8)!)
                data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
                data.append(media.data)
            }
        }
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
}
