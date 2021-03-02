//
//  AppearanceViewController.swift
//  Remindew
//
//  Created by Jorge Alvarez on 12/27/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

protocol AppearanceDelegate {
    
    /// Passes back an image picked from AppearanceViewController
    func didSelectAppearanceObjects(image: UIImage?)
    
    /// Passes back customization options
    func didSelectColorsAndIcons(appearanceOptions: AppearanceOptions)
}

class AppearanceViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Holds all other views,
    let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .customBackgroundColor
        contentView.layer.cornerRadius = 15
        return contentView
    }()
    
    /// View bahind option buttons/views
    let optionsBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = .customCellColor
        return view
    }()
    
    /// Save button to save changes and dismiss view controller
    let saveButton: UIButton = {
        let tempButton = UIButton(type: .system) // .system
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        tempButton.backgroundColor = .clear
        tempButton.tintColor = .mixedBlueGreen
        tempButton.setTitle("Save", for: .normal)
        tempButton.titleLabel?.font = .systemFont(ofSize: 18)
        tempButton.layer.cornerRadius = 0
        return tempButton
    }()
    
    /// ImageView that holds main plant picture (in original size)
    let imageView: UIImageView = {
        let tempImageView = UIImageView()
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
        tempImageView.contentMode = .scaleAspectFit
        tempImageView.backgroundColor = .clear
        tempImageView.image = UIImage(named: "RemindewDefaultImage")
        return tempImageView
    }()
    
    /// Displays customization options for Plant
    let plantCustomizationView: CustomizationView = {
        let view = CustomizationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .customCellColor
        view.containerView.backgroundColor = .customAppearanceComponentColor
        return view
    }()
    
    /// Displays customization options for Main Action ("Water", etc)
    let actionCustomizationView: CustomizationView = {
        let view = CustomizationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .customCellColor
        view.containerView.backgroundColor = .customAppearanceComponentColor
        return view
    }()
    
    /// Button used to present Camera
    let takePhotoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("  Take Photo", for: .normal)
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .lightGray
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    /// Button used to present Image Picker
    let choosePhotoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("  Choose Photo", for: .normal)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .lightGray
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    /// Button used to save current photo to library
    let savePhotoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("  Save Photo", for: .normal)
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .lightGray
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    var plantController: PlantController?
    
    /// Holds plant that will be passed in and displayed
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    var mainImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    /// Tells DetailViewController to update its imageView
    var appearanceDelegate: AppearanceDelegate?
    
    /// Standard padding for left and right sides
    let standardMargin: CGFloat = 20.0
    
    /// Height for photo buttons
    let buttonHeight: CGFloat = 36.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // pass back selected appearance options to DetailViewController when view is going to disappear
        let appearanceOptions = AppearanceOptions(plantIconIndex: Int16(plantCustomizationView.localIconCount),
                                                  plantColorIndex: Int16(plantCustomizationView.localColorsCount),
                                                  actionIconIndex: Int16(actionCustomizationView.localIconCount),
                                                  actionColorIndex: Int16(actionCustomizationView.localColorsCount))
        
        appearanceDelegate?.didSelectColorsAndIcons(appearanceOptions: appearanceOptions)
    }
    
    /// Updates all views when plant is passed in
    private func updateViews() {
        print("updateViews")
        guard isViewLoaded else { return }
        
        imageView.image = mainImage
        
        // EDIT/DETAIL Mode
        if let plant = plant {
            print("edit mode AVC")
            
            plantCustomizationView.plantNameLabel.text = plant.nickname
            actionCustomizationView.plantNameLabel.text = plant.mainAction
            
            plantCustomizationView.localIconCount = Int(plant.plantIconIndex)
            plantCustomizationView.localColorsCount = Int(plant.plantColorIndex)
            actionCustomizationView.localIconCount = Int(plant.actionIconIndex)
            actionCustomizationView.localColorsCount = Int(plant.actionColorIndex)
        }

        // ADD Mode
        else {
            print("add mode AVC")
            
            plantCustomizationView.plantNameLabel.text = NSLocalizedString("Nickname", comment: "nickname")
            actionCustomizationView.plantNameLabel.text = NSLocalizedString("Water", comment: "water")
            
            plantCustomizationView.localIconCount = 8
            plantCustomizationView.localColorsCount = 0
            actionCustomizationView.localIconCount = 0
            actionCustomizationView.localColorsCount = 1
        }
    }
    
    /// Saves contents and dismisses view controller
    @objc func saveButtonTapped() {
        print("Save button tapped")
        dismiss(animated: true, completion: nil)
    }
    
    /// Brings up camera (if permitted) to let user take a photo of their plant
    @objc private func takePhotoTapped() {
        print("take photo")
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined, .denied, .restricted:
            makeCameraUsagePermissionAlert()
            return
        case .authorized:
            print("Authorized camera in takePhoto")
        default:
            print("Default in takePhoto")
        }
        
        // check if we have access to Camera (if not, present an alert with option to go to Settings). Just in case
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Error: camera is unavailable")
            makeCameraUsagePermissionAlert()
            return
        }
        
        let viewController = UIImagePickerController()
        
        viewController.sourceType = .camera
