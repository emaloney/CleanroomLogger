//
//  LiveLogInspectorView.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/18/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

private let cellID = "LogEntryCell"
private let headerHeight = CGFloat(50)
private let padding = CGFloat(6)
private let closeButtonSize = CGFloat(38)

/**
 The `LiveLogInspectorView` provides a live view of the `LogEntry` messages
 recorded by a `BufferedLogEntryMessageRecorder`.
 */
open class LiveLogInspectorView: UIView
{
    /** A function applies styling to the `UILabel` used to display the content
     of a log message. This function is called after the `text` of the label
     has been set. You may replace this function to customize the appearance 
     of the label. */
    open var styleMessageLabel: (UILabel) -> Void = { label in
#if os(iOS)
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
#elseif os(tvOS)
        label.font = UIFont.preferredFont(forTextStyle: .body)
#endif
    }

    /** A function applies styling to the `UILabel` used to display the
     `severity` property of a `LogEntry`. This function is called after the
     `text` of the label has been set. You may replace this function to
     customize the appearance of the label. */
    open var styleSeverityLabel: (UILabel) -> Void = { label in
#if os(iOS)
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
#elseif os(tvOS)
        label.font = UIFont.preferredFont(forTextStyle: .body)
#endif
    }

    /** A function applies styling to the `UILabel` used to display the
     `timestamp` property of a `LogEntry`. This function is called after the
     `text` of the label has been set. You may replace this function to
     customize the appearance of the label. */
    open var styleTimestampLabel: (UILabel) -> Void = { label in
#if os(iOS)
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
#elseif os(tvOS)
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
#endif
    }

    /** A function called when the close button is tapped in the view. By
     default, removes the view from its superview. However, when the view is
     in a `LiveLogInspectorViewController`, this function is replaced with an
     implementation that dismisses the view controller. */
    open var closeButtonTriggered: (LiveLogInspectorView) -> Void = { view in
        view.removeFromSuperview()
    }

    /** If `true`, log entries are displayed in newest-first (reverse
     chronological) order. If `false`, entries are displayed oldest-first. */
    open var isSortedNewestFirst = true {
        didSet {
            tableView.reloadData()
        }
    }

    /** Governs the minimum `LogSeverity` to be shown in the view. Log entries
     with a severity lower than the `minimumSeverity` are not displayed. A
     value of `.verbose` causes all entries to be shown. */
    open var minimumSeverity = LogSeverity.verbose {
        didSet {
            tableView.reloadData()
        }
    }

    /** If `true`, new log entries will be scrolled into view automatically
     as they are recorded. */
    open var isFollowing = true {
        didSet {
            headerView.updateFollowingButton()

            if isFollowing && !oldValue {
                follow()
            }
        }
    }

    /** Controls the affordance given to the status bar when displayed in a
     fullscreen view controller. */
    open var statusBarHeight = CGFloat(0) {
        didSet {
            guard statusBarHeight != oldValue else { return }

            let newHeaderHeight = headerHeight + statusBarHeight
            headerBackgroundHeightConstraint.constant = newHeaderHeight
            headerTopConstraint.constant = statusBarHeight
            tableView.contentInset = UIEdgeInsets(top: newHeaderHeight, left: 0, bottom: 0, right: 0)
        }
    }

    fileprivate var userIsInteracting = false
    fileprivate var modifiedWhileUserInteracting = false
    fileprivate var itemCount = 0

    fileprivate let calendar: Calendar
    fileprivate let timeFormatter: DateFormatter
    fileprivate let dateFormatter: DateFormatter
    fileprivate let recorder: BufferedLogEntryMessageRecorder

    fileprivate var reverseNativeBufferOrder: Bool {
        return recorder.reverseChronological != isSortedNewestFirst
    }

    private let blurView: UIVisualEffectView
    private let vibrancyView: UIVisualEffectView
    private let tableView: UITableView
    private var headerView: LogInspectorHeaderView!
    private let tableFeeder: LiveLogTableFeeder
    private var headerBackgroundHeightConstraint: NSLayoutConstraint!
    private var headerTopConstraint: NSLayoutConstraint!
    private var recordItemCallbackHandle: CallbackHandle?
    private var clearBufferCallbackHandle: CallbackHandle?

