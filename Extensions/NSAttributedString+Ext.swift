import UIKit

extension NSAttributedString
{
    // Number of expected lines when displayed in view
    func numberOfLines(in textView: UITextView,
                       font: UIFont) -> Int
    {
        //        let maxSize = CGSize(width: view.frame.size.width, height: CGFloat(Float.infinity))
        //        let lineHeight = font.lineHeight
        //        let viewSize = boundingRect(with: maxSize,
        //                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
        //                                    context: nil)
        //        return Int(ceil(viewSize.height / lineHeight))
        
        // Calculate expected number of lines
        // Not an ideal solution but "boundingRect"(above) seems to be broken per...
        // https://stackoverflow.com/questions/13621084/boundingrectwithsize-for-nsattributedstring-returning-wrong-size
        let lineHeight = font.lineHeight
        textView.attributedText = self
        let tvSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        return Int(ceil(tvSize.height / lineHeight))
    }
}
