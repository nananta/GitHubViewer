import UIKit


extension UISearchBar
{
    func removeBgView()
    {
        guard let searchBarBgClass = NSClassFromString("UISearchBarBackground") else { return }
        
        // Remove background view(s) from first subview
        subviews.first?.subviews.filter { $0.isKind(of: searchBarBgClass) }.forEach {
            // TODO: Do we actually need to handle removing multiple bg views?
            $0.removeFromSuperview()
        }
        
//        if let view:UIView = self.subviews.first
//        {
//            for curr in view.subviews
//            {
//                if curr.isKind(of: searchBarBgClass)
//                {
//                    if let imageView = curr as? UIImageView
//                    {
//                        imageView.removeFromSuperview()
//                        break
//                    }
//                }
//            }
//        }
    }
    
    func textField() -> UITextField?
    {
        guard let searchTextFieldClass = NSClassFromString("UISearchBarTextField") else { return nil }
    
        return subviews.first?.subviews.filter { $0.isKind(of: searchTextFieldClass) }.first as? UITextField
    }

    func textFieldBgView() -> UIView?
    {
        guard let searchTextFieldBgClass = NSClassFromString("_UISearchBarSearchFieldBackgroundView") else { return nil }
        
        return textField()?.subviews.filter { $0.isKind(of: searchTextFieldBgClass) }.first
    }
    
    //    func textFieldImageView() -> UIImageView?
    //    {
    //        return textField()?.subviews.filter { $0.isKind(of: UIImageView.self) }.first as? UIImageView
    //    }
    
    //_UITextFieldContentView
}
