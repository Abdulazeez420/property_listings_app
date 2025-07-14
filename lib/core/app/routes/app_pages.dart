import 'package:get/get.dart';
import 'package:property_listing_app/core/app/bindings/camera_bindings.dart';
import 'package:property_listing_app/core/app/bindings/property_bindings.dart';
import 'package:property_listing_app/features/camera/presentation/views/camera_view.dart';
import 'package:property_listing_app/features/property/presentation/views/property_detail_view.dart';
import 'package:property_listing_app/features/property/presentation/views/property_list_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.propertyList;

  static final routes = [
    GetPage(
      name: Routes.propertyList,
      page: () => const PropertyListView(),
      binding: PropertyBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.propertyDetail,
      page: () =>  PropertyDetailView(property: Get.arguments,),
      binding: PropertyBindings(),
      transition: Transition.fadeIn,
    ),
     GetPage(
      name: Routes.cameraView,
      page: () => const CameraView(),
      binding: CameraBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}