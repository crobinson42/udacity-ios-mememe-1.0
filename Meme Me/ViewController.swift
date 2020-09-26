//
//  ViewController.swift
//  Meme Me
//
//  Created by Cory Robinson on 9/16/20.
//  Copyright © 2020 Cory Robinson. All rights reserved.
//

import UIKit

struct MemeTextDefaults {
    static let top = "TOP";
    static let bottom = "BOTTOM";
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var toolbarAlbumBtn: UIBarButtonItem!
    @IBOutlet weak var toolbarCameraBtn: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navbarShare: UIBarButtonItem!
    
    var activeTextField: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarCameraBtn.isEnabled = UIImagePickerController.availableMediaTypes(for: .camera) != nil
    
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        let memeTextFieldAttr: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -4.0
            ]
        
        topTextField.defaultTextAttributes = memeTextFieldAttr
        topTextField.textAlignment = .center
        bottomTextField.defaultTextAttributes = memeTextFieldAttr
        bottomTextField.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let imgKey = info[UIImagePickerController.InfoKey.editedImage] != nil ? UIImagePickerController.InfoKey.editedImage : UIImagePickerController.InfoKey.originalImage
        
       if let image = info[imgKey] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            topTextField.becomeFirstResponder()
        }
    }

    @IBAction func pickImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.allowsEditing = true
        present(camera, animated: true, completion: nil)
    }

    @IBAction func onReset(_ sender: UIButton) {
        if (activeTextField != nil) {
            activeTextField!.resignFirstResponder()
        }
        
        topTextField.text = MemeTextDefaults.top
        bottomTextField.text = MemeTextDefaults.bottom
        imageView = nil
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        let meme = generateMeme()
        
        let uiController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        
        present(uiController, animated: true)
        
        uiController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            print("done")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.text?.count == 0) {
            switch textField.tag {
            case 0:
                textField.text = MemeTextDefaults.top
            default:
                textField.text = MemeTextDefaults.bottom
            }
        }
        
        return true
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("keyboarding will hide, repositioning view")
        
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("keyboarding will show, repositioning view")
        
        if (activeTextField != nil && activeTextField?.tag == 1) {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
        
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        view.addGestureRecognizer(tap)
    }
    
    func digitize(_ num:Int) -> [Int] {
        return Array(String(num).components(separatedBy: "").reversed()).map{ Int($0)! }
    }
    
    func generateMeme() -> UIImage {
        print("creating meme image")
        
        if (activeTextField != nil) {
            print("resigning activeTextField")
            activeTextField!.resignFirstResponder()
        }
        
        toolBar.isHidden = true
        navBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let meme = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBar.isHidden = false
        navBar.isHidden = false
        
        return meme
    }
    
//    func save() {
//        let meme = Meme(bottomText: bottomTextField.text!, topText: topTextField.text!, image: imageView.image!, meme: generateMeme())
//    }
}

