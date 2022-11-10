# FoundationPlus

Foundation, but better!

Here are some examples:

**To find a phone number in a string:**

```swift
// Foundation:
let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
let phoneNumber = detector.matches(in: "123-456-7890", range: NSRange(location: 0, length: 12)).first?.phoneNumber

// FoundationPlus:
let phoneNumber = "123-456-7890".phoneNumbers.first
```

**To find what day it is:**

```swift
// Foundation:
let currentDate = Date.now
let calendar = Calendar.current

let day = calendar.component(.day, from: currentDate)

// FoundationPlus:
let day = Date.now[.day]
```

**To find the number of times 3 appears in a set:**
```swift
// Foundation:
let set: NSCountedSet = NSCountedSet(array: [1, 2, 3, 3])
let count: Int = set.count(for: 3)

// FoundationPlus:
let set: CountedSet<Int> = [1, 2, 3, 3]
let count: Int = set.count(of: 3)
```

Not convinced? FoundationPlus will be updated to feature even more revamped Foundation types.
This is where we're at:

- [x] Numbers, Data and Basic Values
    - [x] Int
    - [x] Double
    - [x] Decimal
    - [x] Data
    - [x] DataProtocol
    - [x] MutableDataProtocol
    - [x] ContiguousBytes
    - [x] URL
    - [x] UUID
    - [x] Point
    - [x] Size
    - [x] Rect
    - [x] Vector
    - [x] AffineTransform
    - [x] Scale
- [x] Strings and Text
    - [x] String
    - [x] AttributedString
    - [x] AttributedSubstring
    - [x] CharacterSet
    - [x] Scanner
    - [x] Regex
    - [x] DataDetector
    - [x] TextCheckingResult
    - [x] SpellServer
    - [x] Orthography
- [x] Collections
    - [x] CountedSet<Element>
    - [x] OrderedSet<Element>
    - [x] Cache<Key, Value>
    - [x] PurgeableData
- [x] Dates and Times
    - [x] Date
    - [x] DateInterval
    - [x] DateComponents
    - [x] Calendar
    - [x] TimeZone
    - [x] TimeInterval
- [ ] Units and Measurement
    - [ ] Volume
    - [ ] Mass
    - [ ] Pressure
    - [ ] Acceleration
    - [x] Duration
    - [ ] Frequency
    - [ ] Speed
    - [ ] Energy
    - [ ] Power
    - [ ] Temperature
    - [ ] Illuminance
    - [ ] ElectricCharge
    - [ ] ElectricCurrent
    - [ ] ElectricPotentialDifference
    - [ ] ElectricResistance
    - [ ] ConcentrationOfMass
    - [ ] Dispersion
    - [ ] FuelEfficiency
    - [ ] InformationStorage
    - [x] Angle
    - [x] Length
    - [x] Area
    - [x] Measurement
    - [x] UnitProtocol
- [ ] Data Formatting
    - [ ] Number.Formatter
    - [ ] PersonNameComponents.Formatter
    - [ ] PersonNameComponents
    - [ ] Date.Formatter
    - [ ] DateComponents.Formatter
    - [ ] Date.ISO8601Formatter
    - [ ] Date.RelativeTimeFormatter
    - [ ] DateInterval.Formatter
    - [ ] ByteCountFormatter
    - [ ] MeasurementFormatter
    - [ ] ListFormatter
    - [ ] Locale
    - [ ] Formatter
- [ ] Filters and Sorting
    - [ ] Predicate<Input>
    - [ ] Expression<Input, Output>
    - [ ] ComparisonPredicate<Input>
    - [ ] CompoundPredicate<P1, P2>
    - [ ] SortDescriptor<Element>
    - [ ] SortComparator
    - [ ] ComparableComparator
    - [ ] KeyPathComparator 
- [ ] Task Management
    - [ ] UndoManager
    - [ ] Progress
    - [ ] ProgressReporting
    - [ ] Operation
    - [ ] OperationQueue
    - [ ] BlockOperation
    - [ ] Timer
    - [ ] UserActivity
    - [ ] UserActivity.Delegate
    - [ ] ProcessInfo
    - [ ] BackgroundActivityScheduler
- [ ] Resources
    - [ ] Bundle
    - [ ] Bundle.ResourceRequest
- [ ] Notifications
    - [ ] Notification<Poster>
    - [ ] NotificationCenter
    - [ ] NotificationQueue
    - [ ] DistributedNotificationCenter
- [ ] App Extension Support
    - [ ] ExtensionRequestHandler
    - [ ] ExtensionContext
    - [ ] ItemProvider
    - [ ] ExtensionItem
