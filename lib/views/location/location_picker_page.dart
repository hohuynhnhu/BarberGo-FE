import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../services/location_service.dart';

class LocationPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const LocationPickerPage({
    Key? key,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  }) : super(key: key);

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String _currentAddress = 'Đang tải địa chỉ...';
  bool _isLoading = true;
  bool _isLoadingAddress = false;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ==================== INITIALIZE LOCATION ====================

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Nếu có initial position, dùng nó
      if (widget.initialLat != null && widget.initialLng != null) {
        _currentPosition = LatLng(widget.initialLat!, widget.initialLng!);
        _currentAddress = widget.initialAddress ?? 'Đang tải địa chỉ...';

        _addMarker(_currentPosition!);

        // Get address if not provided
        if (widget.initialAddress == null) {
          _updateAddress(_currentPosition!);
        }
      } else {
        // Get current location
        Position? position = await LocationService.getCurrentLocation();

        if (position != null) {
          _currentPosition = LatLng(position.latitude, position.longitude);

          // Add marker
          _addMarker(_currentPosition!);

          // Get address
          await _updateAddress(_currentPosition!);

          // Move camera
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPosition!, 16),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Initialize location error: $e');

      setState(() {
        _isLoading = false;
        _currentAddress = 'Không thể lấy vị trí';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ==================== UPDATE ADDRESS ====================

  Future<void> _updateAddress(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = 'Đang tải địa chỉ...';
    });

    try {
      String address = await LocationService.getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _currentAddress = address;
        _isLoadingAddress = false;
      });

      // Update marker
      _addMarker(position);

    } catch (e) {
      print('❌ Get address error: $e');
      setState(() {
        _currentAddress = 'Không thể lấy địa chỉ';
        _isLoadingAddress = false;
      });
    }
  }

  // ==================== ADD MARKER ====================

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet, // ✅ Màu tím cho brand
          ),
          draggable: true,
          onDragEnd: (newPosition) {
            _onMarkerDrag(newPosition);
          },
        ),
      );
    });
  }

  // ==================== ON MAP CREATED ====================

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 16),
      );
    }
  }

  // ==================== ON TAP MAP ====================

  void _onTapMap(LatLng position) {
    print('🔵 Map tapped: ${position.latitude}, ${position.longitude}');

    setState(() {
      _currentPosition = position;
    });

    _addMarker(position);
    _updateAddress(position);
  }

  // ==================== ON MARKER DRAG ====================

  void _onMarkerDrag(LatLng position) {
    print('🔵 Marker dragged: ${position.latitude}, ${position.longitude}');

    setState(() {
      _currentPosition = position;
    });

    _updateAddress(position);
  }

  // ==================== GET MY LOCATION ====================

  Future<void> _getMyLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Position? position = await LocationService.getCurrentLocation();

      if (position != null) {
        final newPosition = LatLng(position.latitude, position.longitude);

        setState(() {
          _currentPosition = newPosition;
        });

        _addMarker(newPosition);
        _updateAddress(newPosition);

        // Animate camera
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16),
        );
      }

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== CONFIRM LOCATION ====================

  void _confirmLocation() {
    if (_currentPosition != null) {
      // Return location data
      context.pop({
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'address': _currentAddress,
      });
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B4B8A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chọn vị trí',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ==================== GOOGLE MAP ====================

          _currentPosition != null
              ? GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 16,
            ),
            markers: _markers,
            onTap: _onTapMap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Custom button below
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          )
              : Center(
            child: _isLoading
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF5B4B8A),
                ),
                SizedBox(height: 16),
                Text('Đang tải bản đồ...'),
              ],
            )
                : Text('Không thể tải bản đồ'),
          ),

          // ==================== ADDRESS CARD ====================

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF5B4B8A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Color(0xFF5B4B8A),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Địa chỉ đã chọn',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (_isLoadingAddress)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF5B4B8A),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      _currentAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    if (_currentPosition != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                              'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ==================== MY LOCATION BUTTON ====================

          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              onPressed: _getMyLocation,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: Color(0xFF5B4B8A),
              ),
            ),
          ),

          // ==================== CONFIRM BUTTON ====================

          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _currentPosition != null && !_isLoadingAddress
                  ? _confirmLocation
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B4B8A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'XÁC NHẬN VỊ TRÍ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================== LOADING OVERLAY ====================

          if (_isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF5B4B8A),
                        ),
                        SizedBox(height: 16),
                        Text('Đang lấy vị trí...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}