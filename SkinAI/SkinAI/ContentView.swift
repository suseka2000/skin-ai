import SwiftUI
import PhotosUI
import CoreML
import Vision

struct ContentView: View {

    @State private var selectedImage: UIImage?
    @State private var predictionText = "No prediction"

    @State private var showPicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {

        VStack(spacing: 20) {

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(20)
            }

            Text(predictionText)
                .font(.title2)
                .bold()

            Button("Choose Photo") {
                showActionSheet()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

        }
        .padding()
        .sheet(isPresented: $showPicker) {
            ImagePicker(
                sourceType: sourceType,
                selectedImage: $selectedImage,
                onImagePicked: classifyImage
            )
        }
    }

    func showActionSheet() {

        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first

        let alert = UIAlertController(
            title: "Select Image",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            sourceType = .camera
            showPicker = true
        })

        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            sourceType = .photoLibrary
            showPicker = true
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        window?.rootViewController?.present(alert, animated: true)
    }

    func classifyImage(_ image: UIImage) {
        guard let resized = image.resizeTo(size: CGSize(width: 28, height: 28)),
              let pixelBuffer = resized.toPixelBuffer()
        else {
            predictionText = "Failed to process image"
            return
        }

        do {
            let model = try SkinCancerClassifier(configuration: MLModelConfiguration())
            let output = try model.prediction(conv2d_input: pixelBuffer)
            
            let probabilities = output.Identity
            
            let classes = [
                0: "akiec",
                1: "bcc",
                2: "bkl",
                3: "df",
                4: "nv",
                5: "vasc",
                6: "mel"
            ]
            
            var results: [(String, Double)] = []
            
            for i in 0..<probabilities.count {
                let className = classes[i] ?? "unknown"
                let percentage = probabilities[i].doubleValue * 100
                results.append((className, percentage))
            }
            
            results.sort { $0.1 > $1.1 }
            
            var resultText = ""
            for (className, percentage) in results {
                resultText += String(format: "%@: %.1f%%\n", className.uppercased(), percentage)
            }
            
            predictionText = resultText

        } catch {
            print("Classification error: \(error)")
            predictionText = "Error: \(error.localizedDescription)"
        }
    }
}
