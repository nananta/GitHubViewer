import UIKit

// Manages interaction with GitHub
class GitHubManager
{
    static let repoBaseUrl = "https://api.github.com/repos/"
    
    enum httpStatus: Int
    {
        case notFound = 404
    }
    
    // Fetch repo pull requests from GitHub
    static func fetchPullRequests(for repo: String,
                                  completion: @escaping ([GitHubApi.PullRequest]?, HTTPURLResponse?, Error?) -> Void)
    {
        let pullUrl = repoBaseUrl + repo + "/pulls"
        if let url = URL(string: pullUrl)
        {
            URLSession.fetchJson(from: url) {
                (pullReqs: [GitHubApi.PullRequest]?, response, error) -> Void in
                
                completion(pullReqs, response, error)
            }
        }
        else
        {
            // Inform that repo is invalid
            completion(nil,
                       HTTPURLResponse(url: URL.init(fileURLWithPath: repo),
                                       statusCode: GitHubManager.httpStatus.notFound.rawValue,
                                       httpVersion: "",
                                       headerFields: nil),
                       nil)
        }
    }
    
     // Fetch commit diffs for a pull request from GitHub
    static func fetchCommitsDiff(for pullRequest: GitHubApi.PullRequest,
                                 completion: @escaping (GitHubApi.PullRequestDiff?, String?) -> Void)
    {
        guard let diffUrlStr = pullRequest.diff_url,
            let diffUrl = URL(string: diffUrlStr) else { return }

        URLSession.fetchData(from: diffUrl) {
            diffStr in

            var error: String?
            var prDiff: GitHubApi.PullRequestDiff?
            if diffStr.starts(with: "Sorry, this diff is unavailable")
            {
                error = diffStr
            }
            else
            {
                prDiff = parsePullRequestDiff(diffStr)
            }
            
            completion(prDiff, error)
        }
    }
    
