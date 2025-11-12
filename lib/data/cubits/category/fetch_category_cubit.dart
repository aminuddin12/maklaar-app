// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:developer';

import 'package:com.maklaar.app/data/model/category_model.dart';
import 'package:com.maklaar.app/data/repositories/category_repository.dart';
import 'package:com.maklaar.app/utils/helper_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// States for the fetch category operation
abstract class FetchCategoryState {
  const FetchCategoryState();
}

/// Initial state when no fetch operation has been performed
class FetchCategoryInitial extends FetchCategoryState {
  const FetchCategoryInitial();
}

/// State indicating that the fetch operation is in progress
class FetchCategoryInProgress extends FetchCategoryState {
  const FetchCategoryInProgress();
}

/// State indicating successful fetch of categories
class FetchCategorySuccess extends FetchCategoryState {
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool hasError;
  final List<CategoryModel> categories;

  const FetchCategorySuccess({
    required this.total,
    required this.page,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchCategorySuccess copyWith({
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? hasError,
    List<CategoryModel>? categories,
  }) {
    return FetchCategorySuccess(
      total: total ?? this.total,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'page': page,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'categories': categories.map((x) => x.toJson()).toList(),
    };
  }

  factory FetchCategorySuccess.fromMap(Map<String, dynamic> map) {
    return FetchCategorySuccess(
      total: map['total'] as int,
      page: map['page'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      categories: List<CategoryModel>.from(
        (map['categories']).map<CategoryModel>(
          (x) => CategoryModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchCategorySuccess.fromJson(String source) =>
      FetchCategorySuccess.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FetchCategorySuccess(total: $total, page: $page, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}

/// State indicating failure in fetching categories
class FetchCategoryFailure extends FetchCategoryState {
  final String errorMessage;

  const FetchCategoryFailure(this.errorMessage);
}

/// Cubit responsible for handling category fetching operations
class FetchCategoryCubit extends Cubit<FetchCategoryState> {
  final CategoryRepository _categoryRepository;

  /// Creates a new instance of [FetchCategoryCubit]
  FetchCategoryCubit({CategoryRepository? categoryRepository})
    : _categoryRepository = categoryRepository ?? CategoryRepository(),
      super(const FetchCategoryInitial());

  /// Fetches categories with optional force refresh and delay settings
  Future<void> fetchCategories({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      emit(const FetchCategoryInProgress());

      final categories = await _categoryRepository.fetchCategories(page: 1);

      emit(
        FetchCategorySuccess(
          total: categories.total,
          categories: categories.modelList,
          page: 1,
          hasError: false,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(FetchCategoryFailure(e.toString()));
    }
  }

  /// Gets the current list of categories
  List<CategoryModel> getCategories() {
    if (state is FetchCategorySuccess) {
      return (state as FetchCategorySuccess).categories;
    }
    return <CategoryModel>[];
  }

  /// Fetches more categories for pagination
  Future<void> fetchCategoriesMore() async {
    try {
      if (state is! FetchCategorySuccess) return;

      final currentState = state as FetchCategorySuccess;
      if (currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      final result = await _categoryRepository.fetchCategories(
        page: currentState.page + 1,
      );

      final updatedCategories = [
        ...currentState.categories,
        ...result.modelList,
      ];

      final urls = updatedCategories.map((e) => e.url!).toList();
      await HelperUtils.precacheSVG(urls);

      emit(
        FetchCategorySuccess(
          isLoadingMore: false,
          hasError: false,
          categories: updatedCategories,
          page: currentState.page + 1,
          total: result.total,
        ),
      );
    } catch (e, st) {
      log('$e $st');
      if (state is FetchCategorySuccess) {
        emit(
          (state as FetchCategorySuccess).copyWith(
            isLoadingMore: false,
            hasError: true,
          ),
        );
      }
    }
  }

  /// Checks if there are more categories to load
  bool hasMoreData() {
    if (state is FetchCategorySuccess) {
      final currentState = state as FetchCategorySuccess;
      return currentState.categories.length < currentState.total;
    }
    return false;
  }
}
