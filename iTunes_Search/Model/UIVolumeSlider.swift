//
//  UIVolumeSlider.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 5/20/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import MediaPlayer
class UIVolumeSlider: UISlider {

 func activate(){
        updatePositionForSystemVolume()

        guard let view = superview else { return }
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.alpha = 0.000001
        view.addSubview(volumeView)

    try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)

        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }


    func deactivate(){
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        removeTarget(self, action: nil, for: .valueChanged)
        superview?.subviews.first(where: {$0 is MPVolumeView})?.removeFromSuperview()
    }


    func updatePositionForSystemVolume(){
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        value = AVAudioSession.sharedInstance().outputVolume
    }


    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume", let newVal = change?[.newKey] as? Float {
            setValue(newVal, animated: true)
        }
    }


    @objc private func valueChanged(){
        guard let superview = superview else {return}
        guard let volumeView = superview.subviews.first(where: {$0 is MPVolumeView}) as? MPVolumeView else { return }
        guard let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider else { return }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider.value = self.value
        }
    }

}
