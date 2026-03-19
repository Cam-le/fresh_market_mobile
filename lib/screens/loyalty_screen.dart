import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const int _totalPoints = 1250;
  static const int _nextTierPoints = 2000;

  // static final (not const) because Color is not a const value at compile time
  static final List<_PointEvent> _history = [
    _PointEvent(
        title: 'Đơn hàng #ORD001',
        points: 150,
        date: '15/03/2026',
        type: _EventType.earn),
    _PointEvent(
        title: 'Đổi mã giảm giá 50k',
        points: -500,
        date: '10/03/2026',
        type: _EventType.redeem),
    _PointEvent(
        title: 'Đơn hàng #ORD002',
        points: 200,
        date: '05/03/2026',
        type: _EventType.earn),
    _PointEvent(
        title: 'Bonus thành viên tháng',
        points: 100,
        date: '01/03/2026',
        type: _EventType.bonus),
    _PointEvent(
        title: 'Đơn hàng #ORD003',
        points: 320,
        date: '22/02/2026',
        type: _EventType.earn),
    _PointEvent(
        title: 'Đổi quà tặng',
        points: -200,
        date: '15/02/2026',
        type: _EventType.redeem),
    _PointEvent(
        title: 'Đăng ký tài khoản',
        points: 100,
        date: '01/02/2026',
        type: _EventType.bonus),
    _PointEvent(
        title: 'Đơn hàng #ORD004',
        points: 80,
        date: '20/01/2026',
        type: _EventType.earn),
  ];

  static final List<_Reward> _rewards = [
    _Reward(
        title: 'Giảm 20.000₫',
        cost: 200,
        icon: Icons.local_offer_outlined,
        color: const Color(0xFF43A047)),
    _Reward(
        title: 'Giảm 50.000₫',
        cost: 500,
        icon: Icons.discount_outlined,
        color: const Color(0xFF1E88E5)),
    _Reward(
        title: 'Freeship 1 lần',
        cost: 250,
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFFF5A623)),
    _Reward(
        title: 'Giảm 100.000₫',
        cost: 1000,
        icon: Icons.card_giftcard,
        color: const Color(0xFF8E24AA)),
    _Reward(
        title: 'Giỏ rau sạch 200k',
        cost: 1500,
        icon: Icons.shopping_basket_outlined,
        color: const Color(0xFF5B8A3C)),
    _Reward(
        title: 'VIP 1 tháng',
        cost: 2000,
        icon: Icons.workspace_premium,
        color: const Color(0xFFFB8C00)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm tích lũy'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Đổi điểm'),
            Tab(text: 'Lịch sử'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPointsHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRewardsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHeader() {
    const pct = _totalPoints / _nextTierPoints;

    return Container(
      color: AppTheme.primaryGreen,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          // Points display
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.stars, color: AppTheme.accentOrange, size: 32),
              SizedBox(width: 8),
              Text(
                '$_totalPoints',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  ' điểm',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tier progress
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    _TierBadge(
                      label: 'VIP',
                      color: AppTheme.accentOrange,
                      isActive: true,
                    ),
                    Expanded(child: SizedBox()),
                    _TierBadge(
                      label: 'VIP+',
                      color: Color(0xFFAB47BC),
                      isActive: false,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.accentOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cần thêm ${_nextTierPoints - _totalPoints} điểm để lên hạng VIP+',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // How to earn
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EarnTip(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Mua hàng\n+1đ/1.000₫'),
              _EarnTip(
                  icon: Icons.rate_review_outlined,
                  label: 'Đánh giá\n+10đ/lần'),
              _EarnTip(
                  icon: Icons.person_add_outlined,
                  label: 'Giới thiệu\n+100đ/bạn'),
              _EarnTip(
                  icon: Icons.celebration_outlined, label: 'Sinh nhật\n+200đ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Đổi điểm lấy ưu đãi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _rewards.length,
          itemBuilder: (_, i) => _RewardCard(
            reward: _rewards[i],
            canAfford: _totalPoints >= _rewards[i].cost,
            onRedeem: () {
              if (_totalPoints >= _rewards[i].cost) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Đổi ${_rewards[i].title}?'),
                    content: Text(
                      'Bạn sẽ dùng ${_rewards[i].cost} điểm để đổi ưu đãi này.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Huỷ'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Đã đổi ${_rewards[i].title} thành công!',
                              ),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (_, i) {
        final e = _history[i];
        final isEarn = e.points > 0;
        final color = e.type == _EventType.bonus
            ? const Color(0xFF1E88E5)
            : isEarn
                ? AppTheme.primaryGreen
                : AppTheme.discountRed;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  e.type == _EventType.earn
                      ? Icons.shopping_bag_outlined
                      : e.type == _EventType.bonus
                          ? Icons.card_giftcard_outlined
                          : Icons.redeem,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      e.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isEarn ? '+' : ''}${e.points} điểm',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────

enum _EventType { earn, redeem, bonus }

class _PointEvent {
  final String title;
  final int points;
  final String date;
  final _EventType type;

  // NOT const because it's used inside a static final list with runtime Color values
  _PointEvent({
    required this.title,
    required this.points,
    required this.date,
    required this.type,
  });
}

class _Reward {
  final String title;
  final int cost;
  final IconData icon;
  final Color color;

  // NOT const — Color instances are not compile-time constants
  _Reward({
    required this.title,
    required this.cost,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  const _TierBadge({
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EarnTip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EarnTip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final _Reward reward;
  final bool canAfford;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.reward,
    required this.canAfford,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: canAfford
            ? Border.all(color: reward.color.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (!canAfford)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: reward.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(reward.icon, color: reward.color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.stars,
                        size: 14, color: AppTheme.accentOrange),
                    const SizedBox(width: 3),
                    Text(
                      '${reward.cost} điểm',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRedeem,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: canAfford ? reward.color : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Đổi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: canAfford ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
