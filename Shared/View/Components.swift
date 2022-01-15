//
//  Components.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI





struct RelationshipHeader: View {

    let user: UserCore
    let size: CGFloat
    
    @State var isActive: Bool = false

    var body: some View {
        HStack {
            Button {
                isActive = true
                ScrollTracker.instance.didGoToDetailedView()
            } label: {
                UserImageDecider(imageID: user.userID, size: size)
                    .padding(.leading, 12)
            }
            

            VStack(alignment: .leading) {
                HStack {
                    TitleString(text: user.firstName)
                    UserNameString(text: user.userName)
                }
                
                ConnectionStringMutualFriends(user: user, size: 16)
            }
            
            NavigationLink(destination: ProfileWrapper(params: Profile.getParams(otherID: user.userID, otherName: user.firstName)), isActive: $isActive) { EmptyView() }
        }
    }
}


struct EmptyTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 23, weight: .medium))
    }
}

struct EmptySubtitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.gray)
    }
}




struct TitleString: View {
    static let normal: CGFloat = 17
    static let profile: CGFloat = 20
    
    let text: String
    let size: CGFloat
    
    
    init(text: String) {
        self.text = text
        self.size = TitleString.normal
    }
    
    init(text: String, size: CGFloat) {
        self.text = text
        self.size = size
    }
    
    
    var body: some View {
        Text(text)
            .font(.system(size: self.size))
            .fontWeight(.semibold)
    }
}

struct ConnectionString: View {
    
    static let normal: CGFloat = 16
    static let profile: CGFloat = 18
    
    
    let interpretedRelationship: String
    let size: CGFloat
    
    init(rel: UserCore.Relationship?, links: Int?) {
        self.interpretedRelationship = UserCore.interpretRelationship(rel, links)
        self.size = ConnectionString.normal
    }
    
    init(rel: UserCore.Relationship?, links: Int?, size: CGFloat) {
        self.interpretedRelationship = UserCore.interpretRelationship(rel, links)
        self.size = size
        
    }
    
    init(interpretedRelationship: String, size: CGFloat) {
        self.interpretedRelationship = interpretedRelationship
        self.size = size
    }
    
    init(interpretedRelationship: String) {
        self.interpretedRelationship = interpretedRelationship
        self.size = ConnectionString.normal
    }
    
    
    
    
    
    var body: some View {
        Text(interpretedRelationship)
            .font(.system(size: size))
            .fontWeight(.medium)
            .foregroundColor(Color.gray)
            .frame(alignment: .leading)
    }
}



struct UserNameString: View {
    static let normal: CGFloat = 14
    static let profile: CGFloat = 15
    
    let text: String
    let size: CGFloat
    
    init(text: String) {
        self.text = UserNameString.add_at_sign(text: text)
        self.size = UserNameString.normal
    }
    
    init(text: String, size: CGFloat) {
        self.text = UserNameString.add_at_sign(text: text)
        self.size = size
    }
    
    static func add_at_sign(text: String) -> String {
        if text.first == "@" {
            return text
        } else {
            return "@" + text
        }
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .light))
            .italic()
            .lineLimit(1)
            .truncationMode(.tail)
    }
}



struct ConnectionStringMutualFriends: View {
    @EnvironmentObject var tracker: RelationshipTracker
    let user: UserCore
    let size: CGFloat
    @State var isActive: Bool = false
  
    func getFromTracker() -> String {
        if tracker.isFriend(key: user.userID) {
            return "friend"
        } else {
            return UserCore.interpretRelationship(user.relationship, user.links)
        }
    }
    
    var body: some View {
        HStack {
            if user.relationship == .CONNECTION {
                Button {
                    ScrollTracker.instance.didGoToDetailedView()
                    isActive = true
                } label: {
                    ConnectionString(interpretedRelationship: getFromTracker())
                }
                
            } else {
                ConnectionString(interpretedRelationship: getFromTracker())
            }
            
            NavigationLink(destination: UserListWrapper(params: UserList.getMutualFriendParams(otherID: user.userID, name: user.firstName))
                            .navigationTitle("Mutual Friends with \(user.firstName)"), isActive: $isActive) { EmptyView() }
        }
    }
}

struct Checkmark: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 26))
            .foregroundColor(COLORS.SECONDARY)
    }
}

struct XMark: View {
    var body: some View {
        Image(systemName: "xmark")
            .font(.system(size: 26))
            .foregroundColor(Color.red)
    }
}



struct CheckmarkCircle: View {
    let size: CGFloat
    
    init() { self.size = 30 }
    
    init(size: CGFloat) { self.size = size }
    
    var body: some View {
        Image(systemName: "checkmark.circle")
            .font(.system(size: size))
            .foregroundColor(COLORS.SECONDARY)
    }
}




struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            Spacer()
        }
    }
}






struct UserImageDecider: View {
    let imageID: String
    let size: CGFloat
    

    
    var body: some View {
        if let image = Cache.instance.getImage(name: imageID) {
            ValidUserImage(image: image, size: size)
        } else {
            UserPlaceHolderImage(size: size)
        }
    }
}
    
struct ValidUserImage: View {
    let image: UIImage
    let size: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}


    

struct UserPlaceHolderImage: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(.gray)
            
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: size * 0.55, height: size * 0.55)
        }
        .frame(width: size, height: size)
    }
}


struct OutlinedHeaderRectangle: View {
    let string: String
    let systemImageName: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .foregroundColor(color)
            Text(string)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(7)
        .overlay(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).stroke(color, lineWidth: 1.5))
    }
}



struct SelectorLabel: View {
    let label: String
    @Binding var selected: String
    
    var isSelected: Bool {
        return label == selected
    }
    
    var body: some View {
        Text(label)
            .padding(7)
            .font(.system(size: 16))
            .overlay(Rectangle().frame(height: isSelected ? 3: 0), alignment: .bottom)
            .onTapGesture {
                withAnimation(.linear(duration: 0.1)) {
                    selected = label
                }
            }
            .foregroundColor(isSelected ? COLORS.PRIMARY: .black)
    }
}

struct ContentSelector: View {
    let labels: [String]
    @Binding var selected: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(labels, id: \.self) { label in
                    Spacer()
                    SelectorLabel(label: label, selected: $selected)
                }
                Spacer()
            }
            Divider()
        }
    }
}

struct Hexagon: Shape {
    static let heightWidthRatio: CGFloat = 0.8660254

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let quarterX = rect.midX / 2
        let threeQuarterX = rect.midX + quarterX

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: quarterX, y: rect.minY))
        path.addLine(to: CGPoint(x: threeQuarterX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: threeQuarterX, y: rect.maxY))
        path.addLine(to: CGPoint(x: quarterX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))

        return path
    }
}


struct SmallView: View {
    var body: some View {
        Color.white
            .frame(width: 1, height: 1)
            .opacity(0.1)
    }
}
