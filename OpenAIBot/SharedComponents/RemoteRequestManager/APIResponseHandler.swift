import Foundation

class APIResponseHandler {
    
    // MARK: Shared Instance -
    static let shared = APIResponseHandler()
    
    // MARK: Shared Methods -
    
    // Data Task Publisher Output Handler
    func dataTaskPublisherOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        LoaderUtil.shared.hideLoading()
        guard let httpResponse = output.response as? HTTPURLResponse else { throw APIFailureTypes.invalidResponse }
        switch httpResponse.statusCode {
        case (200...299):
            LogHandler.responseLog(output.data, httpResponse, nil)
            return output.data
            
        case 401:
            throw APIFailureTypes.unAuthorizedUser
            
        default:
            do {
                let resp = try JSONDecoder().decode(SuccessResponse.self, from: output.data)
                throw APIFailureTypes.errorMessage(resp.message ?? "") // or throw URLError(.badServerResponse)
            } catch {
                // Attempt to decode the error response if the success response fails
                if let errorData = try? JSONDecoder().decode(ResponseErrorModel.self, from: output.data) {
                    throw APIFailureTypes.errorMessage(errorData.message ?? "")
                } else if let errorData = try? JSONDecoder().decode(ResponseErrorWithoutDataModel.self, from: output.data) {
                    throw APIFailureTypes.errorMessage(errorData.message ?? "")
                } else {
                    throw APIFailureTypes.errorMessage("Failed to decode")
                }
            }
        }
    }
    
    // Upload Task Response Handler
    func uploadTaskResponse<T: Decodable>(data: Data?, response: URLResponse?, promise: @escaping (Result<T, APIFailureTypes>) -> Void) {
        LoaderUtil.shared.hideLoading()
        guard let httpResponse = response as? HTTPURLResponse, let data else {
            promise(.failure(.errorMessage("null_data_in_response".localized())))
            return
        }
        
        do {
            switch httpResponse.statusCode {
            case (200...299):
                let resp = try JSONDecoder().decode(T.self, from: data)
                promise(.success(resp.self))
                
            case 401:
                throw APIFailureTypes.unAuthorizedUser
                
            default:
                let resp = try JSONDecoder().decode(SuccessResponse.self, from: data)
                throw APIFailureTypes.errorMessage(resp.message ?? "") // or throw URLError(.badServerResponse)
            }
            
        } catch {
            let parseError = parseError(error)
            promise(.failure(.errorMessageWithError(error, parseError)))
        }
    }
    
    fileprivate func parseError(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError
        else {
            return "data_not_parseable_to_string".localized()
        }
        let err = "\(decodingError)"
        let errDesc = String(format: "parse_error_message".localized(), arguments: [err])
        return errDesc
    }
}
