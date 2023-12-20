import UIKit
import SSNeumorphicView
public protocol DayViewDelegate: AnyObject {
  func dayViewDidSelectEventView(_ eventView: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayView(dayView: DayView, didTapTimelineAt date: Date)
  func dayView(dayView: DayView, didLongPressTimelineAt date: Date)
  func dayViewDidBeginDragging(dayView: DayView)
  func dayViewDidTransitionCancel(dayView: DayView)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
  func dayView(dayView: DayView, didUpdate event: EventDescriptor)
}

public class DayView: UIView, TimelinePagerViewDelegate {
  public weak var dataSource: EventDataSource? {
    get {
      timelinePagerView.dataSource
    }
    set(value) {
      timelinePagerView.dataSource = value
    }
  }

  public weak var delegate: DayViewDelegate?

  /// Hides or shows header view
  public var isHeaderViewVisible = true {
    didSet {
      headerHeight = isHeaderViewVisible ? DayView.headerVisibleHeight : 0
      dayHeaderView.isHidden = !isHeaderViewVisible
      setNeedsLayout()
      configureLayout()
    }
  }

    let MARGIN:CGFloat = 12
  public var timelineScrollOffset: CGPoint {
    timelinePagerView.timelineScrollOffset
  }

  private static let headerVisibleHeight: CGFloat = 88
  public var headerHeight: CGFloat = headerVisibleHeight
  public var isFromCalendarScreen = true
  public var autoScrollToFirstEvent: Bool {
    get {
      timelinePagerView.autoScrollToFirstEvent
    }
    set (value) {
      timelinePagerView.autoScrollToFirstEvent = value
    }
  }

  public let dayHeaderView: DayHeaderView
  public let timelinePagerView: TimelinePagerView
  public let containerHeaderView:SSNeumorphicView
  public let containerDayTiming:SSNeumorphicView


  public var state: DayViewState? {
    didSet {
      dayHeaderView.state = state
      timelinePagerView.state = state
    }
  }

  public var calendar: Calendar = Calendar.current

  public var eventEditingSnappingBehavior: EventEditingSnappingBehavior {
    get {
      timelinePagerView.eventEditingSnappingBehavior
    }
    set {
      timelinePagerView.eventEditingSnappingBehavior = newValue
    }
  }

  private var style = CalendarStyle()

  public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
    //  self.calendar.timeZone = deviceTimezone
    self.calendar = calendar
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    self.containerHeaderView  = SSNeumorphicView()
    self.containerDayTiming  = SSNeumorphicView()
    super.init(frame: .zero)
    configure()
  }

  override public init(frame: CGRect) {
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    self.containerHeaderView  = SSNeumorphicView()
    self.containerDayTiming  = SSNeumorphicView()

    super.init(frame: frame)

    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    self.dayHeaderView = DayHeaderView(calendar: calendar)
    self.timelinePagerView = TimelinePagerView(calendar: calendar)
    self.containerHeaderView  = SSNeumorphicView()
    self.containerDayTiming  = SSNeumorphicView()

    super.init(coder: aDecoder)
    configure()
  }

  private func configure() {
      addSubview(containerHeaderView)
      addSubview(containerDayTiming)
      containerDayTiming.addSubview(timelinePagerView)
      containerHeaderView.addSubview(dayHeaderView)
      
      containerDayTiming.backgroundColor = SystemColors.systemBackground
      containerHeaderView.backgroundColor = SystemColors.systemBackground

      configureLayout()
      timelinePagerView.delegate = self

    if state == nil {
    let date = Date().UTCToLocalDate(inFormat: .preDefined).addHoursIfNeeded()
      let newState = DayViewState(date: Date().UTCToLocalDate(inFormat: .preDefined).addHoursIfNeeded(), calendar: calendar)
      newState.move(to: Date().UTCToLocalDate(inFormat: .preDefined).addHoursIfNeeded())
      state = newState
    }
  }
    func configureContainerView(_ selfView:SSNeumorphicView) {
        selfView.viewDepthType = .innerShadow
        selfView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        selfView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        selfView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        selfView.viewNeumorphicCornerRadius = 5
        selfView.viewNeumorphicShadowRadius = 1
        selfView.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    func configureContainerView2(_ selfView:SSNeumorphicView) {
        selfView.viewDepthType = .outerShadow
        selfView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        selfView.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        selfView.viewNeumorphicLightShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        selfView.viewNeumorphicCornerRadius = 5
        selfView.viewNeumorphicShadowRadius = 1
        selfView.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2 )

    }
    func initialiseContainerView() {
       // self.containerHeaderView  = SSNeumorphicView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: headerHeight + 12))

    }
  
