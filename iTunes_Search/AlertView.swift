//
//  AlertView.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import Foundation
import UIKit


class AlertView: UIView {
    
    static let instance = AlertView()
    var cardVC = VideoPlayer()
    
    @IBOutlet var perentView: UIView!
    @IBOutlet weak var alerView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var musicImageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("AlerView", owner: self, options: nil)

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init has not been impemented")
    }

    
    
    private func commonInit() {
        img.layer.cornerRadius = 30
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = 2
        
        perentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        perentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
    
    enum AlertType {
        case success
        case failure
    }

    
    func showAlert(title: String, message: String, alertType: AlertType,videoImage:String){
        self.titleLabel.text = title
    
        let imageUrl = URL(string: videoImage)
        do{
            if let image = imageUrl {
            let data:NSData = try NSData(contentsOf: image)
            self.musicImageView.image =  UIImage(data: data as Data)
            }
        }catch{
            print("error")
        }
        switch alertType {
        case .success:
            img.image = UIImage(named: "success")
            alerView.layer.cornerRadius = 8.0
            doneButton.layer.cornerRadius = 8.0
            musicImageView.layer.cornerRadius = 5.0
        case .failure:
             img.image = UIImage(named: "failure")
        }
        
        UIApplication.shared.keyWindow?.addSubview(perentView)
    }
    @IBAction func clickDoneAction(_ sender: Any) {
        if VideoPlayer.callVideoPlayer.videoPlayerSelected {
            VideoPlayer.callVideoPlayer.favoriteHeartButton()
            perentView.removeFromSuperview()
        }else{
        perentView.removeFromSuperview()
        }
    }
}

