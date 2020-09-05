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

build-runner:
	cd example && flutter packages pub run build_runner build --delete-conflicting-outputs cd ..

build:
	cd example && flutter build apk && cd ..

run-example:
	dart bin/flutter_gen_command.dart --config example/pubspec.yaml

unit-test:
	pub run test --coverage --coverage-path=./coverage/lcov.info

setup-ubuntu:
	sudo apt-get update
	sudo apt-get install apt-transport-https
	sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
	sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
	sudo apt-get update
	sudo apt-get install dart
	echo 'export PATH="$PATH:/usr/lib/dart/bin"' >> ~/.profile
	source ~/.profile
	pub get

setup-macos:
	brew tap dart-lang/dart
	brew install dart
	pub get
