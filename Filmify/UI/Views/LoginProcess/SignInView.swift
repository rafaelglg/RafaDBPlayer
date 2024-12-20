//
//  SignInView.swift
//  Filmify
//
//  Created by Rafael Loggiodice on 10/12/24.
//

import SwiftUI

struct SignInView: View {
    
    @FocusState private var focusFieldEmail: FieldState?
    @FocusState private var focusFieldPassword: FieldState?
    
    @State private var signInVM: SignInViewModel
    @Environment(AuthViewModelImpl.self) private var authViewModel
    @Environment(AppStateImpl.self) private var appState
    
    private let createSignUpView: CreateSignUpView
    
    init(signInVM: SignInViewModel, createSignUpView: CreateSignUpView) {
        self.signInVM = signInVM
        self.createSignUpView = createSignUpView
    }
    
    var body: some View {
        ZStack {
            dismissKeyboardTapInBackground
            VStack {
                loginView
            }
            .animation(.smooth, value: authViewModel.biometricAuth.isAuthenticated)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    @Previewable @State var authViewModel = AuthViewModelImpl()
    SignInView(signInVM: SignInViewModelImpl(),
               createSignUpView: SignUpFactory())
        .environment(authViewModel)
        .environment(AppStateImpl())
}

extension SignInView {
    
    var dismissKeyboardTapInBackground: some View {
        // To dismiss the keyboard when tap the background
        Color(.systemBackground)
            .ignoresSafeArea()
            .onTapGesture {
                focusFieldEmail = nil
                focusFieldPassword = nil
            }
    }
    
    var loginView: some View {
        VStack {
            Spacer()
            Text("Sign in")
                .font(.title)
                .bold()
                .frame(height: 90)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            CustomTextfield(placeholder: "Email", text: $signInVM.emailText)
                .focused($focusFieldEmail, equals: .email)
                .submitLabel(.next)
            
            CustomSecureField(placeholder: "Password", passwordText: $signInVM.passwordText)
                .focused($focusFieldPassword, equals: .password)
                .submitLabel(.done)
            
            signInButton
            biometricButton
            authenticationButtons
            Spacer()
            registerButton
        }
    }
    
    var signInButton: some View {
        Button {
            withAnimation {
                authViewModel.signIn(email: signInVM.emailText, password: signInVM.passwordText)
            }
        } label: {
            Text("Sign in")
                .tint(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 50)
        .background(.buttonBG, in: RoundedRectangle(cornerRadius: 15))
        .padding()
    }
    
    @ViewBuilder
    var biometricButton: some View {
        @Bindable var authViewModel = authViewModel
        let authentication = authViewModel.biometricAuth
        Button {
            authViewModel.biometricAuthentication(email: signInVM.emailText)
        } label: {
            Image(systemName: authentication.biometricType == .touchID ? "touchid" : "faceid" )
                .resizable()
                .tint(.primary)
                .scaledToFit()
                .symbolEffect(.variableColor.iterative, isActive: authentication.isAuthenticating)
                .symbolEffect(.bounce, value: authentication.isAuthenticated)
        }
        .frame(height: 50)
        .padding(.vertical, 30)
        .alert(isPresented: $authViewModel.biometricAuth.showingAlert) {
            Alert(title: Text("Authentication failed"),
                  message: Text(authViewModel.biometricAuth.alertMessage),
                  dismissButton: .cancel())
        }
    }
    
    var authenticationButtons: some View {
        VStack {
            Text("or login with")
            HStack {
                Button {
                } label: {
                    Image(systemName: "applelogo" )
                        .resizable()
                        .tint(.primary)
                        .scaledToFit()
                        .frame(height: 25)
                }
                Button {
                } label: {
                    Image(systemName: "applelogo" )
                        .resizable()
                        .tint(.primary)
                        .scaledToFit()
                        .frame(height: 25)
                }
            }
            .padding(.top, 10)
        }
    }
    
    @ViewBuilder
    var registerButton: some View {
        @Bindable var appState = appState
        HStack {
            Text("New to RafaDB?")
                .font(.headline)
                .foregroundStyle(Color(.systemGray))
            Button {
                appState.changeSignUpState(newValue: .signUp)
            } label: {
                Text("Sign Up")
                    .font(.headline)
            }
            .tint(.buttonBG)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .sheet(item: $appState.currentState) {
            appState.resetNavigationPath()
        } content: { state in
            if state == .signUp {
                createSignUpView.createSignUpView()
            }
        }
    }
}