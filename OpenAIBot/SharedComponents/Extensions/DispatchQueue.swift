import Foundation

extension DispatchQueue {
    func safeAsync(_ dispatchBlock: @escaping () -> Void) {
        // Validate status of current queue and thread
        if self === DispatchQueue.main && Thread.isMainThread {
            dispatchBlock()
        } else {
            self.async {
                dispatchBlock()
            }
        }
    }
}
