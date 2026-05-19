import Foundation

extension String {
    /// Strips HTML tags and decodes HTML entities, returning plain text.
    /// Handles `<p>`, `<br>`, `<b>`, `<i>`, `<ul>`, `<li>` etc.
    var strippedHTML: String {
        // Replace block-level tags with newlines first for readable plain text
        var result = self
        let blockTags = ["</p>", "<br>", "<br/>", "<br />", "</li>", "</div>", "</h1>",
                         "</h2>", "</h3>", "</h4>", "</tr>"]
        for tag in blockTags {
            result = result.replacingOccurrences(of: tag, with: "\n", options: .caseInsensitive)
        }

        // Remove all remaining HTML tags using NSAttributedString (handles entities too)
        if let data = result.data(using: .utf8),
           let attributed = try? NSAttributedString(
               data: data,
               options: [
                   .documentType: NSAttributedString.DocumentType.html,
                   .characterEncoding: String.Encoding.utf8.rawValue
               ],
               documentAttributes: nil
           ) {
            result = attributed.string
        }

        // Collapse excessive newlines to max 2
        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