    public init(recorder: BufferedLogEntryMessageRecorder)
    {
        self.recorder = recorder
        tableView = UITableView(frame: .zero, style: .plain)
        tableFeeder = LiveLogTableFeeder()
        calendar = Calendar(identifier: .gregorian)

        timeFormatter = DateFormatter()
        timeFormatter.setLocalizedDateFormatFromTemplate("jmsSSS")

        dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        let blur = UIBlurEffect(style: .extraLight)
        blurView = UIVisualEffectView(effect: blur)
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur))

        super.init(frame: .zero)

        tableFeeder.owner = self
        tableView.delegate = tableFeeder
        tableView.dataSource = tableFeeder

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tableView.register(LogEntryCell.self, forCellReuseIdentifier: cellID)

        headerView = LogInspectorHeaderView(owner: self)
        let headerBackgroundView = UIVisualEffectView(effect: UIBlurEffect())

        blurView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        headerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundView = nil
        tableView.backgroundColor = .clear

        blurView.contentView.addSubview(vibrancyView)
        addSubview(blurView)
        addSubview(tableView)
        addSubview(headerBackgroundView)
        addSubview(headerView)

        headerTopConstraint = headerView.topAnchor.constraint(equalTo: topAnchor)
        headerTopConstraint.isActive = true
        headerView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        headerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

        headerBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerBackgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        headerBackgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        headerBackgroundHeightConstraint = headerBackgroundView.heightAnchor.constraint(equalToConstant: headerHeight)
        headerBackgroundHeightConstraint.isActive = true

        blurView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true

        vibrancyView.topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
        vibrancyView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true
        vibrancyView.leadingAnchor.constraint(equalTo: blurView.leadingAnchor).isActive = true
        vibrancyView.trailingAnchor.constraint(equalTo: blurView.trailingAnchor).isActive = true

        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    public required init?(coder: NSCoder) { fatalError() }

    open override func willMove(toWindow window: UIWindow?)
    {
        if window != nil && itemCount != recorder.buffer.count {
            tableView.reloadData()
        }

        super.willMove(toWindow: window)
    }

    open override func didMoveToWindow()
    {
        if self.window != nil {
            clearBufferCallbackHandle = recorder.addCallback(didClearBuffer: { _ in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })

            recordItemCallbackHandle = recorder.addCallback(didRecordBufferItem: { _, item, didTruncate in
                guard !self.userIsInteracting else {
                    self.modifiedWhileUserInteracting = true
                    return
                }

                guard item.0.severity >= self.minimumSeverity else {
                    return
                }

                let reverseOrder = self.reverseNativeBufferOrder
                DispatchQueue.main.sync { [table = self.tableView, recorder = self.recorder] in
                    let reverse = recorder.reverseChronological
                    let lastItem = self.itemCount
                    let newestRow = reverse ? 0 : lastItem
                    let oldestRow = reverse ? lastItem : 0
                    let insertRow = reverseOrder ? oldestRow : newestRow
                    let deleteRow = reverseOrder ? newestRow : oldestRow

                    table.beginUpdates()

                    if didTruncate {
                        precondition(recorder.bufferLimit > 0)
                        table.deleteRows(at: [IndexPath(row: deleteRow, section: 0)], with: .fade)
                        self.itemCount -= 1
                    }

                    let insertPath = IndexPath(row: insertRow, section: 0)
                    let insertAtTop = (insertRow == 0)

                    let shouldScroll = self.shouldScroll(to: insertRow)

                    table.insertRows(at: [insertPath], with: insertAtTop ? .top : .automatic)
                    self.itemCount += 1

                    table.endUpdates()

                    if shouldScroll {
                        table.scrollToRow(at: insertPath, at: insertAtTop ? .top : .middle, animated: true)
                    }
                }
            })
        }
        else {
            // dropping the references to the handles will
            // cause the callbacks added above to be de-registered
            clearBufferCallbackHandle = nil
            recordItemCallbackHandle = nil
        }

        super.didMoveToWindow()
    }

    /**
     Toggles the value of the `isSortedNewestFirst` property.
     */
    open func toggleSortOrder()
    {
        isSortedNewestFirst = !isSortedNewestFirst
    }

    /**
     Toggles the value of the `isFollowing` property.
     */
    open func toggleIsFollowing()
    {
        isFollowing = !isFollowing
    }

    fileprivate func refresh()
    {
        tableView.reloadData()
    }

    private func shouldScroll(to row: Int)
        -> Bool
    {
        var shouldScroll = false
        if isFollowing, let visiblePaths = tableView.indexPathsForVisibleRows {
            if row == 0 {
                if let firstPath = visiblePaths.first {
                    shouldScroll = (row <= firstPath.row)
                }
            }
            else {
                if let lastPath = visiblePaths.last {
                    shouldScroll = (row > lastPath.row)
                }
            }
        }
        return shouldScroll
    }

    fileprivate func follow()
    {
        let reverse = recorder.reverseChronological
        let lastBufferItem = itemCount - 1
        let newestRow = reverse ? 0 : lastBufferItem
        let oldestRow = reverse ? lastBufferItem : 0
        let scrollToRow = reverseNativeBufferOrder ? oldestRow : newestRow

        if shouldScroll(to: scrollToRow) {
            let scrollToTop = (scrollToRow == 0)
            tableView.scrollToRow(at: IndexPath(row: scrollToRow, section: 0), at: scrollToTop ? .top : .middle, animated: true)
        }
    }
}

