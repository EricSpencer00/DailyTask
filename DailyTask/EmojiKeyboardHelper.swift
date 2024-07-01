import SwiftUI

struct EmojiKeyboardHelper: UIViewRepresentable {
    @Binding var isVisible: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = true // Ensure the view can interact
        context.coordinator.setFirstResponder(view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isVisible {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: EmojiKeyboardHelper

        init(_ parent: EmojiKeyboardHelper) {
            self.parent = parent
        }

        func setFirstResponder(_ view: UIView) {
            DispatchQueue.main.async {
                view.becomeFirstResponder()
            }
        }
    }
}

extension View {
    func emojiKeyboard(_ isVisible: Binding<Bool>) -> some View {
        self
            .background(
                EmojiKeyboardHelper(isVisible: isVisible)
                    .frame(width: 0, height: 0) // Invisible helper view
            )
    }
}
