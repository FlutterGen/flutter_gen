String colorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceFirst('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF' + hexColor;
  }
  return '0x$hexColor';
}
