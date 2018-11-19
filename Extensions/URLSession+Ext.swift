import Foundation
import os.log

extension URLSession
{
    // Fetch json data and decode
    static func fetchJson<T: Codable>(from url: URL,
                                      completion: @escaping (T?, HTTPURLResponse?, Error?) -> Void)
    {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if let err = error
            {
                os_log("%@: Received error %@ for url %@",
                       type: .error,
                       #function, err.localizedDescription, url.description)
                return
            }
            
            decodeJson(data: data, response: response as? HTTPURLResponse, error: error, completion: completion)
        }.resume()
    }

    // Fetch json data and decode
    static func fetchJson<T: Codable>(from urlRequest: URLRequest,
                                      completion: @escaping (T?, HTTPURLResponse?, Error?) -> Void)
    {
        URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            if let err = error
            {
                os_log("%@: Received error %@ for url request %@",
                       type: .error,
                       #function, err.localizedDescription, urlRequest.description)
                return
            }
            
            decodeJson(data: data, response: response as? HTTPURLResponse, error: error, completion: completion)
        }.resume()
    }
    
    // Decode json and call completion handler
    private static func decodeJson<T: Codable>(data: Data?,
                                               response: HTTPURLResponse?,
                                               error: Error?,
                                               completion: @escaping (T?, HTTPURLResponse?, Error?) -> Void)
    {
        guard let data = data else { return }

        do
        {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            completion(decoded, response, error)
        }
        catch let err
        {
            os_log("JSON decoding failed: %@", type: .error, err as CVarArg)
            completion(nil, response, error)
        }
    }
    
    // Fetch raw data from URL
    static func fetchData(from url: URL,
                          completion: @escaping (String) -> Void)
    {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard error == nil,
                let data = data else { return }
            
            if let dataStr = String(data: data, encoding: .utf8)
            {
//                print("data:" + data)
                completion(dataStr)
            }
            else
            {
                os_log("%@: Failed to decode string from response: %@",
                       type: .error,
                       #function, response.debugDescription)
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
