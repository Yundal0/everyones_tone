import 'package:everyones_tone/app/enums/record_status.dart';
import 'package:everyones_tone/presentation/pages/record/record_view_model.dart';
import 'package:everyones_tone/presentation/widgets/buttons/record_buttons/audio_play_button.dart';
import 'package:everyones_tone/presentation/widgets/buttons/record_buttons/before_record_button.dart';
import 'package:everyones_tone/presentation/widgets/buttons/record_buttons/recording_button.dart';
import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  final RecordViewModel recordViewModel = RecordViewModel();
  RecordPage({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<RecordStatus>(
      valueListenable: recordViewModel.recordingStatusNotifier,
      builder: (context, recordStatus, child) {
        switch (recordStatus) {
          case RecordStatus.before:
            return BeforeRecordButton(recordViewModel: recordViewModel);
          case RecordStatus.recording:
            return RecordingButton(recordViewModel: recordViewModel);
          case RecordStatus.complete:
            return AudioPlayButton(recordViewModel: recordViewModel);
          default:
            return Container();
        }
      },
    );
  }
}
