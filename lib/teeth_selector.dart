import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:teeth_selector/svg.dart';
import 'package:xml/xml.dart';

typedef Data = ({Size size, Map<String, Tooth> teeth});

class TeethSelector extends StatefulWidget {
  final bool multiSelect;
  final Color selectedColor;
  final Color unselectedColor;
  final Color tooltipColor;
  final List<String> initiallySelected;
  final Map<String, Color> colorized;
  final Map<String, Color> StrokedColorized;
  final Color defaultStrokeColor;
  final Map<String, double> strokeWidth;
  final double defaultStrokeWidth;
  final String leftString;
  final String rightString;
  final String topString;
  final String bottomString;
  final bool showPrimary;
  final bool showPermanent;
  final bool showKey;
  final void Function(List<String> selected) onChange;
  final String Function(String isoString)? notation;
  final TextStyle? textStyle;
  final TextStyle? keyTextStyle;
  final TextStyle? tooltipTextStyle;

  const TeethSelector({
    super.key,
    this.multiSelect = false,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.tooltipColor = Colors.black,
    this.initiallySelected = const [],
    this.colorized = const {},
    this.StrokedColorized = const {},
    this.defaultStrokeColor = Colors.transparent,
    this.strokeWidth = const {},
    this.defaultStrokeWidth = 1,
    this.notation,
    this.showPrimary = false,
    this.showPermanent = true,
    this.showKey = true,
    this.leftString = "Left",
    this.rightString = "Right",
    this.topString = "Top",
    this.bottomString = "Bottom",
    this.textStyle = null,
    this.keyTextStyle = null,
    this.tooltipTextStyle = null,
    required this.onChange,
  });

  @override
  State<TeethSelector> createState() => _TeethSelectorState();
}

class _TeethSelectorState extends State<TeethSelector> {
  Data data = loadTeeth();

