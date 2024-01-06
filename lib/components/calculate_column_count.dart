int calculateColumnCount(double viewportWidth) {
  int columnCount = 1; // Default column count for small screens
  if (viewportWidth > 550) {
    columnCount = 2;
  }
  if (viewportWidth > 900) {
    columnCount = 3;
  }
  if (viewportWidth > 1240) {
    columnCount = 4;
  }
  if (viewportWidth > 1600) {
    columnCount = 5;
  }
  // Add more conditions as needed
  return columnCount;
}