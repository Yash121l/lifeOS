import Foundation

extension String {
    /// Strips basic HTML tags often found in Google Calendar descriptions and converts them cleanly to plain text.
    func strippingHTMLAndFormatting() -> String {
        var str = self
        
        // 1. Convert common break tags to actual newlines
        str = str.replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive)
        str = str.replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive)
        str = str.replacingOccurrences(of: "<br />", with: "\n", options: .caseInsensitive)
        
        // 2. Convert paragraph breaks to double newlines
        str = str.replacingOccurrences(of: "</p>", with: "\n\n", options: .caseInsensitive)
        
        // 3. Convert list items to bullet points
        str = str.replacingOccurrences(of: "<li>", with: "• ", options: .caseInsensitive)
        str = str.replacingOccurrences(of: "</li>", with: "\n", options: .caseInsensitive)
        
        // 4. Strip out any remaining HTML tags safely using Regex
        let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive)
        if let regex = regex {
            let range = NSRange(location: 0, length: str.utf16.count)
            str = regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: "")
        }
        
        // 5. Decode basic HTML entities (e.g. &nbsp; -> space, &amp; -> &)
        str = str.replacingOccurrences(of: "&nbsp;", with: " ")
        str = str.replacingOccurrences(of: "&amp;", with: "&")
        str = str.replacingOccurrences(of: "&lt;", with: "<")
        str = str.replacingOccurrences(of: "&gt;", with: ">")
        str = str.replacingOccurrences(of: "&quot;", with: "\"")
        str = str.replacingOccurrences(of: "&#39;", with: "'")
        
        // 6. Cleanup multiple sequential newlines more than 2
        let multipleNewlinesRegex = try? NSRegularExpression(pattern: "\\n{3,}", options: [])
        if let multipleRegex = multipleNewlinesRegex {
            let range = NSRange(location: 0, length: str.utf16.count)
            str = multipleRegex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: "\n\n")
        }
        
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
