//
//  APICaller.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 25/07/2022.
//

import Foundation

struct Constants {
    static let API_KEY = "8765536cf9830a3ff1945261baabe026"
    static let baseURL = "https://api.themoviedb.org"
    static let YoutubeAPI_KEY = "AIzaSyAcS1EKWxsABALnlkGuuL_uYmuul6_bs7Q"
    static let YoutubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
    
}

enum APIError: Error {
    
    case failedToGetData
}

class APICaller {
    
    static let shared = APICaller()
    
    func getTrendingMovies(completion: @escaping (Result<[Title], Error>) -> Void){
        guard let url = URL(string:  "\(Constants.baseURL)/3/trending/all/day?api_key=\(Constants.API_KEY)&language=en-US&page=1") else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _ , error in
            
            guard let data = data, error == nil else {
                return
            }
            do{
                
                //            let results = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                //                print(results)
                let results = try JSONDecoder().decode(TrendingTitlesResponse.self, from:  data)
                //                print(results.results[10].original_name)
                completion(.success(results.results))
            }catch{
                //                print(error.localizedDescription)
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getTrendingTVs(completion: @escaping(Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/tv/day?api_key=\(Constants.API_KEY)&language=en-US&page=1") else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _ , error in
            
            guard let data = data, error == nil else{
                return
            }
            
            do{
                let results = try JSONDecoder().decode(TrendingTitlesResponse.self, from: data)
                completion(.success(results.results))
                
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
        
    }
    
    func getUpcomingMovies(completion: @escaping(Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/movie/upcoming?api_key=\(Constants.API_KEY)&language=en-US&page=1") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _ , error in
            guard let data = data, error == nil else { return }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitlesResponse.self, from: data)
                completion(.success(results.results))
            }
            catch {
                completion(.failure(APIError.failedToGetData))
                
            }
        }
        task.resume()
    }
    
    func getTopRated(completion: @escaping(Result<[Title], Error>) -> Void ) {
        guard let url = URL(string: "\(Constants.baseURL)/3/movie/top_rated?api_key=\(Constants.API_KEY)&language=en-US&page=1") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)){data, _, error in
            guard let data = data , error == nil else { return }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitlesResponse.self, from: data)
                completion(.success(results.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        
        task.resume()
    }
    
    func getPopular(completion: @escaping(Result<[Title], Error>) -> Void ) {
        guard let url = URL(string: "\(Constants.baseURL)/3/movie/popular?api_key=\(Constants.API_KEY)&language=en-US&page=1") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)){data, _, error in
            guard let data = data , error == nil else { return }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitlesResponse.self, from: data)
                completion(.success(results.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
            }
        }
        
        task.resume()
    }
    
    func getSearchMovies(completion: @escaping(Result<[Title], Error>) -> Void) {
        guard let url = URL(string:
                                "\(Constants.baseURL)/3/discover/movie?api_key=\(Constants.API_KEY)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)){ data, _ , error in
            
            guard let data = data , error == nil else { return }
            do{
                let result = try JSONDecoder().decode(TrendingTitlesResponse.self, from: data)
                completion(.success(result.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
                
            }
            
        }
        task.resume()
        
    }
    
    func search(with query: String, completion: @escaping(Result<[Title], Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: "\(Constants.baseURL)/3/search/movie?api_key=\(Constants.API_KEY)&query=\(query)") else { return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)){ data, _ , error in
            guard let data = data , error == nil else { return }
            do{
                let result = try JSONDecoder().decode(TrendingTitlesResponse.self, from: data)
                completion(.success(result.results))
            }
            catch{
                completion(.failure(APIError.failedToGetData))
                
            }
            
        }
        task.resume()
        
    }
    
    
    func getMovie(with query: String, completion: @escaping(Result<VideoElement, Error>) -> Void) {
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: "\(Constants.YoutubeBaseURL)q=\(query)&key=\(Constants.YoutubeAPI_KEY)") else { return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)){ data, _ , error in
            guard let data = data, error == nil else { return }
            do {
//                let results = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                
                let results = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                completion(.success(results.items[0]))
//                print(results)
            } catch {
                completion(.failure(error))
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
}






