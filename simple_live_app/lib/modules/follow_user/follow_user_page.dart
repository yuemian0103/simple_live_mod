import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/models/db/follow_user.dart';
import 'package:simple_live_app/models/db/follow_user_tag.dart';
import 'package:simple_live_app/modules/follow_user/follow_user_controller.dart';
import 'package:simple_live_app/routes/app_navigation.dart';
import 'package:simple_live_app/services/follow_service.dart';
import 'package:simple_live_app/widgets/filter_button.dart';
import 'package:simple_live_app/widgets/follow_user_item.dart';
import 'package:simple_live_app/widgets/page_grid_view.dart';

class FollowUserPage extends GetView<FollowUserController> {
  const FollowUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var count = MediaQuery.of(context).size.width ~/ 500;
    if (count < 1) count = 1;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        // 平台筛选Tab：默认不选中=显示全部平台；点击选中，再点同一平台取消
        title: Obx(
          () {
            var selected = controller.platformFilter.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: Sites.supportSites.map((site) {
                  var isSelected = selected == site.id;
                  return InkWell(
                    onTap: () {
                      controller.togglePlatformFilter(site.id);
                    },
                    child: Container(
                      padding: AppStyle.edgeInsetsH12.copyWith(
                        top: 14,
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: selected == "all" || isSelected ? 1 : 0.55,
                            child: Image.asset(
                              site.logo,
                              width: 20,
                            ),
                          ),
                          AppStyle.hGap8,
                          Text(
                            site.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withAlpha(140),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.save_2_line),
                      AppStyle.hGap12,
                      Text("导出文件")
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.folder_open_line),
                      AppStyle.hGap12,
                      Text("导入文件")
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.text),
                      AppStyle.hGap12,
                      Text("导出文本"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.file_text_line),
                      AppStyle.hGap12,
                      Text("导入文本"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.price_tag_line),
                      AppStyle.hGap12,
                      Text("标签管理"),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                FollowService.instance.exportFile();
              } else if (value == 1) {
                FollowService.instance.inputFile();
              } else if (value == 2) {
                FollowService.instance.exportText();
              } else if (value == 3) {
                FollowService.instance.inputText();
              } else if (value == 4) {
                showTagsManager();
              }
            },
          ),
        ],
        leading: Obx(
          () => FollowService.instance.updating.value
              ? const IconButton(
                  onPressed: null,
                  icon: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    controller.refreshData();
                  },
                  icon: const Icon(Icons.refresh),
                ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 第一行：直播状态筛选（再点一次已选中的项即可取消筛选；平台分类在标题栏Tab）
          Padding(
            padding: AppStyle.edgeInsetsL8.copyWith(top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                          spacing: 12,
                          children: controller.tagList.take(3).skip(1).map((option) {
                            return FilterButton(
                              text: option.tag,
                              selected: controller.filterMode.value == option,
                              onTap: () {
                                if (controller.filterMode.value == option) {
                                  // 已选中，再点一次取消筛选
                                  controller.setFilterMode(controller.tagList.first);
                                } else {
                                  controller.setFilterMode(option);
                                }
                              },
                            );
                          }).toList()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 第二行：自定义标签筛选（始终显示，保证标签入口可见）
          Obx(
            () => Padding(
              padding: AppStyle.edgeInsetsL8.copyWith(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 12,
                        children: [
                          if (controller.userTagList.isEmpty)
                            FilterButton(
                              text: "＋ 添加标签",
                              selected: false,
                              onTap: showTagsManager,
                            )
                          else
                            ...controller.userTagList.map((option) {
                              return FilterButton(
                                text: option.tag,
                                selected:
                                    controller.filterMode.value == option,
                                onTap: () {
                                  if (controller.filterMode.value == option) {
                                    // 已选中，再点一次取消筛选
                                    controller.setFilterMode(
                                        controller.tagList.first);
                                  } else {
                                    controller.setFilterMode(option);
                                  }
                                },
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: AppStyle.radius24,
                    onTap: showTagsManager,
                    child: Padding(
                      padding: AppStyle.edgeInsetsH12.copyWith(
                        top: 4,
                        bottom: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Remix.price_tag_line,
                            size: 14,
                            color: Colors.grey,
                          ),
                          AppStyle.hGap4,
                          Text(
                            "管理",
                            style: Get.textTheme.bodyMedium!.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageGridView(
              crossAxisSpacing: 12,
              crossAxisCount: count,
              pageController: controller,
              firstRefresh: true,
              showPCRefreshButton: false,
              itemBuilder: (_, i) {
                var item = controller.list[i];
                var site = Sites.allSites[item.siteId]!;
                return FollowUserItem(
                  item: item,
                  onRemove: () {
                    controller.removeItem(item);
                  },
                  onTap: () {
                    AppNavigator.toLiveRoomDetail(
                        site: site, roomId: item.roomId);
                  },
                  onLongPress: () {
                    setFollowTagDialog(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void setFollowTagDialog(FollowUser item) {
    /// 控制单选ui
    List<FollowUserTag> copiedList = [
      controller.tagList.first,
      ...controller.tagList.skip(3),
    ];
    Rx<FollowUserTag> checkTag =
        controller.tagList.indexOf(controller.filterMode.value) < 3
            ? copiedList.first.obs
            : controller.filterMode.value.obs;
    Get.dialog(
      AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '设置标签',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      item.userName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.check,
                  ),
                  onPressed: () {
                    controller.setItemTag(item, checkTag.value);
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: copiedList.map((tagItem) {
                  var selected = checkTag.value == tagItem;
                  return InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      checkTag.value = tagItem;
                    },
                    child: Container(
                      padding: AppStyle.edgeInsetsH12.copyWith(
                        top: 6,
                        bottom: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(Get.context!).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? Theme.of(Get.context!).colorScheme.primary
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        tagItem.tag,
                        style: selected
                            ? const TextStyle(color: Colors.white)
                            : TextStyle(
                                color: Theme.of(Get.context!)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showTagsManager() {
    Utils.showBottomSheet(
      title: '标签管理',
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppStyle.divider,
            ListTile(
              title: const Text("添加标签"),
              leading: const Icon(Icons.add),
              onTap: () {
                editTagDialog("添加标签");
              },
            ),
            AppStyle.divider,
            // 列表内容
            Expanded(
              child: Obx(
                () => ReorderableListView.builder(
                  itemCount: controller.userTagList.length,
                  itemBuilder: (context, index) {
                    // 偏移
                    FollowUserTag item = controller.userTagList[index];
                    var count = controller.userTagList[index].userId.length;
                    return ListTile(
                      key: ValueKey(item.id),
                      title: GestureDetector(
                        child: Text(item.tag),
                        onLongPress: () {
                          {
                            editTagDialog("修改标签", followUserTag: item);
                          }
                        },
                      ),
                      trailing: Text(
                        "$count人",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          controller.removeTag(item);
                        },
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    controller.updateTagOrder(oldIndex, newIndex);
                  },
                ),
              ),
            ),
          ]),
    );
  }

  void editTagDialog(String title, {FollowUserTag? followUserTag}) {
    final TextEditingController tagEditController =
        TextEditingController(text: followUserTag?.tag);
    bool upMode = title == "添加标签" ? true : false;
    Get.dialog(
      AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        content: SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              TextField(
                controller: tagEditController,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: AppStyle.edgeInsetsA12,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.withAlpha(51),
                    ),
                  ),
                ),
                onSubmitted: (tag) {
                  upMode
                      ? controller.addTag(tagEditController.text)
                      : controller.updateTagName(
                          followUserTag!, tagEditController.text);
                  Get.back();
                },
              ),
              Container(
                margin: AppStyle.edgeInsetsB4,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('否'),
                    ),
                    TextButton(
                      onPressed: () {
                        upMode
                            ? controller.addTag(tagEditController.text)
                            : controller.updateTagName(
                                followUserTag!, tagEditController.text);
                        Get.back();
                      },
                      child: const Text('是'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
