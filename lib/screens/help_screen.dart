import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;
  final _msgCtrl = TextEditingController();

  static const _faqs = [
    _Faq(
      q: 'Tôi có thể huỷ đơn hàng sau khi đặt không?',
      a: 'Bạn có thể huỷ đơn hàng trong vòng 30 phút sau khi đặt, miễn là đơn chưa được xác nhận giao. '
          'Vào mục Đơn hàng → chọn đơn → bấm "Huỷ đơn hàng".',
    ),
    _Faq(
      q: 'Thời gian giao hàng là bao lâu?',
      a: 'Chúng tôi giao hàng trong 2–4 giờ với đơn đặt trước 14:00. '
          'Đơn đặt sau 14:00 sẽ được giao vào sáng hôm sau (7:00–11:00).',
    ),
    _Faq(
      q: 'Hàng tươi sống được bảo quản thế nào khi giao?',
      a: 'Thực phẩm được đóng gói trong túi giữ lạnh chuyên dụng, đảm bảo nhiệt độ 4–8°C trong suốt quá trình vận chuyển. '
          'Thịt và hải sản có thêm đá khô.',
    ),
    _Faq(
      q: 'Tôi có thể đổi trả hàng không?',
      a: 'Chúng tôi chấp nhận đổi trả trong vòng 24 giờ nếu sản phẩm không đúng mô tả, bị hư hỏng, hoặc thiếu số lượng. '
          'Chụp ảnh sản phẩm và liên hệ hotline 1800 1234.',
    ),
    _Faq(
      q: 'Phí vận chuyển được tính như thế nào?',
      a: 'Miễn phí giao hàng cho đơn từ 200.000₫ trở lên. '
          'Đơn dưới 200.000₫ phụ thu 25.000₫ phí vận chuyển.',
    ),
    _Faq(
      q: 'Tôi có thể mua số lượng lớn cho nhà hàng/quán ăn không?',
      a: 'Có! Chúng tôi có chương trình B2B với giá ưu đãi cho đơn từ 2kg trở lên. '
          'Liên hệ b2b@ansachsongkhoe.vn để biết thêm chi tiết.',
    ),
    _Faq(
      q: 'Điểm tích lũy được tính như thế nào?',
      a: 'Mỗi 1.000₫ chi tiêu = 1 điểm. Điểm có thể đổi lấy mã giảm giá hoặc quà tặng. '
          'Điểm có hiệu lực trong 12 tháng kể từ ngày tích lũy.',
    ),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp & Hỗ trợ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Quick contact cards ────────────────────────────────────
          Row(
            children: [
              _ContactCard(
                icon: Icons.phone_outlined,
                label: 'Hotline',
                sub: '1800 1234',
                color: AppTheme.primaryGreen,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _ContactCard(
                icon: Icons.chat_bubble_outline,
                label: 'Chat trực tuyến',
                sub: 'Phản hồi ngay',
                color: const Color(0xFF1E88E5),
                onTap: () => _showChat(context),
              ),
              const SizedBox(width: 10),
              _ContactCard(
                icon: Icons.email_outlined,
                label: 'Email',
                sub: 'support@...',
                color: const Color(0xFF8E24AA),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── FAQ ────────────────────────────────────────────────────
          const Text('Câu hỏi thường gặp',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          ..._faqs.asMap().entries.map((e) {
            final i = e.key;
            final faq = e.value;
            final expanded = _expandedIndex == i;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: expanded
                        ? AppTheme.primaryGreen.withValues(alpha: 0.4)
                        : const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  onExpansionChanged: (v) =>
                      setState(() => _expandedIndex = v ? i : null),
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreen)),
                    ),
                  ),
                  title: Text(faq.q,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              expanded ? FontWeight.w700 : FontWeight.w500,
                          color: expanded
                              ? AppTheme.primaryGreen
                              : AppTheme.textDark)),
                  iconColor: AppTheme.primaryGreen,
                  collapsedIconColor: AppTheme.textLight,
                  children: [
                    Text(faq.a,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGray,
                            height: 1.65)),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── Support ticket ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.support_agent,
                      color: AppTheme.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text('Gửi yêu cầu hỗ trợ',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 14),
                // Category
                DropdownButtonFormField<String>(
                  value: 'Vấn đề đơn hàng',
                  decoration: const InputDecoration(
                    labelText: 'Loại vấn đề',
                    prefixIcon: Icon(Icons.category_outlined, size: 18),
                  ),
                  items: [
                    'Vấn đề đơn hàng',
                    'Sản phẩm lỗi',
                    'Thanh toán',
                    'Tài khoản',
                    'Khác'
                  ]
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 14))))
                      .toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả vấn đề',
                    hintText: 'Mô tả chi tiết vấn đề bạn gặp phải...',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.edit_outlined, size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _msgCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            '✅ Yêu cầu hỗ trợ đã được gửi! Chúng tôi sẽ phản hồi trong 24 giờ.'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: const Text('Gửi yêu cầu',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.support_agent,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hỗ trợ trực tuyến',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      Text('● Đang hoạt động',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _ChatBubble(
                    text:
                        'Xin chào! Tôi là trợ lý hỗ trợ của Ăn Sạch Sống Khỏe. Tôi có thể giúp gì cho bạn?',
                    isMe: false,
                    time: 'Vừa xong',
                  ),
                  _ChatBubble(
                      text: 'Tôi muốn hỏi về đơn hàng của mình',
                      isMe: true,
                      time: 'Vừa xong'),
                  _ChatBubble(
                    text:
                        'Bạn vui lòng cung cấp mã đơn hàng (bắt đầu bằng ORD) để tôi kiểm tra nhé!',
                    isMe: false,
                    time: 'Vừa xong',
                  ),
                ],
              ),
            ),
            // Input
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 8,
                      offset: Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: AppTheme.textLight),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color),
                    textAlign: TextAlign.center),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textLight),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _ChatBubble(
      {required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryGreen,
                child: Icon(Icons.support_agent, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppTheme.primaryGreen
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Text(text,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: isMe ? Colors.white : AppTheme.textDark)),
                  ),
                  const SizedBox(height: 3),
                  Text(time,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textLight)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Faq {
  final String q;
  final String a;
  const _Faq({required this.q, required this.a});
}
