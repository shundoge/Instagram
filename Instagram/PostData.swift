//
//  PostData.swift
//  Instagram
//
//  Created by TanakaShunichi on 2016/03/29.
//  Copyright © 2016年 shunichi.tanaka. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: NSDate?
    var likes: [String] = []
    var isLiked: Bool = false
    var comment: String?
    
    init(snapshot: FDataSnapshot, myId: String) {
        id = snapshot.key
        
        imageString = snapshot.value.objectForKey("image") as? String
        image = UIImage(data: NSData(base64EncodedString: imageString!, options: .IgnoreUnknownCharacters)!)
        
        name = snapshot.value.objectForKey("name") as? String
        caption = snapshot.value.objectForKey("caption") as? String
        comment = snapshot.value.objectForKey("comment") as? String
        if let likes = snapshot.value.objectForKey("likes") as? [String] {
            self.likes = likes
        }
        
        for likeId in likes {
            if likeId == myId {
                isLiked = true
                break
            }
        }
        
        self.date = NSDate(timeIntervalSinceReferenceDate: snapshot.value.objectForKey("time") as! NSTimeInterval)
    }
}
