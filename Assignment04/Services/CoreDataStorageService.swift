//
//  CoreDataStorageService.swift
//  Assignment04
//
//  Created by Barrett Emerson on 4/6/26.
//

import CoreData

class CoreDataStorageService {
    // singleton - one shared instance used across the entire app
    static let shared = CoreDataStorageService()
    private init() {}
    
    // sets up the Core Data stack - connects our code to the database file on disk
    let container: NSPersistentContainer = {
        // name must match our BookModel.xcdatamodeld file exactly
        let container = NSPersistentContainer(name: "BookModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                // if Core Data can't load, something is seriously wrong
                fatalError("Core Data failed to load: \(error)")
            }
        }
        return container
    }()
    
    // the context is our scratchpad - all operations happen here before being saved to disk
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // saves a book to Core Data when user favorites it
    func saveBook(_ book: Book) {
        let entity = BookEntity(context: context)
        entity.id = book.id
        entity.title = book.title
        entity.authors = book.authors.joined(separator: ",") // array → comma separated string
        entity.publisher = book.publisher
        entity.coverImageURL = book.coverImageURL?.absoluteString // URL → string
        entity.bookDescription = book.description
        
        do {
            try context.save() // write from scratchpad to disk
        } catch {
            print("Failed to save book: \(error)")
        }
    }
    
    // fetches all favorited books from Core Data
    func fetchBooks() -> [Book] {
        let request = NSFetchRequest<BookEntity>(entityName: "BookEntity")
        
        do {
            let entities = try context.fetch(request)
            // transform each BookEntity back into a Book struct
            return entities.map { entity in
                Book(
                    id: entity.id ?? "",
                    title: entity.title ?? "",
                    authors: entity.authors?.components(separatedBy: ",") ?? [], // string → array
                    publisher: entity.publisher,
                    coverImageURL: entity.coverImageURL.flatMap { URL(string: $0) }, // string → URL
                    description: entity.bookDescription
                )
            }
        } catch {
            print("Failed to fetch books: \(error)")
            return []
        }
    }
    
    // deletes a favorited book from Core Data
    func deleteBook(withId id: String) {
        let request = NSFetchRequest<BookEntity>(entityName: "BookEntity")
        // only fetch the book with this specific id
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                context.delete(entity) // mark for deletion on scratchpad
                try context.save()     // make deletion permanent on disk
            }
        } catch {
            print("Failed to delete book: \(error)")
        }
    }
}
