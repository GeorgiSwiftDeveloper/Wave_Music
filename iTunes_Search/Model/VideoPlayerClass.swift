//
//  VideoPlayerClass.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/3/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import MediaPlayer
import YoutubePlayer_in_WKWebView

class VideoPlayerClass: NSObject, WKYTPlayerViewDelegate, UIGestureRecognizerDelegate {
    
    static let callVideoPlayer = VideoPlayerClass()
    
    
    let cardHeight:CGFloat = 800
    let cardHandleAreaHeight:CGFloat = 130
    var playerView = UIView()
    var webView = WKYTPlayerView()
    var cardViewController = CardViewController()
    //    var visualEffectView:UIVisualEffectView!
    var checkCardView = Bool()
    var checkIfPaused = true
    var musicLabelText = UILabel()
    var musicLabelText2 = UILabel()
    var playButton = UIButton()
    var playButton2 = UIButton()
    var cardVisible = false
    var checkifAnimationHappend = Bool()
    
    var leftButton = UIButton()
    var rightButton = UIButton()
    var volumeSlider = UISlider()
    var systemSlider = UISlider()
    var volMax = UIImageView()
    var volMin = UIImageView()
    var addToFavorite = UIButton()
    var sharePlayedMusic = UIButton()
    var checkIfPause = true
    var videoID = String()
    var videoIndex = Int()
    var videoTitle = String()
    var checkIfCollapsed = Bool()
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    var superViewController: UIViewController?
    
    
    func videoPalyerClass(sellectedCell: UITableViewCell,genreVideoID:String,index: Int,superView:UIViewController,ifCellIsSelected: Bool,selectedVideoTitle: String){
        
        videoID = genreVideoID
        videoIndex = index
        videoTitle = selectedVideoTitle
        if checkCardView{
            self.cardViewController.view.removeFromSuperview()
            checkCardView = false
        }
        //        visualEffectView = UIVisualEffectView()
        //        visualEffectView.frame = self.superViewController?.view.frame as! CGRect
        //        self.superViewController!.view.addSubview(visualEffectView)
        //        self.visualEffectView.effect = nil
        
        
        
        
        checkCardView = true
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        cardViewController.view.backgroundColor = #colorLiteral(red: 0.0632667467, green: 0.0395433642, blue: 0.1392272115, alpha: 1)
        self.cardViewController.view.layer.cornerRadius = 12
        superView.addChild(cardViewController)
        superView.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: superView.view.frame.height - cardHandleAreaHeight, width: superView.view.bounds.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
        
        self.webView = WKYTPlayerView(frame: CGRect(x: 0, y: 55, width: UIScreen.main.bounds.width, height: 220))
        
        self.cardViewController.view.addSubview(self.webView)
        let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                              "origin": "https://www.youtube.com"]
//        self.webView.load(withVideoId: genreVideoID[index], playerVars: playerVars)
        
        self.webView.load(withVideoId: genreVideoID, playerVars: playerVars)
        self.webView.delegate = self
        self.webView.isHidden = true
        
        
        volumeSlider.frame = CGRect(x: self.cardViewController.view.center.x - 120, y: 500, width: 250, height: 25)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 100
        volumeSlider.setValue(80, animated: true)
        volumeSlider.isContinuous = true
        volumeSlider.tintColor = UIColor.white
        volumeSlider.isHidden = true
        self.cardViewController.view.addSubview(volumeSlider)
        
        
        
        
        
        self.musicLabelText.frame = CGRect(x: 10, y: 5, width: Int(UIScreen.main.bounds.width - 100), height: 40)
        self.musicLabelText.numberOfLines = 0
        self.musicLabelText.textAlignment = .left
        self.musicLabelText.font = UIFont(name: "Verdana-Bold", size: 10)
        self.musicLabelText.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        self.musicLabelText.text = videoTitle[self.videoIndex]
           self.musicLabelText.text = videoTitle
        self.cardViewController.view.addSubview(self.musicLabelText)
        
