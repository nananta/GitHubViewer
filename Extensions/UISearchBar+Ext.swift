import UIKit


extension UISearchBar
{
    func bgView() -> UIView?
    {
        guard let searchBarBgClass = NSClassFromString("UISearchBarBackground") else { return nil }
        
        // Remove background view
        return subviews.first?.subviews.filter { $0.isKind(of: searchBarBgClass) }.first
    }

    func removeBgView()
    {
        guard let searchBarBgClass = NSClassFromString("UISearchBarBackground") else { return }
        
        // Remove background view
        subviews.first?.subviews.filter { $0.isKind(of: searchBarBgClass) }.forEach {
            $0.removeFromSuperview()
        }
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
}
