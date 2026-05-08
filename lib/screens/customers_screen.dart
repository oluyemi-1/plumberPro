import 'package:flutter/material.dart';

import '../data/customer_data.dart';
import '../services/customer_service.dart';
import '../theme.dart';
import 'customer_detail_screen.dart';
import 'edit_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  /// When true, this screen is opened in pick mode — tapping a row pops
  /// the screen with the chosen [Customer]. When false, tapping opens the
  /// detail screen.
  final bool pickMode;
  const CustomersScreen({super.key, this.pickMode = false});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    CustomerService.instance.ensureLoaded();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Customer> _filtered(List<Customer> all) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q))
        .toList();
  }

  Map<String, List<Customer>> _group(List<Customer> list) {
    final map = <String, List<Customer>>{};
    for (final c in list) {
      map.putIfAbsent(c.firstLetter, () => []).add(c);
    }
    return map;
  }

  /// Flattens the alphabetical groups into a single heterogeneous list of
  /// `String` headers and `Customer` rows, then renders via
  /// `ListView.builder` so only the visible items are built. Avoids the
  /// O(n) widget construction cost of a plain `ListView` when the customer
  /// list grows into the hundreds.
  Widget _buildList(
    List<String> keys,
    Map<String, List<Customer>> groups,
  ) {
    final items = <Object>[];
    for (final letter in keys) {
      items.add(letter);
      items.addAll(groups[letter]!);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final entry = items[i];
        if (entry is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
            child: Text(
              entry,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          );
        }
        return _CustomerTile(
          customer: entry as Customer,
          pickMode: widget.pickMode,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? 'Pick a customer' : 'Customers'),
      ),
      floatingActionButton: widget.pickMode
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.person_add),
              label: const Text('New customer'),
              onPressed: () async {
                final c = await Navigator.push<Customer?>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditCustomerScreen()),
                );
                if (c != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            CustomerDetailScreen(customerId: c.id)),
                  );
                }
              },
            ),
      body: AnimatedBuilder(
        animation: CustomerService.instance,
        builder: (context, _) {
          final all = CustomerService.instance.customers;
          final filtered = _filtered(all);
          final groups = _group(filtered);
          final keys = groups.keys.toList()..sort();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name, address, phone, email…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: all.isEmpty
                    ? const _EmptyState()
                    : filtered.isEmpty
                        ? const _NoMatches()
                        : _buildList(keys, groups),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final bool pickMode;
  const _CustomerTile({required this.customer, required this.pickMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (pickMode) {
              Navigator.pop(context, customer);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        CustomerDetailScreen(customerId: customer.id)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    customer.firstLetter,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name.isEmpty
                            ? 'Unnamed customer'
                            : customer.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (customer.address.isNotEmpty)
                        Text(customer.address,
                            style:
                                Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      if (customer.phone.isNotEmpty)
                        Text(customer.phone,
                            style:
                                Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  pickMode ? Icons.check_circle_outline : Icons.chevron_right,
                  color: pickMode ? AppColors.primary : AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
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
            const Icon(Icons.people_outline,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No customers yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Tap New customer to add one. You can also pick a customer when creating a new job — they will be saved here automatically.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off,
                size: 48, color: AppColors.muted),
            const SizedBox(height: 6),
            Text('No matches',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
