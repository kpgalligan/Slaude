// Port of `anthropic/lib/tools/_toolsets/_base.py`: what the toolset families share — the member registry, the
// options resolved at construction, the stages of a member call every family runs, and the serialized call loop.
//
// A family (`Browser.swift`, `Computer.swift`) supplies its registry and its abstract class; the pipeline stages
// that are its own (the browser's URL and file policies, its state report) sit beside them.
//
// Python finds the members a driver implements by comparing method identities against the abstract class's own
// bodies. Swift cannot see whether a subclass overrides a method, so a driver declares them: `implementedMembers`
// lists the member methods it overrides, and `overridesExecute` says that it overrides `execute`.

import Foundation

/// Fields set on the toolset's `tools[]` entry itself rather than on a member (`BetaToolConfigs`), such as
/// `["cache_control": ["type": "ephemeral"]]`.
public typealias BetaToolConfigs = [String: JSONValue]

/// A screenshot or zoom image from a browser or computer toolset, rendered as one image block. The image must
/// already fit the model's image limits: the API rejects an oversized one rather than scaling it down.
public struct BetaScreenshotResult: Sendable, Hashable, Codable {
    /// Base64 image bytes, without a `data:` prefix.
    public var data: String
    public var mediaType: BetaBase64ImageSourceParam.MediaType

    public init(data: String, mediaType: BetaBase64ImageSourceParam.MediaType = .imagePng) {
        self.data = data
        self.mediaType = mediaType
    }

    enum CodingKeys: String, CodingKey {
        case data
        case mediaType = "media_type"
    }
}

/// What a member returns (`ResultKind`): a navigation result, a screenshot, a cursor position, a string, one tab
/// entry, the tab list, or nothing (a pure action, rendered from its confirmation template followed by the one line
/// of text it may return).
enum ToolsetResultKind: String, Sendable {
    case navigate, screenshot, point, text, tab, tabs, none
}

/// One member of a toolset (`Member`): its result kind, the confirmation the model reads after a pure action
/// (`{field}` placeholders are filled from the input, `{ref}` reads the browser's `target.ref`), whether it is on by
/// default, and whether its input declares `tab_id`.
struct ToolsetMember: Sendable, Hashable {
    let name: String
    let result: ToolsetResultKind
    let text: String?
    let enabledByDefault: Bool
    let declaresTabID: Bool
}

/// One family's members by name, in the API's order, with what the family is called on the wire (`Registry`).
struct ToolsetRegistry: Sendable {
    let family: String
    /// The `x-stainless-helper` value a toolset of this family sends.
    let helperTag: String
    let names: [String]
    let members: [String: ToolsetMember]
    /// Members the API withholds unless `configs` enables them.
    let defaultDisabled: Set<String>

    init(family: String, helperTag: String, members: [ToolsetMember]) {
        self.family = family
        self.helperTag = helperTag
        names = members.map(\.name)
        self.members = Dictionary(uniqueKeysWithValues: members.map { ($0.name, $0) })
        defaultDisabled = Set(members.filter { !$0.enabledByDefault }.map(\.name))
    }

    /// Whether `configs` leave `name` enabled, failing closed when the answer is unclear.
    ///
    /// Only a real boolean `enabled` turns a member on or off. Any other value fails closed, so a malformed entry can
    /// never turn on a member that is off by default.
    func memberEnabled(_ name: String, _ configs: [String: JSONValue]?) -> Bool {
        let entry = configs?[name]
        switch entry {
        case .object(let o)?:
            switch o["enabled"] {
            case .bool(true)?: return true
            case nil, .null?: break
            default: return false
            }
        case nil, .null?: break
        default:
            return false  // an entry that is neither an object nor null (`["navigate": false]`) reads as off
        }
        return !defaultDisabled.contains(name)
    }
}

/// `call()` was invoked from inside a member.
public final class NestedCallError: ToolsetContractError, @unchecked Sendable {
    public init() {
        super.init(
            "call() was invoked from inside a member; a member that composes other members calls their methods directly")
    }
}

