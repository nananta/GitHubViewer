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

    func is3DTouchAvailable() -> Bool
    {
        return self.traitCollection.forceTouchCapability == .available
    }

    func presentPopover(_ vcId: String,
                        delegate: UIPopoverPresentationControllerDelegate)
    {
        // Present VC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: vcId)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect = self.view.bounds
        vc.popoverPresentationController?.delegate = delegate
        present(vc, animated: true)
    }
    
    func isVisible() -> Bool
    {
        return viewIfLoaded?.window != nil
    }
    
    func addNavigationButton(_ button: UIBarButtonItem,
                             left: Bool,
                             add: Bool,
                             insertInFront: Bool = false)
    {
        // Dispatching to get rid of warnings...
        // https://stackoverflow.com/questions/40043786/ios-10-snapshotting-a-view-that-has-not-been-rendered-results-in-an-empty-snapsh
//        DispatchQueue.main.async {
            if add
            {
                self.navigationItem.addButton(left: left, button: button, insertInFront: insertInFront)
            }
            else
            {
                self.navigationItem.removeButtons(left: left, buttons: [button])
                
            }
//        }
    }
}
