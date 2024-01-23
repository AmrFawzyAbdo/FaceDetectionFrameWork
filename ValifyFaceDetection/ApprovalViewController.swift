//
//  ApprovalViewController.swift
//  ValifyOnboarding
//
//  Created by Amr Fawzy on 18/01/2024.
//

import Foundation
import UIKit

// MARK: - ApprovalViewController

public class ApprovalViewController: UIViewController {
    
    // MARK: - Properties

    public var capturedImage: UIImage?
    public weak var delegate: SelfieCaptureDelegate?
    private var imageView: UIImageView?
    
    // MARK: - Lifecycle Methods

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Set up the UI components
        setupUI()
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        // UI setup code
        // Style the back button in the navigation bar
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.tintColor = UIColor(hex: 0x80ADAE)
        }
        // Display the captured image in an image view
        imageView = UIImageView(image: capturedImage)
        imageView?.contentMode = .scaleAspectFit
        imageView?.frame = view.bounds
        if let imageView = imageView {
            view.addSubview(imageView)
        }
        
        let buttonHeight: CGFloat = 50 // Adjust the height as needed
        let cornerRadius: CGFloat = 10 // Adjust the corner radius as needed
        
        // Create and set up the approve button
        let approveButton = UIButton(type: .system)
        approveButton.setTitle("Approve", for: .normal)
        approveButton.addTarget(self, action: #selector(approveButtonPressed), for: .touchUpInside)
        approveButton.backgroundColor = UIColor(hex: 0x80ADAE)
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.frame = CGRect(x: 20, y: view.bounds.maxY - 75 - buttonHeight, width: view.bounds.width - 40, height: buttonHeight)
        approveButton.layer.cornerRadius = cornerRadius
        
        // Create and set up the recapture button
        let recaptureButton = UIButton(type: .system)
        recaptureButton.setTitle("Recapture", for: .normal)
        recaptureButton.addTarget(self, action: #selector(recaptureButtonPressed), for: .touchUpInside)
        recaptureButton.backgroundColor = UIColor(hex: 0x80ADAE)
        recaptureButton.setTitleColor(.white, for: .normal)
        recaptureButton.frame = CGRect(x: 20, y: 50, width: view.bounds.width - 40, height: buttonHeight)
        recaptureButton.layer.cornerRadius = cornerRadius
        
        let stackView = UIStackView(arrangedSubviews: [approveButton, recaptureButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        // Add the stack view to the view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Set up constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func approveButtonPressed() {
        // Approve button pressed action
        // Notify the delegate that the image is approved
        delegate?.didApproveImage(capturedImage)
        capturedImage = nil

        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        // Reset and dismiss the view controller
    }
    
    // MARK: - Helper Methods
    
    private func resetAndDismiss() {
        // Reset captured image and dismiss the view controller
        capturedImage = nil
        DispatchQueue.main.async {
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @objc private func recaptureButtonPressed() {
        // Reset captured image and navigate back to the selfie camera screen
        capturedImage = nil
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}

// MARK: - CustomPresentationController

class CustomPresentationController: UIPresentationController {
    // Custom presentation controller class
    override var shouldRemovePresentersView: Bool {
        return true
    }
}

// MARK: - UIImage Extension

extension UIImage {
    // UIImage extension for horizontal flipping
    func horizontallyFlipped() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: size.width, y: 0)
        context.scaleBy(x: -1, y: 1)
        
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


// MARK: - UIColor Extension

extension UIColor {
    // UIColor extension for hexadecimal color initialization
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
