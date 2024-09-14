import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> languages = [];
  List<String> colors = [];
  String selectedLanguage = 'Tamil';  // Default selected language
  String selectedColor = 'beige';  // Default selected color
  bool isLoadingLanguages = true;
  bool isLoadingColors = true;

  @override
  void initState() {
    super.initState();
    fetchLanguageOptions();
    fetchColorOptions();
  }

  Future<void> fetchLanguageOptions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('language_options').get();
      if (snapshot.docs.isNotEmpty) {
        List<String> fetchedLanguages = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          for (var entry in data.entries) {
            if (entry.value is String) {
              fetchedLanguages.add(entry.value as String);
            }
          }
        }
        setState(() {
          languages = fetchedLanguages;
          isLoadingLanguages = false;
        });
      } else {
        setState(() {
          languages = [];
          isLoadingLanguages = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingLanguages = false;
      });
      print('Error fetching languages: $e');
    }
  }

  Future<void> fetchColorOptions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('color_options').get();
      if (snapshot.docs.isNotEmpty) {
        List<String> fetchedColors = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          for (var entry in data.entries) {
            if (entry.value is String) {
              fetchedColors.add(entry.value as String);
            }
          }
        }
        setState(() {
          colors = fetchedColors;
          isLoadingColors = false;
        });
      } else {
        setState(() {
          colors = [];
          isLoadingColors = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingColors = false;
      });
      print('Error fetching colors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            isLoadingLanguages
                ? Center(child: CircularProgressIndicator())
                : Wrap(
              spacing: 10,
              children: languages.isNotEmpty
                  ? languages.map((language) {
                return ChoiceChip(
                  label: Text(language),
                  selected: selectedLanguage == language,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedLanguage = language;
                    });
                  },
                );
              }).toList()
                  : [Text('No languages available')],
            ),
            const SizedBox(height: 20),
            const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            isLoadingColors
                ? Center(child: CircularProgressIndicator())
                : Wrap(
              spacing: 10,
              children: colors.isNotEmpty
                  ? colors.map((color) {
                return ChoiceChip(
                  label: Text(color),
                  selected: selectedColor == color,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                );
              }).toList()
                  : [Text('No colors available')],
            ),
          ],
        ),
      ),
    );
  }
}
