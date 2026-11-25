import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import '../services/karigor_repository.dart';
import '../theme/app_theme.dart';

class RequestJobModal extends StatefulWidget {
  final ProviderModel? targetKarigor;
  final int? seekerId;
  final VoidCallback? onSuccess;

  const RequestJobModal({
    super.key,
    this.targetKarigor,
    this.seekerId,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    ProviderModel? karigor,
    int? seekerId,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestJobModal(
        targetKarigor: karigor,
        seekerId: seekerId,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<RequestJobModal> createState() => _RequestJobModalState();
}

class _RequestJobModalState extends State<RequestJobModal> {
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _locController.text = "পবনা, শহর এলাকা";
  }

  @override
  void dispose() {
    _descController.dispose();
    _locController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final desc = _descController.text.trim();
    final loc = _locController.text.trim();
    final budgetStr = _budgetController.text.trim();

    if (desc.isEmpty || loc.isEmpty || budgetStr.isEmpty) {
      setState(() {
        _errorMessage = "অনুগ্রহ করে কাজের বিবরণ, ঠিকানা এবং বাজেট — সবগুলো পূরণ করুন।";
      });
      return;
    }

    final amount = double.tryParse(budgetStr);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = "সঠিক বাজেট পরিমাণ লিখুন।";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    final repo = KarigorRepository();

    await repo.sendRequest(
      seekerId: widget.seekerId,
      karigor: widget.targetKarigor,
      description: desc,
      location: loc,
      amount: amount,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.targetKarigor != null
              ? "${widget.targetKarigor!.name} কে অনুরোধ পাঠানো হয়েছে!"
              : "অনুরোধ পাঠানো হয়েছে!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'কাজের অনুরোধ পাঠান',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                  fontFamily: 'Baloo Da 2',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.targetKarigor != null
                    ? 'প্রাপক: ${widget.targetKarigor!.name} (${widget.targetKarigor!.category})'
                    : 'প্রাপক: সাধারণ অনুরোধ',
                style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              const Text(
                'কাজের বিবরণ',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'আপনার সমস্যাটি বিস্তারিত লিখুন...',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'আপনার ঠিকানা',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _locController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.inkSoft),
                  hintText: 'যেমন: পবনা, শহর এলাকা',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'বাজেট / অফারকৃত টাকা',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text('৳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.inkSoft)),
                  ),
                  hintText: 'যেমন: ৫০০',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: AppColors.clayBg,
                        side: const BorderSide(color: AppColors.line),
                      ),
                      child: const Text('বাতিল', style: TextStyle(color: AppColors.inkSoft)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: AppColors.terracotta,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('পাঠান'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
