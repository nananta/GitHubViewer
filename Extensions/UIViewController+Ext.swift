import UIKit

extension UIViewController
{
    @discardableResult func dismissKeyboardWhenTouchOutside() -> UITapGestureRecognizer
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        return tap
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }

    func isVisible() -> Bool
    {
        return viewIfLoaded?.window != nil
    }
}
