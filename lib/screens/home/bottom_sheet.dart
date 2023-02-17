import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:aquarover/services/ui/ble_status_screen.dart';
import 'package:aquarover/services/ui/device_list.dart';

class BottomSheetModal extends StatefulWidget {
  const BottomSheetModal({super.key});

  @override
  State<BottomSheetModal> createState() => _BottomSheetModalState();
}

class _BottomSheetModalState extends State<BottomSheetModal> {
  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
        builder: (_, status, __) {
          if (status == BleStatus.ready) {
            return const DeviceListScreen();
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
