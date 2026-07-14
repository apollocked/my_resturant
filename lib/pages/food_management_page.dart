import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_resturant/main.dart';
import 'package:my_resturant/data/mock_data.dart';
import 'package:my_resturant/cubits/order_cubit.dart';
import 'package:my_resturant/widgets/app_image.dart';

class FoodManagementPage extends StatelessWidget {
  const FoodManagementPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OrderCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('بەڕێوەبردنی خواردنەکان')),
      body: Directionality(textDirection: TextDirection.rtl, child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: mockRecipes.length,
        itemBuilder: (context, index) {
          final r = mockRecipes[index];
          return Card(clipBehavior: Clip.hardEdge, child: Column(children: [
            Expanded(child: Stack(fit: StackFit.expand, children: [
              AppImage(r.imageUrl),
              if (!r.available)
                Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(child: Icon(Icons.visibility_off, color: Colors.white70, size: 28)))),
            ])),
            Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text('${r.price.toInt()} د.ع', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Switch(value: r.available, onChanged: (_) => cubit.toggleAvailability(r.id),
                  activeThumbColor: AppTheme.primary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                Text(r.available ? 'بەردەست' : 'نا بەردەست',
                    style: TextStyle(fontSize: 10, color: r.available ? AppTheme.success : AppTheme.error, fontWeight: FontWeight.w600)),
              ]),
            ])),
          ]));
        },
      )),
    );
  }
}
