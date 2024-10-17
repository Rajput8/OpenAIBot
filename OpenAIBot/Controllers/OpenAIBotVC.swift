import UIKit

class OpenAIBotVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var newChatBtn: UIButton!
    @IBOutlet weak var queryTV: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerCellFromNib(cellID: UpdatedSenderChatCell.identifier)
            tableView.registerCellFromNib(cellID: UpdatedAIChatCell.identifier)
            tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
    
    // MARK: Variables
    fileprivate var viewModel = HomeViewModel()
    fileprivate var chats = [OpenAIChatDetails]()
    fileprivate var threadID: String = ""
    fileprivate var manuallyRaisedQuery: String = ""
    
    // MARK: Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        OpenAI.shared.eventsProtocol = self
        loadingIcon.image = UIImage.gifImageWithName("waiting")
        loadingView.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receivedAllChunks(_ :)),
                                               name: .receivedAllChunks,
                                               object: nil)
    }
    
    // MARK: IB Actions
    @IBAction func tappedNewChat(_ sender: UIButton) {
        viewModel.chatStatus = .unspecified
    }
    
    @IBAction func tappedSend(_ sender: UIButton) {
        let query = queryTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            Toast.show(message: "The query field cannot be empty.")
        } else {
            viewModel.isLocked = true
            if threadID.isEmpty {
                manuallyRaisedQuery = query
                viewModel.chatStatus = .newChat
            } else {
                raisedQuery(query)
            }
        }
    }
    
    // MARK: Shared Methods
    fileprivate func bindViewModel() {
        viewModel.$chats.sink { [weak self] resp in
            // Reload the updated cell
            DispatchQueue.main.async {
                self?.chats = resp
                self?.tableView.reloadData()
            }
        }
        .store(in: &viewModel.cancellables)
        
        viewModel.$chatStatus.sink { [weak self] status in
            switch status {
            case .newChat:
                self?.startChat()
                
            case .endChat, .unspecified:
                self?.endChart()
                self?.loadingView.isHidden = true
                
            default: break
            }
        }
        .store(in: &viewModel.cancellables)
        
        viewModel.$isLocked.sink { status in
            DispatchQueue.main.async { [weak self] in
                if status {
                    self?.sendBtn.isEnabled = false
                } else {
                    self?.sendBtn.isEnabled = true
                }
            }
        }
        .store(in: &viewModel.cancellables)
    }
    
    fileprivate func startChat() {
        chats.removeAll()
        viewModel.chats.removeAll()
        tableView.reloadData()
        
        OpenAI.shared.threadDetails{ [weak self] msg, resp in
            if let msg {
                Toast.show(message: msg)
            } else {
                self?.threadID = resp?.id ?? ""
                self?.viewModel.newCreatedThreadID = resp?.id
                if
                    let query = self?.manuallyRaisedQuery,
                    !query.isEmpty {
                    self?.raisedQuery(query)
                    self?.manuallyRaisedQuery = ""
                }
            }
        }
    }
    
    fileprivate func endChart() {
        newChatBtn.isHidden = true
        chats.removeAll()
        viewModel.chats.removeAll()
        tableView.reloadData()
        threadID = ""
        viewModel.newCreatedThreadID = ""
        viewModel.chatID = ""
        viewModel.isLocked = false
    }
    
    fileprivate func raisedQuery(_ query: String) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingView.isHidden = false
        }
        
        OpenAI.shared.createMessage(query: query,
                                    isStreamEnable: true,
                                    threadID: threadID,
                                    assistant: .paraphrased) { [weak self] msg, resp in
            DispatchQueue.main.async {
                self?.queryTV.text = ""
            }
        }
    }
    
    @objc fileprivate func receivedAllChunks(_ notify: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingView.isHidden = true
        }
        viewModel.isLocked = false
    }
}

// MARK: TableView - Delegates and DataSources
extension OpenAIBotVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let details = chats[indexPath.row]
        if let reply = details.reply, !reply.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: UpdatedAIChatCell.identifier, for: indexPath) as! UpdatedAIChatCell
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.details = details
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UpdatedSenderChatCell.identifier, for: indexPath) as! UpdatedSenderChatCell
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.contentLbl.text = details.question ?? ""
            return cell
        }
    }
}

extension OpenAIBotVC: OpenAIAPIEventsProtocol {
    
    func createdNewMessage(details: NewMessageResponse) {
        viewModel.addNewQuery(details: details)
    }
    
    func receivedNewChunk(details: ThreadMessageDeltaResponse, quesID: String) {
        viewModel.updateReply(details: details, quesID: quesID)
    }
}