  private func configureLayout() {
      configureContainerView(containerHeaderView)
      configureContainerView2(containerDayTiming)
    if #available(iOS 11.0, *) {
        headerContainerConstraints()
        dayTimeContainerConstraints()
        headerConstraints()
        dayTimeConstraints()
    }
  }
    func dayTimeContainerConstraints() {
        containerDayTiming.translatesAutoresizingMaskIntoConstraints = false
        containerDayTiming.clipsToBounds = true
        if isFromCalendarScreen{
            containerDayTiming.topAnchor.constraint(equalTo: containerHeaderView.bottomAnchor, constant: MARGIN).isActive = true
        } else{
            containerDayTiming.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        }

        containerDayTiming.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: MARGIN).isActive = true
        containerDayTiming.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -MARGIN).isActive = true
        containerDayTiming.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: MARGIN).isActive = true

    }
    func dayTimeConstraints() {
        timelinePagerView.translatesAutoresizingMaskIntoConstraints = false

        
        timelinePagerView.topAnchor.constraint(equalTo: containerDayTiming.topAnchor, constant: MARGIN).isActive = true

        timelinePagerView.leadingAnchor.constraint(equalTo: containerDayTiming.leadingAnchor).isActive = true
        timelinePagerView.trailingAnchor.constraint(equalTo: containerDayTiming.trailingAnchor).isActive = true
        timelinePagerView.bottomAnchor.constraint(equalTo: containerDayTiming.bottomAnchor).isActive = true
    }

    func headerContainerConstraints() {
        dayHeaderView.translatesAutoresizingMaskIntoConstraints = false

        dayHeaderView.leadingAnchor.constraint(equalTo: containerHeaderView.leadingAnchor, constant: MARGIN).isActive = true
            
        dayHeaderView.trailingAnchor.constraint(equalTo: containerHeaderView.trailingAnchor, constant: MARGIN).isActive = true

        dayHeaderView.topAnchor.constraint(equalTo: containerHeaderView.topAnchor, constant: MARGIN).isActive = true
            
        dayHeaderView.bottomAnchor.constraint(equalTo: containerHeaderView.bottomAnchor, constant: -MARGIN).isActive = true

    }
    func headerConstraints() {
        
        containerHeaderView.translatesAutoresizingMaskIntoConstraints = false

        containerHeaderView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: MARGIN).isActive = true
        containerHeaderView.clipsToBounds = true

       // containerHeaderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
            
        containerHeaderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -MARGIN).isActive = true


        containerHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        let heightConstraintContainer = containerHeaderView.heightAnchor.constraint(equalToConstant: headerHeight + MARGIN + MARGIN)
          //  heightConstraintContainer.priority = .defaultLow
            heightConstraintContainer.isActive = true
        }
    
  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle
    dayHeaderView.updateStyle(style.header)
    timelinePagerView.updateStyle(style.timeline)
  }

  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    timelinePagerView.timelinePanGestureRequire(toFail: gesture)
  }

  public func scrollTo(hour24: Float, animated: Bool = true) {
    timelinePagerView.scrollTo(hour24: hour24, animated: animated)
  }

  public func scrollToFirstEventIfNeeded(animated: Bool = true) {
    timelinePagerView.scrollToFirstEventIfNeeded(animated: animated)
  }

  public func reloadData() {
    timelinePagerView.reloadData()
  }
  
  public func move(to date: Date) {
    state?.move(to: date)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    if #available(iOS 11, *) {
        headerContainerConstraints()
        headerConstraints()
        dayTimeContainerConstraints()
        dayTimeConstraints()

    } else {
      dayHeaderView.frame = CGRect(origin: CGPoint(x: 0, y: layoutMargins.top),
                                   size: CGSize(width: bounds.width, height: headerHeight))
      let timelinePagerHeight = bounds.height - dayHeaderView.frame.maxY
      timelinePagerView.frame = CGRect(origin: CGPoint(x: 0, y: dayHeaderView.frame.maxY),
                                       size: CGSize(width: bounds.width, height: timelinePagerHeight))
    }
  }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    dayHeaderView.transitionToHorizontalSizeClass(sizeClass)
    updateStyle(style)
  }

  public func create(event: EventDescriptor, animated: Bool = false) {
    timelinePagerView.create(event: event, animated: animated)
  }

  public func beginEditing(event: EventDescriptor, animated: Bool = false) {
    timelinePagerView.beginEditing(event: event, animated: animated)
  }
  
  public func endEventEditing() {
    timelinePagerView.endEventEditing()
  }

  // MARK: TimelinePagerViewDelegate

  public func timelinePagerDidSelectEventView(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
    delegate?.dayViewDidLongPressEventView(eventView)
  }
  public func timelinePagerDidBeginDragging(timelinePager: TimelinePagerView) {
    delegate?.dayViewDidBeginDragging(dayView: self)
  }
  public func timelinePagerDidTransitionCancel(timelinePager: TimelinePagerView) {
    delegate?.dayViewDidTransitionCancel(dayView: self)
  }
  public func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date) {
    delegate?.dayView(dayView: self, willMoveTo: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date) {
    delegate?.dayView(dayView: self, didMoveTo: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didLongPressTimelineAt date: Date) {
    delegate?.dayView(dayView: self, didLongPressTimelineAt: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didTapTimelineAt date: Date) {
    delegate?.dayView(dayView: self, didTapTimelineAt: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didUpdate event: EventDescriptor) {
    delegate?.dayView(dayView: self, didUpdate: event)
  }
}
