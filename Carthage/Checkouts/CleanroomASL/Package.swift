import PackageDescription

let package = Package(
	name: "CleanroomASL",
	dependencies: [
		.Package(url: "https://github.com/emaloney/AppleSystemLogSwiftPackage", majorVersion: 1)
	]
)
