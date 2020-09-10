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

class VideoPlayer: NSObject, WKYTPlayerViewDelegate, UIGestureRecognizerDelegate {
    
    static let callVideoPlayer = VideoPlayer()
    
    
    let cardHeight:CGFloat = 750
    let cardHandleAreaHeight:CGFloat = 130
    
    var webView = WKYTPlayerView()
    var cardViewController = CardViewController()
    var visualEffectView:UIVisualEffectView!
    
    var checkIfPaused = true
    var cardVisible = false
    var checkifAnimationHappend = Bool()
    var checkIfPause = true
    var videoTitle = String()
    
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
    
    var topMusicTextLabel = MusicTextLabel()
    var middleMusicTextLabel = MusicTextLabel()
    
    var playerButton = MusicPlayerButton()
    var middlePlayerButton = MusicPlayerButton()
    var leftButton = MusicPlayerButton()
    var rightButton = MusicPlayerButton()
    
    var volMax = MusicPlayerButton()
    var volMin = MusicPlayerButton()
    
    var musicVolumeSlider = MusicVolumeSlider()
    
    var addToFavorite = MusicPlayerButton()
    var sharePlayedMusic = SharePlayedMusicButton()
    
    func videoPalyerClass(genreVideoID:String,index: Int,superView:UIViewController,ifCellIsSelected: Bool,selectedVideoTitle: String){
        videoTitle = selectedVideoTitle
//        setupCardVisualEffect()
        
        cardViewController = CardViewController(nibName:String(cardController), bundle:nil)
        
        superView.addChild(cardViewController)
        superView.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: superView.view.frame.height - cardHandleAreaHeight, width: superView.view.bounds.width, height: cardHeight)
        
        
        self.cardViewController.view.addSubview(self.webView)
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.pinWebView(to: cardViewController.view)
        self.webView.delegate = self
        self.webView.isHidden = true
        
        let playerVars: [AnyHashable: Any] = ["playsinline" : 1,"controls": "0","showinfo": "0",
                                              "origin": "https://www.youtube.com"]
        DispatchQueue.main.async {
            self.webView.load(withVideoId: genreVideoID, playerVars: playerVars)
        }
        middlePlayerButton = MusicPlayerButton(image: "btn-pause")
        
        self.musicPlayerButtonConfiguration()
        self.topMusicLabelConfiguration()
        
