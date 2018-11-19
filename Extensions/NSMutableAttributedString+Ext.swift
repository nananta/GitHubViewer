import UIKit

extension NSMutableAttributedString
{
    func appendNewLine(_ count: Int = 1)
    {
        var newLineStr = ""
        for _ in 0..<count
        {
            newLineStr += "\n"
        }
        append(NSAttributedString(string: newLineStr))
    }
    
    func appendInvisibleString(_ string: String)
    {
        append(NSAttributedString(string: string,
                                  attributes: [.foregroundColor : UIColor.clear]))
    }
}
