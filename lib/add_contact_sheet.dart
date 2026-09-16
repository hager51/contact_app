import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'contact_model.dart';
import 'home_screen.dart';

class AddContactSheet extends StatefulWidget {
  final void Function(Contact contact) onAdd;

  const AddContactSheet({super.key, required this.onAdd});

  @override
  State<AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Uint8List? pickedImageBytes;

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() {
        pickedImageBytes = bytes;
      });
    }
  }

  void handleSave() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      return;
    }

    final newContact = Contact(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      image: pickedImageBytes,
    );

    widget.onAdd(newContact);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildImageAndPreviewRow(),

            const SizedBox(height: 20),

            buildTextField(controller: nameController, hint: 'Enter User Name'),
            const SizedBox(height: 12),

            buildTextField(controller: emailController, hint: 'Enter User Email'),
            const SizedBox(height: 12),

            buildTextField(controller: phoneController, hint: 'Enter User Phone'),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.darkBlue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Enter user',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildImageAndPreviewRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: pickImageFromGallery,
          child: ClipOval(
            child: Container(
              width: 90,
              height: 90,
              color: AppColors.lightBlue,
              child: pickedImageBytes != null
                  ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                  : Lottie.asset(
                'assets/image_picker.json',
                repeat: false,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildPreviewLine(nameController.text, 'User Name'),
              const SizedBox(height: 8),
              buildPreviewLine(emailController.text, 'example@email.com'),
              const SizedBox(height: 8),
              buildPreviewLine(phoneController.text, '+200000000000'),
            ],
          ),
        ),
      ],
    );
  }


  Widget buildPreviewLine(String text, String hint) {
    final bool hasText = text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasText ? text : hint,
          style: TextStyle(
            color: hasText
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.4),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: AppColors.gold),
      ],
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      onChanged: (value) => setState(() {}),
      style: const TextStyle(color: AppColors.lightBlue, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.lightBlue, fontSize: 16),
        filled: true,
        fillColor: AppColors.darkBlue,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEE403D), width: 2),
        ),
      ),
      cursorColor: AppColors.gold,
    );
  }
}