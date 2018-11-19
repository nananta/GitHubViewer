import Foundation
import os.log

extension URLSession
{
    static func fetchData<T: Codable>(from url: URL,
                                      completion: @escaping (T) -> Void)
    {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard error == nil,
                let d = data else { return }
            
            do
            {
//                let str = String(data: d, encoding: .utf8)
//                print(str)
                
                let decodedData = try JSONDecoder().decode(T.self, from: d)
                print(decodedData)
                completion(decodedData)
            }
            catch let err
            {
                os_log("JSON decoding failed: %@", type: .error, err as CVarArg)
            }
        }.resume()
    }

    static func fetchData<T: Codable>(from urlRequest: URLRequest,
                                      completion: @escaping (T) -> Void)
    {
        URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard error == nil,
                let d = data else { return }
            
            do
            {
                let data = String(data: d, encoding: .utf8)
                print("data:" + data!)
                
                let decodedData = try JSONDecoder().decode(T.self, from: d)
                print(decodedData)
                completion(decodedData)
            }
            catch let err
            {
                os_log("JSON decoding failed: %@", type: .error, err as CVarArg)
            }
            }.resume()
    }
    
    static func download(file: URL,
                         to dir: URL)
    {
        URLSession.shared.downloadTask(with: file) {
            (location, response, error) in
            
            if error != nil
            {
                os_log("%@: Downloading %@ failed with error: %@",
                       type: .error,
                       #function, file.description, error?.localizedDescription ?? "")
            }
            
            guard let downloadedURL = location else { return }

            // Create destination URL for downloaded file
            let destURL = dir.appendingPathComponent(response?.suggestedFilename ?? file.lastPathComponent)
    
            do {
                
                try FileManager.default.moveItem(at: downloadedURL, to: destURL)
                
            } catch {
                os_log("%@: FileManager.default.moveItem() failed with error: %@",
                       type: .error,
                       #function, error.localizedDescription)
            }
        }.resume()
    }
}
