import 'dart:async';

import 'package:charge_station_finder/domain/admin/admin_model.dart';
import 'package:charge_station_finder/infrastructure/admin/admin_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminRepository adminRepository;

  AdminBloc({required this.adminRepository}) : super(AdminLoadingState()) {
    on<AdminCreateUserEvent>(((event, emit) async {
      try {
        emit(AdminLoadingState());
        await adminRepository.createUser(event.adminDomain);
        emit(AdminSuccessState(adminDomains: [event.adminDomain]));
      } catch (e) {
        emit(AdminFailureState(error: e.toString()));
      }
    }));

    on<AdminDeleteUserEvent>(((event, emit) async {
      debugPrint("AdminDeleteUserEvent");
      try {
        emit(AdminLoadingState());
        await adminRepository.deleteUser(event.id);
        event.adminDomains.removeWhere((element) => element.id == event.id);
        emit(AdminSuccessState(adminDomains: event.adminDomains));
      } catch (e) {
        emit(AdminFailureState(error: e));
      }
    }));

    on<AdminGetUsersEvent>(((event, emit) async {
      try {
        emit(AdminLoadingState());
        List<AdminDomain> adminDomains = await adminRepository.getUsers();
        print(adminDomains.length);
        print("\n\n\n\n\n\n\n\n\n\\n\n\n\n\n\n\n\n");
        emit(AdminSuccessState(adminDomains: adminDomains));
      } catch (e) {
        emit(AdminFailureState(error: e.toString()));
      }
    }));

    on<AdminUpdateUserEvent>(((event, emit) async {
      try {
        emit(AdminLoadingState());

        await adminRepository.editUser(event.adminDomain);

        for (var i = 0; i < event.adminDomains.length; i++) {
          if (event.adminDomain.id == event.adminDomains[i].id) {
            event.adminDomains[i] = event.adminDomain;
          }
        }

        emit(AdminSuccessState(adminDomains: event.adminDomains));
      } catch (e) {
        emit(AdminFailureState(error: e));
      }
    }));

    on<AdminUserDetailEvent>(((event, emit) async {
      try {
        emit(AdminLoadingState());
        await Timer(Duration(seconds: 2), () => print('two seconds'));
        // AdminDomain adminDomain = await adminRepository.getUser(event.adminDomain.id!);
        emit(AdminSuccessState(adminDomains: [event.adminDomain]));
      } catch (e) {
        emit(AdminFailureState(error: e));
      }
    }));
  }
}
