import 'package:flutter/material.dart' hide SearchDelegate;
import 'package:flutter/cupertino.dart';
import 'package:moonblink/base_widget/custom_flutter_src/search.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/provider/view_state_list_model.dart';
import 'package:moonblink/view_model/search_model.dart';
import 'package:provider/provider.dart';

class SearchSuggestions<T> extends StatelessWidget {
  final SearchDelegate<T> delegate;
  SearchSuggestions({@required this.delegate});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: IconTheme(
                data: Theme.of(context)
                    .iconTheme
                    .copyWith(opacity: 0.6, size: 16),
                child: MultiProvider(
                  providers: [
                    Provider<TextStyle>.value(
                        value: Theme.of(context).textTheme.bodyText2),
                    ProxyProvider<TextStyle, Color>(
                      update: (context, textStyle, _) =>
                          textStyle.color.withOpacity(0.5),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // SearchHotKeysWidget(delegate: delegate),
                      SearchHistoriesWidget(delegate: delegate),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SearchHistoriesWidget<T> extends StatefulWidget {
  final SearchDelegate<T> delegate;
  SearchHistoriesWidget({@required this.delegate, key}) : super(key: key);

  @override
  _SearchHistoriesWidgetState createState() => _SearchHistoriesWidgetState();
}

class _SearchHistoriesWidgetState extends State<SearchHistoriesWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Provider.of<SearchHistoryModel>(context, listen: false).initData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: null,
                child: Text(
                  S.of(context).searchHistory,
                  style: Provider.of<TextStyle>(context),
                ),
              ),
              Consumer<SearchHistoryModel>(
                builder: (context, model, child) => Visibility(
                    visible: !model.isBusy && !model.isEmpty,
                    child: model.isIdle
                        ? FlatButton.icon(
                            textColor: Provider.of<Color>(context),
                            onPressed: model.clearHistory,
                            icon: Icon(Icons.clear),
                            label: Text(S.of(context).searchClear))
                        : FlatButton.icon(
                            textColor: Provider.of<Color>(context),
                            onPressed: model.initData,
                            icon: Icon(Icons.refresh),
                            label: Text(S.of(context).searchRetry))),
              ),
            ],
          ),
        ),
        SearchSuggestionStateWidget<SearchHistoryModel, String>(
          builder: (context, item) => ActionChip(
            label: Text(item),
            onPressed: () {
              widget.delegate.query = item;
              widget.delegate.showResults(context);
            },
          ),
        ),
      ],
    );
  }
}

class SearchSuggestionStateWidget<T extends ViewStateListModel, E>
    extends StatelessWidget {
  final Widget Function(BuildContext context, E data) builder;

  SearchSuggestionStateWidget({@required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
        builder: (context, model, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: model.isIdle
                  ? Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 10,
                      children: List.generate(model.list.length, (index) {
                        E item = model.list[index];
                        return builder(context, item);
                      }),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      alignment: Alignment.center,
                      child: Builder(builder: (context) {
                        if (model.isBusy) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: CupertinoActivityIndicator(),
                          );
                        } else if (model.isError) {
                          return const Icon(
                            IconFonts.pageError,
                            size: 60,
                            color: Colors.grey,
                          );
                        } else if (model.isEmpty) {
                          return const Icon(
                            IconFonts.pageEmpty,
                            size: 70,
                            color: Colors.grey,
                          );
                        }
                        return SizedBox.shrink();
                      }),
                    ),
            ));
  }
}
