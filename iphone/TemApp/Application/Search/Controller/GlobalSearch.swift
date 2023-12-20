//
//  Search.swift
//  TemApp
//
//  Created by Egor Shulga on 2.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

class SearchCategoryRequest : Encodable {
    var people: Bool
    var posts: Bool
    var groups: Bool
    var goals: Bool
    var challenges: Bool
    var events: Bool
    
    init(people: Bool = false, posts: Bool = false, groups: Bool = false, goals: Bool = false, challenges: Bool = false, events: Bool = false) {
        self.people = people
        self.posts = posts
        self.groups = groups
        self.goals = goals
        self.challenges = challenges
        self.events = events
    }
}

class GlobalSearch {
    static let all = SearchCategoryRequest(people: true, posts: true, groups: true, goals: true, challenges: true, events: true)
    static let people = SearchCategoryRequest(people: true)
    static let posts = SearchCategoryRequest(posts: true)
    static let groups = SearchCategoryRequest(groups: true)
    static let goals = SearchCategoryRequest(goals: true)
    static let challenges = SearchCategoryRequest(challenges: true)
    static let events = SearchCategoryRequest(events: true)
    
    let subcategories: [PreviewSearchTypeAgnostic]
    
    let people = SearchPeople()
    let posts = SearchPosts()
    let groups = SearchGroups()
    let goals = Search<GroupActivity>(url: "search/goals",
                                      description: "Goals",
                                      emptyMessage: SearchSelection.goals.emptyMessage,
                                      header: GlobalSearch.createGoalsSearchHeader,
                                      cell: GlobalSearch.createGoalCell)
    let challenges = Search<GroupActivity>(url: "search/challenges",
                                           description: "Challenges",
                                           emptyMessage: SearchSelection.challenges.emptyMessage,
                                           header: GlobalSearch.createChallengesSearchHeader,
                                           cell: GlobalSearch.createChallengeCell)
    let events = SearchEvents()
    
    init() {
        subcategories = [people, posts, groups, goals, challenges, events]
    }
    
    func loadPreview(_ request: SearchCategoryRequest, filter: String, limit: Int,
                     success: @escaping () -> (), failure: @escaping (_ error: DIError) -> ()) {
        if filter.length == 0 {
            return
        }
        let body: Parameters = [
            "filter": filter,
            "limit": limit,
            "category": request.json()!
        ]
        DIWebLayer.instance.call(method: .post, function: "search", parameters: body) { (response) in
            do {
                let data = response["data"] as! Parameters
                if let people = data["people"] as? Parameters {
                    try self.savePreview(self.people.byName, people["name"])
                    try self.savePreview(self.people.byLocation, people["location"])
                    try self.savePreview(self.people.byGym, people["gym"])
                    try self.savePreview(self.people.byInterests, people["interests"])
                } else {
                    self.people.clearPreview()
                }
                if let posts = data["posts"] as? Parameters {
                    try self.savePreview(self.posts.byPeople, posts["people"])
                    try self.savePreview(self.posts.byCaption, posts["caption"])
                    try self.savePreview(self.posts.byTags, posts["tags"])
                } else {
                    self.posts.clearPreview()
                }
                if let groups = data["groups"] as? Parameters {
                    try self.savePreview(self.groups.available, groups["available"])
                    try self.savePreview(self.groups.participating, groups["participating"])
                } else {
                    self.groups.clearPreview()
                }
                try self.savePreview(self.goals, data["goals"])
                try self.savePreview(self.challenges, data["challenges"])
                if let events = data["events"] as? Parameters {
                    try self.savePreview(self.events.future, events["future"])
                    try self.savePreview(self.events.past, events["past"])
                } else {
                    self.events.clearPreview()
                }
            } catch {
                failure(DIError.invalidJSON())
            }
            success()
        } failure: { (error) in
            failure(error)
        }
    }
    
    private func savePreview(_ search: SearchPeople.ByAttribute, _ byAttribute: Any?) throws {
        if let byAttribute = byAttribute as? Parameters {
            try self.savePreview(search.friends, byAttribute["friends"])
            try self.savePreview(search.other, byAttribute["other"])
        } else {
            search.clearPreview()
        }
    }
    
    private func savePreview(_ search: SearchEvents.ByTime, _ byTime: Any?) throws {
        if let byTime = byTime as? Parameters {
            try self.savePreview(search.available, byTime["available"])
            try self.savePreview(search.participating, byTime["participating"])
        } else {
            search.clearPreview()
        }
    }
    
    private func savePreview<T : Decodable>(_ search: Search<T>, _ data: Any?) throws {
        if let data = data {
            let preview: [T] = try DIWebLayer.instance.decodeFrom(data: data)
            search.savePrevew(preview)
        } else {
            search.clearPreview()
        }
    }
}

class SearchPeople : PreviewSearchCategory {
    typealias T = Friends
    let header = SearchPeople.createSearchHeader
    let subcategories: [SearchPeople.ByAttribute]
    
