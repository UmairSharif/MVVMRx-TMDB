//
//  ApiServices.swift
//  RxMVVM-TMDB
//
//  Created by Umair  on 06/11/2021.
//

import Foundation
import RxSwift
import UIKit
import WebKit

class ApiServices {
    
//    func getMovies(_ query: String, completion: @escaping ([Movie]) -> ()) {
//
//        let session = URLSession.shared
//        var completeUrl = ""
//        var request: URLRequest
//        if query.count > 0 {
//            //completeUrl = Constants.movieSearchUrl+query
//            let resource = Resource<Movies>.searchMovie(query: query)
//            request = resource.request!
//        } else {
//            completeUrl = Constants.popularListUrl+Constants.api_key
//            request = URLRequest(url: URL(string: completeUrl)!)
//        }
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        session.dataTask(with: request) { data, response, error in
//
//            guard let data = data, error == nil, let response = response as? HTTPURLResponse else { return }
//
//            if 200..<300 ~= response.statusCode {
//                do {
//                    let decoder = JSONDecoder()
//                    let movies = try decoder.decode(Movies.self, from: data)
//                    print("Response ==>")
//
//                    completion(movies.listOfMovies)
//                } catch let error {
//                    print("An Error : \(error.localizedDescription)")
//                }
//            } else {
//                print("Api fail with status code: \(response.statusCode)")
//            }
//        }.resume()
//    }
    
    func getMovies(_ query: String, completion: @escaping ([Movie]) -> ()) {
        
        let session = URLSession.shared
        
        var url = ""
        var params = [(String,String)]()
        if query.count > 0 {
            url = Constants.movieSearchUrl
            params = [("query", query)]
        } else {
            url = Constants.popularListUrl
        }
        
        let request = buildRequest(url: url, params: params)
        
        session.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil, let response = response as? HTTPURLResponse else { return }
            
            if 200..<300 ~= response.statusCode {
                do {
                    let decoder = JSONDecoder()
                    let movies = try decoder.decode(Movies.self, from: data)
                    
                    completion(movies.listOfMovies ?? [])
                } catch let newError {
                    print("An Error : \(newError)")
                }
            } else {
                print("Api fail with status code: \(response.statusCode)")
            }
        }.resume()
    }
    
    func getMovieDetail(_ movieID: Int, completion: @escaping (MovieDetail) -> ()) {
        
        let session = URLSession.shared
        let url = Constants.movieDetailUrl+String(movieID)
        let request = buildRequest(url: url, params: [])
        
        session.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil, let response = response as? HTTPURLResponse else { return }
            
            if 200..<300 ~= response.statusCode {
                do {
                    let decoder = JSONDecoder()
                    let movie = try decoder.decode(MovieDetail.self, from: data)
                    print("Response ==>")
                    print(movie.title)
                    completion(movie)
                } catch let error {
                    print("An Error : \(error.localizedDescription)")
                }
            } else {
                print("Api fail with status code: \(response.statusCode)")
            }
        }.resume()
    }
    
    private func buildRequest(method: String = "GET", url: String, params: [(String, String)]) -> URLRequest {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "api_key", value: Constants.apiKey)
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            queryItems.append(keyQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [keyQueryItem]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
}


