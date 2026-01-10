import 'package:flutter/material.dart';
import '../../../candidates/domain/entities/candidate.dart';

class SelectedCandidatesList extends StatelessWidget {
  final List<Candidate> candidates;

  const SelectedCandidatesList({
    super.key,
    required this.candidates,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: candidates.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        final imageUrl = candidate.photoUrl;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            onBackgroundImageError: (_, _) {},
            child: imageUrl.isEmpty
                ? Text(candidate.firstName[0])
                : null,
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
      },
    );
  }
}
