class OptionItem {
  OptionItem({required this.value, required String? label})
    : this.label = label ?? value;

  final String value;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is OptionItem && this.value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
