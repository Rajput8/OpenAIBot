import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    // MARK: Published Variables -
    @Published var apiError: String?
    @Published var chats = [OpenAIChatDetails]()
    @Published var chatStatus: OpenAI.Status = .unspecified
    @Published var currentOpenAIAssistants: OpenAIAssistants = .paraphrased
    @Published var newCreatedThreadID: String?
    @Published var threadDetails: ThreadDetailsResponse?
    @Published var chatID: String?
    @Published var isLocked: Bool = false
    
    // MARK: Shared Variables -
    var cancellables = Set<AnyCancellable>()
    
    // MARK: deinit -
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

extension HomeViewModel {
    
    func addNewQuery(details: NewMessageResponse) {
        let ques = details.content?.first?.text?.value ?? ""
        let quesID = details.id ?? ""
        let details = OpenAIChatDetails(question: ques, questionID: quesID)
        
        // MARK: Update Chats model
        if chats.count > 1 {
            let newChat = [details]
            let loadedChat = chats
            let cummulativeChat = newChat + loadedChat
            chats = cummulativeChat
        } else {
            chats.append(details)
        }
    }
    
    func updateReply(details: ThreadMessageDeltaResponse, quesID: String) {
        // Find the message by ID and update its text
        let reply = details.delta?.content?.first?.text?.value ?? ""
        let replyID = details.id ?? ""
        
        // MARK: Update Chats model
        if let index = chats.firstIndex(where: { $0.replyID == replyID }) {
            let previousReply = chats[index].reply ?? ""
            let updatedReply = previousReply + reply
            chats[index].reply = updatedReply
        } else {
            let ques = fetchQuestion(id: quesID)
            let replyDetails = OpenAIChatDetails(
                question: ques,
                questionID: quesID,
                reply: reply,
                replyID: replyID
            )
            let newReply = [replyDetails]
            let loadedChat = chats
            let cummulativeChat = newReply + loadedChat
            chats = cummulativeChat
        }
    }
    
    fileprivate func fetchQuestion(id: String) -> String {
        for chat in chats {
            if chat.questionID == id {
                return chat.question ?? ""
            }
        }
        return ""
    }
    
    fileprivate func prepareChats() {
        guard let messages = threadDetails?.messages else { return }
        var savedChats = [OpenAIChatDetails]()
        for message in messages {
            let ques = OpenAIChatDetails(
                question: message.question,
                isSavedOnServer: true,
                messageID: message.id
            )
            
            let reply = OpenAIChatDetails(
                question: message.question,
                reply: message.answer,
                isSavedOnServer: true,
                isBookmarked: message.isSaved,
                messageID: message.id
            )
            
            savedChats.append(ques)
            savedChats.append(reply)
        }
        
        // Convert the reversed collection to a regular array
        let reversedChats = Array(savedChats.reversed())
        chats = reversedChats
    }
}
