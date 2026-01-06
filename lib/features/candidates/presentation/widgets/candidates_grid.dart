import 'package:flutter/material.dart';
import '../../domain/entities/candidate.dart';
import 'candidate_card.dart';

class CandidatesGrid extends StatelessWidget {
  final List<Candidate> candidates;
  final Set<String> selectedIds;
  final Function(String) onCandidateTap;

  const CandidatesGrid({
    super.key,
    required this.candidates,
    required this.selectedIds,
    required this.onCandidateTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 4 columns for desktop/web (>900px), 2 for mobile
    final crossAxisCount = screenWidth > 900 ? 4 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        final isSelected = selectedIds.contains(candidate.id);

        return CandidateCard(
          candidate: candidate,
          isSelected: isSelected,
          onTap: () => onCandidateTap(candidate.id),
        );
      },
    );
  }
}
