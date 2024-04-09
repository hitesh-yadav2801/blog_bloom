import 'package:blog_bloom/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_bloom/core/common/widgets/loader.dart';
import 'package:blog_bloom/core/theme/app_palette.dart';
import 'package:blog_bloom/core/utils/show_alert_dialog.dart';
import 'package:blog_bloom/core/utils/show_snackbar.dart';
import 'package:blog_bloom/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:blog_bloom/features/auth/presentation/pages/login_page.dart';
import 'package:blog_bloom/features/blog/presentation/pages/my_blogs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          showSnackBar(context, state.message);
        } else if (state is AuthLogoutSuccessState) {
          Navigator.pushAndRemoveUntil(
            context,
            LoginPage.route(),
                (route) => false,
          );
        }
      },
      builder: (context, state) {
        final userName =
            (context.read<AppUserCubit>().state as AppUserLoggedInState).user.name;

        return Drawer(
          backgroundColor: AppPalette.backgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppPalette.gradient1,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName.isNotEmpty ? userName : 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('My Blogs'),
                leading: const Icon(Icons.book),
                onTap: () {
                  Navigator.push(
                    context,
                    MyBlogsPage.route(),
                  );
                },
              ),
              ListTile(
                title: const Text('Logout'),
                leading: const Icon(Icons.logout_rounded),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoadingState) {
                            return const Loader();
                          }
                          return CustomAlertDialog(
                            title: 'Logout',
                            content: 'Are you sure you want to logout?',
                            confirmText: 'Logout',
                            cancelText: 'Cancel',
                            onConfirm: () {
                              context.read<AuthBloc>().add(AuthLogoutEvent());
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
