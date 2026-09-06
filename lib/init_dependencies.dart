import 'package:blog_diego/core/common/widgets/cubits/app_user/app_user_cubit.dart';
import 'package:blog_diego/feature/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_diego/feature/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:blog_diego/feature/auth/domain/repository/auth_repository.dart';
import 'package:blog_diego/feature/auth/domain/repository/auth_repository_impl.dart';
import 'package:blog_diego/feature/auth/domain/usecases/current_user.dart';
import 'package:blog_diego/feature/auth/domain/usecases/user_login.dart';
import 'package:blog_diego/feature/auth/domain/usecases/user_signup.dart';
import 'package:blog_diego/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];
  if (supabaseUrl == null || supabasePublishableKey == null) {
    throw StateError('Missing .env values');
  }

  _initAuth();

  final supabase = await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);
  //core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}
void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )

    
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}
