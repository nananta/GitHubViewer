import Foundation

class GitHubManager
{
    static let repoBaseUrl = "https://api.github.com/repos/"
    
    // Fetch repo pull requests from GitHub
    static func fetchPullRequests(for repo: String,
                                  completion: @escaping ([GitHubApi.PullRequest]) -> Void)
    {
        let pullUrl = repoBaseUrl + repo + "/pulls"
//        if let url = URL(string: "https://api.github.com/repos/magicalpanda/MagicalRecord/pulls")
        if let url = URL(string: pullUrl)
        {
            URLSession.fetchJson(from: url) {
                (pullReqs: [GitHubApi.PullRequest]) -> Void in
                completion(pullReqs)
            }
        }
    }
    
    // Fetch commit diffs for a pull request from GitHub.  Example diff chunk...
    //    diff --git a/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m
    //    index bfd31a95..8ac67f48 100644
    //    --- a/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m
    //    +++ b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m
    //    @@ -67,7 +67,7 @@
    //         {
    //              return NULL;
    //         }
    //    -    UIColor *color = [UIColor colorWithRed:(componentValues[0] / 255.0f)
    //    -                                     green:(componentValues[1] / 255.0f)
    //    -                                      blue:(componentValues[2] / 255.0f)
    //    +    UIColor *color = [UIColor colorWithRed:(componentValues[0] / (CGFloat)255.)
    //    +                                     green:(componentValues[1] / (CGFloat)255.)
    //    +                                      blue:(componentValues[2] / (CGFloat)255.)
    //         alpha:componentValues[3]];
    static func fetchCommitsDiff(for pullRequest: GitHubApi.PullRequest,
                                 completion: @escaping (GitHubApi.PullRequestDiff) -> Void)
    {
        guard let diffUrlStr = pullRequest.diff_url,
            let diffUrl = URL(string: diffUrlStr) else { return }

        URLSession.fetchString(from: diffUrl) {
            diffStr in

            // Split raw diff into lines and extract info
            var prDiff = GitHubApi.PullRequestDiff(fileDiffs: [])
            var fileDiff: GitHubApi.PullRequestDiff.File?
            var chunkDiff: GitHubApi.PullRequestDiff.CodeChunk?
            diffStr.lines.forEach {
                line in
                
                // Beginning of diffs for a file
                // e.g. "+++ b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m"
                let fileDiffStart = "+++ b/"
                if line.starts(with: fileDiffStart),
                    let filePathIndex = line.range(of: fileDiffStart)?.upperBound
                {
                    // Save previous file diff
                    if let fileDiff = fileDiff
                    {
                        prDiff.fileDiffs?.append(fileDiff)
                    }
                    
                    // New file diff
                    fileDiff = GitHubApi.PullRequestDiff.File(filePath: nil, chunks: [])
                    fileDiff?.filePath = String(line[filePathIndex...])
                    return
                }
                
                // Beginning of diff chunk
                // e.g. "@@ -26,8 +26,8 @@"
                let diffChunkStart = "@@ -"
                if line.starts(with: diffChunkStart),
                    let firstLineIndex = line.range(of: diffChunkStart)?.upperBound,
                    let firstLineNumStr = line[firstLineIndex...].split(separator: ",").first,
                    let firstLineNum = Int(firstLineNumStr)
                {
                    // Save previous code chunk diff
                    if let chunkDiff = chunkDiff
                    {
                        fileDiff?.chunks?.append(chunkDiff)
                    }
                    
                    // New code chunk diff
                    chunkDiff = GitHubApi.PullRequestDiff.CodeChunk()
                    chunkDiff?.start = line
                    chunkDiff?.firstLineNum = abs(firstLineNum)
                    chunkDiff?.lines = []
                    return
                }

                // Beginning of old line
                // e.g. "-  green:(componentValues[1] / 255.0f)"
                let oldLineStart = "-\t"
                if line.starts(with: oldLineStart)
                {
                    chunkDiff?.lines?.append(GitHubApi.PullRequestDiff.LineDiff(old: line, new: nil))
                    return
                }
                
                // Beginning of new line
                // e.g. "+  green:(componentValues[1] / 255.)"
                let newLineStart = "+\t"
                if line.starts(with: newLineStart)
                {
                    chunkDiff?.lines?.append(GitHubApi.PullRequestDiff.LineDiff(old: nil, new: line))
                    return
                }

                // Unchanged line
                chunkDiff?.lines?.append(GitHubApi.PullRequestDiff.LineDiff(old: line, new: nil))
                
            }

            // Save last file chunk diff
            if let chunkDiff = chunkDiff
            {
                fileDiff?.chunks?.append(chunkDiff)
            }
            
            // Save last file diff
            if let fileDiff = fileDiff
            {
                prDiff.fileDiffs?.append(fileDiff)
            }

            print(diffStr.lines)
            
            completion(prDiff)
        }
    }
}
