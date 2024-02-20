library titik_attachment_picker;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:photo_manager/photo_manager.dart';

import 'models/attachment_style.dart';
import 'models/attachment_type.dart';
import 'widgets/image_item_widget.dart';

late BuildContext rootContext;

final List<GlobalKey<GalleryPickerState>> galleryPickerKeys = [
  GlobalKey(),
  GlobalKey()
];

class TitikAttachmentPicker {
  TitikAttachmentPicker({
    this.height,
    this.attachmentStyle,
    this.maxImage = 10,
    this.maxVideo = 1,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.avaiableTypes = const [AttachmentType.photo, AttachmentType.video]
  });
  

  final double? height;
  final AttachmentStyle? attachmentStyle;
  final int maxImage;
  final int maxVideo;
  final Color? backgroundColor;
  final Color? textColor;
  final List<AttachmentType> avaiableTypes;

  final List<AssetEntity> selectedEntites = [];

  Future<List<AssetEntity>> open(BuildContext context) async {
    rootContext = context;
    selectedEntites.clear();
    
    await showCupertinoModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: backgroundColor,
      builder: (context) {
        return Container(
          height: height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
            color: backgroundColor,
          ),
          child: Layout(
            backgroundColor: backgroundColor,
            onTabChanged: _clearAllSelected,
            navBarItems: [
              PersistentBottomNavBarItem(
                activeColorPrimary: attachmentStyle != null && attachmentStyle!.primaryColor != null ? attachmentStyle!.primaryColor! : CupertinoColors.activeBlue,
                icon: const Icon(Icons.image_outlined),
                title: 'Фото'
              ),
              PersistentBottomNavBarItem(
                activeColorPrimary: attachmentStyle != null && attachmentStyle!.primaryColor != null ? attachmentStyle!.primaryColor! : CupertinoColors.activeBlue,
                icon: const Icon(Icons.video_collection_outlined),
                title: 'Видео'
              )
            ],
            screens: [
              GalleryPicker(
                key: galleryPickerKeys[0],
                attachmentStyle: attachmentStyle,
                requestType: RequestType.image,
                onSave: setSelectedEntities,
                maxElement: maxImage,
                backgroundColor: backgroundColor,
                textColor: textColor,
              ),
              GalleryPicker(
                key: galleryPickerKeys[1],
                attachmentStyle: attachmentStyle,
                requestType: RequestType.video,
                onSave: setSelectedEntities,
                maxElement: maxVideo,
                backgroundColor: backgroundColor,
                textColor: textColor,
              ),
            ]
          )
        );
      },
    );

    return selectedEntites;
  }

  void _clearAllSelected() {
    for(var item in galleryPickerKeys) {
      if (item.currentState != null) item.currentState!.clearSelected();
    }
  }

  void setSelectedEntities(List<AssetEntity> elements) {
    selectedEntites.clear();
    selectedEntites.addAll(elements);
    Navigator.of(rootContext).pop();
  }
}

class Layout extends StatefulWidget {
  const Layout({
    super.key,
    required this.screens,
    required this.navBarItems,
    this.onTabChanged,
    this.backgroundColor
  });

  final List<PersistentBottomNavBarItem> navBarItems;
  final List<Widget> screens;
  final void Function()? onTabChanged;
  final Color? backgroundColor;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      backgroundColor: widget.backgroundColor ?? CupertinoColors.white,
      onItemSelected:(value) {
        if (widget.onTabChanged != null) widget.onTabChanged!();
      },
      items: widget.navBarItems,
      screens: widget.screens
    );
  }
}

class GalleryPicker extends StatefulWidget {
  const GalleryPicker({
    super.key,
    this.attachmentStyle,
    this.requestType = RequestType.common,
    this.maxElement = 10,
    this.onSave,
    this.backgroundColor,
    this.textColor = Colors.black
  });

  final AttachmentStyle? attachmentStyle;
  final RequestType requestType;
  final int maxElement;
  final void Function(List<AssetEntity> elements)? onSave;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  State<GalleryPicker> createState() => GalleryPickerState();
}

