import 'package:com.maklaar.app/data/model/home/home_slider.dart';
import 'package:com.maklaar.app/settings.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:com.maklaar.app/utils/custom_exception.dart';
import 'package:com.maklaar.app/utils/network/network_availability.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SliderState {}

class SliderInitial extends SliderState {}

class SliderFetchInProgress extends SliderState {}

class SliderFetchInInternalProgress extends SliderState {}

class SliderFetchSuccess extends SliderState {
  List<HomeSlider> sliderlist = [];

  SliderFetchSuccess(this.sliderlist);

  factory SliderFetchSuccess.fromMap(Map<String, dynamic> map) {
    return SliderFetchSuccess(
      List<HomeSlider>.from(
        (map['sliderlist']).map<HomeSlider>(
          (x) => HomeSlider.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class SliderFetchFailure extends SliderState {
  final String errorMessage;
  final bool isUserDeactivated;

  SliderFetchFailure(this.errorMessage, this.isUserDeactivated);
}

class SliderCubit extends Cubit<SliderState> {
  SliderCubit() : super(SliderInitial());

  /// =================================================================
  ///                       BAGIAN YANG DIPERBAIKI
  /// =================================================================
  ///
  /// Kode di bawah ini telah ditulis ulang untuk mengatasi masalah logika
  /// yang memblokir dan penanganan error yang tidak andal.
  ///
  Future<void> fetchSlider(
      BuildContext context, {
        bool? forceRefresh,
        bool? loadWithoutDelay, // Parameter ini dipertahankan, tapi tidak lagi digunakan secara aktif
      }) async {
    // 1. Tentukan kapan harus menampilkan state loading.
    // Tampilkan loading jika ini pemuatan pertama ATAU jika refresh dipaksa.
    if (state is! SliderFetchSuccess || forceRefresh == true) {
      emit(SliderFetchInProgress());
    }

    try {
      // 2. Selalu coba ambil data terbaru dari API.
      // Fungsi fetchSliderFromDb yang sudah diperbaiki akan dipanggil di sini.
      final List<HomeSlider> sliders = await fetchSliderFromDb();

      // 3. Jika berhasil, emit state Success dengan data baru.
      // Ini akan memperbarui UI dengan data yang baru saja diambil.
      emit(SliderFetchSuccess(sliders));
    } catch (e) {
      // 4. Jika terjadi error APA PUN, tangkap di sini.
      if (isClosed) return; // Pastikan cubit belum ditutup.

      // Periksa apakah pesan error adalah tentang deaktivasi akun.
      final bool isDeactivated = e
          .toString()
          .toLowerCase()
          .contains("your account has been deactivate");

      // Emit state Failure dengan informasi yang relevan.
      emit(SliderFetchFailure(e.toString(), isDeactivated));
    }
  }



  /// =================================================================
  ///              FUNGSI HELPER YANG JUGA DIPERBAIKI
  /// =================================================================
  ///
  /// Fungsi ini disederhanakan untuk lebih fokus dan andal dalam
  /// mengambil dan mem-parsing data.
  ///
  Future<List<HomeSlider>> fetchSliderFromDb() async {
    // Panggil API. Jika gagal (misalnya tidak ada internet),
    // Api.get akan melempar error dan akan ditangkap oleh try-catch di fetchSlider.
    final Map<String, dynamic> response =
    await Api.get(url: Api.getSliderApi, queryParameters: {});

    // Periksa apakah respons dari server berisi error.
    if (response[Api.error] == true) {
      // Jika ya, lempar error dengan pesan dari API.
      // Ini juga akan ditangkap oleh try-catch di fetchSlider.
      throw CustomException(response[Api.message] ?? 'Unknown API error');
    }

    // Jika tidak ada error, lanjutkan proses parsing.
    final List<dynamic> dataList = response['data'] as List;
    final List<HomeSlider> sliderList =
    dataList.map((model) => HomeSlider.fromJson(model)).toList();

    return sliderList;
  }

  /// =================================================================
  ///                       BAGIAN YANG TIDAK DIUBAH
  /// =================================================================
  SliderState? fromJson(Map<String, dynamic> json) {
    try {
      return SliderFetchSuccess.fromMap(json);
    } catch (e) {
      return null;
    }
  }
}