private class LiveLogTableFeeder: NSObject, UITableViewDataSource, UITableViewDelegate
{
    // the LiveLogTableFeeder will never outlive the LiveLogInspectorView that
    // owns it; therefore, the implicitly-unwrapped optional here is safe
    weak var owner: LiveLogInspectorView!

    fileprivate var buffer: [(LogEntry, String)] {
        var buffer = owner.recorder.buffer
        if owner.minimumSeverity != .verbose {
            buffer = buffer.filter{ $0.0.severity >= self.owner.minimumSeverity }
        }
        return buffer
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        guard section == 0 else { return 0 }

        owner.itemCount = buffer.count
        return owner.itemCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        precondition(indexPath.section == 0)

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! LogEntryCell

        let index = owner.reverseNativeBufferOrder
            ? owner.itemCount - indexPath.row - 1
            : indexPath.row

        let (logEntry, message) = buffer[index]
        cell.set(owner: owner, logEntry: logEntry, message: message)

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        (cell as! LogEntryCell).refreshTimestampIfNeeded()
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        (cell as! LogEntryCell).setTimestampNeedsRefresh()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        owner.isFollowing = false
        owner.userIsInteracting = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        owner.userIsInteracting = false

        if owner.modifiedWhileUserInteracting {
            owner.refresh()
            owner.modifiedWhileUserInteracting = false
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        guard !owner.isFollowing else { return }

        // see if we should automatically enable follow mode
        let topPoint = -scrollView.contentInset.top
        let bottomPoint = scrollView.contentSize.height - scrollView.bounds.size.height

        if owner.isSortedNewestFirst {
            if (scrollView.contentOffset.y - 10) < topPoint {
                owner.isFollowing = true
            }
        } else {
            if (scrollView.contentOffset.y + 10) > bottomPoint {
                owner.isFollowing = true
            }
        }
    }
}

private class LogInspectorHeaderView: UIView
{
    // the header view can't outlive the LiveLogInspectorView that
    // contains it; the implicitly-unwrapped optional here is safe
    private weak var owner: LiveLogInspectorView!
    private let closeButton: UIButton
    private let sortButton: UIButton
    private let filterButton: UIButton
    private let followButton: UIButton

    init(owner: LiveLogInspectorView)
    {
        self.owner = owner

        self.closeButton = UIButton(type: .custom)
        self.sortButton = UIButton(type: .custom)
        self.filterButton = UIButton(type: .custom)
        self.followButton = UIButton(type: .custom)

        super.init(frame: .zero)

#if os(iOS)
        let buttonFontSize = UIFont.smallSystemFontSize
#elseif os(tvOS)
        let buttonFontSize = CGFloat(18)
#endif

        closeButton.backgroundColor = UIColor(white: 0.0, alpha: 0.65)
        closeButton.setTitle("✖︎", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = (closeButtonSize / 2)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        closeButton.addTarget(self, action: #selector(closeButtonTriggered), for: .primaryActionTriggered)

        sortButton.contentHorizontalAlignment = .left
        sortButton.setTitleColor(.black, for: .normal)
        sortButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonFontSize)
        sortButton.addTarget(self, action: #selector(sortButtonTriggered), for: .primaryActionTriggered)

        filterButton.contentHorizontalAlignment = .left
        filterButton.setTitleColor(.black, for: .normal)
        filterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonFontSize)
        filterButton.addTarget(self, action: #selector(filterButtonTriggered), for: .primaryActionTriggered)

        followButton.contentHorizontalAlignment = .left
        followButton.setTitleColor(.black, for: .normal)
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonFontSize)
        followButton.addTarget(self, action: #selector(followButtonTriggered), for: .primaryActionTriggered)
        followButton.setTitle("⚪️ No follow", for: .normal)
        followButton.setTitle("🔘 Following", for: .selected)

        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [sortButton, filterButton, followButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = padding
        stackView.distribution = .fillEqually

        addSubview(closeButton)
        addSubview(stackView)

        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: closeButtonSize).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: closeButtonSize).isActive = true

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding).isActive = true
        stackView.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: padding * 2).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding).isActive = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func willMove(toWindow window: UIWindow?)
    {
        if window != nil {
            updateState()
        }

        super.willMove(toWindow: window)
    }

