//
//  PopVC.swift
//  pixel_city
//
//  Created by Arsalan majlesi on 6/14/21.
//

import UIKit


class PopVC : UIViewController , UIGestureRecognizerDelegate{
    
    @IBOutlet weak var image: UIImageView!
    var selectedImg : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = selectedImg
        initDoubletapRec()
        
    }
    
    func initDoubletapRec(){
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tapGestureRec.numberOfTapsRequired = 2
        tapGestureRec.delegate = self
        view.addGestureRecognizer(tapGestureRec)
    }
    
    @objc func doubleTapped(){
        dismiss(animated: true, completion: nil)
    }
    
    func initData(img:UIImage){
        selectedImg = img
    }
}
