import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now,
    );

    // The sheet may have been closed while the picker was open.
    if (!mounted) {
      return;
    }

    // Keep the previous date if the user cancelled the picker.
    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseData() {
    // Accept both "12.50" and "12,50".
    final enteredAmount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and category was entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onAddExpense(
      Expense(
        title: _titleController.text.trim(),
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(builder: (ctx, constraints) {
      final isWide = constraints.maxWidth >= 600;

      final titleField = TextField(
        controller: _titleController,
        maxLength: 50,
        decoration: const InputDecoration(
          label: Text('Title'),
        ),
      );

      final amountField = TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          prefixText: '\$ ',
          label: Text('Amount'),
        ),
      );

      final fields = isWide
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: titleField),
          const SizedBox(width: 24),
          Expanded(child: amountField),
        ],
      )
          : Column(
        children: [
          titleField,
          const SizedBox(height: 16),
          amountField,
        ],
      );

      final categoryDropdown = DropdownButton<Category>(
        value: _selectedCategory,
        items: Category.values
            .map(
              (category) => DropdownMenuItem(
            value: category,
            child: Text(category.name.toUpperCase()),
          ),
        )
            .toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }
          setState(() {
            _selectedCategory = value;
          });
        },
      );

      final dateRow = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              _selectedDate == null
                  ? 'No date selected'
                  : formatter.format(_selectedDate!),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _presentDatePicker,
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      );

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
          child: Column(
            children: [
              fields,
              const SizedBox(height: 16),
              Row(
                children: [
                  categoryDropdown,
                  const SizedBox(width: 16),
                  Expanded(child: dateRow),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitExpenseData,
                    child: const Text('Save Expense'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}