import Fluent

final class PostUserRelation: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.modify("posts", closure: { posts in
            //posts.string("foo", length: 150, optional: false, unique: false, default: nil)
            posts.parent(User.self, optional: false, unique: false, default: nil)
            
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.modify("posts", closure: { posts in
            //posts.delete("foo")
            
        })
    }
}
