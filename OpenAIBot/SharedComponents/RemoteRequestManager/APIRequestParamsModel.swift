import Foundation

struct APIRequestParams {
	var endpoint: APIEndpoints
	var methodType: APIRequestMethodType
	var contentType: APIRequestContentType?
	var requestModelData: Data?
	var params: [String: Any]?
	let mediaContent: [MultipartMediaRequestParams]?
	var isHideLoadingIndicator: Bool = false
    var remoteRequestTail: String?
	
	init(endpoint: APIEndpoints,
		 methodType: APIRequestMethodType,
		 contentType: APIRequestContentType? = nil,
		 requestModelData: Data? = nil,
		 params: [String: Any]? = nil,
		 mediaContent: [MultipartMediaRequestParams]? = nil,
		 isHideLoadingIndicator: Bool = false,
         remoteRequestTail: String? = nil) {
		
		self.endpoint = endpoint
		self.methodType = methodType
		self.contentType = contentType
		self.requestModelData = requestModelData
		self.params = params
		self.mediaContent = mediaContent
		self.isHideLoadingIndicator = isHideLoadingIndicator
        self.remoteRequestTail = remoteRequestTail
	}
}

struct MultipartMediaRequestParams {
	var filename: String
	var data: Data
	var keyname: MediaFileKeyname
	var contentType: MediaContentType
	
	enum MediaContentType: String {
		case imageJPEG = "image/jpeg"
		case imagePNG = "image/png"
		case videoMP4 = "video/mp4"
		case videoMOV = "video/quicktime"
        case audio = "audio/mp3"
	}
	
	enum MediaFileKeyname: String {
		case bioVoice = "bioVoice"
        case file = "image" //"file"
	}
}

// MARK: - SuccessResponse
struct SuccessResponse: Codable {
	let status: Int?
	let message: String?
	let data: Int?
    let userId: String?
}

// MARK: - ResponseErrorWithoutDataModel
struct ResponseErrorWithoutDataModel: Codable {
	let status: Int?
	let message: String?
}

// MARK: - ResponseErrorModel
struct ResponseErrorModel: Codable {
	let status: Int?
	let message: String?
	let data: ResponseErrorData?
}

// MARK: - ResponseErrorData
struct ResponseErrorData: Codable {
	let allWarningMessages, allNonErrorMessages, allErrorMessages: [String]?
	
	enum CodingKeys: String, CodingKey {
		case allWarningMessages = "all_warning_messages"
		case allNonErrorMessages = "all_non_error_messages"
		case allErrorMessages = "all_error_messages"
	}
}
