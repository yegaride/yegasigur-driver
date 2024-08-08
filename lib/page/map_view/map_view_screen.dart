import 'package:cabme_driver/constant/constant.dart';
import 'package:cabme_driver/controller/dash_board_controller.dart';
import 'package:cabme_driver/controller/map_view_controller.dart';
import 'package:cabme_driver/routes/routes.dart';
import 'package:cabme_driver/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  // final mapViewController = Get.put(MapViewController());
  final dashboardController = Get.put(DashBoardController());

  late final GoogleMapController _mapController;
  final Location currentLocation = Location();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetX<MapViewController>(
        init: MapViewController(),
        builder: (mapViewController) {
          return Scaffold(
            backgroundColor: ConstantColors.background,
            body: Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  compassEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target:
                        LatLng(Constant.currentLocation?.latitude ?? 12.516667, Constant.currentLocation?.longitude ?? -69.95),
                    zoom: 14.0,
                  ),
                  minMaxZoomPreference: const MinMaxZoomPreference(8.0, 20.0),
                  buildingsEnabled: false,
                  onMapCreated: (GoogleMapController controller) async {
                    _mapController = controller;

                    LocationData location = await currentLocation.getLocation();

                    _mapController.moveCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          location.latitude ?? 0.0,
                          location.longitude ?? 0.0,
                        ),
                        14,
                      ),
                    );
                  },
                  myLocationEnabled: true,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: ElevatedButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            "assets/icons/ic_side_menu.png",
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 45,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 38),
                          ),
                          onPressed: () {
                            dashboardController.onRouteSelected(Routes.availableJobs);
                          },
                          child: Text(
                            // TODO i18n
                            'available jobs'.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          dashboardController.onRouteSelected(Routes.availableJobs);
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            color: Colors.black,
                          ),
                          child: Center(
                            child: mapViewController.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
                                  )
                                : Text(
                                    mapViewController.availableJobs.value,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
