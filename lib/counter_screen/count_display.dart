import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/entities.dart';

/// A widget that displays the overall status of a counter, including its
/// subcounters
class CountDisplay extends StatelessWidget {
  final List<SubcounterData> otherSubcountersData;
  final SubcounterData thisSubcounterData;
  final bool isDisconnected;
  final int total;
  final int? capacity;
  final bool reverse;
  final void Function() onEditLabel;
  final void Function() onTotalTap;

  /// Creates a widget that displays the status of a counter, given its `total`
  /// count, the [SubcounterData] `thisSubcounterData` of the subcounter for
  /// the current device and a [List] of [SubcounterData] `otherSubcountersData`
  /// for the subcounters of other devices that share the same counter.
  ///
  /// Additionally, a `capacity` can provided to be displayed along with the
  /// total count and an `onEditCallback`can be used to allow the user to change
  /// tha label of the subcounter by pressing on it.
  const CountDisplay(
      {Key? key,
      required this.otherSubcountersData,
      required this.thisSubcounterData,
      required this.isDisconnected,
      required this.total,
      required this.onEditLabel,
      this.capacity,
      this.reverse = false,
      required this.onTotalTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final safeReverse = reverse && capacity != null;
    return Container(
      child: () {
        if (otherSubcountersData.length == 0) {
          return GestureDetector(
            onTap: this.onTotalTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStyledCount(
                  context: context,
                  count: thisSubcounterData.count,
                  capacity: capacity,
                  disconnected: isDisconnected,
                  reverse: reverse,
                ),
                _buildNameInput(
                    defaultValue:
                        AppLocalizations.of(context)!.singleSubcounterLabel),
              ],
            ),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: this.onTotalTap,
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      child: _buildStyledCount(
                        context: context,
                        count: total,
                        capacity: capacity,
                        disconnected: isDisconnected,
                        reverse: safeReverse,
                      ),
                    ),
                    Text(
                      safeReverse
                          ? AppLocalizations.of(context)!
                              .reverseCounterTotalLabel
                          : AppLocalizations.of(context)!.counterTotalLabel,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      height: 20,
                    ),
                  ],
                ),
              ),
              () {
                return Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: [
                        _buildMainSubcounter(
                          context: context,
                          count: thisSubcounterData.count,
                          label: thisSubcounterData.label ??
                              AppLocalizations.of(context)!
                                  .thisEntranceDefaultLabel,
                        ),
                        ...otherSubcountersData.map(
                          (e) => _buildOtherSubcounter(
                            context: context,
                            count: e.count,
                            label: e.label ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }(),
            ],
          );
        }
      }(),
    );
  }

  Widget _buildMainSubcounter(
      {required BuildContext context, required int count, String? label}) {
    return Container(
      height: 120,
      width: 200,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        color: Theme.of(context).primaryColor,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  child: FittedBox(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  height: 40,
                ),
              ),
              Spacer(),
              _buildNameInput(
                defaultValue:
                    AppLocalizations.of(context)!.thisEntranceDefaultLabel,
                brightness: Brightness.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherSubcounter(
      {required BuildContext context, required int count, String? label}) {
    final labelDefined = label != null && label.trim() != '';
    return Container(
      height: 100,
      width: 100,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  child: FittedBox(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  height: 40,
                ),
              ),
              Spacer(),
              Text(
                labelDefined
                    ? label!.trim()
                    : AppLocalizations.of(context)!.otherEntranceDefaultLabel,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: !labelDefined
                    ? TextStyle(fontStyle: FontStyle.italic)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledCount({
    required BuildContext context,
    required int count,
    int? capacity,
    bool disconnected = false,
    bool reverse = false,
  }) {
    Color color = disconnected ? Colors.grey : Colors.black;
    if (capacity != null) {
      if (count >= capacity) {
        color = Colors.red;
      } else if (count >= 0.9 * capacity) {
        color = Colors.orange;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: (capacity != null && reverse ? capacity - count : count)
                .toString(),
            children: [
              TextSpan(
                text: capacity != null ? '/$capacity' : '',
                style: TextStyle(
                    fontSize: 50, color: Theme.of(context).primaryColor),
              ),
            ],
            style: TextStyle(fontSize: 50, color: color),
          ),
          textAlign: TextAlign.center,
        ),
        ...(disconnected
            ? [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.cloud_off,
                  color: Colors.grey,
                  size: 40,
                )
              ]
            : []),
      ],
    );
  }

  Widget _buildNameInput(
      {Brightness brightness = Brightness.light,
      required String defaultValue}) {
    final labelUndefined =
        thisSubcounterData.label == null || thisSubcounterData.label == '';
    return LayoutBuilder(builder: (context, constraints) {
      return TextButton.icon(
        icon: Opacity(
          opacity: 0.5,
          child: Icon(
            Icons.edit,
            color: brightness == Brightness.dark ? Colors.white : null,
          ),
        ),
        label: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth - 60),
          child: Text(
            labelUndefined ? defaultValue : thisSubcounterData.label!,
            style: TextStyle(
              color: brightness == Brightness.dark ? Colors.white : null,
              fontStyle: labelUndefined ? FontStyle.italic : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        onPressed: onEditLabel,
      );
    });
  }
}
