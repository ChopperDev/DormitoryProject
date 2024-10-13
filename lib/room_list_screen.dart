import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // สำหรับเปิดลิงก์

class Room {
  final String roomNumber;
  final String previousElectricityUnit;
  final String currentElectricityUnit;
  final String electricityFee;
  final String waterFee; // เพิ่มค่าน้ำ
  final String wifiFee;
  final String commonFee;
  final String totalAmount;

  Room({
    required this.roomNumber,
    required this.previousElectricityUnit,
    required this.currentElectricityUnit,
    required this.electricityFee,
    required this.waterFee, // เพิ่มค่าน้ำ
    required this.wifiFee,
    required this.commonFee,
    required this.totalAmount,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomNumber: json['room_number'],
      previousElectricityUnit: json['previous_electricity_unit'],
      currentElectricityUnit: json['current_electricity_unit'],
      electricityFee: json['electricity_fee'],
      waterFee: json['water_fee'], // เพิ่มค่าน้ำ
      wifiFee: json['wifi_fee'],
      commonFee: json['common_fee'],
      totalAmount: json['total_amount'],
    );
  }
}

class RoomListScreen extends StatefulWidget {
  final String username;

  RoomListScreen({required this.username});

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late Future<List<Room>> futureRooms;

  @override
  void initState() {
    super.initState();
    futureRooms = fetchRooms();
  }

  Future<List<Room>> fetchRooms() async {
    final response =
        await http.get(Uri.parse('http://172.20.10.5/api/get_rooms.php'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((room) => Room.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  // ฟังก์ชันเปิดลิงก์
  void _launchURL() async {
    const url =
        'https://line.me/R/ti/p/~chopper_31'; // แทนที่ด้วยลิงก์ที่ต้องการ
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // ฟังก์ชันสำหรับปุ่มรีเฟรช
  void _refreshData() {
    setState(() {
      futureRooms = fetchRooms(); // รีเฟรชข้อมูลโดยการดึงข้อมูลใหม่
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'บิลค่าใช้จ่าย ห้องที่ ${widget.username}',
          style:
              TextStyle(color: Colors.white, fontSize: 25), // เพิ่มขนาดตัวอักษร
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white), // เปลี่ยนสีปุ่มรีเฟรชเป็นสีขาว
          onPressed: () {
            setState(() {
              futureRooms = fetchRooms(); // เรียกใช้งาน fetchRooms ใหม่
            });
          },
        ),
      ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0), // เพิ่ม padding
            child: FutureBuilder<List<Room>>(
              future: futureRooms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // กรองเฉพาะห้องที่ตรงกับ username
                  List<Room> rooms = snapshot.data!
                      .where((room) => room.roomNumber == widget.username)
                      .toList();

                  if (rooms.isEmpty) {
                    return Center(
                      child: Container(
                        padding:
                            EdgeInsets.all(16.0), // Padding around the text
                        decoration: BoxDecoration(
                          color: Colors.red[100], // Light red background color
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded corners
                          border: Border.all(
                              color: Colors.red, width: 2), // Red border
                        ),
                        child: Text(
                          'ยังไม่มีข้อมูลสำหรับ ห้อง ${widget.username}',
                          style: TextStyle(
                            fontSize: 22, // Increased font size
                            fontWeight: FontWeight.bold, // Bold font
                            color: Colors.red[800], // Darker red text color
                          ),
                          textAlign: TextAlign.center, // Center align the text
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      Room room = rooms[index];
                      return Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(
                              30.0), // เพิ่ม padding ภายในการ์ด
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'รายละเอียดดังนี้',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.bold), // เพิ่มขนาดตัวอักษร
                              ),
                              SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0), // เพิ่ม padding ด้านล่าง
                                child: Text(
                                    'หน่วยไฟฟ้าก่อนหน้า: ${room.previousElectricityUnit}',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0), // เพิ่ม padding ด้านล่าง
                                child: Text(
                                    'หน่วยไฟฟ้าปัจจุบัน: ${room.currentElectricityUnit}',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0), // เพิ่ม padding ด้านล่าง
                                child: Text(
                                    'ค่าไฟฟ้า: ${room.electricityFee} บาท',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0), // เพิ่ม padding ด้านล่าง
                                child: Text('ค่าน้ำ: ${room.waterFee} บาท',
                                    style:
                                        TextStyle(fontSize: 18)), // เพิ่มค่าน้ำ
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0), // เพิ่ม padding ด้านล่าง
                                child: Text('ค่า Wi-Fi: ${room.wifiFee} บาท',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0), // เพิ่ม padding ด้านล่าง
                                child: Text(
                                    'ค่าส่วนกลาง: ${room.commonFee} บาท',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0), // เพิ่ม padding ด้านล่าง
                                child: Text(
                                    'ยอดรวมทั้งหมด: ${room.totalAmount} บาท',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: MouseRegion(
              cursor: SystemMouseCursors
                  .click, // เปลี่ยนเคอร์เซอร์เมื่อเมาส์อยู่เหนือโลโก้
              child: GestureDetector(
                onTap: _launchURL, // คลิกเพื่อเปิดลิงก์
                child: Image.asset(
                  'assets/line_logo.png', // แน่ใจว่าเส้นทางไฟล์ถูกต้อง
                  width: 60, // ปรับขนาดตามต้องการ
                  height: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 