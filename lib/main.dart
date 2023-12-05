import 'package:flutter/material.dart';
import 'package:labtest/sqlite_db.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _bmi = 0.0;
  String _bmiStatus = '';
  String _selectedGender = 'male';

  @override
  void initState() {
    super.initState();
    lastData();
  }

  Future<void> lastData() async {
    try {
      List<Map<String, dynamic>> result = await SQLiteDB().queryAll('bmi');
      if (result.isNotEmpty) {

        Map<String, dynamic> lastData = result.last;

        setState(() {
          _nameController.text = lastData['username'] ?? '';
          _heightController.text = lastData['height'].toString() ?? '';
          _weightController.text = lastData['weight'].toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _calculateBMI() {
    double height = double.parse(_heightController.text);
    double weight = double.parse(_weightController.text);

    setState(() {
      if (_selectedGender == 'male') {
        _bmi = weight / (height * height / 1000) * 10;
        if (_bmi < 18.5) {
          _bmiStatus = 'Underweight. Careful during strong wind!';
        } else if (_bmi >= 18.6 && _bmi <= 24.9) {
          _bmiStatus = 'That ideal! Please maintain';
        } else if (_bmi >= 25 && _bmi <= 29.9) {
          _bmiStatus = 'Overweight! Work out please';
        } else {
          _bmiStatus = 'Whoa Obese! Dangerous mate!';
        }
      }
      else if (_selectedGender == 'female'){
        _bmi = weight / (height * height / 1000) * 10;
        if (_bmi < 16) {
          _bmiStatus = 'Underweight. Careful during strong wind!';
        } else

        if (_bmi >= 17 && _bmi <= 22) {
          _bmiStatus = 'That ideal! Please maintain';
        } else

        if (_bmi >= 23 && _bmi <= 27) {
          _bmiStatus = 'Overweight! Work out please';
        } else {
          _bmiStatus = 'Whoa Obese! Dangerous mate!';
        }
      }
      Map<String, dynamic> insertData = {
        'username': _nameController.text,
        'weight': double.parse(_weightController.text),
        'height': double.parse(_heightController.text),
        'gender': _selectedGender,
        'bmi_status': _bmiStatus,
      };
      SQLiteDB().insert('bmi', insertData);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text('BMI Calculator',
          style: TextStyle(fontWeight: FontWeight.bold)),),
        backgroundColor: Colors.blue,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Fullname',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height in (cm)',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight in (kg)',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'male',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                Text('Male'),
                SizedBox(width: 20.0),
                Radio<String>(
                  value: 'female',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _calculateBMI,
              child: Text('Calculate BMI and Save'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Your BMI is: ${_bmi.toStringAsFixed(1)} $_bmiStatus',
              style: TextStyle(fontSize: 24.0),
            ),
          ],
        ),
      ),
    );
  }
}