class GalleryPickerState extends State<GalleryPicker> {
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
    containsLivePhotos: true
  );
  final int _sizePerPage = 50;

  AssetPathEntity? _paths;
  List<AssetEntity>? entitiesList;
  int _totalEntitiesCount = 0;

  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;

  PermissionState? _ps;

  final List<AssetEntity> _selectedEntites = [];

  void clearSelected() {
    _selectedEntites.clear();
    setState(() {
      
    });
  }

  Future<void> _requestAssets() async {
    setState(() {
      _isLoading = true;
    });
    // Request permissions.
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    _ps = ps;
    if (!mounted) {
      return;
    }
    // Further requests can be only proceed with authorized or limited.
    // if (!ps.hasAccess) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   debugPrint('Permission is not accessible.');
    //   return;
    // }
    // Obtain assets using the path entity.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: _filterOptionGroup,
      type: widget.requestType,
    );
    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (paths.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('No paths found.');
      return;
    }
    setState(() {
      _paths = paths.first;
    });
    _totalEntitiesCount = await _paths!.assetCountAsync;
    final List<AssetEntity> entities = await _paths!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      entitiesList = entities;
      _isLoading = false;
      _hasMoreToLoad = entitiesList!.length < _totalEntitiesCount;
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _paths!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      entitiesList!.addAll(entities);
      _page++;
      _hasMoreToLoad = entitiesList!.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  bool enabled() {
    return _selectedEntites.length < widget.maxElement;
  }

  int numberOfSelectedItem(AssetEntity entity) {
    return _selectedEntites.indexOf(entity);
  }

  int onSelect(int index, AssetEntity entity) {
    debugPrint("Index of gallery ${index.toString()}");
    if (_selectedEntites.contains(entity)) {
      _selectedEntites.remove(entity);
    } else {
      _selectedEntites.add(entity);
    }
    debugPrint("Selected items length ${_selectedEntites.length}");
    setState(() {});
    return numberOfSelectedItem(entity);
  }
  
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _requestAssets();
    });
    Intl.defaultLocale = 'ru';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _ps == PermissionState.authorized ? Container(color: widget.backgroundColor, child: _buildBody(context)) : Center(
      child: Text(
        'Нет разрешения на просмотр галереи',
        style: TextStyle(
          color: widget.textColor
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_paths == null) {
      return Center(child: Text(
        'Request paths first.',
        style: TextStyle(
          color: widget.textColor
        ),
      ));
    }
    if (entitiesList?.isNotEmpty != true) {
      return Center(child: Text(
        'Галерея пустая',
        style: TextStyle(
          color: widget.textColor
        ),
      ));
    }
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: widget.attachmentStyle != null && widget.attachmentStyle!.primaryColor != null ? widget.attachmentStyle!.primaryColor : null,
                      textStyle: TextStyle(color: widget.attachmentStyle != null && widget.attachmentStyle!.primaryColor != null ? widget.attachmentStyle!.primaryColor : null, fontWeight: FontWeight.w600)
                    ),
                    onPressed: () {
                      _selectedEntites.clear();
                      Navigator.pop(rootContext);
                    },
                    child: const Text(
                      'Отмена'
                    )
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      surfaceTintColor: Colors.grey,
                      foregroundColor: widget.attachmentStyle != null && widget.attachmentStyle!.primaryColor != null ? widget.attachmentStyle!.primaryColor : null, disabledForegroundColor: Colors.white.withOpacity(0.38),
                      textStyle: TextStyle(color: widget.attachmentStyle != null && widget.attachmentStyle!.primaryColor != null ? widget.attachmentStyle!.primaryColor : null, fontWeight: FontWeight.w600)
                    ),
                    onPressed: _selectedEntites.isEmpty ? null : () { if (widget.onSave != null) widget.onSave!(_selectedEntites); },
                    child: const Text(
                      'Готово'
                    )
                  ),
                ],
              ),
              Text(
                'Галерея',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: widget.textColor,
                ),
              )
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutQuad,
          padding: EdgeInsets.only(top: _selectedEntites.length < widget.maxElement ? 30 : 0),
          height: _selectedEntites.length < widget.maxElement ? 0 : 20,
          width: MediaQuery.of(context).size.width,
          alignment:  Alignment.topCenter,
          child: Text(
            'Максимальное кол-во элементов ${widget.maxElement}',
            style: TextStyle(
              fontSize: 10,
              color: widget.textColor!.withOpacity(.54),
              fontWeight: FontWeight.w600
            ),
          ),
        ),
        Expanded(
          child: GridView.custom(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index == entitiesList!.length - 6 &&
                    !_isLoadingMore &&
                    _hasMoreToLoad) {
                  _loadMoreAsset();
                }
                final AssetEntity entity = entitiesList![index];
                return ImageItemWidget(
                  key: ValueKey<int>(index),
                  entity: entity,
                  option: const ThumbnailOption(size: ThumbnailSize.square(600)),
                  enabled: enabled(),
                  attachmentStyle: widget.attachmentStyle,
                  numberOfSelectedItem: _selectedEntites.indexOf(entity),
                  onSelect: onSelect,
                );
              },
              childCount: entitiesList!.length,
              findChildIndexCallback: (Key key) {
                // Re-use elements.
                if (key is ValueKey<int>) {
                  return key.value;
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}