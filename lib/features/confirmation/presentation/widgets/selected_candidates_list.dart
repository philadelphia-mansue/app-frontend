import 'package:flutter/material.dart';
import '../../../../core/widgets/cross_platform_image.dart';
import '../../../candidates/domain/entities/candidate.dart';

class SelectedCandidatesList extends StatelessWidget {
  final List<Candidate> candidates;

  const SelectedCandidatesList({
    super.key,
    required this.candidates,
  });

  Widget _buildCandidateTile(BuildContext context, Candidate candidate, int index) {
    final imageUrl = candidate.photoUrl;
    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? CrossPlatformImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                    child: Text(candidate.firstName.isNotEmpty
                        ? candidate.firstName[0]
                        : '?'),
                  ),
                )
              : CircleAvatar(
                  child: Text(candidate.firstName.isNotEmpty
                      ? candidate.firstName[0]
                      : '?'),
                ),
        ),
      ),
      title: Text(
        candidate.fullName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Column instead of ListView.separated with shrinkWrap
    // Parent has SingleChildScrollView, so no virtualization benefit with shrinkWrap
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < candidates.length; i++) ...[
          _buildCandidateTile(context, candidates[i], i),
          if (i < candidates.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}
