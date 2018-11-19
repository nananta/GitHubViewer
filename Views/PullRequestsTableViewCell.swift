import UIKit

class PullRequestsTableViewCell: UITableViewCell
{
    var pullRequest: GitHubApi.PullRequest?
    
    let leadingAnchorOffset: CGFloat = 15
    let widthAnchorRatio: CGFloat = 0.95
    
    // Pull request title
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.backgroundColor = .clear
        title.textColor = .black
        // Support scaling to user's content size category
        title.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Verdana-Bold", size: 18) ?? UIFont.preferredFont(forTextStyle: .body))
        title.numberOfLines = 0
        // Pin to top left of cell
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        [title.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthAnchorRatio),
         title.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
         title.topAnchor.constraint(equalTo: topAnchor, constant: 2),
         title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingAnchorOffset)].forEach { $0.isActive = true }
        return title
    }()
    
    // Pull request description
    lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        description.backgroundColor = .clear
        description.textColor = .black
        // Support scaling to user's content size category
        description.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Verdana-Italic", size: 16) ?? UIFont.preferredFont(forTextStyle: .body))
        description.numberOfLines = 0
        // Pin to bottom left of cell
        description.translatesAutoresizingMaskIntoConstraints = false
        addSubview(description)
        [description.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthAnchorRatio),
         description.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
         description.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
         description.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingAnchorOffset)].forEach { $0.isActive = true }
        return description
    }()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup()
    {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    class func reuseId() -> String { return String(describing: PullRequestsTableViewCell.self) }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        titleLabel.text = pullRequest?.title
        
        guard let pr = pullRequest,
        let prNum = pr.number,
        let prUser = pr.user?.login,
        let createdDateStr = pr.created_at,
        let createdDate = createdDateStr.date(format: "yyyy-MM-dd'T'HH:mm:ssZ") else { return }
        
        // Convert created date
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        
        descriptionLabel.text = "#" + String(prNum)
            + " opened on " + df.string(from: createdDate)
            + " by " + prUser
    }
}

