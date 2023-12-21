//
//  ViewController.swift
//  VideoAppDemo
//
//  Created by Nandini Vithlani on 29/07/22.
//

import Foundation
import UIKit

public protocol VideoPickerDelegate: AnyObject {
    func didSelect(url: URL?)
}

open class VideoPicker: NSObject {
    private weak var presentationController: UIViewController?
    private weak var delegate: VideoPickerDelegate?
    
    public init(presentationController: UIViewController, delegate: VideoPickerDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.modalPresentationStyle = .fullScreen
            pickerController.mediaTypes = ["public.movie"]
            pickerController.allowsEditing = false
            pickerController.videoQuality = .typeIFrame960x540
            pickerController.sourceType = type
            self.presentationController?.present(pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView? = nil) {
        let alertController = UIAlertController(title: "Select Action", message: nil, preferredStyle: .actionSheet)
        if let action = self.action(for: .savedPhotosAlbum, title: "Select video from gallery") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .camera, title: "Record video from camera") {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let sourceView = sourceView, UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect url: URL?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(url: url)
    }
}

extension VideoPicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let url = info[.mediaURL] as? URL else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: url)
    }
    
}

extension VideoPicker: UINavigationControllerDelegate {
    
}

