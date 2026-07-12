import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          120,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppShadows.button,
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 42),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    'Approval status: 2 approved, 1 under review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final document in DemoData.documents)
            DocumentCard(
              document: document,
              onTap: () => ToastScope.of(context).info(
                'Upload again',
                subtitle: 'Image picker stub opened for ${document.title}.',
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Upload again',
            icon: Icons.upload_file_rounded,
            onPressed: () => ToastScope.of(context).info(
              'Picker stub',
              subtitle: 'Connect image_picker to upload production files.',
            ),
          ),
        ].animate(interval: 45.ms).fadeIn().slideY(begin: 0.03),
      ),
    );
  }
}
