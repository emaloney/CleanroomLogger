import PackageDescription

let package = Package(
	name: "CleanroomLogger",
	dependencies: [
        .Package(url: "https://github.com/emaloney/CleanroomASL", majorVersion: 2, minor: 0)
	]
)