/// The constructor options every family has, validated and resolved once at construction (`BaseToolsetOptions`). A
/// mistake in them raises `ToolsetConfigError`.
///
/// - `wireConfigs` is what the `tools[]` entry sends: the caller's `configs` plus `enabled: false` for every member
///   the class does not serve.
/// - `served` is the members a sampled call may reach (the implemented ones, or all of them for a class that
///   overrides `execute`).
/// - `configured` is the members present in the caller's own `configs`.
struct ToolsetOptions: Sendable {
    let registry: ToolsetRegistry
    let served: Set<String>
    let wireConfigs: [String: JSONValue]?
    let configured: Set<String>
    let toolConfigs: [String: JSONValue]

    init(registry: ToolsetRegistry, implemented: Set<String>, overridesExecute: Bool, configs: [String: JSONValue]?,
         toolConfigs: [String: JSONValue]?) throws
    {
        self.registry = registry
        served = overridesExecute ? Set(registry.names) : implemented.intersection(registry.names)
        wireConfigs = try buildWireConfigs(configs, served, registry.names)
        configured = Set(configs.map { Array($0.keys) } ?? [])
        if toolConfigs?["configs"] != nil {
            throw ToolsetConfigError("tool_configs cannot set 'configs'; pass configs= instead")
        }
        self.toolConfigs = toolConfigs ?? [:]
    }

    /// Whether the member is offered to the model and may be dispatched.
    func isEnabled(_ name: String) -> Bool { registry.memberEnabled(name, wireConfigs) }

    /// Stage one of a call: the registry row for `name`, or the refusal the model reads (an unknown name, a member
    /// this application disabled, or one the driver does not implement).
    func resolve(_ name: String) throws -> ToolsetMember {
        guard let member = registry.members[name] else { throw UnknownMemberError(name, family: registry.family) }
        if !isEnabled(member.name) {
            if !served.contains(member.name) && !configured.contains(member.name) {
                throw UnavailableMemberError(member.name, family: registry.family)
            }
            throw DisabledMemberError(member.name)
        }
        return member
    }

    /// The members of `required` this toolset serves and leaves enabled, sorted: these need a `confirm` callable.
    func confirmRequired(_ required: Set<String>) -> [String] {
        required.filter { served.contains($0) && isEnabled($0) }.sorted()
    }

    /// The `tools[]` entry: the tool configs, then `type`, then the wire `configs`. A fresh value each call.
    func entry(type: String) -> JSONValue {
        var param = toolConfigs
        param["type"] = .string(type)
        if let wireConfigs { param["configs"] = .object(wireConfigs) }
        return .object(param)
    }
}

/// The caller's `configs` with `enabled: false` added for every member that is not served (`build_wire_configs`).
/// Enabling such a member is a configuration error.
func buildWireConfigs(_ configs: [String: JSONValue]?, _ served: Set<String>, _ names: [String]) throws
    -> [String: JSONValue]?
{
    var wire: [String: JSONValue] = [:]
    for (name, given) in configs ?? [:] {
        switch given {
        case .null, .object: wire[name] = given
        default:
            throw ToolsetConfigError("configs[\(pythonStringRepr(name))] must be an object or null, not \(pythonTypeName(given))")
        }
    }
    let unserved = names.filter { !served.contains($0) && wire[$0]?["enabled"] == .bool(true) }
    if !unserved.isEmpty {
        // the model would be offered a member that can only ever answer "not available"
        throw ToolsetConfigError(
            "configs enables member(s) this toolset does not implement: \(pythonList(unserved.sorted())) "
                + "(override the member method and list it in implementedMembers; a subclass that overrides only "
                + "execute() and sets overridesExecute serves every member)")
    }
    for name in names where !served.contains(name) {
        var entry = wire[name]?.objectValue ?? [:]
        entry["enabled"] = false
        wire[name] = .object(entry)
    }
    return wire.isEmpty ? nil : wire
}

// MARK: - Parsing a member's input

