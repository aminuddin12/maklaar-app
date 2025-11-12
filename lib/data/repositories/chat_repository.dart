import 'package:dio/dio.dart';
import 'package:com.maklaar.app/data/model/chat/chat_user_model.dart';
import 'package:com.maklaar.app/data/model/data_output.dart';
import 'package:com.maklaar.app/ui/screens/chat/chat_audio/widgets/chat_widget.dart';
import 'package:com.maklaar.app/utils/api.dart';
import 'package:flutter/material.dart';

class ChatRepository {
  Future<DataOutput<ChatUser>> fetchBuyerChatList(int page) async {
    Map<String, dynamic> response = await Api.get(
        url: Api.getChatListApi,
        queryParameters: {Api.type: "buyer", Api.page: page});

    List<ChatUser> modelList = (response['data']['data'] as List).map(
      (e) {
        return ChatUser.fromJson(e);
      },
    ).toList();

    return DataOutput(total: response['data']['total'], modelList: modelList);
  }

  Future<DataOutput<ChatUser>> fetchSellerChatList(int page) async {
    Map<String, dynamic> response = await Api.get(
        url: Api.getChatListApi,
        queryParameters: {Api.page: page, Api.type: "seller"});

    List<ChatUser> modelList = (response['data']["data"] as List).map(
      (e) {
        return ChatUser.fromJson(e);
      },
    ).toList();

    return DataOutput(
        total: response['data']['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<ChatMessage>> getMessagesApi(
      {required int page, required int itemOfferId}) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.chatMessagesApi,
      queryParameters: {
        Api.itemOfferId: itemOfferId,
        Api.page: page,
      },
    );

    List<ChatMessage> modelList = (response['data']['data'] as List).map(
      (result) {
        int senderId = result['sender_id'];
        String? message = result['message'];
        String? file = result['file'];
        String? audio = result['audio'];
        String createdAt = result['created_at'];
        int itemOfferId = result['item_offer_id'];
        int id = result['id'];

        return ChatMessage(
          key: ValueKey(id),
          message: message ?? "",
          senderId: senderId,
          createdAt: createdAt,
          file: file!,
          audio: audio!,
          itemOfferId: itemOfferId,
          updatedAt: createdAt,
        );
      },
    ).toList();

    return DataOutput(
        total: response['data']['total'] ?? 0, modelList: modelList);
  }

  Future<Map<String, dynamic>> sendMessageApi(
      {required int itemOfferId,
      required String message,
      MultipartFile? audio,
      MultipartFile? attachment}) async {
    Map<String, dynamic> parameters = {
      Api.itemOfferId: itemOfferId,
    };

    if (attachment != null) {
      parameters[Api.file] = attachment;
    }
    if (audio != null) {
      parameters[Api.audio] = audio;
    }

    if (message != "") {
      parameters[Api.message] = message;
    }

    Map<String, dynamic> map =
        await Api.post(url: Api.sendMessageApi, parameter: parameters);

    return map;
  }

  Future<Map<String, dynamic>> blockUserApi({required int blockUserId}) async {
    Map<String, dynamic> parameters = {
      Api.blockedUserId: blockUserId,
    };

    Map<String, dynamic> map =
        await Api.post(url: Api.blockUserApi, parameter: parameters);

    return map;
  }

  Future<Map<String, dynamic>> unBlockUserApi(
      {required int blockUserId}) async {
    Map<String, dynamic> parameters = {
      Api.blockedUserId: blockUserId,
    };

    Map<String, dynamic> map =
        await Api.post(url: Api.unBlockUserApi, parameter: parameters);

    return map;
  }

  Future<DataOutput<BlockedUserModel>> blockedUsersListApi() async {
    Map<String, dynamic> response =
        await Api.get(url: Api.blockedUsersListApi, queryParameters: {});

    List<BlockedUserModel> modelList = (response['data'] as List).map(
      (e) {
        return BlockedUserModel.fromJson(e);
      },
    ).toList();

    return DataOutput(modelList: modelList, total: modelList.length);
  }
}
