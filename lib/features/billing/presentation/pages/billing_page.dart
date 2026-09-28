import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_view.dart';
import '../bloc/billing_bloc.dart';
import '../../domain/entities/invoice.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<BillingBloc>()
        .add(const LoadInvoicesEvent('current_user_id'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.billing)),
      body: BlocBuilder<BillingBloc, BillingState>(
        builder: (context, state) {
          if (state is BillingLoading) {
            return const AppLoadingView(height: 300);
          }
          if (state is BillingError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<BillingBloc>().add(
                const LoadInvoicesEvent('current_user_id'),
              ),
            );
          }
          if (state is BillingEmpty) {
            return AppEmptyView(
              title: l10n.billing,
              subtitle: 'No invoices found.',
              icon: Icons.receipt_outlined,
            );
          }
          if (state is BillingLoaded) {
            final total = state.invoices
                .fold<double>(0, (sum, i) => sum + i.totalAmount);
            final unpaid = state.invoices
                .where((i) => !i.isPaid)
                .fold<double>(0, (sum, i) => sum + i.balanceDue);

            return Column(
              children: [
                // Summary card
                Padding(
                  padding: const EdgeInsetsDirectional.all(
                    AppDimensions.screenPaddingH,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: l10n.translate('amount'),
                          value: '${total.toInt()} SAR',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceM),
                      Expanded(
                        child: _SummaryCard(
                          label: l10n.translate('unpaid'),
                          value: '${unpaid.toInt()} SAR',
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppDimensions.screenPaddingH,
                    ),
                    itemCount: state.invoices.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.spaceM),
                    itemBuilder: (context, i) =>
                        InvoiceCard(invoice: state.invoices[i]),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final statusColor = invoice.isPaid
        ? AppColors.statusConfirmed
        : invoice.isOverdue
            ? AppColors.statusCancelled
            : AppColors.statusPending;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              Icons.receipt_outlined,
              color: statusColor,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormat(
                    'd MMM yyyy',
                    l10n.locale.languageCode,
                  ).format(invoice.issuedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${invoice.totalAmount.toInt()} SAR',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                ),
                child: Text(
                  invoice.isPaid
                      ? l10n.translate('paid')
                      : l10n.translate('unpaid'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
