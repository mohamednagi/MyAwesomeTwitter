import UIKit
import FirebaseStorage
import FirebaseDatabase

class TVCPostWithImage: UITableViewCell {
    
    var ref:DatabaseReference!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var ivUserImage: UIImageView!
    @IBOutlet weak var txtPostText: UITextView!
    @IBOutlet weak var iv_PostImage: UIImageView!
    
    func setPost(post:Post){
        txtPostText.text = post.posTxt
        setPostImage(url: post.postImage!)
        lblPostDate.text = post.postDate
        loadPostFromFirebase(userUID: post.postUID!)
    }
    func setPostImage(url:String){
        let storageRef = Storage.storage().reference(forURL: "gs://myawesometwitter-a841b.appspot.com")
        let postImageRef = storageRef.child(url)
            postImageRef.getData(maxSize: 8*1024*1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            }else{
                self.iv_PostImage.image = UIImage(data:data!)
            }
        }
    }
    func setUserImage(url:String){
        let storageRef = Storage.storage().reference(forURL: "gs://myawesometwitter-a841b.appspot.com")
        let postImageRef = storageRef.child(url)
        postImageRef.getData(maxSize: 8*1024*1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            }else{
                self.ivUserImage.image = UIImage(data:data!)
            }
        }
    }
    func loadPostFromFirebase(userUID:String){
        self.ref = Database.database().reference()
        self.ref.child("Users").child(userUID).observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let postKey = snap.key as? String{
                    
                        if postKey == "UserImagePath" {
                            let userImage = snap.value as! String
                            self.setUserImage(url: userImage)
                        }
                        if postKey == "UserName" {
                            let UserName = snap.value as! String
                            self.lblUserName.text = UserName
                        }
                    }
                }
            }
        }
    }
}