    @objc private func closeButtonTriggered()
    {
        owner.closeButtonTriggered(owner)
    }

    @objc private func sortButtonTriggered()
    {
        owner.toggleSortOrder()

        updateState()

        if owner.isFollowing {
            owner.follow()
        }
    }

    @objc private func filterButtonTriggered()
    {
        switch owner.minimumSeverity {
        case .verbose:  owner.minimumSeverity = .debug
        case .debug:    owner.minimumSeverity = .info
        case .info:     owner.minimumSeverity = .warning
        case .warning:  owner.minimumSeverity = .error
        case .error:    owner.minimumSeverity = .verbose
        }

        updateState()
    }

    @objc private func followButtonTriggered()
    {
        owner.toggleIsFollowing()
    }

    private func updateState()
    {
        if owner.isSortedNewestFirst {
            sortButton.setTitle("▲ New first", for: .normal)
        } else {
            sortButton.setTitle("▼ Old first", for: .normal)
        }

        switch owner.minimumSeverity {
        case .verbose:
            filterButton.setTitle("Showing all", for: .normal)

        case .debug:
            filterButton.setTitle(">=▪️debug", for: .normal)
            
        case .info:
            filterButton.setTitle(">=🔷info", for: .normal)

        case .warning:
            filterButton.setTitle(">=🔶warning", for: .normal)

        case .error:
            filterButton.setTitle(">=❌error", for: .normal)
        }

        updateFollowingButton()
    }

    fileprivate func updateFollowingButton()
    {
        followButton.isSelected = owner.isFollowing
    }
}

private class LogEntryCell: UITableViewCell
{
    private weak var owner: LiveLogInspectorView?
    private var logEntry: LogEntry?
    private var message: String?
    private var timestampNeedsRefresh = false
    private let severityLabel: UILabel
    private let messageLabel: UILabel
    private let timestampLabel: UILabel
    private let severityFormatter: SeverityLogFormatter

    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        severityFormatter = SeverityLogFormatter(style: .custom(textRepresentation: .colorCoded, truncateAtWidth: 1, padToWidth: 1, rightAlign: false))

        severityLabel = UILabel()
        messageLabel = UILabel()
        timestampLabel = UILabel()

        super.init(style: .subtitle, reuseIdentifier: cellID)

        severityLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false

        severityLabel.textAlignment = .center

        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byCharWrapping

        timestampLabel.textAlignment = .right

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(severityLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)

        severityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding).isActive = true
        severityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding).isActive = true
        severityLabel.widthAnchor.constraint(equalToConstant: 25).isActive = true
        severityLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -padding).isActive = true

        messageLabel.topAnchor.constraint(equalTo: severityLabel.topAnchor).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: severityLabel.trailingAnchor, constant: padding).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding).isActive = true
        messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -padding).isActive = true

        timestampLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: padding).isActive = true
        timestampLabel.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor).isActive = true
        timestampLabel.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor).isActive = true
        timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true
    }

    required init?(coder: NSCoder) { fatalError() }

    func set(owner: LiveLogInspectorView, logEntry: LogEntry, message: String)
    {
        self.owner = owner
        self.logEntry = logEntry
        self.message = message

        refreshDisplay()
    }

    func setTimestampNeedsRefresh()
    {
        timestampNeedsRefresh = true
    }

    func refreshDisplay()
    {
        severityLabel.text = logEntry.flatMap { severityFormatter.format($0) }
        messageLabel.text = message

        timestampNeedsRefresh = true
        refreshTimestampIfNeeded()

        owner?.styleSeverityLabel(severityLabel)
        owner?.styleMessageLabel(messageLabel)
    }

    func refreshTimestampIfNeeded()
    {
        guard timestampNeedsRefresh,
            let owner = owner,
            let logEntry = logEntry
        else {
            return
        }

        let timeStr = owner.timeFormatter.string(from: logEntry.timestamp)

        if owner.calendar.isDateInToday(logEntry.timestamp) {
            timestampLabel.text = timeStr
        } else {
            let dateStr = owner.dateFormatter.string(from: logEntry.timestamp)
            timestampLabel.text = dateStr + " " + timeStr
        }

        owner.styleTimestampLabel(timestampLabel)

        timestampNeedsRefresh = false
    }
}

#endif
