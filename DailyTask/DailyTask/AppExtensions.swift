import SwiftUI

extension View {
    func emojiKeyboard(_ isVisible: Binding<Bool>) -> some View {
        self
            .background(
                EmojiKeyboardHelper(isVisible: isVisible)
            )
    }
}

struct EmojiKeyboardHelper: UIViewRepresentable {
    @Binding var isVisible: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.becomeFirstResponder()
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isVisible {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }
}
