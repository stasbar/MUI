class Migrations {
  static dynamic migrate(dynamic object) {
    final migrations = [from1To2];
    return migrations.fold(object, (total, element) => element(total));
  }

  static dynamic from1To2(dynamic potentiallyDeprecated) {
    potentiallyDeprecated['width'] =
    potentiallyDeprecated['width'] == null ? 0 : potentiallyDeprecated['width'];
    potentiallyDeprecated['height'] =
    potentiallyDeprecated['height'] == null ? 0 : potentiallyDeprecated['height'];
    potentiallyDeprecated['length'] =
    potentiallyDeprecated['length'] == null ? 0 : potentiallyDeprecated['length'];
    return potentiallyDeprecated;
  }
}
