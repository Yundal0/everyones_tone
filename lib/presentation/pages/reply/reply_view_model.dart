// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everyones_tone/app/models/chat_model.dart';
import 'package:everyones_tone/app/models/chat_message_model.dart';
import 'package:everyones_tone/app/repository/firestore_data.dart';
import 'package:everyones_tone/presentation/pages/reply/reply_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class ReplyViewModel {
  ReplyRepository replyRemoteRepository = ReplyRepository();
  FirebaseStorage storage = FirebaseStorage.instance;

  //! localAudioUrl을 Firebase Storage Url로 변경
  Future<String> convertLocalAudioToStorageUrl(String localAudioUrl) async {
    File file = File(localAudioUrl);
    try {
      // Firebase Storage에 업로드할 파일의 경로를 지정
      String fileName =
          'audio_url/${DateTime.now().millisecondsSinceEpoch}.mp4';
      Reference ref = storage.ref().child(fileName);

      // 파일 업로드 수행
      UploadTask uploadTask = ref.putFile(file);

      // 업로드 완료까지 대기
      await uploadTask.whenComplete(() => null);

      // 업로드된 파일의 URL 가져오기
      String downloadURL = await ref.getDownloadURL();

      print('downloadURL: $downloadURL');

      return downloadURL;
    } catch (e) {
      // 에러 처리
      print("오디오 파일 업로드 중 에러 발생: $e");
      return '';
    }
  }

  //! 입력받은 정보를 DB에 업로드
  Future<void> uploadReply(
      {required String localAudioUrl,
      required Map<String, dynamic> replyUserData,
      required String replyDocumentId}) async {
    // Firestore 객체 생성
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 오디오 URL 변환
    String replyUserAudioUrl =
        await convertLocalAudioToStorageUrl(localAudioUrl);
    if (replyUserAudioUrl.isEmpty) {
      print('오디오 파일 업로드 실패');
      return;
    }

    // Reply User 데이터 설정
    String replyUserNickname = replyUserData['nickname'] ?? '';
    String replyUserEmail = replyUserData['userEmail'] ?? '';
    String replyUserProfilePicUrl = replyUserData['profilePicUrl'] ?? '';
    String dateCreated = DateFormat("MM/dd HH:mm:ss").format(DateTime.now());

    /// 최초 메신저의 post data 가져오기
    DocumentSnapshot postUserData =
        await firestore.collection('post').doc(replyDocumentId).get();

    bool isCurrentUserPostUser =
        FirestoreData.currentUserEmail == postUserData['userEmail'];

    ChatModel chatModel = ChatModel(
      currentUserNickname: isCurrentUserPostUser
          ? postUserData['nickname']
          : replyUserData['nickname'],

      currentUserEmail: isCurrentUserPostUser
          ? postUserData['userEmail']
          : replyUserData['userEmail'],

      currentUserProfilePicUrl: isCurrentUserPostUser
          ? postUserData['profilePicUrl']
          : replyUserData['profilePicUrl'],

      dateCreated: dateCreated,

      partnerUserNickname: isCurrentUserPostUser
          ? replyUserData['nickname']
          : postUserData['nickname'],
      partnerUserEmail: isCurrentUserPostUser
          ? replyUserData['userEmail']
          : postUserData['userEmail'],
      partnerUserProfilePicUrl: isCurrentUserPostUser
          ? replyUserData['profilePicUrl']
          : postUserData['profilePicUrl'],

      postUserNickname: postUserData['nickname'],
      postUserEmail: postUserData['userEmail'],
      postUserProfilePicUrl: postUserData['profilePicUrl'],
      postTitle: postUserData['postTitle'],
      replyUserNickname: replyUserNickname,
      replyUserEmail: replyUserEmail,
      replyUserProfilePicUrl: replyUserProfilePicUrl,
    );

    /// Post Message Model 생성
    ChatMessageModel postMessageModel = ChatMessageModel(
        audioUrl: postUserData['audioUrl'],
        dateCreated: postUserData['dateCreated'],
        userEmail: postUserData['userEmail']);

    ChatMessageModel replyMessageModel = ChatMessageModel(
        audioUrl: replyUserAudioUrl,
        dateCreated: dateCreated,
        userEmail: replyUserEmail);

    print('ReplyViewModel 실행 완료!');

    /// Firestore 업로드
    await replyRemoteRepository.uploadReplyRemote(
        chatModel, postMessageModel, replyMessageModel, replyDocumentId);

    /// SQflite 업로드
    // await replyRemoteRepository.uploadReplyLocal(
    //     chatModel, postMessageModel, replyMessageModel);
  }
}
