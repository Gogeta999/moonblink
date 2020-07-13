import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/indicator/story_pageview_indicator.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/view_model/story_model.dart';
import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage(this.partnerId);
  final partnerId;
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final _currentPageNotifier = ValueNotifier<int>(0);
    // final StoryController storyController = StoryController();
    return ProviderWidget<StoryModel>(
        model: StoryModel(),
        onModelReady: (storyModel) {
          storyModel.fetchStory(partnerId: widget.partnerId);
          // storyModel.initData();
          // storyModel.loadData();
        },
        builder: (context, storyModel, child) {
          return Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                  child: StepPageIndicator(
                    currentPageNotifier: _currentPageNotifier,
                    itemCount: storyModel.stories.length,
                    onPageSelected: (int pageIndex) {
                      if (_currentPageNotifier.value > pageIndex)
                        pageController.jumpToPage(pageIndex);
                    },
                  ),
                ),
              ),
              Center(
                // height: 500,
                child: SizedBox(
                  height: 400,
                  child: PageView.builder(
                      onPageChanged: (int pageIndex) {
                        _currentPageNotifier.value = pageIndex;
                      },
                      controller: pageController,
                      itemCount: storyModel.stories.length,
                      itemBuilder: (context, index) {
                        Story story = storyModel.stories[index];
                        if (story.mediaType == 2) {
                          return Container(
                            child: StoryVideo.url(story.mediaUrl,
                                controller: storyController),
                          );
                        }
                        return Container(
                          child: StoryImage.url(
                            story.mediaUrl,
                            controller: storyController,
                          ),
                        );
                      }),
                ),
              ),
            ],
          );
        });
  }
}

class Indicator extends StatelessWidget {
  Indicator({
    this.controller,
    this.itemCount: 0,
  }) : assert(controller != null);

  /// PageView的控制器
  final PageController controller;

  /// 指示器的个数
  final int itemCount;

  /// 普通的颜色
  final Color normalColor = Colors.grey;

  /// 选中的颜色
  final Color selectedColor = Colors.white;

  /// 点的大小
  final double size = 8.0;

  /// 点的间距
  final double spacing = 4.0;

  /// 点的Widget
  Widget _buildIndicator(
      int index, int pageCount, double dotSize, double spacing) {
    // 是否是当前页面被选中
    // bool isCurrentPageSelected = index ==
    //     (controller.page != null ? controller.page.round() % pageCount : 0);

    return new Container(
      height: size,
      width: size + (2 * spacing),
      child: new Center(
        child: new Material(
          color: normalColor,
          type: MaterialType.circle,
          child: new Container(
            width: dotSize,
            height: dotSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, (int index) {
        return _buildIndicator(index, itemCount, size, spacing);
      }),
    );
  }
}
