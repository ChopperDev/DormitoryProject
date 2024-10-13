import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// โมเดลสำหรับข้อมูลห้องพัก
class Room {
  final int id;
  final String roomNumber;
  final double previousElectricity;
  final double currentElectricity;
  final double waterFee;
  final double wifiFee;
  final double commonFee;

  Room({
    required this.id,
    required this.roomNumber,
    required this.previousElectricity,
    required this.currentElectricity,
    required this.waterFee,
    required this.wifiFee,
    required this.commonFee,
  });

  // คำนวณค่าห้องทั้งหมด
  double get totalAmount {
    double electricityFee = (currentElectricity - previousElectricity) * 8;
    return electricityFee + waterFee + wifiFee + commonFee;
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: int.parse(json['id']),
      roomNumber: json['room_number'],
      previousElectricity: double.parse(json['previous_electricity_unit']),
      currentElectricity: double.parse(json['current_electricity_unit']),
      waterFee: double.parse(json['water_fee']),
      wifiFee: double.parse(json['wifi_fee']),
      commonFee: double.parse(json['common_fee']),
    );
  }
}

// ฟังก์ชันเพื่อดึงข้อมูลห้องพักจาก API
Future<List<Room>> fetchRooms() async {
  final response =
      await http.get(Uri.parse('http://172.20.10.5/api/get_rooms.php'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    List<Room> rooms = jsonResponse.map((room) => Room.fromJson(room)).toList();

    // เรียงห้องตามหมายเลขห้องจากน้อยไปมาก
    rooms.sort(
        (a, b) => int.parse(a.roomNumber).compareTo(int.parse(b.roomNumber)));

    return rooms;
  } else {
    throw Exception('Failed to load rooms');
  }
}

// ฟังก์ชันสำหรับลบห้อง
Future<void> deleteRoom(int id) async {
  final response = await http
      .delete(Uri.parse('http://172.20.10.5/api/delete_room.php?id=$id'));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete room');
  }
}

// วิดเจ็ตแสดงรายการห้องพัก
class RoomListView extends StatefulWidget {
  @override
  _RoomListViewState createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> {
  late Future<List<Room>> futureRooms;
  String selectedCategory = 'ทั้งหมด'; // ตัวแปรสำหรับเก็บหมวดหมู่ที่เลือก

  @override
  void initState() {
    super.initState();
    futureRooms = fetchRooms();
  }

  // ฟังก์ชันกรองห้องตามหมวดหมู่
  List<Room> filterRooms(List<Room> rooms) {
    if (selectedCategory == 'มิเตอร์') {
      return rooms.where((room) => int.parse(room.roomNumber) <= 99).toList();
    } else if (selectedCategory == 'ห้องพัก') {
      return rooms.where((room) => int.parse(room.roomNumber) >= 100).toList();
    }
    return rooms; // คืนค่าทั้งหมดถ้าเลือก "ทั้งหมด"
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
            },
            items: <String>['ทั้งหมด', 'มิเตอร์', 'ห้องพัก']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0), // เพิ่ม padding ที่นี่
                  child: Text(
                    value,
                    style: TextStyle(
                        fontSize:
                            16), // คุณสามารถปรับแต่งขนาดของข้อความได้ที่นี่
                  ),
                ),
              );
            }).toList(),
            underline: Container(), // ยกเลิกการแสดงผลของเส้นใต้
            dropdownColor: Colors.white, // สีพื้นหลังของ Dropdown
            style: TextStyle(
                color: Colors.black,
                fontSize: 16), // สีและขนาดของข้อความใน Dropdown
            icon: Icon(Icons.arrow_drop_down, color: Colors.black), // ไอคอน
            iconSize: 24, // ขนาดของไอคอน
            elevation: 16, // ระดับเงา
            borderRadius: BorderRadius.circular(8), // ขอบมน
          ),
          Expanded(
            child: FutureBuilder<List<Room>>(
              future: futureRooms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Room> rooms = snapshot.data!;
                  List<Room> filteredRooms = filterRooms(rooms); // กรองห้อง
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'ห้องพัก: ${filteredRooms[index].roomNumber}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoomDetailsScreen(
                                    room: filteredRooms[index]),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditRoomScreen(
                                          room: filteredRooms[index]),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('ยืนยันการลบ'),
                                        content: Text(
                                            'คุณแน่ใจว่าต้องการลบห้อง ${filteredRooms[index].roomNumber}?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('ยกเลิก'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('ยืนยัน'),
                                            onPressed: () {
                                              deleteRoom(
                                                      filteredRooms[index].id)
                                                  .then((_) {
                                                setState(() {
                                                  futureRooms =
                                                      fetchRooms(); // อัปเดตรายการห้อง
                                                });
                                                Navigator.of(context).pop();
                                              }).catchError((error) {
                                                print(
                                                    'Error deleting room: $error');
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
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
        ],
      ),
    );
  }
}

