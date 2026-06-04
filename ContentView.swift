import SwiftUI
import AVKit
import PhotosUI

struct ContentView: View {
    @StateObject var vm = VideoEditorViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    
                    // NATIVE PREVIEW DISPLAY WINDOW
                    if let player = vm.player {
                        VideoPlayer(player: player)
                            .frame(height: 320)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "shield.checkerboard")
                                .font(.system(size: 44))
                                .foregroundColor(.blue)
                            Text("100% Private Offline AI Studio")
                                .font(.headline)
                            Text("Select local video assets to process securely")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 320)
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.08))
                        .cornerRadius(16)
                    }

                    // FILE MEDIA PICKER CONTROLS
                    HStack(spacing: 16) {
                        PhotosPicker(selection: $vm.imageSelection, matching: .videos) {
                            Label("Import Media", systemImage: "photo.on.rectangle.angled")
                                .font(.body)
                                .bold()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: { vm.play() }) {
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .padding(12)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .clipShape(Circle())
                        }

                        Button(action: { vm.pause() }) {
                            Image(systemName: "pause.fill")
                                .font(.title3)
                                .padding(12)
                                .background(Color.red.opacity(0.15))
                                .foregroundColor(.red)
                                .clipShape(Circle())
                        }
                    }

                    if !vm.statusMessage.isEmpty {
                        Text(vm.statusMessage)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.08))
                            .cornerRadius(8)
                    }

                    Divider().padding(.vertical, 5)

                    // OFFLINE UTILITIES INTERFACE CONTROL TOOLBAR
                    VStack(alignment: .leading, spacing: 10) {
                        Text("On-Device AI Engine")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        HStack(spacing: 16) {
                            Button(action: { vm.applyFaceBlur() }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "face.smiling.fill")
                                        .font(.title2)
                                    Text("AI Face Blur")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 100, height: 80)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                            
                            Spacer()
                            
                            Button(action: { vm.exportVideo() }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up.fill")
                                        .font(.title2)
                                    Text("Save Video")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 100, height: 80)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 8)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("AVE Private")
                
                // RENDERING ISOLATED HARDWARE OVERLAY BLOCKER
                if vm.isProcessing {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    VStack(spacing: 14) {
                        ProgressView()
                            .scaleEffect(1.3)
                        Text(vm.statusMessage)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .padding(24)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(14)
                    .shadow(radius: 25)
                }
            }
        }
    }
}
