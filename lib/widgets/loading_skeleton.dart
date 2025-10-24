import 'package:flutter/material.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSkeletonCard(),
            const SizedBox(height: 24),
            _buildSkeletonCard(),
            const SizedBox(height: 24),
            _buildSkeletonCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 150,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              color: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }
}
