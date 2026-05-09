import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowControllers: [NSWindowController] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        bootstrap()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bootstrap),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // To show dock icon, comment this line.
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @objc private func bootstrap() {
        for windowController in windowControllers {
            windowController.close()
        }
        windowControllers.removeAll()

        for screen in NSScreen.screens {
            windowControllers.append(createWindowController(for: screen))
        }
    }

    private func createWindowController(for screen: NSScreen) -> NSWindowController {
        let controller = AppWindowController(screen: screen)
        controller.window?.setFrameOrigin(screen.frame.origin)
        controller.window?.setContentSize(screen.frame.size)
        controller.window?.makeKeyAndOrderFront(nil)
        return controller
    }
}

final class AppWindow: NSWindow {
    private static let watermarkCollectionBehavior: NSWindow.CollectionBehavior = [
        .fullScreenAuxiliary,
        .stationary,
        .canJoinAllSpaces,
    ]

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        alphaValue = 0.99
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        ignoresMouseEvents = true
        isMovable = false
        collectionBehavior = Self.watermarkCollectionBehavior
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)))
        hasShadow = false
    }

    override var canBecomeKey: Bool {
        false
    }

    override var canBecomeMain: Bool {
        false
    }

    override var collectionBehavior: NSWindow.CollectionBehavior {
        get { Self.watermarkCollectionBehavior }
        set { super.collectionBehavior = newValue }
    }
}

final class AppWindowController: NSWindowController {
    init(screen: NSScreen) {
        super.init(window: AppWindow(screen: screen))
        contentViewController = AppController()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class AppController: NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = AppView()
    }
}

final class AppView: NSView {
    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let title = NSLocalizedString("TITLE", comment: "")
        var description = NSLocalizedString("DESCRIPTION", comment: "")

        // Check if running macOS Ventura and newer, and if so use the Ventura description string.
        let venturaVersion = OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)
        let useSystemSettings = ProcessInfo.processInfo.isOperatingSystemAtLeast(venturaVersion)
        if useSystemSettings {
            description = NSLocalizedString("DESCRIPTION_VENTURA", comment: "")
        }

        // Check if screen height is larger than 1500px.
        if bounds.size.height > 1_500 {
            drawWatermark(
                title: title,
                description: description,
                titleFontSize: 36.0,
                descriptionFontSize: 20.0,
                titleY: 150.0,
                descriptionY: 125.0
            )
        } else {
            NSLog("%f", bounds.size.height)
            drawWatermark(
                title: title,
                description: description,
                titleFontSize: 24.0,
                descriptionFontSize: 13.0,
                titleY: 134.0,
                descriptionY: 116.0
            )
        }
    }

    private func drawWatermark(
        title: String,
        description: String,
        titleFontSize: CGFloat,
        descriptionFontSize: CGFloat,
        titleY: CGFloat,
        descriptionY: CGFloat
    ) {
        let textColor = NSColor(white: 0.57, alpha: 0.5)
        let drawingOptions: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        let firstLine = NSAttributedString(
            string: title,
            attributes: [
                .font: NSFont.systemFont(ofSize: titleFontSize),
                .foregroundColor: textColor,
            ]
        )
        let secondLine = NSAttributedString(
            string: description,
            attributes: [
                .font: NSFont.systemFont(ofSize: descriptionFontSize),
                .foregroundColor: textColor,
            ]
        )

        let firstLineRect = firstLine.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: drawingOptions
        )
        let secondLineRect = secondLine.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: drawingOptions
        )

        let decisionWidth = max(firstLineRect.size.width, secondLineRect.size.width)
        let xPosition = bounds.size.width - 125.0 - decisionWidth // padding to right 125

        firstLine.draw(at: CGPoint(x: xPosition, y: titleY))
        secondLine.draw(at: CGPoint(x: xPosition, y: descriptionY))
    }
}

private let appDelegate = AppDelegate()
NSApplication.shared.delegate = appDelegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
