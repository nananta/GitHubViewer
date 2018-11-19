import XCTest
@testable import GitHubViewer

class GitHubManagerTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
    }

    override func tearDown()
    {
        super.tearDown()
    }
    
    func testParsePullRequestDiff()
    {
        // Create example diff from GitHub, parse and validate results
        let diffStr = "diff --git a/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m\n"
        + "index bfd31a95..8ac67f48 100644\n"
        + "--- a/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m\n"
        + "+++ b/MagicalRecord/Categories/DataImport/MagicalImportFunctions.m\n"
        + "@@ -67,7 +70,7 @@\n"
        + "{\n"
        + "    return NULL;"
        + "}\n"
        + "- \n"
        + "+ \n"
        + "if ([colorType hasPrefix:@\"rgba\"])\n"
        + "{\n"
        + "    NSCharacterSet *rgbaCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@\"(,)\"];\n"
        + "@@ -94,9 +100,9 @@\n"
        + "   return nil;\n"
        + "}\n"
        + "\n"
        + "-    UIColor *color = [UIColor colorWithRed:(componentValues[0] / 255.0f)\n"
        + "-                                     green:(componentValues[1] / 255.0f)\n"
        + "-                                      blue:(componentValues[2] / 255.0f)\n"
        + "+    UIColor *color = [UIColor colorWithRed:(componentValues[0] / (CGFloat)255.)\n"
        + "+                                     green:(componentValues[1] / (CGFloat)255.)\n"
        + "+                                      blue:(componentValues[2] / (CGFloat)255.)\n"
        let diff = GitHubManager.parsePullRequestDiff(diffStr)

        // Validate file
        XCTAssert(diff.fileDiffs != nil)
        XCTAssert(diff.fileDiffs!.count == 1)
        let expectedFile = "MagicalRecord/Categories/DataImport/MagicalImportFunctions.m"
        XCTAssert(diff.fileDiffs![0].filePath == expectedFile)
        XCTAssert(diff.fileDiffs![0].fileStatus == .old)
        
        // Validate sections and chunks
        XCTAssert(diff.fileDiffs![0].sections.count == 2)
        XCTAssert(diff.fileDiffs![0].sections[0].start == "@@ -67,7 +70,7 @@")
        XCTAssert(diff.fileDiffs![0].sections[0].oldFirstLine == 67)
        XCTAssert(diff.fileDiffs![0].sections[0].newFirstLine == 70)
        XCTAssert(diff.fileDiffs![0].sections[1].start == "@@ -94,9 +100,9 @@")
        XCTAssert(diff.fileDiffs![0].sections[1].oldFirstLine == 94)
        XCTAssert(diff.fileDiffs![0].sections[1].newFirstLine == 100)
        XCTAssert(diff.fileDiffs![0].sections[0].chunks.count == 3)
        XCTAssert(diff.fileDiffs![0].sections[1].chunks.count == 2)
    }

    func testPerformanceExample()
    {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
