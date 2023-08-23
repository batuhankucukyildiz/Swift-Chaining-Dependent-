

import Foundation
import Combine

struct User : Decodable {
    let id : UUID
}

struct UserDetails : Decodable{
    let name : String
    let email : String
}

struct Friends : Decodable {
    let id : UUID
    let name : String
}


func load<T : Decodable>(url : URL) -> AnyPublisher<T , Error> {
    return URLSession.shared.dataTaskPublisher(for: url)
        .tryMap{ result in
            guard let httpResponse = result.response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            return result.data
            
        }
        .decode(type : T.self , decoder : JSONDecoder())
        .eraseToAnyPublisher()
}

func loadUser() ->AnyPublisher<User , Error> {
    load(url: URL(string: "http://localhost:3000/user")!)
}
func loadDetails(user :User) ->AnyPublisher<UserDetails , Error> {
    load(url: URL(string: "http://localhost:3000/\(user.id)/details")!)
}
func loadFriends(user :User) ->AnyPublisher<[Friends] , Error> {
    load(url: URL(string: "http://localhost:3000/\(user.id)/friends")!)
}

func loadUserDetails () -> AnyPublisher<(UserDetails , [Friends]) ,Error> {
    loadUser()
        .flatMap{ user in
            Publishers.Zip(loadDetails(user: user) , loadFriends(user: user))
        }.eraseToAnyPublisher()
}



