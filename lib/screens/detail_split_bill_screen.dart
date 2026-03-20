import 'package:flutter/material.dart';
import 'package:patungan_plus/models/bill.dart';
import 'package:patungan_plus/models/bill_items.dart';
import 'package:patungan_plus/models/participant.dart';
import 'package:patungan_plus/providers/main_controller.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class DetailSplitBillScreen extends StatefulWidget {
  const DetailSplitBillScreen({super.key});

  @override
  State<DetailSplitBillScreen> createState() => _DetailSplitBillScreenState();
}

class _DetailSplitBillScreenState extends State<DetailSplitBillScreen> {
  BillModel? bill;
  List<Participant> participants = [];
  bool isLoading = true;
  bool isViewMode = false;
  String? selectedParticipantForItemId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBillData();
  }

  Future<void> _fetchBillData() async {
    try {
      final controller = Provider.of<MainController>(context, listen: false);

      // First try to load temporary bill (from input screen)
      BillModel? fetchedBill = controller.getTemporaryBill();

      // If no temporary bill, try to load from DB by ID (for viewing saved bills)
      if (fetchedBill == null) {
        isViewMode = true; // Viewing an existing bill

        final args =
            (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{})
                as Map;
        final billId = args['id'] as int?;

        if (billId == null) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('No bill to display')));
            setState(() => isLoading = false);
          }
          return;
        }

        fetchedBill = await controller.getTransactionById(billId);
        if (fetchedBill != null) {
          participants = await controller.getParticipantsForBill(billId);
        }
      } else {
        isViewMode = false; // Creating a new bill split
      }

      if (mounted) {
        setState(() {
          bill = fetchedBill;
          isLoading = false;
        });

        if (bill == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to load bill')));
        }
      }
    } catch (e) {
      print("Error fetching bill data: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addParticipant() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Participant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Participant Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                hintText: 'Phone (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    participants.add(
                      Participant(
                        id: const Uuid().v4(),
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        phone: phoneController.text.trim(),
                        assignedItems: [], // Initialize safely
                      ),
                    );
                  });
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a name')),
                  );
                }
              } catch (e) {
                print("Error adding participant: $e");
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding participant: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _assignItemToParticipant(int itemIndex) {
    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add participants first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Assign Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select participant for: ${bill?.items[itemIndex].itemName}',
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: participants.length,
                  itemBuilder: (listContext, index) {
                    return ListTile(
                      title: Text(participants[index].name),
                      onTap: () {
                        try {
                          setState(() {
                            final p = participants[index];
                            if (!p.assignedItems.contains(itemIndex)) {
                              // Use List.from to safely ensure we have a growable list
                              final newAssignedItems = List<int>.from(
                                p.assignedItems,
                              );
                              newAssignedItems.add(itemIndex);

                              participants[index] = p.copyWith(
                                assignedItems: newAssignedItems,
                              );
                            }
                          });
                          Navigator.pop(dialogContext);
                        } catch (e) {
                          print("Error assigning item: $e");
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error assigning participant: $e'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Split Bill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Split Bill')),
        body: const Center(child: Text('Failed to load bill')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isViewMode ? 'Bill Details' : 'Split Bill'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildBillHeader(bill!),
              const SizedBox(height: 24),
              buildBillItemsSection(bill!),
              const SizedBox(height: 24),
              buildParticipantsSection(),
              const SizedBox(height: 16),
              const Divider(thickness: 4, color: Color(0xFFF5F5F5)),
              const SizedBox(height: 16),
              buildSplitResultSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: isViewMode
          ? null
          : FloatingActionButton(
              onPressed: _addParticipant,
              backgroundColor: Colors.green,
              child: const Icon(Icons.person_add),
            ),
      bottomNavigationBar: isViewMode ? null : _buildSaveAction(),
    );
  }

  Widget _buildSaveAction() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              try {
                if (participants.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please add participants and assign items before saving.',
                      ),
                    ),
                  );
                  return;
                }

                final controller = Provider.of<MainController>(
                  context,
                  listen: false,
                );
                final result = await controller.finalizeTransaction(
                  bill!,
                  participants,
                );

                if (result != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bill Split Finalized and Saved!'),
                    ),
                  );
                  // Go back to the very first route (Home)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } catch (e) {
                print("Error saving bill: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving bill: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Finalize & Save Bill',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBillHeader(BillModel bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isViewMode ? 'Bill receipt history' : 'Bill detail',
              style: const TextStyle(color: Colors.grey),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
        Text(
          bill.merchantName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Bill Date: ${bill.date.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          'Rp ${bill.totalAmount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00C853),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[800]),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[800]),
                    children: [
                      TextSpan(
                        text: isViewMode
                            ? '${participants.length} participant(s) split Rp ${bill.totalAmount.toStringAsFixed(0)}'
                            : '${participants.length} participant(s) will split Rp ${bill.totalAmount.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBillItemsSection(BillModel bill) {
    return Column(
      children: [
        buildCollapsibleHeader('BILL ITEMS (${bill.items.length})', true),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bill.items.length,
          itemBuilder: (context, index) {
            final item = bill.items[index];
            return buildBillItemTile(item, index);
          },
        ),
      ],
    );
  }

  Widget buildBillItemTile(BillItems item, int itemIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Qty: ${item.quantity} x Rp ${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            if (!isViewMode) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _assignItemToParticipant(itemIndex),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Assign to participant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildParticipantsSection() {
    return Column(
      children: [
        buildCollapsibleHeader('PARTICIPANTS (${participants.length})', true),
        if (participants.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              isViewMode
                  ? 'No participants were recorded for this bill'
                  : 'No participants added yet\nTap + to add participants',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              return buildParticipantTile(participants[index], index);
            },
          ),
      ],
    );
  }

  Widget buildParticipantTile(Participant participant, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: Text(
                    participant.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (participant.phone.isNotEmpty)
                        Text(
                          participant.phone,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isViewMode)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      try {
                        setState(() {
                          participants.removeAt(index);
                        });
                      } catch (e) {
                        print("Error removing participant: $e");
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),
              ],
            ),
            if (participant.assignedItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned items:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...participant.assignedItems.map((itemIndex) {
                      try {
                        final item = bill!.items[itemIndex];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '• ${item.itemName}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      } catch (e) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '• Error loading item',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildSplitResultSection() {
    return Column(
      children: [
        buildCollapsibleHeader('SPLIT RESULT', true),
        if (participants.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Add participants to see split amounts',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              return buildSplitResultDetail(participants[index]);
            },
          ),
      ],
    );
  }

  double _calculateParticipantTotal(Participant participant) {
    double total = 0;
    for (int itemIndex in participant.assignedItems) {
      if (itemIndex >= 0 && itemIndex < bill!.items.length) {
        total += bill!.items[itemIndex].totalPrice;
      }
    }
    return total;
  }

  Widget buildCollapsibleHeader(title, isExpanded) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSplitResultDetail(Participant participant) {
    double totalAmount = 0.0;
    try {
      totalAmount = _calculateParticipantTotal(participant);
    } catch (e) {
      print("Error calculating total: $e");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    participant.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${participant.assignedItems.length} item(s)',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'Rp ${totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
