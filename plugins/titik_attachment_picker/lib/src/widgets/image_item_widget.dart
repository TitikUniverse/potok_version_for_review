import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../models/attachment_style.dart';
import '../picker.dart';
import 'view_content.dart';

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    Key? key,
    required this.entity,
    required this.option,
    this.onTap,
    this.onSelect,
    this.attachmentStyle,
    this.numberOfSelectedItem = -1,
    required this.enabled
  }) : super(key: key);

  /// {@template photo_manager.AssetEntity}
  /// The abstraction of assets (images/videos/audios).
  /// It represents a series of fields `MediaStore` on Android
  /// and the `PHAsset` object on iOS/macOS.
  /// {@endtemplate}
  final AssetEntity entity;

  /// The thumbnail option when requesting assets
  final ThumbnailOption option;

  /// Handler for clicking on an attachment
  final GestureTapCallback? onTap;

  /// Handler of clicking on the selection circle
  final void Function(int index, AssetEntity entity)? onSelect;

  /// UI Customization
  final AttachmentStyle? attachmentStyle;

  /// The number of the selected attachment displayed in the selection circle.
  /// Only positive numbers are displayed
  final int numberOfSelectedItem;

  /// {@template titik_attachment_picker.bool}
  /// Describes the ability to select an attachment.
  /// Requires a non-zero `numberOfSelectedItem`.
  /// {@endtemplate}
  final bool enabled;

  Widget buildContent(BuildContext context) {
    if (entity.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    }
    return _buildImageWidget(context, entity, option);
  }

  Widget _buildImageWidget(
    BuildContext context,
    AssetEntity entity,
    ThumbnailOption option,
  ) {
    initializeDateFormatting("");
    DateFormat dateFormat = DateFormat('mm:ss');

    return GestureDetector(
      onTap: () async {
        int pickerIndex;
        if (entity.type == AssetType.image) {
          pickerIndex = 0;
        } else if (entity.type == AssetType.video) {
          pickerIndex = 1;
        } else {
          return;
        }

        await context.pushTransparentRoute(ViewContent(
          entities: galleryPickerKeys[pickerIndex].currentState!.entitiesList!,
          initialIndex: (key as ValueKey<int>).value,
          attachmentStyle: attachmentStyle)
        );
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AssetEntityImage(
              entity,
              isOriginal: false,
              thumbnailSize: option.size,
              thumbnailFormat: option.format,
              fit: BoxFit.cover,
            ),
          ),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: StatefulBuilder(
              builder: (context, setState) {
                return InkWell(
                  onTap: (!enabled && numberOfSelectedItem < 0) ? null : () {
                    if (key is ValueKey<int>) {
                       int index = (key as ValueKey<int>).value;
                       if (onSelect != null) onSelect!(index, entity);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 30,
                    height: 30,
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: numberOfSelectedItem < 0 ? Colors.transparent : attachmentStyle != null ? attachmentStyle!.selectedColor : Colors.blueGrey,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: Colors.white,
                        strokeAlign: BorderSide.strokeAlignInside,
                        width: 2
                      )
                    ),
                    child: numberOfSelectedItem >= 0 ? Text(
                      (numberOfSelectedItem + 1).toString(),
                      style: attachmentStyle != null && attachmentStyle!.selectedTextStyle != null ? attachmentStyle!.selectedTextStyle : const TextStyle(
                        color: Colors.white
                      ),
                    ) : const SizedBox()
                  ),
                );
              }
            ),
          ),
          if (entity.type == AssetType.video) PositionedDirectional(
            bottom: 4,
            end: 4,
            child: Text(
              dateFormat.format(DateTime(1970, 1, 1, 0, 0, entity.duration)),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          if (entity.isFavorite) PositionedDirectional(
            bottom: 4,
            start: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 16,
              ),
            ),
          ),
          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 300),
          //   child: (!enabled && numberOfSelectedItem < 0) ? Positioned.fill(
          //     child: Container(
          //       color: Colors.black.withOpacity(.75),
          //     )
          //   ) : null
          // )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: buildContent(context),
    );
  }
}