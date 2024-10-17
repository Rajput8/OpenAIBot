import UIKit

class LogHandler {

    static func responseLog(_ data: Data?, _ response: URLResponse?, _ err: Error?) {
        guard let response, let data, err == nil else { return }
        let responseDesc = "\(response)"
        _ = responseDesc.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
        if let _ = String(data: data, encoding: .utf8) {
            // LogHandler.reportLogOnConsole(nil, "ApiRequestResponse is: \(requestResponse)")
        }
    }

    static func requestLog(_ request: URLRequest) { return requestLog(request, nil) }

    static func requestLog(_ request: URLRequest, _ data: Data?) {
        var requestBodyString = ""
        var requestBodyData = ""
        if let requestBodyData = request.httpBody { requestBodyString = String(decoding: requestBodyData, as: UTF8.self) }
        if let bodyData = data { requestBodyData = String(decoding: bodyData, as: UTF8.self) }
		if !requestBodyData.isEmpty {
			debugPrint("BodyData: \(requestBodyData)")
		}

        LogHandler.reportLogOnConsole(nil, "Method: \(request.httpMethod ?? "") \(request)\nHeaders: \(String(describing: request.allHTTPHeaderFields))\nBody \(requestBodyString)")
    }

    static func reportLogOnConsole(_ errorType: APIFailureTypes?, _ desc: String) {
    #if DEBUG
        if let type = errorType {
            Swift.print("errorType is: \(type) and description is: \(desc)")
        } else {
            Swift.print("Log is: \(desc)")
        }
    #endif
    }
}
