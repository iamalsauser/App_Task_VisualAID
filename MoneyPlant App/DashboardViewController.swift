import UIKit
import FirebaseAuth

class DashboardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var tenantSelectedLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var user: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configureProfileImageView()
        print(URL.documentsDirectory)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeVC), userInfo: nil, repeats: false)
    }
    
    func setUpUI() {
        user = PersistenceController.shared.fetchUser()
        userNameLbl.text = user?.name
        tenantSelectedLbl.text = user?.tenant
    }
    
    func configureProfileImageView() {
        // Make the profile image circular
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @objc func changeVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        vc.modalPresentationStyle = .automatic
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func navigateToStartingScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "StartingScreen") as! ViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func didTapLogOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("Successfully signed out")
            navigateToStartingScreen()
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
        PersistenceController.shared.deleteUsers()
    }
    
    @IBAction func didTapAddImageButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // Allow selecting from the photo library
        imagePicker.allowsEditing = true // Allow basic image editing (cropping, etc.)
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Get the selected image (edited or original)
        if let editedImage = info[.editedImage] as? UIImage {
            profileImage.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImage.image = originalImage
        }
        
        // Optionally save the selected image to the user profile or database here
        saveProfileImageLocally(image: profileImage.image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Save profile image locally or to a database (optional)
    func saveProfileImageLocally(image: UIImage?) {
        guard let image = image, let imageData = image.pngData() else { return }
        
        PersistenceController.shared.updateUserProfile(user: user!, name: nil, image: imageData)
        
//        // Save the image to the Documents directory or send it to a database/storage service
//        let fileURL = URL.documentsDirectory.appendingPathComponent("profileImage.png")
//        do {
//            try imageData.write(to: fileURL)
//            print("Profile image saved to \(fileURL)")
//        } catch {
//            print("Failed to save profile image: \(error)")
//        }
    }
}
