//
//  ViewController.swift
//  VisionDemo
//
//  Created by Altynbek Usenbekov on 1/22/20.
//  Copyright © 2020 Altynbek Usenbekov. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    @IBOutlet weak var txt: UITextView!
    
    lazy var workQueue = {
        return DispatchQueue(label: "workQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    }()
    
    lazy var textRecognitionRequest: VNRecognizeTextRequest = {
        let req = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var resultText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                resultText += topCandidate.string
                resultText += "\n"
            }
            
            DispatchQueue.main.async {
                self.txt.text = self.txt.text + "\n" + resultText
            }
        }
        return req
    }()

    @IBAction func startScan(_ sender: Any) {
        txt.text = ""
        
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }
    
    func recognizeText(inImage: UIImage) {
        guard let cgImage = inImage.cgImage else { return }
        
        workQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Document Camera VC Delegate
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for i in 0 ..< scan.pageCount {
            let img = scan.imageOfPage(at: i)
            recognizeText(inImage: img)
        }
        
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true)
    }
    
}

