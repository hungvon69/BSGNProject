import UIKit

class ImagePickerHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private static var imageView: UIImageView?
    private static var viewController: UIViewController?
    
    static func pickImage(for imageView: UIImageView, in viewController: UIViewController) {
        self.imageView = imageView
        self.viewController = viewController
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = sharedInstance
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    private static let sharedInstance = ImagePickerHelper()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any], typeOfAccount: String) {
        if let editedImage = info[.editedImage] as? UIImage {
            ImagePickerHelper.imageView?.image = editedImage
            uploadImageToFirebase(image: editedImage, typeOfAccount: typeOfAccount)
        } else if let originalImage = info[.originalImage] as? UIImage {
            ImagePickerHelper.imageView?.image = originalImage
            uploadImageToFirebase(image: originalImage, typeOfAccount: typeOfAccount)
        }
        ImagePickerHelper.viewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ImagePickerHelper.viewController?.dismiss(animated: true, completion: nil)
    }
    private func uploadImageToFirebase(image: UIImage, typeOfAccount: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to JPEG data.")
            return
        }
        
        // Gọi hàm uploadAvatar trong GlobalService để tải ảnh lên Firebase
        GlobalService.shared.uploadAvatar(imageData: imageData, typeOfAccount: typeOfAccount) { error in
            if let error = error {
                print("Error uploading avatar: \(error.localizedDescription)")
            } else {
                print("Avatar successfully updated!")
            }
        }
    }
}
