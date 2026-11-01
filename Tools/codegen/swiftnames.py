"""Naming rules for turning Python identifiers and literal values into Swift ones."""

from __future__ import annotations

import re

SWIFT_KEYWORDS = {
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init",
    "inout", "internal", "let", "open", "operator", "private", "precedencegroup", "protocol", "public",
    "rethrows", "static", "struct", "subscript", "typealias", "var", "break", "case", "catch", "continue",
    "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return",
    "throw", "switch", "where", "while", "as", "false", "is", "nil", "self", "Self", "super", "throws",
    "true", "try", "Any", "Type", "Protocol", "async", "await",
}

# Nested type names that can't be used as-is.
RESERVED_TYPE_NAMES = {"Type": "TypeValue", "Protocol": "ProtocolValue", "Self": "SelfValue", "Any": "AnyValue"}

# Top-level names the runtime (or Swift/Foundation) already uses.
RESERVED_TOP_LEVEL = {
    "Data", "URL", "Date", "Error", "Stream", "Page", "TokenPage", "PageCursor", "Timeout", "Headers", "Query",
    "Body", "Result", "Set", "Array", "Dictionary", "String", "Int", "Bool", "Double", "Codable", "Never",
    "Void", "Task", "Range", "Character", "Optional", "Decoder", "Encoder", "JSONValue", "APIError",
    "AnthropicError", "Middleware", "APIResponse", "HTTPRequest", "HTTPResponse", "RequestOptions",
    "FileUpload", "ISODate", "Base64FileInput", "OpenEnum", "Anthropic", "BaseClient", "ServerSentEvent",
    "Sequence", "Collection", "Locale", "Calendar", "Notification", "Operation", "Process", "Thread",
    "Selector", "Expression", "Measurement", "Unit", "PageInfo", "Querystring", "EmptyResponse",
    "BinaryResponse", "HTTPHeaders", "APIStatusError", "APIConnectionError", "APITimeoutError",
    "APIResponseValidationError", "APIWebhookValidationError", "BadRequestError", "AuthenticationError",
    "PermissionDeniedError", "NotFoundError", "ConflictError", "RequestTooLargeError",
    "UnprocessableEntityError", "RateLimitError", "ServiceUnavailableError", "OverloadedError",
    "DeadlineExceededError", "InternalServerError", "RetryableError", "CredentialsError",
    "IdentityTokenFileError", "ValueError", "ArgumentTypeError", "HTTPTransport", "MockTransport", "ParamsBuilder", "HeaderValue",
}


def escape_ident(name: str) -> str:
    return f"`{name}`" if name in SWIFT_KEYWORDS else name


ACRONYMS = {"id": "ID", "ids": "IDs", "url": "URL", "urls": "URLs", "uri": "URI", "api": "API", "mcp": "MCP"}


def camel(name: str) -> str:
    """snake_case -> lowerCamelCase, keeping digit runs readable (`foo_2_0` -> `foo2_0`) and
    spelling common initialisms the Swift way (`message_id` -> `messageID`)."""
    name = name.rstrip("_") or name
    lead = ""
    while name.startswith("_"):
        lead += "_"
        name = name[1:]
    parts = [p for p in name.split("_") if p != ""]
    if not parts:
        return lead + "value"
    out = parts[0][:1].lower() + parts[0][1:]
    for p in parts[1:]:
        if out and out[-1].isdigit() and p[0].isdigit():
            out += "_" + p
        elif p.lower() in ACRONYMS and p == p.lower():
            out += ACRONYMS[p.lower()]
        else:
            out += p[:1].upper() + p[1:]
    return lead + out


def pascal(name: str) -> str:
    c = camel(name)
    return c[:1].upper() + c[1:]


def property_name(py: str) -> str:
    return escape_ident(camel(py))


def bare(name: str) -> str:
    return name.strip("`")


def literal_case_name(value: object) -> str:
    if isinstance(value, bool):
        return "true_" if value else "false_"
    if isinstance(value, int):
        return f"_{value}" if value >= 0 else f"minus{-value}"
    s = str(value)
    parts = [p for p in re.split(r"[^A-Za-z0-9]+", s) if p]
    if not parts:
        return "empty"
    first = parts[0]
    if first.isupper() and len(first) > 1:
        first = first.lower()
    else:
        first = first[:1].lower() + first[1:]
    out = first
    for p in parts[1:]:
        if out[-1].isdigit() and p[0].isdigit():
            out += "_" + p
        else:
            out += p[:1].upper() + p[1:]
    if out[0].isdigit():
        out = "_" + out
    return escape_ident(out)


def lower_first(name: str) -> str:
    # Keep acronyms readable: URLImageSource -> urlImageSource, JSONOutputFormat -> jsonOutputFormat.
    m = re.match(r"^([A-Z]+)([A-Z][a-z].*)$", name)
    if m:
        return m.group(1).lower() + m.group(2)
    if name.isupper():
        return name.lower()
    return name[:1].lower() + name[1:]


def type_name(name: str) -> str:
    return RESERVED_TYPE_NAMES.get(name, name)


def swift_string(s: str) -> str:
    out = s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
    return f'"{out}"'


def doc_comment(doc: str | None, indent: str) -> str:
    if not doc:
        return ""
    import textwrap

    text = textwrap.dedent(doc).strip("\n")
    lines = text.split("\n")
    # textwrap.dedent doesn't dedent the first line if docstring starts on the same line as """
    if len(lines) > 1:
        rest = textwrap.dedent("\n".join(lines[1:]))
        lines = [lines[0].strip()] + rest.split("\n")
    return "".join(f"{indent}/// {l}".rstrip() + "\n" for l in lines)