/// Parse the model's `tool_use.input` into the member's input model (`parse_input`).
///
/// A mistyped field is the model's mistake, so it comes back as an `InvalidMemberInputError` the model can read and
/// correct rather than an error that ends the loop. Every failed field is reported, and the value is not echoed.
/// A key the schema does not declare is dropped from the typed input (a Swift struct holds its declared fields only);
/// the member reads the model's whole input on `context.toolUse?.input`.
func parseMemberInput<T: Decodable>(_ type: T.Type, _ raw: [String: JSONValue], member: String, family: String) throws -> T {
    var value = JSONValue.object(raw)
    var problems: [String] = []
    var recorded = Set<String>()
    var patches: [String: Int] = [:]

    func record(_ path: [String], _ message: String) {
        let key = path.joined(separator: ".")
        if recorded.insert(key).inserted { problems.append(inputProblem(path, message)) }
    }

    for _ in 0..<24 {
        do {
            let parsed = try value.decode(as: T.self)
            var unknown: [[String]] = []
            collectUnknownCases(parsed, [], &unknown)
            for path in unknown { record(path, "Input should be one of the allowed values") }
            if problems.isEmpty { return parsed }
            break
        } catch let error as DecodingError {
            guard let (path, message, placeholder) = describeDecodingError(error, in: value) else {
                problems.append("invalid input")
                break
            }
            record(path, message)
            let key = path.joined(separator: ".")
            patches[key, default: 0] += 1
            guard patches[key]! <= 3, let patched = replacing(value, at: path, with: placeholder) else { break }
            value = patched
        } catch {
            problems.append("invalid input")
            break
        }
    }
    let text = problems.isEmpty ? "invalid input" : problems.joined(separator: "; ")
    throw InvalidMemberInputError(member, text, family: family)
}

/// One validation problem as `loc: message` (`input_problem`).
func inputProblem(_ path: [String], _ message: String) -> String {
    let first = message.split(separator: "\n", omittingEmptySubsequences: false).first.map(String.init) ?? ""
    let msg = first.isEmpty ? "invalid input" : first
    return path.isEmpty ? msg : "\(path.joined(separator: ".")): \(msg)"
}

private func pathComponents(_ codingPath: [CodingKey]) -> [String] {
    codingPath.map { key in key.intValue.map(String.init) ?? key.stringValue }
}

/// The path, message and placeholder value for one decoding error; the placeholder lets the next attempt get past
/// the field so every failed field is reported.
private func describeDecodingError(_ error: DecodingError, in value: JSONValue) -> ([String], String, JSONValue)? {
    switch error {
    case .keyNotFound(let key, let context):
        return (pathComponents(context.codingPath + [key]), "Field required", .null)
    case .valueNotFound(let type, let context):
        let path = pathComponents(context.codingPath)
        return (path, "Input should be a valid \(typeKind(type))", placeholder(for: type))
    case .typeMismatch(let type, let context):
        let path = pathComponents(context.codingPath)
        return (path, "Input should be a valid \(typeKind(type))", placeholder(for: type))
    case .dataCorrupted(let context):
        let path = pathComponents(context.codingPath)
        let current = lookup(value, path)
        switch current {
        case .double?, .int?: return (path, "Input should be a valid integer", 0)
        default: return (path, "Invalid value", "")
        }
    @unknown default:
        return nil
    }
}

private func typeKind(_ type: Any.Type) -> String {
    switch type {
    case is String.Type: return "string"
    case is Int.Type: return "integer"
    case is Double.Type, is Float.Type: return "number"
    case is Bool.Type: return "boolean"
    default:
        let name = String(describing: type)
        if name.hasPrefix("Array<") { return "list" }
        return "dictionary"
    }
}

private func placeholder(for type: Any.Type) -> JSONValue {
    switch type {
    case is String.Type: return ""
    case is Int.Type, is Double.Type, is Float.Type: return 0
    case is Bool.Type: return false
    default:
        let name = String(describing: type)
        if name.hasPrefix("Array<") { return [] }
        return .object([:])
    }
}

private func lookup(_ value: JSONValue, _ path: [String]) -> JSONValue? {
    var current: JSONValue? = value
    for part in path {
        switch current {
        case .object(let o)?: current = o[part]
        case .array(let a)?:
            guard let i = Int(part), a.indices.contains(i) else { return nil }
            current = a[i]
        default: return nil
        }
    }
    return current
}

