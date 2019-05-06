//
//  ViewController.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/6/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let audio = BSAudioOutputStreamer(withOutputStream: OutputStream())
    }


    @IBAction func onSongsButtonPressed(_ sender: UIButton) {
        let browser = MPMediaPickerController(mediaTypes: .music)
        browser.allowsPickingMultipleItems = true
        browser.delegate = self
        present(browser, animated: true, completion: nil)
    }
}

extension ViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
