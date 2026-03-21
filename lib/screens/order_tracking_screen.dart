import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../theme/app_theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  static const List<_TrackStep> _steps = [
    _TrackStep(
      icon: Icons.check_circle,
      title: 'Đơn hàng đã đặt',
      subtitle: 'Đơn hàng của bạn đã được tiếp nhận',
      time: '08:32',
      status: _StepStatus.done,
    ),
    _TrackStep(
      icon: Icons.inventory_2_outlined,
      title: 'Đang chuẩn bị hàng',
      subtitle: 'Nhân viên đang đóng gói sản phẩm của bạn',
      time: '08:45',
      status: _StepStatus.done,
    ),
    _TrackStep(
      icon: Icons.local_shipping_outlined,
      title: 'Đang giao hàng',
      subtitle: 'Shipper Nguyễn Văn B đang trên đường đến',
      time: '09:10',
      status: _StepStatus.active,
    ),
    _TrackStep(
      icon: Icons.home_outlined,
      title: 'Giao hàng thành công',
      subtitle: 'Hàng sẽ được giao đến địa chỉ của bạn',
      time: '',
      status: _StepStatus.pending,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut);
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double p) =>
      p
          .toStringAsFixed(0)
          .replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.') +
      '₫';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi đơn hàng'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.headset_mic_outlined),
            tooltip: 'Liên hệ hỗ trợ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMapSection(),
            _buildOrderCard(),
            _buildTimeline(),
            _buildItemsList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMapSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapHeight = (constraints.maxWidth * 0.55).clamp(160.0, 240.0);
        final shipperLeft = constraints.maxWidth * 0.5;

        return Container(
          height: mapHeight,
          color: const Color(0xFFE8F5E9),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, mapHeight),
                painter: _MapGridPainter(),
              ),
              CustomPaint(
                size: Size(constraints.maxWidth, mapHeight),
                painter: _RoutePainter(),
              ),
              // Shipper pin
              Positioned(
                left: shipperLeft - 22,
                top: mapHeight * 0.36,
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentOrange.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.delivery_dining,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
              // Destination pin
              Positioned(
                right: 50,
                top: mapHeight * 0.16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8)
                        ],
                      ),
                      child: const Icon(Icons.home,
                          color: Colors.white, size: 18),
                    ),
                    Container(
                        width: 2, height: 10, color: AppTheme.primaryGreen),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
              // ETA chip
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8)
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: AppTheme.primaryGreen),
                      SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Dự kiến đến',
                              style: TextStyle(
                                  fontSize: 9, color: AppTheme.textGray)),
                          Text('10:30 - 11:00',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Shipper info card
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppTheme.accentOrange.withValues(alpha: 0.2),
                        child: const Icon(Icons.person,
                            color: AppTheme.accentOrange, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Nguyễn Văn B',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    size: 11, color: Color(0xFFFFC107)),
                                Text(' 4.9  •  Shipper',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textGray)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _CircleAction(
                          icon: Icons.phone_outlined, onTap: () {}),
                      const SizedBox(width: 8),
                      _CircleAction(
                          icon: Icons.chat_bubble_outline, onTap: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 16, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.order.id,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đang giao hàng',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentOrange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressAnim.value * 0.6,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accentOrange),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đã đặt',
                        style: TextStyle(
                            fontSize: 9, color: AppTheme.primaryGreen)),
                    const Text('Chuẩn bị',
                        style: TextStyle(
                            fontSize: 9, color: AppTheme.primaryGreen)),
                    const Text('Đang giao',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w700)),
                    Text('Đã giao',
                        style: TextStyle(
                            fontSize: 9, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppTheme.textLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.order.address,
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hành trình đơn hàng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            final isLast = i == _steps.length - 1;
            return _TimelineRow(step: step, isLast: isLast, index: i);
          }),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Sản phẩm đặt hàng',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${widget.order.items.length} sản phẩm',
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textGray)),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.order.items
              .map((item) => _ItemRow(item: item, formatPrice: _formatPrice)),
          const Divider(height: 20),
          Row(
            children: [
              const Text('Tổng thanh toán',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                _formatPrice(widget.order.total),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -3))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.headset_mic_outlined, size: 16),
              label: const Text('Hỗ trợ',
                  style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Huỷ đơn hàng',
                  style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 46),
                backgroundColor: AppTheme.discountRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepStatus { done, active, pending }

class _TrackStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final _StepStatus status;

  const _TrackStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
  });
}

class _TimelineRow extends StatelessWidget {
  final _TrackStep step;
  final bool isLast;
  final int index;

  const _TimelineRow(
      {required this.step, required this.isLast, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDone = step.status == _StepStatus.done;
    final isActive = step.status == _StepStatus.active;
    final color = isDone
        ? AppTheme.primaryGreen
        : isActive
            ? AppTheme.accentOrange
            : const Color(0xFFE0E0E0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(
                    alpha: isDone || isActive ? 0.15 : 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                    color: color, width: isActive ? 2 : 1.5),
              ),
              child: Icon(step.icon, size: 16, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isActive
                              ? AppTheme.accentOrange
                              : isDone
                                  ? AppTheme.textDark
                                  : AppTheme.textLight,
                        ),
                      ),
                    ),
                    if (step.time.isNotEmpty)
                      Text(step.time,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textLight)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? AppTheme.textGray
                        : AppTheme.textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  final String Function(double) formatPrice;

  const _ItemRow({required this.item, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 46, height: 46, color: const Color(0xFFE8F5E9)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${item.product.unit} × ${item.quantity}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textLight)),
              ],
            ),
          ),
          Text(formatPrice(item.subtotal),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }
}

// Custom painters for fake map
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0E8D0)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final blockPaint = Paint()..color = const Color(0xFFC5DFC5);
    canvas.drawRect(Rect.fromLTWH(36, 28, size.width * 0.2, size.height * 0.3),
        blockPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.4, size.height * 0.26,
            size.width * 0.14, size.height * 0.4),
        blockPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentOrange
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.52, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.28,
        size.width * 0.8,
        size.height * 0.2,
      );

    const dashWidth = 8.0;
    const dashSpace = 5.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(
          metric.extractPath(dist, dist + dashWidth),
          paint,
        );
        dist += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
