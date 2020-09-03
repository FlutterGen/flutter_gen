setup:
	flutter channel stable
	flutter upgrade
	flutter pub get
	npm install

dependencies:
	pub get
	cd example && flutter pub get

analyze:
	analyze lib/ bin/

format:
	dartfmt -w lib/ bin/

build-runner:
	cd example && flutter packages pub run build_runner build --delete-conflicting-outputs cd ..

build:
	cd example && flutter build apk && cd ..

run-example:
	dart bin/flutter_gen_command.dart --config example/pubspec.yaml

unit-test:
	pub run test --coverage --coverage-path=./coverage/lcov.info
