import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_model.dart';
import 'add_contact_sheet.dart';

class AppColors {
  static const darkBlue = Color(0xFF29384D);
  static const white = Color(0xFFFFFFFF);
  static const lightBlue = Color(0xFFE2F4F6);
  static const gold = Color(0xFFFFF1D4);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Contact> contacts = [];
  bool isLoading = true;
  late final AnimationController _emptyAnimController;

  static const String storageKey = 'saved_contacts';

  @override
  void initState() {
    super.initState();
    _emptyAnimController = AnimationController(vsync: this);
    loadContacts();
  }

  @override
  void dispose() {
    _emptyAnimController.dispose();
    super.dispose();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedString = prefs.getString(storageKey);

    if (savedString != null) {
      final List decodedList = jsonDecode(savedString);
      setState(() {
        contacts = decodedList.map((item) => Contact.fromMap(item)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(contacts.map((c) => c.toMap()).toList());
    await prefs.setString(storageKey, encodedList);
  }

  void addContact(Contact contact) {
    setState(() {
      contacts.add(contact);
    });
    saveContacts();
  }

  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
    saveContacts();
  }

  void deleteLastContact() {
    setState(() {
      contacts.removeLast();
    });
    saveContacts();
  }

  void openAddContactSheet() {
    _emptyAnimController.stop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddContactSheet(onAdd: addContact),
    ).then((_) {
      if (contacts.isEmpty) {
        _emptyAnimController.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        title: Image.asset('assets/route_logo_white.png', height: 32),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: contacts.isEmpty ? buildEmptyState() : buildContactsGrid(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (contacts.isNotEmpty)
            FloatingActionButton(
              heroTag: 'delete_last',
              backgroundColor: const Color(0xFFEE403D),
              onPressed: deleteLastContact,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
          const SizedBox(height: 12),
          if (contacts.length < 6)
            FloatingActionButton(
              heroTag: 'add_contact',
              backgroundColor: AppColors.gold,
              onPressed: openAddContactSheet,
              child: const Icon(Icons.add, color: AppColors.darkBlue),
            ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/empty_list.json',
            width: 200,
            height: 200,
            controller: _emptyAnimController,
            onLoaded: (composition) {
              _emptyAnimController.duration = composition.duration;
              _emptyAnimController.repeat();
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'There is No Contacts Added Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContactsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 177 / 286,
      ),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ContactCard(
          contact: contact,
          onDelete: () => deleteContact(index),
        );
      },
    );
  }
}

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.gold,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: contact.image != null
                        ? Image.memory(contact.image!, fit: BoxFit.cover)
                        : Container(
                      color: AppColors.lightBlue,
                      child: const Icon(Icons.person, size: 45, color: AppColors.darkBlue),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                          color: AppColors.darkBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: AppColors.gold,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email, color: AppColors.darkBlue, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          contact.email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.darkBlue, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.darkBlue, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          contact.phone,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.darkBlue, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE403D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.delete, size: 14),
                  label: const Text('Delete', style: TextStyle(fontSize: 11)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}