import 'package:flutter/material.dart';

void main() {
  runApp(const LoadGoPartnerApp());
}

class LoadGoPartnerApp extends StatelessWidget {
  const LoadGoPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LoadGo Partner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isGoHomeActive = false;
  int remainingPassDays = 28;

  // Real-time Fare & Weight Validation Logic
  Map<String, dynamic> calculateFareAndValidity({
    required double weightInKg,
    required double distanceInKm,
    required double pickupDistanceInKm,
  }) {
    // Condition 1: Above 30kg -> Auto Vehicle Upgrade Required (Blocked for 2-Wheeler)
    if (weightInKg > 30.0) {
      return {
        'isValid': false,
        'message': 'वजन 30 किग्रा से अधिक है। बाइक राइड ब्लॉक है। कृपया कस्टमर को 3-व्हीलर अपग्रेड के लिए कहें।',
        'totalFare': 0.0,
      };
    }

    double baseFare = 40.0;
    double distanceFare = distanceInKm * 12.0; // ₹12/km
    double extraWeightCharge = 0.0;
    double pickupBonus = 0.0;

    // Condition 2: 20kg to 30kg -> Add ₹3 per extra kg
    if (weightInKg > 20.0) {
      extraWeightCharge = (weightInKg - 20.0) * 3.0;
    }

    // Condition 3: Pickup distance > 2km -> Extra Compensation
    if (pickupDistanceInKm > 2.0) {
      pickupBonus = 10.0;
    }

    double finalFare = baseFare + distanceFare + extraWeightCharge + pickupBonus;

    return {
      'isValid': true,
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'extraWeightCharge': extraWeightCharge,
      'pickupBonus': pickupBonus,
      'totalFare': finalFare,
    };
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AI Photo & Weight Verification'),
          content: const Text(
            'सामान की फोटो AI Vision द्वारा चेक की जा रही है...\n\n'
            'यदि वजन 30 किग्रा से अधिक या साइज़ बड़ा पाया गया, तो सिस्टम ऑर्डर अपने आप कैंसिल कर देगा या कस्टमर की सहमति से किराया अपडेट करेगा।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('बंद करें'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ऑर्डर कैंसिल कर दिया गया है। पिकअप मुआवजा जोड़ दिया गया है।')),
                );
              },
              child: const Text('कैंसिल की पुष्टि करें'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // टेस्ट सिनेरियो पैरामीटर्स (26 किग्रा पार्सल, 10 किमी राइड, 3.5 किमी पिकअप)
    double currentWeight = 26.0;
    double tripDistance = 10.0;
    double pickupDist = 3.5;

    var fareData = calculateFareAndValidity(
      weightInKg: currentWeight,
      distanceInKm: tripDistance,
      pickupDistanceInKm: pickupDist,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('LoadGo Partner'),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Subscription Pass Info
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.green[50],
              child: ListTile(
                leading: const Icon(Icons.verified, color: Colors.green, size: 36),
                title: const Text('0% कमीशन प्लान एक्टिव', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$remainingPassDays दिन बाकी हैं | असीमित राइड्स'),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Go-Home Mode Toggle
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text('Go-Home मोड', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('अपने घर के रास्ते के ऑर्डर प्राप्त करें'),
                value: isGoHomeActive,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() {
                    isGoHomeActive = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            const Text('उपलब्ध ऑर्डर (Available Dispatch)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 3. Order Card Logic
            if (!fareData['isValid'])
              Card(
                color: Colors.red[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    fareData['message'],
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('बाइक राइड रिक्वेस्ट', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Text('दूरी: ${tripDistance.toStringAsFixed(0)} किमी', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('• पिकअप: सदर बाज़ार ($pickupDist किमी दूर)'),
                      if (fareData['pickupBonus'] > 0)
                        const Text('  └ पिकअप मुआवजा: +₹10 जोड़ा गया (>2km)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('• पार्सल वजन: ${currentWeight.toStringAsFixed(0)} किग्रा'),
                      if (fareData['extraWeightCharge'] > 0)
                        Text('  └ अतिरिक्त वजन शुल्क (₹3/kg): +₹${fareData['extraWeightCharge'].toStringAsFixed(0)} जोड़ा गया',
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ड्राइवर की कुल कमाई:', style: TextStyle(fontSize: 15)),
                          Text(
                            '₹${fareData['totalFare'].toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('राइड स्वीकार की गई! पिकअप लोकेशन पर जाएँ...')),
                                );
                              },
                              child: const Text('राइड स्वीकार करें', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _showReportDialog(context),
                            child: const Text('ओवरवेट रिपोर्ट करें'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
