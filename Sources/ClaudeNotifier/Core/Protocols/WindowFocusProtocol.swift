import Foundation

protocol WindowFocusProtocol {
    func focusCursorWindow(forProjectPath path: String)
    func checkAccessibilityPermissions() -> Bool
    func requestAccessibilityPermissions()
}
