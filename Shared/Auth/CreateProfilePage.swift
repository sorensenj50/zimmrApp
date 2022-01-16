//
//  CreateAccountPage.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/2/22.
//

import SwiftUI
import Combine

func removeAtUserName(userName: String) -> String {
    if userName.first == "@" {
        var formatted = userName
        formatted.removeFirst()
        return formatted
    } else {
        return userName
    }
}

enum FocusedTypes {
    case firstName
    case lastName
    case userName
}



struct SetProfilePage: View {
    let isFirstCreating: Bool


    @EnvironmentObject var firebaseAuthManager: FirebaseAuthManager
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var userName: String = ""
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    @State var isLoading: Bool = false
    @FocusState var focusState: FocusedTypes?
    @State var showUserNameError: Bool = false
    @State var profileCreated: Bool = false
    @State var showSubmitButton: Bool = false
    
    
    func uploadImage() {
        let userID = USER_ID.instance.get()!
        let ref = FirebaseStorageManager.instance.getUploadReference(id: userID)
        
        guard let image = image
            else { return }

        guard let imageData = image.resized(to: CGSize(width: 150, height: 150)).jpegData(compressionQuality: 0.5)
            else { return }

        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print(error)
                return
            }
            print("Success?")
        }
    }
    
    func verifyUserName() async {
        if DemoTracker.checkEnterDemoMode(firstName: self.firstName, lastName: self.lastName, userName: self.userName) {
            DemoTracker.instance.isDemoMode = true
            firebaseAuthManager.auraProfileCreated()
        } else {
            self.isLoading = true
            self.focusState = nil
            let formattedUserName = removeAtUserName(userName: userName)
            
            let request = composeReqCore(path: "/userNameCheck", method: "GET", params: ["userName": formattedUserName], cachePolicy: .reloadIgnoringLocalCacheData)
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let decodedResponse = try? JSONDecoder().decode(ExistenceResponse.self, from: data) {
                    self.isLoading = !decodedResponse.exists
                    if !decodedResponse.exists {
                        uploadImage()
                        self.showUserNameError = false
                        await createUserProfile(userName: formattedUserName)
                    } else {
                        self.showUserNameError = true
                    }
                }
                
            } catch {
                print("Post Request Invalid data")
            
            }

        }
    }
    
    static func remove_at_sign(text: inout String) -> String {
        if text.first == "@" {
            text.removeFirst()
            return text
        } else {
            return text
        }
    }
    
    
    func createUserProfile(userName: String) async {
        let path: String
        if isFirstCreating {
            path = "/newUser"
        } else {
            path = "/editUser"
        }
        
        
        let userID = USER_ID.instance.get()!
        let firstTrimmed = self.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastTrimmed = self.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullName = firstTrimmed + " " + lastTrimmed
        let userName = SetProfilePage.remove_at_sign(text: &self.userName)
        
        var body: [String: Any] = ["userID": userID,
                                   "firstName": firstTrimmed,
                                   "creationDate": Date().timeIntervalSince1970,
                                   "fullName": fullName,
                                   "userName": userName]
        
        if isFirstCreating {
            body["phoneNumber"] = PHONE_NUMBER.instance.get()!
        }
        
        if self.image != nil {
            body["hasImage"] = "true"
        } else {
            body["hasImage"] = "false"
        }
        
        
        KeychainHelper.standard.save(service: .firstName, value: firstTrimmed)
        

        let req = composeReqCore(path: path, method: "POST", params: ["":""], body: body, cachePolicy: .reloadIgnoringLocalCacheData)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            if let _ = try? JSONDecoder().decode(StatusResponse.self, from: data) {
                self.isLoading = false
                if isFirstCreating {
                    DispatchQueue.main.async {
                        firebaseAuthManager.auraProfileCreated()
                    }
                }
        }
            
        } catch {
            print("Post Request Invalid data")
            self.isLoading = false
        
        }
    }
    

    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0.01)
                .onTapGesture {
                    if focusState != nil {
                        focusState = nil
                    }
                }
            
            if isFirstCreating {
                VStack {
                    HStack {
                        Button {
                            firebaseAuthManager.signOut()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                        }
                        .padding(.leading, 12)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            
            VStack(spacing: 0) {
                
                Text("Picture")
                    .font(.system(size: 16, weight: .light))
                    .padding(.bottom, 5)
                if let image = image {
                    ValidUserImage(image: image, size: 90)
                        .padding(.bottom, 15)
                        .onTapGesture {
                            showImagePicker = true
                        }

                } else {
                    AddImageButton(showImagePicker: $showImagePicker)
                        .padding(.bottom, 15)
                }
                
                
                VStack(alignment: .leading, spacing: 0) {
                
                    Text("First Name")
                        .font(.system(size: 16, weight: .light))
                        .padding(.leading, 40)
                        .padding(.bottom, 5)
                    BubbleInput(placeHolder: "Truman", type: FocusedTypes.firstName, focusState: $focusState, input: $firstName)
                        .padding(.bottom, 15)
                        .frame(width: 300)
                        
                    Text("Last Name")
                        .font(.system(size: 16, weight: .light))
                        .padding(.leading, 40)
                        .padding(.bottom, 5)
                    BubbleInput(placeHolder: "Gundersen", type: FocusedTypes.lastName, focusState: $focusState, input: $lastName)
                        .padding(.bottom, 15)
                        .frame(width: 300)

                    Text("User Name")
                        .font(.system(size: 16, weight: .light))
                        .padding(.leading, 40)
                        .padding(.bottom, 5)
                    BubbleInput(placeHolder: "@the_snack", type: FocusedTypes.userName, focusState: $focusState, input: $userName)
                        .padding(.bottom, 10)
                        .frame(width: 300)
                }
                .onReceive(Just(userName)) { thing in
                    if firstName.count > 0 && lastName.count > 0 && userName.count > 0 {
                        withAnimation(.linear(duration: 0.3)) {
                            self.showSubmitButton = true
                        }
                       
                    } else {
                        withAnimation(.linear(duration: 0.3)) {
                            self.showSubmitButton = false
                        }
                    }
                }

                
                
                if showUserNameError && focusState != .userName {
                    ErrorMessage(text: "That username is already taken!")
                }
                
                if showSubmitButton {
                    Button {
                        Task { await verifyUserName() }
                    } label: {
                        SubmitButtonText(text: "Submit")
                    }
                }
                
                Spacer()
            }
            if isLoading {
                TaskLoadingView()
            }
            
        }
        .padding(.top, 10)
        .navigationTitle("Create Profile")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)

        }
    }
}

        


