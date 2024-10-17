// MARK: NewThreadResponse -
struct NewThreadResponse: Codable {
    let id, object: String?
    let createdAt: Int?
    let metadata, toolResources: Metadata?
    
    enum CodingKeys: String, CodingKey {
        case id, object
        case createdAt = "created_at"
        case metadata
        case toolResources = "tool_resources"
    }
}

// MARK: Metadata -
struct Metadata: Codable { }

// MARK: Error_Response
struct ErrorResponse: Codable {
    let error: ErrorDetails?
}

// MARK: ErrorDetails -
struct ErrorDetails: Codable {
    let message, type, code: String?
}

// MARK: OpenAI_Chat_Responses -
struct OpenAIChatResponses: Codable {
    let id, object: String?
    let created: Int?
    let model: String?
    let choices: [ChoiceData]?
    let usage: Usage?
    let systemFingerprint: String?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

// MARK: ChoiceData -
struct ChoiceData: Codable {
    let index: Int?
    let message: MessageData?
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

// MARK: MessageData -
struct MessageData: Codable {
    let role, content: String?
}

// MARK: Usage -
struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int?
    let completionTokensDetails: CompletionTokensDetails?
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case completionTokensDetails = "completion_tokens_details"
    }
}

// MARK: CompletionTokensDetails -
struct CompletionTokensDetails: Codable {
    let reasoningTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case reasoningTokens = "reasoning_tokens"
    }
}

// MARK: NewMessageResponse -
struct NewMessageResponse: Codable {
    let id, object: String?
    let createdAt: Int?
    let threadID, role: String?
    let content: [Content]?
    let metadata: Metadata?
    
    enum CodingKeys: String, CodingKey {
        case id, object
        case createdAt = "created_at"
        case threadID = "thread_id"
        case role, content, metadata
    }
}

// MARK: Content -
struct Content: Codable {
    let index: Int?
    let type: String?
    let text: Text?
}

// MARK: Text -
struct Text: Codable {
    let value: String?
}

// MARK: ThreadMessageDeltaResponse -
struct ThreadMessageDeltaResponse: Codable {
    let id, object: String?
    let delta: Delta?
}

// MARK: Delta -
struct Delta: Codable {
    let content: [Content]?
}

// MARK: OpenAIChatDetails -
struct OpenAIChatDetails {
    var question: String?
    var questionID: String?
    var reply: String?
    var replyID: String?
    var isSavedOnServer: Bool?
    var isBookmarked: Bool?
    var messageID: String?
}

// MARK: SavedMessagesResponse -
struct SavedMessagesResponse: Codable {
    var success: Bool?
    var message: String?
    var chatId: String?
    var recent_message_array: [String]?
    var messages: [SavedQuestionAnswerDetails]?
}

// MARK: SavedQuestionAnswerDetails -
struct SavedQuestionAnswerDetails: Codable {
    var _id: String?
    var question: String?
    var answer: String?
    var isSaved: Bool?
}

// MARK: ChatsByAssistantResponse -
struct ChatsByAssistantResponse: Codable {
    let success: Bool?
    let message: String?
    let chats: [ChatData]?
    let savedMessages: [ChatData]?
}

// MARK: ChatData -
struct ChatData: Codable {
    let id, threadID, userID: String?
    let isReadingPlanChat, isMeditationPlanChat: Bool?
    let initialQuestion, createdAt, updatedAt: String?
    let chatID, question: String?
    let answer: String?
    let isSaved: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case threadID = "threadId"
        case userID = "userId"
        case isReadingPlanChat, isMeditationPlanChat, initialQuestion, createdAt, updatedAt
        case chatID = "chatId"
        case question, answer, isSaved
    }
}

// MARK: ThreadDetailsResponse -
struct ThreadDetailsResponse: Codable {
    let success: Bool?
    let message: String?
    let chat: ThreadData?
    let messages: [ChatData]?
}

// MARK: ThreadData -
struct ThreadData: Codable {
    let id, threadID, userID: String?
    let isReadingPlanChat, isMeditationPlanChat: Bool?
    let initialQuestion: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case threadID = "threadId"
        case userID = "userId"
        case isReadingPlanChat, isMeditationPlanChat, initialQuestion
    }
}

// MARK: AddedReflectionsResponse -
struct AddedReflectionsResponse: Codable {
    let success: Bool?
    let reflections: [ReflectionData]?
    let reflection: ReflectionData?
}

// MARK: ReflectionData -
struct ReflectionData: Codable {
    let id, userID, reflections, createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case reflections, createdAt, updatedAt
    }
}
