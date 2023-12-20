import UIKit

public enum SystemColors {
  public static var label: UIColor {
    if #available(iOS 13, *) {
      return .white
    }
    return .white
  }
  public static var secondaryLabel: UIColor {
    if #available(iOS 13, *) {
      return .lightGray
    }
    return .lightGray
  }
    
    public static var systemMainColor: UIColor {
      if #available(iOS 13, *) {
          return UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1)
      }
        return UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1)
    }
    
    public static var systemMainSecondColor: UIColor {
      if #available(iOS 13, *) {
          return UIColor(red: 89/255, green: 129/255, blue: 217/255, alpha: 1)
      }
        return UIColor(red: 89/255, green: 129/255, blue: 217/255, alpha: 1)
    }

  public static var systemBackground: UIColor {
    if #available(iOS 13, *) {
        return UIColor.clear
        //return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
    }
      return UIColor.clear
     // return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
  }
  public static var secondarySystemBackground: UIColor {
    if #available(iOS 13, *) {
      return .secondarySystemBackground
    }
    return UIColor(white: 247/255, alpha: 1)
  }
  public static var systemRed: UIColor {
    if #available(iOS 13, *) {
      return .systemRed
    }
    return .red
  }
  public static var systemBlue: UIColor {
    if #available(iOS 13, *) {
      return .systemBlue
    }
    return .blue
  }
  public static var systemGray4: UIColor {
    if #available(iOS 13, *) {
      return .systemGray4
    }
    return UIColor(red: 209/255,
                   green: 209/255,
                   blue: 213/255, alpha: 1)
  }
  public static var systemSeparator: UIColor {
    if #available(iOS 13, *) {
      return UIColor.clear
    }
      return UIColor.clear
  }
}
