import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/Database_url.dart' as mg;

class AnnounceEventPage extends StatefulWidget {
  @override
  _AnnounceEventPageState createState() => _AnnounceEventPageState();
}

class _AnnounceEventPageState extends State<AnnounceEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _celebrityController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  DateTime? _selectedDate;
  File? _image;
  LatLng? _selectedLocation;

  // Google Maps controller and initial position
  GoogleMapController? _mapController;
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.8880651, 35.5039614),
    zoom: 7,
  );

  // To handle map gesture recognition
  bool _isMapInteracting = false;

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Announce an Event"),
        backgroundColor: Colors.green[800],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          // Prevent page scrolling when map is being interacted with
          if (_isMapInteracting) {
            return true; // Stop the notification from bubbling up
          }
          return false;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_eventNameController, "Event Name"),
                  _buildTextField(_descriptionController, "Description"),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: _selectedDate == null
                              ? "Select Date"
                              : DateFormat.yMMMd().format(_selectedDate!),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(_celebrityController, "Celebrity in Attendance"),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text("Upload Image"),
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                    ),
                  ),
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(_image!, height: 100),
                    ),
                  _buildTextField(_ticketPriceController, "Ticket Price", isNumber: true),
                  SizedBox(height: 20),

                  // Google Maps Section with gesture handling
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Event Location",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 200,
                            child: Listener(
                              onPointerDown: (_) {
                                setState(() {
                                  _isMapInteracting = true;
                                });
                              },
                              onPointerUp: (_) {
                                setState(() {
                                  _isMapInteracting = false;
                                });
                              },
                              onPointerCancel: (_) {
                                setState(() {
                                  _isMapInteracting = false;
                                });
                              },
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: _initialPosition,
                                onTap: _onMapTap,
                                markers: _selectedLocation != null
                                    ? {
                                  Marker(
                                    markerId: MarkerId('selectedLocation'),
                                    position: _selectedLocation!,
                                  ),
                                }
                                    : {},
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                gestureRecognizers: <
                                    Factory<OneSequenceGestureRecognizer>>{
                                  Factory<OneSequenceGestureRecognizer>(
                                        () => EagerGestureRecognizer(),
                                  ),
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a location on the map')),
                          );
                          return;
                        }

                        var db = await mongo.Db.create(mg.mongo_url);
                        await db.open();
                        var collection = db.collection("Event");
                        await collection.insert({
                          'Event Name': _eventNameController.text,
                          'date': _selectedDate,
                          'price': _ticketPriceController.text,
                          'location': {
                            'latitude': _selectedLocation!.latitude,
                            'longitude': _selectedLocation!.longitude,
                          },
                          'description': _descriptionController.text,
                          'image': 1234, // You might want to handle the image properly
                          'celeb': _celebrityController.text,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Event announced successfully!')),
                        );
                      }
                    },
                    child: Text("Announce"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}