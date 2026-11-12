import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // ឯកសារដែលទើបតែបង្កើតមិញ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ផ្ដើមដំណើរការ Firebase តាម Platform នីមួយៗស្វ័យប្រវត្តិ
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const StudySmartApp());
}

class StudySmartApp extends StatelessWidget {
  const StudySmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gmailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passcodeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String name = _nameController.text.trim();
        String gmail = _gmailController.text.trim();
        int age = int.tryParse(_ageController.text.trim()) ?? 0;
        String passcode = _passcodeController.text.trim();

        if (name == "admin" && passcode == "123456") {
          setState(() => _isLoading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ជោគជ័យ៖ ចូលទៅកាន់ Admin Dashboard!")),
          );
          return;
        }

        // បញ្ជូនទិន្នន័យចូលទៅកាន់ Firebase Firestore (Collection: students)
        await FirebaseFirestore.instance.collection('students').add({
          'name': name,
          'gmail': gmail,
          'age': age,
          'passcode': passcode,
          'score': 0,
          'createdAt': Timestamp.now(),
        });

        setState(() => _isLoading = false);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ទិន្នន័យត្រូវបានបញ្ជូនចូល Firebase ដោយជោគជ័យ! 🎉")),
        );

        _nameController.clear();
        _gmailController.clear();
        _ageController.clear();
        _passcodeController.clear();

      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("មានបញ្ហាពេលបញ្ជូនទិន្នន័យ: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Smart - Firebase Connected'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ចុះឈ្មោះសិស្ស (Student Registration)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'ឈ្មោះពេញ (Name)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? 'សូមបញ្ចូលឈ្មោះ' : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _gmailController,
                    decoration: const InputDecoration(
                      labelText: 'Gmail (ត្រូវមាន @gmail.com)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || !val.endsWith('@gmail.com')) {
                        return 'សូមបញ្ចូល Gmail ឱ្យបានត្រឹមត្រូវ (ឧ៖ name@gmail.com)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'អាយុ (Age)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? 'សូមបញ្ចូលអាយុ' : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _passcodeController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'លេខកូដសម្ងាត់ (Passcode Demo)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? 'សូមបញ្ចូលលេខកូដ' : null,
                  ),
                  const SizedBox(height: 25),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitData,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('ចុះឈ្មោះ និងបញ្ជូនទៅ Firebase', style: TextStyle(fontSize: 16)),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}