import AVFoundation
import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI

class VideoEditorViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isProcessing = false
    @Published var statusMessage = ""
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet { loadSelectedVideo() }
    }

    private var currentURL: URL?

    private func loadSelectedVideo() {
        guard let item = imageSelection else { return }
        isProcessing = true
        statusMessage = "Accessing secure local storage..."
        
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success(let data?):
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("input_raw.mp4")
                    try? FileManager.default.removeItem(at: tempURL)
                    try? data.write(to: tempURL)
                    self.currentURL = tempURL
                    self.player = AVPlayer(url: tempURL)
                    self.statusMessage = "Video imported safely!"
                default:
                    self.statusMessage = "Local read failure."
                }
            }
        }
    }

    func play() { player?.play() }
    func pause() { player?.pause() }

    func applyFaceBlur() {
        guard let inputURL = currentURL else {
            statusMessage = "Please import a video first!"
            return
        }
        isProcessing = true
        statusMessage = "Neural Engine tracking faces..."
        
        let asset = AVAsset(url: inputURL)
        let composition = AVMutableVideoComposition(asset: asset) { request in
            let sourceImage = request.sourceImage
            let handler = VNImageRequestHandler(ciImage: sourceImage, options: [:])
            let faceRequest = VNDetectFaceRectanglesRequest()
            
            try? handler.perform([faceRequest])
            
            guard let results = faceRequest.results, !results.isEmpty else {
                request.finish(with: sourceImage, context: nil)
                return
            }
            
            var outputImage = sourceImage
            let size = sourceImage.extent.size
            
            for face in results {
                let box = face.boundingBox
                let faceRect = CGRect(
                    x: box.origin.x * size.width,
                    y: box.origin.y * size.height,
                    width: box.size.width * size.width,
                    height: box.size.height * size.height
                )
                
                let filter = CIFilter.gaussianBlur()
                filter.radius = 45.0
                filter.inputImage = sourceImage
                guard let blurredImage = filter.outputImage else { continue }
                
                outputImage = blurredImage.cropped(to: faceRect).composited(over: outputImage)
            }
            request.finish(with: outputImage, context: nil)
        }
        
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.videoComposition = composition
        self.player = AVPlayer(playerItem: playerItem)
        
        self.isProcessing = false
        self.statusMessage = "Local AI Face Blur applied!"
    }

    func exportVideo() {
        guard let playerItem = player?.currentItem else {
            statusMessage = "No active composition track!"
            return
        }
        isProcessing = true
        statusMessage = "Rendering local MP4 container..."
        
        guard let exporter = AVAssetExportSession(asset: playerItem.asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("ave_render_output.mp4")
        try? FileManager.default.removeItem(at: outputURL)
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        exporter.videoComposition = playerItem.videoComposition
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                if exporter.status == .completed {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                    }) { success, _ in
                        DispatchQueue.main.async {
                            self.isProcessing = false
                            self.statusMessage = success ? "Saved to Camera Roll!" : "Gallery permission error."
                        }
                    }
                } else {
                    self.isProcessing = false
                    self.statusMessage = "Local renderer failed."
                }
            }
        }
    }
}
