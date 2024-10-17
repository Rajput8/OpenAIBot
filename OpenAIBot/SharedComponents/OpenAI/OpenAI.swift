import UIKit
import Foundation

final class OpenAI {
    
    // MARK: Static Class Instance -
    static var shared = OpenAI()
    weak var eventsProtocol: OpenAIAPIEventsProtocol?
    fileprivate var accumulatedData = ""
    fileprivate var currentQuestionID: String = ""
    
    enum Status {
        case newChat
        case endChat
        case changeChatAssistant
        case unspecified
    }
    
    // MARK: Shared Methods -
    fileprivate var openAPIKey: String {
        return AppConfiguration.shared.fetchValueFromPlist(key: "OpenAI_API_Key") as? String ?? ""
    }
    
    fileprivate var assistantId: (OpenAIAssistants) -> String {
        { assistant in
            let key = "OpenAI_Assistant"
            return AppConfiguration.shared.fetchValueFromPlist(key: key) as? String ?? ""
        }
    }
    
    fileprivate var baseURL: String? {
        let key = "OpenAI_API_Base_URL"
        return AppConfiguration.shared.fetchValueFromPlist(key: key) as? String
    }
    
    fileprivate func generateURLRequest(requestParams: OpenAIAPIRequestParams) -> (URLRequest?, String?) {
        guard let baseURL else {
            return (nil, "Failed to fetch OpenAI api baseURL")
        }
        
        var completeEndpoint = "\(baseURL)/\(requestParams.endpoint)"
        
        if let tail = requestParams.remoteRequestTail, !tail.isEmpty {
            completeEndpoint = "\(completeEndpoint)/\(tail)"
        }
        
        // Current API Request URL
        guard let apiRequestURL = URL(string: completeEndpoint) else {
            return (nil, "Failed to generate api request url")
        }
        
        // Generate URLRequest
        var request = URLRequest(url: apiRequestURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        if let dict = requestParams.paramsDict {
            // Convert the params into data
            guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                return (nil, "Failed to encode request body.")
            }
            request.httpBody = data
        }
        
        if let data = requestParams.paramsData {
            request.httpBody = data
        }
        
        return (request, nil)
    }
    
    fileprivate func remoteRequest<T: Decodable>(model: T.Type,
                                                 requestParams: OpenAIAPIRequestParams,
                                                 completion: @escaping (String?, T?) -> Void) {
        
        let generatedRequest = generateURLRequest(requestParams: requestParams)
        
        if let error = generatedRequest.1 {
            completion(error, nil)
        } else {
            guard let request = generatedRequest.0 else {
                completion("Failed to generate URL Request", nil)
                return
            }
            // Create a URLSession data task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion("Error: \(error.localizedDescription)", nil)
                    return
                }
                
                guard let data = data else {
                    completion("No data received.", nil)
                    return
                }
                
                let httpURLResponse = response as? HTTPURLResponse
                let statusCode = httpURLResponse?.statusCode ?? 500
                
                switch statusCode {
                case (200...299):
                    do {
                        let decodeData = try JSONDecoder().decode(T.self, from: data)
                        completion(nil, decodeData)
                    } catch (let error) {
                        completion("Failed to parse response: \(error.localizedDescription)", nil)
                    }
                    
                default:
                    do {
                        let decodeData = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        completion("Status code beyond 200...299: \(decodeData.error?.message ?? "")", nil)
                    } catch (let err) {
                        completion("Status code beyond 200...299: \(err.localizedDescription)", nil)
                    }
                }
            }
            
