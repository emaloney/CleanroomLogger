import PackageDescription

let package = Package(
	name: "CleanroomLogger",
	dependencies: [
		.Package(url: "https://github.com/emaloney/CleanroomASL", versions: Version(1,4,0) ..< Version(2,0,0))
	]
)
