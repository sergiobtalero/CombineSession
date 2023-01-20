//
//  ContentView.swift
//  CombineExpressSession
//
//  Created by Sergio Bravo Talero on 20/01/23.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    @State private var username = ""
    @State private var password = ""
    
    private let usernameInternalPublisher = PassthroughSubject<String, Never>()
    private let passwordInternalPublisher = PassthroughSubject<String, Never>()
    private let buttonTapActionPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome Express iOS Team. \n**Please login**")
                .foregroundColor(.mint)
                .font(.system(size: 25))
                .padding(.bottom, 12)
            TextField("Username", text: $username)
            TextField("Password", text: $password)
            HStack {
                Spacer()
                Button {
                    buttonTapActionPublisher.send(())
                } label: {
                    Text("Login")
                        .foregroundColor(.mint)
                        .fontWeight(.medium)
                }
                .disabled(viewModel.isLoginButtonDisabled)
                Spacer()
            }
            .padding(.top, 25)
        }
        .padding()
        .onChange(of: username) { newValue in
            usernameInternalPublisher.send(newValue)
        }
        .onChange(of: password) { newValue in
            passwordInternalPublisher.send(newValue)
        }
        .alert("Ooops. Something went wrong.", isPresented: $viewModel.showLoginErrorAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("YEIII. You're logged in", isPresented: $viewModel.showLoginSuccessfulAlert) {
            Button("GREAT", role: .cancel) {}
        }
        .onAppear {
            let input = LoginViewModel.Input(
                usernamePublisher: usernameInternalPublisher.eraseToAnyPublisher(),
                passwordPublisher: passwordInternalPublisher.eraseToAnyPublisher(),
                buttonActionPublisher: buttonTapActionPublisher.eraseToAnyPublisher()
            )
            viewModel.setupSubscriptions(input: input)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
