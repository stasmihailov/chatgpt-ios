//
//  TestScreen.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI
import Combine

struct User: Codable, Identifiable {
    var id: Int
    var login: String?
    var avatar_url: String?
}

class GithubUsers: ObservableObject {
    enum GithubUsersState {
        case START
        case LOADING
        case SUCCESS(users: [User])
        case FAILURE(error: String)
    }

    @Published var state: GithubUsersState = .START
    private var cancelables = Set<AnyCancellable>()

    init() {
        getUsers()
    }

    func getUsers() {
        self.state = .LOADING
        APIService.shared.getUsers()
            .sink { completion in
                switch completion {
                case .finished:
                    print("Execution Finihsed.")
                case .failure(let error):
                    self.state = .FAILURE(error: error.localizedDescription)
                }
            } receiveValue: { users in
                self.state = .SUCCESS(users: users)
            }.store(in: &cancelables)
    }
}

class APIService {
    static let shared = APIService()

    func getUsers() -> AnyPublisher<[User], Error> {
        guard let url = URL(string: "https://api.github.com/users") else {
            return Fail(error: "Unable to generate url" as! Error).eraseToAnyPublisher()
        }
        
        return Future { promise in
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                DispatchQueue.main.async {
                    do {
                        guard let data = data else {
                            return promise(.failure("Something went wrong" as! Error))
                        }
                        let users = try JSONDecoder().decode([User].self, from: data)
                        return promise(.success(users))
                    } catch let error {
                        return promise(.failure(error))
                    }
                }
            }.resume()
        }.eraseToAnyPublisher()
    }
}

struct HomeView: View {
    @ObservedObject var users = GithubUsers()

    var body: some View {
        if case .LOADING = users.state {
            loaderView()
        } else if case .SUCCESS(let users) = users.state {
            List(users) { user in
                userCell(user: user)
                    .frame(height: 60)
            }
        } else if case .FAILURE(let error) = users.state {
            VStack(alignment: .center) {
                Spacer()
                Text(error)
                    .font(.headline.bold())
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
        }
    }

    func userCell(user: User) -> some View {
        HStack(spacing: 40) {
            AsyncImage(url: URL(string: user.avatar_url ?? "Unknown user")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60, alignment: .center)
            .clipShape(Circle())

            Text(user.login ?? "")
                .font(.headline)
            Spacer()
        }
    }

    func loaderView() -> some View {
        ZStack {
            Color.black.opacity(0.05)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(1, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
        }
    }
}

struct TestScreen_Preview: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
