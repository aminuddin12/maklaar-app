import 'package:com.maklaar.app/data/cubits/setting_pages_cubit.dart';
import 'package:com.maklaar.app/ui/screens/widgets/errors/no_data_found.dart';
import 'package:com.maklaar.app/ui/theme/theme.dart';
import 'package:com.maklaar.app/utils/extensions/extensions.dart';
import 'package:com.maklaar.app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPages extends StatefulWidget {
  final String? title;
  final String? param;

  const SettingsPages({super.key, this.title, this.param});

  @override
  SettingsPagessState createState() => SettingsPagessState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => SettingsPages(
        title: arguments?['title'] as String,
        param: arguments?['param'] as String,
      ),
    );
  }
}

class SettingsPagessState extends State<SettingsPages> {
  @override
  void initState() {
    super.initState();
    fetchSettingsPagesData();
  }

  void fetchSettingsPagesData() {
    Future.delayed(Duration.zero, () {
      context
          .read<SettingsPagesCubit>()
          .fetchSettingsPages(context, widget.param!, forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          title: widget.title!, showBackButton: true),
      // appBar: Widgets.setAppbar(widget.title!, context, []),
      body: BlocBuilder<SettingsPagesCubit, SettingsPagesState>(
          builder: (context, state) {
        if (state is SettingsPagesFetchProgress) {
          return Center(
            child: UiUtils.progress(
                normalProgressColor: context.color.territoryColor),
          );
        } else if (state is SettingsPagesFetchSuccess) {
          return contentWidget(state, context);
        } else if (state is SettingsPagesFetchFailure) {
          return NoDataFound(
            onTap: fetchSettingsPagesData,
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  Widget contentWidget(SettingsPagesFetchSuccess state, BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: HtmlWidget(
        state.data.toString(),
        onTapUrl: (url) =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        customStylesBuilder: (element) {
          if (element.localName == 'table') {
            return {'background-color': 'grey[50]'};
          }
          if (element.localName == 'p') {
            return {'color': context.color.textColorDark.toString()};
          }
          if (element.localName == 'p' &&
              element.children.any((child) => child.localName == 'strong')) {
            return {
              'color': context.color.territoryColor.toString(),
              'font-size': 'larger',
            };
          }
          if (element.localName == 'tr') {
            // Customize style for `tr`
            return null; // add your custom styles here if needed
          }
          if (element.localName == 'th') {
            return {
              'background-color': 'grey',
              'border-bottom': '1px solid black',
            };
          }
          if (element.localName == 'td') {
            return {'border': '0.5px solid grey'};
          }
          if (element.localName == 'h5') {
            return {
              'max-lines': '2',
              'text-overflow': 'ellipsis',
            };
          }
          return null;
        },
      ),
    );
  }
}