private func replacing(_ value: JSONValue, at path: [String], with new: JSONValue) -> JSONValue? {
    guard let head = path.first else { return new }
    let rest = Array(path.dropFirst())
    switch value {
    case .object(var o):
        guard let inner = rest.isEmpty ? JSONValue.null : o[head], let replaced = replacing(inner, at: rest, with: new) else {
            return nil
        }
        o[head] = replaced
        return .object(o)
    case .array(var a):
        guard let i = Int(head), a.indices.contains(i), let replaced = replacing(a[i], at: rest, with: new) else { return nil }
        a[i] = replaced
        return .array(a)
    default:
        return nil
    }
}

private func isKnownCase<E: OpenEnum & CaseIterable>(_ e: E) -> Bool { E.allCases.contains(e) }

/// The paths of the values in `value` the generated types decoded to their forward-compatible `unknown` case: a
/// literal or union variant the member's schema does not allow, which pydantic rejects.
private func collectUnknownCases(_ value: Any, _ path: [String], _ into: inout [[String]]) {
    if value is JSONValue { return }
    if let e = value as? any OpenEnum & CaseIterable {
        if !isKnownCase(e) { into.append(path) }
        return
    }
    let mirror = Mirror(reflecting: value)
    switch mirror.displayStyle {
    case .optional:
        if let child = mirror.children.first { collectUnknownCases(child.value, path, &into) }
    case .enum:
        if let child = mirror.children.first {
            if child.label == "unknown" { into.append(path) } else { collectUnknownCases(child.value, path, &into) }
        }
    case .struct, .class:
        for child in mirror.children {
            guard let label = child.label else { continue }
            collectUnknownCases(child.value, path + [wireFieldName(label)], &into)
        }
    case .collection:
        for (index, child) in mirror.children.enumerated() { collectUnknownCases(child.value, path + [String(index)], &into) }
    default:
        break
    }
}

/// A generated property name as its wire key (`tabID` → `tab_id`, `scrollDirection` → `scroll_direction`).
func wireFieldName(_ name: String) -> String {
    var s = name.trimmingCharacters(in: CharacterSet(charactersIn: "`"))
    s = s.replacingOccurrences(of: "IDs", with: "Ids").replacingOccurrences(of: "ID", with: "Id")
    var out = ""
    for ch in s {
        if ch.isUppercase {
            out += "_" + ch.lowercased()
        } else {
            out.append(ch)
        }
    }
    return out
}

// MARK: - The confirm gate and error content

/// Turn what the `confirm` callable did into the gate's decision: return to proceed, or raise the refusal the model
/// reads (`confirm_outcome`). A `ToolError` that `confirm` raised is relayed as-is; any other error means the prompt
/// failed, and the call is refused. `false` declines the call.
func confirmOutcome(_ name: String, _ returned: Bool, _ raised: Error?) throws {
    if let raised { throw try hookRefusal(raised, fallback: ConfirmFailedError(name)) }
    if !returned { throw ConfirmDeclinedError(name) }
}

/// Runs `confirm` and applies `confirmOutcome`. Cancellation propagates.
func runConfirm<Context>(_ name: String, _ confirm: (@Sendable (Context) async throws -> Bool)?, _ context: Context) async throws {
    guard let confirm else { return }
    var returned = false
    var raised: Error?
    do {
        returned = try await confirm(context)
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        raised = error
    }
    try confirmOutcome(name, returned, raised)
}

/// A text block.
func textBlock(_ text: String) -> JSONValue { ["type": "text", "text": .string(text)] }

/// The text blocks of a `ToolError`'s content (`error_content`): a string becomes one text block.
func errorContent(_ error: ToolError) -> [JSONValue] {
    let content = errorTextContent(error.content)
    if case .string(let s) = content { return [textBlock(s)] }
    return content.arrayValue ?? []
}

/// `error` with each text block run through `check` and then bounded, or the same object when nothing changed
/// (`checked_error`).
func checkedError(_ error: ToolError, _ check: (String) -> String) -> ToolError {
    let content = errorContent(error)
    var checked: [JSONValue] = []
    for block in content {
        guard case .object(var o) = block else { continue }
        o["text"] = .string(prefixCodePoints(check(o["text"]?.stringValue ?? ""), TOOLSET_FIELD_MAX))
        checked.append(.object(o))
    }
    if checked == content { return error }
    return ToolError(toolsetContent(checked), cause: error)
}

