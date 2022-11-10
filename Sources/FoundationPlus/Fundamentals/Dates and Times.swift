import Foundation

public typealias TimeInterval = Duration

public typealias Date = Foundation.Date

public extension Date {
    init(_ duration: Duration, since date: Date) {
        self.init(timeInterval: duration.seconds, since: date)
    }
    
    static func + (lhs: Date, rhs: Duration) -> Self {
        lhs + rhs.seconds
    }
    
    static func - (lhs: Date, rhs: Duration) -> Self {
        lhs - rhs.seconds
    }
    
    func duration(since date: Date) -> Duration {
        .seconds(timeIntervalSince(date))
    }
    
    typealias Components = Foundation.DateComponents
    
    init?(_ components: Components) {
        if let date = components.date {
            self = date
        } else {
            return nil
        }
    }
    
    /// Creates a date from components.
    ///```swift
    /// let referenceDate = Date(year: 2001, month: 1, day: 1)!
    /// ```swift
    init?(
        calendar: Calendar? = .current,
        timeZone: TimeZone? = nil,
        era: Int? = nil,
        year: Int? = nil,
        month: Int? = nil,
        day: Int? = nil,
        hour: Int? = nil,
        minute: Int? = nil,
        second: Int? = nil,
        nanosecond: Int? = nil,
        weekday: Int? = nil,
        weekdayOrdinal: Int? = nil,
        quarter: Int? = nil,
        weekOfMonth: Int? = nil,
        weekOfYear: Int? = nil,
        yearForWeekOfYear: Int? = nil
    ) {
        self.init(
            Components(calendar: calendar, timeZone: timeZone, era: era, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, weekday: weekday, weekdayOrdinal: weekdayOrdinal, quarter: quarter, weekOfMonth: weekOfMonth, weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear)
        )
    }
}

public extension Date.Components {
    subscript(component: Calendar.Component) -> Int? {
        get { value(for: component) }
        set { setValue(newValue, for: component) }
    }
}

public typealias DateComponents = Date.Components

public struct DateInterval: Equatable {
    public var rawValue: Foundation.DateInterval
    
    public init(from start: Date, for duration: Duration) {
        self.rawValue = .init(start: start, duration: duration.seconds)
    }
    
    public init(from start: Date, to end: Date) {
        self.rawValue = .init(start: start, end: end)
    }
    
    public var duration: Duration {
        .seconds(rawValue.duration)
    }
    
    public var start: Date { rawValue.start }
    public var end: Date { rawValue.end }
}

public func ... (lhs: Date, rhs: Date) -> DateInterval {
    DateInterval(from: lhs, to: rhs)
}

public typealias Calendar = Foundation.Calendar

public extension Date {
    func matches(_ components: DateComponents, calendar: Calendar = .current) -> Bool {
        calendar.date(self, matchesComponents: components)
    }
    
    /// Returns the `component` component of the date.
    func component(_ component: Calendar.Component, calendar: Calendar = .current) -> Int {
        calendar.component(component, from: self)
    }
}

public extension DateComponents {
    init(_ components: Set<Calendar.Component>, from date: Date, calendar: Calendar = .current) {
        self = calendar.dateComponents(components, from: date)
    }
    
    init(_ components: Calendar.Component..., from date: Date, calendar: Calendar = .current) {
        self = calendar.dateComponents(Set(components), from: date)
    }
    
    init(_ components: Set<Calendar.Component>, from startDate: Date, to endDate: Date, calendar: Calendar = .current) {
        self = calendar.dateComponents(components, from: startDate, to: endDate)
    }
    
    init(_ components: Calendar.Component..., from startDate: Date, to endDate: Date, calendar: Calendar = .current) {
        self = calendar.dateComponents(Set(components), from: startDate, to: endDate)
    }
    
    init(
        _ components: Set<Calendar.Component>,
        from dateInterval: DateInterval,
        calendar: Calendar = .current
    ) {
        self.init(components, from: dateInterval.start, to: dateInterval.end, calendar: calendar)
    }
    
    init(
        _ components: Calendar.Component...,
        from dateInterval: DateInterval,
        calendar: Calendar = .current
    ) {
        self.init(Set(components), from: dateInterval.start, to: dateInterval.end, calendar: calendar)
    }
    
    init(
        _ components: Set<Calendar.Component>,
        from startDate: DateComponents,
        to endDate: DateComponents,
        calendar: Calendar = .current
    ) {
        self = calendar.dateComponents(components, from: startDate, to: endDate)
    }
    
    init(
        _ components: Calendar.Component...,
        from startDate: DateComponents,
        to endDate: DateComponents,
        calendar: Calendar = .current
    ) {
        self = calendar.dateComponents(Set(components), from: startDate, to: endDate)
    }
    
    init(
        _ date: Date,
        in timeZone: TimeZone,
        calendar: Calendar = .current
    ) {
        self = calendar.dateComponents(in: timeZone, from: date)
    }
}

extension Calendar: Identifiable {
    public var id: Calendar.Identifier {
        self.identifier
    }
}

extension Date {
    public func maxRange(of component: Calendar.Component, calendar: Calendar = .current) -> Range<Int>? {
        calendar.maximumRange(of: component)
    }
    
    public func minRange(of component: Calendar.Component, calendar: Calendar = .current) -> Range<Int>? {
        calendar.minimumRange(of: component)
    }
    
    public func startOfDay(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }
    
    public init?(_ components: Date.Components, calendar: Calendar = .current) {
        if let date = calendar.date(from: components) { self = date }
        else { return nil }
    }
    
    public func adding(
        _ components: DateComponents,
        calendar: Calendar = .current,
        wrappingComponents: Bool = false
    ) -> Date? {
        calendar.date(byAdding: components, to: self, wrappingComponents: wrappingComponents)
    }
    
    public static func + (
        lhs: Date,
        rhs: DateComponents
    ) -> Date? {
        Calendar.current.date(byAdding: rhs, to: lhs)
    }
    
    public subscript(component: Calendar.Component, calendar calendar: Calendar = .current) -> Int {
        calendar.component(component, from: self)
    }
}

extension Calendar {
    public func range(of component: Component, for date: Date) -> DateInterval? {
        self.dateInterval(of: component, for: date).map {
            DateInterval(from: $0.start, to: $0.end)
        }
    }
    
    public func weekend(containing date: Date) -> DateInterval? {
        if let interval = dateIntervalOfWeekend(containing: date) {
            return DateInterval(from: interval.start, to: interval.end)
        } else {
            return nil
        }
    }
}

public typealias TimeZone = Foundation.TimeZone
