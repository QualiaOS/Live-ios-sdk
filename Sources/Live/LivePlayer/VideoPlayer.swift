//
//  VideoPlayer.swift
//  
//
//  Created by Sacha on 09/09/2020.
//

import SwiftUI
import AVFoundation
import UIKit
import Combine

public struct VideoPlayer: UIViewRepresentable {

	let url: String
	let looping: Bool
	let isPlaying: Bool
	let isLive: Bool
	let isMuted: Bool

	public init(url: String, looping: Bool, isPlaying: Bool, isLive: Bool = true, isMuted: Bool = false) {
		self.url = url
		self.looping = looping
		self.isPlaying = isPlaying
		self.isLive = isLive
		self.isMuted = isMuted
	}

	public func makeUIView(context: Context) -> UIView {
		let playerView = VideoAVPlayerView()
		playerView.playerLayer?.videoGravity = .resizeAspectFill
		if let assetURL = URL(string: url) {
			let asset = AVAsset(url: assetURL)
			let playerItem = AVPlayerItem(asset: asset)

			if isLive {
				playerItem.automaticallyPreservesTimeOffsetFromLive = true
				playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
			}

			let player = AVQueuePlayer(playerItem: playerItem)
			if looping {
				context.coordinator.looper = AVPlayerLooper(player: player, templateItem: playerItem)
			}
			playerView.player = player
			context.coordinator.player = player
		}
		return playerView
	}

	public func updateUIView(_ uiView: UIView, context: Context) {
		if isPlaying {

			if isLive {
				// Keep close to direct as much as possible.
				context.coordinator.player?.seek(to: CMTime.positiveInfinity)
			}

			context.coordinator.player?.play()
		} else {
			context.coordinator.player?.pause()
		}
		context.coordinator.player?.isMuted = isMuted
	}

	public func makeCoordinator() -> VideoPlayer.Coordinator {
		return Coordinator()
	}

	public class Coordinator {
		var looper: AVPlayerLooper?
		var player: AVPlayer?
	}
}

final class VideoAVPlayerView: UIView {

	override static var layerClass: AnyClass { AVPlayerLayer.self }
	var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }
	var player: AVPlayer? {
		get { playerLayer?.player }
		set { playerLayer?.player = newValue }
	}
}
