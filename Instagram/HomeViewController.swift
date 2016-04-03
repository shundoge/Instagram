import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var firebaseRef:Firebase!
    var postArray: [PostData] = []
    var InputStr: String! = ""
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        tableView.delegate = self
        tableView.dataSource = self
     
        // UITableViewを準備する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Firebaseの準備をする
        firebaseRef = Firebase(url: CommonConst.FirebaseURL)
        //let loginUserName = ud.objectForKey(CommonConst.DisplayNameKey) as! String
        
        // 要素が追加されたらpostArrayに追加してTableViewを再表示する
        firebaseRef.childByAppendingPath(CommonConst.PostPATH).observeEventType(FEventType.ChildAdded, withBlock: { snapshot in
            // PostDataクラスを生成して受け取ったデータを設定する
            let postData = PostData(snapshot: snapshot, myId: self.firebaseRef.authData.uid)
            self.postArray.insert(postData, atIndex: 0)
            
            // TableViewを再表示する
            self.tableView.reloadData()
        })
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
        firebaseRef.childByAppendingPath(CommonConst.PostPATH).observeEventType(FEventType.ChildChanged, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            let postData = PostData(snapshot: snapshot, myId: self.firebaseRef.authData.uid)
            
            // 保持している配列からidが同じものを探す
            var index: Int = 0
            for post in self.postArray {
                if post.id == postData.id {
                    index = self.postArray.indexOf(post)!
                    break
                }
            }
            
            // 差し替えるため一度削除する
            self.postArray.removeAtIndex(index)
            
            // 削除したところに更新済みのでデータを追加する
            self.postArray.insert(postData, atIndex: index)
            
            // TableViewの該当セルだけを更新する
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
        cell.postData = postArray[indexPath.row]
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self,action:#selector(HomeViewController.handleButton(_:event:)), forControlEvents:  UIControlEvents.TouchUpInside)
        cell.commentButtonOutlet.addTarget(self,action:#selector(HomeViewController.handleButtonComment(_:event:)), forControlEvents:  UIControlEvents.TouchUpInside)
        
        // UILabelの行数が変わっている可能性があるので再描画させる
        cell.layoutIfNeeded()
         return cell
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    func handleButton(sender: UIButton, event:UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        let uid = firebaseRef.authData.uid
        
        if postData.isLiked {
            // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
            var index = -1
            for likeId in postData.likes {
                if likeId == uid {
                    // 削除するためにインデックスを保持しておく
                    index = postData.likes.indexOf(likeId)!
                    break
                }
            }
            postData.likes.removeAtIndex(index)
        } else {
            postData.likes.append(uid)
        }
        
        let imageString = postData.imageString
        let name = postData.name
        let caption = postData.caption//https://techacademy.s3.amazonaws.com/bootcamp/iphone/instagram/
        let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
        let likes = postData.likes
        let comment = postData.comment
        
        // 辞書を作成してFirebaseに保存する
        let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "likes": likes, "comment": comment!]
        let postRef = Firebase(url: CommonConst.FirebaseURL).childByAppendingPath(CommonConst.PostPATH)
        postRef.childByAppendingPath(postData.id).setValue(post)
    }
    func handleButtonComment(sender: UIButton, event:UIEvent) {
        //popupInput()
        let myAlert: UIAlertController = UIAlertController(title: "コメント", message: "個人情報の記述は消去されます。", preferredStyle: UIAlertControllerStyle.Alert)
        //AlertにTextFieldを追加.
        myAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            
            // NotificationCenterを生成.
            let myNotificationCenter = NSNotificationCenter.defaultCenter()
            
            // textFieldに変更があればchangeTextFieldメソッドに通知.
            myNotificationCenter.addObserver(self, selector: #selector(HomeViewController.changeTextField(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        }

        
        
        
        
        //let alert:UIAlertController = UIAlertController(title:"コメント",message: "コメントを記述してください",
        //preferredStyle: UIAlertControllerStyle.Alert)
        // Alert生成.
        //var commentTextField: String!
        
        
        // OKアクション生成.
        let OkAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            //let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
            self.InputStr = (myAlert.textFields!.first?.text)!
            print("OK")
            
            
            
            
            
            
            
            // タップされたセルのインデックスを求める
            let touch = event.allTouches()?.first
            let point = touch!.locationInView(self.tableView)
            let indexPath = self.tableView.indexPathForRowAtPoint(point)
            
            // 配列からタップされたインデックスのデータを取り出す
            let postData = self.postArray[indexPath!.row]
            
            let ud = NSUserDefaults.standardUserDefaults()
            let loginUserName = ud.objectForKey(CommonConst.DisplayNameKey) as! String
         
            let imageString = postData.imageString
            let name = postData.name
            let caption = postData.caption//https://techacademy.s3.amazonaws.com/bootcamp/iphone/instagram/
            let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
            let likes = postData.likes
            let comment: String? = postData.comment! + "\n#" + loginUserName + "さんのコメント：" +  self.InputStr
            let post = ["caption": caption!, "image": imageString!, "name": name!, "time": time, "likes": likes, "comment": comment!]
            let postRef = Firebase(url: CommonConst.FirebaseURL).childByAppendingPath(CommonConst.PostPATH)
            postRef.childByAppendingPath(postData.id).setValue(post)
            //self.tableView.reloadData()

            
        }
        
        // Cancelアクション生成.
        let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) { (action: UIAlertAction!) -> Void in
            print("Cancel")
        }
        
        
        // Alertにアクションを追加.
        myAlert.addAction(OkAction)
        myAlert.addAction(CancelAction)
        
        // Alertを発動する.
        presentViewController(myAlert, animated: true, completion: nil)

    }
    func changeTextField (sender: NSNotification) {
        let textField = sender.object as! UITextField
        // 入力された文字を取得.
        InputStr = textField.text
    }

    /*func popupInput(){
        //let alert:UIAlertController = UIAlertController(title:"コメント",message: "コメントを記述してください",
        //preferredStyle: UIAlertControllerStyle.Alert)
        // Alert生成.
        //var commentTextField: String!
        let myAlert: UIAlertController = UIAlertController(title: "コメント", message: "個人情報の記述は消去されます。", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        // OKアクション生成.
        let OkAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            //let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
            self.InputStr = (myAlert.textFields!.first?.text)!
            print("OK")
            

        }
        
        // Cancelアクション生成.
        let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) { (action: UIAlertAction!) -> Void in
            print("Cancel")
        }
        
         //AlertにTextFieldを追加.
        myAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            
            // NotificationCenterを生成.
            let myNotificationCenter = NSNotificationCenter.defaultCenter()
            
            // textFieldに変更があればchangeTextFieldメソッドに通知.
            myNotificationCenter.addObserver(self, selector: #selector(HomeViewController.changeTextField(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        }
        
        // Alertにアクションを追加.
        myAlert.addAction(OkAction)
        myAlert.addAction(CancelAction)
        
        // Alertを発動する.
        presentViewController(myAlert, animated: true, completion: nil)
    }*/
    
 }
