//
//  WelcomeViewController.swift
//  StudentApp
//
//  Created by Harmeet on 10/02/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit
class WelcomeViewController: UIViewController, iCarouselDataSource, iCarouselDelegate  {
    
//    @IBOutlet weak var verticalPageControl: CHIPageControlJalapeno!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        carousel.type = .linear
        carousel.bounces = false
        carousel.isPagingEnabled = true
        pageControl.numberOfPages = 5
        doneButton.isHidden = true
        //you can activate touch through code
//        self.verticalPageControl.enableTouchEvents = true
//        self.verticalPageControl.delegate = self
//        self.verticalPageControl.numberOfPages = 5


    }
    /**
     dismiss view method
     */
    @IBAction func dismissView(_ sender: UIButton?) {
        self.remove()
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 5
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: ProfileView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? ProfileView  {
            itemView = view
        } else {
            
            itemView = (Bundle.main.loadNibNamed("ProfileView",
                                                 owner: nil,options: nil)?.first as! ProfileView?)!
            itemView .frame = CGRect(x: 0, y: 0, width: carousel.frame.width, height: carousel.frame.height)
            itemView.contentMode = .center
                    }
        itemView.displayData(index: index)

        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        print(carousel.currentItemIndex)
        if (option == .spacing) {
            return value * 1.1
        }
        pageControl.currentPage = carousel.currentItemIndex
        doneButton.isHidden = true
        if carousel.currentItemIndex == 4 {
            doneButton.isHidden = false
        }
     //   verticalPageControl.progress = Double(carousel.currentItemIndex)

        return value
    }
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
      //  print("dd",carousel.currentItemIndex)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension UIViewController {
    func add(_ parent: UIViewController) {
        parent.addChild(self)
        parent.view.addSubview(view)
        didMove(toParent: parent)
    }

    func remove() {
     //   guard parent != nil else { return }
        self.dismiss(animated: false, completion: nil)
//        willMove(toParent: nil)
//        removeFromParent()
//        view.removeFromSuperview()

    }
}
