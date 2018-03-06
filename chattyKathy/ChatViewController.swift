//
//  ChatViewController.swift
//  chattyKathy
//
//  Created by Kevin Perkins on 3/2/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
    
    var messages   = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    var messageRef = Database.database().reference().child("messages")

    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentUser = Auth.auth().currentUser {
            self.senderId = currentUser.uid
            
            if currentUser.isAnonymous == true {
                self.senderDisplayName = "Anonymous"
            } else {
                self.senderDisplayName = "\(currentUser.displayName!)"
            }
        }
        
        observeMessages()
    }
    
    func observeUser(withId id : String) {
        Database.database().reference().child("users").child(id).observe(.value) { (snapshot) in
            if let userDict = snapshot.value as? [String: Any] {
                let avatarURL = userDict["profileURL"] as! String
                self.setupAvatar(withURL: avatarURL, withSenderID: id)
            }
        }
    }
    
    func setupAvatar(withURL url : String, withSenderID id : String) {
        if url != "" {
            let fileURL = URL(string: url)
            do {
                let data = try Data(contentsOf: fileURL!)
                let image = UIImage(data: data)
                let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
                avatarDict[id] = userImg
            } catch {
                print("unable to set user Avatar for google user")
            }
        } else {
             avatarDict[id] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        self.collectionView.reloadData()
    }
    
    func observeMessages() {
        messageRef.observe(.childAdded, with: { snapshot in
            if let messageDict = snapshot.value as? [String: Any] {
                let mediaType = messageDict["media"] as! String
                let senderId = messageDict["senderId"] as! String
                let senderName = messageDict["senderName"] as! String
                
                self.observeUser(withId: senderId)
                
                switch mediaType {
                    case "TEXT":
                        let text = messageDict["text"] as! String
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    
                    case "PHOTO":
                        let fileURL = messageDict["fileURL"] as? String
                        let url = URL(string: fileURL!)
                        do {
                            let data = try Data(contentsOf: url!)
                            let picture = UIImage(data: data)
                            let photo = JSQPhotoMediaItem(image: picture)
                            
                            if senderId == self.senderId {
                                photo?.appliesMediaViewMaskAsOutgoing = true
                            } else {
                                photo?.appliesMediaViewMaskAsOutgoing = false
                            }
                            
                            self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                        } catch {
                            print("Unable to create data from image url contents")
                        }
                    
                    case "VIDEO":
                        let fileURL = messageDict["fileURL"] as? String
                        let video = URL(string: fileURL!)
                        let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                        
                        if senderId == self.senderId {
                            videoItem?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            videoItem?.appliesMediaViewMaskAsOutgoing = false
                        }
                        
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    default:
                        print("Unknown media type value")
                }
                
                self.collectionView.reloadData()
            }
        })
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "media": "TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (uiAlert) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { (alert) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.default) { (alert) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
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
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()

        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.blue)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        return self.avatarDict[message.senderId]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
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
    
    
    @IBAction func logoutDidTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error: \(error)")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }
    
    func sendMedia(picture: UIImage?, video: NSURL?) {
        if let picture = picture {
            let filePath = "\(Auth.auth().currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            Storage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (meta, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                let fileURL = meta?.downloadURLs![0].absoluteString
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileURL": fileURL, "senderId": self.senderId, "senderName": self.senderDisplayName, "media": "PHOTO"]
                newMessage.setValue(messageData)
            }
        } else if let video = video {
            let filePath = "\(Auth.auth().currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            let data = NSData(contentsOf: video as URL)
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            Storage.storage().reference().child(filePath).putData(data! as Data, metadata: metadata) { (meta, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                let fileURL = meta?.downloadURLs![0].absoluteString
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileURL": fileURL, "senderId": self.senderId, "senderName": self.senderDisplayName, "media": "VIDEO"]
                newMessage.setValue(messageData)
            }
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture: image, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            sendMedia(picture: nil, video: video)
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}