/// `checkedError` with no check: each text block cut to the field limit (`bounded_error`).
func boundedError(_ error: ToolError) -> ToolError { checkedError(error) { $0 } }

/// Content blocks written as JSON, as the generated content type.
func toolsetContent(_ blocks: [JSONValue]) -> BetaToolsetContent {
    (try? JSONValue.array(blocks).decode(as: BetaToolsetContent.self)) ?? .unknown(.array(blocks))
}

/// A `ToolError` raised by a pipeline stage with the content the model reads and the specific refusal as its cause.
func pipelineError(_ content: [JSONValue], cause: Error?) -> ToolError {
    ToolError(toolsetContent(content), cause: cause)
}

// MARK: - The serialized call loop

/// One member call runs at a time: the gate serialises them, counts the calls accepted and not yet finished so
/// `close()` can wait for them, and marks the task inside a call so a nested `call()` or a `close()` from within a
/// member is recognised (`BaseAsyncToolset`).
final class ToolsetCallGate: @unchecked Sendable {
    /// The toolsets whose call the current task is inside.
    @TaskLocal static var holders: Set<ObjectIdentifier> = []

    private let lock = NSLock()
    private var busy = false
    private var queue: [(id: Int, continuation: CheckedContinuation<Void, Error>)] = []
    private var nextID = 0
    private var pending = 0
    private var settledWaiters: [CheckedContinuation<Void, Never>] = []

    /// Counts a call as accepted (queued or running).
    func accept() { lock.withLock { pending += 1 } }

    /// Counts an accepted call as finished.
    func settle() {
        let waiters: [CheckedContinuation<Void, Never>] = lock.withLock {
            pending -= 1
            guard pending == 0 else { return [] }
            defer { settledWaiters = [] }
            return settledWaiters
        }
        for waiter in waiters { waiter.resume() }
    }

    /// Waits until no accepted call is left.
    func waitSettled() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let ready: Bool = lock.withLock {
                if pending == 0 { return true }
                settledWaiters.append(continuation)
                return false
            }
            if ready { continuation.resume() }
        }
    }

    /// Takes the lock, waiting in turn. A cancelled task stops waiting with `CancellationError`.
    func acquire() async throws {
        let id: Int = lock.withLock {
            nextID += 1
            return nextID
        }
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let outcome: Bool? = lock.withLock {
                    if Task.isCancelled { return false }
                    if !busy {
                        busy = true
                        return true
                    }
                    queue.append((id, continuation))
                    return nil
                }
                switch outcome {
                case true?: continuation.resume()
                case false?: continuation.resume(throwing: CancellationError())
                case nil: break
                }
            }
        } onCancel: {
            let waiter: CheckedContinuation<Void, Error>? = lock.withLock {
                guard let index = queue.firstIndex(where: { $0.id == id }) else { return nil }
                return queue.remove(at: index).continuation
            }
            waiter?.resume(throwing: CancellationError())
        }
    }

    /// Releases the lock to the next call in line.
    func release() {
        let next: CheckedContinuation<Void, Error>? = lock.withLock {
            if queue.isEmpty {
                busy = false
                return nil
            }
            return queue.removeFirst().continuation
        }
        next?.resume()
    }

    /// Runs `body` as one call of `owner`: refused when nested, counted for `close()`, serialised with the others.
    func run<T>(for owner: AnyObject, _ body: () async throws -> T) async throws -> T {
        let id = ObjectIdentifier(owner)
        if Self.holders.contains(id) { throw NestedCallError() }
        accept()
        defer { settle() }
        try await acquire()
        defer { release() }
        var holders = Self.holders
        holders.insert(id)
        return try await Self.$holders.withValue(holders) { try await body() }
    }

    /// Whether the current task is inside a call of `owner`.
    static func isInsideCall(of owner: AnyObject) -> Bool { holders.contains(ObjectIdentifier(owner)) }
}
