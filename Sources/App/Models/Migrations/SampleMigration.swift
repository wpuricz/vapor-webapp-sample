import Fluent

final class SampleMigration: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.modify("posts", closure: { bar in
            bar.string("foo", length: 150, optional: false, unique: false, default: nil)
            
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.modify("posts", closure: { bar in
            bar.delete("foo")
            
        })
    }
}
