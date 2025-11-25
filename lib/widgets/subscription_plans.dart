import 'package:flutter/material.dart';

class SubscriptionPlansDialog extends StatelessWidget {
  final bool open;
  final void Function(bool) onOpenChange;
  const SubscriptionPlansDialog(
      {Key? key, this.open = false, required this.onOpenChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!open) return const SizedBox.shrink();
    return Dialog(
      child: SizedBox(
        width: 700,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Choose Your Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _PlanCard(name: 'Free', price: '₹0', features: [
                'Up to 10 entries per month',
                'Basic tracking'
              ])),
              const SizedBox(width: 8),
              Expanded(
                  child: _PlanCard(
                      name: 'Professional',
                      price: '₹299',
                      popular: true,
                      features: ['Unlimited entries', 'Multi-currency'])),
              const SizedBox(width: 8),
              Expanded(
                  child: _PlanCard(
                      name: 'Business',
                      price: '₹999',
                      features: ['Multi-user', 'Advanced analytics'])),
            ])
          ]),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final List<String> features;
  final bool popular;
  const _PlanCard(
      {Key? key,
      required this.name,
      required this.price,
      this.features = const [],
      this.popular = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: popular ? 8 : 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              BorderSide(color: popular ? Colors.blue : Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          if (popular)
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Most Popular',
                        style: TextStyle(color: Colors.white)))),
          const SizedBox(height: 8),
          Text(name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(price,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...features.map((f) => Row(children: [
                const Icon(Icons.check, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(child: Text(f))
              ])),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: () {},
              child: Text(name == 'Free' ? 'Current Plan' : 'Contact Us'))
        ]),
      ),
    );
  }
}
