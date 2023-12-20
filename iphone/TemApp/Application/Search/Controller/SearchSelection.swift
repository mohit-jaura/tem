//
//  SearchSelection.swift
//  TemApp
//
//  Created by Egor Shulga on 7.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

enum SearchMode {
    case preview
    case allInCategory
}

/// Is used to present search category selection (via modal)
enum SearchSelection : CaseIterable {
    case all
    case people
    case posts
    case groups
    case goals
    case challenges
    case events
    
    var title: String {
        switch self {
        case .all: return "All categories"
        case .people: return "People"
        case .posts: return "Posts"
        case .groups: return "Tēms"
        case .goals: return "Goals"
        case .challenges: return "Challenges"
        case .events: return "Calendar events"
        }
    }
    
    var emptyMessage: String {
        switch self {
        case .all: return AppMessages.GlobalSearch.noAll
        case .people: return AppMessages.GlobalSearch.noTemates
        case .posts: return AppMessages.GlobalSearch.noPosts
        case .groups: return AppMessages.GlobalSearch.noTems
        case .goals: return AppMessages.GlobalSearch.noGoals
        case .challenges: return AppMessages.GlobalSearch.noChallenge
        case .events: return AppMessages.GlobalSearch.noEvents
        }
    }
    
    var category: SearchCategory? {
        switch self {
        case .all: return nil
        case .people: return .people
        case .posts: return .posts
        case .groups: return .groups
        case .goals: return .goals
        case .challenges: return .challenges
        case .events: return .events
        }
    }
    
    var request: SearchCategoryRequest {
        switch self {
        case .all: return GlobalSearch.all
        case .people: return GlobalSearch.people
        case .posts: return GlobalSearch.posts
        case .groups: return GlobalSearch.groups
        case .goals: return GlobalSearch.goals
        case .challenges: return GlobalSearch.challenges
        case .events: return GlobalSearch.events
        }
    }
}
