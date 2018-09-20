//
//  CamaraHandler.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/19/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

class CamaraHandler: NSObject {
    static let shared = CamaraHandler()
    
    fileprivate var currentVC: UIViewController!
    var imagePickedBlock: ((UIImage) -> Void)?
    
    fileprivate func camara() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("camara is not available")
            return
        }
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .camera
        currentVC.present(imagePickerVC, animated: true, completion: nil)
    }
    
    fileprivate func photoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("library is not available")
            return
        }
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary
        currentVC.present(imagePickerVC, animated: true, completion: nil)
    }
    
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camara", style: .default) { (_) in
            self.camara()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default) { (_) in
            self.photoLibrary()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
}

extension CamaraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage]
            as? UIImage else { return }
        self.imagePickedBlock?(image)
        currentVC.dismiss(animated: true, completion: nil)
    }
}
