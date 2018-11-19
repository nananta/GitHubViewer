import UIKit

class ViewController: UIViewController
{
    lazy var leftTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.textColor = .white
        tv.backgroundColor = .black
        tv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tv)
        [tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         tv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         tv.trailingAnchor.constraint(equalTo: view.centerXAnchor),
         tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)].forEach {
            $0.isActive = true
        }
        return tv
    }()
    
    lazy var rightTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.textColor = .white
        tv.backgroundColor = .black
        tv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tv)
        //        tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //        tv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        //        tv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        //        tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        [tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         tv.leadingAnchor.constraint(equalTo: view.centerXAnchor),
         tv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)].forEach {
            $0.isActive = true
        }
        return tv
    }()

    var pullReq: GitHubApi.PullRequest?
    var commitDiff: String?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        if let diff = commitDiff,
            let font = UIFont(name: "Georgia", size: 15)
        {
            leftTextView.attributedText = NSMutableAttributedString(string: diff,
                                                                       attributes: [.font : font,
                                                                                    .foregroundColor : UIColor.white,
                                                                                    .backgroundColor : UIColor.blue])
        }

//        var leftText = NSMutableAttributedString(string: "Hello!",
//                                             attributes: [.font : UIFont(name: "Georgia", size: view.frame.width * 0.05),
//                                                          .foregroundColor : UIColor.white,
//                                                          .backgroundColor : UIColor.blue,
//                                                          .strikethroughStyle : 1,
//                                                          .strikethroughColor : UIColor.red])
//        var rightText = NSMutableAttributedString(string: "\nWorld!",
//                                             attributes: [.font : UIFont(name: "Georgia", size: view.frame.width * 0.05),
//                                                          .foregroundColor : UIColor.white,
//                                                          .backgroundColor : UIColor.blue,
//                                                          .strikethroughStyle : 1,
//                                                          .strikethroughColor : UIColor.red])
//        leftTextView.attributedText = leftText
//        rightTextView.attributedText = rightText
//
//        let fontSize = view.frame.width * 0.05
//        if let url = URL(string: "https://api.github.com/repos/magicalpanda/MagicalRecord/pulls")
//        {
//            URLSession.fetchJson(from: url) {
//                (pullReqs: [GitHubApi.PullRequest]) -> Void in
//
//                if let diffUrlStr = pullReqs[0].diff_url,
//                    let diffUrl = URL(string: diffUrlStr)
//                {
//                    URLSession.fetchString(from: diffUrl) {
//                        dataStr in
//
//                        print(dataStr)
//
//                        DispatchQueue.main.async {
//                            [weak self] in
//
//                            self?.leftTextView.attributedText = NSMutableAttributedString(string: dataStr,
//                                                                                          attributes: [.font : UIFont(name: "Georgia", size: fontSize),
//                                                                                                       .foregroundColor : UIColor.white,
//                                                                                                       .backgroundColor : UIColor.blue,
//                                                                                                       .strikethroughStyle : 1,
//                                                                                                       .strikethroughColor : UIColor.red])
//                        }
//                    }
//                }
//
////                print("Pull requests: %@", pullReqs)
//
////                completion(pullReqs)
//            }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        // Set pull request title as navigation bar title
        navigationItem.title = pullReq?.title
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Add border separating text views
//        leftTextView.layer.addBorder(edge: .right, color: .white, thickness: 2)
    }
    
    private func setText(_ text: NSAttributedString)
    {
        leftTextView.attributedText = text
    }
}

