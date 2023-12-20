import Foundation

extension Date {
  func dateOnly2(calendar: Calendar) -> Date {
    let yearComponent = calendar.component(.year, from: self)
    let monthComponent = calendar.component(.month, from: self)
    let dayComponent = calendar.component(.day, from: self)
    let zone = calendar.timeZone

    let newComponents = DateComponents(timeZone: zone,
                                       year: yearComponent,
                                       month: monthComponent,
                                       day: dayComponent) // here,6 hours added because of timezone
    let returnValue = calendar.date(from: newComponents)
    return returnValue!
  }
}
