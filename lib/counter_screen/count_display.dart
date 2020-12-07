import 'package:contapersone/counter_screen/counter_screen.dart';
import 'package:flutter/material.dart';

class CountDisplay extends StatelessWidget {
  final List<SubcounterData> otherSubcounters;
  final SubcounterData thisSubcounter;
  final bool isDisconnected;
  final int total;
  final int capacity;
  final void Function() onEditLabel;

  const CountDisplay(
      {Key key,
      @required this.otherSubcounters,
      @required this.thisSubcounter,
      @required this.isDisconnected,
      @required this.total,
      this.onEditLabel,
      this.capacity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: () {
        if (otherSubcounters.length == 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStyledCount(
                context: context,
                count: thisSubcounter.count,
                capacity: capacity,
                disconnected: isDisconnected,
              ),
              _buildNameInput(defaultValue: 'Conteggio'),
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 60,
                child: _buildStyledCount(
                  context: context,
                  count: total,
                  capacity: capacity,
                  disconnected: isDisconnected,
                ),
              ),
              Text(
                'Conteggio totale',
                textAlign: TextAlign.center,
              ),
              Container(
                height: 20,
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
                          count: thisSubcounter.count,
                          label: thisSubcounter.label ?? 'Questo ingresso',
                        ),
                        ...otherSubcounters.map(
                          (e) => _buildOtherSubcounter(
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
      {@required BuildContext context, @required int count, String label}) {
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
                defaultValue: 'Questo ingresso',
                brightness: Brightness.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherSubcounter({@required int count, String label}) {
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
                labelDefined ? label.trim() : 'Altro ingresso',
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
    @required BuildContext context,
    @required int count,
    int capacity,
    bool disconnected = false,
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
            text: count.toString(),
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
      @required String defaultValue}) {
    final labelUndefined =
        thisSubcounter.label == null || thisSubcounter.label == '';
    return FlatButton.icon(
      icon: Opacity(
        opacity: 0.5,
        child: Icon(
          Icons.edit,
          color: brightness == Brightness.dark ? Colors.white : null,
        ),
      ),
      label: Text(
        labelUndefined ? defaultValue : thisSubcounter.label,
        style: TextStyle(
          color: brightness == Brightness.dark ? Colors.white : null,
          fontStyle: labelUndefined ? FontStyle.italic : null,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
      onPressed: onEditLabel,
    );
  }
}
