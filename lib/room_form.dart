import 'package:flutter/material.dart';
import './room_detail.dart'; // นำเข้า RoomDetail

class RoomForm extends StatefulWidget {
  @override
  _RoomFormState createState() => _RoomFormState();
}

class _RoomFormState extends State<RoomForm> {
  final TextEditingController roomNumberController = TextEditingController();
  final TextEditingController previousElectricityController =
      TextEditingController();
  final TextEditingController currentElectricityController =
      TextEditingController();
  final TextEditingController waterController = TextEditingController();
  final TextEditingController wifiController = TextEditingController();
  final TextEditingController commonFeeController = TextEditingController();

  void _goToRoomDetail() {
    String roomNumber = roomNumberController.text;
    double previousElectricity =
        double.tryParse(previousElectricityController.text) ?? 0.0;
    double currentElectricity =
        double.tryParse(currentElectricityController.text) ?? 0.0;
    double waterFee = double.tryParse(waterController.text) ?? 50.0;
    double wifiFee = double.tryParse(wifiController.text) ?? 50.0;
    double commonFee = double.tryParse(commonFeeController.text) ?? 0.0;

    // ไปยังหน้ารายละเอียดห้องและส่งข้อมูล
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetail(
          roomNumber: roomNumber,
          previousElectricity: previousElectricity,
          currentElectricity: currentElectricity,
          waterFee: waterFee,
          wifiFee: wifiFee,
          commonFee: commonFee,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('กรอกข้อมูลห้อง'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 25),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField(roomNumberController, 'หมายเลขห้อง'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToRoomDetail,
              child: Center(
                // ใช้ Center เพื่อให้ข้อความอยู่ตรงกลาง
                child: Text(
                  'บันทึกข้อมูล และไปยังรายละเอียด',
                  style: TextStyle(color: Colors.white, fontSize: 23),
                  textAlign: TextAlign
                      .center, // ทำให้ข้อความอยู่ตรงกลางภายใน Text widget
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
          labelStyle: TextStyle(color: Colors.black, fontSize: 16),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
