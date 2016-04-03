//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by TanakaShunichi on 2016/03/30.
//  Copyright © 2016年 shunichi.tanaka. All rights reserved.
//
import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var commentButtonOutlet: UIButton!
   /* @IBAction func commentButton(sender: AnyObject) {
        var appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
        //appDelegate.globalimage = sender.postImageView as UIImageView
        
        //let selectedImage : UIImageView = sender.postImageView as! UIImageView
        // 遷移するViewを定義する.
        let mySecondViewController : UIViewController! = self.window?.rootViewController!.storyboard!.instantiateViewControllerWithIdentifier("Comment")
        self.window?.rootViewController!.presentViewController(mySecondViewController as UIViewController, animated: true, completion: nil)
     }*/
    
    var postData: PostData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // 表示されるときに呼ばれるメソッドをオーバーライドしてデータをUIに反映する
    override func layoutSubviews() {
        
        postImageView.image = postData!.image
        captionLabel.text = "(投稿者)\(postData!.name!) : \n\(postData!.caption!)"
        
        let likeNumber = postData!.likes.count
        likeLabel.text = "\(likeNumber)"
        commentLabel.text = postData!.comment
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(postData!.date!)
        dateLabel.text = dateString
        
        if postData!.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            likeButton.setImage(buttonImage, forState: UIControlState.Normal)
        }
        
        super.layoutSubviews()
    }
}
