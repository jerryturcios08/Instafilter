//
//  ViewController.swift
//  Instafilter
//
//  Created by Jerry Turcios on 1/17/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import CoreImage
import UIKit

enum Filters {
    static let CIBumpDistortion = "CIBumpDistortion"
    static let CIGaussianBlur = "CIGaussianBlur"
    static let CIPixellate = "CIPixellate"
    static let CISepiaTone = "CISepiaTone"
    static let CITwirlDistortion = "CITwirlDistortion"
    static let CIUnsharpMask = "CIUnsharpMask"
    static let CIVignette = "CIVignette"
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensitySlider: UISlider!

    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))

        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)

        imageView.alpha = 0
        currentImage = image

        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.imageView.alpha = 1
        })

        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: Filters.CIBumpDistortion, style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: Filters.CIGaussianBlur, style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: Filters.CIPixellate, style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: Filters.CISepiaTone, style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: Filters.CITwirlDistortion, style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: Filters.CIUnsharpMask, style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: Filters.CIVignette, style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Use sender as a source for the popover presentation controller for iPad
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }

        present(ac, animated: true)
    }

    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else { return }

        // Sets the title to the filter selected
        title = actionTitle
        currentFilter = CIFilter(name: actionTitle)

        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

        applyProcessing()
    }

    @IBAction func save(_ sender: UIButton) {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let ac = UIAlertController(title: "Error", message: "Please select an image before pressing save.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
        }
    }

    @IBAction func intensitySliderChanged(_ sender: UISlider) {
        applyProcessing()
    }

    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
        }

        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensitySlider.value * 200, forKey: kCIInputRadiusKey)
        }

        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey)
        }

        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }

        guard let outputImage = currentFilter.outputImage else { return }

        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Checks if there is an error upon pressing save
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved", message: "Your altered image has been saved to your photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
        }
    }
}
