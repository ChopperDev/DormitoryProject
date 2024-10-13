import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http for sending data
import 'dart:convert'; // For JSON encoding/decoding
import 'room_show.dart'; // Import RoomListView from room_show.dart

class RoomDetail extends StatefulWidget {
  final String roomNumber;
  final double previousElectricity;
  final double currentElectricity;
  final double waterFee;
  final double wifiFee;
  final double commonFee;

  RoomDetail({
    required this.roomNumber,
    required this.previousElectricity,
    required this.currentElectricity,
    required this.waterFee,
    required this.wifiFee,
    required this.commonFee,
  });

  @override
  _RoomDetailState createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  late TextEditingController previousElectricityController;
  late TextEditingController currentElectricityController;
  late TextEditingController waterController;
  late TextEditingController wifiController;
  late TextEditingController commonFeeController;

  @override
  void initState() {
    super.initState();
    previousElectricityController =
        TextEditingController(text: widget.previousElectricity.toString());
    currentElectricityController =
        TextEditingController(text: widget.currentElectricity.toString());
    waterController = TextEditingController(text: widget.waterFee.toString());
    wifiController = TextEditingController(text: widget.wifiFee.toString());
    commonFeeController =
        TextEditingController(text: widget.commonFee.toString());
  }

  // Function to calculate electricity fee
  double calculateElectricityFee() {
    double previousElectricity =
        double.tryParse(previousElectricityController.text) ?? 0.0;
    double currentElectricity =
        double.tryParse(currentElectricityController.text) ?? 0.0;
    double electricityUsed = currentElectricity - previousElectricity;
    return electricityUsed * 8; // Calculate electricity fee
  }

  // Function to update and send data to SQL
  Future<void> updateRoom() async {
    double updatedWaterFee =
        double.tryParse(waterController.text) ?? widget.waterFee;
    double updatedWifiFee =
        double.tryParse(wifiController.text) ?? widget.wifiFee;
    double updatedCommonFee =
        double.tryParse(commonFeeController.text) ?? widget.commonFee;

    double electricityFee = calculateElectricityFee();
    double totalAmount =
        electricityFee + updatedWaterFee + updatedWifiFee + updatedCommonFee;

    try {
      final response = await http.post(
        Uri.parse(
            'http://172.20.10.5/api/home.php'), // Replace with your server IP
        body: {
          'room_number': widget.roomNumber,
          'previous_electricity_unit': previousElectricityController.text,
          'current_electricity_unit': currentElectricityController.text,
          'electricity_fee': electricityFee.toString(),
          'water_fee': updatedWaterFee.toString(),
          'wifi_fee': updatedWifiFee.toString(),
          'common_fee': updatedCommonFee.toString(),
          'total_amount': totalAmount.toString(),
        },
      );

      // Check the response status and show Snackbar accordingly
      if (response.statusCode == 200) {
        print('Data saved successfully: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Failed to save data: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save data: ${response.body}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions that occur during the API call
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    previousElectricityController.dispose();
    currentElectricityController.dispose();
    waterController.dispose();
    wifiController.dispose();
    commonFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บิลค่าใช้จ่าย ห้องที่${widget.roomNumber}  (อย่าลืมกรอกเลขห้อง!!)'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 25),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            _buildTextField(
                previousElectricityController, 'ค่าหน่วยไฟรอบก่อน'),
            _buildTextField(
                currentElectricityController, 'ค่าหน่วยไฟรอบปัจจุบัน'),
            _buildTextField(waterController, 'ค่าน้ำ'),
            _buildTextField(wifiController, 'ค่า WIFI'),
            _buildTextField(commonFeeController, 'ค่าส่วนกลาง'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                updateRoom(); // เรียกใช้ฟังก์ชันบันทึกข้อมูล
              },
              child: Text(
                'บันทึกข้อมูล',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: RoomListView(), // เรียกใช้ RoomListView จาก room_show.dart
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
