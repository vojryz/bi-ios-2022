//
//  PostTappedDetail.swift
//  FITstagram
//
//  Created by Vojtech Ryznar on 14.11.2022.
//

import SwiftUI

struct PostTappedDetail: View {
    let post: Post
    @State var comments: [CommentSpecial] = []
    @State var show = true;
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 4){
                Image(systemName: "person.crop.circle")
                Text(post.author.username )
            }.opacity(show ? 1 : 0)
            TabView {
                ForEach(post.photos, id: \.self) { photo in
                    AsyncImage(url: URL(string: photo)) {
                        $0.resizable()
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }.tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                TabView {
                    if (comments.isEmpty){
                        ProgressView()
                            .progressViewStyle(.circular)
                        
                    } else {
                        ForEach(comments) { comment in
                            VStack {
                                HStack {
                                    Text(comment.text).bold()
                                    Image(systemName: "hand.thumbsup")
                                    Text(String(comment.likes)).italic()
                                    
                                }
                                Text(" - " + comment.author.username)
                            }
                        }
                    }
                }.tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .opacity(show ? 1 : 0)
            Button {
                self.show = !self.show
            } label: {
                Text(show ? "Hide" : "Show")
            }
            
        }.task{
            await fetchComments(postId: post.id )
        }
    }
    
    private func fetchComments(postId: String) async {
        var request = URLRequest(url: URL(string: "https://fitstagram.ackee.cz/api/feed/\(postId)/comments")!)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            self.comments = try JSONDecoder().decode([CommentSpecial].self, from: data)
        } catch {
            print("[ERROR]", error)
        }
    }
    
}