        UserDefaults.standard.set(true, forKey:"pause")
        
        
        let tapGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan(recognizer:)))
        
        cardViewController.view.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    @objc func rightButtonAction(sender: UIButton){
        
    }
    
    @objc func leftButtonAction(sender: UIButton){
        
    }
    
    
    @objc func playAndPauseButtonAction(sender: UIButton){
        VideoPlayer.callVideoPlayer.webView.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else {
                
                self?.updatePlayerState(playerState)
                if self?.checkIfPaused == false {
                    self?.webView.playVideo()
                    sender.setImage(UIImage(named: "btn-pause"), for: .normal)
                    UserDefaults.standard.set(true, forKey:"pause")
                }else{
                    self?.webView.pauseVideo()
                    sender.setImage(UIImage(named: "btn-play"), for: .normal)
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
    
    
    
//    func setupCardVisualEffect() {
//        visualEffectView = UIVisualEffectView()
//        visualEffectView.frame = CGRect(x: 0, y: 0, width: (self.superViewController?.view.frame.width)!, height: 145)
//        self.superViewController!.view.addSubview(visualEffectView)
//
//    }
    
    
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
                    //                    self.setupCardVisualEffect()
                    
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHeight
                    self.superViewController?.navigationController?.navigationBar.isHidden = true
                    self.superViewController?.tabBarController?.tabBar.isHidden = true
                    
                    self.middleMusicPlayerButtonConfiguration()
                    self.middleMusicLabelConfiguration()
                    self.musicPrevNextButtons()
                    self.musicPlayerVolumeSliderConfiguration()
                    self.topMusicTextLabel.isHidden = true
                    self.playerButton.isHidden = true
                    self.webView.isHidden = false
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = (self.superViewController?.view.frame.height)! - self.cardHandleAreaHeight
                    self.playerButton.isHidden  = false
                    self.topMusicLabelConfiguration()
                    
                    self.superViewController?.navigationController?.navigationBar.isHidden = false
                    self.superViewController?.tabBarController?.tabBar.isHidden = false
                    //                    self.visualEffectView.removeFromSuperview()
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
//                    self.visualEffectView.effect = UIBlurEffect(style: .systemThickMaterialDark)
                    break
                case .collapsed:
//                    self.visualEffectView.effect = nil
                    break
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
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
    
    
    
    final   func  topMusicLabelConfiguration() {
        topMusicTextLabel = MusicTextLabel(textTitle: videoTitle, textAlignment: .left)
        self.cardViewController.view.addSubview(topMusicTextLabel)
        self.topMusicTextLabel.pinTopMusicLabel(to: self.cardViewController.view, playerButton: self.playerButton)
        
    }
    
    
    final  func  middleMusicLabelConfiguration() {
        middleMusicTextLabel = MusicTextLabel(textTitle: videoTitle, textAlignment: .center)
        self.cardViewController.view.addSubview(middleMusicTextLabel)
        self.middleMusicTextLabel.pinMiddleMusicLabel(superView: self.cardViewController.view, webView: self.webView)
        
    }
    
    final func  musicPlayerButtonConfiguration() {
        playerButton = MusicPlayerButton(image: "btn-pause")
        self.cardViewController.view.addSubview(playerButton)
        self.playerButton.pinPlayerButton(to: self.cardViewController.view, middle: false)
        self.playerButton.addTarget(self, action: #selector(self.playAndPauseButtonAction(sender:)), for: .touchUpInside)
    }
    
    final func  middleMusicPlayerButtonConfiguration() {
        self.cardViewController.view.addSubview(middlePlayerButton)
        self.middlePlayerButton.pinPlayerButton(to: self.cardViewController.view, middle: true)
        self.middlePlayerButton.addTarget(self, action: #selector(self.playAndPauseButtonAction(sender:)), for: .touchUpInside)
    }
    
    func musicPrevNextButtons() {
        leftButton = MusicPlayerButton(image: "btn-previous")
        self.cardViewController.view.addSubview(leftButton)
        self.leftButton.pinLeftAndRightButtons(to: self.middlePlayerButton, ifLeft: true)
        
        rightButton = MusicPlayerButton(image: "btn-next")
        self.cardViewController.view.addSubview(rightButton)
        self.rightButton.pinLeftAndRightButtons(to: self.middlePlayerButton, ifLeft: false)
    }
    
    
    final func  musicPlayerVolumeSliderConfiguration() {
        self.cardViewController.view.addSubview(self.musicVolumeSlider)
        self.musicVolumeSlider.pinMusicVolumeSlider(to: self.cardViewController.view, to: self.middlePlayerButton)
        
        self.musicVolumeSlider.addTarget(self, action: #selector(self.sliderVolume(sender:)), for: .touchUpInside)
        
        volMin = MusicPlayerButton(image: "vol-min")
        self.cardViewController.view.addSubview(volMin)
        self.volMin.pinVolMaxAndVolMin(to: self.musicVolumeSlider, ifMax: false)
        
        volMax = MusicPlayerButton(image: "vol-max")
        
        self.cardViewController.view.addSubview(volMax)
        self.volMax.pinVolMaxAndVolMin(to: self.musicVolumeSlider, ifMax: true)
        
        //        addToFavorite = AddToFavoriteButton(image: "star.fill", text: "Library")
        //        self.addToFavorite.frame = CGRect(x: self.cardViewController.view.frame.origin.x, y: 600, width: 100, height: 30)
        //        self.cardViewController.view.addSubview(addToFavorite)
        //
        //
        //        sharePlayedMusic = SharePlayedMusicButton(image: "arrowshape.turn.up.right.fill", text: "Share")
        //        self.sharePlayedMusic.frame = CGRect(x: self.cardViewController.view.center.x + 40, y: 600, width: 230, height: 30)
        //        self.cardViewController.view.addSubview(sharePlayedMusic)
        
        
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
