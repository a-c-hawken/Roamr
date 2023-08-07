//
//  WelcomeViewController.swift
//  Roamr
//
//  Created by Aydan Hawken on 7/08/23.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        // Do any additional setup after loading the view.
    }
    var scrollView: UIScrollView!
    
    private func configure(){
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view.addSubview(scrollView)
        
        let titles = ["Welcome to Roamr", "Learn the UI"]
        for x in 0..<2 {
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * view.frame.size.width, y: 0, width: view.frame.size.width, height: scrollView.frame.size.height))
            scrollView.addSubview(pageView)
            
            //Image
            let imageView = UIImageView(frame: CGRect(x: -5, y: 0, width: pageView.frame.size.width + 20, height: pageView.frame.size.height + 20))
            imageView.contentMode = .scaleAspectFit
            if x == 0 {
                imageView.image = UIImage(named: "roamrMain")}
            else if x == 1 {
                imageView.image = UIImage(named: "roamrUIlearn")}
            
            pageView.addSubview(imageView)
            
            //Button
            let button = UIButton(frame: CGRect(x: 10, y: pageView.frame.size.height - 60 - 15, width: pageView.frame.size.width - 20, height: 60))
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitle("Continue", for: .normal)
            if x == 1 {
                button.setTitle("Begin my journey", for: .normal)
            }
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 20.0
            button.tag = x + 1
            pageView.addSubview(button)
        }
    }
    
    @objc func didTapButton(_ button: UIButton){
        guard button.tag < 2 else {
            //Dismiss
            Core.shared.setIsNotNewUser()
            dismiss(animated: true, completion: nil)
            return
        }
        
        //Scroll to next page
        let x = CGFloat(button.tag) * view.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
