import 'package:charge_station_finder/application/admin/admin_bloc.dart';
import 'package:charge_station_finder/application/auth/auth_bloc.dart';
import 'package:charge_station_finder/application/home/home_bloc.dart';
import 'package:charge_station_finder/domain/charger/charger_repository_interface.dart';
import 'package:charge_station_finder/domain/contracts/IAuthRepository.dart';
import 'package:charge_station_finder/domain/review/review_repository_interface.dart';
import 'package:charge_station_finder/presentation/routes/routeConfig.dart';
import 'package:charge_station_finder/utils/custom_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'infrastructure/admin/admin_repository.dart';
import 'infrastructure/repository/authRepository.dart';
import 'infrastructure/repository/charger_repository_impl.dart';
import 'infrastructure/repository/review_repository_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var httpClient = CustomHttpClient();
    var reviewRepository = ReviewRepositoryImpl(httpClient: httpClient);
    var chargerRepository = ChargerRepositoryImpl(
        httpClient: httpClient, reviewRepository: reviewRepository);
    var authenticationRepository =
        AuthenticationRepository(httpClient: httpClient);

    var adminRepository = AdminRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ReviewRepositoryInterface>(
            create: (context) => reviewRepository),
        RepositoryProvider<ChargerRepositoryInterface>(
            create: (context) => chargerRepository),
        RepositoryProvider<IAuthenticationRepository>(
          create: (context) => authenticationRepository,
        ),
      ],
      child: MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(
              create: (context) =>
                  HomeBloc(chargerRepository: chargerRepository),
            ),
            BlocProvider<AdminBloc>(
              create: (context) => AdminBloc(adminRepository: adminRepository)
                ..add(AdminGetUsersEvent()),
            ),
            BlocProvider<AuthenticationBloc>(
                create: (context) =>
                    AuthenticationBloc(authRepository: authenticationRepository)
                      ..add(GetUserAuthCredentialEvent())),
          ],
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
              listener: (_, state) {
            // if (state is UserAuthenticated ||
            //     state is AdminAuthenticated ||
            //     state is ProviderAuthenticated) {
            //   httpClient.authToken =
            //       (state as Authenticated).userData!.token;
            // }
          }, builder: (context, state) {
            return RouterMain(
              authBloc: context.read(),
            );
          })),
    );
  }
}
