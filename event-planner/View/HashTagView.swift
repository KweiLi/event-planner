import SwiftUI

extension String {
    func width(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct TagView: View {
    let tags: [String]
    var font: Font = .system(size: 14)
    var uiFont: UIFont { return UIFont.systemFont(ofSize: 14) } // Convenience variable
    let padding: CGFloat = 10.0
    let horizontalPadding: CGFloat = 15.0 // Adjust as per requirement

    @Binding var selectedTag: String

    private var allTagLines: [TagLine] {
        var lines: [TagLine] = []
        var line = TagLine()
        var lineWidth: CGFloat = 0

        for tag in tags {
            let tagWidth = tag.width(font: uiFont) + 2 * horizontalPadding + 2 * padding // Adjusted width calculation

            if lineWidth + tagWidth > UIScreen.main.bounds.width {
                lines.append(line)
                line = TagLine()
                lineWidth = 0
            }

            lineWidth += tagWidth
            line.tags.append(tag)
        }

        if !line.tags.isEmpty {
            lines.append(line)
        }
        return lines
    }

    var body: some View {
        VStack(alignment: .leading, spacing: padding) {
            ForEach(allTagLines, id: \.self) { tagLine in
                HStack(spacing: padding) {
                                        
                    ForEach(tagLine.tags, id: \.self) { tag in
                        Button(action: {
                            self.selectedTag = tag
                        }) {
                            Text(tag)
                                .font(font)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.vertical, padding)
                                .background(Color.white)
                                .cornerRadius(15)
                        }
                    }
                }
            }
        }
        .padding(10) // Padding around the TagLayoutView
        .cornerRadius(10) // Rounded corners
    }
}

extension TagView {
    struct TagLine: Hashable {
        var tags: [String] = []
    }
}

extension String {
    func width(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct TagView_Previews: PreviewProvider {
    @State static var sampleSearchKey: String = ""

    static var previews: some View {
        Group {
            TagListView(tags: ["Swift", "Kotlin", "Java", "Objective-C", "JavaScript", "Python", "Go", "Ruby", "Rust"], searchKey: $sampleSearchKey)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.white)
                .previewDisplayName("Light Mode")

            TagListView(tags: ["Swift", "Kotlin", "Java", "Objective-C", "JavaScript", "Python", "Go", "Ruby", "Rust"], searchKey: $sampleSearchKey)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.black)
                .colorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