    let byName = ByAttribute(url: "search/people/name",
                             description: "by name",
                             header: SearchPeople.createSearchByNameHeader)
    let byLocation = ByAttribute(url: "search/people/location",
                                 description: "by location",
                                 header: SearchPeople.createSearchByLocationHeader)
    let byGym = ByAttribute(url: "search/people/gym",
                            description: "by gym / club",
                            header: SearchPeople.createSearchByGymHeader)
    let byInterests = ByAttribute(url: "search/people/interests",
                                  description: "by interests",
                                  header: SearchPeople.createSearchByInterestsHeader)
    
    init() {
        subcategories = [byName, byLocation, byGym, byInterests]
    }

    class ByAttribute : PreviewSearchCategory {
        typealias T = Friends
        let header: (SearchViewControllerProtocol, UITableView, IndexPath) -> UITableViewCell
        let subcategories: [Search<Friends>]
        
        let friends: Search<Friends>
        let other: Search<Friends>
        
        init(url: String, description: String, header: @escaping (_: SearchViewControllerProtocol, _: UITableView, _: IndexPath) -> UITableViewCell) {
            self.header = header
            friends = Search(url: "\(url)/friends",
                             description: "Tēmates \(description)",
                             emptyMessage: SearchSelection.people.emptyMessage,
                             header: SearchPeople.createSearchFriendsHeader,
                             cell: SearchPeople.createCell)
            other = Search(url: "\(url)/other",
                           description: "Non-tēmates \(description)",
                           emptyMessage: SearchSelection.people.emptyMessage,
                           header: SearchPeople.createSearchOtherHeader,
                           cell: SearchPeople.createCell)
            subcategories = [friends, other]
        }
        
        func moveFromOtherToFriends(otherIndex: Int) {
            friends.preview.insert(other.preview[otherIndex], at: 0)
            other.preview.remove(at: otherIndex)
        }
    }
}

class SearchPosts : PreviewSearchCategory {
    private static let emptyMessage = SearchSelection.posts.emptyMessage
    typealias T = Post
    let header = SearchPosts.createSearchHeader
    let subcategories: [Search<Post>]
    
    let byPeople = Search<Post>(url: "search/posts/people",
                                description: "Posts by Tēmates",
                                emptyMessage: emptyMessage,
                                header: SearchPosts.createSearchByPeopleHeader,
                                cell: SearchPosts.createCell)
    let byCaption = Search<Post>(url: "search/posts/caption",
                                 description: "Posts by Caption",
                                 emptyMessage: emptyMessage,
                                 header: SearchPosts.createSearchByCaptionHeader,
                                 cell: SearchPosts.createCell)
    let byTags = Search<Post>(url: "search/posts/tags",
                              description: "Posts by tags",
                              emptyMessage: emptyMessage,
                              header: SearchPosts.createSearchByTagsHeader,
                              cell: SearchPosts.createCell)
    init() {
        subcategories = [byPeople, byCaption, byTags]
    }
}

class SearchGroups : PreviewSearchCategory {
    private static let emptyMessage = SearchSelection.groups.emptyMessage
    typealias T = Friends
    let header = SearchGroups.createSearchHeader
    let subcategories: [Search<Friends>]
    
    let available = Search<Friends>(url: "search/groups/available",
                                    description: "Tēms Available to Join",
                                    emptyMessage: emptyMessage,
                                    header: SearchGroups.createAvailableGroupsSearchHeader,
                                    cell: SearchGroups.createCell)
    let participating = Search<Friends>(url: "search/groups/participating",
                                        description: "Participating Tēms",
                                        emptyMessage: emptyMessage,
                                        header: SearchGroups.createParticipatingGroupsSearchHeader,
                                        cell: SearchGroups.createCell)
    init() {
        subcategories = [available, participating]
    }
}

class SearchEvents : PreviewSearchCategory {
    typealias T = EventDetail
    let header = SearchEvents.createSearchHeader
    let subcategories: [SearchEvents.ByTime]

    let future = SearchEvents.ByTime(url: "search/events/future",
                                     description: "Future",
                                     header: SearchEvents.createFutureEventsSearchHeader)
    let past = SearchEvents.ByTime(url: "search/events/past",
                                   description: "Past",
                                   header: SearchEvents.createPastEventsSearchHeader)
    init() {
        subcategories = [future, past]
    }

    class ByTime : PreviewSearchCategory {
        typealias T = EventDetail
        let header: (SearchViewControllerProtocol, UITableView, IndexPath) -> UITableViewCell
        let subcategories: [Search<EventDetail>]

        let available: Search<EventDetail>
        let participating: Search<EventDetail>

        init(url: String, description: String, header: @escaping (_: SearchViewControllerProtocol, _: UITableView, _: IndexPath) -> UITableViewCell) {
            self.header = header
            available = Search(url: "\(url)/available",
                               description: "\(description) Available To Join Calendar Events",
                               emptyMessage: SearchSelection.events.emptyMessage,
                               header: SearchEvents.createAvailableEventsSearchHeader,
                               cell: SearchEvents.createCell)
            participating = Search(url: "\(url)/participating",
                               description: "\(description) Participating Calendar Events",
                               emptyMessage: SearchSelection.events.emptyMessage,
                               header: SearchEvents.createParticipatingEventsSearchHeader,
                               cell: SearchEvents.createCell)
            subcategories = [available, participating]
        }
    }
}

