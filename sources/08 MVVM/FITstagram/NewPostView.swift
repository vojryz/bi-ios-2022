//
//  NewPostView.swift
//  FITstagram
//
//  Created by Vojtech Ryznar on 11.12.2022.
//

import SwiftUI

struct AddPostRequest: Encodable {
    let text: String
    let photos: [String]
}

struct NewPostView: View {
    @AppStorage("username") var username = ""
    @State var postText:String
    @State var imagePost: UIImage?
    @State var isImagePickerPresented = false
    @State var showingAlert = false
    @State var isButtonLoading = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(.gray)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if let imagePost {
                        Image(uiImage: imagePost)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .clipped()
                .overlay(
                    Button {
                        isImagePickerPresented = true
                    } label: {
                        Circle()
                            .fill(.white)
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: "pencil")
                                    .resizable()
                                    .padding()
                            )
                    }
                )
            TextField("Text post", text: $postText)
                .padding()
            Button{
                Task{
                    isButtonLoading = true
                    await addPost()
                }
            }label: {
                if(!isButtonLoading){
                    Image(systemName: imagePost != nil && !postText.isEmpty ? "paperplane.fill" : "paperplane")
                } else {
                    Image(systemName: "circle.dotted")
                }
               
            }.disabled(imagePost == nil || postText.isEmpty)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error posting").bold())
                }
        }
        .fullScreenCover(isPresented: $isImagePickerPresented) {
            ImagePostPicker(
                image: $imagePost,
                isPresented: $isImagePickerPresented
            )
        }
        
    }
    @MainActor
    func addPost() async {

        let url = URL(string: "https://fitstagram.ackee.cz/api/feed")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": username
        ]


        do {
            guard let imageCGImage = imagePost?.cgImage else {return};
            let minWidth = min(imageCGImage.width, 2048)
            let minHeight = min(imageCGImage.height, 2048)
            guard let imageCut = imageCGImage.cropping(to: .init(x: 0, y: 0, width: minWidth, height: minHeight)) else {return}
            guard let imageBase64 = UIImage(cgImage: imageCut).jpegData(compressionQuality: 1)?.base64EncodedString() else {return}
            let imageConverted = [imageBase64]
            let body = AddPostRequest(text: postText, photos: imageConverted)
            request.httpBody = try! JSONEncoder().encode(body)
            
            let (_) = try await URLSession.shared.data(for: request)
            try  await Task.sleep(nanoseconds:  1000000000)
                presentationMode.wrappedValue.dismiss()
        } catch {
            print("[ERROR]", error.localizedDescription)
            showingAlert = true
        }
    }
    
    
}
    
    struct NewPostView_Previews: PreviewProvider {
        static var previews: some View {
            NewPostView(postText: "text postu")
        }
    }
    
    struct ImagePostPicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Binding var isPresented: Bool
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let controller = UIImagePickerController()
            controller.delegate = context.coordinator
            return controller
        }
        
        func updateUIViewController(
            _ uiViewController: UIImagePickerController,
            context: Context
        ) { }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(image: $image, isPresented: $isPresented)
        }
        
        final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            @Binding var image: UIImage?
            @Binding var isPresented: Bool
            
            init(image: Binding<UIImage?>, isPresented: Binding<Bool>) {
                self._image = image
                self._isPresented = isPresented
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                isPresented = false
            }
            
            func imagePickerController(
                _ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
            ) {
                guard let image = info[.originalImage] as? UIImage else { return }
                self.image = image
                self.isPresented = false
            }
        }
        
        
    }
