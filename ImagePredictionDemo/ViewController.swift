//
//  ViewController.swift
//  ImagePredictionDemo
//
//  Created by Nico Company on 16.04.19.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var predictButton: UIButton!
    @IBOutlet weak var labelText: UILabel!
    
    @IBOutlet weak var appleProbability: UILabel!
    @IBOutlet weak var bananaProbability: UILabel!
    @IBOutlet weak var orangeProbability: UILabel!
    
    typealias PredictionCompletion = ((PredictionResult?, String?) -> ())

    var imagePicker = UIImagePickerController()
    var ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let placeholder = UIImage(named: "cat")
        self.view.translatesAutoresizingMaskIntoConstraints = true
        imageView.image = placeholder
        imageView.contentMode = .scaleAspectFit
        
    }

    @IBAction func libraryButtonPressed(_ sender: Any) {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            let alert = UIAlertController(title: "No photo library", message: "Photo library is not available", preferredStyle: .alert)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        print("Selected photo library")

        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = false
        self.present(self.imagePicker, animated: true)
        print("Selected photo library")
    }
    
    
    @IBAction func takePhotoButtonPressed(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
            let alert = UIAlertController(title: "No camera", message: "This device does not support the camera.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.imagePicker.allowsEditing = false
        self.present(self.imagePicker, animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = pickedImage
            self.imageView.backgroundColor = .clear
            self.imageView.contentMode = .scaleAspectFit
        }
        self.dismiss(animated: true)
    }
    
    func predict(input: UIImage, complete: @escaping PredictionCompletion){
        let model = fruits()
        
        DispatchQueue.global(qos: .background).async {
            
            let inputImage = input.resize(to: CGSize(width: 224, height: 224))
            
            guard let features = inputImage?.pixelBuffer() else {
                complete(nil, "Error while creating the pixel buffer.")
                return
            }
            
            guard let result = try? model.prediction(_0: features) else {
                complete(nil, "Error while performing the prediction.")
                return
            }
            DispatchQueue.main.async {
                complete(PredictionResult(label: result.classLabel, probs: result._467), nil)
            }
        }
    }
    
    @IBAction func predictButtonPressed(_ sender: Any) {
        print("Predict button is pressed")
        guard let image = self.imageView.image else {
            print("No image available")
            return
        }
        
        self.predict(input: image){ predictionResult, error in
            if (predictionResult != nil) {
                let classLabel = predictionResult!.classLabel
                if (Int(classLabel) == 0){
                    self.labelText.text = "It is an apple"
                } else if(Int(classLabel) == 1){
                    self.labelText.text = "It is a banana"
                }else {
                    self.labelText.text = "It is an orange"
                }
                self.appleProbability.text = String(format: "%.2f", predictionResult!.probabilties["0"]!)
                self.bananaProbability.text = String(format: "%.2f", predictionResult!.probabilties["1"]!)
                self.orangeProbability.text = String(format: "%.2f", predictionResult!.probabilties["2"]!)
                
            }else{
                print(error)
            }
            
            
        }
    }
    
}
