/// Regex that allows Unicode letters (including French accented characters like
/// é, è, ê, à, â, ç, ï, î, etc.), spaces, apostrophes, and hyphens for names.
/// Examples: François, José, Anne-Marie, O'Connor.
final RegExp validNamePattern = RegExp(r"^[\p{L}\p{M}\s'\-]+$", unicode: true);
