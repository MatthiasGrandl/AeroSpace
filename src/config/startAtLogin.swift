import Common

func syncStartAtLogin() {
    let launchAgentsDir = FileManager.default.homeDirectoryForCurrentUser.appending(component: "Library/LaunchAgents/")
    tryCatch { try FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true) }.getOrThrow()
    let url: URL = launchAgentsDir.appending(path: "bobko.aerospace.plist")
    if config.startAtLogin {
        let plist =
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(Bundle.appId)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(URL(filePath: CommandLine.arguments.first ?? errorT("Can't get first argument")).absoluteURL.path)</string>
                    <string>--started-at-login</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
            </dict>
            </plist>
            """
        tryCatch { try plist.write(to: url, atomically: false, encoding: .utf8) }
            .getOrThrow("Can't write to \(url) ")
        tryCatch { try Process.run(URL(filePath: "/bin/launchctl"), arguments: ["load", url.absoluteString]) }.getOrThrow()
    } else {
        tryCatch { try Process.run(URL(filePath: "/bin/launchctl"), arguments: ["unload", url.absoluteString]) }.getOrThrow()
        try? FileManager.default.removeItem(at: url)
    }
}
