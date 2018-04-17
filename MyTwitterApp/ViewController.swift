import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var UserImage: UIImageView!
    var imagepicker:UIImagePickerController?
    var imageReference : StorageReference{
        return Storage.storage().reference().child("UsersImages")
    }
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagepicker = UIImagePickerController()
        imagepicker?.delegate = self
        self.ref = Database.database().reference()
    }
    
    @IBAction func ImageBu(_ sender: UIButton) {
        present(imagepicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
         UserImage.image = image
        }
        imagepicker?.dismiss(animated: true, completion: nil)
    }
    var UserUID:String?
    @IBAction func LoginBu(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { (user, error) in
            if let error = error {
                print(error)
            }else{
                self.UserUID = user?.uid
                self.UploadMeToFirebase()
                self.GoToPosting()
                self.txtName.text=""
                self.txtPassword.text=""
                self.txtEmail.text=""
            }
        }
    }
    
    @IBAction func RegisterBu(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { (user, error) in
            if let error = error {
                print(error)
            }else{
                print(user?.uid)
                self.UserUID = user!.uid
                // make the image name as user name and login date
                let dataformat = DateFormatter()
                dataformat.dateFormat = "MM_DD_YY_h_mm_a"
                let imagepath = "UsersImages/\(self.txtName.text!).jpg"
                // save to database
                self.SaveDataToFirebaseDatabase(UserImagePath: imagepath, UserName: self.txtName.text!)
                self.UploadMeToFirebase()
                self.GoToPosting()
                self.txtName.text=""
                self.txtPassword.text=""
                self.txtEmail.text=""
            }
        }
    }
    func SaveDataToFirebaseDatabase(UserImagePath:String,UserName:String){
        let msg = ["UserName" : UserName,
                   "UserImagePath" : UserImagePath]
        self.ref.child("Users").child(UserUID!).setValue(msg)
    }
    func UploadMeToFirebase(){
        //upload image
        guard let image = self.UserImage.image else {return}
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {return}
        let uploadImageRef = self.imageReference.child("\(self.txtName.text!).jpg")
        let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
            print("upload finished")
        }
        uploadTask.resume()
    }
    
    func GoToPosting(){
            self.performSegue(withIdentifier: "ShowPosts", sender: self.UserUID)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPosts"{
            if let postingvc = segue.destination as? VCPosting{
                postingvc.userUID = self.UserUID
            }
        }
    }
}
