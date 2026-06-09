import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/providers/user_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: Main_AxisAlignment.center,
          children: [
            const Text('Are you a passenger or a driver?'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(userProvider.notifier).setRole('passenger'),
              child: const Text('Passenger'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(userProvider.notifier).setRole('driver'),
              child: const Text('Driver'),
            ),
          ],
        ),
      ),
    );
  }
}
