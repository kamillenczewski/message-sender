import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/images_controller.dart';
import 'package:messenger/controllers/images_io_controller.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/pages/widgets/account_image.dart';
import 'package:messenger/widgets/operation_button.dart';

final getIt = GetIt.instance;

class SelectAccountImageDialog extends HookWidget {
  SelectAccountImageDialog({super.key});
  
  final settings = Settings.instance;
  final imagesIOController = getIt<ImagesIOController>();
  final imagesController = getIt<ImagesController>();
  final accountController = getIt<AccountController>();

  final kWidth = 350.0;

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});

    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: settings.outerColor,
          border: BoxBorder.all(color: settings.innerColor)
        ),
        width: kWidth,
        padding: const .all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            AccountImage(
              accountId: accountController.account!.id, 
              accountName: accountController.account!.name,
              radius: (kWidth - 100) / 2,
              isTooltipVisible: false,
            ),
            OperationButton(  
              title: 'Select', 
              onTap: () async {
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final accountId = getIt<AccountController>().account!.id;

                final file = await imagesIOController.saveImage(accountId, timestamp);
                if (file == null) return;
                await imagesIOController.saveEncryptedImage(accountId, timestamp);
                await imagesIOController.uploadAccountImage(accountId, timestamp);
                imagesController.setFile(accountId, file);
              } 
            ),
          ],
        )
      )
    );
  }
  
}

void showSelectAccountImageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SelectAccountImageDialog();
    },
  );
}


// Dialog(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16.0),
//           color: settings.outerColor,
//           border: BoxBorder.all(color: settings.innerColor)
//         ),
//         width: kWidth,
//         padding: const .all(15),
//         child: StatefulBuilder(
//           builder: (context, setState) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               spacing: 12,
//               children: [
//                 Text(
//                   'Select your photo',
//                   style: TextStyle(
//                     color: settings.innerColor,
//                     fontFamily: settings.fontFamily,
//                     fontSize: 20
//                   ),
//                 ),
//                  == null
//                 ?
//                 SizedBox.shrink()
//                 :
//                 CircleAvatar(
//                   radius: kWidth / 2 - 50,
//                   backgroundImage: FileImage(File(imagesController.getCurrentAccountImagePath()!))
//                 ),
//                 OperationButton(  
//                   title: 'Select', 
//                   onTap: () async {
//                     final timestamp = DateTime.now().millisecondsSinceEpoch;
//                     final accountId = getIt<AccountController>().account!.id;

//                     await imagesController.saveImage(accountId, timestamp);
//                     await imagesController.saveEncryptedImage(accountId, timestamp);
//                     await imagesController.uploadAccountImage(accountId, timestamp);
                    
//                     setState(() {});
//                   } 
//                 ),
//               ],
//             );
//           }
//         ),
//       )
//     );
//   }