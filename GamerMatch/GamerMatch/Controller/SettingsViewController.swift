//
//  SettingsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/29/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

extension SettingsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    /* indicate that the dismiss transition is going to be interactive,
     but only if the user is panning */
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.shouldFinish ? interactor : nil
    }
}



class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var changePictureBtn: UIButton!
    
    let storageRef = Storage.storage().reference()
    var interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        changePictureBtn.layer.cornerRadius = 10.0
        changePictureBtn.layer.masksToBounds = true
        
        userProfileImg.image = User.onlineUser.userImg ?? UIImage(named: "noAvatarImg")
    }
    
    @IBAction func changePicturePressed(sender: UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func menuBtnPressed(sender: UIBarButtonItem){
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        print("EDGE Pan Gesture ....")
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(gestureState: sender.state, progress: progress, interactor: interactor) {
            self.performSegue(withIdentifier: "openMenu", sender: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // add completion closure to store image to firebase storage cloud
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageFileName = "userProfileImage.jpg"
            userProfileImg.image = image
            
            do {
                // create a URL where we can write the JPEG to
                let imageURL = getDocumentsDirectory().appendingPathComponent(imageFileName)
                
                print(imageURL)
                // convert the UIImage into a JPEG data object
                if let jpegData = UIImageJPEGRepresentation(image, 1.0){
                    // write date to the URL
                    print("about to write to directory...")
                    try jpegData.write(to: imageURL)
                }
                
                User.onlineUser.userImg = image
                
            }catch {
                print("Failed to save to disk...")
            }
        }
        dismiss(animated: true) {
            print("Ready to upload to firebase storage...")
            if let image = self.userProfileImg.image {
                self.uploadImgToFirebase(image: image)
            }
        }
    }
    
    func uploadImgToFirebase(image: UIImage) {
        var data: Data
        data = UIImageJPEGRepresentation(image, 0.8)!
        
        // set upload path
        let fileName = User.onlineUser.username! + ".jpg"
        let filePath = "userProfileImages/\(fileName)"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
    
        self.storageRef.child(filePath).putData(data, metadata: metaData) { (metaData, error) in
            print("uploading to firebase...")
            if let error = error {
                print(error.localizedDescription)
                return
            }else {
                // store downloadURL
                let downloadURL = metaData?.downloadURL()?.absoluteString
                
                if let url = downloadURL {
                    User.onlineUser.avatarURL = url
                }
            }
        }
        
    }
    
    func updateAvatarURLValue() {
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsPath = paths[0]
        return documentsPath
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SideMenuViewController {
            destinationViewController.transitioningDelegate = self
            
            // pass the interactor object forward
            destinationViewController.interactor = interactor
        }
    }

}


















