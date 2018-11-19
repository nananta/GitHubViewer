import Foundation

struct GitHubApi
{
    struct User: Codable
    {
        let login: String?
        let id: Int?
        let node_id: String?
        let avatar_url: String?
        let gravatar_id: String?
        let url: String?
        let html_url: String?
        let followers_url: String?
        let following_url: String?
        let gists_url: String?
        let starred_url: String?
        let subscriptions_url: String?
        let organizations_url: String?
        let repos_url: String?
        let events_url: String?
        let received_events_url: String?
        let type: String?
        let site_admin: Bool?
    }
    
    struct Team: Codable
    {
        let id: Int?
        let node_id: String?
        let url: String?
        let name: String?
        let slug: String?
        let description: String?
        let privacy: String?
        let permission: String?
        let members_url: String?
        let repositories_url: String?
        let parent: String?
    }
    
    struct Label: Codable
    {
        let id: Int?
        let node_id: String?
        let url: String?
        let name: String?
        let description: String?
        let color: String?
        let `default`: Bool?
    }
    
    struct License: Codable
    {
        let key: String?
        let name: String?
        let spdx_id: String?
        let url: String?
        let node_id: String?
    }
    
    struct Repo: Codable
    {
        let id: Int?
        let node_id: String?
        let name: String?
        let full_name: String?
        let `private`: Bool?
        let owner: User?
        let html_url: String?
        let description: String?
        let fork: Bool?
        let url: String?
        let forks_url: String?
        let keys_url: String?
        let collaborators_url: String?
        let teams_url: String?
        let hooks_url: String?
        let issue_events_url: String?
        let events_url: String?
        let assignees_url: String?
        let branches_url: String?
        let tags_url: String?
        let blobs_url: String?
        let git_tags_url: String?
        let git_refs_url: String?
        let trees_url: String?
        let statuses_url: String?
        let languages_url: String?
        let stargazers_url: String?
        let contributors_url: String?
        let subscribers_url: String?
        let subscription_url: String?
        let commits_url: String?
        let git_commits_url: String?
        let comments_url: String?
        let issue_comment_url: String?
        let contents_url: String?
        let compare_url: String?
        let merges_url: String?
        let archive_url: String?
        let downloads_url: String?
        let issues_url: String?
        let pulls_url: String?
        let milestones_url: String?
        let notifications_url: String?
        let labels_url: String?
        let releases_url: String?
        let deployments_url: String?
        let created_at: String?
        let updated_at: String?
        let pushed_at: String?
        let git_url: String?
        let ssh_url: String?
        let clone_url: String?
        let svn_url: String?
        let homepage: String?
        let size: Int?
        let stargazers_count: Int?
        let watchers_count: Int?
        let language: String?
        let has_issues: Bool?
        let has_projects: Bool?
        let has_downloads: Bool?
        let has_wiki: Bool?
        let has_pages: Bool?
        let forks_count: Int?
        let mirror_url: String?
        let archived: Bool?
        let open_issues_count: Int?
        let license: License?
        let forks: Int?
        let open_issues: Int?
        let watchers: Int?
        let default_branch: String?
    }
    
    struct Branch: Codable
    {
        let label: String?
        let ref: String?
        let sha: String?
        let user: User?
        let repo: Repo?
    }
    
    struct Links: Codable
    {
        let `self`: Link?
        let html: Link?
        let issue: Link?
        let comments: Link?
        let review_comments: Link?
        let review_comment: Link?
        let commits: Link?
        let statuses: Link?
    }
    
    struct Link: Codable
    {
        let href: String?
    }
    
    struct Milestone: Codable
    {
        let url: String?
        let html_url: String?
        let labels_url: String?
        let id: Int?
        let node_id: String?
        let number: Int?
        let state: String?
        let title: String?
        let description: String?
        let creator: User?
        let open_issues: Int?
        let closed_issues: Int?
        let created_at: String?
        let updated_at: String?
        let closed_at: String?
        let due_on: String?
    }

    struct PullRequest: Codable
    {
        let url: String?
        let id: Int?
        let node_id: String?
        let html_url: String?
        let diff_url: String?
        let patch_url: String?
        let issue_url: String?
        let number: Int?
        let state: String?
        let locked: Bool?
        let title: String?
        let user: User?
        let body: String?
        let created_at: String?
        let updated_at: String?
        let closed_at: String?
        let merged_at: String?
        let merge_commit_sha: String?
        let assignee: User?
        let assignees: [User]?
        let requested_reviewers: [User]?
        let requested_teams: [Team]?
        let labels: [Label]?
        let milestone: Milestone?
        let commits_url: String?
        let review_comments_url: String?
        let review_comment_url: String?
        let comments_url: String?
        let statuses_url: String?
        let head: Branch?
        let base: Branch?
        let _links: Links?
        let author_association: String?

// TODO: Replace JSON names with nicer ones :)
//        enum CodingKeys: String, CodingKey
//        {
//            case url, id
//
//            case nodeId = "node_id"
//            case htmlUrl = "html_url"
//            case authorAssociation = "author_association"
//        }
    }
    
    /*
     Contains commit diffs in a pull request. Example diff chunk...
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
    struct PullRequestDiff
    {
        enum fileStatus: String
        {
            case old = ""
            case new = "(new)"
            case deleted = "(deleted)"
            case renamed = "(renamed)"
        }
        
        struct Chunk
        {
            var oldLines: [String]  // Current/previous lines
            var newLines: [String]  // If empty, chunk is unchanged
            var changed: Bool
        }
        
        struct Section
        {
            var start: String?      // e.g. "@@ -67,7 +67,7 @@" above
            var oldFirstLine: Int   // First line number for old content
            var newFirstLine: Int   // First line number for new content
            var chunks: [Chunk]
        }

        struct File
        {
            var filePath: String?
            var newFilePath: String?    // If set, file was renamed
            var fileStatus: fileStatus
            var sections: [Section]
        }
        
        var fileDiffs: [File]?
    }
}

