setup:
	flutter channel stable
	flutter upgrade
	flutter pub get
	npm install

dependencies:
	flutter pub get

analyze:
	flutter analyze

format:
	flutter format lib/

format-analyze:
	flutter format --set-exit-if-changed --dry-run lib/
	flutter analyze

build-runner:
	cd example && flutter packages pub run build_runner build --delete-conflicting-outputs cd ..

build:
	cd example && flutter build apk && cd ..