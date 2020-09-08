setup:
	flutter channel stable
	flutter upgrade
	flutter pub get
	npm install

dependencies:
	pub get
	cd example && flutter pub get

analyze:
	dartanalyzer lib/ bin/

format:
	dartfmt -w lib/ bin/

build:
	cd example && flutter build apk && cd ..

generate-with-command:
	dart bin/flutter_gen_command.dart --config example/pubspec.yaml

generate-with-runner:
	cd example && flutter packages pub run build_runner build --delete-conflicting-outputs cd ..

unit-test:
	pub run test

coverage:
	pub run test_coverage --no-badge
	./scripts/codecov.sh ${CODECOV_TOKEN}

setup-ubuntu:
	sudo apt-get update
	sudo apt-get install apt-transport-https
	sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
	sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
	sudo apt-get update
	sudo apt-get install dart
	/usr/lib/dart/bin/pub get

setup-macos:
	brew tap dart-lang/dart
	brew install dart
	pub get