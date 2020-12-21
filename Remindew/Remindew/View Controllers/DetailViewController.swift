//
//  DetailViewController.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var plantButton: UIButton!
    @IBOutlet weak var backButton: UINavigationItem!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var waterPlantButton: UIButton!
    @IBOutlet var cameraButtonLabel: UIBarButtonItem!
    @IBOutlet var daySelectorOutlet: DaySelectionView!
    @IBOutlet var dateLabel: UIBarButtonItem!
    @IBOutlet var textView: UITextView!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var dayProgressView: UIProgressView!
    @IBOutlet var speciesProgressView: UIProgressView!
    @IBOutlet var nicknameProgressView: UIProgressView!
    
    // MARK: - Actions
    
    @IBAction func waterPlantButtonTapped(_ sender: UIButton) {
        print("waterPlantButtonTapped")
        
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
            
            // if it DOES need to be watered, update needsWatering to false
            if existingPlant.needsWatering {
                plantController?.updatePlantWithWatering(plant: existingPlant, needsWatering: false)
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        print("CameraButton tapped")
        
        // dismiss keyboards so they don't stay up when library is loading
        nicknameTextField.resignFirstResponder()
        speciesTextField.resignFirstResponder()
        presentPhotoActionSheet()
    }
        
    @IBAction func plantButtonTapped(_ sender: UIButton) {
        
        // first check if notifications are enabled (alerts, badges, and sounds)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            // only create/edit plants if notifications are enabled
            if settings.alertSetting == .enabled  && settings.badgeSetting == .enabled && settings.soundSetting == .enabled {
                print("Permission Granted (.alert, .badge, .sound)")
                DispatchQueue.main.async {
                    self.addOrEditPlant()
                }
            }
            // if notifications are NOT enabled, let user know and take them to Settings app
            else {
                // local alert saying it needs permission
                print("Notification permissions NOT granted")
                DispatchQueue.main.async {
                    self.makePermissionAlert()
                }
            }
        }
    }
    
    // MARK: - Properties
    
    var plantController: PlantController?
    
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    /// Holds the PlantSearchResult array we get in network call
    var plantSearchResults: [PlantSearchResult] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }
    
    /// Holds scientificName grabbed from plant species search
    var fetchedScientificName = ""
    
    /// Array of random plant nicknames for when a user doesn't want to create their own
    let randomNicknames: [String] = ["Twiggy", "Leaf Erikson", "Alvina", "Thornhill", "Plant 43",
                                    "Entty", "Lily", "Greenman", "Bud Dwyer",
                                    "Cilan", "Milo", "Erika", "Gardenia", "Ramos"]
    
    /// Presents and action sheet with options to use camera to take photo or just choose from library
    @objc func presentPhotoActionSheet() {
        print("presentPhotoActionSheet")
        AudioServicesPlaySystemSound(SystemSoundID(1105))
        
        let act = UIAlertController(title: NSLocalizedString("Add Plant Image", comment: "Image Action Sheet Title"),
                                    message: nil,
                                    preferredStyle: .actionSheet)
        
        // Take Photo
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("Take a Photo", comment: "Use Camera to take photo"),
                                            style: .default,
                                            handler: takePhoto)
        takePhotoAction.setValue(UIColor.waterBlue, forKey: "titleTextColor")
        act.addAction(takePhotoAction)
        
        // Choose Photo
        let choosePhotoAction = UIAlertAction(title: NSLocalizedString("Choose from Library", comment: "Choose image from photos"),
                                              style: .default,
                                              handler: presentImagePickerController)
        choosePhotoAction.setValue(UIColor.waterBlue, forKey: "titleTextColor")
        act.addAction(choosePhotoAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                         style: .cancel)
        cancelAction.setValue(UIColor.mixedBlueGreen, forKey: "titleTextColor")
        act.addAction(cancelAction)
        
        present(act, animated: true)
    }
    
    /// Creates or Edits a plant
    private func addOrEditPlant() {
        // before EDIT or ADD, first check for:
        
        // 1. nickname has text AND not empty, else display alert for this
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            makeNicknameAlert()
            return
        }
        
        // 2. species has text AND not empty, else display alert for this
        guard let species = speciesTextField.text, !species.isEmpty else {
            makeSpeciesAlert()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        // Return false is no days are selected, true if there's at least 1 day selected
        let daysAreSelected: Bool = daySelectorOutlet.returnDaysSelected().count > 0
        
        // 3. daysAreSelected is true, else display alert for this
        if !daysAreSelected {
            makeDaysAlert()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        // Check if we should save image
        var imageToSave: UIImage?
        
        // If imageView.image is NOT the default one, save it. Else, don't save
        // Check default image manually here because it won't work with .logoImage for some reason
        if imageView.image.hashValue != UIImage(named: "plantslogoclear1024x1024").hashValue {
            print("Image in imageView is NOT default one")
            imageToSave = imageView.image ?? .logoImage
        }
        
        // If there IS a plant, update (EDIT)
        if let existingPlant = plant {
                            
            plantController?.update(nickname: nickname.capitalized,
                                   species: species.capitalized,
                                   water_schedule: datePicker.date,
                                   frequency: daySelectorOutlet.returnDaysSelected(),
                                   scientificName: fetchedScientificName,
                                   plant: existingPlant)
            // save image
            let imageName = "userPlant\(existingPlant.identifier!)"
            
            // if there is an image to save only
            if let image = imageToSave {
                UIImage.saveImage(imageName: imageName, image: image)
            }
        }
            
        // If there is NO plant (ADD)
        else {
            let plant = plantController?.createPlant(nickname: nickname.capitalized,
                                        species: species.capitalized,
                                        date: datePicker.date,
                                        frequency: daySelectorOutlet.returnDaysSelected(),
                                        scientificName: fetchedScientificName)
            // save image
            let imageName = "userPlant\(plant!.identifier!)"
            
            // if there is an image to save only
            if let image = imageToSave {
                UIImage.saveImage(imageName: imageName, image: image)
            }
        }
        
        // sound won't play for some reason
//        AudioServicesPlaySystemSound(SystemSoundID(1107))
        
        // Vibrate
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Go back to main screen
        navigationController?.popViewController(animated: true)
    }
    
    /// Presents an alert for when a user did not usage of their camera and lets them go to Settings to change it (will restart app though)
    private func makeCameraUsagePermissionAlert() {
    
        // add two options
        let title = NSLocalizedString("Camera Access Denied",
                                      comment: "Title for camera usage not allowed")
        let message = NSLocalizedString("Please allow camera usage by going to Settings and turning Camera access on", comment: "Error message for when camera access is not allowed")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
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
    
    /// Presents an alert for when a user did not allow notifications at launch and lets them go to Settings to change before they make/edit a plant
    private func makePermissionAlert() {
    
        // add two options
        let title = NSLocalizedString("Notifications Disabled",
                                      comment: "Title for notification permissions not allowed")//"Notifications Disabled"
        let message = NSLocalizedString("Please allow notifications by going to Settings and allowing Notifications, Banners, Sounds, and Badges.", comment: "Error message for when notifications are not allowed")//"Please allow notifications by going to Settings and allowing Notifications, Banners, Sounds, and Badges."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // handler could select the textfield it needs or change textview text??
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
    
    /// Presents an alert for missing text in nickname textfield. Inserts random nickname or clicks in nickname textfield for user to enter their own
    private func makeNicknameAlert() {
        
        let title = NSLocalizedString("Missing Nickname",
                                      comment: "Title for no nickname in textfield")
        let message = NSLocalizedString("Please enter a custom nickname for your plant or select a random nickname",
                                        comment: "Message for when nickname is missing in textfield")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.view.tintColor = .lightLeafGreen
        
        self.nicknameProgressView.progress = 0.0
        let alertAction = UIAlertAction(title: NSLocalizedString("Custom", comment: "User generated name"), style: .default) { _ in
            self.nicknameTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.275) {
                self.nicknameProgressView.setProgress(1.0, animated: true)
            }
        }
        let randomAction = UIAlertAction(title: NSLocalizedString("Random", comment: "Randomly generated name"), style: .default) { _ in
            self.chooseRandomNickname()
            self.nicknameTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.275) {
                self.nicknameProgressView.setProgress(1.0, animated: true)
            }
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(randomAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for missing text in species textfield. Clicks in species textfield when user clicks OK
    private func makeSpeciesAlert() {
        let title = NSLocalizedString("Missing Species Name",
                                      comment: "Title for when species name is missing in textfield")
        let message = NSLocalizedString("Please enter a species for your plant.\nExample: \"Peace Lily\"",
                                        comment: "Message for when species name is missing in textfield")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = .lightLeafGreen

        // handler could select the textfield it needs or change textview text??
        self.speciesProgressView.progress = 0.0
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.speciesTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.275) {
                self.speciesProgressView.setProgress(1.0, animated: true)
            }
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents an alert for missing days and changes text view to give a hint
    private func makeDaysAlert() {
        let title = NSLocalizedString("Missing Watering Days",
                                      comment: "Title for when watering days are missing")
        let message = NSLocalizedString("Please select which days you would like to receive reminders",
                                        comment: "Message for when watering days are missing")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = .lightWaterBlue
        // handler could select the textfield it needs or change textview text??
        self.dayProgressView.progress = 0.0
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.textView.text = NSLocalizedString("Select at least one of the days below",
                                                   comment: "Hint on how to set a least one reminder")
            UIView.animate(withDuration: 0.275) {
                self.dayProgressView.setProgress(1.0, animated: true)
            }
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Enters a random nickname in nickname textfield so user doesn't have to make up their own
    private func chooseRandomNickname() {
        let randomInt = Int.random(in: 0..<randomNicknames.count)
        print("randomInt = \(randomInt)")
        nicknameTextField.text = randomNicknames[randomInt]
    }
    
    /// Nav bar date: Sun 11/29
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MM/d"
        return formatter
    }
    
    /// Last Watered Text View / Button title
    var dateFormatter2: DateFormatter {
        let formatter = DateFormatter()
//            formatter.dateFormat = "EEEE MMM d, h:mm a"
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    /// Loading indicator displayed while searching for a plant
    let spinner = UIActivityIndicatorView(style: .large)
        
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // setting to false limits line to 2
//        textView.isScrollEnabled = false
        resultsTableView.backgroundView = spinner
        spinner.color = .leafGreen
        
        // only show it after searching, then hide after choosing plant?
//        resultsTableView.isHidden = true
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        // makes imageView a circle
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill//.scaleToFill
        
        dateLabel.title = dateFormatter.string(from: Date()).capitalized
        // Lets button be disabled with a custom color
        dateLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mixedBlueGreen], for: .disabled)
        
        // Hides Keyboard when tapping outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // so you can still click on the table view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        nicknameTextField.borderStyle = .none
        nicknameTextField.delegate = self
        
        speciesTextField.borderStyle = .none
        speciesTextField.delegate = self
        speciesTextField.returnKeyType = .search
        
        plantButton.applyGradient(colors: [UIColor.darkBlueGreen.cgColor, UIColor.lightBlueGreen.cgColor])
        waterPlantButton.applyGradient(colors: [UIColor.darkWaterBlue.cgColor, UIColor.lightWaterBlue.cgColor])
        
        nicknameProgressView.progressTintColor = .mixedBlueGreen
        speciesProgressView.progressTintColor = .mixedBlueGreen
        dayProgressView.progressTintColor = .waterBlue
        
        nicknameTextField.autocorrectionType = .no
        speciesTextField.autocorrectionType = .no

        datePicker.datePickerMode = .time
        updateViews()
    }
        
    // doing this in viewDIDAppear is a little too slow, but viewWillAppear causes lag on iphone8 sim somehow
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will Appeara")
        // if the view appears and there's no text, auto "click" into first textfield
        if nicknameTextField.text == "" {
            nicknameTextField.becomeFirstResponder()
        }
        
        // Animate progress views
        UIView.animate(withDuration: 0.6) {
            self.nicknameProgressView.setProgress(1.0, animated: true)
        }
        UIView.animate(withDuration: 0.5) {
            self.speciesProgressView.setProgress(1.0, animated: true)
        }
        UIView.animate(withDuration: 0.4) {
            self.dayProgressView.setProgress(1.0, animated: true)
        }
    }
    
    /// Updates textView to display tapped cells scientfic name
    private func updateTextView() {
        
        // if in edit mode
        if let plant = plant {
            // Plant that HAS been watered before
            if let lastWatered = plant.lastDateWatered {
                let dateString = dateFormatter2.string(from: lastWatered)
                // replace this with scientific name from API call later
                textView.text = "Last Watered:\n\(dateString)"
            }
            // Plant that HAS NOT been watered before (brand new plant)
            else {
                // lastWatered is nil for some reason
                textView.text = "Tap any field to edit"
            }
            textView.text += "\n\(fetchedScientificName)"
        }
        
        // if in add mode
        else {
            textView.text = "Please select the preferred reminder days to water your plant"
            textView.text += "\n\(fetchedScientificName)"
        }

    }
    
    /// Update all views depending on if in Edit/Add mode
    func updateViews() {
        
        // update date label at least once a day so it displays correct date
        dateLabel.title = dateFormatter.string(from: Date()).capitalized
                
        guard isViewLoaded else {return}
                
        // DETAIL/EDIT MODE
        if let plant = plant {
            
            // try to load saved image
            if let image = UIImage.loadImageFromDiskWith(fileName: "userPlant\(plant.identifier!)") {
                imageView.image = image
            }
        
            plantButton.setTitle(NSLocalizedString("Save Changes", comment: "Save changes made to plant"), for: .normal)
            
            // Title says how many times a week plant needs water
            if plant.frequency!.count == 7 {
                title = NSLocalizedString("Every day", comment: "7 times a week")
            }
            else if plant.frequency!.count == 1 {
                title = NSLocalizedString("Once a week", comment: "1 time a week")
            }
            else {
                title = "\(plant.frequency!.count)" + NSLocalizedString(" times a week", comment: "Water (X) times a week")
            }
            
            nicknameTextField.text = plant.nickname
            speciesTextField.text = plant.species
            datePicker.date = plant.water_schedule!
            daySelectorOutlet.selectDays((plant.frequency)!)
            fetchedScientificName = plant.scientificName ?? ""
            waterPlantButton.isHidden = false
            
            // plant DOES need to be watered
            if plant.needsWatering {
                waterPlantButton.setTitle("Water Plant", for: .normal)
                waterPlantButton.isEnabled = true
                
            }
            // plant does NOT need to be watered
            else {
                waterPlantButton.isHidden = true
                waterPlantButton.isEnabled = false
            }
            
            // Plant that HAS been watered before
            if let lastWatered = plant.lastDateWatered {
                let dateString = dateFormatter2.string(from: lastWatered)
                // replace this with scientific name from API call later
                textView.text = "Last Watered:\n\(dateString)"
            }
            // Plant that HAS NOT been watered before (brand new plant)
            else {
                // lastWatered is nil for some reason
                textView.text = "Tap any field to edit"
            }
            textView.text += "\n\(plant.scientificName ?? "")"
        }
         
        // ADD MODE
        else {
            plantButton.setTitle(NSLocalizedString("Add Plant", comment: "Add a plant to your collection"), for: .normal)
            title = NSLocalizedString("Add New Plant", comment: "Title for Add Plant screen")
            nicknameTextField.text = ""
            speciesTextField.text = ""
            datePicker.date = Date()
            waterPlantButton.isHidden = true
            textView.text = "Please enter a plant nickname, species, and select reminder days"
        }
        
        plantButton.performFlare()
        // start 0.5 seconds later?
        waterPlantButton.performFlare()
    }
    
    /// Lets user choose an image from their photo library (no permission required)
    private func presentImagePickerController(action: UIAlertAction) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    /// Brings up camera (if permitted) to let user take a photo of their plant
    private func takePhoto(action: UIAlertAction) {
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
        viewController.allowsEditing = true
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    /// Makes custom alerts with given title and message for network errors
    private func makeAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = .lightWaterBlue
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents custom alerts for given network error
    func handleNetworkErrors(_ error: NetworkError) {
        switch error {
        case .badAuth:
            print("badAuth in signToken")
        case .noToken:
            print("no token in searchPlants")
        case .invalidURL:
            makeAlert(title: NSLocalizedString("Invalid Species", comment: ".invalidURL"),
                                         message: NSLocalizedString("Please enter a valid species name", comment: "invalid URL"))
            return
        case .otherError:
            print("other error in searchPlants")
        case .noData:
            print("No data received or data corrupted")
        case .noDecode:
            print("JSON could not be decoded")
        case .invalidToken:
            print("personal token invalid when sending to get temp token url")
        case .serverDown:
            // TODO: needs localization
            makeAlert(title: "Server Maintenance", message: "Servers down for maintenance. Please try again later.")
            return
        default:
            print("default error in searchPlants")
        }
        // Error for all cases that don't have custom ones
        makeAlert(title: NSLocalizedString("Network Error", comment: "any network error"),
                                     message: NSLocalizedString("Search feature temporarily unavailable", comment: "any network error"))
    }
    
    /// Performs a search for plants species (called inside textfield Return)
    func performPlantSearch(_ term: String) {
        self.plantController?.searchPlantSpecies(term, completion: { (result) in
            
            do {
                let plantResults = try result.get()
                DispatchQueue.main.async {
                    self.plantSearchResults = plantResults
                    self.spinner.stopAnimating()
                    if plantResults.count == 0 {
                        self.makeAlert(title: NSLocalizedString("No Results Found",
                                                                comment: "no search resutls"),
                                       message: NSLocalizedString("Please search for another species",
                                                                  comment: "try another species"))
                    }
                    print("set array to plants we got back")
                }
            } catch {
                if let error = error as? NetworkError {
                    DispatchQueue.main.async {
                        print("Error searching for plants in performPlantSearch")
                        self.spinner.stopAnimating()
                        self.handleNetworkErrors(error)
                    }
                }
            }
        })
    }
}

extension DetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // only do the following when in "add mode"
        if let _ = plant { return }
        if textField == nicknameTextField {
            textView.text = "Please enter a nickname for your plant"
        }
        
        else if textField == speciesTextField {
            textView.text = "Species example: \"Peace Lily\"\nClick \"search\" to search"
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Clicked "Search" in species textfield
        if textField == speciesTextField {
            print("Return inside speciesTextfield")

            // dismiss keyboard
            textField.resignFirstResponder()
            
            guard let unwrappedTerm = speciesTextField.text, !unwrappedTerm.isEmpty else { return true }
                    
            // get rid of any spaces in search term
            let term = unwrappedTerm.replacingOccurrences(of: " ", with: "")
            
            // start animating spinner
            spinner.startAnimating()
            
            // check if we need a new token first
            if plantController?.newTempTokenIsNeeded() == true {
                print("new token needed, fetching one first")
                plantController?.signToken(completion: { (result) in
                    do {
                        let message = try result.get()
                        DispatchQueue.main.async {
                            print("success in signToken: \(message)")
                            self.performPlantSearch(term)
                        }
                    } catch {
                        if let error = error as? NetworkError {
                            print("error in detailVC when signing token")
                            DispatchQueue.main.async {
                                self.spinner.stopAnimating()
                                self.handleNetworkErrors(error)
                            }
                        }
                    }
                })
            }
            
            // No new token needed
            else {
                print("No token needed, searching")
                performPlantSearch(term)
            }
        }
        
        // Clicked "Return" in nickname textfield
        if textField == nicknameTextField {
            // go to next textfield (species)
            speciesTextField.becomeFirstResponder()
        }
        
        return true
    }
}

