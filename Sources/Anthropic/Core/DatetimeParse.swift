import Foundation

/// Port of `_utils/_datetime_parse.py` (itself pydantic v1's `datetime_parse`): the lenient date and
/// datetime parsing the SDK applies to response fields.
///
/// Swift's `Date` is an instant, so a datetime without a UTC offset is read as UTC and an offset is
/// applied rather than kept. Out-of-range numbers map to `datetime.max` / `datetime.min`.
public enum DatetimeParse {
    static let msWatershed = 2e10
    static let maxNumber = 3e20

    /// `datetime.max` (9999-12-31T23:59:59.999999).
    public static let maxDate: Date = makeDate(9999, 12, 31, 23, 59, 59, 999_999, offsetSeconds: 0)!
    /// `datetime.min` (0001-01-01T00:00:00).
    public static let minDate: Date = makeDate(1, 1, 1, 0, 0, 0, 0, offsetSeconds: 0)!

    static func isLeap(_ y: Int) -> Bool { (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 }

    static func daysIn(_ year: Int, _ month: Int) -> Int {
        switch month {
        case 2: return isLeap(year) ? 29 : 28
        case 4, 6, 9, 11: return 30
        default: return 31
        }
    }

    /// Builds an instant from validated components; `nil` when a component is out of range.
    static func makeDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int,
                         _ microsecond: Int, offsetSeconds: Int) -> Date?
    {
        guard (1...9999).contains(year), (1...12).contains(month), day >= 1, day <= daysIn(year, month),
              (0..<24).contains(hour), (0..<60).contains(minute), (0..<60).contains(second),
              (0..<1_000_000).contains(microsecond)
        else { return nil }
        // Days since 1970-01-01 in the proleptic Gregorian calendar (like Python's `datetime`).
        func daysFromCivil(_ y0: Int, _ m: Int, _ d: Int) -> Int {
            let y = m <= 2 ? y0 - 1 : y0
            let era = (y >= 0 ? y : y - 399) / 400
            let yoe = y - era * 400
            let mp = (m + 9) % 12
            let doy = (153 * mp + 2) / 5 + d - 1
            let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
            return era * 146_097 + doe - 719_468
        }
        let days = daysFromCivil(year, month, day)
        let seconds = Double(days * 86_400 + hour * 3600 + minute * 60 + second - offsetSeconds)
        return Date(timeIntervalSince1970: seconds + Double(microsecond) / 1_000_000)
    }

    /// `_from_unix_seconds`.
    static func fromUnixSeconds(_ value: Double) throws -> Date {
        if value.isNaN { throw ValueError("cannot convert float NaN to integer") }
        if value > maxNumber { return maxDate }
        if value < -maxNumber { return minDate }
        var seconds = value
        while abs(seconds) > msWatershed { seconds /= 1000 }
        // `timedelta` keeps microseconds.
        let micros = (seconds * 1_000_000).rounded()
        return Date(timeIntervalSince1970: micros / 1_000_000)
    }

    /// `parse_datetime` for numbers (unix seconds, milliseconds, microseconds or nanoseconds).
    public static func parseDatetime(_ number: Double) throws -> Date { try fromUnixSeconds(number) }

    static let datetimePattern = try! NSRegularExpression(
        pattern: #"^(\d{4})-(\d{1,2})-(\d{1,2})[T ](\d{1,2}):(\d{1,2})(?::(\d{1,2})(?:\.(\d{1,6})\d{0,6})?)?(Z|[+-]\d{2}(?::?\d{2})?)?$"#)
    static let datePattern = try! NSRegularExpression(pattern: #"^(\d{4})-(\d{1,2})-(\d{1,2})$"#)

    static func groups(_ re: NSRegularExpression, _ s: String) -> [String?]? {
        let ns = s as NSString
        guard let m = re.firstMatch(in: s, range: NSRange(location: 0, length: ns.length)) else { return nil }
        return (1..<m.numberOfRanges).map { i in
            let r = m.range(at: i)
            return r.location == NSNotFound ? nil : ns.substring(with: r)
        }
    }

    /// `parse_datetime` for strings: a number, or `YYYY-MM-DD[T ]HH:MM[:SS[.ffffff]][Z|±HH[[:]MM]]`.
    public static func parseDatetime(_ value: String) throws -> Date {
        if let number = BaseClient.parsePythonFloat(value) { return try fromUnixSeconds(number) }
        guard let g = groups(datetimePattern, value) else { throw ValueError("invalid datetime format") }
        func int(_ i: Int) -> Int { g[i].flatMap { Int($0) } ?? 0 }
        var micro = 0
        if let f = g[6] { micro = Int(f.padding(toLength: 6, withPad: "0", startingAt: 0)) ?? 0 }
        var offset = 0
        if let tz = g[7], tz != "Z" {
            let chars = Array(tz)
            let minutes = chars.count > 3 ? Int(String(chars.suffix(2))) ?? 0 : 0
            var total = 60 * (Int(String(chars[1...2])) ?? 0) + minutes
            if chars[0] == "-" { total = -total }
            // `timezone()` only accepts offsets strictly within a day.
            if abs(total) >= 24 * 60 { throw ValueError("offset must be a timedelta strictly between -timedelta(hours=24) and timedelta(hours=24)") }
            offset = total * 60
        }
        guard let d = makeDate(int(0), int(1), int(2), int(3), int(4), int(5), micro, offsetSeconds: offset) else {
            throw ValueError("invalid datetime format")
        }
        return d
    }

    /// `parse_date` for numbers.
    public static func parseDate(_ number: Double) throws -> ISODate {
        // `datetime.max.date()` / `datetime.min.date()` (a `Date` can't hold datetime.max's microseconds)
        if number > maxNumber { return ISODate(year: 9999, month: 12, day: 31) }
        if number < -maxNumber { return ISODate(year: 1, month: 1, day: 1) }
        return isoDate(try fromUnixSeconds(number))
    }

    /// `parse_date` for strings: a number, or `YYYY-MM-DD` (month and day may have one digit).
    public static func parseDate(_ value: String) throws -> ISODate {
        if let number = BaseClient.parsePythonFloat(value) { return try parseDate(number) }
        guard let g = groups(datePattern, value), let y = g[0].flatMap({ Int($0) }), let m = g[1].flatMap({ Int($0) }),
              let d = g[2].flatMap({ Int($0) }), makeDate(y, m, d, 0, 0, 0, 0, offsetSeconds: 0) != nil
        else { throw ValueError("invalid date format") }
        return ISODate(year: y, month: m, day: d)
    }

    /// The UTC calendar date of an instant, in the proleptic Gregorian calendar (Foundation's
    /// `Calendar` switches to the Julian calendar before 1582).
    static func isoDate(_ date: Date) -> ISODate {
        let days = Int((date.timeIntervalSince1970 / 86_400).rounded(.down))
        let z = days + 719_468
        let era = (z >= 0 ? z : z - 146_096) / 146_097
        let doe = z - era * 146_097
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146_096) / 365
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        let mp = (5 * doy + 2) / 153
        let d = doy - (153 * mp + 2) / 5 + 1
        let m = mp < 10 ? mp + 3 : mp - 9
        return ISODate(year: yoe + era * 400 + (m <= 2 ? 1 : 0), month: m, day: d)
    }
}
