//
//  ViewController.swift
//  SeeFood
//
//  Created by Hyeongjin Um on 9/9/17.
//  Copyright © 2017 Hyeongjin Um. All rights reserved.
//

import UIKit
import CoreML
import Vision

import AVFoundation

// UIPickerViewDelegate rely on UINavigationControllerDelegate. so wee need both.
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    // create imagePickerController
    let imagePicker = UIImagePickerController()
    
    //Speech
    //syntehsizer 음성합성기
    //utterance (speak out loud from mouth)
    let speechSynthesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SeeFood"
        imagePickerSetup()
    }

    func imagePickerSetup() {
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = selectedImage
            guard let ciimage  = CIImage(image: selectedImage) else {
                fatalError("Could not convert UIImage into CIImage")
            }
            detect(image: ciimage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // detect Image
    func detect(image: CIImage) {
        
        // our coreML's model property
        // VNCoreMLModel - > a container coreML model used for Vision request.
        let inceptionModel = Inceptionv3().model
        guard let model = try? VNCoreMLModel(for: inceptionModel) else {
            fatalError("Loading CoreML Model Failed.")
        }
        // vision CoreML request. ( ready for request )
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            // get result as classification observation
            guard let result = request.results as? [VNClassificationObservation] else { return }
            print(result)
            if let firstResult = result.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.blue
                    
                    // sound
                    if let text = self.navigationItem.title {
                        self.utterance = AVSpeechUtterance(string: text)
                        self.utterance.rate = 0.5
                        self.speechSynthesizer.speak(self.utterance)
                    }
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    
                    // sound
                    if let text = self.navigationItem.title {
                        self.utterance = AVSpeechUtterance(string: text)
                        self.utterance.rate = 0.5
                        self.speechSynthesizer.speak(self.utterance)
                    }
                }
            }
        }
        
        // perform Request actually using handler
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        descriptionLabel.isHidden = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}
