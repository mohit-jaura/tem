//
//  MyContentCarousal.swift
//  TemApp
//
//  Created by Mohit Soni on 17/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation

enum CarousalType:Int{
    case homeScreen = 1, seeAllScreen, both
}

enum TileType:Int {
    case whatsNew = 1, foodTrek, temTv, goalsAndChallenges, temStore, contentMarket, coachingTools
}

class MyContentCarousal{
    
    //  var myContentData:[SeeAllModel] = [SeeAllModel(id:"1",image: "Rectangle Copy 81", title: "What's New", description: "See what is going on in the app. Check your notifications here.",hashTags:""),SeeAllModel(id:"1",image: "Rectangle Copy 7", title: "Food Trek", description: "Understand your relationship with nutrition. Food Trek helps you stay accountable.",hashTags:""),SeeAllModel(id:"1",image: "Rectangle Copy 12", title: "TĒM TV", description: "Featured content created by our team. Health and Wellness education and entertainment.",hashTags:""),SeeAllModel(id:"1",image: "goalsandchallengestile", title: "Goals & Challenges", description: "Stay updated on all of your goals and challenges.",hashTags:""),SeeAllModel(id: "1", image: "retail marekt place tile", title: "TĒM STORE", description: "")]
    
    //  What’s New, Food Trek, TEM TV, Goals and Challenges, TEM Store and Live session
    
    func getContentCarousal(type carousal:CarousalType, completion: @escaping(_ response: [SeeAllModel]?, _ error:DIError? ) -> (Void)){
        DIWebLayerContentMarket().getMyContentList { response in
            let tiles = self.getCarousal(type: carousal, tiles: response)
            completion(tiles,nil)
        } failure: { error in
            completion(nil,error)
        }
    }
    //  var imagesData = [ #imageLiteral(resourceName: "Rectangle Copy 81"), #imageLiteral(resourceName: "Rectangle Copy 7"), #imageLiteral(resourceName: "Rectangle Copy 12"), #imageLiteral(resourceName: "goalsandchallengestile"), #imageLiteral(resourceName: "retail marekt place tile")]
    
    func getCarousal(type carousal:CarousalType,tiles:[Tile]) -> [SeeAllModel]{
        var carousalArray = [SeeAllModel]()
        for tile in tiles {
            let image = tile.image
            let name = tile.name
            let tileDisplayType = CarousalType(rawValue: tile.displayOn)
            let tileType = TileType(rawValue: tile.tileType)
            switch carousal {
                case .homeScreen:
                    switch tileDisplayType {
                        case .homeScreen,.both:
                            switch tileType {
                                case .whatsNew:
                                    carousalArray.append(SeeAllModel(id:"1",image: image, title: name, description: "See what is going on in the app. Check your notifications here.",hashTags:""))
                                case .foodTrek:
                                    carousalArray.append(SeeAllModel(id:"2",image: image, title: name, description: "Understand your relationship with nutrition. Food Trek helps you stay accountable.",hashTags:""))
                                case .temTv:
                                    carousalArray.append(SeeAllModel(id:"3",image: image, title: name, description: "Featured content created by our team. Health and Wellness education and entertainment.",hashTags:""))
                                case .goalsAndChallenges:
                                    carousalArray.append(SeeAllModel(id:"4",image: image, title: name, description: "Stay updated on all of your goals and challenges.",hashTags:""))
                                case .temStore:
                                    carousalArray.append(SeeAllModel(id: "5", image: image, title: name, description: ""))
                                case .contentMarket:
                                    carousalArray.append(SeeAllModel(id: "6", image: image, title: name, description: ""))
                                case .coachingTools:
                                    carousalArray.append(SeeAllModel(id: "7",image: image,title: name,description: ""))
                                default:
                                    break
                            }
                        default:
                            break
                    }
                    
                case .seeAllScreen:
                    switch tileDisplayType {
                        case .seeAllScreen,.both:
                            switch tileType {
                                case .whatsNew:
                                    carousalArray.append(SeeAllModel(id:"1",image: image, title: name, description: "See what is going on in the app. Check your notifications here.",hashTags:""))
                                case .foodTrek:
                                    carousalArray.append(SeeAllModel(id:"2",image: image, title: name, description: "Understand your relationship with nutrition. Food Trek helps you stay accountable.",hashTags:""))
                                case .temTv:
                                    carousalArray.append(SeeAllModel(id:"3",image: image, title: name, description: "Featured content created by our team. Health and Wellness education and entertainment.",hashTags:""))
                                case .goalsAndChallenges:
                                    carousalArray.append(SeeAllModel(id:"4",image: image, title: name, description: "Stay updated on all of your goals and challenges.",hashTags:""))
                                case .temStore:
                                    carousalArray.append(SeeAllModel(id: "5", image: image, title: name, description: ""))
                                case .contentMarket:
                                    carousalArray.append(SeeAllModel(id: "6", image: image, title: name, description: ""))
                                case .coachingTools:
                                    carousalArray.append(SeeAllModel(id: "7",image: image,title: name,description: ""))
                                default:
                                    break
                            }
                        default:
                            break
                    }
                default:
                    break
            }
        }
        return carousalArray
    }
}
