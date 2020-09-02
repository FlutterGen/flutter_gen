setup:
	flutter channel stable
	flutter upgrade
	flutter pub get
	npm install

dependencies:
	pub get

analyze:
	flutter analyze

format:
	flutter format lib/

format-analyze:
	flutter format --set-exit-if-changed --dry-run lib/
	flutter analyze

build:
	cd example && flutter build apk && cd ..

unit-test:
	pub run test --coverage --coverage-path=./coverage/lcov.info
