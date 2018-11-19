import UIKit

// Displays commit diffs for a pull request(with left view showing old content and right view showing new content)
class PullRequestDiffVC: UIViewController
{
    let textViewBgColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    
    // Left text view displaying old content
    lazy var oldTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.textColor = .white
        tv.backgroundColor = textViewBgColor
        tv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tv)
        [tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         tv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         tv.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -1),
         tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)].forEach {
            $0.isActive = true
        }
        return tv
    }()
    
    // Right text view displaying new content
    lazy var newTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.textColor = .white
        tv.backgroundColor = textViewBgColor
        tv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tv)
        [tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         tv.leadingAnchor.constraint(equalTo: view.centerXAnchor),
         tv.widthAnchor.constraint(equalTo: oldTextView.widthAnchor),
         tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)].forEach {
            $0.isActive = true
        }
        return tv
    }()

    var pullReq: GitHubApi.PullRequest?
    var diffs: GitHubApi.PullRequestDiff?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
        oldTextView.delegate = self
        newTextView.delegate = self
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
        
        displayDiffs()
    }
    
    // Display pull request commit diffs
    private func displayDiffs()
    {
        guard let prDiff = diffs else { return }
        
        let oldText = NSMutableAttributedString()
        let newText = NSMutableAttributedString()
        let normalTextColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        let oldTextBgColor = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
        let newTextBgColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)

        oldText.beginEditing()
        newText.beginEditing()
        
        // Diffs for file(s)
        prDiff.fileDiffs?.forEach {
            fileDiff in
            
            guard let filePath = fileDiff.filePath else { return }
            
            // Create file path description
            var filePathDesc = filePath
            if let newFilePath = fileDiff.newFilePath
            {
                filePathDesc += " -> " + newFilePath
            }
            filePathDesc += fileDiff.fileStatus.rawValue
            
            // Add file path to old text
            oldText.appendNewLine()
            oldText.append(NSAttributedString(string: filePathDesc,
                                              attributes: [.foregroundColor : #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)]))
            oldText.appendNewLine()
            
            // Add invisible text to new text so that views align
            newText.appendNewLine()
            newText.appendInvisibleString(filePathDesc)
            newText.appendNewLine()
            
            // Deleted file
            if fileDiff.fileStatus == .deleted
            {
                let deletedMsg = "\nFile was deleted\n"
                oldText.append(NSAttributedString(string: deletedMsg,
                                                  attributes: [.foregroundColor : UIColor.red]))
                // Add invisible text to new text so that views align
                newText.appendInvisibleString(deletedMsg)
                return
            }
            
            // Section diffs in file
            fileDiff.sections.forEach {
                section in
                
                // Add text indicating start of section diff
                if let sectionStart = section.start
                {
                    oldText.appendNewLine()
                    oldText.append(NSAttributedString(string: sectionStart,
                                                      attributes: [.foregroundColor : #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)]))
                    oldText.appendNewLine(2)
                    // Add invisible text to new text so that views align
                    newText.appendNewLine()
                    newText.appendInvisibleString(sectionStart)
                    newText.appendNewLine(2)
                }
                
                // Chunk diffs in section
                var oldTextLineNum = section.oldFirstLine
                var newTextLineNum = section.newFirstLine
                section.chunks.forEach {
                    chunk in
                    
                    let lines = chunk.oldLines.count > chunk.newLines.count ? chunk.oldLines.count : chunk.newLines.count
                    
                    // No changes in chunk, add lines to both old and new text
                    if !chunk.changed
                        && chunk.newLines.isEmpty
                    {
                        chunk.oldLines.forEach {
                            oldText.append(NSAttributedString(string: lineNumberString(oldTextLineNum) + $0 + "\n",
                                                              attributes: [.foregroundColor : normalTextColor,
                                                                           .backgroundColor : textViewBgColor]))
                            newText.append(NSAttributedString(string: lineNumberString(newTextLineNum) + $0 + "\n",
                                                              attributes: [.foregroundColor : normalTextColor,
                                                                           .backgroundColor : textViewBgColor]))
                            oldTextLineNum += 1
                            newTextLineNum += 1
                        }
                        return
                    }
                    
                    // Add previous and new lines
                    for i in 0..<lines
                    {
                        // Add previous lines
                        if chunk.oldLines.indices.contains(i)
                        {
                            // Add previous line to old text
                            oldText.append(NSAttributedString(string: lineNumberString(oldTextLineNum) + chunk.oldLines[i] + "\n",
                                                              attributes: [.foregroundColor : normalTextColor,
                                                                           .backgroundColor : oldTextBgColor]))
                            oldTextLineNum += 1
                        }
                        else if chunk.newLines.indices.contains(i)
                        {
                            // Add invisible new text so that views align
                            oldText.appendInvisibleString(lineNumberString(newTextLineNum) + chunk.newLines[i] + "\n")
                        }

                        // Add new lines
                        if chunk.newLines.indices.contains(i)
                        {
                            // Add new line to new text
                            newText.append(NSAttributedString(string: lineNumberString(newTextLineNum) + chunk.newLines[i] + "\n",
                                                              attributes: [.foregroundColor : normalTextColor,
                                                                           .backgroundColor : newTextBgColor]))
                            newTextLineNum += 1
                        }
                        else if chunk.oldLines.indices.contains(i)
                        {
                            // Add invisible old text so that views align
                            newText.appendInvisibleString(lineNumberString(oldTextLineNum) + chunk.oldLines[i] + "\n")
                        }
                    }
                }
            }
            
            // Set text font
            if let font = UIFont(name: "Georgia",
                                 size: UIDevice.current.iPhone() ? 12 : 14)
            {
                [oldText, newText].forEach { $0.addAttributes([.font : font], range: NSMakeRange(0, $0.string.count)) }
            }
        }
        
        oldText.endEditing()
        newText.endEditing()
        
        // Add diff text to views
        oldTextView.attributedText = oldText
        newTextView.attributedText = newText
    }
    
    private func lineNumberString(_ lineNum: Int) -> String
    {
        return String(lineNum) + " "
    }
}

extension PullRequestDiffVC: UITextViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Synchronize scrolling for text views
        if scrollView == oldTextView
        {
            newTextView.contentOffset = oldTextView.contentOffset
        }
        else
        {
            oldTextView.contentOffset = newTextView.contentOffset
        }
    }
}
