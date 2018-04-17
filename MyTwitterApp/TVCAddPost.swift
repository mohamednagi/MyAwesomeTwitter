import UIKit
import FirebaseDatabase
import FirebaseStorage
class TVCAddPost: UITableViewCell , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    var imagepicker:UIImagePickerController?
    var main:VCPosting?
    @IBOutlet weak var txtPostText: UITextView!
    var ref : DatabaseReference!
    var UserUID:String?
    var imagePath:String = "No Image Yet"
    var imageReference : StorageReference{
        return Storage.storage().reference().child("PostsImages")
    }
    @IBAction func buPost(_ sender: UIButton) {
        ref = Database.database().reference()
        let PostMsg = ["UserUID":UserUID!,
                     "imagePath":imagePath,
                     "Text":txtPostText.text!,
                     "PostDate":ServerValue.timestamp()] as [String : Any]
        ref.child("Posts").childByAutoId().setValue(PostMsg)
        imagePath = "No Image Yet"
        txtPostText.text = ""
    }
    @IBAction func buAttachImage(_ sender: UIButton) {
        imagepicker = UIImagePickerController()
        imagepicker?.delegate = self
        main?.present(imagepicker!, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UploadMeToFirebase(image: image)
        }
        imagepicker?.dismiss(animated: true, completion: nil)
    }
    func UploadMeToFirebase(image:UIImage){
        //upload image
        let storageRef = Storage.storage().reference(forURL: "gs://myawesometwitter-a841b.appspot.com")
        var data = NSData()
            data = UIImageJPEGRepresentation(image, 0.8)! as NSData
        let dataformat = DateFormatter()
        dataformat.dateFormat = "MM_DD_MM_h_mm_a"
        let imageName = "\(self.UserUID!)_ \(dataformat.string(from: NSDate() as Date))"
        self.imagePath = "PostsImages/\(imageName).jpg"
        let childUserImages = storageRef.child(self.imagePath)
        childUserImages.putData(data as Data)
    }
}
