import XCTest
import UIKit

@MainActor
final class IslandSmokeTests: XCTestCase {
    func testStaticAndAnimatedIslandOnHomeScreen() throws {
        continueAfterFailure = false
        for mode in ["static", "animated"] {
            let app = XCUIApplication()
            app.launchArguments = ["--smoke-" + mode]
            app.launch()
            XCTAssertTrue(app.buttons["Adadan al"].waitForExistence(timeout: 20),
                          "Live Activity did not start in " + mode + " mode")
            XCUIDevice.shared.press(.home)
            Thread.sleep(forTimeInterval: 4)
            capture(mode + "-1")
            Thread.sleep(forTimeInterval: 2)
            capture(mode + "-2")
            app.activate()
            app.terminate()
        }
    }

    private func capture(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        // A small top-of-screen capture in logs makes visual review possible
        // without mistaking the in-app mock island for the real SpringBoard UI.
        let image = screenshot.image
        let scale = 430 / image.size.width
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 430, height: 140))
        let crop = renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: 430, height: image.size.height * scale))
        }
        if let data = crop.pngData() {
            print("ADA_SCREENSHOT_" + name + ":" + data.base64EncodedString())
        }
    }
}