struct BubbleInput: View {
    let placeHolder: String
    let type: FocusedTypes

    @FocusState.Binding var focusState: FocusedTypes?
    @Binding var input: String



    var body: some View {

        TextField(placeHolder, text: $input)
            .foregroundColor(.black)
            .font(.system(size: 16, weight: .semibold))
            .focused($focusState, equals: type)
            .submitLabel(.next)
            .keyboardType(.asciiCapable)
            .disableAutocorrection(type == .userName)
            .textInputAutocapitalization(type == .userName ? .never: .words)
            .onReceive(Just(input)) { newValue in
                if type == .firstName {
                    input = String(newValue.prefix(10))
                } else if type == .lastName {
                    input = String(newValue.prefix(15))
                } else if type == .userName {
                    if newValue.count == 1 && newValue.first != "@" {
                        let value = "@" + newValue
                        input = String(value.prefix(20))
                    } else {
                        let value = newValue.replacingOccurrences(of: "\\s", with: "_", options: .regularExpression)
                        input = String(value.prefix(20))
                    }
                }
            }

            .onSubmit {
                if focusState == .firstName {
                    focusState = .lastName
                } else if focusState == .lastName {
                    focusState = .userName
                } else {
                    print("Last")
                }
            }
            .padding(12)
            .background(COLORS.GRAY)
            .cornerRadius(50)
            .padding(.horizontal, 20)
    }
}

struct AddImageButton: View {
    @Binding var showImagePicker: Bool
    var body: some View {
        Button {
            showImagePicker = true
        } label: {
            ZStack {
                Circle()
                    .fill(COLORS.GRAY)
                    .frame(width: 80, height: 80)
                Image(systemName: "person.fill.badge.plus")
                    .font(.system(size: 35, weight: .light))
                    .foregroundColor(.gray)
            }
        }
    }
}

