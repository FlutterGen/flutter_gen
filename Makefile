setup:
	npm install

dependencies:
	cd packages/core/ && dart pub get
	cd packages/runner/ && dart pub get
	cd packages/command && dart pub get
	cd example && flutter pub get && cd ..

analyze:
	dart analyze packages/core/lib/
	dart analyze packages/runner/lib/
	dart analyze packages/command/bin/

format:
	dart format packages/core/lib/
	dart format packages/runner/lib/
	dart format packages/command/bin/

build:
	cd example && flutter build apk && cd ..

generate-config-model:
	cd packages/core/ && dart run build_runner build && cd ..

generate-with-command:
	dart packages/command/bin/flutter_gen_command.dart --config example/pubspec.yaml

generate-with-runner:
	cd example && flutter pub run build_runner build --delete-conflicting-outputs && cd ..

unit-test:
	cd packages/core/ && dart run test && cd ..

coverage:
	./scripts/coverage.sh packages/core
	./scripts/codecov.sh ${CODECOV_TOKEN}
