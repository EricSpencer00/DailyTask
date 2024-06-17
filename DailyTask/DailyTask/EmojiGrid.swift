import SwiftUI

struct EmojiGrid: View {
    @Binding var emojiBank: EmojiBank

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
            ForEach(emojiBank.emojis, id: \.self) { emoji in
                ZStack(alignment: .topTrailing) {
                    Text(emoji)
                        .font(.largeTitle)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
    }
}