//        viewController.allowsEditing = true
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    /// Lets user choose an image from their photo library (no permission required)
    @objc private func choosePhotoTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
//        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    /// Presents an alert for when a user did not usage of their camera and lets them go to Settings to change it (will restart app though)
    private func makeCameraUsagePermissionAlert() {
    
        // add two options
        let title = NSLocalizedString("Camera Access Denied",
                                      comment: "Title for camera usage not allowed")
        let message = NSLocalizedString("Please allow camera usage by going to Settings and turning Camera access on", comment: "Error message for when camera access is not allowed")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("selected OK option")
        }
        let settingsString = NSLocalizedString("Settings", comment: "String for Settings option")
        let settingsAction = UIAlertAction(title: settingsString, style: .default) { _ in
            // take user to Settings app
            print("selected Settings option")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
  
    /// Presents alert that lets user go to Settings to enable access to Photos to add photos
    private func makeLibraryAddUsagePermissionAlert() {
        
        let title = NSLocalizedString("Photos Access Denied",
                                      comment: "Title for library add usage not allowed")
        
        let message = NSLocalizedString("Please allow access to Photos by going to Settings -> Photos -> Add Photos Only", comment: "Error message for when Photos add access is not allowed")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OK
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        // Settings
        let settingsString = NSLocalizedString("Settings", comment: "String for Settings option")
        let settingsAction = UIAlertAction(title: settingsString, style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Button used to save photo to photo library
    @objc private func savePhotoTapped() {
        
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    /// Method called when attempting to save image that's inside imageView
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            // we don't have permission to save to library. Also needs to ask permission again
            makeLibraryAddUsagePermissionAlert()
        } else {
            // TODO: needs localized string
            let ac = UIAlertController(title: "Photo Saved", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    /// Lays out all views needed
    private func setupSubViews() {
                
        view.backgroundColor = .customBackgroundColor
        view.layer.cornerRadius = 15
        
        // Content View
        view.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        contentView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        
        // Image View
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardMargin).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardMargin).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardMargin).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        // Options View
        contentView.addSubview(optionsBackgroundView)
        optionsBackgroundView.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        optionsBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        optionsBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
//        optionsBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        optionsBackgroundView.heightAnchor.constraint(equalToConstant: 278).isActive = true
        
        // Plant Customization View
        contentView.addSubview(plantCustomizationView)
        plantCustomizationView.topAnchor.constraint(equalTo: optionsBackgroundView.topAnchor, constant: 18).isActive = true
        plantCustomizationView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        plantCustomizationView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        plantCustomizationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Main Action Customization View
        contentView.addSubview(actionCustomizationView)
        actionCustomizationView.topAnchor.constraint(equalTo: plantCustomizationView.bottomAnchor).isActive = true
        actionCustomizationView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        actionCustomizationView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        actionCustomizationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Take Photo Button
        contentView.addSubview(takePhotoButton)
        takePhotoButton.topAnchor.constraint(equalTo: actionCustomizationView.bottomAnchor, constant: 8).isActive = true
        takePhotoButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        takePhotoButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        takePhotoButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        takePhotoButton.addTarget(self, action: #selector(takePhotoTapped), for: .touchUpInside)
        
        // Choose Photo Button
        contentView.addSubview(choosePhotoButton)
        choosePhotoButton.topAnchor.constraint(equalTo: takePhotoButton.bottomAnchor, constant: 8).isActive = true
        choosePhotoButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        choosePhotoButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        choosePhotoButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        choosePhotoButton.addTarget(self, action: #selector(choosePhotoTapped), for: .touchUpInside)


        // Save Photo Button
        contentView.addSubview(savePhotoButton)
        savePhotoButton.topAnchor.constraint(equalTo: choosePhotoButton.bottomAnchor, constant: 8).isActive = true
        savePhotoButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        savePhotoButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        savePhotoButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        savePhotoButton.addTarget(self, action: #selector(savePhotoTapped), for: .touchUpInside)
        
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

/// For accessing the photo library
extension AppearanceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked Image")
        
        // .editedImage instead? (used to say .originalImage)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            appearanceDelegate?.didSelectAppearanceObjects(image: image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        picker.dismiss(animated: true, completion: nil)
    }
}

/// Holds 4 options for plant appearance (plantIconIndex, plantColorIndex, actionIconIndex, actionColorIndex)
struct AppearanceOptions {
    /// used for UIImage.plantIconArray
    var plantIconIndex: Int16 = 8
    var plantColorIndex: Int16 = 0
    var actionIconIndex: Int16 = 0
    var actionColorIndex: Int16 = 1
}
