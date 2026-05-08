import 'package:flutter/material.dart';

import '../data/quote_data.dart';
import '../services/quote_service.dart';
import '../theme.dart';
import 'edit_quote_screen.dart';

/// List of every quote, grouped by status (Draft / Sent / Accepted / Rejected)
/// with the open ones at the top. Tapping any quote opens it for editing,
/// re-sharing, or converting to an active job.
class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  @override
  void initState() {
    super.initState();
    QuoteService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotes & estimates')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.note_add),
        label: const Text('New quote'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditQuoteScreen()),
        ),
      ),
      body: AnimatedBuilder(
        animation: QuoteService.instance,
        builder: (context, _) {
          final all = QuoteService.instance.items;
          if (all.isEmpty) return const _EmptyState();

          // Bucket by status. Drafts first because that's where new work
          // sits; then Sent (waiting on the customer); then Accepted /
          // Rejected for history.
          final drafts =
              all.where((q) => q.status == QuoteStatus.draft).toList();
          final sent =
              all.where((q) => q.status == QuoteStatus.sent).toList();
          final accepted =
              all.where((q) => q.status == QuoteStatus.accepted).toList();
          final rejected =
              all.where((q) => q.status == QuoteStatus.rejected).toList();

          // Flatten for ListView.builder so longer lists stay snappy.
          final items = <Object>[const _IntroSlot()];
          if (drafts.isNotEmpty) {
            items.add(const _SectionSlot('Drafts', AppColors.muted));
            items.addAll(drafts);
          }
          if (sent.isNotEmpty) {
            items.add(const _SectionSlot('Sent · awaiting reply',
                AppColors.primary));
            items.addAll(sent);
          }
          if (accepted.isNotEmpty) {
            items.add(const _SectionSlot('Accepted', Colors.green));
            items.addAll(accepted);
          }
          if (rejected.isNotEmpty) {
            items.add(const _SectionSlot('Rejected', Colors.redAccent));
            items.addAll(rejected);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              if (item is _IntroSlot) return const _IntroCard();
              if (item is _SectionSlot) {
                return _SectionHeader(label: item.label, color: item.color);
              }
              if (item is Quote) return _QuoteRow(quote: item);
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _IntroSlot {
  const _IntroSlot();
}

class _SectionSlot {
  final String label;
  final Color color;
  const _SectionSlot(this.label, this.color);
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.handshake, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Quotes close the loop',
                    style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 6),
              const Text(
                  'Build an estimate on the survey — predicted hours × rate plus suggested parts. Share the PDF, capture the customer\'s signature when they accept, and convert to an active job in one tap. Predicted parts seed onto the job automatically.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Row(children: [
        Container(width: 4, height: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ]),
    );
  }
}

class _QuoteRow extends StatelessWidget {
  final Quote quote;
  const _QuoteRow({required this.quote});

  Color get _accent {
    switch (quote.status) {
      case QuoteStatus.draft:
        return AppColors.muted;
      case QuoteStatus.sent:
        return AppColors.primary;
      case QuoteStatus.accepted:
        return Colors.green;
      case QuoteStatus.rejected:
        return Colors.redAccent;
    }
  }

  IconData get _icon {
    switch (quote.status) {
      case QuoteStatus.draft:
        return Icons.edit_note;
      case QuoteStatus.sent:
        return Icons.outgoing_mail;
      case QuoteStatus.accepted:
        return Icons.check_circle;
      case QuoteStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = quote.isExpired() && quote.status.isOpen;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EditQuoteScreen(existing: quote)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          quote.customer.isEmpty
                              ? 'Untitled'
                              : quote.customer,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '£${quote.subtotalGbp.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ]),
                    if (quote.description.isNotEmpty)
                      Text(quote.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      _Pill(label: quote.quoteRef, color: AppColors.muted),
                      if (quote.estimatedHours > 0)
                        _Pill(
                          label:
                              '${_trim(quote.estimatedHours)} h × £${quote.hourlyRateGbp.toStringAsFixed(0)}',
                          color: AppColors.primary,
                        ),
                      if (expired)
                        const _Pill(label: 'Expired', color: Colors.redAccent),
                      if (quote.convertedJobId != null)
                        const _Pill(label: 'Job linked', color: Colors.green),
                    ]),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.note_add_outlined,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No quotes yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Tap New quote at the bottom to draft your first estimate. Build it on the survey, share the PDF, capture acceptance, and convert to a job in one tap.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              icon: const Icon(Icons.note_add),
              label: const Text('Draft your first quote'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditQuoteScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
