import UIKit
import GoogleMobileAds
import FirebaseDatabase
import FirebaseAuth

class VCPosting: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var ref : DatabaseReference!
    @IBOutlet weak var TvPostsList: UITableView!
    var userUID:String?
    var listOfPosts = [Post]()
    var interstitial:GADInterstitial!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPosts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = listOfPosts[indexPath.row]
        if post.postUID == "@#$2@" {
            return 178
        }else if post.postImage == "No Image Yet"{
            return 163
        }else {
            return 280
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = listOfPosts[indexPath.row]
        if post.postUID == "@#$2@" {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TVCAddPost
        cell.UserUID = self.userUID
        cell.main = self
        return cell
        }else if post.postImage == "No Image Yet"{
            let cellWithoutImage = tableView.dequeueReusableCell(withIdentifier: "cellWitoutImage", for: indexPath) as! TVCPostWithoutImage
            cellWithoutImage.setText(post: post)
            return cellWithoutImage
        }else {
            let cellWithImage = tableView.dequeueReusableCell(withIdentifier: "cellWithImage", for: indexPath) as! TVCPostWithImage
            cellWithImage.setPost(post: post)
            return cellWithImage
            
        }
}
    override func viewDidLoad() {
        super.viewDidLoad()
        TvPostsList.dataSource=self
        TvPostsList.delegate=self
        listOfPosts.append(Post(posTxt: "", postImage: "", postDate: "", postUID: "@#$2@"))
        self.ref = Database.database().reference()
        loadPostFromFirebase()
        // ads init
         interstitial = GADInterstitial(adUnitID: "ca-app-pub-5038801077271119/4048778345")
        let request = GADRequest()
        interstitial.load(request)
    }
    @IBAction func BuShowAds(_ sender: UIBarButtonItem) {
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            print("Ads is not ready yet")
        }
    }
    
    func loadPostFromFirebase(){
        
            ref.child("Posts").observe(.value) { (snapshot) in
            self.listOfPosts.removeAll()
            self.listOfPosts.append(Post(posTxt: "", postImage: "", postDate: "", postUID: "@#$2@"))
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let postDic = snap.value as? [String:Any]{
                        var postText:String?
                        if let postTextF = postDic["Text"] as? String{
                            postText = postTextF
                        }
                        var postImage:String?
                        if let postImageF = postDic["imagePath"] as? String{
                            postImage = postImageF
                        }
                        var postDate:String?
                        if let postDateF = postDic["PostDate"] as? String {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                            formatter.date(from: postDate!)
                               postDate = postDateF
                        }
                        var postUID:String?
                        if let postUIDF = postDic["UserUID"] as? String{
                            postUID = postUIDF
                        }
                        self.listOfPosts.append(Post(posTxt: postText!, postImage: postImage!, postDate: postDate!, postUID: postUID!))
                    }
                }
                self.TvPostsList.reloadData()
            }
        }
    }
    @IBAction func BuSignout(_ sender: UIBarButtonItem) {
       try? Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
}
