import Foundation

protocol WindowFocusProtocol {
    func focusIDEWindow(forProjectPath path: String, ideBundleId: String?)
    func checkAccessibilityPermissions() -> Bool
    func requestAccessibilityPermissions()
}
