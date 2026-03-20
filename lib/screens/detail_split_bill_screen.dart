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

  // Track which participant is currently selected for assigning items
  int? selectedParticipantIndex;

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
                    // Optionally auto-select the newly added participant
                    selectedParticipantIndex = participants.length - 1;
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

  void _removeParticipant(int index) {
    try {
      setState(() {
        participants.removeAt(index);
        // Fix selection index to handle array shift
        if (selectedParticipantIndex == index) {
          selectedParticipantIndex = null;
        } else if (selectedParticipantIndex != null &&
            selectedParticipantIndex! > index) {
          selectedParticipantIndex = selectedParticipantIndex! - 1;
        }
      });
    } catch (e) {
      print("Error removing participant: $e");
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBillHeader(bill!),
              const SizedBox(height: 24),
              buildHorizontalParticipantsSection(),
              const SizedBox(height: 16),
              buildBillItemsSection(bill!),
              const SizedBox(height: 16),
              const Divider(thickness: 4, color: Color(0xFFF5F5F5)),
              const SizedBox(height: 16),
              buildSplitResultSection(),
            ],
          ),
        ),
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
      ],
    );
  }

  Widget buildHorizontalParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCollapsibleHeader('PARTICIPANTS (${participants.length})', true),
        const SizedBox(height: 8),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: isViewMode
                ? participants.length
                : participants.length + 1,
            itemBuilder: (context, index) {
              if (!isViewMode && index == participants.length) {
                return _buildAddParticipantButton();
              }
              return _buildParticipantAvatar(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantAvatar(int index) {
    final participant = participants[index];
    final isSelected = selectedParticipantIndex == index;

    return GestureDetector(
      onTap: () {
        if (isViewMode) return;
        setState(() {
          selectedParticipantIndex = isSelected ? null : index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.black,
                      width: 1,
                    ),
                    color: isSelected
                        ? Colors.green.withOpacity(0.2)
                        : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      participant.name.isNotEmpty
                          ? participant.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.green.shade800
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                if (!isViewMode)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: GestureDetector(
                      onTap: () => _removeParticipant(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 65,
              child: Text(
                participant.name,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddParticipantButton() {
    return GestureDetector(
      onTap: _addParticipant,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                color: Colors.white,
              ),
              child: const Center(
                child: Text('+ Add', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),
            const Text('', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget buildBillItemsSection(BillModel bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCollapsibleHeader('BILL ITEMS (${bill.items.length})', true),
        if (!isViewMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              selectedParticipantIndex != null
                  ? 'Tap an item below to assign it to ${participants[selectedParticipantIndex!].name}.'
                  : 'Select a participant above to start assigning items.',
              style: TextStyle(
                color: selectedParticipantIndex != null
                    ? Colors.green.shade700
                    : Colors.grey,
                fontSize: 13,
                fontWeight: selectedParticipantIndex != null
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ),
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
    // Find who is assigned to this specific item
    final assignedParticipants = participants
        .where((p) => p.assignedItems.contains(itemIndex))
        .toList();

    return GestureDetector(
      onTap: () {
        if (isViewMode || selectedParticipantIndex == null) return;
        try {
          setState(() {
            final p = participants[selectedParticipantIndex!];
            final newAssignedItems = List<int>.from(p.assignedItems);

            // Toggle assignment
            if (newAssignedItems.contains(itemIndex)) {
              newAssignedItems.remove(itemIndex);
            } else {
              newAssignedItems.add(itemIndex);
            }

            participants[selectedParticipantIndex!] = p.copyWith(
              assignedItems: newAssignedItems,
            );
          });
        } catch (e) {
          print("Error assigning item: $e");
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1,
            ), // Square styling as requested
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    item.totalPrice.toStringAsFixed(0),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (assignedParticipants.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: assignedParticipants.map((p) {
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 1),
                        color: Colors.green.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else if (!isViewMode && selectedParticipantIndex != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Tap to assign',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
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
        // Calculate shares: split equally if multiple participants select the same item
        int totalShares = participants
            .where((p) => p.assignedItems.contains(itemIndex))
            .length;
        if (totalShares > 0) {
          total += (bill!.items[itemIndex].totalPrice / totalShares);
        }
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    participant.name.isNotEmpty
                        ? participant.name[0].toUpperCase()
                        : '?',
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
