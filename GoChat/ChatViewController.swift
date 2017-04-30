//
//  ChatViewController.swift
//  GoChat
//
//  Created by Ken Chan on 2017/4/14.
//  Copyright © 2017年 KenChan. All rights reserved.
//

import UIKit
import MobileCoreServices
import JSQMessagesViewController
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
var messages = [JSQMessage]()

var messageRef = FIRDatabase.database().reference().child("messages")
override func viewDidLoad() {
    super.viewDidLoad()
    
    self.senderId = "123"
    self.senderDisplayName = "Ken"
    // Do any additional setup after loading the view.
    
    //        messageRef.childByAutoId().setValue("first message")
    //        messageRef.childByAutoId().setValue("second message")
    //        messageRef.observe(FIRDataEventType.childAdded) {(snapshot: FIRDataSnapshot) in
    //            print(snapshot.value)
    //            if let dict = snapshot.value as? String {
    //                print("dict: \(dict)")
    //            }
    //        }
            observeMessages()
}

func observeMessages() { //pulling data
    messageRef.observe(.childAdded, with: { snapshot in
        //print(snapshot.value)
        if let dict = snapshot.value as? [String: AnyObject] {
            let mediaType = dict["MediaType"] as! String
            let senderId = dict["senderId"] as! String
            let senderName = dict["senderName"] as! String
            
            switch mediaType {
            case "TEXT":
                let text = dict["text"] as? String
                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                break
            case "PHOTO":
                let fileUrl = dict["fileUrl"] as! String
                let url = URL(string: fileUrl)
                let data = try? Data(contentsOf: url!)
                let picture = UIImage(data: data!)
                let photo = JSQPhotoMediaItem(image: picture)
                self.messages.append(JSQMessage(senderId: self.senderId, displayName: senderName, media: photo))
                break
            case "VIDEO":
                let fileURL = dict["fileUrl"] as! String
                let video = URL(string: fileURL)
                let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                break
            default:
                print("unknown data type")
                break
            }
                self.collectionView.reloadData()
        }
    })
}

override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    //        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
    //        collectionView.reloadData()
    //        print(messages)
    let newMessage = messageRef.childByAutoId()
    let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
    newMessage.setValue(messageData)
}

override func didPressAccessoryButton(_ sender: UIButton!) {
    print("didPressAccessoryButton")
    
    let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
    
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert:UIAlertAction) in
        
    }
    let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { (alert:UIAlertAction) in
        self.getMediaFrom(type: kUTTypeImage)
    }
    let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.default) { (alert:UIAlertAction) in
        self.getMediaFrom(type: kUTTypeMovie)
    }
    
    sheet.addAction(cancel)
    sheet.addAction(photoLibrary)
    sheet.addAction(videoLibrary)
    self.present(sheet, animated: true, completion: nil)
    
    //        let imagePicker = UIImagePickerController()
    //        imagePicker.delegate = self
    //        self.present(imagePicker, animated: true, completion: nil)
}

func getMediaFrom(type: CFString) {
    let mediaPicker = UIImagePickerController()
    mediaPicker.delegate = self
    mediaPicker.mediaTypes = [type as String]
    self.present(mediaPicker, animated: true, completion: nil)
}

override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
}

override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let bubbleFactory = JSQMessagesBubbleImageFactory()
    return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
}

override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
}

override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print("number of item:\(messages.count)")
    return messages.count
}

override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    return cell
}

override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
    print("didTapMessageBubbleIndexPath: \(indexPath.item)")
    let message = messages[indexPath.item]
    if message.isMediaMessage {
        if let mediaItem = message.media as? JSQVideoMediaItem {
            let player = AVPlayer(url: mediaItem.fileURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true, completion: nil)
        }
    }
}



override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}

@IBAction func logoutDidTapped(_ sender: Any) {
    // Create  main storyboard instance
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    // From main storyboard instantiate a View controller
    let LogInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LoginViewController
    
    // Get the app delegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Set LogIn View Controller as root view controller
    appDelegate.window?.rootViewController = LogInVC
}

//? means optional
func sendMedia(picture: UIImage?, video: URL?) {
    let filePath = "\(FIRAuth.auth()!.currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
    if let picture =  picture {
        print(filePath)
        //! means unwarp
        let data = UIImageJPEGRepresentation(picture, 0.1)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
            in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            let fileUrl = metadata!.downloadURLs?[0].absoluteString
            
            let newMessage = self.messageRef.childByAutoId()
            let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
            newMessage.setValue(messageData)
        }
    } else if let video = video {
        print(filePath)
        //! means unwarp
        let data = try? Data(contentsOf: video)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/mp4"
        FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error)
            in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            let fileUrl = metadata!.downloadURLs?[0].absoluteString
            
            let newMessage = self.messageRef.childByAutoId()
            let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
            newMessage.setValue(messageData)
        }
    }
}
}
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    print("did finish picking")
    //get the image
    print(info)
    if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
        let photo = JSQPhotoMediaItem(image: picture)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
        sendMedia(picture: picture, video: nil)
    }
    else if let video = info[UIImagePickerControllerMediaURL] as? URL{
        let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
        sendMedia(picture: nil, video: video)
    }
    self.dismiss(animated: true, completion: nil)
    collectionView.reloadData()
}
}