  @override
  void initState() {
    for (var element in widget.initiallySelected) {
      if (data.teeth[element] != null) {
        data.teeth[element]!.selected = true;
      }
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    if (data.size == Size.zero) return const UnconstrainedBox();

    return FittedBox(
      child: SizedBox.fromSize(
        size: data.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 10,
              top: data.size.height * 0.5 - 11,
              child: Text(widget.rightString, style: widget.textStyle),
            ),
            Positioned(
              right: 10,
              top: data.size.height * 0.5 - 11,
              child: Text(widget.leftString, style: widget.textStyle),
            ),
            Positioned.fill(
              top: data.size.height * -0.35,
              child: Align(
                alignment: Alignment.center,
                child: Text(widget.topString, style: widget.textStyle),
              ),
            ),
            Positioned.fill(
              top: data.size.height * 0.35,
              child: Align(
                alignment: Alignment.center,
                child: Text(widget.bottomString, style: widget.textStyle),
              ),
            ),
            // teeth
            for (final MapEntry(key: key, value: tooth) in data.teeth.entries)
              if ((widget.showPrimary || int.parse(key) < 50) && (widget.showPermanent || int.parse(key) > 50)) ...[
                Positioned.fromRect(
                  rect: tooth.rect,
                  child: GestureDetector(
                    key: Key("tooth-iso-$key-${tooth.selected ? "selected" : "not-selected"}"),
                    onTap: () {
                      setState(() {
                        if (widget.multiSelect == false) {
                          for (final tooth in data.teeth.entries) {
                            if (tooth.key != key) {
                              tooth.value.selected = false;
                            }
                          }
                        }
                        tooth.selected = !tooth.selected;
                        widget.onChange(data.teeth.entries
                            .where((tooth) => tooth.value.selected)
                            .map((tooth) => tooth.key)
                            .toList());
                      });
                    },
                    child: Tooltip(
                      triggerMode: TooltipTriggerMode.longPress,
                      message: widget.notation == null ? key : widget.notation!(key),
                      textAlign: TextAlign.center,
                      textStyle: widget.tooltipTextStyle,
                      preferBelow: false,
                      decoration: BoxDecoration(color: widget.tooltipColor, boxShadow: kElevationToShadow[6]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color:
                              tooth.selected ? widget.selectedColor : widget.colorized[key] ?? widget.unselectedColor,
                          shape: ToothBorder(
                            tooth.path,
                            strokeColor: widget.StrokedColorized[key] ?? widget.defaultStrokeColor,
                            strokeWidth: widget.strokeWidth[key] ?? widget.defaultStrokeWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.showKey) ...[
                  // PERMANENT
                  // TOP LEFT
                  if ([11, 12].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left,
                      top: tooth.rect.top - 20,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([13, 14, 15].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 15,
                      top: tooth.rect.top - 10,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([16, 17, 18].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 20,
                      top: tooth.rect.top,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  // TOP RIGHT
                  if ([21, 22].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right - 15,
                      top: tooth.rect.top - 20,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([23, 24, 25].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right,
                      top: tooth.rect.top - 10,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([26, 27, 28].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right + 5,
                      top: tooth.rect.top,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  // BOTTOM RIGHT
                  if ([31, 32].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right - 15,
                      top: tooth.rect.top + tooth.rect.height + 5,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([33, 34, 35].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right,
                      top: tooth.rect.top + 30,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([36, 37, 38].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right + 5,
                      top: tooth.rect.top + 10,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  // BOTTOM LEFT
                  if ([41, 42].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left,
                      top: tooth.rect.top + tooth.rect.height + 5,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([43, 44, 45].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 15,
                      top: tooth.rect.top + 30,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([46, 47, 48].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 23,
                      top: tooth.rect.top + 10,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  // PRIMARY
                  // TOP LEFT
                  if ([51, 52].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left,
                      top: tooth.rect.top - 20,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([53].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 15,
                      top: tooth.rect.top - 10,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([54, 55].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 25,
                      top: tooth.rect.top,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  // TOP RIGHT
                  if ([61, 62].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right,
                      top: tooth.rect.top - 20,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([63].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right + 5,
                      top: tooth.rect.top - 10,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([64, 65].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right + 10,
                      top: tooth.rect.top,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  // BOTTOM LEFT
                  if ([81].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left,
                      top: tooth.rect.top + 50,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([82, 83].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 15,
                      top: tooth.rect.top + 40,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([84, 85].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.left - 25,
                      top: tooth.rect.top + 15,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  // BOTTOM RIGHT
                  if ([71].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right - 10,
                      top: tooth.rect.top + 50,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([72, 73].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right,
                      top: tooth.rect.top + 40,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                  if ([74, 75].contains(int.parse(key)))
                    Positioned(
                      left: tooth.rect.right + 10,
                      top: tooth.rect.top + 15,
                      child: Text("$key", style: widget.keyTextStyle),
                    ),
                ]
              ],
          ],
        ),
      ),
    );
  }
}

Data loadTeeth() {
  final doc = XmlDocument.parse(svgString);
  final viewBox = doc.rootElement.getAttribute('viewBox')!.split(' ');
  final w = double.parse(viewBox[2]);
  final h = double.parse(viewBox[3]);

  final teeth = doc.rootElement.findAllElements('path');
  return (
    size: Size(w, h),
    teeth: <String, Tooth>{
      for (final tooth in teeth) tooth.getAttribute('id')!: Tooth(parseSvgPathData(tooth.getAttribute('d')!)),
    },
  );
}

class Tooth {
  Tooth(Path originalPath) {
    rect = originalPath.getBounds();
    path = originalPath.shift(-rect.topLeft);
  }

  late final Path path;
  late final Rect rect;
  bool selected = false;
}

class ToothBorder extends ShapeBorder {
  final Path path;
  final double strokeWidth;
  final Color strokeColor;

  const ToothBorder(
    this.path, {
    required this.strokeWidth,
    required this.strokeColor,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return rect.topLeft == Offset.zero ? path : path.shift(rect.topLeft);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = strokeColor;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