            // Start the task
            task.resume()
        }
    }
    
    fileprivate func streamRemoteRequest(requestParams: OpenAIAPIRequestParams,
                                         completion: @escaping (String?) -> Void) {
        
        let generatedRequest = generateURLRequest(requestParams: requestParams)
        
        if let error = generatedRequest.1 {
            completion(error)
        } else {
            guard let request = generatedRequest.0 else {
                completion("Failed to generate URL Request")
                return
            }
            
            Task {
                await startStreaming(with: request)
            }
        }
    }
    
    fileprivate func startStreaming(with request: URLRequest) async {
        do {
            let (bytes, _) = try await URLSession.shared.bytes(for: request)
            for try await line in bytes.lines {
                if line.contains("data") && line.contains("[DONE]") {
                    NotificationCenter.default.post(name: .receivedAllChunks, object: nil)
                } else {
                    if line.contains("data") && line.contains("thread.message.delta") {
                        processLine(line: line)
                    }
                }
            }
        } catch {
            print("Error during streaming: \(error)")
        }
    }
    
    // Decode the JSON data
    fileprivate func processLine(line: String) {
        // Extract the JSON part from the line (after "data:")
        let jsonString = line.components(separatedBy: "data: ").last ?? ""
        let jsonData = jsonString.data(using: .utf8)!
        // Decode the JSON and check if the object is "thread.message.delta"
        do {
            let decodeData = try JSONDecoder().decode(ThreadMessageDeltaResponse.self, from: jsonData)
            eventsProtocol?.receivedNewChunk(details: decodeData, quesID: currentQuestionID)
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

// MARK: OpenAI Native Remote Requests -
extension OpenAI {
    func threadDetails(thread_id: String? = nil,
                       completion: @escaping (String?, NewThreadResponse?) -> Void) {
        let requestParams = OpenAIAPIRequestParams(endpoint: .threads,
                                                   methodType: .post,
                                                   remoteRequestTail: thread_id)
        remoteRequest(model: NewThreadResponse.self, requestParams: requestParams) { msg, resp in
            completion(msg, resp)
        }
    }
    
    func runThread(isStreamEnable: Bool = false,
                   threadID: String,
                   assistant: OpenAIAssistants) {
        
        let id = assistantId(assistant)
        
        let params = ["assistant_id": id,
                      "stream": isStreamEnable] as [String : Any]
        
        let tail = "\(threadID)/runs"
        
        let requestParams = OpenAIAPIRequestParams(endpoint: .threads,
                                                   methodType: .post,
                                                   paramsDict: params,
                                                   remoteRequestTail: tail)
        
        streamRemoteRequest(requestParams: requestParams) { _ in }
    }
    
    func createMessage(query: String,
                       isStreamEnable: Bool = false,
                       threadID: String,
                       assistant: OpenAIAssistants,
                       completion: @escaping (String?, NewMessageResponse?) -> Void) {
        
        // Create the request body params
        let params = ["role": "user", "content": query] // User's query or prompt
        
        let tail = "\(threadID)/messages"
        
        let requestParams = OpenAIAPIRequestParams(endpoint: .threads,
                                                   methodType: .post,
                                                   paramsDict: params,
                                                   remoteRequestTail: tail)
        remoteRequest(model: NewMessageResponse.self,
                      requestParams: requestParams) { [weak self] msg, resp in
            guard let resp else { return }
            if let raisedQuery = resp.content?.first?.text?.value {
                completion(msg, resp)
                self?.runThread(isStreamEnable: isStreamEnable,
                                threadID: threadID,
                                assistant: assistant)
                self?.currentQuestionID = resp.id ?? ""
                self?.eventsProtocol?.createdNewMessage(details: resp)
            }
        }
    }
    
    func chat(query: String,
              customInstruction: String,
              isStreamEnable: Bool = false,
              completion: @escaping (String?, OpenAIChatResponses?) -> Void) {
        
        // Create the request body params with custom instructions
        let params: [String: Any] = [
            "model": "gpt-3.5-turbo", // Replace with the appropriate model if needed
            "stream": isStreamEnable,
            "messages": [
                [
                    "role": "system",
                    "content": customInstruction // Custom instruction to guide the assistant's behavior
                ],
                [
                    "role": "user",
                    "content": query // User's query or prompt
                ]
            ]
        ]
        
        let tail = "/completions"
        
        let requestParams = OpenAIAPIRequestParams(endpoint: .chat,
                                                   methodType: .post,
                                                   paramsDict: params,
                                                   remoteRequestTail: tail)
        print("requestParams: \(requestParams.endpoint)")
        remoteRequest(model: OpenAIChatResponses.self,
                      requestParams: requestParams) { msg, resp in
            completion(msg, resp)
        }
    }
}

// MARK: OpenAIAPIEventsProtocol
protocol OpenAIAPIEventsProtocol: AnyObject {
    func receivedNewChunk(details: ThreadMessageDeltaResponse, quesID: String)
    func createdNewMessage(details: NewMessageResponse)
}

// MARK: OpenAIAssistants -
enum OpenAIAssistants: String, CaseIterable {
    case paraphrased = "Paraphrased"
    
    static func assistantType(_ name: String) -> OpenAIAssistants {
        for type in OpenAIAssistants.allCases {
            if type.rawValue == name {
                return type
            }
        }
        return .paraphrased
    }
}

// MARK: OpenAIAPIEndpoints -
enum OpenAIAPIEndpoints: String {
    case assistants = "assistants"
    case chat = "chat"
    case threads = "threads"
}

// MARK: OpenAIAPIEvents -
enum OpenAIAPIEvents: String {
    case done = "done"
    case thread_run_created = "thread.run.created"
    case thread_run_queued = "thread.run.queued"
    case thread_run_in_progress = "thread.run.in_progress"
    case thread_run_step_created = "thread.run.step.created"
    case thread_run_step_in_progress = "thread.run.step.in_progress"
    case thread_message_created = "thread.message.created"
    case thread_message_in_progress = "thread.message.in_progress"
    case thread_message_delta = "thread.message.delta"
    case thread_message_completed = "thread.message.completed"
    case thread_run_step_completed = "thread.run.step.completed"
    case thread_run_completed = "thread.run.completed"
}

// MARK: OpenAIAPIRequestParams -
struct OpenAIAPIRequestParams {
    var endpoint: OpenAIAPIEndpoints
    var methodType: APIRequestMethodType
    var contentType: APIRequestContentType?
    var paramsData: Data?
    var paramsDict: [String: Any]?
    var remoteRequestTail: String?
    
    init(endpoint: OpenAIAPIEndpoints,
         methodType: APIRequestMethodType,
         contentType: APIRequestContentType? = nil,
         paramsData: Data? = nil,
         paramsDict: [String : Any]? = nil,
         remoteRequestTail: String? = nil) {
        self.endpoint = endpoint
        self.methodType = methodType
        self.contentType = contentType
        self.paramsData = paramsData
        self.paramsDict = paramsDict
        self.remoteRequestTail = remoteRequestTail
    }
}
