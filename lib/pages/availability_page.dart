import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/theme/app_theme.dart';
import 'package:my_resturant/data/mock_data.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/app_image.dart';

class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OrderCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('خواردنە بەردەستەکان')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mockRecipes.length,
          itemBuilder: (context, index) {
            final r = mockRecipes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(r.imageUrl, width: 48, height: 48),
                ),
                title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                subtitle: Text('${r.price.toInt()} د.ع', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                trailing: Switch(
                  value: r.available,
                  onChanged: (_) => cubit.toggleAvailability(r.id),
                  activeTrackColor: AppTheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
