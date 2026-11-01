// Transformed from `anthropic.types.beta.beta_tool_computer_use_20251124` (beta_tool_computer_use_20251124.py).

import Foundation

public struct BetaToolComputerUse20251124: Codable, Hashable, Sendable {
    /// The height of the display in pixels.
    public var displayHeightPx: Int
    /// The width of the display in pixels.
    public var displayWidthPx: Int
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var type: String
    public var allowedCallers: [AllowedCallers]?
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeral?
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// The X11 display number (e.g. 0, 1) for the display.
    public var displayNumber: Int?
    /// Whether to enable an action to take a zoomed-in screenshot of the screen.
    public var enableZoom: Bool?
    public var inputExamples: [[String: JSONValue]]?
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?

    public init(displayHeightPx: Int, displayWidthPx: Int, name: String = "computer", type: String = "computer_20251124", allowedCallers: [AllowedCallers]? = nil, cacheControl: BetaCacheControlEphemeral? = nil, deferLoading: Bool? = nil, displayNumber: Int? = nil, enableZoom: Bool? = nil, inputExamples: [[String: JSONValue]]? = nil, strict: Bool? = nil) {
        self.displayHeightPx = displayHeightPx
        self.displayWidthPx = displayWidthPx
        self.name = name
        self.type = type
        self.allowedCallers = allowedCallers
        self.cacheControl = cacheControl
        self.deferLoading = deferLoading
        self.displayNumber = displayNumber
        self.enableZoom = enableZoom
        self.inputExamples = inputExamples
        self.strict = strict
    }

    enum CodingKeys: String, CodingKey {
        case displayHeightPx = "display_height_px"
        case displayWidthPx = "display_width_px"
        case name
        case type
        case allowedCallers = "allowed_callers"
        case cacheControl = "cache_control"
        case deferLoading = "defer_loading"
        case displayNumber = "display_number"
        case enableZoom = "enable_zoom"
        case inputExamples = "input_examples"
        case strict
    }

    public enum AllowedCallers: OpenEnum, CaseIterable {
        case direct
        case codeExecution20250825
        case codeExecution20260120
        case codeExecution20260521
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [AllowedCallers] = [.direct, .codeExecution20250825, .codeExecution20260120, .codeExecution20260521]

        public init(rawValue: String) {
            switch rawValue {
            case "direct": self = .direct
            case "code_execution_20250825": self = .codeExecution20250825
            case "code_execution_20260120": self = .codeExecution20260120
            case "code_execution_20260521": self = .codeExecution20260521
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .direct: return "direct"
            case .codeExecution20250825: return "code_execution_20250825"
            case .codeExecution20260120: return "code_execution_20260120"
            case .codeExecution20260521: return "code_execution_20260521"
            case .unknown(let value): return value
            }
        }
    }
}