- [ ] Scripting Support
    - [ ] AppleScript
    - [ ] AppleEvent.Descriptor
    - [ ] AppleEvent.Manager
    - [ ] ScriptCommand
    - [ ] QuitCommand
    - [ ] SetCommand
    - [ ] MoveCommand
    - [ ] CreateCommand
    - [ ] DeleteCommand
    - [ ] ExistsCommand
    - [ ] GetCommand
    - [ ] CloneCommand
    - [ ] CountCommand
    - [ ] CloseCommand
    - [ ] ScriptObjectSpecifier
    - [ ] PropertySpecifier
    - [ ] PositionalSpecifier
    - [ ] RandomSpecifier
    - [ ] RangeSpecifier
    - [ ] UUIDSpecifier
    - [ ] WhoseSpecifier
    - [ ] NameSpecifier
    - [ ] MiddleSpecifier
    - [ ] IndexSpecifier
    - [ ] RelativeSpecifier
    - [ ] ScriptSuiteRegistry
    - [ ] ScriptClassDescription
    - [ ] ClassDescription
    - [ ] ScriptCommandDescription
    - [ ] ScriptWhoseTest
    - [ ] SpecifierTest
    - [ ] LogicalTest
    - [ ] ScriptCoercionHandler
    - [ ] ScriptExecutionContext
- [x] Errors and Exceptions
    - [x] RecoverableError
    - [x] AssertionHandler
    - [x] Exception
    - [x] LocalizedError
- [ ] File System
    - [ ] FileHandle
    - [ ] FileSecurity
    - [ ] FileVersion
    - [ ] FilePresenter
    - [ ] FileAccessIntent
    - [ ] FileCoordinator
- [ ] Archives and Serialization
    - [ ] JSONEncoder
    - [ ] JSONDecoder
    - [ ] JSONSerialization
    - [ ] PropertyListEncoder
    - [ ] PropertyListDecoder
    - [ ] PropertyListSerialization
    - [ ] XML.DTD
    - [ ] XML.DTDNode
    - [ ] XML.Document
    - [ ] XML.Element
    - [ ] XML.Node
    - [ ] XML.Parser
    - [ ] XML.Parser.Delegate
    - [ ] KeyedArchiver
    - [ ] KeyedArchiver.Delegate
    - [ ] KeyedUnarchiver
    - [ ] KeyedUnarchiver.Delegate
- [ ] Preferences
    - [ ] Defaults
    - [ ] Defaults.Key
- [ ] iCloud
    - [ ] FileManager
    - [ ] FileManager.Delegate
    - [ ] UbiquitousKeyValueStore
    - [ ] MetadataQuery
    - [ ] MetadataQuery.Delegate
    - [ ] MetadataItem
- [ ] URL Loading System
    - [ ] URL.Session
    - [ ] URL.Session.Task
    - [ ] URL.Request
    - [ ] URL.Response
    - [ ] URL.HTTPResponse
    - [ ] HTTP.URLResponse
    - [ ] URL.CachedResponse
    - [ ] URL.Cache
    - [ ] URL.AuthenticationChallenge
    - [ ] URL.Credential
    - [ ] URL.CredentialStorage
    - [ ] URL.ProtectionSpace
    - [ ] HTTP.Cookie
    - [ ] HTTP.Cookie.Storage
- [ ] XPC
    - [ ] CreatesXPCProxy
    - [ ] XPCConnection
    - [ ] XPCInterface
    - [ ] XPCCoder
    - [ ] XPCListener
        - [ ] XPCListenerDelegate
        - [ ] XPCListenerEndpoint
- [ ] Processes and Threads
    - [ ] RunLoop
    - [ ] Timer
    - [ ] ProcessInfo
    - [ ] Thread
    - [ ] LockProtocol
    - [ ] Lock
    - [ ] RecursiveLock
    - [ ] DistributedLock
    - [ ] ConditionLock
    - [ ] Condition
    - [ ] OperationQueue
    - [ ] Process
    - [ ] UserScriptTask
    - [ ] UserAppleScriptTask
    - [ ] UserAutomatorTask
    - [ ] UserUnixTask
    - [x] BlockOperation
    - [x] Operation
- [ ] Streams, Sockets and Ports
    - [ ] Stream
    - [ ] InputStream
    - [ ] OutputStream
    - [ ] Process
    - [ ] Pipe
    - [ ] Host
    - [ ] Port
    - [ ] SocketPort
- [ ] Grammar
    - [ ] Grammar.Gender
    - [ ] Grammer.Number
    - [ ] Grammar.PartOfSpeech
