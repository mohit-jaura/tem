////
////  SocketIOManger.swift
////  FoodDelivery
////
////  Created by debut on 02/08/17.
////  Copyright © 2017 Capovela LLC. All rights reserved.
////
//
//import UIKit
//import SocketIO
//import CoreLocation
//
//struct SocketOnMethods {
//    static let testResponse = "block_added"
//}
//
//class SocketIOManger: NSObject {
//
//    //Shared Instance:----
//
//    static let shared = SocketIOManger()
//
//    // MARK: Variables:---
//
//    var socket: SocketIOClient!
//    let manager = SocketManager(socketURL: URL(string: Constant.Socket.url)!, config: [.log(true), .compress])
//
//    // MARK: Intilaizer:-----
//
//    override init() {
//        self.socket = manager.defaultSocket
//    }
//    // MARK: Socket Methods:---- This Fucntion will get the Data After getting
//    func onSocket(completionBlockOfSucces completion_block:@escaping ((AnyObject,String) -> Void)){
//        self.socket.on(SocketOnMethods.testResponse) { (data, ack) in
//            print("Data:--\(data)")
//        }
//    }
//
//    //This Fucntion will use to emit methods:--
//
//    func emitSocket() {
//        let parameter : SocketData = ["user_id":"parteek@1234"] as [String : Any]
//        self.socket.emitWithAck("message_send", parameter).timingOut(after: 0) { (data) in
//            print("data:-----\(data)")
//        }
//    }
//
//    //This Function will check socket is connected or not
//    func isSocketConnected() -> Bool{
//        let socketConnectionStatus = SocketIOManger.shared.socket.status
//        switch socketConnectionStatus {
//        case SocketIOStatus.connected:
//            return true
//        case SocketIOStatus.connecting:
//            return true
//        case SocketIOStatus.disconnected:
//            return false
//        case SocketIOStatus.notConnected:
//            return false
//        }
//    }
//
//    func connect(){
//        self.socket.connect()
//        print("socket connected ")
//    }
//
//    func dissConnect(){
//        self.socket.disconnect()
//        print("socket.disconnected")
//    }
//
//}//Class:---
