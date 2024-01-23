//
//  SelfieCameraViewController.swift
//  ValifyOnboarding
//
//  Created by Amr Fawzy on 18/01/2024.
//

import UIKit
import AVFoundation

// MARK: - SelfieCaptureDelegate

// Protocol to communicate captured images to the presenting view controller
public protocol SelfieCaptureDelegate: AnyObject {
    func didApproveImage(_ image: UIImage?)
}

// MARK: - SelfieCameraViewController

public class SelfieCameraViewController: UIViewController {
    
    // MARK: - Properties
    
    public weak var delegate: SelfieCaptureDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var frontCamera: AVCaptureDevice?
    private var stillImageOutput: AVCapturePhotoOutput?
    
    // MARK: - Lifecycle Methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set up camera when the view is about to appear
        setupCamera()
        
        // Configure the capture output
        setupCaptureOutput()
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() {
        // Camera setup code
        
        // Use a global queue for camera setup
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
            
            // Set up the front camera as the default
            guard let captureSession = self.captureSession else { return }
            
            if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                self.frontCamera = frontCamera
                
                do {
                    let input = try AVCaptureDeviceInput(device: frontCamera)
                    if captureSession.canAddInput(input) {
                        captureSession.addInput(input)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            // Add the still image output to the capture session
            if let stillImageOutput = self.stillImageOutput, captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
            // Main thread to update UI components
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                // Set up the preview layer for displaying the camera feed
                self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.previewLayer?.videoGravity = .resizeAspectFill
                self.previewLayer?.frame = self.view.layer.bounds
                guard let previewLayer = self.previewLayer else { return }
                
                // Add the preview layer to the view's layer
                self.view.layer.addSublayer(previewLayer)
                
                // Start the capture session on a background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession?.startRunning()
                }
                // Create and add a capture button with an icon
                let captureButton = UIButton(type: .system)
                // Set up the capture button appearance
                captureButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
                captureButton.tintColor = .white  // Set the color of the camera icon
                captureButton.addTarget(self, action: #selector(self.captureButtonPressed), for: .touchUpInside)
                captureButton.frame = CGRect(x: self.view.bounds.midX - 25, y: self.view.bounds.maxY - 75, width: 50, height: 50)
                self.view.addSubview(captureButton)
                
                // Create and add a close (X) button
                let closeButton = UIButton(type: .system)
                // Set up the close button appearance
                closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                closeButton.tintColor = .white  // Set the color of the close icon
                closeButton.addTarget(self, action: #selector(self.closeButtonPressed), for: .touchUpInside)
                closeButton.frame = CGRect(x: 20, y: 50, width: 80, height: 80)
                self.view.addSubview(closeButton)
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func closeButtonPressed() {
        // Handle the close button press (dismiss the view controller)
        print("Close button pressed")
        
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func captureButtonPressed() {
        // Capture button pressed action
        print("captureButtonPressed")
        
        guard let captureSession = captureSession, let stillImageOutput = stillImageOutput else { return }
        // Capture a still image
        let settings = AVCapturePhotoSettings()
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Capture Output Setup
    
    private func setupCaptureOutput() {
        // Capture output setup code
        
        stillImageOutput = AVCapturePhotoOutput()
        guard let captureSession = captureSession, let stillImageOutput = stillImageOutput else { return }
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate Methods

extension SelfieCameraViewController: AVCapturePhotoCaptureDelegate, SelfieCaptureDelegate {
    // AVCapturePhotoCaptureDelegate methods
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let capturedImage = UIImage(data: imageData),
           self.isFacePresent(in: capturedImage) {
            if let flippedImage = capturedImage.horizontallyFlipped() {
                DispatchQueue.main.async {
                    let approvalVC = ApprovalViewController()
                    approvalVC.capturedImage = flippedImage
                    approvalVC.delegate = self.delegate
                    self.navigationController?.pushViewController(approvalVC, animated: true)
                    
                    // Stop the capture session after capturing an image
                    self.captureSession?.stopRunning()
                }
            }
        } else {
            // Show an error message or handle accordingly
            DispatchQueue.main.async {
                self.showFaceDetectionError()
                self.resetCaptureSession()
            }
        }
    }
    
    // Additional Helper Methods
    
    private func resetCaptureSession() {
        // Reset the capture session
        captureSession?.startRunning()
    }
    
    
    private func showFaceDetectionError() {
        // Show face detection error
        let alertController = UIAlertController(title: "Error", message: "No face detected. Please recapture.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func didApproveImage(_ image: UIImage?) {
        // Handle the approved image, e.g., save it, send it to a server, etc.
        if let approvedImage = image {
            print("Image approved: \(approvedImage)")
            // Perform any additional actions needed
        } else {
            print("Error: Approved image is nil")
        }
    }
    
    
    private func isFacePresent(in image: UIImage) -> Bool {
        // Check if face is present in the captured image
        if let ciImage = CIImage(image: image) {
            let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            let features = detector?.features(in: ciImage)
            return features?.isEmpty == false
        }
        return false
    }
    
}
