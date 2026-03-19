import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Notification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final _NotifType type;
  bool isRead;

  _Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum _NotifType { order, promo, system, delivery }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_Notification> _all = [
    _Notification(
      id: '1',
      title: 'Đơn hàng đã được xác nhận ✅',
      body:
          'Đơn hàng #ORD001 của bạn đã được xác nhận. Dự kiến giao hàng trong 2–4 giờ.',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: _NotifType.order,
    ),
    _Notification(
      id: '2',
      title: '🚚 Đơn hàng đang được giao',
      body:
          'Shipper đang trên đường giao đơn hàng #ORD001 đến bạn. Vui lòng giữ điện thoại.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: _NotifType.delivery,
    ),
    _Notification(
      id: '3',
      title: '🎉 Flash Sale hôm nay – Giảm 40%',
      body:
          'Rau củ quả tươi giảm đến 40% chỉ hôm nay. Đừng bỏ lỡ! Áp dụng đến 23:59.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: _NotifType.promo,
      isRead: true,
    ),
    _Notification(
      id: '4',
      title: 'Mã giảm giá mới cho bạn 🎁',
      body:
          'Bạn nhận được mã WELCOME50 giảm 50k cho đơn từ 200k. Hạn sử dụng: 7 ngày.',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      type: _NotifType.promo,
      isRead: true,
    ),
    _Notification(
      id: '5',
      title: 'Đơn hàng đã giao thành công 🎊',
      body:
          'Đơn hàng #ORD000 đã được giao thành công. Hãy đánh giá sản phẩm nhé!',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: _NotifType.order,
      isRead: true,
    ),
    _Notification(
      id: '6',
      title: 'Cập nhật ứng dụng mới',
      body:
          'Phiên bản 2.1 đã sẵn sàng. Nhiều tính năng mới và cải tiến hiệu suất.',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: _NotifType.system,
      isRead: true,
    ),
    _Notification(
      id: '7',
      title: '🌿 Rau hữu cơ vừa về hàng',
      body: 'Lô rau hữu cơ mới nhất vừa về kho. Đặt hàng ngay kẻo hết!',
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: _NotifType.promo,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Notification> get _unread => _all.where((n) => !n.isRead).toList();
  List<_Notification> get _promos =>
      _all.where((n) => n.type == _NotifType.promo).toList();

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  Color _typeColor(_NotifType type) {
    switch (type) {
      case _NotifType.order:
        return AppTheme.primaryGreen;
      case _NotifType.delivery:
        return AppTheme.accentOrange;
      case _NotifType.promo:
        return const Color(0xFF7B1FA2);
      case _NotifType.system:
        return Colors.blueGrey;
    }
  }

  IconData _typeIcon(_NotifType type) {
    switch (type) {
      case _NotifType.order:
        return Icons.shopping_bag_outlined;
      case _NotifType.delivery:
        return Icons.local_shipping_outlined;
      case _NotifType.promo:
        return Icons.local_offer_outlined;
      case _NotifType.system:
        return Icons.info_outline;
    }
  }

  Widget _buildList(List<_Notification> notifs) {
    if (notifs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text('Không có thông báo',
                style: TextStyle(color: AppTheme.textGray, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifs.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, i) {
        final n = notifs[i];
        final color = _typeColor(n.type);
        return Dismissible(
          key: Key(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppTheme.discountRed,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) =>
              setState(() => _all.removeWhere((x) => x.id == n.id)),
          child: InkWell(
            onTap: () => setState(() => n.isRead = true),
            child: Container(
              color:
                  n.isRead ? Colors.transparent : color.withValues(alpha: 0.04),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_typeIcon(n.type), size: 22, color: color),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: n.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textGray,
                              height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _timeAgo(n.time),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _unread.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo${unreadCount > 0 ? ' ($unreadCount)' : ''}'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => setState(() {
                for (final n in _all) {
                  n.isRead = true;
                }
              }),
              child: const Text('Đọc tất cả',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Tất cả (${_all.length})'),
            Tab(text: unreadCount > 0 ? 'Chưa đọc ($unreadCount)' : 'Chưa đọc'),
            const Tab(text: 'Khuyến mãi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_all),
          _buildList(_unread),
          _buildList(_promos),
        ],
      ),
    );
  }
}
