import 'package:blog_diego/feature/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_diego/feature/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:blog_diego/feature/auth/domain/repository/auth_repository.dart';
import 'package:blog_diego/feature/auth/domain/repository/auth_repository_impl.dart';
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
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(serviceLocator<SupabaseClient>()),
  );
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator()),
  );
  serviceLocator.registerFactory(() => UserSignUp(serviceLocator()));

  serviceLocator.registerFactory(() => UserLogin(serviceLocator()));

  serviceLocator.registerLazySingleton(
    () => AuthBloc(userSignUp: serviceLocator(), userLogin: serviceLocator()),
  );
}
