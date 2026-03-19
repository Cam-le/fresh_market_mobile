import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Address {
  String id, name, phone, address, label;
  bool isDefault;

  _Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.label,
    this.isDefault = false,
  });
}

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final List<_Address> _addresses = [
    _Address(
      id: '1',
      name: 'Nguyễn Văn A',
      phone: '0901 234 567',
      address: '123 Nguyễn Huệ, P. Bến Nghé, Q.1, TP.HCM',
      label: 'Nhà',
      isDefault: true,
    ),
    _Address(
      id: '2',
      name: 'Nguyễn Văn A',
      phone: '0901 234 567',
      address: '456 Lê Lợi, P. Bến Thành, Q.1, TP.HCM',
      label: 'Văn phòng',
    ),
  ];

  void _showAddressForm({_Address? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    String label = existing?.label ?? 'Nhà';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(existing == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              // Label chips
              Row(
                children: ['Nhà', 'Văn phòng', 'Khác']
                    .map((l) => GestureDetector(
                          onTap: () => setModal(() => label = l),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: label == l
                                  ? AppTheme.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: label == l
                                      ? AppTheme.primaryGreen
                                      : const Color(0xFFE0E0E0)),
                            ),
                            child: Text(l,
                                style: TextStyle(
                                  color: label == l
                                      ? Colors.white
                                      : AppTheme.textGray,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              _buildField('Họ và tên', nameCtrl, Icons.person_outline),
              const SizedBox(height: 12),
              _buildField('Số điện thoại', phoneCtrl, Icons.phone_outlined,
                  type: TextInputType.phone),
              const SizedBox(height: 12),
              _buildField('Địa chỉ chi tiết', addrCtrl, Icons.home_outlined,
                  maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (existing == null) {
                      setState(() => _addresses.add(_Address(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameCtrl.text,
                            phone: phoneCtrl.text,
                            address: addrCtrl.text,
                            label: label,
                          )));
                    } else {
                      setState(() {
                        existing.name = nameCtrl.text;
                        existing.phone = phoneCtrl.text;
                        existing.address = addrCtrl.text;
                        existing.label = label;
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                      existing == null ? 'Thêm địa chỉ' : 'Lưu thay đổi',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textLight),
        labelStyle: const TextStyle(fontSize: 13, color: AppTheme.textGray),
        floatingLabelStyle: const TextStyle(color: AppTheme.primaryGreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ giao hàng')),
      body: Column(
        children: [
          Expanded(
            child: _addresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('Chưa có địa chỉ nào',
                            style: TextStyle(color: AppTheme.textGray)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final addr = _addresses[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: addr.isDefault
                              ? Border.all(
                                  color: AppTheme.primaryGreen, width: 1.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6)
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  addr.label == 'Nhà'
                                      ? Icons.home_outlined
                                      : addr.label == 'Văn phòng'
                                          ? Icons.business_outlined
                                          : Icons.location_on_outlined,
                                  color: AppTheme.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGreen
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(addr.label,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.primaryGreen,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        if (addr.isDefault) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentOrange
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text('Mặc định',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppTheme.accentOrange,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('${addr.name} | ${addr.phone}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text(addr.address,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textGray,
                                            height: 1.4)),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    size: 18, color: AppTheme.textLight),
                                onSelected: (v) {
                                  if (v == 'edit') {
                                    _showAddressForm(existing: addr);
                                  }
                                  if (v == 'default') {
                                    setState(() {
                                      for (final a in _addresses) {
                                        a.isDefault = false;
                                      }
                                      addr.isDefault = true;
                                    });
                                  }
                                  if (v == 'delete') {
                                    setState(() => _addresses.remove(addr));
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Chỉnh sửa')),
                                  if (!addr.isDefault)
                                    const PopupMenuItem(
                                        value: 'default',
                                        child: Text('Đặt làm mặc định')),
                                  const PopupMenuItem(
                                      value: 'delete', child: Text('Xoá')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _showAddressForm(),
                icon: const Icon(Icons.add_location_alt_outlined,
                    color: AppTheme.primaryGreen),
                label: const Text('Thêm địa chỉ mới',
                    style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
