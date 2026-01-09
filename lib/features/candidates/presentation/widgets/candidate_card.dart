import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/candidate.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final bool isSelected;
  final VoidCallback onTap;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.isSelected,
    required this.onTap,
  });

  String _getCorsProxyUrl(String url) {
    // For development: use CORS proxy. Remove in production when server has proper CORS headers
    if (url.isEmpty) return url;
    // Using corsproxy.io as a temporary workaround
    return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CandidateCard: ${candidate.fullName} photoUrl: ${candidate.photoUrl}');
    final imageUrl = _getCorsProxyUrl(candidate.photoUrl);
    const selectedColor = Colors.indigo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          color: isSelected
              ? selectedColor.withValues(alpha: 0.08)
              : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Image error for ${candidate.fullName}: $error');
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  // Always show radio indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : Colors.white,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Text(
                candidate.fullName.toUpperCase(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
