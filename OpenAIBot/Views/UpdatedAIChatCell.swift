import UIKit

class UpdatedAIChatCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var contentMainView: UIView!
    @IBOutlet weak var contentLbl: UILabel!
    
    // MARK: Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var details: OpenAIChatDetails? {
        didSet {
            guard let details else { return }
            //contentLbl.text = details.reply ?? ""
            let reply = details.reply ?? ""
            contentLbl.attributedText = reply.createAttributedString()
        }
    }
    
    // MARK: Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: IB Actions
    
    // MARK: Shared Methods
}
