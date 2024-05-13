//
//  Throttler.swift
//  ObjectDetection
//
//  Created by Mateusz Obłoza on 21/04/2024.
//

import Foundation

class ThrottlerService {
    private var workItem: DispatchWorkItem = DispatchWorkItem { }
    private var previousRun: Date = Date.distantPast
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval

    init(minimumDelay: TimeInterval,
         queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)) {
        self.minimumDelay = minimumDelay
        self.queue = queue
    }

    func throttle(_ block: @escaping () -> Void) {
        workItem.cancel()

        workItem = DispatchWorkItem { [weak self] in
            self?.previousRun = Date()
            block()
        }

        let now = Date()
        let delay = max(previousRun.addingTimeInterval(minimumDelay).timeIntervalSince(now), 0)
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

}
