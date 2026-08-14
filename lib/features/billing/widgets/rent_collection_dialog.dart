import 'package:flutter/material.dart';

class RentCollectionResult {
  final double amount;
  final DateTime paymentDate;
  final String? remarks;

  const RentCollectionResult({
    required this.amount,
    required this.paymentDate,
    this.remarks,
  });
}

class RentCollectionDialog extends StatefulWidget {
  final double rentDue;
  final double alreadyCollected;
  final DateTime rentMonth;

  const RentCollectionDialog({
    super.key,
    required this.rentDue,
    required this.alreadyCollected,
    required this.rentMonth,
  });

  @override
  State<RentCollectionDialog> createState() =>
      _RentCollectionDialogState();
}

class _RentCollectionDialogState
    extends State<RentCollectionDialog> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  late DateTime _paymentDate;

  double get _outstanding =>
      widget.rentDue - widget.alreadyCollected;

  @override
  void initState() {
    super.initState();

    _paymentDate = DateTime.now();

    _amountController.text =
        _outstanding.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectPaymentDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _paymentDate = selected;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount =
        double.parse(_amountController.text.trim());

    Navigator.pop(
      context,
      RentCollectionResult(
        amount: amount,
        paymentDate: _paymentDate,
        remarks:
            _remarksController.text.trim().isEmpty
                ? null
                : _remarksController.text.trim(),
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Collect Rent'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Rent for ${_formatMonth(widget.rentMonth)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _SummaryRow(
                  label: 'Monthly Rent',
                  value:
                      '₹${widget.rentDue.toStringAsFixed(0)}',
                ),
                _SummaryRow(
                  label: 'Already Collected',
                  value:
                      '₹${widget.alreadyCollected.toStringAsFixed(0)}',
                ),
                _SummaryRow(
                  label: 'Outstanding',
                  value:
                      '₹${_outstanding.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount to Collect',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter amount';
                    }

                    final amount =
                        double.tryParse(value.trim());

                    if (amount == null ||
                        amount <= 0) {
                      return 'Enter a valid amount';
                    }

                    if (amount > _outstanding) {
                      return 'Amount cannot exceed outstanding rent';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Payment Date'),
                  subtitle:
                      Text(_formatDate(_paymentDate)),
                  trailing: const Icon(
                    Icons.calendar_today,
                  ),
                  onTap: _selectPaymentDate,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Remarks (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Collect Rent'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}