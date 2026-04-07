//
//  OpenLibraryAPIService.swift
//  Assignment04
//
//  Created by Barrett Emerson on 4/6/26.
//

import Foundation

class OpenLibraryAPIService {
    // singleton - one shared instance used across the entire app
    static let shared = OpenLibraryAPIService()
    private init() {}
    
    func fetchBooks(query: String) async throws -> [Book] {
        // clean up the search term so it's safe to use in a URL
        // spaces and special characters aren't allowed in URLs
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }
        
        // build the full URL using the encoded search term
        guard let url = URL(string: "https://openlibrary.org/search.json?q=\(encodedQuery)") else {
            throw URLError(.badURL)
        }
        
        // make the network request and wait for the response
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // check we got a successful HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // decode the JSON into our SearchResponse wrapper, then return the books array
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.docs
    }
}