        self.musicLabelText2.numberOfLines = 0
        self.musicLabelText2.textAlignment = .left
        self.musicLabelText2.font = UIFont(name: "Verdana-Bold", size: 10)
        self.musicLabelText2.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        self.musicLabelText2.text = videoTitle[self.videoIndex]
        self.musicLabelText2.text = videoTitle
        self.musicLabelText2.isHidden = true
        self.cardViewController.view.addSubview(self.musicLabelText2)
        
        
        self.playButton.frame = CGRect(x: self.cardViewController.view.center.x + 160, y: 10, width: 30, height: 30)
        self.playButton.addTarget(self, action: #selector(self.playAndPauseButtonAction(sender:)), for: .touchUpInside)
        self.cardViewController.view.addSubview(self.playButton)
        
        
        self.playButton2.addTarget(self, action: #selector(self.playAndPauseButtonAction(sender:)), for: .touchUpInside)
        self.playButton2.isHidden = true
        self.cardViewController.view.addSubview(self.playButton2)
        
        self.leftButton.addTarget(self, action: #selector(self.leftButtonAction(sender:)), for: .touchUpInside)
        self.rightButton.addTarget(self, action: #selector(self.rightButtonAction(sender:)), for: .touchUpInside)
        
        
        webView.playVideo()
        self.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
        self.playButton2.setImage(UIImage(named: "btn-pause"), for: .normal)
        UserDefaults.standard.set(true, forKey:"pause")
        
        
        let tapGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan(recognizer:)))
        
        cardViewController.view.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    @objc func rightButtonAction(sender: UIButton){
        
        if self.videoIndex == self.videoID.count - 1{
            self.videoIndex = -1
        }else{
            self.videoIndex += 1
//            self.musicLabelText.text = videoTitle[self.videoIndex]
//            self.musicLabelText2.text = videoTitle[self.videoIndex]
            let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                                  "origin": "https://www.youtube.com"]
//            self.webView.load(withVideoId: self.videoID[self.videoIndex], playerVars: playerVars)
            self.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
            self.playButton2.setImage(UIImage(named: "btn-pause"), for: .normal)
            
        }
    }
    
    @objc func leftButtonAction(sender: UIButton){
        if self.videoIndex == 0{
            self.videoIndex = self.videoID.count
        }else{
            self.videoIndex -= 1
//            self.musicLabelText.text = videoTitle[self.videoIndex]
//            self.musicLabelText2.text = videoTitle[self.videoIndex]
            let playerVars: [AnyHashable: Any] = ["playsinline" : 1,
                                                  "origin": "https://www.youtube.com"]
//            self.webView.load(withVideoId: self.videoID[self.videoIndex], playerVars: playerVars)
            self.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
            self.playButton2.setImage(UIImage(named: "btn-pause"), for: .normal)
        }
    }
    
    
    @objc func playAndPauseButtonAction(sender: UIButton){
        VideoPlayerClass.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? WKYTPlayerState {
                
                self?.updatePlayerState(playerState)
                if self?.checkIfPaused == false {
                    self?.webView.playVideo()
                    self?.playButton.setImage(UIImage(named: "btn-pause"), for: .normal)
                    self?.playButton2.setImage(UIImage(named: "btn-pause"), for: .normal)
                    UserDefaults.standard.set(true, forKey:"pause")
                }else{
                    self?.webView.pauseVideo()
                    self?.playButton.setImage(UIImage(named: "btn-play"), for: .normal)
                    self?.playButton2.setImage(UIImage(named: "btn-play"), for: .normal)
                    UserDefaults.standard.set(false, forKey:"pause")
                }
            }
        })
    }
    
    
    
    func updatePlayerState(_ playerState: WKYTPlayerState){
        switch playerState {
        case .ended:
            checkIfPaused = false
        case .paused:
            checkIfPaused = false
        case .playing:
            checkIfPaused = true
        default:
            break
        }
    }
    
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        webView.playVideo();
    }
    
    
    
    
    
    
    @objc func handleCardTap(recognzier:UIPanGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.6)
        default:
            break
        }
    }
    
    
    @objc func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.6)
        case .changed:
            let translation = recognizer.translation(in: self.cardViewController.view)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    
    
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.7) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHeight
                    self.cardViewController.view.layer.opacity = 1
                    self.playButton2.frame = CGRect(x: self.cardViewController.view.center.x - 30, y: 400, width: 60, height: 60)
                    self.musicLabelText2.frame = CGRect(x: 10, y: Int(self.cardViewController.view.center.y) - 180, width: Int(UIScreen.main.bounds.width) - 20, height: 50)
                    self.cardViewController.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    self.leftandRightButton()
                    self.musicLabelText2.textAlignment = .center
                    self.superViewController?.navigationController?.navigationBar.isHidden = true
                    self.superViewController?.tabBarController?.tabBar.isHidden = true
                    self.volumeSlider.addTarget(self, action: #selector(self.sliderVolume(sender:)), for: .touchUpInside)
                    self.musicLabelText2.isHidden = false
                    self.playButton2.isHidden = false
                    self.musicLabelText.isHidden = true
                    self.playButton.isHidden = true
                    self.webView.isHidden = false
                    self.volumeSlider.isHidden = false
                    self.playerView.isHidden = false
                    self.checkIfCollapsed = false
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHandleAreaHeight
                    self.playButton.frame = CGRect(x: self.cardViewController.view.center.x + 160, y: 10, width: 30, height: 30)
                    self.musicLabelText.frame = CGRect(x: 10, y: 5, width: Int(UIScreen.main.bounds.width - 100), height: 40)
                    self.cardViewController.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    self.musicLabelText.numberOfLines = 0
                    self.musicLabelText.textAlignment = .left
                    self.musicLabelText.font = UIFont(name: "Verdana-Bold", size: 10)
                    self.superViewController?.navigationController?.navigationBar.isHidden = false
                    self.superViewController?.tabBarController?.tabBar.isHidden = false
                    self.checkIfCollapsed = true
                    if ((self.superViewController as? MyLibraryViewController) != nil) {
                       self.superViewController?.viewDidLoad()
                    }
                  
                    // self.visualEffectView.removeFromSuperview()
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 16
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 12
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    break
                    //                    self.visualEffectView.effect = UIBlurEffect(style: .systemThickMaterialDark)
                    
                case .collapsed:
                    self.musicLabelText.isHidden = false
                    self.playButton.isHidden = false
                    //                    self.visualEffectView.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
        }
    }
    
    
    func leftandRightButton(){
        
        self.leftButton.frame = CGRect(x: self.cardViewController.view.center.x - 120, y: 400, width: 60, height: 60)
        self.leftButton.setImage(UIImage(named: "btn-previous"), for: .normal)
        self.cardViewController.view.addSubview(leftButton)
        
        self.rightButton.frame = CGRect(x: self.cardViewController.view.center.x + 60, y: 400, width: 60, height: 60)
        self.rightButton.setImage(UIImage(named: "btn-next"), for: .normal)
        self.cardViewController.view.addSubview(rightButton)
        
        self.volMin.frame = CGRect(x: self.cardViewController.view.center.x - 145, y: 505, width: 15, height: 15)
        self.volMin.image = UIImage(named: "vol-min")
        self.cardViewController.view.addSubview(volMin)
        
        
        self.volMax.frame = CGRect(x: self.cardViewController.view.center.x + 145, y: 505, width: 15, height: 15)
        self.volMax.image = UIImage(named: "vol-max")
        self.cardViewController.view.addSubview(volMax)
        
        
        let textFont = UIFont(name: "Helvetica Bold", size: 11)
        
        self.addToFavorite.frame = CGRect(x: self.cardViewController.view.frame.origin.x, y: 600, width: 100, height: 30)
        self.addToFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
        self.addToFavorite.imageView?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.addToFavorite.imageView?.clipsToBounds = true
        self.addToFavorite.setTitle("  My Library", for: .normal)
        self.addToFavorite.titleLabel?.font = textFont
        
        self.cardViewController.view.addSubview(addToFavorite)
        
        
        self.sharePlayedMusic.frame = CGRect(x: self.cardViewController.view.center.x + 40, y: 600, width: 230, height: 30)
        self.sharePlayedMusic.setImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
        self.sharePlayedMusic.imageView?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.sharePlayedMusic.imageView?.clipsToBounds = true
        self.sharePlayedMusic.setTitle(" Share", for: .normal)
        self.sharePlayedMusic.titleLabel?.font = textFont
        self.cardViewController.view.addSubview(sharePlayedMusic)
        
        
    }
    
    
    @objc  func sliderVolume(sender: UISlider) {
        switch Int(sender.value) {
        case 0:
            MPVolumeView.setVolume(0.0)
        case 5...15:
            MPVolumeView.setVolume(0.2)
        case 15...20:
            MPVolumeView.setVolume(0.3)
        case 20...40:
            MPVolumeView.setVolume(0.4)
        case 40...60:
            MPVolumeView.setVolume(0.5)
        case 60...80:
            MPVolumeView.setVolume(0.7)
        case 80...100:
            MPVolumeView.setVolume(1)
        default:
            break
        }
    }
    
    
    
    
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    
    
}


extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
