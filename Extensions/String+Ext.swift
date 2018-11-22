import UIKit

extension String
{
    var lines: [String] {
        return split { String($0).rangeOfCharacter(from: .newlines) != nil }.map(String.init)
    }
    
    func date(format: String) -> Date?
    {
        let df = DateFormatter()
        df.dateFormat = format
        return df.date(from: self)
    }
}