    /*
     Parse raw pull request diff.  Example diff chunk...
         diff --git a/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m
         index bfd31a95..8ac67f48 100644
         --- a/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m
         +++ b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m
         @@ -67,7 +67,7 @@
         {
         return NULL;
         }
         -    UIColor *color = [UIColor colorWithRed:(componentValues[0] / 255.0f)
         -                                     green:(componentValues[1] / 255.0f)
         -                                      blue:(componentValues[2] / 255.0f)
         +    UIColor *color = [UIColor colorWithRed:(componentValues[0] / (CGFloat)255.)
         +                                     green:(componentValues[1] / (CGFloat)255.)
         +                                      blue:(componentValues[2] / (CGFloat)255.)
         alpha:componentValues[3]];
     */
    static func parsePullRequestDiff(_ diffStr: String) -> GitHubApi.PullRequestDiff
    {
        // Split raw diff into lines and extract info
        var prDiff = GitHubApi.PullRequestDiff(fileDiffs: [])
        var fileDiff: GitHubApi.PullRequestDiff.File?
        var sectionDiff: GitHubApi.PullRequestDiff.Section?
        var chunkDiff: GitHubApi.PullRequestDiff.Chunk?
        diffStr.lines.forEach {
            line in
            
            // Start of file diff
            if line.starts(with: "diff --git")
            {
                // Save last chunk, section and file diff
                if let chunk = chunkDiff
                {
                    sectionDiff?.chunks.append(chunk)
                    chunkDiff = nil
                }
                if let section = sectionDiff
                {
                    fileDiff?.sections.append(section)
                    sectionDiff = nil
                }
                if let fileDiff = fileDiff
                {
                    prDiff.fileDiffs?.append(fileDiff)
                }
                
                // New file diff
                fileDiff = GitHubApi.PullRequestDiff.File(filePath: nil,
                                                          newFilePath: nil,
                                                          fileStatus: .old,
                                                          sections: [])
                return
            }

            // Ignore for now
            if line.starts(with: "index") { return }
            
            // File was added
            if line.starts(with: "new file mode")
            {
                fileDiff?.fileStatus = .new
                return
            }
            
            // File was deleted
            if line.starts(with: "deleted file mode")
            {
                fileDiff?.fileStatus = .deleted
                return
            }
            
            // Similarity for renamed file, ignore for now
            // e.g. "similarity index 74%"
            if line.starts(with: "similarity index ") { return }
            
            // Old file path
            let oldFilePathTag = "rename from "
            if line.starts(with: oldFilePathTag),
                let filePathIndex = line.range(of: oldFilePathTag)?.upperBound
            {
                fileDiff?.fileStatus = .renamed
                fileDiff?.filePath = String(line[filePathIndex...])
                return
            }
            
            // New file path
            let newFilePathTag = "rename to "
            if line.starts(with: newFilePathTag),
                let filePathIndex = line.range(of: newFilePathTag)?.upperBound
            {
                fileDiff?.newFilePath = String(line[filePathIndex...])
                return
            }

            // Name of existing/deleted file
            // e.g. "--- a/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m"
            let deletedFileTag = "--- a/"
            if fileDiff?.filePath == nil,
                line.starts(with: deletedFileTag)
            {
                if line.starts(with: deletedFileTag),
                    let filePathIndex = line.range(of: deletedFileTag)?.upperBound
                {
                    fileDiff?.filePath = String(line[filePathIndex...])
                    return
                }
            }

            // Name of existing/added file
            // e.g. "+++ b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m"
            let addedFileTag = "+++ b/"
            if fileDiff?.filePath == nil,
                line.starts(with: addedFileTag),
                let filePathIndex = line.range(of: addedFileTag)?.upperBound
            {
                // Ignore if file was deleted
                guard let diff = fileDiff,
                    diff.fileStatus != .deleted else { return }
                
                fileDiff?.filePath = String(line[filePathIndex...])
                return
            }
            
            // Beginning of section diff
            // e.g. "@@ -26,8 +26,8 @@"
            let sectionDiffStart = "@@ "
            if line.starts(with: sectionDiffStart),
                let sectionInfoOffset = line.range(of: sectionDiffStart)?.upperBound
            {
                // Save previous chunk and section diffs
                if let chunk = chunkDiff
                {
                    sectionDiff?.chunks.append(chunk)
                    chunkDiff = nil
                }
                if let section = sectionDiff
                {
                    fileDiff?.sections.append(section)
                    sectionDiff = nil
                }
                
                let sectionInfo = line[sectionInfoOffset...].split(separator: " ")
                guard sectionInfo.count >= 2,
                    let oldFirstLineStr = sectionInfo[0].split(separator: ",").first,
                    let newFirstLineStr = sectionInfo[1].split(separator: ",").first,
                    let oldFirstLine = Int(oldFirstLineStr),
                    let newFirstLine = Int(newFirstLineStr) else { return }
                    
                // New chunk and section diffs
                chunkDiff = GitHubApi.PullRequestDiff.Chunk(oldLines: [],
                                                            newLines: [],
                                                            changed: false)
                sectionDiff = GitHubApi.PullRequestDiff.Section(start: line,
                                                                oldFirstLine: abs(oldFirstLine),
                                                                newFirstLine: abs(newFirstLine),
                                                                chunks: [])
                return
            }
            
            // Changed line
            // e.g. "-  green:(componentValues[1] / 255.0f)"
            if line.starts(with: "-")
            {
                // New chunk since previous chunk is unchanged or only contains new lines, save previous
                if let chunk = chunkDiff,
                    !chunk.changed
                {
                    sectionDiff?.chunks.append(chunk)
                    chunkDiff = GitHubApi.PullRequestDiff.Chunk(oldLines: [],
                                                                newLines: [],
                                                                changed: true)
                }

                // Add  changed line to chunk
                chunkDiff?.oldLines.append(line)
                chunkDiff?.changed = true
                return
            }
            
            // New line
            // e.g. "+  green:(componentValues[1] / 255.)"
            if line.starts(with: "+")
            {
                // New chunk, save previous
                if let chunk = chunkDiff,
                    !(chunk.changed || chunk.oldLines.isEmpty)
                {
                    sectionDiff?.chunks.append(chunk)
                    chunkDiff = GitHubApi.PullRequestDiff.Chunk(oldLines: [],
                                                                newLines: [],
                                                                changed: false)
                }

                // Add new line to chunk
                chunkDiff?.newLines.append(line)
                return
            }
            
            // Not sure what this line indicates, ignore for now
            if line.starts(with: "\\ No newline at end of file")
            {
                return
            }
            
            // New chunk, save previous
            if let chunk = chunkDiff,
                chunk.changed || !chunk.newLines.isEmpty
            {
                sectionDiff?.chunks.append(chunk)
                chunkDiff = GitHubApi.PullRequestDiff.Chunk(oldLines: [],
                                                            newLines: [],
                                                            changed: false)
            }

            // Add unchanged line
            chunkDiff?.oldLines.append(line)
        }
        
        // Save last chunk, section and file diff
        if let chunk = chunkDiff
        {
            sectionDiff?.chunks.append(chunk)
            chunkDiff = nil
        }
        if let section = sectionDiff
        {
            fileDiff?.sections.append(section)
            sectionDiff = nil
        }
        if let fileDiff = fileDiff
        {
            prDiff.fileDiffs?.append(fileDiff)
        }
        
//        print(diffStr.lines)

        return prDiff
    }
}
