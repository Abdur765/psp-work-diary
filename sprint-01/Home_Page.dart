import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elaros_mobile_app/ui/home/view_models/health_view_model.dart';
import 'package:elaros_mobile_app/ui/core/graphs/bar_chart.dart' as custom_bar;
import 'package:elaros_mobile_app/ui/core/graphs/base_chart.dart';

// Figma colors
const _bgColor = Color(0xfff9fafb);
const _cardBg = Colors.white;
const _textPrimary = Color(0xff111827);
const _textSecondary = Color(0xff6b7280);
const _border = Color(0xffe5e7eb);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: _bgColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xff3b82f6)),
                  SizedBox(height: 16),
                  Text('Loading health data...', style: TextStyle(color: _textSecondary)),
                ],
              ),
            ),
          );
        }

        if (vm.error != null) {
          return Scaffold(
            backgroundColor: _bgColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xffef4444)),
                  const SizedBox(height: 16),
                  Text('Error: ${vm.error}',
                      textAlign: TextAlign.center, style: const TextStyle(color: _textPrimary, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.loadAllData(),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff3b82f6)),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        final zone = vm.currentZone;
        final now = DateTime.now();
        const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        final dateStr = '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              color: const Color(0xff3b82f6),
              onRefresh: () => vm.loadAllData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER - Blue gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff3b82f6), Color(0xff1e3a8a)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Elaros",
                              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text("Today's Overview",
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(dateStr,
                              style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),

                    // CURRENT STATUS CARD (overlaps header slightly)
                    Transform.translate(
                      offset: const Offset(0, -4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildCurrentZoneCard(vm, zone),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // KEY METRICS
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text("Key Metrics",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMetricsGrid(vm),
                    ),
                    const SizedBox(height: 24),

                    // HEART RATE THROUGHOUT DAY
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildChartCard(
                        title: "Heart Rate Throughout Day",
                        caption: "Colors represent different activity zones",
                        child: vm.hourlyHeartRate.isNotEmpty
                            ? SizedBox(
                                height: 200,
                                child: custom_bar.BarChart(
                                  data: vm.hourlyHeartRate,
                                  mappingKeyX: 'hour',
                                  mappingKeyY: 'avgHR',
                                  darkTheme: false,
                                  xAxisTitle: 'Hour',
                                  yAxisTitle: 'HR (bpm)',
                                  legendPosition: null,
                                ),
                              )
                            : _noData(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ACTIVITY BY HOUR (Steps)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildChartCard(
                        title: "Daily Steps",
                        caption: "Step count distribution shows periods of activity and rest",
                        child: vm.dailySteps.isNotEmpty
                            ? SizedBox(
                                height: 200,
                                child: custom_bar.BarChart(
                                  data: vm.dailySteps,
                                  mappingKeyX: 'date',
                                  mappingKeyY: 'steps',
                                  darkTheme: false,
                                  xAxisTitle: 'Date',
                                  yAxisTitle: 'Steps',
                                  xScaleType: ScaleType.ordinal,
                                  legendPosition: null,
                                ),
                              )
                            : _noData(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CALORIES CHART
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildChartCard(
                        title: "Daily Calories Burned",
                        caption: "Calorie expenditure over the last 7 days",
                        child: vm.dailyCalories.isNotEmpty
                            ? SizedBox(
                                height: 200,
                                child: custom_bar.BarChart(
                                  data: vm.dailyCalories,
                                  mappingKeyX: 'date',
                                  mappingKeyY: 'calories',
                                  darkTheme: false,
                                  xAxisTitle: 'Date',
                                  yAxisTitle: 'Calories',
                                  xScaleType: ScaleType.ordinal,
                                  legendPosition: null,
                                ),
                              )
                            : _noData(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SLEEP SUMMARY
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSleepCard(vm),
                    ),
                    const SizedBox(height: 16),

                    // TIME IN EACH ZONE
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text("Time in Each Zone",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildZoneCards(vm),
                    ),

                    const SizedBox(height: 96), // Bottom nav clearance
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentZoneCard(HealthViewModel vm, HRZone zone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withValues(alpha: 0.08), offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Zone info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Zone", style: TextStyle(fontSize: 12, color: Color(0xff4b5563))),
                  const SizedBox(height: 4),
                  Text("Zone ${zone.number}",
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: _textPrimary)),
                ],
              ),
              // Right: Heart icon circle
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: zone.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: zone.color, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Recovery Score", style: TextStyle(fontSize: 12, color: _textSecondary)),
                    const SizedBox(height: 2),
                    Text("${vm.recoveryScore}%",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Current HR", style: TextStyle(fontSize: 12, color: _textSecondary)),
                    const SizedBox(height: 2),
                    Text("${vm.latestHR} bpm",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(HealthViewModel vm) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          icon: Icons.favorite, iconColor: const Color(0xffef4444),
          label: "Resting HR", value: "${vm.minHR}", unit: "bpm",
        ),
        _MetricCard(
          icon: Icons.directions_walk, iconColor: const Color(0xff3b82f6),
          label: "Total Steps", value: vm.formatNumber(vm.todaySteps), unit: null,
        ),
        _MetricCard(
          icon: Icons.show_chart, iconColor: const Color(0xff8b5cf6),
          label: "Avg HR", value: "${vm.avgHR}", unit: "bpm",
        ),
        _MetricCard(
          icon: Icons.local_fire_department, iconColor: const Color(0xff10b981),
          label: "Calories", value: vm.todayCalories.toStringAsFixed(0), unit: "kcal",
        ),
      ],
    );
  }

  Widget _buildChartCard({required String title, String? caption, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(height: 16),
          child,
          if (caption != null) ...[
            const SizedBox(height: 8),
            Text(caption, style: const TextStyle(fontSize: 11, color: _textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepCard(HealthViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bedtime, color: Color(0xff6366f1), size: 20),
              SizedBox(width: 8),
              Text("Sleep Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SleepStat(label: "Total", value: vm.sleepDuration),
              _SleepStat(label: "Asleep", value: "${vm.sleepAsleepMinutes}m"),
              _SleepStat(label: "Restless", value: "${vm.sleepRestlessMinutes}m"),
              _SleepStat(label: "Awake", value: "${vm.sleepAwakeMinutes}m"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCards(HealthViewModel vm) {
    return Column(
      children: hrZoneDefinitions.map((zone) {
        final isActive = zone.number == vm.currentZone.number;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? zone.bgColor : _cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActive ? zone.color : _border, width: isActive ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: zone.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Zone ${zone.number} - ${zone.name}",
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: isActive ? zone.textColor : _textPrimary,
                          )),
                      if (isActive)
                        Text(zone.description,
                            style: TextStyle(fontSize: 12, color: zone.textColor.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                if (isActive)
                  Icon(Icons.check_circle, color: zone.color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _noData() {
    return const SizedBox(
      height: 60,
      child: Center(child: Text('No data available', style: TextStyle(color: _textSecondary, fontSize: 12))),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit;

  const _MetricCard({required this.icon, required this.iconColor, required this.label, required this.value, this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary)),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(unit!, style: const TextStyle(fontSize: 12, color: _textSecondary)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepStat extends StatelessWidget {
  final String label;
  final String value;

  const _SleepStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary)),
        ],
      ),
    );
  }
}
