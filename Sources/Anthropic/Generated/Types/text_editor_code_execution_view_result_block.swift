// Transformed from `anthropic.types.text_editor_code_execution_view_result_block` (text_editor_code_execution_view_result_block.py).

import Foundation

public struct TextEditorCodeExecutionViewResultBlock: Codable, Hashable, Sendable {
    public var content: String
    public var fileType: FileType
    public var numLines: Int?
    public var startLine: Int?
    public var totalLines: Int?
    public var type: String

    public init(content: String, fileType: FileType, numLines: Int? = nil, startLine: Int? = nil, totalLines: Int? = nil, type: String = "text_editor_code_execution_view_result") {
        self.content = content
        self.fileType = fileType
        self.numLines = numLines
        self.startLine = startLine
        self.totalLines = totalLines
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case fileType = "file_type"
        case numLines = "num_lines"
        case startLine = "start_line"
        case totalLines = "total_lines"
        case type
    }

    public enum FileType: OpenEnum, CaseIterable {
        case text
        case image
        case pdf
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [FileType] = [.text, .image, .pdf]

        public init(rawValue: String) {
            switch rawValue {
            case "text": self = .text
            case "image": self = .image
            case "pdf": self = .pdf
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .text: return "text"
            case .image: return "image"
            case .pdf: return "pdf"
            case .unknown(let value): return value
            }
        }
    }
}
