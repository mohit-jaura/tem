//
//  TaggingDataSource.swift
//  Tagging
//
//  Created by DongHeeKang on 2018. 6. 24..
//

public protocol TaggingDataSource: AnyObject {
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String])
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel])
    func tagging(_ tagged: (NSMutableAttributedString,NSRange))
    func tagging(searchUser:String)

}

public extension TaggingDataSource {
    func tagging(_ tagging: Tagging, didChangedTagableList tagableList: [String]) {return}
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel]) {return}
    func tagging(_ tagged: (NSMutableAttributedString,NSRange)) {return}

}
