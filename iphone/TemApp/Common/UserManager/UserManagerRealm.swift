//
//  UserManagerRealm.swift
//  TemApp
//
//  Created by Mohit Soni on 31/01/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation
import RealmSwift

class UserManagerRealm {
    
    func saveCurrentUser(user: User) {
        do {
            let realm = try Realm()
            let userResult = realm.objects(UserRealm.self)
            let realmUser = convertUserToRealmUser(user: user)
            try realm.write {
                realm.delete(userResult)
                realm.add(realmUser)
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    func getCurrentUser() -> User? {
        do {
            let realm = try Realm()
            let userResult = realm.objects(UserRealm.self)
            if userResult.count > 0 {
                let user = convertRealmUserToUser(realm: userResult[0])
                return user
            }
            return nil
        } catch(let error) {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    // function to convert realmUser modal to exists user modal
    func convertUserToRealmUser(user: User) -> UserRealm {
        let realmUser = UserRealm()
        realmUser.id = user.id
        realmUser.accountabilityMission = user.accountabilityMission
        let address = AddresRealm()
        address.city = user.address?.city ?? ""
        address.state = user.address?.state ?? ""
        address.country = user.address?.country ?? ""
        address.pincode = user.address?.pinCode ?? ""
        address.line = user.address?.place_id ?? ""
        realmUser.address = address
        realmUser.admintype = user.adminType
        realmUser.algoType = user.algoOption?.rawValue
        realmUser.calenderNotification = user.calenderNotificationStatus
        realmUser.countryCode = user.countryCode
        realmUser.createdAt = user.createdAt
        realmUser.deviceToken = user.deviceToken
        realmUser.dob = user.dateOfBirth
        realmUser.email = user.email
        realmUser.fbConnected = user.fbConnected
        realmUser.firstName = user.firstName
        realmUser.gender = user.gender
        let gym = GymRealm()
        gym.location.append(objectsIn: user.gymAddress?.location ?? [])
        gym.name = user.gymAddress?.name ?? ""
        gym.type = user.gymAddress?.gymType?.rawValue ?? 0
        gym.name = user.gymAddress?.name ?? ""
        gym.placeId = user.gymAddress?.place_id ?? ""
        gym.gymTypeMandatory = user.gymAddress?.hasGymType?.rawValue ?? 0
        realmUser.gym = gym
        let height = HeightRealm()
        height.feet = user.feet ?? 0
        height.inch = user.inch ?? 0
        realmUser.height = height
        realmUser.interest.append(objectsIn: user.interests)
        realmUser.isCompanyAccount = user.isCompanyAccount
        realmUser.isPrivate = user.isPrivate
        realmUser.lastName = user.lastName
        realmUser.location.append(objectsIn: user.address?.location ?? [])
        realmUser.phone = user.phoneNumber
        realmUser.profileCompletionStatus = user.profileCompletionStatus
        realmUser.profilePic = user.profilePicUrl
        realmUser.pushNotification = user.pushNotification
        let socialMedias = List<SocialMediaRealm>()
        if let medias = user.socialMedia {
            for media in medias {
                let socialMedia = SocialMediaRealm()
                socialMedia.id = media["_id"] as? String
                socialMedia.createdAt = media["created_at"] as? String
                socialMedia.firstName = media["first_name"] as? String
                socialMedia.lastName = media["last_name"] as? String
                socialMedia.snsId = media["sns_id"] as? String
                socialMedia.snsType = media["sns_type"] as? Int
                socialMedia.updatedAt = media["updated_at"] as? String
                socialMedias.append(socialMedia)
            }
        }
        realmUser.socialMedia = socialMedias
        realmUser.status = user.status
        realmUser.tagIds = List<TagIdRealm>()
        realmUser.token = user.oauthToken
        realmUser.tracker = user.tracker
        realmUser.trackerStatus = user.trackerStatus
        realmUser.username = user.userName
        realmUser.verifiedStatus = user.verifiedStatus
        realmUser.weight = user.weight
        return realmUser
    }
    
    // function to convert exists user modal to realmUser modal
    func convertRealmUserToUser(realm realmUser: UserRealm) -> User {
        let user = User()
        user.id = realmUser.id
        user.accountabilityMission = realmUser.accountabilityMission
        let address = Address()
        address.city = realmUser.address?.city ?? ""
        address.state = realmUser.address?.state ?? ""
        address.country = realmUser.address?.country ?? ""
        address.pinCode = realmUser.address?.pincode ?? ""
        address.place_id = realmUser.address?.line ?? ""
        user.address = address
        user.adminType = realmUser.admintype
        user.algoOption = NewsFeedAlgoOption(rawValue: realmUser.algoType ?? 0)
        user.calenderNotificationStatus = realmUser.calenderNotification
        user.countryCode = realmUser.countryCode
        user.createdAt = realmUser.createdAt
        user.deviceToken = realmUser.deviceToken
        user.dateOfBirth = realmUser.dob
        user.email = realmUser.email
        user.fbConnected = realmUser.fbConnected
        user.firstName = realmUser.firstName
        user.gender = realmUser.gender
        let gym = Address()
        gym.location?.append(contentsOf: realmUser.location)
        gym.name = realmUser.gym?.name ?? ""
        gym.gymType = GymLocationType(rawValue: realmUser.gym?.type ?? 0)
        gym.name = realmUser.gym?.name ?? ""
        gym.place_id = realmUser.gym?.placeId ?? ""
        gym.hasGymType = CustomBool(rawValue: realmUser.gym?.gymTypeMandatory ?? 0)
        user.gymAddress = gym
        user.feet = realmUser.height?.feet ?? 0
        user.inch = realmUser.height?.inch ?? 0
        user.interests.append(contentsOf: realmUser.interest)
        user.isCompanyAccount = realmUser.isCompanyAccount
        user.isPrivate = realmUser.isPrivate
        user.lastName = realmUser.lastName
        user.address?.location?.append(contentsOf: realmUser.location)
        user.phoneNumber = realmUser.phone
        user.profileCompletionStatus = realmUser.profileCompletionStatus
        user.profilePicUrl = realmUser.profilePic
        user.pushNotification = realmUser.pushNotification
        var socialMedias = [Parameters]()
        for media in realmUser.socialMedia {
            var socialMedia = Parameters()
            socialMedia["_id"] = media.id
            socialMedia["created_at"] = media.createdAt
            socialMedia["first_name"] = media.firstName
            socialMedia["last_name"] = media.lastName
            socialMedia["sns_id"] = media.snsId
            socialMedia["sns_type"] = media.snsType
            socialMedia["updated_at"] = media.updatedAt
            socialMedias.append(socialMedia)
        }
        user.socialMedia = socialMedias
        user.status = realmUser.status
        user.oauthToken = realmUser.token
        user.tracker = realmUser.tracker
        user.trackerStatus = realmUser.trackerStatus
        user.userName = realmUser.username
        user.verifiedStatus = realmUser.verifiedStatus
        user.weight = realmUser.weight
        return user
    }
}

