import UIKit

extension UIDevice
{
    func isPortrait() -> Bool
    {
        return orientation.isValidInterfaceOrientation
            ? orientation.isPortrait
            : UIApplication.shared.statusBarOrientation.isPortrait
    }
    
    func iPhone() -> Bool
    {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}


