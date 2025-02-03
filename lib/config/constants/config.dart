// config.dart

class Config {
  static List<String> _companies = [];
  static List<String> _products = [];

  static void setCompanies(final companies) {
    _companies = companies;
  }

  static List<String> getCompanies() {
    return _companies;
  }

  static void setProducts(final products) {
    _products = products;
  }

  static List<String> getProducts() {
    return _products;
  }
}
