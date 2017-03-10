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

#if os(iOS)
private let hPadding = CGFloat(6)
private let vPadding = CGFloat(4)
private let headerHeight = CGFloat(50)
private let severityLabelWidth = CGFloat(25)
private let iconButtonSize = CGFloat(38)
#elseif os(tvOS)
private let hPadding = CGFloat(50)
private let vPadding = CGFloat(25)
private let headerHeight = CGFloat(100)
private let severityLabelWidth = CGFloat(50)
private let iconButtonSize = CGFloat(76)
#endif

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
    open var messageFont: UIFont = {
#if os(iOS)
        return UIFont.systemFont(ofSize: UIFont.systemFontSize)
#elseif os(tvOS)
        return UIFont.preferredFont(forTextStyle: .body)
#endif
    }()

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

    fileprivate let recorder: BufferedLogEntryMessageRecorder

    fileprivate var reverseNativeBufferOrder: Bool {
        return recorder.reverseChronological != isSortedNewestFirst
    }

    private let tableView: UITableView
    private var headerView: LogInspectorHeaderView!
    private var headerBackgroundHeightConstraint: NSLayoutConstraint!
    private let tableFeeder: LiveLogTableFeeder
    private var headerTopConstraint: NSLayoutConstraint!
    private var recordItemCallbackHandle: CallbackHandle?
    private var clearBufferCallbackHandle: CallbackHandle?

    public init(recorder: BufferedLogEntryMessageRecorder)
    {
        self.recorder = recorder
        tableView = UITableView(frame: .zero, style: .plain)
        tableFeeder = LiveLogTableFeeder()

        super.init(frame: .zero)

        tableFeeder.owner = self
        tableView.delegate = tableFeeder
        tableView.dataSource = tableFeeder

        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tableView.register(LogEntryCell.self, forCellReuseIdentifier: cellID)

        let headerBgColor = UIColor(white: 0.95, alpha: 1.0)

        let headerBackgroundView = UIView()
        headerBackgroundView.backgroundColor = headerBgColor
        headerView = LogInspectorHeaderView(owner: self)
        headerView.backgroundColor = headerBgColor

        headerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

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
    private let style: NSParagraphStyle
    private let alternatingBarColor: UIColor

    override init()
    {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.lineBreakMode = .byCharWrapping
        self.style = style

        self.alternatingBarColor = UIColor(red: 0.97, green: 1.0, blue: 0.99, alpha: 1.0)

        super.init()
    }

    fileprivate var buffer: [(LogEntry, String)] {
        var buffer = owner.recorder.buffer
        if owner.minimumSeverity != .verbose {
            buffer = buffer.filter{ $0.0.severity >= self.owner.minimumSeverity }
        }
        return buffer
    }

    func bufferIndex(for indexPath: IndexPath)
        -> Int
    {
        let index = owner.reverseNativeBufferOrder
            ? owner.itemCount - indexPath.row - 1
            : indexPath.row

        return index
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        guard section == 0 else { return 0 }

        owner.itemCount = buffer.count
        return owner.itemCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
        -> CGFloat
    {
        let width = tableView.bounds.width - (hPadding * 2)
        let size = CGSize(width: width, height: CGFloat.infinity)

        let index = bufferIndex(for: indexPath)
        let (_, message) = buffer[index]
        let rect = message.boundingRect(with: size,
                                       options: [.usesFontLeading, .usesLineFragmentOrigin, .truncatesLastVisibleLine],
                                       attributes: [NSFontAttributeName: owner.messageFont, NSParagraphStyleAttributeName: style],
                                       context: nil)

        let height = rect.height + (vPadding * 2)
        return height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        precondition(indexPath.section == 0)

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! LogEntryCell

        let index = bufferIndex(for: indexPath)
        let (logEntry, message) = buffer[index]
        cell.set(owner: owner, logEntry: logEntry, message: message)

        cell.backgroundColor = (index % 2 == 0) ? .white : alternatingBarColor

        return cell
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
    private let clearButton: UIButton
    private var interfaceWidth = InterfaceWidth.medium
    private var lastLayoutWidth = CGFloat(0)

    private enum InterfaceWidth {
        case small
        case medium
        case large
    }

    init(owner: LiveLogInspectorView)
    {
        self.owner = owner

        self.closeButton = UIButton(type: .custom)
        self.sortButton = UIButton(type: .custom)
        self.filterButton = UIButton(type: .custom)
        self.followButton = UIButton(type: .custom)
        self.clearButton = UIButton(type: .custom)

        super.init(frame: .zero)

        closeButton.setTitle("⊠", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.layer.cornerRadius = (iconButtonSize / 2)
        closeButton.addTarget(self, action: #selector(closeButtonTriggered), for: .primaryActionTriggered)

        sortButton.contentHorizontalAlignment = .left
        sortButton.setTitleColor(.black, for: .normal)
        sortButton.addTarget(self, action: #selector(sortButtonTriggered), for: .primaryActionTriggered)

        filterButton.contentHorizontalAlignment = .left
        filterButton.setTitleColor(.black, for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTriggered), for: .primaryActionTriggered)

        followButton.contentHorizontalAlignment = .left
        followButton.setTitleColor(.black, for: .normal)
        followButton.addTarget(self, action: #selector(followButtonTriggered), for: .primaryActionTriggered)

        clearButton.setTitle("🗑", for: .normal)
        clearButton.setTitleColor(.black, for: .normal)
        clearButton.addTarget(self, action: #selector(clearButtonTriggered), for: .primaryActionTriggered)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [sortButton, filterButton, followButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = hPadding
        stackView.distribution = .fillEqually

        addSubview(closeButton)
        addSubview(stackView)
        addSubview(clearButton)

        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: hPadding).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: iconButtonSize).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: iconButtonSize).isActive = true

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: vPadding).isActive = true
        stackView.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: hPadding * 2).isActive = true
        stackView.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: hPadding * -2).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vPadding).isActive = true

        clearButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -hPadding).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: iconButtonSize).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: iconButtonSize).isActive = true
    }

    required init?(coder: NSCoder) { fatalError() }

    private func adjust(to windowWidth: CGFloat)
    {
        guard windowWidth != lastLayoutWidth else { return }

        if windowWidth < 375 {
            interfaceWidth = .small
        }
        else if windowWidth > 375 {
            interfaceWidth = .large
        }
        else {
            interfaceWidth = .medium
        }

        Log.verbose?.value(windowWidth)
        Log.verbose?.value(lastLayoutWidth)
        Log.verbose?.value(interfaceWidth)

#if os(iOS)
        let textSize: CGFloat
        switch interfaceWidth {
        case .small, .medium:
            textSize = UIFont.smallSystemFontSize

        case .large:
            textSize = UIFont.systemFontSize
        }

        let textFont = UIFont.boldSystemFont(ofSize: textSize)
        let iconFont = UIFont.boldSystemFont(ofSize: 24)
#elseif os(tvOS)
        let textFont = UIFont.preferredFont(forTextStyle: .body)
        let iconFont = UIFont.preferredFont(forTextStyle: .headline)
#endif
        closeButton.titleLabel?.font = iconFont
        sortButton.titleLabel?.font = textFont
        filterButton.titleLabel?.font = textFont
        followButton.titleLabel?.font = textFont
        clearButton.titleLabel?.font = iconFont

        lastLayoutWidth = windowWidth
    }

    override func willMove(toWindow window: UIWindow?)
    {
        if let window = window {
            adjust(to: window.bounds.width)

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

    @objc private func clearButtonTriggered()
    {
        owner.recorder.clear()
    }

    private func updateState()
    {
        let shortSortTitle = owner.isSortedNewestFirst ? "▲ New" : "▼ Old"
        let sortTitle: String
        switch interfaceWidth {
        case .small:    sortTitle = shortSortTitle
        case .medium:   sortTitle = "\(shortSortTitle)est"
        case .large:    sortTitle = "\(shortSortTitle) first"
        }
        sortButton.setTitle(sortTitle, for: .normal)

        let filterTitle: String
        switch owner.minimumSeverity {
        case .verbose:
            switch interfaceWidth {
            case .small:            filterTitle = "All"
            case .medium, .large:   filterTitle = "Showing all"
            }

        case .debug:
            switch interfaceWidth {
            case .small:    filterTitle = ">=debug"
            case .medium:   filterTitle = ">=▪️debug"
            case .large:    filterTitle = ">= ▪️debug"
            }

        case .info:
            switch interfaceWidth {
            case .small:    filterTitle = ">=info"
            case .medium:   filterTitle = ">=🔷info"
            case .large:    filterTitle = ">= 🔷info"
            }

        case .warning:
            switch interfaceWidth {
            case .small:    filterTitle = ">=warn"
            case .medium:   filterTitle = ">=🔶warn"
            case .large:    filterTitle = ">= 🔶warning"
            }

        case .error:
            switch interfaceWidth {
            case .small:    filterTitle = ">=error"
            case .medium:   filterTitle = ">=❌error"
            case .large:    filterTitle = ">= ❌error"
            }
        }
        filterButton.setTitle(filterTitle, for: .normal)

        updateFollowingButton()
    }

    fileprivate func updateFollowingButton()
    {
        let title: String
        if owner.isFollowing {
            switch interfaceWidth {
            case .small:            title = "🔘 Follow"
            case .medium, .large:   title = "🔘 Following"
            }
        } else {
            switch interfaceWidth {
            case .small:            title = "⚪️ Follow"
            case .medium, .large:   title = "⚪️ Following"
            }
        }
        followButton.setTitle(title, for: .normal)
    }
}

private class LogEntryCell: UITableViewCell
{
    private let messageLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        messageLabel = UILabel()

        super.init(style: .subtitle, reuseIdentifier: cellID)

        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byCharWrapping

        contentView.addSubview(messageLabel)
    }

    required init?(coder: NSCoder) { fatalError() }

    func set(owner: LiveLogInspectorView, logEntry: LogEntry, message: String)
    {
        switch logEntry.severity {
        case .verbose:  messageLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        case .debug:    messageLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        case .info:     messageLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.8, alpha: 1.0)
        case .warning:  messageLabel.textColor = UIColor(red: 0.867, green: 0.467, blue: 0.133, alpha: 1.0)
        case .error:    messageLabel.textColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        }

        messageLabel.font = owner.messageFont
        messageLabel.text = message
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()

        var frame = contentView.bounds
        frame.origin.x += hPadding
        frame.origin.y += vPadding
        frame.size.width -= (hPadding * 2)
        frame.size.height -= (vPadding * 2)

        messageLabel.frame = frame
    }
}

#endif