class Search<T : Decodable> : PreviewSearch, CategorySearch {
    fileprivate(set) var preview: [T] = []
    fileprivate(set) var all: [T] = []
    
    fileprivate let url: String
    fileprivate var filter: String?
    fileprivate(set) var limit = 3
    fileprivate(set) var page = 0
    fileprivate(set) var nextPage = 1
    
    let headerFactory: (SearchViewControllerProtocol, UITableView, IndexPath) -> UITableViewCell
    let cellFactory: (SearchViewControllerProtocol, UITableView, IndexPath, T) -> UITableViewCell
    let footerFactory: (SearchViewControllerProtocol, UITableView, IndexPath, CategorySearch) -> UITableViewCell
    
    let description: String
    let emptyMessage: String

    init(url: String,
         description: String,
         emptyMessage: String,
         header: @escaping (SearchViewControllerProtocol, UITableView, IndexPath) -> UITableViewCell,
         cell: @escaping (SearchViewControllerProtocol, UITableView, IndexPath, T) -> UITableViewCell,
         footer: @escaping (SearchViewControllerProtocol, UITableView, IndexPath, CategorySearch) -> UITableViewCell = GlobalSearch.footerCellFactory) {
        self.url = url
        self.description = description
        self.emptyMessage = emptyMessage
        self.headerFactory = header
        self.cellFactory = cell
        self.footerFactory = footer
    }
    
    func savePrevew(_ data: [T]) {
        preview = data
    }
    
    func removeFromPreview(where shouldBeRemoved: (T) -> Bool) {
        preview.removeAll(where: shouldBeRemoved)
    }
}

extension Search : PreviewSearchTypeAgnosticDataSource {
    var isPreviewEmpty: Bool {
        return preview.count == 0
    }
    
    func clearPreview() {
        preview.removeAll()
    }
    
    func previewCellsCount() -> Int {
        let result: Int
        if preview.count == 0 {
            result = 0
        } else {                            // rows for data
            result = preview.count + 2      // with additional rows for header & footer
        }
        return result
    }
}

extension Search : PreviewSearchItemSource {
    func tryGetPreviewItem(_ blockIndex: Int, _ item: inout T?) -> Bool {
        var index = blockIndex
        if index == 0 {
            return true
        }
        index -= 1
        if index < preview.count {
            item = preview[index]
        }
        // Item is considered found in the current search result,
        // but actual value could be null, if index points to header or footer.
        return true
    }
}

extension Search : PreviewSearchCellSource {
    func tryAcquirePreviewCell(_ controller: SearchViewControllerProtocol, _ table: UITableView, _ tableIndex: IndexPath, _ index: inout Int, _ cell: inout UITableViewCell?) -> Bool {
        if preview.count == 0 {
            return false
        }
        if index == 0 {
            cell = headerFactory(controller, table, tableIndex)
            return true
        }
        index -= 1
        if index < preview.count {
            cell = cellFactory(controller, table, tableIndex, preview[index])
            return true
        }
        index -= preview.count
        if index == 0 {
            cell = footerFactory(controller, table, tableIndex, self)
            return true
        }
        index -= 1
        return false
    }
}

extension Search : CategorySearchItemSource {
    func clear() {
        all.removeAll()
    }
    
    func resetAndLoad(filter: String, limit: Int, success: @escaping () -> (), failure: @escaping (_ error: DIError) -> ()) {
        self.filter = filter
        self.limit = limit
        self.page = 0
        self.nextPage = 1
        self.loadNextPage(success: success, failure: failure)
    }
    
    func loadNextPage(success: @escaping () -> (), failure: @escaping (_ error: DIError) -> ()) {
        guard let filter = filter, page < nextPage else {
            return
        }
        page = nextPage
        let body: Parameters = [
            "filter": filter,
            "limit": limit,
            "page": nextPage
        ]
        DIWebLayer.instance.call(method: .post, function: url, parameters: body) { (response) in
            do {
                let data = response["data"] as! [Parameters]
                if self.page == 1 {
                    self.all.removeAll()
                }
                let pageData: [T] = try DIWebLayer.instance.decodeFrom(data: data)
                if pageData.count > 0 {
                    self.all.append(contentsOf: pageData)
                    self.nextPage = self.page + 1
                }
            } catch {
                failure(DIError.invalidJSON())
            }
            success()
        } failure: { (error) in
            failure(error)
        }
    }
}

extension Search : CategorySearchCellSource {
    var isEmpty: Bool { all.count == 0 }
    
    func cellsCount() -> Int {
        return all.count
    }
    
    func tryAcquireCell(_ controller: SearchViewControllerProtocol, _ table: UITableView, _ tableIndex: IndexPath, _ cell: inout UITableViewCell?) -> Bool {
        let index = tableIndex.row
        if index < all.count {
            cell = cellFactory(controller, table, tableIndex, all[index])
            return true
        }
        return false
    }
}