// หน้ารายละเอียดของห้องพัก
class RoomDetailsScreen extends StatelessWidget {
  final Room room;

  RoomDetailsScreen({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'บิลค่าใช้จ่าย ห้อง ${room.roomNumber}',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        // Added padding to body
        padding: const EdgeInsets.all(30.0), // Adjust padding around the Card
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: double.infinity, // Ensures the container takes full width
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายละเอียด ดังนี้',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'ค่าไฟหน่วยละ 8 บาท',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ค่าหน่วยไฟรอบก่อน: ${room.previousElectricity} หน่วย',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ค่าหน่วยไฟรอบปัจจุบัน: ${room.currentElectricity} หน่วย',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ค่าไฟ: ${((room.currentElectricity - room.previousElectricity) * 8).toStringAsFixed(2)} บาท',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ค่าประปา: ${room.waterFee.toStringAsFixed(2)} บาท',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ค่า Wifi: ${room.wifiFee.toStringAsFixed(2)} บาท',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ค่าบริการส่วนกลาง: ${room.commonFee.toStringAsFixed(2)} บาท',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Text(
                    'รวมเป็นเงินทั้งหมด: ${room.totalAmount.toStringAsFixed(2)} บาท',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// หน้าจอสำหรับแก้ไขข้อมูลห้องพัก
class EditRoomScreen extends StatelessWidget {
  final Room room;

  EditRoomScreen({required this.room});

  final TextEditingController roomNumberController = TextEditingController();
  final TextEditingController previousElectricityController =
      TextEditingController();
  final TextEditingController currentElectricityController =
      TextEditingController();
  final TextEditingController waterFeeController = TextEditingController();
  final TextEditingController wifiFeeController = TextEditingController();
  final TextEditingController commonFeeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // กำหนดค่าตั้งต้นสำหรับ controller
    roomNumberController.text = room.roomNumber;
    previousElectricityController.text = room.previousElectricity.toString();
    currentElectricityController.text = room.currentElectricity.toString();
    waterFeeController.text = room.waterFee.toString();
    wifiFeeController.text = room.wifiFee.toString();
    commonFeeController.text = room.commonFee.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขข้อมูล ห้องที่ ${room.roomNumber}'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: roomNumberController,
              decoration: InputDecoration(
                labelText: 'หมายเลขห้อง',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: previousElectricityController,
              decoration: InputDecoration(
                labelText: 'ค่าหน่วยไฟรอบก่อน',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: currentElectricityController,
              decoration: InputDecoration(
                labelText: 'ค่าหน่วยไฟรอบปัจจุบัน',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: waterFeeController,
              decoration: InputDecoration(
                labelText: 'ค่าน้ำ',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: wifiFeeController,
              decoration: InputDecoration(
                labelText: 'ค่า WIFI',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: commonFeeController,
              decoration: InputDecoration(
                labelText: 'ค่าส่วนกลาง',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateRoom(context);
              },
              child: Text('บันทึก'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ยืนยันการรีเซ็ต'),
                      content: Text(
                          'คุณแน่ใจว่าต้องการรีเซ็ตค่าใช้จ่ายทั้งหมดเป็น 0 หรือไม่?'),
                      actions: [
                        TextButton(
                          child: Text('ยกเลิก'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('ยืนยัน'),
                          onPressed: () {
                            roomNumberController.text = room.roomNumber;
                            previousElectricityController.text = '0';
                            currentElectricityController.text = '0';
                            waterFeeController.text = '0';
                            wifiFeeController.text = '0';
                            commonFeeController.text = '0';

                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              // style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('รีเซ็ตค่าใช้จ่าย'),
            ),
          ],
        ),
      ),
    );
  }

  void updateRoom(BuildContext context) async {
    double previousElectricity =
        double.parse(previousElectricityController.text);
    double currentElectricity = double.parse(currentElectricityController.text);
    double electricityFee = (currentElectricity - previousElectricity) * 8;

    final response = await http.put(
      Uri.parse('http://172.20.10.5/api/update_room.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'id': room.id,
        'room_number': roomNumberController.text,
        'previous_electricity': previousElectricity,
        'current_electricity': currentElectricity,
        'water_fee': double.parse(waterFeeController.text),
        'wifi_fee': double.parse(wifiFeeController.text),
        'common_fee': double.parse(commonFeeController.text),
        'electricity_fee': electricityFee,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('แก้ไขเรียบร้อยแล้ว!')),
      );
      Navigator.pop(context);
    } else {
      print('Error updating room: ${response.body}');
    }
  }
}
