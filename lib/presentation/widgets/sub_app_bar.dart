import 'package:everyones_tone/app/config/app_color.dart';
import 'package:everyones_tone/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everyones_tone/app/enums/record_status.dart';
import 'package:everyones_tone/presentation/pages/record/record_view_model.dart';

class SubAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  
  // Constructor
  const SubAppBar({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // ViewModel을 context에서 읽어오기
    final recordViewModel = Provider.of<RecordViewModel>(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.neutrals60, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 취소 버튼
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "취소",
              style: AppTextStyle.bodyMedium(AppColor.neutrals40),
            ),
          ),

          // 모달 제목
          Text(
            title,
            style: AppTextStyle.headlineMedium(),
          ),

          // 완료 버튼
          // 음성 녹음 파일 있으면 완료 버튼 활성화하기
          Consumer<RecordViewModel>(
            builder: (context, model, child) {
              return TextButton(
                onPressed: model.recordingStatusNotifier.value == RecordStatus.complete
                    ? onPressed
                    : null, // RecordStatus가 complete일 때만 onPressed 활성화
                child: Text(
                  "완료",
                  style: AppTextStyle.bodyLarge(
                    model.recordingStatusNotifier.value == RecordStatus.complete
                        ? AppColor.primaryBlue 
                        : AppColor.neutrals60, 
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
