const configDefaultYamlContent = '''
name: UNKNOWN

flutter_gen:
  output: lib/gen/ # Optional
#  line_length: 80 # Optional
  parse_metadata: false # Optional

  # Optional
  integrations:
    image: true
    flutter_svg: false
    rive: false
    lottie: false
  
  images:
    # Optional
    parse_animation: false

  assets:
    enabled: true # Optional
    outputs: # Optional
      # Set to true if you want this package to be a package dependency
      # See: https://flutter.dev/docs/development/ui/assets-and-images#from-packages
      package_parameter_enabled: false # Optional
      # Available values:
      # - camel-case
      # - snake-case
      # - dot-delimiter
      style: dot-delimiter # Optional
      class_name: Assets
    exclude: []

  fonts:
    enabled: true # Optional
    outputs: # Optional
      class_name: FontFamily

  colors:
    enabled: true # Optional
    inputs: [] # Optional
    outputs: # Optional
      class_name: ColorName

flutter:
  # See: https://flutter.dev/docs/development/ui/assets-and-images#specifying-assets
  assets: []
  # See: https://flutter.dev/docs/cookbook/design/fonts#2-declare-the-font-in-the-pubspec
  fonts: []
''';
