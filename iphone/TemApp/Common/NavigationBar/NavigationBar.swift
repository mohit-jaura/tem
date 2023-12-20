//
//  NavigationBar.swift
//  Omakase
//
//  Created by Harpreet on 24/10/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//


// MARK: Protocol.
protocol NavigationDelegate: AnyObject {
    func navigationBar(_ navigationBar: NavigationBar,leftButtonTapped leftButton: UIButton)
    func navigationBar(_ navigationBar: NavigationBar,rightButtonTapped rightButton: UIButton)
    func navigationBar(_ navigationBar: NavigationBar,titleLabelTapped titleLabel: UILabel)
}

enum ButtonType {
    case Search
    case Filter
    case AddPost
}

enum ButtonAction {
    case back1
    case back
    case menu
    case hidden
    case search
    case filter
    case addPost
    case share
    case activityFilter
    case dot
    case startNewChat
    case delete
    case edit
    case editWhite
    case menuWhite
    case backWhite
    
    var icon: UIImage? {
        switch self {
        case .back1:return #imageLiteral(resourceName: "<")
        case .back: return #imageLiteral(resourceName: "left-arrow")
        case .menu: return #imageLiteral(resourceName: "menu")
        case .search: return #imageLiteral(resourceName: "search")
        case .filter: return #imageLiteral(resourceName: "filter")
        case .addPost: return #imageLiteral(resourceName: "aad_frndNew")
        case .share: return #imageLiteral(resourceName: "postShare")
        case .hidden : return nil
        case .activityFilter : return #imageLiteral(resourceName: "filterIcon")
        case .dot : return #imageLiteral(resourceName: "more")
        case .startNewChat: return #imageLiteral(resourceName: "edit")
        case .edit: return #imageLiteral(resourceName: "edit")
        case .delete: return #imageLiteral(resourceName: "deleteRed")
        case .menuWhite: return #imageLiteral(resourceName: "menuWhite")
        case .backWhite: return #imageLiteral(resourceName: "left-arrowWhite")
        case .editWhite: return #imageLiteral(resourceName: "editWhite")
        }
        
    }
}

import UIKit
class NavigationBar: UIViewController {
    
    
    // MARK: IBOulets.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet var rightButton: [UIButton]!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    // MARK: Variables.
    weak var delegate:NavigationDelegate?
    var leftAction:ButtonAction = .back
    var rightAction:[ButtonAction] = [.hidden]
    var isProfile = false
    
    // MARK: ViewLifeCycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Methods
    // MARK: ... Public
    func configureNavigation(_ title: String? = nil, leftButtonAction leftAction: ButtonAction = .back,rightButtonAction: [ButtonAction] = [.hidden],backgroundColor: UIColor = .clear, showBottomSeparator: Bool? = false) {
        addGesture()
        self.view.backgroundColor = backgroundColor
        setupAppearance(on: leftButton, withAction: leftAction)
        self.bottomLineView.isHidden = !showBottomSeparator!
        self.leftAction = leftAction
        self.titleLabel.text = title
        self.titleLabel.font = UIFont(name: "Roboto-Bold", size: 17)
//        for (_,button) in rightButton.enumerated() {
//            if button.tag < rightButtonAction.count {
//                setupAppearance(on: button, withAction: rightButtonAction[button.tag])
//            }else{
//                setupAppearance(on: button, withAction: .hidden)
//            }
//        }
        updateRightButtonItems(rightButtonAction: rightButtonAction)
    }
    
    func updateRightButtonItems(rightButtonAction: [ButtonAction]) {
        self.rightAction = rightButtonAction
        for (_,button) in rightButton.enumerated() {
            if button.tag < rightButtonAction.count {
                setupAppearance(on: button, withAction: rightButtonAction[button.tag])
            }else{
                setupAppearance(on: button, withAction: .hidden)
            }
        }
    }
    
    func setupAppearance(on button: UIButton, withAction action: ButtonAction) -> Void {
        if action == .hidden {
            button.isUserInteractionEnabled = false
        }else{
            button.isUserInteractionEnabled = true
        }
        button.setImage(action.icon, for: UIControl.State())
        if isProfile{
            if action == .back{
                button.setImage(#imageLiteral(resourceName: "arrowupSmall"), for: UIControl.State())
            } else {
                button.setImage(action.icon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: UIControl.State())
                button.tintColor = .white
            }
        }
    
    }
    
    /// display the badge view on menu icon
    /// - Parameter unreadCount: unread count of notifcations
    func displayBadge(unreadCount: Int?) {
        if self.leftAction == .menu || self.leftAction == .menuWhite {
            DispatchQueue.main.async {
                if let value = unreadCount,
                    value > 0 {
                    self.badgeView.isHidden = false
                } else {
                    self.badgeView.isHidden = true
                }
            }
        }
    }
    
    // MARK:- IBActions Methods
    @IBAction func leftButtonTapped(_ sender: UIButton) -> Void {
        delegate?.navigationBar(self, leftButtonTapped: sender)
    }
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        delegate?.navigationBar(self, rightButtonTapped: sender)
    }
    
    // MARK: Function to add Gesture.
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        self.titleLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func titleLabelTapped(recognizer: UITapGestureRecognizer) {
        delegate?.navigationBar(self, titleLabelTapped: titleLabel)
    }
    
}

