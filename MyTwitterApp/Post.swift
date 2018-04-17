import UIKit

class Post {

    var posTxt:String?
    var postImage:String?
    var postDate:String?
    var postUID:String?
    
    init(posTxt:String,postImage:String,postDate:String,postUID:String) {
        self.posTxt=posTxt
        self.postUID=postUID
        self.postDate=postDate
        self.postImage=postImage
    }
}
