import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/transactions_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/transactions_state.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/transaction_tile_new.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/transactions_empty_state.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2FA),
      bottomNavigationBar: const _BackToHomeButton(),
      body: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TransactionsStatus.failure) {
            return TransactionsErrorState(
              message: state.errorMessage ?? 'Failed to load transactions',
              onRetry: () => context.read<TransactionsCubit>().fetchTransactions(),
            );
          }

          if (!state.hasData) {
            return const TransactionsEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            itemCount: state.transactions.length,
            itemBuilder: (_, index) =>
                TransactionTileNew(transaction: state.transactions[index]),
          );
        },
      ),
    );
  }
}

class _BackToHomeButton extends StatelessWidget {
  const _BackToHomeButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.home),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 68.0, vertical: 20),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: const Text(
              'back to home page',
              style: TextStyle(
                color: Color(0xFF645D9C),
                fontSize: 15,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
