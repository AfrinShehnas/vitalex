import 'package:flutter/material.dart';
import 'dyslexia_testing_module.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  String selectedAge = '10';

  final Color bgColor = const Color(0xFFE6F2E6);
  final Color textColor = const Color(0xFF5C4033);
  final Color buttonColor = const Color(0xFFB5EAD7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: Text('Dyslexia Assessment', style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'Select your age:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: textColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: DropdownButton<String>(
                  value: selectedAge,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    '6','7','8','9','10','11','12',
                    '13','14','15','16','17','18+'
                  ].map((age) {
                    return DropdownMenuItem<String>(
                      value: age,
                      child: Text(
                        age == '18+' ? '18+ years old' : '$age years old',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedAge = value!);
                  },
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: textColor,
                  ),
                  onPressed: () {
  int userAge =
      selectedAge == '18+' ? 19 : int.parse(selectedAge);
  // 👆 Using 19 to differentiate from exact 18

  String ageGroup;

  if (userAge >= 6 && userAge <= 7) {
    ageGroup = "6-7";
  } else if (userAge >= 8 && userAge <= 9) {
    ageGroup = "8-9";
  } else if (userAge >= 10 && userAge <= 12) {
    ageGroup = "10-12";
  } else if (userAge >= 13 && userAge <= 15) {
    ageGroup = "13-15";
  } else if (userAge >= 16 && userAge <= 18) {
    ageGroup = "16-18";
  } else {
    ageGroup = "18+";
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DyslexiaTestingModule(
        userAge: userAge,
        ageGroup: ageGroup,
      ),
    ),
  );
},
                  child: const Text(
                    'Start Assessment',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}