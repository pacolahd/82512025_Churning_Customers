import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: ChurnPrediction(),
  ));
}

class ChurnPrediction extends StatefulWidget {
  const ChurnPrediction({Key? key}) : super(key: key);

  @override
  _ChurnPredictionState createState() => _ChurnPredictionState();
}

class _ChurnPredictionState extends State<ChurnPrediction> {
  // List of actual categorical feature names for the model
  List<String> actualCategoricalFeatureNames = [
    'PaymentMethod_Electronic check',
    'SeniorCitizen_Yes',
    'Contract_Month-to-month',
    'Contract_Two year',
    'InternetService_Fiber optic',
    'InternetService_No',
    'OnlineSecurity_No',
    'OnlineBackup_No',
    'DeviceProtection_No',
    'TechSupport_No'
  ];

  // Define the numeric features
  List<String> numericFeatures = ['Tenure', 'Monthly Charges', 'Total Charges'];

  // Define categorical features and their options
  Map<String, List<String>> categoricalFeatures = {
    'Payment Method': ["Electronic Check", "Other"],
    'Senior Citizen': ["Yes", "No"],
    'Contract': ["Monthly", "Two Years", "Other"],
    'Internet Service': ["Optical Fiber", "No Internet Service", "Other"],
    'Online Security': ["Yes", "No"],
    'Online Backup': ["Yes", "No"],
    'Device Protection': ["Yes", "No"],
    'Tech Support': ["Yes", "No"]
  };

  // Controllers for text fields
  Map<String, TextEditingController> numericControllers = {};
  // Map to store the selected values for categorical features
  Map<String, String> selectedCategoricalValues = {};

  // Variables to store prediction and accuracy
  int? prediction;
  double? accuracy;

  // Variable to track if an error occurred
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for numeric features
    for (var feature in numericFeatures) {
      numericControllers[feature] = TextEditingController();
    }
  }

  Future<void> getPrediction() async {
    // Reset prediction and accuracy
    setState(() {
      prediction = null;
      accuracy = null;
      errorMessage = null;
    });

    // Validate user input
    if (numericFeatures
            .any((feature) => numericControllers[feature]!.text.isEmpty) ||
        categoricalFeatures.keys
            .any((category) => selectedCategoricalValues[category] == null)) {
      setState(() {
        errorMessage = 'Please enter values for all fields.';
      });
      return;
    }

    try {
      // Prepare the input data
      List<String> features = [];

      // Add numeric feature values to the payload
      for (var feature in numericFeatures) {
        features.add(numericControllers[feature]!.text);
      }

      // Add categorical feature values to the payload (0 or 1)
      for (var category in categoricalFeatures.keys) {
        List<String> labels = categoricalFeatures[category]!;
        String selectedLabel = selectedCategoricalValues[category]!;
        String featureValue;

        if (category == 'Senior Citizen' || category == 'Payment Method') {
          featureValue = selectedLabel == labels[0] ? '1' : '0';
        } else if (category == 'Contract' || category == 'Internet Service') {
          String a = '0';
          String b = '0';
          if (selectedLabel == labels[0]) {
            a = '1';
          } else if (selectedLabel == labels[1]) {
            b = '1';
          }
          features.add(a);
          features.add(b);
          continue; // Skip the next iteration
        } else {
          featureValue = selectedLabel == labels[0] ? '0' : '1';
        }

        features.add(featureValue);
      }

      // Create the request payload
      Map<String, dynamic> payload = {'input_data': features};
      print(payload);

      // Send a POST request to the Flask API
      final response = await http.post(
        Uri.parse('http://192.168.56.1:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print(
          "Done: ${response.statusCode}, ${response.reasonPhrase}, ${response.body}");

      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> data = jsonDecode(response.body);

        // Extract the prediction and confidence from the response
        setState(() {
          prediction = data['prediction'];
          accuracy = data['confidence'];
        });
      } else if (response.statusCode == 500) {
        setState(() {
          errorMessage =
              'Please enter actual number values for all numeric fields.';
        });
        return;
      } else {
        setState(() {
          errorMessage = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(children: [
          Text("TelcChurn Prediction app"),
          Text(
            "By Ryan Tangu Mbun Tangwe",
            style: TextStyle(fontSize: 15),
          ),
        ]),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 400,
                child: const Card(
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "This application applies a Multi-layer Perception deep learning model which uses keras and tensorflow Functional API, to predict customer churn in a telecom company.",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: const Text(
                    "Enter the details of the customer:",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  )),

              // Text fields for numeric features
              for (var feature in numericFeatures)
                Column(
                  children: [
                    Container(
                      width: 400,
                      child: TextField(
                        controller: numericControllers[feature],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: feature),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              const SizedBox(height: 16.0),
              // Toggles (selection boxes) for categorical features
              for (var category in categoricalFeatures.keys)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      child: Text(
                        '${category}:',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    DropdownButton<String>(
                      value: selectedCategoricalValues[category],
                      onChanged: (value) {
                        setState(() {
                          selectedCategoricalValues[category] = value!;
                        });
                      },
                      items: categoricalFeatures[category]!
                          .map<DropdownMenuItem<String>>((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      hint: Text('Select ${category.toLowerCase()}'),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              const SizedBox(height: 16.0),
              // Display error message if present
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        backgroundColor: Colors.redAccent),
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  getPrediction();
                },
                child: const Text(
                  'Predict Customer Churn',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              // Display prediction and accuracy
              if (prediction != null && accuracy != null)
                Column(
                  children: [
                    Text('Churn Prediction: ${prediction == 1 ? 'Yes' : 'No'}',
                        style: const TextStyle(fontSize: 18)),
                    Text('Confidence: ${accuracy!.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
