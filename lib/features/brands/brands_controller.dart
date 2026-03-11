import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../data/local/shades_loader.dart';
import '../../data/models/brand_model.dart';

class BrandsController extends GetxController {
  final brands = <BrandModel>[].obs;
  final selectedBrands = <String>{}.obs; // brand ids
  final selectedShades = <String>{}.obs; // shade ids
  final expandedBrand = RxnString(); // currently expanded brand id
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    brands.value = await ShadesLoader.load();
    isLoading.value = false;
  }

  void toggleBrand(String brandId) {
    if (selectedBrands.contains(brandId)) {
      selectedBrands.remove(brandId);
      // Deselect all shades of this brand
      final b = brands.firstWhere((b) => b.id == brandId);
      for (final s in b.shades) selectedShades.remove(s.id);
      if (expandedBrand.value == brandId) expandedBrand.value = null;
    } else {
      selectedBrands.add(brandId);
      expandedBrand.value = brandId; // auto-expand on select
    }
  }

  void toggleExpanded(String brandId) {
    expandedBrand.value = expandedBrand.value == brandId ? null : brandId;
  }

  void toggleShade(String shadeId) {
    if (selectedShades.contains(shadeId)) {
      selectedShades.remove(shadeId);
    } else {
      selectedShades.add(shadeId);
    }
  }

  int selectedShadeCountFor(String brandId) {
    final b = brands.firstWhere((b) => b.id == brandId);
    return b.shades.where((s) => selectedShades.contains(s.id)).length;
  }

  void proceed() {
    if (selectedBrands.isEmpty) {
      Get.snackbar(
        'Select a brand',
        'Pick at least one brand to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedShades.isEmpty) {
      Get.snackbar(
        'Select shades',
        'Pick at least one shade to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(AppRoutes.results);
  }
}
