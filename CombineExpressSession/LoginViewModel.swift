//
//  LoginViewModel.swift
//  CombineExpressSession
//
//  Created by Sergio Bravo Talero on 20/01/23.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    private let networkManager: NetworkManager
    
    var networkingCancellable: AnyCancellable?
    var subscriptions = Set<AnyCancellable>()
    
    @Published var isLoginButtonDisabled = true
    @Published var showLoginErrorAlert = false
    @Published var showLoginSuccessfulAlert = false
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
}

extension LoginViewModel {
    struct Input {
        let usernamePublisher: AnyPublisher<String, Never>
        let passwordPublisher: AnyPublisher<String, Never>
        let buttonActionPublisher: AnyPublisher<Void, Never>
    }
    
    public func setupSubscriptions(input: LoginViewModel.Input) {
        let filledtextFieldsPublisher = input.usernamePublisher
            .combineLatest(input.passwordPublisher) { username, password in
                return !username.isEmpty && !password.isEmpty
            }
            .eraseToAnyPublisher()
        observeFilledTextFieldsPublisher(filledtextFieldsPublisher)
        observeButtonActionPublisher(input.buttonActionPublisher)
    }
    
    private func observeFilledTextFieldsPublisher(_ publisher: AnyPublisher<Bool, Never>) {
        publisher
            .sink { [weak self] areFieldsCompleted in
                self?.isLoginButtonDisabled = !areFieldsCompleted
            }
            .store(in: &subscriptions)
    }
    
    private func observeButtonActionPublisher(_ publisher: AnyPublisher<Void, Never>) {
        publisher
            .sink { [weak self ]_ in
                self?.loginUserWithPublisher()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Networking
private extension LoginViewModel {
    private func loginUserWithPublisher() {
        let loginPublisher: AnyPublisher<User, NetworkManager.SimulatedError> = networkManager.fetchResponse(url: "http://www.testloginexpress.com")
        networkingCancellable = loginPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.showLoginErrorAlert = true
                    self?.networkingCancellable = nil
                },
                receiveValue: { [weak self] user in
                    self?.showLoginSuccessfulAlert = true
                    self?.networkingCancellable = nil
                })
    }
}