/// For accessing the photo library
extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked Image")
        
        // .editedImage instead? (used to say .originalImage)
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        picker.dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantSearchResults.count//(plantController?.plantSearchResults.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cast as a custom tableview cell (after I make one)
        guard let resultCell = resultsTableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
    
        let plantResult = plantSearchResults[indexPath.row]//plantController?.plantSearchResults[indexPath.row]
        
        // common name
        resultCell.commonNameLabel.text = plantResult.commonName?.capitalized ?? "No common name"
        
        // scientific name
        resultCell.scientificNameLabel.text = plantResult.scientificName ?? "No scientific name"
        
        resultCell.spinner.startAnimating()
        // image
        // store returned UUID? for task for later
        let token = plantController?.loadImage(plantResult.imageUrl) { result in
            do {
                
                // extract result (UIImage)
                let image = try result.get()
                
                // if we get an image, display in cell's image view on main queue
                DispatchQueue.main.async {
                    resultCell.plantImageView?.image = image
                    resultCell.spinner.stopAnimating()
                }
            } catch {
                // do something if there's an error
                // set image to default picture?
                print("Error in result of loadImage in cellForRowAt")
                DispatchQueue.main.async {
                    resultCell.plantImageView?.image = .logoImage
                    resultCell.spinner.stopAnimating()
                }
//                resultCell.plantImageView?.image = .logoImage
            }
        }
        
        // use UUID? we just made to now cancel the load for it
        resultCell.onReuse = {
            // when cell is reused, try to cancel the task it started here
            if let token = token {
                resultCell.spinner.stopAnimating()
                self.plantController?.cancelLoad(token)
            }
        }
        
        return resultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let plantResultCell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell
        let scientificName = plantResultCell?.scientificNameLabel.text ?? ""
        imageView.image = plantResultCell?.plantImageView.image
        fetchedScientificName = scientificName
        updateTextView()
    }
}
